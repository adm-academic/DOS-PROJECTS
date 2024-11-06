var
  s:string;

procedure WriteS(s:String);assembler;
{ (C Mixx) }
asm
  push ds {сохраняем сегмент данных}
  mov ah,40h {номер функции прерывания}
  mov bx,1{стандартный вывод это 1}
  lds dx,[s] {адрес строки в ds:dx}
  mov si,dx {адрес строки в ds:si для lodsb}
  lodsb {длину строки в al (первый байт в строке это ее длина!)}
  inc dx{чтобы не напечатать первый байт}
  xor cx,cx;
  mov cl,al{чтобы в сх была длина строки}
  int 21h {DOS}
  pop ds {восстанавливаем ds}
end;

begin
  s:='Hello World!';
  { установка режима vga 640x480 }
  asm
    MOV AX, 0012h ;
    INT 10h
  end;


  { вывод строки }
  writeS(s);
  readln;
  { установка текстового режима }
  asm
    MOV AX, 0003h ;
    INT 10h
  end;
end.
