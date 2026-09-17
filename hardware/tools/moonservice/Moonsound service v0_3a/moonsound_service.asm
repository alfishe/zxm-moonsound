		DEVICE ZXSPECTRUM128

REPDEL:		EQU 	5C09h				;Time (in 50ths of a second) that a key must be held down before it repeats. This starts off at 35.
REPPER:   	EQU	5C0Ah                           ;Delay (in 50ths of a second) between successive repeats of a key held down - initially 5.
BORDCR:		EQU 	5C48h
ATTR_P:		EQU 	5C8Dh

MOON_BASE:	equ	0C4h
MOON_REG1:	equ	MOON_BASE
MOON_DAT1:	equ	MOON_BASE+1
MOON_REG2:	equ	MOON_BASE+2
MOON_DAT2:	equ	MOON_BASE+3
MOON_STAT:	equ	MOON_BASE

MOON_WREG:	equ	7Eh
MOON_WDAT:	equ	MOON_WREG+1

		.org 	6000h

;-------------------------------------------------------------------
; описание: Точка входа в программу после передачи управления из ОС
;---------------------------------------------------------------------
MoonService_Start:		
		di	
		ld	a, 10h
		ld	bc, 7FFDh
		out	(c), a
		call	MoonService_init_card		;инициализация и проверка наличия карты

		push	af                              ;запомним результат 
		set	3, (iy + 30h)			;включим CAPS LOCK (5С3A + 30h)
		ld	hl, 110h
		ld	(REPDEL), hl

		ld	a, 28h
		call	VideoDRV_clear_screen   	;очищаем экран
		res	5, (iy + 1)
		res	7, (iy + 30h)
		res	3, (iy + 37h)
		call	VideoDRV_create_scraddr 	;создаем таблицу адресов экрана
		pop	af

		jp	nz,MoonService_card_not_found	;карта не найдена

loc_0_6032:
		ld	ix, MoonService_window_name	;создаем окно программы
		call	VideoDRV_create_window

		ld	ix, MoonService_window_help     ;создадим окно помощи
		call	VideoDRV_create_window

		ld	ix, MoonService_window_info	;создадим окно информации о страницах ПЗУ
		call	VideoDRV_create_window
		call	MoonService_card_info

		ld	ix, MoonService_window_menu	;создадим окно меню
		call	VideoDRV_create_window
loc_0_60AC:
		call	MoonService_key_pressed		;опрос клавиатуры меню
		call	MoonService_menu_action         ;обработка события, при ввыборе пунктов меню
		db	0Dh				;код клавиши - Ввод
		dw	MoonService_menu_execute
		db	00h				;конец таблицы	
		jr	loc_0_60AC
;-------------------------------------------------------------------
; описание: Вывод информации о карте
; параметры: нет                                                    
; возвращаемое  значение: нет
;---------------------------------------------------------------------
MoonService_card_info:
		ld	hl, MoonService_msg_Dev		;выведем информацию о чипе
		call	VideoDRV_print_string
		ld	hl,MoonService_id_ym278
		ld	a,(MoonService_dev_id)
		cp	20h
		jr	z,MoonService_chip_0
		ld	hl,MoonService_id_unk
MoonService_chip_0:
		call	VideoDRV_print_string

		ld	hl, MoonService_msg_ROM		;выведем информацию о ПЗУ
		call	VideoDRV_print_string

;		ld	hl, MoonService_mem_2048		
;		call	VideoDRV_print_string

		call	MoonService_flash_info		;определим тип микросхемы ПЗУ

		ld	hl, MoonService_msg_RAM		;выведем информацию о ОЗУ
		call	VideoDRV_print_string

		ld	c,0				;признак что памяти нет

		ld	de,0211h			;открываем ОЗУ на запись
		call	MoonService_wave_out
	
		ld	de,0320h			;устанавливаем адрес 200000h
		call	MoonService_wave_out

		ld	de,0400h                        ;старший байт
		call	MoonService_wave_out		
		inc	d                               ;05 - младший байт адреса
		call	MoonService_wave_out
		ld	de,0655h                        ;06 -запишем данные -> 55h
		call	MoonService_wave_out		
		call	MoonService_busy		;проверим готовность микросхемы
		ld	e,0AAh                          ;06 -запишем данные -> 0AAh
		call	MoonService_wave_out		
		call	MoonService_busy		;проверим готовность микросхемы

		nop
		nop
		nop

		ld	de,0211h			;открываем ОЗУ на чтение
		call	MoonService_wave_out
		ld	de,0320h			;устанавливаем адрес 200000h
		call	MoonService_wave_out
		ld	de,0400h                        ;старший байт
		call	MoonService_wave_out		
		inc	d                               ;05 - младший байт адреса
		call	MoonService_wave_out
		inc	d   
		call	MoonService_wave_in
		ld	l,a
		call	MoonService_wave_in

		cp	0AAh				;сравним что прочитали	
		jr	nz, MoonService_chip_1
		ld	a,l
		cp	55h				;сравним что прочитали	
		jr	nz, MoonService_chip_1
		ld	a,1
		or	c
		ld	c,a
MoonService_chip_1:
		ld	de,0211h			;открываем ОЗУ на запись
		call	MoonService_wave_out
		ld	de,0328h			;устанавливаем адрес 280000h
		call	MoonService_wave_out

		ld	de,0400h                        ;старший байт
		call	MoonService_wave_out		
		inc	d                               ;младший байт адреса
		call	MoonService_wave_out
		ld	de,06AAh                        ;06 -запишем данные -> AAh
		call	MoonService_wave_out		
		call	MoonService_busy		;проверим готовность микросхемы
		ld	e,55h                          	;06 -запишем данные -> 55h
		call	MoonService_wave_out		
		call	MoonService_busy		;проверим готовность микросхемы

		nop
		nop
		nop

		ld	de,0211h			;открываем ОЗУ на чтение
		call	MoonService_wave_out
		ld	de,0328h			;устанавливаем адрес 280000h
		call	MoonService_wave_out
		ld	de,0400h                        ;старший байт
		call	MoonService_wave_out		
		inc	d                               ;05 - младший байт адреса
		call	MoonService_wave_out
		inc	d   
		call	MoonService_wave_in
		ld	l,a
		call	MoonService_wave_in

		cp	55h				;сравним что прочитали	
		jr	nz, MoonService_chip_2
		ld	a,l
		cp	0AAh				;сравним что прочитали	
		jr	nz, MoonService_chip_2
		ld	a,2
		or	c
		ld	c,a
MoonService_chip_2:
		ld	a,c
		ld	(MoonService_dev_mem),a
		ld	hl,MoonService_mem_none	
		and	a
		jr	z,MoonService_chip_3
		ld	hl,MoonService_mem_1024
		cp	3
		jr	z,MoonService_chip_3
		ld	hl,MoonService_mem_512
MoonService_chip_3:
		call	VideoDRV_print_string
		ld	de, 0210h			;закрываем доступ к ОЗУ карты
		jp	MoonService_wave_out
;-------------------------------------------------------------------
; описание: Вывод сообщения об отсутствии карты 
; параметры: нет                                
; возвращаемое  значение: нет
;---------------------------------------------------------------------
MoonService_card_not_found:
		ld	ix,MoonService_window_message    ;адрес окна 
		call	VideoDRV_create_window       	;создадим текущее окно

		ld	hl, aErrorSndNotFound          
		call	VideoDRV_print_string        	;выведем сообщение

		call	MoonService_press_anykey         ;ждем нажатия любой клавиши
		jp	MoonService_exit
;-------------------------------------------------------------------
; описание: Вывод сообщения об отсутствии памяти ОЗУ
; параметры: нет                                
; возвращаемое  значение: нет
;---------------------------------------------------------------------
MoonService_ram_not_found:
		ld	ix,MoonService_window_message    ;адрес окна 
		call	VideoDRV_create_window       ;создадим текущее окно

		ld	hl, aErrorRamNotFound          
		call	VideoDRV_print_string        ;выведем сообщение

		call	MoonService_press_anykey        ;ждем нажатия любой клавиши
		jp	MoonService_Start
;-------------------------------------------------------------------
; описание: Обработчик пунктов меню
; параметры: нет                    
; возвращаемое  значение: нет
;---------------------------------------------------------------------
MoonService_menu_execute:
		ld	a, (ix + 12h)
		and	a
		jr	z, MoonService_test_ram
		dec	a
		jp	z, MoonService_test_rom
		dec	a
		jp	z, MoonService_update_flash
		jp	MoonService_exit
;-------------------------------------------------------------------
; описание: Процесс тестирования ОЗУ
; параметры: нет
; возвращаемое  значение: нет
;---------------------------------------------------------------------
MoonService_test_ram:
		ld	a,(MoonService_dev_mem)		;проверим наличие банков памяти
		and	a
		jp 	z,MoonService_ram_not_found

		ld	ix, MoonService_window_hram     ;окно справки
		call	VideoDRV_create_window

		ld	ix, MoonService_window_tram     ;создадим окно теста
		call	VideoDRV_create_window
		xor	a
MoonService_test_ram_00:
		ld	(MoonService_check_byte),a

		ld	a,(MoonService_dev_mem)		;проверим наличие банка 0
		and	1
		jp 	z,MoonService_test_ram_12

		ld	hl,1030h
		ld	bc,0000h			;B - номер банка, С - номер сегмента
		ld	d,8				;число сегментов-столбцов
MoonService_test_ram_0:
		ld	(MoonService_text_tpos + 1),hl

		call	MoonService_check_segment	;проверка одного сегмента
		ld	a,0fh                           ;сегмент исправен
		jr      z,MoonService_test_ram_01
		ld	a,0ah				;сегмент неисправен
MoonService_test_ram_01:
		ld	(MoonService_text_tcol + 1),a
		inc	c				;увеличим номер сегмента

		push	bc
		ld	hl,MoonService_text_tpos
		call	VideoDRV_print_string
		pop	bc

		ld	e,3				;число сегментов в строке
MoonService_test_ram_1:
		call	MoonService_check_segment	;проверка одного сегмента

		ld	a,0fh                           ;сегмент исправен
		jr      z,MoonService_test_ram_11
		ld	a,0ah				;сегмент неисправен
MoonService_test_ram_11:
		ld	(MoonService_text_tcol + 1),a
		inc	c				;увеличим номер сегмента

		push	bc
		ld	hl,MoonService_text_tcol ;seg
		call	VideoDRV_print_string
		pop	bc

		call	MoonService_check_anykey
		jp	nz,MoonService_test_ram_5
		
		dec	e
		jr	nz,MoonService_test_ram_1

		ld	hl,(MoonService_text_tpos + 1)
		ld	a,l
		add	a,8
		ld	l,a
		dec	d
		jr	nz,MoonService_test_ram_0

MoonService_test_ram_12:
		ld	a,(MoonService_dev_mem)		;проверим наличие банка 1
		and	2
		jp 	z,MoonService_test_ram_32

		ld	hl,8730h
		ld	bc,0100h			;B - номер банка, С - номер сегмента
		ld	d,8				;число сегментов-столбцов
MoonService_test_ram_2:
		ld	(MoonService_text_tpos + 1),hl

		call	MoonService_check_segment	;проверка одного сегмента
		ld	a,0fh                           ;сегмент исправен
		jr      z,MoonService_test_ram_21
		ld	a,0ah				;сегмент неисправен
MoonService_test_ram_21:
		ld	(MoonService_text_tcol + 1),a
		inc	c				;увеличим номер сегмента

		push	bc
		ld	hl,MoonService_text_tpos
		call	VideoDRV_print_string
		pop	bc

		ld	e,3				;число сегментов в строке
MoonService_test_ram_3:
		call	MoonService_check_segment	;проверка одного сегмента
		ld	a,0fh                           ;сегмент исправен
		jr      z,MoonService_test_ram_31
		ld	a,0ah				;сегмент неисправен
MoonService_test_ram_31:
		ld	(MoonService_text_tcol + 1),a
		inc	c				;увеличим номер сегмента

		push	bc
		ld	hl,MoonService_text_tseg
		call	VideoDRV_print_string
		pop	bc

		call	MoonService_check_anykey
		jr	nz,MoonService_test_ram_5

		dec	e
		jr	nz,MoonService_test_ram_3

		ld	hl,(MoonService_text_tpos + 1)
		ld	a,l
		add	a,8
		ld	l,a
		dec	d
		jr	nz,MoonService_test_ram_2

MoonService_test_ram_32:		
		ld	hl,4000h			;пауза между тестами
MoonService_test_ram_33:		
		dec	hl
		ld	a,l
		or	h
		jr	nz,MoonService_test_ram_33
		
		ld	a,0fh
		ld	(MoonService_text_col + 1),a
		ld	hl,MoonService_text_col
		call	VideoDRV_print_string
	
		ld	hl,1030h
		ld	d,8
MoonService_test_ram_4:		
		ld	(MoonService_text_pos + 1),hl
		ld	hl,MoonService_text_pos
		call	VideoDRV_print_string
		ld	e,24h
MoonService_test_ram_41:
                ld	a,20h
		call	VideoDRV_print_char
		dec	e
		jr	nz,MoonService_test_ram_41	

		ld	hl,(MoonService_text_pos + 1)
		ld	a,l
		add	a,8
		ld	l,a
		dec	d
		jr	nz,MoonService_test_ram_4

		ld	a,(MoonService_check_byte)
		inc	a
		jp	MoonService_test_ram_00
		
MoonService_test_ram_5:
		jp	MoonService_Start
;-------------------------------------------------------------------
; описание: Выход из программы в TR-DOS
; параметры: нет
; возвращаемое  значение: нет
;---------------------------------------------------------------------
MoonService_exit:
		ld	hl, 0
		push	hl
		jp	3D2Fh
;-------------------------------------------------------------------
; описание: Обработка событий меню
; параметры: нет
; возвращаемое  значение: нет
;---------------------------------------------------------------------
MoonService_key_pressed:
		ld	c, (ix + 12h)
		ld	b, (ix + 13h)
		call	sub_0_626B			;отрисовка курсора
		set	3, (iy + 37h)
loc_0_61A5:
		bit	3, (iy + 37h)
		jr	z, loc_0_61AF
		res	3, (iy + 37h)
loc_0_61AF:
		ei	
		halt	
		di	
		bit	5, (iy + 1)
		jr	z, loc_0_61A5
		ld	a, (iy - 32h)
		res	5, (iy + 1)
		cp	0Ah				;нажали кнопку - Стрелка вниз
		jr	nz, loc_0_61CC                  ;нет, тогда на обработку другой кнопки
		call	MoonService_key_down
		set	3, (iy + 37h)
		jr	loc_0_61AF
loc_0_61CC:
		cp	0Bh                              ;нажали кнопку - Стрелка вверх
		jr	nz, loc_0_61D9                   ;нет, тогда на обработку другой кнопки
		call	MoonService_key_up
		set	3, (iy + 37h)
		jr	loc_0_61AF
loc_0_61D9:
		res	7, (iy + 30h)
		ld	(ix + 12h), c
		ld	(ix + 13h), b
		push	af
		ld	a, (ix + 4)
		call	sub_0_6283
		pop	af
		ret	
;-------------------------------------------------------------------
; описание: Обработка событий меню
; параметры: нет
; возвращаемое  значение: нет
;---------------------------------------------------------------------
MoonService_key_down:
		ld	l, (ix + 10h)
		ld	h, (ix + 11h)
		ld	a, h
		or	l
		ret	z
		scf	
		sbc	hl, bc
		ret	z
		inc	bc
		ld	a, (ix + 2)
		sub	3
		cp	(ix + 0Fh)
		jr	z, loc_0_621A
		inc	(ix + 0Fh)
		ld	a, (ix + 4)
		call	sub_0_6283
		ld	de, 20h	; ' '
		add	hl, de
		ld	(loc_0_6284+1),	hl
		ld	a, (ix + 5)
		jp	sub_0_6283
loc_0_621A:
		ld	a, (ix + 0)
		add	a, a
		add	a, a
		add	a, a
		inc	a
		ld	h, a
		ld	a, (ix + 1)
		add	a, (ix + 2)
		sub	2
		add	a, a
		add	a, a
		add	a, a
		ld	l, a
		ld	(VideoDRV_address_screen + 1),hl
		jp	loc_0_7110
;-------------------------------------------------------------------
; описание: Стрелка вверx
; параметры: нет
; возвращаемое  значение: нет
;---------------------------------------------------------------------
MoonService_key_up:
		ld	a, b
		or	c
		ret	z
		dec	bc
		ld	a, (ix + 0Fh)
		and	a
		jr	z, loc_0_6255
		dec	(ix + 0Fh)
		ld	a, (ix + 4)
		call	sub_0_6283
		and	a
		ld	de, 20h	; ' '
		sbc	hl, de
		ld	(loc_0_6284+1),	hl
		ld	a, (ix + 5)
		jr	sub_0_6283

loc_0_6255:
		ld	a, (ix + 0)
		add	a, a
		add	a, a
		add	a, a
		inc	a
		ld	h, a
		ld	a, (ix + 1)
		inc	a
		add	a, a
		add	a, a
		add	a, a
		ld	l, a
		ld	(VideoDRV_address_screen + 1),hl
		jp	loc_0_7138

sub_0_626B:
		push	de
		ld	h, (ix + 0)     		;позиция по X
		ld	l, (ix + 1)                     ;позиция по Y
		ld	a, (ix + 0Fh)			;число пунктов меню
		add	a, l
		ld	l, a
		inc	l
		call	sub_0_7214
		ex	de, hl
		ld	(loc_0_6284 + 1),hl
		ld	a, (ix + 5)
		pop	de
sub_0_6283:
		push	bc
loc_0_6284:
		ld	hl, 0
		push	hl
		ld	b, (ix + 3)
loc_0_628B:
		ld	(hl), a
		inc	hl
		djnz	loc_0_628B
		pop	hl
		pop	bc
		ret	
;-------------------------------------------------------------------
; описание: Проверка одного сегмента RAM
; параметры: B - номер банка
;	     C - номер сегмента по 16Кб
; возвращаемое  значение: Z = 1 исправен, Z = 0 неисправен
;---------------------------------------------------------------------
MoonService_check_segment:
		push	hl
		push	de
		push	bc
		ld	de,0211h			;запись в RAM
		call	MoonService_wave_out

		ld	a,c
		add	a,a
		add	a,a
		rrca
		rrca
		rrca
		rrca
		ld	l,a
		and	0Fh
		ld	h,a
		ld	a,l
		and	0F0h
		ld	l,a

		ld	a,b
		ld	e,20h
		and	a
		jr	z,MoonService_check_segment_0
		ld	e,28h

MoonService_check_segment_0:
		ld	a,e
		or	h
		ld	e,a
		inc	d
		call	MoonService_wave_out

		ld	e,l
		inc	d
		call	MoonService_wave_out
		ld	de,0500h
		call	MoonService_wave_out
		inc	d

		ld	hl,4000h
		ld	a,(MoonService_check_byte)
		ld	e,a

MoonService_check_segment_1:
		call	MoonService_wave_out
		call	MoonService_busy
		inc	e

		dec	hl
		ld	a,l
		or	h
		jr	nz,MoonService_check_segment_1		
		pop	bc			

		push	bc
		ld	de,0211h			;чтение из RAM 
		call	MoonService_wave_out

		ld	a,c
		add	a,a
		add	a,a
		rrca
		rrca
		rrca
		rrca
		ld	l,a
		and	0Fh
		ld	h,a
		ld	a,l
		and	0F0h
		ld	l,a

		ld	a,b
		ld	e,20h
		and	a
		jr	z,MoonService_check_segment_3
		ld	e,28h

MoonService_check_segment_3:
		ld	a,e
		or	h
		ld	e,a
		inc	d
		call	MoonService_wave_out

		ld	e,l
		inc	d
		call	MoonService_wave_out
		ld	de,0500h
		call	MoonService_wave_out
		inc	d

		ld	hl,4000h
		ld	a,(MoonService_check_byte)
		ld	e,a

