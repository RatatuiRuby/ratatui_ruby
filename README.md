<!--
  SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
  SPDX-License-Identifier: CC-BY-SA-4.0
-->
# ratatui_ruby

> [!NOTE]  
> **ratatui_ruby** is a community wrapper that is not affiliated with [the Ratatui team](https://github.com/orgs/ratatui/people).


## Introduction

**ratatui_ruby** is a Ruby wrapper for [Ratatui](https://ratatui.rs). It allows you to cook up Terminal User Interfaces in Ruby.

> [!WARNING]  
> **ratatui_ruby** is currently in an early stage of development. Use at your own risk.

Please join our **announce** mailing list at https://lists.sr.ht/~kerrick/ratatui_ruby-announce to stay up-to-date on new releases and announcements.


## Compatibility

**ratatui_ruby** is designed to run on [everything Ruby does](https://www.ruby-lang.org/en/documentation/installation/), including:

- GNU/Linux, macOS, Windows, OpenBSD, and FreeBSD; and
- x86_64 (AMD, Intel) and ARM (Apple Silicon, Raspberry Pi).


## Installation

Add this line to your application's Gemfile:

```ruby
gem 'ratatui_ruby'
```

And then execute:

```bash
bundle install
```

Or install it yourself as:

```bash
gem install ratatui_ruby
```


## Usage

**ratatui_ruby** uses an immediate-mode API. You describe your UI using Ruby `Data` objects and call `draw` in a loop.

```ruby
require "ratatui_ruby"
RatatuiRuby.init_terminal
begin
  RatatuiRuby.draw(
    RatatuiRuby::Paragraph.new(
      text: "Hello World",
      block: RatatuiRuby::Block.new(
        borders: [:all]
      )
    )
  )
  sleep 2
ensure
  RatatuiRuby.restore_terminal
end
```

For a full tutorial, see [the Quickstart](./docs/quickstart.md).


## Documentation

For the full documentation on how to use **ratatui_ruby**, see our [docs](./docs/index.md).


## Contributing

Bug reports and pull requests are welcome on [sourcehut](https://sourcehut.org) at https://sr.ht/~kerrick/ratatui_ruby/. This project is intended to be a safe, productive collaboration, and contributors are expected to adhere to the [Ruby Community Conduct Guideline](https://www.ruby-lang.org/en/conduct/).

Issues for the underlying Rust library should be filed at [ratatui/ratatui](https://github.com/ratatui/ratatui).

Want to help develop **ratatui_ruby**? Check out our [contribution guide](./CONTRIBUTING.md).


## Copyright & License

**ratatui_ruby** is copyright 2025, Kerrick Long. **ratatui_ruby** is licensed under the GNU Affero General Public License v3.0 or later; see [LICENSES/AGPL-3.0-or-later.txt](./LICENSES/AGPL-3.0-or-later) for the full text.

Some parts of this program are copied from other sources under appropriate reuse licenses, and the copyright belongs to their respective owners. See the [REUSE Specification – Version 3.3](https://reuse.software/spec-3.3/) for information about how we comply with attribution and licensing requirements.