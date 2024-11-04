unit
  SVGraph;

interface

type
  LongRec = record
    Lo: Word;
    Hi: Integer;
  end;

const
  DrawMode: Integer = 0;

procedure PutPixel(X, Y: Integer; Color: Byte);
function GetPixel(X, Y: Integer): Byte;
procedure Line(X1, Y1, X2, Y2: Integer; Color: Byte);
procedure Rectangle(X1, Y1, X2, Y2: Integer; Color: Byte);
procedure Bar(X1, Y1, X2, Y2: Integer; Color: Byte);
procedure PutImage(X1, Y1: Integer; var BitMap);
procedure SetPalette(var Palette);

implementation

uses
  Vesa, Objects, Crt, Dos{$IFDEF DPMI},DPMI, DPMIUtil{$ENDIF};

procedure PutPixel;
var
  Offset: Longint;
  Bank: Integer;
begin
  if (X >= 0) and (Y >= 0) and (X < VesaMode.Width)
  and (Y < VesaMode.Height) then begin
    Offset := LongMul(Y, VesaMode.Width) + X;
    Bank := LongRec(Offset).Hi;
    if Bank <> LastBank then SetBank(Bank);
    case DrawMode of
    0: Mem[SegA000: LongRec(Offset).Lo] := Color;
    1: Mem[SegA000: LongRec(Offset).Lo] := Color xor Mem[SegA000: LongRec(Offset).Lo];
    2: Mem[SegA000: LongRec(Offset).Lo] := Color or Mem[SegA000: LongRec(Offset).Lo];
    end;
  end;
end;

function GetPixel;
var
  Offset: Longint;
  Bank: Integer;
begin
  if (X >= 0) and (Y >= 0) and (X < VesaMode.Width)
  and (Y < VesaMode.Height) then begin
    Offset := LongMul(Y, VesaMode.Width) + X;
    Bank := LongRec(Offset).Hi;
    if Bank <> LastBank then SetBank(Bank);
    GetPixel := Mem[SegA000: LongRec(Offset).Lo];
  end;
end;

procedure Line;
var
  D, X, Y,
  DX, DY,
  NX, NY,
  IncR1, IncR2,
  XEnd, YEnd     : Integer;
Begin
  DX := Abs (X2 - X1);
  DY := Abs (Y2 - Y1);
  if DX > DY then
  begin
    D := 2 * DY - DX;
    IncR1 := 2 * DY;
    IncR2 := 2 * (DY - DX);
    XEnd := X2;
  end
  else
  begin
    D := 2 * DX - DY;
    IncR1 := 2 * DX;
    IncR2 := 2 * (DX - DY);
    YEnd := Y2;
  end;
  if X1 > X2 then NX := -1
  else            NX :=  1;
  if Y1 > Y2 then NY := -1
  else            NY :=  1;
  X := X1;
  Y := Y1;
  PutPixel(X, Y, Color);
  if DY < DX then
    while X <> XEnd do
    begin
      X := X+NX;
      if D < 0 then D := D+IncR1
      else begin
        Y := Y+NY;
        D := D+IncR2;
      end;
      PutPixel(X, Y, Color);
    end
  else
    while Y <> YEnd do
    begin
      Y := Y+NY;
      if D < 0 then D := D+IncR1
      else begin
        X := X+NX;
        D := D+IncR2;
      end;
       PutPixel(X, Y, Color);
    end;
end;

procedure Rectangle;
begin
  Line(X1, Y1, X2, Y1, Color);
  Line(X2, Y1, X2, Y2, Color);
  Line(X2, Y2, X1, Y2, Color);
  Line(X1, Y2, X1, Y1, Color);
end;

procedure HLine(AOffset, ABank: Word; Length: Integer; Color: Byte);
begin
  if (AOffset < Word(-VesaMode.Width)) or (AOffset <= Word(-Length)) then asm
      cld
      mov  ax, SegA000
      mov  es, ax
      mov  al, Color
      mov  di, AOffset
      mov  cx, Length
      rep  stosb
  end else asm
      cld
      mov  ax, SegA000
      mov  es, ax
      mov  al, Color
      mov  di, AOffset
      mov  cx, di
      neg  cx
      sub  length, cx
      rep  stosb
  @1: push ax
      push es
      push di
      push cx
      inc  ABank
      push ABank
      call SetBank
      pop  cx
      pop  di
      pop  es
      pop  ax
      mov  cx, length
      jcxz @3
  @2: rep  stosb
  @3:
  end;
end;

procedure Bar;
var
  I: Integer;
  Offset: Longint;
begin
  if (X2 < X1) or (X2 < 0) or (X1 > VesaMode.Width) then Exit;
  if X1 < 0 then X1 := 0;
  if X2 >= VesaMode.Width then X2 := VesaMode.Width - 1;

  if (Y2 < Y1) or (Y2 < 0) or (Y1 > VesaMode.Height) then Exit;
  if Y1 < 0 then Y1 := 0;
  if Y2 >= VesaMode.Height then Y2 := VesaMode.Height - 1;

  Offset := LongMul(Y1, VesaMode.Width) + X1;

  for I := Y1 to Y2 do begin
    if LongRec(Offset).Hi <> LastBank then SetBank(LongRec(Offset).Hi);
    HLine(LongRec(Offset).Lo, LongRec(Offset).Hi, X2 - X1 + 1, Color);
    Inc(Offset, VesaMode.Width);
  end;
end;

procedure ImageLine(AOffset, ABank: Word; Length: Integer; var BitMap);
begin
  if (AOffset < Word(-VesaMode.Width)) or (AOffset <= Word(-Length)) then asm
      push ds
      cld
      mov  ax, SegA000
      mov  es, ax
      mov  di, AOffset
      mov  cx, Length
      lds  si, BitMap
      rep  movsb
      pop  ds
  end else asm
      cld
      push ds
      mov  ax, SegA000
      mov  es, ax
      mov  di, AOffset
      mov  cx, di
      neg  cx
      sub  length, cx
      lds  si, BitMap
      rep  movsb
  @1: push ax
      push es
      push di
      push cx
      push ds
      push si
      mov  ax, seg @Data
      mov  ds, ax
      inc  ABank
      push ABank
      call SetBank
      pop  si
      pop  ds
      pop  cx
      pop  di
      pop  es
      pop  ax
      mov  cx, length
      jcxz @3
  @2: rep  movsb
  @3:
      pop  ds
  end;
end;

procedure PutImage;
var
  X2, Y2: Integer;
  I: Integer;
  Offset: Longint;
  BitMapOffset: Longint;
begin
  X2 := X1 + TWordArray(BitMap)[0];
  Y2 := Y1 + TWordArray(BitMap)[1];
  if (X2 < X1) or (X2 < 0) or (X1 > VesaMode.Width) then Exit;
  if X1 < 0 then X1 := 0;
  if X2 >= VesaMode.Width then X2 := VesaMode.Width - 1;

  if (Y2 < Y1) or (Y2 < 0) or (Y1 > VesaMode.Height) then Exit;
  if Y1 < 0 then Y1 := 0;
  if Y2 >= VesaMode.Height then Y2 := VesaMode.Height - 1;

  Offset := LongMul(Y1, VesaMode.Width) + X1;
  BitMapOffset := 4;
  for I := Y1 to Y2 do begin
    if LongRec(Offset).Hi <> LastBank then SetBank(LongRec(Offset).Hi);
    ImageLine(LongRec(Offset).Lo, LongRec(Offset).Hi, X2 - X1 + 1, TByteArray(BitMap)[BitMapOffset]);
    Inc(BitMapOffset, TWordArray(BitMap)[0] + 1);
    Inc(Offset, VesaMode.Width);
  end;
end;

{$IFDEF DPMI}
procedure SetPalette;
var
  RP: TRealModeRegs;
  LocalPalette: Pointer;
begin
  ClearRegs (RP);
  with RP do
  begin
    LocalPalette := XGlobalDosAlloc(768, ES);
    Move(Palette, LocalPalette^, 768);
    AX := $1012;
    CX := 256;
    BX := 0;
  end;
  RealModeInt ($10, RP);
  XGlobalDosFree (LocalPalette);
end;
{$ELSE}
procedure SetPalette;
var
  R: Registers;
begin
  R.AX := $1012;
  R.ES := Seg(Palette);
  R.DX := Ofs(Palette);
  R.CX := 256;
  R.BX := 0;
  Intr($10, R);
end;
{$ENDIF}

end.
