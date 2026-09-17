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
		db 	'                опхбер, опхбер! х еые мелмнцн MICK бюл онмюднедюер !'
		db	' мю яеи пюг яанпмхй онябъыем йюпрхмйе, опеднярюбкеммни бекхйхл яоейрпслнбяйхл усднфмхйнл - ROBAT.'
		db	' нм еые беямни нрйкхймскяъ мю лни йпхй он онбндс йюпрхмнй дкъ яанпмхйнб х мюпхянбюк йпсрсч йюпрхмйс,'
		db	' врн рюй яйюгюрэ б гнас дшуюмхе яоепкн. ъ ондслюк, врн дкъ рюйни йюпрхмйх мсфмю х яннрберярбсчыюъ'
		db	' якюдйюъ лсгшйю. онхяйх лнх мелмнцн гюръмскхяэ, врн бшгбюкн мейсч наеяонйнеммнярэ, мн лме ме унрекняэ'
		db	' онйюгшбюрэ йюпрхмйс я нашвмшлх лекндхълх, унрекняэ врн рн хмрепеямемэйне.'
		db	' х хмрепеямемэйне мюькняэ, опюбдю лсгшйю пюявхрюмю мю 60цж опепшбюмхъ х гюцпсфюелше ящлокш.'
		db	' я гюцпсгйни ящлокнб онярсохк опнярн. б щлскърнпе MSX 2 ямък дюло оюлърх ящлокнб YM278 х рсон гюйювюк'
		db	' ецн б йюпрс, аег бяъйнцн онрпньемхъ х рюмжеб я асамнл. ю бнр я 60цж лнцср с кчдеи бнгмхймсрэ опнакелш. рюй йюй с лемъ'
		db	' б йювеярбе пюанвеи кньюдйх бшярсоюер лни дхяйпермши темъ, рн дкъ мецн ме ярюкн опнакелни опепшбюрэяъ'
		db	' я вюярнрни 60цж нр лсмяюсмдю. дю йнмевмн лнцср ашрэ опнакелш я аецсыеи ярпнйни, лнфер всрйю пбюрэ,'
		db	' мн гюрн лсгнм хцпюер х щрн йпсрн. рюй бнр еярэ онднгпемхе, врн ясоеп осоеп йнлосреп щбю ме лнфер яеае'
		db	' рюйнцн онгбнкхрэ, ю хлеммн опепшбюрэяъ нр бмеьмху хярнвмхйнб - онгнп йюйни рн. темъ онксвюеряъ йпсве.'
		db	' спю рнбюпхых!. мн дслюч хмфемепш щбш ме дносярър, врнаш йюйни рн дхяйпермши йнло сдекюк б вел рн ясоеп'
		db	' йнлоэчреп мю FPGA. врн фе, гюдюдхл гюдювйс хл :)'
		db	' х еые пюг мюонлмч, йюпрхмйс дкъ яанпмхйю опеднярюбхк ROBAT, гю врн елс анкэысыхи пеяоейр.'
		db	' лсгшйю, гбсвюыюъ б яанпмхйе б бюпхюмре OPL4 мюохяюмю BART ROYMANS.'

		db	' хрюй, б щрнл яанпмхйе дбемюджюрэ лекндхи, йнрнпше'
		db	' оепейкчвючряъ осрел мюфюрхъ йкюбхьх "SPACE", кхан фдере онйю ме гюйнмвхряъ лекндхъ.'
		db	' яохянй лекндхи хдер якеднл: '

		db	' CHILDREN.MWM (CHILDREN - ROBERT MILES - BART ROYMANS),'
		db	' ROCKDAWN.MWM (ROCK ROCK DAWN),'
		db	' STILLBEL.MWM (I STILL BELIEVE - BART ROYMANS),'
		db	' YS4LAVA.MWM (THE LAVA AREA, KISS TO ELDIL - BART ROYMANS),'
		db	' BELAIR.MWM (BEL AIR HOUSE - (ANTWERPEN) - BART ROYMANS),'
		db	' CRYSISTE.MWM (CRY LITTLE SISTER - BART ROYMANS),'
		db	' PARADISE.MWM (SEARCH FOR A CLOUD - BART ROYMANS),'
		db	' PALACE2.MWM (THE PALACE - BART ROYMANS),'
		db	' YS2BATTL.MWM (YS2 BATTLE THEME 3 - BART ROYMANS),'
		db	' INTRO2.MWM (THE INTRO JV880 / JD990 - BART ROYMANS),'
		db	' SOLVOID.MWM (SOLITARY VOID - BART ROYMANS),'
		db	' YS2ROAD.MWM (YS 2 ROAD - BART ROYMANS).'	

		db	' йпнле рнцн еярэ еые ндмю ймнойю "BREAK" - бшунд б TR-DOS.'
		db 	' н опнцпюлле: нямнбмше люрепхюкш ашкх онгюхлярбнбюмш я опнцпюлл йнлоэчрепю "MSX" х бекхйни'
		db	' лсянпйх онд мюгбюмхел хмрепмер.' 
		db 	' бяе щрн янахпюкняэ мю пя опх онлных юяяелакепю  SJASMPLUS.'
		db	' мюонлмч, еякх с бюя йюпрхмйх, йнрнпше унрхре носакхйнбюрэ онд лсгшйс, рн лхкнярх опняхл б якедсчыхи бшосяй.'
		db	' йнпнве, фдел мнбшу рбнпемхи нр усднфмхйнб опнтеяяхнмюкэмшу х ме нвемэ. гюяхл опняхл нрйкюмъряъ, дюкее хдер'
		db	' рпюдхжхнммюъ псапхйю.'
		db	'             опхберш х яоюяхаш!     '
		db	' ююю, Tеае опнярн опхбер йюй бекхйнлс анцс делняжемш :).'
		db	' TS-LABS, яоюяхан гю рн, врн опхчрхк мю ябнел тнпсле аеяунгмнцн окчьебнцн ледбедъ.'
		db	' ROBAT, ме опнярн яоюяхан, ю яоюяхахые гю онрпъяючысч йюпрхмйс, нмю йпсрю.'
		db	' CREATOR х LESSNIK (BREEZE), яоюяхан гю нргшбш он опедшдсыелс бшосяйс.'
		db	' BART ROYMANS яоюяхан гю лсгшйс, гбсвюыеи б яанпмхйе, нцпнлмши пеяоейр х сбюфсую.'
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
