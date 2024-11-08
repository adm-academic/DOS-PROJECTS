unit U2564BPP;
{
  ������ ��� ������������ 256-������ !!!

  ����� ����� �������� ����㦠�� � ������ �� 1 �� 15
  ࠧ��� �����஢�� 16-梥��� BMP-����ࠦ����.
  ��㡨�� ����஢���� 梥� ⠪�� ����ࠦ���� ���筮 㪠�뢠����
  ��� 4BPP ( 4 Bits Per Pixels ).
  ������ ����ࠦ���� �ᯮ���� ᢮� 16-����� �������,
  ����� �� ���ᥪ����� � �����ࠬ� ��㣨� ����ࠦ����.
  ���� 16 梥⮢ � ������ (0-15) ����ࠨ������ � �ᯮ�������
  ��� ���ᮢ�� ࠧ��� ������⮢ ���䥩�, � ���� 梥⮢
  ������� �� ������᪮� ������� Turbo Pascal 16-Colors;


   # ���ᮢ�� 䠩��� BMP 256 colors +-

   # ���ᮢ�� 䠩��� BMP 16 colors +-

   # ࠡ��� � �����ன, ��� ��� BMP ⠪ � ����� *---
     @ ����⠭⭠� ������ 16 梥⮢,
       �ᯮ���� ���஥��� 梥� BP7 BGI  +
     @ ���⪠ �ᥩ ������� +
     @ ���⪠ ������ 梥⮢��� ����� +
     @ �������� ⨯ 梥⮢��� ����� (Free,Interface,Bitmap) +
     @ �᢮������ � ������ ���� N +
     @ ���� N �����-���? +
     @ ������� �᫮ ᢮������ ����� +
     @ ������� ����� ᫥���饣� ᢮������� ����� +
     @ ����㧨�� 4bpp Bitmap � ���� N,
       ��� ��⬠�� �ᯮ�짮���� ��� ������ ���
       �ࠢ����� � ���쭥�襬 ---
     @ ������ ���� ⨯� Bitmap �� ����� ---
     @ �������� Bitmap � ����� N �� ���� ---
     @ ��� ��� ����� N ������� ��� 16-梥��� ������� ---
     @ ��� ��।������ 256-������ ������ ��� RGB ---
     @ MapFrom4bppTo256 (���� N �����). ��� ����� �� �����⭮�� �����
       ������� ��᮫��� ����� �� �⭮�⥫쭮��.
     @ MapFrom256To4bb - ��� ��᮫�⭮�� ������ ������� ---
       N 梥⮢��� ����� � �⭮�⥫�� ������,
       � ⠪��, �᫨ ����, � ��� ����㦥����� ��⬠��

}
interface

type
   T_Buff_RGB_DESC = record { ��� �����筮�� ������ ������� VGA  }
                    R: byte;
                    G: byte;
                    B: byte;
                   end;
   { ��� 16-梥⭮�� ����� ������� VGA  }
   T_Buff_RGBPalette_16  = Array[0..15] of T_Buff_RGB_DESC;
   { ��� �ᥩ ������� VGA  }
   T_Buff_RGBPalette_256 = Array[0..255] of T_Buff_RGB_DESC;

   { ��� 梥⮢��� ����� }
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
   { ����⠭�� ���� ����� 16 梥⮢ ������� VGA  }
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
  { ����� ��� �⥭��-����� ������� VGA }
  Buff_RGBPalette_16: Array[0..15] of T_Buff_RGB_DESC;
  Buff_RGBPalette_256: Array[0..255] of T_Buff_RGB_DESC;

type

  { ��� ������ ��� 梥⮢��� �����.
    ���⮢�� ���� �ᥣ�� ᮤ�ন� 16 梥⮢.
    ������ � ��ਠ�⠬�. }
  T_Colors_Block = record
     Palette : T_Buff_RGBPalette_16; { ������ �� 16-� 梥⮢ }
     Colors_Offset : byte;
     { ⨯ �����, ᢮�����, ����䥩�� ��� ���⨭�� BitMap }
     Case CB_Type:   Type_Colors_Block  of
       CB_Free      : (   );
       CB_Interface : (   );
       CB_Bitmap    : (   );
  end;

  { ��� ������ ��� �ᥣ� 梥⮢��� ����࠭�⢠ 256-梥⮢ }
  T_Colors_Space = array [ 0..255 ] of T_Colors_Block;

var
  Colors_Space : T_Colors_Space;
  U2564BPP_Initialized : boolean;

{
===========================================================================
}
{ �������� ����� !!!
  ����砥� ���祭�� R,G,B ��� 㪠������� ������ Index }
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


