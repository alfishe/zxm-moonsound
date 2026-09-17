		DEVICE ZXSPECTRUM128

MOON_BASE:	equ	0C4h
MOON_REG1:	equ	MOON_BASE
MOON_DAT1:	equ	MOON_BASE+1
MOON_REG2:	equ	MOON_BASE+2
MOON_DAT2:	equ	MOON_BASE+3
MOON_STAT:	equ	MOON_BASE

MOON_WREG:	equ	7Eh
MOON_WDAT:	equ	MOON_WREG+1

PTW_SIZE:		equ	13	; size of Wave playtable line


MBPlayer_play_busy:	 equ	0da00h	; status:   0 = not playing
					;           255 = playing
MBPlayer_songdata_bank1: equ	0da01h	; mapperbank with song data
MBPlayer_songdata_bank2: equ	0da02h	; mapperbank with song data
MBPlayer_songdata_bank3: equ	0da03h	; mapperbank with song data
MBPlayer_songdata_adres: equ	0da04h	; address of song data
MBPlayer_play_pos:	 equ	0da06h	; current position
MBPlayer_play_step:	 equ	0da07h	; current step
MBPlayer_status:	 equ	0da08h	; status bytes (0 = off)
MBPlayer_step_buffer:	 equ	0da0bh	; decrunched step, played next int
MBPlayer_step_buffer_1:	 equ	0da1dh	; 6 bytes
MBPlayer_load_buffer:	 equ	0da23h
MBPlayer_freeDOS2segs:	 equ	0da26h
MBPlayer_upper_fcb:	 equ	0da40h


		.org 4000h

MFM_Player_Start:
		db 	"AB"
		db    	0 ;  
		db    	0 ;  
		dw 	loc_0_4010
		db    	0 ;  
		db    	0 ;  
		db    	0 ;  
		db    	0 ;  
		db    	0 ;  
		db    	0 ;  
		db    	0
		db    	0
		db    	0
		db    	0
;-------------------------------------------------------------------
; описание: Драйвер проигрыватель мелодий редактора MoonBlaster для MoonSound 
; параметры: нет
; возвращаемое  значение: нет
;---------------------------------------------------------------------
loc_0_4010:
		push	hl
		ld	de, aR800

loc_0_4014:
		ld	hl, 0FD89h

loc_0_4017:
		ld	a, (de)
		cp	(hl)
		jr	nz, loc_0_4022
		or	a
		jr	z, loc_0_4035
		inc	hl
		inc	de
		jr	loc_0_4017

loc_0_4022:
		ld	a, (de)
		or	a
		jr	z, loc_0_4029
		inc	de
		jr	loc_0_4022

loc_0_4029:
		inc	de
		inc	de
		inc	de
		ld	a, (de)
		inc	a
		jr	z, loc_0_4032
		jr	loc_0_4014


loc_0_4032:
		pop	hl
		scf	
		ret	


loc_0_4035:
		ex	de, hl
		inc	hl
		ld	e, (hl)
		inc	hl
		ld	d, (hl)
		pop	hl
		call	sub_0_4040
		and	a
		ret	


sub_0_4040:
		push	de
		ret	
;-------------------------------------------------------------------
; описание: Функция MBPLAY - старт музыки
; параметры: нет
; возвращаемое  значение: нет
;---------------------------------------------------------------------
MBPlayer_mbplay:
		push	hl
		call	MBPlayer_start_music
		pop	hl
		ret	
;-------------------------------------------------------------------
; описание: Функция MBSTOP - останов музыки
; параметры: нет
; возвращаемое  значение: нет
;---------------------------------------------------------------------
MBPlayer_mbstop:
		push	hl
		call	MBPlayer_stop_music
		pop	hl
		ret	
;-------------------------------------------------------------------
; описание: Функция MBCONT - продолжение воспроизведения музыки
; параметры: нет
; возвращаемое  значение: нет
;---------------------------------------------------------------------
MBPlayer_mbcont:
		push	hl
		call	MBPlayer_continue_music
		pop	hl
		ret	
;-------------------------------------------------------------------
; описание: Функция MBHALT - приостановка воспроизведения музыки
; параметры: нет
; возвращаемое  значение: нет
;---------------------------------------------------------------------
MBPlayer_mbhalt:
		push	hl
		call	MBPlayer_halt_music
		pop	hl
		ret	
;-------------------------------------------------------------------
; описание: Функция MBBANK1 - установка 1 банка памяти
; параметры: нет
; возвращаемое  значение: нет
;---------------------------------------------------------------------
MBPlayer_mbbank1:
		call	MBPlayer_mbbank
		ld	(MBPlayer_songdata_bank1), a
		ret	
;-------------------------------------------------------------------
; описание: Функция MBBANK2 - установка 2 банка памяти
; параметры: нет
; возвращаемое  значение: нет
;---------------------------------------------------------------------
MBPlayer_mbbank2:
		call	MBPlayer_mbbank
		ld	(MBPlayer_songdata_bank2), a
		ret	
;-------------------------------------------------------------------
; описание: Функция MBBANK3 - установка 3 банка памяти
; параметры: нет
; возвращаемое  значение: нет
;---------------------------------------------------------------------
MBPlayer_mbbank3:
		call	MBPlayer_mbbank
		ld	(MBPlayer_songdata_bank3), a
		ret	
;-------------------------------------------------------------------
; описание: Вычисление свободного банка памяти
; параметры: нет
; возвращаемое  значение: нет
;---------------------------------------------------------------------
MBPlayer_mbbank:
		ld	ix, 521Ch
		call	MBPlayer_basic_call
		push	hl
		push	af
		ld	a, (MBPlayer_play_busy)
		or	a
		call	nz, MBPlayer_stop_music
		pop	af
		pop	hl
		ret	

;-------------------------------------------------------------------
; описание: Установка рабочего адреса музыки
; параметры: нет
; возвращаемое  значение: нет
;---------------------------------------------------------------------
MBPlayer_mbaddr:
		ld	ix, 542Fh
		call	MBPlayer_basic_call
		push	hl
		push	de
		ld	a, (MBPlayer_play_busy)
		or	a
		call	nz, MBPlayer_stop_music
		pop	de
		pop	hl
		ld	(MBPlayer_songdata_adres), de
		ret	
;-------------------------------------------------------------------
; описание: Загрузка MFM файла
; параметры: нет
; возвращаемое  значение: нет
;---------------------------------------------------------------------
MBPlayer_load_mwm:
		ld	ix, 4C64h
		call	MBPlayer_basic_call
		push	hl

		ld	ix, 67D0h	
		call	MBPlayer_basic_call
		push	hl
		pop	ix

		call	MBPlayer_build_fcb

		call	MBPlayer_getbank_FE

		push	af
		call	MBPlayer_open_file
		or	a
		jp	nz, MBPlayer_error_open
		ld	hl, MBPlayer_songdata_bank1
		ld	(MBPlayer_load_bank), hl

		ld	a, (hl)
		call	MBPlayer_selbank_FE

		ld	hl, 6
		ld	de, (MBPlayer_songdata_adres)
		call	MBPlayer_load_file
		call	MBPlayer_check_header
		jr	nz, MBPlayer_error_compatible

		ld	hl, 812					
		ld	de, (MBPlayer_songdata_adres)
		call	MBPlayer_load_file
		ld	a, (de)
		add	hl, de
		ex	de, hl
		inc	a
		ld	l, a
		ld	h, 0
		call	MBPlayer_load_file
		call	MBPlayer_check_pats
		add	hl, de
		ex	de, hl
		add	a, a
		ld	l, a
		ld	h, 0
		call	MBPlayer_load_file
		add	hl, de
		ld	(MBPlayer_load_addres), hl

loc_0_40F6:
		ld	de, MBPlayer_load_buffer
		ld	hl, 3
		call	MBPlayer_load_file
		ld	a, (0DA25h)
		or	a
		jr	z, loc_0_4123
		ld	de, (MBPlayer_load_addres)
		ld	hl, (MBPlayer_load_buffer)
		call	MBPlayer_load_file
		ld	de, 8000h
		ld	(MBPlayer_load_addres), de
		ld	hl, (MBPlayer_load_bank)
		inc	hl
		ld	a, (hl)
		ld	(MBPlayer_load_bank), hl
		call	MBPlayer_selbank_FE
		jr	loc_0_40F6


loc_0_4123:
		call	MBPlayer_close_file
		pop	af
		call	MBPlayer_selbank_FE
		call	sub_0_4F84
		pop	hl
		ret	
;-------------------------------------------------------------------
; описание: Сообщение об ошибке несовместимости файла музыки
; параметры: нет
; возвращаемое  значение: нет
;---------------------------------------------------------------------
MBPlayer_error_compatible:
		ld	hl, aNotACompatible
		jr	loc_0_4137
;-------------------------------------------------------------------
; описание: Сообщение об ошибке открытия файла
; параметры: нет
; возвращаемое  значение: нет
;---------------------------------------------------------------------
MBPlayer_error_open:
		ld	hl, aMoonblasterLoa

loc_0_4137:
		call	MBPlayer_print
		call	0C0h
		pop	af
		call	MBPlayer_selbank_FE
		pop	hl
		ld	ix, 409Bh
		jp	MBPlayer_basic_call
;-------------------------------------------------------------------
; описание: Проверка заголовка файла
; параметры: DE - адрес данных
; возвращаемое  значение: нет
;---------------------------------------------------------------------
MBPlayer_check_header:
		ld	hl, aMbms
		ld	b, 6
loc_0_414E:
		ld	a, (de)
		cp	(hl)
		ret	nz
		inc	hl
		inc	de
		djnz	loc_0_414E
		ret	
;-------------------------------------------------------------------
; описание: Поиск максимального номера паттерна
; параметры: DE - адрес поиска
;	     L - число байт в массиве
; возвращаемое  значение: нет
;---------------------------------------------------------------------
MBPlayer_check_pats:
		push	hl
		push	de
		ld	b, l
		ex	de, hl
		xor	a
