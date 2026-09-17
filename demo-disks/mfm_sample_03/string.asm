;--------------------------------------------------------------------
; нОХЯЮМХЕ: аЕЦСЫЮЪ ЯРПНЙЮ
; юБРНП ОНПРЮ: НЯМНБЮ БШДПЮМЮ ХГ ГЮОХКЪРНПЮ
;--------------------------------------------------------------------
Str_reload:
		ld	a,(Str_flg_end)
		and	a
		jr 	z,Str_init
		xor	a
		ld	(Str_flg_end),a
		scf
		ret

Str_init:
		ld	a,0Fh
		ld	(Str_count_bit),a
		ld	hl,Str_addr_text
		ld	(Str_addr_work),hl
		ld	a,(hl)
		ret


Str_init_load:
		ld	a,0Fh
		ld	(Str_count_bit),a
		ld	hl,Str_addr_load
		ld	(Str_addr_work),hl
		ld	a,1
		ld	(Str_flg_end),a
		ld	a,(hl)
		ret	

Str_play:
		ld	a,(Str_count_bit)
		inc	a
		and	0Fh
		ld	(Str_count_bit),a
		or	a
		jr	nz, Str_move_string

Str_next_symbol:
		ld	hl,(Str_addr_work)
		ld	a,(hl)
		and	a
		call	z,Str_reload
		ret	c
		inc	hl
		ld	(Str_addr_work),hl
		call	Str_load_symbol

Str_move_string:
		ld	de, 5471h
		ld	hl, Str_buf_data +1 
		ld	b, 10h

Str_move_line:
		scf	
		ccf	
		rl	(hl)
		dec	hl
		rl	(hl)
		inc	hl
		inc	hl
		inc	hl
		ex	de, hl
		push	hl
		rl	(hl)
		dec	hl
		rl	(hl)
		dec	hl
		rl	(hl)
		dec	hl
		rl	(hl)
		dec	hl
		rl	(hl)
		dec	hl
		rl	(hl)
		dec	hl
		rl	(hl)
		dec	hl
		rl	(hl)
		dec	hl
		rl	(hl)
		dec	hl
		rl	(hl)
		dec	hl
		rl	(hl)
		dec	hl
		rl	(hl)
		dec	hl
		rl	(hl)
		dec	hl
		rl	(hl)
		dec	hl
		rl	(hl)
		dec	hl
		rl	(hl)
		pop	hl
		inc	h
		ld	a, h
		and	7
		jr	nz, Str_next_line
		ld	a, l
		sub	0E0h ; 'Ю'
		ld	l, a
		sbc	a, a
		and	0F8h ; 'Ь'
		add	a, h
		ld	h, a
Str_next_line:
		ex	de, hl
		djnz	Str_move_line
		and	a
		ret

Str_load_symbol:
		sub	20h
		cp	60h
		jr	c, Str_load_data
		sub	60h

Str_load_data:
		ld	h, 0
		ld	l, a
		add	hl, hl
		add	hl, hl
		add	hl, hl
		add	hl, hl
		add	hl, hl
		ld	bc, Str_addr_font
		add	hl, bc
		ld	(Str_save_stack + 1),sp
		ld	sp, hl
		ld	hl, Str_buf_data
		pop	bc
		ld	(hl), c
		inc	hl
		ld	(hl), b
		inc	hl
		pop	bc
		ld	(hl), c
		inc	hl
		ld	(hl), b
		inc	hl
		pop	bc
		ld	(hl), c
		inc	hl
		ld	(hl), b
		inc	hl
		pop	bc
		ld	(hl), c
		inc	hl
		ld	(hl), b
		inc	hl
		pop	bc
		ld	(hl), c
		inc	hl
		ld	(hl), b
		inc	hl
		pop	bc
		ld	(hl), c
		inc	hl
		ld	(hl), b
		inc	hl
		pop	bc
		ld	(hl), c
		inc	hl
		ld	(hl), b
		inc	hl
		pop	bc
		ld	(hl), c
		inc	hl
		ld	(hl), b
		inc	hl
		pop	bc
		ld	(hl), c
		inc	hl
		ld	(hl), b
		inc	hl
		pop	bc
		ld	(hl), c
		inc	hl
		ld	(hl), b
		inc	hl
		pop	bc
		ld	(hl), c
		inc	hl
		ld	(hl), b
		inc	hl
		pop	bc
		ld	(hl), c
		inc	hl
		ld	(hl), b
		inc	hl
		pop	bc
		ld	(hl), c
		inc	hl
		ld	(hl), b
		inc	hl
		pop	bc
		ld	(hl), c
		inc	hl
		ld	(hl), b
		inc	hl
		pop	bc
		ld	(hl), c
		inc	hl
		ld	(hl), b
		inc	hl
		pop	bc
		ld	(hl), c
		inc	hl
		ld	(hl), b
		inc	hl
Str_save_stack:
		ld	sp, 0
		ret	


Str_flg_end:
		db 	0

Str_count_bit:
		db 	0
Str_addr_work:
		dw 	0

Str_buf_data:   
		ds	512

Str_addr_load:
		db	'      *LOAD* ',0

Str_addr_text:
		db 	'                             << SPACE TO CHANGE MUSIC >>       '
		db 	'                             опхбер, опхбер. х бяч днпнцс ноърэ бюя днмхлюер MICK!'
		db	' бннаыел онйю хдер люярэ хкх опсую, йкеоюч б лепс ябнху окчьебшу лнгцнб х яхк лсгшйюкэмше бшосяйх'
		db	' дкъ гбсйнбни йюпрш *ZXM-MOONSOUND*. мю щрнр пюг бшосяй бйкчвюер б яеаъ лекндхх я пюяьхпемхел'
		db	' тюикнб MFM. лекндхи щрнцн тнплюрю ме рюй лмнцн, лнфер еые мю оюпс бшосяйнб убюрхр, еякх йнмевмн'
		db	' фекюмхе еые асдер мюопъцюрэ ябнх окчьебше лнгцх. йюяюрекэмн щрнцн бшосяйю, рн днаюбхк юмюкхгюрнп.'
		db	' опюбдю опхькняэ мелмнцн лндхтхжхпнбюрэ окееп, мн рюй яйюгюрэ - онд бхгсюкхгюжхч опнжеяяю бяецдю'
		db	' хмрепеямее хдер лсгхжхпнбюмхе. рюйфе днаюбкемю юмхлюжхъ йнрю, йнрнпюъ опюбдю днярсомю дкъ йнлонб'	
		db	' йнлс анкэье 128й, хяонкэгсеряъ ахр 7 онпрю 7FFD. мс ю б нярюкэмнл бяе он опефмелс, бяе он опнярнлс.'

		db	' хрюй, б щрнл яанпмхйе рпхмюджюрэ лекндхи, йнрнпше'
		db	' оепейкчвючряъ осрел мюфюрхъ йкюбхьх "SPACE", кхан фдере онйю ме гюйнмвхряъ лекндхъ.'
		db	' яохянй лекндхи хдер якеднл: '

		db	' ALESTE.MFM (FRIKANDEL SPECIAL - (C) MEITS 1995),'
		db	' FOREST.MFM (THE FOREST OF THELONIA - BART ROYMANS),'
		db	' HUISHUIS.MFM (HOUSE - RIEDELTJE),'
		db	' RELAXED.MFM (RELAXXEDD - BART ROYMANS),'
		db	' JAMMED2.MFM (JAMMED 2.0 - BART ROYMANS),'
		db	' JDKTHEME.MFM (J.D.K. THEME - BART ROYMANS),'
		db	' MATIN.MFM (MATIN - BART ROYMANS),'
		db	' MORNGROW.MFM (THE MORNING GROW - YS-I MANGA / R. VD MoOOSDIJK),'
		db	' PARODIUS.MFM (PARODIUS - BART and DAVE),'
		db	' RIEDEL.MFM (MB FOR MOONSOUND FM V0.91. -  CODING BY R.SCHRIJVERS),'
		db	' SLOWNDOWN.MFM (SLOW DOWN TOWN - BART ROYMANS),'
		db	' RANDAM.MFM (GILIAN MEETS RANDSM - BART ROYMANS),'
		db	' SALMON_1.MFM (CASTLE OF SALMON - BART ROYMANS).'

		db	' йпнле рнцн еярэ еые ндмю ймнойю "BREAK" - бшунд б TR-DOS.'
		db 	' н опнцпюлле: нямнбмше люрепхюкш ашкх онгюхлярбнбюмш я опнцпюлл йнлоэчрепю "MSX" х бекхйни'
		db	' лсянпйх онд мюгбюмхел хмрепмер.' 
		db 	' бяе щрн янахпюкняэ мю пя опх онлных юяяелакепю  SJASMPLUS.'
		db	' мюонлмч, еякх с бюя йюпрхмйю цде еярэ релю ксмш х оеигюифеи, рн лхкнярх опняхл б якедсчыхи бшосяй.'
		db	' йнпнве, фдел мнбшу рбнпемхи нр усднфмхйнб опнтеяяхнмюкэмшу х ме нвемэ. гюяхл опняхл нрйкюмъряъ, дюкее хдер'
		db	' рпюдхжхнммюъ псапхйю.'
		db	'             опхберш х яоюяхаш!     '
		db	' ююю, йюй бяецдю х бегде цпнлюдмши опхберхые.'
		db	' TS-LABS, яоюяхан гю рн опхчрхк мю ябнел тнпсле аеяунгмнцн окчьебнцн ледбедъ.'
		db	' лсгшйюмрюл хг яанпмхйю, пеяоейр гю рюйхе гюлевюрекэмше лсгнмш.'
		db	' бяел бкюдекэжюл опндсйжхх онд апемднл "ZXM" анкэьсыхи опхбер. бюя реоепэ лмнцн, лнфмн ме асдс бюя мюгшбюрэ бяеу онхлеммн.'
		db	' опхбер рюйфе бяел яоейрпслхярюл, ашбьхл, мюярнъыхл х бнглнфмн асдсыхл.'
		db	'       х онякедмхи юагюж :) :)'
		db	' мюирх онякедмчч хмтнплюжхч он лнхл опнейрюл лнфмн мю яюире WWW.MICKLAB.RU.'
		db	' ябъгюряъ ян лмни лнфмн вепег тнпсл WWW.TS-LABS.INFO - мхймеил MICK хкх вепег лшкн'
		db	' MICKLAB(цюб-цюб)MAIL.RU   ' 
		db	' онпю опныюрэяъ. онялнпрхл асдср кх еые опнцпюллйх нр лемъ :) онйю! онйю!      '
		db	'            YULI *2016*    GRAPHICS AND CODE BY MICK         '
		db	'                                             ',0           		
Str_addr_font:
		incbin "aaa_3.fnt"
Str_end_font:
