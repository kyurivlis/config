(define-module (rc users kyurivlis)
  #:use-module (contrib features javascript)
  #:use-module (gnu home services shepherd)
  #:use-module (gnu home services xdg)
  #:use-module (gnu home services)
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
  #:use-module (rde features clojure)
  #:use-module (rde features emacs-xyz)
  #:use-module (rde features gnupg)
  #:use-module (rde features irc)
  #:use-module (rde features keyboard)
  #:use-module (rde features mail)
  #:use-module (rde features networking)
  #:use-module (rde features password-utils)
  #:use-module (rde features security-token)
  #:use-module (rde features system)
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
  #:use-module (rde features guile)
  #:use-module (rde features gtk)
  #:use-module (rde features emacs-xyz)
  #:use-module (rde features finance)
  #:use-module (rde features fontutils)
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

(define (feature-additional-services)
  (feature-custom-services
   #:feature-name-prefix 'kyurivlis
   #:home-services
   (list
    home-extra-packages-service
    ssh-extra-config-service
    i2pd-add-ilita-irc-service
    mpv-add-user-settings-service
    rde-guix-add-to-shell-profile-service
    add-to-path-nix-and-local)))

;;; User-specific features with personal preferences

;; Initial user's password hash will be available in store, so use this
;; feature with care (display (crypt "hi" "$6$abc"))

(define dev-features
  (list
   (feature-markdown)))

(define virtualization-features
  (list
   (feature-podman)
   (feature-distrobox)
   (feature-qemu)))

(define general-features
  (append
   rde-base
;;   rde-mail
   rde-emacs
   rde-cli
   (list
    (feature-librewolf)
    (feature-mpv)
    (feature-fonts)
    (feature-gtk3)
    ;; (feature-emacs-ednc)
    ;; (feature-transmission)
    )))

(define %all-features
  (append
   virtualization-features
   general-features))

;; To override default features obtained from (rde presets) just remove them
;; from the list and add them back with customizations needed.
(define all-features-cooked
  (append
   ;; "C-h S" (info-lookup-symbol), "C-c C-d C-i" (geiser-doc-look-up-manual)
   ;; to see the info manual for a particular function.

   ;; Here we basically remove all the features which has feature name equal
   ;; to either 'base-services or 'kernel.
   (remove (lambda (f)
             (member
              (feature-name f)
              '(base-services
                swaylock
                xdg
                kernel
                )))
           %all-features)
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
     (templates "$HOME/tpl")))
    (feature-kernel
     #:initrd-modules (list "btrfs"))
    (feature-base-services
     #:default-substitute-urls '("https://bordeaux.guix.gnu.org" "https://cuirass.genenetwork.org" "http://ci.guix.trop.in" "https://substitutes.nonguix.org")
     #:guix-authorized-keys
     (list (plain-file "nonguix.pub" "(public-key (ecc (curve Ed25519) (q #C1FD53E5D4CE971933EC50C9F307AE2171A2D3B52C804642A7A35F84F3A4EA98#)))")
		   (plain-file "na" "(public-key (ecc (curve Ed25519) (q #9578AD6CDB23BA51F9C4185D5D5A32A7EEB47ACDD55F1CCB8CEE4E0570FBF961#)))")))
    )))

(define-public %kyurivlis-features
  (append
   all-features-cooked
   (list
    (feature-additional-services)
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
     #:gpg-primary-key "7F1A388DA6D2F8C8"
     ;; authentication subkey
     #:ssh-keys '(("B3B323E26BAA661F09143F782374A047917DE580")))
    ;; (feature-security-token)
    ;; (feature-password-store
    ;;  #:password-store-directory "/data/kyurivlis/password-store"
    ;;  #:remote-password-store-url "ssh://kyurivlis@olorin.lan/~/state/password-store")

    (feature-mail-settings
     #:mail-directory-fn (const "/data/kyurivlis/mail")
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

    (feature-yggdrasil)
    (feature-i2pd
     #:outproxy 'http://acetone.i2p:3128
     ;; 'purokishi.i2p
     #:less-anonymous? #t)

    ;(feature-android)
    ;(feature-javascript)
    ;(feature-ocaml #:opam? #t)

    (feature-sourcehut
     #:user-name-fn (const "kyurivlis"))
    (feature-yt-dlp)

    (feature-libreoffice)

    (feature-keyboard
     ;; To get all available options, layouts and variants run:
     ;; cat `guix build xkeyboard-config`/share/X11/xkb/rules/evdev.lst
     #:keyboard-layout
     (keyboard-layout
      "us,ru" ","
      #:options '("grp:shifts_toggle"))))))
