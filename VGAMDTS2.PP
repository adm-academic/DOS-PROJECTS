program VGA_Mode_test;
uses crt, go32, sysutils;




{$GOTO ON}
label
   again;

var
  i,j: integer;
  xx, yy : smallint;
  ii : longint;

{$ASMMODE INTEL}



begin
  { установка режима vga 640x480 }
  asm
    MOV AX, 0013h ;
    INT 10h
  end;

  randomize;
  repeat
    again :
    for ii := 0 to 320*200-1 do
    begin
       Mem[ SegA000 : ii ] := random( 255 );
    end;

    delay( 15 );
  until keypressed;
  if readkey <> #13 then
    goto again;


  for ii := 0 to 320*200-1 do
    begin
       Mem[ SegA000 : ii ] := random( 255 );
    end;


  { установка текстового режима }
  asm
    MOV AX, 0003h ;
    INT 10h
  end;


end.
