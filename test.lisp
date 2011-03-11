(eval-when (:compile-toplevel)
  (require :cl-ppcre))

(defpackage :run (:use :cl :cl-ppcre))
(in-package :run)

;; read /data/Xilinx/12.3/ISE_DS/ISE/lib/lin/perllib/5.8.8/pod/perlrequick.pod
;; for regular expression tutorial
;; note: here i realize that regex isn't useful for parsing recursive structures
(with-open-file (str "/usr/local/include/x264.h" :direction :input)
  (let ((all (make-string (file-length str))))
    (read-sequence all str)
    ;; typedef struct and optional name followed by {
    ;; then smallest string containing everything until }
    ;; then extract the name of the struct 
    
    ;; uncomment uses perlop sample code that deletes (most) C comments, the
    ;; '*?'  searches for the shortest string
	  
    (let* ((uncomment (regex-replace-all "/\\*((\\n|.)*?)\\*/" all ""))
	   (newline-string (make-string 1 :initial-element #\Newline))
	   (reduced-newlines (regex-replace-all 
			      "\\s*\\n" uncomment
			      newline-string))
	   (struct-body-name 
	    "(typedef\\s)?struct\\s*\\w*\\s*{\\s*((\\n|.)*?)(\\n})\\s*([^;]*);")
	   (internal-struct
	    "struct\\s*\\w*\\s*{\\s*((\\n|.)*?)(\\n\\s*})\\s*([^;]*);")
	   (type-decl "\\s*(\\w*\\s*[*\\s])([^;]*);"))
      ;(format t "~a~%" reduced-newlines)

      (do-register-groups (a decls c d name) (struct-body-name reduced-newlines)
	(when (string-equal name "x264_param_t")
	  (do-register-groups (decls b c name) (internal-struct decls)
	    (do-register-groups (type vname) (type-decl decls)
	      (format t "~a~%" `((,type) ,name . ,vname)))))))
    ;; find all constant definitions in x264.h, remove prefix X264_
    #+nil (do-register-groups (a b) ("#define\\s(X264_([0-9A-Z_]*))" 
			       all)
      (format t "~a~%" (list a b)))))

