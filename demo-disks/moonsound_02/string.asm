;--------------------------------------------------------------------
; нОХЯЮМХЕ: аЕЦСЫЮЪ ЯРПНЙЮ
; юБРНП ОНПРЮ: НЯМНБЮ БШДПЮМЮ ХГ Demo 2 AAA Band
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
		ld	a,10h
		ld	(Str_count_bit),a
		ld	hl,Str_addr_text
		ld	(Str_addr_work),hl
		ld	a,(hl)
		ret

Str_init_load:
		ld	a,10h
		ld	(Str_count_bit),a
		ld	hl,Str_addr_load
		ld	(Str_addr_work),hl
		ld	a,1
		ld	(Str_flg_end),a
		ld	a,(hl)
		ret	

Str_play:
		ld	a,(Str_count_bit)
		dec	a
		ld	(Str_count_bit),a
		jr	nz, Str_move_string
		ld	a, 10h
		ld	(Str_count_bit),a

loc_0_6722:
		ld	hl,(Str_addr_work)
		ld	a, (hl)
		and	a
		call	z,Str_reload
		ret	c
		inc	hl
		ld	(Str_addr_work),hl
		sub	20h

		cp	60h
		jr	c, Str_load_data
		sub	60h
Str_load_data:
		ld	l, a
		ld	h, 0
		add	hl, hl
		add	hl, hl
		add	hl, hl
		add	hl, hl
		add	hl, hl
		ld	de, Str_addr_font
		add	hl, de
		ld	de, Str_buf_data
		ld	bc, 20h	; ' '
		ldir	

Str_move_string:
		ld	ix, Str_buf_data
		ld	hl, 54BFh
		ld	b, 16
Str_move_line:
		push	hl
		or	a
		ld	d, (ix++1)
		ld	e, (ix++0)
		sla	d
		rl	e
		ld	(ix++1), d
		ld	(ix++0), e
		rl	(hl)
		dec	l
		rl	(hl)
		dec	l
		rl	(hl)
		dec	l
		rl	(hl)
		dec	l
		rl	(hl)
		dec	l
		rl	(hl)
		dec	l
		rl	(hl)
		dec	l
		rl	(hl)
		dec	l
		rl	(hl)
		dec	l
		rl	(hl)
		dec	l
		rl	(hl)
		dec	l
		rl	(hl)
		dec	l
		rl	(hl)
		dec	l
		rl	(hl)
		dec	l
		rl	(hl)
		dec	l
		rl	(hl)
		dec	l
		rl	(hl)
		dec	l
		rl	(hl)
		dec	l
		rl	(hl)
		dec	l
		rl	(hl)
		dec	l
		rl	(hl)
		dec	l
		rl	(hl)
		dec	l
		rl	(hl)
		dec	l
		rl	(hl)
		dec	l
		rl	(hl)
		dec	l
		rl	(hl)
		dec	l
		rl	(hl)
		dec	l
		rl	(hl)
		dec	l
		rl	(hl)
		dec	l
		rl	(hl)
		dec	l
		rl	(hl)
		dec	l
		rl	(hl)
		pop	hl

		inc	ix
		inc	ix

		inc	h
		ld	a,h
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
		dec	b
		jp	nz,Str_move_line
		ret	

Str_flg_end:
		db 	0

Str_count_bit:
		db 	0
Str_addr_work:
		dw 	0

Str_buf_data:   
		ds	32

Str_addr_load:
		db	'            *LOAD*     ',0

