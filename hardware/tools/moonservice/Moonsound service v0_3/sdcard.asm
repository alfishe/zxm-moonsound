;-------------------------------------------------------------------
; НОХЯЮМХЕ: лНДСКЭ ТСМЙЖХИ ПЮАНРШ Я SD ЙЮПРНИ, НЯМНБЮМ МЮ ХЯУНДМХЙЮУ 16.02.2014 savelij
;---------------------------------------------------------------------
P_DATA		equ 	57h
P_CONF		equ 	77h

CMD_09:		equ 	49h	;SEND_CSD
CMD_12:		equ 	4Ch	;STOP_TRANSMISSION
CMD_17:		equ 	51h	;READ_SINGLE_BLOCK
CMD_18:		equ	52h	;READ_MULTIPLE_BLOCK
CMD_24:		equ 	58h	;WRITE_BLOCK
CMD_25:		equ 	59h	;WRITE_MULTIPLE_BLOCK
CMD_55:		equ 	77h	;APP_CMD
CMD_58:		equ 	7Ah	;READ_OCR
CMD_59:		equ 	7Bh	;CRC_ON_OFF
ACMD_41:	equ 	69h	;SD_SEND_OP_COND


;мю бунде:
;HL-рейярнбюъ ярпнйю осрх нр ROOT
;DE-юдпея йсдю цпсгхрэ
SDCard_start:
		LD 	IYL,2
		LD 	(ADRPATH),HL
		LD 	(ADR_LD),DE
		LD 	A,3
		OUT 	(P_CONF),A
		XOR	A
		OUT 	(P_DATA),A
		LD 	BC,P_DATA
		LD 	DE,10FFh
SDCard_start_00:
		OUT 	(C),E
		DEC 	D
		JR 	NZ,SDCard_start_00
		LD 	A,1
		OUT 	(P_CONF),A
		XOR 	A
		EX 	AF,AF'
ZAW001:		
		LD 	HL,CMD00
		CALL 	OUTCOM			;оепебндхл йюпрнвйс б пефхл SPI йнлюмдни 0
		CALL 	IN_OOUT			;фдел нрберю
		EX 	AF,AF'
		DEC 	A
		JP 	Z,ZAW003		;фдел он явервхйс 256 пюг
		EX 	AF,AF'
		DEC 	A
		JR 	NZ,ZAW001		;фдел онйю йюпрю нрберхр аюирнл 1
		LD 	BC,P_DATA
		LD 	HL,CMD08
		CALL 	OUTCOM			;нопедекъел яоежхтхйюжхч йюпрш
		CALL 	IN_OOUT			;б "A" нрбер йюпрш R1
		IN 	H,(C)
		NOP
		IN 	H,(C)	
		NOP
		IN 	H,(C)
		NOP
		IN 	H,(C)			;опнвхрюкх нярюкэмше аюирш б мхйсдю
		BIT 	2,A			;еякх ньхайю, рн
		LD 	HL,0			;йюпрю яоежхтхйюжхх 1.0
		JR 	NZ,ZAW006		;хмюве 
		LD 	H,40h			;йюпрю яоежхтхйюжхх 2.0
ZAW006:		
		LD 	A,CMD_55
		CALL 	OUT_COM			;гюосяйюел бмсрпеммчч хмхжхюкхгюжхч йюпрш
		CALL 	IN_OOUT
		LD 	BC,P_DATA
		LD 	A,ACMD_41
		OUT 	(C),A
		LD 	A,H
		OUT 	(C),A
		XOR 	A
		OUT 	(C),A
		NOP
		OUT 	(C),A
		NOP
		OUT 	(C),A
		DEC 	A
		OUT 	(C),A
		CALL 	IN_OOUT
		AND 	A
		JR 	NZ,ZAW006		;фдел онйю йюпрш оепеидер б пефхл цнрнбмнярх
ZAW004:		
		LD 	A,CMD_59
		CALL 	OUT_COM			;опхмсдхрекэмн нрйкчвюел CRC16
		CALL 	IN_OOUT
		AND 	A
		JR 	NZ,ZAW004
ZAW005:		
		LD 	HL,CMD16
		CALL 	OUTCOM			;опхмсдхрекэмши пюглеп яейрнпю 512 аюир
		CALL 	IN_OOUT
		AND 	A
		JR 	NZ,ZAW005

;хмхжхюкхгюжхъ оепелеммшу FAT
WC_FAT:		
		LD 	DE,0
		LD 	B,D
		LD 	C,E
		CALL 	LOADLST			;вхрюел яейрнп 0 йюпрнвйх
		PUSH 	HL
		POP 	IX
		LD 	DE,01BEh
		ADD 	HL,DE			;оепеундхл мю ялеыемхе дкъ опнбепнй
		LD 	A,(HL)			;опнбепъл врнаш ашк 0, йюпрнвйх ме лнцср ашрэ гюцпсгнвмшлх
		AND 	7Fh
		JR 	NZ,RDFAT05		;еякх ме 0, опнбепхрэ дпсцне
		LD 	DE,4
		ADD 	HL,DE			;оепеундхл й опнбепйе рхою пюгдекю
		LD 	A,(HL)
		LD 	B,0
		CP 	1			;FAT12?
		JR 	Z,RDFAT06
		LD 	B,2
		CP 	0Bh			;FAT32?
		JR 	Z,RDFAT06
		CP 	0Ch			;FAT32?
		JR 	Z,RDFAT06
		LD 	B,1
		CP 	4			;FAT14?
		JR 	Z,RDFAT06
		CP 	6			;FAT16?
		JR 	Z,RDFAT06
		CP 	0Eh			;FAT16?
		JR 	NZ,RDFAT05
RDFAT06:
		LD 	A,B			;аепел хг "B" рхо пюгдекю
		LD 	(CAL_FAT),A		;янупюмхкх
		ADD 	HL,DE
		CALL 	LOADZP			;аепел мнлеп яейрнпю мювюкю нямнбмнцн пюгдекю
		JR 	RDFAT00			;оепеундхл й хмхжхюкхгюжхх оепелеммшу дкъ пюанрш я тюрнл

;MBR ме намюпсфем, опнбепъел яейрнп 0 йюпрш йюй нохяюрекэ
RDFAT05:	
		LD 	C,(IX + 0Dh)		;C=йнкхвеярбн яейрнпнб б йкюярепе
		XOR 	A
		LD 	E,A
		LD 	B,8
SDCard_start_01:
		RR 	C
		ADC 	A,0
		DJNZ 	SDCard_start_01		;йнкхвеярбн яейрнпнб б йкюярепе днкфмн ашрэ яреоемэч 2
		DEC 	A
		JR 	NZ,SDCard_start_02	;опнбепхкх йнкхвеярбн ахр
		INC 	E			;+1, еярэ рюйне
SDCard_start_02:
		LD 	A,(IX + 0Eh)
		OR 	(IX + 0Fh)
		JR 	Z,SDCard_start_03	;йнкхвеярбн гюпегепбхпнбюммшу яейрнпнб днкфмн ашрэ >0
		INC 	E			;+1, еярэ рюйне
SDCard_start_03:
		LD 	A,(IX + 13h)
		OR 	(IX + 14h)
		JR 	NZ,SDCard_start_04	;йнкхвеярбн яейрнпнб мю пюгдеке дкъ тюр16?
		INC 	E
SDCard_start_04:
		LD	A,(IX + 20h)
		OR 	(IX + 21h)
		OR 	(IX + 22h)
		OR 	(IX + 23h)
		JR 	NZ,SDCard_start_05	;йнкхвеярбн яейрнпнб мю пюгдеке дкъ тюр32?
		INC 	E			;ндмн хг мху днкфмн ашрэ =0, дпсцне >0
SDCard_start_05:
		LD 	A,(IX + 15h)
		AND 	0F0h
		CP 	0F0h
		JR 	NZ,SDCard_start_06	;ярюпьхе ахрш днкфмш ашрэ б 1
		INC 	E
SDCard_start_06:
		LD 	A,E
		CP 	4			;сякнбхъ янбоюкх?
		LD 	A,0DDh			;FAT ме мюидем
		SCF
		RET 	NZ
		LD 	A,0FFh
		LD 	(CAL_FAT),A		;рхо тюр онйю ме нопедекем
		LD 	DE,0
		LD 	B,D
		LD 	C,E

RDFAT00		LD 	(STARTRZ),DE
		LD 	(STARTRZ + 2),BC	;онкнфхкх мнлеп ярюпрнбнцн яейрнпю пюгдекю
		CALL 	LOADLST			;гюцпсгхкх ецн
		LD 	HL,0
		LD 	DE,(BUF_512_+ 16h)	;BPB_FATSZ16
		LD 	A,D
		OR 	E
		JR 	NZ,RDFAT01		;еякх ме FAT12/16 (BPB_FATSZ16=0)
		LD 	DE,(BUF_512_+ 24h)
		LD 	HL,(BUF_512_+ 26h)	;BPB_FATSZ32
						;рн аепел хг ялеыемхъ +36
RDFAT01		LD 	(SEC_FAT + 2),HL
		LD 	(SEC_FAT),DE		;вхякн яейрнпнб мю FAT-рюакхжс
		LD 	HL,0
		LD 	DE,(BUF_512_ + 13h)	;BPB_TOTSEC16
		LD 	A,D
		OR 	E
		JR 	NZ,RDFAT02		;еякх ме FAT12/16 (BPB_TOTSEC16=0)
		LD 	DE,(BUF_512_+ 20h)
		LD 	HL,(BUF_512_+ 22h)	;BPB_TOTSEC32
						;рн аепел хг ялеыемхъ +32
RDFAT02		LD 	(SEC_DSC+2),HL
		LD 	(SEC_DSC),DE		;й-бн яейрнпнб мю дхяйе/пюгдеке

;бшвхякъел ROOTDIRSECTORS
		LD 	DE,(BUF_512_+ 11h)	;BPB_ROOTENTCNT
		LD 	HL,0
		LD 	A,D
		OR 	E
		JR 	Z,RDFAT03
		LD 	B,H
		LD 	C,L
		LD 	A,10h
		CALL 	BCDE_A
		EX 	DE,HL