loc_0_415B:
		cp	(hl)
		jr	nc, loc_0_415F
		ld	a, (hl)

loc_0_415F:
		inc	hl
		djnz	loc_0_415B
		inc	a
		pop	de
		pop	hl
		ret	
;-------------------------------------------------------------------
; описание: Функция MBVER - запрос версии драйвера
; параметры: нет
; возвращаемое  значение: нет
;---------------------------------------------------------------------
MBPlayer_mbver:
		push	hl
		ld	hl, aMoonblasterFor
		call	MBPlayer_print
		pop	hl
		ret	

;-------------------------------------------------------------------
; описание: Создание описателя файла
; параметры: нет
; возвращаемое  значение: нет
;---------------------------------------------------------------------
MBPlayer_build_fcb:
		ld	hl, unk_0_4F8E
		ld	de, MBPlayer_upper_fcb
		ld	bc, 25h	; '%'
		ldir	
		ld	a, (ix + 0)
		ld	e, (ix + 1)
		ld	d, (ix + 2)
		ld	hl, 0DA41h
		ld	b, 9

loc_0_4188:
		ld	a, (de)
		cp	2Eh ; '.'
		jr	z, loc_0_4192
		ld	(hl), a
		inc	hl
		inc	de
		djnz	loc_0_4188

loc_0_4192:
		inc	de
		ex	de, hl
		ld	de, 0DA49h
		ld	bc, 3
		ldir	
		ret	
;-------------------------------------------------------------------
; описание: Вызов фунукий DOS
; параметры: IX - номер функции
; возвращаемое  значение: нет
;---------------------------------------------------------------------
MBPlayer_basic_call:
		ld	iy, (0FCC1h)
		jp	1Ch
;-------------------------------------------------------------------
; описание: Вывод текстовой строки 
; параметры: HL - адрес строки
; возвращаемое  значение: нет
;---------------------------------------------------------------------
MBPlayer_print:
		ld	a, (hl)
		or	a
		ret	z
		rst	18h
		inc	hl
		jr	MBPlayer_print
;-------------------------------------------------------------------
; описание: Инициализация проигрывателя
; параметры: нет
; возвращаемое  значение: нет
;---------------------------------------------------------------------
MBPlayer_start_music:
		di	
		ld	a, (MBPlayer_play_busy)
		or	a
		ret	nz

		ld	hl, 0
		ld	(MBPlayer_status), hl
		ld	(MBPlayer_status + 1), hl
		ld	a, 0FFh
		ld	(MBPlayer_play_busy), a
		xor	a
		ld	(byte_0_4F4E), a
		ld	a, 0Fh
		ld	(MBPlayer_play_step), a
		ld	a, 0FFh
		ld	(MBPlayer_play_pos), a

		call	MBPlayer_getbank_FE
		push	af

		ld	a, (MBPlayer_songdata_bank1)
		call	MBPlayer_selbank_FE

		ld	hl, (MBPlayer_songdata_adres)
		ld	de, MBPlayer_xleng
		ld	bc, 718				;2CEh
		ldir	
		ld	de, 94				;5Eh
		add	hl, de
		ld	(MBPlayer_pos_address), hl
		ld	a, (MBPlayer_xleng)
		inc	a
		ld	e, a
		add	hl, de
		ld	(MBPlayer_pat_address), hl

		pop	af
		call	MBPlayer_selbank_FE

		call	MBPlayer_init_opl4

		ld	a, (MBPlayer_play_speed)
		sub	2
		ld	(MBPlayer_play_timercnt), a

loc_0_4201:
		di	
		ld	hl, 0FD9Fh
		ld	de, locret_0_44B2
		ld	bc, 5
		ldir	
		ld	a, (0F342h)
		ld	(unk_0_4221), a
		ld	hl, MBPlayer_interrupt
		ld	de, 0FD9Fh
		ld	bc, 5
		ldir	
		ei	
		ret	
;-------------------------------------------------------------------
; описание: Вход в обработчик прерывания
; параметры: нет
; возвращаемое  значение: нет
;---------------------------------------------------------------------
MBPlayer_interrupt:
		rst	30h

unk_0_4221:	db    	0 
		dw 	MBPlayer_play_music
		ret	
;-------------------------------------------------------------------
; описание: Инициализация OPL4 регистров
; параметры: нет
; возвращаемое  значение: нет
;---------------------------------------------------------------------
MBPlayer_init_opl4:
		ld	a, 3
		ld	c, 5
		call	MBPlayer_out_fm2
		ld	a, 40h
		ld	c, 8
		call	MBPlayer_out_fm1
		ld	a, (MBPlayer_play_chvol_1)
		ld	hl, unk_0_4F43
		add	a, l
		jr	nc, loc_0_423D
		inc	h

loc_0_423D:
		ld	l, a
		ld	a, (hl)
		ld	c, 4
		call	MBPlayer_out_fm2
		ld	c, 2
		ld	a, 10h
		call	MBPlayer_out_wave
		ld	a, (MBPlayer_play_chvol_1)
		add	a, a
		ld	b, a
		ld	a, 12h
		sub	b
		ld	(MBPlayer_play_chvol_2), a
		call	sub_0_4264
		ld	a, (MBPlayer_xtempo)
		ld	(MBPlayer_play_speed), a
		xor	a
		ld	(MBPlayer_play_tspval), a
		ret	


sub_0_4264:
		ld	ix, unk_0_5368
		ld	de, PTW_SIZE
		ld	a, (MBPlayer_play_chvol_1)
		or	a
		jr	z, loc_0_4296
		ld	iy, MBPlayer_play_table_wav_1
		ld	b, a

loc_0_4276:
		exx	
		ld	a, (ix - 49h)
		ld	(iy + 7), a
		ld	a, (ix + 0)
		ld	hl, loc_0_4286
		jp	loc_0_46FB


loc_0_4286:
		ld	a, (ix - 64h)
		ld	hl, loc_0_428F
		jp	loc_0_4791


loc_0_428F:
		inc	ix
		exx	
		add	iy, de
		djnz	loc_0_4276

loc_0_4296:
		ld	iy, MBPlayer_play_table_wav_2
		ld	a, (MBPlayer_play_chvol_2)
		ld	b, a

loc_0_429E:
		exx	
		ld	a, (ix - 49h)
		ld	(iy + 7), a
		ld	a, (ix + 0)
		ld	hl, loc_0_42AE
		jp	loc_0_4695

loc_0_42AE:
		ld	a, (ix - 64h)
		ld	hl, loc_0_42B7
		jp	loc_0_4773


loc_0_42B7:
		inc	ix
		exx	
		add	iy, de
		djnz	loc_0_429E
		ld	b, 6
		ld	iy, MBPlayer_play_table_wav_3
		ld	ix, unk_0_537A
		ld	de, 12h

loc_0_42CB:
		push	de
		push	bc
		ld	a, (ix - 49h)
		add	a, a
		ld	(iy + 5), a
		ld	a, (ix + 0)
		push	af
		call	MBPlayer_play_wwavevt2
		pop	af
		ld	hl, MBPlayer_xwavvols - 1
		add	a, l
		jr	nc, loc_0_42E3
		inc	h

loc_0_42E3:
		ld	l, a
		ld	a, (hl)
		ld	(iy + 0Fh), a
		call	MBPlayer_play_wchgvol2
		ld	a, (ix - 64h)
		call	MBPlayer_play_wchgste2
		inc	ix
		pop	bc
		pop	de
		add	iy, de
		djnz	loc_0_42CB

		ld	c, 0BDh
		ld	a, (byte_0_531E)
		jp	MBPlayer_out_fm1
;-------------------------------------------------------------------
; описание: Возобновление проигрывания
; параметры: нет
; возвращаемое  значение: нет
;---------------------------------------------------------------------
MBPlayer_continue_music:
		ld	a, (MBPlayer_play_busy)
		or	a
		ret	nz
		dec	a
		ld	(MBPlayer_play_busy), a
		jp	loc_0_4201
;-------------------------------------------------------------------
; описание: Остановка проигрывания
; параметры: нет
; возвращаемое  значение: нет
;---------------------------------------------------------------------
MBPlayer_stop_music:
		jr	MBPlayer_halt_music
;-------------------------------------------------------------------
; описание: Остановка проигрывания
; параметры: нет
; возвращаемое  значение: нет
;---------------------------------------------------------------------
MBPlayer_halt_music:
		ld	a, (MBPlayer_play_busy)
		or	a
		ret	z

		di	
		xor	a
		ld	(MBPlayer_play_busy), a
		ld	hl, locret_0_44B2
		ld	de, 0FD9Fh
		ld	bc, 5
		ldir	
		ei	

		ld	de, PTW_SIZE
		ld	a, (MBPlayer_play_chvol_1)
		or	a
		jr	z, loc_0_433A
		ld	b, a
		ld	iy, MBPlayer_play_table_wav_1

loc_0_4333:
		call	sub_0_435E
		add	iy, de
		djnz	loc_0_4333

loc_0_433A:
		ld	a, (MBPlayer_play_chvol_2)
		ld	b, a
		ld	iy, MBPlayer_play_table_wav_2

loc_0_4342:
		call	sub_0_435E
		add	iy, de
		djnz	loc_0_4342
		ld	b, 6
		ld	iy, MBPlayer_play_table_wav_3
		ld	de, 12h

loc_0_4352:
		call	MBPlayer_play_woffevt
		call	MBPlayer_play_wchgdmp
		add	iy, de
		djnz	loc_0_4352
		ei	
		ret	

sub_0_435E:
		push	bc
		ld	b, (iy + 2)
		xor	a
		call	sub_0_4BB3
		set	4, b
		call	sub_0_4BB3
		pop	bc
		ret	
;-------------------------------------------------------------------
; описание: Проигрывание музыки по прерываниям
; параметры: нет
; возвращаемое  значение: нет
;---------------------------------------------------------------------
MBPlayer_play_music:
		di	
		ld	a, (MBPlayer_xhzequal)
		or	a
		jr	z, loc_0_438A
		ld	a, (0FFE8h)
		and	2
		jr	nz, loc_0_438A

		ld	hl, byte_0_4F4E
		ld	a, (hl)
		inc	a
		cp	6
		jr	c, loc_0_4389
		ld	(hl), 0
		jp	locret_0_44B2

loc_0_4389:
		ld	(hl), a

loc_0_438A:
		call	sub_0_4A9A
		call	MBPlayer_getbank_FE
		push	af

		ld	a, (MBPlayer_play_speed)
		ld	hl, MBPlayer_play_timercnt
		inc	(hl)
		cp	(hl)
		jp	nz, MBPlayer_play_int_sec
		ld	(hl), 0
		ld	a, (MBPlayer_songdata_bank)
		call	MBPlayer_selbank_FE

		call	MBPlayer_play_wtones

		ld	hl, MBPlayer_step_buffer
		ld	de, PTW_SIZE			;размер данных
		ld	a, (MBPlayer_play_chvol_1)
		or	a
		jp	z, loc_0_43F8
		ld	b, a				;число каналов
		ld	iy, MBPlayer_play_table_wav_1

loc_0_43B9:
		ld	a, (hl)
		or	a
		jp	z, loc_0_43F3
		exx	

		ld	hl, MBPlayer_play_int_wend_1
		cp	97
		jp	c, MBPlayer_play_wonevt_1 	; wave on
		jp	z, loc_0_467D
		cp	122
		jp	c, loc_0_46F9
		cp	186
		jp	c, loc_0_476C
		cp	189
		jp	c, loc_0_478B
		cp	208
		jp	c, loc_0_47B8
		cp	227
		jp	c, loc_0_47F5
		cp	240
		jp	c, loc_0_4849
		cp	247
		jp	c, loc_0_484A
		cp	250
		jp	c, loc_0_4851

MBPlayer_play_int_wend_1:
		exx	

loc_0_43F3:
		add	iy, de
		inc	hl
		djnz	loc_0_43B9

loc_0_43F8:
		ld	iy, MBPlayer_play_table_wav_2
		ld	a, (MBPlayer_play_chvol_2)
		ld	b, a

loc_0_4400:
		ld	a, (hl)
		or	a
		jp	z, loc_0_443A
		exx	
		ld	hl, MBPlayer_play_int_wend_2
		cp	97
		jp	c, MBPlayer_play_wonevt_1 	; wave on
		jp	z, loc_0_467D
		cp	122
		jp	c, loc_0_4693
		cp	186
		jp	c, loc_0_4758
		cp	189
		jp	c, loc_0_476D
		cp	208
		jp	c, loc_0_47B8
		cp	227
		jp	c, loc_0_47F5
		cp	240
		jp	c, loc_0_482D
		cp	247
		jp	c, loc_0_484A
		cp	250
		jp	c, loc_0_4851

MBPlayer_play_int_wend_2:
		exx	

loc_0_443A:
		add	iy, de
		inc	hl
		djnz	loc_0_4400
		ld	a, (MBPlayer_play_chvol_1)
		add	a, l
		jr	nc, loc_0_4446
		inc	h

loc_0_4446:
		ld	l, a

loc_0_4447:
		in	a, (0C4h)
		bit	1, a
		jr	nz, loc_0_4447

		ld	iy, MBPlayer_play_table_wav_3
		ld	b, 6
		ld	de, 12h

loc_0_4456:
		ld	a, (hl)
		or	a
		jr	z, loc_0_4494

		ex	af, af'
		ld	a, b
		exx	
		ld	b, a
		ex	af, af'

		ld	de, MBPlayer_play_int_wend_3
		push	de
		cp	97
		jp	c, MBPlayer_play_wonevt 	; wave on
		jp	z, MBPlayer_play_woffevt        ; wave off
		cp	146
		jp	c, MBPlayer_play_wwavevt        ; wave
		cp	178
		jp	c, MBPlayer_play_wchgvol        ; volume
		cp	193
		jp	c, MBPlayer_play_wchgste        ; stereo
		cp	212
		jp	c, MBPlayer_play_wlnk           ; link
		cp	231
		jp	c, MBPlayer_play_wchgpit        ; pitch bending
		cp	238
		jp	c, MBPlayer_play_wchgdet        ; detune
		cp	241
		jp	c, MBPlayer_play_wchgmod        ; modulation
		cp	243
		jp	c, MBPlayer_play_wchgdmp        ; damp

MBPlayer_play_int_wend_3:
		exx	

loc_0_4494:
		add	iy, de
		inc	hl
		djnz	loc_0_4456
		ld	a, (hl)
		or	a
		jr	z, loc_0_44AE
		cp	18h
		jp	c, loc_0_4A29
		jp	z, loc_0_4A33
		cp	1Ch
		jr	c, loc_0_44AE
		cp	4Ch ; 'L'
		jp	c, MBPlayer_play_chgtrs

loc_0_44AE:
		pop	af
		call	MBPlayer_selbank_FE

locret_0_44B2:
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
		jr	nz, loc_0_44AE
		ld	a, (MBPlayer_play_step)
		inc	a
		and	0Fh
		ld	(MBPlayer_play_step), a
		ld	hl, (MBPlayer_songdata_ptr)
		call	z, MBPlayer_play_nextpos
		ld	a, (MBPlayer_songdata_bank)
		call	MBPlayer_selbank_FE

		ld	de, MBPlayer_step_buffer
		ld	a, (hl)
		inc	hl
		cp	255
		jp	nz, loc_0_44EB
		exx	
		ld	hl, MBPlayer_step_buffer
		ld	de, MBPlayer_step_buffer + 1
		ld	bc, 24
		ld	(hl), b
		ldir	
		exx	
		jp	loc_0_450A


loc_0_44EB:
		ld	(de), a
		inc	de
		push	hl
		inc	hl
		inc	hl
		inc	hl
		exx	
		pop	hl
		ld	b, 3

loc_0_44F5:
		ld	a, (hl)
		exx	
		ld	b, 8
		ld	c, a

loc_0_44FA:
		xor	a
		rlc	c
		jr	nc, loc_0_4501
		ld	a, (hl)
		inc	hl

loc_0_4501:
		ld	(de), a
		inc	de
		djnz	loc_0_44FA
		exx	
		inc	hl
		djnz	loc_0_44F5
		exx	

loc_0_450A:
		ld	(MBPlayer_songdata_ptr), hl
		ld	hl, MBPlayer_step_buffer
		ld	de, PTW_SIZE
		ld	a, (MBPlayer_play_chvol_1)
		or	a
		jp	z, loc_0_4522
		ld	iy, MBPlayer_play_table_wav_1
		ld	b, a
		call	sub_0_4530

loc_0_4522:
		ld	iy, MBPlayer_play_table_wav_2
		ld	a, (MBPlayer_play_chvol_2)
		ld	b, a
		call	sub_0_4530
		jp	loc_0_4565

sub_0_4530:
		exx	
		ld	a, (MBPlayer_play_tspval)
		ld	b, a
		exx	

loc_0_4536:
		ld	a, (hl)
		dec	a
		cp	60h ; '`'
		jr	nc, loc_0_455F
		exx	
		ld	(iy + 4), 0
		add	a, b
		ld	(iy + 1), a
		ld	hl, unk_0_4CC8
		add	a, a
		add	a, l
		jr	nc, loc_0_454D
		inc	h

loc_0_454D:
		ld	l, a
		ld	d, (hl)
		dec	hl
		ld	e, (hl)
		inc	de
		ld	a, (iy + 7)
		add	a, e
		ld	e, a
		dec	de
		ld	(iy + 9), d
		ld	(iy + 0Ah), e
		exx	

loc_0_455F:
		add	iy, de
		inc	hl
		djnz	loc_0_4536
		ret	


loc_0_4565:
		ld	a, (MBPlayer_play_chvol_1)
		add	a, l
		jr	nc, loc_0_456C
		inc	h

loc_0_456C:
		ld	l, a
		ld	bc, 660h
		ld	iy, MBPlayer_play_table_wav_3
		ld	de, 12h

loc_0_4577:
		ld	a, (hl)
		dec	a
		cp	c
		jp	c, loc_0_4585

loc_0_457D:
		add	iy, de
		inc	hl
		djnz	loc_0_4577
		jp	loc_0_44AE


loc_0_4585:
		ld	(iy + 2), 0
		exx	
		ld	d, a
		ld	hl, off_0_53C0
		ld	b, 0
		ld	c, (iy + 0Ah)
		ld	a, c
		cp	0AFh ; 'Ї'
		jp	z, loc_0_461E

loc_0_4599:
		ld	a, d
		add	hl, bc
		add	hl, bc
		ld	e, (hl)
		inc	hl
		ld	d, (hl)
		ex	de, hl
		ld	e, (hl)
		inc	hl
		ld	c, (hl)
		inc	hl
		ld	b, (hl)
		inc	hl
		ld	(iy + 0Dh), c
		ld	(iy + 0Eh), b
		bit	0, e
		jr	z, loc_0_45B5
		ld	b, a
		ld	a, (MBPlayer_play_tspval)
		add	a, b

loc_0_45B5:
		ld	b, 0
		ld	de, 5

loc_0_45BA:
		cp	(hl)
		jr	c, loc_0_45D1
		ld	b, (hl)
		add	hl, de
		cp	(hl)
		jr	c, loc_0_45D1
		ld	b, (hl)
		add	hl, de
		cp	(hl)
		jr	c, loc_0_45D1
		ld	b, (hl)
		add	hl, de
		cp	(hl)
		jr	c, loc_0_45D1
		ld	b, (hl)
		add	hl, de
		jp	loc_0_45BA

loc_0_45D1:
		ld	d, a
		inc	hl
		ld	a, (hl)
		ld	(iy + 7), a
		inc	hl
		ld	a, (hl)
		and	1
		ld	(iy + 6), a
		ld	a, (hl)
		rra	
		add	a, d
		sub	b
		ld	(iy + 0), a
		inc	hl
		ld	e, (hl)
		inc	hl
		ld	d, (hl)
		ld	(iy + 11h), d
		ld	(iy + 10h), e
		ld	hl, tabdiv12
		ld	c, a
		ld	b, 0
		add	hl, bc
		add	hl, bc
		ld	c, (hl)
		inc	hl
		ld	a, (hl)
		ex	de, hl
		add	a, l
		jr	nc, loc_0_45FF
		inc	h

loc_0_45FF:
		ld	l, a
		ld	e, (hl)
		inc	hl
		ld	d, (hl)
		sla	e
		ld	a, d
		rla	
		add	a, c
		ld	d, a
		ld	h, b

loc_0_460A:
		ld	l, (iy + 5)
		bit	7, l
		jr	z, loc_0_4612
		dec	h

loc_0_4612:
		add	hl, hl
		add	hl, de
		ld	(iy + 8), l
		ld	(iy + 9), h
		exx	
		jp	loc_0_457D

loc_0_461E:
		ld	a, d
		cp	24h ; '$'
		jp	c, loc_0_4599
		cp	53h ; 'S'
		jp	c, loc_0_462B
		ld	a, 52h ; 'R'

loc_0_462B:
		ld	hl, gmdrm_c4
		sub	24h ; '$'
		ld	b, a
		add	a, a
		add	a, a
		add	a, b
		add	a, l
		jr	nc, loc_0_4638
		inc	h
loc_0_4638:
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
		jp	loc_0_460A
;-------------------------------------------------------------------
; описание: Play ON event
; параметры: нет
; возвращаемое  значение: нет
;---------------------------------------------------------------------
MBPlayer_play_wonevt_1:
		ld	c, (iy + 0)
		ld	e, (iy + 2)
		ld	b, e
		set	4, e
		out	(c), e
		inc	c
		ld	a, (iy + 9)
		out	(c), a
		dec	c
		out	(c), b
		ld	d, (iy + 0Ah)
		inc	c
		out	(c), d
		ld	(iy + 0Bh), d
		dec	c
		out	(c), e
		or	20h ; ' '
		ld	(iy + 0Ch), a
		inc	c
		out	(c), a
		jp	(hl)

loc_0_467D:
		ld	(iy + 4), 0
		ld	a, (iy + 2)
		or	10h
		ld	c, (iy + 0)
		out	(c), a
		inc	c
		in	a, (c)
		and	0DFh ; 'Я'
		out	(c), a
		jp	(hl)

loc_0_4693:
		sub	61h ; 'a'
loc_0_4695:
		push	hl
		ld	(iy + 4), 0
		ld	hl, unk_0_4F2A
		add	a, l
		jr	nc, loc_0_46A1
		inc	h
loc_0_46A1:
		ld	l, a
		ld	a, (hl)
		ld	hl, unk_0_50F4
		add	a, l
		jr	nc, loc_0_46AA
		inc	h
loc_0_46AA:
		ld	l, a
		ex	de, hl
		ld	a, (MBPlayer_play_chvol_2)
		exx	
		sub	b
		exx	
		add	a, a
		add	a, a

		ld	hl, unk_0_4BFB
		add	a, l
		jr	nc, loc_0_46BB
		inc	h

loc_0_46BB:
		ld	l, a
		ex	de, hl
		ld	a, (de)
		ld	b, 0Ch
		ld	c, (iy + 0)

loc_0_46C3:
		out	(c), a
		add	a, 3
		inc	c
		outi	
		dec	c
		out	(c), a
		add	a, 1Dh
		inc	c
		outi	
		dec	c
		djnz	loc_0_46C3
		inc	de
		ex	de, hl
		outi	
		inc	c
		ex	de, hl
		outi	
		dec	c
		ex	de, hl
		outi	
		inc	c
		ex	de, hl
		outi	
		dec	c
		ld	a, (de)
		out	(c), a
		inc	c
		in	a, (c)
		and	30h ; '0'
		xor	30h ; '0'
		jr	nz, loc_0_46F4
		xor	30h ; '0'
loc_0_46F4:
		or	(hl)
		out	(c), a
		pop	hl
		jp	(hl)

loc_0_46F9:
		sub	61h ; 'a'

loc_0_46FB:
		push	hl
		ld	(iy + 4), 0
		ld	hl, unk_0_4F29
		add	a, a
		add	a, l
		jr	nc, loc_0_4708
		inc	h
loc_0_4708:
		ld	l, a
		ld	a, (hl)
		ld	hl, unk_0_51FC
		add	a, l
		jr	nc, loc_0_4711
		inc	h
loc_0_4711:
		ld	l, a
		ex	de, hl
		ld	a, (MBPlayer_play_chvol_1)
		exx	
		sub	b
		exx	
		ld	hl, unk_0_4F2B
		add	a, a
		add	a, l
		jr	nc, loc_0_4721
		inc	h

loc_0_4721:
		ld	l, a
		ld	a, (hl)
		ld	hl, unk_0_4C43
		add	a, l
		jr	nc, loc_0_472A
		inc	h

loc_0_472A:
		ld	l, a
		ld	c, (iy + 0)
		ld	b, 3Ch ; '<'
loc_0_4730:
		outi	
		ex	de, hl
		inc	c
		outi	
		ex	de, hl
		dec	c
		djnz	loc_0_4730
		outi	
		inc	c
		in	a, (c)
		and	30h ; '0'
		xor	30h ; '0'
		jr	nz, loc_0_4747
		xor	30h ; '0'

loc_0_4747:
		ld	b, a
		ld	a, (de)
		or	b
		out	(c), a
		dec	c
		ld	a, (hl)
		out	(c), a
		inc	de
		ld	a, (de)
		or	b
		inc	c
		out	(c), a
		pop	hl
		jp	(hl)

loc_0_4758:
		sub	7Ah ; 'z'
		ld	d, a
		ld	c, (iy + 0)
		ld	a, (iy + 3)
		out	(c), a
		inc	c
		in	a, (c)
		and	0C0h ; 'А'
		add	a, d
		out	(c), a
		jp	(hl)
loc_0_476C:
		jp	(hl)
loc_0_476D:
		ld	(iy + 4), 0
		sub	0B9h ; '№'
loc_0_4773:
		add	a, a
		add	a, a
		add	a, a
		add	a, a
		ld	d, a
		ld	c, (iy + 0)
		ld	a, (iy + 2)
		add	a, 20h ; ' '
		out	(c), a
		inc	c
		in	a, (c)
		and	0Fh
		add	a, d
		out	(c), a
		jp	(hl)
loc_0_478B:
		ld	(iy + 4), 0
		sub	0B9h ; '№'
loc_0_4791:
		add	a, a
		add	a, a
		add	a, a
		add	a, a
		ld	d, a
		ld	c, (iy + 0)
		ld	a, (iy + 2)
		add	a, 20h ; ' '
		ld	b, a
		out	(c), a
		inc	c
		in	a, (c)
		and	0Fh
		add	a, d
		out	(c), a
		ld	a, b
		add	a, 3
		dec	c
		out	(c), a
		inc	c
		in	a, (c)
		and	0Fh
		add	a, d
		out	(c), a
		jp	(hl)

loc_0_47B8:
		push	hl
		sub	0C6h ; 'Ж'
		add	a, (iy + 1)
		ld	(iy + 1), a
		ld	hl, unk_0_4CC8
		add	a, a
		add	a, l
		jr	nc, loc_0_47C9
		inc	h

loc_0_47C9:
		ld	l, a
		ld	d, (hl)
		dec	hl
		ld	e, (hl)
		inc	de
		ld	a, (iy + 7)
		add	a, e
		ld	e, a
		dec	de
		ld	(iy + 0Bh), e
		ld	c, (iy + 0)
		ld	b, (iy + 2)
		out	(c), b
		inc	c
		ld	(iy + 4), 0
		out	(c), e
		dec	c
		set	4, b
		out	(c), b
		set	5, d
		ld	(iy + 0Ch), d
		inc	c
		out	(c), d
		pop	hl
		jp	(hl)

loc_0_47F5:
		sub	0D9h ; 'Щ'
		ld	(iy + 4), 1
		sla	a
		ld	(iy + 5), a
		jp	c, loc_0_4808
		ld	(iy + 6), 0
		jp	(hl)

loc_0_4808:
		ld	(iy + 6), 0FFh
		ex	de, hl
		ld	h, (iy + 0Ch)
		bit	1, h
		jp	nz, loc_0_482B
		ld	a, h
		and	0FCh ; 'ь'
		sub	4
		ld	l, (iy + 0Bh)
		res	5, h
		add	hl, hl
		ld	(iy + 0Bh), l
		ld	b, a
		ld	a, h
		and	3
		or	b
		ld	(iy + 0Ch), a
loc_0_482B:
		ex	de, hl
		jp	(hl)

loc_0_482D:
		sub	0E9h ; 'й'
		ld	b, a
		ld	c, (iy + 0)
		ld	a, (iy + 3)
		sub	3
		out	(c), a
		inc	c
		in	a, (c)
		ld	e, a
		and	0C0h ; 'А'
		ld	d, a
		ld	a, e
		and	3Fh ; '?'
		add	a, b
		add	a, d
		out	(c), a
		jp	(hl)

loc_0_4849:
		jp	(hl)

loc_0_484A:
		sub	0F3h ; 'у'
		add	a, a
		ld	(iy + 7), a
		jp	(hl)

loc_0_4851:
		sub	0F5h ; 'х'
		ld	(iy + 4), a
		sub	2
		add	a, a
		add	a, a
		add	a, a
		add	a, a
		ex	de, hl
		ld	hl, unk_0_5338
		add	a, l
		jr	nc, loc_0_4864
		inc	h
