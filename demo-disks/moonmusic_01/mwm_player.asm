;--------------------------------------------------------------------
; Описание: Проигрывающий модуль музыкальных файлов MWM c компьютера MSX
; Автор порта: Тарасов М.Н.(Mick),2015
;--------------------------------------------------------------------
MOON_BASE:	equ	0C4h
MOON_REG1:	equ	MOON_BASE
MOON_DAT1:	equ	MOON_BASE+1
MOON_REG2:	equ	MOON_BASE+2
MOON_DAT2:	equ	MOON_BASE+3
MOON_STAT:	equ	MOON_BASE

MOON_WREG:	equ	7Eh
MOON_WDAT:	equ	MOON_WREG+1

PTW_SIZE:	equ	20	; size of Wave playtable line
WAVCHNS:	equ	24

;-------------------------------------------------------------------
; описание: Инициализация проигрывателя
; параметры: нет
; возвращаемое  значение: нет
;---------------------------------------------------------------------
MBPlayer_init:
		jp	MBPlayer_start_music
;-------------------------------------------------------------------
; описание: Проигрывание ноты
; параметры: нет
; возвращаемое  значение: нет
;---------------------------------------------------------------------
MBPlayer_play:
		jp	MBPlayer_play_music
;-------------------------------------------------------------------
; описание: Остановка проигрывания
; параметры: нет
; возвращаемое  значение: нет
;---------------------------------------------------------------------
MBPlayer_stop:
		jp	MBPlayer_stop_music
;-------------------------------------------------------------------
; описание: Установка тишины в звуковой чип
; параметры: нет
; возвращаемое  значение: нет
;---------------------------------------------------------------------
MBPlayer_fade:
		jp	MBPlayer_fade_music
;-------------------------------------------------------------------
; описание: Инициализация проигрывателя
; параметры: нет
; возвращаемое  значение: нет
;---------------------------------------------------------------------
MBPlayer_start_music:
		di	
		ld	a, (MBPlayer_play_busy)
		or	a
		ret	nz				; already playing?

		ld	a, 0FFh
		ld	(MBPlayer_play_busy), a 	; set busy playing

		xor	a
		ld	(MBPlayer_play_intcnt), a
		ld	a, 15
		ld	(MBPlayer_play_step), a 	; set step and position
		ld	a, 0FFh
		ld	(MBPlayer_play_pos), a

;		call	MBPlayer_getbank_FE
;		ld	(MBPlayer_save_curbank), a

;		ld	a, (MBPlayer_songdata_bank1)
;		call	MBPlayer_selbank_FE

		ld	hl, (MBPlayer_songdata_addres)
		ld	de, MBPlayer_xleng
		ld	bc, 220
		ldir	
		ld	de, 58
		add	hl, de
		ld	(MBPlayer_pos_address), hl
		ld	a, (MBPlayer_xleng)
		inc	a
		ld	e, a
		add	hl, de
		ld	(MBPlayer_pat_address), hl

;		ld	a, (MBPlayer_save_curbank)
;		call	MBPlayer_selbank_FE

		call	MBPlayer_init_opl4 		;initialise OPL4
		call	MBPlayer_init_voices
		ld	a, (MBPlayer_xtempo)
		ld	(MBPlayer_play_speed), a
		ld	a, (MBPlayer_play_speed)
		sub	3
		ld	(MBPlayer_play_timercnt), a
		xor	a
		ld	(MBPlayer_play_tspval), a
		ld	(MBPlayer_play_fading), a
		ld	(MBPlayer_play_fadecnt), a
		ld	(MBPlayer_play_fadetcnt), a

loc_0_4378:
		ld	a,2
		out	(MOON_REG1),a
		ld	a,(MBPlayer_xhzequal)
		or	a
		jr	z,Speed60Hz
		cp	1
		jr	nz,Speedxhz
		ld	a,248
		jr	Speedxhz
Speed60Hz:
		ld	a,208
Speedxhz:
		neg
		out	(MOON_DAT1),a
		nop
		ld	a,4
		out	(MOON_REG1),a
		nop
		ld	a,00100001b
		out	(MOON_DAT1),a

;		di	
;		ld	hl, 0FD9Fh
;		ld	de, locret_0_455C
;		ld	bc, 5
;		ldir	
;		ld	a, 0C3h	; 'Г'
;		ld	(0FD9Fh), a
;		ld	hl, MBPlayer_play_music
;		ld	(0FDA0h), hl
;		ei	
		ret	
;-------------------------------------------------------------------
; описание: Инициализация OPL4 регистров
; параметры: нет
; возвращаемое  значение: нет
;---------------------------------------------------------------------
MBPlayer_init_opl4:
		ld	a, 3
		ld	c, 5
		call	sub_0_4A3F
		ld	c, 2
		ld	a, 10h
		jp	MBPlayer_out_wave
;-------------------------------------------------------------------
; описание: Инициализация OPL4 каналов
; параметры: нет
; возвращаемое  значение: нет
;---------------------------------------------------------------------
MBPlayer_init_voices:
		ld	b, WAVCHNS			; # wave channels
		ld	iy, MBPlayer_play_table_wav
		ld	ix, MBPlayer_xbegwav
		ld	de, PTW_SIZE
loc_0_43AC:
		push	de
		push	bc
		ld	a,(ix - 48h)			; xdetune!
		add	a, a
		ld	(iy + 5), a			; detune!
		ld	a, (ix + 0)                     ; wave/patchnr
		push	af
		call	MBPlayer_play_wwavevt2
		pop	af
		ld	hl, MBPlayer_xwavvols - 1
		add	a, l
		jr	nc, loc_0_43C4
		inc	h

loc_0_43C4:
		ld	l, a
		ld	a, (hl)
		ld	(iy + 0Fh), a
		call	MBPlayer_play_wchgvol2
		ld	a, (ix - 62h)
		call	MBPlayer_play_wchgste2
		inc	ix
		pop	bc
		pop	de
		add	iy, de
		djnz	loc_0_43AC
		ret	

