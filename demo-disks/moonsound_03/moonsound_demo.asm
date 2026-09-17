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

		ld	a,10h 
		ld	bc,7ffdh
		out	(c),a
		ld	hl,0D000h			;грузим ADWENTUR.MWM
		ld	de,(5CF4h)
		ld	bc,0F05h
		call	3d13h
		call	MoonSound_mwmload


		ld	a,11h 
		ld	bc,7ffdh
		out	(c),a
		ld	hl,0D000h			;грузим CHURCHDE.MWM
		ld	de,(5CF4h)
		ld	bc,1F05h
		call	3d13h
		call	MoonSound_mwmload

		ld	a,13h 
		ld	bc,7ffdh
		out	(c),a
		ld	hl,0D000h			;грузим FOTI.MWM
		ld	de,(5CF4h)
		ld	bc,1F05h
		call	3d13h
		call	MoonSound_mwmload

		ld	a,14h 
		ld	bc,7ffdh
		out	(c),a
		ld	hl,0D000h			;грузим JAZZY.MWM
		ld	de,(5CF4h)
		ld	bc,0D05h
		call	3d13h
		call	MoonSound_mwmload

		ld	a,16h 
		ld	bc,7ffdh
		out	(c),a
		ld	hl,0D000h			;грузим MADNESS2.MWM
		ld	de,(5CF4h)
		ld	bc,0D05h
		call	3d13h
		call	MoonSound_mwmload

		ld	a,17h 
		ld	bc,7ffdh
		out	(c),a
		ld	hl,0D000h			;грузим TRAGEDY.MWM
		ld	de,(5CF4h)
		ld	bc,1005h
		call	3d13h
		call	MoonSound_mwmload

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

		ld	hl,0FFE0h
		ld	de,xlfo_table
		ld	bc,12h
		ldir

		ld	hl,0C000h
		ld	(songdata_adres),hl
		call	MBPlayer_init

		ld	a,60h                          
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
		jr	nz,MoonSound_key_E
		ld	a,4
                ld	(MoonSound_key_press),a
		jr	MoonSound_loop

MoonSound_key_E:
		ld	a,0FBh
		in	a,(0FEh)
		bit	2,a
		jr	nz,MoonSound_key_F
		ld	a,5
                ld	(MoonSound_key_press),a
		jr	MoonSound_loop

MoonSound_key_F:
		ld	a,0FDh
		in	a,(0FEh)
		bit	3,a
		jr	nz,MoonSound_key_Break
		ld	a,6
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
		jp	z,MoonSound_key_clear		;эта мелодия уже играет

		ld	a,8
		call	MBPlayer_fade			;затухание мелодии
		
MoonSound_fade_wait:	
		ld	a,(play_busy)			;ждем пока остановится проигрыватель
		or	a
		jr	nz,MoonSound_fade_wait

		ld	a,l
		ld	(MoonSound_page_memory),a	;номер страницы памяти новой мелодии
		ld	bc,7ffdh
		out	(c),a

		ld	hl,0FFE0h
		ld	de,xlfo_table
		ld	bc,12h
		ldir

		ld	hl,0C000h
		ld	(songdata_adres),hl
		call	MBPlayer_init

		ld	a,10h				;возвращаем текущую страницу
		ld	bc,7ffdh
		out	(c),a
		ei
		jp      MoonSound_key_clear

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
		ld	(songdata_adres),hl

;--- Load MWM file ---

; Note: The routine below is a bit complex because it supports
; songs > 16K. However, if you know that your song will always be < 16K you
; can simplify it a lot:
; - read the header and trash it!
; - read the rest of the file
; - modify the play_nextpos routine so that 3 is added to the pattern address

mbload:

		ld	hl,songdata_bank1	; select first song bank
		ld	(load_bank),hl
		ld	a,(hl)
;	call	selbank_FE

		ld	hl,6
		ld	de,(songdata_adres)
		call	load_file			; read header
;	ld	a,8				; file type 8 = wave user song
;	call	check_header
;	jr	nz,loderr2

		ld	hl,278
		ld	de,(songdata_adres)		; read settings
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
		jr	z,mbload2
		ld	de,(load_adres)
		ld	hl,(load_buffer)
		call	load_file

		ld	de,0C000h
		ld	(load_adres),de
		ld	hl,(load_bank)
		inc	hl
		ld	a,(hl)
		ld	(load_bank),hl
;	call	selbank_FE
		jr	mbload_lp

mbload2:
		ld	de, dXlfo
		ld	hl, 4
		call	load_file
		ld	b, l
		ld	hl, aXlfo
		call	xlfo_compare
		jr	nz,xlfo_init
		ld	de,xlfo_table
		ld	hl, 12h
		call	load_file

		ld	hl,xlfo_table
		ld	de,0FFE0h
		ld	bc,12h
		ldir
		ret

aXlfo:		db 	'XLFO'
dXlfo:		db    	0,0,0,0  


xlfo_compare:
		ld	a, (de)
		cp	(hl)
		ret	nz
		inc	hl
		inc	de
		djnz	xlfo_compare
		ret	

xlfo_init:
		ld	hl,xls_table
		ld	de,0FFE0h
		ld	bc,12h
		ldir
		ret
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

;-------------------------------------------------------------------
; описание: Таблица страниц
;---------------------------------------------------------------------
MoonSound_page_table:
		db	10h,11h,13h,14h,16h,17h

MoonSound_page_memory:
		db	0		
MoonSound_key_press:
		db	0

load_adres:	dw	0
load_bank:	dw	0
load_position:	dw	0
load_buffer:	db	0,0,0


Interrupt_handle:
		push	hl
		push	de
		push	bc
		push	af


;		in	a, (0C4h)
;		rla	
;		jr	nc, Interrupt_exit

		call	Str_play

		ld	a,(MoonSound_page_memory)	;загрузим номер страницы памяти текущей музыки
		ld	bc,7ffdh
		out	(c),a
		call	MBPlayer_play

		ld	a,10h
		ld	bc,7ffdh
		out	(c),a

Interrupt_exit:

		pop	af
		pop	bc
		pop	de
		pop	hl
		ei
		ret


		.include  string.asm
		.include  mwm_player.asm

MoonSound_end:
		.savebin "moonsound.bin",MoonSound_Start, MoonSound_end - MoonSound_Start


		.end

