;; helix-lazygit — lazygit integration for helix-steel
;;
;; Opens lazygit as a real terminal buffer (helix-steel's native
;; terminal-buffer-mode: a running program whose PTY output lives in a
;; normal Document, kept in sync automatically) instead of the old
;; floating-component PTY overlay. Being a real buffer means it gets
;; bufferline, splits, and buffer-next/previous for free, and closes
;; itself the moment lazygit exits (whichever way you quit it) — no more
;; area-calculation, event-interception, or manual PTY-exit-detection code
;; needed here at all.
;;
;; Usage in init.scm:
;;   (require "helix-lazygit/lazygit.scm")
;;   (keymap (global) (normal (space (g ":lazygit"))))
;;
;; While lazygit has focus, its own keys (including its own `q` to quit)
;; work normally since keystrokes are forwarded straight to the process.
;; `<F12>` detaches back to Normal mode without going through lazygit at
;; all, for when the process needs to be closed forcefully.

(require "helix/editor.scm")
(require "helix/static.scm")
(require "helix/commands.scm")
(require "helix/misc.scm")
(require "steel/result")

;; The doc-id of the currently open lazygit buffer, or #f.
(define *lazygit-doc-id* #f)

;;@doc
;; Open lazygit as a terminal buffer, replacing the current view. If
;; lazygit is already open and still running, switches to it instead of
;; spawning a second instance.
(define (lazygit)
  (if (and *lazygit-doc-id* (term-buffer-alive? *lazygit-doc-id*))
      (editor-switch-action! *lazygit-doc-id* (Action/Replace))
      (begin
        (set! *lazygit-doc-id*
              (term-buffer-spawn!
               (string-append "cd " (helix-find-workspace) " && exec lazygit")))
        (set-bufferline-name! "lazygit"))))

;;@doc
;; Close lazygit if currently open (also kills the process, if it's still
;; running).
(define (close-lazygit)
  (when (and *lazygit-doc-id* (term-buffer-alive? *lazygit-doc-id*))
    (editor-switch-action! *lazygit-doc-id* (Action/Replace))
    (buffer-close!))
  (set! *lazygit-doc-id* #f)
  void)

(provide lazygit close-lazygit)
