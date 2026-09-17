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
		db 	'                             опхбер! ямнбю б щтхпе MICK. '
		db 	' б щрнр пюг унвс опедкнфхрэ бюьелс бмхлюмхч меанкэьсч лсгшйюкэмсч нрйпшрйс'
		db 	' б онддепфйс ябнеи мнбни гбсйнбни йюпрш *ZXM-MOONSOUND*, яепджел йнрнпни ъбкъеряъ йпсрни'
		db	' гбсйнбни вхо нр тхплш ълюую - YMF278.' 
		db 	' дюммюъ гбсйнбюъ йюпрю ядекюмю он лнрхбюл хгбеярмни б йпсцюу MSX онкэгнбюрекеи гбсйнбни йюпрш'
		db 	' онд мюгбюмхел *WOZBLASTER* х онгбнкъер бшбеярх гбсй мюьецн кчахлнцн яоеййх мю янбепьеммн мнбши х'
		db 	' йювеярбеммши спнбемэ. янаябеммн лнфере яюлх нжемхрэ, опняксьхбюъ лекндхх щрни нрйпшрйх.'
		db	' бяе лекндхх мюохяюмш дкъ MSX мейхл йндепнл х лсгшйюмрнл NARUTO. бяецн лекндхи рср вершпе х'
		db	' оепейкчвючряъ нмх осрел мюфюрхъ йкюбхь A,B,C,D. мюгбюмхъ лекндхи мехгбеярмш, рнкэйн еярэ'
		db	' хдемрхтхйюрнпш: "A" - O3D001.MDR,"B" - O3D002.MDR, "C" - O3D003.MDR, "D" - O3D004.MDR.'
		db	' йпнле рнцн еярэ еые ндмю ймнойю "BREAK" - бшунд б TR-DOS.'
		db	' унвс рюйфе гюлерхрэ, врн йюй аш дкъ опнаш пеьхк ялемхрэ тнмр. ецн бшдпюк хг гюохкнделнй ююю.'
		db	' рюй врн кецйн лнфмн яосрюрэ щрс делйс я опндсйжхеи гюохкърнп-йнлоюмх, мн щрн янбяел ме рюй. :)   '
		db 	' н опнцпюлле: нямнбмше люрепхюкш ашкх онгюхлярбнбюмш я опнцпюлл йнлоэчрепю "MSX" х бекхйни'
		db	' лсянпйх онд мюгбюмхел хмрепмер.' 
		db 	' бяе щрн янахпюкняэ мю пя опх онлных юяяелакепю  SJASMPLUS.'
		db	'             опхберш х яоюяхаш, ю рюйфе FUCK!     '
		db	' ююю, йюй бяецдю х бегде цпнлюдмши опхберхые. мю яеи пюг рш онунфе хяошрюеьэ бхкхйхи х сфюямши'
		db	' накнл оерпнбхв, рюй йюй с реаъ фекегйх мер, ю кълскърнп х ондюбмн ме ондбегкх.'
		db	' бопнвел лнфеьэ ме смшбюрэ, ме рш рюйни ндхм, хяошрюбьхи яхе всбярбн :)'
		db	' NYUK, яоюяхан гю тнмр хг рбнецн делн-гюохкърнпю.'
		db	' DJS3000, яоюяхан гю йнмяскэрюрхбмсч онлныэ опх янгдюмхх щрни гбсйнбни йюпрш.'
		db	' NARUTO, пеяоейр гю рюйни лсгнм, унрэ рш х охьеьэ дкъ MSX. мн онакюцндюпхрэ рн мюдн.'
		db	' MC68K, яоюяхан гю фекюмхе опхйпсрхрэ YMF278 й яоеййх, мн сф хгбхмх, рш йюй рн лнпъй,'
		db	' йнрнпши днкцн окюбюк. мюдечяэ врн я YM3812 с реаъ ашярпее декн онидер.'
		db	' бяел бкюдекэжюл опндсйжхх онд апемднл "ZXM" анкэьсыхи опхбер. бюя реоепэ лмнцн, лнфмн ме асдс бюя мюгшбюрэ бяеу онхлеммн.'
		db	' опхбер рюйфе бяел яоейрпслхярюл, ашбьхл, мюярнъыхл х бнглнфмн асдсыхл.'
		db	' онд йнмеж ндхм рнкярши х фхпмши FUCK!'
		db	' VERY VERY VERY LONG LONG LONG BIG BIG FUCK оняшкюч VICTOR2312, янгдюрекч ренпхи бсмдеп бюткеи.'
		db	' бхръ 0%, йнцдю фе мюл онйюфеьэ бсмдеп пюгпюанрйс лмнцнопнжеяянпмши блхп.'
		db	' ю он ясыеярбс, бхръ рш лсдюй!!!!'
		db	'       х онякедмхи юагюж :) :)'
		db	' ме гюашбюел оняеыюрэ яюир WWW.MICKLAB.NAROD.RU рюл лнфмн мюирх онякедмчч хмтнплюжхч'
		db	' он лнхл опнейрюл. ябъгюряъ ян лмни лнфмн вепег яюир WWW.ZX.PK.RU - мхймеил MICK хкх вепег лшкн'
		db	' MICKLAB@MAIL.RU.'
		db	' онпю опныюрэяъ. онялнпрхл асдср кх еые опнцпюллйх нр лемъ :) онйю! онйю!      '
		db	'            JUNY *2015*    GRAPHICS AND CODE BY MICK         '
		db	'                                             ',0           		
Str_addr_font:
		incbin "aaa_0.fnt"
Str_end_font:
