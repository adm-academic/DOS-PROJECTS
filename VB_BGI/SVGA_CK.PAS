
uses crt, graph;

const
  max_mnumber = 10;

type
  GraphModeDescriptor = record
     mnumber: integer;
     mwidth:  longint;
     mheight: longint;
     mcolors: longint;
  end;

var
  d,m: integer;
  i:longint;
  R: integer;
  md: GraphModeDescriptor;
  apage: integer;

begin
   d:= installuserdriver('BGI256', nil);
   m:=2;
   initgraph(d,m,'c:\bp\bgi');
   md.mnumber := m;
   md.mwidth := GetMaxX+1;
   md.mheight := GetMaxY + 1;
   md.mcolors := GetMaxColor + 1;

   randomize;
   apage := 0;

   repeat
     Repeat Until Port[$3DA] And 8 = 8; { wait for vertical retrace }
     { setbkcolor(150);
       cleardevice; }
     setcolor(255);
     setfillstyle(1,150);
     bar(0,0,getmaxx-1,getmaxy-1);



     Repeat Until Port[$3DA] And 8 = 8; { wait for vertical retrace }
     {
     for i:=0 to (320*200-1) do
     begin
        Mem[ SegA000 : i ] := random(255);
      end;
     }

     for i:= 1 to 20
      do
     begin
       Repeat Until Port[$3DA] And 8 = 8; { wait for vertical retrace }
       setfillstyle( SOLIDFILL, random(255) );
       R:=random(120);
       fillellipse( random(getmaxx), random(getmaxy), R, R );
     end;

   until keypressed;

   CloseGraph;
   writeln( md.mnumber, ' : ', md.mwidth, 'x', md.mheight, 'x' , md.mcolors);


   {readln;}

end.
