unit U2564BPP;
{
  ТОЛЬКО ДЛЯ ВИДЕОРЕЖИМОВ 256-ЦВЕТОВ !!!

  Модуль который позволяет загружать в память от 1 до 15
  разных палитровых 16-цветных BMP-изображений.
  Глубина кодирования цвета таких изображений обычно указывается
  как 4BPP ( 4 Bits Per Pixels ).
  Каждое изображение использует свою 16-битную палитру,
  которая не пересекается с палитрами других изображений.
  Первые 16 цветов в палитре (0-15) натсраиваются и используются
  для отрисовки разных элементов интефейса, и коды цветов
  берутся из классической палитры Turbo Pascal 16-Colors;


   # отрисовку файлов BMP 256 colors +-

   # отрисовку файлов BMP 16 colors +-

   # работу с палитрой, как для BMP так и вообще *---
     @ Константная палитра 16 цветов,
       используя встроенные цвета BP7 BGI  +
     @ Очистка всей палитры +
     @ Очистка одного цветового блока +
     @ Изменить тип цветового блока (Free,Interface,Bitmap) +
     @ Освободить и очистить блок N +
     @ Блок N занят-нет? +
     @ Получить число свободных боков +
     @ Получить номер следующего свободного блока +
     @ Загрузить 4bpp Bitmap в блок N,
       имя битмапа использовать как индекс для
       управления в дальнейшем ---
     @ Очистить блок типа Bitmap по имени ---
     @ Заменить Bitmap в блоке N на новый ---
     @ Для любого блока N получить его 16-цветную палитру ---
     @ Для переданного 256-индекса вернуть его RGB ---
     @ MapFrom4bppTo256 (плюс N блока). Для идекса ИЗ известного блока
       получить абсолютный идекс по относительному.
     @ MapFrom256To4bb - для абсолютного индекса получить ---
       N цветового блока и относительный индекс,
       а также, если есть, то имя загруженного битмапа

}
interface

type
   T_Buff_RGB_DESC = record { для единичного элмента палитры VGA  }
                    R: byte;
                    G: byte;
                    B: byte;
                   end;
   { для 16-цветного блока палитры VGA  }
   T_Buff_RGBPalette_16  = Array[0..15] of T_Buff_RGB_DESC;
   { для всей палитры VGA  }
   T_Buff_RGBPalette_256 = Array[0..255] of T_Buff_RGB_DESC;

   { Вид цветового блока }
  Type_Colors_Block = ( CB_Free, CB_Interface, CB_Bitmap );


Procedure GetRGBPalette(Index:Integer;var R,G,B:Byte);
Procedure SetRGBPalette_Array(Index,Count:Integer;var RGB);
Procedure GetRGBPalette_Array(Index,Count:Integer;var RGB);
procedure Flush_Colors_Space;
procedure Flush_Colors_Block( N : byte  );
function Get_Count_Of_Free_Blocks : byte;
function Get_Free_Block_Number : shortint;
procedure Clear_Colors_Block(N:byte);
procedure Colors_Block_Change_Type(N:byte; New_Type : Type_Colors_Block);
function Colors_Block_Is_Available(N: byte) : boolean;
procedure  Clear_Colors_Space;
function Initialize_U2564BPP : boolean;
function Is_Mode_256_Colors : boolean;
procedure DIRTY_TESTS;


implementation

uses crt, graph, dos;

const
   { Константный блок первых 16 цветов палитры VGA  }
   Default_VGA_Palette : T_Buff_RGBPAlette_16  =
   (
    {0} {Black}       ( R:$00; G:$00; B:$00 ),
    {1} {Blue}        ( R:$00; G:$00; B:$2A ),
    {2} {Green}       ( R:$00; G:$2A; B:$00 ),
    {3} {Cyan}        ( R:$00; G:$2A; B:$2A ),
    {4} {Red}         ( R:$2A; G:$00; B:$00 ),
    {5} {Magenta}     ( R:$2A; G:$00; B:$2A ),
    {6} {Brown}       ( R:$2A; G:$15; B:$00 ),
    {7} {LightGray}   ( R:$2A; G:$2A; B:$2A ),
    {8} {DarkGray}    ( R:$15; G:$15; B:$15 ),
    {9} {LightBlue}   ( R:$15; G:$15; B:$3F ),
    {10}{LIghtGreen}  ( R:$15; G:$3F; B:$15 ),
    {11}{LightCyan}   ( R:$15; G:$3F; B:$3F ),
    {12}{LightRed}    ( R:$3F; G:$15; B:$15 ),
    {13}{LightMagenta}( R:$3F; G:$15; B:$3F ),
    {14}{Yellow}      ( R:$3F; G:$3F; B:$15 ),
    {15}{White}       ( R:$3F; G:$3F; B:$3F )
   );


