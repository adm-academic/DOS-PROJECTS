{ ############################################################## }
type
 T_BitMapFileHeader = record   { ���� ��������� BMP }
   fType : array [0..1] of char;
   fSize : longint;
   fReserved_1 : word;
   fReserved_2 : word;
   fOffsetBits : longint;
 end;

 T_BitMapInfoHeader = record { ��ன ��������� BMP }
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

 T_BGRN_Palette_Element = record { ������� ������� BMP }
     B : byte;
     G : byte;
     R : byte;
     N : byte; { must be null value }
 end;

 P_BGRN_Palette_Element = ^T_BGRN_Palette_Element; { 㪠��⥫� ��
                                        ������� �������, �㦥� ���
                                        ����㯠 � ������⠬ �������
                                        �� ⨯� ���ᨢ� }



procedure paint_4bpp_BMP_directly( filename:string;
                                    X,Y: integer );
 var
  BitMapFileHeader : T_BitMapFileHeader;  { ��������� 1  }
  BitMapInfoHeader : T_BitMapInfoHeader;  { ��������� 2  }
  BGRN_Palette_Element : T_BGRN_Palette_Element; { ������� ������� }
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
    foffset_palette:= $36; { ᬥ饭�� ������� � 䠩�� �����⭮ ��࠭��  }
    foffset_pixels := foffset_palette + palette_size; { ���᫨� ᬥ饭��
                                                  ���ᨢ� ���ᥫ�� ����ࠦ����  }
    pixels_size := BitMapFileHeader.fSize - foffset_pixels; { ࠧ��� �����
                                             ������ � ���ᥫﬨ ���⨭��  }
    data_size := palette_size + pixels_size;
    if ( filesize(f) <>
       (sizeof(BitMapFileHeader) + sizeof(BitMapInfoHeader) + data_size) )
       then
    begin
       closegraph;
       writeln('Check result sizes NOT PASSED!');
       halt( 0 );
    end;

    { === �⠥� �� 䠩�� �� ����� ��㪥 �������� �������
      � �ਬ��塞 �� �ࠧ� ��� ����������� === }
    for i:=0 to 15 do
    begin
      blockread(f, BGRN_Palette_Element, sizeof(BGRN_Palette_Element) );
      SetRGBPalette( i,
                        integer( BGRN_Palette_Element.R shr 2 ),
                        integer( BGRN_Palette_Element.G shr 2 ),
                        integer( BGRN_Palette_Element.B shr 2 )
                    );
    end;

    { === �� ���ᥫ� ��㥬 ����ࠦ���� === }
    { ���ᥫ� ���������� �� ��� ��㪨 � ���� ����  }
    seek(f, foffset_pixels); { ���室�� �� ��砫� ���ᨢ� ���ᥫ��  }
    real_start_X := X;
    { ����ࠦ���� �뢮����� ᭨�� �����, ���᫨ ������ ���न����
      ��砫� ����ࠦ���� }
    real_start_Y := Y + BitMapInfoHeader.fHeight - 1;

    { ᮡ�⢥��� � ���� 横��� �뢮��� ����ࠦ���� ��-���ᥫ쭮  }
    { ### ����� �㦥� ����⨭� ��� ���-�� ��楤�� Move ### }
    for yy:=real_start_Y downto Y do { �� Y �뢮��� ᭨��-�����  }
    begin
      xx := 0; { �� X �뢮��� ���, ⠪ ��� ���ᥫ� ����������
                 �� 2 ��㪨 � ����� ���� }
      repeat

         blockread( f, pair_pixels, 1 ); { ����� ����������� ���� ���ᥫ��}

         high_pixel := ( pair_pixels and $F0 ) shr 4; { ����� ���� ���ᥫ�}
         putpixel( xx,yy,word( high_pixel ) ); { �뢥��� ��� �� ��ᯫ��}
         xx := xx + 1; { ����⨬ ����稪 xx  }

         { �᫨ xx ���⨨� �ࠢ��� ��� - � ��節�� 横� }
         if xx >=  BitMapInfoHeader.fWidth-1 then
           break;

         { ����� �ࠢ� ���ᥫ� }
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
  BitMapFileHeader : T_BitMapFileHeader;  { ��������� 1  }
  BitMapInfoHeader : T_BitMapInfoHeader;  { ��������� 2  }
  BGRN_Palette_Element : T_BGRN_Palette_Element; { ������� ������� }
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
    foffset_palette:= $36; { ᬥ饭�� ������� � 䠩�� �����⭮ ��࠭��  }
    foffset_pixels := foffset_palette + palette_size; { ���᫨� ᬥ饭��
                                                  ���ᨢ� ���ᥫ�� ����ࠦ����  }
    pixels_size := BitMapFileHeader.fSize - foffset_pixels; { ࠧ��� �����
                                             ������ � ���ᥫﬨ ���⨭��  }
    data_size := palette_size + pixels_size;
    if ( filesize(f) <>
       (sizeof(BitMapFileHeader) + sizeof(BitMapInfoHeader) + data_size) )
       then
    begin
       closegraph;
       writeln('Check result sizes NOT PASSED!');
       halt( 0 );
    end;

    { === �⠥� �� 䠩�� �� ����� ��㪥 �������� �������
      � �ਬ��塞 �� �ࠧ� ��� ����������� === }
    for i:=0 to 255 do
    begin
      blockread(f, BGRN_Palette_Element, sizeof(BGRN_Palette_Element) );
      SetRGBPalette( i,
                        integer( BGRN_Palette_Element.R shr 2 ),
                        integer( BGRN_Palette_Element.G shr 2 ),
                        integer( BGRN_Palette_Element.B shr 2 )
                    );
    end;

    { === �� ���ᥫ� ��㥬 ����ࠦ���� === }
    { ���ᥫ� �� ������ ����� }
    seek(f, foffset_pixels); { ���室�� �� ��砫� ���ᨢ� ���ᥫ��  }
    real_start_X := X;
    { ����ࠦ���� �뢮����� ᭨�� �����, ���᫨ ������ ���न����
      ��砫� ����ࠦ���� }
    real_start_Y := Y + BitMapInfoHeader.fHeight - 1;

    { ᮡ�⢥��� � ���� 横��� �뢮��� ����ࠦ���� ��-���ᥫ쭮  }
    { ### ����� �㦥� ����⨭� ��� ���-�� ��楤�� Move ### }
    for yy:=real_start_Y downto Y do { �� Y �뢮��� ᭨��-�����  }
    for xx:=X to BitMapInfoHeader.fWidth-1 do
    begin
         blockread( f, pixel, 1 ); { ����� ���ᥫ� }
         putpixel( xx, yy, word( pixel ) ); { �뢥��� ��� �� ��ᯫ��}
    end;

    close(f);

 end;
