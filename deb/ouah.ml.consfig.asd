(asdf:defsystem "ouah.ml.consfig"
  :serial t
  :depends-on (#:consfigurator #:cl-interpol)
  :components
  ((:file "package")
   (:file "consfig")))
               