MoonService_check_segment_4:
		call	MoonService_wave_in
		cp	e
		jr	nz,MoonService_check_segment_5

		inc	e
		dec	hl
		ld	a,l
		or	h
		jr	nz,MoonService_check_segment_4

MoonService_check_segment_5:
		ld	de,0210h			;Отключаем доступ к RAM
		call	MoonService_wave_out
		pop	bc					
		pop	de
		pop	hl
		ret	
;-------------------------------------------------------------------
; описание: Инициализация карты ZXM-MoonSound
; параметры: нет
; возвращаемое  значение: A - 0 нет ошибок, иначе ошибка
;---------------------------------------------------------------------
MoonService_init_card:

		in	a,(MOON_STAT)                       ;проверяем наличие карты
		cp	0FFh
		jr	nz,MoonService_init_0
		ret	

MoonService_init_0:
		ld	de, 0400h 
		call	MoonService_fm2_out
		ld	de, 0503h			; set 1 to NEW2, NEW
		call	MoonService_fm2_out
		ld	de, 0bd00h			; RHYTHM
		call	MoonService_fm1_out
		ld	de, 0210h			; Set WaveTable header
		call	MoonService_wave_out
		
		in	a,(MOON_WDAT)			;получим ID девайса
		and	0E0h
		ld	(MoonService_dev_id),a
		xor	a
		ret	
;-------------------------------------------------------------------
; описание: Запись в регистры fm1
; параметры: D = адрес регистра 
;	     E = данные
; возвращаемое  значение: нет
;-------------------------------------------------------------------
MoonService_fm1_out:
		ld	a, d
		out	(MOON_REG1), a

		nop
		nop
		
		ld	a, e
		out	(MOON_DAT1), a
		ret
;-------------------------------------------------------------------
; описание: Запись в регистры fm2
; параметры: D = адрес регистра 
;	     E = данные
; возвращаемое  значение: нет
;-------------------------------------------------------------------
MoonService_fm2_out:
		ld	a,d
		out	(MOON_REG2), a

		nop
		nop
	
		ld	a,e
		out	(MOON_DAT2), a
		ret
;-------------------------------------------------------------------
; описание: Запись в регистры Wave
; параметры: D = адрес регистра 
;	     E = данные
; возвращаемое  значение: нет
;-------------------------------------------------------------------
MoonService_wave_out:
		ld	a, d
		out	(MOON_WREG),a
		
		nop
		nop	

		ld	a, e
		out	(MOON_WDAT),a
		ret
;-------------------------------------------------------------------
; описание: Чтение из регистра Wave
; параметры: D = адрес регистра 
; возвращаемое  значение: А - данные
;-------------------------------------------------------------------
MoonService_wave_in:
		ld	a, d
		out	(MOON_WREG),a

		push	de				
		pop	de				

		in	a,(MOON_WDAT)
		ret
;-------------------------------------------------------------------
; описание: Ожидание готовности микросхемы
; параметры: нет
; возвращаемое  значение: нет
;-------------------------------------------------------------------
MoonService_busy:
		in	a,(MOON_STAT)
		rra
		jr	c,MoonService_busy		
		ret
;-------------------------------------------------------------------
; описание: Ожидание нажатие клавиши
; параметры: нет
; возвращаемое  значение: нет
;---------------------------------------------------------------------
MoonService_press_anykey:
		ei	
		halt	
		di	
		bit	5, (iy + 1)
		jr	z, MoonService_press_anykey
		ld	a, (iy - 32h)
		res	5, (iy + 1)
		ret	
;-------------------------------------------------------------------
; описание: Проверка нажатия любой клавиши
; параметры: нет
; возвращаемое  значение: нет
;---------------------------------------------------------------------
MoonService_check_anykey:
		ei	
		halt	
		di	
		bit	5, (iy + 1)
		ret	z
		res	5, (iy + 1)
		ret	
;-------------------------------------------------------------------
; описание: Создание в буфере памяти адресов экрана
; параметры: нет
; возвращаемое  значение: нет
;---------------------------------------------------------------------
VideoDRV_create_scraddr:
		ld	b, 18h
		ld	de, 4000h
		ld	hl, 0B800h
loc_0_6F59:
		ld	c, 8
loc_0_6F5B:
		ld	(hl), e
		inc	hl
		ld	(hl), d
		inc	hl
		inc	d
		dec	c
		jr	nz, loc_0_6F5B
		ld	a, 20h ; ' '
		add	a, e
		ld	e, a
		jr	c, loc_0_6F6D
		ld	a, d
		sub	8
		ld	d, a
loc_0_6F6D:
		djnz	loc_0_6F59
		ret	
;-------------------------------------------------------------------
; описание: Очистка экрана и установка заданного цвета атрибута и бордера
; параметры: A - атрибут цвета
; возвращаемое  значение: нет
;---------------------------------------------------------------------
VideoDRV_clear_screen:
		ld	hl, 4000h
		ld	e, l
		ld	d, h
		ld	(hl), l
		inc	e
		ld	bc, 1800h
		ldir	
		ld	(ATTR_P), a
		ld	(BORDCR), a
		ld	hl, 5800h
		ld	d, h
		ld	e, l
		ld	(hl), a
		ld	bc, 2FFh
		inc	e
		ldir	
		rrca	
		rrca	
		rrca	
		and	7
		out	(0FEh),	a
		ret	

sub_0_6FA9:
		ld	a, (ix + 0)
		inc	ix
		add	a, c
		ld	l, a
		ld	h, (ix + 0)
		inc	ix
		ld	d, h
		ld	e, l
		inc	e
		ld	(hl), 0FFh
		push	bc
		call	sub_0_71B0
		pop	bc
		djnz	sub_0_6FA9
		ret	

sub_0_6FC2:
		push	hl
		push	bc
		push	ix
		push	af
		ld	a, 22h ; '"'
		sub	b
		add	a, a
		ld	(sub_0_71B0+1),	a
		push	bc
		ld	a, c
		rlca	
		rlca	
		rlca	
		dec	a
		dec	a
		ld	b, a
		ld	ix, 0B800h
		ex	de, hl
		ld	l, d
		ld	h, 0
		add	hl, hl
		add	hl, hl
		add	hl, hl
		add	hl, hl
		ex	de, hl
		add	ix, de
		push	ix
		ld	c, l

loc_0_6FE8:
		inc	ix
		inc	ix
		ld	e, (ix + 0)
		ld	d, (ix + 1)
		ld	a, c
		add	a, e
		ld	e, a
		ex	de, hl

loc_0_6FF6:
		ld	(hl), 80h ; 'А'
		inc	hl
		ld	(hl), 0
		ld	d, h
		ld	e, l
		inc	e
		push	bc
		call	sub_0_71B0
		pop	bc

loc_0_7003:
		ld	(hl), 1
		djnz	loc_0_6FE8
		ld	e, (ix + 0)
		ld	d, (ix + 1)
		inc	d
		ld	a, c
		add	a, e
		ld	e, a
		ex	de, hl

loc_0_7012:
		ld	(hl), 0FFh
		ld	d, h
		ld	e, l
		inc	e
		push	bc
		call	sub_0_71B0
		ldi	
		pop	bc
		pop	ix
		ld	e, (ix + 0)
		ld	d, (ix + 1)
		ld	a, c
		add	a, e
		ld	e, a
		ex	de, hl

loc_0_702A:
		ld	(hl), 0FFh
		ld	d, h
		ld	e, l
		inc	e
		push	bc
		call	sub_0_71B0
		ldi	
		pop	bc
		ld	a, (ix + 0)
		add	a, c
		ld	e, a
		ld	a, (ix + 1)
		rra	
		rra	
		rra	
		and	0Fh
		or	50h ; 'P'
		ld	d, a
		ex	de, hl
		pop	de
		ld	b, e
		pop	af

loc_0_704A:
		push	hl
		ld	d, h
		ld	e, l
		inc	e
		ld	(hl), a
		push	bc
		call	sub_0_71B0
		ldi	
		pop	bc
		pop	hl
		ld	de, 20h	; ' '
		add	hl, de
		djnz	loc_0_704A
		pop	ix
		pop	bc
		pop	hl
		ret	
;-------------------------------------------------------------------
; описание: Создание окна на экране
; параметры: IX - адрес параметров окна
; возвращаемое  значение: нет
;---------------------------------------------------------------------
;ОПИСАТЕЛЬ ОКНА (АДРЕС В IX)
;+00 X КООРДИНАТА
;+01 Y КООРДИНАТА
;+02 V ВЫСОТА
;+03 H ШИРИНА
;+04 C ЦВЕТ
;+05 C ЦВЕТ КУРСОРА
;+06 F ФЛАГОВЫЙ
;+07 N НОМЕР ПУНКТА В ОКНЕ
;  БИТ 7-0=БАЙТЫ 8-9 ТЕКУЩИЙ ПУНКТ МЕНЮ,
;        1=БАЙТЫ 8-9 АДРЕС ХРАНЕНИЯ
;+08 | ТЕКУЩИЙ
;+09 | ПУНКТ МЕНЮ
;+0A : КОЛИЧЕСТВО
;+0B : ПУНКТОВ МЕНЮ
;+0C | АДРЕС
;+0D | ТЕКСТА
;+0E : СПИСОК АДРЕСОВ
;+0F : ПОДПРОГРАММ
;+10 | АДРЕС СПИСКА АКТИВНЫХ
;+11 | ЗОН ДЛЯ МЫШИ
;+12 : АДРЕС СПИСКА
;+13 : ГОРЯЧИХ КЛАВИШ

;ФОРМАТ ФЛАГОВОГО БАЙТА ОКНА
;IX+6
;7-0-НЕТ, 1-ЕСТЬ НИЖНИЙ ЗАГОЛОВОК
;6-0-С РАМКОЙ,1-БЕЗ РАМКИ
;5-0-НЕТ, 1-ЕСТЬ ВЕРХНИЙ ЗАГОЛОВОК
;4-0-НЕТ, 1-ЕСТЬ ТЕКСТ
;3
;2-
;1-
;0-
;---------------------------------------------------------------------
VideoDRV_create_window:
		bit	6,(ix + 8)			;проверим нужно рисовать рамку или нет
		ld	hl, 8001h
		ld	b,0FFh
		jr	z,loc_0_7071
		ld	hl,0
		ld	b,l
loc_0_7071:
		ld	a, h
		ld	(loc_0_6FF6+1),	a
		ld	a, l
		ld	(loc_0_7003+1),	a
		ld	a, b
		ld	(loc_0_702A+1),	a
		ld	(loc_0_7012+1),	a
		ld	l, (ix + 0)     		;позиция по X
		ld	h, (ix + 1)                     ;позиция по Y
		ld	c, (ix + 2)                     ;высота
		ld	b, (ix + 3)                     ;ширина
		ld	a, (ix + 4)                     ;цвет
		ld	(VideoDRV_colour_attr + 1),a
		call	sub_0_6FC2			;рисуем рамку

		bit	5, (ix + 8)                     ;проверяем наличие верхнего заголовка
		jr	z, loc_0_70B9                   ;нет его - пропускаем
		ld	hl, sub_0_71B0+1
		dec	(hl)
		dec	(hl)
		push	ix
		ld	c, (ix + 0)                     ;позиция по X
		ld	b, 8
		ld	l, (ix + 1)                     ;позиция по Y
		ld	h, 0
		ld	ix, 0B800h
		add	hl, hl
		add	hl, hl
		add	hl, hl
		add	hl, hl
		ex	de, hl
		add	ix, de
		call	sub_0_6FA9
		pop	ix
loc_0_70B9:
		bit	7, (ix + 8)			;проверяем наличие нижнего заголовка
		jr	z, loc_0_70E0                   ;нет его - пропускаем
		push	ix
		ld	c, (ix + 0)                     ;позиция по X
		ld	b, 8
		ld	a, (ix + 1)                     ;позиция по Y
		add	a, (ix + 2)                     ;высота
		dec	a
		ld	l, a
		ld	h, 0
		add	hl, hl
		add	hl, hl
		add	hl, hl
		add	hl, hl
		ld	ix, 0B800h
		ex	de, hl
		add	ix, de
		call	sub_0_6FA9
		pop	ix
loc_0_70E0:
		ld	a, (ix + 0)                      ;позиция по X
		add	a, a
		add	a, a
		add	a, a
		inc	a
		ld	d, a
		ld	(loc_0_72A6 + 1),a
		ld	(VideoDRV_centre_state_01 + 1),a
		ld	a, (ix + 1)      		;позиция по Y
		add	a, a
		add	a, a
		add	a, a
		ld	e, a
		ld	(VideoDRV_address_screen + 1),de
		ld	a, (ix + 3)                     ;ширина
		add	a, a
		add	a, a
		add	a, a
		ld	(VideoDRV_centre_state_00 +1),a

		bit	4, (ix + 8)			;проверим есть ли текст
		ret	nz                              ;если нет, то выходим

		ld	l, (ix + 0Dh)			;получим адрес текста 
		ld	h, (ix + 0Eh)                   ;и
		jp	VideoDRV_print_string           ;веведем его в окно
loc_0_7110:
		push	bc
		push	ix
		ld	l, (ix + 1)                     ;позиция по Y
		inc	l
		call	sub_0_71F3
