;-------------------------------------------------------------------
; описание: Запрос информации о типе ПЗУ
; параметры: нет
; возвращаемое  значение: нет
;---------------------------------------------------------------------
MoonService_flash_info:
		ld	b,0
		ld	hl,0555h
		ld	c,0AAh
		call	MoonService_flash_bwrite
		ld	hl,02AAh
		ld	c,55h
		call	MoonService_flash_bwrite
		ld	hl,0555h
		ld	c,90h
		call	MoonService_flash_bwrite

		ld	hl,0
		call	MoonService_flash_bread 	;Manufacturer ID
		ld	a,c
		ld	(MoonService_flash_manufacturer),a

		inc	hl
		call	MoonService_flash_bread 	;Device ID
		ld	a,c
		ld	(MoonService_flash_device),a

		dec	hl
		ld	c,0F0h
		call	MoonService_flash_bwrite	;сброс

		ld	a,(MoonService_flash_device)
		cp	0ADh
		jr	nz,MoonService_flash_unknown

		ld	a,(MoonService_flash_manufacturer)		
		ld	hl, MoonService_flash_amd
		cp	01h                      	;AM29F016
		jr	z,MoonService_flash_print		

		ld	hl, MoonService_flash_stm
		cp	20h                             ;M29F016
		jr	z,MoonService_flash_print		
		
		ld	hl, MoonService_flash_mxic
		cp	0C2h                            ;MX29F016
		jr	z,MoonService_flash_print		

MoonService_flash_unknown:
		ld	hl,MoonService_id_unk

MoonService_flash_print:
		call	VideoDRV_print_string
		ret
;-------------------------------------------------------------------
; описание: Запись байта в ПЗУ
; параметры: 
;	     HL - адрес записи
;	     B  - номер страницы
;	     С  - записываемый байт 
; возвращаемое  значение: нет 
;---------------------------------------------------------------------
MoonService_flash_bwrite:
		push	de
		ld	de,0211h			;запись в ROM
		call	MoonService_wave_out

		ld	a,b                             ;номер страницы
		and	1Fh
		ld	e,a
		inc	d
		call	MoonService_wave_out

		ld	e,h                             ;старший адрес сегмента
		inc	d
		call	MoonService_wave_out

		ld	e,l                             ;младший байт сегмента
		inc	d
		call	MoonService_wave_out

		inc	d
		ld	e,c				;записываемый байт
		call	MoonService_wave_out

		ld	de,0210h			;Отключаем доступ к ROM
		call	MoonService_wave_out
		pop	de
		ret	
;-------------------------------------------------------------------
; описание: Чтение байта из ПЗУ
; параметры: 
;	     HL - адрес записи
;	     B  - номер страницы
; возвращаемое  значение:  C  - прочитанный байт
;---------------------------------------------------------------------
MoonService_flash_bread:
		push	de
		ld	de,0211h			;запись в ROM
		call	MoonService_wave_out

		ld	a,b                             ;номер страницы
		and	1Fh
		ld	e,a
		inc	d
		call	MoonService_wave_out

		ld	e,h                             ;старший адрес сегмента
		inc	d
		call	MoonService_wave_out

		ld	e,l                             ;младший байт сегмента
		inc	d
		call	MoonService_wave_out

		inc	d
		call	MoonService_wave_in		;читаем байт	
		ld	c,a

		ld	de,0210h			;Отключаем доступ к ROM
		call	MoonService_wave_out
		pop	de
		ret	
;-------------------------------------------------------------------
; описание: Процесс записи во FLASH ПЗУ
; параметры: нет
; возвращаемое  значение: нет
;---------------------------------------------------------------------
MoonService_update_flash:
		ld	ix, MoonService_window_hflash     ;окно справки
		call	VideoDRV_create_window

		ld	ix, MoonService_window_tflash     ;создадим окно теста
		call	VideoDRV_create_window

		ld 	hl,MoonService_flash_file
		push	iy
		CALL 	SDCard_start
		pop	iy
		jp 	c,MoonService_error_00

		ld	hl,MoonService_flash_warning          
		call	VideoDRV_print_string        	;выведем сообщение

		ld	a,30h
		ld	(MoonService_flash_num),a
		ld	(MoonService_flash_num + 1),a


		ld	hl,1020h
		ld	(MoonService_flash_page + 1),hl          

		xor	a
		ld	(NUM_CLS_ST),a
		ld	(MoonService_flash_cpage),a	;страницы ПЗУ

MoonService_update_00:
		ld	a,(MoonService_flash_cpage)
		cp	11
		jr	c,MoonService_update_01

		call	MoonService_flash_scroll

MoonService_update_01:
		ld	hl,MoonService_flash_page	;---------  Загрузка -------------          
		call	VideoDRV_print_string        	;выведем сообщение

		ld	hl,MoonService_flash_load          
		call	VideoDRV_print_string        	;выведем сообщение

		push	iy
		ld	a,(NUM_CLS_ST)
      		ld 	iyh,a				;ИЗНАЧАЛЬНОЕ СМЕЩЕНИЕ В КЛАСТЕРЕ
		ld	bc,(NUM_CLS_HIGH)
		ld	de,(NUM_CLS_LOW)

		ld	a,4				;четыре страницы по 16 кб
		ld 	hl,0C000h			;адрес буфера
MoonService_update_02:
		push	af
		push 	hl

		dec	a
		call	MoonService_set_page		;установим номер страницы

		ld 	a,(BYTSSEC)			;ВЗЯЛИ РАЗМЕР КЛАСТЕРА В СЕКТОРАХ
		ld 	ixh,a				;СОХРАНИЛИ
		ld 	ixl,20h				;32 сектора по 512байт = 16кб
		call 	LD_FILE				;прочитаем данные из файла
		jr 	c,MoonService_update_03		;файл закончился

		pop	hl
		pop 	af
		dec 	a
		jr	nz,MoonService_update_02	;еще есть данные

		push	af
		push	hl

MoonService_update_03:
		pop	hl
		pop 	af
		ld	a,iyh
		ld	(NUM_CLS_ST),a
		ld	(NUM_CLS_HIGH),bc		;сохраним номер кластера, где находится файл
		ld	(NUM_CLS_LOW),de
		pop	iy

		ld	hl,(MoonService_flash_page + 1)	;---------  Проверка -------------
		ld	h,46h
		ld	(MoonService_text_tpos2 + 1),hl
		ld	hl,MoonService_text_tpos2          
		call	VideoDRV_print_string

		ld	hl,MoonService_flash_check          
		call	VideoDRV_print_string        	;выведем сообщение

		ld	a,(MoonService_flash_cpage)	;текущая страница ПЗУ
		call	MoonService_flash_checking
		jp	c,MoonService_test_flash_5

		ld	hl,(MoonService_flash_page + 1)	;---------  Стирание -------------
		ld	h,46h
		ld	(MoonService_text_tpos2 + 1),hl
		ld	hl,MoonService_text_tpos2          
		call	VideoDRV_print_string

		ld	hl,MoonService_flash_erase          
		call	VideoDRV_print_string        	;выведем сообщение

		ld	a,(MoonService_flash_cpage)	;текущая страница ПЗУ
		call	MoonService_flash_erasing
		jp	c,MoonService_test_flash_5

		ld 	bc,0 				;---------  Пауза -------------
MoonService_update_13:
		dec	bc                              ;ожидаем пока микруха придет в себя
		ld	a,b                             ;после стирания
		or	c
		jr 	nz,MoonService_update_13		

		ld	hl,(MoonService_flash_page + 1)	;---------  Запись -------------
		ld	h,46h
		ld	(MoonService_text_tpos2 + 1),hl
		ld	hl,MoonService_text_tpos2          
		call	VideoDRV_print_string

		ld	hl,MoonService_flash_write          
		call	VideoDRV_print_string        	;выведем сообщение

		call	MoonService_flash_writing
		jp	c,MoonService_test_flash_5

		ld	hl,(MoonService_flash_page + 1)	;---------  Проверка -------------
		ld	h,46h
		ld	(MoonService_text_tpos2 + 1),hl
		ld	hl,MoonService_text_tpos2          
		call	VideoDRV_print_string

		ld	hl,MoonService_flash_verify          
		call	VideoDRV_print_string        	;выведем сообщение

		ld	a,(MoonService_flash_cpage)	;текущая страница ПЗУ
		call	MoonService_flash_verifying
		jp	c,MoonService_test_flash_5
		

		ld	hl,(MoonService_flash_page + 1)	;---------  OK -------------
		ld	h,46h
		ld	(MoonService_text_tpos2 + 1),hl
		ld	hl,MoonService_text_tpos2          
		call	VideoDRV_print_string

		ld	hl,MoonService_flash_ok          
		call	VideoDRV_print_string        	;выведем сообщение


		ld	a,(MoonService_flash_num + 1)
		inc	a
		cp	3Ah
		jr	c,MoonService_update_04
		ld	a,(MoonService_flash_num)
		inc	a
		ld	(MoonService_flash_num),a
		ld	a,30h
