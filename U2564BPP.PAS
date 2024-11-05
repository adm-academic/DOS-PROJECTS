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


   # отрисовку файлов BMP 256 colors +-

   # отрисовку файлов BMP 16 colors +-

   # работу с палитрой, как для BMP так и вообще *---
     @ Константная палитра 16 цветов,
       используя встроенные цвета BP7 BGI  +
     @ Очистка всей палитры +
     @ Зарезервировать блок N для интерфейса ---
     @ Зарезервировать блок N для изображения ---
     @ Загрузить 4bpp Bitmap в блок N,
       имя битмапа использовать как индекс для
       управления в дальнейшем ---
     @ Освободить и очистить блок N ---
     @ Получить следующий свободный блок ---
     @ Получить число свободных боков ---
     @ Очистить блок типа Bitmap по имени ---
     @ Блок N занят-нет? ---
     @ Заменить Bitmap в блоке N на новый ---
     @ Для любого блока N получить его 16-цветную палитру ---
     @ Для переданного 256-индекса вернуть его RGB ---
     @ MapFrom4bppTo256 (плюс N блока). Для известного блока
       получить абсолютный идекс по относительному.
     @ MapFrom256To4bb - для абсолютного индекса получить ---
       N цветового блока и относительный индекс,
       а также, если есть, то имя загруженного битмапа
     @



}
interface

procedure DIRTY_TESTS;
Procedure SetRGBPalette_Array( Index,Count:Integer;var RGB );
Procedure GetRGBPalette( Index:Integer;var R,G,B:Byte );
Procedure GetRGBPalette_Array( Index,Count:Integer;var RGB );


implementation

uses crt, graph, dos;

const
  x=1;

type
   T_Buff_RGB_DESC = record
                    R: byte;
                    G: byte;
                    B: byte;
                   end;
   T_Buff_RGBPalette_16  = Array[0..15] of T_Buff_RGB_DESC;
   T_Buff_RGBPalette_256 = Array[0..255] of T_Buff_RGB_DESC;

const
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
  Buff_RGBPalette_16: Array[0..15] of T_Buff_RGB_DESC;
  Buff_RGBPalette_256: Array[0..255] of T_Buff_RGB_DESC;

type
  { Цветовой блок всегда содержит 16 цветов. }
  T_Color_Block = record
     Palette : T_Buff_RGBPalette_16; { палитра из 16-и цветов }
     Case CB_Type: ( CB_Interface, CB_Bitmap ) of
      CB_Interface : (   );
      CB_Bitmap : ( Bitmap_name : string );
  end;
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

{ сбрасывает всё цветовое пространство 256 цветов
  в начальное состояние }
procedure  Clear_Color_Space;
var
 i,j : integer;
 gray_fill: T_Buff_RGB_DESC;
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

