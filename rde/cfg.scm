;;; Module
(define-module (cfg))

(use-modules (ice-9 regex) (ice-9 ftw) (srfi srfi-1) (srfi srfi-13) (srfi srfi-26))

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
  (chdir (getenv "GUIX_PROFILE"))
  (let ((mods "share/guile/site/3.0/")
        (pats (list "./package/." "./service/." "./feature/." "./home/.")))
    (eval
     `(use-modules
       ,@(apply append
                (map (lambda (p)
                       (map (lambda (x)
                              (set! x (substring x 0 (- (string-length x) 4)))
                              (map string->symbol (take-right (string-split x #\/) 3)))
                            (find-files (string-append mods (string-append p "\\.scm$")))))
                     pats)))
     (current-module))))