MoonService_update_04:
		ld	(MoonService_flash_num + 1),a

		ld	a,(MoonService_flash_cpage)
		inc	a
		ld	(MoonService_flash_cpage),a

		cp	11
		jr	nc,MoonService_update_05

		ld	a,(MoonService_flash_page + 1)
		add	a, 8
		ld	(MoonService_flash_page + 1),a

MoonService_update_05:
		ld	a,(MoonService_flash_cpage)
		cp	32
		jp	nz,MoonService_update_00

		jp 	MoonService_test_flash_5

MoonService_error_00:
		cp 	0EEh
		ld 	hl,aErrorSdCardNot
		jr 	z,MoonService_error_01
		cp 	0DDh
		ld 	hl,aErrorFatNotFou
		jr 	z,MoonService_error_01
		cp 	99h
		ld 	hl,aErrorRomSize
		jr 	z,MoonService_error_01
		ld 	hl,aErrorFileNotFo

MoonService_error_01:
		push	hl
		ld	ix,MoonService_window_message    ;адрес окна 
		call	VideoDRV_create_window       	;создадим текущее окно

		pop	hl          
		call	VideoDRV_print_string        	;выведем сообщение

MoonService_test_flash_5:
		ld	a,5
		call	MoonService_set_page		;установим номер страницы

		ld	hl,MoonService_flash_pressanykey          
		call	VideoDRV_print_string        	;выведем сообщение

		call	MoonService_check_anykey
		jp	z,MoonService_test_flash_5

		jp	MoonService_Start


MoonService_flash_scroll:
      		ld	b,8

MoonService_flash_scroll_00:
      		ld	hl,4180h
      		ld	de,4080h

		push	bc
     		ld  	a,96

MoonService_flash_scroll_01:
		push	af
      		push	hl
      		push	hl

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

      		pop	de
      		pop	hl
      		call	MoonService_flash_lnext
      		pop	af
      		dec	a
      		jp	nz,MoonService_flash_scroll_01
		pop	bc
		dec	 b
		jp	nz,MoonService_flash_scroll_00
      		ret

MoonService_flash_lnext:
		inc	h
      		ld	a,h
      		and	7
      		ret	nz
      		ld	a,l
      		add	20h
      		ld	l,a
      		ret	c
      		ld	a,h
      		sub	08h
      		ld	h,a
      		ret

MoonService_set_page:
		push	bc
	        ld	bc,MoonService_num_page
		add	a,c
		ld	c,a
		jr	nc,MoonService_num_page_0
		inc 	b
MoonService_num_page_0:
		ld	a,(bc)
		ld	bc,7ffdh
		out	(c),a
		pop	bc
		ret
;-------------------------------------------------------------------
; описание: Таблица номеров страниц
;---------------------------------------------------------------------
MoonService_num_page:
		db	17h,16h,14h,13h,11h,10h
;-------------------------------------------------------------------
; описание: Проверка контрольной суммы загруженной страницы
; параметры: A - номер страницы
; возвращаемое  значение: 
;---------------------------------------------------------------------
MoonService_flash_checking:
		ld	c,a				;номер текущей страницы
		ld	b,0				;четыре страницы по 16 кб

MoonService_flash_checking_00:
		push	bc

		ld	a,3
		sub	b
		call	MoonService_set_page		;установим номер страницы
		call	MoonService_check_crc		;подсчитаем контрольную сумму -> регистр E
		pop	bc

		ld	hl,MoonService_crc_table
		ld	a,c
		rlca
		rlca
		add	a,b
		add	a,l
		jr 	nc,MoonService_flash_checking_01
		inc	h

MoonService_flash_checking_01:
		ld	l,a
		ld	a,(hl)				;возьмем контстанту из таблицы
		cp	e		                ;сравним ее с подсчитанной
		jr	nz,MoonService_flash_checking_02;ошибка чтения

		inc 	b
		ld	a,b
		cp	4	
		jr	nz,MoonService_flash_checking_00;еще есть данные
		xor	a				;нет нет ошибок
		ret

MoonService_flash_checking_02:				;ошибка
		ld	hl,(MoonService_flash_page + 1)	
		ld	h,46h
		ld	(MoonService_text_tpos2 + 1),hl
		ld	hl,MoonService_text_tpos2          
		call	VideoDRV_print_string

		ld	hl,MoonService_flash_error          
		call	VideoDRV_print_string        	;выведем сообщение

                scf
		ret
;-------------------------------------------------------------------
; описание: Сравнение записанного в ПЗУ и буфера
; параметры: A - номер страницы
; возвращаемое  значение: 
;---------------------------------------------------------------------
MoonService_flash_verifying:
		ld	c,a

		ld	de,0211h			;чтение из ROM
		call	MoonService_wave_out
		ld	e,c
		inc	d
		call	MoonService_wave_out

		ld	e,0
		inc	d
		call	MoonService_wave_out
		inc	d
		call	MoonService_wave_out
		inc	d
		ld	b,e				;четыре страницы по 16 кб

MoonService_flash_verifying_00:
		push	bc

		ld	a,3
		sub	b
		call	MoonService_set_page		;установим номер страницы

		ld	bc,16384
		ld	hl,0C000h

MoonService_flash_verifying_01:
		call	MoonService_wave_in
		cp	(hl)
		jr	nz,MoonService_flash_verifying_02;ошибка сравнения
		inc	hl
		dec	bc
		ld	a,b
		or	c
		jr	nz,MoonService_flash_verifying_01
		pop	bc

		inc 	b
		ld	a,b
		cp	4	
		jr	nz,MoonService_flash_verifying_00;еще есть данные

		ld	de,0210h			;Отключаем доступ к ROM
		call	MoonService_wave_out

		xor	a				;нет нет ошибок
		ret

MoonService_flash_verifying_02:				;ошибка

		ld	c,0F0h
		call	MoonService_flash_bwrite	;сброс

		pop	bc
		ld	de,0210h			;Отключаем доступ к ROM
		call	MoonService_wave_out

		ld	hl,(MoonService_flash_page + 1)	
		ld	h,46h
		ld	(MoonService_text_tpos2 + 1),hl
		ld	hl,MoonService_text_tpos2          
		call	VideoDRV_print_string

		ld	hl,MoonService_flash_error          
		call	VideoDRV_print_string        	;выведем сообщение

                scf
		ret
;-------------------------------------------------------------------
; описание: Стирание страницы ПЗУ
; параметры: A - номер страницы
; возвращаемое  значение: 
;---------------------------------------------------------------------
MoonService_flash_erasing:
		and	1fh					;очистим нужные биты
		push	af 					;запомним номер страницы
		ld	b,0
		ld	hl,0555h
		ld	c,0AAh
		call	MoonService_flash_bwrite
		ld	hl,02AAh
		ld	c,55h
		call	MoonService_flash_bwrite
		ld	hl,0555h
		ld	c,80h
		call	MoonService_flash_bwrite
		ld	hl,0555h
		ld	c,0AAh
		call	MoonService_flash_bwrite
		ld	hl,02AAh
		ld	c,55h
		call	MoonService_flash_bwrite
		pop	af					;восстановим номер страницы
		ld	b,a
		ld	hl,0
		ld	c,30h
		call	MoonService_flash_bwrite

		ld	a,87

MoonService_flash_erasing_00:
        	dec	a
        	jr	nz,MoonService_flash_erasing_00

		ld	hl,0

MoonService_flash_erasing_01:					;
		call	MoonService_flash_bread
		ld	e,c

		call	MoonService_flash_bread
		ld	a,c
		xor	e

        	bit     6,a
        	jr      z,MoonService_flash_erasing_02  ; no toggle - end! (carry is clear)

        	bit     5,a
        	jr      nz,MoonService_flash_erasing_01 ; if toggle and error bit toggles -
                             				; repeat reading

        	bit     5,e 				; toggle, error bit is set - error!
        	jr      z,MoonService_flash_erasing_01  ; otherwise - just toggle, wait more

		push	bc
		jp	MoonService_flash_verifying_02

MoonService_flash_erasing_02:

		ld	de,0210h			;Отключаем доступ к ROM
		call	MoonService_wave_out

		xor	a				;нет ошибок
		ret
;-------------------------------------------------------------------
; описание: Запись страницы ПЗУ
; параметры: A - номер страницы
; возвращаемое  значение: 
;---------------------------------------------------------------------
MoonService_flash_writing:
		ld	hl,0				;адрес внутри страницы
		ld	b,0				;четыре страницы по 16 кб

MoonService_flash_writing_00:
		push	bc

		ld	a,3
		sub	b
		call	MoonService_set_page		;установим номер страницы

		ld	bc,16384
		ld	ix,0C000h

MoonService_flash_writing_01:
		push	bc
		push	hl

		ld	b,0
		ld	hl,0555h
		ld	c,0AAh
		call	MoonService_flash_bwrite
		ld	hl,02AAh
		ld	c,55h
		call	MoonService_flash_bwrite
		ld	hl,0555h
		ld	c,0A0h
		call	MoonService_flash_bwrite

		pop	hl
		ld	a,(MoonService_flash_cpage)	;текущая страница ПЗУ
		ld	b,a
		ld	c,(ix + 0)
		call	MoonService_flash_bwrite

