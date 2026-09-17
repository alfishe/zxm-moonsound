;--------------------------------------------------------------------
; ќписание: ѕроигрывающий модуль музыкальных файлов MWM c компьютера MSX
; јвтор порта: “арасов ћ.Ќ.(Mick),2015
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
; описание: »нициализаци€ проигрывател€
; параметры: нет
; возвращаемое  значение: нет
;---------------------------------------------------------------------
MBPlayer_init:
		jp	start_music
;-------------------------------------------------------------------
; описание: ѕроигрывание ноты
; параметры: нет
; возвращаемое  значение: нет
;---------------------------------------------------------------------
MBPlayer_play:
		jp	play_int
;-------------------------------------------------------------------
; описание: ќстановка проигрывани€
; параметры: нет
; возвращаемое  значение: нет
;---------------------------------------------------------------------
MBPlayer_stop:
		jp	stop_music
;-------------------------------------------------------------------
; описание: ”становка тишины в звуковой чип
; параметры: нет
; возвращаемое  значение: нет
;---------------------------------------------------------------------
MBPlayer_fade:
		jp	fade_music
;-------------------------------------------------------------------
; описание: ѕродолжение воспроизведени€
; параметры: нет
; возвращаемое  значение: нет
;---------------------------------------------------------------------
MBPlayer_continue:
		jp	cont_music
;-------------------------------------------------------------------
; описание: »нициализаци€ проигрывател€
; параметры: нет
; возвращаемое  значение: нет
;---------------------------------------------------------------------
start_music:	
		di
		ld	a,(play_busy)
		or	a
		ret	nz				; already playing?

		ld	hl,0
		ld	(status),hl
		ld	(status + 1),hl			; clear status bytes

		ld	a,0ffh
		ld	(play_busy),a			; set busy playing

		ld	(play_pos),a
		ld	a,15
		ld	(play_step),a			; set step and position

;		call	curbank_FE

		push	af
		ld	a,(songdata_bank1)
;		call	selbank_FE

		ld	hl,(songdata_adres)
		ld	de,xleng
		ld	bc,220
		ldir					; copy song settings
		ld	de,58
		add	hl,de				; skip name/wavekit
		ld	(pos_address),hl
		ld	a,(xleng)
		inc	a
		ld	e,a
		add	hl,de
		ld	(pat_address),hl
		pop	af

;		call	selbank_FE

		call	init_opl4			; initialise OPL4
		call	init_voices			; set start voices
		ld	a,(xtempo)
		ld	(play_speed),a			; set tempo
		ld	a,(play_speed)
		sub	3
		ld	(play_timercnt),a		; initialise timer (tempo)
		xor	a
		ld	(play_tspval),a			; transpose off
		ld	(play_fading),a
		ld	(play_fadecnt),a
		ld	(play_fadetcnt),a
		
start_mus_cnt:
		ret
		di
;		ld	hl,0fd9Ah
;		ld	de,old_int
;		ld	bc,5
;		ldir		; save interrupt hook

;		ld	a,(0f342h)
;		ld	(Page_nmb),a
;		ld	hl,opl4_int_han
;		ld	de,0fb04h
;		ld	bc,9
;		ldir

;		ld	hl,0FD9Ah	;Init On Hook 0FD9Ah a Jump to empty RS232 area
;		ld	(hl),0C3h	; JP
;		inc	hl
;		ld	(hl),004h	; 04
;		inc	hl
;		ld	(hl),0FBh	; FB

		ld	a,2
		out	(MOON_REG1),a
		ld	a,(xhzequal)
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
		ei
		ret

;opl4_int_han:
;		in	a,(MOON_STAT)		; Put this shit in the RS232 area
;		rla				; this is to prevent 50 or 60 CALLFs
;		ret	nc			; to the replayer
;		rst	030h

;Page_nmb:	db	0
;		dw	play_int
;		ret

;-------------------------------------------------------------------
; описание: »нициализаци€ OPL4 регистров
; параметры: нет
; возвращаемое  значение: нет
;---------------------------------------------------------------------
init_opl4:	
		ld	a,5
		out	(MOON_REG2),a
		nop	
		ld	a,3
		out	(MOON_DAT2),a

		ld	c,2
		ld	a,10000b
		jp	opl4_out_wave		; init Wave ROM stuff
;-------------------------------------------------------------------
; описание: »нициализаци€ OPL4 каналов
; параметры: нет
; возвращаемое  значение: нет
;---------------------------------------------------------------------
init_voices:
		ld	b,WAVCHNS			; # wave channels
		ld	iy,play_table_wav
		ld	ix,xbegwav
		ld	de,PTW_SIZE
