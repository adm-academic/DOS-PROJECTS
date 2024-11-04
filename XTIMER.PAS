Unit XTIMER;

INTERFACE
Var elapsed: Longint; { прошедшее время, в милисекундах. }
Procedure ClockOn;    { включает счётчик времени }
Procedure ClockOff;   { выключает его }
Procedure PrintTime;  { выводит прошедшее время }

IMPLEMENTATION

{uses CRT;}
const Seg0040: word=$0040; { constant of CRT module }

var start:longint;

{ Copyright (c) 1989-1993 Norbert Juffa }
FUNCTION Clock: LONGINT; ASSEMBLER; { same as VMS; time in milliseconds }
ASM
    PUSH    DS		    { save caller's data segment }
    MOV     DS, Seg0040     { access ticker counter }
    MOV     BX, 6Ch	    { offset of ticker counter in segm.}
    MOV     DX, 43h	    { timer chip control port }
    MOV     AL, 4	    { freeze timer 0 }
    PUSHF		    { save caller's int flag setting }
    CLI 		    { make reading counter an atomic operation}
    MOV     DI, DS:[BX]     { read BIOS ticker counter }
    MOV     CX, DS:[BX+2]
    STI 		    { enable update of ticker counter }
    OUT     DX, AL	    { latch timer 0 }
    CLI 		    { make reading counter an atomic operation}
    MOV     SI, DS:[BX]     { read BIOS ticker counter }
    MOV     BX, DS:[BX+2]
    IN	    AL, 40h	    { read latched timer 0 lo-byte }
    MOV     AH, AL	    { save lo-byte }
    IN	    AL, 40h	    { read latched timer 0 hi-byte }
    POPF		    { restore caller's int flag }
    XCHG    AL, AH	    { correct order of hi and lo }
    CMP     DI, SI	    { ticker counter updated ? }
    JE	    @no_update	    { no }
    OR	    AX, AX	    { update before timer freeze ? }
    JNS     @no_update	    { no }
    MOV     DI, SI	    { use second }
    MOV     CX, BX	    {  ticker counter }
@no_update:  NOT     AX 	     { counter counts down }
    MOV     BX, 36EDh	    { load multiplier }
    MUL     BX		    { W1 * M }
    MOV     SI, DX	    { save W1 * M (hi) }
    MOV     AX, BX	    { get M }
    MUL     DI		    { W2 * M }
    XCHG    BX, AX	    { AX = M, BX = W2 * M (lo) }
    MOV     DI, DX	    { DI = W2 * M (hi) }
    ADD     BX, SI	    { accumulate }
    ADC     DI, 0	    {  result }
    XOR     SI, SI	    { load zero }
    MUL     CX		    { W3 * M }
    ADD     AX, DI	    { accumulate }
    ADC     DX, SI	    {  result in DX:AX:BX }
    MOV     DH, DL	    { move result }
    MOV     DL, AH	    {  from DL:AX:BX }
    MOV     AH, AL	    {	to }
    MOV     AL, BH	    {	 DX:AX:BH }
    MOV     DI, DX	    { save result }
    MOV     CX, AX	    {  in DI:CX }
    MOV     AX, 25110	    { calculate correction }
    MUL     DX		    {  factor }
    SUB     CX, DX	    { subtract correction }
    SBB     DI, SI	    {  factor }
    XCHG    AX, CX	    { result back }
    MOV     DX, DI	    {  to DX:AX }
    POP     DS		    { restore caller's data segment }
END;

procedure clockon;
begin
	start:=clock;
end;
procedure clockoff;
begin
	elapsed:=clock-start;
end;
Procedure PrintTime;
begin
	writeln('Elapsed time = ',elapsed, ' ms');
end;

BEGIN
	Port [$43] := $34;  { need rate generator, not square wave }
	Port [$40] := 0;    { generator as programmed by some BIOSes }
	Port [$40] := 0;    { for timer 0 }
END.