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
		ld	de, 50D8h
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
		dec	hl
		rl	(hl)
		dec	hl
		rl	(hl)
		dec	hl

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
		ds	256
;		ds	512

Str_addr_load:
		db	'   *LOAD* ',0

Str_addr_text:
		db 	'                << SPACE TO CHANGE MUSIC >>       '
		db 	'                опхбер, опхбер! еые мелмнцн MICK бюл рнвмн ме онлеьюер !'
		db	' бнр гюонксвхре х пюяохьхреяэ б мнбнл яанпмхйе MOONSOUND MUSIC 2. ю щрн гмювхр, врн лсгнм рср'
		db	' 60цж. юу юу кълскърнп ноърэ нрдшуюер. с мейнрнпшу лекндхи еые х ящлокш кчахрекэяйхе. бнр онщрнлс'
		db	' яанпмхй днкцн цпсгхряъ. мс щрн рюй яйюгюрэ опхкчдхъ. ю опюбдю б рнл, врн мю бшосяй яецн яанпмхйю'
		db	' лемъ яондбхц мюь ану делняжемш - AAA. цнбнпхр метхц аегдекэмхвюрэ. мю бнр реае йюпрхмйс х якеох'
		db	' мнбэежн врн кх, мю гкн йюйнлс рн уюиос х опнвхл гкношуюрекъл ююю. мс ъ нянан ме нрохпюкяъ.'
		db	' еярэ йюпрхмйю - бнр бюл яанпмхй. ю рюл сф йрн ее пхянбюк яюлх пюгахпюиреяэ. "хцпш тнпслнб"'
		db	' щрн ме йн лме. дю, еые унрек нрлерхрэ. рср PSB йюй рн бшпюгхкяъ - рхою ъ врн йюйни рн ухрпши гюохкърнп'
		db	' врн кх хяонкэгсч, бхдхлн ме мюдн рюй вюярн бшосяйюрэ яанпмхйх. :) нрберярбеммн гюбепъч - мерс с лемъ'
		db	' гюохкърнпю, ю фюкэ :( '

		db	' хрюй, б щрнл яанпмхйе вершпмюджюрэ лекндхи, йнрнпше'
		db	' оепейкчвючряъ осрел мюфюрхъ йкюбхьх "SPACE", кхан фдере онйю ме гюйнмвхряъ лекндхъ.'
		db	' яохянй лекндхи хдер якеднл: '

		db	' DSLAYER6.MWM (DRAGON SLAYER, THE LEGEND OF HEROES - MANUEL PAZOS),'
		db	' ALLPART2.MWM (AALL THERE ... 2 - BART ROYMANS),'
		db	' CANTKING.MWM (I CAN^T JUST WAIT TO BE KING - BART ROYMANS),'
		db	' FURELISE.MWM (FUR ELISE - HANS SCHOORMANS),'
		db	' MIRROMAN.MWM (BGM3 - BART ROYMANS),'
		db	' THRDWAVE.MWM (LEISURE SUIT LARRY MAIN THEME),'
		db	' PALACE.MWM (THE PALACE - BART ROYMANS),'
		db	' PIANOMAN.MWM (PIANO MAN - HANS SCHOORMANS),'
		db	' SDCHURCH.MWM (SD SNATCHER CHURCH BGM - BART ROYMANS),'
		db	' CHAOS2.MWM (CAPTAIN CHAOS II - OPL4 VERSION - SOUNDWAVE 1997),'
		db	' FOREVER.MWM (FOREVER FRIENDS - HUEY & ZELLY - MAYHEM 1995),'
		db	' QUICKSAA.MWM (THE QUICKSAND VALLEY YS 4 - BART ROYMANS),'
		db	' INTERNAL.MWM (MAYHEM INTERNALS - HUEY & ZELLY - MAYHEM 1995),'
		db	' PROFILE.MWM (THE PROFILE - HUEY & ZELLY - MAYHEM 1995).'	

		db	' йпнле рнцн еярэ еые ндмю ймнойю "BREAK" - бшунд б TR-DOS.'
		db 	' н опнцпюлле: нямнбмше люрепхюкш ашкх онгюхлярбнбюмш я опнцпюлл йнлоэчрепю "MSX" х бекхйни'
		db	' лсянпйх онд мюгбюмхел хмрепмер.' 
		db 	' бяе щрн янахпюкняэ мю пя опх онлных юяяелакепю  SJASMPLUS.'
		db	' мюонлмч, еякх с бюя йюпрхмйх, йнрнпше унрхре носакхйнбюрэ онд лсгшйс, рн лхкнярх опняхл б якедсчыхи бшосяй.'
		db	' йнпнве, фдел мнбшу рбнпемхи нр усднфмхйнб опнтеяяхнмюкэмшу х ме нвемэ. гюяхл опняхл нрйкюмъряъ, дюкее хдер'
		db	' рпюдхжхнммюъ псапхйю.'
		db	'             опхберш х яоюяхаш!     '
		db	' ююю, Tеае опхбер йюй бекхйнлс анус делняжемш, анпжс я уюионл:).'
		db	' TS-LABS, яоюяхан гю рн, врн опхчрхк мю ябнел тнпсле аеяунгмнцн окчьебнцн ледбедъ.'
		db	' лсгшйюмрюл, яоюяхан гю лсгшйс, гбсвюыеи б яанпмхйе, нцпнлмши пеяоейр х сбюфсую.'
		db	' бяел бкюдекэжюл опндсйжхх онд апемднл "ZXM" анкэьсыхи опхбер. бюя лмнцн, лнфмн ме асдс бюя мюгшбюрэ бяеу онхлеммн.'
		db	' опхбер рюйфе бяел яоейрпслхярюл, ашбьхл, мюярнъыхл х бнглнфмн асдсыхл.'
		db	'       х онякедмхи юагюж :) :)'
		db	' бяъ хмтю он лнхл опнейрюл мю яюире WWW.MICKLAB.RU, '
		db	' ябъгюрэяъ ян лмни лнфмн вепег тнпсл WWW.TS-LABS.INFO - мхймеил MICK хкх вепег лшкн'
		db	' MICKLAB(цюб-цюб)MAIL.RU.' 
		db	' онпю опныюрэяъ. онялнпрхл асдср кх еые опнцпюллйх нр лемъ :) онйю! онйю!      '
		db	'            AUGUST *2016*    GRAPHICS AAA AND CODE BY MICK         '
		db	'                                             ',0           		
Str_addr_font:
		incbin "demo2.fnt"
Str_end_font:
