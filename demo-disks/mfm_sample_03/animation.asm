;--------------------------------------------------------------------
; Описание: Анимация спрайта говорящего кота
; Автор порта: Тарасов М.Н.(Mick),2012
;--------------------------------------------------------------------
Animation_init:
		xor	a
		ld	(Animation_step),a
		ld	(Animation_phase),a
Animation_view:
		ld	a,(Animation_step)
		inc	a
		ld	(Animation_step),a
		cp	07h
		ret	nz
		xor	a
		ld	(Animation_step),a
		ld	a,(Animation_phase)
		inc	a	
		cp	9
		jr	c,Animation_next_cat_phase
		xor	a

Animation_next_cat_phase:
		ld	(Animation_phase),a
		ld	l,a
		ld	h,0
		add	hl,hl
		ld	bc,Animation_table_phase_cat
		add	hl,bc
		ld	a,(hl)
		inc	hl
		ld	h,(hl)
		ld	l,a
		ld	a,90h
		ld	bc,7ffdh
		out	(c),a
		ld	de,40F3h
		ld	b,64h				;размерность по Y
		
Animation_loop_Y_cat:
		ld	c,20h
		push	de
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
		inc	d
		ld	a,d
		and 	7
		jr	nz,Animation_next_line_cat
		ld	a,e
		add	20h
		ld	e,a
		jr	c,Animation_next_line_cat
		ld	a,d
		sub	8
		ld	d,a
Animation_next_line_cat:
    		djnz    Animation_loop_Y_cat
		ret	    

Animation_step:
		db	0
Animation_phase:
		db	0

Animation_table_phase_cat:
                dw	CatPoison_phase_000	
                dw	CatPoison_phase_001	
                dw	CatPoison_phase_002	
                dw	CatPoison_phase_003	
                dw	CatPoison_phase_004	
                dw	CatPoison_phase_005	
                dw	CatPoison_phase_006	
                dw	CatPoison_phase_007	
                dw	CatPoison_phase_008	
