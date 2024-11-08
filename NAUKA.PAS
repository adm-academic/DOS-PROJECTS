uses crt,graph, bmp, U2564BPP;
{
  �ணࠬ�� ��� ��᫥������� ���������⥩ �ணࠬ�஢����
  ��䨪� � ०��� VGA 320x200 256 梥⮢.
  ��᫥�㥬:
   # ᮢ���⭮� �ᯮ�짮�����
     �ࠩ��஢ BGI � ��אַ�� ����㯠 � ����������  +

   # ������ ����⨭�  � ����������� ---
      - ����⨭� ����ணࠬ�� Move(); ---
      - ����⨭� �������ﬨ ���஥����� ��ᥬ���� ---

   # ���ᮢ�� 䠩��� BMP 256 colors +-

   # ���ᮢ�� 䠩��� BMP 16 colors +-

   # ࠡ��� � �����ன, ��� ��� BMP ⠪ � ����� *---
     @ ����⠭⭠� ������ 16 梥⮢,
       �ᯮ���� ���஥��� 梥� BP7 BGI  +
     @ ���⪠ �ᥩ ������� +
     @ ��१�ࢨ஢��� ���� N ��� ����䥩� ---
     @ ��१�ࢨ஢��� ���� N ��� ����ࠦ���� ---
     @ ����㧨�� 4bpp Bitmap � ���� N,
       ��� ��⬠�� �ᯮ�짮���� ��� ������ ���
       �ࠢ����� � ���쭥�襬 ---
     @ �᢮������ � ������ ���� N ---
     @ ������� ᫥���騩 ᢮����� ���� ---
     @ ������� �᫮ ᢮������ ����� ---
     @ ������ ���� ⨯� Bitmap �� ����� ---
     @ ���� N �����-���? ---
     @ �������� Bitmap � ����� N �� ���� ---
     @ ��� ��� ����� N ������� ��� 16-梥��� ������� ---
     @ ��� ��।������ 256-������ ������ ��� RGB ---
     @ MapFrom4bppTo256 (���� N �����). ��� �����⭮�� �����
       ������� ��᮫��� ����� �� �⭮�⥫쭮��.
     @ MapFrom256To4bb - ��� ��᮫�⭮�� ������ ������� ---
       N 梥⮢��� ����� � �⭮�⥫�� ������,
       � ⠪��, �᫨ ����, � ��� ����㦥����� ��⬠��
     @

   # ࠧ��饭�� ��᪮�쪨� ����ࠦ���� 16 colors � ᢮���
     �����ࠬ� � ������ 256-梥⮢�� �����஢�� ����࠭�⢥ ---

   # ���࠭���� - ����㧪� �ࠣ���⮢ ��࠭�: ---
      * ������                     ---
      * �१ GetImage/PutImage   ---

   # �������� ����᪨� �ࠩ��  ---

   # �������� �����஢���� �ࠩ��,  ---
     �᫨ �� �ᯮ�짮���� ᢥ����� �����஢�� 梥⮢
     ��� ������� �ࠩ� �� ���譥� ।����
     �� ��� ᮧ�����, � � �ணࠬ�� ����� ���� ����㯭�
     16 ���⨭�� �㬬�୮, �� �ࠩ�� � 䮭��� ����ࠦ����.
     ����� �⮨� �뤥���� �� ��� 16-� ���� 梥⮢�� ����࠭�⢮
     ��� ��⥬��� 梥⮢. �������� �� �� ���� ���஥��� �
     ��࡮ ��᪠�� 16 �⠭������ 梥⮢ ������� EGA.

   # �� ���� �⮣� ��᫥������� � ��� ���� ᤥ����,
      * ���������樮���� �ணࠬ�� NAUKA  *---
      * ����������� "��⭠誨" � �᫮�묨 ���⪠�� ---
      * ����������� "��⭠誨" � �����-����ࠦ����� ---
        � ���⪠��-���⨭����
}

var
  d,m: integer;
  i,j : longint;
  fnt : integer;
  Palette : PaletteType;
  s: string;

procedure DRAW_16COLORS;
var
  R,G,B: byte;
  Ri,Gi,Bi: integer;
  slow_palette_16 : array [0..15] of record
                                       R: byte;
                                       G: byte;
                                       B: byte;
                                       Ri: integer;
                                       Gi: integer;
                                       Bi: integer;
                                     end;

begin
   {
   d:=VGA;
   m:=VGAhi;
   initgraph(d,m,'C:\BP\BGI\');
   }

   for i:=0 to 15 do
   begin
     GetRGBPalette(i,R,G,B);
     slow_palette_16[i].R:=R; slow_palette_16[i].Ri:=R;
     slow_palette_16[i].G:=G; slow_palette_16[i].Gi:=G;
     slow_palette_16[i].B:=B; slow_palette_16[i].Bi:=B;

     { ����㥬 ��।��� 梥��� ������  }
     setfillstyle(SOLIDFILL,i);
     bar( 0      , ( getmaxy div 16)*i ,
          getmaxx, ( getmaxy div 16)*(i+1) );

     { �뢥��� �� ������ ������ �� ���浪��� �����  }
     if (i<=7) then
       setcolor( i+7 )
     else
       setcolor( i-7 );
     settextstyle(2,HorizDIr,4);
     settextjustify(LeftText,CenterText);
     str(i,s);
     s:=s + ' COLOR INDEX';
     outtextxy( 10, ( (getmaxy div 16)*i ) + ((getmaxy div 16) div 2) -2,
                s );

   end;


   {
   readln;
   closegraph;
   for i:=0 to 15 do
   begin
     writeln(i, '  -  ',
              slow_palette_16[i].R,  ',' ,
              slow_palette_16[i].G,  ',' ,
              slow_palette_16[i].B
              );
   end;
   }

end;

procedure SCREEN_GRAB_COLORS;
type
  RGBRec = record
    RedVal, GreenVal, BlueVal: Integer;
  end;
const
  GRABColors: array[0..MaxColors] of RGBRec =
    (
      ( RedVal:$00; GreenVal:$00; BlueVal:$00 ),
      ( RedVal:$00; GreenVal:$00; BlueVal:$29 ),
      ( RedVal:$00; GreenVal:$29; BlueVal:$00 ),
      ( RedVal:$00; GreenVal:$29; BlueVal:$29 ),
      ( RedVal:$29; GreenVal:$00; BlueVal:$00 ),
      ( RedVal:$29; GreenVal:$00; BlueVal:$29 ),
      ( RedVal:$29; GreenVal:$15; BlueVal:$00 ),
      ( RedVal:$29; GreenVal:$29; BlueVal:$29 ),
      ( RedVal:$15; GreenVal:$15; BlueVal:$15 ),
      ( RedVal:$15; GreenVal:$15; BlueVal:$3F ),
      ( RedVal:$15; GreenVal:$3F; BlueVal:$15 ),
      ( RedVal:$15; GreenVal:$3F; BlueVal:$3F ),
      ( RedVal:$3F; GreenVal:$15; BlueVal:$15 ),
      ( RedVal:$3F; GreenVal:$15; BlueVal:$3F ),
      ( RedVal:$3F; GreenVal:$3F; BlueVal:$15 ),
      ( RedVal:$3F; GreenVal:$3F; BlueVal:$3F )
    );
var
  i,j : integer;
begin
   d:=VGA;
   m:=VGAhi;
   initgraph(d,m,'C:\BP\BGI\');

   for i:=0 to 15 do
   begin
     { ��⠭���� ��।��� 梥� ������� ��
       ����饩�� ⠡���� }
     setrgbpalette(i,
                     GRABColors[i].RedVal,
                     GRABColors[i].GreenVal,
                     GRABColors[i].BlueVal
                   );
   end;


   for i:=0 to 15 do
   begin

     { ����㥬 ��।��� 梥��� ������  }
     setfillstyle(SOLIDFILL,i);
     bar( 0      , ( getmaxy div 16)*i ,
          getmaxx, ( getmaxy div 16)*(i+1) );

     { �뢥��� �� ������ ������ �� ���浪��� �����  }
     if (i=0) then
       setcolor(15)
     else if (i<=7) then
       setcolor( i+7 )
     else
       setcolor( i-7 );
     settextstyle(2,HorizDIr,7);
     settextjustify(LeftText,CenterText);
     str(i,s);
     s:=s + ' COLOR INDEX';
     outtextxy( 25, ( (getmaxy div 16)*i ) + ((getmaxy div 16) div 2) -2,
                s );
   end;

  readln;
  closegraph;


end;



procedure EGA_COLORS;
type
  RGBRec = record
    RedVal, GreenVal, BlueVal: Integer;
  end;
const
  EGAColors: array[0..MaxColors] of RGBRec =
    (                                     {NAME       COLOR}
    (RedVal:$00;GreenVal:$00;BlueVal:$00),{Black      EGA  0}
    (RedVal:$00;GreenVal:$00;BlueVal:$FC),{Blue       EGA  1}
    (RedVal:$24;GreenVal:$FC;BlueVal:$24),{Green      EGA  2}
    (RedVal:$00;GreenVal:$FC;BlueVal:$FC),{Cyan       EGA  3}
    (RedVal:$FC;GreenVal:$14;BlueVal:$14),{Red        EGA  4}
    (RedVal:$B0;GreenVal:$00;BlueVal:$FC),{Magenta    EGA  5}
    (RedVal:$70;GreenVal:$48;BlueVal:$00),{Brown      EGA 20}
    (RedVal:$C4;GreenVal:$C4;BlueVal:$C4),{White      EGA  7}
    (RedVal:$34;GreenVal:$34;BlueVal:$34),{Gray       EGA 56}
    (RedVal:$00;GreenVal:$00;BlueVal:$70),{Lt Blue    EGA 57}
    (RedVal:$00;GreenVal:$70;BlueVal:$00),{Lt Green   EGA 58}
    (RedVal:$00;GreenVal:$70;BlueVal:$70),{Lt Cyan    EGA 59}
    (RedVal:$70;GreenVal:$00;BlueVal:$00),{Lt Red     EGA 60}
    (RedVal:$70;GreenVal:$00;BlueVal:$70),{Lt Magenta EGA 61}
    (RedVal:$FC;GreenVal:$FC;BlueVal:$24),{Yellow     EGA 62}
    (RedVal:$FC;GreenVal:$FC;BlueVal:$FC) {Br. White  EGA 63}
    );
var
  i,j : integer;
begin
   d:=VGA;
   m:=VGAhi;
   initgraph(d,m,'C:\BP\BGI\');

   for i:=0 to 15 do
   begin
     { ��⠭���� ��।��� 梥� ������� ��
       ����饩�� ⠡���� }
     setrgbpalette(i,
                     EGAColors[i].RedVal,
                     EGAColors[i].GreenVal,
                     EGAColors[i].BlueVal
                   );
   end;


   for i:=0 to 15 do
   begin

     { ����㥬 ��।��� 梥��� ������  }
     setfillstyle(SOLIDFILL,i);
     bar( 0      , ( getmaxy div 16)*i ,
          getmaxx, ( getmaxy div 16)*(i+1) );

     { �뢥��� �� ������ ������ �� ���浪��� �����  }
     if (i=0) then
       setcolor(15)
     else if (i<=7) then
       setcolor( i+7 )
     else
       setcolor( i-7 );
     settextstyle(2,HorizDIr,7);
     settextjustify(LeftText,CenterText);
     str(i,s);
     s:=s + ' COLOR INDEX';
     outtextxy( 25, ( (getmaxy div 16)*i ) + ((getmaxy div 16) div 2) -2,
                s );
   end;

  readln;
  closegraph;

end;


begin
   {
   SCREEN_GRAB_COLORS;
   EGA_COLORS;
   }
   d:=installuserdriver('BGI256',nil);
   m:=0;
   initgraph(d,m,'SPRUCHRS');


   DRAW_16COLORS;
   readln;
   Clear_Colors_Block(0);
   readln;

   Initialize_U2564BPP;
   DIRTY_TESTS;
   readln;

   closegraph;
   halt(0);
   { =======================================================  }


   d:=installuserdriver('BGI256',nil);
   m:=0;
   initgraph(d,m,'SPRUCHRS');
   SBMI('cenbibl2.bmp',0,0,0);

   fnt:=installuserfont('TSRC');
   settextstyle( 1, HorizDir,5);
   settextjustify( CenterText, CenterText );
   setcolor( 98 );
   outtextxy( getmaxx div 2, 50, '�������' );
   outtextxy( getmaxx div 2, getmaxy -  50, '�����' );


   randomize;
   {
   for i:=1 to 320*200-1 do
     Mem[ SegA000 : i ] := random(255);
   }

   readln;
   closegraph;
end.