init_wavesl:
		push	de
		push	bc
		ld	a,(ix - 72)			; xdetune!
		add	a,a
		ld	(iy + 5),a			; detune!
		ld	(iy + 12),0			; Reverb off
		ld	a,(ix + 0)			; wave/patchnr
		push	af
		call	play_wwavevt2
		pop	af
		ld	hl,xwavvols - 1
		add	a,l			
		jr	nc,init_wavesl_1
		inc	h
init_wavesl_1:
		ld	l,a
		ld	a,(hl)				; volume
		ld	(iy + 15),a
		call	play_wchgvol2
		ld	a,(ix - 98)			; stereo preset
		call	play_wchgste2
		inc	ix
		pop	bc
		pop	de
		add	iy,de
		djnz	init_wavesl
		ret

;-------------------------------------------------------------------
; описание: ѕродолжение воспроизведени€
; параметры: нет
; возвращаемое  значение: нет
;---------------------------------------------------------------------
cont_music:
		ld	a,(play_busy)	; already playing?
		or	a
		ret	nz
		dec	a
		ld	(play_busy),a
		jp	start_mus_cnt
;-------------------------------------------------------------------
; описание: ќстановка проигрывани€
; параметры: нет
; возвращаемое  значение: нет
;---------------------------------------------------------------------
stop_music:
		ld	a,(play_busy)			; already stopped?
		or	a
		ret	z

		di
		ld	a,4
		out	(MOON_REG1),a
		nop	
		ld	a,128
		out	(MOON_DAT1),a			; Reset Opl4 flags to prevent a crash
		nop	
		xor	a
		out	(MOON_DAT1),a			; Stop timers
		ld	(play_busy),a
;		ld	hl,old_int			; restore old interrupt hook
;		ld	de,0fd9ah
;		ld	bc,5
;		ldir

		ld	b,WAVCHNS			; # wave channels
		ld	iy,play_table_wav
		ld	de,PTW_SIZE
stop_musicl3:
		call	play_woffevt
		call	play_chgdmp
		add	iy,de
		djnz	stop_musicl3
		ei
		ret
;-------------------------------------------------------------------
; описание: ”становка тишины в звуковой чип
; параметры: A - скорость затухани€
; возвращаемое  значение: нет
;---------------------------------------------------------------------
fade_music:	
		ld	b,a
		ld	a,(play_busy)			; already stopped?
		or	a
		ret	z
		ld	a,255
		ld	(play_fading),a			; fading on
		ld	a,b
		ld	(play_fadespd),a		; set fade speed
		ret
;-------------------------------------------------------------------
; описание: ѕроигрывание ноты
; параметры: нет
; возвращаемое  значение: нет
;---------------------------------------------------------------------
play_int:
		di
		ld	a,4

		out	(MOON_REG1),a
		nop	
		ld	a,128+1
		out	(MOON_DAT1),a			; reset opl4 IRQ

		call	play_pitch			; pitch-bend/modulation handler

		ld	a,(play_fading)
		or	a
		jr	z,play_int5
		call	play_fade			; fading
		ld	a,(play_fading)
		or	a
		jp	z,play_int_end
play_int5:

;		call	curbank_FE
		push	af

		ld	a,(play_speed)			; speed
		ld	hl,play_timercnt
		inc	(hl)
		cp	(hl)
		jp	nz,play_int_sec			; almost there?
		ld	(hl),0

		ld	a,(songdata_bank)
;		call	selbank_FE

		call	play_wtones			; select tones in advance

		ld	hl,step_buffer			; songdata-adres
		ld	iy,play_table_wav
		ld	b,WAVCHNS			; # Wave channels!
		ld	de,PTW_SIZE
play_int_wlus:
		ld	a,(hl)
		or	a
		jr	z,play_int_wend2		; empty

		ex	af,af'
		ld	a,b
		exx
		ld	b,a
		ex	af,af'

		ld	de,play_int_wend
		push	de

		cp	97
		jp	c,play_wonevt			; wave on
		jp	z,play_woffevt			; wave off
		cp	146
		jp	c,play_wwavevt			; wave
		cp	178
		jp	c,play_wchgvol			; volume
		cp	193
		jp	c,play_wchgste			; stereo
		cp	212
		jp	c,play_wlnk			; link
		cp	231
		jp	c,play_wchgpit			; pitch bending
		cp	238
		jp	c,play_wchgdet			; detune
		cp	241
		jp	c,play_wchgmod			; modulation
		jp	z,play_chgpsr			; pseudo reverb on
		cp	243
		jp	c,play_chgdmp			; damp
		jp	z,play_chglfo			; LFO
		cp	245
		jp	c,play_chgpso			; pseudo reverb off
		cp	255
		jp	c,play_chgxls			; eXtra Lfo Settings

play_int_wend:
		exx
