;;; Module
(define-module (cfg))

(use-modules (ice-9 regex) (ice-9 ftw) (srfi srfi-1) (srfi srfi-13) (srfi srfi-26)
             (ice-9 match) (ice-9 control) (srfi srfi-9)
             (gnu) (gnu services) (gnu packages) (guix packages) (guix gexp) (guix build utils)
             (rde packages) (rde home services video) (rde features)
             (gnu bootloader) (gnu bootloader grub))

(define (find-files pat)
  (define (f lof pat)
    (cond
     ((or (null? lof) (null? pat)) lof)
     (else
      (let ((nlof (scandir (car lof) (cut string-match (car pat) <>))))
        (cond
         (nlof (set! nlof (map (lambda (x) (string-join (list (car lof) x) "/"))
                               (remove (cut string-match "^\\.\\.?$" <>) nlof)))
               (append (f nlof (cdr pat)) (f (cdr lof) pat)))
         (else
          (f (cdr lof) pat)))))))
  (f '(".") (string-split pat #\/)))

(define (use-most-cfg-modules)
  (with-directory-excursion
   (getenv "GUIX_PROFILE")
   (let ((mods "share/guile/site/3.0/")
         (pats (list "./package/." "./service/." "./feature/."  "./home/." "./system/.")))
     (eval
      `(use-modules
        ,@(apply append
                 (map (lambda (p)
                        (map (lambda (x)
                               (set! x (substring x 0 (- (string-length x) 4)))
                               (map string->symbol (take-right (string-split x #\/) 3)))
                             (find-files (string-append mods (string-append p "\\.scm$")))))
                      pats)))
      (current-module)))))

;; FIXME shadow bug, config fields -> unbound variables.
(use-most-cfg-modules)
(use-modules (rde features xdg) (gnu services web))

;;; Util
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

;; TODO manage multiple hosts cleanly
(define (efi-sys?)
  (file-exists? "/sys/firmware/efi"))

;; TODO doesn't work with make, asks for more modules than necessary
(define* (symbols->packages #:rest lst)
  (map (lambda (sym) (specification->package+output (symbol->string sym))) lst))

;; TODO generalized for every cons if test apply?
(define (stringify sexp)
  (match sexp
    ((arg . rest) (cons (stringify arg) (stringify rest)))
    ((? symbol? s) (symbol->string s))
    ((? string? s) s)
    (() '())
    (_ "")))

;;; Features
;;;; Home services
(define home-extra-packages-service
  (simple-service
   'home-profile-extra-packages
   home-profile-service-type
   (append
    (list
     (@ (gnu packages tree-sitter) tree-sitter-clojure)
     (@ (gnu packages tree-sitter) tree-sitter-html)
     ;; (@ (nongnu packages mozilla) firefox)
     )
    (strings->packages
     "nyxt" "yt-dlp" "curl" "nss-certs"
     "fd" "ripgrep" "recutils" "binutils" "gdb" "stow"
     "imagemagick"  "make"
     "pavucontrol" "alsa-utils"
     "adwaita-icon-theme"))))

;; (define mpv-add-user-settings-service
;;   (simple-service
;;    'mpv-add-user-settings-irc
;;    home-mpv-service-type
;;    (home-mpv-extension
;;     (mpv-conf
;;      `((global
;;         ((keep-open . yes)
;;          (ytdl-format . "bestvideo[height<=?720][fps<=?30]+bestaudio/best")
;;          (save-position-on-quit . yes)
;;          (speed . 1.61))))))))

(define add-to-path-nix-and-local
  (simple-service
   'add-nix-and-local-bin
   home-environment-variables-service-type
   `(("PATH" . "$HOME/.local/bin:$HOME/.nix-profile/bin:$PATH"))))

;;;; Core
(define core-features
  (list
   (feature-base-services
    #:default-substitute-urls '("https://bordeaux.guix.gnu.org" "https://cuirass.genenetwork.org" "http://ci.guix.trop.in" "https://substitutes.nonguix.org")
    #:guix-authorized-keys (list (plain-file "nonguix.pub" "(public-key (ecc (curve Ed25519) (q #C1FD53E5D4CE971933EC50C9F307AE2171A2D3B52C804642A7A35F84F3A4EA98#)))")
				 (plain-file "na" "(public-key (ecc (curve Ed25519) (q #9578AD6CDB23BA51F9C4185D5D5A32A7EEB47ACDD55F1CCB8CEE4E0570FBF961#)))")))
   (feature-desktop-services)
   (feature-user-info
    #:user-name "kyurivlis"
    #:full-name "Yuri Kholodkov"
    #:email "kyurivlis@autistici.org"
    #:user-groups '("wheel" "netdev" "audio" "video" "dialout" "input")
    #:emacs-advanced-user? #t)
   ;; https://wiki.debian.org/GnuPG/AirgappedMasterKey glhf
   (feature-gnupg
    ;; last 16 chars of main key
    #:gpg-primary-key "7F1A388DA6D2F8C8"
    ;; authentication subkey
    #:ssh-keys '(("B3B323E26BAA661F09143F782374A047917DE580")))
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
     (templates "$HOME/tpl")))
   (feature-keyboard #:keyboard-layout (keyboard-layout "us,ru" "," #:options '("grp:shifts_toggle")))))

;;;; Host
(define-record-type adhost
  (make-adhost name rootfs kernel)
  adhost?
  (name ahname)
  (rootfs ahrootfs)
  (kernel ahkernel))

(define ahext4
  (file-system
   (device (file-system-label "main"))
   (mount-point "/")
   (type "ext4")))
(define ahbtrfs
  (file-system
   (device (file-system-label "main"))
   (mount-point "/")
   (type "btrfs")
   (options "compress=zstd,discard=async")
   (flags '(no-atime))))
;;(define ahbcachefs  '())

(define ahlinux
  (feature-kernel
   #:kernel linux-lts
   #:initrd microcode-initrd
   #:firmware (list linux-firmware)
   #:kernel-arguments '("net.ifnames=0")))

(define ahlinuxlibre
  (feature-kernel
   #:kernel linux-libre))

(define adhosts (map make-adhost (stringify '(tp vm hp wv ez nl))
                     (list ahext4 ahext4 ahbtrfs ahbtrfs ahbtrfs ahbtrfs)
                     (list ahlinux ahlinuxlibre ahlinux ahlinuxlibre ahlinux ahlinuxlibre)))

(define myhost (car (find-tail (lambda (h) (string= (or (getenv "HOSTNAME") (gethostname)) (ahname h))) adhosts)))
;; (define myhost (make-adhost
;;                 "nl"
;;                 (file-system
;;                         (device (uuid "d6d9bccc-ca0c-4579-abf2-dabf9c02c579"))
;;                         (mount-point "/")
;; 			(options "compress=zstd,discard=async")
;;                         (type "btrfs"))
;;                 ahlinux))

(define host-features
  (list
   (feature-host-info
    #:host-name (ahname myhost)
    #:timezone "Europe/Moscow")
   (if (efi-sys?)
       (feature-bootloader)
       (feature-bootloader
        #:bootloader-configuration
        (bootloader-configuration
         (bootloader grub-bootloader)
         (targets '("/dev/sda")))))
   (ahkernel myhost)
   (feature-file-systems
    #:file-systems
    (cons (ahrootfs myhost)
            (if (efi-sys?)
                (list (file-system
                       (device (file-system-label "efi"))
                       (mount-point "/boot/efi")
                       (type "vfat")))
                '()))
    #:swap-devices
    (list (swap-space
           (target "/swap/swapfile")
           (discard? #t))))
   ))

;;;; GUI
(define gui-features
  (if (string= (gethostname) "wv")
      (list
       (feature-emacs #:emacs emacs
                      ;; #:extra-early-init-el `((load-file "~/c/emacs/early-init.el"))
                      ;; #:extra-init-el `((load-file "~/c/emacs/init.el"))
                      )
       ;; (feature-emacs-exwm)
       ;; (feature-emacs-exwm-run-on-tty)
       (feature-emacs-ednc))
      (list
       ;; (feature-emacs #:emacs emacs)
       ;; (feature-emacs-ednc)
       ;; (feature-sway)
       ;; (feature-emacs-power-menu)
       ;; (feature-sway-run-on-tty)
       ;; (feature-sway-screenshot)
       ;; ;; (feature-sway-statusbar
       ;; ;;  #:use-global-fonts? #f)
       ;; (feature-swaynotificationcenter)
       ;; (feature-waybar)
       ;; (feature-swayidle)
       ;; (feature-swaylock)
       )))

;;;; Other
(define other-features
  (list
;;;;; Misc
   (feature-base-packages #:system-packages (list nix))
   (feature-custom-services
    #:feature-name-prefix 'qeqpep
    #:system-services
    (list
     (service nix-service-type)
     (service httpd-service-type
              (httpd-configuration
               (config
                (httpd-config-file
                 (server-name "kyurivlis.mooo.com")
                 (document-root "/srv/http/kyurivlis.mooo.com")))))
     (service openssh-service-type))
    #:home-services
    (list
     home-extra-packages-service
;;     mpv-add-user-settings-service
     add-to-path-nix-and-local))
   (feature-yggdrasil)
   (feature-networking)

;;;;; Apps
  (feature-fonts)
 ;; (feature-msmtp)
  (feature-gtk3)
;;  (feature-batsignal)
;;  (feature-imv)
;;  (feature-ledger)
  (feature-mpv)
  ;; (feature-transmission #:auto-start? #f)

;;;;; Dev
   (feature-bash)
   (feature-zsh)
   (feature-direnv)
   (feature-git
    #:sign-commits? #f)
   (feature-guile)
   (feature-ssh)
   (feature-docker)
   ;; (feature-qemu)
   ))

;;;;; Emacs
(define emacs-features
  (list
   (feature-emacs-tab-bar)
   (feature-emacs-vertico)
   (feature-emacs-completion)
   (feature-emacs-corfu)
   (feature-emacs-appearance)
   (feature-emacs-modus-themes)
   (feature-emacs-dashboard)
      (feature-emacs-tramp)
   (feature-emacs-project)
   (feature-compile)
   (feature-emacs-input-methods)
   (feature-emacs-which-key)
   (feature-emacs-dired)
   (feature-emacs-eshell)
   (feature-emacs-monocle)

;;   (feature-emacs-message)
   ;; (feature-emacs-erc
   ;;  #:erc-log? #t
   ;;  #:erc-autojoin-channels-alist '((Libera.Chat "#rde")))
   (feature-emacs-telega)
   (feature-emacs-elpher)
   (feature-emacs-webpaste)

   (feature-emacs-pdf-tools)
   (feature-emacs-nov-el)
;   (feature-emacs-org-protocol)

   (feature-emacs-smartparens
    #:show-smartparens? #t)
   (feature-emacs-eglot)
   ))

;;;; Minimal
(define min-features
  (list
   (feature-zsh
    #:zprofile
    `("source /etc/profile"
      "source \"HOME\"/.cargo/env"))

   (feature-emacs-portable)
   (feature-fonts)

     (feature-emacs-keycast #:turn-on? #t)
     (feature-emacs-which-key)
     (feature-emacs-vertico)
     (feature-emacs-completion)
     (feature-emacs-eshell)

     (feature-vterm)
     (feature-git #:sign-commits? #f)
     (feature-emacs-git)
     (feature-emacs-project)
     (feature-emacs-org)
     (feature-emacs-org-roam
      #:org-roam-directory "~/o/wiki")
     (feature-emacs-org-agenda
      #:org-agenda-files '("~/o/todo.org"))
     (feature-emacs-appearance)
     (feature-emacs-modus-themes)))

;;; Dispatch
(define cfg (rde-config (features (append core-features host-features gui-features other-features ;; emacs-features
))))
(define os (rde-config-operating-system cfg))
(define home (rde-config-home-environment cfg))

(define mincfg (rde-config (integrate-he-in-os? #t) (features (append core-features host-features min-features))))
(define minos (rde-config-operating-system mincfg))
(define minhome (rde-config-home-environment mincfg))

(define* (dispatch #:optional (target (getenv "TRG")) (cfg (getenv "CFG")))
    (match (stringify target)
      ("sys" (if (stringify cfg) os minos))
      (_ (if (stringify cfg) home minhome))))

(dispatch)