loc_0_43DB:
		ld	a, (MBPlayer_play_busy)
		or	a
		ret	nz
		dec	a
		ld	(MBPlayer_play_busy), a
		jp	loc_0_4378
;-------------------------------------------------------------------
; описание: Остановка проигрывания
; параметры: нет
; возвращаемое  значение: нет
;---------------------------------------------------------------------
MBPlayer_stop_music:
;		ld	a, (MBPlayer_play_busy)
;		or	a
;		ret	z

		di	
		xor	a
		ld	(MBPlayer_play_busy), a

;		ld	hl, locret_0_455C
;		ld	de, 0FD9Fh
;		ld	bc, 5
;		ldir	
		ld	b, WAVCHNS			; # wave channels
		ld	iy, MBPlayer_play_table_wav
		ld	de, PTW_SIZE

loc_0_4405:
		call	MBPlayer_play_woffevt
		call	MBPlayer_play_wchgdmp
		add	iy, de
		djnz	loc_0_4405
		ei	
		ret	
;-------------------------------------------------------------------
; описание: Установка затухания
; параметры: B - скорость затухания
; возвращаемое  значение: нет
;---------------------------------------------------------------------
MBPlayer_fade_music:
		ld	b, a
		ld	a, (MBPlayer_play_busy)		; already stopped?
		or	a
		ret	z
		ld	a, 255
		ld	(MBPlayer_play_fading), a 	; fading on
		ld	a, b
		ld	(MBPlayer_play_fadespd), a      ; set fade speed
		ret	
;-------------------------------------------------------------------
; описание: Проигрывание музыки по прерываниям
; параметры: нет
; возвращаемое  значение: нет
;---------------------------------------------------------------------
MBPlayer_play_music:
		di	
;		ld	a, (MBPlayer_xhzequal)
;		or	a
;		jr	z, loc_0_443E

;		ld	a, (0FFE8h)
;		and	2
;		jr	nz, loc_0_443E

;		ld	hl, MBPlayer_play_intcnt
;		ld	a, (hl)
;		inc	a
;		cp	6
;		jr	c, loc_0_443D
;		ld	(hl), 0
;		jp	locret_0_455C
;
;loc_0_443D:
;		ld	(hl), a

loc_0_443E:
		call	MBPlayer_play_pitch

		ld	a, (MBPlayer_play_fading)
		or	a
		jr	z, loc_0_4451
		call	MBPlayer_play_fade
		ld	a, (MBPlayer_play_fading)
		or	a
		jp	z, locret_0_455C

loc_0_4451:
;		call	MBPlayer_getbank_FE
;		ld	(MBPlayer_save_curbank), a

		ld	a, (MBPlayer_play_speed) 	; speed
		ld	hl, MBPlayer_play_timercnt
		inc	(hl)
		cp	(hl)
		jp	nz, MBPlayer_play_int_sec	; almost there?
		ld	(hl), 0

		ld	iy, unk_0_4E30
		ld	hl, unk_0_4B98
		ld	bc, 860h
		ld	de, PTW_SIZE

loc_0_4471:
		ld	a, (hl)
		dec	a
		cp	c
		call	c, MBPlayer_calc_wave
		add	iy, de
		inc	hl
		djnz	loc_0_4471

;		ld	a, (MBPlayer_songdata_bank)
;		call	MBPlayer_selbank_FE

		ld	hl, MBPlayer_step_buffer        ;WAVE Event routines
		ld	b, WAVCHNS			; # channels
		ld	iy, MBPlayer_play_table_wav
		ld	de, PTW_SIZE
		ld	c, 96

loc_0_4490:
		ld	a, (hl)
		dec	a
		cp	c
		jp	nc, loc_0_44D3
		ld	a, 67h
		add	a, b 				; calc. register
		out	(MOON_WREG), a
		xor	a
loc_0_449C:
		push	bc
		pop	bc
		out	(MOON_WDAT), a			; off

		ld	a, 1Fh
		add	a, b
loc_0_44A3:
		push	bc
		pop	bc
		out	(MOON_WREG), a
		ld	a, (iy + 8)
		ld	(iy + 12h), a
		or	(iy + 6)
loc_0_44B0:
		push	bc
		pop	bc
		out	(MOON_WDAT), a			; freq + tone

		ld	a, 7
		add	a, b
loc_0_44B7:
		push	bc
		pop	bc
		out	(MOON_WREG), a
		ld	a, (iy + 7)
loc_0_44BE:
		push	bc
		pop	bc
		out	(MOON_WDAT), a 			; tone

		ld	a, 37h
		add	a, b
loc_0_44C5:
		push	bc
		pop	bc
		out	(MOON_WREG), a
		ld	a, (iy + 9)
		ld	(iy + 13h), a
loc_0_44CF:
		push	bc
		pop	bc
		out	(MOON_WDAT), a
loc_0_44D3:
		inc	hl
		add	iy, de
		djnz	loc_0_4490

		ld	hl, MBPlayer_step_buffer		; songdata-adres 
		ld	ix, MBPlayer_volume_buffer_1
		ld	iy, MBPlayer_play_table_wav
		ld	b,WAVCHNS
		ld	de,PTW_SIZE
loc_0_44E4:
		in	a, (MOON_STAT)
		and	2
		jr	nz, loc_0_44E4

MBPlayer_play_int_wlus:
		xor	a
		ld	(ix + 0), a
		ld	(ix + 18h), a


		ld	a, (hl)
		or	a
		jr	z, MBPlayer_play_int_wend2		; empty

		ex	af, af'
		ld	a, b
		exx	
		ld	b, a
		ex	af, af'

		ld	de, MBPlayer_play_int_wend
		push	de

		cp	97
		jp	c, MBPlayer_play_wonevt		; wave on
		jp	z, MBPlayer_play_woffevt	; wave off 
		cp	146
		jp	c, MBPlayer_play_wwavevt	; wave 
		cp	178
		jp	c, MBPlayer_play_wchgvol	; volume 
		cp	193
		jp	c, MBPlayer_play_wchgste	; stereo 
		cp	212
		jp	c, MBPlayer_play_wlnk		; link 
		cp	231
		jp	c, MBPlayer_play_wchgpit	; pitch bending 
		cp	238
		jp	c, MBPlayer_play_wchgdet	; detune 
		cp	241
		jp	c, MBPlayer_play_wchgmod	; modulation 
		cp	243
		jp	c, MBPlayer_play_wchgdmp	; damp 