Str_addr_text:
		db 	'                             опхбер! MICK ноърэ рпебнфхр бюя. '
		db 	' мю яеи пюг ялеч опедкнфхрэ бюьелс бмхлюмхч еые ндмс меанкэьсч лсгшйюкэмсч нрйпшрйс.'
		db 	' х ноърэ бяе щрн б пюлйюу онддепфйх ябнеи мнбни гбсйнбни йюпрш *ZXM-MOONSOUND*.'
		db	' б опнькши пюг ашкн вершпе лекндхх, йнрнпше онйюгюкх мю врн яонянамю щрю йюпрю, б щрнр пюг'
		db	' лекндхи сфе ьеярэ. унвс нрлерхрэ, врн мю яюлнл деке лекндхи йнмевмн анкэье, мн ме бяе япюгс.'
		db	' нрйпшрйх онъбкъчряъ б опнжеяяе хгсвемхъ пюгкхвмшу лсгшйюкэмшу тнплюрнб. б щрни нрйпшрйе'
		db	' янапюмш лекндхх нр лсгшйюкэмнцн педюйрнпю "MOONBLASTER" дкъ йюпрш *MOONSOUND* хкх *WOZBLASTER*'
		db	' йюй йнлс асдер сднамее. рюй йюй яюл тнплюр тюикнб днярюрнвмн пюгмннапюгем, рн дкъ мювюкю бгък'
		db	' опнярше лекндхх, хяонкэгсчыхе ндмс ярпюмхжс оюлърх х мерпеасчыхе гюцпсгйх кчахрекэяйху'
		db	' рюй мюгшбюелшу SAMPLEKIT, мн еярэ йсдю пюгбхбюрэяъ. :)   ' 
		db	' оепейкчвючряъ лекндхх осрел мюфюрхъ йкюбхь A,B,C,D,E,F. яннрбеярбхе мюгбюмхи лекндхи йкюбхьюл: '
		db	' "A" - BONGIE.MWM (BONGIE, BONGIE - BY QIX (SURREC)),'
		db	' "B" - JOINTEE.MWM (JOINTEE - BY QIX (SURREC)),'
		db	' "C" - PUMPING.MWM (PUMPING AND HUMPING - UNKNOWN),'
		db	' "D" - REMEMBER.MWM (REMEMBER - BY QIX (SURREC)),'
		db	' "E" - SACRIFIC.MWM (SACRIFICE - BY QIX (SURREC)),'
		db	' "F" - WILLWIND.MWM (THE WILL OF THE WIND - OPL4 - SOUNDWAVE 1997).'
		db	' йпнле рнцн еярэ еые ндмю ймнойю "BREAK" - бшунд б TR-DOS.'
		db	' ноърэ фе гюлевс, врн йюй аш ноърэ мнбши бшдпюммши тнмр. х ноърэ нм бшдпюм хг делйх нр ююю (DEMO 2).'
		db	' мн б нркхвхх нр опнькни нрйпшрйх щрнр тнмр ашк мелмнцн оеперюянбюм, мс ме нвемэ опхйюкшбюер охяюрэ мю йнх-8'
		db	' б мюье рн бпелъ, оняелс мелмнцн ецн оепекноюрхк. :) '
		db 	' н опнцпюлле: нямнбмше люрепхюкш ашкх онгюхлярбнбюмш я опнцпюлл йнлоэчрепю "MSX" х бекхйни'
		db	' лсянпйх онд мюгбюмхел хмрепмер.' 
		db 	' бяе щрн янахпюкняэ мю пя опх онлных юяяелакепю  SJASMPLUS.'
		db	'             опхберш х яоюяхаш, х аеяялепрмши FUCK!     '
		db	' ююю, йюй бяецдю х бегде цпнлюдмши опхберхые. б нвепедмни пюг рш хяошрюеьэ бекхйхи х сфюямши'
		db	' накнл оерпнбхв, рюй йюй с реаъ фекегйх мер, ю кълскърнпонйю мхйрн ме янхгбнкхк ондбегрх.'
		db	' бопнвел лнфеьэ ме смшбюрэ, ме рш рюйни ндхм, хяошрюбьхи яхе всбярбн :)'
		db	' дю еые яоюяхан гю тнмр хг рбнеи делн-2.'
		db	' DJS3000, яоюяхан гю йнмяскэрюрхбмсч онлныэ опх янгдюмхх щрни гбсйнбни йюпрш.'
		db	' QIX х дпсцхл юбрнпюл лсгшйх, гбсвюыеи б нрйпшрйе, пеяоейр гю рюйни лсгнм.'
		db	' MC68K, яоюяхан гю фекюмхе опхйпсрхрэ YMF278 й яоеййх, мн сф хгбхмх, рш йюй рн лнпъй,'
		db	' йнрнпши днкцн окюбюк. мюдечяэ врн я YM3812 с реаъ ашярпее декн онидер.'
		db	' бяел бкюдекэжюл опндсйжхх онд апемднл "ZXM" анкэьсыхи опхбер. бюя реоепэ лмнцн, лнфмн ме асдс бюя мюгшбюрэ бяеу онхлеммн.'
		db	' опхбер рюйфе бяел яоейрпслхярюл, ашбьхл, мюярнъыхл х бнглнфмн асдсыхл.'
		db	' онд йнмеж ндхм рнкярши х фхпмши FUCK!'
		db	' VERY VERY VERY LONG LONG LONG BIG BIG FUCK янгдюрекч ренпхи бсмдепбюткеи,бюткемрхмс гюыевйхмс - VICTOR2312,' 
		db	' я онцнмъкнбшл "бхръ 0%", йнцдю фе рш оепемеярюмеьэ опхмхлюрэ 40 цпюдсямши щкейяхп бяегмюмхъ х онйюфеьэ'
		db	' мюл лмнцнопнжеяянпмши бсмдепбюткч - блхп мю янрме бл80.'
		db	' ю мер, он ясыеярбс, бхръ рш лсдюй х бпъд кх врн няхкхьэ, йпнле ярюйюмю 40 цпюдсямнцн щкхйяхпю!!!!'
		db	'       х онякедмхи юагюж :) :)'
		db	' ме гюашбюел оняеыюрэ яюир WWW.MICKLAB.NAROD.RU рюл лнфмн мюирх онякедмчч хмтнплюжхч'
		db	' он лнхл опнейрюл. ябъгюряъ ян лмни лнфмн вепег яюир WWW.ZX.PK.RU - мхймеил MICK хкх вепег лшкн'
		db	' MICKLAB@MAIL.RU.'
		db	' онпю опныюрэяъ. онялнпрхл асдср кх еые опнцпюллйх нр лемъ :) онйю! онйю!      '
		db	'            JULY *2015*    GRAPHICS AND CODE BY MICK         '
		db	'                                             ',0           		
Str_addr_font:
		incbin "demo2.fnt"
Str_end_font:

