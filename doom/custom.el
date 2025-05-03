(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(modus-themes-variable-pitch-ui t)
 '(org-agenda-files '("~/o/schd.org"))
 '(org-directory "~/o")
 '(org-goto-interface 'outline-path-completion)
 '(org-roam-directory "/home/kyurivlis/o/roam/")
 '(safe-local-variable-values
   '((geiser-insert-actual-lambda)
     (eval progn (require 'lisp-mode)
      (defun emacs27-lisp-fill-paragraph (&optional justify)
        (interactive "P")
        (or (fill-comment-paragraph justify)
            (let
                ((paragraph-start
                  (concat paragraph-start
                          "\\|\\s-*\\([(;\"]\\|\\s-:\\|`(\\|#'(\\)"))
                 (paragraph-separate
                  (concat paragraph-separate "\\|\\s-*\".*[,\\.]$"))
                 (fill-column
                  (if
                      (and (integerp emacs-lisp-docstring-fill-column)
                           (derived-mode-p 'emacs-lisp-mode))
                      emacs-lisp-docstring-fill-column
                    fill-column)))
              (fill-paragraph justify))
            t))
      (setq-local fill-paragraph-function #'emacs27-lisp-fill-paragraph))
     (eval modify-syntax-entry 43 "'") (eval modify-syntax-entry 36 "'")
     (eval modify-syntax-entry 126 "'") (geiser-repl-per-project-p . t)
     (eval with-eval-after-load 'yasnippet
      (let
          ((guix-yasnippets
            (expand-file-name "etc/snippets/yas"
                              (locate-dominating-file default-directory
                                                      ".dir-locals.el"))))
        (unless (member guix-yasnippets yas-snippet-dirs)
          (add-to-list 'yas-snippet-dirs guix-yasnippets) (yas-reload-all))))
     (eval with-eval-after-load 'tempel
      (if (stringp tempel-path) (setq tempel-path (list tempel-path)))
      (let
          ((guix-tempel-snippets
            (concat
             (expand-file-name "etc/snippets/tempel"
                               (locate-dominating-file default-directory
                                                       ".dir-locals.el"))
             "/*.eld")))
        (unless (member guix-tempel-snippets tempel-path)
          (add-to-list 'tempel-path guix-tempel-snippets))))
     (eval setq-local guix-directory
      (locate-dominating-file default-directory ".dir-locals.el"))
     (eval add-to-list 'completion-ignored-extensions ".go")))
 '(symex-common-lisp-backend 'sly)
 '(warning-suppress-log-types
   '((files missing-lexbind-cookie
      "~/.config/emacs/.local/straight/build-31.0.50/doom-snippets/fundamental-mode/.yas-setup.el")
     (files missing-lexbind-cookie
      "~/.config/emacs/.local/straight/build-31.0.50/doom-snippets/fundamental-mode/.yas-setup.el"))))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(default ((((type graphic)) :family "Aporetic Sans Mono" :height 125))))
