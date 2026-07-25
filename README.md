# helix-lazygit

Lazygit integration for [helix-steel](https://github.com/mattwparas/helix) — opens lazygit as a real terminal buffer inside helix (helix-steel's native terminal-buffer-mode). No terminal multiplexer needed.

## Requirements

- [mattwparas/helix](https://github.com/mattwparas/helix) built with the `steel` feature, on a branch/build that includes native terminal-buffer-mode (`term-buffer-spawn!` in `helix/static.scm`)
- `lazygit` on your `$PATH`

## Installation

```sh
forge pkg install --git https://github.com/RoastBeefer00/lazygit.hx.git
```

Or add to your `cog.scm` dependencies:

```scheme
(#:name lazygit.hx #:git-url "https://github.com/RoastBeefer00/lazygit.hx.git")
```

## Usage

In your `init.scm`:

```scheme
(require "lazygit.hx/lazygit.scm")

(keymap (global)
        (normal (space (g ":lazygit"))))
```

### Commands

| Command | Description |
|---|---|
| `:lazygit` | Open lazygit overlay |
| `:close-lazygit` | Close lazygit programmatically |

### Controls

- **`q`** — quit lazygit and return to helix (uses lazygit's own quit binding; the buffer closes itself as soon as the process exits)
- **`<F12>`** — detach back to Normal mode without going through lazygit (e.g. to force-close via `:close-lazygit` or `:bc!` if lazygit is unresponsive)

## How it works

`:lazygit` opens a real Helix buffer running `lazygit` in a PTY (via `term-buffer-spawn!`), `cd`'d into the helix workspace root and `exec`'d so no wrapper shell survives. Because it's a normal buffer, it participates in bufferline/split/buffer-navigation like anything else, and closes itself automatically the moment the lazygit process exits, however that happens.
