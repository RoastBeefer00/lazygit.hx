(define package-name 'lazygit.hx)
(define version "0.2.0")

;; No dependencies: uses helix-steel's native terminal-buffer-mode
;; (term-buffer-spawn!/term-buffer-alive?, in helix/static.scm) instead of
;; the steel-pty dylib + term.scm component system.
(define dependencies '())

(define dylibs '())
