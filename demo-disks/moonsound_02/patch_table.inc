;-------------------------------------------------------------------
; описание:  Patch table
;---------------------------------------------------------------------
patch_table:
		dw	patch_0
		dw	patch_1
		dw	patch_2A, patch_2B
		dw	patch_0
		dw	patch_3B
		dw	patch_4
		dw	patch_5A, patch_5B
		dw	patch_6
		dw	patch_7
		dw	patch_8
		dw	patch_9
		dw	patch_10A, patch_10B
		dw	patch_11
		dw	patch_12
		dw	patch_13
		dw	patch_14
		dw	patch_15A, patch_15B
		dw	patch_16
		dw	patch_17
		dw	patch_18
		dw	patch_19
		dw	patch_20
		dw	patch_21A, patch_21B
		dw	patch_22
		dw	patch_23A, patch_23B
		dw	patch_24
		dw	patch_25
		dw	patch_26
		dw	patch_27
		dw	patch_28
		dw	patch_29
		dw	patch_30
		dw	patch_31
		dw	patch_32
		dw	patch_33
		dw	patch_34
		dw	patch_35
		dw	patch_36
		dw	patch_37
		dw	patch_38
		dw	patch_39
		dw	patch_40
		dw	patch_41
		dw	patch_42
		dw	patch_43
		dw	patch_44
		dw	patch_45
		dw	patch_46
		dw	patch_47
		dw	patch_48
		dw	patch_49
		dw	patch_50A, patch_50B
		dw	patch_51A, patch_51B
		dw	patch_52
		dw	patch_53
		dw	patch_54
		dw	patch_55
		dw	patch_56
		dw	patch_57
		dw	patch_58
		dw	patch_59
		dw	patch_60
		dw	patch_61
		dw	patch_62A, patch_62B
		dw	patch_63A, patch_63B
		dw	patch_64
		dw	patch_65
		dw	patch_66
		dw	patch_67
		dw	patch_68
		dw	patch_69
		dw	patch_70
		dw	patch_71
		dw	patch_72
		dw	patch_73
		dw	patch_74
		dw	patch_75
		dw	patch_76A,patch_76B
		dw	patch_77A,patch_77B
		dw	patch_78
		dw	patch_80A, patch_80B
		dw	patch_81A, patch_81B
		dw	patch_82A, patch_82B
		dw	patch_83A, patch_83B
		dw	patch_84A, patch_84B
		dw	patch_85A, patch_85B
		dw	patch_86A, patch_86B
		dw	patch_87A, patch_84B
		dw	patch_88A, patch_88B
		dw	patch_89A, patch_89B
		dw	patch_90A, patch_90B
		dw	patch_91A, patch_91B
		dw	patch_92A, patch_92B
		dw	patch_93A, patch_93B
		dw	patch_94A, patch_94B
		dw	patch_95A, patch_95B
		dw	patch_79
		dw	patch_96
		dw	patch_97A, patch_97B
		dw	patch_98A, patch_98B
		dw	patch_99A, patch_99B
		dw	patch_100A, patch_100B
		dw	patch_102A, patch_102B
		dw	patch_103A, patch_103B
		dw	patch_104
		dw	patch_105
		dw	patch_106
		dw	patch_107
		dw	patch_109A,patch_109B
		dw	patch_108
		dw	patch_110
		dw	patch_111
		dw	patch_112A,patch_112B
		dw	patch_113
		dw	patch_114A,patch_114B
		dw	patch_115
		dw	patch_116
		dw	patch_117
		dw	patch_118
		dw	patch_119
		dw	patch_120
		dw	patch_121
		dw	patch_122A,patch_122B
		dw	patch_124
		dw	patch_125A,patch_125B
		dw	patch_126A,patch_126B
		dw	patch_127
		dw	drum_1
		dw	drum_2
		dw	drum_3
		dw	drum_4
		dw	drum_5
		dw	drum_6
		dw	drum_7
		dw	drum_8
		dw	drum_midi
       	

;--- GM 0 = Ac. Piano ---

patch_0:	
		db	1	; transpose on
		dw	patch_0hdr
		db	16,02ch,1 + 36 * 2	; tone 300
		dw	frq_842
		db	22,02dh,1 + 52 * 2	; tone 301
		dw	frq_363
		db	28,02eh,1 + 46 * 2	; tone 302
		dw	frq_810
		db	34,02fh,1 + 52 * 2	; tone 303
		dw	frq_369
		db	40,030h,1 + 46 * 2	; tone 304
		dw	frq_726
		db	46,031h,1 + 52 * 2	; tone 305
		dw	frq_290
		db	52,032h,1 + 58 * 2	; tone 306
		dw	frq_21
		db	59,033h,1 + 52 * 2	; tone 307
		dw	frq_286
		db	65,034h,1 + 47 * 2	; tone 308
		dw	frq_941
		db	255,035h,1 + 65 * 2	; tone 309
		dw	frq_191
       	
patch_0hdr:
		db	020h,0ffh


;--- GM 1 = Bright Acoustic Piano ---

patch_1:
		db	1	; transpose on
		dw	patch_0hdr	
		db	22,02ch,1 + 36 * 2	; tone 300
		dw	frq_842
		db	28,02dh,1 + 58 * 2	; tone 301
		dw	frq_363
		db	34,02eh,1 + 52 * 2	; tone 302
		dw	frq_809
		db	40,02fh,1 + 58 * 2	; tone 303
		dw	frq_369
		db	46,030h,1 + 52 * 2	; tone 304
		dw	frq_726
		db	52,031h,1 + 58 * 2	; tone 305
		dw	frq_290
		db	59,032h,1 + 64 * 2	; tone 306
		dw	frq_21
		db	65,033h,1 + 59 * 2	; tone 307
		dw	frq_286
		db	71,034h,1 + 53 * 2	; tone 308
		dw	frq_941
		db	255,035h,1 + 71 * 2	; tone 309
		dw	frq_191


;--- GM 2 = Elec. Grand Piano ---
; A = v104
; B = v98

patch_2A:
		db	1	; transpose on
		dw	patch_2Ahdr
		db	22,02ch,1 + 36 * 2	; tone 300
		dw	frq_844
		db	28,02dh,1 + 58 * 2	; tone 301
		dw	frq_364
		db	34,02eh,1 + 52 * 2	; tone 302
		dw	frq_811
		db	40,02fh,1 + 58 * 2	; tone 303
		dw	frq_370
		db	46,030h,1 + 52 * 2	; tone 304
		dw	frq_727
		db	52,031h,1 + 58 * 2	; tone 305
		dw	frq_291
		db	59,032h,1 + 64 * 2	; tone 306
		dw	frq_22
		db	65,033h,1 + 59 * 2	; tone 307
		dw	frq_287
		db	71,034h,1 + 53 * 2	; tone 308
		dw	frq_942
		db	255,035h,1 + 71 * 2	; tone 309
		dw	frq_192
       	
patch_2Ahdr:
		db	020h,0c8h,007h,0ffh

patch_2B:	
		db	1	; transpose on
		dw	patch_2Bhdr
		db	255,108,36 * 2
		dw	frq_113
       	
patch_2Bhdr:	
		db	028h,0ffh


;--- GM 3 = Honky Tonk, met patch#0 ---
; gelijk volume

patch_3B:	
		db	1	; transpose on
		dw	patch_0hdr	
		db	16,02ch,1 + 36 * 2	; tone 300
		dw	frq_852
		db	22,02dh,1 + 52 * 2	; tone 301
		dw	frq_355
		db	28,02eh,1 + 46 * 2	; tone 302
		dw	frq_820
		db	34,02fh,1 + 52 * 2	; tone 303
		dw	frq_360
		db	40,030h,1 + 46 * 2	; tone 304
		dw	frq_737
		db	46,031h,1 + 52 * 2	; tone 305
		dw	frq_282
		db	52,032h,1 + 58 * 2	; tone 306
		dw	frq_27
		db	59,033h,1 + 52 * 2	; tone 307
		dw	frq_282
		db	65,034h,1 + 47 * 2	; tone 308
		dw	frq_952
		db	255,035h,1 + 65 * 2	; tone 309
		dw	frq_184
       	
;--- GM 4 = Elec. Piano 1 (+ 2B?) ---
; Eigenlijk samen met tone 11, maar slaat nergens op

patch_4:
		db	1	; transpose on
		dw	patch_4hdr
		db	255,108,36 * 2
		dw	frq_113
       	
patch_4hdr:
		db	022h,0c8h,048h,0ffh
       	

;--- GM 5 = Elec. Piano 2 ---
; volumes gelijk

patch_5A:	
		db	1	; transpose on
		dw	patch_5Ahdr
		db	16,02ch,1 + 36 * 2	; tone 300
		dw	frq_844
		db	22,02dh,1 + 52 * 2	; tone 301
		dw	frq_364
		db	28,02eh,1 + 46 * 2	; tone 302
		dw	frq_811
		db	34,02fh,1 + 52 * 2	; tone 303
		dw	frq_370
		db	40,030h,1 + 46 * 2	; tone 304
		dw	frq_727
		db	46,031h,1 + 52 * 2	; tone 305
		dw	frq_291
		db	52,032h,1 + 58 * 2	; tone 306
		dw	frq_22
		db	59,033h,1 + 52 * 2	; tone 307
		dw	frq_287
		db	65,034h,1 + 47 * 2	; tone 308
		dw	frq_942
		db	255,035h,1 + 65 * 2	; tone 309
		dw	frq_192

patch_5Ahdr:	
		db	01bh,0ffh

patch_5B:	
		db	1	; transpose on
		dw	patch_5Ahdr
		db	22,02ch,1 + 36 * 2	; tone 300
		dw	frq_842
		db	28,02dh,1 + 58 * 2	; tone 301
		dw	frq_363
		db	34,02eh,1 + 52 * 2	; tone 302
		dw	frq_809
		db	40,02fh,1 + 58 * 2	; tone 303
		dw	frq_369
		db	46,030h,1 + 52 * 2	; tone 304
		dw	frq_726
		db	52,031h,1 + 58 * 2	; tone 305
		dw	frq_290
		db	59,032h,1 + 64 * 2	; tone 306
		dw	frq_21
		db	65,033h,1 + 59 * 2	; tone 307
		dw	frq_286
		db	71,034h,1 + 53 * 2	; tone 308
		dw	frq_941
		db	255,035h,1 + 71 * 2	; tone 309
		dw	frq_191


;--- GM 6 = Harpsichord ---

patch_6:	
		db	1	; transpose on
		dw	patch_0hdr
		db	34,128,24 * 2
		dw	frq_288
		db	40,129,46 * 2
		dw	frq_847
		db	46,130,52 * 2
		dw	frq_288
		db	54,131,46 * 2
		dw	frq_823
		db	255,132,42 * 2
		dw	frq_823


;--- GM 7 = Clavi ---

patch_7:	
		db	1	; transpose on
		dw	patch_7hdr
		db	58,39,24 * 2
		dw	frq_203
		db	255,40,70 * 2	; was andere header!
		dw	frq_215
patch_7hdr:	
		db	028h,0c8h,02bh,0ffh


;--- GM 8 = Celesta ---

patch_8:	
		db	1	; transpose on
		dw	patch_8hdr
		db	255,43,12 * 2
		dw	frq_94
patch_8hdr:	
		db	020h,0e0h,3,0ffh


;--- GM 9 = Glockenspiel ---

patch_9:	
		db	1	; transpose on
		dw	patch_2Bhdr
		db	255,243,0 * 2
		dw	frq_141

;--- GM 10 = Music Box ---

patch_10A:	
		db	1	; transpose on
		dw	patch_10Ahdr
		db	255,243,12 * 2
		dw	frq_143
patch_10Ahdr:	
		db	020h,098h,0a6h,0ffh

patch_10B:	
		db	1	; transpose on
		dw	patch_10Bhdr
		db	255,1,1 + 24 * 2	; tone 257
		dw	frq_79
patch_10Bhdr:	
		db	020h,098h,0d4h,0ffh


;--- GM 11 = Vibraphone ---

patch_11:	
		db	1	; transpose on
		dw	patch_2Bhdr
		db	255,1,1 + 24 * 2	; tone 257
		dw	frq_82

;--- GM 12 = Marimba ---

patch_12:	
		db	1	; transpose on
		dw	patch_12hdr
		db	40,244, 24 * 2
		dw	frq_82
		db	255,245, 52 * 2	; was andere header!
		dw	frq_69
patch_12hdr:	
		db	038h,0ffh

;--- GM 13 = Xylophone ---

patch_13:	
		db	1	; transpose on
		dw	patch_12hdr
		db	255,36h, 1 + 0 * 2	; tone 310
		dw	frq_94


;--- GM 14 = Tubular Bells ---

patch_14:	
		db	1	; transpose on
		dw	patch_14hdr
		db	255,255, 12 * 2
		dw	frq_532
patch_14hdr:	
		db	021h,0e0h,1,0ffh

;--- GM 15 = Dulcimer ---

patch_15A:	
		db	1	; transpose on
		dw	patch_15Ahdr
		db	255,63, 12 * 2
		dw	frq_708
patch_15Ahdr:	
		db	029h,0ffh

patch_15B:	
		db	1
		dw	patch_15Bhdr
		db	255,64, 12 * 2
		dw	frq_708
patch_15Bhdr:	
		db	02ah,0ffh

;--- GM 16 = Drawbar organ ---

patch_16:	
		db	1	; transpose on
		dw	patch_16hdr
		db	255,142,12 * 2
		dw	frq_835
patch_16hdr:	
		db	03ah,0ffh

;--- GM 17 = Percussive organ ---

patch_17:	
		db	1	; transpose on
		dw	patch_17hdr
		db	36,140, 24 * 2
		dw	frq_950
		db	255,141, 36 * 2
		dw	frq_944
patch_17hdr:	
		db	03bh,0ffh

;--- GM 18 = Rock Organ ---

patch_18:	
		db	1	; transpose on
		dw	patch_18hdr
		db	25,28h, 1 + 36 * 2	; tone 296
		dw	frq_219
		db	37,29h, 1 + 49 * 2	; tone 297
		dw	frq_220
		db	49,2ah, 1 + 49 * 2	; tone 298
		dw	frq_217
		db	61,2bh, 1 + 49 * 2	; tone 299
		dw	frq_214
		db	255,27h, 1 + 49 * 2	; tone 295
		dw	frq_215
patch_18hdr:	
		db	039h,0ffh

;--- GM 19 = Church organ ---

patch_19:	
		db	1	; transpose on
		dw	patch_19hdr
		db	18,135, 36 * 2
		dw	frq_835
		db	25,136, 54 * 2
		dw	frq_155
		db	33,137, 49 * 2
		dw	frq_459
		db	42,138, 45 * 2
		dw	frq_847
		db	255,139, 54 * 2
		dw	frq_167
patch_19hdr:	
		db	011h,0ffh


;--- GM 20 = Reed Organ ---

patch_20:	
		db	1	; transpose on
		dw	patch_20hdr
		db	60,172, 24 * 2
		dw	frq_557
		db	255,173, 60 * 2
		dw	frq_556
patch_20hdr:	
		db	038h,0e0h,1,0ffh

;--- GM 21 = Accordion ---

patch_21A:	
		db	1	; transpose on
		dw	patch_21Ahdr
		db	53,6, 12 * 2
		dw	frq_727
		db	255,7, 41 * 2
		dw	frq_1018
patch_21Ahdr:	
		db	022h,0e0h,0,0ffh

patch_21B:	
		db	1	; transpose on
		dw	patch_21Bhdr
		db	255,112, 12 * 2
		dw	frq_833
patch_21Bhdr:	
		db	023h,0ffh

;--- GM 22 = Harmonica ---

patch_22:	
		db	1	; transpose on
		dw	patch_22hdr
		db	255,112, 12 * 2
		dw	frq_847
patch_22hdr:	
		db	030h,0e0h,2,0ffh

;--- GM 23 = Tango Accordion ---

patch_23A:	
		db	1	; transpose on
		dw	patch_23Ahdr
		db	60,172, 24 * 2
		dw	frq_559
		db	255,173, 60 * 2
		dw	frq_558
patch_23Ahdr:	
		db	038h,0ffh

patch_23B:	
		db	1
		dw	patch_23Bhdr
		db	255,65, 48 * 2
		dw	frq_445
patch_23Bhdr:	
		db	03ah,098h,075h,0B0h,000h,0ffh

;--- GM 24 = Nylon Ac. Gtr ---

patch_24:	
		db	1	; transpose on
		dw	patch_24hdr
		db	24,179, 36 * 2
		dw	frq_459
		db	31,183, 48 * 2
		dw	frq_555
		db	37,181, 55 * 2
		dw	frq_21
		db	44,180, 49 * 2
		dw	frq_459
		db	255,182, 44 * 2
		dw	frq_726
patch_24hdr:	
		db	028h,0c8h,9,0ffh


;--- GM 26 = Steel Ac. Gtr ---

patch_25:	
		db	1	; transpose on
		dw	patch_25hdr
		db	26,12,36 * 2	;was andere header
		dw	frq_442
		db	33,13,50 * 2	; "
		dw	frq_448
		db	48,14,45 * 2	; "
		dw	frq_823
		db	255,15,48 * 2	; "
		dw	frq_823
patch_25hdr:	
		db	028h,098h,0f6h,0b0h,034h,0c8h,9h,0ffh


;--- GM 26 = Elec Jazz Gtr ---

patch_26:	
		db	1	; transpose on
		dw	patch_2Bhdr
		db	26,90, 36 * 2
		dw	frq_373
		db	40,91, 50 * 2
		dw	frq_143
		db	255,92, 52 * 2
		dw	frq_70


;--- GM 27 = Elec Clean Gtr ---

patch_27:	
		db	1	; transpose on
		dw	patch_27hdr
		db	21,97, 36 * 2
		dw	frq_519
		db	26,96, 57 * 2
		dw	frq_143
		db	33,99, 50 * 2
		dw	frq_701
		db	40,98, 57 * 2
		dw	frq_9
		db	45,101, 52 * 2
		dw	frq_508
		db	52,100, 57 * 2
		dw	frq_118
		db	61,102, 52 * 2
		dw	frq_531
		db	255,103, 49 * 2
		dw	frq_823
patch_27hdr:	
		db	029h,0ffh


;--- GM 28 = Muted Gtr ---

patch_28:	
		db	1	; transpose on
		dw	patch_2Bhdr
		db	255,104, 12 * 2
		dw	frq_847


;--- GM 29 = Overdriven Gtr ---

patch_29:	
		db	1	; transpose on
		dw	patch_27hdr
		db	41,165, 36 * 2
		dw	frq_228
		db	255,166, 65 * 2
		dw	frq_459

;--- GM 30 = Distortion Gtr ---