loc_0_711A:
		ld	a, (ix + 10h)
		add	a, c
		ld	l, a
		ld	h, (ix + 11h)
		ld	a, (ix + 0)
		add	a, c
		ld	e, a
		ld	d, (ix + 1)                     ;позиция по Y
		call	sub_0_7165
		ld	de, 10h
		add	ix, de
		djnz	loc_0_711A
		pop	ix
		pop	bc
		ret	

loc_0_7138:
		push	bc
		push	ix
		ld	a, (ix + 2)                      ;высота
		add	a, (ix + 1)                      ;позиция по Y
		sub	3
		ld	l, a
		call	sub_0_71F3

loc_0_7147:
		ld	a, (ix + 0)                      ;позиция по X
		add	a, c
		ld	l, a
		ld	h, (ix + 1)                      ;позиция по Y
		ld	a, (ix + 10h)
		add	a, c
		ld	e, a
		ld	d, (ix + 11h)
		call	sub_0_7165
		ld	de, 0FFF0h
		add	ix, de
		djnz	loc_0_7147
		pop	ix
		pop	bc
		ret	
sub_0_7165:
		push	bc
		push	hl
		push	de
		call	sub_0_71B0
		pop	de
		pop	hl
		inc	h
		inc	d
		push	hl
		push	de
		call	sub_0_71B0
		pop	de
		pop	hl
		inc	h
		inc	d
		push	hl
		push	de
		call	sub_0_71B0
		pop	de
		pop	hl
		inc	h
		inc	d
		push	hl
		push	de
		call	sub_0_71B0
		pop	de
		pop	hl
		inc	h
		inc	d
		push	hl
		push	de
		call	sub_0_71B0
		pop	de
		pop	hl
		inc	h
		inc	d
		push	hl
		push	de
		call	sub_0_71B0
		pop	de
		pop	hl
		inc	h
		inc	d
		push	hl
		push	de
		call	sub_0_71B0
		pop	de
		pop	hl
		inc	h
		inc	d
		push	hl
		push	de
		call	sub_0_71B0
		pop	de
		pop	hl
		inc	h
		inc	d
		pop	bc
		ret	

sub_0_71B0:
		jr	sub_0_71B0
		ldi	
		ldi	
		ldi	
		ldi	
		ldi	
		ldi	
		ldi	
		ldi	
		ldi	
		ldi	
		ldi	
		ldi	
		ldi	
		ldi	
		ldi	
		ldi	
		ldi	
		ldi	
		ldi	
		ldi	
		ldi	
		ldi	
		ldi	
		ldi	
		ldi	
		ldi	
		ldi	
		ldi	
		ldi	
		ldi	
		ldi	
		ldi	
		ret	

sub_0_71F3:
		ld	a, 20h ; ' '
		sub	(ix + 3)                         ;ширина
		add	a, a
		ld	(sub_0_71B0+1),	a
		ld	c, (ix + 0)                      ;позиция по X
		ld	b, (ix + 2)                      ;высота
		dec	b
		dec	b
		dec	b
		ld	h, 0
		add	hl, hl
		add	hl, hl
		add	hl, hl
		ld	ix, 0B800h
		ex	de, hl
		add	ix, de
		add	ix, de
		ret	
sub_0_7214:
		ld	(loc_0_7231 + 1),a
		ld	a, l
		and	18h
		or	40h ; '@'
		ex	af, af'
		ld	a, l
		and	7
		rrca	
		rrca	
		rrca	
		add	a, h
		ld	l, a
		ex	af, af'
		ld	h, a
		ld	e, l
		ld	a, h
		rrca	
		rrca	
		rrca	
		and	3
		or	58h ; 'X'
		ld	d, a
loc_0_7231:
		ld	a, 0
		ret	
;-------------------------------------------------------------------
; описание: Печать на экран строку символов
; параметры: HL - адрес строки символов
; возвращаемое  значение: нет
;---------------------------------------------------------------------
VideoDRV_print_string:
		ld	a, (hl)
		inc	hl
		and	a
		ret	z
		call	VideoDRV_print_char
		jr	VideoDRV_print_string
;-------------------------------------------------------------------
; описание: Печать на экран символа в HEX виде
; параметры: A - выводимый символ
; возвращаемое  значение: нет
;---------------------------------------------------------------------
VideoDRV_print_hex:
		push	af
		rrca	
		rrca	
		rrca	
		rrca	
		call	VideoDRV_print_hex_0
		pop	af
VideoDRV_print_hex_0:
		and	0Fh
		cp	0Ah
		jr	c,VideoDRV_print_hex_1
		add	a,7
VideoDRV_print_hex_1:
		add	a,30h
;-------------------------------------------------------------------
; описание: Печать на экран символ
; параметры: A - выводимый символ
; возвращаемое  значение: нет
;---------------------------------------------------------------------
VideoDRV_print_char:
		cp	20h ; ' '
		jr	nc, VideoDRV_print_symbol
		cp	3			
		jr	nz, VideoDRV_function_09
;-------------------------------------------------------------------
; описание: Функция 03h - ЦЕНТРОВКА СТРОКИ В ОКНЕ
;---------------------------------------------------------------------
		ld	b,0             	
		push	hl

VideoDRV_centre_loop:
		ld	a, (hl)
		cp	20h ; ' '
		jr	c, VideoDRV_centre_state_00
		ld	a, 6
		add	a, b                        
		ld	b, a
		inc	hl
		jr	VideoDRV_centre_loop

VideoDRV_centre_state_00:
		ld	a, 0
		sub	b
		srl	a
		dec	a

VideoDRV_centre_state_01:
		add	a, 0
		ld	(VideoDRV_address_screen + 2),	a
		pop	hl
		ret	
;-------------------------------------------------------------------
; описание: Функция 09h - ТАБУЛЯЦИЯ НА N ПОЗИЦИЙ
;---------------------------------------------------------------------
VideoDRV_function_09:
		cp	9
		jr	nz, VideoDRV_function_0D
		ld	a, (hl) 		
		inc	hl
		ld	b, a
		add	a, a
		add	a, b
		add	a, a
		ld	b, a
		ld	a, (VideoDRV_address_screen + 2)
		add	a, b
		ld	(VideoDRV_address_screen + 2),a
		ret	
;-------------------------------------------------------------------
; описание: Функция 0Dh - ПЕРЕВОД СТРОКИ 
;---------------------------------------------------------------------
VideoDRV_function_0D:
		cp	0Dh
		jr	nz,VideoDRV_function_14
loc_0_72A6:
		ld	a, 0			
		ld	(VideoDRV_address_screen + 2),	a
		ld	a, (VideoDRV_address_screen + 1)
		add	a, 8
		ld	(VideoDRV_address_screen + 1),	a
		ret	
;-------------------------------------------------------------------
; описание: Функция 14h - ВКЛ/ВЫКЛ ИНВЕРСИИ ПЕЧАТИ
;---------------------------------------------------------------------
VideoDRV_function_14:
		cp	14h
		jr	nz, VideoDRV_function_16
		ld	a, (hl)			
		inc	hl
		and	a
		jr	z, VideoDRV_change_inverse
		ld	a, 0FCh

VideoDRV_change_inverse:
		ld	(VideoDRV_inverse_state + 1),a
		ret	
;-------------------------------------------------------------------
; описание: Функция 16h - ПЕЧАТЬ В УКАЗАННОЙ ПОЗИЦИИ
;---------------------------------------------------------------------
VideoDRV_function_16:
		cp	16h
		jr	nz,VideoDRV_function_17
		ld	c, (hl)			
		inc	hl
		ld	b, (hl)
		inc	hl
		ld	(VideoDRV_address_screen + 1),bc
		ret	
;-------------------------------------------------------------------
; описание: Функция 17h - Установка атрибута 
;---------------------------------------------------------------------
VideoDRV_function_17:
		cp 	17h
		ret	nz
		ld	a,(hl)
		inc	hl
		ld	(VideoDRV_colour_attr + 1),a
		ret
;-------------------------------------------------------------------
; описание: Вывод символа
;---------------------------------------------------------------------
VideoDRV_print_symbol:
		push	hl
		push	de
		ld	de, EvaFont_address
		ld	l, a
		xor	a
		ld	h, a
		add	hl, hl
		add	hl, hl
		add	hl, hl
		add	hl, de
		exx	

VideoDRV_address_screen:
		ld	hl, 0
		ld	d, a
		ld	a, h
		and	0F8h ; '°'
		ld	b, a
		ld	a, h
		and	7
		ld	c, a
		ld	a, 6
		add	a, h
		ld	h, a
		ld	(VideoDRV_address_screen + 1),hl
		ld	e, l
		ld	a, b
		ld	hl,0B800h
		ld	b, d
		add	hl, de
		add	hl, de
		rrca	
		rrca	
		rrca	
		add	a, (hl)
		inc	hl
		ld	e, a
		ld	d, (hl)
		ld	a, 15h
		sub	c
		sub	c
		sub	c
		ld	(loc_0_731B+1),	a
		ld	hl, VideoDRV_table_mask
		add	hl, bc
		add	hl, bc
		ld	a, (hl)
		inc	hl
		ld	h, (hl)
		ld	l, a
		ex	de, hl
		ld	a, 8
loc_0_7312:
		ex	af, af'
		exx	
		ld	a, (hl)
		inc	hl
		exx	

VideoDRV_inverse_state:
		xor	0
		ld	c, a
		xor	a
loc_0_731B:
		jr	loc_0_732F+1

		srl	c
		rra	
		srl	c
		rra	
		srl	c
		rra	
		srl	c
		rra	
		srl	c
		rra	
		srl	c
		rra	

loc_0_732F:
		srl	c
		rra	
		ld	b, a
		ld	a, (hl)
		and	e
		or	c
		ld	(hl), a
		inc	l
		ld	a, (hl)
		and	d
		or	b
		ld	(hl), a
		dec	l
		inc	h
		ex	af, af'
		dec	a
		jp	nz, loc_0_7312
		dec	h
		ld 	a,h
		rrca
		rrca
		rrca
		and	3
		or 	58h
		ld 	h,a

VideoDRV_colour_attr:
		ld	a,0
		ld 	(hl),a
		exx	
		pop	de
		pop	hl
		ret	

;-------------------------------------------------------------------
; описание: Таблица масок
;---------------------------------------------------------------------
VideoDRV_table_mask:
		db    	3 
		db 	0FFh
		db  	81h
		db 	0FFh
		db 	0C0h
		db 	0FFh
		db 	0E0h
		db  	7Fh
		db 	0F0h
		db  	3Fh
		db 	0F8h
		db  	1Fh
		db 	0FCh
		db  	0Fh
		db 	0FEh
		db    	7
;-------------------------------------------------------------------
; описание: Поиск по таблице соответствий нажатия клавиши и пункта меню
; параметры: нет
; возвращаемое  значение: нет
;---------------------------------------------------------------------
MoonService_menu_action:
		pop	hl
		ld	b, a
loc_0_7449:
		ld	a, (hl)
		inc	hl
		and	a
		jr	nz, loc_0_744F
		jp	(hl)
loc_0_744F:
		ld	e, (hl)
		inc	hl
		ld	d, (hl)
		inc	hl
		cp	b
		jr	nz, loc_0_7449
		push	de
loc_0_7457:
		ld	a, (hl)
		inc	hl
		and	a
		jr	nz, loc_0_745E
		ex	(sp), hl
		jp	(hl)
loc_0_745E:
		inc	hl
		inc	hl
		jr	loc_0_7457
;-------------------------------------------------------------------
; описание: Сообщения о ошибках
;---------------------------------------------------------------------
aErrorCrcError:	
		db 	"ERROR: CRC error"
		db 	0
aErrorSndNotFound:
		db 	"ERROR: Sound card not found!"
		db 	0
aErrorRamNotFound:
		db 	"ERROR: No SRAM memory!"
		db 	0
;-------------------------------------------------------------------
; описание: Информационные сообщения  
;---------------------------------------------------------------------
MoonService_id_unk:
		db 	"Unknown",0
MoonService_id_ym278:
		db 	"YMF278",0
MoonService_mem_none:
		db 	"None",0
MoonService_mem_512:
		db 	"512Kb",0
MoonService_mem_1024:
		db 	"1024Kb",0
MoonService_mem_2048:
		db 	"2048Kb",0
MoonService_msg_Dev:
		db 	0Dh," Chip: ",0
MoonService_msg_RAM:
		db 	0Dh," RAM:  ",0
MoonService_msg_ROM:
		db 	0Dh," ROM:  ",0
;-------------------------------------------------------------------
; описание: Пустое окно для вывода сообщений
;---------------------------------------------------------------------
MoonService_window_message:
		db    	5 ;
		db    	8 ;  
		db    	3 ;  
		db  	17h ;  
		db  	17h ;  
		db    	0 ;  
		db    	0 ;  
		db    	0 ;  
		db    	0 ;  
		db    	0 ;  
		db    	0 ;  
		db    	0 ;  
		db    	0 ;  
		dw 	unk_0_7528
		db    	0 ;  
		db    	0 ;  
		db    	0 ;  
		db    	0 ;  
		db    	0 ;  
unk_0_7528:	db  	0Dh
		db  	20h ;  
		db    	0 ;  
