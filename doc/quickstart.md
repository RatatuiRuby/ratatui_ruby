<!--
  SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
  SPDX-License-Identifier: CC-BY-SA-4.0
-->
# Quickstart

Welcome to **ratatui_ruby**! This guide will help you get up and running with your first Terminal User Interface in Ruby.

## Installation

Add this line to your application's Gemfile:

```ruby
gem "ratatui_ruby"


And then execute:

```bash
bundle install


Or install it yourself as:

```bash
gem install ratatui_ruby


## Basic Application

Here is a "Hello World" application that demonstrates the core lifecycle of a **ratatui_ruby** app.

```ruby
require "ratatui_ruby"
 
# 1. Initialize the terminal
RatatuiRuby.init_terminal
 
begin
  # The Main Loop
  loop do
    # 2. Create your UI (Immediate Mode)
    # We define a Paragraph widget inside a Block with a title and borders.
    view = RatatuiRuby::Paragraph.new(
      text: "Hello, Ratatui! Press 'q' to quit.",
      align: :center,
      block: RatatuiRuby::Block.new(
        title: "My Ruby TUI App",
        title_alignment: :center,
        borders: [:all],
        border_color: "cyan",
        style: { fg: "white" }
      )
    )
 
    # 3. Draw the UI
    RatatuiRuby.draw(view)
 
    # 4. Poll for events
    event = RatatuiRuby.poll_event
    break if event == "q" || event == :ctrl_c
  end
ensure
  # 5. Restore the terminal to its original state
  RatatuiRuby.restore_terminal
end


<pre class="terminal-preview" data-example="quickstart_lifecycle">
┌My Ruby TUI App───────────────────────────────────────────────────────────────┐
│                      Hello, Ratatui! Press 'q' to quit.                      │
│                                                                              │
│                                                                              │
│                                                                              │
│                                                                              │
│                                                                              │
│                                                                              │
│                                                                              │
│                                                                              │
│                                                                              │
│                                                                              │
│                                                                              │
│                                                                              │
│                                                                              │
│                                                                              │
│                                                                              │
│                                                                              │
│                                                                              │
│                                                                              │
│                                                                              │
│                                                                              │
│                                                                              │
└──────────────────────────────────────────────────────────────────────────────┘
</pre>

### How it works

1.  **`RatatuiRuby.init_terminal`**: Enters raw mode and switches to the alternate screen.
2.  **Immediate Mode UI**: On every iteration of the loop, you describe what the UI should look like by creating `Data` objects (like `Paragraph` and `Block`).
3.  **`RatatuiRuby.draw(view)`**: The Ruby UI tree is passed to the Rust backend, which renders it to the terminal.
4.  **`RatatuiRuby.poll_event`**: Checks for keyboard, mouse, or resize events.
5.  **`RatatuiRuby.restore_terminal`**: Crucial for leaving raw mode and returning the user to their shell properly. Always wrap your loop in a `begin...ensure` block to guarantee this runs.

### Idiomatic Session

You can simplify your code by using `RatatuiRuby.run`. This method handles the terminal lifecycle for you, yielding a `Session` object with factory methods for widgets.

