(define-module (rc main)
  #:use-module (rde features)
  #:use-module (gnu services)
  #:use-module (srfi srfi-1)
  #:use-module (ice-9 match)
  #:use-module (rc hosts cloud)
  #:use-module (rc hosts live)
  #:use-module (rc hosts marleng)
  #:use-module (rc users kyurivlis)
  #:use-module (rc users guest))

;; (define* (use-nested-configuration-modules
;;           #:key
;;           (users-subdirectory "/users")
;;           (hosts-subdirectory "/hosts"))
;;   (use-modules (guix discovery)
;;                (guix modules))

;;   (define current-module-file
;;     (search-path %load-path
;;                  (module-name->file-name (module-name (current-module)))))

;;   (define current-module-directory
;;     (dirname (and=> current-module-file canonicalize-path)))

;;   (define src-directory
;;     (dirname current-module-directory))

;;   (define current-module-subdirectory
;;     (string-drop current-module-directory (1+ (string-length src-directory))))

;;   (define users-modules
;;     (scheme-modules
;;      src-directory
;;      (string-append current-module-subdirectory users-subdirectory)))

;;   (define hosts-modules
;;     (scheme-modules
;;      src-directory
;;      (string-append current-module-subdirectory hosts-subdirectory)))

;;   (map (lambda (x) (module-use! (current-module) x)) hosts-modules)
;;   (map (lambda (x) (module-use! (current-module) x)) users-modules))

;;(use-nested-configuration-modules)


;;; Some TODOs

;; TODO: Add an app for saving and reading articles and web pages
;; https://github.com/wallabag/wallabag
;; https://github.com/chenyanming/wallabag.el

;; TODO: feature-animated-wallpapers (make my own!)
;; TODO: feature-librewolf
;; TODO: Revisit <https://en.wikipedia.org/wiki/Git-annex>
;; TODO: <https://www.labri.fr/perso/nrougier/GTD/index.html#table-of-contents>


;;; marleng

(define-public marleng-config
  (rde-config
   (features
    (append
     %marleng-features
     %kyurivlis-features))))

(define-public marleng-os
  (rde-config-operating-system marleng-config))

(define-public marleng-he
  (rde-config-home-environment marleng-config))


;;; live

;; TODO: Pull channels from lock file in advance and link them to example-config
;; TODO: Add auto-login

(define-public live-config
  (rde-config
   (integrate-he-in-os? #t)
   (features
    (append
     %live-features
     %guest-features))))

(define-public live-os
  (rde-config-operating-system live-config))


;;; Dispatcher, which helps to return various values based on environment
;;; variable value.

(define (dispatcher)
  (let ((rde-target (getenv "TRG")))
    (match rde-target
      ("home" marleng-he)
      ("sys" marleng-os)
      ("live" live-os)
      (_ marleng-he))))

;; (pretty-print-rde-config marleng-config)
;; (use-modules (gnu services)
;;           (gnu services base))
;; (display
;;  (filter (lambda (x)
;;         (eq? (service-kind x) console-font-service-type))
;;       (rde-config-system-services marleng-config)))

;; (use-modules (rde features))
;; ((@ (ice-9 pretty-print) pretty-print)
;;  (map feature-name (rde-config-features marleng-config)))

;; ((@ (ice-9 pretty-print) pretty-print)
;;  (rde-config-home-services marleng-config))

;; (define br ((@ (rde api store) build-with-store) marleng-he))
(dispatcher)


;;; TODO: Call reconfigure from scheme file.
;;; TODO: Rename configs.scm to main.scm?
