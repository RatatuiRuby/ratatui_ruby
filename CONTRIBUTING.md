<!--
  SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
  SPDX-License-Identifier: CC-BY-SA-4.0
-->
# Contribution Guide

This project is intended to be a safe, productive collaboration, and contributors are expected to adhere to the [Ruby Community Conduct Guideline](https://www.ruby-lang.org/en/conduct/).


## Reporting Issues

Bug reports are welcome on [sourcehut](https://sourcehut.org) at https://todo.sr.ht/~kerrick/ratatui_ruby.

Issues for Ratatui should be filed at [ratatui/ratatui](https://github.com/ratatui/ratatui).


## Requesting Features

ratatui_ruby aims to wrap all [Ratatui](https://ratatui.rs) features. Please request new features there.


## Pull Requests

Please join our **devel** mailing list at https://lists.sr.ht/~kerrick/ratatui_ruby-devel. Then, send a pull request via email to the mailing list. 

The easiest way to send a pull request via email is to use [git-send-email](https://git-scm.com/docs/git-send-email). If you are unfamiliar with using git to send a pull request via email, read the [four-step tutorial at git-send-email.io](https://git-send-email.io).

Alternatively, [sourcehut](https://sourcehut.org) has a web UI you can use to prepare the email to send. [Read their documentation](https://man.sr.ht/git.sr.ht/#sending-patches-upstream) to find out if this is right for you.


## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).


## Contributors’ Documentation

We have documentation on how **ratatui_ruby** works internally, how it is designed, and how it interacts with the official Ratatui projects. See the [contributors’ documentation index](docs/contributors/index.md) for more information.