{ ############################################################## }
type
 T_BitMapFileHeader = record   { первый заголовок BMP }
   fType : array [0..1] of char;
   fSize : longint;
   fReserved_1 : word;
   fReserved_2 : word;
   fOffsetBits : longint;
 end;

 T_BitMapInfoHeader = record { второй заголовок BMP }
  fSize     :  longint;
  fWIdth    :  longint;
  fHeight   :  longint;
  fPlanes   :  word;
  fBitCount :  word;
  fCompression : longint;
  fSizeImage   : longint;
  fXpelsPerMetr: longint;
  fYpelsPerMetr: longint;
  fColorsUsed  : longint;
  fColorsImportant : longint;
 end;

 T_BGRN_Palette_Element = record { элемент палитры BMP }
     B : byte;
     G : byte;
     R : byte;
     N : byte; { must be null value }
 end;
 P_BGRN_Palette_Element = ^T_BGRN_Palette_Element; { указатель на
                                        элемент палитры, нужен для
                                        доступа к элементам палитры
                                        по типу массива }



 procedure paint_4bpp_BMP_directly( filename:string;
                                    X,Y: integer );
 var
  BitMapFileHeader : T_BitMapFileHeader;  { заголовок 1  }
  BitMapInfoHeader : T_BitMapInfoHeader;  { заголовок 2  }
  BGRN_Palette_Element : T_BGRN_Palette_Element; { элемент палитры }
  f : file;
  t : text;
  i,j: integer;
  palette_size, pixels_size, data_size : longint;
  foffset_palette, foffset_pixels: longint;
  real_start_X, real_start_Y : integer;
  xx, yy : integer;

  pair_pixels, high_pixel, low_pixel : byte;

 begin
   assign(f, filename );
   reset(f,1);

   blockread(f,BitMapFileHeader,sizeof(BitMapFileHeader));
   blockread(f,BitMapInfoHeader,sizeof(BitMapInfoHeader));
   if ( BitMapFileHeader.fType[0] <> 'B' ) and
      ( BitMapFileHeader.fType[1] <> 'M' ) then
        begin
          closegraph;
          writeln('File format must be BMP');
          halt( 0 );
        end;
   if ( BitMapInfoHeader.fBitCount <> 4 ) then
    begin
      closegraph;
      writeln('File BPP Depth must be equal 4 (that means be 16 colors)!' );
      halt( 0 );
    end;
   if ( BitMapInfoHeader.fColorsUsed <> 0  ) and
      ( BitMapInfoHeader.fColorsUsed <> 16 ) then
      begin
        closegraph;
        writeln('File ColorsUsed Parameter Must be 0 or 16 !' );
        halt( 0 );
      end;
   if ( BitMapInfoHeader.fCompression <>0  ) then
     begin
       closegraph;
       writeln('File Must be uncompressed!');
       halt ( 0 );
     end;
   if ( filesize(f) <> BitMapFileHeader.fSize ) then
     begin
       closegraph;
       writeln(' Bad file sizes !');
       halt( 0 );
     end;

    palette_size := 16 * 4;
    foffset_palette:= $36; { смещение палитры в файле известно заранее  }
    foffset_pixels := foffset_palette + palette_size; { вычислим смещение
                                                  массива пикселей изображения  }
    pixels_size := BitMapFileHeader.fSize - foffset_pixels; { размер блока
                                             данных с пикселями картинки  }
    data_size := palette_size + pixels_size;
    if ( filesize(f) <>
       (sizeof(BitMapFileHeader) + sizeof(BitMapInfoHeader) + data_size) )
       then
    begin
       closegraph;
       writeln('Check result sizes NOT PASSED!');
       halt( 0 );
    end;

    { === читаем из файла по одной штуке элементы палитры
      и применяем их сразу для видеопдаптера === }
    for i:=0 to 15 do
    begin
      blockread(f, BGRN_Palette_Element, sizeof(BGRN_Palette_Element) );
      SetRGBPalette( i,
                        integer( BGRN_Palette_Element.R shr 2 ),
                        integer( BGRN_Palette_Element.G shr 2 ),
                        integer( BGRN_Palette_Element.B shr 2 )
                    );
    end;

    { === по пикселям рисуем изображение === }
    { пиксели запакованы по два штуки в один байт  }
    seek(f, foffset_pixels); { переходим на начало массива пикселей  }
    real_start_X := X;
    { изображение выводится снизу вверх, вычисли нижнюю координату
      начала изображения }
    real_start_Y := Y + BitMapInfoHeader.fHeight - 1;

    { собственно в двух циклах выводим изображение по-пиксельно  }
    { ### здесь нужен блиттинг или хотя-бы процедура Move ### }
    for yy:=real_start_Y downto Y do { по Y выводим снизу-вверх  }
    begin
      xx := 0; { по X выводим хитро, так как пиксели запакованы
                 по 2 штуки в каждый байт }
      repeat

         blockread( f, pair_pixels, 1 ); { прочтём запакованую пару пикселей}

         high_pixel := ( pair_pixels and $F0 ) shr 4; { возьём левый пиксель}
         putpixel( xx,yy,word( high_pixel ) ); { выведем его на дисплей}
         xx := xx + 1; { прирастим счётчик xx  }

         { если xx достииг правого края - то брякнем цикл }
         if xx >=  BitMapInfoHeader.fWidth-1 then
           break;

         { возьмём правый пиксель }
         low_pixel :=  pair_pixels and $0F;
         putpixel( xx,yy,word( low_pixel ) );
         xx:= xx + 1;

      until xx >= BitMapInfoHeader.fWidth-1 ;
    end;

    close(f);

 end;


  procedure paint_8bpp_BMP_directly( filename:string;
                                    X,Y: integer );
 var
  BitMapFileHeader : T_BitMapFileHeader;  { заголовок 1  }
  BitMapInfoHeader : T_BitMapInfoHeader;  { заголовок 2  }
  BGRN_Palette_Element : T_BGRN_Palette_Element; { элемент палитры }
  f : file;
  t : text;
  i,j: integer;
  palette_size, pixels_size, data_size : longint;
  foffset_palette, foffset_pixels: longint;
  real_start_X, real_start_Y : integer;
  xx, yy : integer;

  pixel : byte;

 begin
   assign(f, filename );
   reset(f,1);

   blockread(f,BitMapFileHeader,sizeof(BitMapFileHeader));
   blockread(f,BitMapInfoHeader,sizeof(BitMapInfoHeader));
   if ( BitMapFileHeader.fType[0] <> 'B' ) and
      ( BitMapFileHeader.fType[1] <> 'M' ) then
        begin
          closegraph;
          writeln('File format must be BMP');
          halt( 0 );
        end;
   if ( BitMapInfoHeader.fBitCount <> 8 ) then
    begin
      closegraph;
      writeln('File BPP Depth must be equal 8 (that means be 256 colors)!' );
      halt( 0 );
    end;
   if ( BitMapInfoHeader.fColorsUsed <> 0  ) and
      ( BitMapInfoHeader.fColorsUsed <> 256 ) then
      begin
        closegraph;
        writeln('File ColorsUsed Parameter Must be 0 or 16 !' );
        halt( 0 );
      end;
   if ( BitMapInfoHeader.fCompression <>0  ) then
     begin
       closegraph;
       writeln('File Must be uncompressed!');
       halt ( 0 );
     end;
   if ( filesize(f) <> BitMapFileHeader.fSize ) then
     begin
       closegraph;
       writeln(' Bad file sizes !');
       halt( 0 );
     end;

    palette_size := 256 * 4;
    foffset_palette:= $36; { смещение палитры в файле известно заранее  }
    foffset_pixels := foffset_palette + palette_size; { вычислим смещение
                                                  массива пикселей изображения  }
    pixels_size := BitMapFileHeader.fSize - foffset_pixels; { размер блока
                                             данных с пикселями картинки  }
    data_size := palette_size + pixels_size;
    if ( filesize(f) <>
       (sizeof(BitMapFileHeader) + sizeof(BitMapInfoHeader) + data_size) )
       then
    begin
       closegraph;
       writeln('Check result sizes NOT PASSED!');
       halt( 0 );
    end;

    { === читаем из файла по одной штуке элементы палитры
      и применяем их сразу для видеопдаптера === }
    for i:=0 to 255 do
    begin
      blockread(f, BGRN_Palette_Element, sizeof(BGRN_Palette_Element) );
      SetRGBPalette( i,
                        integer( BGRN_Palette_Element.R shr 2 ),
                        integer( BGRN_Palette_Element.G shr 2 ),
                        integer( BGRN_Palette_Element.B shr 2 )
                    );
    end;

    { === по пикселям рисуем изображение === }
    { пиксели по ОДНОМУ байту }
    seek(f, foffset_pixels); { переходим на начало массива пикселей  }
    real_start_X := X;
    { изображение выводится снизу вверх, вычисли нижнюю координату
      начала изображения }
    real_start_Y := Y + BitMapInfoHeader.fHeight - 1;

    { собственно в двух циклах выводим изображение по-пиксельно  }
    { ### здесь нужен блиттинг или хотя-бы процедура Move ### }
    for yy:=real_start_Y downto Y do { по Y выводим снизу-вверх  }
    for xx:=X to BitMapInfoHeader.fWidth-1 do
    begin
         blockread( f, pixel, 1 ); { прочтём пиксель }
         putpixel( xx, yy, word( pixel ) ); { выведем его на дисплей}
    end;

    close(f);

 end;

function Is_Mode_256_Colors : boolean;
begin
   Is_Mode_256_Colors := ( GetMaxColor = 255 );
end;


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


 Clear_Color_Space;
 cleardevice;
 paint_8bpp_BMP_directly('cenbibl.bmp',0,0);
 readln;

 Clear_Color_Space;
 cleardevice;
 paint_4bpp_BMP_directly('cenbibl2.bmp',0,0);
 readln;

 Clear_Color_Space;
 cleardevice;
 paint_8bpp_BMP_directly('leo.bmp',0,0);
 readln;

 Clear_Color_Space;
 cleardevice;
 paint_4bpp_BMP_directly('leo2.bmp',0,0);



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








