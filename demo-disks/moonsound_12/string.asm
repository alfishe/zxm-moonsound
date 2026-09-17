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
		ld	de, 54BFh
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
		ds	512

Str_addr_load:
		db	'            *LOAD*     ',0

Str_addr_text:
		db 	'                << SPACE TO CHANGE MUSIC >>       '
		db 	'                опхбер, опхбер! ноърэ я бюлх окчьебши ледбедэ MICK!'
		db	' йкеоюи яанпмхйх, онйю хдер опсую - рюй лнфмн оепетпюгхпнбюрэ хгбеярмне хгпевемхе - йси фекегн онйю цнпъвн.'
		db	' й велс щрю опхкчдхъ, ю й рнлс врн еые ндхм ябефхи яанпмхй лекндхи дкъ гбсйнбни йюпрш *ZXM-MOONSOUND*'
		db	' днярсоем дкъ опняксьхбюмхъ.'
		db	' б щрнл яанпмхйе бяецн 7 лекндхи, мн нмх назелхярше х яюлне бйсямне, врн лекндхвмше,'
		db	' рюй яюдхреяэ онсднамее х мюякюфдюиреяэ лсгшйни. мюяйнкэйн ъ онмък рср лекндхх йюбепш я хцпсьей,'
		db	' унръ лнцс х ньхаюрэяъ. б йювеярбе йюпрхмйх бшярсоючр гкше ярпюсяш, ю лнфер х ме гкше. йнпнве ютпхйю дерйю.'
		db	' ясдхрэ ярпнцн лнх усднфеярбеммше онпшбш ме ярнхр, рюй йюй опнтх с мюя мю нрдшуе бнр х опхундхряъ'
		db	' псйнфномхвюрэ. нпхцхмюк йюпрхмйх еяреярбеммшл напюгнл онгюхлярбнбюм хг хмерю. ю б нярюкэмнл бяе йюй нашвмн,'
		db	' нвепедмюъ онпжхъ тюикнб я пюяьхпемхел MWM, йнрнпше ме рпеасчр гюцпсгйх ящлокнб.' 
		db	' х яюлше онякедмхе мнбнярх хг лхпю яоейрпслю. ськши опеондюбюрекэ х ме лемее ськши ьйнкэмхй хг оърхцнпяйю'
		db	' гюмнбн хгнапекх яоейрпсл, ондясмсб хгбеярмши йнлоэчреп ZX NEXT гю опнрнрхо асдсыецн нревеярбеммнцн йнлоэчрепю.'
		db	' рхою лнк бнр мюь нрбер мю опнцпюллс хлонпрнгюлеыемхъ. х гюпюанрюкх мю щрнл цпюмр.'
		db	' хмрепеямн CONAN, йюй ндхм хг пюгпюанрвхйнб ZX NEXT, бшбедер мю вхярсч бндс фскхйнб хкх мер.'
		db	' йнпнве цнпнд оърхцнпяй ноърэ нркхвхкяъ. рюл еярэ ме рнкэйн кюярнмнцхе днканеаш мнлепмше бхрх (VIKTOR2312), ю реоепэ'
		db	' х фскэе, бшдючыхе всфхе пюгпюанрйх гю ябнх.'
		db	' бнаыел асдел якедхрэ гю дюкэмеиьхл пюгбхрхел янашрхи.    '

		db	' хрюй, б щрнл яанпмхйе яелэ лекндхи, йнрнпше'
		db	' оепейкчвючряъ осрел мюфюрхъ йкюбхьх "SPACE", кхан фдере онйю ме гюйнмвхряъ лекндхъ.'
		db	' яохянй лекндхи хдер якеднл: '

		db	' IMPACT187.MWM (IMPACT 187 - BDD 1993 - OMEGA 1995 (C) DREAMSCAPE),'
		db	' KONAMI_2.MWM (RETURN OF FIREBIRD - SOUNDWAVE 1998),'
		db	' COPYRIGHT.MWM (COPYRIGHT - BDD 1992 - OMEGA 1995 (C) DREAMSCAPE),'
		db	' KONAMI_3.MWM (METALION - GRADIUS 2 - SOUNDWAVE 1998),'
		db	' VROLIKE.MWM (VROLIKE - BDD 1992 - OMEGA 1995 (C) DREAMSCAPE),'
		db	' TURRICAN.MWM (TURRICAN II - METALSLAVE 1992 - OMEGA 1995 (C) DREAMSCAPE),'
		db	' THEME2.MWM (BDD THEME 2 - BDD 1991 - OMEGA 1995 (C) DREAMSCAPE).'

		db	' йпнле рнцн еярэ еые ндмю ймнойю "BREAK" - бшунд б TR-DOS.'
		db 	' н опнцпюлле: нямнбмше люрепхюкш ашкх онгюхлярбнбюмш я опнцпюлл йнлоэчрепю "MSX" х бекхйни'
		db	' лсянпйх онд мюгбюмхел хмрепмер.' 
		db 	' бяе щрн янахпюкняэ мю пя опх онлных юяяелакепю  SJASMPLUS.'
		db	' мюонлмч, еякх с бюя йюпрхмйю цде еярэ релю ксмш х оеигюифеи, рн лхкнярх опняхл б якедсчыхи бшосяй.'
		db	' йнпнве, фдел мнбшу рбнпемхи нр усднфмхйнб опнтеяяхнмюкэмшу х ме нвемэ. гюяхл опняхл нрйкюмъряъ, дюкее хдер'
		db	' рпюдхжхнммюъ псапхйю.'
		db	'             опхберш х яоюяхаш!     '
		db	' ююю, Tеае опнярн опхбер йюй бекхйнлс анцс делняжемш :).'
		db	' TS-LABS, яоюяхан гю рн, врн опхчрхк мю ябнел тнпсле аеяунгмнцн окчьебнцн ледбедъ.'
		db	' юбрнпюл лсгшйх, гбсвюыеи б яанпмхйе нцпнлмши пеяоейр х сбюфсую.'
		db	' бяел бкюдекэжюл опндсйжхх онд апемднл "ZXM" анкэьсыхи опхбер. бюя лмнцн, лнфмн ме асдс бюя мюгшбюрэ бяеу онхлеммн.'
		db	' опхбер рюйфе бяел яоейрпслхярюл, ашбьхл, мюярнъыхл х бнглнфмн асдсыхл.'
		db	'       х онякедмхи юагюж :) :)'
		db	' бяъ хмтю он лнхл опнейрюл мю яюире WWW.MICKLAB.RU, '
		db	' ябъгюрэяъ ян лмни лнфмн вепег тнпсл WWW.TS-LABS.INFO - мхймеил MICK хкх вепег лшкн'
		db	' MICKLAB(цюб-цюб)MAIL.RU.' 
		db	' онпю опныюрэяъ. онялнпрхл асдср кх еые опнцпюллйх нр лемъ :) онйю! онйю!      '
		db	'            JULY *2016*    GRAPHICS AND CODE BY MICK         '
		db	'                                             ',0           		
Str_addr_font:
		incbin "demo2.fnt"
Str_end_font:
