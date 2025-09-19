(define-module (rc hosts zarya)
  #:use-module (rde features base)
  #:use-module (rde features system)
  #:use-module (rde features wm)
  #:use-module (gnu system file-systems)
  #:use-module (gnu system mapped-devices)
  #:use-module (ice-9 match)
  #:use-module (nongnu packages linux)
    #:use-module (gnu packages linux)
  #:use-module (nongnu system linux-initrd)
  #:use-module (gnu bootloader grub)
  #:use-module (gnu bootloader))


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
;;             (dependencies zarya-mapped-devices))))
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

(define zarya-file-systems
  (list
   (file-system
    (device (file-system-label "main"))
    (mount-point "/")
    (type "btrfs")
    (options "compress=zstd,discard=async")
    (flags '(no-atime)))))

(define-public %zarya-features
  (list
   (feature-host-info
    #:host-name "fl"
    ;; ls `guix build tzdata`/share/zoneinfo
    #:timezone  "Europe/Moscow")
   ;;; Allows to declare specific bootloader configuration,
   ;;; grub-efi-bootloader used by default
   (feature-bootloader
    #:bootloader-configuration
    (bootloader-configuration
     (bootloader grub-bootloader)
     (targets '("/dev/sda"))))
   (feature-kernel
;;    #:kernel linux-libre-lts
    #:kernel linux-lts
    #:initrd microcode-initrd
    #:firmware (list linux-firmware)
    #:kernel-arguments '("net.ifnames=0"))

   (feature-file-systems
    #:file-systems   zarya-file-systems)
   ))
