;** TMS-7000(tm) DISASSEMBLER V1.10beta3 - (c) 2015-20 GmEsoft, All rights reserved. **
;
;	Tue Dec 27 08:39:46 2022
;
;	Disassembly of : CTS256A.BIN
;	Equates file   : CTS256A.EQU
;	Screening file : CTS256A.SCR


;==============================================================================

	AORG	>F000

;==============================================================================

	; Main entry point
CTS256	MOV	%>3A,B
	LDSP			; Init stack pointer 3B-XX
	MOVD	%SP0256,R45	; R45 := $2000 - Memory-mapped parallel output to SP0256A-AL2
	MOVP	%>AA,P0		; P0 = IOCNT0 := 1010 1010
				; 	Full Expansion;
				;	Clear INT1, INT2 and INT3 flags
	MOVP	%>0A,P16	; P16 = IOCNT1 := 0000 1010
				;	Clear INT4 and INT5 flags
	MOVP	P4,B		; Read P4 = APORT
	AND	%>07,B		; Get Serial mode
	CMP	%>00,B		; Is it Parallel mode ?
				; useful ?
	; Jump if yes
	JZ	PARALL		; Start in parallel mode
	AND	%>7F,R10	; Clear R10.7, indicating serial mode
	MOVP	P4,A		; Read P4 = APORT
	AND	%>08,A		; Get Selectable Serial Config flag
	CMP	%>00,A		; Is it set ?
				; useful ?
	; Jump if not
	JZ	SER7N2		; Serial fixed 7N2 config
	LDA	@>1000		; Read serial config from $1000
	MOVP	A,P17		; Init P17 = SMODE with seria config
	JMP	SERSEL		; Serial selectable config

SER7N2	MOVP	%>CB,P17	; P17 = SMODE := Fixed Serial 7N2 config
SERSEL	MOVP	%>15,P17	; P17 = SCTL0 := OOO1 O1O1
				; Reset error flags; enable RX & TX
	; A := value for SCTL1 (prescaler)
	LDA	@SCT1TB(B)	; Table of values for SCTL1
	PUSH	A
	; A := value for T3DATA (timer3 reload)
	LDA	@T3DATB(B)	; Table of timer3 reload values T3DATA
	POP	B
	MOVP	B,P21		; set SCTL1
	MOVP	A,P20		; set T3DATA
	ORP	%>01,P16	; enable T4
	; proceed with RAM setup
	JMP	INIRAM		; Init RAM config

	; Table of values for SCTL1
SCT1TB	BYTE	>FF,>40,>43,>40,>43,>40,>40,>40

	; Table of timer3 reload values T3DATA
T3DATB	BYTE	>FF,>20,>57,>07,>C2,>0F,>81,>03

	; Start in parallel mode
PARALL	OR	%>80,R10	; Set R10.7, indicating parallel mode
	MOVD	%PARLINP,R47	; R47 := $0200 parallel input mapped address
	ORP	%>30,P0		; P0 = IOCNT0, set .4=enable INT3, .5=clear INT3
	; Init RAM config
INIRAM	MOVP	P4,B		; B := P4 = APORT
	AND	%>10,B		; test APORT.4 = RAM buffer - 0=internal - 1=external
	CMP	%>00,B		; useful ?
	; jump if internal
	JZ	INTRAM		; init internal RAM pointers

	MOVD	%CTSXRAM,R3	; R2:3 := base RAM address = $3000
	MOVD	R3,R41		; R40:41 := R2:3
	PUSH	R2
	DEC	R2
	MOV	R2,R34		; R34:35 := R2:3 - 1 ($2FFF)
	MOV	%>FF,R35
	ADD	%>02,R2		; R2 += 2 ($31)
	CLR	R23		; R23 := 0 (page counter)
	; Init external RAM sizing loop

IRAML0	INC	R2		; ++R2
	CMP	%>F0,R2		; R2 == $F0 ($F000 reached) ?
	; Exit loop if yes
	JZ	IRAMX0
	INC	R23		; ++R23
	CMP	%>10,R23	; R23 == $10 (16 pages) ?
	; exit loop if yes
	JZ	IRAMX0
	MOV	%>5A,A		; A := $5A (RAM test pattern)
	STA	*R3		; *R2:3 := A
	CLR	A		; A := 0 (useful?)
	LDA	*R3		; A := *R2:3
	CMP	%>5A,A		; A == $5A (test pattern) ?
	; exit loop if not
	JNZ	IRAMX0
	SWAP	A		; A := $A5 (reverse bits)
	STA	*R3		; *R2:3 := A
	CLR	A		; A := 0 (useful?)
	LDA	*R3		; A := *R2:3
	CMP	%>A5,A		; A == $A5 (test pattern) ?
	; exit loop if not
	JNZ	IRAMX0
	; Test next RAM page
	JMP	IRAML0

IRAMX0	MOV	R2,R38		; R38:39 := R2:$00 (end RAM addr + 1)
	CLR	R39		; ATTENTION: page boundary !!
	SUB	%>01,R2		; --R2 (why not DEC R2?)
	MOVD	R3,R7		; R6:7 := R2:3 = last RAM page addr (output buffer read ptr)
	MOVD	R7,R43		; R42:43 := R6:R7 (output buffer start)
	SUB	%>01,R2		; --R2 (why not DEC R2?)
	MOV	R2,R36		; R36:37 := R2:$FF (input buffer end)
	MOV	%>FF,R37
	POP	R2		; R2 := $30
	MOV	%>DF,R50	; R50 := $DF
	JMP	INIROM		; Init EPROM

	; init internal RAM pointers
INTRAM	MOVD	%>0051,R41	; R40:41 := $0051 (input buffer start)
	MOVD	%>0065,R37	; R36:37 := $0065 (input buffer end)
	MOVD	%>0050,R35	; R34:35 := $0050 (input buffer start - 1)
	MOVD	%>0066,R43	; R42:43 := $0066 (output buffer start)
	MOVD	%>0080,R39	; R38:39 := $0080 (end RAM addr + 1)
	MOVD	R41,R3		; R2:R3 := $0051 (input buffer read ptr)
	MOVD	R43,R7		; R6:R7 := $0066 (output buffer read ptr)
	MOV	%>01,R50	; R50 := $01

	; Init EPROM
INIROM	MOVD	%>0000,R19	; R18:19 := 0
LF0DA	CLR	B		; B := 0 (5 signature bytes counter/index)
	ADD	%>10,R18	; ++R18 (next page, starting at $1000)
	CMP	%>F0,R18	; $F0 reached ? (ending at $F000)
	; Jump if yes
	JZ	INITOK		; Done peripherals init
LF0E3	LDA	*R19		; Read signature byte
	; and compare it to the 5 first letters flags $80,$48,$28,$58,$85
	CMPA	@LTFLGS(B)	; Letter flags
	; next page if mismatch
	JNZ	LF0DA
	INC	B		; next test byte
	CMP	%>05,B		; done 5 bytes
	; Exit if yes => EPROM found
	JZ	STAROM		; Boot in EPROM
	INC	R19		; next EPROM byte
	JMP	LF0E3		; loop

	; Boot in EPROM
STAROM	INC	R19		; point to 1st byte following sig bytes
	MOVD	R19,R49		; R48:49 := R18:19 = EPROM entry point
	BR	*R49		; Boot in EPROM

	; Done peripherals init
INITOK	MOV	%>00,R48	; R48 := 0 (EPROM not present)
	CALL	@INIPTR		; Init buffer pointers and regs
	CALL	@SAYOK		; Say O.K.
	JMP	LF110

;==============================================================================

	; Polling loop
POLL	BTJO	%>01,R11,LF110	; test R11.0 = any delimiter; jump if yes
	AND	%>EF,R11	; reset R11.4 (found delimiter?)

	; Idle loop (wait interrupt?)
WTIDLE	BTJZ	%>10,R11,WTIDLE	; Idle loop (wait R11.4)
LF110	CMP	R3,R5		; Input buffer read ptr LSB != write ptr LSB ?
	JNZ	ENDPOL		; Exit polling loop if yes
	CMP	R2,R4		; Idem for MSB ?
	JNZ	ENDPOL		; Exit polling loop if yes
	JMP	POLL		; Polling loop

	; Exit polling loop
ENDPOL	CMP	%>00,R56	; Chars in buffer MSB
	JNZ	LF126		; exit ENDPOL loop if != 0
	CMP	%>00,R57	; Chars in buffer LSB
	JZ	ENDPOL		; loop if == 0

	; Exit ENDPOL loop
LF126	BTJZ	%>08,R11,LF133	; R11.3 == 1 (output buffer full or too high)? Jump if not
	CMP	%>01,R50	; Internal RAM ?
	; jump if yes
	JZ	CLBUF1		; Clear buffers if yes

	; wait reset of bit 3 of R11
W11B3	BTJO	%>08,R11,W11B3	; wait reset of bit 3 of R11 (output buffer low enough)
LF133	CALL	@ENCODE		; Encode text to allophones
	CMP	R7,R9		; Output buffer empty ?
	JZ	LF110		; jump to input buffer polling loop if yes
	ORP	%>01,P0		; enable INT1* (SP0256) to send output
	JMP	LF110		; jump to input buffer polling loop

	; Clear buffers
CLBUF1	BR	@CLBUF		; clear buffers - reinit

;==============================================================================

	; Init buffer pointers and regs
INIPTR	AND	%>00,R11	; R11 := 0 (why not CLR R11?)
	CLR	R55		; R55 := 0 (chars to free?)
	CLR	R56		; R56 := 0
	CLR	R57		; R57 := 0
	ORP	%>01,P6		; set P6.0 (DSR/BUSY)
	MOVD	R41,R3		; R2:3 := R40:41 (input buffer start)
	MOVD	R43,R7		; R6:7 := R42:43 (output buffer start)
	MOV	%>20,A		; A := $20
	STA	*R3		; *R2:3 := $20 (input buffer read ptr)
	CALL	@INCR3		; inc R2:3 and roll to R40:41 if == R42:43
	MOVD	R3,R5		; R4:5 := R2:3 (input buffer write ptr)
	PUSH	R3		; save pointers
	PUSH	R7
	PUSH	R6
	DEC	R3		; R6:7 := ( R6:7 - R2:3 + 1 ) = input buffer size
	SUB	R3,R7
	SBB	R2,R6
	MOVD	R7,R52		; R51:52 := input buffer size - 1
	DECD	R52
	TSTA			; = CLR C
	RRC	R6		; R6:7 /= 2
	RRC	R7
	MOVD	R7,R31		; R30:31 := buffer size / 2 (and clears C)
	RRC	R6		; R6:7 /= 2
	RRC	R7
	TSTA			; = CLR C
	RRC	R6		; R6:7 /= 2
	RRC	R7
	MOVD	R7,R33		; R32:33 := buffer size / 8
	POP	R6		; restore pointers
	POP	R7
	POP	R3
	MOVD	R7,R9		; R8:9 := R6:7 = output buffer write ptr
	MOVD	R3,R25		; R24:25 last delimiter ptr := R2:3 input buffer read ptr
	MOVD	R39,R54		; R53:54 := R38:39 = end RAM address + 1
	SUB	R43,R54		; R53:54 := ( R53:54 - R42:43 ) = output buffer size
	SBB	R42,R53
	MOVP	P4,B		; B := APORT
	AND	%>80,B		; APORT.7 set ? (Delimiter=any)
	CMP	%>00,B		; useful ?
	; Jump if not
	JZ	LF1A6
	OR	%>01,R11	; R11.0 := 1 if any delimiter
LF1A6	EINT			; enable interrupts
	RETS

;==============================================================================

	; "O-K\n"
STROK	TEXT	'O-K'
	BYTE	>0D

	; Say O.K.
SAYOK	AND	%>F9,R10	; Clear R10.1 and R10.2: Write to input buffer
	CLR	B
LF1B0	LDA	@STROK(B)	; Get char
	CALL	@STINPB		; Store char in input buffer
	INC	B		; next char
	CMP	%>04,B		; loop until 4 chars processed
	JNZ	LF1B0
	RETS			; return

;==============================================================================

	; INT4 handler (serial interrupt)
INT4	BTJOP	%>02,P17,INT3	; Jump if P17.1 (RXRDY) == 1
	RETI			; else return from interrupt

	; INT3 handler (parallel interrupt)
INT3	PUSH	A		; save A from interrupt
	BTJO	%>80,R10,LF1D1	; R10.7 (parallel mode) == 1 ? Jump if yes
	ANDP	%>FE,P16	; Reset P16.0 (disable serial INT4)
	; wait RXBUF ready with new character
