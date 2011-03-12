(defpackage :x264
  (:use :cl :sb-alien)
  (:export
   #:x264_param_t))

(defpackage :coder
  (:use :cl :sb-alien :x264)
  (:export
  ))