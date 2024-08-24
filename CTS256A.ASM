;** TMS-7000(tm) DISASSEMBLER V1.10beta3 - (c) 2015-20 GmEsoft, All rights reserved. **
;
;	Tue Dec 27 08:39:46 2022
;
;	Disassembly of : CTS256A.BIN
;	Equates file   : CTS256A.EQU
;	Screening file : CTS256A.SCR


;==============================================================================

; registers used by the text-to-speech code in the masked ROM...
REGA	EQU	R0			; A register
XREGA	EQU	>0000			; A register long address
REGB	EQU	R1			; B register
XREGB	EQU	>0001			; B register long address
INRDH	EQU	R2			; input buffer read pointer MSB
INRDL	EQU	R3			; input buffer read pointer LSB
INRD	EQU	R3			; input buffer read pointer
INWRH	EQU	R4			; input buffer write pointer MSB
INWRL	EQU	R5			; input buffer write pointer LSB
INWR	EQU	R5			; input buffer write pointer
OUTRDH	EQU	R6			; output buffer read pointer MSB
OUTRDL	EQU	R7			; output buffer read pointer LSB
OUTRD	EQU	R7			; output buffer read pointer
OUTWRH	EQU	R8			; output buffer write pointer MSB
OUTWRL	EQU	R9			; output buffer write pointer LSB
OUTWR	EQU	R9			; output buffer write pointer
FLAGS1	EQU	R10			; flags 1
FLAGS2	EQU	R11			; flags 2
BUFPTRH	EQU	R12			; buffer pointer MSB
BUFPTRL	EQU	R13			; buffer pointer MSB
BUFPTR	EQU	R13			; buffer pointer pair
XBUFPTR	EQU	>000D			; temp register pair long address
INRDPH	EQU	R14			; next input buffer read pointer MSB
INRDPL	EQU	R15			; next input buffer read pointer LSB
INRDP	EQU	R15			; next input buffer read pointer
INRDBH	EQU	R16			; backward input buffer read pointer MSB
INRDBL	EQU	R17			; backward input buffer read pointer LSB
INRDB	EQU	R17			; backward input buffer read pointer
PEPROMH	EQU	R18			; EPROM scan pointer MSB
PEPROML	EQU	R19			; EPROM scan pointer LSB
PEPROM	EQU	R19			; EPROM scan pointer
INRDLH	EQU	R18			; last input buffer read pointer MSB
INRDLL	EQU	R19			; last input buffer read pointer LSB
INRDLX	EQU	R19			; last input buffer read pointer
RULPTRH	EQU	R20			; Rules pointer MSB
RULPTRL	EQU	R21			; Rules pointer MSB
RULPTR	EQU	R21			; Rules pointer
NXTCHR	EQU	R22			; Next character (-$20 & $3F)
COUNTER	EQU	R23			; Counter (RAM pages or chars)
LSTDLMH	EQU	R24			; last delimiter position MSB
LSTDLML	EQU	R25			; last delimiter position LSB
LSTDELM	EQU	R25			; last delimiter position
ISP0256	EQU	R27			; SP0256 write address
INRDLBH	EQU	R28			; last backward input buffer read pointer MSB
INRDLBL	EQU	R29			; last backward input buffer read pointer LSB
INRDLB	EQU	R29			; last backward input buffer read pointer
INLWMH	EQU	R30			; input buffer low water mark MSB
INLWML	EQU	R31			; input buffer low water mark LSB
INLWMX	EQU	R31			; input buffer low water mark
INHWMH	EQU	R32			; input buffer low water mark MSB
INHWML	EQU	R33			; input buffer low water mark LSB
INHWMX	EQU	R33			; input buffer low water mark
INSTA1H	EQU	R34			; input buffer start - 1 MSB
INSTA1L	EQU	R35			; input buffer start - 1 LSB
INSTA1	EQU	R35			; input buffer start - 1
INENDH	EQU	R36			; input buffer end MSB
INENDL	EQU	R37			; input buffer end LSB
INEND	EQU	R37			; input buffer end
OUTEN1H	EQU	R38			; output buffer end + 1 MSB
OUTEN1L	EQU	R39			; output buffer end + 1 LSB
OUTEND1	EQU	R39			; output buffer end + 1
INSTAH	EQU	R40			; input buffer start MSB
INSTAL	EQU	R41			; input buffer start LSB
INSTA	EQU	R41			; input buffer start
OUTSTAH	EQU	R42			; output buffer start MSB
OUTSTAL	EQU	R43			; output buffer start LSB
OUTSTA	EQU	R43			; output buffer start
PSP0256	EQU	R45			; SP0256 base pointer
PPARINP	EQU	R47			; Parallel input base pointer
JEPROMH	EQU	R48			; EPROM jump vector MSB
JEPROM	EQU	R49			; EPROM jump vector
OUTHWM	EQU	R50			; output buffer high water mark
INFREEH	EQU	R51			; number of free bytes in input buffer MSB
INFREEL	EQU	R52			; number of free bytes in input buffer LSB
INFREE	EQU	R52			; number of free bytes in input buffer
OUTFREH	EQU	R53			; number of free bytes in output buffer MSB
OUTFREL	EQU	R54			; number of free bytes in output buffer LSB
OUTFREE	EQU	R54			; number of free bytes in output buffer
MATCHED	EQU	R55			; matched chars counter
INLENH	EQU	R56			; number of bytes in input buffer MSB
INLENL	EQU	R57			; number of bytes in input buffer LSB
INLEN	EQU	R57			; number of bytes in input buffer

; I/O ports...
IOCNT0	EQU	P0			; I/O Control register 0
APORT	EQU	P4			; Port A
BPORT	EQU	P6			; Port B
IOCNT1	EQU	P16			; I/O Control register 1
SSTAT	EQU	P17			; read - Serial port Status
SMODE	EQU	P17			; 1st write - Serial port Mode
SCTL0	EQU	P17			; 2nd and subsequent writes - Serial port Control register 0
T3DATA	EQU	P20			; Timer 3 Data
SCTL1	EQU	P21			; Serial Control register 1
RXBUF	EQU	P22			; Serial Receive Buffer
TXBUF	EQU	P23			; Serial Transmit Buffer





;==============================================================================

	AORG	>F000

;==============================================================================

	; Main entry point
CTS256	MOV	%>3A,B
	LDSP				; Init stack pointer 3B-XX
	MOVD	%SP0256,PSP0256		; PSP0256 := $2000 - Memory-mapped parallel output to SP0256A-AL2
	MOVP	%>AA,IOCNT0		; IOCNT0 = IOCNT0 := 1010 1010
					; 	Full Expansion;
					;	Clear INT1, INT2 and INT3 flags
	MOVP	%>0A,IOCNT1		; IOCNT1 = IOCNT1 := 0000 1010
					;	Clear INT4 and INT5 flags
	MOVP	APORT,B			; Read APORT = APORT
	AND	%>07,B			; Get Serial mode
	CMP	%>00,B			; Is it Parallel mode?
					; useful?
	; Jump if yes
	JZ	PARALL			; Start in parallel mode
	AND	%>7F,FLAGS1		; Clear FLAGS1.7, indicating serial mode
	MOVP	APORT,A			; Read APORT = APORT
	AND	%>08,A			; Get Selectable Serial Config flag
	CMP	%>00,A			; Is it set?
					; useful?
	; Jump if not
	JZ	SER7N2			; Serial fixed 7N2 config
	LDA	@>1000			; Read serial config from $1000
	MOVP	A,SMODE			; Init P17 = SMODE with serial config
	JMP	SERSEL			; Serial selectable config

SER7N2	MOVP	%>CB,SMODE		; P17 = SMODE := Fixed Serial 7N2 config
SERSEL	MOVP	%>15,SCTL0		; P17 = SCTL0 := OOO1 O1O1
					; Reset error flags; enable RX & TX
	; A := value for SCTL1 (prescaler)
	LDA	@SCT1TB(B)		; Table of values for SCTL1
	PUSH	A
	; A := value for T3DATA (timer3 reload)
	LDA	@T3DATB(B)		; Table of timer3 reload values T3DATA
	POP	B
	MOVP	B,SCTL1			; set SCTL1
	MOVP	A,T3DATA		; set T3DATA
	ORP	%>01,IOCNT1		; enable T4
	; proceed with RAM setup
	JMP	INIRAM			; Init RAM config

	; Table of values for SCTL1
SCT1TB	BYTE	>FF,>40,>43,>40,>43,>40,>40,>40

	; Table of timer3 reload values T3DATA
T3DATB	BYTE	>FF,>20,>57,>07,>C2,>0F,>81,>03

	; Start in parallel mode
PARALL	OR	%>80,FLAGS1		; Set FLAGS1.7, indicating parallel mode
	MOVD	%PARINP,PPARINP		; PPARINP := $0200 parallel input mapped address
	ORP	%>30,IOCNT0		; IOCNT0 = IOCNT0, set .4=enable INT3, .5=clear INT3
	; Init RAM config
INIRAM	MOVP	APORT,B			; B := APORT = APORT
	AND	%>10,B			; test APORT.4 = RAM buffer - 0=internal - 1=external
	CMP	%>00,B			; useful?
	; jump if internal
	JZ	INTRAM			; init internal RAM pointers

	MOVD	%CTSXRAM,INRD		; INRD := base RAM address = $3000
	MOVD	INRD,INSTA		; INSTA := INRD
	PUSH	INRDH
	DEC	INRDH
	MOV	INRDH,INSTA1H		; INSTA1 := INRD - 1 ($2FFF)
	MOV	%>FF,INSTA1L
	ADD	%>02,INRDH		; INRDH += 2 ($31)
	CLR	COUNTER			; COUNTER := 0 (page counter)
	; Init external RAM sizing loop

IRAML0	INC	INRDH			; ++INRDH
	CMP	%>F0,INRDH		; INRDH == $F0 ($F000 reached)?
	; Exit loop if yes
	JZ	IRAMX0
	INC	COUNTER			; ++COUNTER
	CMP	%>10,COUNTER		; COUNTER == $10 (16 pages)?
	; exit loop if yes
	JZ	IRAMX0
	MOV	%>5A,A			; A := $5A (RAM test pattern)
	STA	*INRD			; *INRD := A
	CLR	A			; A := 0 (useful?)
	LDA	*INRD			; A := *INRD
	CMP	%>5A,A			; A == $5A (test pattern)?
	; exit loop if not
	JNZ	IRAMX0
	SWAP	A			; A := $A5 (reverse bits)
	STA	*INRD			; *INRD := A
	CLR	A			; A := 0 (useful?)
	LDA	*INRD			; A := *INRD
	CMP	%>A5,A			; A == $A5 (test pattern)?
	; exit loop if not
	JNZ	IRAMX0
	; Test next RAM page
	JMP	IRAML0

