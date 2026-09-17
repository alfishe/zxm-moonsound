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
		db 	'                             мс йюй аш гдпюярэе! х ямнбю бюя опхберярбсер MICK. '
		db	' еые ндмю лсгшйюкэмюъ нрйпшрйю бшькю б ябер, рюй яйюгюрэ, бяе дкъ бюьецн акюцю х яксую,' 
		db	' бяе дкъ онддепфйх мнбни гбсйнбни йюпрш *ZXM-MOONSOUND*.' 
		db	' б щрнр пюг ноърэ опедярюбкемш ьеярэ гюлевюрекэмшу лекндхи, йнрнпше днкфмш бюл онмпюбхрэяъ.'
		db	' унвс нрлерхрэ, врн мю яюлнл деке лекндхи йнмевмн анкэье, мн ме бяе япюгс. йюй ъ сфе цнбнпхк,'
		db	' еякх мюьх усднфмхйх, мювхмючыхе х опнтеяяхнмюкш, асдср опедкюцюрэ цпютхвеяйне нтнплкемхе,'
		db	' рн нрйпшрйх асдср яшоюрэяъ йюй делш с ююю хг гюохкърнпю.'
		db	' рюй врн депгюире, ксвье врн мхасдэ рбнпхрэ, вел мшрэ нр рнл, врн делняжемю мю яоеййх слепкю.'
		db	' он бяеи бхдхлнярх мюпндс рпсдмн опхгмюрэяъ б онкмеиьел меярнъйе мю ZX, мн ярпнхрэ хг яеаъ'
		db	' жемхрекеи, щйяоепрнб, нянаеммн оняке опхмърхъ 40 цпюдсямнцн щкхйяхпю бяегмюмхъ - щрн дю,'
		db	' щрн бяецдю онфюксиярю. х унпньн, врн мюьекяъ ндхм векнбей, йнрнпши днйюгюк напюрмне.'    
		db	' ю хлеммн б щрни нрйпшрйе цпютхвеяйне нтнплкемхе опеднярюбхк ANDREW_CURDS, гю врн елс анкэьсыее яоюяхан.'
		db	' бнр бхдхре мхвецн ярпюьмнцн б щрнл мер, рюй врн дюбюире, йнмвюире апчгфюрэ йюй ярюпхйх х рбнпхре'
		db	' бн акюцн мюьецн яоеййх.   юу, янбяел гюашк, врн опнднкфюел хгдебюрэяъ мюд ююю х бшдхпюрэ тнмрш хг ецн'
		db	' гюохкнделнй :)  '	
		db	' хрюй, йюй цнбнпхк бшье, б яанпмхйе ьеярэ лекндхи, йнрнпше'
		db	' оепейкчвючряъ осрел мюфюрхъ йкюбхь A,B,C,D,E,F. яннрберярбхе мюгбюмхи лекндхи йкюбхьюл: '
		db	' "A" - ADVENUR.MWM (ADVENTURE - BY QIX),'
		db	' "B" - CHURCHDE.MWM (DEMON IS CHURCH - BY QIX),'
		db	' "C" - FOTI.MWM (FOXES ON THE ICE - WJKKIO - OPL4 - SOUNDWAVE 1997).'
		db	' "D" - JAZZY.MWM (DISC STATION TITLE - JAZZY VERSION - OPL4 - SOUNDWAVE 1998).'
		db	' "E" - MADNESS2.MWM (HOUSE OF FAN - MADDNESS - ERIC),'
		db	' "F" - TRAGEDY.MWM (TRAGEDIES - OPL4 - SOUNDWAVE 1997).'
		db	' йпнле рнцн еярэ еые ндмю ймнойю "BREAK" - бшунд б TR-DOS.'
		db 	' н опнцпюлле: нямнбмше люрепхюкш ашкх онгюхлярбнбюмш я опнцпюлл йнлоэчрепю "MSX" х бекхйни'
		db	' лсянпйх онд мюгбюмхел хмрепмер.' 
		db 	' бяе щрн янахпюкняэ мю пя опх онлных юяяелакепю  SJASMPLUS.'
		db	'             опхберш х яоюяхаш, х наъгюрекэмши FUCK!     '
		db	' ююю, йюй бяецдю х бегде цпнлюдмши опхберхые. б нвепедмни пюг рш хяошрюеьэ бекхйхи х сфюямши'
		db	' накнл оерпнбхв, рюй йюй с реаъ фекегйх мер, ю кълскърнпю рн мелю.'
		db	' бопнвел лнфеьэ ме смшбюрэ, ме рш рюйни ндхм, хяошрюбьхи яхе всбярбн :)'
		db	' NYUK, яоюяхан гю тнмр хг рбнецн делн-гюохкърнпю.'
		db      ' ANDREW_CURDS, яоюяхан гю бекхйнкеомсч йюпрхмйс, яоюяхан врн нрйкхймскяъ мю опхгшб н онлных.'
		db	' DJS3000, яоюяхан гю йнмяскэрюрхбмсч онлныэ опх янгдюмхх щрни гбсйнбни йюпрш.'
		db	' QIX, ERIC х дпсцхл юбрнпюл лсгшйх, гбсвюыеи б нрйпшрйе, пеяоейр гю рюйни лсгнм.'
		db	' MC68K, яоюяхан гю фекюмхе опхйпсрхрэ YMF278 й яоеййх, мн сф хгбхмх, ъ реаъ ноепедхк,'
		db	' хан рш йюй лнпъй, йнрнпши днкцн окюбюк. мюдечяэ врн я YM3812 с реаъ ашярпее декн онидер.'
		db	' бяел бкюдекэжюл опндсйжхх онд апемднл "ZXM" анкэьсыхи опхбер. бюя реоепэ лмнцн, лнфмн ме асдс бюя мюгшбюрэ бяеу онхлеммн.'
		db	' опхбер рюйфе бяел яоейрпслхярюл, ашбьхл, мюярнъыхл х бнглнфмн асдсыхл.'
		db	' онд йнмеж ндхм фхпмши FUCK!'
		db	' VERY VERY VERY LONG LONG LONG BIG BIG FUCK цюмднье оемнвйхмс, янгдюрекч ренпхи бсмдепбюткеи - VICTOR2312,' 
		db	' бхрей 0%", саеияъ юо яремйс, лнфер рнцдю рш бшкевхьяъ нр аеяопнасдмни меюдейбюрмнярх.'
		db	' мн опефде бяе фе онйюфх мюл бсмдепбюткч лмнцнопнжеяянпмсч - блхп мю янрме бл80.'
		db	' ю мер, он ясыеярбс, бхръ рш лсдюй х бпъд кх врн няхкхьэ, йпнле онрнйю меюдейбюрю!!!!'
		db	'       х онякедмхи юагюж :) :)'
		db	' ме гюашбюел оняеыюрэ яюир WWW.MICKLAB.NAROD.RU рюл лнфмн мюирх онякедмчч хмтнплюжхч'
		db	' он лнхл опнейрюл. ябъгюряъ ян лмни лнфмн вепег яюир WWW.ZX.PK.RU - мхймеил MICK хкх вепег лшкн'
		db	' MICKLAB(цюб-цюб)MAIL.RU.'
		db	' онпю опныюрэяъ. онялнпрхл асдср кх еые опнцпюллйх нр лемъ :) онйю! онйю!      '
		db	'            JULY *2015*    GRAPHICS BY ANDREWS_CURDS AND CODE BY MICK         '
		db	'                                             ',0           		
Str_addr_font:
		incbin "aaa_1.fnt"
Str_end_font:
