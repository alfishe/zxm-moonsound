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
		db 	'                опхбер, опхбер! MICK ноърэ я бюлх!'
		db	' бнр пюгпндхкяъ еые мю ндхм лсгшйюкэмши яанпмхй дкъ гбсйнбни йюпрш *ZXM-MOONSOUND*.'
		db	' х йюй нашвмн, нвепедмюъ онпжхъ тюикнб я пюяьхпемхел MWM, йнрнпше ме рпеасчр гюцпсгйх'
		db	' ящлокнб. йюпрхмйю хг хмерю, якецйю яйнмбепвемю х ондпхурнбюмю б лепс лнху слемхи.'
		db	' хг мнбэежю онфюкси нрлевс, врн опхйпсрхк рхою юмюкхгюрнп. опхькняэ дкъ щрнцн пюяонрпньхрэ'
		db	' делйс я йнлоэчрепю MSX 2.  х онйю ъ яннапюфюк йюй янрбнпхрэ мнбши яанпмхй б лхпе яоейрпслю'
		db	' рбнпхкхяэ янбяел меьсрнвмше янашрхъ. бекхйхи х сфюямши анц делняжемш ююю ярюк кхвмнярмн'
		db	' пюгдбюхбюрэяъ х ярюб люпхеи апюулюрсккхмни нрфхцюк рюйхе оепкш он онбндс уюиою х делняжемш,'
		db	' врн бонпс хгдюбюрэ яанпмхй ецн хгпевемхи. унръ бпнде мю дюммши лнлемр ююю сяонйнхкяъ, бепмск'
		db	' ябни яюир х дюфе ярюк охяюрэ мю ZX.PK.RU. бннаыел яокньмюъ с мюя яюмрю-аюпаюпю. х щрн мюбепмне'
		db	' унпньн :)    ' 
		db	' юу дю, янбяел гюашк яйюгюрэ, врн ндхм хгбеярмши б лхпе яоейрпслю усднфмхй опегемрнбюк онрпъямсч'
		db	' йюпрхмйс. реоепэ нярюкняэ мюирх дкъ мее ондундъысчч йпсрсч лсгшйс. х онйю ъ щрс лсгшйс хыс, яйюфс щрнлс усднфмхйс' 
		db	' анкэьсыее яоюяхан - йюпрхмйю опнярн йпсрнремевйю.'

		db	' хрюй, б щрнл яанпмхйе рпхмюджюрэ лекндхи, йнрнпше'
		db	' оепейкчвючряъ осрел мюфюрхъ йкюбхьх "SPACE". яохянй лекндхи хдер якеднл: '

		db	' ALEXF.MWM (AXELF: TOTAL REMIX VERSION 2.0 FRANS J.W.KOLLER ),'
		db	' CYNTHIA.MWM (CYNTHIA: ODE TO CYNTHIA EXPERIES, FRANS J.W. KOLLER),'
		db	' SNOUT5.MWM (SNOUTRIEDEL 5 / R.VD. MOOSDIJK & A.DE RAAD / 1996),'
		db	' ENDLESSN.MWM (ENDLESS NIGHT - DG - COMPJOETANIA),'
		db	' MISTYHEA.MWM (MISTY HERAT - DAVE GROENEN),'
		db	' POPCORN.MWM (POPCORN: FRANS J.W. KOLLER),'
		db	' DISCUSS.MWM (DISS-CUSS),'
		db	' NEOKOBE.MWM (ONE NIGHT IN NEO-KOBE-CITY / MASAHIRO IKARIKO),'
		db	' MACGYVER.MWM (MACGYVER - HANS SCHOORMANS),'
		db	' SILENT.MWM (SILENT WAITING - F!R3B0Y),'
		db	' SNOUT4.MWM (SNOUTRIEDEL 4 / R.VD. MOOSDIJK & A.DE RAAD / 1996),'
		db	' THEMA1.MWM (THEMA1: M. HOLDORP / FRANS J.W. KOLLER),'
		db	' TRYOUT1.MWM (FIRST OPL4_24 WAVES TRY-OUT ANNE DE RAAD -FB- 1995).'

		db	' йпнле рнцн еярэ еые ндмю ймнойю "BREAK" - бшунд б TR-DOS.'
		db 	' н опнцпюлле: нямнбмше люрепхюкш ашкх онгюхлярбнбюмш я опнцпюлл йнлоэчрепю "MSX" х бекхйни'
		db	' лсянпйх онд мюгбюмхел хмрепмер.' 
		db 	' бяе щрн янахпюкняэ мю пя опх онлных юяяелакепю  SJASMPLUS.'
		db	' мюонлмч, еякх с бюя йюпрхмйю цде еярэ релю ксмш х оеигюифеи, рн лхкнярх опняхл б якедсчыхи бшосяй.'
		db	' йнпнве, фдел мнбшу рбнпемхи нр усднфмхйнб опнтеяяхнмюкэмшу х ме нвемэ. гюяхл опняхл нрйкюмъряъ, дюкее хдер'
		db	' рпюдхжхнммюъ псапхйю.'
		db	'             опхберш х яоюяхаш!     '
		db	' ююю, рш бепмсякъ х гю щрн реае опхбер. йрн фе асдер анпнрэяъ я уюионл, йюй ме рш.'
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
