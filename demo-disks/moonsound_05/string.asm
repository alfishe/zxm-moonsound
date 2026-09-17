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
		ld	de, 50BFh
		ld	hl, Str_buf_data +1 
		ld	b, 18h

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
		ld	l,a
		ld	bc,7ffdh
		ld	a,17h
		out	(c),a
		ld	h, 0
	    	add	hl,hl
	    	add	hl,hl
		add	hl,hl
		add	hl,hl
	    	ld	d, h
		ld	e, l
	    	add	hl,hl
		add	hl,de
		ld	bc, 0e000h		;Str_addr_font
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

		ld	bc,7ffdh
		ld	a,10h
		out	(c),a
		ret	


Str_flg_end:
		db 	0

Str_count_bit:
		db 	0
Str_addr_work:
		dw 	0

Str_buf_data:   
		ds	768

Str_addr_load:
		db	'            *LOAD*     ',0

Str_addr_text:
		db 	'                             << SPACE TO CHANGE MUSIC >>       '
		db 	'                             опхбер, MICK опедярюбкъер мнбши яанпмхй'
		db	' дкъ гбсйнбни йюпрш *ZXM-MOONSOUND*. дюбмемэйн мхвецн ме бшйкюдшбюк, х бнр рюй яйюгюрэ пеьхкяъ.' 
		db	' унръ омск лемъ б щрнл мюопюбкемхх ANDREW_CURDS. нм лме дюбмн опегемрнбюк йюпрхмйс, ю ъ бекхйхи'
		db	' кемхбеж, йюй рн опн мее х гюашк. мн мхвецн, нм лме мюонлмхк х гюндмн ондяйюгюк онбнд бшундю яанпмхйю '
		db	' - демэ бяеу бкчакеммшу. йнпнве, цнбнпхр нм лме, ю врн ме гюаюжюрэ яанпмхвей йн дмч ябърнцн бюкемрхмю.'
		db	' х йюпрхмйю цнбнпхр ондундъыюъ - оюпнвйю онд ксммни. мс врн фе, ярпъумск я лнгцнб ошкэ х мювюк янахпюрэ лсгнм.'
		db	' бопнвел днкцн ме опхькняэ хяйюрэ, бгък мю опеоюпхпнбюмхе яанпмхй лсгшйх я MSX, онд мюгбюмхел SURREC 3.'
		db	' рюй, дслюч лсгнм еярэ, йюпрхмйю еярэ, нярюкняэ онднапюрэ мечгюммши б лнху яанпмхйюу тнмр.'
		db	' мю опняэас ондекхрэяъ тнмрнл нрйкхймскяъ GOBLINISH, опеднярюбхб ябнч делйс мю онрпньйх.'
		db	' й якнбс, нм яйюгюк, врн щрнр тнмр хг педюйрнпю "якнбн х декн" я PC бпнде.' 
		db	' хрюй, б щрнл яанпмхйе вершпмюджюрэ лекндхи, йнрнпше'
		db	' оепейкчвючряъ осрел мюфюрхъ йкюбхьх "SPACE". бяе лекндхх мюохяюмш лсгшйюмрнл QIX, яохянй йнрнпшу хдер якеднл: '
		db	' EXPLOSIO.MWM (EXPLOSION  - BY QIX),'
		db	' ANGELDEA.MWM (ANGEL OF DEATH - BY QIX),'
		db	' ATTACK.MWM (DEMON"S ATTACK - BY QIX).'
		db	' BEATING.MWM (BEATING DEMON - BY QIX),'
		db	' LOGO.MWM (LOGO - BY QIX).'
		db	' SILENTS.MWM (SILENTS OF PEACE - BY QIX).'
		db	' JUBILAT.MWM (JUBILATION - BY QIX).'
		db	' KILLERS.MWM (KILLERS - BY QIX).'
		db	' SWITCH.MWM (SWITCH 50/60 HZ - BY QIX).'
		db	' PAIN.MWM (PAIN - BY QIX).'
		db	' SUDDENS.MWM (SUDDEN SIMPHONIE - BY QIX).'
		db	' TARGET.MWM (TARGET - BY QIX).'
		db	' WATERS.MWM (WATERS IN PARADISE - BY QIX).'
		db	' XENORIUM.MWM (XENORIUM 1 - BY QIX).'
		db	' йпнле рнцн еярэ еые ндмю ймнойю "BREAK" - бшунд б TR-DOS.'
		db 	' н опнцпюлле: нямнбмше люрепхюкш ашкх онгюхлярбнбюмш я опнцпюлл йнлоэчрепю "MSX" х бекхйни'
		db	' лсянпйх онд мюгбюмхел хмрепмер.' 
		db 	' бяе щрн янахпюкняэ мю пя опх онлных юяяелакепю  SJASMPLUS.'
		db	' мюонлмч, еякх с бюя йюпрхмйю цде еярэ релю ксмш х оеигюифеи, рн лхкнярх опняхл б якедсчыхи бшосяй.'
		db	' йнпнве, фдел мнбшу рбнпемхи нр усднфмхйнб опнтеяяхнмюкэмшу х ме нвемэ. гюяхл опняхл нрйкюмъряъ, дюкее хдер'
		db	' рпюдхжхнммюъ псапхйю.'
		db	'             опхберш х яоюяхаш х тюйх!     '
		db	' ююю, йюй бяецдю х бегде цпнлюдмши опхберхые. рш ноърэ хяошрюеьэ бекхйхи х сфюямши'
		db	' накнл оерпнбхв, рюй йюй с реаъ фекегйх мер, ю кълскърнп рн онунфе норхлхгхпнбюрэ мейнлс :).'
		db	' бопнвел лнфеьэ ме смшбюрэ, ме рш рюйни ндхм, хяошрюбьхи яхе всбярбн. :)'
		db      ' ANDREW_CURDS, яоюяхан гю бекхйнкеомсч йюпрхмйс, яоюяхан врн нрйкхймскяъ мю опхгшб н онлных.'
		db	' GOBLINISH, яоюяхан гю тнмр, нм нвемэ йярюрх, рюй яйюгюрэ опнярн яоюяхрекэ.'
		db	' DJS3000, яоюяхан гю йнмяскэрюрхбмсч онлныэ опх янгдюмхх щрни гбсйнбни йюпрш.'
		db	' TS-LABS, яоюяхан гю рн опхчрхк мю ябнел тнпсле аеяунгмнцн окчьебнцн ледбедъ, хан лсдхкн '
		db	' онд мюгбюмхел кюярнмнцюъ бсмдепбюткъ VIKTOR2312 бяе рюйх бшфхк лемъ я тнпслю ZX-PK.RU.'
		db	' QIX, пеяоейр гю рюйни гюлевюрекэмши лсгнм.'
		db	' бяел бкюдекэжюл опндсйжхх онд апемднл "ZXM" анкэьсыхи опхбер. бюя реоепэ лмнцн, лнфмн ме асдс бюя мюгшбюрэ бяеу онхлеммн.'
		db	' опхбер рюйфе бяел яоейрпслхярюл, ашбьхл, мюярнъыхл х бнглнфмн асдсыхл.'
		db	' дбю фхпмшу FUCK!'
		db	' VERY VERY VERY LONG LONG LONG BIG BIG FUCK кюярнмнцни бсмдепбютке, влньмхйс, мхйвелмнлс лсдюгбнмс' 
		db	' - VIKTOR2312. бхрей рш йнмвеммши днканеа. лме нвемэ фюкэ врн юдлхмхярпюжхъ ZX-PK.RU ме бхдхр рбнецн'
		db	' аеяопнябермнцн днканеахглю х опныюер реаъ. мн сбш рш лемъ днярюк усикн онцюмне.'
		db	' RINDEX, йюй ме опхяйнпамн мн реае рнфе ькч FUCK. нонлмхяэ, бяонлмх йюйхл рш ашк пюмэье х вел рш ярюмнбхьэяъ'
		db	' яеивюя  - бяегмючыхл бхрэйнл. бяонлмх врн рш слек х ядекюи онкегмне дкъ яоеййх, ю ме яхдх бн ткеиле.'  
		db	'       х онякедмхи юагюж :) :)'
		db	' бмхлюмхе, яашкюяэ леврю хдхнрю, ъ йсохк днлем WWW.MICKLAB.RU х рюл лнфмн мюирх онякедмчч хмтнплюжхч'
		db	' он лнхл опнейрюл. ябъгюряъ ян лмни лнфмн вепег тнпсл WWW.TS-LABS.INFO - мхймеил MICK хкх вепег лшкн'
		db	' MICKLAB(цюб-цюб)MAIL.RU. тнпсл ZX-PK.RU ъ онйхмск, ме гмюч бпелеммн хкх мюбяецдю, он йпюимеи лепе онйю'
		db	' рюл асдер нахрюрэ псйнфною кюярнмнцюъ бсмдепбюткъ бхръ мнкэ опнжемрнб.'
		db	' онпю опныюрэяъ. онялнпрхл асдср кх еые опнцпюллйх нр лемъ :) онйю! онйю!      '
		db	'            FEBRUARY *2016*    GRAPHICS BY ANDREWS_CURDS AND CODE BY MICK         '
		db	'                                             ',0           		

Str_end_font:
