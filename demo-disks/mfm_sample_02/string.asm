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
		ld	de, 5471h
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
;		dec	hl
;		rl	(hl)
;		dec	hl
;		rl	(hl)
;		dec	hl
;		rl	(hl)
;		dec	hl
;		rl	(hl)
;		dec	hl
;		rl	(hl)
;		dec	hl
;		rl	(hl)
;		dec	hl
;		rl	(hl)
;		dec	hl
;		rl	(hl)
;		dec	hl
;		rl	(hl)
;		dec	hl
;		rl	(hl)
;		dec	hl
;		rl	(hl)
;		dec	hl
;		rl	(hl)
;		dec	hl
;		rl	(hl)
;		dec	hl
;		rl	(hl)
;		dec	hl
;		rl	(hl)
;		dec	hl
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
		db	'      *LOAD* ',0

Str_addr_text:
		db 	'                             << SPACE TO CHANGE MUSIC >>       '
		db 	'                             опхбер, MICK опедярюбкъер мнбши яанпмхй  '
		db	' лсгшйх дкъ гбсйнбни йюпрш *ZXM-MOONSOUND*. б щрнл яанпмхйе, б нркхвхх нр яанпмхйнб *MOONSOUND*'
		db	' янапюмш лекндхх тнплюрю MFM, йнрнпши ъбкъеряъ пюммеи бепяхеи тюикнб тнплюрю MWM.'
		db	' ху ме рюй лмнцн ашкн бшосыемн, мн йюфдюъ хг мху нвемэ дюфе меокную.'
		db	' йнпнве, ме нрйкюдшбюъ б днкцхи ъыхй, мюапюк лсгнм х мюжюпюоюк беяексч йюпрхмйс.'
		db	' япюгс цнбнпч, цпхаш ме ек, рпюбс ме йспхк :)'
		db	' хрюй, б щрнл яанпмхйе оърмюджюрэ лекндхи я пюяьхпемхел MFM, йнрнпше'
		db	' оепейкчвючряъ осрел мюфюрхъ йкюбхьх "SPACE", яохянй йнрнпшу хдер якеднл: '

		db	' ALONEBTL.MFM (ALONE BATTLE / YS-II / BART ROYMANS / ZODIAC 1995),'
		db	' DJINGLE1.MFM (END OF SEARCH / RHUMBA VERSION / R. V/D MOOSDIJK),'
		db	' DJINGLE2.MFM (END OF SEARCH / SLOW-AGE VERSION / BART ROYMANS),'
		db	' DJINGLE3.MFM (END OF SEARCH / NORMAL VERSION / R. V/D MOOSDIJK),'
		db	' DJINGLE4.MFM (END OF SEARCH / HAPPY VERSION / BART ROYMANS),'
		db	' DJINGLE5.MFM (END OF SEARCH / BRUTAL VERSION / MOOSDIJK & ROYMANS),'
		db	' CRYOGENT.MFM (CRYOGENITY LIVE / R. V/D MOOSDIJK / ZODIAC 1995),'
		db	' DERTIGAP.MFM (DERTIG APRIL 1995, EERSTE MET MOONSOUND A.MINNAARD),'
		db	' FEEDBACK.MFM (THE FEEDBACK THEME / TECNO-SOFT / R. V/D MOOSDIJK),'
		db	' FOUNTAIN.MFM (FOUNTAIN OF LOVE / YS-1 / R. V/D MOOSDIJK ZODIAC),'
		db	' PATSTORY.MFM (A PATHETIC STORY / YS-II / BART ROYMANS / ZODIAC 1995),'
		db	' JDK2.MFM (JDK SONG II / YS-III / BART ROYMANS / ZODIAC 1995),'
		db	' SALMON.MFM (THE PALACE OF SALMON / YS-II / R. V/D MOOSDIJK),'
		db	' MEMORY.MFM (IN THE MEMORY / YS-I / R. V/D MOOSDIJK ZODIAC),' 
		db	' PALACEOD.MFM (PALACE OF DESTRUCTION / YS I / NIHON FALCOM).'

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
		incbin "aaa_2.fnt"
Str_end_font:
