program ASSEMBLER_MOVSW_DEMO;
{ пробы и замеры скорости работы команд пакетной
  пересылки данных.  }
uses crt, xtimer;

var
 A,B: array[1..250] of integer;
 t:   longint;
 i,j: integer;


begin
 clrscr;
 asm
  lea  si, A  { Смещение A в SI (источник)  }
  push ds
  pop  es     { скопируем DS в ES }
  lea  di, B  { смещение B в DI (приемник)  }
  mov  cx,250 { в CX помещаем счетчик переноса  }
  cld         { направление переноса - наращивать  }
  rep  movsw  { переносим 250 слов, то есть 500 байт  }
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