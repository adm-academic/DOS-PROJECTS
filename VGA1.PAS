var
  s:string;

procedure WriteS(s:String);assembler;
{ (C Mixx) }
asm
  push ds {��࠭塞 ᥣ���� ������}
  mov ah,40h {����� �㭪樨 ���뢠���}
  mov bx,1{�⠭����� �뢮� �� 1}
  lds dx,[s] {���� ��ப� � ds:dx}
  mov si,dx {���� ��ப� � ds:si ��� lodsb}
  lodsb {����� ��ப� � al (���� ���� � ��ப� �� �� �����!)}
  inc dx{�⮡� �� �������� ���� ����}
  xor cx,cx;
  mov cl,al{�⮡� � �� �뫠 ����� ��ப�}
  int 21h {DOS}
  pop ds {����⠭�������� ds}
end;

begin
  s:='Hello World!';
  { ��⠭���� ०��� vga 640x480 }
  asm
    MOV AX, 0012h ;
    INT 10h
  end;


  { �뢮� ��ப� }
  writeS(s);
  readln;
  { ��⠭���� ⥪�⮢��� ०��� }
  asm
    MOV AX, 0003h ;
    INT 10h
  end;
end.
