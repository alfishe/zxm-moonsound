;--------------------------------------------------------------------
; Описание: Программа проигрывания разных звуковых модулей Amstrad CPC
; поддержка в железе: ZXM-MoonSound
; Автор порта: Тарасов М.Н.(Mick),2014
;--------------------------------------------------------------------
		DEVICE ZXSPECTRUM128

		.org 	6200h

;-------------------------------------------------------------------
; описание: Точка входа в программу после передачи управления из ОС
;---------------------------------------------------------------------
MoonSound_Start:		
		xor	a               		;бордер в черный цвет
		out	(0feh),a	
		ld	(MoonSound_count_music),a	;счетчик номера музыки

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
		ld	hl,0C000h			;грузим музыкальный пак 0.
		ld	de,(5CF4h)
		ld	bc,1D05h
		call	3d13h

		ld	a,13h 
		ld	bc,7ffdh
		out	(c),a
		ld	hl,0C000h			;грузим музыкальный пак 1.
		ld	de,(5CF4h)
		ld	bc,2305h
		call	3d13h

		ld	sp,5fffh
		ld	a,10h 
		ld	bc,7ffdh
		out	(c),a
		call	Str_init			;инициализация бегущей строки

		ld	hl,6000h                       	
		ld	de,6001h
		ld	bc,0100h
		ld	(hl),61h
		ldir
		ld	a,0c3h                          
		ld	(6161h),a
		ld	hl,Interrupt_handle
		ld	(6162h),hl

		ld	a,60h                          
		ld	i,a
		im	2

		xor	a
		jp	MoonSound_next_music

;		ei

MoonSound_key:		
		xor	a
                ld	(MoonSound_key_press),a
MoonSound_loop:		
		halt

		ld	a,7fh				;ожидаем пробел - переход к следующей композиции
		in	a,(0feh)
		rra	
		jr	c,MoonSound_key

		ld	a,0FEh
		in	a,(0FEh)
		rra	    
		jp	nc,MoonSound_exit

		ld	a,(MoonSound_key_press)
		and	a
		jr	nz,MoonSound_loop

		inc	a
                ld	(MoonSound_key_press),a

		call	MBPlayer_stop

		ld	a,(MoonSound_count_music)
		inc	a
		cp	2
		jr	c,MoonSound_next_music
		xor	a

MoonSound_next_music:
		di	
		ld	(MoonSound_count_music),a
		ld	l,a
		ld	e,a
		ld	h,0
		ld	d,h
		add	hl,hl
		add	hl,hl
		add	hl,de
		ld	de,MoonSound_tabl_music
		add	hl,de
		ld	a,(hl)				;номер страницы памяти
		ld	(MoonSound_page_memory),a
		inc	hl
		ld	e,(hl)				;адрес трека                          
		inc	hl
		ld	d,(hl)
		inc	hl
		ld	a,(hl)                          ;число неполных байт
		inc	hl
		ld	b,(hl)				;число секторов
		and	a
		jr	z,MoonSound_copy_block
		inc	b	

MoonSound_copy_block:
		ld	hl,0D000h
		ld	(MoonSound_copy_addr),hl
		ex	hl,de

MoonSound_copy_loop:
		push	bc
		ld	a,(MoonSound_page_memory)	;загрузим номер страницы памяти
		ld	bc,7ffdh
		out	(c),a

		ld	de,MoonSound_copy_buffer
		ld	bc,100h
		ldir
		push	hl
		ld	a,10h
		ld	bc,7ffdh
		out	(c),a
		ld	hl,(MoonSound_copy_addr)
		ld	de,MoonSound_copy_buffer
		ex	hl,de
		ld	bc,100h
		ldir
		ex	hl,de
		ld	(MoonSound_copy_addr),hl
		pop	hl
		pop	bc
		djnz	MoonSound_copy_loop

		call	MoonSound_mwmload

		ld	hl,0C000h
		ld	(MBPlayer_songdata_addres),hl
		call	MBPlayer_init

		ei
		jp      MoonSound_loop

MoonSound_tabl_music:
		db	11h   				; 1 музыкальное произведение
		dw	0C000h
		dw	1CC0h

		db	13h   				; 3 музыкальное произведение
		dw	0C000h
		dw	2240h

MoonSound_exit:		
		di	
		call	MBPlayer_stop
		ld	hl,0	
		push	hl
      		jp  	3d2fh				;выход в TR-DOS



MoonSound_mwmload:
		ld	hl,0D000h
		ld	(load_position),hl
		ld	hl,0C000h
		ld	(MBPlayer_songdata_addres),hl

;--- Load MWM file ---

; Note: The routine below is a bit complex because it supports
; songs > 16K. However, if you know that your song will always be < 16K you
; can simplify it a lot:
; - read the header and trash it!
; - read the rest of the file
; - modify the play_nextpos routine so that 3 is added to the pattern address

mbload:

		ld	hl,MBPlayer_songdata_bank1	; select first song bank
		ld	(load_bank),hl
		ld	a,(hl)

		ld	hl,6
		ld	de,(MBPlayer_songdata_addres)
		call	load_file			; read header

		ld	hl,812
		ld	de,(MBPlayer_songdata_addres)		; read settings
		call	load_file
		ld	a,(de)
		add	hl,de
		ex	de,hl
		inc	a
		ld	l,a
		ld	h,0
		call	load_file			; read positions
		call	check_pats
		add	hl,de
		ex	de,hl
		add	a,a
		ld	l,a
		ld	h,0
		call	load_file			; read pattern addresses
		add	hl,de
		ld	(load_adres),hl

mbload_lp:
		ld	de,load_buffer
		ld	hl,3
		call	load_file
		ld	a,(load_buffer + 2)
		or	a
		ret	z
		ld	de,(load_adres)
		ld	hl,(load_buffer)
		call	load_file

		ld	de,0C000h
		ld	(load_adres),de
		ld	hl,(load_bank)
		inc	hl
		ld	a,(hl)
		ld	(load_bank),hl
		jr	mbload_lp



;--- Load (part of) file ---
; In: HL = number of bytes to read
;     DE = transfer address

load_file:	
		push	hl
		push	de
		push	bc

		push	hl
		pop	bc
		ld	hl,(load_position)
		ldir
		ld	(load_position),hl
		pop	bc
		pop	de
		pop	hl
		ret

;--- search highest pattern ---
; In: L = #positions, DE = pointer to patterns
; Out: A = highest pattern

check_pats:	
		push	hl
		push	de
		ld	b,l
		ex	de,hl
		xor	a
check_patslp:	
		cp	(hl)
		jr	nc,check_pats2
		ld	a,(hl)
check_pats2:	inc	hl
		djnz	check_patslp
		inc	a
		pop	de
		pop	hl
		ret

MoonSound_key_press:
		db	0
MoonSound_count_music:
		db	0
MoonSound_page_memory:
		db	0		

MoonSound_copy_addr:
		dw	0
MoonSound_copy_buffer:
		ds	256

load_adres:	dw	0
load_bank:	dw	0
load_position:	dw	0
load_buffer:	db	0,0,0


Interrupt_handle:
		push	hl
		push	de
		push	bc
		push	af

		call	Str_play

;		ld	a,(MoonSound_page_memory)	;загрузим номер страницы памяти текущей музыки
;		ld	bc,7ffdh
;		out	(c),a
		call	MBPlayer_play

;		ld	a,10h
;		ld	bc,7ffdh
;		out	(c),a

Interrupt_exit:

		pop	af
		pop	bc
		pop	de
		pop	hl
		ei
		ret


		.include  string.asm
		.include  mfm_player.asm

MoonSound_end:
		.savebin "moonsound.bin",MoonSound_Start, MoonSound_end - MoonSound_Start


		.end

