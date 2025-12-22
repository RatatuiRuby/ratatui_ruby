// SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
// SPDX-License-Identifier: AGPL-3.0-or-later

use magnus::{define_module, function, prelude::*, Error, IntoValue, Symbol, Value};
use ratatui::{
    backend::CrosstermBackend,
    layout::{Alignment, Constraint, Direction, Layout, Rect},
    style::{Color, Modifier, Style},
    symbols,
    text::Line,
    widgets::{
        BarChart, Block, Borders, Cell, Chart, Clear, Dataset, Gauge, List, ListState, Paragraph,
        Row, Sparkline, Table, Tabs, Wrap,
    },
    Frame, Terminal,
};
use std::io;
use std::sync::Mutex;

lazy_static::lazy_static! {
    static ref TERMINAL: Mutex<Option<Terminal<CrosstermBackend<io::Stdout>>>> = Mutex::new(None);
}

fn init_terminal() -> Result<(), Error> {
    let mut term_lock = TERMINAL.lock().unwrap();
    if term_lock.is_none() {
        crossterm::terminal::enable_raw_mode()
            .map_err(|e| Error::new(magnus::exception::runtime_error(), e.to_string()))?;
        let mut stdout = io::stdout();
        crossterm::execute!(stdout, crossterm::terminal::EnterAlternateScreen)
            .map_err(|e| Error::new(magnus::exception::runtime_error(), e.to_string()))?;
        let backend = CrosstermBackend::new(stdout);
        let terminal = Terminal::new(backend)
            .map_err(|e| Error::new(magnus::exception::runtime_error(), e.to_string()))?;
        *term_lock = Some(terminal);
    }
    Ok(())
}

fn restore_terminal() -> Result<(), Error> {
    let mut term_lock = TERMINAL.lock().unwrap();
    if let Some(mut terminal) = term_lock.take() {
        let _ = crossterm::terminal::disable_raw_mode();
        let _ = crossterm::execute!(
            terminal.backend_mut(),
            crossterm::terminal::LeaveAlternateScreen
        );
    }
    Ok(())
}

fn draw(tree: Value) -> Result<(), Error> {
    let mut term_lock = TERMINAL.lock().unwrap();
    if let Some(terminal) = term_lock.as_mut() {
        terminal
            .draw(|f| {
                if let Err(e) = render_node(f, f.size(), tree) {
                    eprintln!("Render error: {:?}", e);
                }
            })
            .map_err(|e| Error::new(magnus::exception::runtime_error(), e.to_string()))?;
    } else {
        eprintln!("Terminal is None!");
    }
    Ok(())
}

fn parse_block(block_val: Value) -> Result<Block<'static>, Error> {
    if block_val.is_nil() {
        return Ok(Block::default());
    }

    let title: Value = block_val.funcall("title", ())?;
    let borders_val: Value = block_val.funcall("borders", ())?;
    let border_color: Value = block_val.funcall("border_color", ())?;

    let mut block = Block::default();

    if !title.is_nil() {
        let title_str: String = title.funcall("to_s", ())?;
        block = block.title(title_str);
    }

    if !borders_val.is_nil() {
        let mut ratatui_borders = Borders::NONE;
        if let Some(sym) = Symbol::from_value(borders_val) {
            match sym.to_string().as_str() {
                "all" => ratatui_borders = Borders::ALL,
                "top" => ratatui_borders = Borders::TOP,
                "bottom" => ratatui_borders = Borders::BOTTOM,
                "left" => ratatui_borders = Borders::LEFT,
                "right" => ratatui_borders = Borders::RIGHT,
                _ => {}
            }
        } else if let Some(borders_array) = magnus::RArray::from_value(borders_val) {
            for i in 0..borders_array.len() {
                let sym: Symbol = borders_array.entry(i as isize)?;
                match sym.to_string().as_str() {
                    "all" => ratatui_borders |= Borders::ALL,
                    "top" => ratatui_borders |= Borders::TOP,
                    "bottom" => ratatui_borders |= Borders::BOTTOM,
                    "left" => ratatui_borders |= Borders::LEFT,
                    "right" => ratatui_borders |= Borders::RIGHT,
                    _ => {}
                }
            }
        }
        block = block.borders(ratatui_borders);
    }

    if !border_color.is_nil() {
        let color_str: String = border_color.funcall("to_s", ())?;
        if let Some(color) = parse_color(&color_str) {
            block = block.border_style(Style::default().fg(color));
        }
    }

    Ok(block)
}

