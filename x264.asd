(cl:eval-when (:compile-toplevel :load-toplevel :execute)
  (asdf:oos 'asdf:load-op :sb-grovel))
(defpackage #:x264-system (:use #:asdf #:cl #:sb-grovel))
(in-package #:x264-system)

(asdf:defsystem :x264
  :depends-on (sb-grovel)
  :components ((:file "packages")
	       (sb-grovel:grovel-constants-file "constants"
						:package :x264
						:depends-on ("packages"))))