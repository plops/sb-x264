("/usr/local/include/x264.h")
#.(labels ((minus->underscore (seq)
	     (substitute #\_ #\- seq))
	   (make-slot (type c-type slots)
	      (loop for e in slots collect
		   (etypecase e
		     (cons
		      (destructuring-bind (array-symb name) e
			(unless (eq array-symb 'array) 
			  (error "I don't understand ~a. Its not of the form (array ...)." e))
			`((array ,type) ,name ,c-type 
			  ,(string-downcase (minus->underscore (symbol-name name))))))
		     (symbol
		      `(,type ,e ,c-type ,(minus->underscore (string-downcase (symbol-name e))))))))
	    (u32 (slots) (make-slot 'u32 "__u32" slots))
	    (s32 (slots) (make-slot 's32 "__s32" slots))
	    (u8 (slots)  (make-slot 'u8 "__u8" slots))
	    (constants-combine (prefix suffixes)
	      (loop for e in suffixes collect
		   `(:integer ,e ,(concatenate 
				   'string prefix 
				   (string-upcase (minus->underscore (symbol-name e)))))))
	    (enum-combine (prefix suffixes)
	      (loop for e in suffixes collect
		   (destructuring-bind (lisp-name c-name)
		       (if (consp e)
			   e
			   (list e e))
		     `(,lisp-name ,(concatenate 
				 'string prefix 
				 (string-upcase (minus->underscore (symbol-name c-name))))))))) 
    `((:integer X264_BUILD X264_CPU_CACHELINE_32 X264_CPU_CACHELINE_64 X264_CPU_ALTIVEC X264_CPU_MMX X264_CPU_MMXEXT X264_CPU_SSE X264_CPU_SSE2 X264_CPU_SSE2_IS_SLOW X264_CPU_SSE2_IS_FAST X264_CPU_SSE3 X264_CPU_SSSE3 X264_CPU_SHUFFLE_IS_FAST X264_CPU_STACK_MOD4 X264_CPU_SSE4 X264_CPU_SSE42 X264_CPU_SSE_MISALIGN X264_CPU_LZCNT X264_CPU_ARMV6 X264_CPU_NEON X264_CPU_FAST_NEON_MRC X264_CPU_SLOW_CTZ X264_CPU_SLOW_ATOM X264_CPU_AVX X264_ANALYSE_I4x4 X264_ANALYSE_I8x8 X264_ANALYSE_PSUB16x16 X264_ANALYSE_PSUB8x8 X264_ANALYSE_BSUB16x16 X264_DIRECT_PRED_NONE  X264_DIRECT_PRED_SPATIAL X264_DIRECT_PRED_TEMPORAL X264_DIRECT_PRED_AUTOX264_ME_DIA X264_ME_HEX X264_ME_UMH X264_ME_ESA X264_ME_TESA X264_CQM_FLAT X264_CQM_JVT X264_CQM_CUSTOM X264_RC_CQP X264_RC_CRF X264_RC_ABR X264_QP_AUTO X264_AQ_NONE X264_AQ_VARIANCE X264_AQ_AUTOVARIANCE X264_B_ADAPT_NONE X264_B_ADAPT_FAST X264_B_ADAPT_TRELLIS X264_WEIGHTP_NONE  X264_WEIGHTP_SIMPLE X264_WEIGHTP_SMART X264_B_PYRAMID_NONE X264_B_PYRAMID_STRICT X264_B_PYRAMID_NORMAL X264_KEYINT_MIN_AUTO X264_KEYINT_MAX_INFINITE X264_OPEN_GOP_NONE X264_OPEN_GOP_NORMAL X264_OPEN_GOP_BLURAY X264_CSP_MASK  X264_CSP_NONE X264_CSP_I420 X264_CSP_YV12 X264_CSP_NV12 X264_CSP_MAX X264_CSP_VFLIP X264_CSP_HIGH_DEPTH X264_TYPE_AUTO X264_TYPE_IDR X264_TYPE_I X264_TYPE_P X264_TYPE_BREF X264_TYPE_B X264_TYPE_KEYFRAME X264_LOG_NONE X264_LOG_ERROR X264_LOG_WARNING X264_LOG_INFO X264_LOG_DEBUG X264_THREADS_AUTO X264_SYNC_LOOKAHEAD_AUTO X264_NAL_HRD_NONE X264_NAL_HRD_VBR X264_NAL_HRD_CBR X264_PARAM_BAD_NAME X264_PARAM_BAD_VALUE)

      (enum NAL_UNKNOWN   
	    NAL_SLICE     
	    NAL_SLICE_DPA 
	    NAL_SLICE_DPB 
	    NAL_SLICE_DPC 
	    NAL_SLICE_IDR 
	    NAL_SEI       
	    NAL_SPS       
	    NAL_PPS       
	    NAL_AUD       
	    NAL_FILLER)

      (enum NAL_PRIORITY_DISPOSABLE
	    NAL_PRIORITY_LOW       
	    NAL_PRIORITY_HIGH     
	    NAL_PRIORITY_HIGHEST)

      (struct x264_nal_t
	      (int i_ref_idc)
	      (int i_type)
	      (int b_long_startcode)
	      (int i_first_mb)
	      (int i_last_mb)
	      (int i_payload)
	      (uint8_t* p_payload))
      (struct x264_zone_t
	      (int i_start) 
	      (int i_end)
	      (int b_force_qp)
	      (int i_qp)
	      (float f_bitrate_factor)
	      ((struct x264_param_t *) param))
      (struct x264_param_t
	      ((unsigned int) cpu)
	      ((int) i_threads)       
	      ((int) b_sliced_threads)  
	      ((int) b_deterministic) 
	      ((int) i_sync_lookahead) 
	      ((int) i_width)
	      ((int) i_height)
	      ((int) i_csp)  
	      ((int) i_level_idc)
	      ((int) i_frame_total) 
	      ((int) i_nal_hrd)
	      (structi vui
		      ((int) i_sar_height)
		      ((int) i_sar_width)
		      ((int) i_overscan)    
		      ((int) i_vidformat)
		      ((int) b_fullrange)
		      ((int) i_colorprim)
		      ((int) i_transfer)
		      ((int) i_colmatrix)
		      ((int) i_chroma_loc))    
	      ((int) i_frame_reference)  
	      ((int) i_dpb_size)
	      ((int) i_keyint_max)       
	      ((int) i_keyint_min)       
	      ((int) i_scenecut_threshold) 
	      ((int) b_intra_refresh)    
	      ((int) i_bframe)   
	      ((int) i_bframe_adaptive)
	      ((int) i_bframe_bias)
	      ((int) i_bframe_pyramid)   
	      ((int) i_open_gop)         
	      ((int) b_deblocking_filter)
	      ((int) i_deblocking_filter_alphac0)    
	      ((int) i_deblocking_filter_beta)       
	      ((int) b_cabac)
	      ((int) i_cabac_init_idc)
	      ((int) b_interlaced)
	      ((int) b_constrained_intra)
	      ((int) i_cqm_preset)
	      ((char*) psz_cqm_file)      
	      ((uint8_t) cqm_4iy[16])        
	      ((uint8_t) cqm_4ic[16])
	      ((uint8_t) cqm_4py[16])
	      ((uint8_t) cqm_4pc[16])
	      ((uint8_t) cqm_8iy[64])
	      ((uint8_t) cqm_8py[64])
	      ((void*)       p_log_private)
	      ((int) i_log_level)
	      ((int) b_visualize)
	      ((char*) psz_dump_yuv)  
	      (structi analyse
		      ((unsigned int) intra)     
		      ((unsigned int) inter)     
		      ((int) b_transform_8x8)
		      ((int) i_weighted_pred) 
		      ((int) b_weighted_bipred) 
		      ((int) i_direct_mv_pred) 
		      ((int) i_chroma_qp_offset)
		      ((int) i_me_method) 
		      ((int) i_me_range) 
		      ((int) i_mv_range) 
		      ((int) i_mv_range_thread) 
		      ((int) i_subpel_refine) 
		      ((int) b_chroma_me) 
		      ((int) b_mixed_references) 
		      ((int) i_trellis)  
		      ((int) b_fast_pskip) 
		      ((int) b_dct_decimate) 
		      ((int) i_noise_reduction) 
		      ((float) f_psy_rd) 
		      ((float) f_psy_trellis) 
		      ((int) b_psy) 
		      ((int) i_luma_deadzone[2]) 
		      ((int) b_psnr)    
		      ((int) b_ssim))    
	      (structi rc
		      ((int) i_rc_method)    
		      ((int) i_qp_constant)  
		      ((int) i_qp_min)       
		      ((int) i_qp_max)       
		      ((int) i_qp_step)      
		      ((int) i_bitrate)
		      ((float) f_rf_constant)  
		      ((float) f_rf_constant_max)  
		      ((float) f_rate_tolerance)
		      ((int) i_vbv_max_bitrate)
		      ((int) i_vbv_buffer_size)
		      ((float) f_vbv_buffer_init) 
		      ((float) f_ip_factor)
		      ((float) f_pb_factor)
		      ((int) i_aq_mode)      
		      ((float) f_aq_strength)
		      ((int) b_mb_tree)      
		      ((int) i_lookahead)
		      ((int) b_stat_write)   
		      ((char) *psz_stat_out)
		      ((int) b_stat_read)    
		      ((char) *psz_stat_in)
		      ((float) f_qcompress)    
		      ((float) f_qblur)        
		      ((float) f_complexity_blur) 
		      ((x264_ zone_t*) zones)         
		      ((int) i_zones)        
		      ((char* )        psz_zones)
		      (structi copy_rect
			       ((unsigned int) i_left)
			       ((unsigned int) i_top)
			       ((unsigned int) i_right)
			       ((unsigned int) i_bottom))
		      ((int) i_frame_packing)
		      ((int) b_aud))                  
	      ((int) b_repeat_headers)       
	      ((int) b_annexb)
	      ((int) i_sps_id)               
	      ((int) b_vfr_input)
	      ((int) b_pulldown)             
	      ((uint32_t) i_fps_num)
	      ((uint32_t) i_fps_den)
	      ((uint32_t) i_timebase_num)    
	      ((uint32_t) i_timebase_den)    
	      ((int) b_tff)
	      ((int) b_pic_struct)
	      ((int) b_fake_interlaced)
	      ((int) i_slice_max_size)    
	      ((int) i_slice_max_mbs)     
	      ((int) i_slice_count))

      (struct x264_level_t
	      ((int) level_idc)
	      ((int) mbps)        
	      ((int) frame_size)  
	      ((int) dpb)         
	      ((int) bitrate)     
	      ((int) cpb)         
	      ((int) mv_range)    
	      ((int) mvs_per_2mb) 
	      ((int) slice_rate)  
	      ((int) mincr)       
	      ((int) bipred8x8)   
	      ((int) direct8x8)   
	      ((int) frame_only))
      
      (enum pic_struct_e  PIC_STRUCT_AUTO              
	    PIC_STRUCT_PROGRESSIVE       
	    PIC_STRUCT_TOP_BOTTOM        
	    PIC_STRUCT_BOTTOM_TOP        
	    PIC_STRUCT_TOP_BOTTOM_TOP    
	    PIC_STRUCT_BOTTOM_TOP_BOTTOM 
	    PIC_STRUCT_DOUBLE            
	    PIC_STRUCT_TRIPLE)

      (struct x264_hrd_t
	      ((double) cpb_initial_arrival_time)
	      ((double) cpb_final_arrival_time)
	      ((double) cpb_removal_time)
	      ((double) dpb_output_time))

      (struct x264_sei_payload_t
	      ((int) payload_size)
	      ((int) payload_type)
	      ((uint8_t*) payload))
      
      (struct x264_sei_t
	      ((int) num_payloads)
	      ((x264_sei_payload_t) *payloads))
      
      (struct x264_image_t
	      ((int) i_csp)       
	      ((int) i_plane)     
	      ((int) i_stride[4]) 
	      ((uint8_t*) plane[4])   )

      (struct x264_image_properties_t
	      ((float) *quant_offsets))
      
      (struct x264_picture_t
	      ((int) i_type)
	      ((int) i_qpplus1)
	      ((int) i_pic_struct)
	      ((int) b_keyframe)
	      ((int64_t) i_pts)
	      ((int64_t) i_dts)
	      ((x264_ param_t*) param)
	      ((x264_image_t) img)
	      ((x264_image_properties_t) prop)
	      ((x264_hrd_t) hrd_timing)
	      ((x264_sei_t) extra_sei)
	      ((void*) opaque))))