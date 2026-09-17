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
		db 	'                             опхбер, ямнбю бюя аеяонйнхр MICK. '
		db	' пеьхк бюл опедярюбхрэ еые ндмс лсгшйюкэмсч нрйпшрйс б онддепфйс мнбни гбсйнбни йюпрш *ZXM-MOONSOUND*.' 
		db	' нвепедмше ьеярэ гюлевюрекэмшу лекндхи унръ х мелмнцн ябнеапюгмшу, мн б жекнл днкфмш бюл онмпюбхрэяъ.'
		db	' ярхлскнл бшосяйю дюммни нрйпшрйх оняксфхкю йюпрхмйю, йнрнпсч опедярюбхк ANDREW_CURDS. х еякх б опнькнл'
		db	' бшосяйе йюпрхмйю ашкю бяецн кхьэ юдюрюжхеи сфе мюпхянбюммни хл дкъ йюйнцн рн  йнмйспяю, рн мю яеи пюг,'
		db	' рюй яйюгюрэ вхяреиьхи щйяйкчгхбвхй - мюпхянбюмю яоежхюкэмн дкъ лсгшйюкэмни нрйпшрйх. '
		db	' рюй врн еярэ релю ксмш х оеигюифеи, фдел мнбшу рбнпемхи нр усднфмхйнб опнтеяяхнмюкэмшу х ме нвемэ.'
		db	' б нрйпшрйе рюйфе опхлемем мнбши тнмр дкъ аецсыеи ярпнйх. бепмее нм ме мнбши, ю бшдпюммши хг йюйни рн'
		db	' хг лмнцнвхякеммшу гюохкнделнй нр ююю. :)  мн б лнеи йнккейжхх нрйпшрнй - нм еые ме хяонкэгнбюкяъ. :)'
		db	' хрюй, йюй цнбнпхк бшье, б яанпмхйе ьеярэ лекндхи, йнрнпше'
		db	' оепейкчвючряъ осрел мюфюрхъ йкюбхь A,B,C,D,E,F. яннрберярбхе мюгбюмхи лекндхи йкюбхьюл: '
		db	' "A" - DREAMER.MWM (THE SWEET DREAMER - MEITS 2004),'
		db	' "B" - DREAMTHI.MWM (THE DREAMTIEF - MEITS 1994/2004),'
		db	' "C" - KNOWNEED.MWM (I KNOWN WHAT YOU NEED - MASTER OF AUDIO 1994/2004).'
		db	' "D" - MILKMAN.MWM ( THE MILKMAN - MASTER OF AUDIO 1994/2004).'
		db	' "E" - MIRROR.MWM (THE (NEW) TOY MIRROR (NOT EVEN BROKEN) - MEITS 1996),'
		db	' "F" - SPRING.MWM (STRAWBERRY SPRING - MASTER OF AUDIO 1994/2004).'
		db	' йпнле рнцн еярэ еые ндмю ймнойю "BREAK" - бшунд б TR-DOS.'
		db 	' н опнцпюлле: нямнбмше люрепхюкш ашкх онгюхлярбнбюмш я опнцпюлл йнлоэчрепю "MSX" х бекхйни'
		db	' лсянпйх онд мюгбюмхел хмрепмер.' 
		db 	' бяе щрн янахпюкняэ мю пя опх онлных юяяелакепю  SJASMPLUS.'
		db	'             опхберш х яоюяхаш, х ONE FUCK!     '
		db	' ююю, йюй бяецдю х бегде цпнлюдмши опхберхые. б нвепедмни пюг рш хяошрюеьэ бекхйхи х сфюямши'
		db	' накнл оерпнбхв, рюй йюй с реаъ фекегйх мер, ю кълскърнпю рн мелю.'
		db	' бопнвел лнфеьэ ме смшбюрэ, ме рш рюйни ндхм, хяошрюбьхи яхе всбярбн. :)'
		db	' х дю, бепмхяэ мю тнпсл, ю рн йюй рн ярюкн осярн. ндмю рнкэйн кюярнмнцюъ бсмдепбюткъ онпрхр беяэ бнгдсу.  '
		db	' NYUK, яоюяхан гю тнмр хг рбнецн делн-гюохкърнпю. '
		db      ' ANDREW_CURDS, яоюяхан гю бекхйнкеомсч йюпрхмйс, яоюяхан врн нрйкхймскяъ мю опхгшб н онлных.'
		db	' DJS3000, яоюяхан гю йнмяскэрюрхбмсч онлныэ опх янгдюмхх щрни гбсйнбни йюпрш.'
		db	' MEITS х MASTER OF AUDIO, пеяоейр гю рюйни лсгнм.'
		db	' бяел бкюдекэжюл опндсйжхх онд апемднл "ZXM" анкэьсыхи опхбер. бюя реоепэ лмнцн, лнфмн ме асдс бюя мюгшбюрэ бяеу онхлеммн.'
		db	' опхбер рюйфе бяел яоейрпслхярюл, ашбьхл, мюярнъыхл х бнглнфмн асдсыхл.'
		db	' онд йнмеж ндхм фхпмши FUCK!'
		db	' VERY VERY VERY LONG LONG LONG BIG BIG FUCK кюярнмнцни бсмдепбютке, янгдюрекч ренпхи, бяе я мскъ - VICTOR2312,' 
		db	' бхрей мскеопнжемрши, йнцдю фе рш бшкевхьяъ нр аеяопнасдмни меюдейбюрмнярх. бхдхлн лемэье мюдн мчуюрэ бнднвйс'
		db	' хкх лнфер ашрэ гюйсяшбюрэ ме рнкэйн ндмхл днапнткнрхйнл. '
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
		incbin "aaa_2.fnt"
Str_end_font:
