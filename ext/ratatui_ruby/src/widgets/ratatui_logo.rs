use magnus::{Error, Value};
use ratatui::{layout::Rect, widgets::{RatatuiLogo, RatatuiLogoSize}, Frame};

pub fn render(frame: &mut Frame, area: Rect, _node: Value) -> Result<(), Error> {
    // RatatuiLogo does not support custom styling (it has fixed colors).
    // It requires a size argument.
    let widget = RatatuiLogo::new(RatatuiLogoSize::Small);
    frame.render_widget(widget, area);
    Ok(())
}

#[cfg(test)]
mod tests {
    use ratatui::{buffer::Buffer, layout::Rect, widgets::Widget};
    use super::*;

    #[test]
    fn test_render() {
        let mut buffer = Buffer::empty(Rect::new(0, 0, 50, 20));
        let widget = RatatuiLogo::new(RatatuiLogoSize::Small);
        widget.render(Rect::new(0, 0, 50, 20), &mut buffer);
        
        let content = buffer.content().iter().map(|c| c.symbol()).collect::<String>();
        
        // The logo uses block characters for rendering
        assert!(content.contains('█'));
        assert!(!content.trim().is_empty());
    }
}