MBPlayer_play_int_wend:
		exx	

MBPlayer_play_int_wend2:
;		ld	a, (byte_0_4C6F)
;		or	a
;		jr	z, loc_0_45A6
		ld	a, (ix + 0)
		or	a
		jp	z, loc_0_45A6
		push	hl
		ld	h, a
		ld	l, a
		ld	a, (iy + 0Bh)
		and	0Fh
		jr	z, loc_0_4598
		cp	8
		jr	z, loc_0_4595
		jr	nc, loc_0_457D
		cp	7
		jr	z, loc_0_4590
		add	a, a
		add	a, h
		ld	h, a
		jp	loc_0_4598

loc_0_457D:
		cp	9
		jr	z, loc_0_458B
		neg	
		add	a, 10h
		add	a, a
		add	a, l
		ld	l, a
		jp	loc_0_4598

loc_0_458B:
		ld	l, 0
		jp	loc_0_4598

loc_0_4590:
		ld	h, 0
		jp	loc_0_4598

loc_0_4595:
		ld	hl, 0
loc_0_4598:
		ld	a, h
		rla	
		rla	
		rla	
		rla	
		and	0F0h
		or	l
		jr	z, loc_0_45A5
		ld	(ix + 18h), a
loc_0_45A5:
		pop	hl

loc_0_45A6:
		add	iy, de
		inc	hl
		inc	ix
		dec	b
		jp	nz, MBPlayer_play_int_wlus

		ld	a, (hl)
		or	a
		jr	z, loc_0_4556

		cp	24			
		jp	c, MBPlayer_play_chgtmp         ; change tempo
		jr	z, MBPlayer_play_endop  	; end of pattern
		cp	76
		jp	nc, loc_0_4556
		sub	52				; set transpose
		ld	(MBPlayer_play_tspval), a
		jp	loc_0_4556

MBPlayer_play_endop:
		ld	a, 0Fh
		ld	(MBPlayer_play_step), a
		jp	loc_0_4556

MBPlayer_play_chgtmp:
		add	a, 0E7h				; change tempo
		neg	
		ld	(MBPlayer_play_speed), a
loc_0_4556:
;		ld	a,(MBPlayer_save_curbank)
;		call	MBPlayer_selbank_FE
locret_0_455C:
		ret	
		ret
		ret
		ret
		ret
;-------------------------------------------------------------------
; описание: Interrupt routine BEFORE play-interrupt
; параметры: нет
; возвращаемое  значение: нет
;---------------------------------------------------------------------
MBPlayer_play_int_sec:
		dec	a
		cp	(hl)
		jp	z, loc_0_461F
		dec	a
		cp	(hl)
		jp	nz, loc_0_4556

		ld	a, (MBPlayer_play_step)
		inc	a
		and	0Fh
		ld	(MBPlayer_play_step), a
		ld	hl, (MBPlayer_songdata_ptr)
		jp	nz, loc_0_45CF

;		ld	a, (MBPlayer_songdata_bank1)
;		call	MBPlayer_selbank_FE 		; this bank contains pattern addresses

		ld	a, (MBPlayer_xleng)		; next position
		inc	a
		ld	b, a
		ld	a, (MBPlayer_play_pos)
		inc	a
		cp	b
		jp	c, loc_0_4599


;		ld	a, (MBPlayer_xloop)
;		cp	255
;		jp	nz, loc_0_4599

;               ld	a,(MoonSound_key_press)
;		and	a
;		jr	z,loc_0_4597 

		ld	a,1
                ld	(MoonSound_flg_next),a
		
		jp	MBPlayer_stop_music		; stop song, want loop OFF

			
loc_0_4597:
		call	MBPlayer_stop_music		; stop song, want loop OFF
		jp	MBPlayer_start_music		

;		xor	a

loc_0_4599:
		ld	(MBPlayer_play_pos), a
		ld	hl, (MBPlayer_pos_address)
		add	a, l
		jr	nc, loc_0_45A3
		inc	h
loc_0_45A3:
		ld	l, a
		ld	a, (hl)
		ld	(MBPlayer_current_pat), a
		add	a, a
		ld	hl, (MBPlayer_pat_address)
		add	a, l
		jr	nc, loc_0_45B0
		inc	h

loc_0_45B0:
		ld	l, a
		ld	e, (hl)
		inc	hl
		ld	d, (hl)
		ex	de, hl
		ld	a, h
		rlca	
		rlca	
		and	3
		ld	de, MBPlayer_songdata_bank1
		add	a, e
		jr	nc, loc_0_45C1
		inc	d
loc_0_45C1:
		ld	e, a
		ld	a, (de)
		ld	(MBPlayer_songdata_bank), a
		ld	a, h
		and	3Fh
		ld	h, a
		ld	de, (MBPlayer_songdata_addres)
		add	hl, de
loc_0_45CF:
;		ld	a, (MBPlayer_songdata_bank)
;		call	MBPlayer_selbank_FE

		ld	de, MBPlayer_step_buffer

		ld	a, (hl)
		inc	hl
		cp	0FFh				; 0FFh => completely empty
		jp	nz, loc_0_45F0
		exx	
		ld	hl, MBPlayer_step_buffer
		ld	de, MBPlayer_step_buffer + 1
		ld	bc, 24
		ld	(hl), b
		ldir	
		exx	
		jp	loc_0_460F
loc_0_45F0:
		ld	(de), a				; 1st byte uncrunched
		inc	de
		push	hl
		inc	hl
		inc	hl
		inc	hl
		exx	
		pop	hl
		ld	b, 3				; decrunch 3 * 8 bytes
