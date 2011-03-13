(declaim (optimize (speed 0) (safety 3) (debug 3)))
(eval-when (:compile-toplevel :load-toplevel :execute) 
  (require :asdf)
  (require :x264))

(in-package :coder)

(load-shared-object "libx264.so")

(define-alien-routine x264_param_default_preset
    int
  (param (* x264_param_t))
  (preset c-string)
  (tune c-string))

(define-alien-routine x264_param_apply_profile
    int
  (param (* x264_param_t))
  (profile c-string))

(defun make-parameters (w h fps)
  (let ((param))
    (setf param (make-alien x264:x264_param_t))
    (x264_param_default_preset param "veryfast" "zerolatency")
    (macrolet ((p (a)
		 `(slot param ',a)))
      (setf (p x264::i_threads) 1
	    (p x264::i_width) w
	    (p x264::i_height) h
	    (p x264::i_fps_num) fps
	    (p x264::i_fps_den) 1
	    (p x264::i_keyint_max) fps
	    (p x264::b_intra_refresh) 1
	    (p x264::rc.i_rc_method) x264::X264_RC_CRF
	    (p x264::rc.f_rf_constant) 25s0
	    (p x264::rc.f_rf_constant_max) 35s0
	    (p x264::b_repeat_headers) 1
	    (p x264::b_annexb) 1)
      (x264_param_apply_profile param "baseline")
      param)))

(defmacro with-parameters ((param &key (h 240) (w (floor h 3/4)) (fps 30)) 
			   &body body)
  `(let ((,param))
     (unwind-protect
	  (progn
	    (setf ,param (make-parameters ,w ,h ,fps))
	    ,@body)
       (free-alien ,param))))

(define-alien-routine x264_encoder_open_113
    (* int) ;; it's actually a pointer to x264_t but that type is opaque
  (param (* x264::x264_param_t)))

(define-alien-routine x264_encoder_close
    void
  (handler (* int)))

(defmacro with-encoder ((handle param) &body body)
 `(let ((,handle))
    (unwind-protect
	 (progn (setf ,handle (x264_encoder_open_113 ,param))
		,@body)
      (x264_encoder_close ,handle))))

(define-alien-routine x264_picture_alloc 
    ;; mallocs pic->img.plane[0] aligned to 16byte boundary
    int
  (pic (* x264::x264_picture_t))
  (colorspace int)
  (width int)
  (height int))

(define-alien-routine x264_picture_clean ;; frees pic->img.plane[0]
    sb-alien:void
  (pic (* x264::x264_picture_t)))

(defmacro with-c-picture ((pic w h) &body body)
  "x264 library allocates space for image data"
  `(let ((,pic))
     (unwind-protect
	  (progn (setf ,pic (make-alien x264::x264_picture_t))
		 (x264_picture_alloc ,pic x264::X264_CSP_I420 ,w ,h)
		 ,@body)
       (progn 
	 (x264_picture_clean ,pic)
	 (free-alien ,pic)))))

;; maybe I can use lisp arrays (if they are 16byte aligned?) with this
;; function:
(define-alien-routine x264_picture_init 
    void
  (pic (* x264::x264_picture_t)))

(defmacro with-picture ((pic i420 w h) &body body)
  "x264 library allocates space for image data, i420 contains a WxH
Y-image followed by a (W/2)x(H/2) U-image and V-image."
  `(let ((,pic)
	 (colorspace x264::X264_CSP_I420) ;; yuv 4:2:0 planar
	 ;; HPwebcam delivers YUYV 4:2:2
	 )
     (unwind-protect
	  (let* ((,i420 (make-array (* 3/2 ,h ,w) :element-type '(unsigned-byte 8)))) 
	    (setf ,pic (make-alien x264::x264_picture_t))
	    (x264_picture_init ,pic)
	    (macrolet ((i (pic entry)
			 `(slot (slot ,pic 'x264::img) ',entry)))
	      (sb-sys:with-pinned-objects (,i420)
		(let* ((sap-y (sb-sys:vector-sap ,i420))
		       (sap-u (sb-sys:sap+ sap-y (* ,w ,h)))
		       (sap-v (sb-sys:sap+ sap-u (/ (* ,w ,h) 4))))
		  (setf (i ,pic x264::i_csp) colorspace
			(i ,pic x264::i_plane) 3
			(deref (i ,pic x264::plane) 0) (sap-alien sap-y (* (unsigned 8)))
			(deref (i ,pic x264::plane) 1) (sap-alien sap-u (* (unsigned 8)))
			(deref (i ,pic x264::plane) 2) (sap-alien sap-v (* (unsigned 8)))
			(deref (i ,pic x264::i_stride) 0) ,w
			(deref (i ,pic x264::i_stride) 1) (/ ,w 2)
			(deref (i ,pic x264::i_stride) 2) (/ ,w 2)))))
	    ,@body)
       (progn 
	 (free-alien ,pic)))))

#+nil
(defparameter *pic*
 (multiple-value-list
  (x264_picture_alloc x264::X264_CSP_I420
		      320 240)))

#+nil
(sb-alien:deref
 (slot (slot (second *pic*) 'x264::img) 'x264::plane)
 0)

#+nil
(with-picture (pic 320 240)
  (type-of (deref (slot (slot pic 'x264::img) 'x264::plane) 0)
	   ))

(define-alien-routine x264_encoder_encode
    int
  (handle (* int))
  (pp-nal (* (* x264::x264_nal_t))) ;; i think library does allocation
  (pi_nal int :out)
  (pic-in (* x264::x264_picture_t))
  (pic-out (* x264::x264_picture_t)))

(defun make-test-img (w h)
  (let ((yuyv (make-array (list h w 2) :element-type '(unsigned-byte 8))))
    (dotimes (i w)
      (dotimes (j h)
	(setf (aref yuyv j i 0) (mod i 255) ;; gray
	      (aref yuyv j i 1) (if (= 0 (mod i 2))
				    0 ;; u
				    j ;; v
				    ))))
    yuyv))

#+nil
(defparameter *e* (init))

(defun fo ()
  (let ((w 320) (h 240))
    (with-parameters (p :w w :h h)
      (with-encoder (enc p)
	(with-picture (pic i420 w h)
	  (let ((y (make-array (list h w) :element-type '(unsigned-byte 8)
			       :displaced-to i420)))
	    (dotimes (i w)
	      (dotimes (j h)
		(setf (aref y j i) (mod i 255))))
	    (with-picture (pic-out i420-out w h)
	      (let ((pp-nal (make-alien (* x264::x264_nal_t))))
		(defparameter *o* 
		  (list 'pp-nal pp-nal 
			'encode-values
			(multiple-value-list (x264_encoder_encode enc 
								  pp-nal
								  pic 
								  pic-out))))))))))))


(time (fo))


#+nil
(defun blub ()
 (let* ((w 320) (h 240)
	(m (make-test-img w h))
	(m1 (sb-ext:array-storage-vector m))
	(buf (make-array (* w h 2) :element-type '(unsigned-byte 8))))
   (with-picture (pic-out w h)
     (with-picture (pic w h)
       (setf (sb-alien:deref (slot (slot pic 'x264::img) 'x264::plane) 0)
	     (sb-sys:vector-sap m1))
       (sb-alien:with-alien ((pp-nal (* x264::x264_nal_t)))
	 (defparameter *o* 
	     (multiple-value-list (x264_encoder_encode *e* (sb-sys:vector-sap buf)
						       (sb-alien:addr pic) 
						       (sb-alien:addr pic-out)))))))))

#+nil
(blub)