;-------------------------------------------------------------------
; описание: Окно меню
;---------------------------------------------------------------------
MoonService_window_menu:
		db    	1		;+0 позиция по X 
		db  	2               ;+1 позиция  по Y
		db    	6               ;+2 высота
		db  	0Eh             ;+3 ширина
		db  	0Fh             ;+4 цвет
		db  	1Fh
		db 	0B6h
		db  	76h
		db  	20h 		;+08h - флаговый байт  
		db    	0 ;  
		db    	0 ;  
		db    	0 ;  
		db    	0 ;  
		dw 	unk_0_76D2
		db    	0 ;  
		db    	4 ;              ;+0Fh -  число пунктов меню
		db    	0 ;  
		db    	0 ;  
		db    	0 ;  
unk_0_76D2:	db  	14h 
		db    	1	 ;  
		db    	3 ;  
		db 	"Select"
		db 	14h
		db 	0
		db 	0Dh  
		db    	3 ;  
		db 	"Test RAM"
		db  	0Dh ;  
		db    	3 ;  
		db 	"Test ROM"
		db  	0Dh ;  
		db    	3 ;  
		db 	"Update ROM"
		db  	0Dh ;  
		db    	3 ;  
		db 	"Exit"
		db 	0
;-------------------------------------------------------------------
; описание: Заголовк приложения 
;---------------------------------------------------------------------
MoonService_window_name:
		db    	0
		db    	0 ;  
		db  	18h ;  
		db  	20h ;  
		db  	29h ; )
		db  	1Fh ;  
		db    	0 ;  
		db    	0 ;  
		db  	22h ; "
		db    	0 ;  
		db    	0 ;  
		db    	0 ;  
		db    	0 ;  
		dw 	unk_0_7706
		db    	0 ;  
		db    	0 ;  
		db    	0 ;  
		db    	0 ;  
		db    	0 ;  
unk_0_7706:	db  	14h 
		db    	1 ;  
		db    	3 ;  
		db 	"MoonService for *ZXM-MoonSound* v0.3a"
		db  	14h ;  
		db    	0 ;  
		db    	0 ;  
;-------------------------------------------------------------------
; описание: Окно информации о карте
;---------------------------------------------------------------------
MoonService_window_info:
		db    	10h 
		db    	2 ;  
		db  	5 ;  
		db  	0Eh ;  
		db  	0Fh ;  
		db    	0 ;  
		db    	0 ;  
		db    	0 ;  
		db  	22h ; "
		db    	0 ;  
		db    	0 ;  
		db    	0 ;  
		db    	0 ;  
		dw 	unk_0_7737
		db    	0 ;  
		db    	0 ;  
		db    	0 ;  
		db    	0 ;  
		db    	0 ;  
unk_0_7737:	db  	14h
		db    	1 ;  
		db    	3 ;  
		db 	"Sound card Info"
		db  	14h ;  
		db    	0 ;  
		db    	0 ;  
;-------------------------------------------------------------------
; описание: Окно справки
;---------------------------------------------------------------------
MoonService_window_help:
		db    	0
		db  	12h ;  
		db    	6 ;  
		db  	20h ;  
		db  	0Fh ;  
		db    	0 ;  
		db    	0 ;  
		db    	0 ;  
		db    	0 ;  
		db    	0 ;  
		db    	0 ;  
		db    	0 ;  
		db    	0 ;  
		dw 	unk_0_7771
		db    	0 ;  
		db    	0 ;  
		db    	0 ;  
		db    	0	 ;  
		db    	0 ;  
unk_0_7771:	db  	0Dh
		db    	3 ;  
		db 	"Сервисная программа для проверки"
		db  	0Dh ;  
		db    	3 ;  
		db 	"функционирования звуковой карты"
		db  	0Dh ;  
		db    	3 ;  
		db 	"*ZXM-MoonSound*, Micklab, 2015...2016"
		db 	0
;-------------------------------------------------------------------
; описание: Окно обновления
;---------------------------------------------------------------------
MoonService_window_tram:
		db    	1 
		db    	2 ;  
		db  	15 ;  
		db  	30 ;  
		db  	0Fh ;  
		db    	0 ;  
		db    	0 ;  
		db    	0 ;  
		db  	22h ; "
		db    	0 ;  
		db    	0 ;  
		db    	0 ;  
		db    	0 ;  
		dw 	MoonService_taddr_tram
		db    	0 ;  
		db    	0 ;  
		db    	0 ;  
		db    	0 ;  
		db    	0 ;  
MoonService_taddr_tram:	
		db	14h
		db  	1
		db    	3 ;  
		db 	"Test Static RAM"
		db  	14h ;  
		db    	0 ;  
		db  	0Dh ;  
		db  	0Dh ;  
		db	3
		db 	"Bank 0              Bank 1"
MoonService_text_tinfo:
		db	16h,70h,10h,17h,0fh
		db	20h,0dch,0dch,0dch
		db	" - 16кб сегмент исправен"
		db	16h,78h,10h,17h,0ah
		db	20h,0dch,0dch,0dch,17h,0fh
		db	" - 16кб сегмент неисправен",0
;-------------------------------------------------------------------
; описание: Окно справки  в режиме проверки RAM
;---------------------------------------------------------------------
MoonService_window_hram:
		db    	0
		db  	12h ;  
		db    	6 ;  
		db  	20h ;  
		db  	0Fh ;  
		db    	0 ;  
		db    	0 ;  
		db    	0 ;  
		db    	0 ;  
		db    	0 ;  
		db    	0 ;  
		db    	0 ;  
		db    	0 ;  
		dw 	MoonService_taddr_hram
		db    	0 ;  
		db    	0 ;  
		db    	0 ;  
		db    	0	 ;  
		db    	0 ;  
MoonService_taddr_hram:
		db  	0Dh
		db    	3 ;  
		db 	"Проверка работоспособности микросхем ОЗУ"
		db  	0Dh ;  
		db    	3 ;  
		db 	"Bank 0 соотвествует микросхеме DD4"
		db  	0Dh ;  
		db    	3 ;  
		db 	"Bank 1 соотвествует микросхеме DD5"
		db  	0Dh ;  
		db    	3 ;  
		db 	"Нажатие на любую клавишу - выход из теста"
		db 	0

		.include "rom_test.asm"	
		.include "flash.asm"	
		.include "sdcard.asm"
;-------------------------------------------------------------------
; описание: Текстовые переменные
;---------------------------------------------------------------------
MoonService_text_tpos:
		db	16h,0,0
MoonService_text_tcol:
		db	17h,0
MoonService_text_tseg:
		db	20h,0dfh,0dfh,0dfh,0

MoonService_text_pos:
		db	16h,0,0,0
MoonService_text_col:
		db	17h,0,0

		.include "evafont.inc"
unk_0_831B:	
		db    	0
MoonService_dev_id:
		db	0
MoonService_dev_mem:
		db	0
MoonService_check_byte:
		db	0

MoonService_End:
		.savebin "MoonService.bin",MoonService_Start, MoonService_End - MoonService_Start

		.end
