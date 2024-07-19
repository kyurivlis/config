#!/usr/bin/env -S guile -s
!#
(use-modules (srfi srfi-1) (ice-9 pretty-print))

(define f (second (command-line)))

(with-input-from-file f
  (lambda ()
    (let ((chans (map (lambda (c)
		        (cons (car c)
			      (remove (lambda (e) (eq? (car e) 'commit))
                                      (cdr c))))
		      (cdr (read)))))
      (with-output-to-file f
        (lambda () (pretty-print (cons 'list chans)))))))
