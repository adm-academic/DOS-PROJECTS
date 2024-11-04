uses crt,graph, bmp;


var
  d,m: integer;

begin
   d:=installuserdriver('BGI256',nil);
   m:=0;
   initgraph(d,m,'');
   SBMI('cenbibl.bmp',0,0,0);

   readln;
   closegraph;
end.