play_int_wend2:
		add	iy,de
		inc	hl
		djnz	play_int_wlus

		ld	a,(hl)				; command line
		or	a
		jr	z,play_cmdcnt

		cp	24
		jp	c,play_chgtmp			; change tempo
		jp	z,play_endop			; end of pattern
		cp	28
		jr	c,play_cmdcnt			; status
		cp	76 + 1
		jp	c,play_chgtrs			; transpose
		cp	211
		jp	c,play_chgbasefr		; base frequency

play_cmdcnt:
play_int_fin:
		pop	af
;		call	selbank_FE

play_int_end:
old_int:						
		ret
		ret
		ret
		ret

;-----------------------------------------------
;--- Interrupt routine BEFORE play-interrupt ---
;-----------------------------------------------
play_int_sec:	
		dec	a
		cp	(hl)
		jp	z,play_int_secit
		dec	a
		cp	(hl)
		jp	nz,play_int_fin

play_int_3rd:
		ld	a,(play_step)			; increase current step
		inc	a
		and	01111b
		ld	(play_step),a
		ld	hl,(songdata_ptr)
		call	z,play_nextpos			; step 0 => new position


		ld	a,(songdata_bank)
;		call	selbank_FE


		ld	de,step_buffer
decr_step_lp:
		ld	a,(hl)
		inc	hl
		cp	0ffh	; 0FFh => completely empty
		jp	nz,decr_step_2
		exx
		ld	hl,step_buffer
		ld	de,step_buffer + 1
		ld	bc,25 - 1
		ld	(hl),b
		ldir
		exx
		jp	decr_step_end

decr_step_2:
		ld	(de),a	; 1st byte uncrunched
		inc	de
		push	hl
		inc	hl
		inc	hl
		inc	hl
		exx
		pop	hl
		ld	b,3	; decrunch 3 * 8 bytes
decr_step_lp1:
		ld	a,(hl)
		exx
		ld	b,8	; decrunch 8 bytes
		ld	c,a
decr_step_lp2:
		xor	a
		rlc	c
		jr	nc,decr_step_3	; no carry? then empty event
		ld	a,(hl)
		inc	hl
decr_step_3:
		ld	(de),a
		inc	de
		djnz	decr_step_lp2
		exx
		inc	hl
		djnz	decr_step_lp1
		exx
decr_step_end:
		ld	(songdata_ptr),hl

;--- Calculate freq. & note nr of wave to play ---

		ld	iy,play_table_wav
		ld	hl,step_buffer	; third interrupt
		ld	bc, (256 * (WAVCHNS/2)) + 96	; Wave channels
		jr	play_int_seclp

play_int_secit:
		ld	b,WAVCHNS
		ld	hl,step_buffer
		ld	iy,play_table_wav
		ld	de,PTW_SIZE
play_int_secl2:
		ld	a,(hl)
		dec	a
		cp	96
		jr	nc,play_int_secpb
		ld	(iy + 2),0
play_int_secpb:
		inc	hl
		add	iy,de
		djnz	play_int_secl2

		ld	iy,play_table_wav + (WAVCHNS/2) * PTW_SIZE
		ld	hl,step_buffer + WAVCHNS / 2	; second interrupt
		ld	bc, (256 * (WAVCHNS/2)) + 96	; Wave channels
		jr	play_int_seclp


play_int_seclp:
		ld	de,PTW_SIZE
play_int_secwl:
		ld	a,(hl)
		dec	a
		cp	c	; 96
		jp	c,calc_wave	; JP to and fro for extra speed
play_int_secwe:
		add	iy,de
		inc	hl
		djnz	play_int_secwl
		jp	play_int_fin

;--- calc wave stuff ---

calc_wave:
		exx
		ld	d,a

		ld	hl,patch_table	; dit stuk verandert A niet!
		ld	b,0
		ld	c,(iy + 10)
		ld	a,c
		cp	175
		jp	z,calc_drm	; gm drum patch
		cp	176
		jp	nc,calc_own	; own wave

calc_drm_cnt:	ld	a,d
		add	hl,bc
		add	hl,bc
		ld	e,(hl)
		inc	hl
		ld	d,(hl)	; 	; to patch
		ex	de,hl
		ld	e,(hl)
		inc	hl
		ld	c,(hl)
		inc	hl
		ld	b,(hl)
		inc	hl
		ld	(iy + 13),c	; pointer to header bytes
		ld	(iy + 14),b
	; search right patch part

		bit	0,e	; transpose
		jr	z,keyb_wonwav7
		ld	b,a
		ld	a,(play_tspval)
		add	a,b
keyb_wonwav7:	
		ld	b,0
		ld	de,3 + 2
calc_wave_lp:	cp	(hl)
		jr	c,calc_wave_2
		ld	b,(hl)
		add	hl,de
		cp	(hl)			; 4 * the same, saves 30 T-states!
		jr	c,calc_wave_2			; (Anything for some extra speed)
		ld	b,(hl)
		add	hl,de
		cp	(hl)
		jr	c,calc_wave_2
		ld	b,(hl)
		add	hl,de
		cp	(hl)
		jr	c,calc_wave_2
		ld	b,(hl)
		add	hl,de
		jp	calc_wave_lp
