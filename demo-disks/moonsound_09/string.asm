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
		db 	'                опхбер, опхбер! MICK йюй нашвмн яоеьхр бюя онрпебнфхрэ!'
		db	' ме сяоеб бшосярхрэ опедшдсыхи яанпмхй лекндхи, йюй рср фе цнрнб ябефхи дебърши '
		db	' яанпмхй йпюяхбшу х ме нвемэ лекндхи дкъ гбсйнбни йюпрш *ZXM-MOONSOUND*.'
		db	' нянан яйюгюрэ рн мевецн, бяе йюй нашвмн, нвепедмюъ онпжхъ тюикнб я пюяьхпемхел MWM, йнрнпше ме рпеасчр гюцпсгйх'
		db	' ящлокнб. йюпрхмйю хг хмерю, якецйю яйнмбепвемю х ондпхурнбюмю б лепс лнху слемхи.'
		db	' рюйфе унрекняэ аш нрлерхрэ, врн лекндхи еые лмнцн, мн унрэ нмх х хлечр наыее дкъ мху пюяьхпемхе MWM, мн'
		db	' мю опюйрхйе лндскх йюй опюбхкн люкн янблеярхлш лефдс янани. рюй врн опхундхряъ еые хяйюрэ дкъ мху' 
		db	' яннрберярбсчыхи опнхцпшбючыхи лндскэ.'
		db	' ю онрнл ецн онпрньхрэ мю хяундмхйх. янаярбеммн щрн онфюкси х бяе.     '	 
		db	' мс ю б лхпе яоейрпслю ярпюярх бяе мюйюкъчряъ. ме сяоеб ююю онъбхряъ мю ZX.PK.RU йюй яжеохкяъ ян ябнхл'
		db	' ноонмемрнл, хлемселшл йюй DENPOPOV. х беяэ онрнй янгмюмхъ, бшкхкяъ мю менйпеоьее янгмюмхе лндепюрнпнб х онкэгнбюрекеи'
		db	' тнпслю. мн оняйнкэйс пюгахпюрэяъ мхйрн ме ярюк б рнл, йрн опюб, ю йрн бхмнбюр, рн гюаюмхкх нанху.'
		db	' мн пебнкчжхнмеп х анц делняжемш ююю ме ялнц щрнцн бшрепоерэ х янгдюк ябни тнпсл, онябъыеммши делняжеме'
		db	' цде ецн кхвмнярэ мювюкю йкнмхпнбюрэяъ б ценлерпхвеяйни опнцпеяяхх. сфе ярюкн ме лндмн ашрэ люпхеи'
		db	' апюулюрсккхмни, нм ярюк хпхмни ъпнбни. унръ вепег оюпс дмеи бпнде йюй мелмнцн ябнх кхвмнярх ялнц янапюрэ б едхмнцн ялнрпъыецн.'
		db	' мн аег люпюглю ме нанькняэ - нм гюоперхк цняръл вхрюрэ релш. бнр нмн йюй ндмюйн б фхгмх ашбюер.'
		db	' врн фе, асдел опнднкфюрэ якедхрэ йюй асдср пюгбхбюрэяъ янашрхъ, онойнпмнл сфе гюоюяяъ.' 

		db	' хрюй, б щрнл яанпмхйе дебърмюджюрэ лекндхи, йнрнпше'
		db	' оепейкчвючряъ осрел мюфюрхъ йкюбхьх "SPACE". яохянй лекндхи хдер якеднл: '

		db	' ONLY_YOU.MWM (ONLY YOU CAN MAKE ME...(C) MEITS 1996),'
		db	' WOLFIE.MWM (MB FOR MOONSOUND WAVE V0.92 CODING BY R.SCHRIJVERS),'
		db	' CHRISTMA.MWM (MERRY CHRISTMAS AND A HAPPY NEWJEAR  BY QIX),'
		db	' DARKSCRI.MWM (DARK SCRIPT BY QIX),'
		db	' GHOST.MWM (GHOST BY QIX),'
		db	' HAPPYEND.MWM (HAPPY ENDING BY QIX),'
		db	' HEAVEN.MWM (DEATH IN HEAVEN BY QIX),'
		db	' PALACE.MWM (PALACE BY QIX),'
		db	' PLUGPRAY.MWM (PLUG & PRAY / R.VD MOOSDIJK / ZODIAC - FOR SUNRISE),'
		db	' POPCORN.MWM (MB FOR MOONSOUND WAVE V0.92 CODING BY R.SCHRIJVERS),'
		db	' ROMSTAND.MWM (BUILDING THE ROM-STAND! - WOLF 1995),'
		db	' SAXOJAM.MWM (SAXO JAM BY QIX),'
		db	' CONCERT.MWM (MB FOR MOONSOUND WAVE V0.92 CODING BY R.SCHRIJVERS),'
		db	' SDSNATCH.MWM (SD-SNATCHER /Konami/ -> OPL4  (C) 1995 WOLF),'
		db	' TWEANPEAK.MWM (TWIN PEAKZ /BADALAMENTI/  (C) WOLF/CS),'
		db	' WALTZMVV.MWM (MB FOR MOONSOUND WAVE V0.92 CODING BY R.SCHRIJVERS),'
		db	' WISPER.MWM (WISPERING  BY QIX),'
		db	' YO_ANNE.MWM (YO ANNE! JUBA AGAIN!  MEITS 1996),'
		db	' JARRE.MWM (MB FOR MOONSOUND WAVE V0.92 CODING BY R.SCHRIJVERS).'

		db	' йпнле рнцн еярэ еые ндмю ймнойю "BREAK" - бшунд б TR-DOS.'
		db 	' н опнцпюлле: нямнбмше люрепхюкш ашкх онгюхлярбнбюмш я опнцпюлл йнлоэчрепю "MSX" х бекхйни'
		db	' лсянпйх онд мюгбюмхел хмрепмер.' 
		db 	' бяе щрн янахпюкняэ мю пя опх онлных юяяелакепю  SJASMPLUS.'
		db	' мюонлмч, еякх с бюя йюпрхмйю цде еярэ релю ксмш х оеигюифеи, рн лхкнярх опняхл б якедсчыхи бшосяй.'
		db	' йнпнве, фдел мнбшу рбнпемхи нр усднфмхйнб опнтеяяхнмюкэмшу х ме нвемэ. гюяхл опняхл нрйкюмъряъ, дюкее хдер'
		db	' рпюдхжхнммюъ псапхйю.'
		db	'             опхберш х яоюяхаш!     '
		db	' ююю, Tеае опхбер, врн рн с реаъ я пюяякнемхел кхвмняреи  яксвхкняэ, йюй аш бяе оевюкэмн ме гюйнмвхкняэ дкъ ояхухйх.'
		db	' TS-LABS, яоюяхан гю рн, врн опхчрхк мю ябнел тнпсле аеяунгмнцн окчьебнцн ледбедъ.'
		db	' CREATOR, яоюяхан гю ноепюрхбмн мюидеммши аюц б опнькнл яанпмхйе.'
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
