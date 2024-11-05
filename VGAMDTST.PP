program VGA_Mode_test;
uses crt, graph, go32, sysutils;
{$GOTO ON}
label
   again;

var
  d,m : smallint;
  i,j: integer;
  xx, yy : smallint;
  ii : longint;

begin
   d:= 6;
   m := 0;
   initgraph(d,m,'C:\BP\BGI\');

  { setactivepage(0);
   setvisualpage(0);
  }
  randomize;
  repeat
    again :
    for ii := 0 to 320*200-1 do
    begin
       Mem[ SegA000 : ii ] := random( 255 );
    end;
    settextstyle( 0,HorizDir,2 );
    setcolor( white );
    outtextxy( 5, 20, 'ENTER for Continue');
    delay( 15 );
  until keypressed;
  if readkey <> #13 then
    goto again;


  for ii := 0 to 320*200-1 do
    begin
       Mem[ SegA000 : ii ] := random( 255 );
    end;


   settextstyle( 0,HorizDir,2);
   setcolor( white );
   outtextxy( 20, 20, 'TEST BGI-LIKE');
   outtextxy( 20, 20 + 40, 'and DirectAccess.' );
   outtextxy( 20, 20 + 80, 'Page Number : ' + inttostr(0) );
   readln;

   {
   for i:=1 to 5 do
   begin
   setactivepage( i );
   setvisualpage( i );
   settextstyle( 3, HorizDir, 4 );
   setcolor( white );
   outtextxy( 20, 20 + 80, 'Page Number : ' + inttostr( i ) );
   readln;
   end;


   setactivepage(0);
   setvisualpage(0);
   }

   cleardevice;
   closegraph;
end.