calc_wave_2:	
		ld	d,a	; save note...
		inc	hl
		ld	a,(hl)	; low byte tone
		ld	(iy + 7),a

		inc	hl
		ld	a,(hl)
		and	1	; also resets carry!
		ld	(iy + 6),a	; high byte tone

		ld	a,(hl)	; tone-note
		rra		; note that carry was set 0 earlier!!
		add	a,d
		sub	b
		ld	(iy + 0),a	; last note

		inc	hl
		ld	e,(hl)
		inc	hl
		ld	d,(hl)
		ld	(iy + 17),d	; pointer to freqtab
		ld	(iy + 16),e

		ld	hl,tabdiv12
		ld	c,a
		ld	b,0
		add	hl,bc
		add	hl,bc
		ld	c,(hl)
		inc	hl
		ld	a,(hl)
		ex	de,hl

		add	a,l			
		jr	nc,calc_drmcnt1
		inc	h
calc_drmcnt1:
		ld	l,a

		ld	e,(hl)
		inc	hl
		ld	d,(hl)			; DE = freq

		sla	e			; freq fine
		ld	a,d
		rla				; freq rotated 1 left
		add	a,c			; octave
		                        	
		ld	d,a			; high byte freq

		ld	h,b			; LD H,0!
calc_drmcnt2:	
		ld	l,(iy + 5)
		bit	7,l
		jr	z,calc_wave_6
		dec	h
		add	hl,hl			; detune...
calc_wave_7:	
		add	hl,de
		res	3,h
		ld	(iy + 8),l		; freq fine
		ld	(iy + 9),h
		exx				; Yes! Finally, finished...
		jp	play_int_secwe
calc_wave_6:	
		ex	de,hl
		add	hl,de			; detune...
		ld	d,1000b
		jr	calc_wave_7

;--- Calc GM drums ---

calc_drm:	
		ld	a,d
		cp	36
		jp	c,calc_drm_cnt	; < 36 => first drum handled as patch
		cp	85 + 5 + 1
		jp	c,calc_drm2
		ld	a,84 + 4 + 1	; > 89 => 89
calc_drm2:
		ld	hl,gmdrm_c4
		sub	36
		ld	b,a
		add	a,a
		add	a,a
		ld	e,a
		ld	d,0
		add	hl,de
		ld	e,b
		add	hl,de
		ld	a,(hl)
		ld	(iy + 7),a
		ld	(iy + 6),0
		inc	hl
		ld	e,(hl)
		inc	hl
		ld	d,(hl)
		inc	hl
		ld	a,(hl)
		ld	(iy + 13),a
		inc	hl
		ld	a,(hl)
		ld	(iy + 14),a
		ld	h,0
		jp	calc_drmcnt2

calc_own:
		sub	176
		ld	c,a
		add	a,a
		add	a,a
		add	a,a
		ld	l,a
		ld	h,0
		add	hl,hl
		add	a,l
		jr	nc,calc_own_0
		inc	h
calc_own_0:
		ld	l,a
		ld	a,c
		add	a,l
		jr	nc,calc_own_1
		inc	h
calc_own_1:
		ld	l,a
		ld	bc,waves
		add	hl,bc	; pointer to patch

		ld	e,(hl)	; transpose
		inc	hl
		ld	a,d
		bit	0,e	; transpose
		jr	z,calc_own2
		ld	a,(play_tspval)
		add	a,d

calc_own2:	
		ld	d,0
		ld	bc,3
calc_own_lp:	
		cp	(hl)
		jr	c,calc_own_2
		ld	d,(hl)
		add	hl,bc
		jp	calc_own_lp
calc_own_2:	
		ld	b,a	; save note...
		inc	hl
		ld	a,(hl)	; low byte tone
		ld	e,a
		add	a,128	; tone 384 and above
		ld	(iy + 7),a
		ld	(iy + 6),1	; RAM wave is altijd > 256
		inc	hl

		ld	a,(hl)	; tone-note
		add	a,b
		sub	d
		ld	(iy + 0),a	; last note
		push	af

		ld	(iy + 14),0	; no header

		ld	hl,tones_data
		ld	d,0
		add	hl,de
		ld	a,(hl)
		and	110b
		ld	hl,frqtab_amiga
		jr	z,calc_own3
		ld	hl,frqtab_441khz
		cp	2
		jr	z,calc_own3
		ld	hl,frqtab_turbo
calc_own3:	
		pop	af
		ld	(iy + 16),l
		ld	(iy + 17),h

		ld	e,a	; D is still 0
		add	hl,de
		add	hl,de
		ld	e,(hl)
		inc	hl
		ld	d,(hl)
		ld	h,0
		jp	calc_drmcnt2


