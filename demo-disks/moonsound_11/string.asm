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
		db 	'                опхбер, опхбер! мюднедкхбши окчьебши ледбедэ MICK опнднкфюер бюл днйсвюрэ !'
		db	' х еые ндхм ябефхи яанпмхй лекндхи дкъ гбсйнбни йюпрш *ZXM-MOONSOUND* унвс бюл опедкнфхрэ дкъ опняксьхбюмхъ.'
		db	' мю щрнр пюг лекндхи лмнцн, юф жекшу 30, мн нмх бяе йнпнрйхе. жекхйнл яанпмхй гбсвхр 26 лхмср,'
		db	' рюй врн бпелемх нм с бюя гюилер янбяел мелмнцн. он ясрх щрн яанпмхй ндмнцн лсгшйюмрю - MANUEL PAZOS,'
		db	' мн еярэ дбю-рпх рпейю я дпсцхлх юбрнпюлх, ндхм хг йнрнпшу яюл WOLF. х он рюпдхжхх мюьх усднфмхйх'
		db	' нрдшуючр, опхундхряъ блеярн мху гюмхлюрэяъ йнохоюярни, рнеярэ йюкъйюмхел люкъйюмхел.'
		db	' ю б нярюкэмнл бяе йюй нашвмн, нвепедмюъ онпжхъ тюикнб я пюяьхпемхел MWM,'
		db	' йнрнпше ме рпеасчр гюцпсгйх'
		db	' ящлокнб. йюпрхмйю хг хмерю, якецйю яйнмбепвемю х ондпхурнбюмю б лепс лнху слемхи.'
		db	' мс х еые унрекняэ аш нрлерхрэ, врн б лхпе яоейрпслю ярпюярх бяе мюйюкъчряъ х мюйюкъчряъ.'
		db	' ме сяоекх срхумсрэ ярпюярх он онбндс ююю х ецн люпхеи апюулюрсккхмни, йюй наыеярбеммнярэ'
		db	' бгнпбюк RINDEX. ецн бяе рюйх гюаюмхкх мю ZX.PK.RU, рюй яйюгюрэ гюрпюуюк рюл бяел лнгц.'
		db	' вепр, йсдю декяъ рнр RINDEX, йнрнпнцн гмюкх янбяел дпсцхл. хрнцн, бяе пюгфнохкхяэ х хлеел'
		db	' вершпе тнпслю х ндхм уюио. х йюй онкюцюеряъ ян ябнхлх жюпълх х онпъдйюлх, хмрпхцюлх яокермълх.'
		db	' йнпнве хцпю опеярнкнб яегнм йюйни рн рюл. мн б щрни цпшгме лхмся ндхм - онунфе мюярсохк гюйюр'
		db	' яоейрпслю. нахдмн х дняюдмн. кюдмн убюрхр н цпсярмнл.    '

		db	' хрюй, б щрнл яанпмхйе рпхджюрэ йнпнремэйху лекндхи, йнрнпше'
		db	' оепейкчвючряъ осрел мюфюрхъ йкюбхьх "SPACE", кхан фдере онйю ме гюйнмвхряъ лекндхъ.'
		db	' яохянй лекндхи хдер якеднл: '

		db	' IMPACT196.MWM (IMPACT 196 - BDD 1992 - Omega 1995 (C) DREAMSCAPE),'
		db	' AMAG02.MWM (AMAGO 2 - MANUEL PAZOS),'
		db	' APROACH.MWM (APPROACHING - MANUEL PAZOS),'
		db	' BASS.MWM (BASS INSPIRATION - MANUEL PAZOS),'
		db	' CEREMONY.MWM (CEREMONY - MANUEL PAZOS),'
		db	' AMAG06.MWM (AMAGO 6 - MANUEL PAZOS),'
		db	' MISION.MWM (MISION IMPOSIBLE - MANUEL PAZOS),'
		db	' CLOUDS.MWM (CLOUDS - MANUEL PAZOS),'
		db	' DONTCRY.MWM (DONT CRY LITTLE SISTER - MANUEL PAZOS),'
		db	' ECHOS.MWM (ECHOS - MANUEL PAZOS),'
		db	' GALIOUS.MWM (THE MAZE OF GALIOUS INNER CASTLE - MANUEL PAZOS),'
		db	' ITIY2.MWM (ITIY 2 - MANUEL PAZOS),'
		db	' LOOP.MWM (LOOP - MANUEL PAZOS),'
		db	' MAE2.MWM (MAE 2 - MANUEL PAZOS),'
		db	' AMAG04.MWM (AMAGO 4 - MANUEL PAZOS),'
		db	' BLOWING.MWM (BLOWING DARKNESS - MANUEL PAZOS),'
		db	' CREDITS.MWM (CREDITOS CARLOS GARSIA. MARZO 1996 - MANUEL PAZOS),'
		db	' GALIOUS2.MWM (THE MAZE OF GALIOUS WORLD - MANUEL PAZOS),'
		db	' MAE.MWM (MAE - MANUEL PAZOS),'
		db	' NERTY.MWM (NERTY - MANUEL PAZOS),'
		db	' PARO14.MWM (PARODIUS BGM 14 - MANUEL PAZOS),' 
		db	' SACRA.MWM (MUSICA SACRA - MANUEL PAZOS),'
		db	' TEARSYLP.MWM (TEARS OF SYLPH - MANUEL PAZOS),'
		db	' FD_MG5.MWM (BOSS BATTLE - MG - SOUNDWAVE 1998),'
		db	' AMAG05.MWM (AMAGO 5 - MANUEL PAZOS),'
		db	' CUARTA.MWM (4A CARLOS GARCIA, MARZO 1996 - MANUEL PAZOS),'
		db	' MAKING1.MWM (UNKNOWN),'
		db	' NONAMED.MWM (UNKNOWN),'
		db	' PARO14B.MWM (PARODIUS BGM 14 - MANUEL PAZOS),' 
		db	' GO.MWM (SPELLEKE... G A M E O V E R - (C) 1995 WOLF).'

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
		incbin "aaa_1.fnt"
Str_end_font:
