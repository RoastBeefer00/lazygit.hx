# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this is

`lazygit.hx` is a [helix-steel](https://github.com/mattwparas/helix) plugin (Steel/Scheme) that opens lazygit as a real terminal buffer inside helix, using helix-steel's native terminal-buffer-mode — no terminal multiplexer, no floating overlay component, no PTY/VTE library required.

The entire plugin is a single file: `lazygit.scm`. There is no build step.

## Package metadata

`cog.scm` is the package manifest (name, version, dependencies). There are no runtime dependencies — everything the plugin needs (`term-buffer-spawn!`, `term-buffer-alive?`, `editor-switch!`, `buffer-close!`) is built into helix-steel itself (`helix/static.scm`, `helix/editor.scm`, `helix/commands.scm`).

## Installation / testing

Install into a helix-steel setup:
```sh
forge pkg install --git https://github.com/RoastBeefer00/lazygit.hx.git
```

Record the demo GIF (requires `vhs` and `helix-steel` with this plugin loaded):
```sh
cd demo && vhs lazygit.tape
```

## Architecture

`lazygit.scm` is deliberately small — spawning a terminal as a real `Document` means Helix's own machinery (bufferline, split layout, buffer-navigation, cursor rendering, process-exit-closes-the-buffer) handles everything the old floating-component version had to reimplement by hand.

1. **`lazygit`** — if `*lazygit-doc-id*` points at a still-running terminal buffer (`term-buffer-alive?`), switches to it (`editor-switch!`); otherwise spawns a new one with `term-buffer-spawn!`, running `cd <workspace> && exec lazygit` (the `exec` means the PTY's child *is* lazygit, no wrapper shell survives it), and sets its bufferline name.

2. **`close-lazygit`** — if the tracked buffer is still alive, switches to it and calls `(buffer-close!)` (a normal typed-command call, exposed via `helix/commands.scm`), which closes the buffer and — via the `document-closed` hook helix-steel's terminal-buffer-mode wires up internally — kills the child process too. Then clears the tracked doc-id.

State is a single module-level var, `*lazygit-doc-id*`, holding the doc-id of the open buffer (or `#f`). There's no separate cleanup path to keep in sync with an event handler or a read loop: the buffer closing itself when lazygit exits (any way — its own `q`, a crash, `:bc!`, whatever) *is* the cleanup path, and `term-buffer-alive?` reflects that automatically the next time `lazygit` or `close-lazygit` runs.

## Steel/Scheme notes

- `term-buffer-spawn!`, `term-buffer-send!`, `term-buffer-alive?` are helix-steel's native terminal-buffer primitives (`helix/static.scm`) — see helix-steel's own docs/source for the full API and how it's implemented (a real PTY + `vt100` screen flattened into the Document's rope, in `helix-term/src/term_pty.rs`).
- The plugin uses `helix-find-workspace` to set lazygit's working directory, same as before.
- `<F12>` (built into terminal-buffer-mode itself, not this plugin) detaches focus back to Normal mode without forwarding the keystroke to lazygit — useful if lazygit needs to be force-closed rather than quit normally.
