program VGA_Mode_test;
uses crt, graph, sysutils;

var
  d,m : smallint;
  i,j: integer;
  xx, yy : smallint;

begin
   d:= 6;
   m := 0;
   initgraph(d,m,'C:\BP\BGI\');

  { setactivepage(0);
   setvisualpage(0);
  }

   randomize;
   for yy:=0 to 200-1 do
    for xx:=0 to 320-1 do
    begin
     PutPixel( xx, yy, random(GetMaxColor) );
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
