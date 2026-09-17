;--------------------------------------------------------------------
; Описание: Программа проигрывания разных звуковых модулей MDR
; поддержка в железе: ZXM-MoonSound
; Автор порта: Тарасов М.Н.(Mick),2015
;--------------------------------------------------------------------
		DEVICE ZXSPECTRUM128

		.org 	6000h

;-------------------------------------------------------------------
; описание: Точка входа в программу после передачи управления из ОС
;---------------------------------------------------------------------
MoonSound_Start:		
		xor	a               		;бордер в черный цвет
		out	(0feh),a	

		ld	hl,4000h
		ld	de,4001h
		ld	bc,1b00h
		ld	(hl),c
		ldir
		
		ld	hl,4000h			;грузим экран
		ld	de,(5CF4h)
		ld	bc,1B05h
		call	3d13h

		call	Str_init_load
		ei
MoonSound_loading:
		halt
		ld	b,0
MoonSound_wait:
		djnz	MoonSound_wait			
		call	Str_play
		jr	c,MoonSound_load
		jr	nc,MoonSound_loading	
MoonSound_load:
		di                                      ;на всякий пожарный запретим прерывания

		ld	a,11h 
		ld	bc,7ffdh
		out	(c),a
		ld	hl,0C000h			;грузим музыку O3D001.MDR - 16кб
		ld	de,(5CF4h)
		ld	bc,4005h
		call	3d13h

		ld	a,13h 
		ld	bc,7ffdh
		out	(c),a
		ld	hl,0C000h			;грузим музыку O3D002.MDR - 8кб.
		ld	de,(5CF4h)
		ld	bc,2005h
		call	3d13h

		ld	a,14h 
		ld	bc,7ffdh
		out	(c),a
		ld	hl,0C000h			;грузим музыку O3D003.MDR - 8кб
		ld	de,(5CF4h)
		ld	bc,2005h
		call	3d13h
		
		ld	a,16h 
		ld	bc,7ffdh
		out	(c),a
		ld	hl,0C000h			;грузим музыку O3D004.MDR - 16кб
		ld	de,(5CF4h)
		ld	bc,4005h
		call	3d13h


		ld	sp,5fffh
		ld	a,11h 
		ld	(MoonSound_page_memory),a
		ld	bc,7ffdh
		out	(c),a
		call	Str_init			;инициализация бегущей строки

		call	MoonDriver_Init
		ld	a,10h 
		ld	bc,7ffdh
		out	(c),a

		ld	hl,0fe00h                       ;создаем таблицу прерывания для im 2
		ld	de,0fe01h
		ld	bc,0100h
		ld	(hl),0fdh
		ldir
		ld	a,0c3h                          ;установим вектор прерывания
		ld	(0fdfdh),a
		ld	hl,Interrupt_handle
		ld	(0fdfeh),hl
		di
		ld	a,0feh                          ;окончание установки прерывания
		ld	i,a
		im	2
		ei
MoonSound_key_clear:		
		xor	a
                ld	(MoonSound_key_press),a
MoonSound_loop:		
		halt

		ld	a,0FDh
		in	a,(0FEh)
		bit	0,a
		jr	nz,MoonSound_key_B
		ld	a,1
                ld	(MoonSound_key_press),a
		jr	MoonSound_loop
MoonSound_key_B:
		ld	a,7Fh
		in	a,(0FEh)
		bit	4,a
		jr	nz,MoonSound_key_C
		ld	a,2
                ld	(MoonSound_key_press),a
		jr	MoonSound_loop
MoonSound_key_C:
		ld	a,0FEh
		in	a,(0FEh)
		bit	3,a
		jr	nz,MoonSound_key_D
		ld	a,3
                ld	(MoonSound_key_press),a
		jr	MoonSound_loop
MoonSound_key_D:
		ld	a,0FDh
		in	a,(0FEh)
		bit	2,a
		jr	nz,MoonSound_key_Break
		ld	a,4
                ld	(MoonSound_key_press),a
		jr	MoonSound_loop
MoonSound_key_Break:
		ld	a,7fh				;ожидаем пробел - переход к следующей композиции
		in	a,(0feh)
		rra	
		jr	c,MoonSound_key_next

		ld	a,0FEh
		in	a,(0FEh)
		rra	    
		jr	nc,MoonSound_exit

MoonSound_key_next:
		ld	a,(MoonSound_key_press)
		and	a
		jr	z,MoonSound_loop

		dec	a
		ld	l,a
		ld	h,0
		ld	de,MoonSound_page_table
		add	hl,de
		ld	a,(hl)				;номер страницы новой музыки
		ld	l,a
		ld	a,(MoonSound_page_memory)	;загрузим номер страницы памяти текущей музыки
		cp	l
		jr	z,MoonSound_key_clear		;эта мелодия уже играет

		di	
		call	MoonDriver_Keyoff
		ld	a,l
		ld	(MoonSound_page_memory),a	;номер страницы памяти новой мелодии
		ld	bc,7ffdh
		out	(c),a
		call	MoonDriver_Init			;инициализируем проигрыватель

		ld	a,10h				;возвращаем текущую страницу
		ld	bc,7ffdh
		out	(c),a
		ei
		jp      MoonSound_key_clear

MoonSound_exit:		
		di	
		call	MoonDriver_Keyoff
		ld	hl,0	
		push	hl
      		jp  	3d2fh				;выход в TR-DOS

;-------------------------------------------------------------------
; описание: Таблица страниц
;---------------------------------------------------------------------
MoonSound_page_table:
		db	11h,13h,14h,16h

MoonSound_page_memory:
		db	0		
MoonSound_key_press:
		db	0

Interrupt_handle:
		push	hl	
		push	bc	
		push	de
		push	af	

		call	Str_play

		ld	a,(MoonSound_page_memory)	;загрузим номер страницы памяти текущей музыки
		ld	bc,7ffdh
		out	(c),a
		call	MoonDriver_Play
		ld	a,10h
		ld	bc,7ffdh
		out	(c),a

		pop	af
		pop	de
		pop	bc
		pop	hl
		ei
		ret


		.include  moon_driver.asm
		.include  string.asm

MoonSound_end:
		.savebin "moonsound.bin",MoonSound_Start, MoonSound_end - MoonSound_Start


		.end

