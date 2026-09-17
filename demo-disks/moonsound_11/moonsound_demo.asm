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
		ld	(MoonSound_number_music),a
                ld	(MoonSound_flg_next),a

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
		ld	bc,3F05h
		call	3d13h

		ld	a,13h 
		ld	bc,7ffdh
		out	(c),a
		ld	hl,0C000h			;грузим музыкальный пак 1.
		ld	de,(5CF4h)
		ld	bc,3F05h
		call	3d13h

		ld	a,14h 
		ld	bc,7ffdh
		out	(c),a
		ld	hl,0C000h			;грузим музыкальный пак 2.
		ld	de,(5CF4h)
		ld	bc,4005h
		call	3d13h
		
		ld	a,16h 
		ld	bc,7ffdh
		out	(c),a
		ld	hl,0C000h			;грузим музыкальный пак 3
		ld	de,(5CF4h)
		ld	bc,2C05h
		call	3d13h

;		ld	a,17h 
;		ld	bc,7ffdh
;		out	(c),a
;		ld	hl,0C000h			;грузим музыкальный пак 4
;		ld	de,(5CF4h)
;		ld	bc,3505h
;		call	3d13h


		ld	sp,5fffh
		ld	a,10h 
		ld	bc,7ffdh
		out	(c),a

		call	Str_init			;инициализация бегущей строки
		call	Analyzer_init			

		call	MoonSound_view_number
		call	MoonSound_time_init

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

                ld	a,(MoonSound_flg_next)
		and	a
		jr	nz,MoonSound_select_next 	

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

		ld	a,8
		call	MBPlayer_fade			;затухание мелодии
		
MoonSound_fade_wait:	
		ld	a,(MBPlayer_play_busy)		;ждем пока остановится проигрыватель
		or	a
		jr	nz,MoonSound_fade_wait
		call	MBPlayer_stop


MoonSound_select_next:
		xor	a
                ld	(MoonSound_flg_next),a

		ld	a,(MoonSound_count_music)
		inc	a
		cp	30
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
		ld	hl,0C800h
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

		ld	a,(MoonSound_number_music)
		inc	a
		ld	c,a
		and	0Fh
		cp	10
		jr	c,MoonSound_number_correct
		ld	a,6
		add	c
		ld	c,a

MoonSound_number_correct:
		ld	a,c
		ld	(MoonSound_number_music),a
		cp	31h
		jr	c,MoonSound_number_valid
		ld	a,1

MoonSound_number_valid:
		ld	(MoonSound_number_music),a
		call	MoonSound_view_number
		call	MoonSound_time_init

		ei
		jp      MoonSound_loop

MoonSound_tabl_music:
		db	11h   				; 1 музыкальное произведение
		dw	0C000h
		dw	2C20h
		db	11h   				; 2 музыкальное произведение
		dw	0EC20h
		dw	03D0h
		db	11h   				; 3 музыкальное произведение
		dw	0EFF0h
		dw	08B0h
		db	11h   				; 4 музыкальное произведение
		dw	0F8A0h
		dw	0280h
		db	11h   				; 5 музыкальное произведение
		dw	0FB20h
		dw	0390h

		db	13h   				; 6 музыкальное произведение
		dw	0C000h
		dw	06E0h
		db	13h   				; 7 музыкальное произведение
		dw	0C710h
		dw	0600h
		db	13h   				; 8 музыкальное произведение
		dw	0CD10h
		dw	06D0h
		db	13h   				; 9 музыкальное произведение
		dw	0D3E0h
		dw	06B0h
		db	13h   				; 10 музыкальное произведение
		dw	0DA90h
		dw	07D0h
		db	13h   				; 11 музыкальное произведение
		dw	0E260h
		dw	0BF0h
		db	13h   				; 12 музыкальное произведение
		dw	0EE50h
		dw	07E0h
		db	13h   				; 13 музыкальное произведение
		dw	0F630h
		dw	02F0h
		db	13h   				; 14 музыкальное произведение
		dw	0F920h
		dw	05A0h

		db	14h   				; 15 музыкальное произведение
		dw	0C000h
		dw	0350h
		db	14h   				; 16 музыкальное произведение
		dw	0C350h
		dw	07A0h
		db	14h   				; 17 музыкальное произведение
		dw	0CAF0h
		dw	03C0h
		db	14h   				; 18 музыкальное произведение
		dw	0CEB0h
		dw	06E0h
		db	14h   				; 19 музыкальное произведение
		dw	0D590h
		dw	0A70h
		db	14h   				; 20 музыкальное произведение
		dw	0E000h
		dw	0430h
		db	14h   				; 21 музыкальное произведение
		dw	0E430h
		dw	0790h
		db	14h   				; 22 музыкальное произведение
		dw	0EBC0h
		dw	0690h
		db	14h   				; 23 музыкальное произведение
		dw	0F250h
		dw	0370h
		db	14h   				; 24 музыкальное произведение
		dw	0F5C0h
		dw	0990h

		db	16h   				; 25 музыкальное произведение
		dw	0C000h
		dw	04B0h
		db	16h   				; 26 музыкальное произведение
		dw	0C4B0h
		dw	0C20h
		db	16h   				; 27 музыкальное произведение
		dw	0D0D0h
		dw	0300h
		db	16h   				; 28 музыкальное произведение
		dw	0D3D0h
		dw	0250h
		db	16h   				; 29 музыкальное произведение
		dw	0D620h
		dw	08B0h
		db	16h   				; 30 музыкальное произведение
		dw	0DED0h
		dw	0CE0h



MoonSound_exit:		
		di	
		call	MBPlayer_stop
		ld	hl,0	
		push	hl
      		jp  	3d2fh				;выход в TR-DOS


MoonSound_time_init:
		xor	a
                ld	(MoonSound_time_int),a
		ld	(MoonSound_time_count),a		
		ld	(MoonSound_time_minute),a
		jr	MoonSound_time_draw

MoonSound_time_view:
                ld	a,(MoonSound_time_int)
		inc	a
                ld	(MoonSound_time_int),a
		cp	50
		ret	c
		xor	a
                ld	(MoonSound_time_int),a
                ld	a,(MoonSound_time_count)
		inc	a
		ld	c,a
		and	0Fh
		cp	10
		jr	c,MoonSound_time_next
		ld	a,6
		add	c
		ld	c,a
MoonSound_time_next:
		ld	a,c
		ld	(MoonSound_time_count),a		
		cp	60h
		jr	c,MoonSound_time_draw
		xor	a
		ld	(MoonSound_time_count),a		
		ld	a,(MoonSound_time_minute)
		inc	a
		ld	(MoonSound_time_minute),a
		cp	10
		jr	c,MoonSound_time_draw
		xor	a
		ld	(MoonSound_time_minute),a
MoonSound_time_draw:
		ld	a,(MoonSound_time_minute)
		and	0Fh
		ld	hl,401Ch
		call 	MoonSound_view_symbol
		ld	a,(MoonSound_time_count)
		ld	c,a
		and	0F0h
		rrca
		rrca
		rrca
		rrca
		ld	hl,401Eh
		call	MoonSound_view_symbol
		ld	a,c
		and	0Fh
		ld	hl,401Fh
		jr	MoonSound_view_symbol
 
MoonSound_view_number:
		ld	c,a
		and	0F0h
		rrca
		rrca
		rrca
		rrca
		ld	hl,4007h
		call	MoonSound_view_symbol
		ld	a,c
		and	0Fh
		ld	hl,4008h
MoonSound_view_symbol:
		push	hl
		ld	h,0
		ld	l,a
		add	hl,hl
		add	hl,hl
		add	hl,hl
		ld	de,MoonSound_table_symbol
	        add	hl,de	
		ex	de,hl
		pop	hl
		ld	b,8

MoonSound_view_loop:
		ld	a,(de)
		ld	(hl),a
		inc	de		
		inc	h
		ld	a,h
		and	7
		jr	nz,MoonSound_next_line
		ld	a,l
		add	a,20h
		ld	l,a
		jr	c,MoonSound_next_line
		ld	a,h
		sub	8
		ld	h,a
MoonSound_next_line:
		djnz	MoonSound_view_loop
		ret	

MoonSound_mwmload:
		ld	hl,0C800h
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

		ld	hl,278
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
		ld	a,l
		or	h
		ret	z

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

MoonSound_table_symbol:
  		db 	0,3Ch,66h,6Eh,76h,66h,3Ch,0
  		db 	0,18h,38h,18h,18h,18h,7Eh,0
  		db 	0,3Ch,66h,0Ch,18h,30h,7Eh,0
  		db 	0,7Eh,0Ch,18h,0Ch,66h,3Ch,0
  		db 	0,0Ch,1Ch,3Ch,6Ch,7Eh,0Ch,0
  		db 	0,7Eh,60h,7Ch,06h,66h,3Ch,0
  		db 	0,3Ch,60h,7Ch,66h,66h,3Ch,0
  		db 	0,7Eh,06h,0Ch,18h,30h,30h,0
  		db 	0,3Ch,66h,3Ch,66h,66h,3Ch,0
		db 	0,3Ch,66h,3Eh,06h,0Ch,38h,0

MoonSound_flg_next:
		db	0
MoonSound_number_music:
		db	0

MoonSound_count_music:
		db	0

MoonSound_page_memory:
		db	0		
MoonSound_key_press:
		db	0

MoonSound_time_int:
		db	0
MoonSound_time_count:
		db	0		
MoonSound_time_minute:
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

		call 	Analyzer_update
		call	Str_play
		call	MoonSound_time_view

;		ld	a,(MoonSound_page_memory)	;загрузим номер страницы памяти текущей музыки
;		ld	bc,7ffdh
;		out	(c),a
		call	MBPlayer_play

		call 	Analyzer_view

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


		.include  analyzer.asm
		.include  string.asm
		.include  mwm_player.asm

MoonSound_end:
		.savebin "moonsound.bin",MoonSound_Start, MoonSound_end - MoonSound_Start


		.end