;щрн пеюкхгнбюмю тнплскю
;ROOTDIRSECTORS=((BPB_ROOTENTCNT*32)+(BPB_BYTSPERSEC-1))/BPB_BYTSPERSEC
;б HL=ROOTDIRSECTORS. еякх FAT32, рн HL=0 бяецдю

RDFAT03		PUSH 	HL			;ROOTDIRSECTORS
		LD	(ROOTSEC),HL
		LD 	A,(BUF_512_+ 10h)
		LD 	DE,(SEC_FAT)
		LD 	HL,(SEC_FAT+2)
		DEC 	A
SDCard_start_07:
		EX 	DE,HL
		ADD 	HL,HL
		EX 	DE,HL
		ADC 	HL,HL
		DEC 	A
		JR 	NZ,SDCard_start_07
		POP 	BC			;онкмши пюглеп FAT-накюярх б яейрнпюу
		CALL 	HLDEPBC			;опхаюбхкх ROOTDIRSECTORS
		LD 	BC,(BUF_512_+ 0Eh)	;BPB_RSVDSECCNT
		LD 	(RSVDSEC),BC
		CALL 	HLDEPBC			;опхаюбхкх BPB_RESVDSECCNT
		LD 	(FRSTDAT),DE
		LD 	(FRSTDAT + 2),HL	;онкнфхкх мнлеп оепбнцн яейрнпю дюммшу
		LD 	B,H
		LD 	C,L
		LD 	HL,SEC_DSC		;BCDE+32-не вхякн он юдпеяс HL
		CALL 	BCDEHLM			;бшвкх хг онкмнцн й-бю яейрнпнб пюгдекю
		LD 	A,(BUF_512_ + 0Dh)
		LD 	(BYTSSEC),A
		CALL 	BCDE_A			;пюгдекхкх мю й-бн яейрнпнб б йкюярепе
		LD 	(CLS_DSC),DE
		LD 	(CLS_DSC+2),BC		;онкнфхкх йнк-бн йкюярепнб мю пюгдеке

		LD 	A,(CAL_FAT)
		CP 	0FFh
		JR 	NZ,RDFAT04
		LD 	DE,(SEC_FAT-1)		;еякх пюгпъдмнярэ тюрю ме нопедекемю, нопедекъел
		LD 	BC,(SEC_FAT+1)		;бгъкх йнкхвеярбн йкюярепнб мю пюгдеке
		LD 	E,0
		PUSH 	BC
		PUSH 	DE
		SRL 	B
		RR 	C
		RR 	D
		RR 	E
		LD 	HL,CLS_DSC
		PUSH 	HL
		CALL 	HLBCDEM
		LD 	A,E
		AND 	80h
		OR 	D
		OR 	C
		OR 	B
		LD 	A,2
		POP 	HL
		POP 	DE
		POP 	BC
		JR 	Z,RDFAT04
		CALL 	HLBCDEM
		LD 	A,D
		OR 	C
		OR 	B
		LD 	A,1
		JR 	Z,RDFAT04
		XOR 	A

;дкъ FAT12/16 бшвхякъел юдпея оепбнцн яейрнпю дхпейрнпхх
;дкъ FAT32 аепел он ялеыелхч +44, мю бшунде BCDE-яейрнп ROOTDIR
RDFAT04		PUSH 	AF
		LD 	DE,(RSVDSEC)
		LD 	BC,0
		LD 	HL,STARTRZ
		CALL 	BCDEHLP
		LD 	(FATSTR),DE
		LD 	(FATSTR+2),BC		;бшвхякхкх х онкнфхкх мнлеп яейрнпю мювюкю FAT-еюакхж
		POP 	AF
		LD 	(CAL_FAT),A		;срнвмхкх рхо тюрю
		AND 	A
		LD 	DE,0
		LD 	B,D
		LD 	C,E
		JR 	Z,FSRROO2		;FAT12-NONE
		DEC 	A
		JR 	Z,FSRROO2		;FAT16
		LD 	DE,(BUF_512_ + 2Ch)
		LD 	BC,(BUF_512_ + 2Eh)	;FAT32
FSRROO2		LD 	(ROOTCLS),DE
		LD 	(ROOTCLS+2),BC		;онкнфхкх мнлеп йкюяреп ROOT дхпейрнпхх

		LD 	HL,(ADRPATH)		;бепмскх юдпея ярпнйх осрх дн тюикю
FINDFL1		PUSH 	BC
		PUSH 	DE			;янупюмхкх мнлеп йкюярепю
		CALL 	FNDBUF			;пюяоюйнбйю вюярх рейярнбни ярпнйх дкъ янгдюмхъ люяйх онхяйю
		POP 	DE
		POP 	BC			;бняярюмнбхкх мнлеп йкюярепю
		PUSH 	HL			;янупюмхкх рейсыхи юдпея рейярнбни ярпнйх

		LD 	HL,TDIRCLS		;юдпея рюакхжш йкюярепнб рейсыеи дхпейрнпхх
		LD 	A,D
		OR 	E
		OR 	B
		OR 	C
		CALL 	SAVEZP			;янупюмхкх б рюакхжс мнлеп рейсыецн йкюярепю
		JR 	Z,LASTCLS		;еякх мнлеп йкюярепю 0, рн щрн ROOT дхпю (дкъ тюр12/16)
