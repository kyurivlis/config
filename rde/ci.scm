(define-module (rc ci)
  #:use-module (rde features)
  #:use-module (rde features base)
  #:use-module (rde features shells))


;;; Code:

(define minimal-rc
  (rde-config
   (features
    (list
     (feature-user-info
      #:user-name "jd"
      #:full-name "John Doe"
      #:email "john@doe.com"
      #:emacs-advanced-user? #t)
     (feature-zsh)))))

(rde-config-home-environment minimal-rc)