loc_0_4864:
		ld	l, a
		ld	(iy + 5), l
		ld	(iy + 6), h
		ld	h, (iy + 0Ch)
		bit	1, h
		jp	nz, loc_0_488B
		ld	a, h
		and	0FCh ; 'ь'
		sub	4
		ld	l, (iy + 0Bh)
		res	5, h
		add	hl, hl
		ld	(iy + 0Bh), l
		ex	af, af'
		ld	a, h
		and	3
		ld	h, a
		ex	af, af'
		or	h
		ld	(iy + 0Ch), a
loc_0_488B:
		ex	de, hl
		jp	(hl)
;-------------------------------------------------------------------
; описание:  WAVE Event routines
; параметры: нет
; возвращаемое  значение: нет
;---------------------------------------------------------------------
MBPlayer_play_wtones:

		ld	hl, MBPlayer_step_buffer_1
		ld	b, 6
		ld	iy, MBPlayer_play_table_wav_3
		ld	de, 12h
loc_0_4899:
		ld	a, (hl)
		dec	a
		cp	60h ; '`'
		jp	nc, loc_0_48D4
		ld	a, 67h ; 'g'
		add	a, b
		out	(MOON_WREG), a
		xor	a
		nop	
		out	(MOON_WDAT), a
		ld	a, 4Fh ; 'O'
		add	a, b
		out	(MOON_WREG), a
		ld	c, a
		ld	a, 0FFh
		out	(MOON_WDAT), a
		ld	a, 1Fh
		add	a, b
		out	(MOON_WREG), a
		ld	a, (iy + 8)
		or	(iy + 6)
		out	(MOON_WDAT), a
		ld	a, 7
		add	a, b
		out	(MOON_WREG), a
		ld	a, (iy + 7)
		out	(MOON_WDAT), a
		ld	a, 37h ; '7'
		add	a, b
		out	(MOON_WREG), a
		ld	a, (iy + 9)
		out	(MOON_WDAT), a
loc_0_48D4:
		inc	hl
		add	iy, de
		djnz	loc_0_4899
		ret	
;-------------------------------------------------------------------
; описание: Play ON event
; параметры: нет
; возвращаемое  значение: нет
;---------------------------------------------------------------------
MBPlayer_play_wonevt:
		ld	l, (iy + 0Dh)
		ld	h, (iy + 0Eh)
		dec	b
		ld	a, b
		ld	a, 80h ; 'Ђ'
		add	a, b
		out	(MOON_WREG), a
		ld	a, (hl)
		out	(MOON_WDAT), a
		inc	hl
loc_0_48EB:
		ld	a, (hl)
		cp	0FFh
		jr	z, loc_0_48FB
		add	a, b
		out	(MOON_WREG), a
		inc	hl
		ld	a, (hl)
		out	(MOON_WDAT), a
		inc	hl
		jp	loc_0_48EB

loc_0_48FB:
		ld	a, 50h
		add	a, b
		out	(MOON_WREG), a
		ld	a, (iy + 0Fh)
		or	1
		out	(MOON_WDAT), a
		ld	a, 68h
		add	a, b
		out	(MOON_WREG), a
		ld	a, 80h
		or	(iy + 0Bh)
		out	(MOON_WDAT), a
		ret	
;-------------------------------------------------------------------
; описание: Play OFF event
; параметры: нет
; возвращаемое  значение: нет
;---------------------------------------------------------------------
MBPlayer_play_woffevt:
		ld	a, 67h ; 'g'
		add	a, b
		out	(MOON_WREG), a
		ld	(iy + 2), 0
		in	a, (MOON_WDAT)
		and	7Fh ; ''
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

		ld	c, a
		ld	hl, MBPlayer_xwavnrs - 1
		add	a, l
		jr	nc, loc_0_492E
		inc	h
loc_0_492E:
		ld	l, a
		ld	a, (hl)
		ld	(iy + 0Ah), a
		ld	a, c
		ld	hl, MBPlayer_xwavvols - 1
		add	a, l
		jr	nc, loc_0_493B
		inc	h
loc_0_493B:
		ld	l, a
		ld	a, (iy + 0Fh)
		and	1
		ld	d, a
		ld	a, (hl)
		add	a, a
		add	a, a
		or	d
		ld	(iy + 0Fh), a
		ld	(iy + 2), 0
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
		add	a, a
		add	a, a
		ld	c, a
		ld	a, 4Fh ; 'O'
		add	a, b
		out	(MOON_WREG), a
		ld	a, (iy + 0Fh)
		and	1
		or	c
		ld	(iy + 0Fh), a
		out	(MOON_WDAT), a
		ld	(iy + 2), 0
		ret	
;-------------------------------------------------------------------
; описание: Link note
; параметры: нет
; возвращаемое  значение: нет
;---------------------------------------------------------------------
MBPlayer_play_wlnk:
		ld	(iy + 2), 0
		push	bc
		sub	202
		add	a, (iy + 0)
		ld	(iy + 0), a

		ld	hl, tabdiv12
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
		jr	nc, loc_0_498D
		inc	h
loc_0_498D:
		ld	l, a
		ld	e, (hl)
		inc	hl
		ld	d, (hl)
		ex	de, hl
		sla	l
		ld	a, h
		rla	
		add	a, c
		ld	h, a
		ld	d, 0
		ld	e, (iy + 5)
		bit	7, e
		jr	z, loc_0_49A2
		dec	d
loc_0_49A2:
		add	hl, de
		add	hl, de
		ld	(iy + 8), l
		ld	(iy + 9), h
		pop	bc
		ld	a, 1Fh
		add	a, b
		out	(MOON_WREG), a
		ld	a, l
		or	(iy + 6)
		out	(MOON_WDAT), a
		ld	a, 37h ; '7'
		add	a, b
		out	(MOON_WREG), a
		ld	a, h
		or	(iy + 0Ch)
		out	(MOON_WDAT), a
		ret	
;-------------------------------------------------------------------
; описание: Play stereo event
; параметры: нет
; возвращаемое  значение: нет
;---------------------------------------------------------------------
MBPlayer_play_wchgste:
		sub	0B9h

MBPlayer_play_wchgste2:
		and	0Fh
		ld	d, a
		ld	a, (iy + 0Bh)
		and	0F0h ; 'р'
		or	d
		ld	(iy + 0Bh), a

		ld	a, 67h ; 'g'
		add	a, b
		out	(MOON_WREG), a
		ld	(iy + 2), 0
		in	a, (MOON_WDAT)
		and	0F0h ; 'р'
		or	d
		out	(MOON_WDAT), a
		ret	
;-------------------------------------------------------------------
; описание: Pitch bending
; параметры: нет
; возвращаемое  значение: нет
;---------------------------------------------------------------------
MBPlayer_play_wchgpit:
		sub	221	
		ld	(iy + 2), 1  		; Pitch bending on
		add	a, a
		add	a, a
		ld	(iy + 3), a		; Set pitch bend speed
		rlca	
		jr	c, loc_0_49F4
		ld	(iy + 4), 0
		ret	
loc_0_49F4:
		ld	(iy + 4), 0FFh
		ret	
;-------------------------------------------------------------------
; описание: Modulation event
; параметры: нет
; возвращаемое  значение: нет
;---------------------------------------------------------------------
MBPlayer_play_wchgmod:
		sub	0ECh ; 'м'
		ld	(iy + 2), a
		add	a, a
		add	a, a
		add	a, a
		add	a, a
		ld	hl, unk_0_5318
		add	a, l
		jr	nc, loc_0_4A09
		inc	h
loc_0_4A09:
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
		ld	a, 67h ; 'g'
		add	a, b
		out	(MOON_WREG), a
		ld	(iy + 2), 0
		in	a, (MOON_WDAT)
		or	40h ; '@'
		out	(MOON_WDAT), a
		ret	

loc_0_4A29:
		ld	b, a
		ld	a, 19h
		sub	b
		ld	(MBPlayer_play_speed), a
		jp	loc_0_44AE

loc_0_4A33:
		ld	a, 0Fh
		ld	(MBPlayer_play_step), a
		jp	loc_0_44AE
;-------------------------------------------------------------------
; описание:  set transpose 
; параметры: нет
; возвращаемое  значение: нет
;---------------------------------------------------------------------
MBPlayer_play_chgtrs:
		sub	52
		ld	(MBPlayer_play_tspval), a
		jp	loc_0_44AE
;-------------------------------------------------------------------
; описание: Переход к следующей позиции
; параметры: нет
; возвращаемое  значение: нет
;---------------------------------------------------------------------
MBPlayer_play_nextpos:
		ld	a, (MBPlayer_songdata_bank1)
		call	MBPlayer_selbank_FE

		ld	a, (MBPlayer_xleng)
		inc	a
		ld	b, a
		ld	a, (MBPlayer_play_pos)
		inc	a
		cp	b
		jp	c, loc_0_4A5E
		ld	a, (MBPlayer_xloop)
		cp	255
		call	z, MBPlayer_play_nextstop

loc_0_4A5E:
		ld	(MBPlayer_play_pos), a
		ld	hl, (MBPlayer_pos_address)
		add	a, l
		jr	nc, loc_0_4A68
		inc	h

loc_0_4A68:
		ld	l, a
		ld	a, (hl)
		ld	(byte_0_4F50), a
		add	a, a
		ld	hl, (MBPlayer_pat_address)
		add	a, l
		jr	nc, loc_0_4A75
		inc	h
loc_0_4A75:
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
		jr	nc, loc_0_4A86
		inc	d
loc_0_4A86:
		ld	e, a
		ld	a, (de)
		ld	(MBPlayer_songdata_bank), a
		ld	a, h
		and	3Fh ; '?'
		ld	h, a
		ld	de, (MBPlayer_songdata_adres)
		add	hl, de
		ret	
