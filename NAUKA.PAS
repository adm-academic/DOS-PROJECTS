uses crt,graph, bmp, U2564BPP;
{
  Программа для исследования возможностей программрования
  графики в режиме VGA 320x200 256 цветов.
  исследуем:
   # совместное использование
     драйверов BGI и прямого доступа к видеопамяти  +

   # быстрый блиттинг  в видеопамять ---
      - блиттинг подпрограмой Move(); ---
      - блиттинг инструкциями встроенного ассемблера ---

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

   # размещение нескольких изображений 16 colors со своими
     палитрами в едином 256-цветовом палитровом пространстве ---

   # Сохранение - загрузку фрагментов экрана: ---
      * вручную                     ---
      * через GetImage/PutImage   ---

   # подвижные статические спрайты  ---

   # подвижные анимированные спрайты,  ---
     если не использовать сведение палитровых цветов
     для каждого спрайта во внешнем редакторе
     при его создании, то в программе может быть доступно
     16 картинок суммарно, это спрайты и фоновые изображения.
     Также стоит выделить из этих 16-ти одно цветовое пространство
     для системных цветов. Возможно что это будут встроенные в
     Турбо Паскаль 16 стандартных цветов палитры EGA.

   # На базе этого исследования и его кода сделать,
      * демонтстрационную программу NAUKA  *---
      * головоломку "Пятнашки" с числовыми плитками ---
      * головоломку "Пятнашки" с полем-изображением ---
        и плитками-картинками
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

     { нарисуем очередную цветную полоску  }
     setfillstyle(SOLIDFILL,i);
     bar( 0      , ( getmaxy div 16)*i ,
          getmaxx, ( getmaxy div 16)*(i+1) );

     { выведем на каждую полоску её порядковый номер  }
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
     { установим очередной цвет палитры из
       имеющейся таблицы }
     setrgbpalette(i,
                     GRABColors[i].RedVal,
                     GRABColors[i].GreenVal,
                     GRABColors[i].BlueVal
                   );
   end;


   for i:=0 to 15 do
   begin

     { нарисуем очередную цветную полоску  }
     setfillstyle(SOLIDFILL,i);
     bar( 0      , ( getmaxy div 16)*i ,
          getmaxx, ( getmaxy div 16)*(i+1) );

     { выведем на каждую полоску её порядковый номер  }
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
     { установим очередной цвет палитры из
       имеющейся таблицы }
     setrgbpalette(i,
                     EGAColors[i].RedVal,
                     EGAColors[i].GreenVal,
                     EGAColors[i].BlueVal
                   );
   end;


   for i:=0 to 15 do
   begin

     { нарисуем очередную цветную полоску  }
     setfillstyle(SOLIDFILL,i);
     bar( 0      , ( getmaxy div 16)*i ,
          getmaxx, ( getmaxy div 16)*(i+1) );

     { выведем на каждую полоску её порядковый номер  }
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
   outtextxy( getmaxx div 2, 50, 'АПОФЕОЗ' );
   outtextxy( getmaxx div 2, getmaxy -  50, 'НАУКИ' );


   randomize;
   {
   for i:=1 to 320*200-1 do
     Mem[ SegA000 : i ] := random(255);
   }

   readln;
   closegraph;
end.