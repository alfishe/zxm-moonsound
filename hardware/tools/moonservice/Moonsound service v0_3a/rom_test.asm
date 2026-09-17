;-------------------------------------------------------------------
; описание: Процесс тестирования ПЗУ
; параметры: нет
; возвращаемое  значение: нет
;---------------------------------------------------------------------
MoonService_test_rom:
		ld	ix, MoonService_window_hrom     ;окно справки
		call	VideoDRV_create_window

		ld	ix, MoonService_window_trom     ;создадим окно теста
		call	VideoDRV_create_window
MoonService_test_rom_00:

		ld	hl,4228h
		ld	c,0				;B - номер банка, С - номер сегмента
		ld	d,8				;число сегментов-столбцов
MoonService_test_rom_0:
		push	hl
		ld	(MoonService_text_tpos1 + 1),hl

		call	MoonService_check_romseg	;проверка одного сегмента
		ld	a,0fh                           ;сегмент исправен
		jr      z,MoonService_test_rom_01
		ld	a,0ah				;сегмент неисправен
MoonService_test_rom_01:
		ld	(MoonService_text_tcol1 + 1), a
		inc	c				;увеличим номер сегмента

		push	bc
		ld	hl,MoonService_text_tpos1
		call	VideoDRV_print_string
		pop	bc

		ld	e,15				;число сегментов в строке
MoonService_test_rom_1:
		call	MoonService_check_romseg	;проверка одного сегмента
		ld	a,0fh                           ;сегмент исправен
		jr      z,MoonService_test_rom_11
		ld	a,0ah				;сегмент неисправен
MoonService_test_rom_11:
		ld	(MoonService_text_tcol1 + 1),a

			
		ld	a,(MoonService_text_tpos1 + 2)
		add	a, 8
		ld	(MoonService_text_tpos1 + 2),a
		inc	c				;увеличим номер сегмента

		push	bc
		ld	hl,MoonService_text_tpos1
		call	VideoDRV_print_string
		pop	bc

		call	MoonService_check_anykey
		jp	nz,MoonService_test_rom_5
		
		dec	e
		jr	nz,MoonService_test_rom_1

		pop	hl
		ld	a,l
		add	a,8
		ld	l,a
		dec	d
		jr	nz,MoonService_test_rom_0

MoonService_test_rom_12:

		ld	hl,4000h			;пауза между тестами

MoonService_test_rom_33:		
		dec	hl
		ld	a,l
		or	h
		jr	nz,MoonService_test_rom_33
		
		ld	a,0fh
		ld	(MoonService_text_col + 1),a
		ld	hl,MoonService_text_col
		call	VideoDRV_print_string
	
		ld	hl,1028h
		ld	d,8
MoonService_test_rom_4:		
		ld	(MoonService_text_pos + 1),hl
		ld	hl,MoonService_text_pos
		call	VideoDRV_print_string
		ld	e,24h
MoonService_test_rom_41:
                ld	a,20h
		call	VideoDRV_print_char
		dec	e
		jr	nz,MoonService_test_rom_41	

		ld	hl,(MoonService_text_pos + 1)
		ld	a,l
		add	a,8
		ld	l,a
		dec	d
		jr	nz,MoonService_test_rom_4

		ld	a,(MoonService_check_byte)
		inc	a
		jp	MoonService_test_rom_00
		
MoonService_test_rom_5:
		pop	hl
		jp	MoonService_Start
;-------------------------------------------------------------------
; описание: Проверка одного сегмента RAM
; параметры: C - номер сегмента по 16Кб
; возвращаемое  значение: Z = 1 исправен, Z = 0 неисправен
;---------------------------------------------------------------------
MoonService_check_romseg:
		push	hl
		push	de
		push	bc
		ld	de,0211h			;чтение из ROM
		call	MoonService_wave_out

		ld	a,c
		add	a,a
		add	a,a
		ld	b,10h
		jr	c, MoonService_check_romseg_0
		ld	b,0
MoonService_check_romseg_0:
		rrca
		rrca
		rrca
		rrca
		ld	l,a
		and	0Fh
		or	b
		ld	h,a
		ld	a,l
		and	0F0h
		ld	l,a
		ld	a,0
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

		ld	bc,16384
		ld	hl,0C000h

MoonService_check_romseg_4:
		call	MoonService_wave_in
		ld	(hl),a
;		inc	e
		inc	hl
		dec	bc
		ld	a,b
		or	c
		jr	nz,MoonService_check_romseg_4

		ld	de,0210h			;Отключаем доступ к ROM
		call	MoonService_wave_out
		call	MoonService_check_crc		;подсчитаем кс сегмента
		pop	bc					
		
		ld	hl,MoonService_crc_table
		ld	a,c
		add	a,l
		jr 	nc,MoonService_check_romseg_5
		inc	h

MoonService_check_romseg_5:
		ld	l,a
		ld	a,(hl)				;возьмем контстанту из таблицы
		cp	e		                ;сравним ее с подсчитанной
		pop	de
		pop	hl
		ret	
;-------------------------------------------------------------------
; описание: Печать на экран строку символов
; параметры: нет
; возвращаемое  значение: байт CRC
;---------------------------------------------------------------------
MoonService_check_crc:
		ld	hl,0C000h			;адрес буфера страницы 16
		ld	bc, 16384
		ld	e,0				;байт CRC
MoonService_check_crc_0:
		ld	a,(hl)
		xor	e
		push	hl
		ld      hl,MoonService_crc8_table
		add	a,l
		jr	nc,MoonService_check_crc_1
		inc	h
MoonService_check_crc_1:
                ld	l,a
		ld	e,(hl)
		pop	hl
		inc	hl	
		dec	bc
		ld	a,b
		or	c
		jr	nz,MoonService_check_crc_0
		ret
;-------------------------------------------------------------------
; описание: Таблица констант контрольной суммы
;---------------------------------------------------------------------
MoonService_crc8_table:
		db	00h,0E5h,2Fh,0CAh,5Eh,0BBh,71h,94h
		db	0BCh,59h,93h,76h,0E2h,07h,0CDh,28h
		db	9Dh,78h,0B2h,57h,0C3h,26h,0ECh,09h
		db	21h,0C4h,0Eh,0EBh,7Fh,9Ah,50h,0B5h
		db	0DFh,3Ah,0F0h,15h,81h,64h,0AEh,4Bh
		db	63h,86h,4Ch,0A9h,3Dh,0D8h,12h,0F7h
		db	42h,0A7h,6Dh,88h,1Ch,0F9h,33h,0D6h
		db	0FEh,1Bh,0D1h,34h,0A0h,45h,8Fh,6Ah
		db	5Bh,0BEh,74h,91h,05h,0E0h,2Ah,0CFh
		db	0E7h,02h,0C8h,2Dh,0B9h,5Ch,96h,73h
		db	0C6h,23h,0E9h,0Ch,98h,7Dh,0B7h,52h
		db	7Ah,9Fh,55h,0B0h,24h,0C1h,0Bh,0EEh
		db	84h,61h,0ABh,4Eh,0DAh,3Fh,0F5h,10h
		db	38h,0DDh,17h,0F2h,66h,83h,49h,0ACh
		db	19h,0FCh,36h,0D3h,47h,0A2h,68h,8Dh
		db	0A5h,40h,8Ah,6Fh,0FBh,1Eh,0D4h,31h
		db	0B6h,53h,99h,7Ch,0E8h,0Dh,0C7h,22h
		db	0Ah,0EFh,25h,0C0h,54h,0B1h,7Bh,9Eh
		db	2Bh,0CEh,04h,0E1h,75h,90h,5Ah,0BFh
		db	97h,72h,0B8h,5Dh,0C9h,2Ch,0E6h,03h
		db	69h,8Ch,46h,0A3h,37h,0D2h,18h,0FDh
		db	0D5h,30h,0FAh,1Fh,8Bh,6Eh,0A4h,41h
		db	0F4h,11h,0DBh,3Eh,0AAh,4Fh,85h,60h
		db	48h,0ADh,67h,82h,16h,0F3h,39h,0DCh
		db	0EDh,08h,0C2h,27h,0B3h,56h,9Ch,79h
		db	51h,0B4h,7Eh,9Bh,0Fh,0EAh,20h,0C5h
		db	70h,95h,5Fh,0BAh,2Eh,0CBh,01h,0E4h
		db	0CCh,29h,0E3h,06h,92h,77h,0BDh,58h
		db	32h,0D7h,1Dh,0F8h,6Ch,89h,43h,0A6h
		db	8Eh,6Bh,0A1h,44h,0D0h,35h,0FFh,1Ah
		db	0AFh,4Ah,80h,65h,0F1h,14h,0DEh,3Bh
		db	13h,0F6h,3Ch,0D9h,4Dh,0A8h,62h,87h