patch_30:	
		db	1	; transpose on
		dw	patch_30hdr
		db	19,81, 36 * 2
		dw	frq_434
		db	23,82, 55 * 2
		dw	frq_143
		db	27,83, 47 * 2
		dw	frq_847
		db	31,84, 51 * 2
		dw	frq_434
		db	35,85, 55 * 2
		dw	frq_143
		db	39,86, 47 * 2
		dw	frq_847
		db	43,87, 51 * 2
		dw	frq_459
		db	47,88, 55 * 2
		dw	frq_143
		db	255,89, 47 * 2
		dw	frq_775
patch_30hdr:	
		db	021h,0ffh

;--- GM 31 = Gtr Harmonics ---

patch_31:	
		db	1	; transpose on
		dw	patch_2Bhdr
		db	45,94, 24 * 2
		dw	frq_507
		db	50,93, 69 * 2
		dw	frq_118
		db	255,95, 62 * 2
		dw	frq_726

;--- GM 32 = Acoustic Bass ---

patch_32:	
		db	1	; transpose on
		dw	patch_32hdr
		db	25,4, 48 * 2
		dw	frq_188
		db	255,5, 49 * 2
		dw	frq_70
patch_32hdr:	
		db	018h,0ffh


;--- GM 33 = Elec. Bass (finger) ---

patch_33:	
		db	1	; transpose on
		dw	patch_32hdr
		db	9,74,48 * 2
		dw	frq_645
		db	14,75,57 * 2
		dw	frq_221
		db	19,76,50 * 2
		dw	frq_843
		db	255,77,55 * 2
		dw	frq_378


;--- GM 34 = Elec. Bass (pick) ---

patch_34:	
		db	1	; transpose on
		dw	patch_32hdr
		db	12,79,48 * 2
		dw	frq_135
		db	19,80,48 * 2
		dw	frq_715
		db	24,107,55 * 2
		dw	frq_264
		db	48,105,48 * 2
		dw	frq_921
		db	255,106,72 * 2
		dw	frq_434

;--- GM 35 = Fretless Bass ---

patch_35:	
		db	1	; transpose on
		dw	patch_35hdr
		db	255,78,24 * 2
		dw	frq_373
patch_35hdr:	
		db	010h,098h,0f3h,0b0h,063h,0c8h,019h,0ffh

;--- GM 36 = Slap Bass 1 ---

patch_36:	
		db	1	; transpose on
		dw	patch_36hdr
		db	255,163,(36 + 3) * 2
		dw	frq_641
patch_36hdr:	
		db	019h,0ffh

;--- GM 37 = Slap bass 2 ---

patch_37:	
		db	1	; transpose on
		dw	patch_37hdr
		db	255,162,24 * 2
		dw	frq_288
patch_37hdr:	
		db	020h,098h,0b0h,0ffh

;--- GM 38 = Synth Bass 1 ---

patch_38:	
		db	1	; transpose on
		dw	patch_38hdr
		db	255,190,36 * 2
		dw	frq_835
patch_38hdr:	
		db	039h,0ffh

;--- GM 39 = Synth Bass 2 ---

patch_39:	
		db	1	; transpose on
		dw	patch_38hdr
		db	255,17h,1 + 48 * 2	; tone 279
		dw	frq_215

;--- GM 40 = Violin ---

patch_40:	
		db	1	; transpose on
		dw	patch_40hdr
		db	35,5h,1 + 24 * 2	; tone 261
		dw	frq_288
		db	40,2h,1 + 59 * 2	; tone 258
		dw	frq_69
		db	42,6h,1 + 52 * 2	; tone 262
		dw	frq_627
		db	45,7h,1 + 54 * 2	; tone 263
		dw	frq_556
		db	48,8h,1 + 57 * 2	; tone 264
		dw	frq_264
		db	51,0ah,1 + 48 * 2	; tone 266
		dw	frq_920
		db	53,0bh,1 + 51 * 2	; tone 267
		dw	frq_726
		db	55,0ch,1 + 53 * 2	; tone 268
		dw	frq_579
		db	58,0dh,1 + 55 * 2	; tone 269
		dw	frq_338
		db	255,09h,1 + 58	* 2	; tone 265
		dw	frq_143
patch_40hdr:	
		db	03bh,0ffh


;--- GM 41 = Viola ---

patch_41:	
		db	1	; transpose on
		dw	patch_41hdr
		db	27,03h,1 + 24 * 2	; tone 259
		dw	frq_715
		db	30,04h,1 + 51 * 2	; tone 260
		dw	frq_531
		db	33,05h,1 + 54 * 2	; tone 261
		dw	frq_288
		db	38,02h,1 + 57 * 2	; tone 258
		dw	frq_69
		db	40,06h,1 + 50 * 2	; tone 262
		dw	frq_627
		db	43,07h,1 + 52 * 2	; tone 263
		dw	frq_556
		db	46,08h,1 + 55 * 2	; tone 264
		dw	frq_264
		db	49,0ah,1 + 46 * 2	; tone 266
		dw	frq_920
		db	51,0bh,1 + 49 * 2	; tone 267
		dw	frq_726
		db	54,0ch,1 + 51 * 2	; tone 268
		dw	frq_579
		db	56,0dh,1 + 54 * 2	; tone 269
		dw	frq_338
		db	255,09h,1 + 56 * 2	; tone 265
		dw	frq_143
patch_41hdr:	
		db	03bh,098h,0a3h,0ffh


;--- GM 42 = Cello ---

patch_42:	
		db	1	; transpose on
		dw	patch_42hdr
		db	22,12h,1 + 36 * 2	; tone 274
		dw	frq_203
		db	32,13h,1 + 46 * 2	; tone 275
		dw	frq_701
		db	39,15h,1 + 44 * 2	; tone 277
		dw	frq_822
		db	45,16h,1 + 51 * 2	; tone 278
		dw	frq_531
		db	255,14h,1 + 57 * 2	; tone 276
		dw	frq_69
patch_42hdr:	
		db	033h,0c8h,8,0ffh

;--- GM 43 = Contrabass ---

patch_43:	
		db	1	; transpose on
		dw	patch_43hdr
		db	18,10h,1 + 48 * 2	; tone 272
		dw	frq_15
		db	255,11h,1 + 54 * 2	; tone 273
		dw	frq_8
patch_43hdr:	
		db	010h,098h,090h,0ffh

;--- GM 44 = Tremolo Strings ---

patch_44:	
		db	1	; transpose on
		dw	patch_44hdr
		db	36,176,24 * 2
		dw	frq_98
		db	42,53,48 * 2
		dw	frq_557
		db	48,51,54 * 2
		dw	frq_26
		db	59,52,48 * 2
		dw	frq_650
		db	255,175,47 * 2
		dw	frq_538
patch_44hdr:	
		db	038h,0e0h,6,0ffh


;--- GM 45 = Pizzicato Strings ---

patch_45:	
		db	1	; transpose on
		dw	patch_2Bhdr
		db	27,184,36 * 2
		dw	frq_20
		db	36,185,51 * 2
		dw	frq_216
		db	43,187,48 * 2
		dw	frq_639
		db	49,186,55 * 2
		dw	frq_84
		db	255,188,49 * 2
		dw	frq_455

;--- GM 46 = Harp ---

patch_46:	
		db	1	; transpose on
		dw	patch_46hdr
		db	47,126,12 * 2
		dw	frq_360
		db	255,127,47 * 2
		dw	frq_434
patch_46hdr:	
		db	029h,0c8h,7,0ffh


;--- GM 47 = Timpani ---

patch_47:	
		db	1	; transpose on
		dw	patch_2Bhdr
		db	255,0,1 + 36 * 2	; tone 256
		dw	frq_217


;--- GM 48 = Strings ---

patch_48:	
		db	1	; transpose on
		dw	patch_0hdr
		db	36,03ch,1 + 24 * 2	; tone 316
		dw	frq_96
		db	42,03eh,1 + 48 * 2	; tone 318
		dw	frq_557
		db	48,03dh,1 + 54 * 2	; tone 317
		dw	frq_24
		db	59,03fh,1 + 48 * 2	; tone 319
		dw	frq_653
		db	255,040h,1 + 47 * 2	; tone 320
		dw	frq_548

;--- GM 49 = Slow Strings ---

patch_49:	
		db	1	; transpose on
		dw	patch_49hdr
		db	36,176, 24 * 2
		dw	frq_98
		db	42,53, 48 * 2
		dw	frq_557
		db	48,51, 54 * 2
		dw	frq_27
		db	59,52, 48 * 2
		dw	frq_650
		db	255,175, 47 * 2
		dw	frq_538
patch_49hdr:	
		db	019h,0ffh


;--- GM 50 = Synth Strings 1 ---

patch_50A:	
		db	1	; transpose on
		dw	patch_50Ahdr
		db	255,2, 24 * 2
		dw	frq_935
patch_50Ahdr:	
		db	020h,098h,093h,0b0h,022h,0c8h,06h,0ffh

patch_50B:	
		db	1	; transpose on
		dw	patch_50Bhdr
		db	255,174, 12 * 2
		dw	frq_91
patch_50Bhdr:	
		db	020h,098h,070h,0c8h,006h,0ffh


;--- GM 51 = Synth Strings 2 ---

patch_51A:	
		db	1	; transpose on
		dw	patch_51Ahdr
		db	255,2, 12 * 2
		dw	frq_935
patch_51Ahdr:	
		db	019h,098h,070h,0b0h,000h,0c8h,06h,0ffh

patch_51B:	
		db	1	; transpose on
		dw	patch_51Ahdr
		db	255,2, 12 * 2
		dw	frq_927


;--- GM 52 = Choir Aahs ---

patch_52:	
		db	1	; transpose on
		dw	patch_52hdr
		db	35,24, 24 * 2
		dw	frq_204
		db	41,25, 47 * 2
		dw	frq_815
		db	48,26, 53 * 2
		dw	frq_206
		db	255,27, 48 * 2
		dw	frq_356
patch_52hdr:	
		db	01ah,0ffh

;--- GM 53 = Voice Oohs ---

patch_53:	
		db	1	; transpose on
		dw	patch_53hdr
		db	255,41, 12 * 2
		dw	frq_273
patch_53hdr:	
		db	020h,098h,0f7h,0b0h,020h,0c8h,8,0ffh

;--- GM 54 = Synth Voice ---

patch_54:	
		db	1	; transpose on
		dw	patch_54hdr
		db	255,42, 12 * 2
		dw	frq_208
patch_54hdr:	
		db	019h,098h,085h,0b0h,021h,0c8h,7,0ffh

;--- GM 55 = Orchestra Hit ---

patch_55:	
		db	1	; transpose on
		dw	patch_55hdr
		db	255,73, 12 * 2
		dw	frq_835
patch_55hdr:	
		db	030h,0ffh

;--- GM 56 = Trumpet ---

patch_56:	
		db	1	; transpose on
		dw	patch_56hdr
		db	37,246, 24 * 2
		dw	frq_46
		db	44,248, 49 * 2
		dw	frq_460
		db	49,247, 56 * 2
		dw	frq_22
		db	55,250, 49 * 2
		dw	frq_436
		db	62,249, 55 * 2
		dw	frq_46
		db	255,251, 50 * 2
		dw	frq_436
patch_56hdr:	
		db	032h,0ffh

;--- GM 57 = Trombone ---

patch_57:	
		db	1	; transpose on
		dw	patch_57hdr
		db	35,240, 24 * 2
		dw	frq_228
		db	40,241, 47 * 2
		dw	frq_750
		db	255,242, 52 * 2
		dw	frq_264
patch_57hdr:	
		db	021h,0ffh

;--- GM 58 = Tuba ---

patch_58:	
		db	1	; transpose on
		dw	patch_57hdr
		db	22,133, 36 * 2
		dw	frq_550
		db	255,134, 46 * 2
		dw	frq_908

;--- GM 59 = Muted Trumpet ---

patch_59:	
		db	1	; transpose on
		dw	patch_59hdr
		db	46,177, 12 * 2
		dw	frq_630
		db	255,178, 46 * 2
		dw	frq_630
patch_59hdr:	
		db	28h,0e0h,1,0ffh

;--- GM 60 = French Horn ---

patch_60:	
		db	1	; transpose on
		dw	patch_60hdr
		db	50,124, 12 * 2
		dw	frq_290
		db	255,125, 50 * 2
		dw	frq_679
patch_60hdr:	
		db	01ah,0ffh

;--- GM 61 = Brass Section ---

patch_61:	
		db	1	; transpose on
		dw	patch_2Bhdr
		db	43,252, 12 * 2
		dw	frq_820
		db	255,253, 43 * 2
		dw	frq_832

;--- GM 62 = Synth Brass 1 ---

patch_62A:	
		db	1	; transpose on
		dw	patch_62Ahdr
		db	16,211, 48 * 2
		dw	frq_916
		db	22,218, 64 * 2
		dw	frq_354
		db	28,212, 58 * 2
		dw	frq_916
		db	34,219, 64 * 2
		dw	frq_345
		db	40,213, 58 * 2
		dw	frq_935
		db	46,220, 64 * 2
		dw	frq_350
		db	52,214, 58 * 2
		dw	frq_925
		db	58,221, 64 * 2
		dw	frq_363
		db	64,215, 58 * 2
		dw	frq_969
		db	70,222, 64 * 2
		dw	frq_338
		db	77,216, 58 * 2
		dw	frq_925
		db	255,217, 53 * 2
		dw	frq_925
patch_62Ahdr:	
		db	018h,0ffh


patch_62B:	
		db	1	; transpose on
		dw	patch_62Bhdr
		db	16,18h, 1 + 48 * 2	; tone 280
		dw	frq_929
		db	22,19h, 1 + 64 * 2	; tone 281
		dw	frq_360
		db	28,1ah, 1 + 58 * 2	; tone 282
		dw	frq_927
		db	34,1bh, 1 + 64 * 2	; tone 283
		dw	frq_360
		db	40,1ch, 1 + 58 * 2	; tone 284
		dw	frq_939
		db	46,1dh, 1 + 64 * 2	; tone 285
		dw	frq_366
		db	52,1eh, 1 + 58 * 2	; tone 286
		dw	frq_951
		db	58,1fh, 1 + 64 * 2	; tone 287
		dw	frq_366
		db	64,20h, 1 + 58 * 2	; tone 288
		dw	frq_977
		db	70,21h, 1 + 64 * 2	; tone 289
		dw	frq_342
		db	77,22h, 1 + 58 * 2	; tone 290
		dw	frq_927
		db	255,23h, 1 + 53 * 2	; tone 291
		dw	frq_927
patch_62Bhdr:	
		db	018h,098h,0a5h,0b0h,011h,0ffh


;--- GM 63 = Synth Brass 2 ---
; B zachter dan A, vals??

patch_63A:	
		db	1	; transpose on
		dw	patch_63Ahdr
		db	16,18h, 1 + 48 * 2	; tone 280
		dw	frq_931
		db	22,19h, 1 + 64 * 2	; tone 281
		dw	frq_361
		db	28,1ah, 1 + 58 * 2	; tone 282
		dw	frq_929
		db	34,1bh, 1 + 64 * 2	; tone 283
		dw	frq_361
		db	40,1ch, 1 + 58 * 2	; tone 284
		dw	frq_941
		db	46,1dh, 1 + 64 * 2	; tone 285
		dw	frq_367
		db	52,1eh, 1 + 58 * 2	; tone 286
		dw	frq_953
		db	58,1fh, 1 + 64 * 2	; tone 287
		dw	frq_367
		db	64,20h, 1 + 58 * 2	; tone 288
		dw	frq_978
		db	70,21h, 1 + 64 * 2	; tone 289
		dw	frq_343
		db	77,22h, 1 + 58 * 2	; tone 290
		dw	frq_929
		db	255,23h, 1 + 53 * 2	; tone 291
		dw	frq_929
patch_63Ahdr:	
		db	026h,0ffh


patch_63B:	
		db	1	; transpose on
		dw	patch_63Bhdr
		db	255,24h, 1 + 12 * 2	; tone 292
		dw	frq_557
patch_63Bhdr:	
		db	022h,0ffh

;--- GM 64 = Soprano Sax ---

patch_64:	
		db	1	; transpose on
		dw	patch_30hdr
		db	40,227, 12 * 2
		dw	frq_701
		db	46,228, 52 * 2
		dw	frq_216
		db	52,229, 46 * 2
		dw	frq_677
		db	58,230, 52 * 2
		dw	frq_242
		db	65,231, 46 * 2
		dw	frq_726
		db	255,232, 65 * 2
		dw	frq_94

;--- GM 65 = Alto Sax ---

patch_65:	
		db	1	; transpose on
		dw	patch_65hdr
		db	27,146, 36 * 2
		dw	frq_27
		db	30,150, 51 * 2
		dw	frq_737
		db	35,153, 54 * 2
		dw	frq_385
		db	36,143, 59 * 2
		dw	frq_242
		db	39,147, 60 * 2
		dw	frq_46
		db	42,151, 51 * 2
		dw	frq_775
		db	45,154, 54 * 2
		dw	frq_460
		db	48,144, 57 * 2
		dw	frq_216
		db	51,148, 60 * 2
		dw	frq_22
		db	53,152, 51 * 2
		dw	frq_727
		db	57,155, 53 * 2
		dw	frq_480
		db	60,145, 57 * 2
		dw	frq_290
		db	255,149, 60 * 2
		dw	frq_94
patch_65hdr:	
		db	019h,0c8h,000bh,0ffh

;--- GM 66 = Tenor Sax ---

patch_66:	
		db	1	; transpose on
		dw	patch_36hdr
		db	25,233, 36 * 2
		dw	frq_75
		db	29,234, 49 * 2
		dw	frq_715
		db	35,235, 53 * 2
		dw	frq_228
		db	42,237, 47 * 2
		dw	frq_653
		db	48,236, 54 * 2
		dw	frq_70
		db	58,238, 48 * 2
		dw	frq_531
		db	255,239, 46 * 2
		dw	frq_920


;--- GM 67 = Baritone Sax ---

patch_67:	
		db	1	; transpose on
		dw	patch_36hdr
		db	22,223, 36 * 2
		dw	frq_299
		db	29,225, 46 * 2
		dw	frq_545
		db	34,226, 53 * 2
		dw	frq_299
		db	255,224, 46 * 2
		dw	frq_874

;--- GM 68 = Oboe ---

patch_68:	
		db	1	; transpose on
		dw	patch_68hdr
		db	37,66, 12 * 2
		dw	frq_920
		db	44,68, 49 * 2
		dw	frq_338
		db	50,67, 44 * 2
		dw	frq_920
		db	56,70, 50 * 2
		dw	frq_335
		db	62,69, 44 * 2
		dw	frq_920
		db	255,71, 50 * 2
		dw	frq_335
patch_68hdr:	
		db	039h,0ffh

;--- GM 69 = English Horn ---

patch_69:	
		db	1	; transpose on
		dw	patch_69hdr
		db	33,60, 24 * 2
		dw	frq_254
		db	39,59, 45 * 2
		dw	frq_750
		db	255,61, 51 * 2
		dw	frq_242
patch_69hdr:	
		db	031h,0ffh

