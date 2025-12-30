use magnus::{prelude::*, Error, Symbol, Value};
use ratatui::{
    style::{Color, Modifier, Style},
    text::Line,
    widgets::{Block, BorderType, Borders, Padding},
    layout::Alignment,
    symbols,
};
use bumpalo::Bump;

pub fn parse_color(color_str: &str) -> Option<Color> {
    color_str.parse::<Color>().ok()
}

pub fn parse_color_value(val: Value) -> Result<Option<Color>, Error> {
    if val.is_nil() {
        return Ok(None);
    }
    let s: String = val.funcall("to_s", ())?;
    Ok(parse_color(&s))
}

pub fn parse_modifier_str(s: &str) -> Option<Modifier> {
    match s {
        "bold" => Some(Modifier::BOLD),
        "italic" => Some(Modifier::ITALIC),
        "dim" => Some(Modifier::DIM),
        "reversed" => Some(Modifier::REVERSED),
        "underlined" => Some(Modifier::UNDERLINED),
        "slow_blink" => Some(Modifier::SLOW_BLINK),
        "rapid_blink" => Some(Modifier::RAPID_BLINK),
        "crossed_out" => Some(Modifier::CROSSED_OUT),
        "hidden" => Some(Modifier::HIDDEN),
        _ => None,
    }
}

pub fn parse_style(style_val: Value) -> Result<Style, Error> {
    let ruby = magnus::Ruby::get().unwrap();
    if style_val.is_nil() {
        return Ok(Style::default());
    }

    let mut style = Style::default();

    let (fg, bg, modifiers_val) = if let Some(hash) = magnus::RHash::from_value(style_val) {
        (
            hash.lookup(ruby.to_symbol("fg")).unwrap_or_else(|_| ruby.qnil().as_value()),
            hash.lookup(ruby.to_symbol("bg")).unwrap_or_else(|_| ruby.qnil().as_value()),
            hash.lookup(ruby.to_symbol("modifiers")).unwrap_or_else(|_| ruby.qnil().as_value()),
        )
    } else {
        (
            style_val.funcall("fg", ())?,
            style_val.funcall("bg", ())?,
            style_val.funcall("modifiers", ())?,
        )
    };

    if !fg.is_nil() {
        if let Ok(fg_str) = fg.funcall::<_, _, String>("to_s", ()) {
            if let Some(color) = parse_color(&fg_str) {
                style = style.fg(color);
            }
        }
    }

    if !bg.is_nil() {
        if let Ok(bg_str) = bg.funcall::<_, _, String>("to_s", ()) {
            if let Some(color) = parse_color(&bg_str) {
                style = style.bg(color);
            }
        }
    }

    if !modifiers_val.is_nil() {
        if let Some(modifiers_array) = magnus::RArray::from_value(modifiers_val) {
            for i in 0..modifiers_array.len() {
                let index = isize::try_from(i).map_err(|e| Error::new(ruby.exception_range_error(), e.to_string()))?;
                if let Ok(sym) = modifiers_array.entry::<Symbol>(index) {
                    if let Some(m) = parse_modifier_str(&sym.to_string()) {
                        style = style.add_modifier(m);
                    }
                }
            }
        }
    }

    Ok(style)
}

pub fn parse_border_set<'a>(set_val: Value, bump: &'a Bump) -> Result<symbols::border::Set<'a>, Error> {
    let ruby = magnus::Ruby::get().unwrap();
    let hash = magnus::RHash::from_value(set_val).ok_or_else(|| {
        Error::new(ruby.exception_type_error(), "expected hash for border_set")
    })?;

    let get_char = |key: &str| -> Result<Option<&'a str>, Error> {
        let mut val: Value = hash.lookup(ruby.to_symbol(key)).unwrap_or_else(|_| ruby.qnil().as_value());
        if val.is_nil() {
            val = hash.lookup(ruby.str_new(key)).unwrap_or_else(|_| ruby.qnil().as_value());
        }
        if val.is_nil() {
            Ok(None)
        } else {
            let s: String = val.funcall("to_s", ())?;
            Ok(Some(bump.alloc_str(&s)))
        }
    };

    let mut set = symbols::border::Set::default();
    if let Some(s) = get_char("top_left")? { set.top_left = s; }
    if let Some(s) = get_char("top_right")? { set.top_right = s; }
    if let Some(s) = get_char("bottom_left")? { set.bottom_left = s; }
    if let Some(s) = get_char("bottom_right")? { set.bottom_right = s; }
    if let Some(s) = get_char("vertical_left")? { set.vertical_left = s; }
    if let Some(s) = get_char("vertical_right")? { set.vertical_right = s; }
    if let Some(s) = get_char("horizontal_top")? { set.horizontal_top = s; }
    if let Some(s) = get_char("horizontal_bottom")? { set.horizontal_bottom = s; }

    Ok(set)
}

pub fn parse_block(block_val: Value, bump: &Bump) -> Result<Block<'_>, Error> {
    if block_val.is_nil() { return Ok(Block::default()); }

    let mut block = Block::default();
    if let Ok(v) = block_val.funcall::<&str, _, Value>("style", ()) {
        if !v.is_nil() { block = block.style(parse_style(v)?); }
    }

    if let Ok(v) = block_val.funcall::<&str, _, Value>("title_style", ()) {
        if !v.is_nil() { block = block.title_style(parse_style(v)?); }
    }

    if let Ok(title) = block_val.funcall::<&str, _, Value>("title", ()) {
        if !title.is_nil() { 
            let s: String = title.funcall("to_s", ())?;
            block = block.title(Line::from(s));
        }
    }

    if let Ok(v) = block_val.funcall::<&str, _, Value>("title_alignment", ()) {
        if let Some(align_sym) = Symbol::from_value(v) {
            match align_sym.to_string().as_str() {
                "center" => block = block.title_alignment(Alignment::Center),
                "right" => block = block.title_alignment(Alignment::Right),
                _ => block = block.title_alignment(Alignment::Left),
            }
        }
    }

    block = parse_titles(block_val, block)?;
    block = parse_borders(block_val, block, bump)?;
    block = parse_padding(block_val, block);

    Ok(block)
}

fn parse_titles(block_val: Value, mut block: Block<'_>) -> Result<Block<'_>, Error> {
    if let Ok(titles_val) = block_val.funcall::<&str, _, Value>("titles", ()) {
        if titles_val.is_nil() { return Ok(block); }
        if let Some(titles_array) = magnus::RArray::from_value(titles_val) {
            for i in 0..titles_array.len() {
                let ruby = magnus::Ruby::get().unwrap();
                let index = isize::try_from(i).map_err(|e| Error::new(ruby.exception_range_error(), e.to_string()))?;
                let title_item: Value = titles_array.entry(index)?;
                let mut content = String::new();
                let mut alignment = Alignment::Left;
                let mut is_bottom = false;
                let mut style = Style::default();

                if let Some(hash) = magnus::RHash::from_value(title_item) {
                    if let Ok(v) = hash.lookup::<_, Value>(ruby.to_symbol("content")) { 
                        if !v.is_nil() { content = v.funcall("to_s", ())?; }
                    }
                    if let Ok(v) = hash.lookup::<_, Value>(ruby.to_symbol("alignment")) {
                        if let Some(s) = Symbol::from_value(v) {
                            match s.to_string().as_str() {
                                "center" => alignment = Alignment::Center,
                                "right" => alignment = Alignment::Right,
                                _ => {}
                            }
                        }
                    }
                    if let Ok(v) = hash.lookup::<_, Value>(ruby.to_symbol("position")) {
                        if let Some(s) = Symbol::from_value(v) {
                            if s.to_string().as_str() == "bottom" { is_bottom = true; }
                        }
                    }
                    if let Ok(v) = hash.lookup::<_, Value>(ruby.to_symbol("style")) { 
                        if !v.is_nil() { style = parse_style(v)?; }
                    }
                } else {
                    content = title_item.funcall("to_s", ())?;
                }

                let line = Line::from(content).alignment(alignment).style(style);
                block = if is_bottom { block.title_bottom(line) } else { block.title_top(line) };
            }
        }
    }
    Ok(block)
}

fn parse_borders<'a>(block_val: Value, mut block: Block<'a>, bump: &'a Bump) -> Result<Block<'a>, Error> {
    if let Ok(borders_val) = block_val.funcall::<&str, _, Value>("borders", ()) {
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
            } else if let Some(arr) = magnus::RArray::from_value(borders_val) {
                for i in 0..arr.len() {
                    let ruby = magnus::Ruby::get().unwrap();
                    let index = isize::try_from(i).map_err(|e| Error::new(ruby.exception_range_error(), e.to_string()))?;
                    let sym: Symbol = arr.entry(index)?;
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
    }

    if let Ok(v) = block_val.funcall::<&str, _, Value>("border_style", ()) {
        if !v.is_nil() { block = block.border_style(parse_style(v)?); }
        else if let Ok(color_val) = block_val.funcall::<&str, _, Value>("border_color", ()) {
            if !color_val.is_nil() {
                if let Ok(s) = color_val.funcall::<&str, _, String>("to_s", ()) {
                    if let Some(c) = parse_color(&s) { block = block.border_style(Style::default().fg(c)); }
                }
            }
        }
    }

    if let Ok(v) = block_val.funcall::<&str, _, Value>("border_set", ()) {
        if !v.is_nil() { block = block.border_set(parse_border_set(v, bump)?); }
        else if let Ok(v) = block_val.funcall::<&str, _, Value>("border_type", ()) {
            if let Some(sym) = Symbol::from_value(v) {
                match sym.to_string().as_str() {
                    "rounded" => block = block.border_type(BorderType::Rounded),
                    "double" => block = block.border_type(BorderType::Double),
                    "thick" => block = block.border_type(BorderType::Thick),
                    "quadrant_inside" => block = block.border_type(BorderType::QuadrantInside),
                    "quadrant_outside" => block = block.border_type(BorderType::QuadrantOutside),
                    _ => block = block.border_type(BorderType::Plain),
                }
            }
        }
    }
    Ok(block)
}

fn parse_padding(block_val: Value, block: Block<'_>) -> Block<'_> {
    if let Ok(padding_val) = block_val.funcall::<&str, _, Value>("padding", ()) {
        if padding_val.is_nil() { return block; }
        if let Ok(p) = u16::try_convert(padding_val) {
            return block.padding(Padding::uniform(p));
        }
        if let Some(arr) = magnus::RArray::from_value(padding_val) {
            if arr.len() == 4 {
                let left: u16 = arr.entry(0).unwrap_or(0);
                let right: u16 = arr.entry(1).unwrap_or(0);
                let top: u16 = arr.entry(2).unwrap_or(0);
                let bottom: u16 = arr.entry(3).unwrap_or(0);
                return block.padding(Padding::new(left, right, top, bottom));
            }
        }
    }
    block
}