```rb
require "ratatui_ruby"

# 1. Initialize the terminal and ensure it is restored.
RatatuiRuby.run do |tui|
  loop do
    # 2. Create your UI with methods instead of classes.
    view = tui.paragraph(
      text: "Hello, Ratatui! Press 'q' to quit.",
      align: :center,
      block: tui.block(
        title: "My Ruby TUI App",
        title_alignment: :center,
        borders: [:all],
        border_color: "cyan",
        style: { fg: "white" }
      )
    )

    # 3. Use RatatuiRuby methods, too.
    tui.draw(view)
    event = tui.poll_event
    
    break if event == "q" || event == :ctrl_c
  end
end


#### How it works

1.  **`RatatuiRuby.run`**: This context manager initializes the terminal before the block starts and ensures `restore_terminal` is called when the block exits (even if an error occurs).
2.  **Widget Shorthand**: The block yields a `Session` object (here named `tui`). This object provides factory methods for every widget, allowing you to write `tui.paragraph(...)` instead of the more verbose `RatatuiRuby::Paragraph.new(...)`.
3.  **Method Shorthand**: The session object also provides aliases for module functions of `RatatuiRuby`, allowing you to write `tui.draw(...)` instead of the more verbose `RatatuiRuby::draw(...)`.

For a deeper dive into the available application architectures (Manual vs Managed), see [Application Architecture](./application_architecture.md).

## Examples

To see more complex layouts and widget usage, check out the `examples/` directory in the repository.

### [Analytics](https://git.sr.ht/~kerrick/ratatui_ruby/tree/main/item/examples/analytics/app.rb)
Demonstrates the use of `Tabs` and `BarChart` widgets with a simple data-switching mechanism. Features custom highlight styles, base styles, and dividers for the tabs, as well as toggling the `BarChart::direction` between vertical and horizontal, and customizing `BarChart::label_style` (x) and `BarChart::value_style` (z).

<pre class="terminal-preview" data-example="analytics">
┌Views─────────────────────────────────────────────────────────────────────────┐
│ Revenue  |  Traffic  |  Errors                                               │
└──────────────────────────────────────────────────────────────────────────────┘
┌Analytics: Revenue────────────────────────────────────────────────────────────┐
│         ████████                                                             │
│         ████████                                                             │
│         ████████                                                             │
│         ████████                                                             │
│▄▄▄▄▄▄▄▄ ████████                                                             │
│████████ ████████                                                             │
│████████ ████████                                                             │
│████████ ████████                                                             │
│████████ ████████                                                             │
│████████ ████████                                                             │
│████████ ████████                                                             │
│███50███ ███80███                                                             │
│   Q1       Q2                                                                │
└──────────────────────────────────────────────────────────────────────────────┘
┌Controls──────────────────────────────────────────────────────────────────────┐
│←/→: Navigate Tab  v: Direction (vertical)  q: Quit                           │
│h/l: Pad Left (0)  j/k: Pad Right (0)  d: Divider ( | )                       │
│space: Highlight (Yellow Bold)  x: Label (Yellow Bold)  space: Highlight (Yell│
│z: Value (Yellow Bold)                                                        │
└──────────────────────────────────────────────────────────────────────────────┘
</pre>

### [All Events](https://git.sr.ht/~kerrick/ratatui_ruby/tree/main/item/examples/all_events/app.rb)
A comprehensive demonstration of every event type supported by **ratatui_ruby**: Key, Mouse, Resize, Paste, and Focus events.

<pre class="terminal-preview" data-example="all_events">
               All Event Types Demo — Press 'q' or Ctrl+C to quit               
┌⌨️   Key Events────────────────────────┐┌🖱️   Mouse Events──────────────────────┐
│           Press any key...           ││          Click or scroll...          │
│                                      ││                                      │
│                                      ││                                      │
│                                      ││                                      │
│                                      ││                                      │
│                                      ││                                      │
│                                      ││                                      │
│                                      ││                                      │
│                                      ││                                      │
│                                      ││                                      │
└──────────────────────────────────────┘└──────────────────────────────────────┘
┌📐  Resize Events──────────────────────┐┌✨  Paste & Focus Events───────────────┐
│                 80×24                ││     Paste text or change focus...    │
│                                      ││                                      │
│                                      ││                                      │
│                                      ││                                      │
│                                      ││                                      │
│                                      ││                                      │
│                                      ││                                      │
│                                      ││                                      │
│                                      ││                                      │
└──────────────────────────────────────┘└──────────────────────────────────────┘
</pre>

### [Block Padding](https://git.sr.ht/~kerrick/ratatui_ruby/tree/main/item/examples/block_padding/app.rb)
Demonstrates the `padding` property of the `Block` widget, supporting both uniform and directional padding.

<pre class="terminal-preview" data-example="block_padding">
┌Uniform Padding (2)───────────────────────────────────────────────────────────┐
│                                                                              │
│                                                                              │
│  This text is padded by 2 on all sides.                                      │
│  Notice the space between the border and this text.                          │
│                                                                              │
│                                                                              │
│                                                                              │
│                                                                              │
└──────────────────────────────────────────────────────────────────────────────┘
┌Directional Padding [Left: 4, Right: 0, Top: 2, Bottom: 0]────────────────────┐
│                                                                              │
│                                                                              │
│    This text has different padding per side.                                 │
│    Left: 4, Top: 2.                                                          │
│                                                                              │
│                                                                              │
│                                                                              │
│                                                                              │
└──────────────────────────────────────────────────────────────────────────────┘
Press 'q' to quit.                                                              
                                                                                
                                                                                
                                                                                
</pre>

### [Block Titles](https://git.sr.ht/~kerrick/ratatui_ruby/tree/main/item/examples/block_titles/app.rb)
Demonstrates the `Block` widget's ability to render multiple titles with individual alignment and positioning (top/bottom).

<pre class="terminal-preview" data-example="block_titles">
┌Top Left─────────────────────────────────────────────────────────────Top Right┐
│                                                                              │
│                                                                              │
│                                                                              │
│                                                                              │
│                                                                              │
│                                                                              │
│                                                                              │
│                                                                              │
└──────────────────────────────────────────────────────────────────────────────┘
┌──────────────────────────────────────────────────────────────────────────────┐
│                                                                              │
│                                                                              │
│                                                                              │
│                                                                              │
│                                                                              │
│                                                                              │
│                                                                              │
│                                                                              │
└Bottom Left─────────────────────Bottom Center─────────────────────Bottom Right┘
┌Simple String Title (Top Left Default)────────────────────────────────────────┐
│                                                                              │
│                                                                              │
└─────────────────────────────────Mixed Title──────────────────────────────────┘
</pre>


### [Box Demo](https://git.sr.ht/~kerrick/ratatui_ruby/tree/main/item/examples/box_demo/app.rb)
A simple demonstration of `Block` and `Paragraph` widgets, reacting to key presses to change colors, border styles, and title styling (`title_style`).

<pre class="terminal-preview" data-example="box_demo">
┌Box Demo──────────────────────────────────────────────────────────────────────┐
│                           Arrow Keys: Change Color                           │
│                                                                              │
│                             Current Color: Green                             │
│                                                                              │
│                                                                              │
│                                                                              │
│                                                                              │
│                                                                              │
│                                                                              │
│                                                                              │
│                                                                              │
│                                                                              │
│                                                                              │
│                                                                              │
│                                                                              │
│                                                                              │
│                                                                              │
└──────────────────────────────────────────────────────────────────────────────┘
┌Controls──────────────────────────────────────────────────────────────────────┐
│↑↓←→: Color (Green)  q: Quit                                                  │
│space: Border Type (Plain)  s: Style (Default)                                │
│enter: Align Title (Left)  t: Title Style (Default)                           │
└──────────────────────────────────────────────────────────────────────────────┘
</pre>

### [Calendar Demo](https://git.sr.ht/~kerrick/ratatui_ruby/tree/main/item/examples/calendar_demo/app.rb)
A simple demo application for the `Calendar` widget.

<pre class="terminal-preview" data-example="calendar_demo">
┌ Calendar (q = quit) ─┐                                                        
│    December 2025     │                                                        
│ Su Mo Tu We Th Fr Sa │                                                        
│     1  2  3  4  5  6 │                                                        
│  7  8  9 10 11 12 13 │                                                        
│ 14 15 16 17 18 19 20 │                                                        
│ 21 22 23 24 25 26 27 │                                                        
│ 28 29 30 31          │                                                        
│                      │                                                        
└──────────────────────┘                                                        
                                                                                
                                                                                
                                                                                
                                                                                
                                                                                
                                                                                
                                                                                
                                                                                
                                                                                
                                                                                
                                                                                
                                                                                
                                                                                
                                                                                
</pre>

### [Chart Demo](https://git.sr.ht/~kerrick/ratatui_ruby/tree/main/item/examples/chart_demo/app.rb)
Demonstrates the `Chart` widget with both scatter and line datasets, including custom axes.

<pre class="terminal-preview" data-example="chart_demo">
┌Chart Demo (Q to quit)────────────────────────────────────────────────────────┐
│1 │Amplitude⡰⠒⠉⠉⠑⢄                                        ⢀⠔⠊⠉⠉⠑⢄    ┌───────┐│
│  │       ⡠⠋      ⠑⡄                                     ⡠⠃      ⠣⡀  │Scatter││
│  │      ⡰⠁        ⠘⢄                    •              ⡜      •  ⠘⢄ │Line • ││
│  │     ⡜           ⠈⢆                                 ⡜           ⠈⢆└───────┘│
│  │    ⡸             ⠈⢆  •                            ⡜             ⠘⡄        │
│  │   ⡰⠁              ⠘⡄                             ⡸               ⠘⡄       │
│  │  ⢠⠃                ⠘⡄                           ⡰⠁   •            ⠱⡀      │
│  │ ⢀⠇                  ⢱                          ⢠⠃                  ⢣      │
│  │ ⡜             •     •⢣                        ⢀⠎                   ⠈⢆     │
│  │⡸                     ⠈⡆ •                     ⡜  •                  ⠘⡄•   │
│0 │⠁                  •   ⠘⡄                   • ⡰⠁                      ⠘⡄   │
│  │                        ⢱                    ⢠⠃                        ⢱   │
│  │     •                •  ⢣                  ⢀⠎                          ⢣  │
│  │                          ⢇                 ⡎•                          ⠈⡆ │
│  │                          ⠈⢆               ⡜          •   •     •        ⠘⡄│
│  │                           ⠘⡄     •       ⡜                               ⠘│
│  │                            ⠘⡄           ⡜                                 │
│  │                             ⠈⢆         ⡜                                  │
│  │                              ⠈⢢      ⢠⠊                                   │
│-1│                                ⠉⠢⢄⣀⡠⠔⠁                                Time│
│  └───────────────────────────────────────────────────────────────────────────│
│  0                                     5                                   10│
└──────────────────────────────────────────────────────────────────────────────┘
</pre>

### [Custom Widget (Escape Hatch)](https://git.sr.ht/~kerrick/ratatui_ruby/tree/main/item/examples/custom_widget/app.rb)
Demonstrates how to define a custom widget in pure Ruby using the `render(area, buffer)` escape hatch for low-level drawing.

<pre class="terminal-preview" data-example="custom_widget">
Above custom widget                                                             
                                                                                
                                                                                
                                                                                
                                                                                
                                                                                
                                                                                
                                                                                
                                                                                
                                                                                
                                                                                
                                                                                
\                                                                               
 \                                                                              
  \                                                                             
   \                                                                            
    \                                                                           
     \                                                                          
      \                                                                         
       \                                                                        
        \                                                                       
         \                                                                      
          \                                                                     
                                                                                
</pre>


### [Flex Layout](https://git.sr.ht/~kerrick/ratatui_ruby/tree/main/item/examples/flex_layout/app.rb)
Demonstrates modern layout features including `Constraint.fill` and `Constraint.ratio` for proportional space distribution and `flex: :space_between` for evenly distributing fixed-size elements.

<pre class="terminal-preview" data-example="flex_layout">
┌Header────────────────────────────────────────────────────────────────────────┐
│Fill & Flex Layout Demo (press 'q' to quit)                                   │
└──────────────────────────────────────────────────────────────────────────────┘
┌Fill(1)───────────┐┌Fill(3)───────────────────────────────────────────────────┐
│                  ││                                                          │
│                  ││                                                          │
│                  ││                                                          │
└──────────────────┘└──────────────────────────────────────────────────────────┘
┌Block A───┐                      ┌Block B───┐                      ┌Block C───┐
│          │                      │          │                      │          │
│          │                      │          │                      │          │
│          │                      │          │                      │          │
│          │                      │          │                      │          │
└──────────┘                      └──────────┘                      └──────────┘
           ┌Even A────┐           ┌Even B────┐           ┌Even C────┐           
           │          │           │          │           │          │           
           │          │           │          │           │          │           
           │          │           │          │           │          │           
           └──────────┘           └──────────┘           └──────────┘           
┌Ratio(1, 4)───────┐┌Ratio(3, 4)───────────────────────────────────────────────┐
│                  ││                                                          │
│                  ││                                                          │
│                  ││                                                          │
└──────────────────┘└──────────────────────────────────────────────────────────┘
</pre>

### [LineGauge Demo](https://git.sr.ht/~kerrick/ratatui_ruby/tree/main/item/examples/line_gauge_demo/app.rb)
Demonstrates the `LineGauge` widget with customizable filled and unfilled symbols, base style support via the `style` parameter, independent styling for filled/unfilled portions, and interactive ratio cycling with arrow keys.

<pre class="terminal-preview" data-example="line_gauge_demo">
LineGauge Widget Demo - Cycle attributes with hotkeys                           
┌Interactive Gauge─────────────────────────────────────────────────────────────┐
│50% █████████████████████████████████████░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░│
│                                                                              │
└──────────────────────────────────────────────────────────────────────────────┘
┌Inverse (100% - ratio)────────────────────────────────────────────────────────┐
│50% █████████████████████████████████████░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░│
│                                                                              │
└──────────────────────────────────────────────────────────────────────────────┘
                                                                                
                                                                                
                                                                                
                                                                                
                                                                                
                                                                                
                                                                                
                                                                                
                                                                                
                                                                                
┌Controls──────────────────────────────────────────────────────────────────────┐
│←/→: Ratio (50%)  b: Base Style (None)  q: Quit                               │
│f: Filled Symbol (█ (Block))  c: Filled Color (Green)                         │
│u: Unfilled Symbol (░ (Light Shade))  x: Unfilled Color (Dark Gray)           │
└──────────────────────────────────────────────────────────────────────────────┘
</pre>

### [List Demo](https://git.sr.ht/~kerrick/ratatui_ruby/tree/main/item/examples/list_demo/app.rb)
Demonstrates the `List` widget with interactive attribute cycling. Features multiple item sets to browse, customizable highlight styles and symbols, and exploration of all List options including direction, highlight spacing, repeat symbol mode, scroll padding, and base styling. The sidebar provides hotkey documentation for discovering all List features, including the new `p` key to adjust scroll padding.

<pre class="terminal-preview" data-example="list_demo">
List Widget Demo - Interactive Attribute Cycling                                
┌Large List (Selection: none)──────────────────────────────────────────────────┐
│Item 1                                                                        │
│Item 2                                                                        │
│Item 3                                                                        │
│Item 4                                                                        │
│Item 5                                                                        │
│Item 6                                                                        │
│Item 7                                                                        │
│Item 8                                                                        │
│Item 9                                                                        │
│Item 10                                                                       │
│Item 11                                                                       │
│Item 12                                                                       │
│Item 13                                                                       │
│Item 14                                                                       │
└──────────────────────────────────────────────────────────────────────────────┘
┌Controls──────────────────────────────────────────────────────────────────────┐
│i: Items  ↑/↓: Navigate  x: Select  h: Highlight (Blue Bold)                  │
│y: Symbol (>> )  d: Direction (Top to Bottom)                                 │
│s: Spacing (When Selected)  p: Scroll Padding (None)                          │
│b: Base (None)  r: Repeat (Off)  q: Quit                                      │
│                                                                              │
└──────────────────────────────────────────────────────────────────────────────┘
</pre>

### [Login Form](https://git.sr.ht/~kerrick/ratatui_ruby/tree/main/item/examples/login_form/app.rb)
Shows how to use `Overlay`, `Center`, and `Cursor` to build a modal login form with text input.

<pre class="terminal-preview" data-example="login_form">
                                                                                
                                                                                
                                                                                
                                                                                
                                                                                
                                                                                
                                                                                
                                                                                
                                                                                
                                                                                
                    ┌Login Form────────────────────────────┐                    
                    │Enter Username: [  ]                  │                    
                    │                                      │                    
                    └──────────────────────────────────────┘                    
                                                                                
                                                                                
                                                                                
                                                                                
                                                                                
                                                                                
                                                                                
                                                                                
                                                                                
                                                                                
</pre>

### [Map Demo](https://git.sr.ht/~kerrick/ratatui_ruby/tree/main/item/examples/map_demo/app.rb)
Exhibits the `Canvas` widget's power, rendering a world map along with animated circles and lines.

<pre class="terminal-preview" data-example="map_demo">
┌World Map ['b' background, 'm' marker: braille]───────────────────────────────┐
│                     ⣀⢀⣀⣀⡀   ⢀⣀⡀ ⡀                                            │
│            ⢠⣤⣰⣦⣶⣶⣿⣭⣿⣣⠶⠶⣿⣉⣉⠉⠉⠁  ⠁⠉⢽⠎⠁    ⠲⠶⠶⠖   ⠐⠛⢃⡀⣀⢤   ⢀⣐⣋⣷⠶⡤⣀    ⣀⡀⣀⡀      │
│⢖⡀⡀⣤⡖⠒⠒⠤⠤⠤⠤⠶⠿⠿⣿⣹⢿⣿⣿⢿⣭⣽⣿⡒⣦⣀⠘⣷⠄  ⢀⡀⢼⣏⢀      ⡠⠤⠒⠶⡤⢀⣄⡀⢻⠯⠤⢾⣻⡗⠛⠉    ⠈⠉⠈⠈⠙⠒⠚⠋ ⠒⠐⠦⠤⠤⠤⠶│
│⠉⠉⠻⣿⣃⣀⣤⡤⣄⣀⡀       ⢠⠒⠛⠳⡟⠳⣿⣏ ⠙⠦⠴⠋⠁ ⠈⠛⠋⠁⢀⡀ ⣖⡉⢰⢾⣥⡄⠙⠉⠁     ⠈              ⢀⣀⣀⡠⣤⣦⢤⠤⠛│
│   ⠒⠛⠉⠁   ⠿⣄⡀      ⠉⠓⢖⠎ ⢀⣘⣲⡄        ⠰⣾⣟⣄⠼⠛⠟⠚⠁                       ⠺⣶  ⢪⠜⠁   │
│           ⠈⡟          ⢸⠭⠿⠛⠛        ⢀⡤⣿⢀⣠⣴⣆⡀⢀⣴⣶⢆ ⡶⣆               ⢀⣀⡔⣽⡅       │
│            ⠳⣀       ⢀⣺⠉            ⠘⣧⢴⠧⠼⡿⠟⠻⣿⢭⣬⠉ ⠸⠿             ⢺⠟⣿⣠⣶⡟        │
│             ⠘⢿⣄  ⡔⠒⠒⣿⡄            ⢀⡼    ⠈⠙⠋⠉⠛⣿⡀ ⢶⣤⣄⣀⡀          ⢠⡇⠈⠋          │
│    ⠐⠦        ⠈⠉⢧⣘⢆⣴⡞⠛⣷⣤⣄          ⣯          ⣸⣷⡊⠉⣉⡽ ⠙⢲ ⢀⡴⠻⣄ ⢰⣶⠚⢙⡁            │
│                 ⠈⠉⠛⢯⣇⣠⣴⢤⣤⡀        ⢧⡀      ⡠⠔⠊ ⠙⠷⢮⠅   ⠈⣇⣏  ⠉⣷⢄⠵ ⣸⣷⡄           │
│                     ⢉⡇   ⠙⠲⡄       ⠙⠒⢒⣊⡲⡔⠉     ⣀⠎     ⠈⠋  ⠰⡿⡆⣠⠔⣗⣙⣣           │
│                     ⢼      ⠉⠓⠲⣄      ⠈⠁⠈⢢     ⡼⠁           ⠘⢽⣝⣒⣻⡯⡛⢻⣮⢒⣦⡶⣄⡀    │
│⡀                    ⠈⢢⡀      ⢰⠃         ⢸     ⢹⢀⣴             ⠉⠉⣙⣥⠖⣎⣽⡌⠃ ⠙⢀⡀ ⢀│
│⠁                      ⢸    ⢀⣀⠏          ⠸⡄   ⣲⠁⡝⡞             ⣤⠖⠋  ⠈⠁⠑⣆  ⠶⠁ ⠉│
│                       ⢸   ⢀⠞             ⢳  ⡰⠃ ⠉⠁             ⢹ ⢀⣀⣀⢀  ⢸⠆     │
│                       ⡎⢀⣠⠽⠉              ⠈⠉⠉                  ⠈⠉⠉ ⠈⠛⠦⣤⠎    ⣷⡄│
│                      ⢸⠇⢴⠁                           ⢀⡀               ⠛   ⠰⠾⠋ │
│                      ⠘⠶⠧⠐⠛                          ⠈⠁                       │
│                        ⢀⣠⡤                       ⣀⡀         ⡀ ⣀    ⡀         │
│         ⢀⣀⣀⣀⣀⣀⡀⢠⣤⣄⣀⣀⣀⣠⣴⡿⢳         ⣀⡤⠤⠤⠤⠔⠶⠖⠲⠤⠒⠒⠒⠋⠉⠁⠉⠉⠹⠶⠒⠋⠉⠉⠉⠉⠈⠉⠈⠉⠉⠉⠉⠉⠉⠉⠒⠒⠲⢤⣤  │
│   ⠰⠶⣶⣶⠏⠉⠉  ⠉ ⠈⠉⠉⠁    ⠶⢞⣩⣥⡄⣤⣶⣶⣀⣶⡶⠉⠉⠉                                     ⣠⣿   │
│⠉⠉⠉⠉⠒⠘⠙⠓⠃                 ⠉                                               ⠈⠁⠉⠉│
└──────────────────────────────────────────────────────────────────────────────┘
</pre>

### [Mouse Events](https://git.sr.ht/~kerrick/ratatui_ruby/tree/main/item/examples/mouse_events/app.rb)
Detailed plumbing of mouse events, including clicks, drags, and movement tracking.

<pre class="terminal-preview" data-example="mouse_events">
                                                                                
                                                                                
                                                                                
                                                                                
                                                                                
                                                                                
┌Mouse Event Plumbing──────────────────────────────────────────────────────────┐
│                       Waiting for Mouse... (q to quit)                       │
│                                                                              │
│                                                                              │
│                                                                              │
│                                                                              │
│                                                                              │
│                                                                              │
│                                                                              │
│                                                                              │
│                                                                              │
└──────────────────────────────────────────────────────────────────────────────┘
                                                                                
                                                                                
                                                                                
                                                                                
                                                                                
                                                                                
</pre>

### [Popup Demo](https://git.sr.ht/~kerrick/ratatui_ruby/tree/main/item/examples/popup_demo/app.rb)
Demonstrates the `Clear` widget and how to prevent "style bleed" when rendering opaque popups over colored backgrounds.

<pre class="terminal-preview" data-example="popup_demo">
BACKGROUND RED BACKGROUND RED BACKGROUND RED BACKGROUND RED BACKGROUND RED      
BACKGROUND RED BACKGROUND RED BACKGROUND RED BACKGROUND RED BACKGROUND RED      
BACKGROUND RED BACKGROUND RED BACKGROUND RED BACKGROUND RED BACKGROUND RED      
BACKGROUND RED BACKGROUND RED BACKGROUND RED BACKGROUND RED BACKGROUND RED      
BACKGROUND RED BACKGROUND RED BACKGROUND RED BACKGROUND RED BACKGROUND RED      
BACKGROUND RED BACKGROUND RED BACKGROUND RED BACKGROUND RED BACKGROUND RED      
BACKGROUND RED B┌Popup Demo (q to quit, space to toggle)───────┐GROUND RED      
BACKGROUND RED B│CKGROUND RED B✗ Clear is DISABLEDROUND RED BAC│GROUND RED      
BACKGROUND RED B│CKGROUND RED BACKGROUND RED BACKGROUND RED BAC│GROUND RED      
BACKGROUND RED B│CKGROUND RStyle Bleed: Popup is RED!ND RED BAC│GROUND RED      
BACKGROUND RED B│CKGROUND R(Inherits background style)D RED BAC│GROUND RED      
BACKGROUND RED B│CKGROUND RED BACKGROUND RED BACKGROUND RED BAC│GROUND RED      
BACKGROUND RED B│CKGROUND RED Press Space to toggleOUND RED BAC│GROUND RED      
BACKGROUND RED B│CKGROUND RED BACKGROUND RED BACKGROUND RED BAC│GROUND RED      
BACKGROUND RED B│CKGROUND RED BACKGROUND RED BACKGROUND RED BAC│GROUND RED      
BACKGROUND RED B│CKGROUND RED BACKGROUND RED BACKGROUND RED BAC│GROUND RED      
BACKGROUND RED B│CKGROUND RED BACKGROUND RED BACKGROUND RED BAC│GROUND RED      
BACKGROUND RED B└──────────────────────────────────────────────┘GROUND RED      
BACKGROUND RED BACKGROUND RED BACKGROUND RED BACKGROUND RED BACKGROUND RED      
BACKGROUND RED BACKGROUND RED BACKGROUND RED BACKGROUND RED BACKGROUND RED      
                                                                                
                                                                                
                                                                                
                                                                                
</pre>

### [Rich Text](https://git.sr.ht/~kerrick/ratatui_ruby/tree/main/item/examples/rich_text/app.rb)
Demonstrates `Text::Span` and `Text::Line` for creating styled text with inline formatting, enabling word-level control over colors and text modifiers.

<pre class="terminal-preview" data-example="rich_text">
┌Simple Rich Text──────────────────────────────────────────────────────────────┐
│Normal text, Bold Text, Italic Text, Red Text.                                │
│                                                                              │
│                                                                              │
│                                                                              │
│                                                                              │
│                                                                              │
│                                                                              │
│                                                                              │
│                                                                              │
│                                                                              │
└──────────────────────────────────────────────────────────────────────────────┘
┌Status Report─────────────────────────────────────────────────────────────────┐
│✓ Feature Complete - All tests passing                                        │
│⚠ Warning - Documentation pending                                             │
│✗ Not Started - Performance benchmarks                                        │
│                                                                              │
│Press Q to quit                                                               │
│                                                                              │
│                                                                              │
│                                                                              │
│                                                                              │
│                                                                              │
└──────────────────────────────────────────────────────────────────────────────┘
</pre>

### [Scrollbar Demo](https://git.sr.ht/~kerrick/ratatui_ruby/tree/main/item/examples/scrollbar_demo/app.rb)
A demonstration of the `Scrollbar` widget, featuring mouse wheel scrolling and extensive customization of symbols and styles.

<pre class="terminal-preview" data-example="scrollbar_demo">
┌Scroll with Mouse Wheel | Theme: Standard | Orientation: vertical─────────────▲
│Line 1                                                                        █
│Line 2                                                                        █
│Line 3                                                                        █
│Line 4                                                                        █
│Line 5                                                                        █
│Line 6                                                                        █
│Line 7                                                                        █
│Line 8                                                                        ║
│Line 9                                                                        ║
│Line 10                                                                       ║
│Line 11                                                                       ║
│Line 12                                                                       ║
│Line 13                                                                       ║
│Line 14                                                                       ║
│Line 15                                                                       ║
│Line 16                                                                       ║
│Line 17                                                                       ║
│Line 18                                                                       ║
│Line 19                                                                       ║
│Line 20                                                                       ║
│Line 21                                                                       ║
│Line 22                                                                       ║
└──────────────Press 's' to cycle theme, 'o' to cycle orientation──────────────▼
</pre>

### [Scroll Text](https://git.sr.ht/~kerrick/ratatui_ruby/tree/main/item/examples/scroll_text/app.rb)
Demonstrates the `Paragraph` widget's scroll functionality, allowing navigation through long text content using arrow keys for both horizontal and vertical scrolling.

<pre class="terminal-preview" data-example="scroll_text">
┌Scrollable Text───────────────────────────────────────────────────────────────┐
│Line 1: This is a long line of text that can be scrolled horizontally         │
│Line 2: This is a long line of text that can be scrolled horizontally         │
│Line 3: This is a long line of text that can be scrolled horizontally         │
│Line 4: This is a long line of text that can be scrolled horizontally         │
│Line 5: This is a long line of text that can be scrolled horizontally         │
│Line 6: This is a long line of text that can be scrolled horizontally         │
│Line 7: This is a long line of text that can be scrolled horizontally         │
│Line 8: This is a long line of text that can be scrolled horizontally         │
│Line 9: This is a long line of text that can be scrolled horizontally         │
│Line 10: This is a long line of text that can be scrolled horizontally        │
│Line 11: This is a long line of text that can be scrolled horizontally        │
│Line 12: This is a long line of text that can be scrolled horizontally        │
│Line 13: This is a long line of text that can be scrolled horizontally        │
│Line 14: This is a long line of text that can be scrolled horizontally        │
│Line 15: This is a long line of text that can be scrolled horizontally        │
│Line 16: This is a long line of text that can be scrolled horizontally        │
│Line 17: This is a long line of text that can be scrolled horizontally        │
└──────────────────────────────────────────────────────────────────────────────┘
┌Controls──────────────────────────────────────────────────────────────────────┐
│NAVIGATION                                                                    │
│↑/↓: Vert Scroll (0)  ←/→: Horz Scroll (0)  q: Quit                           │
│                                                                              │
└──────────────────────────────────────────────────────────────────────────────┘
</pre>

### [Sparkline Demo](https://git.sr.ht/~kerrick/ratatui_ruby/tree/main/item/examples/sparkline_demo/app.rb)
Demonstrates the `Sparkline` widget with interactive attribute cycling. Features multiple data sets with different patterns (steady growth, gaps, random, sawtooth, peaks), and explores all `Sparkline` options including direction, color, and the new `absent_value_symbol` and `absent_value_style` parameters for distinguishing zero/absent values from low data.

<pre class="terminal-preview" data-example="sparkline_demo">
Sparkline Widget Demo - Cycle attributes with hotkeys                           
┌Interactive Sparkline─────────────────────────────────────────────────────────┐
│ ▁▂▂▃▄▄▅▆▆▇█                                                                  │
└──────────────────────────────────────────────────────────────────────────────┘
┌Reversed Data─────────────────────────────────────────────────────────────────┐
│█▇▆▆▅▄▄▃▂▂▁                                                                   │
└──────────────────────────────────────────────────────────────────────────────┘
┌Without Absent Marker─────────────────────────────────────────────────────────┐
│ ▁▂▂▃▄▄▅▆▆▇█                                                                  │
└──────────────────────────────────────────────────────────────────────────────┘
┌Gap Pattern (Responsive)──────────────────────────────────────────────────────┐
│▄·▆·▄·▇·▅·█·                                                                  │
└──────────────────────────────────────────────────────────────────────────────┘
                                                                                
                                                                                
                                                                                
                                                                                
                                                                                
                                                                                
                                                                                
┌Controls──────────────────────────────────────────────────────────────────────┐
│↑/↓: Data (Steady Growth)  d: Direction (Left to Right)  c: Color (Green)     │
│m: Marker (Dot (·))  s: M. Style (Default)  q: Quit                           │
└──────────────────────────────────────────────────────────────────────────────┘
</pre>

### [Gauge Demo](https://git.sr.ht/~kerrick/ratatui_ruby/tree/main/item/examples/gauge_demo/app.rb)
Demonstrates the `Gauge` widget with interactive attribute cycling. Features multiple gauge instances with customizable ratio, gauge color, background style, Unicode toggle, and label modes. The sidebar provides hotkey documentation for exploring all Gauge options, including the distinction between `style` (background) and `gauge_style` (filled bar).

<pre class="terminal-preview" data-example="gauge_demo">
Gauge Widget Demo                                                               
┌Interactive Gauge─────────────────────────────────────────────────────────────┐
│██████████████████████████████████████████████████▊                           │
│█████████████████████████████████████65% █████████▊                           │
│██████████████████████████████████████████████████▊                           │
└──────────────────────────────────────────────────────────────────────────────┘
┌Inverse (1.0 - ratio)─────────────────────────────────────────────────────────┐
│███████████████████████████▎                                                  │
│███████████████████████████▎                                                  │
│███████████████████████████▎         35%                                      │
│███████████████████████████▎                                                  │
└──────────────────────────────────────────────────────────────────────────────┘
┌Min Threshold (Magenta)───────────────────────────────────────────────────────┐
│██████████████████████████████████████████████████▊                           │
│███████████████████████████████████Min 50% ███████▊                           │
│██████████████████████████████████████████████████▊                           │
└──────────────────────────────────────────────────────────────────────────────┘
                                                                                
┌Controls──────────────────────────────────────────────────────────────────────┐
│←/→: Adjust Ratio (0.65)  q: Quit                                             │
│g: Color (Green)  b: Background (Dark Gray BG)                                │
│u: Unicode (On)  l: Label (Percentage)                                        │
│                                                                              │
└──────────────────────────────────────────────────────────────────────────────┘
</pre>

### [Table Select](https://git.sr.ht/~kerrick/ratatui_ruby/tree/main/item/examples/table_select/app.rb)
Demonstrates interactive row selection in the `Table` widget with keyboard navigation, highlighting selected rows with custom styles and symbols, applying a base style, and dynamically adjusting `column_spacing`.

<pre class="terminal-preview" data-example="table_select">
┌Processes─────────────────────────────────────────────────────────────────────┐
│PID      Name            CPU                                                  │
│1234     ruby            15.2%                                                │
│5678     postgres        8.7%                                                 │
│9012     nginx           3.1%                                                 │
│3456     redis           12.4%                                                │
│7890     sidekiq         22.8%                                                │
│2345     webpack         45.3%                                                │
│6789     node            18.9%                                                │
│                                                                              │
│                                                                              │
│                                                                              │
│                                                                              │
│                                                                              │
│                                                                              │
│                                                                              │
│                                                                              │
│                                                                              │
│Total: 7 Total CPU: 126.                                                      │
└──────────────────────────────────────────────────────────────────────────────┘
┌Controls──────────────────────────────────────────────────────────────────────┐
│↑/↓: Navigate  x: Toggle Selection (none)  q: Quit                            │
│s: Style (Cyan)  h: Spacing (When Selected)  +/-: Col Space (1)               │
└──────────────────────────────────────────────────────────────────────────────┘
</pre>

### [Table Flex](https://git.sr.ht/~kerrick/ratatui_ruby/tree/main/item/examples/table_flex/app.rb)
Demonstrates different flex modes in the `Table` widget, such as `:space_between` and `:space_around`, allowing for modern, responsive table layouts.

<pre class="terminal-preview" data-example="table_flex">
┌Header────────────────────────────────────────────────────────────────────────┐
│Table Flex Layout (press 'q' to quit)                                         │
└──────────────────────────────────────────────────────────────────────────────┘
┌Flex: :legacy (Default)───────────────────────────────────────────────────────┐
│Legacy (Default)     Table                                                    │
│Item 1               Item 2                                                   │
│Item 3               Item 4                                                   │
│                                                                              │
│                                                                              │
└──────────────────────────────────────────────────────────────────────────────┘
┌Flex: :space_between──────────────────────────────────────────────────────────┐
│Space                                                     Between             │
│A                                                         B                   │
│C                                                         D                   │
│                                                                              │
│                                                                              │
└──────────────────────────────────────────────────────────────────────────────┘
┌Flex: :space_around───────────────────────────────────────────────────────────┐
│          Space                                  Around                       │
│          E                                      F                            │
│          G                                      H                            │
│                                                                              │
│                                                                              │
└──────────────────────────────────────────────────────────────────────────────┘
</pre>

