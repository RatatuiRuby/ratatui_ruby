# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

if (-not (Get-Command mise -ErrorAction SilentlyContinue)) {
  Write-Error "mise isn't installed. Please install it to continue: https://mise.jdx.dev"
  exit 1
}

# Rust's default MSVC target requires Visual Studio Build Tools with the
# C++ workload. Install via winget if not already present.
$vsWhere = "${env:ProgramFiles(x86)}\Microsoft Visual Studio\Installer\vswhere.exe"
if (-not (Test-Path $vsWhere) -or -not (& $vsWhere -products * -requires Microsoft.VisualStudio.Component.VC.Tools.x86.x64 -property installationPath)) {
  Write-Host "Visual Studio Build Tools with C++ workload is required for Rust compilation."
  $answer = Read-Host "Install it now via winget? This will require administrator privileges. [Y/n]"
  if ($answer -and $answer -notmatch '^[Yy]') {
    Write-Error "Cannot continue without Visual Studio Build Tools."
    exit 1
  }
  winget install Microsoft.VisualStudio.2022.BuildTools --override "--wait --passive --add Microsoft.VisualStudio.Workload.VCTools --includeRecommended"
}

# Use precompiled Ruby binaries (RubyInstaller) instead of compiling from
# source via ruby-build. RubyInstaller bundles MSYS2 devkit, which provides
# proper RbConfig for native gem extension compilation.
mise settings set ruby.compile false

mise install
mise x -- rustup component add rustfmt clippy
mise x -- python -m pip install reuse
mise x -- gem install bundler:4.0.3

if ($env:CI -eq "true") {
  bundle config set --local frozen true
}

mise x -- bundle install

if ($env:CI -ne "true") {
  pre-commit install
  bundle exec rake rdoc
}
