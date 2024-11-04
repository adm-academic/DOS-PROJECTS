unit U2564BPP;
{
  ТОЛЬКО ДЛЯ ВИДЕОРЕЖИМОВ 256-ЦВЕТОВ !!!
  ТОЛЬКО Real Mode !!!

  Модуль который позволяет загружать в память от 1 до 15
  разных палитровых 16-цветных BMP-изображений.
  Глубина кодирования цвета таких изображений обычно указывается
  как 4BPP ( 4 Bits Per Pixels ).
  Каждое изображение использует свою 16-битную палитру,
  которая не пересекается с палитрами других изображений.
  Первые 16 цветов в палитре (0-15) натсраиваются и используются
  для отрисовки разных элементов интефейса, и коды цветов
  берутся из классичской палитры Turbo Pascal 16-Colors;
}
interface

procedure DIRTY_TESTS;
Procedure SetRGBPalette_Array(Index,Count:Integer;var RGB);
Procedure GetRGBPalette(Index:Integer;var R,G,B:Byte);
Procedure GetRGBPalette_Array(Index,Count:Integer;var RGB);


implementation
uses crt, graph;

const
  x=1;

type
   T_Buff_RGB_BYTE = record
                    R: byte;
                    G: byte;
                    B: byte;
                   end;
   T_Buff_RGBPalette_16  = Array[0..15] of T_Buff_RGB_BYTE;
   T_Buff_RGBPalette_256 = Array[0..255] of T_Buff_RGB_BYTE;

const
   Default_VGA_Palette : T_Buff_RGBPAlette_16  =
   (
    {0}   ( R:$00; G:$00; B:$00 ),
    {1}   ( R:$00; G:$00; B:$2A ),
    {2}   ( R:$00; G:$2A; B:$00 ),
    {3}   ( R:$00; G:$2A; B:$2A ),
    {4}   ( R:$2A; G:$00; B:$00 ),
    {5}   ( R:$2A; G:$00; B:$2A ),
    {6}   ( R:$2A; G:$15; B:$00 ),
    {7}   ( R:$2A; G:$2A; B:$2A ),
    {8}   ( R:$15; G:$15; B:$15 ),
    {9}   ( R:$15; G:$15; B:$3F ),
    {10}  ( R:$15; G:$3F; B:$15 ),
    {11}  ( R:$15; G:$3F; B:$3F ),
    {12}  ( R:$3F; G:$15; B:$15 ),
    {13}  ( R:$3F; G:$15; B:$3F ),
    {14}  ( R:$3F; G:$3F; B:$15 ),
    {15}  ( R:$3F; G:$3F; B:$3F )
   );

var

  Buff_RGBPalette_16: Array[0..15] of T_Buff_RGB_BYTE;
  Buff_RGBPalette_256: Array[0..255] of T_Buff_RGB_BYTE;

{
===========================================================================
}
{ ВОЗМОЖНЫ ГЛЮКИ !!!
  получает значения R,G,B для указанного индекса Index }
Procedure GetRGBPalette(Index:Integer;var R,G,B:Byte);assembler;
asm
 MOV AX,1015H;
 MOV BX,INDEX
 INT 10H
 LES DI,R
 MOV ES:[DI],DH
 LES DI,G
 MOV ES:[DI],CH
 LES DI,B
 MOV ES:[DI],CL
end;


{ устанавливает массив цветов в палитру видеокарты }
{ index - индекс начального цвета в палитре видеокарты }
{ count - количесво устанавливаемых цветов }
{ RGB - массив устанавливаемых цветов }
Procedure SetRGBPalette_Array(Index,Count:Integer;var RGB);assembler;
asm
 LES DX,RGB
 MOV BX,Index
 MOV CX,Count
 MOV AX,1012H
 INT 10H
end;

{ копирует в переменную RGB описания Count штук цветов начиная с индекса Index }
Procedure GetRGBPalette_Array(Index,Count:Integer;var RGB);assembler;
asm
 MOV BX,Index
 MOV CX,Count
 LES DX,RGB
 MOV AX,1016H
 INT 10H
end;

{
======================================================================
}

{ сбрасывает всё цветовое пространство 256 цветов
  в начальное состояние }
procedure  ClearColorSpace;
var
 i,j : integer;
 gray_fill: T_Buff_RGB_BYTE;
begin
  { первые 16 цветов возьмём из константной таблицы цветов VGA }
  for i:=0 to 15 do
    begin
      Buff_RGBPalette_256[i]:= Default_VGA_Palette[i];
    end;

  { остальные заполним нейтральным серым цветом }
  gray_fill.R:=$2A; gray_fill.G:=$2A; gray_fill.B:=$2A;
  for i:=16 to 255 do
    Buff_RGBPalette_256[i]:=gray_fill;

  SetRGBPalette_Array( 0, 256, Buff_RGBPalette_256 );

end;

procedure Draw_25COLORS_BMP;
begin


end;


procedure DIRTY_TESTS;
begin
 writeln('Start Dirty U2564BPP tests... ');

 ClearColorSpace;

 Draw_256COLORS_BMP;

end;



begin
   Writeln;
   Writeln('Used Unit "U2564BPP.PAS" ');
   Writeln('Which manages 4bpp color spaces in a ',
           'total space of 256 colors.');
   {$IFDEF DPMI}
     Writeln('ERROR. Only Real Mode Processor SUPPORTED !!!');
     halt(0);
   {$ENDIF}
end.