var
  { буферы для чтения-записи палитры VGA }
  Buff_RGBPalette_16: Array[0..15] of T_Buff_RGB_DESC;
  Buff_RGBPalette_256: Array[0..255] of T_Buff_RGB_DESC;

type

  { Тип данных для цветового блока.
    Цветовой блок всегда содержит 16 цветов.
    Запись с Вариантами. }
  T_Colors_Block = record
     Palette : T_Buff_RGBPalette_16; { палитра из 16-и цветов }
     Colors_Offset : byte;
     { тип блока, свободный, интерфейсный или картинка BitMap }
     Case CB_Type:   Type_Colors_Block  of
       CB_Free      : (   );
       CB_Interface : (   );
       CB_Bitmap    : (   );
  end;

  { Тип данных для всего цветового пространства 256-цветов }
  T_Colors_Space = array [ 0..255 ] of T_Colors_Block;

var
  Colors_Space : T_Colors_Space;
  U2564BPP_Initialized : boolean;

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
{ RGB   - массив устанавливаемых цветов }
Procedure SetRGBPalette_Array(Index,Count:Integer;var RGB);assembler;
asm
 LES DX,RGB
 MOV BX,Index
 MOV CX,Count
 MOV AX,1012H
 INT 10H
end;

{ копирует в переменную RGB описания Count штук цветов начиная
  с индекса Index }
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

{ Выгружает всё цветовое пространтсво в регистры DAC видеоадаптера VGA }
procedure Flush_Colors_Space;
var
  index_CB, index_color : integer;
begin
   { переложим все цвета из цветового пространства в буфер VGA  }
   for index_CB:=0 to 15 do
     begin
     for index_color := index_CB*16 to index_CB*16 + 15 do
       begin
       Buff_RGBPalette_256[ index_color ].R :=
               Colors_Space[ index_color ].Palette[ index_CB ].R;
       end;
     end;
   { выгрузим буфер VGA в регистры DAC видеоадаптера  }
   SetRGBPalette_Array( 0, 256, Buff_RGBPalette_256   );
end;


{ Выгружает указанный цветовой блок в регистры DAC видеоадаптера VGA }
procedure Flush_Colors_Block( N : byte  );
var
  i,j : integer;
begin
  SetRGBPalette_Array( Colors_Space[N].Colors_Offset,
                       16,
                       Colors_Space[N].Palette );
end;

{ Возвращает число свободных блоков.
  Если свободных нет - возвращает ноль - 0  }
function Get_Count_Of_Free_Blocks : byte;
var
  i: integer;
  cnt : integer;
begin
  cnt := 0;
  for i:=0 to 15 do
    if Colors_Space[i].CB_Type = CB_Free then
      inc( cnt );
  Get_Count_Of_Free_Blocks := cnt;
end;

{ Получить номер следующего свободного блока.
  Если свободного блока нет - возвращет -1 }
function Get_Free_Block_Number : shortint;
var
  i: integer;
begin
  for i:= 0 to 15 do
    if Colors_Space[i].CB_Type = CB_Free then
      begin
      Get_Free_Block_Number := i;
      exit;
      end;
  Get_Free_Block_Number := -1;
end;



{ Очищает указанный цветовой блок, устанавливая на всех индексированных
  цветах нейтральный серый и помечая его как свододный CB_Free
}
procedure Clear_Colors_Block(N:byte);
var
 i,j: integer;
begin
  Colors_Space[N].CB_Type := CB_Free;
  Colors_Space[N].Colors_Offset := N*16;
  for j:=0 to 15 do
    begin
    Colors_Space[N].Palette[j].R := $2A;
    Colors_Space[N].Palette[j].G := $2A;
    Colors_Space[N].Palette[j].B := $2A;
    end;
  Flush_Colors_Block(N);
end;

{ Изменяет тип цветового блока N на новый.
  Не трогает текущую палитру указанного блока.}
procedure Colors_Block_Change_Type(N:byte; New_Type : Type_Colors_Block);
begin
   Colors_Space[N].CB_Type := new_type;
   Colors_Space[N].Colors_Offset := N*16;
end;

{
 Возвращает истину если указанный цветовой блок свободен
}
function Colors_Block_Is_Available(N: byte) : boolean;
begin
   Colors_Block_Is_Available := Colors_Space[N].CB_Type = CB_Free;
end;


{ сбрасывает всё цветовое пространство 256 цветов
  в начальное состояние }
procedure  Clear_Colors_Space;
var
 i,j : integer;
 gray_fill: T_Buff_RGB_DESC;
begin
  { всего в цветовом пространтсве 16 блоков,
    нулевой блок заполним из константной таблицы цветов VGA }
  for j:=0 to 15 do
    begin
    Colors_Space[0].Palette[j].R := Default_VGA_Palette[j].R;
    Colors_Space[0].Palette[j].G := Default_VGA_Palette[j].G;
    Colors_Space[0].Palette[j].B := Default_VGA_Palette[j].B;
    end;
  Colors_Space[0].CB_Type := CB_Interface;
  Colors_Space[0].Colors_Offset:= 0;

  { проиницализируем палитры остальных 15 блоков нейтральным серым цветом,
    и пометим записи всех 15-ти блоков как свободные }
  for i:=1 to 15 do
    begin
    Colors_Space[0].CB_Type := CB_Free;
    Colors_Space[0].Colors_Offset := i*16;
    for j:=0 to 15 do
      begin
        Colors_Space[i].Palette[j].R := $2A;
        Colors_Space[i].Palette[j].G := $2A;
        Colors_Space[i].Palette[j].B := $2A;
      end;
    end;
  { применим внесенные изменения к регистрам VGA }
  Flush_Colors_Space;
end;


{ Выполняет некоторые проверки параметров ОС и видеорежима,
  а также провоидит инициализацию модуля.
  В некоторых случаях выдаёт сообщение об ошибке и завершает
  объемлющую программу.
  Если инициализация успешна - возвращает Истину.  }
function Initialize_U2564BPP : boolean;
begin
  if GraphResult <> GrOk then
    begin
    Initialize_U2564BPP := False;
    closegraph;
    Writeln('Initialize U2564BPP Error - Graph Mode Not Available !');
    Writeln('Program will be interrupted!');
    halt( 5 );
    end
  else
    begin
    if GetMaxColor<>255 then
      begin
      Initialize_U2564BPP := False;
      closegraph;
      Writeln('Initialize U2563BPP Error - Graph not in 256-colors Mode !');
      Writeln('Program will be interrupted!');
      halt( 5 );
      end
    else
      begin
      Initialize_U2564BPP := True;
      Clear_Colors_Space;
      exit;
      end;
    end;
end;


function Is_Mode_256_Colors : boolean;
begin
   Is_Mode_256_Colors := ( GetMaxColor = 255 );
end;


{$I BMP.INC} { Include File With Graph Module BMP code }


procedure DIRTY_TESTS;
var
  i,j : integer;
begin
 writeln('Start Dirty U2564BPP tests... ');

 { ### нужно проверять чтобы был включен видеорежим 256-цветов ### }
 if (not Is_Mode_256_Colors) then
 begin
   closegraph;
   writeln('Graph Mode must be 256 colors !!!');
   halt ( 0 );
 end;


 Clear_Colors_Space;
 cleardevice;
 paint_8bpp_BMP_directly('cenbibl.bmp',0,0);
 readln;

 Clear_Colors_Space;
 cleardevice;
 paint_4bpp_BMP_directly('cenbibl2.bmp',0,0);
 readln;

 Clear_Colors_Space;
 cleardevice;
 paint_8bpp_BMP_directly('leo.bmp',0,0);
 readln;

 Clear_Colors_Space;
 cleardevice;
 paint_4bpp_BMP_directly('leo2.bmp',0,0);


end;




begin
   Writeln;
   Writeln('Used Unit "U2564BPP.PAS" ');
   Writeln('Which manages 4bpp (16 colors) color spaces ',
           'in a total space of 256 colors.');
   {$IFDEF DPMI}
     Writeln('ATTENTION ! Unit U2564BPP runs in "16-BIT PROTECTED MODE" !');
   {$ELSE}
     Writeln('ATTENTION ! Unit U2564BPP runs in "REAL MODE" !');
   {$ENDIF}
   Writeln('Press ENTER for continue loading program !');
   U2564BPP_Initialized := False;
   readln;
end.