;---------------------------
;--- WAVE Event routines ---
;---------------------------

play_wtones:	
		ld	hl,step_buffer	; songdata address
		ld	b,WAVCHNS	; # channels
		ld	iy,play_table_wav
		ld	de,PTW_SIZE
play_wtonesl:	ld	a,(hl)
		dec	a
		cp	96
		jp	nc,play_wtonese

		ld	a,068h - 1
		add	a,b	; calc. register
		out	(MOON_WREG),a
		xor	a
		nop
		nop
		out	(MOON_WDAT),a	; off

		ld	a,050h - 1
		add	a,b	; calc. register
		nop
		out	(MOON_WREG),a
		ld	c,a
		ld	a,11111111b
		nop	
		out	(MOON_WDAT),a	; volume 0!

		ld	a,20h - 1
		add	a,b
		nop
		out	(MOON_WREG),a
		ld	a,(iy + 8)
		ld	(iy + 18),a
		or	(iy + 6)
		nop	
		out	(MOON_WDAT),a	; freq + tone

		ld	a,8 - 1
		add	a,b
		nop
		out	(MOON_WREG),a
		ld	a,(iy + 7)

		nop
		out	(MOON_WDAT),a	; tone

		ld	a,38h - 1
		add	a,b
		nop
		out	(MOON_WREG),a
		ld	a,(iy + 9)
		ld	(iy + 19),a
		or	(iy + 12)	; pseude reverb
		nop
		out	(MOON_WDAT),a	; freq

play_wtonese:	
		inc	hl
		add	iy,de
		djnz	play_wtonesl
		ret


;--- Play ON-event ---

play_wonevt:
		dec	b
		ld	l,(iy + 13)
		ld	h,(iy + 14)
		ld	a,h
		or	a	; Check only on high byte of pointer
		jr	z,play_wonevtlp2	; own voice, no header...

		ld	a,80h
		add	a,b
		out	(MOON_WREG),a
		ld	a,(hl)
		nop
		out	(MOON_WDAT),a
		inc	hl

play_wvwait:
		in	a,(MOON_STAT)	; wait till Wave Load ready
		bit	1,a
		jr	nz,play_wvwait

play_wonevtlp:
		ld	a,(hl)
		cp	0ffh
		jr	z,play_wonevtlp2
		add	a,b
		nop
		out	(MOON_WREG),a
		inc	hl
		ld	a,(hl)
		nop
		out	(MOON_WDAT),a	; header byte
		inc	hl
		jp	play_wonevtlp

play_wonevtlp2:
		ld	a,050h	; set volume back to normal
		add	a,b
		nop
		out	(MOON_WREG),a
		ld	a,(iy + 15)
		or	1	; level direct
		nop
		out	(MOON_WDAT),a

		ld	a,068h
		add	a,b
		nop
		out	(MOON_WREG),a
		ld	a,10000000b
		or	(iy + 11)	; pan pot
		nop
		out	(MOON_WDAT),a	; key on
		ret


;--- Play OFF event ---

play_woffevt:	
		ld	a,068h - 1
		add	a,b	; calc. register
		out	(MOON_WREG),a
		ld	(iy+2),0	; pb/mod off
		nop	
		in	a,(MOON_WDAT)
		and	1111111b
		nop
		out	(MOON_WDAT),a
		ret


;--- Play Wave event ---

play_wwavevt:	
		sub	98 - 1
play_wwavevt2:	
		ld	(iy + 2),0	; pb off
		ld	c,a
		ld	hl,xwavnrs - 1
		add	a, l
		jr	nc, play_wwavevt_0
		inc	h
play_wwavevt_0:
		ld	l, a
		ld	a,(hl)
		ld	(iy + 10),a
		ld	a,c
		ld	hl,xwavvols - 1
		add	a, l
		jr	nc, play_wwavevt_1
		inc	h
play_wwavevt_1:
		ld	l, a
		ld	a,(iy + 15)
		and	1
		ld	d,a
		ld	a,(play_fading)
		or	a
		jr	nz,play_wavevtfd

		ld	a,(hl)
		add	a,a
		add	a,a
		or	d
		ld	(iy + 15),a
		ret

play_wavevtfd:	
		ld	a,(hl)
		add	a,a
		add	a,a
		or	d
		cp	(iy + 15)
		ret	c
		ld	(iy + 15),a
		ret


;--- Play volume event ---

play_wchgvol:	
		sub	146
		xor	31
		add	a,a
play_wchgvol2:	
		add	a,a	; * 4, OPL4 can handle 0-127
		add	a,a
		ld	c,a

		ld	a,(play_fading)
		or	a
		jr	z,play_wchgvolfd
		ld	a,c
		or	1
		cp	(iy + 15)
		ret	c