NEXTCLS		PUSH 	HL
		CALL 	RDFATZP			;вхрюел якедсыхи мнлеп йкюярепю хг жеонвйх дхпейрнпхх
		CALL 	LST_CLS			;опнбепъел мю йнмеж жеонвйх
		POP 	HL
		JR 	C,LASTCLS
		CALL 	SAVEZP			;еякх меонякедмхи янупюмъел б рюакхжс
		JR 	NEXTCLS			;якедсчыхи мнлеп йкюярепю

LASTCLS		LD 	BC,0FFFFh
		CALL 	SAVEZP			;йкюдел люпйеп йнмжю жеонвйх

FINDFL		INC 	BC			;хыел он гюдюммни люяйе мювхмюъ я 0
		CALL 	RDDIRSC			;цпсгхл он мнлепс нохяюрекъ яейрнп дхпейрнпхх
		LD 	A,C
		AND 	0Fh			;б яейрнпе люйяхлсл 16 нохяюрекеи
		LD 	E,A
		LD 	D,0
		EX 	DE,HL
		ADD 	HL,HL
		ADD	HL,HL
		ADD 	HL,HL
		ADD 	HL,HL
		ADD 	HL,HL
		ADD 	HL,DE			;онксвхкх юдпея мсфмнцн нохяюрекъ
		LD 	A,(HL)			;опнбепъел оепбши аюир хлемх нохяюрекъ
		AND 	A
		LD 	A,0AAh			;еякх аюир =0, рн
		JP 	Z,WR_STAT		;оепеунд он ньхайе = тюик ме мюидем
		PUSH 	HL
		PUSH 	BC
		CALL 	COMPARE			;япюбмхбюел я гюдюммни люяйни
		POP 	BC
		POP 	DE
		PUSH 	DE
		POP 	IX			;яндепфхлне IX=юдпея нохяюрекъ
		JR 	NZ,FINDFL		;ме янбоюдюер, оепеундхл й якедсчыелс нохяюрекч
		LD 	A,(IX + 1Fh)
		OR 	(IX + 1Dh)
		OR 	(IX + 1Ch)
		LD 	A,99h
		JP 	NZ,WR_STAT
		LD 	A,(IX + 1Eh)

		CP 	32			;2 ЛЕЦЮАЮИРЮ

		LD 	A,99h
		JP 	NZ,WR_STAT

		CALL 	RD_CLAS			;гюахпюел мнлеп йкюярепю хг мюидеммнцн нохяюрекъ
		EX 	(SP),HL			;бняярюмнбхкх рейсыхи юдпея б ярпнйе осрх дн тюикю
		INC 	SP
		INC 	SP			;люяйхпнбйю мю ярейе юдпеяю пюглепю б аюирюу рейсыецн тюикю
		LD 	A,(HL)
		AND 	A			;рейярнбюъ ярпнйю йнмвхкюяэ?
		JR 	NZ,FINDFL1		;еякх мер, рн хыел дюкэье
		LD 	A,(IX + 0Bh)		;опнбепъел щрн дхпю хкх тюик?
		AND 	10h
		JR 	NZ,FINDFL		;еякх дхпю, рн опнднкфюел онхяй

		ld	(NUM_CLS_HIGH),bc	;ЯНУПЮМХЛ МНЛЕП ЙКЮЯРЕПЮ, ЦДЕ МЮУНДХРЯЪ ТЮИК
		ld	(NUM_CLS_LOW),de
		xor 	a
		ret

ZAW003:		
		ld 	a,0EEh			;бшдювю ньхайх "мер йюпрнвйх"
		scf
		ret

WR_STAT:	
		pop 	hl
		scf
		ret


; HL  - юдпея гюцпсгйх
; IXL - йнкхвеярбн яейрнпнб дкъ гюцпсгйх
; IXH - пюглеп йкюярепю
; IYL -
; IYH - ялеыемхе б йкюярепе
LD_FILE:
		PUSH 	BC
		PUSH 	DE
		PUSH 	HL
		CALL 	REALSEC		;оепебекх мнлеп йкюярепю б мнлеп яейрнпю
		LD 	A,IYH
		LD 	L,A
		LD 	H,0
		ADD 	HL,DE
		EX 	DE,HL
		JR 	NC,LD_FILE1
		INC 	BC			;BCDE=мнлеп яейрнпю нрйсдю цпсгхрэ
LD_FILE1:
		LD 	A,IXL
		CP 	IXH
		JP 	C,LD_FILE2
		LD 	A,IXH
LD_FILE2:
		ADD 	A,IYH
		CP 	IXH
		LD 	A,IXL
		JP 	C,LD_FILE5
		LD 	A,IXH
		SUB 	IYH
LD_FILE5:
		LD 	IYL,A			;яйнкэйн яейрнпнб яеивюя цпсгхл
		POP 	HL			;бняярюмнбхкх юдпея гюцпсгйх
		CALL 	RDMULTI			;гюцпсгхкх яейрнпю
		POP 	DE
		POP 	BC			;бняярюмнбхкх мнлеп йкюярепю
		LD 	A,IYH
		ADD 	A,IYL
		CP	IXH
		JP	C,LD_FILE3
		SUB 	IXH
LD_FILE3:
		LD 	IYH,A
		JP 	C,LD_FILE4
		PUSH 	HL			;янупюмхкх юдпея гюцпсгйх
		CALL 	RDFATZP			;опнвхрюкх мнлеп якедсчыецн йкюярепю
		CALL 	LST_CLS			;опнбепхкх, ю лнфер щрн онякедмхи йкюяреп?
		POP 	HL			;бняярюмнбхкх юдпея гюцпсгйх
		RET 	C			;еякх онякедмхи, бшундхл
LD_FILE4:
		LD 	A,IXL
		SUB 	IYL
		RET	Z
		LD 	IXL,A
		JP 	NZ,LD_FILE
		RET

SAVEZP:
		LD 	(HL),E
		INC 	HL
		LD 	(HL),D
		INC 	HL
		LD 	(HL),C
		INC 	HL
		LD 	(HL),B
		INC 	HL
		RET

LOADZP:
		LD 	E,(HL)
		INC 	HL
		LD 	D,(HL)
		INC 	HL
		LD 	C,(HL)
		INC 	HL
		LD 	B,(HL)
		INC 	HL
		RET

;времхе яейрнпю DIR он мнлепс BC
RDDIRSC:
		PUSH 	BC
		LD 	D,B
		LD 	E,C
		LD 	BC,0
		LD 	A,10h
		CALL 	BCDE_A
		LD 	A,E
		PUSH 	AF
		LD 	A,(BYTSSEC)
		PUSH 	AF
		CALL 	BCDE_A
		LD 	HL,TDIRCLS
		EX 	DE,HL
		ADD 	HL,HL
		ADD 	HL,HL
		ADD 	HL,DE
		CALL 	LOADZP
		CALL 	REALSEC
		POP 	AF
		DEC 	A
		LD 	L,A
		POP 	AF
		AND 	L
		LD 	L,A
		LD 	H,0
		ADD 	HL,DE
		EX 	DE,HL
		LD 	HL,0
		ADC 	HL,BC
		LD 	B,H
		LD 	C,L
		CALL 	LOADLST
		POP 	BC
		RET

;опнбепйю мю онякедмхи йкюяреп б жеонвйе
LST_CLS:
		LD 	A,(CAL_FAT)		;гюбхяхр нр пюгпъдмнярх тюрю
		AND 	A
		JP 	NZ,LST_CL1
		LD 	HL,0FF7h		;опнбепйю дкъ тюр12
		SBC 	HL,DE
		RET

LST_CL1:
		DEC 	A
		JP 	NZ,LST_CL2
LST_CL3:
		LD 	HL,0FFF7h		;опнбепйюл дкъ тюр16 х лкюдьху ахр тюр32
		SBC 	HL,DE
		RET

LST_CL2:
		LD 	HL,0FFFh		;опнбепйю дкъ ярюпьху ахр тюр32
		SBC 	HL,BC
		RET 	NZ
		JP 	LST_CL3

;времхе якедсчыецн мнлепю йкюярепю б жеонвйе
RDFATZP:
		LD	A,(CAL_FAT)		;времхе гюбхяхр нр пюгпюдмнярх тюрю
		AND 	A
		JP 	Z,RDFATS0		;оепеунд боепед дкъ тюр12
		DEC 	A
		JP 	Z,RDFATS1		;оепеунд боепед дкъ тюр16
		EX 	DE,HL			;гдеяэ времхе дкъ тюр32
		ADD 	HL,HL
		EX 	DE,HL
		LD 	HL,0
		ADC 	HL,BC
		ADC 	HL,BC			;слмнфхкх мнлеп йкюярепю мю 2
		LD 	A,E
		LD 	E,D
		LD 	D,L
		LD 	C,H
		LD 	B,0			;пюгдекхкх мнлеп йкюярепю мю 256
		CALL 	RDFATS2			;вхрюел лкюдьхе 16 ахр хяонкэгсъ времхе дкъ тюр16
		INC 	HL
		LD 	C,(HL)
		INC 	HL
		LD 	B,(HL)			;опнвхрюкх онякедсчыхе ярюпьхе 16 ахр
		RET

RDFATS1:
		LD 	BC,0
		LD 	A,E
		LD 	E,D
		LD 	D,C			;пюгдекхкх мнлеп йкюярепю мю 256, ярюпьхе 16 ахр =0
RDFATS2:
		PUSH 	AF			;наыее времхе 16 ахрмнцн мнлепю йкюярепю дкъ тюр16/32
		PUSH 	BC
		LD 	HL,FATSTR
		CALL 	BCDEHLP
		CALL 	LOADLST			;гюцпсгхкх бшвхякеммши мнлеп яейрнпю
		POP 	BC
		POP 	AF
		LD 	E,A
		LD 	D,0
		ADD 	HL,DE
		ADD 	HL,DE			;бшвхякхкх ялеыемхе дн мсфмнцн мнлепю б гюцпсфеммнл яейрнпе
		LD 	E,(HL)
		INC 	HL
		LD 	D,(HL)			;онксвхкх 16 ахр мнлепю йкюярепю
		RET

;времхе 12 ахрмнцн мнлепю йкюярепю хг жеонвйх дкъ тюр12
RDFATS0:
		LD 	H,D
		LD 	L,E
		ADD 	HL,HL
		ADD 	HL,DE			;HL=HL*3
		SRL 	H
		RR 	L			;HL=HL/2 - б хрнце слмнфхкх мнлеп йкюярепю мю 1,5
		LD 	A,E			;A-мюл хмрепеяем рнкэйн ахр мнлеп ярюпнцн мнлепю йкюярепю
		LD 	E,H
		LD 	D,0
		LD 	B,D
		LD 	C,D			;пюгдекхкх мнлеп йкюярепю мю 256
		SRL 	E
		PUSH 	AF
		PUSH 	HL
		LD 	HL,FATSTR
		CALL 	BCDEHLP
		CALL 	LOADLST			;гюцпсгхкх бшвхякеммши яейрнп
		POP 	BC
		LD 	A,B
		AND 	1
		LD 	B,A			;BC=ялеыемхе б гюцпсфеммнл яейрнпе
		ADD 	HL,BC			;HL=юдпея нрйсдю вхрюрэ аюирш мнлепю йкюярепю
		LD 	B,(HL)			;опнвхрюкх лкюдьсч вюярэ мнлепю йкюярепю
		INC 	HL			;юдпея якедсчыецн аюирю
		LD 	A,H
		CP 	HIGH (BUF_512_)+2	;опнбепйю мю оепеунд цпюмхжш гюцпсфеммнцн яейрнпю
		JP 	NZ,RDFATS4
		PUSH 	BC			;бшукд гю опедекш рейсыецн гюцпсфеммнцн яейрнпю
		LD 	BC,0
		INC 	DE
		CALL 	LOADLST			;гюцпсфюел якедсчыхи яейрнп тюр рюакхжш
		POP 	BC
RDFATS4:
		POP 	AF
		LD 	D,(HL)			;вхрюел ярюпьхе ахрш мнлепю йкюярепю
		LD 	E,B			;реоепэ DE=мнлеп якедсчыецн йкюярепю б жеонвйе
		LD 	BC,0
		RRA				;опнбепъел ахр 0 ярюпнцн мнлепю йкюярепю
		JP 	NC,RDFATS3
		SRL 	D			;ядбхцюел мнлеп опнвхрюммнцн мнлепю йкюярепю б лкюдьхе 12 ахр
		RR 	E
		SRL 	D
		RR 	E
		SRL 	D
		RR 	E
		SRL 	D
		RR 	E
RDFATS3:
		LD 	A,D
		AND 	0Fh
		LD 	D,A			;яапняхкх мегмювюыхе ярюпьхе 4 ахрю с онксвеммнцн мнлепю йкюярепю
		RET

;бшвхякемхе пеюкэмнцн яейрнпю
;мю бунде BCDE=мнлеп йкюярепю FAT
;мю бшунде BCDE=мнлеп пеюкэмнцн яейрнпю
REALSEC:
		LD 	A,B
		OR 	C
		OR 	D
		OR 	E
		JP 	NZ,REALSE1		;BCDE=0?
		LD 	HL,SEC_FAT		;щрн ROOT дхпейрнпхъ с тюр12/16
		LD 	DE,(FATSTR)		;леярнонкнфемхе ROOT дхпш япюгс оняке тюр рюакхжш
		LD 	BC,(FATSTR+2)
		PUSH 	HL
		CALL 	BCDEHLP			;опхаюбхкх й мювюкс тюр рюакхжш ее пюглеп
		POP 	HL
		JP 	BCDEHLP			;опхаюбхкх еые пюг х онксвхкх мнлеп яейрнпю мювюкю ROOT дхпш

REALSE1:
		LD 	HL,0FFFEh
		EX 	DE,HL
		ADD 	HL,DE
		EX 	DE,HL
		INC 	HL
		ADC 	HL,BC			;HLDE=мнлеп йкюярепю-2
		LD 	A,(BYTSSEC)		;мсфмн слмнфхрэ мю пюглеп йкюярепю
		JP 	REALSE2

REALSE3:
		SLA 	E
		RL 	D
		RL	L
		RL 	H
REALSE2:
		RRCA
		JP 	NC,REALSE3		;слмнфхкх мю пюглеп йкюярепю
		LD 	B,H
		LD 	C,L
		LD 	HL,STARTRZ
		CALL 	BCDEHLP			;опхаюбхкх ялеыемхе нр мювюкю дхяйю
		LD 	HL,FRSTDAT
		JP 	BCDEHLP			;опхаюбхкх ялеыемхе нр мювюкю пюгдекю

;BCDE=BCDE/512
BCDE200:
		LD 	E,D
		LD 	D,C
		LD 	C,B
		LD 	B,0
		LD 	A,2
		JP 	BCDE_A

;BCDE>>A=BCDE
BCDE_A1:
		SRL 	B
		RR 	C
		RR 	D
		RR 	E
BCDE_A:
		RRCA
		JP 	NC,BCDE_A1
		RET

;(ADR)-BCDE=BCDE
BCDEHLM:
		LD 	A,(HL)
		INC 	HL
		SUB 	E
		LD 	E,A
		LD 	A,(HL)
		INC 	HL
		SBC 	A,D
		LD 	D,A
		LD 	A,(HL)
		INC 	HL
		SBC 	A,C
		LD 	C,A
		LD 	A,(HL)
		SBC 	A,B
		LD 	B,A
		RET

;(ADR)+BCDE=BCDE
BCDEHLP:
		LD 	A,(HL)
		INC 	HL
		ADD 	A,E
		LD 	E,A
		LD 	A,(HL)
		INC 	HL
		ADC 	A,D
		LD 	D,A
		LD 	A,(HL)
		INC 	HL
		ADC 	A,C
		LD 	C,A
		LD 	A,(HL)
		ADC 	A,B
		LD 	B,A
		RET

;BCDE-(ADR)=BCDE
HLBCDEM:
		LD 	A,E
		SUB 	(HL)
		INC 	HL
		LD 	E,A
		LD 	A,D
		SBC 	A,(HL)
		INC 	HL
		LD 	D,A
		LD 	A,C
		SBC 	A,(HL)
		INC 	HL
		LD 	C,A
		LD 	A,B
		SBC 	A,(HL)
		LD 	B,A
		RET

;HLDE+BC=HLDE
HLDEPBC:
		EX 	DE,HL
		ADD 	HL,BC
		EX 	DE,HL
		LD 	BC,0
		ADC 	HL,BC
		RET

;цпсгхкйю ндмнцн яейрнпю
LOADLST:
		LD 	HL,BUF_512_		;юдпея астепю яейрнпю
		LD 	A,1			;цпсгхрэ 1 яейрнп
		CALL 	RDMULTI			;гюцпсгхкх яейрнп
		LD 	HL,BUF_512_		;мю бшунде HL=юдпея мювюкю астепю гюцпсфеммнцн яейрнпю
		RET

;ондювю йнлюмдш б SD йюпрс аег оюпюлерпнб
OUTCOM:
		PUSH 	BC
		LD 	BC,0600h + P_DATA	;бшдюрэ б онпр 6 аюир
		OTIR
		POP 	BC
		RET

;бшдювю б онпр SD йюпрш йнлюмдш я оюпюлерпнл 0
OUT_COM:
		PUSH 	BC
		LD 	BC,P_DATA
		OUT 	(C),A		;нропюбхкх йнд йнлюмдш
		XOR 	A
		OUT 	(C),A		;ахрш 31-24 оюпюлерпю
		NOP
		OUT 	(C),A		;ахрш 23-16 оюпюлерпю
		NOP
		OUT 	(C),A		;ахрш 15-8 оюпюлерпю
		NOP
		OUT 	(C),A		;ахрш 7-0 оюпюлерпю
		DEC 	A
		OUT 	(C),A		;аег CRC16
		POP 	BC
		RET

SECM200:
		PUSH 	HL
		PUSH 	BC
		LD 	A,CMD_58
		CALL 	OUT_COM
		CALL 	IN_OOUT
		LD 	BC,P_DATA
		IN 	H,(C)
		NOP
		IN 	A,(C)
		NOP
		IN 	A,(C)
		NOP
		IN 	A,(C)
		BIT 	6,H
		POP 	HL
		JP 	NZ,SECN200
		EX 	DE,HL
		ADD 	HL,HL
		EX 	DE,HL
		ADC 	HL,HL
		LD 	H,L
		LD 	L,D
		LD 	D,E
		LD 	E,0
SECN200:
		LD 	A,CMD_18
		LD 	C,P_DATA
		OUT 	(C),A
		NOP
		OUT 	(C),H
		NOP
		OUT 	(C),L
		NOP
		OUT 	(C),D
		NOP
		OUT 	(C),E
		LD 	A,0FFh
		OUT 	(C),A
		POP 	HL
		RET

IN_OOUT:
		PUSH 	DE
		LD 	DE,04FFh
IN_WAIT:
		IN 	A,(P_DATA)
		CP 	E
		JP 	NZ,IN_EXIT
IN_NEXT:
		DEC 	D
		JP 	NZ,IN_WAIT
IN_EXIT:
		POP 	DE
		RET

CMD00:
		DB 	40h,00h,00h,00h,00h,95h		;GO_IDLE_STATE
CMD08:
		DB 	48h,00h,00h,01h,0AAh,87h	;SEND_IF_COND
CMD16:
		DB 	50h,00h,00h,02h,00h,0FFh	;SET_BLOCKEN

