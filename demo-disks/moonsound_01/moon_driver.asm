;********************************************
; defines
;********************************************

MOON_BASE:	equ	0C4h
MOON_REG1:	equ	MOON_BASE
MOON_DAT1:	equ	MOON_BASE+1
MOON_REG2:	equ	MOON_BASE+2
MOON_DAT2:	equ	MOON_BASE+3
MOON_STAT:	equ	MOON_BASE

MOON_WREG:	equ	7Eh
MOON_WDAT:	equ	MOON_WREG+1


USE_CH: 	equ	24+18
FM_BASECH:	equ	24

;********************************************
; MDR file format
;********************************************
S_ADDR_CORRECT: equ	0C000h - 8000h	

S_DEVICE_FLAGS:	equ	0C007h                  ;8007
                        
S_TRACK_TABLE:	equ	0C010h                  ;8010
S_TRACK_BANK:	equ	S_TRACK_TABLE + 2
S_LOOP_TABLE:	equ	S_TRACK_TABLE + 4
S_LOOP_BANK:	equ	S_TRACK_TABLE + 6
S_VENV_TABLE:	equ	S_TRACK_TABLE + 8
S_VENV_LOOP:	equ	S_TRACK_TABLE + 10
S_PENV_TABLE:	equ	S_TRACK_TABLE + 12
S_PENV_LOOP:	equ	S_TRACK_TABLE + 14
S_NENV_TABLE:	equ	S_TRACK_TABLE + 16
S_NENV_LOOP:	equ	S_TRACK_TABLE + 18
S_LFO_TABLE:	equ	S_TRACK_TABLE + 20
S_INST_TABLE:	equ	S_TRACK_TABLE + 22
S_OPL3_TABLE:	equ	S_TRACK_TABLE + 24
;-------------------------------------------------------------------
; описание: »нициализаци€ проигрывател€
; параметры: нет
; возвращаемое  значение: нет
;---------------------------------------------------------------------
MoonDriver_Init:
	jp	moon_init_all
;-------------------------------------------------------------------
; описание: ѕроигрывание 
; параметры: нет
; возвращаемое  значение: нет
;---------------------------------------------------------------------
MoonDriver_Play:
	jp	moon_proc_tracks			;Execute 1frame (1/60)
;-------------------------------------------------------------------
; описание: выключение всех нот
; параметры: нет
; возвращаемое  значение: нет
;---------------------------------------------------------------------
MoonDriver_Keyoff:
	jp	moon_seq_all_keyoff			;All key-off

;-------------------------------------------------------------------
; Initialises all driver things
;-------------------------------------------------------------------
moon_init_all:
	call	moon_init				;инициализаци€ карты
	jp	moon_seq_init
;-------------------------------------------------------------------
; описание: »нициализаци€ карты ZXM-MoonSound
; параметры: нет
; возвращаемое  значение: нет
;---------------------------------------------------------------------
moon_init:
	; CONNECTION SEL
	ld	de, 0400h 
	call	moon_fm2_out
	; set 1 to NEW2, NEW
	ld	de, 0503h
	call	moon_fm2_out
	; RHYTHM
	ld	de, 0bd00h
	call	moon_fm1_out
	; Set WaveTable header
	ld	de, 0210h
	call	moon_wave_out
	ret
;-------------------------------------------------------------------
; ќписание: ѕеременные проигывател€
;-------------------------------------------------------------------
seq_cur_ch:
	db 	0
seq_use_ch:
	db 	0
seq_start_fm:
	db 	0
seq_cur_bank:
	db 	0
seq_opsel:
	db 	0
seq_reg_bd:
	db 	0
seq_jump_flag:
	db 	0

seq_tmp_note:
	db 	0
seq_tmp_ch:
	db 	0
seq_tmp_oct:     
	db 	0
seq_tmp_fnum:
	dw 	0
;-------------------------------------------------------------------
;Workarea for channels in the driver
;-------------------------------------------------------------------
seq_work:
seq_ch1_dsel:
	db 	0
seq_ch1_opsel:
	db 	0
seq_ch1_synth:
	db 	0
seq_ch1_efx1:
	db 	0
seq_ch1_cnt:
	db 	0
seq_ch1_loop:
	db 	0
seq_ch1_bank:
	db 	0
seq_ch1_addr:
	dw 	0
seq_ch1_tadr:
	dw 	0
seq_ch1_tone:
	dw 	0
seq_ch1_key:
	db 	0
seq_ch1_damp:
	db 	0
seq_ch1_lfo:
	db 	0
seq_ch1_lfo_vib:
	db 	0
seq_ch1_ar_d1r:
	db 	0
seq_ch1_dl_d2r:
	db 	0
seq_ch1_rc_rr:
	db 	0
seq_ch1_am:
	db 	0
seq_ch1_note:
	db 	0
seq_ch1_pitch:
	dw 	0
seq_ch1_p_ofs:
	dw 	0
seq_ch1_oct:
	db 	0
seq_ch1_fnum:
	dw 	0
seq_ch1_reverb:
	db 	0
seq_ch1_vol:
	db 	0
seq_ch1_pan:
	db 	0
seq_ch1_detune:
	db 	0
seq_ch1_venv:
	db 	0
seq_ch1_nenv:
	db 	0
seq_ch1_penv:
	db 	0
seq_ch1_nenv_adr:
	dw 	0
seq_ch1_penv_adr:
	dw 	0
seq_ch1_venv_adr:
	dw 	0
seq_work_end:

IDX_DSEL:     equ 	(seq_ch1_dsel    - seq_work) ; Device Select
IDX_OPSEL:    equ 	(seq_ch1_opsel   - seq_work) ; Operator Select
IDX_SYNTH:    equ 	(seq_ch1_synth   - seq_work) ; FeedBack,Synth and OpMode
IDX_EFX1:     equ 	(seq_ch1_efx1    - seq_work) ; Effect flags
IDX_CNT:      equ 	(seq_ch1_cnt     - seq_work) ; Counter
IDX_LOOP:     equ 	(seq_ch1_loop    - seq_work) ; Loop
IDX_BANK:     equ 	(seq_ch1_bank    - seq_work) ; Which bank
IDX_ADDR:     equ 	(seq_ch1_addr    - seq_work) ; Address to data
IDX_TADR:     equ 	(seq_ch1_tadr    - seq_work) ; Address of a Tone Table
IDX_TONE:     equ 	(seq_ch1_tone    - seq_work) ; Tone number in OPL4
IDX_KEY:      equ 	(seq_ch1_key     - seq_work) ; data in Key register
IDX_DAMP:     equ 	(seq_ch1_damp    - seq_work) ; Damp switch
IDX_LFO:      equ 	(seq_ch1_lfo     - seq_work) ; LFO switch
IDX_LFO_VIB:  equ 	(seq_ch1_lfo_vib - seq_work) ; LFO and VIB
IDX_AR_D1R:   equ 	(seq_ch1_ar_d1r  - seq_work) ; AR and D1R
IDX_DL_D2R:   equ 	(seq_ch1_dl_d2r  - seq_work) ; DL and D2R 
IDX_RC_RR:    equ 	(seq_ch1_rc_rr   - seq_work) ; RC and RR
IDX_AM:       equ 	(seq_ch1_am      - seq_work) ; AM
IDX_NOTE:     equ 	(seq_ch1_note    - seq_work) ; Note data
IDX_PITCH:    equ 	(seq_ch1_pitch   - seq_work) ; Pitch data
IDX_P_OFS:    equ 	(seq_ch1_p_ofs   - seq_work) ; Offset for pitch
IDX_OCT:      equ 	(seq_ch1_oct     - seq_work) ; Octave in OPL4
IDX_FNUM:     equ 	(seq_ch1_fnum    - seq_work) ; F-number in OPL4
IDX_REVERB:   equ 	(seq_ch1_reverb  - seq_work) ; Pseudo reverb
IDX_VOL:      equ 	(seq_ch1_vol     - seq_work) ; Volume in OPL4
IDX_PAN:      equ 	(seq_ch1_pan     - seq_work) ; Pan in OPL4
IDX_DETUNE:   equ 	(seq_ch1_detune  - seq_work) ; Detune
IDX_VENV:     equ 	(seq_ch1_venv    - seq_work) ; Volume envelope in data
IDX_NENV:     equ 	(seq_ch1_nenv    - seq_work) ; Vote envelope  in data
IDX_PENV:     equ 	(seq_ch1_penv    - seq_work) ; Pitch envelope in data
IDX_NENV_ADR: equ 	(seq_ch1_nenv_adr - seq_work)
IDX_PENV_ADR: equ 	(seq_ch1_penv_adr - seq_work)
IDX_VENV_ADR: equ 	(seq_ch1_venv_adr - seq_work)

IDX_VOLOP:    equ 	(seq_ch1_reverb  - seq_work) ; Volume Operator in connect
IDX_OLDAT1:   equ 	(seq_ch1_ar_d1r  - seq_work) ; Volume Data for 1stOP

;-------------------------------------------------------------------
; Note : IDX_SYNTH OxxFFFSS
; O : 4OP mode
; F : FeedBack
; S : SynthType (bit0 for 1st&2nd bit1 for 3rd&4th)
;-------------------------------------------------------------------
SEQ_WORKSIZE: equ 	(seq_work_end - seq_work)

	ds	(SEQ_WORKSIZE * (USE_CH-1))

seq_data_end:

	db	"PianoTone"			; Piano OPL4
piano_tone:
	db	14h,27h				; min -> max
	dw	012ch				; tone
	dw	7474				; pitch offset
	db 	20h,0f2h,13h,08h,00h ;regs
	

	db	28h,2dh
	dw	012dh
	dw	6816
	db	20h,0f2h,14h,08h,00h 

	db	2eh,33h
	dw	012eh
	dw	5899
	db	20h,0f2h,14h,08h,00h
	
	db	34h,39h
	dw	012fh
	dw	5290
	db	20h,0f2h,14h,08h,00h
	
	db	3ah,3fh
	dw	0130h
	dw	4260
	db	20h,0f2h,14h,08h,00h

	db	40h,45h
	dw	0131h
	dw	3625
	db	20h,0f2h,14h,08h,00h

	db	46h,4bh
	dw	0132h
	dw	3116
	db	20h,0f2h,14h,08h,00h

	db	4ch,52h
	dw	0133h
	dw	2081
	db	20h,0f2h,14h,18h,00h

	db	53h,58h
	dw	0134h
	dw	1444
	db  	20h,0f3h,14h,18h,00h

	db	59h,6dh
	dw	0135h
	dw	1915
	db  	20h,0f4h,15h,08h,00h

	; terminator ( both min and max should be zero )
	db	0,0
	dw	0
	dw	0
	db  	0,0,0,0,0
;-------------------------------------------------------------------
; F-Number table for OPL3
;-------------------------------------------------------------------
fm_fnumtbl_old:
	dw	346 ; C
	dw	367 ; C+
	dw	389 ; D
	dw	412 ; D+
	dw	436 ; E
	dw	462 ; F
	dw	490 ; F+
	dw	519 ; G
	dw	550 ; G+
	dw	582 ; A
	dw	617 ; A+
	dw	654 ; B
	dw	693 ; C
	
fm_fnumtbl:
	dw	345 ; C 523.300000
	dw	365 ; C+ 554.400000
	dw	387 ; D 587.300000
	dw	410 ; D+ 622.300000
	dw	435 ; E 659.300000
	dw	460 ; F 698.500000
	dw	488 ; F+ 740.000000
	dw	517 ; G 784.000000
	dw	547 ; G+ 830.600000
	dw	580 ; A 880.000000
	dw	614 ; A+ 932.300000
	dw	651 ; B 987.800000
	dw	690 ; C 1046.500000
;-------------------------------------------------------------------
; Tonedata for OPL3
;-------------------------------------------------------------------
fm_testtone:
	db	00h ; FBS
	db	00h ; FBS2
	db	00h ; BD

	db	01h ; TREMOLO VIB SUS KSR MUL
	db	00h ; KSL OL
	db	11h ; AR DR
	db	13h ; SL RR
	db	01h ; WF
	           
	db	04h ;
	db	00h;
	db	11h ;
	db	18h ; 
	db	00h ; WF

	db	01h
	db	3fh
	db	55h
	db	55h
	db	00h

	db	01h
	db	3fh
	db	55h
	db	55h
	db	00h

fm_op2reg_tbl:
	db	00h ; 0
	db	01h
	db	02h ; 2
	db	03h
	db	04h ; 4
	db	05h
	db	08h ; 6
	db	09h
	db	0Ah ; 8
	db	0Bh
	db	0Ch ; 10
	db	0Dh
	db	10h ; 12
	db	11h
	db	12h ; 14
	db	13h
	db	14h ; 16
	db	15h ; 17
	           


fm_opbtbl:
	db	00h ; CH0
	db	01h ; CH1
	db	02h ; CH2
	db	06h ; CH3
	db	07h ; CH4
	db	08h ; CH5
	db	0ch ; CH6
	db	0dh ; CH7
	db	0eh ; CH8
	db	12h ; CH9
	db	13h ; CH10
	db	14h ; CH11
	db	18h ; CH12
	db	19h ; CH13
	db	1ah ; CH14
	db	1eh ; CH15
	db	1fh ; CH16
	db	20h ; CH17
;-------------------------------------------------------------------
; BSMCH
;-------------------------------------------------------------------
fm_drum_fnum:
	dw 	0120h ; B
	dw 	0150h ; S
	dw 	01c0h ; M
	dw 	01c0h ; C
	dw 	0150h ; H

fm_drum_fnum_map:
	db 	06h ; B
	db 	07h ; S
	db 	08h ; M
	db 	08h ; C
	db 	07h ; H

fm_drum_oct:
	db 	02h ; B
	db 	02h ; S
	db 	00h ; M
	db 	00h ; C
	db 	02h ; H
;-------------------------------------------------------------------
; описание: ѕолучение адреса пам€ти из таблицы
; параметры: HL - адрес таблицы
; возвращаемое  значение: HL - адрес пам€ти
;---------------------------------------------------------------------
get_table:
	ld	e, a
	ld	d, 0

	ld	a, (hl)
	inc	hl
	ld	h, (hl)
	ld	l, a

	push	de
	ld	de,S_ADDR_CORRECT
	add	hl,de
	pop	de	

	add	hl, de
	add	hl, de

	ld	a, (hl)
	inc	hl
	ld	h, (hl)
	ld	l, a

	ld	de,S_ADDR_CORRECT
	add	hl,de

	ret
;-------------------------------------------------------------------
; описание: ѕолучение данных пам€ти по адресу из таблицы
; параметры: HL - адрес таблицы
; возвращаемое  значение: ј - данные
;---------------------------------------------------------------------
get_a_table
	ld	a,(seq_cur_ch)
	ld	e,a
	ld	d,0

	ld	a,(hl)
	inc	hl
	ld	h,(hl)
	ld	l,a

	push	de
	ld	de,S_ADDR_CORRECT
	add	hl,de
	pop	de	

	add	hl,de

	ld	a,(hl)
	ret
;-------------------------------------------------------------------
; moon_seq_init
; initializes all channel's work
; dest : ALL
;-------------------------------------------------------------------
moon_seq_init:
	xor	a
	ld	hl,seq_cur_ch
	ld	de,seq_cur_ch +1
	ld	bc,seq_data_end - seq_cur_ch
	ld	(hl),a
	ldir		

	ld	a, (S_DEVICE_FLAGS)
	or	a
	jr	nz, skip_def_device
	ld	a, 1 ; OPL4 by default
skip_def_device:
	ld	b,a

	ld	iy, fm_opbtbl
	ld	ix, seq_work

	ld	d, 0
	ld	e, 18h ; 24channels ; OPL4

	rr	b
	call	c, seq_init_chan

	inc	d
	ld	e, 12h ; 18channels
	rr	b
	call	c, seq_init_chan ; OPL3

	ld	ix, seq_work
	ret
;-------------------------------------------------------------------
; seq_init_chan
; in   : D = device, E = channels
; dest : AF,E
;-------------------------------------------------------------------
seq_init_chan:

	ld	a,d
	or	a
	jr	z,skip_set_start_fm 		; if device isn't OPL3 then skip

	ld	a, (seq_use_ch)
	ld	(seq_start_fm), a

skip_set_start_fm:
	ld	a, (seq_use_ch)
	add	a,e
	ld	(seq_use_ch), a


seq_init_chan_lp:
	xor	a
	ld	(ix + IDX_CNT),a
	ld	a,d
	ld	(ix + IDX_DSEL),a

	push	de
	ld	a, 0ffh
	ld	(ix + IDX_VENV), a
	ld	(ix + IDX_PENV), a
	ld	(ix + IDX_NENV), a
	ld	(ix + IDX_DETUNE), a
	ld	a,(ix + IDX_DSEL)
	or	a
	jr 	z,init_op4tone

init_fmtone:
	ld	hl,fm_testtone
	ld	(ix + IDX_TADR), l
	ld	(ix + IDX_TADR+1), h
	ld	a,30h
	ld	(ix + IDX_PAN), a
	ld	a,2
	ld	(ix + IDX_VOLOP), a
	ld	a,3fh
	ld	(ix + IDX_VOL),a
	ld	a,(iy)
	ld	(ix + IDX_OPSEL),a
	inc	iy
	jr	init_tone_fin

init_op4tone:
	ld	hl,piano_tone
	ld	(ix + IDX_TADR),l
	ld	(ix + IDX_TADR+1),h
	xor	a
	ld	(ix + IDX_PAN),a

init_tone_fin:

	ld	hl, S_TRACK_TABLE
	ld	a, (seq_cur_ch)
	call	get_table

	ld	(ix + IDX_ADDR), l
	ld	(ix + IDX_ADDR+1), h

	ld	hl, S_TRACK_BANK
	call	get_a_table
	ld	(ix + IDX_BANK),a

	; next work
	ld	de, SEQ_WORKSIZE
	add	ix, de

	pop	de
	
	; next channel
	ld	a, (seq_cur_ch)
	inc	a
	ld	(seq_cur_ch), a

	dec	e
	jr	nz,seq_init_chan_lp
	ret
;-------------------------------------------------------------------
; seq_init_fmbase
; initializes all fmbase
; dest : ALL
;-------------------------------------------------------------------
seq_init_fmbase:
	ld	ix, seq_work
	ld	b, 18 ; num of fmchan
	ld	hl, fm_opbtbl
seq_init_fmbase_lp1:
	ld	a, (hl)
	ld	(ix + IDX_OPSEL), a
	inc	hl
	ld	de, SEQ_WORKSIZE
	add	ix, de
	djnz	seq_init_fmbase_lp1
	ret
;-------------------------------------------------------------------
;seq_all_keyoff
;this makes all keys off
;-------------------------------------------------------------------
moon_seq_all_keyoff:
	ld	ix,seq_work
	xor	a
	ld	(seq_cur_ch), a
seq_all_keyoff_lp:

	call	moon_key_off

	ld	de, SEQ_WORKSIZE
	add	ix, de

	ld	a, (seq_use_ch)
	ld	e, a
	ld	a, (seq_cur_ch)
	cp	e
	jr	nc,seq_all_keyoff_end

	inc	a
	ld	(seq_cur_ch), a
	jr	seq_all_keyoff_lp
	
seq_all_keyoff_end:
	ret
;-------------------------------------------------------------------
; moon_proc_tracks
; Process tracks in 1/60 interrupts
;-------------------------------------------------------------------
moon_proc_tracks:
	ld	ix,seq_work
	xor	a
	ld	(seq_cur_ch),a

proc_tracks_lp:
	call	proc_venv
	call	proc_penv
	call	proc_nenv
	call	proc_venv_reg
	call	proc_freq_reg
	call	seq_track
	ld	de,SEQ_WORKSIZE
	add	ix,de
	ld	a, (seq_use_ch)
	ld	e, a
	ld	a, (seq_cur_ch)
	inc	a
	cp	e
	jr	nc,proc_tracks_end
	ld	(seq_cur_ch),a
	jr	proc_tracks_lp
	
proc_tracks_end:
	ld 	a,(seq_jump_flag)
	or 	a
	ret 	z
	jr 	moon_proc_tracks
;-------------------------------------------------------------------
;seq_track
;Count down and process in a channel
;-------------------------------------------------------------------
seq_track:
	ld	a,(ix + IDX_CNT)
	or	a
	jr	z,seq_cnt_zero
	dec	a
	ld	(ix + IDX_CNT),a
	ret

seq_cnt_zero:
	ld	l, (ix + IDX_ADDR)
	ld	h, (ix + IDX_ADDR + 1)
seq_track_lp:
	; Read command from memory
	ld	a, (hl) 
	inc	hl
	cp	0e0h
	jr	nc, seq_command
	jp	seq_repeat_or_note

seq_command:
	ld	bc, seq_track_lp
	push	bc ; <- return address
	push	hl ; <- Preserve HL as pointer 
	add	a, 20h
	sla	a
	ld	l, a
	ld	h, 0
	ld	bc, seq_jmptable
	add	hl, bc

	; Read address from table
	ld	a, (hl)
	inc	hl
	ld	h, (hl)
	ld	l,a
	jp	(hl)
;-------------------------------------------------------------------
; seq_next
; preserves  address and do next
; in   : HL
; dest : AF
;-------------------------------------------------------------------
seq_next:
	ld	(ix + IDX_ADDR),l
	ld	(ix + IDX_ADDR+1),h
	jr	seq_track

	ret
;********************************************
; seq_repeat_or_note
;
; n < $90 =  note
; $A0     =  repeat_end
; $A1     =  repeat_esc

seq_repeat_or_note:
	cp	90h
	jr	c,seq_note

	cp	0a1h
	jr	z,seq_repeat_esc

;********************************************
seq_repeat_end:
	ld	a,(ix + IDX_LOOP)
	cp	1
	jr	z,seq_skip_rep_jmp

	or	a
	jr	nz,seq_skip_set_repcnt_end

	ld	a,(hl)    ; read repeat counter

seq_skip_set_repcnt_end:
	jr	seq_rep_jmp

;********************************************
seq_repeat_esc:
	ld	a,(ix + IDX_LOOP)
	cp	1
	jr	z,seq_rep_jmp

	or	a
	jr	nz,seq_skip_set_repcnt_esc

	ld	a,(hl)      ; read repeat counter

seq_skip_set_repcnt_esc:
	jr	seq_skip_rep_jmp

seq_skip_rep_jmp:
	inc	hl
	dec	a
	ld	(ix + IDX_LOOP),a
	inc	hl  ; bank
	inc	hl  ; addr l
	inc	hl  ; addr h
	jr	seq_next

seq_rep_jmp:
	inc	hl
	dec	a
	ld	(ix + IDX_LOOP),a

	ld	bc,seq_next
	push	bc
	push	hl

	ld	hl,seq_bank ; go to address
	jp	(hl)

;********************************************
seq_note:
	push	hl

	push	af
	ld	a, (ix + IDX_DSEL)
	or	a
	jr	z,seq_note_opl4

seq_note_fm:
	pop	af
	ld	(ix + IDX_NOTE),a
	call 	moon_set_fmnote
	jr	set_note_fin

seq_note_opl4:

	pop	af
	call	conv_data_to_midi
	ld	(ix + IDX_NOTE),a
	call	moon_set_midinote

set_note_fin:
	call	moon_key_on
	pop	hl

; note length
	ld	a, (hl)
	ld	(ix + IDX_CNT),a
	inc	hl
	jr	seq_next
; 
;
read_cmd_length:
	pop	af
	ld	a, (hl)
	ld	(ix + IDX_CNT),a
	inc	hl
	jr	seq_next


seq_jmptable:
	dw	seq_drumnote ; $e0 : Set drum note
	dw	seq_drumbit ; $e1 : Set drum bits
	dw	seq_jump   ; $e2 :
	dw	seq_fbs    ; $e3 : Set FBS
	dw	seq_tvp    ; $e4 : Set TVP
	dw	seq_ld2ops ; $e5 : Load 2OP Instrument
	dw	seq_setop  ; $e6 : Set opbase
	dw	seq_nop    ; $e7 : Pitch shift
	dw	seq_nop    ; $e8 :
	dw	seq_slar   ; $e9 : Slar switch
	dw	seq_revbsw ; $ea : Reverb switch / VolumeOP
	dw	seq_damp   ; $eb : Damp switch / OPMODE
	dw	seq_nop    ; $ec : LFO freq
	dw	seq_nop    ; $ed : LFO mode
	dw	seq_bank   ; $ee : Bank change
	dw	seq_lfosw  ; $ef : Mode change
	dw	seq_pan    ; $f0 : Set Pan
	dw	seq_inst   ; $f1 : Load Instrument (4OP or OPL4)
	dw	seq_drum   ; $f2 : Set Drum
	dw	seq_nop    ; $f3 :
	dw	seq_wait   ; $f4 : Wait
	dw	seq_data_write ; $f5 : Data Write
	dw	seq_nop    ; $f6
	dw	seq_nenv   ; $f7 : Note  envelope
	dw	seq_penv   ; $f8 : Pitch envelope
	dw	seq_skip_1 ; $f9 
	dw	seq_detune ; $fa : Detune
	dw	seq_nop    ; $fb : LFO
	dw	seq_rest   ; $fc : Rest
	dw	seq_volume ; $fd : Volume
	dw	seq_skip_1 ; $fe : Not used
	dw	seq_loop   ; $ff : Loop
;-------------------------------------------------------------------
; Volume envelope stuff
;-------------------------------------------------------------------
start_venv:
	ld	a,(ix + IDX_VENV)
	cp	0ffh
	ret	z

	call	set_venv_head
	jr	proc_venv_start

proc_venv:
	ld	a,(ix + IDX_VENV)
	cp	0ffh
	ret	z

proc_venv_start:
	ld	l,(ix + IDX_VENV_ADR)
	ld	h,(ix + IDX_VENV_ADR + 1)
	ld	a,l
	or	h
	ret	z

	ld	a, (hl)
	cp	0ffh
	jr	z,proc_venv_end
	inc	hl
	ld	(ix + IDX_VENV_ADR),l
	ld	(ix + IDX_VENV_ADR + 1),h

	ld	(ix + IDX_VOL),a
	ret


proc_venv_end:
	jp	set_venv_loop
;-------------------------------------------------------------------
; Set venv's volume to register actually
;-------------------------------------------------------------------
proc_venv_reg:
	ld	a,(ix + IDX_VENV)
	cp	0ffh
	ret	z
	jp	moon_set_vol_ch
;-------------------------------------------------------------------
; Pitch envelope stuff
;-------------------------------------------------------------------
start_penv:
	ld	a,(ix + IDX_PENV)
	cp	0ffh
	ret	z

	call	set_penv_head
	jr	proc_penv_start


proc_penv:
	ld	a,(ix + IDX_PENV)
	cp	0ffh
	ret	z
