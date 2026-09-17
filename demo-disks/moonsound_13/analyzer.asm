;--------------------------------------------------------------------
; Описание: Модуль отображения анализатора
; Автор: Тарасов М.Н.(Mick),2016
;--------------------------------------------------------------------

;-------------------------------------------------------------------
; описание: Обновление параметров анализатора
; параметры: нет
; возвращаемое  значение: нет
;---------------------------------------------------------------------
Analyzer_update:
		ld	a, 0Ch
		ld	(byte_0_CF9), a
		ld	de, MBPlayer_volume_buffer_2
		ld	hl, Analyzer_vol_table_1
		ld	a, 24

loc_0_5D8:
		ex	af, af'
		push	hl
		ld	a, (de)

		and	0Fh
		ld	c,a
		ld	a,(de)
		and	0F0h
		rrca	
		rrca	
		rrca
		rrca	
		cp	c
		jr	nc,Analyzer_up_ch0
		ld	a,c	

Analyzer_up_ch0:
		and	0Fh
		jr	z, loc_0_5EA
		neg	
		add	a, 11h
		jp	loc_0_5F0

loc_0_5EA:
		ld	a, (hl)
		cp	1
		jr	c, loc_0_5FA
		dec	a
loc_0_5F0:
		ld	(hl), a
loc_0_5FA:
		ld	a, 4
		ld	hl, byte_0_CF9
		add	a, (hl)
		ld	(hl), a
		pop	hl
		inc	hl
		xor	a
		ld	(de), a
		inc	de
		ex	af, af'
		dec	a
		jr	nz, loc_0_5D8
		ret
;-------------------------------------------------------------------
; описание: Отображение анализатора
; параметры: нет
; возвращаемое  значение: нет
;---------------------------------------------------------------------
Analyzer_view:
		ld	c,15
		ld	hl,4049h
		call	Analyzer_draw

		ld	c,14
		ld	hl,4249h
		call	Analyzer_draw

		ld	c,13
		ld	hl,4449h
		call	Analyzer_draw
                                                        
		ld	c,12
		ld	hl,4649h
		call	Analyzer_draw

		ld	c,11
		ld	hl,4069h
		call	Analyzer_draw
                                                       
		ld	c,10
		ld	hl,4269h
		call	Analyzer_draw

		ld	c,9
		ld	hl,4469h
		call	Analyzer_draw

		ld	c,8
		ld	hl,4669h
		call	Analyzer_draw

		ld	c,7
		ld	hl,4089h
		call	Analyzer_draw

		ld	c,6
		ld	hl,4289h
		call	Analyzer_draw

		ld	c,5
		ld	hl,4489h
		call	Analyzer_draw

		ld	c,4
		ld	hl,4689h
		call	Analyzer_draw

		ld	c,3
		ld	hl,40A9h
		call	Analyzer_draw

		ld	c,2
		ld	hl,42A9h
		call	Analyzer_draw

		ld	c,1
		ld	hl,44A9h
		call	Analyzer_draw

		ld	hl,46A9h
		call	Analyzer_fill
		ret
;-------------------------------------------------------------------
; описание: Отрисовка левого канала анализатора
; параметры: HL - адрес экрана
;            C - позиция в индикаторе
; возвращаемое  значение: нет
;---------------------------------------------------------------------
Analyzer_draw:
		ld	b,12
		ld	de, Analyzer_vol_table_1
Analyzer_loop:
		ld	(hl),0
		ld	a,(de)
		cp	c
		jr	c,Analyzer_skip_0
		ld	(hl),70h
Analyzer_skip_0:
		inc	de

		ld	a,(de)
		cp	c
		jr	c,Analyzer_skip_1
		ld	a,07h
		or	(hl)
		ld	(hl),a
Analyzer_skip_1:
		inc	l
		inc	de
		djnz	Analyzer_loop
		ret	
;-------------------------------------------------------------------
; описание: Отрисовка левого канала анализатора
; параметры: HL - адрес экрана
; возвращаемое  значение: нет
;---------------------------------------------------------------------
Analyzer_fill:
		ld	b,12

Analyzer_fill_loop:
		ld	(hl),77h
		inc	l
		djnz	Analyzer_fill_loop
		ret	
;-------------------------------------------------------------------
; описание: Обновление параметров анализатора
; параметры: нет
; возвращаемое  значение: нет
;---------------------------------------------------------------------
Analyzer_init:
              	ld	b, 24
		ld	hl,Analyzer_vol_table_1

Analyzer_init_loop:
                ld	(hl),0
		inc	hl
		djnz	Analyzer_init_loop
		ret
;-------------------------------------------------------------------
; описание: Отрисовка атрибутов иероглифа
; параметры: нет
; возвращаемое  значение: нет
;---------------------------------------------------------------------
Analyzer_draw_flash:
		ld	a,(Analyzer_vol_table_1)
		ld	e,a
		ld	a,(Analyzer_vol_table_1 + 1)
		add	e
		and	0Fh
		ld	hl,Analyzer_table_1
		ld	e,a
		ld	d,0
		add	hl,de
		ld	a,(hl)
		ld	hl,5990h
		ld	(hl),a
		inc	l
		ld	(hl),a

		ld	l,0AEh
		ld	(hl),a
		inc	l
		ld	(hl),a
		inc	l
		ld	(hl),a
		inc	l
		ld	(hl),a
		inc	l
		ld	(hl),a

		ld	l,0CEh
		ld	(hl),a
		inc	l
		ld	(hl),a
		inc	l
		ld	(hl),a
		inc	l
		ld	(hl),a
		inc	l
		ld	(hl),a
		inc	l
		ld	(hl),a

		ld	l,0EDh
		ld	(hl),a
		inc	l
		ld	(hl),a
		inc	l
		ld	(hl),a
		inc	l
		ld	(hl),a
		inc	l
		ld	(hl),a
		inc	l
		ld	(hl),a
		inc	l
		ld	(hl),a

		ld	hl,5A0Eh
		ld	(hl),a
		inc	l
		ld	(hl),a
		inc	l
		ld	(hl),a
		inc	l
		ld	(hl),a
		inc	l
		ld	(hl),a

		ld	l,2Eh
		ld	(hl),a
		inc	l
		ld	(hl),a
		inc	l
		ld	(hl),a
		inc	l
		ld	(hl),a
		inc	l
		ld	(hl),a

		ret
;-------------------------------------------------------------------
; описание: Таблица атрибутов 
;---------------------------------------------------------------------
Analyzer_table_1:
		db	4Fh,4Fh,4Fh,4Eh,4Eh,4Eh,4Dh,4Dh,4Dh,4Ch,4Ch,4Bh,4Bh,4Ah,4Ah,4Ah	
;-------------------------------------------------------------------
; описание:  Переменные правого и левого каналов анализатора
;---------------------------------------------------------------------
byte_0_CF9:
		ds	1
Analyzer_vol_table_1:
		ds	24