play_wchgvolfd:
		ld	a,050h - 1
		add	a,b
		out	(MOON_WREG),a
		ld	a,(iy + 15)	; level direct
		and	1
		or	c
		ld	(iy + 15),a
		nop
		out	(MOON_WDAT),a
		ret

;--- Link note ---

play_wlnk:	
		ld	(iy + 2),0
		push	bc
		sub	202
		add	a,(iy + 0)
		ld	(iy + 0),a

		bit	0,(iy + 6)
		jr	z,play_wlnk2
		bit	7,(iy + 7)
		jr	nz,play_wlnk3

play_wlnk2:	
		ld	hl,tabdiv12
		ld	c,a
		ld	b,0
		add	hl,bc
		add	hl,bc
		ld	c,(hl)
		inc	hl
		ld	a,(hl)
		ld	l,(iy + 16)
		ld	h,(iy + 17)
		add	a, l
		jr	nc,play_wlnk2_0
		inc	h
play_wlnk2_0:
		ld	l, a
		ld	e,(hl)
		inc	hl
		ld	d,(hl)
		ex	de,hl	; HL = freq

		add	hl,hl
		ld	a,h
		add	a,c
		ld	h,a
play_wlnk_7:	
		ld	d,0
		ld	e,(iy + 5)
		bit	7,e
		jr	z,play_wlnk_6
		dec	d
play_wlnk_6:	
		add	hl,de	; detune...
		add	hl,de

		ld	(iy + 18),l	; freq fine
		ld	(iy + 19),h

		pop	bc
		ld	a,20h - 1
		add	a,b
		out	(MOON_WREG),a
		ld	a,l
		or	(iy + 6)
		nop
		out	(MOON_WDAT),a	; freq + tone

		ld	a,38h - 1
		add	a,b
		nop	
		out	(MOON_WREG),a
		ld	a,h
		or	(iy + 12)
		nop	
		out	(MOON_WDAT),a	; freq
		ret

play_wlnk3:	
		ld	l,(iy + 16)	; link own wave
		ld	h,(iy + 17)
		ld	e,a
		ld	d,0
		add	hl,de
		add	hl,de
		ld	e,(hl)
		inc	hl
		ld	d,(hl)
		ex	de,hl	; freq
		jp	play_wlnk_7


;--- Play stereo event ---

play_wchgste:	
		sub	178 + 7
play_wchgste2:	
		and	1111b
		ld	d,a
		ld	a,(iy+11)
		and	11110000b
		or	d
		ld	(iy+11),a
		ld	a,68h - 1
		add	a,b
		out	(MOON_WREG),a
		ld	(iy + 2),0
		nop
		in	a,(MOON_WDAT)
		and	11110000b
		or	d
		nop
		out	(MOON_WDAT),a
		ret

;--- Pitch bending ---

play_wchgpit:	
		sub	221
		ld	(iy+2),1	; Pitch bending on
		add	a,a
		add	a,a
		ld	(iy+3),a	; Set pitch bend speed
		rlca		; bit 7,a
		jr	c,play_wchgpit2
		ld	(iy+4),0
		ret

play_wchgpit2:	
		ld	(iy+4),0ffh
		ret


;--- Modulation event ---

play_wchgmod:	
		sub	238 - 2
		ld	(iy + 2),a
		add	a,a
		add	a,a
		add	a,a
		add	a,a
		ld	hl,xmodtab - 2 * 16
		add	a, l
		jr	nc,play_wchgmod_0
		inc	h
play_wchgmod_0:
		ld	l, a
		ld	(iy + 3),l
		ld	(iy + 4),h
		ret

;--- Set detune ---

play_wchgdet:	
		sub	234
		add	a,a
		add	a,a	; * 4
		ld	(iy + 5),a
		ret

;--- Damp ---

play_chgdmp:
		ld	a,068h - 1
		add	a,b	; calc. register
		out	(MOON_WREG),a
		ld	(iy+2),0	; pb/mod off
		nop
		in	a,(MOON_WDAT)
		or	1000000b
		nop	
		out	(MOON_WDAT),a
		ret

;--- Pseudo reverb on ---

play_chgpsr:	
		set	3,(iy+12)
		ret

;--- Pseudo reverb off ---

play_chgpso:	
		res	3,(iy+12)
		ret

;--- LFO ---

play_chglfo:	
		ld	a,068h - 1
		add	a,b	; calc. register
		out	(MOON_WREG),a
		nop
		in	a,(MOON_WDAT)
		xor	100000b
		nop
		out	(MOON_WDAT),a
		ret

;--- eXtra Lfo Settings

play_chgxls:
		sub	246
		add	a,a
		ld	hl,xls_tabel
		add	a, l
		jr	nc,play_chgxls_0
		inc	h
