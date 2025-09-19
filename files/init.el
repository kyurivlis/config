(use-package ekg
  :init
  (require 'ekg-embedding)
  ;; (ekg-embedding-generate-on-save)
  ;; (require 'ekg-llm)
  ;; (require 'llm-openai)  ;; The specific provider you are using must be loaded.
  ;; (let ((my-provider (make-llm-openai-compatible :url "https://openrouter.ai/api/v1" :key "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"
  ;;                                                :chat-model ""
  ;;                                                :embedding-model "")))
  ;;   (setq ekg-llm-provider my-provider
  ;;         ekg-embedding-provider my-provider))
  )

(use-package symex
  :config
  (symex-mode)
  (global-set-key (kbd "s-s") #'symex-mode-interface)
  (setopt symex-orientation 'squirrel)
  (lithium-define-keys
   symex-editing-mode
   (("s-s" symex-editing-mode-exit :exit)
    )))

(use-package symex-ide)

(defun lalboard-keys-to-laptop (list)
  (defun process-da-list (l f)
    (cond
     ((null l) nil)
     ((listp (car l)) (cons (process-da-list (car l) f)
                            (process-da-list (cdr l) f)))
     (t (cons (funcall f (car l))
              (process-da-list (cdr l) f)))))

  (defvar lalboard-laptop-keys-alist
    '(("0*" . "<space>")
      ("0^" . "<tab>")
      ("0_" . "<escape>")
      ("0>" . "0")
      ("0<" . "1")

      ("1*" . "d")
      ("1^" . "c")
      ("1_" . "g")
      ("1>" . "2")
      ("1<" . "3")

      ("2*" . "r")
      ("2^" . "l")
      ("2_" . "'")
      ("2>" . "4")
      ("2<" . "5")

      ("3*" . "t")
      ("3^" . "m")
      ("3_" . "k")
      ("3>" . "6")
      ("3<" . "7")

      ("4*" . "s")
      ("4^" . "v")
      ("4_" . "z")
      ("4>" . "8")
      ("4<" . "9")

      ("*0" . "<backspace>")
      ("^0" . "<return>")
      ("_0" . "<delete>")
      (">0" . ";")
      ("<0" . "}")

      ("*1" . "n")
      ("^1" . "f")
      ("_1" . "h")
      (">1" . "<XF86Tools>")
      ("<1" . "<XF86Launch5>")

      ("*2" . "a")
      ("^2" . "o")
      ("_2" . "\'")
      (">2" . "<XF86Launch6>")
      ("<2" . "<XF86Launch7>")

      ("*3" . "e")
      ("^3" . "u")
      ("_3" . ";")
      (">3" . "<XF86Launch8>")
      ("<3" . "<XF86Launch9>")

      ("*4" . "i")
      ("^4" . "j")
      ("_4" . ",")
      (">4" . "<insert>")
      ("<4" . "<XF86AudioMicMute>")))

  (process-da-list
   list
   (lambda (el)
     (if (stringp el)
         (seq-let  (a b) (split-string el "-")
           (let
               ((k
                 (alist-get (or b a) lalboard-laptop-keys-alist nil nil #'equal)))
             (print (cons a (cons k b)))
             (if k (if b (concat a "-"  k) k) el)))
       el))))

(defvar symex-layout
  '(;; ("1" digit-argument)
    ;; ("2" digit-argument)
    ;; ("3" digit-argument)
    ;; ("4" digit-argument)
    ;; ("5" digit-argument)
    ;; ("6" digit-argument)
    ;; ("7" digit-argument)
    ;; ("8" digit-argument)
    ;; ("9" digit-argument)

    ("0*" symex-yank)
    ("0^" symex-goto-highest)
    ("0_" symex-goto-lowest)
    ("0>" symex-goto-last)
    ("0<" symex-goto-first)

    ("s-0*" symex-yank-remaining)
    ("s-0^" symex-collapse)
    ("s-0_" symex-unfurl)
    ("s-0>" symex-collapse-remaining)
    ("s-0<" symex-unfurl-remaining)

    ("1*" symex-tidy)
    ("1^" symex-go-up)
    ("1_" symex-go-down)
    ("1>" symex-go-forward)
    ("1<" symex-go-backward)

    ("s-1*" symex-tidy-proper)
    ("s-1^" symex-climb-branch)
    ("s-1_" symex-descend-branch)
    ("s-1>" symex-traverse-forward)
    ("s-1<" symex-traverse-backward)

    ("2*" symex-evaluate)
    ("2^" symex-eval-recursive)
    ("2_" symex-evaluate-pretty)
    ("2>" symex-traverse-forward-more)
    ("2<" symex-traverse-backward-more)

    ("s-2*" symex-evaluate-definition)
    ("s-2^" symex-editing-mode-exit)
;    ("s-2_" )
    ("s-2>" symex-traverse-forward-skip)
    ("s-2<" symex-traverse-backward-skip)

    ("3*" symex-repl)
    ("3^" symex-insert-newline)
    ("3_" symex-append-newline)
    ("3>" symex-leap-forward)
    ("3<" symex-leap-backward)

    ("s-3*" symex-run)
    ("s-3^" symex-join-lines-backward)
    ("s-3_" symex-join-lines)
    ("s-3>" symex-soar-forward)
    ("s-3<" symex-soar-backward)

    ("4*" symex-describe)
    ("4^" symex-previous-visual-line)
    ("4_" symex-next-visual-line)
    ("4>" forward-char)
    ("4<" backward-char)

   ("s-4*" symex-editing-mode-exit)
    ("s-4^" scroll-down-command)
    ("s-4_" scroll-up-command)
    ("s-4>" forward-word)
    ("s-4<" backward-word)

    ("*0" symex-paste-after)
    ("^0" symex-wrap :exit)
    ("_0" symex-comment)
    (">0" symex-append-at-end :exit)
    ("<0" symex-insert-at-beginning :exit)

    ("M-*0" symex-paste-before)
    ("M-^0" symex-wrap-and-append :exit)
    ("M-_0" symex-comment-remaining)
    ("M->0" symex-append-after :exit)
    ("M-<0" symex-insert-before :exit)

    ("*1" symex-change :exit)
    ("^1" symex-raise)
    ("_1" symex-splice)
    (">1" symex-shift-forward)
    ("<1" symex-shift-backward)

    ("M-*1" symex-change-remaining :exit)
    ("M-^1" symex-split)
    ("M-_1" symex-join)
    ("M->1" symex-shift-forward-most)
    ("M-<1" symex-shift-backward-most)

    ("*2" symex-replace :exit)
    ("^2" symex-open-line-before :exit)
    ("_2" symex-open-line-after :exit)
    (">2" symex-emit-forward)
    ("<2" symex-emit-backward)

    ("M-*2" symex-change-delimiter)
    ("M-^2" undo)
    ("M-_2" undo-redo)
    ("M->2" symex-capture-forward)
    ("M-<2" symex-capture-backward)

    ("*3" symex-create-round)
    ("^3" symex-wrap-round)
    ("_3" symex-create-square)
    (">3" symex-cycle-quote)
    ("<3" symex-cycle-unquote)

    ("M-*3" symex-create-curly)
    ("M-^3" symex-wrap-curly)
    ("M-_3" symex-wrap-square)
    ("M->3" symex-remove-quoting-level)
    ("M-<3" symex-add-quoting-level)

    ("*4" symex-delete)
    ("^4" symex-delete-backward)
    ("_4" symex-delete-remaining)
    (">4" symex-swallow)
    ("<4" symex-swallow-tail)

    ("M-*4" symex-clear)
    ("M-^4" symex-repeat)
    ("M-_4" symex--toggle-highlight)
    ("M->4" symex-repeat-pop)
    ("M-<4" symex-repeat-recent)))

(eval
 `(lithium-define-keys symex-editing-mode
                        ,(lalboard-keys-to-laptop symex-layout)))

(use-package org-noter)

(tab-bar-mode -1)
(shell-command "xrandr --output Virtual-1 --mode 1366x768 --rate 60")

(global-visual-line-mode)
