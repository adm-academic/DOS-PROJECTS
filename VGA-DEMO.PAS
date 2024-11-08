uses Graph;

var
  Driver, Mode,
  TestDriver,
  ErrCode, i: Integer;

{$F+}
function TestDetect: Integer;
{ --- �㭪�� ��⮮����㦥���. �����頥� ४�����㥬� �����०�� --- }
begin
  TestDetect := 1;   { �᭮���� ०�� �ࠩ��� = 1 }
end;
{$F-}

begin
  { ��⠭���� �ࠩ��� }
  TestDriver := InstallUserDriver('VGA256', @TestDetect);
  if GraphResult <> grOk then
  begin
    Writeln('�訡�� ��⠭���� �ࠩ��� VGA 320x200x256');
    Halt(1);
  end;
  Driver := Detect;   { ��३� � ����᪨� ०�� }
  InitGraph(Driver, Mode, ' ');
  ErrCode := GraphResult;
  if ErrCode <> grOk then
  begin
    Writeln('�訡�� ���樠����樨 ��䨪�: ', ErrCode);
    Halt(1);
  end;

  { �த�������஢��� ��⥭�� ��᭮��, ᨭ��� � �������� 梥⮢ }
  for i := 1 to 63 do begin
    SetRGBpalette(i, i, 0, 0);
    SetFillStyle(SolidFill, i); Bar(i*3, 0, i*3+3, 60);
    SetRGBpalette(i+63, 0, i, 0);
    SetFillStyle(SolidFill, i+63); Bar(i*3, 60, i*3+3, 120);
    SetRGBpalette(i+63*2, 0, 0, i);
    SetFillStyle(SolidFill, i+63*2); Bar(i*3, 120, i*3+3, 180);
  end;

  ReadLn;

  CloseGraph;
end.