;-------------------------------------------------------------------
; описание: Останов после 255 повторов
; параметры: нет
; возвращаемое  значение: нет
;---------------------------------------------------------------------
MBPlayer_play_nextstop:
		call	MBPlayer_stop_music
		xor	a
		ret	

sub_0_4A9A:
		ld	de, PTW_SIZE
		ld	a, (MBPlayer_play_chvol_1)
		or	a
		jp	z, loc_0_4AB7
		ld	b, a
		ld	iy, MBPlayer_play_table_wav_1
		ld	hl, loc_0_4AB3

loc_0_4AAC:
		ld	a, (iy + 4)
		or	a
		jp	nz, loc_0_4AE5

loc_0_4AB3:
		add	iy, de
		djnz	loc_0_4AAC

loc_0_4AB7:
		ld	iy, MBPlayer_play_table_wav_2
		ld	a, (MBPlayer_play_chvol_2)
		ld	b, a
		ld	hl, loc_0_4AC9

loc_0_4AC2:
		ld	a, (iy + 4)
		or	a
		jp	nz, loc_0_4AE5

loc_0_4AC9:
		add	iy, de
		djnz	loc_0_4AC2
		ld	iy, MBPlayer_play_table_wav_3
		ld	de, 12h
		ld	hl, loc_0_4AE0
		ld	b, 6

loc_0_4AD9:
		ld	a, (iy + 2)
		or	a
		jp	nz, loc_0_4B4C

loc_0_4AE0:
		add	iy, de
		djnz	loc_0_4AD9
		ret	

loc_0_4AE5:
		exx	
		ld	l, (iy + 5)
		ld	h, (iy + 6)
		dec	a
		jp	nz, loc_0_4B25

loc_0_4AF0:
		ld	e, (iy + 0Bh)
		ld	d, (iy + 0Ch)
		bit	7, h
		add	hl, de
		jr	nz, loc_0_4B1B
		ld	a, d
		and	2
		or	h
		ld	h, a

loc_0_4B00:
		ld	c, (iy + 0)
		ld	d, (iy + 2)
		out	(c), d
		inc	c
		ld	(iy + 0Bh), l
		out	(c), l
		dec	c
		set	4, d
		out	(c), d
		ld	(iy + 0Ch), h
		inc	c
		out	(c), h
		exx	
		jp	(hl)

loc_0_4B1B:
		bit	1, h
		jp	nz, loc_0_4B00
		dec	h
		dec	h
		jp	loc_0_4B00


loc_0_4B25:
		ld	c, a
		ld	d, 0
		ld	e, (hl)
		sla	e
		jr	nc, loc_0_4B2E
		dec	d

loc_0_4B2E:
		inc	hl
		ld	a, (hl)
		cp	0Ah
		jp	nz, loc_0_4B42
		ld	a, c
		ld	hl, unk_0_5328
		add	a, a
		add	a, a
		add	a, a
		add	a, a
		add	a, l
		jr	nc, loc_0_4B41
		inc	h

loc_0_4B41:
		ld	l, a
loc_0_4B42:
		ld	(iy + 5), l
		ld	(iy + 6), h
		ex	de, hl
		jp	loc_0_4AF0

loc_0_4B4C:
		exx	
		ld	c, a
		ld	l, (iy + 3)
		ld	h, (iy + 4)
		dec	c
		jp	nz, loc_0_4B8C
		ex	de, hl

loc_0_4B59:
		ld	h, (iy + 9)
		ld	l, (iy + 8)
		add	hl, de
		bit	3, h
		jr	z, loc_0_4B70
		bit	7, d
		jr	nz, loc_0_4B6E
		ld	a, h
		add	a, 8
		ld	h, a
		jr	loc_0_4B70

loc_0_4B6E:
		res	3, h

loc_0_4B70:
		ld	(iy + 8), l
		ld	(iy + 9), h
		ld	a, (iy + 1)
		ld	c, a
		out	(MOON_WREG), a
		ld	a, l
		or	(iy + 6)
		out	(MOON_WDAT), a
		ld	a, c
		add	a, 18h
		out	(MOON_WREG), a
		ld	a, h
		out	(MOON_WDAT), a
		exx	
		jp	(hl)

loc_0_4B8C:
		ld	d, 0
		ld	e, (hl)
		sla	e
		sla	e
		jr	nc, loc_0_4B96
		dec	d

loc_0_4B96:
		inc	hl
		ld	a, (hl)
		cp	0Ah
		jp	nz, loc_0_4BAA
		ld	a, c
		ld	hl, unk_0_5328
		add	a, a
		add	a, a
		add	a, a
		add	a, a
		add	a, l
		jr	nc, loc_0_4BA9
		inc	h

loc_0_4BA9:
		ld	l, a

loc_0_4BAA:
		ld	(iy + 3), l
		ld	(iy + 4), h
		jp	loc_0_4B59

sub_0_4BB3:
		ex	af, af'
		ld	c, (iy + 0)
		out	(c), b
		ex	af, af'
		out	(0C5h),	a
		ret	

		ld	c, (iy + 0)
		out	(c), b
		nop	
		in	a, (0C5h)
		ret	

;-------------------------------------------------------------------
; описание: Вывод данных в регистры FM части
; параметры: C - номер регистра
;	     A - выводимый байт
; возвращаемое  значение: нет
;---------------------------------------------------------------------
MBPlayer_out_fm1:
		ex	af, af'
		ld	a, c
		out	(0C4h),	a
		ex	af, af'
		out	(0C5h),	a
		ret	
;-------------------------------------------------------------------
; описание: Вывод данных в регистры FM части
; параметры: C - номер регистра
;	     A - выводимый байт
; возвращаемое  значение: нет
;---------------------------------------------------------------------
MBPlayer_out_fm2:
		ex	af, af'
		ld	a, c
		out	(0C6h),	a
		ex	af, af'
		out	(0C5h),	a
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
		out	(MOON_WREG), a
		ex	af, af'
		out	(MOON_WDAT), a
		ret	

		ld	a, c
		out	(MOON_WREG), a
		nop	
		in	a, (MOON_WDAT)
		ret	

		db 0C5h ; Е
		db 0F5h ; х
		db  3Ah ; :
		db  2Dh ; -
		db    0 ;  
		db 0FEh ; ю
		db    3 ;  
		db  38h ; 8
		db  0Ah ;  
		db 0DBh ; Ы
		db 0E6h ; ж
		db  47h ; G
		db 0DBh ; Ы
		db 0E6h ; ж
		db  90h ; ђ
		db 0FEh ; ю
		db    5 ;  
		db  38h ; 8
		db 0F9h ; щ
		db 0F1h ; с
		db 0C1h ; Б
		db 0C9h ; Й

unk_0_4BFB:	db  32h
		db 0F2h
		db 0F5h
		db 0C8h
		db  31h
		db 0F1h
		db 0F4h
		db 0C7h
		db  30h
		db 0F0h
		db 0F3h
		db 0C6h
		db  32h
		db 0F2h
		db 0F5h
		db 0C8h
		db  31h
		db 0F1h
		db 0F4h
		db 0C7h
		db  30h
		db 0F0h
		db 0F3h
		db 0C6h
		db  2Ah
		db 0EAh
		db 0EDh
		db 0C5h
		db  22h
		db 0E2h
		db 0E5h
		db 0C2h
		db  29h
		db 0E9h
		db 0ECh
		db 0C4h
		db  21h
		db 0E1h
		db 0E4h
		db 0C1h
		db  28h
		db 0E8h
		db 0EBh
		db 0C3h
		db  20h
		db 0E0h
		db 0E3h
		db 0C0h
		db  2Ah
		db 0EAh
		db 0EDh
		db 0C5h
		db  22h
		db 0E2h
		db 0E5h
		db 0C2h
		db  29h
		db 0E9h
		db 0ECh
		db 0C4h
		db  21h
		db 0E1h
		db 0E4h
		db 0C1h
		db  28h
		db 0E8h
		db 0EBh
		db 0C3h
		db  20h
		db 0E0h
		db 0E3h
		db 0C0h

unk_0_4C43:	
		db  20h 
		db  23h ; #
		db  40h ; @
		db  43h ; C
		db  60h ; `
		db  63h ; c
		db  80h ; Ђ
		db  83h ; ѓ
		db 0E0h ; а
		db 0E3h ; г
		db  28h ; (
		db  2Bh ; +
		db  48h ; H
		db  4Bh ; K
		db  68h ; h
		db  6Bh ; k
		db  88h ; €
		db  8Bh ; ‹
		db 0E8h ; и
		db 0EBh ; л
		db 0C0h ; А
		db 0C3h ; Г
		db  21h ; !
		db  24h ; $
		db  41h ; A
		db  44h ; D
		db  61h ; a
		db  64h ; d
		db  81h ; Ѓ
		db  84h ; „
		db 0E1h ; б
		db 0E4h ; д
		db  29h ; )
		db  2Ch
		db  49h ; I
		db  4Ch ; L
		db  69h ; i
		db  6Ch ; l
		db  89h ; ‰
		db  8Ch ; Њ
		db 0E9h ; й
		db 0ECh ; м
		db 0C1h ; Б
		db 0C4h ; Д
		db  22h ; "
		db  25h ; %
		db  42h ; B
		db  45h ; E
		db  62h ; b
		db  65h ; e
		db  82h ; ‚
		db  85h ; …
		db 0E2h ; в
		db 0E5h ; е
		db  2Ah ; *
		db  2Dh ; -
		db  4Ah ; J
		db  4Dh ; M
		db  6Ah ; j
		db  6Dh ; m
		db  8Ah ; Љ
		db  8Dh ; Ќ
		db 0EAh ; к
		db 0EDh ; н
		db 0C2h ; В
		db 0C5h ; Е
		db  20h ;  
		db  23h ; #
		db  40h ; @
		db  43h ; C
		db  60h ; `
		db  63h ; c
		db  80h ; Ђ
		db  83h ; ѓ
		db 0E0h ; а
		db 0E3h ; г
		db  28h ; (
		db  2Bh ; +
		db  48h ; H
		db  4Bh ; K
		db  68h ; h
		db  6Bh ; k
		db  88h ; €
		db  8Bh ; ‹
		db 0E8h ; и
		db 0EBh ; л
		db 0C0h ; А
		db 0C3h ; Г
		db  21h ; !
		db  24h ; $
		db  41h ; A
		db  44h ; D
		db  61h ; a
		db  64h ; d
		db  81h ; Ѓ
		db  84h ; „
		db 0E1h ; б
		db 0E4h ; д
		db  29h ; )
		db  2Ch ; ,
		db  49h ; I
		db  4Ch ; L
		db  69h ; i
		db  6Ch ; l
		db  89h ; ‰
		db  8Ch ; Њ
		db 0E9h ; й
		db 0ECh ; м
		db 0C1h ; Б
		db 0C4h ; Д
		db  22h ; "
		db  25h ; %
		db  42h ; B
		db  45h ; E
		db  62h ; b
		db  65h ; e
		db  82h ; ‚
		db  85h ; …
		db 0E2h ; в
		db 0E5h ; е
		db  2Ah ; *
		db  2Dh ; -
		db  4Ah ; J
		db  4Dh ; M
		db  6Ah ; j
		db  6Dh ; m
		db  8Ah ; Љ
		db  8Dh ; Ќ
		db 0EAh ; к
		db 0EDh ; н
		db 0C2h ; В
		db 0C5h ; Е
		db  59h ; Y