;лмнцн яейрнпмне времхе я SD йюпрш
RDMULTI:
		EX 	AF,AF'
		CALL 	SECM200
		EX 	AF,AF'
		LD 	BC,P_DATA
RDMULT1:
		EX 	AF,AF'
RDMULT2:
		CALL 	IN_OOUT
		CP 	0FEh
		JP 	NZ,RDMULT2
		INIR
		NOP
		INIR
		NOP
		IN 	A,(C)
		NOP
		IN 	A,(C)
		EX 	AF,AF'
		DEC 	A
		JP 	NZ,RDMULT1
		LD 	A,CMD_12
		CALL 	OUT_COM
SDCard_start_08:
		CALL 	IN_OOUT
		INC 	A
		JP 	NZ,SDCard_start_08
		RET

;бшанпйю мнлепю йкюярепю хг тюикнбнцн нохяюрекъ
RD_CLAS:
		EX 	DE,HL
		LD 	DE,14h		;ярюпьхе 16 ахр вхрюел хг ялеыемхъ +20
		ADD 	HL,DE
		LD 	C,(HL)
		INC 	HL
		LD 	B,(HL)
		LD 	E,5			;лкюдьхе 16 ахр вхрюел хг ялеыемхъ +26
		ADD 	HL,DE
		LD 	E,(HL)
		INC 	HL
		LD 	D,(HL)
		INC 	HL
		RET

;опнбепйю он люяйе
COMPARE:
		LD 	DE,FB_EXT
		LD 	B,0Bh
SDCard_start_09:
		LD 	A,(DE)
		CP 	(HL)
		RET 	NZ
		INC 	HL
		INC 	DE
		DJNZ 	SDCard_start_09
		RET

;пюяоюйнбыхй осрх й тюикс
FNDBUF:
		
		LD 	BC,0802h
		LD 	DE,FB_EXT
FNDBUF4:
		LD 	A,(HL)
		INC 	HL
		CP 	2Eh
		JR 	Z,FNDBUF2
		CP 	5Ch
		JR 	Z,FNDBUF5
		LD 	(DE),A
		INC 	DE
		DJNZ 	FNDBUF4
		LD 	A,(HL)
		AND 	A
		RET 	Z
		INC 	HL
		JR 	FNDBUF3

FNDBUF5:
		LD 	A,C
		AND 	A
		RET 	Z
FNDBUF2:
		LD 	A,B
		AND 	A
		JR 	Z,FNDBUF3
		LD 	A,20h
SDCard_start_0A:
		LD 	(DE),A
		INC 	DE
		DJNZ 	SDCard_start_0A
FNDBUF3:
		LD 	B,3
		DEC 	C
		DEC 	HL
		LD 	A,(HL)
		CP 	5Ch
		JR 	Z,FNDBUF4
		INC 	HL
		JR 	FNDBUF4
;-------------------------------------------------------------------
; НОХЯЮМХЕ: оЕПЕЛЕММШЕ
;---------------------------------------------------------------------
TDIRCLS:
		ds 	1024				;0X400 астеп йкюярепнб ROOT дхпейрнпхх
BUF_512_:
		ds	512				;0X200 астеп яейрнпю
CAL_FAT:
		ds	1				;1 йюкхап FAT
BYTSSEC:
		ds 	1				;1 йнкхвеярбн яейрнпнб б йкюярепе
ROOTCLS:
		ds 	4				;4 яейрнп мювюкю ROOT дхпейрнпхх
ROOTSEC:
		ds 	2				;2 пюглеп б яейрнпюу ROOT дхпейрнпхх
SEC_FAT:
		ds 	4				;4 йнкхвеярбн яейрнпнб ндмни FAT
RSVDSEC:
		ds 	2				;2 пюглеп пегепбмни накюярх
STARTRZ:
		ds 	4				;4 мювюкн дхяйю/пюгдекю
FRSTDAT:
		ds 	4				;4 юдпея оепбнцн яейрнпю дюммшу нр BPB
SEC_DSC:
		ds 	4				;4 йнкхвеярбн яейрнпнб мю дхяйе/пюгдеке
CLS_DSC:
		ds 	4				;4 йнкхвеярбн йкюярепнб мю дхяйе/пюгдеке
FATSTR:
		ds 	4				;4 мювюкн оепбни FAT рюакхжш
FB_EXT:
		ds 	11				;B астеп 8.3 дкъ онхяйю хлемх
ADRPATH:
		ds 	2				;2 юдпея осрх й хлемх тюикю
ADR_LD:
		ds 	2				;2 юдпея гюцпсгйх
NUM_CLS_HIGH:
		ds 	2				;2 МНЛЕП ЙКЮЯРЕПЮ ЯРЮПЬЕЕ ЯКНБН
NUM_CLS_LOW:
		ds 	2				;2 МНЛЕП ЙКЮЯРЕПЮ ЛКЮДЬЕЕ ЯКНБН
NUM_CLS_ST:
		ds 	1				;1 ЯЛЕЫЕМХЕ Б ТЮИКЕ