proc_penv_start:
	ld	l,(ix + IDX_PENV_ADR)
	ld	h,(ix + IDX_PENV_ADR + 1)

	ld	a, (hl)
	cp	0ffh
	jr	z,proc_penv_end

	inc	hl
	ld	(ix + IDX_PENV_ADR),l
	ld	(ix + IDX_PENV_ADR + 1),h

	push	af
	ld	a,(ix + IDX_DSEL)
	or	a
	jr	nz,proc_penv_fm

proc_penv_opl4:
	pop	af

	ld	l,(ix + IDX_PITCH)
	ld	h,(ix + IDX_PITCH + 1)
	call	add_freq_offset
	ld	(ix + IDX_PITCH),l
	ld	(ix + IDX_PITCH+1),h

	jp	moon_calc_opl4freq


proc_penv_end:
	jp	set_penv_loop

proc_penv_fm:
	pop	af
	ld	l,(ix + IDX_FNUM)
	ld	h,(ix + IDX_FNUM + 1)
	call	add_freq_offset

	ld	a,h
	cp	80h
	jr	nc,penv_fm_set_fnum

	ld	de,346
	call	comp_hl_de
	jr	c,penv_fm_dec_oct
	jr	z,penv_fm_dec_oct

	ld	de,693
	call	comp_hl_de
	jr	nc,penv_fm_inc_oct
	jr	z, penv_fm_inc_oct

penv_fm_set_fnum:
	ld	(ix + IDX_FNUM), l
	ld	(ix + IDX_FNUM+1), h
	jp	moon_key_fmfreq

penv_fm_dec_oct:
	; hl < de
	dec	(ix + IDX_OCT)
	add	hl,de
	call	comp_hl_de
	jr	c,penv_fm_dec_oct

	jr	penv_fm_set_fnum

penv_fm_inc_oct:
	; hl > de
	ld	bc,346
penv_fm_inc_oct_lp:
	inc	(ix + IDX_OCT)
	xor	a
	sbc	hl,bc
	call	comp_hl_de
	jr	nc,penv_fm_inc_oct_lp
	jr	penv_fm_set_fnum
;-------------------------------------------------------------------
; comp_hl_de
; Compare hl with de
; in   : HL,DE
; out  : C = (HL < DE), NC = (HL > DE), Z = (HL == DE)
; dest : AF
;-------------------------------------------------------------------
comp_hl_de:
	ld	a,h
	cp	d
	ret	nz
	ld	a,l
	cp	e
	ret
;-------------------------------------------------------------------
; Note envelope stuff
;-------------------------------------------------------------------
start_nenv:
	ld	a,(ix + IDX_NENV)
	cp	0ffh
	ret	z

	call	set_nenv_head
	jr	proc_nenv_start

proc_nenv:
	ld	a,(ix + IDX_NENV)
	cp	0ffh
	ret	z

proc_nenv_start:
	ld	l, (ix + IDX_NENV_ADR)
	ld	h, (ix + IDX_NENV_ADR + 1)

	ld	a, (hl)	
	cp	0ffh
	jp	z, set_nenv_loop

	inc	hl
	ld	(ix + IDX_NENV_ADR), l
	ld	(ix + IDX_NENV_ADR + 1), h

	push	af
	ld	a, (ix + IDX_DSEL)
	or	a
	jr	nz, proc_nenv_fm
	jr	proc_nenv_opl4

proc_nenv_opl4:
	pop	af
	bit	7, a
	jr	nz, proc_nenv_nega_opl4

	add	a, (ix + IDX_NOTE)
	ld	(ix + IDX_NOTE), a
proc_nenv_opl4_setnote
	call	moon_calc_midinote
	jp	moon_calc_opl4freq

proc_nenv_nega_opl4:
	and	7fh
	ld	e, a
	ld	a, (ix + IDX_NOTE)
	sub	e
	ld	(ix + IDX_NOTE), a
	jr	proc_nenv_opl4_setnote

proc_nenv_fm:
	pop	af
	ld	b, 0
	bit	7, a
	jr	nz, proc_nenv_fm_nega
proc_nenv_fm_lp1:
	cp	0ch
	jr	c, proc_nenv_fm_add
	sub	0ch
	inc	b
	jr	proc_nenv_fm_lp1
proc_nenv_fm_add:
	ld	c, a ; C = (note % 12)
	ld	a, (ix + IDX_NOTE)
	and	0fh
	add	a, c
	cp	0ch
	jr	c, skip_nenv_inc_oct
	add	a,4
	and	0fh
	inc	b
skip_nenv_inc_oct:
	ld	c, a ; C = (note & 0x0f)
	ld	a, b ; B = oct
	rlca
	rlca
	rlca
	rlca
	ld	b, a
	ld	a, (ix + IDX_NOTE)
	and	0f0h
	add	a, b
	or	c
	ld	(ix + IDX_NOTE), a
	call	moon_set_fmnote
	jp	moon_key_fmfreq

proc_nenv_fm_nega:
	and	7fh

proc_nenv_fm_nega_lp1:
	cp	0ch
	jr	c,proc_nenv_fm_sub
	sub	0ch
	inc	b
	jr	proc_nenv_fm_nega_lp1
proc_nenv_fm_sub:
	ld	c, a ; C = (note % 12)
	ld	a,(ix + IDX_NOTE)
	and	0fh
	sub	c
	jr	nc,skip_nenv_dec_oct
	sub	4
	and	0fh
	inc	b
skip_nenv_dec_oct:
	ld	c,a ; C = (note & 0x0f)
	ld	a,b ; B = oct
	rlca
	rlca
	rlca
	rlca
	ld	b,a
	ld	a,(ix + IDX_NOTE)
	and	0f0h
	sub	b
	or	c
	ld	(ix + IDX_NOTE),a
	call	moon_set_fmnote
	jp	moon_key_fmfreq
;-------------------------------------------------------------------
;Set frequency to registers actually
;
;-------------------------------------------------------------------
proc_freq_reg:
	ld	a,(ix + IDX_PENV)
	cp	0ffh
	jr	nz,proc_freq_to_moon
	ld	a,(ix + IDX_NENV)
	cp	0ffh
	jr	nz,proc_freq_to_moon
	ret
proc_freq_to_moon:
	jp	moon_set_freq_ch
;-------------------------------------------------------------------
; Subroutines to process sequence
; dest : AF, BC, DE
; No Program
;-------------------------------------------------------------------
seq_nop:
	pop	hl
	ret

; Skip the command with an augment
seq_skip_1:
	pop	hl
	inc	hl
	ret


; cmd $FF : loop point
seq_loop:
	pop	hl

	ld	hl, S_LOOP_TABLE
	ld	a, (seq_cur_ch)
	call	get_table

	push	hl

	ld	hl, S_LOOP_BANK
	call	get_a_table
	ld	(ix + IDX_BANK),a

	pop	hl
	ret

; cmd $FD : volume
seq_volume:
	pop	hl

	ld	a,(hl)
	ld	(ix + IDX_VENV),a

	bit	7,a
	jr	z,seq_venv
	and	7fh

	ld	(ix + IDX_VOL),a

	ld	a, 0ffh
	ld	(ix + IDX_VENV),a  ; venv = off

	call	moon_set_vol_ch

	inc	hl
	ret

seq_venv:

	call	set_venv_head

	inc	hl
	ret

; cmd $FC : rest
seq_rest:
	pop	hl
	call	moon_key_off
	jp	read_cmd_length

; cmd $FA : detune
seq_detune:
	pop	hl

	ld	a,(hl)
	ld	(ix + IDX_DETUNE),a
	inc	hl
	ret

; cmd $F8 : pitch env
seq_penv:
	pop	hl

	ld	a, (hl)
	inc	hl

	ld	(ix + IDX_PENV),a
	cp	0ffh
	call	nz,set_penv_head

	ret

; cmd $F7 : note env
seq_nenv:
	pop	hl

	ld	a, (hl)
	inc	hl

	ld	(ix + IDX_NENV), a
	cp	0ffh
	call	nz,set_nenv_head

	ret
;-------------------------------------------------------------------
; cmd $F5 : data_write
; in: low, high, data
;-------------------------------------------------------------------
seq_data_write:
	pop	hl
	ld	a, (hl)
	ld	d, a ; Address Low
	inc	hl
	ld	a, (hl) ; Address High
	or	a
	jr	z, write_data_cur_fm ; (a >> 8) == 0
	dec a
	jr	z, write_data_fm1 ; (a >> 8) == 1
	dec a
	jr	z, write_data_fm2 ; (a >> 8) == 2
	inc	hl
	ret

write_data_cur_fm:
	inc	hl
	ld	a, (hl)
	ld	e, a ; Data
	inc	hl
	
	ld	a, (seq_cur_ch)
	cp	9
	jp	c, moon_fm1_out
	jp	moon_fm2_out

write_data_fm1:
	inc	hl
	ld	a, (hl)
	ld	e, a ; Data
	inc	hl
	jp	moon_fm1_out

write_data_fm2:
	inc	hl
	ld	a, (hl)
	ld	e, a ; Data
	inc	hl
	jp	moon_fm2_out

; cmd $F4 : wait
seq_wait:
	pop	hl
	jp	read_cmd_length

; cmd $F2 : drum
seq_drum:
	pop	hl
	ld	a, (hl)
	and	1fh
	ld	e, a
	ld	a, (seq_reg_bd)
	and	0e0h
	or	e
	ld	(seq_reg_bd), a
	ld	e, a
	ld	d, 0bdh
	call	moon_fm1_out
	inc	hl
	ret
	
; cmd $E1 : drumbit
seq_drumbit:
	pop	hl

	; drums key-off
	ld	a, (hl)
	and	1fh
	xor	0ffh
	
	; e = mask bits of drums
	ld	e, a
	ld	a, (seq_reg_bd)
	and	e
	ld	(seq_reg_bd), a
	ld	e, a
	ld	d, 0bdh
	call	moon_fm1_out
	
	; set fnum
	push	hl
	ld	a, (hl)
	and	1fh
	
	ld	c, 0
	ld	b, 5

	rlca
	rlca
	rlca

; A = drum bits, BC = count
drumbit_fnum_lp:
	rlca

	jr	nc, drumbit_fnum_next
	push	af
	push	bc
	call	drumbit_set_fnum ; set Fnum for drums
	pop	bc
	pop	af

drumbit_fnum_next:
	inc	c
	djnz	drumbit_fnum_lp
	
	pop	hl
	
	; skip if jump flag is true
	ld	a, (seq_jump_flag)
	or	a
	jr	nz, drumbit_skip_keyon

	; drums key-on
	ld	a, (hl)
	and	1fh
	ld	e, a
	ld	a, (seq_reg_bd)
	and	0e0h
	or	e
	ld	(seq_reg_bd), a
	ld	e, a
	ld	d, 0bdh
	call	moon_fm1_out

drumbit_skip_keyon:
	; length check
	ld	a, (hl)
	and 	80h 					; Lxxxxxxx L = the command has length 
	jr	nz, drumbit_with_length
	inc	hl
	ret

; drumbit with length
drumbit_with_length:
	inc 	hl
	jp	read_cmd_length
;-------------------------------------------------------------------
; Set Fnum for drum
; C = index
; dest : almost all
;-------------------------------------------------------------------
drumbit_set_fnum:
	; fnum 
	ld	hl, fm_drum_fnum
	ld	b, 0
	add	hl, bc
	add	hl, bc
	ld	a, (hl)
	ld	(seq_tmp_fnum), a
	inc	hl
	ld	a, (hl)
	ld	(seq_tmp_fnum + 1), a
	
	; oct
	ld	hl, fm_drum_oct
	add	hl, bc
	ld	a, (hl)
	ld	(seq_tmp_oct), a

	; ch
	ld	hl, fm_drum_fnum_map
	add	hl, bc
	ld	a, (hl)
	ld	(seq_tmp_ch), a

	; write FnumL
	call	moon_key_write_fmfreq_base

	ld	e, a
	ld	d, 0b0h
	ld	a, (seq_tmp_ch)
	
	; write FnumH and BLK
	jp	moon_write_fmreg_nch


; cmd $E0 : drum note
seq_drumnote:
	pop	hl
	
	; set fnum	
	ld	a, (hl) ; drum bits
	and	1fh
	
	push	af
	inc	hl 
	ld	a, (hl) ; note
	ld	(seq_tmp_note), a
	inc	hl
	pop	af
	
	push	hl

	ld	c, 0
	ld	b, 5
	
	rlca
	rlca
	rlca

; A = drum bits, BC = count
drumnote_lp:
	rlca
	
	jr	nc, drumnote_next
	push	af
	push	bc
	call	drumnote_fnum ; set Fnum for drums
	pop	bc
	pop	af

drumnote_next:
	inc c
	djnz	drumnote_lp
	
	pop	hl
	inc	hl
	ret

; C = index
; dest: AF, BC, HL
drumnote_fnum:
	push	bc
	ld	a, (seq_tmp_note)
	call	moon_calc_opl3note
	pop	bc
	
	; oct
	ld	b, 0
	ld	hl, fm_drum_oct
	add	hl, bc
	ld	a, (seq_tmp_oct)
	ld	(hl), a

	; fnum 
	ld	hl, fm_drum_fnum
	add	hl, bc
	add	hl, bc
	ld	a, (seq_tmp_fnum)
	ld	(hl), a
	inc	hl
	ld	a, (seq_tmp_fnum + 1)
	ld	(hl), a
	
	ret


; cmd $F1 : Load instrument
seq_inst:
	pop	hl
	ld	a, (hl)

	push	af

	; Device select
	ld	a, (ix + IDX_DSEL)
	or	a
	jr	z, seq_inst_opl4

	; Load OPL3 instrument
	pop	af
	push	hl
	ld	hl, S_OPL3_TABLE
	call	get_table

	ld	(ix + IDX_TADR), l
	ld	(ix + IDX_TADR+1), h

	; set tone to FM
	call	moon_set_fmtone

	jr	seq_inst_fin

seq_inst_opl4:
	pop	af
	push	hl
	ld	hl, S_INST_TABLE
	call	get_table

	ld	(ix + IDX_TADR), l
	ld	(ix + IDX_TADR+1), h

seq_inst_fin:

;	call	set_page3_ch
	pop	hl

	inc	hl
	ret

; cmd $F0 : pan
seq_pan:
	pop	hl
	; Device select
	ld	a,(ix + IDX_DSEL)
	or	a
	jr	z,seq_pan_opl4

seq_pan_fm:
	ld	a,(hl)
	and	0fh
	rlca
	rlca
	rlca
	rlca
	ld	(ix + IDX_PAN), a ; PPPPxxxx
	call 	moon_write_fmpan ; Write PAN to FM
	
	jr	seq_pan_fin

seq_pan_opl4:
	ld	a, (hl)
	ld	(ix + IDX_PAN), a
seq_pan_fin:
	inc	hl
	ret

; cmd $EF : mode change
seq_lfosw:
	pop	hl

	ld	a,(hl)
	ld	(ix + IDX_LFO),a
	inc	hl
	ret


; cmd $EE : change bank
seq_bank:
	pop	hl

	ld	a,(hl) ; read number of bank
	inc	hl
	
	push	af
	
	ld	a,(hl) ; read address
	inc	hl
	ld	h,(hl)
	ld	l,a

	push	de
	ld	de,S_ADDR_CORRECT
	add	hl,de
	pop	de	

	pop	af

	ld	(ix + IDX_BANK),a
	ret

; cmd $EB : damp switch / OPMODE
seq_damp:
	pop	hl
	; Device select
	ld	a,(ix + IDX_DSEL)
	or	a
	jr	z,seq_damp_opl4

	ld	a,(hl)
	and	3fh
	ld	e,a
	ld	d,4
	call	moon_fm2_out
	jr	seq_damp_fin
	
seq_damp_opl4:
	ld	a,(hl)
	ld	(ix + IDX_DAMP),a
seq_damp_fin:
	inc	hl
	ret

; cmd $EA : reverb sw / VolumeOP
seq_revbsw:
	pop	hl
	ld	a,(hl)
	ld	(ix + IDX_REVERB),a
	inc	hl
	ret

; cmd $E9 : slar sw
seq_slar:
	pop	hl
	set	0,(ix + IDX_EFX1)
	ret


; cmd $E6 : set opbase
seq_setop:
	pop	hl
	ld	a, (hl)
	ld	(ix + IDX_OPSEL), a
	inc	hl
	ret

; cmd $E5 : load 2ops
seq_ld2ops:
	ld	a, (ix + IDX_DSEL)
	or	a
	jr	nz, seq_ld2ops_fm

	pop	hl
	inc	hl
	ret
seq_ld2ops_fm:
	pop	hl

	ld	a,(hl)
	push	hl
	ld	hl, S_OPL3_TABLE
	call	get_table

	ld	(ix + IDX_TADR), l
	ld	(ix + IDX_TADR+1), h

	; Set 2OP tone to FM
	call	moon_set_fmtone2

	pop	hl
	inc	hl
	ret


; cmd $E4 : tvp
seq_tvp:
	pop	hl
	ld	a, (hl)
	and	7
	rrca
	rrca
	rrca
	ld	e, a
	ld	a, (seq_reg_bd)
	and	1fh
	or	e

	ld	(seq_reg_bd), a
	ld	e, a
	ld	d, 0bdh
	call	moon_fm1_out

	inc	hl
	ret

; cmd $E3 : fb
seq_fbs:
	pop	hl
	ld	a, (hl)
	and	7
	rlca
	rlca
	ld	e, a
	ld	a,(ix + IDX_SYNTH)
	and	0e3h
	or	e
	ld	(ix + IDX_SYNTH),a
	inc	hl
	ret

; cmd $E2 : set jump flag
seq_jump:
	pop	hl
	ld	a, (hl)
	ld (seq_jump_flag), a
	inc	hl
	ret
;-------------------------------------------------------------------
; pause_venv
; dest : AF
;-------------------------------------------------------------------
pause_venv:
	xor	a
	ld	(ix + IDX_VENV_ADR), a
	ld	(ix + IDX_VENV_ADR+1), a
	ret
;-------------------------------------------------------------------
; read_effect_table
; in   : A  = index
;      : HL = table address 
;      : DE = pointer to value in work
; out  : (ix + de) = (HL + 2A)
; dest : AF
;-------------------------------------------------------------------
read_effect_table:
	push	ix
	add	ix, de
	call	get_table

	ld	(ix), l
	ld	(ix+1), h
	pop	ix
	ret
;-------------------------------------------------------------------
; set_venv_loop
; dest : AF,DE
;-------------------------------------------------------------------
set_venv_loop:
	push	hl
	ld	hl, S_VENV_LOOP
	jr	set_venv_hl
;-------------------------------------------------------------------
; set_venv_head
; dest : AF,DE
;-------------------------------------------------------------------
set_venv_head:
	push	hl
	ld	hl, S_VENV_TABLE
set_venv_hl:
	ld	de, IDX_VENV_ADR
	ld	a, (ix + IDX_VENV)
	and	7fh
	call	read_effect_table
	pop	hl
	ret
;-------------------------------------------------------------------
; set_penv_loop
; dest : AF, DE
;-------------------------------------------------------------------
set_penv_loop:
	push	hl
	ld	hl, S_PENV_LOOP
	jr	set_penv_hl
;-------------------------------------------------------------------
; set_penv_head
; dest : AF, DE
;-------------------------------------------------------------------
set_penv_head:
	push	hl
	ld	hl, S_PENV_TABLE
set_penv_hl:
	ld	de, IDX_PENV_ADR
	ld	a, (ix + IDX_PENV)
	call	read_effect_table
	pop	hl
	ret
;-------------------------------------------------------------------
; set_nenv_loop
; dest : AF, DE
;-------------------------------------------------------------------
set_nenv_loop:
	push	hl
	ld	hl, S_NENV_LOOP
	jr	set_nenv_hl
;-------------------------------------------------------------------
; set_nenv_head
; dest : AF, DE
;-------------------------------------------------------------------
set_nenv_head:
	push	hl
	ld	hl, S_NENV_TABLE
set_nenv_hl:
	ld	de, IDX_NENV_ADR
	ld	a, (ix + IDX_NENV)
	call	read_effect_table
	pop	hl
	ret
;-------------------------------------------------------------------
; conv_data_to_midi
; Converts data to midi note
; in   : A = data ($40 = o4c)
; out  : A = midi note
; dest : AF,DE
;-------------------------------------------------------------------
conv_data_to_midi:
	ld	d,0
	ld	e,a

	rrca
	rrca
	rrca
	rrca
	and	0fh
	ld	d,a
	jr	z,skip_conv_midi_lp
	xor	a
conv_midi_lp:
	add	a,0ch
	dec	d
	jr	nz,conv_midi_lp
skip_conv_midi_lp:
	ld	d,a
	ld	a,e
	and	0fh
	add	a,d
	add	a,0ch
	ret
;-------------------------------------------------------------------
; oct_div
; octave divider
; in   : H = pitch / 0x100
; out  : L = octave
; dest : AF
;-------------------------------------------------------------------
oct_div:
	ld	a,h
	ld	l,0

oct_div_lp:
	add	a,0fah
	ret	nc
	inc	l
	jr	oct_div_lp
;-------------------------------------------------------------------
; make_fnum
; Make F-number from pitch
; F-num = pitch / $600
; in   : HL = pitch
; out  : HL = f-num
; dest : AF, DE
;-------------------------------------------------------------------
make_fnum:
	ld	de, $fa00
make_fnum_lp:
	add	hl, de
	jr	c, make_fnum_lp
	ld	de, 0600h
	add	hl, de

	ex	de,hl

	ld	hl, freq_table
	add	hl, de
	add	hl, de

	ld	a, (hl)
	inc	hl
	ld	h, (hl)
	ld	l, a

	ret
;-------------------------------------------------------------------
; moon_set_fmtone2
; load and set 2 oprators from data in table
; in   : work
; dest : DE
;-------------------------------------------------------------------
moon_set_fmtone2:
	push	af
	push	bc
	push	hl

	ld	c, 2

	jr	moon_set_fmtone_start_lp
;-------------------------------------------------------------------
; moon_set_fmtone
; load and set 4 oprators from data in table
; in   : work
; dest : DE
;-------------------------------------------------------------------
moon_set_fmtone:
	push	af
	push	bc
	push	hl

	ld	c,4

moon_set_fmtone_start_lp:
	ld	l, (ix + IDX_TADR)
	ld	h, (ix + IDX_TADR+1)

	ld	a, (ix + IDX_OPSEL)
	ld	(seq_opsel), a

	; FBS   store to IDX_SYNTH( OxxFFFSS )
	ld	a, (hl)
	and	0eh 
	rlca
	ld	e, a
	ld	a, (hl)
	and	1
	or	e
	ld	e, a
	inc	hl

	ld	a, (ix + IDX_SYNTH)
	and	0e2h
	or	e
	ld	(ix + IDX_SYNTH), a ; xxxFFFxS

	ld	a, c
	cp	4
	jr	nz, fmtone_skip_set_fbs2

	; FBS-2  Store SynthType for 4OP
	ld	a, (hl)
	and	1
	rlca
	or	80h    ; 4OP flag
	ld	e, a
	
	ld	a, (ix + IDX_SYNTH)
	and	7dh    ; mask for 4OP and 2nd SynthType
	or	e
	ld	(ix + IDX_SYNTH), a ; OxxFFFSS 
	inc	hl

	jr	fmtone_set_tvp

fmtone_skip_set_fbs2:
	ld	a, (ix + IDX_SYNTH)
	and	7fh
	ld	(ix + IDX_SYNTH), a
	inc	hl

fmtone_set_tvp:
	; TYP in W/WX is removed
	inc	hl
	call	moon_load_fmvol

moon_set_fmtone_lp1:
	call	moon_set_fmop
	ld	a, (seq_opsel)
	add	a,3
	ld	(seq_opsel), a

	dec	c
	jr	nz, moon_set_fmtone_lp1
	
	call moon_write_fmpan

	pop	hl
	pop	bc
	pop	af
	ret

moon_load_fmvol:
	push	hl
	push	bc
	push	ix
	inc	hl ; skip Reg.$20
	ld	de, 5
moon_load_fmvol_lp:
	ld	a, (hl)
	ld	(ix + IDX_OLDAT1), a
	inc	ix
	add	hl, de
	dec	c
	jr	nz, moon_load_fmvol_lp

	pop	ix
	pop	bc
	pop	hl
	ret

moon_set_fmop:
	ld	a, (hl)
	ld	e, a
	ld	d, 20h
	call	moon_write_fmop
	inc	hl
	ld	a, (hl)
	ld	e, a
	ld	d, 40h
	call	moon_write_fmop  ; OL
	inc	hl
	ld	a, (hl)
	ld	e, a
	ld	d, 60h
	call	moon_write_fmop
	inc	hl
	ld	a, (hl)
	ld	e, a
	ld	d, 80h
	call	moon_write_fmop
	inc	hl
	ld	a, (hl)
	ld	e, a
	ld	d, 0e0h
	call	moon_write_fmop
	inc	hl
	ret
;-------------------------------------------------------------------
; moon_tonesel
; Select tone number from table ( OPL4 )
; in   : work
; dest : flags, HL
;-------------------------------------------------------------------
moon_tonesel:
	ld	l,(ix + IDX_TADR)
	ld	h,(ix + IDX_TADR+1)
tonesel_lp01:
	push	af
	push	hl
	ld	a,(hl)
	inc	hl
	or	(hl)
	jr	z,tonesel_fin ; if min == 0 && max == 0
	pop	hl
	pop	af

	cp	(hl)
	jr	c,tonesel_skip01    ; if a < (hl)
	inc	hl
	cp	(hl)
	jr	c,tonesel_loadtone  ; if a < (hl)
	jr	z,tonesel_loadtone  ; if a == (hl)
	jr	tonesel_skip02

tonesel_fin:
	pop	hl
	pop	af
	ret

tonesel_skip01:
	inc	hl
tonesel_skip02:
	push	de
	ld	de,000ah
	add	hl,de
	pop	de

	jr	tonesel_lp01

tonesel_loadtone:
	push	af
	inc	hl
	ld	a,(hl)
	ld	(ix + IDX_TONE),a
	inc	hl
	ld	a,(hl)
	ld	(ix + IDX_TONE+1),a
	inc	hl
	ld	a,(hl)
	ld	(ix + IDX_P_OFS),a
	inc	hl
	ld	a,(hl)
	ld	(ix + IDX_P_OFS+1),a

	inc	hl
	ld	a,(hl)
	ld	(ix + IDX_LFO_VIB),a
	inc	hl
	ld	a,(hl)
	ld	(ix + IDX_AR_D1R),a
	inc	hl
	ld	a,(hl)
	ld	(ix + IDX_DL_D2R),a
	inc	hl
	ld	a,(hl)
	ld	(ix + IDX_RC_RR),a
	inc	hl
	ld	a,(hl)
	ld	(ix + IDX_AM),a

	pop	af
	ret
;-------------------------------------------------------------------
; moon_calc_opl4freq
; in   : HL = pitch
; dest : AF,HL
;-------------------------------------------------------------------
moon_calc_opl4freq:
	push	hl
	call	oct_div
	ld	a,l
	add	a,0f8h
	ld	(ix + IDX_OCT),a
	pop	hl

	call	make_fnum

	ld	(ix + IDX_FNUM),l
	ld	(ix + IDX_FNUM+1),h
	ret
;-------------------------------------------------------------------
; moon_calc_midinote
; calclulates freq from note
; in   : A = note ( 04c = 0x3c )
; out  : work
; dest : AF,DE
;-------------------------------------------------------------------
moon_calc_midinote:
	add	a,0c4h	; a -= $3c

	ld	l,0
	srl	a
	ld	h,a
	rr	l
	and	40h
	jr	z,skip_set_nega ; if a >= $80 then it's negative 
	ld	a,h
	or	80h
	ld	h,a
skip_set_nega:
	ld	de,1e00h ; 7680
	add	hl,de
	ld	e,(ix + IDX_P_OFS)
	ld	d,(ix + IDX_P_OFS+1)
	add	hl,de

	ld	a,(ix + IDX_DETUNE)
	call	add_freq_offset

skip_detune:
	ld	a,h
	cp	60h
	jr	c,skip_set_pitch ; if a < $60
	ld	hl,5fffh
skip_set_pitch:
	ld	(ix + IDX_PITCH),l
	ld	(ix + IDX_PITCH + 1),h
	ret
;-------------------------------------------------------------------
; add_freq_offset
; HL = HL + VALUE
; in : A ( detune data )
; dest : DE
;-------------------------------------------------------------------
add_freq_offset:

	cp	0ffh
	ret	z
	
	bit	7,a
	jr	nz,add_freq_nega
	
	ld	e,a
	ld	d,0
	jr	add_freq_de

add_freq_nega:
	and	7fh
	ld	d,0
	ld	e,a
	xor	a
	sub	e
	jr	nc,add_freq_de
	dec	d
add_freq_de:
	ld	e,a
	add	hl,de
	add	hl,de
	ret
;-------------------------------------------------------------------
; moon_set_midinote
; in : A = note
;
;-------------------------------------------------------------------
moon_set_midinote:
	bit	0,(ix + IDX_EFX1)
	call	z,moon_tonesel
	call	moon_calc_midinote
	jp	moon_calc_opl4freq
;-------------------------------------------------------------------
; moon_set_fmnote
; in   : A = note
; dest : AF, HL, BC
;-------------------------------------------------------------------
moon_set_fmnote:
	call	moon_calc_opl3note

	; oct
	ld	a, (seq_tmp_oct)
	ld	(ix + IDX_OCT), a

	; Fnum
	ld	hl, (seq_tmp_fnum)
	ld	(ix + IDX_FNUM), l
	ld	(ix + IDX_FNUM+1), h
	ret
;-------------------------------------------------------------------
; moon_calc_opl3note
; in : A = note , (ix + IDX_DETUNE)
; out : (seq_tmp_fnum), (seq_tmp_oct)
; dest AF, BC, HL
;-------------------------------------------------------------------
moon_calc_opl3note:
	push	af
	and	0fh
	cp	0ch
	jr	c, fm_load_fnumtbl
	sub	0ch
fm_load_fnumtbl:
	ld	hl, fm_fnumtbl
	ld	c, a
	ld	b, 0
	add	hl, bc
	add	hl, bc
	ld	a, (hl)
	ld	(seq_tmp_fnum), a
	inc	hl
	ld	a, (hl)
	ld	(seq_tmp_fnum + 1), a
	pop	af
	rra
	rra
	rra
	rra
	and	0fh
	ld	(seq_tmp_oct), a

	; Add detune effect
	ld	hl, (seq_tmp_fnum)	

	ld	a, (ix + IDX_DETUNE)
	call	add_freq_offset

	ld	(seq_tmp_fnum), hl

	ret
;-------------------------------------------------------------------
; moon_write_fmop
; Write an OPL3 reg for op
; (opsel)
; in   : seq_opsel, D = addr, E = data
; dest : AF, DE
;-------------------------------------------------------------------
moon_write_fmop:
	push	hl
	ld	a, (seq_opsel)
	cp	12h
	jr	c,skip_sub_a
	sub	12h
skip_sub_a:
	ld	hl, fm_op2reg_tbl ; HL = HL + A
	add	a,l
	ld	l,a
	jr	nc,add_hl_fin
	inc	h
add_hl_fin:
	ld	a,(hl)
	add	a,d
	ld	d,a
	pop	hl

	ld	a,(seq_opsel)
	cp	12h
	jr	c,moon_write_fmop_1
	jp	moon_fm2_out
moon_write_fmop_1:
	jp	moon_fm1_out
;-------------------------------------------------------------------
; moon_write_fmreg
; moon_write_fmreg_ch
; Write to OPL3 register 
; in : D = addr, E = data
; dest : AF, DE
;-------------------------------------------------------------------
moon_write_fmreg:
	ld	a, (seq_cur_ch)
	jr	moon_write_fmreg_nch

; A = ch
moon_write_fmreg_nch:
	push	de
	ld	e, a
	ld	a, (seq_start_fm)
	ld	d, a
	ld	a, e
	sub	d ; a = ch, d = start_fm
	pop	de
	jr moon_write_fm_ch

; Write fm ( A = ch )
moon_write_fm_ch:
; first or second FM register
	cp	9
	jr	c, moon_write_fm1

; second register
	sub	9
	add	a, d
	ld	d, a
	jp	moon_fm2_out

; first register
moon_write_fm1:
	add	a, d
	ld	d, a
	jp	moon_fm1_out
;-------------------------------------------------------------------
; wait while BUSY
; dest : AF
;-------------------------------------------------------------------
moon_wait:
	in	a, (MOON_STAT)
	and	1
	jr	nz, moon_wait
	ret
;-------------------------------------------------------------------
; write moonsound fm1 register
; in   : D = an address of register , E = data
; dest : AF
;-------------------------------------------------------------------
moon_fm1_out:
	; call	moon_wait
	ld	a, d
	out	(MOON_REG1), a
	; call	moon_wait
	ld	a, e
	out	(MOON_DAT1), a
	ret
;-------------------------------------------------------------------
; «апись в fm2 регистр MoonSound 
; ¬ходные данные: D = номер регистра , 
;		  E = данные
; ¬ыходные данные : нет
;-------------------------------------------------------------------
moon_fm2_out:
	; call	moon_wait
	ld	a,d
	out	(MOON_REG2), a
	; call	moon_wait
	ld	a,e
	out	(MOON_DAT2), a
	ret
;-------------------------------------------------------------------
; «апись в wave регистр MoonSound 
; ¬ходные данные: D = номер регистра , 
;		  E = данные
; ¬ыходные данные : нет
;-------------------------------------------------------------------
moon_wave_out:
	; call	moon_wait
	ld	a, d
	out	(MOON_WREG),a
	; call	moon_wait
	ld	a, e
	out	(MOON_WDAT),a
	ret
;-------------------------------------------------------------------
; add number of channel to the index of register
; in : D = index of register
; dest : AF
;-------------------------------------------------------------------
moon_add_reg_ch:
	ld	a, (seq_cur_ch)
	add	a, d
	ld	d, a
	ret
;-------------------------------------------------------------------
; set frequency on the channel
; in   : work
; dest : AF,DE
;-------------------------------------------------------------------
moon_set_freq_ch:
	ld	a, (ix + IDX_DSEL)
	or	a
	ret	nz

set_freq_ch_opl4:
	; ocatve and f-number(hi)
	ld	a, (ix + IDX_FNUM + 1)
	rlca
	and	0eh
	ld	e,a
	ld	a, (ix + IDX_FNUM)
	rlca
	and	1
	or	e
	ld	e,a

	ld	a, (ix + IDX_OCT)
	and	0fh
	rlca
	rlca
	rlca
	rlca
	or	e
	ld	e, a

	ld	a, (ix + IDX_REVERB)
	or	a
	jr	z, moon_set_freq_ch_skip_reverb
	set	3, e
moon_set_freq_ch_skip_reverb:

	ld	d, 38h
	call	moon_add_reg_ch
	call	moon_wave_out

	; f-number(lo)
	ld	a, (ix + IDX_TONE+1)
	and	1
	ld	e,a

	ld	a, (ix + IDX_FNUM)
	rlca
	and	0feh
	or	e
	ld	e, a

	ld	d, 20h
	call	moon_add_reg_ch
	jp	moon_wave_out
;-------------------------------------------------------------------
; set volume on the channel
; in   : work
; dest : AF,DE
;-------------------------------------------------------------------
moon_set_vol_ch:
	ld	a, (ix + IDX_DSEL)
	or	a
	jr	nz, moon_set_fmvol_ch

	; volume ( 0x7f = -inf )
	ld	a, (ix + IDX_VOL)
	xor	7fh
	rlca
	or	1
	ld	e, a
	ld	d, 50h
	call	moon_add_reg_ch
	jp	moon_wave_out

moon_set_fmvol_ch:
	push	ix
	push	hl
	push	bc

	ld	a, (ix + IDX_OPSEL)
	ld	(seq_opsel), a

	ld	b, (ix + IDX_VOL)

	ld	h, (ix + IDX_VOLOP)

	ld	c, 2
	ld	a, (ix + IDX_SYNTH)
	and	80h
	jr	z,moon_set_fmvol_lp ; 4OP check
	ld	c,4
moon_set_fmvol_lp
	rr	h
	jr	nc, skip_set_fmvol
	call	moon_calc_current_fmvol
	ld	e, a
	ld	d, 40h
	call	moon_write_fmop
skip_set_fmvol:
	inc	ix
	ld	a, (seq_opsel)
	add	a, 3
	ld	(seq_opsel), a

	dec	c
	jr	nz, moon_set_fmvol_lp

	pop	bc
	pop	hl
	pop	ix
	ret

moon_calc_current_fmvol:
	; A = (OL + (63-VOL))
	ld	a,b
	and	3fh
	xor	3fh
	ld	e,a

	ld	a, (ix + IDX_OLDAT1)
	and	3fh
	add	a, e
	cp	40h
	jr	nc, set_fmvol_min
	ld	e, a
	jr	set_fmvol_ks
set_fmvol_min:
	ld	e, 3fh
set_fmvol_ks:
	ld	a, (ix + IDX_OLDAT1)
	and	0c0h
	or	e
	ret
;-------------------------------------------------------------------
; set ADSR regs
; in   : work
; dest : AF,DE
;-------------------------------------------------------------------
moon_set_adsr:
	ld	e, (ix + IDX_LFO_VIB)
	ld	d, 80h
	call	moon_add_reg_ch
	call	moon_wave_out
	ld	e, (ix + IDX_AR_D1R)
	ld	d, 98h
	call	moon_add_reg_ch
	call	moon_wave_out
	ld	e, (ix + IDX_DL_D2R)
	ld	d, 0B0h
	call	moon_add_reg_ch
	call	moon_wave_out
	ld	e, (ix + IDX_RC_RR)
	ld	d, 0C8h
	call	moon_add_reg_ch
	call	moon_wave_out
	ld	e, (ix + IDX_AM)
	ld	d, 0E0h
	call	moon_add_reg_ch
	jp	moon_wave_out
;-------------------------------------------------------------------
; moon_key_data
; make data for key-on/off
; in   : work
; out  : E = data for key
; dest : almost all
;-------------------------------------------------------------------
moon_key_data:
	ld	a, (ix + IDX_PAN)
	and	0fh

;;	or	$10 ; PCM-MIX

	ld	e,a
	ld	a,(ix + IDX_LFO)
	or	a
	jr	nz,moon_key_data_lfo_on
	set	5,e  ; LFO deactive
moon_key_data_lfo_on:
	ld	a,(ix + IDX_DAMP)
	or	a
	jr	z,moon_key_data_damp_off
	set	6,e  ; Damp on
moon_key_data_damp_off:
	ret
;-------------------------------------------------------------------
; moon_key_off
; this function does : key-off
; in   : work
; dest : almost all
;-------------------------------------------------------------------
moon_key_off:
	; key off

	ld	a,(ix + IDX_DSEL)
	or	a
	jr	z,moon_key_opl4off

moon_key_fmoff:
	ld	a,(ix + IDX_KEY)
	and	20h
	ret	z
	ld	a,(ix + IDX_KEY)
	and	0dfh
	ld	e,a
	ld	d,0b0h
	ld	(ix + IDX_KEY),e
	
	; skip if jump flag is true
	ld	a, (seq_jump_flag)
	or	a
	ret nz
	
	jp	moon_write_fmreg ; key-off

moon_key_opl4off:
	ld	a,(ix + IDX_KEY)
	and	80h
	ret	z
	ld	a,(ix + IDX_KEY)
	and	7fh
	ld	e,a
	ld	d,68h
	ld	(ix + IDX_KEY),e
	call	moon_add_reg_ch
	jp	moon_wave_out ; key-off
;-------------------------------------------------------------------
; moon_write_fmpan
; calc and write Reg $Cx
; dest AF, DE
;-------------------------------------------------------------------
moon_write_fmpan:
	ld	a, (ix + IDX_SYNTH)
	ld	d, a
	and	1ch ; 000FFF00
	rrca
	ld	e, a
	ld	a, d
	and	1 ; SynthType
	or	e
	or	(ix + IDX_PAN)
	
	; E -> $C0
	ld	e,a
	ld	d,0c0h
	call moon_write_fmreg

	; 4OP
	ld	a, (ix + IDX_SYNTH)
	ld	d, a
	and	80h
	
	; skip if not 4op
	jr	z, moon_write_fmpan_4op_fin 
	
	ld	a, d
	rrca
	and	1 ; 2nd SynthType
	or	(ix + IDX_PAN)
	ld	e, a
	ld	d, 0c0h

	; E -> $C0 + 3 + ch 
	ld	a, (seq_cur_ch)
	add	a, 3
	jp	moon_write_fmreg_nch

moon_write_fmpan_4op_fin:
	ret
;-------------------------------------------------------------------
; moon_key_on
; Set tone number, frequency and key-on
; in   : work
; dest : almost all
;-------------------------------------------------------------------
moon_key_on:

	ld	a,(ix + IDX_DSEL)
	or	a
	jr	z,moon_key_opl4on

moon_key_fmon:
	bit	0, (ix + IDX_EFX1)
	jr	nz,slar_fm_on

	call	moon_key_off
	call	start_venv
	call	start_penv
	call	start_nenv

slar_fm_on:
	res	0, (ix + IDX_EFX1)
	call	moon_key_write_fmfreq
	or	20h ; key on
	ld	e, a
	ld	d, 0b0h
	ld	(ix + IDX_KEY), e
	
	; skip if jump flag is true
	ld	a, (seq_jump_flag)
	or	a
	ret nz

	jp	moon_write_fmreg ; key-on


moon_key_opl4on:
	bit	0,(ix + IDX_EFX1)
	jr	nz,slar_opl4_on

	call	moon_key_off
	call	start_venv
	call	start_penv
	call	start_nenv


	; tone number(hi)
	ld	a,(ix + IDX_TONE+1)
	and	1
	ld	e,a
	ld	d,20h
	call	moon_add_reg_ch
	call	moon_wave_out

	; tone number(lo)
	ld	e,(ix + IDX_TONE)
	ld	d,8
	call	moon_add_reg_ch
	call	moon_wave_out

moon_wavechg_lp:
	in	a, (MOON_STAT)
	and	2
	jr	nz,moon_wavechg_lp

	call	moon_set_freq_ch
	call	moon_set_vol_ch
	call	moon_set_adsr

moon_opl4_set_keyreg:
	; OPL4 key-on
	; skip if jump flag is true
	ld	a, (seq_jump_flag)
	or	a
	ret nz

	call	moon_key_data
	ld	a,e
	or	80h ; key-on
	ld	e,a
	ld	d,68h
	ld	(ix + IDX_KEY),e

	call	moon_add_reg_ch
	jp	moon_wave_out ; key-on

slar_opl4_on:
	res	0,(ix + IDX_EFX1)
	jp	moon_set_freq_ch
;-------------------------------------------------------------------
; moon_key_write_fmfreq
; calculates and writes related FM frequency
; out : A = Reg.$B0 ( FnumH + BLK )
; dest : almost all
;-------------------------------------------------------------------
moon_key_write_fmfreq:
	ld	a, (seq_cur_ch)
	ld	(seq_tmp_ch), a

	ld	a, (ix + IDX_OCT)
	ld	(seq_tmp_oct), a
	
	ld	l, (ix + IDX_FNUM)
	ld	h, (ix + IDX_FNUM + 1)
	ld	(seq_tmp_fnum), hl

moon_key_write_fmfreq_base:
	ld	a, (seq_tmp_fnum)
	ld	e, a
	ld	d, 0a0h
	ld	a, (seq_tmp_ch)
	call	moon_write_fmreg_nch

	ld	a, (seq_tmp_fnum + 1)
	and	3
	ld	e, a

	ld	a, (seq_tmp_oct)
	rlca
	rlca
	and	1ch ; mask for Octave
	or	e   ; F-Number
	ret
;-------------------------------------------------------------------
; moon_key_fmfreq
; calculates and writes related regs with keeping key
;-------------------------------------------------------------------
moon_key_fmfreq:
	call	moon_key_write_fmfreq
	ld	e,a
	ld	a, (ix + IDX_KEY)
	and	20h
	or	e

	ld	(ix + IDX_KEY), a
	ld	e, a
	ld	d, 0b0h
	
	; skip if jump flag is true
	ld	a, (seq_jump_flag)
	or	a
	ret nz

	jp	moon_write_fmreg ; key-on


;-------------------------------------------------------------------
; описание: “аблица частот
;---------------------------------------------------------------------
freq_table:
	.include	"ftbl600.inc"