play_chgxls_0:
		ld	l, a
		ld	a,068h - 1
		add	a,b	; calc. register
		ld	d,a	; Save calculation for later
		out	(MOON_WREG),a
		nop	
		in	a,(MOON_WDAT)
		nop
		ld	c,a
		set	5,a
		out	(MOON_WDAT),a

		ld	a,080h - 1
		add	a,b	; calc. register
		out	(MOON_WREG),a
		ld	a,(hl)
		nop	
		out	(MOON_WDAT),a
		inc	hl

		ld	a,0E0h - 1
		add	a,b	; calc. register
		out	(MOON_WREG),a
		ld	a,(hl)
		nop	
		out	(MOON_WDAT),a
		nop	

		ld	a,d	; Reg d = #68
		out	(MOON_WREG),a
		nop
		ld	a,c	; Reg c = contents reg #68
		res	5,a
		out	(MOON_WDAT),a
		ret

xls_tabel:
		db	49,0
		db	50,0
		db	51,0
		db	52,0
		db	53,0
		db	54,0
		db	55,0
		db	58,5
		db	03,0

;--------------------------
;--- CMD Event routines ---
;--------------------------

;-- change tempo --

play_chgtmp:	
		cpl
		add	a,25 +1
		ld	(play_speed),a
		jp	play_cmdcnt

;-- change base frequency --

play_chgbasefr:
		ld	c,a
		ld	a,2
		out	(MOON_REG1),a
		ld	a,c
		sub	77
		nop
		out	(MOON_DAT1),a
		neg
		ld	(xhzequal),a
		jp	play_cmdcnt


;-- end of pattern --

play_endop:	
		ld	a,15
		ld	(play_step),a
		jp	play_cmdcnt

;--- set transpose ---

play_chgtrs:	
		sub	52
		ld	(play_tspval),a
		jp	play_cmdcnt

;---------------------------
;--- Go to next position ---
;---------------------------

play_nextpos:	
;		ld	a,(songdata_bank1)
;		call	selbank_FE	; this bank contains pattern addresses

		ld	a,(xleng)
		inc	a
		ld	b,a
		ld	a,(play_pos)
		inc	a
		cp	b
		jp	c,play_nextpos2
		ld	a,(xloop)
		cp	255
		call	z,play_nextstop	; stop song, want loop OFF

play_nextpos2:
		ld	(play_pos),a
		ld	hl,(pos_address)
		add	a, l
		jr	nc,play_nextpos2_0
		inc	h
play_nextpos2_0:
		ld	l, a
		ld	a,(hl)
		ld	(current_pat),a
		add	a,a
		ld	hl,(pat_address)
		add	a, l
		jr	nc,play_nextpos2_1
		inc	h
play_nextpos2_1:
		ld	l, a
		ld	e,(hl)
		inc	hl
		ld	d,(hl)
		ex	de,hl
		ld	a,h
		rlca
		rlca
		and	011b
		ld	de,songdata_bank1
		add	a, e
		jr	nc,play_nextpos2_2
		inc	d
play_nextpos2_2:
		ld	e, a
		ld	a,(de)
		ld	(songdata_bank),a
		ld	a,h
		and	00111111b
		ld	h,a
		ld	de,(songdata_adres)
		add	hl,de
		ret

play_nextstop:
		call	stop_music
		xor	a
		ret

;--------------------------------
;--- Pitch interrupt routines ---
;--------------------------------

;----- pitch bending/modulation -----

play_pitch:
		ld	iy,play_table_wav
		ld	de,PTW_SIZE
		ld	hl,play_pitchwvl2
		ld	b,WAVCHNS	; wave channels
play_pitchwlus:
		ld	a,(iy+2)
		or	a
		jp	nz,play_pitch_wdo
play_pitchwvl2:
		add	iy,de
		djnz	play_pitchwlus
		ret



;--- pitch bending ---

play_pitch_wdo:	
		exx

		ld	c,a

		ld	l,(iy + 3)	; pitch bend speed
		ld	h,(iy + 4)
		dec	c
		jp	nz,play_mod_wdo	; modulation
		ex	de,hl
play_pitch_wd4:
		ld	h,(iy + 19)
		ld	l,(iy + 18)
		add	hl,de	; sliding
		bit	3,h
		jr	z,play_pitch_wd5
		bit	7,d
		jr	nz,play_pitch_wd6
		ld	a,h
		add	a,1000b
		ld	h,a
		jr	play_pitch_wd5
play_pitch_wd6:
		res	3,h
play_pitch_wd5:
		ld	(iy + 18),l	; freq fine
		ld	(iy + 19),h
		ld	a,(iy + 1)
		ld	c,a
		out	(MOON_WREG),a
		ld	a,l
		or	(iy + 6)
		nop
		out	(MOON_WDAT),a	; freq + tone

		ld	a,c
		add	a,24
		nop
		out	(MOON_WREG),a
		ld	a,h
		nop
		out	(MOON_WDAT),a	; freq
		exx
		jp	(hl)