unk_0_4CC8:	db    1
		db  6Dh ; m
		db    1 ;  
		db  83h ; ѓ
		db    1 ;  
		db  9Ah ; љ
		db    1 ;  
		db 0B2h ; І
		db    1 ;  
		db 0CCh ; М
		db    1 ;  
		db 0E8h ; и
		db    1 ;  
		db    5 ;  
		db    2 ;  
		db  23h ; #
		db    2 ;  
		db  44h ; D
		db    2 ;  
		db  67h ; g
		db    2 ;  
		db  8Bh ; ‹
		db    2 ;  
		db  59h ; Y
		db    5 ;  
		db  6Dh ; m
		db    5 ;  
		db  83h ; ѓ
		db    5 ;  
		db  9Ah ; љ
		db    5 ;  
		db 0B2h ; І
		db    5 ;  
		db 0CCh ; М
		db    5 ;  
		db 0E8h ; и
		db    5 ;  
		db    5 ;  
		db    6 ;  
		db  23h ; #
		db    6 ;  
		db  44h ; D
		db    6 ;  
		db  67h ; g
		db    6 ;  
		db  8Bh ; ‹
		db    6 ;  
		db  59h ; Y
		db    9 ;  
		db  6Dh ; m
		db    9 ;  
		db  83h ; ѓ
		db    9 ;  
		db  9Ah ; љ
		db    9 ;  
		db 0B2h ; І
		db    9 ;  
		db 0CCh ; М
		db    9 ;  
		db 0E8h ; и
		db    9 ;  
		db    5 ;  
		db  0Ah ;  
		db  23h ; #
		db  0Ah ;  
		db  44h ; D
		db  0Ah ;  
		db  67h ; g
		db  0Ah ;  
		db  8Bh ; ‹
		db  0Ah ;  
		db  59h ; Y
		db  0Dh ;  
		db  6Dh ; m
		db  0Dh ;  
		db  83h ; ѓ
		db  0Dh ;  
		db  9Ah ; љ
		db  0Dh ;  
		db 0B2h ; І
		db  0Dh ;  
		db 0CCh ; М
		db  0Dh ;  
		db 0E8h ; и
		db  0Dh ;  
		db    5 ;  
		db  0Eh ;  
		db  23h ; #
		db  0Eh ;  
		db  44h ; D
		db  0Eh ;  
		db  67h ; g
		db  0Eh ;  
		db  8Bh ; ‹
		db  0Eh ;  
		db  59h ; Y
		db  11h ;  
		db  6Dh ; m
		db  11h ;  
		db  83h ; ѓ
		db  11h ;  
		db  9Ah ; љ
		db  11h ;  
		db 0B2h ; І
		db  11h ;  
		db 0CCh ; М
		db  11h ;  
		db 0E8h ; и
		db  11h ;  
		db    5 ;  
		db  12h ;  
		db  23h ; #
		db  12h ;  
		db  44h ; D
		db  12h ;  
		db  67h ; g
		db  12h ;  
		db  8Bh ; ‹
		db  12h ;  
		db  59h ; Y
		db  15h ;  
		db  6Dh ; m
		db  15h ;  
		db  83h ; ѓ
		db  15h ;  
		db  9Ah ; љ
		db  15h ;  
		db 0B2h ; І
		db  15h ;  
		db 0CCh ; М
		db  15h ;  
		db 0E8h ; и
		db  15h ;  
		db    5 ;  
		db  16h ;  
		db  23h ; #
		db  16h ;  
		db  44h ; D
		db  16h ;  
		db  67h ; g
		db  16h ;  
		db  8Bh ; ‹
		db  16h ;  
		db  59h ; Y
		db  19h ;  
		db  6Dh ; m
		db  19h ;  
		db  83h ; ѓ
		db  19h ;  
		db  9Ah ; љ
		db  19h ;  
		db 0B2h ; І
		db  19h ;  
		db 0CCh ; М
		db  19h ;  
		db 0E8h ; и
		db  19h ;  
		db    5 ;  
		db  1Ah ;  
		db  23h ; #
		db  1Ah ;  
		db  44h ; D
		db  1Ah ;  
		db  67h ; g
		db  1Ah ;  
		db  8Bh ; ‹
		db  1Ah ;  
		db  59h ; Y
		db  1Dh ;  
		db  6Dh ; m
		db  1Dh ;  
		db  83h ; ѓ
		db  1Dh ;  
		db  9Ah ; љ
		db  1Dh ;  
		db 0B2h ; І
		db  1Dh ;  
		db 0CCh ; М
		db  1Dh ;  
		db 0E8h ; и
		db  1Dh ;  
		db    5 ;  
		db  1Eh ;  
		db  23h ; #
		db  1Eh ;  
		db  44h ; D
		db  1Eh ;  
		db  67h ; g
		db  1Eh ;  
		db  8Bh ; ‹
		db  1Eh ;  

MBPlayer_play_table_wav_2:	
		db 	0C6h,0,0A8h,55h,0,0,0,0,0,0,0,0,0
		db 	0C6h,0,0A7h,54h,0,0,0,0,0,0,0,0,0
		db 	0C6h,0,0A6h,53h,0,0,0,0,0,0,0,0,0
		db 	0C4h,0,0A8h,55h,0,0,0,0,0,0,0,0,0
		db 	0C4h,0,0A7h,54h,0,0,0,0,0,0,0,0,0
		db 	0C4h,0,0A6h,53h,0,0,0,0,0,0,0,0,0
		db 	0C6h,0,0A5h,4Dh,0,0,0,0,0,0,0,0,0
		db 	0C6h,0,0A2h,45h,0,0,0,0,0,0,0,0,0
		db 	0C6h,0,0A4h,4Ch,0,0,0,0,0,0,0,0,0
		db 	0C6h,0,0A1h,44h,0,0,0,0,0,0,0,0,0
		db 	0C6h,0,0A3h,4Bh,0,0,0,0,0,0,0,0,0
		db 	0C6h,0,0A0h,43h,0,0,0,0,0,0,0,0,0
		db 	0C4h,0,0A5h,4Dh,0,0,0,0,0,0,0,0,0
		db 	0C4h,0,0A2h,45h,0,0,0,0,0,0,0,0,0
		db 	0C4h,0,0A4h,4Ch,0,0,0,0,0,0,0,0,0
		db 	0C4h,0,0A1h,44h,0,0,0,0,0,0,0,0,0
		db 	0C4h,0,0A3h,4Bh,0,0,0,0,0,0,0,0,0
		db 	0C4h,0,0A0h,43h,0,0,0,0,0,0,0,0,0

MBPlayer_play_table_wav_1:	
		db 	0C4h,0,0A0h,43h,0,0,0,0,0,0,0,0,0
		db 	0C4h,0,0A1h,44h,0,0,0,0,0,0,0,0,0
		db 	0C4h,0,0A2h,45h,0,0,0,0,0,0,0,0,0
		db 	0C6h,0,0A0h,43h,0,0,0,0,0,0,0,0,0
		db 	0C6h,0,0A1h,44h,0,0,0,0,0,0,0,0,0
		db 	0C6h,0,0A2h,45h,0,0,0,0,0,0,0,0,0

MBPlayer_play_table_wav_3:	
		db	0,25h,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0	; ch19
		db	0,24h,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0	; ch20
		db	0,23h,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0	; ch21
		db	0,22h,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0	; ch22
		db	0,21h,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0	; ch23
		db	0,20h,0,0,0,0,0,0,0,0,0,0,0,0,0,0	; ch24
unk_0_4F29:	
		db    0 
unk_0_4F2A:	
		db    0 

unk_0_4F2B:	db    0 

		db  0Bh ;  
		db  16h ;  
		db  21h ; !
		db  2Ch ; ,
		db  37h ; 7
		db  42h ; B
		db  4Dh ; M
		db  58h ; X
		db  63h ; c
		db  6Eh ; n
		db  79h ; y
		db  84h ; „
		db  8Fh ; Џ
		db  9Ah ; љ
		db 0A5h ; Ґ
		db 0B0h ; °
		db 0BBh ; »
		db 0C6h ; Ж
		db 0D1h ; С
		db 0DCh ; Ь
		db 0E7h ; з
		db 0F2h ; т
		db 0FDh ; э
unk_0_4F43:	
		db    0
		db    1 ;  
		db    3 ;  
		db    7 ;  
		db  0Fh ;  
		db  1Fh  
		db  3Fh