IRAMX0	MOV	INRDH,OUTEN1H		; OUTEND1 := INRDH:$00 (end RAM addr + 1)
	CLR	OUTEN1L			; ATTENTION: page boundary !!
	SUB	%>01,INRDH		; --INRDH (why not DEC INRDH?)
	MOVD	INRD,OUTRD		; OUTRD   := INRD = last RAM page addr (output buffer read ptr)
	MOVD	OUTRD,OUTSTA		; OUTSTA  := OUTRD (output buffer start)
	SUB	%>01,INRDH		; --INRDH (why not DEC INRDH?)
	MOV	INRDH,INENDH		; INEND   := INRDH:$FF (input buffer end)
	MOV	%>FF,INENDL
	POP	INRDH			; INRDH   := $30
	MOV	%>DF,OUTHWM		; OUTHWM  := $DF
	JMP	INIROM			; Init EPROM

	; init internal RAM pointers
INTRAM	MOVD	%>0051,INSTA		; INSTA   := $0051 (input buffer start)
	MOVD	%>0065,INEND		; INEND   := $0065 (input buffer end)
	MOVD	%>0050,INSTA1		; INSTA1  := $0050 (input buffer start - 1)
	MOVD	%>0066,OUTSTA		; OUTSTA  := $0066 (output buffer start)
	MOVD	%>0080,OUTEND1		; OUTEND1 := $0080 (end RAM addr + 1)
	MOVD	INSTA,INRD		; INRD    := $0051 (input buffer read ptr)
	MOVD	OUTSTA,OUTRD		; OUTRD   := $0066 (output buffer read ptr)
	MOV	%>01,OUTHWM		; OUTHWM  := $01   (output high water mark)

	; Init EPROM
INIROM	MOVD	%>0000,PEPROM		; PEPROM := 0
LF0DA	CLR	B			; B := 0 (5 signature bytes counter/index)
	ADD	%>10,PEPROMH		; ++PEPROMH (next page, starting at $1000)
	CMP	%>F0,PEPROMH		; $F0 reached? (ending at $F000)
	; Jump if yes
	JZ	INITOK			; Done peripherals init
LF0E3	LDA	*PEPROM			; Read signature byte
	; and compare it to the 5 first letters flags $80,$48,$28,$58,$85
	CMPA	@LTFLGS(B)		; Letter flags
	; next page if mismatch
	JNZ	LF0DA
	INC	B			; next test byte
	CMP	%>05,B			; done 5 bytes
	; Exit if yes => EPROM found
	JZ	STAROM			; Boot in EPROM
	INC	PEPROML			; next EPROM byte
	JMP	LF0E3			; loop

	; Boot in EPROM
STAROM	INC	PEPROML			; point to 1st byte following sig bytes
	MOVD	PEPROM,JEPROM		; JEPROM := PEPROM = EPROM entry point
	BR	*JEPROM			; Boot in EPROM

	; Done peripherals init
INITOK	MOV	%>00,JEPROMH		; JEPROMH := 0 (EPROM not present)
	CALL	@INIPTR			; Init buffer pointers and regs
	CALL	@SAYOK			; Say O.K.
	JMP	LF110

;==============================================================================

	; Polling loop
POLL	BTJO	%>01,FLAGS2,LF110	; test FLAGS2.0 = any delimiter; jump if yes
	AND	%>EF,FLAGS2		; reset FLAGS2.4 (found delimiter?)

	; Idle loop (wait interrupt?)
WTIDLE	BTJZ	%>10,FLAGS2,WTIDLE	; Idle loop (wait FLAGS2.4)
LF110	CMP	INRDL,INWRL		; Input buffer read ptr LSB != write ptr LSB?
	JNZ	ENDPOL			; Exit polling loop if yes
	CMP	INRDH,INWRH		; Idem for MSB?
	JNZ	ENDPOL			; Exit polling loop if yes
	JMP	POLL			; Polling loop

	; Exit polling loop
ENDPOL	CMP	%>00,INLENH		; Chars in buffer MSB
	JNZ	LF126			; exit ENDPOL loop if != 0
	CMP	%>00,INLENL		; Chars in buffer LSB
	JZ	ENDPOL			; loop if == 0

	; Exit ENDPOL loop
LF126	BTJZ	%>08,FLAGS2,LF133	; FLAGS2.3 == 1 (output buffer full or too high)? Jump if not
	CMP	%>01,OUTHWM		; Internal RAM?
	; jump if yes
	JZ	CLBUF1			; Clear buffers if yes

	; wait reset of bit 3 of FLAGS2
W11B3	BTJO	%>08,FLAGS2,W11B3	; wait reset of bit 3 of FLAGS2 (output buffer low enough)
LF133	CALL	@ENCODE			; Encode text to allophones
	CMP	OUTRDL,OUTWRL		; Output buffer empty?
	JZ	LF110			; jump to input buffer polling loop if yes
	ORP	%>01,IOCNT0		; enable INT1* (SP0256) to send output
	JMP	LF110			; jump to input buffer polling loop

	; Clear buffers
CLBUF1	BR	@CLBUF			; clear buffers - reinit

;==============================================================================

	; Init buffer pointers and regs
INIPTR	AND	%>00,FLAGS2		; FLAGS2  := 0 (why not CLR FLAGS2?)
	CLR	MATCHED			; MATCHED := 0 (matched chars to discard)
	CLR	INLENH			; INLENH  := 0
	CLR	INLENL			; INLENL  := 0
	ORP	%>01,BPORT		; set BPORT.0 (DSR/BUSY)
	MOVD	INSTA,INRD		; INRD    := INSTA (input buffer start)
	MOVD	OUTSTA,OUTRD		; OUTRD   := OUTSTA (output buffer start)
	MOV	%>20,A			; A       := $20
	STA	*INRD			; *INRD   := $20 (input buffer read ptr)
	CALL	@INCINRD		; inc INRD and roll to INSTA if == OUTSTA
	MOVD	INRD,INWR		; INWR := INRD (input buffer write ptr)
	PUSH	INRDL			; save pointers
	PUSH	OUTRDL
	PUSH	OUTRDH
	DEC	INRDL			; OUTRD := ( OUTRD - INRD + 1 ) = input buffer size
	SUB	INRDL,OUTRDL
	SBB	INRDH,OUTRDH
	MOVD	OUTRD,INFREE		; INFREE := input buffer size - 1
	DECD	INFREE
	TSTA				; = CLR C
	RRC	OUTRDH			; OUTRD /= 2
	RRC	OUTRDL
	MOVD	OUTRD,INLWMX		; INLWMX := buffer size / 2 (and clears C)
	RRC	OUTRDH			; OUTRD /= 2
	RRC	OUTRDL
	TSTA				; = CLR C
	RRC	OUTRDH			; OUTRD /= 2
	RRC	OUTRDL
	MOVD	OUTRD,INHWMX		; INHWMX := buffer size / 8
	POP	OUTRDH			; restore pointers
	POP	OUTRDL
	POP	INRDL
	MOVD	OUTRD,OUTWR		; OUTWR := OUTRD = output buffer write ptr
	MOVD	INRD,LSTDELM		; LSTDELM last delimiter ptr := INRD input buffer read ptr
	MOVD	OUTEND1,OUTFREE		; OUTFREE := OUTEND1 = end RAM address + 1
	SUB	OUTSTAL,OUTFREE		; OUTFREE := ( OUTFREE - OUTSTA ) = output buffer size
	SBB	OUTSTAH,OUTFREH
	MOVP	APORT,B			; B := APORT
	AND	%>80,B			; APORT.7 set? (Delimiter=any)
	CMP	%>00,B			; useful?
	; Jump if not
	JZ	LF1A6
	OR	%>01,FLAGS2		; FLAGS2.0 := 1 if any delimiter
LF1A6	EINT				; enable interrupts
	RETS

;==============================================================================

	; "O-K\n"
STROK	TEXT	'O-K'
	BYTE	>0D

	; Say O.K.
AUDIBLE					; from datasheet
SAYOK	AND	%>F9,FLAGS1		; Clear FLAGS1.1 and FLAGS1.2: Write to input buffer
	CLR	B
LF1B0	LDA	@STROK(B)		; Get char
	CALL	@STINPB			; Store char in input buffer
	INC	B			; next char
	CMP	%>04,B			; loop until 4 chars processed
	JNZ	LF1B0
	RETS				; return

;==============================================================================

	; INT4 handler (serial interrupt)
INT4	BTJOP	%>02,SSTAT,INT3		; Jump if P17.1 (RXRDY) == 1
	RETI				; else return from interrupt

	; INT3 handler (parallel interrupt)
INT3	PUSH	A			; save A from interrupt
	BTJO	%>80,FLAGS1,LF1D1	; FLAGS1.7 (parallel mode) == 1? Jump if yes
	ANDP	%>FE,IOCNT1		; Reset IOCNT1.0 (disable serial INT4)
	; wait RXBUF ready with new character
WRXRDY	BTJZP	%>02,SSTAT,WRXRDY	; wait RXBUF ready with new character
	MOVP	RXBUF,A			; get A := RXBUF incoming character
	JMP	LF1D6			; handle incoming char in A

	; Parallel mode
LF1D1	ANDP	%>EF,IOCNT0		; Disable IOCNT0.0 = INT3*
	LDA	*PPARINP		; Read char from parallel input ($0200)

	; Handle incoming char
LF1D6	CALL	@STINPB			; Store char in input buffer
	POP	A			; restore A from interrupt
	BTJO	%>20,FLAGS2,LF1E1	; FLAGS2.5 == 1? (input buffer full) skip next instr if yes
	CALL	@ENINT			; re-enable parallel or serial interrupt
LF1E1	RETI				; return from interrupt

;==============================================================================

	; Store char in input buffer
STINPB	PUSH	B			; Save registers
	PUSH	FLAGS1
	PUSH	BUFPTRH
	PUSH	BUFPTRL
	AND	%>F9,FLAGS1		; reset FLAGS1.1 and FLAGS1.2: write to input buffer
	CMP	%>1B,A			; <ESC>? => clear buffers
	JNZ	NOTESC			; Skip if not

	; clear buffers - reinit
CLBUF	ANDP	%>FE,IOCNT0		; Disable INT1* (SP0256)
	CALL	@INIPTR			; Init buffer pointers and regs
	MOV	%>3A,B			; Init SP
	LDSP				;
	MOVD	PSP0256,ISP0256		; R26:27 := R44:45  (SP0256 device)
	STA	*ISP0256		; *R26:27 := A  (SP0256 device)
	CALL	@ENINT			; Enable input interrupt (parallel or serial)
	BR	@POLL			; Polling loop

	; Not <ESC>
NOTESC	CMP	%>12,A			; <Ctrl-R>? => backspace until last delimiter
	JNZ	NOTCTR			; Skip if not

	; Handle <Ctrl-R>
	BTJO	%>01,FLAGS2,LF21E	; FLAGS2.0 == 1 (any delimiter)? Exit if yes
	SUB	LSTDLML,INRDL		; INRD (input buf read ptr) -= LSTDELM (last delimiter)
	SBB	LSTDLMH,INRDH		;	(may not work correctly if rolled...)
	SUB	INRDL,INFREEL		; INFREE (input buffer free size) -= INRD
	SBB	INRDH,INFREEH
	MOVD	LSTDELM,INRD		; INRD := LSTDELM (last delimiter position)
	MOV	%>01,INLENL		; input buffer counter LSB(why?) := 1
LF21E	BR	@XSTINP			; exit handler

	; Not <Ctrl-R>
NOTCTR	CMP	%>08,A			; <BkSp>?
	JNZ	NOTBKS			; Skip if not

	; Handle <BkSp>
	CMP	INRDH,INWRH		; Input buffer pointers equal?
	JNZ	LF22F
	CMP	INRDL,INWRL
	JZ	XSTINP			; If yes, exit handler
LF22F	PUSH	INRDL			; Save INRD
	PUSH	INRDH
	MOVD	INWR,INRD		; INRD := INWR input buffer write ptr
	CALL	@DECINRD		; dec INRD and roll if needed
	MOVD	INRD,INWR		; INWR := INRD
	POP	INRDH			; restore INRD
	POP	INRDL
	INC	INFREEL			; Inc INFREE input buffer free size
	JNC	XSTINP
	INC	INFREEH
	JMP	XSTINP			; exit handler

	; Not <BkSp>: Handle other chars
