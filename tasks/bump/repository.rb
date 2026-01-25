# frozen_string_literal: true

#--
# SPDX-FileCopyrightText: 2026 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later
#++

require "shellwords"
require "tmpdir"

class Repository
  TRUNK = "trunk"

  def on_trunk? = current_branch == TRUNK

  def current_branch
    `git branch --show-current`.strip
  end

  def create_branch(name)
    system("git checkout -b #{name}", exception: true)
  end

  def checkout(name)
    system("git checkout #{name}", exception: true)
  end

  def assert_can_bump!(segment)
    assert_pristine!

    if on_trunk? && segment == :patch
      raise ArgumentError, "Cannot bump:patch from trunk. Use a release branch."
    end

    if !on_trunk? && [:minor, :major].include?(segment)
      raise ArgumentError, "Cannot bump:#{segment} from #{current_branch}. Switch to trunk first."
    end
  end

  def assert_pristine!
    return if `git status --porcelain`.strip.empty?

    raise ArgumentError, "Working tree is not clean. Commit or stash changes first."
  end

  def commit_all(message)
    msg_file = File.join(Dir.tmpdir, "ratatui_ruby_commit_msg_#{$$}.txt")
    system("git add -A", exception: true)
    File.write(msg_file, message)
    system("git commit -F #{msg_file.shellescape}", exception: true)
  ensure
    File.delete(msg_file) if msg_file && File.exist?(msg_file)
  end
end