WRXRDY	BTJZP	%>02,P17,WRXRDY	; wait RXBUF ready with new character
	MOVP	P22,A		; get A := RXBUF incoming character
	JMP	LF1D6		; handle incoming char in A

	; Parallel mode
LF1D1	ANDP	%>EF,P0		; Disable P0.0 = INT3*
	LDA	*R47		; Read char from parallel input ($0200)

	; Handle incoming char
LF1D6	CALL	@STINPB		; Store char in input buffer
	POP	A		; restore A from interrupt
	BTJO	%>20,R11,LF1E1	; R11.5 == 1 ? (input buffer full) skip next instr if yes
	CALL	@ENINT		; re-enable parallel or serial interrupt
LF1E1	RETI			; return from interrupt

;==============================================================================

	; Store char in input buffer
STINPB	PUSH	B		; Save registers
	PUSH	R10
	PUSH	R12
	PUSH	R13
	AND	%>F9,R10	; reset R10.1 and R10.2: write to input buffer
	CMP	%>1B,A		; <ESC> ? => clear buffers
	JNZ	NOTESC		; Skip if not

	; clear buffers - reinit
CLBUF	ANDP	%>FE,P0		; Disable INT1* (SP0256)
	CALL	@INIPTR		; Init buffer pointers and regs
	MOV	%>3A,B		; Init SP
	LDSP			;
	MOVD	R45,R27		; R26:27 := R44:45  (SP0256 device)
	STA	*R27		; *R26:27 := A  (SP0256 device)
	CALL	@ENINT		; Enable input interrupt (parallel or serial)
	BR	@POLL		; Polling loop

	; Not <ESC>
NOTESC	CMP	%>12,A		; <Ctrl-R> ? => backspace until last delimiter
	JNZ	NOTCTR		; Skip if not

	; Handle <Ctrl-R>
	BTJO	%>01,R11,LF21E	; R11.0 == 1 (any delimiter) ? Exit if yes
	SUB	R25,R3		; R2:3 (input buf read ptr) -= R24:25 (last delimiter)
	SBB	R24,R2		;	(may not work correctly if rolled...)
	SUB	R3,R52		; R51:52 (input buffer free size) -= R2:3
	SBB	R2,R51
	MOVD	R25,R3		; R2:3 := R24:25 (last delimiter position)
	MOV	%>01,R57	; input buffer counter LSB(why?) := 1
LF21E	BR	@XSTINP		; exit handler

	; Not <Ctrl-R>
NOTCTR	CMP	%>08,A		; <BkSp> ?
	JNZ	NOTBKS		; Skip if not

	; Handle <BkSp>
	CMP	R2,R4		; Input buffer pointers equal ?
	JNZ	LF22F
	CMP	R3,R5
	JZ	XSTINP		; If yes, exit handler
LF22F	PUSH	R3		; Save R2:3
	PUSH	R2
	MOVD	R5,R3		; R2:3 := R4:5 input buffer write ptr
	CALL	@DECR3		; dec R2:3 and roll if needed
	MOVD	R3,R5		; R4:5 := R2:3
	POP	R2		; restore R2:3
	POP	R3
	INC	R52		; Inc R51:52 input buffer free size
	JNC	XSTINP
	INC	R51
	JMP	XSTINP		; exit handler

	; Not <BkSp>: Handle other chars
NOTBKS	CMP	%>27,A		; ''' ?
	JZ	STOCHR		; Jump if yes
	CMP	%>7B,A		; higher than 'z' ?
	JP	DELIMT		; Jump if yes
	CMP	%>30,A		; '0'..'9' ?
	JN	DELIMT
	CMP	%>3A,A
	JN	STOCHR
	CMP	%>41,A		; >= 'A' ?
	JPZ	STOCHR

	; Delimiter (not letter/digit/')
DELIMT	BTJO	%>01,R11,LF267	; R11.0 set (any delimiter) ? Jump if yes
	CMP	%>0D,A		; <CR> ?
	JNZ	LF26A		; skip if not
	OR	%>10,R11	; R11.4 := 1 (found CR => exit idle loop)
LF267	MOVD	R3,R25		; R24:25 := R2:3 (last delimiter position)
LF26A	OR	%>80,A		; A.7 := 1 (set high bit)
	INC	R57		; Increment R56:57 (# of bytes in input buffer)
	JNC	STOCHR		; put char in buffer
	INC	R56

	; put char in buffer
STOCHR	CALL	@RWBUFR		; write char in buffer
	BTJZ	%>20,R11,XSTINP	; R11.5 set (inp buffer full)? if not exit handler
	MOV	%>8D,A		; A := <CR> + $80
	INC	R57		; Increment R56:57 (# of bytes in input buffer)
	JNC	LF281
	INC	R56
LF281	CALL	@RWBUFR		; write char in buffer
	; exit handler
XSTINP	POP	R13		; Restore registers
	POP	R12
	POP	R10
	POP	B
	RETS			; end of input char handling

;==============================================================================

	; R10:7 ? (enable INT3) : (enable INT4)
ENINT	BTJZ	%>80,R10,ENINT4	; enable INT4
	ORP	%>10,P0
	RETS

	; enable INT4
ENINT4	ORP	%>01,P16
	RETS

;==============================================================================

	; select input or output buffer and read/store byte in it
RWBUFR	BTJO	%>02,R10,RDBUF	; R10.1 set ? Jump if yes (read from either buffer)

	; write to input or output buffer
	BTJO	%>04,R10,WROBUF	; R10.2 set ? Jump if yes (output buffer)
	MOVD	R5,R13		; R12:13 := R4:5 input buffer write ptr
	DECD	R52		; Decrement # of free input buffer bytes
	JMP	WRBUF		; Store A in buffer

WROBUF	MOVD	R9,R13		; R12:13 := R8:9 output buffer write ptr
	DECD	R54		; Decr output buffer free size

	; Store byte A in buffer
WRBUF	STA	*R13		; *R12:13 := A (store byte in buffer)
	LDA	@>000D		; A := R13 (why using LDA?)
	ADD	%>01,R13	; Increment R12:13
	ADC	%>00,R12
	CALL	@ROLR13		; Roll R12:13 if needed
	BTJO	%>04,R10,WOBUFX	; R10.2 set ? Jump if yes (output buffer)
	MOVD	R13,R5		; R4:5 := R12:13 (inp buffer write ptr)
WRBUFX	CALL	@CHKBUF		; Check if inp or out buffer full or above HWM
	RETS			; return

WOBUFX	MOVD	R13,R9		; R8:9 := R12:13 (out buffer write ptr)
	JMP	WRBUFX		; Check buffer and return

	; read from input or output buffer
RDBUF	BTJO	%>04,R10,RDOBUF	; R10.2 set ? jump if yes (output buffer)

	; read from input buffer
	MOVD	R3,R13		; R12:13 := R2:3 input buffer read ptr
	BTJO	%>02,R11,RDBUF1	; R11.1 set ? Jump if yes
	INC	R55		; inc R55 if not... (Free bytes? TODO: clarify)
	JMP	RDBUF1		; Read byte

	; read from output buffer
RDOBUF	MOVD	R7,R13		; R12:13 := R6:7 out buffer read ptr
	INC	R54		; Inc R53:54 = Out free bytes? (TODO: clarify)
	JNC	RDBUF1
	INC	R53

	; Read byte from buffer
RDBUF1	LDA	*R13		; Read byte
	BTJO	%>04,R10,LF2F3	; R10.2 set ? jump if yes (out buffer)

	BTJZ	%>80,A,LF2F0	; Is high bit set ? Jump if not
	OR	%>01,R10	; R10.0 := A.7 = char high bit
	JMP	LF2F3

LF2F0	AND	%>FE,R10

	; Incr buffer read pointer
LF2F3	PUSH	A
	LDA	@>000D		; A := R13 (why?)
	ADD	%>01,R13	; increment R12:13
	ADC	%>00,R12
	CALL	@ROLR13		; Roll if needed
	BTJO	%>04,R10,ROBUFX	; jump if output buffer

	; update input buffer read ptr
	MOVD	R13,R3		; R2:3 := R12:13
	POP	A		; restore character
	RETS			; return

	; update output buffer read ptr
ROBUFX	MOVD	R13,R7		; R6:7 := R12:13
	CALL	@CKOBUF		; Check if output buffer full or above HWM
	POP	A		; restore allophone
	RETS

;==============================================================================

	; Roll R12:R13 according to active buffer (R10.2)
	; - if R10.2 set (output buffer active):
	;	to R42:43 (out buffer start) if reached R38:39 (out buffer end)
	; - if R10.2 not set (input buffer active):
	;	to R40:41 (in buffer start)  if reached R42:43 (in buffer end)
ROLR13	BTJO	%>04,R10,ROLOUT	; Roll output buffer
	; Roll input buffer
ROLINP	CMP	R43,R13
	JNZ	LF322
	CMP	R42,R12
	JNZ	LF322
	MOVD	R41,R13
LF322	RETS

	; Roll output buffer
ROLOUT	CMP	R39,R13
	JNZ	LF330
	CMP	R38,R12
	JNZ	LF330
	MOVD	R43,R13
LF330	RETS

;==============================================================================

	; Check if inp or out buffer full or above HWM
CHKBUF	BTJZ	%>04,R10,CKIBUF	; Send XON/XOFF if needed

	; Check if output buffer full or above high water mark
CKOBUF	CMP	%>01,R53	; Only 1 free byte in output buffer ?
	JZ	LF343		; jump if yes
	CMP	R50,R54		; R54>R50 ? (output counter >= HWM ?)
	JP	LF343		; jump if yes
	OR	%>08,R11	; set R11.3 (output buffer full)
	RETS

LF343	AND	%>F7,R11	; reset R11.3 (output buffer not full)
	RETS

	; Check if input buffer full or above high water mark
CKIBUF	CMP	%>00,R51	; Free bytes in input buffer ?
	JP	LF356		; jump if yes
	CMP	%>01,R52
	JP	LF356
	OR	%>20,R11	; set R11.5 (input buffer full)
	JMP	TXOFF		; Send XOFF, clear DTR/BUSY*

	; Input buffer not full
LF356	CMP	R30,R51		; R50:51 inp buf free bytes < 1/2 size ?
	JN	LF362		; Jump if yes
	JP	TXON		; Else send XON, set DTR/BUSY*
	CMP	R31,R52
	JPZ	TXON
LF362	CMP	R32,R51		; R50:51 inp buf free bytes < 1/8 size ?
	JP	LF384		; Jump if not
	JN	LF36E		; Else Send XOFF, clear DTR/BUSY*
	CMP	R33,R52
	JP	LF384

LF36E	OR	%>04,R11	; set R11.2: input buffer above HWM

	; Send XOFF, clear DTR/BUSY*
TXOFF	ANDP	%>FE,P6		; clear P6.0 (DSR/BUSY=true)
	MOVP	%>13,P23	; TXBUF := XOFF
	RETS

	; Send XON, set DTR/BUSY*
TXON	AND	%>DB,R11
	CALL	@ENINT		; R10:7 = parallel mode ? (enable INT3) : (enable INT4)
	ORP	%>01,P6		; set P6.0 (DSR/BUSY=false)
	MOVP	%>11,P23	; TXBUF := XON
LF384	RETS			; Return

;==============================================================================

	; INT1 handler (SP0256)
INT1	ANDP	%>FE,P0		; Disable P0.0 = INT1*
	PUSH	A		; save regs
	PUSH	B
	PUSH	R10
	PUSH	R12
	PUSH	R13
	OR	%>06,R10	; select "read from output buffer"
	CALL	@RWBUFR		; do the read
	MOVD	R45,R27		; R26:27:= R44:45 SP0256 base address
	ADD	R0,R27		; Add allophone code to the address
	STA	*R27		; Write any byte to that address (value doesn't care)
	POP	R13		; restore regs
	POP	R12
	POP	R10
	POP	B
	POP	A
	CMP	R7,R9		; Buffer empty ?
	JZ	LF3AE		; skip if yes
	ORP	%>01,P0		; else enable P0.0 = INT1*
LF3AE	RETI			; return from interrupt

;==============================================================================

	; select rules set
SELRUL	CMP	%>30,A
	JPZ	LF3B5
	JMP	LF3DF		; < '0' => rules for punctuation

LF3B5	CMP	%>3A,A
	JPZ	LF3C1
	MOVD	%RULNUM,R21	; Rules for digits
	AND	%>DF,R10	; Non-letters rules
	RETS

LF3C1	CMP	%>41,A
	JPZ	LF3C7
	JMP	LF3DF

LF3C7	CMP	%>5B,A
	JPZ	LF3CF
	OR	%>20,R10	; Letters rules
	RETS

LF3CF	CMP	%>61,A
	JPZ	LF3D5
	JMP	LF3DF

LF3D5	CMP	%>7B,A
	JPZ	LF3DF
	SUB	%>20,A
	OR	%>20,R10	; Letters rules
	RETS

LF3DF	AND	%>DF,R10	; Non-letters rules
	MOVD	%RLPNCT,R21	; Rules for punctuation
	RETS

;==============================================================================

	; Encode text to allophones
ENCODE	CMP	%>00,R48	; EPROM active ?
	; Skip if not
	JZ	LF3EE
	BR	*R49		; Jump in EPROM

LF3EE	MOVD	R3,R17		; R16:17 := R2:3 (backward input buffer read ptr)
	CALL	@DECR17		; dec R16:17 and roll if needed
LF3F4	CALL	@FETCH		; Fetch char and mask high bit
	BTJZ	%>01,R10,LF400	; R11.7 := R10.0 (character high bit)
	OR	%>80,R11
	JMP	LF403

LF400	AND	%>7F,R11
LF403	CALL	@SELRUL		; select rules set
	BTJZ	%>20,R10,LF41B	; R10.5 set (rules for letters) ? jump if no

	CLR	B		; useful?
	SUB	%>41,A		; A -= 'A'
	MPY	%>02,A		; AB := A * 2
	ADD	%>02,B		; B += 2
	LDA	@TABRUL(B)	; Index of rules tables
	MOV	A,R20		; R20 := MSB of letter rules table
	LDA	@TABRU1(B)	; Index of rules tables LSB
	MOV	A,R21		; R21 := LSB of letter rules table

LF41B	MOV	%>01,B		; B := 1 (number of '[') to seek
	CALL	@RSEEKB		; right seek 1st '['

	; Compare chars between [ ]
LF420	CALL	@CMPBKT		; compare in-brackets
	BTJO	%>10,R10,LF467	; R10.4 set (match failed) ? Jump if yes

	; Check patterns after ]
	MOVD	R17,R29		; R28:29 := R16:17 (save backward input buffer read ptr)
	AND	%>BF,R10	; clear R10.6 (read input using R2:3)
	CALL	@CHKPAT		; Check rule pattern
	BTJO	%>10,R10,LF467	; R10.4 set (match failed) ? Jump if yes

	; Check patterns before [
	CALL	@LSEEKB		; left seek '['
	OR	%>40,R10	; set R10.6 (read input using R16:17)
	CALL	@CHKPAT		; Check rule pattern
	BTJO	%>10,R10,LF47A	; R10.4 set (match failed) ? Jump if yes

	; Matching Rule found
	ADD	R55,R52		; R51:52 += R55 (free preceding chars?)
	ADC	%>00,R51
	CLR	R55		; no more chars to free

	; Seek allophones to output
	AND	%>FD,R11	; clear R11.1 (allow to count chars to free in R55)
	MOV	%>02,B		; B := 2 (number of '[') to seek
	CALL	@RSEEKB		; right seek 2nd '[' => 1st allophone

	; Write allophones
	CALL	@WRALLO		; Write allophones

	; Next input character
	MOVD	R15,R3		; R2:3 := R14:15 - restore input buffer read ptr
	MOVD	R3,R17		; R16:17 := R2:3 - copy to backward input buffer read ptr
	CALL	@DECR17		; dec R16:17 and roll to R36:37 if == R34:35
	BTJZ	%>80,R11,LF3F4	; High bit of char was set (final?) ? Jump if not

	; Finalize and return
	DECD	R57		; dec R56:57 (number of bytes in input buffer?)
	CALL	@CKIBUF		; Check if input buffer full or above high water mark
	RETS			; return

	; Match failed after opening [ => seek next rule
LF467	INC	R21		; inc R20:21 rule pointer
	JNC	LF46D
	INC	R20
LF46D	MOV	%>02,B		; B := 2 (number of '[') to seek

	; Seek next rule opening [
LF46F	CALL	@RSEEKB		; right seek 2nd or 3rd '[' => next pattern '['
	MOV	%>01,R55	; R55 := 1 (one char to free?)
	AND	%>FD,R11	; clear R11.1 (allow to count chars to free in R55)
	JMP	LF420		; check next rule

	; Match failed before opening [ => seek next rule
LF47A	MOV	%>03,B		; B := 3 (number of '[') to seek
	JMP	LF46F		; right seek 3rd '[' and check next rule

;==============================================================================

	; left seek '['
LSEEKB	LDA	*R21		; A := *R20:21
	BTJZ	%>40,A,LF484	; A.6 set ('[' found) ? jump if not
	RETS			; else return

LF484	DECD	R21		; dec R20:21
	JMP	LSEEKB		; and loop

;==============================================================================

	; right seek Bth '['
RSEEKB	CLR	R23		; R23 := 0

LF48A	LDA	*R21		; A := *R20:21
	BTJZ	%>40,A,LF496	; A.6 set ('[' found) ? jump if not
	INC	R23		; inc R23
	CMP	R23,B		; jump if R23 != B
	JNZ	LF496
	RETS			; else return: found

LF496	INC	R21		; inc R20:21
	JNC	LF49C
	INC	R20
LF49C	JMP	LF48A		; and loop

;==============================================================================

	; Write allophones
WRALLO	CLR	R23		; R23 := 0
	LDA	*R21		; A := *R20:21
	CMP	%>FF,A		; A == $FF ?
	JZ	LF4C1		; jump if yes
	BTJZ	%>80,A,LF4AB	; A.7 set (']' found) ? jump if not
	INC	R23		; else inc R23
LF4AB	AND	%>3F,A		; mask A.6 and A.7
	AND	%>FD,R10	; clear R10.1 (write in buffer)
	OR	%>04,R10	; set R10.2 (output buffer)
	CALL	@RWBUFR		; write allophone in buffer
	INC	R21		; inc R20:21
	JNC	LF4BC
	INC	R20
LF4BC	CMP	%>01,R23	; ']' found ?
	JNZ	WRALLO		; loop if not
LF4C1	RETS			; else return

;==============================================================================

	; compare in-brackets
CMPBKT	MOVD	R3,R19		; R18:19 := R2:3 (input read ptr)
	AND	%>F7,R10	; clear R10.3
	BTJZ	%>20,R10,LF4D4	; R10.5 letter rules? jump if not
	LDA	*R21		; A := *R20:21
	CMP	%>FF,A		; A == $FF ? (single letter/end of rules)
	JNZ	LF4DD		; jump if not to letter rules
	JMP	LF502		; else exit (success)

	; not letter rules
LF4D4	CMP	%>FF,A		; A == $FF ?
	JZ	LF502		; exit if yes (success)
	CALL	@DECR3		; dec R2:3 and roll if needed
	DEC	R55		; dec R55 (chars to free?)

	; letter rules
LF4DD	CALL	@FETCH		; Fetch char and mask high bit
	CMP	%>61,A		; lower case ?
	JN	LF4E6		; skip if not
	SUB	%>20,A		; else adjust to upper case
LF4E6	SUB	%>20,A		; adjust to range 00-3F
	MOV	A,B		; B := A
	LDA	*R21		; A := *R20:21
	BTJZ	%>80,A,LF4F1	; A.7 set (']' found) ? Skip if not
	OR	%>08,R10	; else set R10.3
LF4F1	AND	%>3F,A		; mask A.6 and A.7
	CMP	R0,B		; A == B ?
	JZ	LF4FE		; jump if yes
	OR	%>10,R10	; set R10.4: pattern match failed
	MOVD	R19,R3		; R2:3 := R18:19
	RETS			; return (failed)

LF4FE	BTJZ	%>08,R10,LF50C	; R10.3 set (']' found) ? Jump if not

	; pattern match successful
LF502	MOVD	R3,R15		; R14:15 := R2:3 - save input buffer read ptr
	AND	%>EF,R10	; clear R10.4: pattern match successful
	OR	%>02,R11	; set R11.1 - forbid to count chars to free in R55 ?
	RETS			; return

LF50C	INC	R21		; inc R20:21
	JNC	LF4DD
	INC	R20
	JMP	LF4DD		; and loop: check next char

;==============================================================================

	; Get letter flags
GFLAGS	MOV	R22,B
	CMP	%>3A,B
	JP	GFLAGX
	CMP	%>21,B
	JN	GFLAGX
	SUB	%>21,B
	LDA	@LTFLGS(B)	; Letter flags
	RETS

GFLAGX	CLR	A
	RETS

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
LTFLGS	BYTE	>80		; A 1000 0000 - EPROM sig check begin
	BYTE	>48		; B 0100 1000
	BYTE	>28		; C 0010 1000
	BYTE	>58		; D 0101 1000
	BYTE	>85		; E 1000 0101 - EPROM sig check end
	BYTE	>08		; F 0000 1000
	BYTE	>68		; G 0110 1000
	BYTE	>08		; H 0000 1000
	BYTE	>84		; I 1000 0100
	BYTE	>78		; J 0111 1000
	BYTE	>08		; K 0000 1000
	BYTE	>58		; L 0101 1000
	BYTE	>48		; M 0100 1000
	BYTE	>58		; N 0101 1000
	BYTE	>82		; O 1000 0010
	BYTE	>08		; P 0000 1000
	BYTE	>08		; Q 0000 1000
	BYTE	>58		; R 0101 1000
	BYTE	>38		; S 0011 1000
	BYTE	>18		; T 0001 1000
	BYTE	>82		; U 1000 0010
	BYTE	>48		; V 0100 1000
	BYTE	>48		; W 0100 1000
	BYTE	>28		; X 0010 1000
	BYTE	>84		; Y 1000 0100
	BYTE	>78		; Z 0111 1000

;==============================================================================

	; Pattern jump table
PATBRT	BR	@PATVOW		; #	09	1+ vowels

	BR	@PATVOC		; .	0A	voiced consonant: B D G J L M N R V W X

	BR	@PATSUF		; %	0B	suffix: -ER(S) -E -ES -ED -ELY -ING -OR -MENT

	BR	@PATSIB		; &	0C	sibilant: S C G Z X J CH SH

	BR	@PATPLU		; @	0D	T S R D L Z N J TH CH SH preceding long U

	BR	@PAT1CO		; ^	0E	1 consonant only

	BR	@PATFVO		; +	0F	front vowel: E I Y

	BR	@PAT0MC		; :	10	0+ consonants

	BR	@PAT1MC		; *	11	1+ consonants

	BR	@PATBVO		; >	12	back vowel: O U

	BR	@PATNLT		; <	13	Anything other than a letter

	BR	@PAT2MV		; ?	14	2+ vowels

;==============================================================================

	; Check rule pattern
CHKPAT	BTJO	%>40,R10,LF572	; R10.6 set (scan direction left) ? jump if yes
	MOV	%>40,B		; '[' mask
	INC	R21		; inc R20:21 rule ptr
	JNC	LF570
	INC	R20
LF570	JMP	LF576		; proceed

LF572	MOV	%>80,B		; ']' mask
	DECD	R21		; dec R20:21 rule ptr

	; check if boundary has been reached
LF576	LDA	*R21		; get rule char
	BTJZ	B,A,LF58C	; is '[' or ']' ? jump if not
	BTJO	%>40,R10,LF582	; R10.6 set (scan direction left) ? jump if yes
	DECD	R21		; dec R20:21 rule ptr
	JMP	LF588

LF582	INC	R21		; inc R20:21 rule ptr
	JNC	LF588
	INC	R20
LF588	AND	%>EF,R10	; clear R10.4 rule pattern match failed
	RETS			; return

	; check rule char
LF58C	CALL	@GNEXT		; get next input char and move code to range 00-3F
	LDA	*R21		; A := *R20:21 - load rule char
	CMP	%>15,A		; A < $15 ? (pattern symbol)
	JN	LF5A4		; jump if yes
LF595	CMP	R0,R22		; otherwise compare input char with rule char
	JZ	CHKPAT		; continue with next char if both chars match

	; pattern match failed
PATFLD	OR	%>10,R10	; set R10.4 - match failed
	MOVD	R19,R3		; R2:3 := R18:19 - restore input ptr
	MOVD	R29,R17		; R16:17 := R28:29 - restore backward input ptr
	RETS			; return (failed)

	; check rule pattern symbol
LF5A4	CMP	%>07,A		; is a "'" ?
	JZ	LF595		; jump if yes
	; compute pattern symbol handler address
	MOV	A,B		; B := A
	SUB	%>09,B		; B -= 9
	MPY	%>03,B		; B *= 3
	BR	@PATBRT(B)	; Branch to PATBRT + B

	; <	13	Anything other than a letter
PATNLT	CALL	@GFLAGS		; Get letter flags
	CMP	%>00,A		; Is a letter ?
	JZ	PATOK1		; Accept if yes
	JMP	PATFLD		; else pattern match failed

	; *	11	1+ consonants
PAT1MC	CALL	@GFLAGS		; Get letter flags
	BTJO	%>08,A,LF5C1	; Is a consonant ? Jump if yes
	JMP	PATFLD		; else pattern match failed

LF5C1	CALL	@GNEXT		; get next char and move code to range 00-3F
	CALL	@GFLAGS		; Get letter flags
	BTJO	%>08,A,LF5C1	; Is a consonant ? Loop until not
	JMP	LF5FB		; Unget and Accept rule

	; ?	14	2+ vowels
PAT2MV	CALL	@GFLAGS		; Get letter flags
	BTJO	%>80,A,LF5D4	; Vowel flag ? Jump if yes
	JMP	PATFLD		; pattern match failed

LF5D4	CALL	@GNEXT		; get next char and move code to range 00-3F
	CALL	@GFLAGS		; Get letter flags
	BTJO	%>80,A,LF5DF	; Vowel flag ? Jump if yes
	JMP	PATFLD		; pattern match failed

LF5DF	CALL	@GNEXT		; get next char and move code to range 00-3F
	CALL	@GFLAGS		; Get letter flags
	BTJO	%>80,A,LF5DF	; Vowel flag ? Loop until not
	JMP	LF5FB		; Unget and accept rule

	; :	10	0+ consonants
PAT0MC	CALL	@GFLAGS		; Get letter flags
	BTJO	%>08,A,LF5F2	; Consonant ? Jump if yes
	JMP	LF5FB		; else unget and accept rule

LF5F2	CALL	@GNEXT		; get next char and move code to range 00-3F
	CALL	@GFLAGS		; Get letter flags
	BTJO	%>08,A,LF5F2	; Is a consonant ? Loop until not

	; Unget and accept rule
LF5FB	CALL	@UNGET		; Unget last input character

	; pattern match ok
PATOK1	BR	@CHKPAT		; Check next rule pattern

	; %	0B	suffix: -ER(S) -E -ES -ED -ELY -ING -OR -MENT
PATSUF	CALL	@GFLAGS		; Get letter flags
	BTJO	%>01,A,LF657	; Suffix flag ('E') ? Jump if yes
	CMP	%>29,R22	; 'I' ?
	JZ	LF63C		; Jump if yes
	CMP	%>2D,R22	; 'M' ?
	JZ	LF618		; Jump if yes
	CMP	%>2F,R22	; 'O' ?
	JZ	LF633		; jump if yes
	JMP	PATFL1		; pattern match failed

	; found 'M'
LF618	CALL	@FETCH		; Fetch char and mask high bit
	CMP	%>45,A		; 'E' ?
	JZ	LF621		; jump if yes
	JMP	PATFL1		; pattern match failed

	; found 'ME'
LF621	CALL	@FETCH		; Fetch char and mask high bit
	CMP	%>4E,A		; 'N' ?
	JZ	LF62A		; jump if yes
	JMP	PATFL1		; pattern match failed

	; found 'MEN'
LF62A	CALL	@FETCH		; Fetch char and mask high bit
	CMP	%>54,A		; 'T'
	JZ	LF64E		; jump if yes, suffix -MENT found
	JMP	PATFL1		; pattern match failed

	; Found 'O'
LF633	CALL	@FETCH		; Fetch char and mask high bit
	CMP	%>52,A		; 'R' ?
	JZ	LF64E		; jump if yes, suffix -OR found
	JMP	PATFL1		; pattern match failed

	; Found 'I'
LF63C	CALL	@FETCH		; Fetch char and mask high bit
	CMP	%>4E,A		; 'N' ?
	JZ	LF645		; jump if yes
	JMP	PATFL1		; pattern match failed

	; found 'IN'
LF645	CALL	@FETCH		; Fetch char and mask high bit
	CMP	%>47,A		; 'G' ?
	JZ	LF64E		; jump if yes, suffix -ING found
	JMP	PATFL1		; pattern match failed

	; Suffix found
LF64E	CALL	@CHKLTR		; Check if next input char is a letter
	BTJO	%>20,R10,PATFL1	; pattern match failed
	JMP	PATOK2		; Accept rule

	; found 'E'
LF657	CALL	@FETCH		; Fetch char and mask high bit
	CMP	%>52,A		; 'R' ?
	JNZ	LF66A		; jump if not
	CALL	@FETCH		; Fetch char and mask high bit
	CMP	%>53,A		; 'S' ? (optional plural)
	JZ	LF64E		; jump if yes, suffix -ERS found
	CALL	@DECR3		; dec R2:3 and roll if needed
	JMP	LF64E		; suffix -ER found

LF66A	CMP	%>53,A		; 'S'
	JZ	LF64E		; jump if yes, suffix -ES found
	CMP	%>44,A		; 'D'
	JZ	LF64E		; jump if yes, suffix -ED found
	CMP	%>4C,A		; 'L'
	JZ	LF682		; jump if yes
	CALL	@DECR3		; dec R2:3 and roll if needed
				; suffix -E found
	CALL	@CHKLTR		; Check if next input char is a letter
	BTJZ	%>20,R10,PATOK2	; Jump if R10.5 unset (not a letter => OK)
	JMP	PATFL1		; pattern match failed

	; found 'EL'
LF682	CALL	@FETCH		; Fetch char and mask high bit
	CMP	%>59,A		; 'Y' ?
	JZ	LF64E		; jump if yes, suffix -ELY found

	; pattern match failed
PATFL1	BR	@PATFLD		; pattern match failed

	; Test if next input char is a letter, R10.5=1 if yes
CHKLTR	CALL	@FETCH		; Fetch char and mask high bit
	PUSH	R21		; save R20:21
	PUSH	R20
	CALL	@SELRUL		; select rules set, test if letter rule
	POP	R20		; restore R20:21
	POP	R21
	CALL	@DECR3		; dec R2:3 and roll if needed
	RETS			; return R10.5=1 if letter

	; #	09	1+ vowels
PATVOW	CALL	@GFLAGS		; Get letter flags
	BTJO	%>80,A,LF6A6	; Vowel flag ? Jump if yes
	JMP	PATFL1		; pattern match failed

LF6A6	CALL	@GNEXT		; get next char and move code to range 00-3F
	CALL	@GFLAGS		; Get letter flags
	BTJO	%>80,A,LF6A6	; Vowel flag ? Loop until not
	CALL	@UNGET		; Unget input character
	JMP	PATOK2		; Accept rule

	; .	0A	voiced consonant: B D G J L M N R V W X
PATVOC	CALL	@GFLAGS		; Get letter flags
	BTJO	%>40,A,PATOK2	; Voiced consonant flag ? Accept if yes
	JMP	PATFL1		; pattern match failed

PATOK2	BR	@CHKPAT		; Check rule pattern

	; ^	0E	1 consonant only
PAT1CO	CALL	@GFLAGS		; Get letter flags
	BTJO	%>08,A,PATOK2	; Consonant flag ? Accept if yes
	JMP	PATFL1		; pattern match failed

	; +	0F	front vowel: E I Y
PATFVO	CALL	@GFLAGS		; Get letter flags
	BTJO	%>04,A,PATOK2	; Front vowel flag ? Accept if yes
	JMP	PATFL1		; pattern match failed

	; >	12	back vowel: O U
PATBVO	CALL	@GFLAGS		; Get letter flags
	BTJO	%>02,A,PATOK2	; Back vowel flag ? Accept if yes
	JMP	PATFL1		; pattern match failed

	; &	0C	sibilant: S C G Z X J CH SH
PATSIB	CALL	@GFLAGS		; Get letter flags
	BTJO	%>20,A,PATOK2	; Sibilant flag ? Accept if yes
	CALL	@GNEXT		; get next char and move code to range 00-3F
	JMP	LF6F0

	; @	0D	T S R D L Z N J TH CH SH preceding long U
PATPLU	CALL	@GFLAGS		; Get letter flags
	BTJO	%>10,A,PATOK2	; Letter influencing long U flag ? Accept if yes
				; (Could have checked for 'H' here...)
	CALL	@GNEXT		; get next char and move code to range 00-3F
	CMP	%>34,R22	; 'T' ?
	JZ	LF6FC		; jump if yes
LF6F0	CMP	%>23,R22	; 'C' ?
	JZ	LF6FC		; jump if yes
	CMP	%>33,R22	; 'S' ?
	JZ	LF6FC		; jump if yes
	JMP	PATFL1		; pattern match failed

	; check for TH, SH or SH
LF6FC	MOVD	R17,R3		; R2:3 := R16:17
	CALL	@INCR3		; inc R2:3 and roll if needed
	CALL	@INCR3		; inc R2:3 and roll if needed
	CALL	@FETCH		; Fetch char and mask high bit
	CMP	%>48,A		; 'H'
	JZ	PATOK2		; Accept if yes
	BR	@PATFLD		; pattern match failed

;==============================================================================

	; Fetch char and mask high bit
FETCH	OR	%>02,R10	; R10.1 = 1 - sel buffer read mode
	AND	%>FB,R10	; R10.2 = 0 - sel input buffer
	CALL	@RWBUFR		; read in input buffer
	AND	%>7F,A		; mask high bit of char
	RETS			; return

;==============================================================================

	; inc R16:17 and roll if needed
INCR17	INC	R17		; inc R16:17
	JNC	LF721
	INC	R16
LF721	MOVD	R17,R13		; R12:13 := R16:17
	CALL	@ROLINP		; Roll input buffer R12:13
	MOVD	R13,R17		; R16:17 := R12:13
	RETS

;==============================================================================

	; inc R2:3 and roll if needed
INCR3	INC	R3		; inc R2:3
	JNC	LF731
	INC	R2
LF731	MOVD	R3,R13		; R12:13 := R2:3
	CALL	@ROLINP		; Roll input buffer R12:13
	MOVD	R13,R3		; R2:3 := R12:13
	RETS

;==============================================================================

	; dec R2:3 and roll if needed
DECR3	DECD	R3		; dec R2:3
	CMP	R35,R3		; before input buffer start ?
	JNZ	LF74A
	CMP	R34,R2
	JNZ	LF74A		; jump if not
	MOVD	R37,R3		; roll to input buffer end
LF74A	RETS			; return

;==============================================================================

	; dec R16:17 and roll if needed
DECR17	DECD	R17		; dec R16:17
	CMP	R35,R17		; before input buffer start ?
	JNZ	LF75A
	CMP	R34,R16
	JNZ	LF75A		; jump if not
	MOVD	R37,R17		; roll to input buffer end
LF75A	RETS			; return

;==============================================================================

	; get next char and move code to range 00-3F
GNEXT	BTJZ	%>40,R10,LF766	; R10.6 set ? jump if not
	PUSH	R3		; else save R2:3
	PUSH	R2
	MOVD	R17,R3		; and move R16:17 to R2:3
LF766	CALL	@FETCH		; Fetch char and mask high bit
	BTJZ	%>40,R10,LF774	; R10.6 set ? jump if not
	CALL	@DECR17		; else dec R16:17 and roll if needed
	POP	R2		; and restore R2:3
	POP	R3
LF774	CMP	%>61,A		; lower case ?
	JN	LF77A		; jump if not
	SUB	%>20,A		; change to upper case
LF77A	SUB	%>20,A		; shift to range 00-3F
	MOV	A,R22		; store in R22
	RETS			; return

;==============================================================================

	; Unget last input character
UNGET	BTJO	%>40,R10,LF787	; R10.6 set ? jump if yes
	CALL	@DECR3		; dec R2:3 (input buffer read ptr) and roll if needed
	RETS

LF787	CALL	@INCR17		; inc R16:17 (backward input buffer read ptr) and roll if needed
	RETS


;==============================================================================

	BYTE	>FF		; boundary

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
PARLINP	EQU	>0200		; Memory-mapped parallel input from Host
SP0256	EQU	>2000		; Memory-mapped parallel output to SP0256A-AL2
CTSXRAM	EQU	>3000		; CTS-256A External RAM origin
;==============================================================================

	END	CTS256

;==============================================================================