NOTBKS	CMP	%>27,A			; '''?
	JZ	STOCHR			; Jump if yes
	CMP	%>7B,A			; higher than 'z'?
	JP	DELIMT			; Jump if yes
	CMP	%>30,A			; '0'..'9'?
	JN	DELIMT
	CMP	%>3A,A
	JN	STOCHR
	CMP	%>41,A			; >= 'A'?
	JPZ	STOCHR

	; Delimiter (not letter/digit/')
DELIMT	BTJO	%>01,FLAGS2,LF267	; FLAGS2.0 set (any delimiter)? Jump if yes
	CMP	%>0D,A			; <CR>?
	JNZ	LF26A			; skip if not
	OR	%>10,FLAGS2		; FLAGS2.4 := 1 (found CR => exit idle loop)
LF267	MOVD	INRD,LSTDELM		; LSTDELM := INRD (last delimiter position)
LF26A	OR	%>80,A			; A.7 := 1 (set high bit) if delimiter
	INC	INLENL			; Increment INFREE (# of bytes in input buffer)
	JNC	STOCHR			; put char in buffer
	INC	INLENH

	; put char in buffer
STOCHR	CALL	@RWBUFR			; write char in buffer
	BTJZ	%>20,FLAGS2,XSTINP	; FLAGS2.5 set (inp buffer full)? if not exit handler
	MOV	%>8D,A			; A := <CR> + $80
	INC	INLENL			; Increment INFREE (# of bytes in input buffer)
	JNC	DINC1
	INC	INLENH
DINC1	CALL	@RWBUFR			; write char in buffer
	; exit handler
XSTINP	POP	BUFPTRL			; Restore registers
	POP	BUFPTRH
	POP	FLAGS1
	POP	B
	RETS				; end of input char handling

;==============================================================================

	; FLAGS1:7 ? (enable INT3) : (enable INT4)
ENINT	BTJZ	%>80,FLAGS1,ENINT4	; enable INT4
	ORP	%>10,IOCNT0
	RETS

	; enable INT4
ENINT4	ORP	%>01,IOCNT1
	RETS

;==============================================================================

	; select input or output buffer and read/store byte in it
RWBUFR	BTJO	%>02,FLAGS1,RDBUF	; FLAGS1.1 set? Jump if yes (read from either buffer)

	; write to input or output buffer
	BTJO	%>04,FLAGS1,WROBUF	; FLAGS1.2 set? Jump if yes (output buffer)

	; write to input buffer
	MOVD	INWR,BUFPTR		; BUFPTR := INWR input buffer write ptr
	DECD	INFREE			; Decrement # of free input buffer bytes
	JMP	WRBUF			; Store A in buffer

	; write to output buffer
WROBUF	MOVD	OUTWR,BUFPTR		; BUFPTR := OUTWR output buffer write ptr
	DECD	OUTFREE			; Decr output buffer free size

	; Write byte A to buffer
WRBUF	STA	*BUFPTR			; *BUFPTR := A (store byte in buffer)
	LDA	@XBUFPTR		; A := BUFPTR (why using LDA?)
	ADD	%>01,BUFPTRL		; Increment BUFPTR
	ADC	%>00,BUFPTRH
	CALL	@ROLBUFP		; Roll BUFPTR if needed
	BTJO	%>04,FLAGS1,WOBUFX	; FLAGS1.2 set? Jump if yes (output buffer)
	MOVD	BUFPTR,INWR		; INWR := BUFPTR (inp buffer write ptr)
WRBUFX	CALL	@CHKBUF			; Check if inp or out buffer full or above HWM
	RETS				; return

WOBUFX	MOVD	BUFPTR,OUTWR		; OUTWR := BUFPTR (out buffer write ptr)
	JMP	WRBUFX			; Check buffer and return

	; read from input or output buffer
RDBUF	BTJO	%>04,FLAGS1,RDOBUF	; FLAGS1.2 set? jump if yes (output buffer)

	; read from input buffer
	MOVD	INRD,BUFPTR		; BUFPTR := INRD input buffer read ptr
	BTJO	%>02,FLAGS2,RDBUF1	; FLAGS2.1 set? Jump if yes
	INC	MATCHED			; inc MATCHED if not... (matched chars to discard)
	JMP	RDBUF1			; Read byte

	; read from output buffer
RDOBUF	MOVD	OUTRD,BUFPTR		; BUFPTR := OUTRD out buffer read ptr
	INC	OUTFREL			; Inc OUTFREE = Out free bytes? (TODO: clarify)
	JNC	RDBUF1
	INC	OUTFREH

	; Read A from buffer
RDBUF1	LDA	*BUFPTR			; Read byte
	BTJO	%>04,FLAGS1,LF2F3	; FLAGS1.2 set? jump if yes (out buffer)

	BTJZ	%>80,A,LF2F0		; Is high bit set? Jump if not
	OR	%>01,FLAGS1		; FLAGS1.0 := A.7 = char high bit = delimiter flag
	JMP	LF2F3

LF2F0	AND	%>FE,FLAGS1		; clear FLAGS1.0 = delimiter flag

	; Incr buffer read pointer
LF2F3	PUSH	A
	LDA	@XBUFPTR		; A := BUFPTR (why?)
	ADD	%>01,BUFPTRL		; increment BUFPTR
	ADC	%>00,BUFPTRH
	CALL	@ROLBUFP		; Roll if needed
	BTJO	%>04,FLAGS1,ROBUFX	; jump if output buffer

	; update input buffer read ptr
	MOVD	BUFPTR,INRD		; INRD := BUFPTR
	POP	A			; restore character
	RETS				; return

	; update output buffer read ptr
ROBUFX	MOVD	BUFPTR,OUTRD		; OUTRD := BUFPTR
	CALL	@CKOBUF			; Check if output buffer full or above HWM
	POP	A			; restore allophone
	RETS

;==============================================================================

	; Roll BUFPTR according to active buffer (FLAGS1.2)
	; - if FLAGS1.2 set (output buffer active):
	;	to OUTSTA (out buffer start) if reached OUTEND1 (out buffer end)
	; - if FLAGS1.2 not set (input buffer active):
	;	to INSTA (in buffer start)  if reached OUTSTA (in buffer end)
ROLBUFP	BTJO	%>04,FLAGS1,ROLOUT	; Roll output buffer
	; Roll input buffer
ROLINP	CMP	OUTSTAL,BUFPTRL
	JNZ	LF322
	CMP	OUTSTAH,BUFPTRH
	JNZ	LF322
	MOVD	INSTA,BUFPTR
LF322	RETS

	; Roll output buffer
ROLOUT	CMP	OUTEN1L,BUFPTRL
	JNZ	LF330
	CMP	OUTEN1H,BUFPTRH
	JNZ	LF330
	MOVD	OUTSTA,BUFPTR
LF330	RETS

;==============================================================================

	; Check if inp or out buffer full or above HWM
CHKBUF	BTJZ	%>04,FLAGS1,CKIBUF	; Send XON/XOFF if needed

	; Check if output buffer full or above high water mark
CKOBUF	CMP	%>01,OUTFREH		; Only 1 free byte in output buffer?
	JZ	LF343			; jump if yes
	CMP	OUTHWM,OUTFREL		; OUTFREE > OUTHWM? (output counter >= HWM?)
	JP	LF343			; jump if yes
	OR	%>08,FLAGS2		; set FLAGS2.3 (output buffer full)
	RETS

LF343	AND	%>F7,FLAGS2		; reset FLAGS2.3 (output buffer not full)
	RETS

	; Check if input buffer full or above high water mark
CKIBUF	CMP	%>00,INFREEH		; Free bytes in input buffer?
	JP	LF356			; jump if yes
	CMP	%>01,INFREEL
	JP	LF356
	OR	%>20,FLAGS2		; set FLAGS2.5 (input buffer full)
	JMP	TXOFF			; Send XOFF, clear DTR/BUSY*

	; Input buffer not full
LF356	CMP	INLWMH,INFREEH		; INFREE inp buf free bytes < 1/2 size?
	JN	LF362			; Jump if yes
	JP	TXON			; Else send XON, set DTR/BUSY*
	CMP	INLWML,INFREEL
	JPZ	TXON
LF362	CMP	INHWMH,INFREEH		; INFREE inp buf free bytes < 1/8 size?
	JP	LF384			; Jump if not
	JN	LF36E			; Else Send XOFF, clear DTR/BUSY*
	CMP	INHWML,INFREEL
	JP	LF384

LF36E	OR	%>04,FLAGS2		; set FLAGS2.2: input buffer above HWM

	; Send XOFF, clear DTR/BUSY*
TXOFF	ANDP	%>FE,BPORT		; clear BPORT.0 (DSR/BUSY=true)
	MOVP	%>13,TXBUF		; TXBUF := XOFF
	RETS

	; Send XON, set DTR/BUSY*
TXON	AND	%>DB,FLAGS2
	CALL	@ENINT			; FLAGS1:7 = parallel mode ? (enable INT3) : (enable INT4)
	ORP	%>01,BPORT		; set BPORT.0 (DSR/BUSY=false)
	MOVP	%>11,TXBUF		; TXBUF := XON
LF384	RETS				; Return

;==============================================================================

	; INT1 handler (SP0256)
INT1	ANDP	%>FE,IOCNT0		; Disable IOCNT0.0 = INT1*
	PUSH	A			; save regs
	PUSH	B
	PUSH	FLAGS1
	PUSH	BUFPTRH
	PUSH	BUFPTRL
	OR	%>06,FLAGS1		; select "read from output buffer"
	CALL	@RWBUFR			; do the read
	MOVD	PSP0256,ISP0256		; ISP0256 := PSP0256 SP0256 base address
	ADD	REGA,ISP0256		; Add allophone code to the address
	STA	*ISP0256		; Write any byte to that address (value doesn't care)
	POP	BUFPTRL			; restore regs
	POP	BUFPTRH
	POP	FLAGS1
	POP	B
	POP	A
	CMP	OUTRDL,OUTWRL		; Buffer empty?
	JZ	LF3AE			; skip if yes
	ORP	%>01,IOCNT0		; else enable IOCNT0.0 = INT1*
LF3AE	RETI				; return from interrupt

;==============================================================================

	; select rules set
SELRUL	CMP	%>30,A			; A >='0'?
	JPZ	SELRUL1			; jump if yes
	JMP	SELPCT			; < '0' => rules for punctuation

SELRUL1	CMP	%>3A,A			; A >='9'+1?
	JPZ	SELRUL2			; jump if yes
	MOVD	%RULNUM,RULPTR		; select rules for digits
	AND	%>DF,FLAGS1		; Non-letters rules
	RETS				; done

SELRUL2	CMP	%>41,A			; A >='A'?
	JPZ	SELRUL3			; jump if yes
	JMP	SELPCT			; < 'A' => rules for punctuation

SELRUL3	CMP	%>5B,A			; A >='Z'+1?
	JPZ	SELRUL4			; jump if yes
	OR	%>20,FLAGS1		; Letters rules
	RETS

SELRUL4	CMP	%>61,A			; A >='a'?
	JPZ	SELRUL5			; jump if yes
	JMP	SELPCT			; < 'a' => rules for punctuation

SELRUL5	CMP	%>7B,A			; A >='z'+1?
	JPZ	SELPCT			; jump if yes
	SUB	%>20,A			; A -= $20 (convert to upper case)
	OR	%>20,FLAGS1		; Letters rules
	RETS				; done

SELPCT	AND	%>DF,FLAGS1		; Non-letters rules
	MOVD	%RLPNCT,RULPTR		; Rules for punctuation
	RETS

;==============================================================================

	; Encode text to allophones
ENCODE	CMP	%>00,JEPROMH		; EPROM active?
	; Skip if not
	JZ	ENCODE1
	BR	*JEPROM			; Jump in EPROM

ENCODE1	MOVD	INRD,INRDB		; INRDB := INRD (backward input buffer read ptr)
	CALL	@DECINRB		; dec INRDB and roll if needed

	; Main encoder loop
ENCODL1	CALL	@FETCH			; Fetch char and mask high bit
	BTJZ	%>01,FLAGS1,ENCODE2	; FLAGS2.7 := FLAGS1.0 (delimiter flag)
	OR	%>80,FLAGS2
	JMP	ENCODE3

ENCODE2	AND	%>7F,FLAGS2
ENCODE3	CALL	@SELRUL			; select rules set
	BTJZ	%>20,FLAGS1,ENCODE4	; FLAGS1.5 set (rules for letters)? jump if no

	CLR	B			; useful?
	SUB	%>41,A			; A -= 'A'
	MPY	%>02,A			; AB := A * 2
	ADD	%>02,B			; B += 2
	LDA	@TABRUL(B)		; Index of rules tables
	MOV	A,RULPTRH		; RULPTRH := MSB of letter rules table
	LDA	@TABRU1(B)		; Index of rules tables LSB
	MOV	A,RULPTRL		; RULPTRL := LSB of letter rules table

ENCODE4	MOV	%>01,B			; B := 1 (number of '[') to seek
	CALL	@RSEEKB			; right seek 1st '['

	; Loop 2: Compare chars between [ ]
ENCODL2	CALL	@CMPBKT			; compare in-brackets
	BTJO	%>10,FLAGS1,ENCODF1	; FLAGS1.4 set (match failed)? Jump if yes

	; Check patterns after ]
	MOVD	INRDB,INRDLB		; INRDLB := INRDB (save backward input buffer read ptr)
	AND	%>BF,FLAGS1		; clear FLAGS1.6 (read input using INRD)
	CALL	@CHKPAT			; Check rule pattern
	BTJO	%>10,FLAGS1,ENCODF1	; FLAGS1.4 set (match failed)? Jump if yes

	; Check patterns before [
	CALL	@LSEEKB			; left seek '['
	OR	%>40,FLAGS1		; set FLAGS1.6 (read input using INRDB)
	CALL	@CHKPAT			; Check rule pattern
	BTJO	%>10,FLAGS1,ENCODF2	; FLAGS1.4 set (match failed)? Jump if yes

	; Matching Rule found
	ADD	MATCHED,INFREEL		; INFREE += MATCHED (discard preceding chars)
	ADC	%>00,INFREEH
	CLR	MATCHED			; no more chars to discard

	; Seek allophones to output
	AND	%>FD,FLAGS2		; clear FLAGS2.1 (allow to count chars to discard in MATCHED)
	MOV	%>02,B			; B := 2 (number of '[') to seek
	CALL	@RSEEKB			; right seek 2nd '[' => 1st allophone

	; Write allophones
	CALL	@WRALLO			; Write allophones

	; Next input character
	MOVD	INRDP,INRD		; INRD := INRDP - restore input buffer read ptr
	MOVD	INRD,INRDB		; INRDB := INRD - copy to backward input buffer read ptr
	CALL	@DECINRB		; dec INRDB and roll to INEND if == INSTA1
	BTJZ	%>80,FLAGS2,ENCODL1	; High bit of char was set (delimiter)? Jump if not

	; Finalize and return
	DECD	INLEN			; dec INFREE (number of bytes in input buffer?)
	CALL	@CKIBUF			; Check if input buffer full or above high water mark
	RETS				; return

	; Match failed after opening [ => seek next rule
ENCODF1	INC	RULPTRL			; inc RULPTR rule pointer
	JNC	DINC2
	INC	RULPTRH
DINC2	MOV	%>02,B			; B := 2 (number of '[') to seek

	; Loop: Seek next rule opening [
ENCODL3	CALL	@RSEEKB			; right seek 2nd or 3rd '[' => next pattern '['
	MOV	%>01,MATCHED		; MATCHED := 1 (one char to discard)
	AND	%>FD,FLAGS2		; clear FLAGS2.1 (allow to count chars to free in MATCHED)
	JMP	ENCODL2			; check next rule

	; Match failed before opening [ => seek next rule
ENCODF2	MOV	%>03,B			; B := 3 (number of '[') to seek
	JMP	ENCODL3			; right seek 3rd '[' and check next rule

;==============================================================================

	; left seek '['
LSEEKB	LDA	*RULPTR			; A := *RULPTR
	BTJZ	%>40,A,LSEEBB1		; A.6 set ('[' found)? jump if not
	RETS				; else return

LSEEBB1	DECD	RULPTR			; dec RULPTR
	JMP	LSEEKB			; and loop

;==============================================================================

	; right seek Bth '['
RSEEKB	CLR	COUNTER			; COUNTER := 0

RSEEKB1	LDA	*RULPTR			; A := *RULPTR
	BTJZ	%>40,A,RSEEKB2		; A.6 set ('[' found)? jump if not
	INC	COUNTER			; inc COUNTER
	CMP	COUNTER,B		; jump if COUNTER != B
	JNZ	RSEEKB2
	RETS				; else return: found

RSEEKB2	INC	RULPTRL			; inc RULPTR
	JNC	DINC3
	INC	RULPTRH
DINC3	JMP	RSEEKB1			; and loop

;==============================================================================

	; Write allophones
WRALLO	CLR	COUNTER			; COUNTER := 0 (flag for exit)
	LDA	*RULPTR			; A := *RULPTR
	CMP	%>FF,A			; A == $FF?
	JZ	WRALLOX			; exit if yes: no allophone to send
	BTJZ	%>80,A,WRALLO1		; A.7 set (']' found)? jump if not
	INC	COUNTER			; else inc COUNTER
WRALLO1	AND	%>3F,A			; mask A.6 and A.7
	AND	%>FD,FLAGS1		; clear FLAGS1.1 (write in buffer)
	OR	%>04,FLAGS1		; set FLAGS1.2 (output buffer)
	CALL	@RWBUFR			; write allophone in buffer
	INC	RULPTRL			; inc RULPTR
	JNC	DINC4			;
	INC	RULPTRH			;
DINC4	CMP	%>01,COUNTER		; ']' found?
	JNZ	WRALLO			; loop if not
WRALLOX	RETS				; else return

;==============================================================================

	; compare in-brackets
CMPBKT	MOVD	INRD,INRDLX		; INRDLX := INRD (input read ptr)
	AND	%>F7,FLAGS1		; clear FLAGS1.3
	BTJZ	%>20,FLAGS1,CMPNLTR	; FLAGS1.5 letter rules? jump if not
	LDA	*RULPTR			; A := *RULPTR
	CMP	%>FF,A			; A == $FF? (single letter/end of rules)
	JNZ	CMPLTR			; jump if not to letter rules
	JMP	CMPEND			; else exit (success)

	; not letter rules: check 1st char, otherwise implicit
CMPNLTR	CMP	%>FF,A			; A == $FF?
	JZ	CMPEND			; exit if yes (success)
	CALL	@DECINRD		; dec INRD and roll if needed
	DEC	MATCHED			; dec MATCHED (matched chars to discard)

	; letter rules
CMPLTR	CALL	@FETCH			; Fetch char and mask high bit
	CMP	%>61,A			; lower case?
	JN	CMPLTR1			; skip if not
	SUB	%>20,A			; else adjust to upper case
CMPLTR1	SUB	%>20,A			; adjust to range 00-3F
	MOV	A,B			; B := A
	LDA	*RULPTR			; A := *RULPTR
	BTJZ	%>80,A,CMPLTR2		; A.7 set (']' found)? Skip if not
	OR	%>08,FLAGS1		; else set FLAGS1.3
CMPLTR2	AND	%>3F,A			; mask A.6 and A.7
	CMP	REGA,B			; A == B?
	JZ	CPMATCH			; jump if yes
	OR	%>10,FLAGS1		; set FLAGS1.4: pattern match failed
	MOVD	INRDLX,INRD		; INRD := INRDLX
	RETS				; return (failed)

CPMATCH	BTJZ	%>08,FLAGS1,CMPNEXT	; FLAGS1.3 set (']' found)? Jump if not

	; pattern match successful
CMPEND	MOVD	INRD,INRDP		; INRDP := INRD - save input buffer read ptr
	AND	%>EF,FLAGS1		; clear FLAGS1.4: pattern match successful
	OR	%>02,FLAGS2		; set FLAGS2.1 - forbid to count matched chars to discard
	RETS				; return

	; next letter
CMPNEXT	INC	RULPTRL			; inc RULPTR
	JNC	CMPLTR			;
	INC	RULPTRH			;
	JMP	CMPLTR			; and loop: check next char

;==============================================================================

	; Get letter flags
GFLAGS	MOV	NXTCHR,B		; B := Next char
	CMP	%>3A,B			; B > 'Z'-$20?
	JP	GFLAGX			; exit if yes
	CMP	%>21,B			; B < 'A'-$20?
	JN	GFLAGX			; exit if yes
	SUB	%>21,B			; B -= 'A' (could replace the CMP above!)
	LDA	@LTFLGS(B)		; Letter flags
	RETS				; done

GFLAGX	CLR	A			; non-letter => clear all flags
	RETS				; done

	; Letter flags
	; ------------
	; 7(80): Vowel
	; 6(40): Voiced consonant
	; 5(20): Sibilant
	; 4(10): Preceding long U
	; 3(08): Consonant
	; 2(04): Front vowel
	; 1(02): Back vowel
	; 0(01): Suffix ('E')
LTFLGS	BYTE	>80			; A 1000 0000 - EPROM sig check begin
	BYTE	>48			; B 0100 1000
	BYTE	>28			; C 0010 1000
	BYTE	>58			; D 0101 1000
	BYTE	>85			; E 1000 0101 - EPROM sig check end
	BYTE	>08			; F 0000 1000
	BYTE	>68			; G 0110 1000
	BYTE	>08			; H 0000 1000
	BYTE	>84			; I 1000 0100
	BYTE	>78			; J 0111 1000
	BYTE	>08			; K 0000 1000
	BYTE	>58			; L 0101 1000
	BYTE	>48			; M 0100 1000
	BYTE	>58			; N 0101 1000
	BYTE	>82			; O 1000 0010
	BYTE	>08			; P 0000 1000
	BYTE	>08			; Q 0000 1000
	BYTE	>58			; R 0101 1000
	BYTE	>38			; S 0011 1000
	BYTE	>18			; T 0001 1000
	BYTE	>82			; U 1000 0010
	BYTE	>48			; V 0100 1000
	BYTE	>48			; W 0100 1000
	BYTE	>28			; X 0010 1000
	BYTE	>84			; Y 1000 0100
	BYTE	>78			; Z 0111 1000

;==============================================================================

	; Pattern jump table
PATBRT	BR	@PATVOW			; #	09	1+ vowels
	BR	@PATVOC			; .	0A	voiced consonant: B D G J L M N R V W X
	BR	@PATSUF			; %	0B	suffix: -ER(S) -E -ES -ED -ELY -ING -OR -MENT
	BR	@PATSIB			; &	0C	sibilant: S C G Z X J CH SH
	BR	@PATPLU			; @	0D	T S R D L Z N J TH CH SH preceding long U
	BR	@PAT1CO			; ^	0E	1 consonant only
	BR	@PATFVO			; +	0F	front vowel: E I Y
	BR	@PAT0MC			; :	10	0+ consonants
	BR	@PAT1MC			; *	11	1+ consonants
	BR	@PATBVO			; >	12	back vowel: O U
	BR	@PATNLT			; <	13	Anything other than a letter
	BR	@PAT2MV			; ?	14	2+ vowels

;==============================================================================

	; Check rule pattern
CHKPAT	BTJO	%>40,FLAGS1,CKPATL1	; FLAGS1.6 set (scan direction left)? jump if yes
	MOV	%>40,B			; '[' mask
	INC	RULPTRL			; inc RULPTR rule ptr
	JNC	DINC5
	INC	RULPTRH
DINC5	JMP	CHKPAT1			; proceed

CKPATL1	MOV	%>80,B			; ']' mask
	DECD	RULPTR			; dec RULPTR rule ptr

	; check if boundary has been reached
CHKPAT1	LDA	*RULPTR			; get rule char
	BTJZ	B,A,CKPTCHR		; is '[' or ']'? jump if not
	BTJO	%>40,FLAGS1,CKPATL2	; FLAGS1.6 set (scan direction left)? jump if yes
	DECD	RULPTR			; dec RULPTR rule ptr
	JMP	DINC6

CKPATL2	INC	RULPTRL			; inc RULPTR rule ptr
	JNC	DINC6
	INC	RULPTRH
DINC6	AND	%>EF,FLAGS1		; clear FLAGS1.4 rule pattern match failed
	RETS				; return

	; check rule char
CKPTCHR	CALL	@GNEXT			; get next input char and move code to range 00-3F
	LDA	*RULPTR			; A := *RULPTR - load rule char
	CMP	%>15,A			; A < $15? (pattern symbol)
	JN	CHKSYMB			; jump if yes
CKNXCHR	CMP	REGA,NXTCHR		; otherwise compare input char with rule char
	JZ	CHKPAT			; continue with next char if both chars match

	; pattern match failed
PATFLD	OR	%>10,FLAGS1		; set FLAGS1.4 - match failed
	MOVD	INRDLX,INRD		; INRD := INRDLX - restore input ptr
	MOVD	INRDLB,INRDB		; INRDB := INRDLB - restore backward input ptr
	RETS				; return (failed)

	; check rule pattern symbol
CHKSYMB	CMP	%>07,A			; is a "'"?
	JZ	CKNXCHR			; jump if yes (apostrophe not a pattern symbol)
	; compute pattern symbol handler address
	MOV	A,B			; B := A
	SUB	%>09,B			; B -= 9
	MPY	%>03,B			; B *= 3
	BR	@PATBRT(B)		; Branch to PATBRT + B

;..............................................................................
	; <	13	Anything other than a letter
PATNLT	CALL	@GFLAGS			; Get letter flags
	CMP	%>00,A			; Is a letter?
	JZ	PATOK1			; Accept if yes
	JMP	PATFLD			; else pattern match failed

;..............................................................................
	; *	11	1+ consonants
PAT1MC	CALL	@GFLAGS			; Get letter flags
	BTJO	%>08,A,PATL1MC		; Is a consonant? Jump if yes
	JMP	PATFLD			; else pattern match failed

PATL1MC	CALL	@GNEXT			; get next char and move code to range 00-3F
	CALL	@GFLAGS			; Get letter flags
	BTJO	%>08,A,PATL1MC		; Is a consonant? Loop until not
	JMP	PATOK0			; Unget and Accept rule

;..............................................................................
	; ?	14	2+ vowels
PAT2MV	CALL	@GFLAGS			; Get letter flags
	BTJO	%>80,A,PAT2MV1		; Vowel flag? Jump if yes
	JMP	PATFLD			; pattern match failed

PAT2MV1	CALL	@GNEXT			; get next char and move code to range 00-3F
	CALL	@GFLAGS			; Get letter flags
	BTJO	%>80,A,PATL2MV		; Vowel flag? Jump if yes
	JMP	PATFLD			; pattern match failed

PATL2MV	CALL	@GNEXT			; get next char and move code to range 00-3F
	CALL	@GFLAGS			; Get letter flags
	BTJO	%>80,A,PATL2MV		; Vowel flag? Loop until not
	JMP	PATOK0			; Unget and accept rule

;..............................................................................
	; :	10	0+ consonants
PAT0MC	CALL	@GFLAGS			; Get letter flags
	BTJO	%>08,A,PATL0MC		; Consonant? Jump if yes
	JMP	PATOK0			; else unget and accept rule

PATL0MC	CALL	@GNEXT			; get next char and move code to range 00-3F
	CALL	@GFLAGS			; Get letter flags
	BTJO	%>08,A,PATL0MC		; Is a consonant? Loop until not

	; Unget and accept rule
PATOK0	CALL	@UNGET			; Unget last input character

	; pattern match ok
PATOK1	BR	@CHKPAT			; Check next rule pattern

;..............................................................................
	; %	0B	suffix: -ER(S) -E -ES -ED -ELY -ING -OR -MENT
PATSUF	CALL	@GFLAGS			; Get letter flags
	BTJO	%>01,A,PS_E		; Suffix flag ('-E')? Jump if yes
	CMP	%>29,NXTCHR		; 'I'? (-I*)
	JZ	PS_I			; Jump if yes
	CMP	%>2D,NXTCHR		; 'M'? (-M*)
	JZ	PS_M			; Jump if yes
	CMP	%>2F,NXTCHR		; 'O'? (-O*)
	JZ	PS_O			; jump if yes
	JMP	PATFL1			; pattern match failed

	; found '-M'
PS_M	CALL	@FETCH			; Fetch char and mask high bit
	CMP	%>45,A			; 'E'?  (-ME*)
	JZ	PS_ME			; jump if yes
	JMP	PATFL1			; pattern match failed

	; found '-ME'
PS_ME	CALL	@FETCH			; Fetch char and mask high bit
	CMP	%>4E,A			; 'N'?  (-MEN*)
	JZ	PS_MEN			; jump if yes
	JMP	PATFL1			; pattern match failed

	; found '-MEN'
PS_MEN	CALL	@FETCH			; Fetch char and mask high bit
	CMP	%>54,A			; 'T'? (-MENT)
	JZ	PATCKSU			; jump if yes, suffix -MENT found
	JMP	PATFL1			; pattern match failed

	; Found '-O' (-OR)
PS_O	CALL	@FETCH			; Fetch char and mask high bit
	CMP	%>52,A			; 'R'? (-OR)
	JZ	PATCKSU			; jump if yes, suffix -OR found
	JMP	PATFL1			; pattern match failed

	; Found '-I' (-ING)
PS_I	CALL	@FETCH			; Fetch char and mask high bit
	CMP	%>4E,A			; 'N'? (-IN*)
	JZ	PS_IN			; jump if yes
	JMP	PATFL1			; pattern match failed

	; found '-IN'
PS_IN	CALL	@FETCH			; Fetch char and mask high bit
	CMP	%>47,A			; 'G'? (-ING)
	JZ	PATCKSU			; jump if yes, suffix -ING found
	JMP	PATFL1			; pattern match failed

	; Suffix found: check that no letter follows
PATCKSU	CALL	@CHKLTR			; Check if next input char is a letter
	BTJO	%>20,FLAGS1,PATFL1	; pattern match failed
	JMP	PATOK2			; Accept rule

	; found '-E' (-ER, -ERS, -ES, -ED, -ELY)
PS_E	CALL	@FETCH			; Fetch char and mask high bit
	CMP	%>52,A			; 'R'? (-ER)
	JNZ	PS_E1			; jump if not
	CALL	@FETCH			; Fetch char and mask high bit
	CMP	%>53,A			; 'S'? (optional plural -ERS)
	JZ	PATCKSU			; jump if yes, suffix -ERS found
	CALL	@DECINRD		; dec INRD and roll if needed
	JMP	PATCKSU			; suffix -ER found

PS_E1	CMP	%>53,A			; 'S' (-ES)
	JZ	PATCKSU			; jump if yes, suffix -ES found
	CMP	%>44,A			; 'D' (-ED)
	JZ	PATCKSU			; jump if yes, suffix -ED found
	CMP	%>4C,A			; 'L' (-EL*)
	JZ	PS_EL			; jump if yes
	CALL	@DECINRD		; dec INRD and roll if needed
					; suffix -E found
	CALL	@CHKLTR			; Check if next input char is a letter
	BTJZ	%>20,FLAGS1,PATOK2	; Jump if FLAGS1.5 unset (not a letter => OK)
	JMP	PATFL1			; pattern match failed

	; found '-EL'
PS_EL	CALL	@FETCH			; Fetch char and mask high bit
	CMP	%>59,A			; 'Y'? (-ELY)
	JZ	PATCKSU			; jump if yes, suffix -ELY found

	; pattern match failed
PATFL1	BR	@PATFLD			; pattern match failed


	; Test if next input char is a letter, FLAGS1.5=1 if yes
CHKLTR	CALL	@FETCH			; Fetch char and mask high bit
	PUSH	RULPTRL			; save RULPTR
	PUSH	RULPTRH
	CALL	@SELRUL			; select rules set, test if letter rule
	POP	RULPTRH			; restore RULPTR
	POP	RULPTRL
	CALL	@DECINRD		; dec INRD and roll if needed
	RETS				; return FLAGS1.5=1 if letter

;..............................................................................
	; #	09	1+ vowels
PATVOW	CALL	@GFLAGS			; Get letter flags
	BTJO	%>80,A,PATVOW1		; Vowel flag? Jump if yes
	JMP	PATFL1			; pattern match failed

PATVOW1	CALL	@GNEXT			; get next char and move code to range 00-3F
	CALL	@GFLAGS			; Get letter flags
	BTJO	%>80,A,PATVOW1		; Vowel flag? Loop until not
	CALL	@UNGET			; Unget input character
	JMP	PATOK2			; Accept rule

;..............................................................................
	; .	0A	voiced consonant: B D G J L M N R V W X
PATVOC	CALL	@GFLAGS			; Get letter flags
	BTJO	%>40,A,PATOK2		; Voiced consonant flag? Accept if yes
	JMP	PATFL1			; pattern match failed

PATOK2	BR	@CHKPAT			; Check rule pattern

;..............................................................................
	; ^	0E	1 consonant only
PAT1CO	CALL	@GFLAGS			; Get letter flags
	BTJO	%>08,A,PATOK2		; Consonant flag? Accept if yes
	JMP	PATFL1			; pattern match failed

;..............................................................................
	; +	0F	front vowel: E I Y
PATFVO	CALL	@GFLAGS			; Get letter flags
	BTJO	%>04,A,PATOK2		; Front vowel flag? Accept if yes
	JMP	PATFL1			; pattern match failed

;..............................................................................
	; >	12	back vowel: O U
PATBVO	CALL	@GFLAGS			; Get letter flags
	BTJO	%>02,A,PATOK2		; Back vowel flag? Accept if yes
	JMP	PATFL1			; pattern match failed

;..............................................................................
	; &	0C	sibilant: S C G Z X J CH SH
PATSIB	CALL	@GFLAGS			; Get letter flags
	BTJO	%>20,A,PATOK2		; Sibilant flag? Accept if yes
	CALL	@GNEXT			; get next char and move code to range 00-3F
	JMP	PATCSH			; check for CH or SH

;..............................................................................
	; @	0D	T S R D L Z N J TH CH SH preceding long U
PATPLU	CALL	@GFLAGS			; Get letter flags
	BTJO	%>10,A,PATOK2		; Letter influencing long U flag? Accept if yes
					; (Could have checked for 'H' here...)
	CALL	@GNEXT			; get next char and move code to range 00-3F
	CMP	%>34,NXTCHR		; 'T'?
	JZ	PATTCSH			; jump if yes
PATCSH	CMP	%>23,NXTCHR		; 'C'?
	JZ	PATTCSH			; jump if yes
	CMP	%>33,NXTCHR		; 'S'?
	JZ	PATTCSH			; jump if yes
	JMP	PATFL1			; pattern match failed

	; check for TH, CH or SH
PATTCSH	MOVD	INRDB,INRD		; INRD := INRDB
	CALL	@INCINRD		; inc INRD and roll if needed
	CALL	@INCINRD		; inc INRD and roll if needed
	CALL	@FETCH			; Fetch char and mask high bit
	CMP	%>48,A			; 'H'
	JZ	PATOK2			; Accept if yes
	BR	@PATFLD			; pattern match failed

;==============================================================================

	; Fetch char and mask high bit
FETCH	OR	%>02,FLAGS1		; FLAGS1.1 = 1 - sel buffer read mode
	AND	%>FB,FLAGS1		; FLAGS1.2 = 0 - sel input buffer
	CALL	@RWBUFR			; read in input buffer (FLAGS1.0 set if delimiter)
	AND	%>7F,A			; mask high bit of char (delimiter flag)
	RETS				; return

;==============================================================================

	; inc INRDB and roll if needed
INCINRB	INC	INRDBL			; inc INRDB
	JNC	DINC7
	INC	INRDBH
DINC7	MOVD	INRDB,BUFPTR		; BUFPTR := INRDB
	CALL	@ROLINP			; Roll input buffer BUFPTR
	MOVD	BUFPTR,INRDB		; INRDB := BUFPTR
	RETS

;==============================================================================

	; inc INRD and roll if needed
INCINRD	INC	INRDL			; inc INRD
	JNC	DINC8
	INC	INRDH
DINC8	MOVD	INRD,BUFPTR		; BUFPTR := INRD
	CALL	@ROLINP			; Roll input buffer BUFPTR
	MOVD	BUFPTR,INRD		; INRD := BUFPTR
	RETS

;==============================================================================

	; dec INRD and roll if needed
DECINRD	DECD	INRD			; dec INRD
	CMP	INSTA1L,INRDL		; before input buffer start?
	JNZ	DECIRD1
	CMP	INSTA1H,INRDH
	JNZ	DECIRD1			; jump if not
	MOVD	INEND,INRD		; roll to input buffer end
DECIRD1	RETS				; return

;==============================================================================

	; dec INRDB and roll if needed
DECINRB	DECD	INRDB			; dec INRDB
	CMP	INSTA1L,INRDBL		; before input buffer start?
	JNZ	LF75A
	CMP	INSTA1H,INRDBH
	JNZ	LF75A			; jump if not
	MOVD	INEND,INRDB		; roll to input buffer end
LF75A	RETS				; return

;==============================================================================

	; get next char and move code to range 00-3F
GNEXT	BTJZ	%>40,FLAGS1,GNEXT1	; FLAGS1.6 set? jump if not (scan right)
	PUSH	INRDL			; else save INRD
	PUSH	INRDH			;
	MOVD	INRDB,INRD		; and move INRDB to INRD (backward read pointer)
GNEXT1	CALL	@FETCH			; Fetch char and mask high bit
	BTJZ	%>40,FLAGS1,GNEXT2	; FLAGS1.6 set? jump if not (scan right)
	CALL	@DECINRB		; else dec INRDB and roll if needed (scan left)
	POP	INRDH			; and restore INRD
	POP	INRDL			;
GNEXT2	CMP	%>61,A			; lower case?
	JN	GNEXT3			; jump if not
	SUB	%>20,A			; change to upper case (bug: should be done in FETCH!)
GNEXT3	SUB	%>20,A			; shift to range 00-3F
	MOV	A,NXTCHR		; store in NXTCHR
	RETS				; return

;==============================================================================

	; Unget last input character
UNGET	BTJO	%>40,FLAGS1,UNGET1	; FLAGS1.6 set? jump if yes
	CALL	@DECINRD		; dec INRD (input buffer read ptr) and roll if needed
	RETS

UNGET1	CALL	@INCINRB		; inc INRDB (backward input buffer read ptr) and roll if needed
	RETS


;==============================================================================

	BYTE	>FF			; boundary

	; Rules for punctuation
RLPNCT	BYTE	>CD,>C0,>0A,>47,>B3,>EB,>09,>10
	BYTE	>0A,>25,>47,>B3,>EB,>09,>47,>B3
	BYTE	>EB,>47,>B3,>F7,>C7,>FF,>CC,>C3
	BYTE	>DB,>C3,>C0,>C1,>CE,>44,>84,>C1
	BYTE	>44,>84,>DF,>44,>84,>DA,>C4,>C5
	BYTE	>49,>34,>37,>37,>07,>0B,>0D,>80
	BYTE	>C4,>61,>18,>2D,>33,>2B,>80,>C3
	BYTE	>78,>0F,>10,>1C,>33,>80,>FF,>C2
	; Rules for 'A'
RULESA	BYTE	>13,>FF,>13,>D4,>63,>28,>A5,>54
	BYTE	>02,>A9,>FF,>13,>CF,>13,>72,>A5
	BYTE	>13,>FB,>0E,>F3,>09,>54,>B7,>13
	BYTE	>F2,>2F,>4F,>A7,>13,>FF,>0E,>32
	BYTE	>CF,>F2,>09,>EF,>13,>10,>6E,>B9
	BYTE	>47,>0B,>93,>67,>21,>29,>AE,>4F
	BYTE	>01,>24,>07,>07,>8B,>FF,>37,>21
	BYTE	>CF,>F7,>57,>97,>13,>10,>FF,>0E
	BYTE	>0F,>13,>D4,>13,>FF,>0E,>09,>CF
	BYTE	>FF,>0E,>0F,>09,>D4,>09,>10,>6C
	BYTE	>2C,>B9,>4F,>2D,>93,>13,>EC,>09
	BYTE	>4F,>AD,>09,>10,>E7,>25,>4C,>01
	BYTE	>8A,>FF,>0E,>0B,>D4,>FF,>0E,>0F
	BYTE	>10,>09,>DA,>13,>72,>B2,>4F,>A7
	BYTE	>72,>B2,>5A,>A7,>13,>10,>F2,>13
	BYTE	>FB,>F2,>13,>F3,>F2,>FB,>69,>B2
	BYTE	>47,>AF,>E9,>D4,>F9,>D4,>F5,>D7
	BYTE	>09,>10,>EC,>13,>FE,>09,>10,>6C
	BYTE	>B3,>13,>7E,>AB,>6C,>AB,>57,>02
	BYTE	>A9,>FF,>2C,>0E,>D7,>13,>10,>62
	BYTE	>2C,>A5,>54,>01,>3F,>BE,>62,>2C
	BYTE	>A5,>4F,>01,>3F,>BE,>6E,>A7,>0F
	BYTE	>54,>0B,>01,>8A,>FF,>DA
	; Rules for 'B'
RULESB	BYTE	>13,>FF,>13,>41,>3F,>93,>2D,>21
	BYTE	>39,>E5,>7F,>93,>13,>E5,>0E,>09
	BYTE	>41,>3F,>93,>13,>65,>25,>AE,>13
	BYTE	>7F,>0C,>8B,>13,>6F,>34,>A8,>13
	BYTE	>41,>3F,>35,>9D,>13,>75,>B3,>09
	BYTE	>41,>3F,>0C,>AB,>75,>29,>AC,>41
	BYTE	>3F,>0C,>0C,>AD,>FF,>22,>FF,>FF
	BYTE	>13,>41,>9C,>FF,>33,>41,>9C,>F4
	BYTE	>42,>8D,>13,>FF,>0E,>41,>9C,>FF
	BYTE	>41,>BF
	; Rules for 'C'
RULESC	BYTE	>13,>FF,>13,>77,>37,>93,>13,>E8
	BYTE	>0E,>42,>AA,>0E,>25,>E8,>42,>AA
	BYTE	>E8,>42,>B2,>33,>E9,>09,>77,>37
	BYTE	>86,>E9,>09,>E5,>E9,>2F,>E5,>E9
	BYTE	>25,>2E,>E5,>FF,>0F,>77,>B7,>23
	BYTE	>FF,>FF,>EB,>09,>42,>AA,>EB,>42
	BYTE	>A9,>6F,>AD,>0B,>42,>08,>0F,>90
	BYTE	>E3,>0F,>42,>2A,>37,>B7,>FF,>13
	BYTE	>42,>A9,>FF,>33,>42,>A9,>FF,>12
	BYTE	>42,>88,>FF,>42,>AA
	; Rules for 'D'
RULESD	BYTE	>13,>FF,>13,>41,>21,>93,>FF,>24
	BYTE	>FF,>09,>10,>65,>A4,>13,>41,>21
	BYTE	>0C,>01,>95,>0A,>25,>FF,>13,>41
	BYTE	>95,>09,>11,>25,>FF,>13,>42,>8D
	BYTE	>13,>E5,>0E,>09,>41,>21,>8C,>13
	BYTE	>EF,>13,>41,>21,>9F,>13,>6F,>25
	BYTE	>B3,>41,>21,>0F,>AB,>13,>6F,>29
	BYTE	>2E,>A7,>41,>21,>1F,>0C,>AC,>13
	BYTE	>6F,>B7,>41,>21,>A0,>09,>F5,>10
	BYTE	>21,>41,>0A,>96,>E7,>41,>8A,>EA
	BYTE	>41,>8A,>FF,>13,>41,>95,>FF,>33
	BYTE	>41,>95,>FF,>41,>A1
	; Rules for 'E'
RULESE	BYTE	>13,>FF,>13,>D3,>09,>10,>FF,>13
	BYTE	>FF,>07,>11,>FF,>13,>FF,>11,>FF
	BYTE	>13,>D3,>09,>E4,>13,>41,>95,>09
	BYTE	>10,>FF,>24,>13,>FF,>F6,>25,>32
	BYTE	>47,>A3,>09,>11,>EC,>FE,>72,>A9
	BYTE	>09,>7C,>93,>09,>10,>F2,>09,>F3
	BYTE	>FF,>0E,>0B,>D3,>72,>A9,>47,>07
	BYTE	>0E,>8C,>F2,>09,>47,>AF,>F2,>F3
	BYTE	>13,>76,>25,>AE,>13,>53,>23,>0C
	BYTE	>8B,>13,>76,>25,>AE,>53,>23,>07
	BYTE	>07,>8B,>09,>10,>F7,>71,>9F,>0D
	BYTE	>F7,>DF,>F7,>71,>9F,>FF,>2F,>D3
	BYTE	>09,>10,>0C,>F3,>13,>4C,>AB,>09
	BYTE	>10,>FF,>33,>13,>FF,>09,>10,>6C
	BYTE	>B9,>13,>6D,>93,>09,>10,>6D,>25
	BYTE	>2E,>B4,>50,>0C,>0B,>02,>8D,>66
	BYTE	>35,>AC,>68,>1E,>AD,>65,>B2,>FC
	BYTE	>E5,>D3,>61,>32,>AE,>74,>8B,>13
	BYTE	>61,>B2,>0E,>F4,>11,>61,>B2,>FC
	BYTE	>61,>A4,>47,>07,>01,>95,>09,>10
	BYTE	>E1,>13,>53,>8F,>E1,>33,>35,>C7
	BYTE	>E1,>D3,>69,>27,>A8,>D4,>E9,>D3
	BYTE	>13,>79,>A5,>C6,>F9,>D3,>F5,>D6
	BYTE	>FF,>C7
	; Rules for 'F'
RULESF	BYTE	>13,>FF,>13,>47,>07,>A8,>F5,>2C
	BYTE	>68,>9E,>FF,>26,>FF,>6F,>35,>B2
	BYTE	>68,>BA,>FF,>E8
	; Rules for 'G'
RULESG	BYTE	>13,>FF,>13,>41,>0A,>93,>69,>B6
	BYTE	>41,>24,>0C,>A3,>13,>FF,>29,>0E
	BYTE	>41,>A4,>E5,>34,>41,>24,>87,>33
	BYTE	>35,>67,>25,>B3,>41,>3D,>01,>0A
	BYTE	>07,>07,>B7,>E7,>41,>A4,>72,>25
	BYTE	>21,>B4,>41,>22,>27,>14,>8D,>FF
	BYTE	>13,>41,>A2,>13,>22,>09,>FF,>41
	BYTE	>BD,>FF,>0F,>41,>8A,>09,>E8,>E8
	BYTE	>E8,>41,>BD,>FF,>41,>BD
	; Rules for 'H'
RULESH	BYTE	>13,>FF,>13,>54,>02,>B2,>13,>61
	BYTE	>B6,>5B,>1A,>A3,>13,>65,>32,>A5
	BYTE	>5B,>BC,>13,>6F,>35,>B2,>60,>B3
	BYTE	>6F,>B7,>5B,>A0,>79,>B0,>5B,>0C
	BYTE	>02,>89,>FF,>12,>F9,>FF,>09,>DB
	BYTE	>FF,>FF
	; Rules for 'I'
RULESI	BYTE	>13,>EE,>4C,>8B,>2E,>FF,>2E,>25
	BYTE	>C6,>FF,>13,>C6,>EE,>24,>46,>8B
	BYTE	>13,>10,>FF,>0B,>C6,>13,>10,>65
	BYTE	>A4,>13,>46,>01,>95,>09,>11,>65
	BYTE	>A4,>13,>53,>01,>95,>26,>32,>E5
	BYTE	>2E,>24,>C7,>65,>AE,>53,>0C,>8B
	BYTE	>E5,>34,>46,>8C,>65,>B2,>53,>B3
	BYTE	>FF,>0B,>D3,>E5,>D3,>EE,>0B,>53
	BYTE	>8B,>F2,>09,>46,>B3,>FF,>0E,>0B
	BYTE	>C6,>FF,>0E,>0F,>10,>09,>CC,>FA
	BYTE	>0B,>46,>AB,>F3,>0B,>46,>AB,>FF
	BYTE	>1F,>0B,>C6,>0F,>0E,>FF,>0E,>0F
	BYTE	>CC,>FF,>34,>0B,>C6,>09,>11,>FF
	BYTE	>0E,>0F,>CC,>F2,>F4,>11,>FF,>2F
	BYTE	>2E,>F1,>67,>A8,>C6,>6C,>A4,>46
	BYTE	>3E,>01,>95,>67,>AE,>46,>8B,>67
	BYTE	>AE,>0E,>46,>8B,>67,>AE,>0B,>46
	BYTE	>8B,>71,>35,>A5,>53,>02,>A9,>FF
	BYTE	>21,>C6,>2D,>FF,>23,>C6,>FF,>CC
	; Rules for 'J'
RULESJ	BYTE	>13,>FF,>13,>41,>0A,>94,>FF,>41
	BYTE	>8A
	; Rules for 'K'
RULESK	BYTE	>13,>FF,>13,>42,>2A,>94,>13,>FF
	BYTE	>2E,>FF,>FF,>13,>42,>A9,>FF,>42
	BYTE	>AA
	; Rules for 'L'
RULESL	BYTE	>13,>FF,>13,>47,>07,>AD,>EF,>23
	BYTE	>09,>6D,>B5,>FF,>2C,>FF,>FF,>0B
	BYTE	>FE,>65,>21,>A4,>6D,>13,>01,>95
	BYTE	>61,>35,>27,>A8,>6D,>1A,>A8,>FF
	BYTE	>ED
	; Rules for 'M'
RULESM	BYTE	>E2,>D0,>13,>FF,>13,>47,>07,>90
	BYTE	>6F,>B6,>50,>1F,>A3,>FF,>2D,>FF
	BYTE	>FF,>D0
	; Rules for 'N'
RULESN	BYTE	>13,>FF,>13,>47,>07,>8B,>25,>E7
	BYTE	>0F,>4B,>01,>8A,>E7,>32,>6C,>01
	BYTE	>A4,>E7,>09,>6C,>01,>A4,>67,>AC
	BYTE	>0B,>6C,>01,>24,>BE,>E7,>EC,>EB
	BYTE	>13,>6C,>02,>A9,>EB,>33,>6C,>02
	BYTE	>A9,>EB,>6C,>02,>AA,>13,>6F,>B7
	BYTE	>13,>78,>A0,>FF,>2E,>FF,>09,>10
	BYTE	>F5,>4B,>31,>96,>13,>FF,>F8,>47
	BYTE	>B4,>4B,>02,>8D,>FF,>CB
	; Rules for 'O'
RULESO	BYTE	>13,>FF,>13,>F5,>E6,>13,>4F,>A3
	BYTE	>72,>2F,>35,>27,>A8,>4F,>0F,>27
	BYTE	>B5,>09,>10,>F2,>13,>F3,>09,>10
	BYTE	>72,>B3,>13,>73,>AB,>F2,>FA,>13
	BYTE	>6E,>A5,>6E,>0F,>8B,>0F,>6E,>A5
	BYTE	>6E,>0F,>8B,>11,>F7,>2E,>E0,>F7
	BYTE	>F5,>13,>76,>25,>B2,>75,>23,>B3
	BYTE	>F6,>4F,>A3,>FF,>0E,>0B,>F5,>FF
	BYTE	>0E,>25,>2E,>F5,>FF,>0E,>29,>09
	BYTE	>F5,>EC,>24,>75,>AD,>75,>27,>28
	BYTE	>B4,>57,>17,>02,>8D,>75,>27,>A8
	BYTE	>4F,>0F,>A8,>0C,>75,>B2,>FA,>10
	BYTE	>75,>B2,>60,>B3,>13,>F5,>E0,>10
	BYTE	>F5,>33,>09,>E0,>75,>B3,>4F,>B7
	BYTE	>75,>2C,>A4,>5E,>01,>95,>0E,>F5
	BYTE	>0E,>2C,>CF,>75,>B0,>5F,>02,>89
	BYTE	>F5,>E0,>F9,>C5,>69,>2E,>A7,>75
	BYTE	>0C,>AC,>E9,>C5,>6F,>B2,>FA,>6F
	BYTE	>AB,>13,>5E,>02,>A9,>6F,>AB,>33
	BYTE	>5E,>02,>A9,>6F,>AB,>5E,>02,>AA
	BYTE	>6F,>A4,>13,>5E,>01,>95,>EF,>24
	BYTE	>DE,>EF,>DF,>FF,>25,>F5,>FF,>13
	BYTE	>F5,>61,>B2,>FA,>E1,>F5,>13,>6E
	BYTE	>2C,>B9,>75,>0B,>2D,>93,>13,>6E
	BYTE	>23,>A5,>6E,>0F,>0B,>B7,>6E,>07
	BYTE	>B4,>75,>0B,>02,>8D,>23,>FF,>2E
	BYTE	>CF,>FF,>2E,>27,>D7,>13,>11,>FF
	BYTE	>2E,>CF,>29,>EE,>4F,>8B,>09,>10
	BYTE	>EE,>13,>4F,>8B,>FF,>33,>34,>13
	BYTE	>F5,>E6,>0E,>57,>A8,>74,>28,>25
	BYTE	>B2,>4F,>36,>B3,>73,>B3,>13,>57
	BYTE	>17,>37,>B7,>09,>11,>ED,>4F,>90
	BYTE	>FF,>D8
	; Rules for 'P'
RULESP	BYTE	>73,>39,>23,>A8,>77,>37,>06,>01
	BYTE	>AA,>13,>FF,>13,>42,>09,>93,>E8
	BYTE	>E8,>65,>2F,>B0,>42,>09,>13,>02
	BYTE	>89,>6F,>B7,>42,>09,>A0,>75,>B4
	BYTE	>13,>42,>09,>1E,>02,>8D,>FF,>30
	BYTE	>FF,>FF,>42,>89
	; Rules for 'Q'
RULESQ	BYTE	>13,>FF,>13,>42,>2A,>31,>9F,>75
	BYTE	>21,>B2,>42,>08,>30,>98,>75,>A5
	BYTE	>13,>42,>2A,>31,>9F,>F5,>42,>08
	BYTE	>B0,>FF,>42,>88
	; Rules for 'R'
RULESR	BYTE	>13,>FF,>13,>FB,>13,>E5,>0E,>09
	BYTE	>4E,>93,>E8,>CE,>FF,>32,>FF,>11
	BYTE	>FF,>E7,>FF,>CE
	; Rules for 'S'
RULESS	BYTE	>13,>FF,>13,>47,>07,>37,>B7,>E8
	BYTE	>E5,>09,>69,>2F,>AE,>66,>0F,>8B
	BYTE	>6F,>2D,>A5,>77,>0F,>90,>09,>75
	BYTE	>B2,>09,>66,>B3,>75,>B2,>09,>65
	BYTE	>B3,>09,>F5,>09,>66,>96,>09,>73
	BYTE	>B5,>09,>65,>96,>09,>65,>A4,>13
	BYTE	>6B,>01,>95,>09,>FF,>09,>EB,>61
	BYTE	>29,>A4,>77,>37,>07,>07,>01,>95
	BYTE	>0E,>69,>2F,>AE,>65,>0F,>8B,>FF
	BYTE	>33,>FF,>0A,>FF,>13,>EB,>09,>10
	BYTE	>0A,>25,>FF,>13,>EB,>09,>11,>14
	BYTE	>FF,>13,>EB,>09,>11,>09,>FF,>13
	BYTE	>F7,>35,>FF,>13,>F7,>13,>10,>09
	BYTE	>FF,>13,>EB,>13,>63,>A8,>77,>37
	BYTE	>02,>A9,>FF,>23,>0F,>FF,>09,>ED
	BYTE	>6B,>90,>09,>FF,>2E,>07,>EB,>FF
	BYTE	>13,>F7,>FF,>77,>B7
	; Rules for 'T'
RULEST	BYTE	>FF,>07,>33,>42,>91,>63,>A8,>42
	BYTE	>B2,>13,>FF,>13,>42,>0D,>93,>13
	BYTE	>68,>A5,>13,>09,>52,>93,>13,>68
	BYTE	>A5,>13,>52,>8F,>EF,>13,>42,>0D
	BYTE	>9F,>6F,>24,>21,>B9,>42,>0D,>1F
	BYTE	>21,>94,>68,>A1,>0E,>13,>52,>9A
	BYTE	>13,>68,>29,>B3,>13,>52,>0C,>37
	BYTE	>B7,>13,>68,>25,>B9,>52,>94,>13
	BYTE	>68,>25,>32,>A5,>52,>AF,>13,>68
	BYTE	>25,>B2,>5D,>B3,>68,>25,>B2,>76
	BYTE	>B3,>68,>25,>29,>B2,>52,>AF,>13
	BYTE	>68,>25,>AD,>10,>52,>07,>90,>68
	BYTE	>25,>33,>A5,>13,>52,>13,>AB,>13
	BYTE	>68,>25,>AE,>52,>07,>8B,>68,>32
	BYTE	>2F,>35,>27,>A8,>13,>5D,>27,>9F
	BYTE	>68,>2F,>33,>A5,>52,>35,>B7,>68
	BYTE	>2F,>35,>27,>A8,>13,>52,>B5,>13
	BYTE	>68,>35,>B3,>52,>0F,>37,>B7,>68
	BYTE	>A5,>13,>D2,>E8,>DD,>09,>10,>65
	BYTE	>A4,>13,>42,>0D,>0C,>01,>95,>33
	BYTE	>E9,>09,>2E,>42,>B2,>E9,>2F,>E5
	BYTE	>E9,>21,>E5,>69,>25,>AE,>65,>0F
	BYTE	>8B,>75,>B2,>09,>42,>32,>B3,>F5
	BYTE	>21,>42,>32,>96,>13,>77,>AF,>42
	BYTE	>0D,>9F,>FF,>34,>FF,>FF,>33,>42
	BYTE	>91,>FF,>42,>8D
	; Rules for 'U'
RULESU	BYTE	>13,>FF,>13,>71,>9F,>EE,>29,>59
	BYTE	>16,>8B,>13,>EE,>4F,>8B,>13,>70
	BYTE	>2F,>AE,>4F,>02,>09,>18,>8B,>0D
	BYTE	>F2,>09,>56,>B3,>F2,>09,>71,>16
	BYTE	>B3,>F2,>11,>F3,>FF,>0E,>13,>CF
	BYTE	>FF,>0E,>0E,>CF,>F9,>C6,>13,>27
	BYTE	>FF,>09,>FF,>27,>FF,>0B,>FF,>27
	BYTE	>FF,>09,>EE,>0D,>FF,>DF,>FF,>71
	BYTE	>96
	; Rules for 'V'
RULESV	BYTE	>13,>FF,>13,>63,>93,>69,>25,>B7
	BYTE	>63,>31,>9F,>FF,>E3
	; Rules for 'W'
RULESW	BYTE	>13,>FF,>13,>41,>21,>0F,>01,>3F
	BYTE	>3E,>31,>96,>13,>65,>32,>A5,>6E
	BYTE	>B4,>13,>61,>B3,>13,>6E,>0F,>AB
	BYTE	>E1,>33,>6E,>98,>E1,>34,>6E,>17
	BYTE	>97,>61,>AE,>6E,>18,>8B,>68,>25
	BYTE	>32,>A5,>70,>AF,>68,>21,>B4,>70
	BYTE	>18,>02,>8D,>68,>2F,>AC,>79,>35
	BYTE	>AD,>68,>AF,>79,>9F,>EF,>2D,>6E
	BYTE	>8F,>E8,>F0,>61,>B2,>6E,>BA,>6F
	BYTE	>B2,>0E,>6E,>B3,>F2,>CE,>FF,>EE
	; Rules for 'X'
RULESX	BYTE	>13,>FF,>13,>47,>02,>29,>B7,>13
	BYTE	>FF,>EB,>FF,>42,>29,>B7
	; Rules for 'Y'
RULESY	BYTE	>6F,>35,>B2,>59,>BA,>13,>FF,>13
	BYTE	>6E,>86,>6F,>35,>2E,>A7,>59,>0F
	BYTE	>AC,>13,>6F,>B5,>59,>9F,>65,>21
	BYTE	>B2,>10,>59,>BC,>13,>65,>B3,>59
	BYTE	>07,>37,>B7,>13,>FF,>D9,>09,>11
	BYTE	>FF,>13,>D3,>09,>11,>FF,>29,>D3
	BYTE	>13,>10,>FF,>13,>C6,>13,>10,>FF
	BYTE	>09,>C6,>13,>10,>FF,>0E,>0F,>10
	BYTE	>09,>CC,>13,>10,>FF,>0E,>09,>C6
	BYTE	>FF,>CC
	; Rules for 'Z'
RULESZ	BYTE	>13,>FF,>13,>6B,>93,>FF,>3A,>FF
	BYTE	>FF,>EB
	; Rules for digits
RULNUM	BYTE	>D0,>6B,>3C,>B5,>D1,>6E,>0F,>0F
	BYTE	>8B,>D2,>42,>0D,>9F,>D3,>5D,>0E
	BYTE	>93,>D4,>68,>BA,>D5,>68,>06,>A3
	BYTE	>D6,>77,>37,>0C,>02,>29,>B7,>D7
	BYTE	>77,>37,>07,>23,>0C,>8B,>D8,>54
	BYTE	>02,>8D,>D9,>78,>06,>8B

;==============================================================================

	; Index of rules tables
TABRUL	DATA	RLPNCT
TABRU1	EQU	$-1
	DATA	RULESA,RULESB,RULESC,RULESD
	DATA	RULESE,RULESF,RULESG,RULESH
	DATA	RULESI,RULESJ,RULESK,RULESL
	DATA	RULESM,RULESN,RULESO,RULESP
	DATA	RULESQ,RULESR,RULESS,RULEST
	DATA	RULESU,RULESV,RULESW,RULESX
	DATA	RULESY,RULESZ,RULNUM,>FFFF

;==============================================================================
	; Interrupt vectors
	DATA	INT4,INT3,>FFFF,INT1
	DATA	CTS256

;==============================================================================
PARINP	EQU	>0200			; Memory-mapped parallel input from Host
SP0256	EQU	>2000			; Memory-mapped parallel output to SP0256A-AL2
CTSXRAM	EQU	>3000			; CTS-256A External RAM origin
;==============================================================================

; addresses within the text-to-speech code in the masked ROM...
AUDIBLE	EQU	SAYOK			; say "OK" (AUDIBLE)
GISPEECH EQU	ENCODE			; encode text as allophones ()
SAVE	EQU	STINPB			; store character in input buffer
ESCAPE	EQU	CLBUF			; clear buffers and reinitialize

	END	CTS256

;==============================================================================