fn render_node(frame: &mut Frame, area: Rect, node: Value) -> Result<(), Error> {
    let class = node.class();
    let class_name = unsafe { class.name() };

    match class_name.as_ref() {
        "RatatuiRuby::Paragraph" => {
            let text: String = node.funcall("text", ())?;
            let style_val: Value = node.funcall("style", ())?;
            let block_val: Value = node.funcall("block", ())?;
            let wrap: bool = node.funcall("wrap", ())?;
            let align_sym: Symbol = node.funcall("align", ())?;

            let style = parse_style(style_val)?;
            let mut paragraph = Paragraph::new(text).style(style);

            if !block_val.is_nil() {
                paragraph = paragraph.block(parse_block(block_val)?);
            }

            if wrap {
                paragraph = paragraph.wrap(Wrap { trim: true });
            }

            match align_sym.to_string().as_str() {
                "center" => paragraph = paragraph.alignment(Alignment::Center),
                "right" => paragraph = paragraph.alignment(Alignment::Right),
                _ => {}
            }

            frame.render_widget(paragraph, area);
        }
        "RatatuiRuby::Cursor" => {
            let x: u16 = node.funcall("x", ())?;
            let y: u16 = node.funcall("y", ())?;
            frame.set_cursor(area.x + x, area.y + y);
        }
        "RatatuiRuby::Overlay" => {
            let layers_val: Value = node.funcall("layers", ())?;
            let layers_array = magnus::RArray::from_value(layers_val).ok_or_else(|| {
                Error::new(magnus::exception::type_error(), "expected array for layers")
            })?;

            for i in 0..layers_array.len() {
                let layer: Value = layers_array.entry(i as isize)?;
                if let Err(e) = render_node(frame, area, layer) {
                    eprintln!("Error rendering overlay layer {}: {:?}", i, e);
                }
            }
        }
        "RatatuiRuby::Center" => {
            let child: Value = node.funcall("child", ())?;
            let width_percent: u16 = node.funcall("width_percent", ())?;
            let height_percent: u16 = node.funcall("height_percent", ())?;

            let popup_layout = Layout::default()
                .direction(Direction::Vertical)
                .constraints([
                    Constraint::Percentage((100 - height_percent) / 2),
                    Constraint::Percentage(height_percent),
                    Constraint::Percentage((100 - height_percent) / 2),
                ])
                .split(area);

            let vertical_center_area = popup_layout[1];

            let popup_layout_horizontal = Layout::default()
                .direction(Direction::Horizontal)
                .constraints([
                    Constraint::Percentage((100 - width_percent) / 2),
                    Constraint::Percentage(width_percent),
                    Constraint::Percentage((100 - width_percent) / 2),
                ])
                .split(vertical_center_area);

            let center_area = popup_layout_horizontal[1];

            frame.render_widget(Clear, center_area);
            render_node(frame, center_area, child)?;
        }
        "RatatuiRuby::Layout" => {
            let direction_sym: Symbol = node.funcall("direction", ())?;
            let children_val: Value = node.funcall("children", ())?;
            let children_array = magnus::RArray::from_value(children_val)
                .ok_or_else(|| Error::new(magnus::exception::type_error(), "expected array"))?;

            let constraints_val: Value = node.funcall("constraints", ())?;
            let constraints_array = magnus::RArray::from_value(constraints_val);

            let direction = if direction_sym.to_string() == "vertical" {
                Direction::Vertical
            } else {
                Direction::Horizontal
            };

            let len = children_array.len();
            if len > 0 {
                let mut ratatui_constraints = Vec::new();

                if let Some(arr) = constraints_array {
                    for i in 0..arr.len() {
                        let constraint_obj: Value = arr.entry(i as isize)?;
                        let type_sym: Symbol = constraint_obj.funcall("type", ())?;
                        let value: u16 = constraint_obj.funcall("value", ())?;

                        match type_sym.to_string().as_str() {
                            "length" => ratatui_constraints.push(Constraint::Length(value)),
                            "percentage" => ratatui_constraints.push(Constraint::Percentage(value)),
                            "min" => ratatui_constraints.push(Constraint::Min(value)),
                            _ => {}
                        }
                    }
                }

                // If constraints don't match children, adjust or default
                if ratatui_constraints.len() != len {
                    ratatui_constraints = (0..len)
                        .map(|_| Constraint::Percentage(100 / (len as u16).max(1)))
                        .collect();
                }

                let chunks = Layout::default()
                    .direction(direction)
                    .constraints(ratatui_constraints)
                    .split(area);

                for i in 0..len {
                    let child: Value = children_array.entry(i as isize)?;
                    if let Err(e) = render_node(frame, chunks[i], child) {
                        eprintln!("Error rendering child {}: {:?}", i, e);
                    }
                }
            }
        }
        "RatatuiRuby::List" => {
            let items_val: Value = node.funcall("items", ())?;
            let items_array = magnus::RArray::from_value(items_val)
                .ok_or_else(|| Error::new(magnus::exception::type_error(), "expected array"))?;
            let selected_index_val: Value = node.funcall("selected_index", ())?;
            let block_val: Value = node.funcall("block", ())?;

            let mut items = Vec::new();
            for i in 0..items_array.len() {
                let item: String = items_array.entry(i as isize)?;
                items.push(item);
            }

            let mut state = ListState::default();
            if !selected_index_val.is_nil() {
                let index: usize = selected_index_val.funcall("to_int", ())?;
                state.select(Some(index));
            }

            let mut list = List::new(items).highlight_symbol(">> ");

            if !block_val.is_nil() {
                list = list.block(parse_block(block_val)?);
            }

            frame.render_stateful_widget(list, area, &mut state);
        }
        "RatatuiRuby::Gauge" => {
            let ratio: f64 = node.funcall("ratio", ())?;
            let label_val: Value = node.funcall("label", ())?;
            let style_val: Value = node.funcall("style", ())?;
            let block_val: Value = node.funcall("block", ())?;

            let mut gauge = Gauge::default().ratio(ratio);

            if !label_val.is_nil() {
                let label_str: String = label_val.funcall("to_s", ())?;
                gauge = gauge.label(label_str);
            }

            if !style_val.is_nil() {
                gauge = gauge.gauge_style(parse_style(style_val)?);
            }

            if !block_val.is_nil() {
                gauge = gauge.block(parse_block(block_val)?);
            }

            frame.render_widget(gauge, area);
        }
        "RatatuiRuby::Table" => {
            let header_val: Value = node.funcall("header", ())?;
            let rows_val: Value = node.funcall("rows", ())?;
            let rows_array = magnus::RArray::from_value(rows_val).ok_or_else(|| {
                Error::new(magnus::exception::type_error(), "expected array for rows")
            })?;
            let widths_val: Value = node.funcall("widths", ())?;
            let widths_array = magnus::RArray::from_value(widths_val).ok_or_else(|| {
                Error::new(magnus::exception::type_error(), "expected array for widths")
            })?;
            let block_val: Value = node.funcall("block", ())?;

            let mut rows = Vec::new();
            for i in 0..rows_array.len() {
                let row_val: Value = rows_array.entry(i as isize)?;
                let row_array = magnus::RArray::from_value(row_val).ok_or_else(|| {
                    Error::new(magnus::exception::type_error(), "expected array for row")
                })?;

                let mut cells = Vec::new();
                for j in 0..row_array.len() {
                    let cell_val: Value = row_array.entry(j as isize)?;
                    let class = cell_val.class();
                    let class_name = unsafe { class.name() };

                    if class_name.as_ref() == "RatatuiRuby::Paragraph" {
                        let text: String = cell_val.funcall("text", ())?;
                        let style_val: Value = cell_val.funcall("style", ())?;
                        let cell_style = parse_style(style_val)?;
                        cells.push(Cell::from(text).style(cell_style));
                    } else if class_name.as_ref() == "RatatuiRuby::Style" {
                        // Not sure if this makes sense but let's see
                        cells.push(Cell::from("").style(parse_style(cell_val)?));
                    } else {
                        let cell_str: String = cell_val.funcall("to_s", ())?;
                        cells.push(Cell::from(cell_str));
                    }
                }
                rows.push(Row::new(cells));
            }

            let mut constraints = Vec::new();
            for i in 0..widths_array.len() {
                let constraint_obj: Value = widths_array.entry(i as isize)?;
                let type_sym: Symbol = constraint_obj.funcall("type", ())?;
                let value: u16 = constraint_obj.funcall("value", ())?;

                match type_sym.to_string().as_str() {
                    "length" => constraints.push(Constraint::Length(value)),
                    "percentage" => constraints.push(Constraint::Percentage(value)),
                    "min" => constraints.push(Constraint::Min(value)),
                    _ => {}
                }
            }

            let mut table = Table::new(rows, constraints);

            if !header_val.is_nil() {
                let header_array = magnus::RArray::from_value(header_val).ok_or_else(|| {
                    Error::new(magnus::exception::type_error(), "expected array for header")
                })?;
                let mut header_cells = Vec::new();
                for i in 0..header_array.len() {
                    let cell_val: Value = header_array.entry(i as isize)?;
                    let class = cell_val.class();
                    let class_name = unsafe { class.name() };

                    if class_name.as_ref() == "RatatuiRuby::Paragraph" {
                        let text: String = cell_val.funcall("text", ())?;
                        let style_val: Value = cell_val.funcall("style", ())?;
                        let cell_style = parse_style(style_val)?;
                        header_cells.push(Cell::from(text).style(cell_style));
                    } else {
                        let cell_str: String = cell_val.funcall("to_s", ())?;
                        header_cells.push(Cell::from(cell_str));
                    }
                }
                table = table.header(Row::new(header_cells));
            }

            if !block_val.is_nil() {
                table = table.block(parse_block(block_val)?);
            }

            frame.render_widget(table, area);
        }
        "RatatuiRuby::Tabs" => {
            let titles_val: Value = node.funcall("titles", ())?;
            let selected_index: usize = node.funcall("selected_index", ())?;
            let block_val: Value = node.funcall("block", ())?;

            let titles_array = magnus::RArray::from_value(titles_val).ok_or_else(|| {
                Error::new(magnus::exception::type_error(), "expected array for titles")
            })?;

            let mut titles = Vec::new();
            for i in 0..titles_array.len() {
                let title: String = titles_array.entry(i as isize)?;
                titles.push(Line::from(title));
            }

            let mut tabs = Tabs::new(titles).select(selected_index);

            if !block_val.is_nil() {
                tabs = tabs.block(parse_block(block_val)?);
            }

            frame.render_widget(tabs, area);
        }
        "RatatuiRuby::BarChart" => {
            let data_val: magnus::RHash = node.funcall("data", ())?;
            let bar_width: u16 = node.funcall("bar_width", ())?;
            let bar_gap: u16 = node.funcall("bar_gap", ())?;
            let max_val: Value = node.funcall("max", ())?;
            let style_val: Value = node.funcall("style", ())?;
            let block_val: Value = node.funcall("block", ())?;

            let keys: magnus::RArray = data_val.funcall("keys", ())?;
            let mut labels = Vec::new();
            let mut data_vec = Vec::new();

            for i in 0..keys.len() {
                let key: Value = keys.entry(i as isize)?;
                let val: u64 = data_val.funcall("[]", (key,))?;
                let label: String = key.funcall("to_s", ())?;
                labels.push(label);
                data_vec.push(val);
            }

            let chart_data: Vec<(&str, u64)> = labels
                .iter()
                .zip(data_vec.iter())
                .map(|(l, v)| (l.as_str(), *v))
                .collect();

            let mut bar_chart = BarChart::default()
                .data(&chart_data)
                .bar_width(bar_width)
                .bar_gap(bar_gap);

            if !max_val.is_nil() {
                let max: u64 = u64::try_convert(max_val)?;
                bar_chart = bar_chart.max(max);
            }

            if !style_val.is_nil() {
                bar_chart = bar_chart.style(parse_style(style_val)?);
            }

            if !block_val.is_nil() {
                bar_chart = bar_chart.block(parse_block(block_val)?);
            }

            frame.render_widget(bar_chart, area);
        }
        "RatatuiRuby::Sparkline" => {
            let data_val: magnus::RArray = node.funcall("data", ())?;
            let max_val: Value = node.funcall("max", ())?;
            let style_val: Value = node.funcall("style", ())?;
            let block_val: Value = node.funcall("block", ())?;

            let mut data_vec = Vec::new();
            for i in 0..data_val.len() {
                let val: u64 = data_val.entry(i as isize)?;
                data_vec.push(val);
            }

            let mut sparkline = Sparkline::default().data(&data_vec);

            if !max_val.is_nil() {
                let max: u64 = u64::try_convert(max_val)?;
                sparkline = sparkline.max(max);
            }

            if !style_val.is_nil() {
                sparkline = sparkline.style(parse_style(style_val)?);
            }

            if !block_val.is_nil() {
                sparkline = sparkline.block(parse_block(block_val)?);
            }

            frame.render_widget(sparkline, area);
        }
        "RatatuiRuby::LineChart" => {
            let datasets_val: magnus::RArray = node.funcall("datasets", ())?;
            let x_labels_val: magnus::RArray = node.funcall("x_labels", ())?;
            let y_labels_val: magnus::RArray = node.funcall("y_labels", ())?;
            let y_bounds_val: magnus::RArray = node.funcall("y_bounds", ())?;
            let block_val: Value = node.funcall("block", ())?;

            let mut datasets = Vec::new();
            // We need to keep the data alive until the chart is rendered
            let mut data_storage: Vec<Vec<(f64, f64)>> = Vec::new();
            let mut name_storage: Vec<String> = Vec::new();

            for i in 0..datasets_val.len() {
                let ds_val: Value = datasets_val.entry(i as isize)?;
                let name: String = ds_val.funcall("name", ())?;
                let data_array: magnus::RArray = ds_val.funcall("data", ())?;

                let mut points = Vec::new();
                for j in 0..data_array.len() {
                    let point_array_val: Value = data_array.entry(j as isize)?;
                    let point_array =
                        magnus::RArray::from_value(point_array_val).ok_or_else(|| {
                            Error::new(magnus::exception::type_error(), "expected array for point")
                        })?;
                    let x_val: Value = point_array.entry(0)?;
                    let y_val: Value = point_array.entry(1)?;

                    let x: f64 = x_val.funcall("to_f", ())?;
                    let y: f64 = y_val.funcall("to_f", ())?;
                    points.push((x, y));
                }

                data_storage.push(points);
                name_storage.push(name);
            }

            for i in 0..data_storage.len() {
                let ds_val: Value = datasets_val.entry(i as isize)?;
                let color_val: Value = ds_val.funcall("color", ())?;
                let color_str: String = color_val.funcall("to_s", ())?;
                let color = parse_color(&color_str).unwrap_or(Color::White);

                let ds = Dataset::default()
                    .name(name_storage[i].clone())
                    .marker(symbols::Marker::Braille)
                    .style(Style::default().fg(color))
                    .data(&data_storage[i]);
                datasets.push(ds);
            }

            let mut x_labels = Vec::new();
            for i in 0..x_labels_val.len() {
                let label: String = x_labels_val.entry(i as isize)?;
                x_labels.push(ratatui::text::Span::from(label));
            }

            let mut y_labels = Vec::new();
            for i in 0..y_labels_val.len() {
                let label: String = y_labels_val.entry(i as isize)?;
                y_labels.push(ratatui::text::Span::from(label));
            }

            let y_bounds: [f64; 2] = [y_bounds_val.entry(0)?, y_bounds_val.entry(1)?];

            // Calculate x_bounds based on datasets if possible
            let mut min_x = 0.0;
            let mut max_x = 0.0;
            let mut first = true;
            for ds_data in &data_storage {
                for (x, _) in ds_data {
                    if first {
                        min_x = *x;
                        max_x = *x;
                        first = false;
                    } else {
                        if *x < min_x {
                            min_x = *x;
                        }
                        if *x > max_x {
                            max_x = *x;
                        }
                    }
                }
            }

            // Ensure there's some range
            if min_x == max_x {
                max_x = min_x + 1.0;
            }

            let x_axis = ratatui::widgets::Axis::default()
                .labels(x_labels)
                .bounds([min_x, max_x]);

            let y_axis = ratatui::widgets::Axis::default()
                .labels(y_labels)
                .bounds(y_bounds);

            let mut chart = Chart::new(datasets).x_axis(x_axis).y_axis(y_axis);

            if !block_val.is_nil() {
                chart = chart.block(parse_block(block_val)?);
            }

            frame.render_widget(chart, area);
        }
        _ => {}
    }
    Ok(())
}

fn poll_event() -> Result<Value, Error> {
    if crossterm::event::poll(std::time::Duration::from_millis(16))
        .map_err(|e| Error::new(magnus::exception::runtime_error(), e.to_string()))?
    {
        let event = crossterm::event::read()
            .map_err(|e| Error::new(magnus::exception::runtime_error(), e.to_string()))?;

        if let crossterm::event::Event::Key(key) = event {
            if key.kind == crossterm::event::KeyEventKind::Press {
                let hash = magnus::RHash::new();
                hash.aset(Symbol::new("type"), Symbol::new("key"))?;

                let code = match key.code {
                    crossterm::event::KeyCode::Char(c) => c.to_string(),
                    crossterm::event::KeyCode::Up => "up".to_string(),
                    crossterm::event::KeyCode::Down => "down".to_string(),
                    crossterm::event::KeyCode::Left => "left".to_string(),
                    crossterm::event::KeyCode::Right => "right".to_string(),
                    crossterm::event::KeyCode::Enter => "enter".to_string(),
                    crossterm::event::KeyCode::Esc => "esc".to_string(),
                    crossterm::event::KeyCode::Backspace => "backspace".to_string(),
                    crossterm::event::KeyCode::Tab => "tab".to_string(),
                    _ => "unknown".to_string(),
                };
                hash.aset(Symbol::new("code"), code)?;

                let mut modifiers = Vec::new();
                if key
                    .modifiers
                    .contains(crossterm::event::KeyModifiers::CONTROL)
                {
                    modifiers.push("ctrl");
                }
                if key.modifiers.contains(crossterm::event::KeyModifiers::ALT) {
                    modifiers.push("alt");
                }
                if key
                    .modifiers
                    .contains(crossterm::event::KeyModifiers::SHIFT)
                {
                    modifiers.push("shift");
                }
                if !modifiers.is_empty() {
                    hash.aset(Symbol::new("modifiers"), modifiers)?;
                }

                return Ok(hash.into_value());
            }
        }
    }
    Ok(magnus::value::qnil().into_value())
}

