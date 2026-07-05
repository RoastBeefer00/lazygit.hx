# helix-lazygit

Lazygit integration for [helix-steel](https://github.com/mattwparas/helix) — opens lazygit as a full-screen terminal overlay inside helix. No terminal multiplexer needed.

## Requirements

- [mattwparas/helix](https://github.com/mattwparas/helix) built with the `steel` feature
- `lazygit` on your `$PATH`
- `steel-pty` (installed automatically via `forge install`)

## Installation

```sh
forge pkg install --git https://github.com/RoastBeefer00/helix-lazygit.git
```

Or add to your `cog.scm` dependencies:

```scheme
(#:name helix-lazygit #:git-url "https://github.com/RoastBeefer00/helix-lazygit.git")
```

## Usage

In your `init.scm`:

```scheme
(require "helix-lazygit/lazygit.scm")

(keymap (global)
        (normal (space (g ":lazygit"))))
```

### Commands

| Command | Description |
|---|---|
| `:lazygit` | Open lazygit overlay |
| `:close-lazygit` | Close lazygit programmatically |

### Controls

- **`q`** — quit lazygit and return to helix (uses lazygit's own quit binding)
- **`Ctrl-Esc`** — force-close the overlay without quitting lazygit's process

## How it works

helix-lazygit spawns lazygit in a PTY, renders its VTE cell output directly into a helix component, and clips the editor to hide it completely while lazygit is open. The shell is read from `$SHELL` and the working directory is set to the helix workspace root.
