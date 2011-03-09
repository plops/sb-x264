(require :cl-ppcre)

(defpackage :run (:use :cl :cl-ppcre))
(in-package :run)

;; read /data/Xilinx/12.3/ISE_DS/ISE/lib/lin/perllib/5.8.8/pod/perlrequick.pod
;; for regular expression tutorial
(with-open-file (str "/usr/local/include/x264.h" :direction :input)
  (let ((all (make-string (* 128 8192))))
    (read-sequence all str)
    ;; typedef struct and optional name followed by {
    ;; then smallest string containing everything until }
    ;; then extract the name of the struct 
    (let ((struct-body-name "typedef\\sstruct\\s\\w*\\s*{(([^.]|[.])*?)\\n}\\s([^;]*);")
	  ;; perlop sample code that deletes (most) C comments, the
	  ;; '*?'  searches for the shortest string
	  (comment "/\\*((.|[\\n])*?)\\*/"))
     (do-register-groups (a b c) (struct-body-name all)
       (let ((body
	      ;; replace multiple newlines with just one
	      (regex-replace-all "\\s*\\n"
				 (regex-replace-all comment a "") "
")))
	(format t "~a~%" 
		(list 
		 c
		 body)))))
    ;; find all constant definitions in x264.h, remove prefix X264_
    #+nil (do-register-groups (a b) ("#define\\s(X264_([0-9A-Z_]*))" 
			       all)
      (format t "~a~%" (list a b)))))

