unit DPMIUtil;

interface

uses Objects, DPMI;

procedure ClearRegs (var Regs: TRealModeRegs);
function  XGlobalDosAlloc (Size: Longint; var RealSeg: Word): Pointer;
procedure XGlobalDosFree (P: Pointer);

implementation

uses WinAPI;

procedure ClearRegs (var Regs: TRealModeRegs);
begin
  FillChar (Regs, SizeOf (Regs), 0);
end;

function XGlobalDosAlloc (Size: Longint; var RealSeg: Word): Pointer;
var
  L: Longint;
begin
  L:= GlobalDosAlloc (Size);
  RealSeg:= LongRec (L).Hi;
  XGlobalDosAlloc:= Ptr (LongRec (L).Lo, 0);
end;

procedure XGlobalDosFree (P: Pointer);
begin
  GlobalDosFree (PtrRec (P).Seg);
end;

end.