MoonService_flash_writing_02:
		call	MoonService_flash_bread
		ld	e,c

		call	MoonService_flash_bread
		ld	a,c
		xor	e

        	bit     6,a
        	jr      z,MoonService_flash_writing_03  ; no toggle - end! (carry is clear)

        	bit     5,a
        	jr      nz,MoonService_flash_writing_02 ; if toggle and error bit toggles -
                             				; repeat reading

        	bit     5,e 				; toggle, error bit is set - error!
        	jr      z,MoonService_flash_writing_02  ; otherwise - just toggle, wait more

		pop	bc
		jp	MoonService_flash_verifying_02

MoonService_flash_writing_03:

		call	MoonService_flash_bread
		ld	a,(ix + 0)
		cp 	c
		jr	z,MoonService_flash_writing_04

;		push	bc
;		call	VideoDRV_print_hex
;		pop	bc
;		ld	a,c
;		call    VideoDRV_print_hex
		pop	bc
		jp	MoonService_flash_verifying_02
		
MoonService_flash_writing_04:			
		pop	bc
		inc	ix
		inc	hl
		dec	bc
		ld	a,b
		or	c
		jr	nz,MoonService_flash_writing_01

		pop	bc
		inc 	b
		ld	a,b
		cp	4	
		jr	nz,MoonService_flash_writing_00 ;еще есть данные
		xor	a				;нет ошибок
		ret
;-------------------------------------------------------------------
; описание: Окно обновления
;---------------------------------------------------------------------
MoonService_window_tflash:
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
		dw 	MoonService_taddr_tflash
		db    	0 ;  
		db    	0 ;  
		db    	0 ;  
		db    	0 ;  
		db    	0 ;  
MoonService_taddr_tflash:	
		db	14h
		db  	1
		db    	3 ;  
		db 	"Update ROM"
		db  	14h ;  
		db    	0 ;  
		db  	0Dh ;  
		db	3
		db	0
;-------------------------------------------------------------------
; описание: Окно справки  в режиме проверки ROM
;---------------------------------------------------------------------
MoonService_window_hflash:
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
		dw 	MoonService_taddr_hflash
		db    	0 ;  
		db    	0 ;  
		db    	0 ;  
		db    	0	 ;  
		db    	0 ;  
MoonService_taddr_hflash:
		db  	0Dh
		db    	3 ;  
		db 	"Файл обновления должен иметь имя "
		db  	0Dh ;  
		db    	3 ;  
		db 	"MOONSND.ROM и должен находиться"
		db  	0Dh ;  
		db    	3 ;  
		db 	"в корне SD карты (контроллер ZC)."
		db 	0
;-------------------------------------------------------------------
; описание: Информационные сообщения  
;---------------------------------------------------------------------
MoonService_flash_amd:
		db 	"AM29F016",0
MoonService_flash_mxic:
		db 	"MX29F016",0
MoonService_flash_stm:
		db 	"M29F016",0
MoonService_flash_file:		
		db 	"MOONSND.ROM",0
aErrorFileNotFo:
		db 	"ERROR: File not found!"
		db 	0
aErrorFatNotFou:
		db 	"ERROR: FAT not found!"
		db 	0
aErrorSdCardNot:
		db 	"ERROR: SD card not found!"
		db 	0
aErrorRomSize:	
		db	"ERROR: File size error!",0
MoonService_flash_page:
		db	16h,0,0
		db	"Page "
MoonService_flash_num:
		db	'0','0'
		db	": "
		db	0
MoonService_flash_warning:
		db	16h,0B0h,10h,17h,0ah
		db	"  Не выключайте питание компьютера! ",17h,0fh,0
MoonService_flash_pressanykey:
		db	16h,0B0h,10h,17h,0ah
		db	"  Нажмите любую клавишу для выхода! ",17h,0fh,0
MoonService_flash_error:
		db	"Error!      ",0
MoonService_flash_load:
		db	"Loading...  ",0
MoonService_flash_check:
		db	"Checking... ",0
MoonService_flash_erase:
		db	"Erasing...  ",0
MoonService_flash_write:
		db	"Writing...  ",0
MoonService_flash_verify:
		db	"Verifying...",0
MoonService_flash_ok:
		db	"Ok!         ",0
MoonService_text_tpos2:
		db	16h,0,0,0
;-------------------------------------------------------------------
; описание: Переменные
;---------------------------------------------------------------------
MoonService_flash_manufacturer:
		db	0
MoonService_flash_device:
		db	0
MoonService_flash_cpage:
		db	0