loc_0_45FA:
		ld	a, (hl)
		exx	
		ld	b, 8				; decrunch 8 bytes
		ld	c, a
loc_0_45FF:
		xor	a
		rlc	c
		jr	nc, loc_0_4606			; no carry? then empty event
		ld	a, (hl)
		inc	hl
loc_0_4606:
		ld	(de), a
		inc	de
		djnz	loc_0_45FF
		exx	
		inc	hl
		djnz	loc_0_45FA
		exx	
loc_0_460F:                                         ;Calculate freq. & note nr of wave to play
		ld	(MBPlayer_songdata_ptr), hl

		ld	iy, MBPlayer_play_table_wav
		ld	hl, MBPlayer_step_buffer    ; third interrupt
		ld	bc, 860h                    ;(256 * (WAVCHNS/2)) + 96	; Wave channels
		jp	loc_0_4645

loc_0_461F:
		ld	b, WAVCHNS
		ld	hl, MBPlayer_step_buffer
		ld	iy, MBPlayer_play_table_wav
		ld	de, PTW_SIZE
		ld	c, 96
loc_0_462D:
		ld	a, (hl)
		dec	a
		cp	c
		jr	nc, loc_0_4636
		ld	(iy + 2), 0
loc_0_4636:
		inc	hl
		add	iy, de
		djnz	loc_0_462D

		ld	iy, unk_0_4D90		;play_table_wav + (WAVCHNS/2) * PTW_SIZE
		ld	hl, unk_0_4B90		;step_buffer + WAVCHNS / 2	; second interrupt
		ld	bc, 860h                ;(256 * (WAVCHNS/2)) + 96	; Wave channels
loc_0_4645:
		ld	de, PTW_SIZE
loc_0_4648:
		ld	a, (hl)
		dec	a
		cp	c
		call	c, MBPlayer_calc_wave
		add	iy, de
		inc	hl
		djnz	loc_0_4648
		jp	loc_0_4556
;-------------------------------------------------------------------
; описание: calc wave stuff
; параметры: нет
; возвращаемое  значение: нет
;---------------------------------------------------------------------
MBPlayer_calc_wave:
		exx	
		ld	d, a

		ld	hl, MBPlayer_patch_table	; dit stuk verandert A niet!
		ld	b, 0
		ld	c, (iy + 0Ah)
		ld	a, c
		cp	175
		jp	z, MBPlayer_calc_drm		; gm drum patch
		cp	176
		jp	nc, loc_0_4755			; own wave

loc_0_466B:
		ld	a, d
		add	hl, bc
		add	hl, bc
		ld	e, (hl)
		inc	hl
		ld	d, (hl)				; to patch
		ex	de, hl
		ld	e, (hl)
		inc	hl
		ld	c, (hl)
		inc	hl
		ld	b, (hl)
		inc	hl
		ld	(iy + 0Dh), c			; pointer to header bytes
		ld	(iy + 0Eh), b

		bit	0, e				; search right patch part
		jr	z, loc_0_4687			; transpose

		ld	b, a
		ld	a, (MBPlayer_play_tspval)
		add	a, b
loc_0_4687:
		ld	b, 0
		ld	de, 5
loc_0_468C:
		cp	(hl)
		jr	c, loc_0_46CB
		ld	b, (hl)
		add	hl, de
		cp	(hl)
		jr	c, loc_0_46CB
		ld	b, (hl)
		add	hl, de
		cp	(hl)
		jr	c, loc_0_46CB
		ld	b, (hl)
		add	hl, de
		cp	(hl)
		jr	c, loc_0_46CB
		ld	b, (hl)
		add	hl, de
		cp	(hl)
		jr	c, loc_0_46CB
		ld	b, (hl)
		add	hl, de
		cp	(hl)
		jr	c, loc_0_46CB
		ld	b, (hl)
		add	hl, de
		cp	(hl)
		jr	c, loc_0_46CB
		ld	b, (hl)
		add	hl, de
		cp	(hl)
		jr	c, loc_0_46CB
		ld	b, (hl)
		add	hl, de
		cp	(hl)
		jr	c, loc_0_46CB
		ld	b, (hl)
		add	hl, de
		cp	(hl)
		jr	c, loc_0_46CB
		ld	b, (hl)
		add	hl, de
		cp	(hl)
		jr	c, loc_0_46CB
		ld	b, (hl)
		add	hl, de
		cp	(hl)
		jr	c, loc_0_46CB
		ld	b, (hl)
		add	hl, de
		jp	loc_0_468C
loc_0_46CB:
		ld	d, a                    ; save note...
		inc	hl
		ld	a, (hl)			; low byte tone
		ld	(iy + 7), a

		inc	hl
		ld	a, (hl)
		and	1                       ; also resets carry!
		ld	(iy + 6), a             ; high byte tone

		ld	a, (hl)                 ; tone-note
		rra				; note that carry was set 0 earlier!!	
		add	a, d
		sub	b
		ld	(iy + 0), a		; last note

		inc	hl
		ld	e, (hl)
		inc	hl
		ld	d, (hl)
		ld	(iy + 11h), d		; pointer to freqtab
		ld	(iy + 10h), e

		ld	hl, MBPlayer_tabdiv12
		ld	c, a
		ld	b, 0
		add	hl, bc
		add	hl, bc
		ld	c, (hl)
		inc	hl
		ld	a, (hl)
		ex	de, hl

		add	a, l
		jr	nc, loc_0_46F9
		inc	h
loc_0_46F9:
		ld	l, a
		ld	e, (hl)
		inc	hl
		ld	d, (hl)

		sla	e   			; freq fine
		ld	a, d
		rla	      			; freq rotated 1 left
		add	a, c                    ; octave

		ld	d, a                    ; high byte freq
		ld	h, b
loc_0_4704:
		ld	l, (iy + 5)
		bit	7, l
		jr	z, loc_0_4718
		dec	h
		add	hl, hl			; detune...
