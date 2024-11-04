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
  i: integer;
  md: GraphModeDescriptor;

begin
   d:=installuserdriver('BGI256', nil);
   m:=0;
   initgraph(d,m,'');
   md.mnumber := m;
   md.mwidth := GetMaxX+1;
   md.mheight := GetMaxY + 1;
   md.mcolors := GetMaxColor + 1;
   CloseGraph;
   writeln( md.mnumber, ' : ', md.mwidth, 'x', md.mheight, 'x' , md.mcolors);

   readln;

end.