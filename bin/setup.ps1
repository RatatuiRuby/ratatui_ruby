# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

if (-not (Get-Command mise -ErrorAction SilentlyContinue)) {
  Write-Error "mise isn't installed. Please install it to continue: https://mise.jdx.dev"
  exit 1
}

# Read the Ruby version from mise.toml so we install the matching RubyInstaller.
$rubyVersion = (Select-String -Path mise.toml -Pattern 'ruby\s*=\s*"([^"]+)"').Matches.Groups[1].Value
$rubyMajorMinor = ($rubyVersion -split '\.')[0..1] -join '.'

# mise cannot compile Ruby from source on Windows (ruby-build produces broken
# native extension support). Install Ruby via RubyInstaller, which bundles the
# MSYS2 devkit for native gem compilation.
if (-not (Get-Command ruby -ErrorAction SilentlyContinue) -or -not ((ruby --version) -match $rubyMajorMinor)) {
  Write-Host "Ruby $rubyMajorMinor is required but not installed."
  if ($env:CI -ne "true") {
    $answer = Read-Host "Install it now via RubyInstaller (winget)? This will require administrator privileges. [Y/n]"
    if ($answer -and $answer -notmatch '^[Yy]') {
      Write-Error "Cannot continue without Ruby."
      exit 1
    }
  }
  winget install --id "RubyInstallerTeam.RubyWithDevKit.$rubyMajorMinor" --accept-source-agreements --accept-package-agreements
  # Refresh PATH so ruby is available
  $env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "User")
}

# Rust's default MSVC target requires Visual Studio Build Tools with the
# C++ workload.
$vsWhere = "${env:ProgramFiles(x86)}\Microsoft Visual Studio\Installer\vswhere.exe"
if (-not (Test-Path $vsWhere) -or -not (& $vsWhere -products * -requires Microsoft.VisualStudio.Component.VC.Tools.x86.x64 -property installationPath)) {
  Write-Host "Visual Studio Build Tools with C++ workload is required for Rust compilation."
  if ($env:CI -ne "true") {
    $answer = Read-Host "Install it now via winget? This will require administrator privileges. [Y/n]"
    if ($answer -and $answer -notmatch '^[Yy]') {
      Write-Error "Cannot continue without Visual Studio Build Tools."
      exit 1
    }
  }
  winget install Microsoft.VisualStudio.2022.BuildTools --override "--wait --passive --add Microsoft.VisualStudio.Workload.VCTools --includeRecommended"
}

# Create .mise.local.toml (gitignored) with Windows-specific overrides:
#   - disable_tools: prevents mise from installing its own (broken) Ruby
#   - BINDGEN_EXTRA_CLANG_ARGS: tells clang where to find MSYS2 POSIX headers
#     (e.g. strings.h) that Ruby's defines.h includes
if (-not (Test-Path .mise.local.toml) -or -not (Select-String -Path .mise.local.toml -Pattern 'disable_tools' -Quiet)) {
  $localToml = @"

[settings]
disable_tools = ["ruby"]
"@
  if ($env:RI_DEVKIT) {
    $msysRoot = (Join-Path $env:RI_DEVKIT "ucrt64") -replace '\\', '/'
    $localToml += @"

[env]
BINDGEN_EXTRA_CLANG_ARGS = "-include stdbool.h --target=x86_64-w64-mingw32 --sysroot=$msysRoot -I$msysRoot/include"
CARGO_BUILD_TARGET = "x86_64-pc-windows-gnu"
"@
  }
  Add-Content -Path .mise.local.toml -Value $localToml
}

# mise handles Rust, Python, and pre-commit. Ruby is disabled above.
mise install
mise x -- rustup target add x86_64-pc-windows-gnu
mise x -- rustup component add rustfmt clippy
mise x -- python -m pip install reuse
gem install bundler:4.0.3

if ($env:CI -eq "true") {
  bundle config set --local frozen true
}

bundle install

if ($env:CI -ne "true") {
  pre-commit install
  bundle exec rake rdoc
}
