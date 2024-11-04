unit
  DPMI;

interface

type
  TRealModeRegs = record
    case Integer of
      0: (
        EDI, ESI, EBP, EXX, EBX, EDX, ECX, EAX: Longint;
        Flags, ES, DS, FS, GS, IP, CS, SP, SS: Word);
      1: (
        DI, DIH, SI, SIH, BP, BPH, XX, XXH: Word;
        case Integer of
          0: (
            BX, BXH, DX, DXH, CX, CXH, AX, AXH: Word);
          1: (
            BL, BH, BLH, BHH, DL, DH, DLH, DHH,
            CL, Ch, CLH, CHH, AL, AH, ALH, AHH: Byte));
  end;

procedure RealModeInt (Int: Byte; var Regs: TRealModeRegs);

implementation

{
----------310300-----------------------------
INT 31 - DPMI 0.9 API - protected mode - SIMULATE REAL MODE INTERRUPT
	AX = 0300h
	BL = interrupt number
	BH = flags
	    bit 0: reset the interrupt controller and A20 line
	    others must be 0
	CX = number of words to copy from protected mode to real mode stack
	ES:DI / ES:EDI = selector:offset of real mode call structure
			(see below)
Return: CF set on error
	CF clear if successful
	    real mode call structure modified (all fields except SS:SP, CS:IP
	      filled with return values from real mode interrupt)
	protected mode stack unchanged
Notes:	16-bit programs use ES:DI as pointer, 32-bit programs use ES:EDI
	CS:IP in the real mode call structure is ignored for this call,
	  instead, the indicated interrupt vector is used for the address
	the flags in the call structure are pushed on the real mode stack to
	  form an interrupt stack frame, and the trace and interrupt flags are
	  clear on entry to the handler
	DPMI will provide a small (30 words) real mode stack if SS:SP is zero
	the real mode handler must return with the stack in the same state as
	  it was on being called
SeeAlso: AX=0302h

Format of real mode call structure:
Offset	Size	Description
 00h	DWORD	EDI
 04h	DWORD	ESI
 08h	DWORD	EBP
 0Ch	DWORD	reserved
 10h	DWORD	EBX
 14h	DWORD	EDX
 18h	DWORD	ECX
 1Ch	DWORD	EAX
 20h	WORD	flags
 22h	WORD	ES
 24h	WORD	DS
 26h	WORD	FS
 28h	WORD	GS
 2Ah	WORD	IP
 2Ch	WORD	CS
 2Eh	WORD	SP
 30h	WORD	SS
}

procedure RealModeInt; assembler;
asm
  mov  ax, 0300h
  mov  bl, Int
  xor  bh, bh
  xor  cx, cx
  les  di, Regs
  int  31h
end;

end.
