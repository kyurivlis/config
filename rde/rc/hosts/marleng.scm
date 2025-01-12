(define-module (rc hosts marleng)
  #:use-module (rde features base)
  #:use-module (rde features system)
  #:use-module (rde features wm)
  #:use-module (gnu system file-systems)
  #:use-module (gnu system mapped-devices)
  #:use-module (ice-9 match))


;;; Hardware/host specifis features

;; TODO: Switch from UUIDs to partition labels For better
;; reproducibilty and easier setup.  Grub doesn't support luks2 yet.

;; (define btrfs-subvolumes
;;   (map (match-lambda
;;          ((subvol . mount-point)
;;           (file-system
;;             (type "btrfs")
;;             (device "/dev/mapper/enc")
;;             (mount-point mount-point)
;;             (options (format #f "subvol=~a" subvol))
;;             (dependencies marleng-mapped-devices))))
;;        '((@ . "/")
;;          (@boot . "/boot")
;;          (@gnu  . "/gnu")
;;          (@home . "/home")
;;          (@data . "/data")
;;          (@var-log . "/var/log")
;;          (@swap . "/swap"))))

;; (define data-fs
;;   (car
;;    (filter
;;     (lambda (x) (equal? (file-system-mount-point x) "/data"))
;;     btrfs-subvolumes)))

(define marleng-file-systems
  (list
   (file-system
    (device (file-system-label "main"))
    (mount-point "/")
    (type "btrfs")
    (options "compress=zstd,discard=async")
    (flags '(no-atime)))
   (file-system
    (device (file-system-label "efi"))
    (mount-point "/boot/efi")
    (type "vfat"))))

(define-public %marleng-features
  (list
   (feature-host-info
    #:host-name "nl"
    ;; ls `guix build tzdata`/share/zoneinfo
    #:timezone  "Europe/Moscow")
   ;;; Allows to declare specific bootloader configuration,
   ;;; grub-efi-bootloader used by default
   ;; (feature-bootloader)
   (feature-file-systems
    #:file-systems   marleng-file-systems)
   ))
