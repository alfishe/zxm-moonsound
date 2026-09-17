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
		db 	'                опхбер, MICK ямнбю я бюлх!'
		db	' еые ндхм лсгшйюкэмши яанпмхй дкъ гбсйнбни йюпрш *ZXM-MOONSOUND* сбхдек ябер.'
		db	' янаярбеммн б цнкнбс мхвецн ме опхундхр, врнаш рюйнцн мюянвхмърэ н бнгмхймнбемхх'
		db	' щрнцн яанпмхйю. бяе йюй опефде. аепел йсвйс MWM тюикнб, люкчел йюпрхмйс х бнр мнбши бшосяй цнрнб.'
		db	' дпсцне бюфмн мю яеи демэ. бекхйхи х сфюямши ююю пюгнвюпнбюкяъ б гелкъмюу. нм пеьхк, врн нмх'
		db	' ме днярнимш асдсыецн х ямея ябни яюир блеяре я мюякедхел яоеййх, ю рюйфе сдюкхк ябнч цпсоос'
		db	' бйнмрюйре. ю фюкэ, рюл ашк меокнуни лсгнм, йнрнпши лнфмн ашкн бйкчвюрэ б йювеярбе тнмю.'
		db	' ююю нахдхбьхяэ - гюъбхк, врн анкэье яоеййх елс ме хмрепеяем. щу, фюкэ, фюкэ.'
		db	' оняелс рюй онксвхкняэ, врн яанпмхй онксвхкяъ б нямнбмнл кхпхвеяйхл. мс дю кюдмн.'   
		db	' хрюй, б щрнл яанпмхйе бняелмюджюрэ лекндхи, йнрнпше'
		db	' оепейкчвючряъ осрел мюфюрхъ йкюбхьх "SPACE". яохянй лекндхи хдер якеднл: '

		db	' KONAMI_1.MWM (HINOTORI"S QUEST - SOUNDWAVE 1998),'
		db	' ALEID.MWM (ALEID KINGDOM - ARRANGED BY J. HASSINK, 31-03-1997),'
		db	' ALESTE.MWM (ALESTE ETUDE - OPL4 VERSION - SOUNDWAVE 1998),'
		db	' REGGAE.MWM (REGGAE COOKS - OPL4 VERSION - SOUNDWAVE 1998),'
		db	' EXTOR1.MWM (EXTOR 1 - BY QIX),' 
		db	' END13DO.MWM (THE END 13 IN EEN DOZIJN - BY QIX),'
		db	' DISCST-1.MWM (DISCTATION MENU - ANTIQUE VERSION - SOUNDWAVE"96),'
		db	' FD_MG_1.MWM (NIGHTFALL - MG2 - SOUNDWAVE 1998),'
		db	' FF7_SEL.MWM (FINAL FANTASY 7 - OPENING - OPL4 - SOUNDWAVE 1998),'
		db	' FD_MG_2.MWM (END TITLES - MG2 - SOUNDWAVE 1995/1998),'
		db	' FD_MG_3.MWM (RED ALERT - MG - SOUNDWAVE 1995/1998),'
		db	' FF7.MWM (ON KOEN"S REQUEST: KALM - OPL4 - SOUNDWAVE 1998),'
		db	' FF7_OMOI.MWM (FINAL FANTASY 7 - OMOI - OPL4 - SOUNDWAVE 1998),'
		db	' ONEPIAN.MWM (ONE PIANO MELODY - BY QIX),'
		db	' FD_MG_4.MWM (RENDEZ-VOUS - MG2 - SOUNDWAVE 1995/1998),'
		db	' FD_MG_5.MWM (BOSS BATTLE - MG - SOUNDWAVE 1998),'
		db	' FD_MG_6.MWM (INVASION - MG - SOUNDWAVE 1998),'
		db	' KONAMI_4.MWM (SNEAKY SNATCHIN - SOUNDWAVE 1998).'

		db	' йпнле рнцн еярэ еые ндмю ймнойю "BREAK" - бшунд б TR-DOS.'
		db 	' н опнцпюлле: нямнбмше люрепхюкш ашкх онгюхлярбнбюмш я опнцпюлл йнлоэчрепю "MSX" х бекхйни'
		db	' лсянпйх онд мюгбюмхел хмрепмер.' 
		db 	' бяе щрн янахпюкняэ мю пя опх онлных юяяелакепю  SJASMPLUS.'
		db	' мюонлмч, еякх с бюя йюпрхмйю цде еярэ релю ксмш х оеигюифеи, рн лхкнярх опняхл б якедсчыхи бшосяй.'
		db	' йнпнве, фдел мнбшу рбнпемхи нр усднфмхйнб опнтеяяхнмюкэмшу х ме нвемэ. гюяхл опняхл нрйкюмъряъ, дюкее хдер'
		db	' рпюдхжхнммюъ псапхйю.'
		db	'             опхберш х яоюяхаш!     '
		db	' ююю, унрэ рш х онйхмск яоеййх, бяе пюбмн реае опхбер.'
		db	' TS-LABS, яоюяхан гю рн, врн опхчрхк мю ябнел тнпсле аеяунгмнцн окчьебнцн ледбедъ.'
		db	' DJS3000, яоюяхан гю йнмяскэрюрхбмсч онлныэ опх янгдюмхх щрни гбсйнбни йюпрш.'
		db	' юбрнпюл лсгшйх, гбсвюыеи б яанпмхйе нцпнлмши пеяоейр х сбюфсую.'
		db	' бяел бкюдекэжюл опндсйжхх онд апемднл "ZXM" анкэьсыхи опхбер. бюя лмнцн, лнфмн ме асдс бюя мюгшбюрэ бяеу онхлеммн.'
		db	' опхбер рюйфе бяел яоейрпслхярюл, ашбьхл, мюярнъыхл х бнглнфмн асдсыхл.'
		db	'       х онякедмхи юагюж :) :)'
		db	' бяъ хмтю он лнхл опнейрюл мю яюире WWW.MICKLAB.RU, '
		db	' ябъгюрэяъ ян лмни лнфмн вепег тнпсл WWW.TS-LABS.INFO - мхймеил MICK хкх вепег лшкн'
		db	' MICKLAB(цюб-цюб)MAIL.RU.' 
		db	' онпю опныюрэяъ. онялнпрхл асдср кх еые опнцпюллйх нр лемъ :) онйю! онйю!      '
		db	'            MARCH *2016*    GRAPHICS AND CODE BY MICK         '
		db	'                                             ',0           		
Str_addr_font:
		incbin "aaa_4.fnt"
Str_end_font:
