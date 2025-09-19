(define-module (rc users kyurivlis)
  #:use-module (contrib features javascript)
  #:use-module (contrib features wm)
  #:use-module (gnu home services shepherd)
  #:use-module (gnu home services xdg)
  #:use-module (gnu home services)
  #:use-module (gnu services base)
  #:use-module (gnu home-services ssh)
  #:use-module (gnu packages)
  #:use-module (gnu services)
  #:use-module (guix channels)
  #:use-module (guix download)
  #:use-module (guix gexp)
  #:use-module (guix inferior)
  #:use-module (guix packages)
  #:use-module (rde features android)
  #:use-module (rde features base)
  #:use-module (rde features wm)
  #:use-module (gnu packages wm)
  #:use-module (gnu services sddm)
  #:use-module (gnu services ssh)
  #:use-module (rde features clojure)
  #:use-module (rde features gnupg)
  #:use-module (rde features irc)
  #:use-module (rde features keyboard)
  #:use-module (rde features mail)
  #:use-module (rde features networking)
  #:use-module (rde features password-utils)
  #:use-module (rde features security-token)
  #:use-module (rde features system)
  #:use-module (gnu system)
  #:use-module (rde features xdg)
  #:use-module (rde features markup)
  #:use-module (rde features libreoffice)
  #:use-module (rde features containers)
  #:use-module (rde features virtualization)
  #:use-module (rde features ocaml)
  #:use-module (rde features presets)
  #:use-module (rde features version-control)
  #:use-module (rde features video)
  #:use-module (rde features terminals)
  #:use-module (rde features gtk)
  #:use-module (rde features sourcehut)
    #:use-module (rde features base)
  #:use-module (rde features bittorrent)
  #:use-module (rde features documentation)
  #:use-module (rde features emacs)
  #:use-module (gnu packages emacs)
  #:use-module (rde features guile)
  #:use-module (rde features gtk)
  #:use-module (rde features emacs-xyz)
  #:use-module (contrib packages emacs-xyz)
  #:use-module (rde features finance)
  #:use-module (rde features fontutils)
  #:use-module (gnu packages fonts)
  #:use-module (rde features image-viewers)
  #:use-module (rde features irc)
  #:use-module (rde features linux)
  #:use-module (rde features mail)
  #:use-module (rde features markup)
  #:use-module (rde features networking)
  #:use-module (rde features shells)
  #:use-module (rde features shellutils)
  #:use-module (rde features ssh)
  #:use-module (rde features terminals)
  #:use-module (rde features tmux)
  #:use-module (rde features version-control)
  #:use-module (rde features video)
  #:use-module (rde features virtualization)
  #:use-module (rde features web-browsers)
  #:use-module (rde features wm)
  #:use-module (rde features xdg)
  #:use-module (rde features)
  #:use-module (rde home services emacs)
  #:use-module (rde home services i2p)
  #:use-module (rde home services shells)
  #:use-module (rde home services video)
  #:use-module (rde home services wm)
  #:use-module (rde packages aspell)
  #:use-module (rde packages)
  #:use-module (srfi srfi-1))


;;; Helpers

(define* (mail-acc id user #:optional (type 'gmail))
  "Make a simple mail-account with gmail type by default."
  (mail-account
   (id   id)
   (fqda user)
   (type type)))

(define* (mail-lst id fqda urls)
  "Make a simple mailing-list."
  (mailing-list
   (id   id)
   (fqda fqda)
   (config (l2md-repo
            (name (symbol->string id))
            (urls urls)))))



;;; Service extensions

(define home-extra-packages-service
  (simple-service
   'home-profile-extra-packages
   home-profile-service-type
   (append
    (list
     (@ (gnu packages tree-sitter) tree-sitter-clojure)
     (@ (gnu packages tree-sitter) tree-sitter-html)
     (@ (gnu packages guile) guile-next))
    (strings->packages
     "nyxt" "yt-dlp"
     "kmonad"
     "ripgrep" "curl" "just"
     "imagemagick"
     "recutils" "binutils" "gdb" "make"
     "pavucontrol" "alsa-utils" "wev" "libnotify"
     "hicolor-icon-theme" "adwaita-icon-theme" "gnome-themes-extra" "arc-theme"))))

(define mpv-add-user-settings-service
  (simple-service
   'mpv-add-user-settings
   home-mpv-service-type
   (home-mpv-extension
    (mpv-conf
     `((global
        ((keep-open . yes)
         (ytdl-format . "bestvideo[height<=?720][fps<=?30][vcodec!=?vp9]+bestaudio/best
")
         (save-position-on-quit . yes)
         (speed . 1.61))))))))

(define i2pd-add-ilita-irc-service
  (simple-service
   'i2pd-add-ilita-irc
   home-i2pd-service-type
   (home-i2pd-extension
    (tunnels-conf
     `((IRC-ILITA ((type . client)
                   (address . 127.0.0.1)
                   (port . 6669)
                   (destination . irc.ilita.i2p)
                   (destinationport . 6667)
                   (keys . ilita-keys.dat))))))))

(define ssh-extra-config-service
  (simple-service
   'ssh-extra-config
   home-ssh-service-type
   (home-ssh-extension
    (toplevel-options
     '((host-key-algorithms . "+ssh-rsa")
       (pubkey-accepted-key-types . "+ssh-rsa"))))))

(define rde-guix-add-to-shell-profile-service
  (simple-service
   'rde-guix-add-to-shell-profile
    home-shell-profile-service-type
   (list "
GUIX_PROFILE=/home/kyurivlis/c/rc/profile
if [ -f $GUIX_PROFILE/etc/profile ]; then source $GUIX_PROFILE/etc/profile; fi
")))

(define add-to-path-nix-and-local
  (simple-service
   'add-nix-and-local-bin
   home-environment-variables-service-type
   `(("PATH" . "$HOME/.local/bin:$HOME/.nix-profile/bin:$PATH"))))

(define guix-substitutes-service
  (simple-service
   'guix-substitutes
   guix-service-type
   (guix-extension
    (substitute-urls (list "https://substitutes.nonguix.org"))
    (authorized-keys (list (plain-file "nonguix.pub" "(public-key (ecc (curve Ed25519) (q #C1FD53E5D4CE971933EC50C9F307AE2171A2D3B52C804642A7A35F84F3A4EA98#)))"))))))

(define (feature-additional-services)
  (feature-custom-services
   #:feature-name-prefix 'kyurivlis
   #:system-services
   (list guix-substitutes-service
         (service openssh-service-type)
         (service sddm-service-type
                  (sddm-configuration
                   (auto-login-user "kyurivlis")
                   (auto-login-session "stumpwm")))
         )
   #:home-services
   (list
    home-extra-packages-service
    ssh-extra-config-service
    i2pd-add-ilita-irc-service
    mpv-add-user-settings-service
    rde-guix-add-to-shell-profile-service
    add-to-path-nix-and-local)))


;;; User-specific features with personal preferences
 (define* (feature-personal-emacs-config)
  "Personal Emacs configuration with extra packages and settings."
  (define f-name 'personal-emacs-config)

  (define (get-home-services config)
    (list
     (rde-elisp-configuration-service
      f-name
      config
      `((with-eval-after-load 'org
          (setq org-use-speed-commands t)
          (setq org-enforce-todo-dependencies t)
          ;; (setq org-enforce-todo-checkbox-dependencies t)
          (setq org-log-reschedule 'time)
          (defun rde-org-goto-end-of-heading ()
            (interactive)
            (org-end-of-meta-data t)
            (left-char)
            (unless (string-blank-p (buffer-substring (line-beginning-position)
                                                      (line-end-position)))
              (newline)))
          (define-key org-mode-map (kbd "M-o") 'rde-org-goto-end-of-heading))

        (with-eval-after-load 'geiser-mode
          (setq geiser-mode-auto-p nil)
          (defun abcdw-geiser-connect ()
            (interactive)
            (geiser-connect 'guile "localhost" "37146"))

          (define-key geiser-mode-map (kbd "C-c M-j") 'abcdw-geiser-connect))

        (with-eval-after-load 'page-break-lines
          (global-page-break-lines-mode 1))
        (with-eval-after-load 'simple
          (setq-default display-fill-column-indicator-column 80)
          (add-hook 'prog-mode-hook 'display-fill-column-indicator-mode))

        (setq copyright-names-regexp
              (format "%s <%s>" user-full-name user-mail-address))
        (add-hook 'after-save-hook (lambda () (copyright-update nil nil)))
        (add-hook 'emacs-startup-hook (lambda () (load-file "/home/kyurivlis/cfg/files/init.el")))

        )
      #:elisp-packages
      (append
       (list
        ;; (@ (rde packages emacs-xyz) emacs-corfu-candidate-overlay)
        )
       (strings->packages
        ;; "emacs-dirvish"
        "emacs-symex-ide"
        "emacs-org-noter"
        "emacs-elixir-mode"
        "emacs-ekg"
        "emacs-company-posframe"
        "emacs-wgrep"
        "emacs-ox-haunt"
        "emacs-haskell-mode"
        "emacs-rainbow-mode"
        "emacs-hl-todo"
        "emacs-yasnippet"
        ;; "emacs-xkb-mode"
        ;; "emacs-consult-dir"
        "emacs-kind-icon"
        "emacs-nginx-mode" "emacs-yaml-mode"
        "emacs-multitran"
        "emacs-minimap"
        "emacs-ement"
        "emacs-geiser" "emacs-geiser-guile"
        "emacs-restart-emacs"
        "emacs-org-present")))))
  (feature
     (name f-name)
     (values `((,f-name . #t)))
     (home-services-getter get-home-services)))

;; wut
(define* (feature-personal-base-services)
  (let ((f (feature-base-services)))
    (feature
     (name (feature-name f))
     (values (feature-values f))
     (system-services-getter
      (lambda (c)
	(let ((s ((feature-system-services-getter f) c)))
	  (modify-services s
	                   (guix-service-type config =>
     				              (guix-configuration
     				               (inherit config)
     				               (substitute-urls
     				                (list "https://bordeaux.guix.gnu.org" "http://ci.guix.trop.in"))))))))
     )))


(define emacs-features
  (list
   (feature-emacs-tab-bar)
   (feature-markdown)
   (feature-personal-emacs-config)
   (feature-emacs #:emacs emacs)
   (feature-emacs-ednc)
   ))

(define virtualization-features
  (list
   (feature-podman)
   (feature-distrobox)
   (feature-qemu)))

(define general-features
  (append
   (remove (lambda (f)
             (member
              (feature-name f)
              '(swaylock
	        base-services
                xdg
                emacs
                kernel
                )))
           (append
            rde-base
            rde-mail
            rde-emacs
            rde-cli))
   (list
    (feature-additional-services)
    (feature-personal-base-services)
    (feature-base-packages
     #:system-packages
     (list stumpwm))
    (feature-librewolf)
    (feature-mpv)
    (let* ((s 14)
           (p font-aporetic))
      (feature-fonts
       #:default-font-size s
       #:font-monospace
       (font (name "Aporetic Sans Mono") (size s) (package p))
       #:font-serif
       (font (name "Aporetic Serif") (size s) (package p))
       #:font-sans
       (font (name "Aporetic Sans") (size s) (package p))))
    (feature-gtk3)
    (feature-transmission)
    (feature-foot)
    (feature-yggdrasil)
    (feature-yt-dlp)
    (feature-i2pd
     #:outproxy 'http://acetone.i2p:3128
     ;; 'purokishi.i2p
     #:less-anonymous? #t)
    (feature-clojure)
    )))

(define-public %kyurivlis-features
  (append
   general-features
   emacs-features
   virtualization-features
   (list
    (feature-xdg
     #:xdg-user-directories-configuration
     (home-xdg-user-directories-configuration
      (music "$HOME/m/t")
      (videos "$HOME/m/v")
      (pictures "$HOME/m/p")
      (documents "$HOME/m/d")
      (download "$HOME/d")
      (desktop "$HOME")
      (publicshare "$HOME/shr")
      (templates "$HOME/tpl"))
     )
    (feature-user-info
     #:user-name "kyurivlis"
     #:full-name "Yuri Kholodkov"
     #:email "kyurivlis@autistici.org"
     #:user-groups '("wheel" "netdev" "audio" "video" "dialout" "input")
     #:emacs-advanced-user? #t
     #:user-initial-password-hash
     "$6$f$1wv9ESj/Hzolses5lsu36iOItFMC.hwy450OEm0nj1Ut0pxke4dnRLXuPbycV33Dm/bvHM5DO5nWvZJ6AWikC1")
    (feature-gnupg
     ;; https://wiki.debian.org/GnuPG/AirgappedMasterKey glhf
     ;; last 16 chars of main key
     #:gpg-primary-key "F9E48A9E639F1DCD"
     ;; authentication subkey
     #:ssh-keys '(("63F702C2A14A730AB2E206D7C7C35FACADF0E869")))
    ;; (feature-security-token)
    ;; (feature-password-store
    ;;  #:password-store-directory "/data/kyurivlis/password-store"
    ;;  #:remote-password-store-url "ssh://kyurivlis@olorin.lan/~/state/password-store")

    (feature-mail-settings
     #:mail-directory-fn (const "/home/kyurivlis/m/e")
     #:mail-accounts (list
                      (mail-account
                       (id 'work)
                       (type 'migadu)
                       (fqda "kyurivlis@autistici.org")
                       (pass-cmd "pass show mail/work")))
     #:mailing-lists (list (mail-lst 'guile-devel "guile-devel@gnu.org"
                                     '("https://yhetil.org/guile-devel/0"))
                           (mail-lst 'guix-devel "guix-devel@gnu.org"
                                     '("https://yhetil.org/guix-devel/0"))
                           (mail-lst 'guix-bugs "guix-bugs@gnu.org"
                                     '("https://yhetil.org/guix-bugs/0"))
                           (mail-lst 'guix-patches "guix-patches@gnu.org"
                                     '("https://yhetil.org/guix-patches/1"))))

    (feature-irc-settings
     #:irc-accounts (list
                     (irc-account
                      (id 'srht)
                      (network "chat.sr.ht")
                      (bouncer? #t)
                      (nick "kyurivlis"))
                     (irc-account
                      (id 'libera)
                      (network "irc.libera.chat")
                      (nick "kyurivlis"))
                     (irc-account
                      (id 'oftc)
                      (network "irc.oftc.net")
                      (nick "kyurivlis"))))
    ;(feature-android)
    ;(feature-javascript)
    ;(feature-ocaml #:opam? #t)

    (feature-sourcehut
     #:user-name-fn (const "kyurivlis"))

;;    (feature-libreoffice)

    (feature-keyboard
     ;; To get all available options, layouts and variants run:
     ;; cat `guix build xkeyboard-config`/share/X11/xkb/rules/evdev.lst
     #:keyboard-layout
     (keyboard-layout
      "us,ru" ","
      #:options '("grp:shifts_toggle"))))))
