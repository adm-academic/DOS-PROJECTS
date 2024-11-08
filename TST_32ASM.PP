uses
  crt, mouse, graph, sysutils, go32;
{$APPTYPE CONSOLE}
{$ASMMODE INTEL}

begin
  asm
    mov eax, $0
    mov ebx, $CCDDEEFF
  end;

end.