loc_0_470D:
		add	hl, de
		res	3, h
		ld	(iy + 8), l		; freq fine
		ld	(iy + 9), h
		exx				; Yes! Finally, finished...	
		ret	
loc_0_4718:
		ex	de, hl
		add	hl, de 			; detune...
		ld	d, 8
		jp	loc_0_470D
;-------------------------------------------------------------------
; описание: Calc GM drums
; параметры: нет
; возвращаемое  значение: нет
;---------------------------------------------------------------------
MBPlayer_calc_drm:
		ld	a, d
		cp	36			
		jp	c, loc_0_466B		; < 36 => first drum handled as patch
		cp	57h
		jp	c, loc_0_472C
		ld	a, 56h
loc_0_472C:
		ld	hl, MBPlayer_gmdrm_c4
		sub	36
		ld	b, a
		add	a, a
		add	a, a
		add	a, b
		add	a, l
		jr	nc, loc_0_4739
		inc	h

loc_0_4739:
		ld	l, a
		ld	a, (hl)
		ld	(iy + 7), a
		ld	(iy + 6), 0
		inc	hl
		ld	e, (hl)
		inc	hl
		ld	d, (hl)
		inc	hl
		ld	a, (hl)
		ld	(iy + 0Dh), a
		inc	hl
		ld	a, (hl)
		ld	(iy + 0Eh), a
		ld	h, 0
		jp	loc_0_4704

loc_0_4755:
		sub	176
		ld	c, a
		add	a, a
		add	a, a
		add	a, a
		ld	l, a
		ld	h, 0
		add	hl, hl
		add	a, l
		jr	nc, loc_0_4763
		inc	h
loc_0_4763:
		ld	l, a
		ld	a, c
		add	a, l
		jr	nc, loc_0_4769
		inc	h
loc_0_4769:
		ld	l, a
		ld	bc, MBPlayer_waves
		add	hl, bc                          ; pointer to patch

		ld	e, (hl)                         ; transpose
		inc	hl
		ld	a, d
		bit	0, e 				; transpose
		jr	z, loc_0_4779
		ld	a, (MBPlayer_play_tspval)
		add	a, d
loc_0_4779:
		ld	d, 0
		ld	bc, 3
loc_0_477E:
		cp	(hl)
		jr	c, loc_0_4786
		ld	d, (hl)
		add	hl, bc
		jp	loc_0_477E

loc_0_4786:
		ld	b, a 				; save note...
		inc	hl
		ld	a, (hl)				; low byte tone
		ld	e, a
		add	a, 80h 				; tone 384 and above 
		ld	(iy + 7), a
		ld	(iy + 6), 1			; RAM wave is altijd > 256
		inc	hl

		ld	a, (hl)				; tone-note
		add	a, b
		sub	d
		ld	(iy + 0), a			; last note
		push	af

		ld	(iy + 0Dh), 0			; no header
		ld	(iy + 0Eh), 0

		ld	hl, MBPlayer_tones_data
		ld	d, 0
		add	hl, de
		ld	a, (hl)
		and	6
		ld	hl, MBPlayer_frqtab_amiga
		jr	z, loc_0_47BB
		ld	hl, MBPlayer_frqtab_441khz
		cp	2
		jr	z, loc_0_47BB
		ld	hl, MBPlayer_frqtab_turbo
loc_0_47BB:
		pop	af
		ld	(iy + 10h), l
		ld	(iy + 11h), h

		ld	e, a			; D is still 0
		add	hl, de
		add	hl, de
		ld	e, (hl)
		inc	hl
		ld	d, (hl)
		ld	h, 0
		jp	loc_0_4704
;-------------------------------------------------------------------
; описание: Play ON event
; параметры: нет
; возвращаемое  значение: нет
;---------------------------------------------------------------------
MBPlayer_play_wonevt:
		push	af
		ld	a, (iy++0Fh)
		and	1Fh
		rra	
		or	a
		jp	nz, loc_0_4857
		inc	a

loc_0_4857:
		ld	(ix++0), a
		pop	af

		dec	b
		ld	l, (iy + 0Dh)
		ld	h, (iy + 0Eh)
		ld	a, l
		or	h 			
		jr	z, loc_0_47F7           

		ld	a, 80h
		add	a, b
		out	(MOON_WREG), a
		ld	a, (hl)
loc_0_47DE:
		push	bc
		pop	bc
		out	(MOON_WDAT), a
		inc	hl
loc_0_47E3:
		ld	a, (hl)
		cp	0FFh
		jr	z, loc_0_47F7
		add	a, b
loc_0_47E9:
		push	bc
		pop	bc
		out	(MOON_WREG), a
		inc	hl
		ld	a, (hl)
loc_0_47EF:
		push	bc
		pop	bc
		out	(MOON_WDAT), a 		; header byte
		inc	hl
		jp	loc_0_47E3

loc_0_47F7:
		ld	a, 50h 			; set volume back to normal
		add	a, b
loc_0_47FA:
		push	bc
		pop	bc
		out	(MOON_WREG), a
		ld	a, (iy + 0Fh)
		or	1			; level direct
loc_0_4803:
		push	bc
		pop	bc
		out	(MOON_WDAT), a

		ld	a, 68h 			
		add	a, b
loc_0_480A:
		push	bc
		pop	bc
		out	(MOON_WREG), a
		ld	a, 80h
		or	(iy + 0Bh)             ; pan pot
loc_0_4813:
		push	bc
		pop	bc
		out	(MOON_WDAT), a		; key on

		ret
;-------------------------------------------------------------------
; описание: Play OFF event
; параметры: нет
; возвращаемое  значение: нет
;---------------------------------------------------------------------
MBPlayer_play_woffevt:
		ld	a, 67h
		add	a, b 			; calc. register
		out	(MOON_WREG), a

		ld	(iy + 2), 0 		; pb/mod off
loc_0_4821:
		push	bc
		pop	bc
		in	a, (MOON_WDAT)
		and	7Fh
loc_0_4827:
		push	bc
		pop	bc
		out	(MOON_WDAT), a
		ret	
;-------------------------------------------------------------------
; описание: Play Wave event
; параметры: нет
; возвращаемое  значение: нет
;---------------------------------------------------------------------
MBPlayer_play_wwavevt:
		sub	61h
MBPlayer_play_wwavevt2:
		ld	(iy + 2), 0 		; pb off
		ld	c, a
		ld	hl, MBPlayer_xwavnrs - 1
		add	a, l
		jr	nc, loc_0_483A
		inc	h
loc_0_483A:
		ld	l, a
		ld	a, (hl)
		ld	(iy + 0Ah), a
		ld	a, c
		ld	hl, MBPlayer_xwavvols - 1
		add	a, l
		jr	nc, loc_0_4847
		inc	h
loc_0_4847:
		ld	l, a
		ld	a, (iy + 0Fh)
		and	1
		ld	d, a
		ld	a, (MBPlayer_play_fading)
		or	a
		jr	nz, loc_0_485C

		ld	a, (hl)
		add	a, a
		add	a, a
		or	d
		ld	(iy + 0Fh), a
		ret	

loc_0_485C:
		ld	a, (hl)
		add	a, a
		add	a, a
		or	d
		cp	(iy + 0Fh)
		ret	c
		ld	(iy + 0Fh), a
		ret	
;-------------------------------------------------------------------
; описание: Play volume event
; параметры: нет
; возвращаемое  значение: нет
;---------------------------------------------------------------------
MBPlayer_play_wchgvol:
		sub	146
		xor	1Fh
		add	a, a
MBPlayer_play_wchgvol2:
		add	a, a			;OPL4 can handle 0-127
		add	a, a
		ld	c, a

		ld	a, (MBPlayer_play_fading)
		or	a
		jr	z, loc_0_487D
		ld	a, c
		or	1
		cp	(iy + 0Fh)
		ret	c

loc_0_487D:
		ld	a, 4Fh			
		add	a, b
		out	(MOON_WREG), a
		ld	a, (iy + 0Fh) 		; level direct
		and	1
		or	c
		ld	(iy + 0Fh), a

loc_0_488B:
		push	bc
		pop	bc
		out	(MOON_WDAT), a
		ret	
;-------------------------------------------------------------------
; описание: Link note
; параметры: нет
; возвращаемое  значение: нет
;---------------------------------------------------------------------
MBPlayer_play_wlnk:
		push	af
		ld	a, (iy++0Fh)
		and	1Fh
		rra	
		or	a
		jp	nz, loc_0_492A
		inc	a

loc_0_492A:
		ld	(ix++0), a
		pop	af


		ld	(iy + 2), 0
		push	bc
		sub	202
		add	a, (iy + 0)
		ld	(iy + 0), a

		bit	0, (iy + 6)
		jr	z, loc_0_48A9
		bit	7, (iy + 7)
		jr	nz, loc_0_48F9
loc_0_48A9:
		ld	hl, MBPlayer_tabdiv12
		ld	c, a
		ld	b, 0
		add	hl, bc
		add	hl, bc
		ld	c, (hl)
		inc	hl
		ld	a, (hl)
		ld	l, (iy + 10h)
		ld	h, (iy + 11h)
		add	a, l
		jr	nc, loc_0_48BE
		inc	h
loc_0_48BE:
		ld	l, a
		ld	e, (hl)
		inc	hl
		ld	d, (hl)
		ex	de, hl 			; HL = freq

		sla	l
		ld	a, h
		rla	
		add	a, c
		ld	h, a
loc_0_48C9:
		ld	d, 0
		ld	e, (iy + 5)
		bit	7, e
		jr	z, loc_0_48D3
		dec	d
loc_0_48D3:
		add	hl, de			; detune...
		add	hl, de

		ld	(iy + 12h), l		; freq fine
		ld	(iy + 13h), h

		pop	bc
		ld	a, 1Fh
		add	a, b
		out	(MOON_WREG), a
		ld	a, l
		or	(iy + 6)
loc_0_48E5:
		push	bc
		pop	bc
		out	(MOON_WDAT), a		; freq + tone

		ld	a, 37h
		add	a, b
loc_0_48EC:
		push	bc
		pop	bc
		out	(MOON_WREG), a
		ld	a, h
		or	(iy + 0Ch)
loc_0_48F4:
		push	bc
		pop	bc
		out	(MOON_WDAT), a 		; freq
		ret	

loc_0_48F9:
		ld	l, (iy + 10h)		; link own wave
		ld	h, (iy + 11h)
		ld	e, a
		ld	d, 0
		add	hl, de
		add	hl, de
		ld	e, (hl)
		inc	hl
		ld	d, (hl)
		ex	de, hl			; freq
		jp	loc_0_48C9
;-------------------------------------------------------------------
; описание: Play stereo event
; параметры: нет
; возвращаемое  значение: нет
;---------------------------------------------------------------------
MBPlayer_play_wchgste:
		sub	0B9h 		; 178 + 7
MBPlayer_play_wchgste2:
		and	0Fh
		ld	d, a
		ld	a, (iy + 0Bh)
		and	0F0h
		or	d
		ld	(iy + 0Bh), a
		ld	a, 67h
		add	a, b
		out	(MOON_WREG), a
		ld	(iy + 2), 0
loc_0_4922:
		push	bc
		pop	bc
		in	a, (MOON_WDAT)
		and	0F0h
		or	d
loc_0_4929:
		push	bc
		pop	bc
		out	(MOON_WDAT), a
		ret	
;-------------------------------------------------------------------
; описание: Pitch bending
; параметры: нет
; возвращаемое  значение: нет
;---------------------------------------------------------------------
MBPlayer_play_wchgpit:
		sub	221
		ld	(iy + 2), 1		; Pitch bending on
		add	a, a
		add	a, a
		ld	(iy + 3), a		; Set pitch bend speed
		rlca	
		jr	c, loc_0_4941
		ld	(iy + 4), 0
		ret	
loc_0_4941:
		ld	(iy + 4), 0FFh
		ret	
;-------------------------------------------------------------------
; описание: Modulation event
; параметры: нет
; возвращаемое  значение: нет
;---------------------------------------------------------------------
MBPlayer_play_wchgmod:
		sub	0ECh		;238 - 2
		ld	(iy + 2), a
		add	a, a
		add	a, a
		add	a, a
		add	a, a
		ld	hl, MBPlayer_xmodtab - 2 * 16
		add	a, l
		jr	nc, loc_0_4956
		inc	h
loc_0_4956:
		ld	l, a
		ld	(iy + 3), l
		ld	(iy + 4), h
		ret	
;-------------------------------------------------------------------
; описание: Set detune
; параметры: нет
; возвращаемое  значение: нет
;---------------------------------------------------------------------
MBPlayer_play_wchgdet:
		sub	234
		add	a, a
		add	a, a
		ld	(iy + 5), a
		ret	
;-------------------------------------------------------------------
; описание: Damp
; параметры: нет
; возвращаемое  значение: нет
;---------------------------------------------------------------------
MBPlayer_play_wchgdmp:
		ld	a, 67h
		add	a, b			; calc. register
		out	(MOON_WREG), a
		ld	(iy + 2), 0
loc_0_496F:
		push	bc
		pop	bc
		in	a, (MOON_WDAT)
		or	40h			; pb/mod off
loc_0_4975:
		push	bc
		pop	bc
		out	(MOON_WDAT), a
		ret	
;-------------------------------------------------------------------
; описание: pitch bending/modulation
; параметры: нет
; возвращаемое  значение: нет
;---------------------------------------------------------------------
MBPlayer_play_pitch:
		ld	iy, MBPlayer_play_table_wav
		ld	de,PTW_SIZE
		ld	hl,MBPlayer_play_pitchwvl2
		ld	b,WAVCHNS		; wave channels
MBPlayer_play_pitchwlus:
		ld	a, (iy + 2)
		or	a
		jp	nz, MBPlayer_play_pitch_wdo
MBPlayer_play_pitchwvl2:
		add	iy, de
		djnz	MBPlayer_play_pitchwlus
		ret	
;-------------------------------------------------------------------
; описание: pitch bending
; параметры: нет
; возвращаемое  значение: нет
;---------------------------------------------------------------------
MBPlayer_play_pitch_wdo:
		exx	

		ld	c, a

		ld	l, (iy + 3)		; pitch bend speed
		ld	h, (iy + 4)
		dec	c
		jp	nz, MBPlayer_play_mod_wdo ; modulation
		ex	de, hl
loc_0_499F:
		ld	h, (iy + 13h)
		ld	l, (iy + 12h)
		add	hl, de			; sliding
		bit	3, h
		jr	z, loc_0_49B7
		bit	7, d
		jr	nz, loc_0_49B5
		ld	a, h
		add	a, 8
		ld	h, a
		jp	loc_0_49B7
loc_0_49B5:
		res	3, h
loc_0_49B7:
		ld	(iy + 12h), l		; freq fine
		ld	(iy + 13h), h
		ld	a, (iy + 1)
		ld	c, a
		out	(MOON_WREG), a
		ld	a, l
		or	(iy + 6)
loc_0_49C7:
		push	bc
		pop	bc
		out	(MOON_WDAT), a		; freq + tone

		ld	a, c
		add	a, 24
loc_0_49CE:
		push	bc
		pop	bc
		out	(MOON_WREG), a
		ld	a, h
loc_0_49D3:
		push	bc
		pop	bc
		out	(MOON_WDAT), a 		; freq
		exx	
		jp	(hl)
;-------------------------------------------------------------------
; описание: Модуляция
; параметры: нет
; возвращаемое  значение: нет
;---------------------------------------------------------------------
MBPlayer_play_mod_wdo:
		ld	d, 0
		ld	e, (hl)
		sla	e
		sla	e
		jr	nc, loc_0_49E3
		dec	d
loc_0_49E3:
		inc	hl
		ld	a, (hl)
		cp	10
		jp	nz, loc_0_49F7
		ld	a, c

		ld	hl, MBPlayer_xmodtab - 16
		add	a, a
		add	a, a
		add	a, a
		add	a, a
		add	a, l
		jr	nc, loc_0_49F6
		inc	h
loc_0_49F6:
		ld	l, a
loc_0_49F7:
		ld	(iy + 3), l
		ld	(iy + 4), h
		jp	loc_0_499F
;-------------------------------------------------------------------
; описание: Затухание мелодии
; параметры: нет
; возвращаемое  значение: нет
;---------------------------------------------------------------------
MBPlayer_play_fade:	
		ld	a,(MBPlayer_play_fadespd)	; speed
		ld	hl,MBPlayer_play_fadecnt
		inc	(hl)
		cp	(hl)
		ret	nz
		ld	(hl), 0

		ld	b,WAVCHNS
		ld	iy,MBPlayer_play_table_wav
		ld	de,PTW_SIZE
loc_0_4A14:
		ld	a, (iy + 0Fh)		
		add	a, 8                    ; -4, but bit 0 is not for volume
		jr	nc, loc_0_4A1D
		ld	a, 255
loc_0_4A1D:
		ld	(iy + 0Fh), a
		ld	a, 4Fh
		add	a, b
		out	(MOON_WREG), a
		ld	a, (iy + 0Fh)		; level direct
loc_0_4A28:
		push	bc
		pop	bc
		out	(MOON_WDAT), a
		add	iy, de
		djnz	loc_0_4A14

		ld	hl, MBPlayer_play_fadetcnt 	; total counter
		inc	(hl)
		ld	a, (hl)
		cp	33			; will always be faded out in 33 steps
		ret	nz
		xor	a
		ld	(MBPlayer_play_fading), a
		jp	MBPlayer_stop_music

sub_0_4A3F:
		ex	af, af'
		ld	a, c
loc_0_4A41:
		push	bc
		pop	bc
		out	(MOON_REG2),a
		ex	af, af'
loc_0_4A46:
		push	bc
		pop	bc
		out	(MOON_DAT2),a
		ret	
;-------------------------------------------------------------------
; описание: Вывод данных в регистры Wave части
; параметры: C - номер регистра
;	     A - выводимый байт
; возвращаемое  значение: нет
;---------------------------------------------------------------------
MBPlayer_out_wave:	
		ex	af, af'
		ld	a, c
loc_0_4A4D:
		push	bc
		pop	bc
		out	(MOON_WREG), a
		ex	af, af'
loc_0_4A52:
		push	bc
		pop	bc
		out	(MOON_WDAT), a
		ret	
;-------------------------------------------------------------------
; описание: Чтение данных из регистра Wave части
; параметры: C - номер регистра
; возвращаемое  значение: A - байт данных
;---------------------------------------------------------------------
MBPlayer_in_wave:	
		push	bc
		pop	bc
		ld	a, c
		out	(MOON_WREG), a
		nop	
loc_0_4A5D:
		push	bc
		pop	bc
		in	a, (MOON_WDAT)
		ret	

MBPlayer_play_busy:
		db	0
MBPlayer_play_pos:	
		db 	0
MBPlayer_play_step:	
		db 	0
MBPlayer_save_curbank:	
		db	0
MBPlayer_songdata_bank1:	
		db 	0
MBPlayer_songdata_addres:	
		dw 	0
MBPlayer_songdata_bank:	
		db 	0

MBPlayer_step_buffer:	
		db    	0
		db    	0
		db    	0 ;  
		db    	0 ;  
		db    	0 ;  
		db    	0 ;  
		db    	0 ;  
		db    	0 ;  
unk_0_4B90:	
		db    	0
		db    	0 ;  
		db    	0 ;  
		db    	0 ;  
		db    	0 ;  
		db    	0 ;  
		db    	0 ;  
		db    	0 ;  
unk_0_4B98:	
		db    	0
		db    	0 ;  
		db    	0 ;  
		db    	0 ;  
		db    	0 ;  
		db    	0 ;  
		db    	0 ;  
		db    	0 ;  
		db    	0 ;  
MBPlayer_play_speed:	
		db 	0
MBPlayer_play_tspval:	
		db 	0
MBPlayer_play_timercnt:	
		db 	0
MBPlayer_play_intcnt:
		db 	0
MBPlayer_current_pat:	
		db 	0
MBPlayer_play_fading:	
		db 	0
MBPlayer_play_fadecnt:	
		db 	0
MBPlayer_play_fadespd:	
		db 	0
MBPlayer_play_fadetcnt:	
		db 	0
MBPlayer_sample_address:	
		db    	0
		db    	0 ;  
		db    	0 ;  
		db    	0 ;  
MBPlayer_samplesize:	
		dw 	0
;-------------------------------------------------------------------
; описание: Информация о треке = 220 байт
; параметры: нет
; возвращаемое  значение: нет
;---------------------------------------------------------------------
MBPlayer_xleng:	
		ds	1		; Song length
MBPlayer_xloop:		
		ds	1		; Loop position
MBPlayer_xwvstpr:	
		ds	24		; Stereo settings Wave
MBPlayer_xtempo:		
		ds	1		; Tempo
MBPlayer_xhzequal:	
		ds	1		; Base frequency
MBPlayer_xdetune:		
		ds	24		; Detune settings
MBPlayer_xmodtab:		
		ds	3*16		; Modulation tables
MBPlayer_xbegwav:		
		ds	24		; Start waves
MBPlayer_xwavnrs:	
		ds	48		; Wave numbers
MBPlayer_xwavvols:	                	
		ds	48		; Wave volumes


MBPlayer_pat_address:	
		dw 	0
MBPlayer_pos_address:	
		dw 	0
MBPlayer_songdata_ptr:	
		dw 	0

;--- smart table: --

;    - last note played                 01: + 0
;    - frequency register               01: + 1
;    - pitch bending on/off             01: + 2
;    - pitch bend speed                 02: + 3
;    - detune value                     01: + 5
;    - tone nr for next interrupt       02: + 6
;    - freq for next interrupt          02: + 8
;    - current patch                    01  + 10
;    - current stereo setting           01  + 11
;    - pseudo reverb                    01  + 12
;    - Pointer to header bytes          02  + 13
;    - Volume                           01  + 15
;    - Pointer to used freq table       01  + 16
;    - Current pitch freq.              02  + 18
;                               --
;    Total:                             20

MBPlayer_play_table_wav:
		db	0,037h,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0	; ch1
		db	0,036h,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0	; ch2
		db	0,035h,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0	; ch3
		db	0,034h,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0	; ch4
		db	0,033h,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0	; ch5
		db	0,032h,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0	; ch6
		db	0,031h,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0	; ch7
		db	0,030h,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0	; ch8
unk_0_4D90:	
		db	0,02fh,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0	; ch9
		db	0,02eh,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0	; ch10
		db	0,02dh,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0	; ch11
		db	0,02ch,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0	; ch12
		db	0,02bh,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0	; ch13
		db	0,02ah,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0	; ch14
		db	0,029h,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0	; ch15
		db	0,028h,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0	; ch16
unk_0_4E30:	
		db	0,027h,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0	; ch17
		db	0,026h,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0	; ch18
		db	0,025h,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0	; ch19
		db	0,024h,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0	; ch20
		db	0,023h,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0	; ch21
		db	0,022h,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0	; ch22
		db	0,021h,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0	; ch23
		db	0,020h,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0	; ch24

		.include	"freq_table_0.inc"
		.include	"freq_table_1.inc"
		.include	"freq_table_2.inc"
		.include	"freq_table_3.inc"

MBPlayer_waves:
		.incbin	"powerkit_wave.bin"
MBPlayer_tones_data:	
		.incbin	"powerkit_table.bin" 

MBPlayer_volume_buffer_1:	
		ds    24
MBPlayer_volume_buffer_2:	
		ds    24

		.include "patch_table.inc"
		.include "freq_table_4.inc"