MBPlayer_songdata_bank:	
		db 	0
MBPlayer_play_speed:	
		db 	0
MBPlayer_play_tspval:	
		db	0
MBPlayer_play_timercnt:	
		db 	0
byte_0_4F4E:	
		db 	0
MBPlayer_play_chvol_2:	
		db 	0
byte_0_4F50:	
		db 	0
;-------------------------------------------------------------------
; описание: Открытие файла
; параметры: нет
; возвращаемое  значение: нет
;---------------------------------------------------------------------
MBPlayer_open_file:
		ld	de, MBPlayer_upper_fcb
		ld	c, 0Fh
		call	0F37Dh
		ld	hl, 1
		ld	(0DA4Eh), hl
		dec	hl
		ld	(0DA61h), hl
		ld	(0DA63h), hl
		ret	
;-------------------------------------------------------------------
; описание: Чтение файла
; параметры: DE - адрес памяти, куда будем считывать данные
;	     HL - число байт
; возвращаемое  значение: нет
;---------------------------------------------------------------------
MBPlayer_load_file:
		push	hl
		push	de
		push	hl
		ld	c, 1Ah
		call	0F37Dh
		ld	de, MBPlayer_upper_fcb
		pop	hl
		ld	c, 27h ; '''
		call	0F37Dh
		pop	de
		pop	hl
		ret	
;-------------------------------------------------------------------
; описание: Закрытие файла
; параметры: нет
; возвращаемое  значение: нет
;---------------------------------------------------------------------
MBPlayer_close_file:
		ld	de, MBPlayer_upper_fcb
		ld	c, 10h
		call	0F37Dh
		ret	

sub_0_4F84:
		ld	b, 0
loc_0_4F86:
		push	bc
		call	0FD9Fh
		pop	bc
		djnz	loc_0_4F86
		ret	


unk_0_4F8E:	db    0 
		db  20h ;  
		db  20h ;  
		db  20h ;  
		db  20h ;  
		db  20h ;  
		db  20h ;  
		db  20h ;  
		db  20h ;  
		db  20h ;  
		db  20h ;  
		db  20h ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
;-------------------------------------------------------------------
; описание: Заголовок файла
;---------------------------------------------------------------------
aMbms:		db 	"MBMS"
		db  	10h ;  
		db    	1 ;  

;-------------------------------------------------------------------
; описание: Сообщения
;---------------------------------------------------------------------
aMoonblasterLoa:db 	"MoonBlaster Load Error!" 
		db 	0
aNotACompatible:db 	"Not a (compatible) MoonBlaster file!" 
		db 	0
aMoonblasterFor:db 	"MoonBlaster for MoonSound FM BASIC driver v0.92"
		db 	0Ah
		db 	0Dh
		db 	"           Coding by R.Schrijvers"
		db 	0Ah
		db 	0Dh
		db 	"             (c) Moonsoft 1995"
		db 	0Ah
		db 	0Dh
		db 	0
;-------------------------------------------------------------------
; описание: Таблица функций
;---------------------------------------------------------------------
aR800:		db 	"R800"            
		db 	0
		dw 	MBPlayer_mbr800
aZ80:		db 	"Z80"
		db 	0
		dw 	MBPlayer_mbz80
aMbplay:	db 	"MBPLAY"
		db 	0
		dw 	MBPlayer_mbplay
aMbstop:	db 	"MBSTOP"
		db 	0
		dw 	MBPlayer_mbstop
aMbcont:	db 	"MBCONT"
		db 	0
		dw 	MBPlayer_mbcont
aMbhalt:	db 	"MBHALT"
		db 	0
		dw 	MBPlayer_mbhalt
aMbbank1:	db 	"MBBANK1"
		db 	0
		dw 	MBPlayer_mbbank1
aMbbank2:	db 	"MBBANK2"
		db 	0
		dw 	MBPlayer_mbbank2
aMbbank3:	db 	"MBBANK3"
		db 	0
		dw 	MBPlayer_mbbank3
aMbaddr:	db 	"MBADDR"
		db 	0
		dw 	MBPlayer_mbaddr
aMbver:		db 	"MBVER"
		db 	0
		dw 	MBPlayer_mbver
aMfmload:	db 	"MFMLOAD"
		db 	0
		dw 	MBPlayer_load_mwm
		db 	0FFh ;  
;-------------------------------------------------------------------
; описание: Переключение банка памяти в адресах 8000...BFFFh
; параметры: A - номер страницы
; возвращаемое  значение: нет
;---------------------------------------------------------------------
MBPlayer_selbank_FE:
		out	(0FEh),	a
		ret	
;-------------------------------------------------------------------
; описание: Получение текущего банка памяти в адресах 8000...BFFFh
; параметры: нет
; возвращаемое  значение: A - номер страницы
;---------------------------------------------------------------------
MBPlayer_getbank_FE:
		in	a, (0FEh)
		ret	
;-------------------------------------------------------------------
; описание: Проверка типа процессора - Z80
; параметры: нет
; возвращаемое  значение: нет
;---------------------------------------------------------------------
MBPlayer_mbz80:	
		ld	a, (2Dh)
		cp	3
		ret	c
		ld	a, 80h ; 'Ђ'
		jp	180h
;-------------------------------------------------------------------
; описание: Проверка типа процессора - R800
; параметры: нет
; возвращаемое  значение: нет
;---------------------------------------------------------------------
MBPlayer_mbr800:
		ld	a, (2Dh)
		cp	3
		ret	c
		ld	a, 82h ; '‚'
		jp	180h

;-------------------------------------------------------------------
; описание: Информация о треке = 718 байт
; параметры: нет
; возвращаемое  значение: нет
;---------------------------------------------------------------------
MBPlayer_xleng:	
		ds	1		; Song length
MBPlayer_xloop:	
		ds	1		; Loop position
unk_0_50F4:	
		db    	0 
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
unk_0_51FC:	db    0 ;		; DATA XREF: seg000:470Ao
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
unk_0_521C:	db    0 ;		; DATA XREF: sub_0_406Fo
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
unk_0_5318:	db    0 ;		; DATA XREF: seg000:4A02o
		db    0 ;  
		db    0 ;  
		db    0 ;  

MBPlayer_xtempo:	
		ds	1		; Tempo
MBPlayer_xhzequal:	
		ds	1		; Base frequency

byte_0_531E:	db 0
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
unk_0_5328:	db    0 ;		; DATA XREF: sub_0_4A9A+9Co
					; sub_0_4A9A+104o
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
MBPlayer_play_chvol_1:	
		db 	0

unk_0_5338:	db    0
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
unk_0_5368:	db    0 
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
unk_0_537A:	db    0 
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0 ;  
		db    0
MBPlayer_xwavnrs:
		ds    	32			; Wave numbers
MBPlayer_xwavvols:
		ds	32			; Wave volumes

off_0_53C0:
        	.include "patch_table.inc"
		.include "freq_table_1.inc"

MBPlayer_pat_address:	
		dw	0
MBPlayer_pos_address:	
		dw 	0
MBPlayer_songdata_ptr:	
		dw 	0

                .include "freq_table_0.inc"

MBPlayer_load_addres:	
		dw 	0
MBPlayer_load_bank:	
		dw 	0

		db    3 ;  
		db 0FFh ;  
		db    1 ;  
		db    2 ;  
		db  5Ch ; \
		db 0FFh ;  
		db    2 ;  
		db  18h ;  
		db 0EFh ; п
		db  75h ; u
		db    1 ;  
		db 0CBh ; Л
		db  61h ; a
		db 0FFh ;  
		db  0Fh ;  
		db  19h ;  
		db  17h ;  
		db  75h ; u
		db  32h ; 2
		db  98h ; 
		db 0F4h ; ф
		db 0B0h ; °
		db  15h ;  
		db 0C8h ; И
		db  16h ;  
		db 0E0h ; а
		db    1 ;  
		db 0FFh ;  
		db    1 ;  
		db 0AEh ; ®
		db  57h ; W
		db  1Dh ;  
		db  13h ;  
		db  30h ; 0
		db 0CFh ; П
		db  71h ; q
		db  21h ; !
		db  14h ;  
		db  6Ah ; j
		db 0E7h ; з
		db  68h ; h
		db  25h ; %
		db  12h ;  
		db  5Ah ; Z
		db 0F7h ; ч
		db  76h ; v
		db  2Dh ; -
		db  15h ;  
		db  62h ; b
		db  0Fh ;  
		db  6Bh ; k
		db  35h ; 5
		db  17h ;  
		db  5Ah ; Z
		db  47h ; G
		db  72h ; r
		db 0FFh ;  
		db  16h ;  
		db  6Ah ; j
		db 0FFh ;  
		db  65h ; e
		db    1 ;  
		db 0CDh ; Н
		db  55h ; U
		db 0FFh ;  
		db  0Eh ;  
		db  19h ;  
		db  4Fh ; O
		db  67h ; g
		db    1 ;  
		db  55h ; U
		db  55h ; U
		db 0FFh ;  
		db 0A9h ; ©
		db  18h ;  
		db 0DFh ; Я
		db  70h ; p
		db    1 ;  
		db 0AEh ; ®
		db  57h ; W
		db 0FFh ;  
		db  37h ; 7
		db  19h ;  
		db 0AFh ; Ї
		db  6Dh ; m
		db    1 ;  
		db  1Bh ;  
		db  62h ; b
		db  22h ; "
		db 0A4h ; ¤
		db  60h ; `
		db 0F7h ; ч
		db  64h ; d
		db 0FFh ;  
		db 0A8h ; Ё
		db  5Ch ; \
		db 0CFh ; П
		db  6Bh ; k
		db  1Ch ;  
		db 0FFh ;  
		db    1 ;  


MFM_Player_end:
		.savebin "mfm_player.bin",MFM_Player_Start, MFM_Player_end - MFM_Player_Start


		.end
