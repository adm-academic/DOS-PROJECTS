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
