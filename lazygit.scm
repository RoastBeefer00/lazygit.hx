;; helix-lazygit — lazygit integration for helix-steel
;;
;; Opens lazygit as a full-screen overlay PTY terminal within helix.
;; Close with 'q' (lazygit's own quit) or Ctrl-Esc.
;;
;; Usage in init.scm:
;;   (require "helix-lazygit/lazygit.scm")
;;   (keymap (global) (normal (space (g ":lazygit"))))

(#%require-dylib "libsteel_pty"
                 (only-in create-native-pty-system!
                          kill-pty-process!
                          pty-process-send-command
                          virtual-terminal
                          vte/resize
                          pty-resize!
                          async-try-read-line
                          vte/advance-bytes))

(require (prefix-in helix. "helix/commands.scm"))
(require "helix/editor.scm")
(require "helix/misc.scm")
(require "steel/result")
(require-builtin helix/components)
(require "steel-pty/term.scm")

;;;; Shell detection

(define *lazygit-shell*
  (let ([r (maybe-get-env-var "SHELL")])
    (if (Ok? r) (Ok->value r) "/bin/sh")))

;;;; Area calculation — full-screen overlay with small padding

(define *lazygit-stashed-area* #f)
(define *lazygit-terminal-area* #f)

(define (lazygit-calculate-area state rect)
  (if (and *lazygit-terminal-area* (equal? *lazygit-stashed-area* rect))
      *lazygit-terminal-area*
      (begin
        (set! *lazygit-stashed-area* rect)
        (let* ([pad-x 2]
               [pad-y 1]
               [w (- (area-width rect) (* 2 pad-x))]
               [h (- (area-height rect) (* 2 pad-y) 1)])
          ;; clip full editor width so helix is completely hidden
          (set-editor-clip-right! (area-width rect))
          (term-resize-from-term state (- h 2) (- w 5))
          (set! *lazygit-terminal-area*
                (area (+ (area-x rect) pad-x)
                      (+ (area-y rect) pad-y)
                      w h))
          *lazygit-terminal-area*))))

(define lazygit-render (make-terminal-renderer lazygit-calculate-area))

;;;; State

(define *lazygit* #f)

(define (lazygit-cleanup! term)
  (set! *lazygit-stashed-area* #f)
  (set! *lazygit-terminal-area* #f)
  (set! *lazygit* #f)
  (set-editor-clip-right! 0)
  (set-box! (Terminal-kill-switch term) #t)
  (set-box! (Terminal-focused? term) #f))

;;;; Event handler
;;
;; Intercepts 'q' to kill the process cleanly and Ctrl-Esc to force-close.
;; All other events are forwarded to the standard terminal handler.

(define (lazygit-event-handler state event)
  (cond
    [(and (unbox (Terminal-focused? state))
          (equal? (key-event-char event) #\q))
     ;; Let lazygit handle its own quit — kill PTY and clean up
     (kill-pty-process! (Terminal-*pty-process* state))
     (lazygit-cleanup! state)
     (set-box! (Terminal-active state) #f)
     event-result/close]

    [(and (unbox (Terminal-focused? state))
          (key-event-escape? event)
          (equal? (key-event-modifier event) key-modifier-ctrl))
     ;; Force-close without letting lazygit exit naturally
     (kill-pty-process! (Terminal-*pty-process* state))
     (lazygit-cleanup! state)
     (set-box! (Terminal-active state) #f)
     event-result/close]

    [else (terminal-event-handler state event)]))

;;;; PTY read loop — detects natural exit (lazygit quit via 'q')

(define (lazygit-loop term)
  (define (inner)
    (if (unbox (Terminal-kill-switch term))
        ;; Already cleaned up via event handler
        (begin
          (set! *lazygit-stashed-area* #f)
          (set! *lazygit-terminal-area* #f)
          (set! *lazygit* #f))
        (helix-await-callback
         (async-try-read-line (Terminal-*pty-process* term))
         (lambda (line)
           (if line
               (begin
                 (vte/advance-bytes (Terminal-*vte* term) line)
                 (inner))
               ;; PTY exited naturally
               (begin
                 (lazygit-cleanup! term)
                 (when (unbox (Terminal-active term))
                   (set-box! (Terminal-active term) #f)
                   (pop-last-component! "lazygit"))))))))
  (inner))

;;;; Public API

;;@doc
;; Open lazygit in a full-screen terminal overlay within helix.
(define (lazygit)
  (define term
    (make-terminal-custom
     "lazygit"
     *lazygit-shell*
     45 80
     (lambda (t)
       (pty-process-send-command
        (Terminal-*pty-process* t)
        (string-append "cd " (helix-find-workspace) " && exec lazygit\r")))
     vte/advance-bytes
     lazygit-render
     lazygit-event-handler))
  (set! *lazygit* term)
  (set! *lazygit-stashed-area* #f)
  (set! *lazygit-terminal-area* #f)
  (lazygit-loop term)
  (show-term term))

;;@doc
;; Close lazygit if currently open.
(define (close-lazygit)
  (when *lazygit*
    (let ([term *lazygit*])
      (kill-pty-process! (Terminal-*pty-process* term))
      (lazygit-cleanup! term)
      (when (unbox (Terminal-active term))
        (set-box! (Terminal-active term) #f)
        (pop-last-component! "lazygit")))))

(provide lazygit close-lazygit)