{ ��⠭�������� ���ᨢ 梥⮢ � ������� ���������� }
{ index - ������ ��砫쭮�� 梥� � ������ ���������� }
{ count - �����᢮ ��⠭���������� 梥⮢ }
{ RGB   - ���ᨢ ��⠭���������� 梥⮢ }
Procedure SetRGBPalette_Array(Index,Count:Integer;var RGB);assembler;
asm
 LES DX,RGB
 MOV BX,Index
 MOV CX,Count
 MOV AX,1012H
 INT 10H
end;

{ ������� � ��६����� RGB ���ᠭ�� Count ��� 梥⮢ ��稭��
  � ������ Index }
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

{ ���㦠�� ��� 梥⮢�� ����࠭�᢮ � ॣ����� DAC ����������� VGA }
procedure Flush_Colors_Space;
var
  index_CB, index_color : integer;
begin
   { ��५���� �� 梥� �� 梥⮢��� ����࠭�⢠ � ���� VGA  }
   for index_CB:=0 to 15 do
     begin
     for index_color := index_CB*16 to index_CB*16 + 15 do
       begin
       Buff_RGBPalette_256[ index_color ].R :=
               Colors_Space[ index_color ].Palette[ index_CB ].R;
       end;
     end;
   { ���㧨� ���� VGA � ॣ����� DAC �����������  }
   SetRGBPalette_Array( 0, 256, Buff_RGBPalette_256   );
end;


{ ���㦠�� 㪠����� 梥⮢�� ���� � ॣ����� DAC ����������� VGA }
procedure Flush_Colors_Block( N : byte  );
var
  i,j : integer;
begin
  SetRGBPalette_Array( Colors_Space[N].Colors_Offset,
                       16,
                       Colors_Space[N].Palette );
end;

{ �����頥� �᫮ ᢮������ ������.
  �᫨ ᢮������ ��� - �����頥� ���� - 0  }
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

{ ������� ����� ᫥���饣� ᢮������� �����.
  �᫨ ᢮������� ����� ��� - ������� -1 }
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



{ ��頥� 㪠����� 梥⮢�� ����, ��⠭������� �� ��� ������஢�����
  梥�� ����ࠫ�� ��� � ������ ��� ��� ᢮����� CB_Free
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

{ ������� ⨯ 梥⮢��� ����� N �� ����.
  �� �ண��� ⥪���� ������� 㪠������� �����.}
procedure Colors_Block_Change_Type(N:byte; New_Type : Type_Colors_Block);
begin
   Colors_Space[N].CB_Type := new_type;
   Colors_Space[N].Colors_Offset := N*16;
end;

{
 �����頥� ��⨭� �᫨ 㪠����� 梥⮢�� ���� ᢮�����
}
function Colors_Block_Is_Available(N: byte) : boolean;
begin
   Colors_Block_Is_Available := Colors_Space[N].CB_Type = CB_Free;
end;


{ ���뢠�� ��� 梥⮢�� ����࠭�⢮ 256 梥⮢
  � ��砫쭮� ���ﭨ� }
procedure  Clear_Colors_Space;
var
 i,j : integer;
 gray_fill: T_Buff_RGB_DESC;
begin
  { �ᥣ� � 梥⮢�� ����࠭�ᢥ 16 ������,
    �㫥��� ���� �������� �� ����⠭⭮� ⠡���� 梥⮢ VGA }
  for j:=0 to 15 do
    begin
    Colors_Space[0].Palette[j].R := Default_VGA_Palette[j].R;
    Colors_Space[0].Palette[j].G := Default_VGA_Palette[j].G;
    Colors_Space[0].Palette[j].B := Default_VGA_Palette[j].B;
    end;
  Colors_Space[0].CB_Type := CB_Interface;
  Colors_Space[0].Colors_Offset:= 0;

  { �ந��栫����㥬 ������� ��⠫��� 15 ������ ����ࠫ�� ��� 梥⮬,
    � ����⨬ ����� ��� 15-� ������ ��� ᢮����� }
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
  { �ਬ���� ���ᥭ�� ��������� � ॣ���ࠬ VGA }
  Flush_Colors_Space;
end;


{ �믮���� ������� �஢�ન ��ࠬ��஢ �� � �����०���,
  � ⠪�� �஢����� ���樠������ �����.
  � �������� ����� �뤠�� ᮮ�饭�� �� �訡�� � �����蠥�
  ��ꥬ����� �ணࠬ��.
  �᫨ ���樠������ �ᯥ譠 - �����頥� ��⨭�.  }
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

 { ### �㦭� �஢����� �⮡� �� ����祭 �����०�� 256-梥⮢ ### }
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








