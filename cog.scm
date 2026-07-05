(define package-name 'helix-lazygit)
(define version "0.1.0")

;; steel-pty must export: make-terminal-renderer, make-terminal-with-renderer,
;; term-resize-from-term, terminal-event-handler, Terminal-*vte*, Terminal-*pty-process*,
;; Terminal-kill-switch, Terminal-active, Terminal-focused?, Terminal-name, show-term
(define dependencies
  '((#:name steel-pty #:git-url "https://github.com/mattwparas/steel-pty.git")))

(define dylibs '())