fn parse_color(color_str: &str) -> Option<Color> {
    color_str.parse::<Color>().ok()
}

fn parse_style(style_val: Value) -> Result<Style, Error> {
    if style_val.is_nil() {
        return Ok(Style::default());
    }

    let mut style = Style::default();

    let fg: Value = style_val.funcall("fg", ())?;
    if !fg.is_nil() {
        let fg_str: String = fg.funcall("to_s", ())?;
        if let Some(color) = parse_color(&fg_str) {
            style = style.fg(color);
        }
    }

    let bg: Value = style_val.funcall("bg", ())?;
    if !bg.is_nil() {
        let bg_str: String = bg.funcall("to_s", ())?;
        if let Some(color) = parse_color(&bg_str) {
            style = style.bg(color);
        }
    }

    let modifiers_val: Value = style_val.funcall("modifiers", ())?;
    if !modifiers_val.is_nil() {
        let modifiers_array = magnus::RArray::from_value(modifiers_val).ok_or_else(|| {
            Error::new(
                magnus::exception::type_error(),
                "expected array for modifiers",
            )
        })?;

        for i in 0..modifiers_array.len() {
            let sym: Symbol = modifiers_array.entry(i as isize)?;
            match sym.to_string().as_str() {
                "bold" => style = style.add_modifier(Modifier::BOLD),
                "italic" => style = style.add_modifier(Modifier::ITALIC),
                "dim" => style = style.add_modifier(Modifier::DIM),
                "reversed" => style = style.add_modifier(Modifier::REVERSED),
                "underlined" => style = style.add_modifier(Modifier::UNDERLINED),
                "slow_blink" => style = style.add_modifier(Modifier::SLOW_BLINK),
                "rapid_blink" => style = style.add_modifier(Modifier::RAPID_BLINK),
                "crossed_out" => style = style.add_modifier(Modifier::CROSSED_OUT),
                "hidden" => style = style.add_modifier(Modifier::HIDDEN),
                _ => {}
            }
        }
    }

    Ok(style)
}

