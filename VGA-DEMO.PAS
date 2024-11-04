uses Graph;

var
  Driver, Mode,
  TestDriver,
  ErrCode, i: Integer;

{$F+}
function TestDetect: Integer;
{ --- Функция автообнаружения. Возвращает рекомендуемый видеорежим --- }
begin
  TestDetect := 1;   { Основной режим драйвера = 1 }
end;
{$F-}

begin
  { Установка драйвера }
  TestDriver := InstallUserDriver('VGA256', @TestDetect);
  if GraphResult <> grOk then
  begin
    Writeln('Ошибка установки драйвера VGA 320x200x256');
    Halt(1);
  end;
  Driver := Detect;   { Перейти в графический режим }
  InitGraph(Driver, Mode, ' ');
  ErrCode := GraphResult;
  if ErrCode <> grOk then
  begin
    Writeln('Ошибка инициализации графики: ', ErrCode);
    Halt(1);
  end;

  { Продемонстрировать оттенки красного, синего и зеленого цветов }
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