;--- GM 70 = Bassoon ---

patch_70:	
		db	1	; transpose on
		dw	patch_69hdr
		db	11,56, 48 * 2
		dw	frq_73
		db	23,58, 47 * 2
		dw	frq_532
		db	255,57, 59 * 2
		dw	frq_75

;--- GM 71 = Clarinet ---

patch_71:	
		db	1	; transpose on
		dw	patch_71hdr
		db	36,158, 24 * 2
		dw	frq_810
		db	42,160, 60 * 2
		dw	frq_288
		db	51,159, 54 * 2
		dw	frq_726
		db	255,161, 51 * 2
		dw	frq_920
patch_71hdr:	
		db	029h,0ffh

;--- GM 72 = Piccolo ---

patch_72:	
		db	1	; transpose on
		dw	patch_72hdr
		db	41,113, 24 * 2
		dw	frq_94
		db	54,114, 53 * 2
		dw	frq_118
		db	60,115, 54 * 2
		dw	frq_94
		db	72,116, 60 * 2
		dw	frq_288
		db	255,117, 60 * 2
		dw	frq_920
patch_72hdr:	
		db	038h,0e0h,2,0ffh

;--- GM 73 = Flute ---

patch_73:	
		db	1	; transpose on
		dw	patch_72hdr
		db	41,113, 24 * 2
		dw	frq_94
		db	54,114, 53 * 2
		dw	frq_118
		db	255,115, 54 * 2
		dw	frq_94

;--- GM 74 = Recorder ---

patch_74:	
		db	1	; transpose on
		dw	patch_74hdr
		db	255,189, 24 * 2
		dw	frq_143
patch_74hdr:	
		db	030h,0e0h,1,0ffh

;--- GM 75 = Pan Flute ---

patch_75:	
		db	1	; transpose on
		dw	patch_75hdr
		db	255,119, 0 * 2
		dw	frq_461
patch_75hdr:	
		db	030h,0e0h,3,0ffh

;--- GM 76 = Blown Bottle ---

patch_76A:	
		db	1	; transpose on
		dw	patch_76Ahdr
		db	255,119, 0 * 2
		dw	frq_461
patch_76Ahdr:	
		db	038h,0e0h,1,0ffh

patch_76B:	
		db	1	; transpose on
		dw	patch_76Bhdr
		db	255,25h, 1 + (12 + 2) * 2	; tone 293
		dw	frq_21
patch_76Bhdr:	
		db	0h,0ffh

;--- GM 77 = Shakuhachi ---

patch_77A:		
		db	1	; transpose on
		dw	patch_75hdr
		db	255,171, 12 * 2
		dw	frq_969

patch_77B:	
		db	1	; transpose on
		dw	patch_77Bhdr
		db	255,118, 12 * 2
		dw	frq_345
patch_77Bhdr:	
		db	028h,0e0h,2,0ffh

;--- GM 78 = Whistle ---

patch_78:	
		db	1	; transpose on
		dw	patch_78hdr
		db	255,170, 0 * 2
		dw	frq_94
patch_78hdr:	
		db	02ch,098h,070h,0ffh

;--- GM 79 = Ocarina ---

patch_79:	
		db	1	; transpose on
		dw	patch_79hdr
		db	255,170, 0 * 2
		dw	frq_94
patch_79hdr:	
		db	029h,0e0h,1,0ffh

;--- GM 80 = Lead 1 (square) ---

patch_80A:	
		db	1	; transpose on
		dw	patch_80Ahdr
		db	19,204, 60 * 2
		dw	frq_341
		db	31,205, 55 * 2
		dw	frq_343
		db	43,202, 55 * 2
		dw	frq_343
		db	55,207, 55 * 2
		dw	frq_343
		db	67,206, 55 * 2
		dw	frq_343
		db	255,203, 55 * 2
		dw	frq_343
patch_80Ahdr:	
		db	038h,098h,0c6h,0ffh


patch_80B:	
		db	1	; transpose on
		dw	patch_80Bhdr
		db	19,204, 60 * 2
		dw	frq_335
		db	31,205, 55 * 2
		dw	frq_338
		db	43,202, 55 * 2
		dw	frq_338
		db	55,207, 55 * 2
		dw	frq_338
		db	67,206, 55 * 2
		dw	frq_338
		db	255,203, 55 * 2
		dw	frq_338
patch_80Bhdr:	
		db	008h,098h,0c6h,0ffh


;--- GM 81 = Lead 2 (sawtooth) ---

patch_81A:	
		db	1	; transpose on
		dw	patch_81Ahdr
		db	16,18h, 1 + 48 * 2	; tone 280
		dw	frq_927
		db	22,19h, 1 + 64 * 2	; tone 281
		dw	frq_358
		db	28,1ah, 1 + 58 * 2	; tone 282
		dw	frq_925
		db	34,1bh, 1 + 64 * 2	; tone 283
		dw	frq_358
		db	40,1ch, 1 + 58 * 2	; tone 284
		dw	frq_936
		db	46,1dh, 1 + 64 * 2	; tone 285
		dw	frq_364
		db	52,1eh, 1 + 58 * 2	; tone 286
		dw	frq_949
		db	58,1fh, 1 + 64 * 2	; tone 287
		dw	frq_364
		db	64,20h, 1 + 58 * 2	; tone 288
		dw	frq_974
		db	70,21h, 1 + 64 * 2	; tone 289
		dw	frq_340
		db	79,22h, 1 + 58 * 2	; tone 290
		dw	frq_925
		db	255,23h, 1 + 55 * 2	; tone 291
		dw	frq_925
patch_81Ahdr:	
		db	030h,098h,0f2h,0b0h,022h,0c8h,00ah,0ffh

patch_81B:	
		db	1	; transpose on
		dw	patch_81Ahdr
		db	16,18h, 1 + 48 * 2	; tone 280
		dw	frq_918
		db	22,19h, 1 + 64 * 2	; tone 281
		dw	frq_352
		db	28,1ah, 1 + 58 * 2	; tone 282
		dw	frq_916
		db	34,1bh, 1 + 64 * 2	; tone 283
		dw	frq_352
		db	40,1ch, 1 + 58 * 2	; tone 284
		dw	frq_927
		db	46,1dh, 1 + 64 * 2	; tone 285
		dw	frq_358
		db	52,1eh, 1 + 58 * 2	; tone 286
		dw	frq_941
		db	58,1fh, 1 + 64 * 2	; tone 287
		dw	frq_358
		db	64,20h, 1 + 58 * 2	; tone 288
		dw	frq_966
		db	70,21h, 1 + 64 * 2	; tone 289
		dw	frq_333
		db	79,22h, 1 + 58 * 2	; tone 290
		dw	frq_916
		db	255,23h, 1 + 55 * 2	; tone 291
		dw	frq_916

;--- GM 82 = Lead 3 (calliope) ---

patch_82A:	
		db	1	; transpose on
		dw	patch_82Ahdr
		db	255,170, 0 * 2
		dw	frq_94
patch_82Ahdr:	
		db	028h,0e0h,2,0ffh

patch_82B:	
		db	1	; transpose on
		dw	patch_82Bhdr
		db	255,118, 12 * 2
		dw	frq_345
patch_82Bhdr:	
		db	028h,098h,0b0h,0e0h,2,0ffh

;--- GM 83 = Lead 4 (chiff) ---

patch_83A:	
		db	1	; transpose on
		dw	patch_83Ahdr
		db	255,3ah, 1 + 12 * 2	; tone 314
		dw	frq_314
patch_83Ahdr:	
		db	02ah,0e0h,1,0ffh

patch_83B:	
		db	1	; transpose on
		dw	patch_2Bhdr
		db	255,254, 12 * 2
		dw	frq_311


;--- GM 84 = Lead 5 (charang) ---

patch_84A:	
		db	1	; transpose on
		dw	patch_84Ahdr
		db	41,165, 36 * 2
		dw	frq_231
		db	255,166, 65 * 2
		dw	frq_462
patch_84Ahdr:	
		db	033h,0ffh

patch_84B:	
		db	1	; transpose on
		dw	patch_84Bhdr
		db	16,18h, 1 + 48 * 2	; tone 280
		dw	frq_918
		db	22,19h, 1 + 64 * 2	; tone 281
		dw	frq_352
		db	28,1ah, 1 + 58 * 2	; tone 282
		dw	frq_916
		db	34,1bh, 1 + 64 * 2	; tone 283
		dw	frq_352
		db	40,1ch, 1 + 58 * 2	; tone 284
		dw	frq_927
		db	46,1dh, 1 + 64 * 2	; tone 285
		dw	frq_358
		db	52,1eh, 1 + 58 * 2	; tone 286
		dw	frq_941
		db	58,1fh, 1 + 64 * 2	; tone 287
		dw	frq_358
		db	64,20h, 1 + 58 * 2	; tone 288
		dw	frq_966
		db	70,21h, 1 + 64 * 2	; tone 289
		dw	frq_333
		db	79,22h, 1 + 58 * 2	; tone 290
		dw	frq_916
		db	255,23h, 1 + 55 * 2	; tone 291
		dw	frq_916
patch_84Bhdr:	
		db	02ah,098h,0f2h,0b0h,022h,0c8h,00eh,0ffh


;--- GM 85 = Lead 6 (voice) ---

patch_85A:	
		db	1	; transpose on
		dw	patch_85Ahdr
		db	255,170, 0 * 2
		dw	frq_98
patch_85Ahdr:	
		db	02eh,0ffh

patch_85B:	
		db	1	; transpose on
		dw	patch_85Bhdr
		db	255,42, 12 * 2
		dw	frq_204