#[magnus::init]
fn init() -> Result<(), Error> {
    let m = define_module("RatatuiRuby")?;
    m.define_module_function("init_terminal", function!(init_terminal, 0))?;
    m.define_module_function("restore_terminal", function!(restore_terminal, 0))?;
    m.define_module_function("draw", function!(draw, 1))?;
    m.define_module_function("poll_event", function!(poll_event, 0))?;
    Ok(())
}

#[cfg(test)]
mod tests {
    use super::*;
    use ratatui::style::Color;
    use ratatui::widgets::Widget;

    #[test]
    fn test_parse_color() {
        assert_eq!(parse_color("red"), Some(Color::Red));
        assert_eq!(parse_color("blue"), Some(Color::Blue));
        assert_eq!(parse_color("#ffffff"), Some(Color::Rgb(255, 255, 255)));
        assert_eq!(parse_color("#000000"), Some(Color::Rgb(0, 0, 0)));
        assert_eq!(parse_color("invalid"), None);
    }

    #[test]
    fn test_sparkline_render() {
        let mut buf = ratatui::buffer::Buffer::empty(Rect::new(0, 0, 10, 1));
        let data = vec![1, 2, 3];
        let sparkline = Sparkline::default().data(&data);
        sparkline.render(Rect::new(0, 0, 10, 1), &mut buf);
        // Check if anything was rendered. Braille patterns or blocks.
        // For Sparkline, it renders something.
        assert!(buf.content().iter().any(|c| c.symbol() != " "));
    }

    #[test]
    fn test_line_chart_render() {
        let mut buf = ratatui::buffer::Buffer::empty(Rect::new(0, 0, 20, 10));
        let data = vec![(0.0, 0.0), (1.0, 1.0)];
        let datasets = vec![Dataset::default().data(&data)];
        let chart = Chart::new(datasets)
            .x_axis(ratatui::widgets::Axis::default().bounds([0.0, 1.0]))
            .y_axis(ratatui::widgets::Axis::default().bounds([0.0, 1.0]));
        chart.render(Rect::new(0, 0, 20, 10), &mut buf);
        assert!(buf.content().iter().any(|c| c.symbol() != " "));
    }
}
