(eval-when (:compile-toplevel :load-toplevel :execute) 
  (require :asdf)
  (require :x264))

(in-package :coder)

(load-shared-object "libx264.so")

(define-alien-routine x264_param_default_preset
    int
  (param x264_param_t :out)
  (preset c-string)
  (tune c-string))

(define-alien-routine x264_param_apply_profile
    int
  (param x264_param_t :in-out)
  (profile c-string))

(define-alien-routine x264_encoder_open_113
    (* int)
  (param x264_param_t :copy))

(defun init (&key (w 320) (h 240) (fps 30))
 (multiple-value-bind (ret param)
     (x264_param_default_preset "veryfast" "zerolatency")
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
    (multiple-value-bind (ret param2)
	(x264_param_apply_profile param "baseline")
      (let ((enc (x264_encoder_open_113 param2)))
	enc)))))
#+nil
(init)

(define-alien-routine x264_picture_alloc
    int
  (pic x264::x264_picture_t :out)
  (colorspace int)
  (width int)
  (height int))
#+nil
(multiple-value-list
 (x264_picture_alloc x264::X264_CSP_I420
		     320 240))

(define-alien-routine x264_encoder_encode
    int
  (handle (* int))
  (pp-nal (* (* x264::x264_nal_t)))
  (pi_nal int :out)
  (pic-in (* x264::x264_picture_t))
  (pic-out (* x264::x264_picture_t)))