patch_85Bhdr:	
		db	029h,098h,0f0h,0c8h,00ah,0ffh


;--- GM 86 = Lead 7 (fifths) ---

patch_86A:	
		db	1	; transpose on
		dw	patch_86Ahdr
		db	16,18h, 1 + 48 * 2	; tone 280
		dw	frq_918
		db	22,19h, 1 + 64 * 2	; tone 281
		dw	frq_352
		db	28,1ah, 1 + 58 * 2	; tone 282
		dw	frq_916
		db	34,1bh, 1 + 64 * 2	; tone 283
		dw	frq_352
		db	40,1ch, 1 + 58 * 2	; tone 284
		dw	frq_927
		db	46,1dh, 1 + 64 * 2	; tone 285
		dw	frq_358
		db	52,1eh, 1 + 58 * 2	; tone 286
		dw	frq_941
		db	58,1fh, 1 + 64 * 2	; tone 287
		dw	frq_358
		db	64,20h, 1 + 58 * 2	; tone 288
		dw	frq_966
		db	70,21h, 1 + 64 * 2	; tone 289
		dw	frq_333
		db	79,22h, 1 + 58 * 2	; tone 290
		dw	frq_916
		db	255,23h, 1 + 55 * 2	; tone 291
		dw	frq_916
patch_86Ahdr:	
		db	032h,098h,0f5h,0ffh

patch_86B:	
		db	1	; transpose on
		dw	patch_86Bhdr
		db	255,2, 12 * 2
		dw	frq_929
patch_86Bhdr:	
		db	031h,098h,0b3h,0b0h,022h,0c8h,00bh,0ffh

;--- GM 87 = Lead 8 (bass + lead) ---

patch_87A:	
		db	1	; transpose on
		dw	patch_27hdr
		db	255,17h, 1 + 48 * 2	; tone 279
		dw	frq_219


;--- GM 88 = Pad 1 (new age) ---
; B zachter dan A
patch_88A:	
		db	1	; transpose on
		dw	patch_88Ahdr
		db	255,2, 12 * 2
		dw	frq_927
patch_88Ahdr:	
		db	024h,0ffh

patch_88B:	
		db	1	; transpose on
		dw	patch_88Bhdr
		db	255,243, 12 * 2
		dw	frq_721
patch_88Bhdr:	
		db	023h,098h,0a2h,0b0h,014h,0c8h,6,0e0h,1,0ffh

;--- GM 89 = Pad 2 (warm) ---
; B zachter dan A
patch_89A:	
		db	1	; transpose on
		dw	patch_89Ahdr
		db	255,78, 24 * 2
		dw	frq_379
patch_89Ahdr:	
		db	02ah,0e0h,2,0ffh

patch_89B:	
		db	1	; transpose on
		dw	patch_63Bhdr
		db	255,41, 12 * 2
		dw	frq_261


;--- GM 90 = Pad 3 (polysynth) ---

patch_90A:	
		db	1	; transpose on
		dw	patch_90Ahdr
		db	16,18h, 1 + 48 * 2	; tone 280
		dw	frq_929
		db	22,19h, 1 + 64 * 2	; tone 281
		dw	frq_360
		db	28,1ah, 1 + 58 * 2	; tone 282
		dw	frq_927
		db	34,1bh, 1 + 64 * 2	; tone 283
		dw	frq_360
		db	40,1ch, 1 + 58 * 2	; tone 284
		dw	frq_939
		db	46,1dh, 1 + 64 * 2	; tone 285
		dw	frq_366
		db	52,1eh, 1 + 58 * 2	; tone 286
		dw	frq_951
		db	58,1fh, 1 + 64 * 2	; tone 287
		dw	frq_366
		db	64,20h, 1 + 58 * 2	; tone 288
		dw	frq_977
		db	70,21h, 1 + 64 * 2	; tone 289
		dw	frq_341
		db	79,22h, 1 + 58 * 2	; tone 290
		dw	frq_927
		db	255,23h, 1 + 55 * 2	; tone 291
		dw	frq_927
patch_90Ahdr:	
		db	023h,098h,0f2h,0b0h,022h,0c8h,007h,0e0h,1,0ffh

patch_90B:	
		db	1	; transpose on
		dw	patch_90Bhdr
		db	255,24h, 1 + 12 * 2	; tone 292
		dw	frq_550
patch_90Bhdr:	
		db	022h,098h,0e5h,0ffh

;--- GM 91 = Pad 4 (choir) ---

patch_91A:	
		db	1	; transpose on
		dw	patch_91Ahdr
		db	35,24, 24 * 2
		dw	frq_204
		db	41,25, 47 * 2
		dw	frq_815
		db	48,26, 53 * 2
		dw	frq_206
		db	255,27, 48 * 2
		dw	frq_356
patch_91Ahdr:	
		db	025h,0c8h,006h,0ffh

patch_91B:	
		db	1	; transpose on
		dw	patch_91Bhdr
		db	255,42, 12 * 2
		dw	frq_208
patch_91Bhdr:	
		db	024h,098h,065h,0b0h,021h,0ffh

;--- GM 92 = Pad 5 (bowed) ---

patch_92A:	
		db	1	; transpose on
		dw	patch_92Ahdr
		db	255,2, 1 + 24 * 2	; tone 257
		dw	frq_88
patch_92Ahdr:	
		db	019h,098h,044h,0e0h,2,0ffh

patch_92B:	
		db	1	; transpose on
		dw	patch_92Bhdr
		db	255,170, 0 * 2
		dw	frq_89
patch_92Bhdr:	
		db	019h,098h,040h,0c8h,6,0ffh

;--- GM 93 = Pad 6 (metallic) ---

patch_93A:	
		db	1	; transpose on
		dw	patch_93Ahdr
		db	26,12, 36 * 2
		dw	frq_445
		db	33,13, 50 * 2
		dw	frq_450
		db	48,14, 45 * 2
		dw	frq_828
		db	255,15, 48 * 2
		dw	frq_828
patch_93Ahdr:	
		db	00ah,0b0h,003h,0c8h,6,0ffh

patch_93B:	
		db	1	; transpose on
		dw	patch_93Bhdr
		db	255,63, 12 * 2
		dw	frq_698
patch_93Bhdr:	
		db	031h,098h,085h,0ffh

;--- GM 94 = Pad 7 (halo) ---
patch_94A:	
		db	1	; transpose on
		dw	patch_52hdr
		db	255,24h, 1 + 12 * 2	; 292
		dw	frq_560

patch_94B:	
		db	1	; transpose on
		dw	patch_5Ahdr
		db	255,42, 12 * 2
		dw	frq_202


;--- GM 95 = Pad 8 (sweep) ---

patch_95A:	
		db	1	; transpose on
		dw	patch_95Ahdr
		db	16,211, 48 * 2
		dw	frq_920
		db	22,218, 64 * 2
		dw	frq_356
		db	28,212, 58 * 2
		dw	frq_920
		db	34,219, 64 * 2
		dw	frq_348
		db	40,213, 58 * 2
		dw	frq_937
		db	46,220, 64 * 2
		dw	frq_352
		db	52,214, 58 * 2
		dw	frq_926
		db	58,221, 64 * 2
		dw	frq_365
		db	64,215, 58 * 2
		dw	frq_974	; 975
		db	70,222, 64 * 2
		dw	frq_341
		db	76,216, 58 * 2
		dw	frq_926
		db	255,217, 52 * 2
		dw	frq_926
patch_95Ahdr:	
		db	019h,098h,015h,0c8h,6,0ffh

patch_95B:	
		db	1	; transpose on
		dw	patch_95Bhdr
		db	16,211, 48 * 2
		dw	frq_909
		db	22,218, 64 * 2
		dw	frq_350
		db	28,212, 58 * 2
		dw	frq_909
		db	34,219, 64 * 2
		dw	frq_340
		db	40,213, 58 * 2
		dw	frq_927
		db	46,220, 64 * 2
		dw	frq_345
		db	52,214, 58 * 2
		dw	frq_916
		db	58,221, 64 * 2
		dw	frq_357
		db	64,215, 58 * 2
		dw	frq_964
		db	70,222, 64 * 2
		dw	frq_333
		db	76,216, 58 * 2
		dw	frq_926
		db	255,217, 52 * 2
		dw	frq_916

patch_95Bhdr:	
		db	018h,098h,015h,0c8h,6,0ffh

;--- GM 96 = Rain ---

patch_96:	
		db	0	; transpose off
		dw	patch_15Bhdr
		db	255,43h, 1 + (48 + 1) * 2	; tone 323
		dw	frq_448


;--- GM 97 = Soundtrack ---

patch_97A:	
		db	1	; transpose on
		dw	patch_97Ahdr
		db	255,2, 24 * 2
		dw	frq_927
patch_97Ahdr:	
		db	02ah,098h,060h,0ffh

patch_97B:	
		db	1	; transpose on
		dw	patch_97Bhdr
		db	255,243, 0 * 2
		dw	frq_704
patch_97Bhdr:	
		db	02dh,098h,052h,0b0h,014h,0c8h,006h,0e0h,2,0ffh

;--- GM 98 = Crystal ---

patch_98A:	
		db	1	; transpose on
		dw	patch_98Ahdr
		db	255,243, 0 * 2
		dw	frq_143
patch_98Ahdr:	
		db	033h,0ffh

patch_98B:	
		db	1	; transpose on
		dw	patch_98Bhdr
		db	21,109, 36 * 2
		dw	frq_824
		db	31,110, 45 * 2
		dw	frq_831
		db	255,111, 43 * 2
		dw	frq_843
