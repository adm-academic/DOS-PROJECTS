program ASSEMBLER_MOVSW_DEMO;
{ �஡� � ������ ᪮��� ࠡ��� ������ ����⭮�
  ����뫪� ������.  }
uses crt, xtimer;

var
 A,B: array[1..250] of integer;
 t:   longint;
 i,j: integer;


begin
 clrscr;
 asm
  lea  si, A  { ���饭�� A � SI (���筨�)  }
  push ds
  pop  es     { ᪮���㥬 DS � ES }
  lea  di, B  { ᬥ饭�� B � DI (�ਥ����)  }
  mov  cx,250 { � CX ����頥� ���稪 ��७��  }
  cld         { ���ࠢ����� ��७�� - ���騢���  }
  rep  movsw  { ��७�ᨬ 250 ᫮�, � ���� 500 ����  }
 end;


 {
 ClockOn;
 for i:=1 to 250 do
  B[i]:=A[i];
 PrintTime;
 ClockOff;
 }

 readln;
end.