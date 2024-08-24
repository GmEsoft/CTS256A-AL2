# CTS256A-AL2

## Commented disassembly of the GI(tm) CTS256A-AL2(tm) Code-To-Speech Processor

The CTS256A-AL2 is an 8-bit microcomputer programmed to create text-to-allophone address sequences, in flexible and cost effective manner. It sources the SP0256A-AL2 which is a speech synthesizer whose output drives an audio amplifier to produce speech output.

Input of the CTS256A-AL2 is standard English ASCII characters, which makes connecting to a stand-alone terminal or any personal computer simple.


### Files:
- `CTS256A.ASM` Disassembled and commented source of the ROM contained in the PIC7040 Microcontroller (based on TI TMS7042 MCU);
- `CTS256A.LST` Listing of the assembly of `CTS256A.ASM`;
- `CTS256A.PRN` Raw disassembly listing of the ROM contained in the PIC7040 Microcontroller (based on TI TMS7042 MCU);
- `CTS256A.BIN` Binary image of the ROM (address range $F000-$FFF);
- `RULES.TXT`   Extracted rules used to convert the text to SP0256 allophones;
- `extract_rules.c` C program to extract the CTS rules from the ROM image;
- `CTS256A.SCR` Screening file for the disassembler;
- `CTS256A.EQU` Equates file for the disassembler;
- `DASM7000.EXE` TMS7000 series disassembler.


### Oddities

While studying the CTS256A-AL2 module I found a number of oddities:
- The module doesn't handle the lower case letters properly. For example, "rider." in lower case generates `{[R]=[RR1]} {[I]=[IH]}
{[D]=[PA2 DD2]} {[ER]=[ER1]} {[.]=[PA5 PA5]}` whereas "RIDER." in upper case generates `{[R]=[RR1]} {[I]^%=[AY]} {[D]=[PA2 DD2]}
{[ER]=[ER1]} {[.]=[PA5 PA5]}`. I found that the `FETCH` routine in the ROM does not perform the conversion to upper case. The
conversion is done in `GNEXT`, which calls `FETCH`. But in the pattern check routines, `FETCH` is directly called, so the lower case
chars are not converted.
- When I converted the rules to plain text, I found a pattern symbol '$1F' (symbolized as '$') that is not
recognized by the encoding routine in the ROM. I suspect that the rule `[I]$% = [AY]` is wrongly encoded, and should be in fact
`[I]D% = [AY]`, if I refer to the original
[document from the Naval Research Laboratory](https://apps.dtic.mil/sti/pdfs/ADA021929.pdf):
	````
	[IZ]%=/AY Z/
	[IS]%=/AY Z/
	[I]D%=/AY/
	+^[I]^+=/IH/
	[I]T%=/AY/
	#^:[I]^+=/IH/
	````
  And the corresponding rules extracted from the CTS256A-AL2 ROM:
	````
	[IZ]% = [AY ZZ]
	[IS]% = [AY ZZ]
	[I]$% = [AY]		; and not [I]D% = [AY]
	+^[I]^+ = [IH]
	[I]T% = [AY]
	#*[I]^+ = [IH]
	````

### Credits

Frank Palazzolo, who designed an extractor to dump the masked ROMs of TMS7000-based devices, and published
the ROM binary image `cts256a.bin`: https://github.com/palazzol/TMS7xxx_dumper