patch_98Bhdr:	
		db	03bh,098h,085h,0c8h,6,0ffh

;--- GM 99 = Atmosphere ---

patch_99A:	
		db	1	; transpose on
		dw	patch_99Ahdr
		db	255,2, 24 * 2
		dw	frq_927
patch_99Ahdr:	
		db	032h,098h,073h,0b0h,022h,0c8h,6,0e0h,1,0ffh

patch_99B:	
		db	1	; transpose on
		dw	patch_99Bhdr
		db	24,179, 36 * 2
		dw	frq_459
		db	31,183, 48 * 2
		dw	frq_555
		db	37,181, 55 * 2
		dw	frq_21
		db	44,180, 49 * 2
		dw	frq_459
		db	255,182, 44 * 2
		dw	frq_726
patch_99Bhdr:	
		db	032h,0c8h,7,0e0h,2,0ffh

;--- GM 100 = Brightness ---

patch_100A:	
		db	1	; transpose on
		dw	patch_15Bhdr
		db	255,37h, 1 + 24 * 2	; tone 311
		dw	frq_366

patch_100B:	
		db	1	; transpose on
		dw	patch_100Bhdr
		db	255,42, 12 * 2
		dw	frq_208
patch_100Bhdr:	
		db	029h,0c8h,6,0ffh

;--- GM 102 = Echoes ---

patch_102A:	
		db	1	; transpose on
		dw	patch_102Ahdr
		db	255,24h, 1 + 24 * 2	; tone 292
		dw	frq_552
patch_102Ahdr:	
		db	02bh,098h,0f5h,0b0h,021h,0c8h,6,0ffh

patch_102B:	
		db	1	; transpose on
		dw	patch_102Bhdr
		db	255,42, 12 * 2
		dw	frq_211
patch_102Bhdr:	
		db	02bh,098h,085h,0b0h,023h,0c8h,7,0ffh

;--- GM 103 = FX 8 (sci-fi) ---

patch_103A:	
		db	1	; transpose on
		dw	patch_103Ahdr
		db	26,12, 36 * 2
		dw	frq_443
		db	33,13, 50 * 2
		dw	frq_448
		db	48,14, 45 * 2
		dw	frq_824
		db	255,15, 48 * 2
		dw	frq_824
patch_103Ahdr:	
		db	02bh,098h,090h,0c8h,6,0e0h,3,0ffh

patch_103B:	
		db	1	; transpose on
		dw	patch_63Bhdr
		db	255,2, 12 * 2
		dw	frq_925


;--- GM 104 = Sitar ---

patch_104:	
		db	1	; transpose on
		dw	patch_104hdr
		db	255,0fh, 1 + 12 * 2	; tone 271
		dw	frq_847
patch_104hdr:	
		db	032h,098h,0f4h,0b0h,015h,0c8h,016h,0e0h,1,0ffh

;--- GM 105 = Banjo ---

patch_105:	
		db	1	; transpose on
		dw	patch_23Ahdr
		db	29,19, 24 * 2
		dw	frq_641
		db	33,20, 53 * 2
		dw	frq_203
		db	37,18, 45 * 2
		dw	frq_944
		db	45,21, 49 * 2
		dw	frq_288
		db	53,23, 45 * 2
		dw	frq_677
		db	255,22, 53 * 2
		dw	frq_45

;--- GM 106 = Shamisen ---

patch_106:	
		db	1	; transpose on
		dw	patch_2Bhdr
		db	255,0eh, 1 + 12 * 2	; tone 270
		dw	frq_97

;--- GM 107 = Koto ---

patch_107:	
		db	1	; transpose on
		dw	patch_0hdr
		db	255,169, 12 * 2
		dw	frq_556


;--- GM 108 = Kalimba ---

patch_108:	
		db	1	; transpose on
		dw	patch_23Ahdr
		db	255,37h, 1 + 12 * 2	; tone 311
		dw	frq_366


;--- GM 109 = Bagpipes ---

patch_109A:	
		db	1	; transpose on
		dw	patch_109Ahdr
		db	34,164, 48 * 2
		dw	frq_1
		db	255,168, 46 * 2
		dw	frq_335
patch_109Ahdr:	
		db	01ch,0ffh


patch_109B:	
		db	1	; transpose on
		dw	patch_109Bhdr
		db	34,167, 48 * 2
		dw	frq_0
		db	255,168, 46 * 2
		dw	frq_335
patch_109Bhdr:	
		db	019h,0ffh

;--- GM 110 = Fiddle ---

patch_110:	
		db	1	; transpose on
		dw	patch_69hdr
		db	35,05h, 1 + 24 * 2	; tone 261
		dw	frq_288
		db	40,02h, 1 + 59 * 2	; tone 258
		dw	frq_69
		db	42,06h, 1 + 52 * 2	; tone 262
		dw	frq_630
		db	45,07h, 1 + 54 * 2	; tone 263
		dw	frq_556
		db	48,08h, 1 + 57 * 2	; tone 264
		dw	frq_264
		db	51,0ah, 1 + 48 * 2	; tone 266
		dw	frq_920
		db	53,0bh, 1 + 51 * 2	; tone 267
		dw	frq_726
		db	55,0ch, 1 + 53 * 2	; tone 268
		dw	frq_579
		db	58,0dh, 1 + 55 * 2	; tone 269
		dw	frq_338
		db	255,09h, 1 + 58 * 2	; tone 265
		dw	frq_143

;--- GM 111 = Shanai ---

patch_111:	
		db	1	; transpose on
		dw	patch_111hdr
		db	255,65, 36 * 2
		dw	frq_448
patch_111hdr:	
		db	031h,0c8h,9,0ffh

;--- GM 112 = Tinkle Bell ---

patch_112A:	
		db	1	; transpose on
		dw	patch_112Ahdr
		db	255,243, 0 * 2
		dw	frq_721
patch_112Ahdr:	
		db	03bh,098h,0d6h,0ffh

patch_112B:	
		db	1	; transpose on
		dw	patch_17hdr
		db	255,37h, 1 + 36 * 2	; 311
		dw	frq_214

;--- GM 113 = Agogo ---

patch_113:	
		db	0	; transpose off
		dw	patch_23Ahdr
		db	255,11, 12 * 2
		dw	frq_217


;--- GM 114 = Steel Drums ---

patch_114A:	
		db	0	; transpose off
		dw	patch_114Ahdr
		db	255,254, 12 * 2
		dw	frq_317
patch_114Ahdr:	
		db	038h,0e0h,1,0ffh

patch_114B:	
		db	0	; transpose off
		dw	patch_114Bhdr
		db	255,1, 1 + 36 * 2	; tone 257
		dw	frq_195
patch_114Bhdr:	
		db	038h,098h,0b0h,0b0h,005h,0e0h,1,0ffh

;--- GM 115 = Woodblock ---

patch_115:	
		db	0	; transpose off
		dw	patch_115hdr
		db	255,44, 24 * 2
		dw	frq_355
patch_115hdr:	
		db	0,0ffh

;--- GM 116 = Taiko Drum ---

patch_116:	
		db	0	; transpose off
		dw	patch_23Ahdr
		db	255,62, 12 * 2
		dw	frq_217

;--- GM 117 = Melodic Tom ---

patch_117:	
		db	0	; transpose off
		dw	patch_117hdr
		db	255,199, 36 * 2
		dw	frq_616
patch_117hdr:	
		db	038h,0c8h,1,0ffh

;--- GM 118 = Synth Drum ---

patch_118:	
		db	0	; transpose off
		dw	patch_23Ahdr
		db	255,38, 24 * 2
		dw	frq_27

;--- GM 119 = Reverse Cymbal ---

patch_119:	
		db	0	; transpose off
		dw	patch_119hdr
		db	255,49, 36 * 2
		dw	frq_143
patch_119hdr:	
		db	038h,0c8h,9,0ffh

;--- GM 120 = Gtr Fret Noise ---

patch_120:	
		db	0	; transpose off
		dw	patch_23Ahdr
		db	255,38h, 1 + 24 * 2	; tone 312
		dw	frq_354

;--- GM 121 = Breath Noise ---

patch_121:	
		db	0	; transpose off
		dw	patch_23Ahdr
		db	255,25h, 1 + 24 * 2	; tone 293
		dw	frq_733

;--- GM 122 = Sea Shore ---

patch_122A:	
		db	0	; transpose off
		dw	patch_122Ahdr
		db	255,8, 36 * 2
		dw	frq_264
patch_122Ahdr:	
		db	0,0c8h,4,0ffh

patch_122B:	
		db	0	; transpose off
		dw	patch_122Bhdr
		db	255,55, 48 * 2
		dw	frq_203
patch_122Bhdr:	
		db	0,098h,020h,0b0h,4,0c8h,5,0e0h,0,0ffh


;--- GM 124 = Telephone / Bird ---

patch_124:	
		db	0	; transpose off
		dw	patch_115hdr
		db	48, 3, 36 * 2
		dw	frq_27
		db	255, 9, 36 * 2
		dw	frq_203


;--- GM 125 = Helicopter ---

patch_125A:	
		db	0	; transpose off
		dw	patch_125Ahdr
		db	255, 1, 24 * 2
		dw	frq_560
patch_125Ahdr:	
		db	8,0c8h,7,0ffh

patch_125B:	db	0	; transpose off
		dw	patch_125Bhdr
		db	255, 55, 36 * 2
		dw	frq_462
patch_125Bhdr:	
		db	0,0c8h,7,0e0h,0,0ffh


;--- GM 126 = Applause ---

patch_126A:	
		db	0	; transpose off
		dw	patch_126Ahdr
		db	255, 54, 24 * 2
		dw	frq_216
patch_126Ahdr:	
		db	0fh,098h,070h,0ffh

patch_126B:	
		db	0	; transpose off
		dw	patch_126Bhdr
		db	255, 54, 24 * 2
		dw	frq_462
patch_126Bhdr:	
		db	07h,098h,070h,0ffh

;--- GM 127 = Gunshot / Snare ---

patch_127:	
		db	0	; transpose off
		dw	patch_127hdr
		db	48,39h, 1 + 24 * 2	; tone 313
		dw	frq_203
;        	db      255, 59, 1 + 24 * 2
		db	255, 120, 0 + 24 * 2
		dw	frq_203
patch_127hdr:	
		db	038h,0c8h,3,0ffh

;--- Drum patch 1 ---

drum_1:	
		db	0	; transpose off
		dw	drum_1hdr
		db	48,17, 24 * 2	; tone 17
		dw	frq_264
		db	255,191, 36 * 2	; tone 191
		dw	frq_264
drum_1hdr:	
		db	0,098h,0f4h,0b0h,0feh,0c8h,6,0ffh

;--- Drum patch 2 ---

drum_2:	
		db	0	; transpose off
		dw	drum_2hdr
		db	48,209, 24 * 2	; tone 209
		dw	frq_908
		db	255,197, 24 * 2	; tone 197
		dw	frq_908
drum_2hdr:	
		db	0,098h,0f5h,0b0h,0f2h,0c8h,6,0ffh


;--- Drum patch 3 ---

drum_3:		
		db	0	; transpose off
		dw	drum_3hdr
		db	255,10, 24 * 2	; tone 10
		dw	frq_654
drum_3hdr:	
		db	0,098h,0f4h,0b0h,0f2h,0c8h,6,0ffh

;--- Drum patch 4 ---

drum_4:		
		db	0	; transpose off
		dw	drum_3hdr
		db	255,28, 24 * 2	; tone 28
		dw	frq_187

;--- Drum patch 5 ---

drum_5:	
		db	0	; transpose off
		dw	drum_3hdr
		db	255,31, 24 * 2	; tone 31
		dw	frq_908

;--- Drum patch 6 ---

drum_6:		
		db	0	; transpose off
		dw	drum_3hdr
		db	255,156, 24 * 2	; tone 156
		dw	frq_27

;--- Drum patch 7 ---

drum_7:	
		db	0	; transpose off
		dw	drum_3hdr
		db	255,49, 24 * 2	; tone 49
		dw	frq_24

;--- Drum patch 8 ---

drum_8:	
		db	0	; transpose off
		dw	drum_8hdr
		db	255,157, 24 * 2	; tone 157
		dw	frq_737
drum_8hdr:	
		db	0,0b0h,027h,0c8h,6,0ffh

gmdrm_hdr1:	
		db	0,098h,0f4h,0b0h,0f2h,0c8h,6,0ffh
gmdrm_hdr2:	
		db	0,098h,0f5h,0b0h,0f2h,0c8h,6,0ffh
gmdrm_hdr3:	
		db	0,098h,0f2h,0b0h,0f2h,0c8h,6,0ffh
gmdrm_hdr4:	
		db	0,098h,0f1h,0b0h,0f2h,0c8h,6,0ffh
gmdrm_hdr5:	
		db	0,098h,0f4h,0b0h,027h,0c8h,6,0ffh
gmdrm_hdr6:	
		db	0,098h,0f4h,0b0h,0f2h,0c8h,7,0ffh
gmdrm_hdr7:	
		db	0,098h,0f6h,0b0h,0ffh,0c8h,6,0ffh
gmdrm_hdr8:	
		db	0,098h,0f4h,0b0h,0f2h,0c8h,6,0ffh
gmdrm_hdr9:	
		db	0,098h,0f4h,0b0h,0f2h,0c8h,4,0ffh

;--- Midi Drum patch ---

drum_midi:	
		db	0	; transpose off
		dw	gmdrm_hdr1
		db	36,16, (48 - 35) * 2	; tone 16
		dw	frq_311

gmdrm_c4:	
		db	17
		db	018h,0f2h
		dw	gmdrm_hdr1
gmdrm_cp4:	
		db	210
		db	0f6h,0
		dw	gmdrm_hdr1
gmdrm_d4:	
		db	209
		db	0f4h,0f6h
		dw	gmdrm_hdr2
gmdrm_dp4:	
		db	10
		db	02ah,0f5h
		dw	gmdrm_hdr1
gmdrm_e4:	
		db	209
		db	038h,003h
		dw	gmdrm_hdr3
gmdrm_f4:	
		db	200
		db	060h,0
		dw	gmdrm_hdr1
gmdrm_fp4:	
		db	121
		db	05ch,1
		dw	gmdrm_hdr1
gmdrm_g4:	
		db	200
		db	0a8h,2
		dw	gmdrm_hdr1
gmdrm_gp4:	
		db	123
		db	034h,5
		dw	gmdrm_hdr1
gmdrm_a4:	
		db	200
		db	046h,4
		dw	gmdrm_hdr1
gmdrm_ap4:	
		db	122
		db	034h,5
		dw	gmdrm_hdr4
gmdrm_b4:	db	199
		db	00ah,3
		dw	gmdrm_hdr1

gmdrm_c5:	
		db	199
		db	0f4h,4
		dw	gmdrm_hdr1
gmdrm_cp5:	
		db	49
		db	032h,0
		dw	gmdrm_hdr1
gmdrm_d5:	
		db	199
		db	090h,010h
		dw	gmdrm_hdr1
gmdrm_dp5:	
		db	46
		db	0ceh,1
		dw	gmdrm_hdr1
gmdrm_e5:	
		db	122
		db	056h,0e1h
		dw	gmdrm_hdr1
gmdrm_f5:	
		db	33
		db	03ch,1
		dw	gmdrm_hdr1
gmdrm_fp5:	
		db	37
		db	0bah,0
		dw	gmdrm_hdr3
gmdrm_g5:	
		db	49
		db	0cah,5
		dw	gmdrm_hdr2
gmdrm_gp5:	db	29
		db	0feh,0f6h
		dw	gmdrm_hdr1
gmdrm_a5:	
		db	49
		db	070h,3
		dw	gmdrm_hdr1
gmdrm_ap5:	db	157
		db	0cah,0f5h
		dw	gmdrm_hdr5
gmdrm_b5:	
		db	46
		db	074h,5
		dw	gmdrm_hdr6

gmdrm_c6:	
		db	28
		db	076h,1
		dw	gmdrm_hdr1
gmdrm_cp6:	
		db	28
		db	032h,0
		dw	gmdrm_hdr1
gmdrm_d6:	
		db	30
		db	0dah,0f4h
		dw	gmdrm_hdr1
gmdrm_dp6:	
		db	31
		db	0feh,0f6h
		dw	gmdrm_hdr1
gmdrm_e6:	
		db	31
		db	0fch,0f2h
		dw	gmdrm_hdr1
gmdrm_f6:	
		db	156
		db	03eh,0
		dw	gmdrm_hdr1
gmdrm_fp6:	
		db	156
		db	0d0h,0f4h
		dw	gmdrm_hdr1
gmdrm_g6:	
		db	11
		db	016h,0
		dw	gmdrm_hdr1
gmdrm_gp6:	
		db	11
		db	03ch,0f4h
		dw	gmdrm_hdr1
gmdrm_a6:	
		db	47
		db	050h,3
		dw	gmdrm_hdr1
gmdrm_ap6:	
		db	48
		db	04ah,0
		dw	gmdrm_hdr1
gmdrm_b6:	
		db	45
		db	038h,0f3h
		dw	gmdrm_hdr1

gmdrm_c7:	
		db	044h
		db	053h,0f2h
		dw	gmdrm_hdr7
gmdrm_cp7:	
		db	36
		db	074h,5
		dw	gmdrm_hdr8
gmdrm_d7:	
		db	36
		db	048h,0f6h
		dw	gmdrm_hdr1
gmdrm_dp7:	
		db	32
		db	050h,0f5h
		dw	gmdrm_hdr1
gmdrm_e7:	
		db	44
		db	028h,0f2h
		dw	gmdrm_hdr1
gmdrm_f7:	
		db	44
		db	05ch,0e7h
		dw	gmdrm_hdr1
gmdrm_fp7:	
		db	34
		db	022h,010h
		dw	gmdrm_hdr1
gmdrm_g7:	
		db	35
		db	0c0h,0f6h
		dw	gmdrm_hdr1
gmdrm_gp7:	
		db	50
		db	050h,0
		dw	gmdrm_hdr1
gmdrm_a7:	
		db	50
		db	054h,0
		dw	gmdrm_hdr9
gmdrm_ap7:	
		db	191
		db	018h,0f2h
		dw	gmdrm_hdr1
gmdrm_b7:	
		db	197
		db	018h,0f7h
		dw	gmdrm_hdr1
gmdrm_c8:	
		db	197
		db	038h,003h
		dw	gmdrm_hdr1
gmdrm_cp8:	
		db	208
		db	018h,0f2h
		dw	gmdrm_hdr1
gmdrm_d8:	
		db	120
		db	018h,0f2h
		dw	gmdrm_hdr1
gmdrm_dp8:	
		db	201
		db	008h,0f2h
		dw	gmdrm_hdr1
gmdrm_e8:	
		db	198
		db	018h,00h
		dw	gmdrm_hdr1
gmdrm_f8:	
		db	59
		db	019h,0f2h
		dw	gmdrm_hdr1



