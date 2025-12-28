<!--
  SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
  SPDX-License-Identifier: CC-BY-SA-4.0
-->
# ratatui_ruby

[![
builds.sr.ht status](https://builds.sr.ht/~kerrick/ratatui_ruby.svg)](https://builds.sr.ht/~kerrick/ratatui_ruby?) [![
License](https://img.shields.io/badge/dynamic/regex?url=https%3A%2F%2Fgit.sr.ht%2F~kerrick%2Fratatui_ruby%2Fblob%2Fmain%2Fratatui_ruby.gemspec&search=spec%5C.license%20%3D%20%22(.*)%22&replace=%241&label=License&color=a2c93e)](https://spdx.org/licenses/AGPL-3.0-or-later.html) [![
Gem Total Downloads](https://img.shields.io/gem/dt/ratatui_ruby)](https://rubygems.org/gems/ratatui_ruby) [![
Gem Version](https://img.shields.io/gem/v/ratatui_ruby)](https://rubygems.org/gems/ratatui_ruby) [![
Ratatui Version](https://img.shields.io/badge/dynamic/toml?url=https%3A%2F%2Fgit.sr.ht%2F~kerrick%2Fratatui_ruby%2Fblob%2Fmain%2Fext%2Fratatui_ruby%2FCargo.toml&query=%24.dependencies.ratatui.version&prefix=v&logo=ratatui&label=Ratatui)](https://crates.io/crates/ratatui/0.26.3) [![
Mailing List: Discussion](https://img.shields.io/badge/mailing_list-discussion-5865F2.svg?logo=data:image/svg+xml;base64,PHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHdpZHRoPSIyNCIgaGVpZ2h0PSIyNCIgdmlld0JveD0iMCAwIDI0IDI0IiBmaWxsPSJub25lIiBzdHJva2U9IiNmZmZmZmYiIHN0cm9rZS13aWR0aD0iMiIgc3Ryb2tlLWxpbmVjYXA9InJvdW5kIiBzdHJva2UtbGluZWpvaW49InJvdW5kIiBjbGFzcz0iaWNvbiBpY29uLXRhYmxlciBpY29ucy10YWJsZXItb3V0bGluZSBpY29uLXRhYmxlci1tYWlsIj48cGF0aCBzdHJva2U9Im5vbmUiIGQ9Ik0wIDBoMjR2MjRIMHoiIGZpbGw9Im5vbmUiLz48cGF0aCBkPSJNMyA3YTIgMiAwIDAgMSAyIC0yaDE0YTIgMiAwIDAgMSAyIDJ2MTBhMiAyIDAgMCAxIC0yIDJoLTE0YTIgMiAwIDAgMSAtMiAtMnYtMTB6IiAvPjxwYXRoIGQ9Ik0zIDdsOSA2bDkgLTYiIC8+PC9zdmc+Cg==)](https://lists.sr.ht/~kerrick/ratatui_ruby-discuss) [![
Mailing List: Development](https://img.shields.io/badge/mailing_list-development-4954d5.svg?logo=data:image/svg+xml;base64,PHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHdpZHRoPSIyNCIgaGVpZ2h0PSIyNCIgdmlld0JveD0iMCAwIDI0IDI0IiBmaWxsPSJub25lIiBzdHJva2U9IiNmZmZmZmYiIHN0cm9rZS13aWR0aD0iMiIgc3Ryb2tlLWxpbmVjYXA9InJvdW5kIiBzdHJva2UtbGluZWpvaW49InJvdW5kIiBjbGFzcz0iaWNvbiBpY29uLXRhYmxlciBpY29ucy10YWJsZXItb3V0bGluZSBpY29uLXRhYmxlci1tYWlsIj48cGF0aCBzdHJva2U9Im5vbmUiIGQ9Ik0wIDBoMjR2MjRIMHoiIGZpbGw9Im5vbmUiLz48cGF0aCBkPSJNMyA3YTIgMiAwIDAgMSAyIC0yaDE0YTIgMiAwIDAgMSAyIDJ2MTBhMiAyIDAgMCAxIC0yIDJoLTE0YTIgMiAwIDAgMSAtMiAtMnYtMTB6IiAvPjxwYXRoIGQ9Ik0zIDdsOSA2bDkgLTYiIC8+PC9zdmc+Cg==)](https://lists.sr.ht/~kerrick/ratatui_ruby-devel) [![
Mailing List: Announcements](https://img.shields.io/badge/mailing_list-announcements-3b44ac.svg?logo=data:image/svg+xml;base64,PHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHdpZHRoPSIyNCIgaGVpZ2h0PSIyNCIgdmlld0JveD0iMCAwIDI0IDI0IiBmaWxsPSJub25lIiBzdHJva2U9IiNmZmZmZmYiIHN0cm9rZS13aWR0aD0iMiIgc3Ryb2tlLWxpbmVjYXA9InJvdW5kIiBzdHJva2UtbGluZWpvaW49InJvdW5kIiBjbGFzcz0iaWNvbiBpY29uLXRhYmxlciBpY29ucy10YWJsZXItb3V0bGluZSBpY29uLXRhYmxlci1tYWlsIj48cGF0aCBzdHJva2U9Im5vbmUiIGQ9Ik0wIDBoMjR2MjRIMHoiIGZpbGw9Im5vbmUiLz48cGF0aCBkPSJNMyA3YTIgMiAwIDAgMSAyIC0yaDE0YTIgMiAwIDAgMSAyIDJ2MTBhMiAyIDAgMCAxIC0yIDJoLTE0YTIgMiAwIDAgMSAtMiAtMnYtMTB6IiAvPjxwYXRoIGQ9Ik0zIDdsOSA2bDkgLTYiIC8+PC9zdmc+Cg==)](https://lists.sr.ht/~kerrick/ratatui_ruby-announce)


## Introduction

**ratatui_ruby** is a Ruby wrapper for [Ratatui](https://ratatui.rs). It allows you to cook up Terminal User Interfaces in Ruby.
**ratatui_ruby** is a community wrapper that is not affiliated with [the Ratatui team](https://github.com/orgs/ratatui/people).

> [!WARNING]  
> **ratatui_ruby** is currently in an early stage of development. Use at your own risk.

Please join the **announce** mailing list at https://lists.sr.ht/~kerrick/ratatui_ruby-announce to stay up-to-date on new releases and announcements.


## Compatibility

**ratatui_ruby** is designed to run on [everything Ruby does](https://www.ruby-lang.org/en/documentation/installation/), including:

- GNU/Linux, macOS, Windows, OpenBSD, and FreeBSD; and
- x86_64 (AMD, Intel) and ARM (Apple Silicon, Raspberry Pi).

We support the latest minor version of every
[non-eol Ruby version](https://www.ruby-lang.org/en/downloads/branches/),
plus the latest preview of the next version.


## Installation

Add this line to your application's Gemfile:

```ruby
gem "ratatui_ruby"
```

And then execute:

```bash
bundle install
```

Or install it yourself with:

```bash
gem install ratatui_ruby
```


## Usage

**ratatui_ruby** uses an immediate-mode API. You describe your UI using Ruby objects and call `draw` in a loop.

```ruby
require "ratatui_ruby"
RatatuiRuby.main_loop do |tui|
  tui.draw \
    tui.paragraph \
        text: "Hello, Ratatui! Press 'q' to quit.",
        align: :center,
        block: tui.block(
          title: "My Ruby TUI App",
          borders: [:all],
          border_color: "cyan"
        )
  event = tui.poll_event
  break if event && event[:type] == :key && event[:code] == "q"
end
```

For a full tutorial, see [the Quickstart](./doc/quickstart.md).


## Documentation

For the full documentation on how to use **ratatui_ruby**, see the [documentation](./doc/index.md).  For other information, see the [wiki](https://man.sr.ht/~kerrick/ratatui_ruby).


## Contributing

Bug reports and pull requests are welcome on [sourcehut](https://sourcehut.org) at https://sr.ht/~kerrick/ratatui_ruby/. This project is intended to be a safe, productive collaboration, and contributors are expected to adhere to the [Code of Conduct](https://man.sr.ht/~kerrick/ratatui_ruby/code_of_conduct.md).

Issues for the underlying Rust library should be filed at [ratatui/ratatui](https://github.com/ratatui/ratatui).

Want to help develop **ratatui_ruby**? Check out the [contribution guide on the wiki](https://man.sr.ht/~kerrick/ratatui_ruby/contributing.md).


## Copyright & License

**ratatui_ruby** is copyright 2025, Kerrick Long. **ratatui_ruby** is licensed under the GNU Affero General Public License v3.0 or later; see [LICENSES/AGPL-3.0-or-later.txt](./LICENSES/AGPL-3.0-or-later) for the full text.

Some parts of this program are copied from other sources under appropriate reuse licenses, and the copyright belongs to their respective owners. See the [REUSE Specification – Version 3.3](https://reuse.software/spec-3.3/) for information about how we comply with attribution and licensing requirements.

This program was created with significant assistance from multiple LLMs. The process was human-controlled through creative prompts, with human contributions to each commit. See commit footers for model attribution. [declare-ai.org](https://declare-ai.org/1.0.0/creative.html)