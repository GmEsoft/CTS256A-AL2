# CTS256A-AL2

## Commented disassembly of the GI(tm) CTS256A-AL2(tm) Code-To-Speech Processor

The CTS256A-AL2 is an 8-bit microcomputer programmed to create text-to-allophone address sequences, in flexible and cost effective manner. It sources the SP0256A-AL2 which is a speech synthesizer whose output drives an audio amplifier to produce speech output.

Input of the CTS256A-AL2 is standard English ASCII characters, which makes connecting to a stand-alone terminal or any personal computer simple.

### Files:
- `CTS256A.ASM` Disassembled and commented source of the ROM contained in the PIC7040 Microcontroller (based on TI TMS7042 MCU);
- `CTS256A.PRN` Raw disassembly listing of the ROM contained in the PIC7040 Microcontroller (based on TI TMS7042 MCU);
- `CTS256A.BIN` Binary image of the ROM (address range $F000-$FFF);
- `RULES.TXT`   Extracted rules used to convert the text to SP0256 allophones;
- `extract_rules.c` C program to extract the CTS rules from the ROM image;
- `CTS256A.SCR` Screening file for the disassembler;
- `CTS256A.EQU` Equates file for the disassembler;
- `DASM7000.EXE` TMS7000 series disassembler.