;---- modulation ----

play_mod_wdo:
		ld	d,0
		ld	a,(hl)
		add	a,a
		add	a,a
		ld	e,a
		jr	nc,play_mod_wdo3
		dec	d
play_mod_wdo3:
		inc	hl
		ld	a,(hl)
		cp	10
		jp	nz,play_mod_wdo2
		ld	a,c

		ld	hl,xmodtab - 16
		add	a,a
		add	a,a
		add	a,a
		add	a,a
		add	a, l
		jr	nc,play_mod_wdo_0
		inc	h
play_mod_wdo_0:
		ld	l, a
play_mod_wdo2:
		ld	(iy + 3),l
		ld	(iy + 4),h
		jp	play_pitch_wd4


;-------------------------------
;--- Fade interrupt routines ---
;-------------------------------


play_fade:	
		ld	a,(play_fadespd)	; speed
		ld	hl,play_fadecnt
		inc	(hl)
		cp	(hl)
		ret	nz
		ld	(hl),0

		ld	b,WAVCHNS
		ld	iy,play_table_wav
		ld	de,PTW_SIZE
play_fadelp:	
		ld	a,(iy + 15)
		add	a,8	; -4, but bit 0 is not for volume
		jr	nc,play_fade2
		ld	a,255
play_fade2:	
		ld	(iy + 15),a
		ld	a,050h - 1
		add	a,b
		out	(MOON_WREG),a
		ld	a,(iy + 15)	; level direct
		nop	
		out	(MOON_WDAT),a
		add	iy,de
		djnz	play_fadelp

		ld	hl,play_fadetcnt	; total counter
		inc	(hl)
		ld	a,(hl)
		cp	33	; will always be faded out in 33 steps
		ret	nz
		xor	a
		ld	(play_fading),a
		jp	stop_music

;----------------
;--- OPL4 out ---
;----------------

opl4_out_wave:	
		ex	af,af'
		ld	a,c
		nop
		out	(MOON_WREG),a
		ex	af,af'
		nop
		out	(MOON_WDAT),a
		ret

		.include	"freq_table_0.inc"
		.include	"patch_table.inc"
		.include	"freq_table_1.inc"

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

play_table_wav:
		db	0,037h,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0	; ch1
		db	0,036h,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0	; ch2
		db	0,035h,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0	; ch3
		db	0,034h,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0	; ch4
		db	0,033h,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0	; ch5
		db	0,032h,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0	; ch6
		db	0,031h,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0	; ch7
		db	0,030h,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0	; ch8
		db	0,02fh,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0	; ch9
		db	0,02eh,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0	; ch10
		db	0,02dh,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0	; ch11
		db	0,02ch,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0	; ch12
		db	0,02bh,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0	; ch13
		db	0,02ah,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0	; ch14
		db	0,029h,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0	; ch15
		db	0,028h,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0	; ch16
		db	0,027h,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0	; ch17
		db	0,026h,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0	; ch18
		db	0,025h,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0	; ch19
		db	0,024h,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0	; ch20
		db	0,023h,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0	; ch21
		db	0,022h,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0	; ch22
		db	0,021h,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0	; ch23
		db	0,020h,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0	; ch24

play_busy:	
		db	0		; status:   0 = not playing,  255 = playing
songdata_bank1:	
		db	0		; mapperbank with song data
songdata_adres:	
		dw	0		; address of song data
play_pos:	
		db	0		; current position
play_step:	
		db	0		; current step
status:	
		db	0,0,0		; status bytes (0 = off)
step_buffer:	
		ds	24		; decrunched step, played next int

songdata_bank:	
		db	0
play_speed:	
		db	0		; current play speed
play_tspval:	
		db	0		; current transpose
play_timercnt:	
		db	0		; tempo counter
current_pat:	
		db	0
play_fading:	
		db	0
play_fadecnt:	
		db	0
play_fadespd:	
		db	0
play_fadetcnt:	
		db	0
;-------------------------------------------------------------------
; описание: »нформаци€ о треке = 220 байт
; параметры: нет
; возвращаемое  значение: нет
;---------------------------------------------------------------------
xleng:	
		ds	1		; Song length
xloop:		
		ds	1		; Loop position
xwvstpr:	
		ds	24		; Stereo settings Wave
xtempo:		
		ds	1		; Tempo
xhzequal:	
		ds	1		; Base frequency
xdetune:		
		ds	24		; Detune settings
xmodtab:		
		ds	3*16		; Modulation tables
xbegwav:		
		ds	24		; Start waves
xwavnrs:	
		ds	48	; Wave numbers
xwavvols:	
		ds	48	; Wave volumes

pat_address:	
		dw	0
pos_address:	
		dw	0
songdata_ptr:	
		dw	0
waves:	
		ds	48 * 25
tones_data:	
		ds	64