;-------------------------------------------------------------------
; описание: Таблица констант контрольной суммы ПЗУ сэмплов
;---------------------------------------------------------------------
MoonService_crc_table:
		db	0E0h,0DAh,07h,0CFh,7Bh,48h,5Dh,0D9h
		db	93h,0BDh,31h,0Ch,70h,4Ch,0B2h,10h
		db	0F0h,2Bh,57h,11h,1Dh,0DDh,36h,99h
		db	0F3h,83h,0D2h,0FCh,10h,83h,62h,3Fh
		db	34h,0CAh,0C6h,14h,3Ch,57h,65h,0BEh
		db	1Fh,0F1h,0D4h,0F4h,8Ch,0FEh,71h,74h
		db	0C2h,0B2h,22h,35h,89h,5Eh,08h,8Eh
		db	8Ch,97h,0B8h,14h,0EAh,0C8h,6Ah,06h
		db	0F4h,93h,6Bh,0E9h,0E2h,8Ch,3Dh,92h
		db	0FEh,8Ch,0AFh,0EEh,20h,95h,0A0h,97h
		db	54h,87h,0E7h,8Fh,04h,2Ah,0B2h,0DBh
		db	1Eh,0F9h,0AAh,0CAh,79h,0FDh,13h,4Ah
		db	0B1h,0C0h,27h,63h,10h,0B8h,0F0h,43h
		db	0E0h,15h,0B3h,0D6h,0E3h,7Bh,3Fh,0DAh
		db	0DFh,0EDh,2Bh,16h,0CAh,56h,85h,75h
		db	0C3h,0F6h,0E3h,0DBh,0B0h,70h,39h,9Fh

;-------------------------------------------------------------------
; описание: Окно обновления
;---------------------------------------------------------------------
MoonService_window_trom:
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
		dw 	MoonService_taddr_trom
		db    	0 ;  
		db    	0 ;  
		db    	0 ;  
		db    	0 ;  
		db    	0 ;  
MoonService_taddr_trom:	
		db	14h
		db  	1
		db    	3 ;  
		db 	"Test ROM"
		db  	14h ;  
		db    	0 ;  
		db  	0Dh ;  
		db	3
		db	16h,70h,2Ch,17h,0fh
		db	20h,0dch
		db	" - 16кб сегмент исправен"
		db	16h,78h,2Ch,17h,0ah
		db	20h,0dch,17h,0fh
		db	" - 16кб сегмент неисправен",0
;-------------------------------------------------------------------
; описание: Окно справки  в режиме проверки ROM
;---------------------------------------------------------------------
MoonService_window_hrom:
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
		dw 	MoonService_taddr_hrom
		db    	0 ;  
		db    	0 ;  
		db    	0 ;  
		db    	0	 ;  
		db    	0 ;  
MoonService_taddr_hrom:
		db  	0Dh
		db    	3 ;  
		db 	"Проверка контрольной суммы "
		db  	0Dh ;  
		db    	3 ;  
		db 	"информации в ПЗУ (микросхема DD3)"
		db  	0Dh ;  
		db    	3 ;  
		db 	"Нажатие на любую клавишу - выход из теста"
		db 	0
;-------------------------------------------------------------------
; описание: Текстовые переменные
;---------------------------------------------------------------------
MoonService_text_tpos1:
		db	16h,0,0
MoonService_text_tcol1:
		db	17h,0
MoonService_text_tseg1:
		db	0dfh,0
