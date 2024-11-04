unit Vesa;

Interface

Type ModeList=Array[1..32] Of Word;  { List of VESA mode numbers }

     TVesaMode=Record
       Attr     : Word;         { Mode Attributes                   }
       WinA     : Byte;         { Window A attributes               }
       WinB     : Byte;         { Window B attributes               }
       Gran     : Word;         { Window granularity in K bytes     }
       WinSiz   : Word;         { Size of window in K bytes         }
       SegA     : Word;         { Segment address of window A       }
       SegB     : Word;         { Segment address of window B       }
       WinFunc  : Procedure;    { Windows positioning function      }
       Bytes    : Word;         { Number of bytes per line          }
       Width    : Word;         { Number of horizontal pixels       }
       Height   : Word;         { Number of vertical pixels         }
       CharW    : Byte;         { Width of character cell           }
       CharH    : Byte;         { Height of character cell          }
       Planes   : Byte;         { Number of memory planes           }
       Bits     : Byte;         { Number of bits per pixel          }
       nBanks   : Byte;         { Number of banks        (not used) }
       Model    : Byte;         { Memory model type                 }
       Banks    : Byte;         { Size of bank           (not used) }
       Pages    : Byte;         { Number of image pages             }
       Reserved : Byte; { The following are for 15,16,24,32 bit colour modes }
       RedMaskSize   : Byte;    { Size of Red mask in bits          }
       RedFieldPos   : Byte;    { Bit position of LSB of Red mask   }
       GreenMaskSize : Byte;    { Size of Green mask in bits        }
       GreenFieldPos : Byte;    { Bit position of LSB of Green mask }
       BlueMaskSize  : Byte;    { Size of Blue mask in bits         }
       BlueFieldPos  : Byte;    { Bit position of LSB of Blue mask  }
       RsvdMaskSize  : Byte;    { Size of Reserved mask in bits     }
       RsvdFieldPos  : Byte;    { Bit pos. of LSB of Reserved mask  }
       DirColModeInf : Byte;    { Direct Colour mode attributes     }
       Filler   : Array[0..215] Of Byte; { Not used - filler        }
     End;

     TVesaInfo=Record
       Signature    : LongInt;   { Signature - "VESA"               }
       Version      : Word;      { VESA Version number              }
       OEMName      : PChar;     { Pointer to manufacturer name     }
       Capabilities : Longint;   { Capabilities       (Not used)    }
       List         : ^ModeList; { Pointer to list of VESA modes    }
       TotalMemory  : Word;      { Number of 64k memory blocks on card }
       Filler       : Array[1..238] of Byte;
     End; { 258 byte size due to bug in the Diamond SpeedStar 24X v1.01 BIOS }


Var  VesaMode : TVesaMode;
                { Contains all info needed for drawing on the screen }
     VesaInfo : TVesaInfo;
                { Contains info on the VESA BIOS Extensions }

     vesaon   : Byte;
                { Specifies whether a VESA mode is on or not      }

     ClipRect : Record  { Clipping rectangle }
                  xl,yl,xh,yh : Integer;
                End;
const
     LastBank: Word = 11111;

Function  IsVesa:Boolean;
          { Detects whether VESA support is present }
Procedure GetVesaInfo;
          { Get Information on VESA modes, etc }
Procedure GetVesaModeInfo(md:Word);
          { Get Information on a VESA mode (md) }
Function  SetMode(md:Word):Boolean;
          { Sets a video mode (OEM and VESA) }
Function  GetMode:Word;
          { Returns the current video mode }
Function  SizeOfVideoState:Word;
          { Returns the size of the buffer needed to save the video state }
Procedure SaveVideoState(Var buf);
          { Saves the SVGA video state in the buffer }
Procedure RestoreVideoState(Var buf);
          { Restores the SVGA video state from the buffer}
procedure SetBank(Bank:Word);
          { Set the video bank to draw on }
Function  GetBank:Word;
          { Gets the current active video bank }
Procedure SetLineLength(Var len:Word);
          { Sets the logical scan line length, returns the actual length set }
Function  GetLineLength:Word;
          { Returns the current logical scan line length }
Procedure SetDisplayStart(pixel,line:Word);
          { Sets the first pixel and line on the display }
Procedure GetDisplayStart(Var pixel,line:Word);
          { Returns the first pixel and line on the display }
Procedure SetClipArea(xl,yl,xh,yh:Integer);
          { Sets the clipping area on the screen }

{---------------------------------------------------------------------------}
{-----------------------------} Implementation {----------------------------}
{---------------------------------------------------------------------------}

{$IFDEF DPMI}
uses Dos, DPMI, DPMIUtil;
{$ELSE}
uses Dos;
{$ENDIF}

Var  rp : Registers;

Function IsVesa:Boolean;
Begin
  rp.ax:=$4F03;
  Intr($10,rp);
  IsVesa:=(rp.al=$4F);
end;

{$IFDEF dpmi}

procedure GetVesaInfo;
var
  RP: TRealModeRegs;
  LocalVesaInfo: Pointer;
begin
  ClearRegs (RP);
  with RP do
  begin
    LocalVesaInfo := XGlobalDosAlloc(SizeOf(VesaInfo), ES);
    AX:=$4F00;
  end;
  RealModeInt ($10, RP);
  Move(LocalVesaInfo^, VesaInfo, SizeOf(VesaInfo));
  XGlobalDosFree (LocalVesaInfo);
end;

procedure GetVesaModeInfo(MD:Word);
var
  RP: TRealModeRegs;
  LocalVesaMode: Pointer;
begin
  ClearRegs (RP);
  with RP do
  begin
    LocalVesaMode := XGlobalDosAlloc (SizeOf(VesaMode), ES);
    AX:=$4F01;
    CX:=MD;
  end;
  RealModeInt ($10, RP);
  Move(LocalVesaMode^, VesaMode, SizeOf(VesaMode));
  XGlobalDosFree (LocalVesaMode);
End;

{$ELSE}
procedure GetVesaInfo;
begin
  RP.AX:=$4F00;
  RP.DI:=Ofs(VesaInfo);
  RP.ES:=Seg(VesaInfo);
  Intr($10,rp);
End;

Procedure GetVesaModeInfo(md:Word);
Begin
  rp.ax:=$4F01;
  rp.cx:=md;
  rp.di:=Ofs(VesaMode);
  rp.es:=Seg(VesaMode);
  Intr($10,rp);
End;
{$ENDIF}

Function SetMode(md:Word):Boolean;
begin
  SetMode:=True; VesaOn:=1;
  If md>$13 Then Begin
    rp.bx:=md;
    rp.ax:=$4F02;
    Intr($10,rp);
    If rp.ax<>$4F Then SetMode:=False Else GetVesaModeInfo(md);
  End Else Begin
    rp.ax:=md;
    Intr($10,rp);
    VesaMode.GRAN:=64; VesaOn:=0;
    VesaMode.SegA:=SegA000;
    case MD of  { OEM (standard) video modes }
      1..3,7 : Begin { Text modes }
                 VesaMode.Width:=80;  VesaMode.Height:=25;
                 if MD=7 then begin
                   VesaMode.Bits:=1;  VesaMode.SegA:=SegB000;
                 end else begin
                   VesaMode.Bits:=4;  VesaMode.SegA:=SegB800;
                 end;
                 VesaMode.Bytes:=160; VesaMode.Model:=0;
               End;
      $13 : Begin  { 320 x 200 x 256 colours, VGA & MCGA }
              VesaMode.Width:=320; VesaMode.Height:=200;
              VesaMode.Bits:=8;    VesaMode.Model:=4;
              VesaMode.Bytes:=320;
            End;
      $12 : Begin  { 640 x 480 x 16 colours, VGA only }
              VesaMode.Width:=640; VesaMode.Height:=480;
              VesaMode.Bits:=4;    VesaMode.Model:=3;
              VesaMode.Bytes:=80;
            End;
      $10 : Begin  { 640 x 350 x 16 colours, VGA & EGA with 128k+ }
              VesaMode.Width:=640; VesaMode.Height:=350;
              VesaMode.Bits:=4;    VesaMode.Model:=3;
              VesaMode.Bytes:=80;
            End;
      $0E : Begin  { 640 x 200 x 16 colours, VGA & EGA }
              VesaMode.Width:=640; VesaMode.Height:=200;
              VesaMode.Bits:=4;    VesaMode.Model:=3;
              VesaMode.Bytes:=80;
            End;
      $0D : Begin  { 320 x 200 x 16 colours, VGA & EGA }
              VesaMode.Width:=320; VesaMode.Height:=200;
              VesaMode.Bits:=4;    VesaMode.Model:=3;
              VesaMode.Bytes:=40;
            End;
      Else SetMode:=False;
    End;
  End;
  SetClipArea(0,0,VesaMode.Width-1,VesaMode.Height-1);
End;

Function GetMode:Word;
Begin
  rp.ax:=$4F03;
  Intr($10,rp);
  GetMode:=rp.bx;
End;

Function SizeOfVideoState:Word;
Begin  { Will save/restore all video states }
  rp.ax:=$4F04;
  rp.dl:=0;
  rp.cx:=$0F;  { hardware, BIOS, DAC & SVGA states }
  Intr($10,rp);
  SizeOfVideoState:=rp.bx;
End;

Procedure SaveVideoState(Var buf);
Begin
  rp.ax:=$4F04;
  rp.dl:=1;
  rp.cx:=$0F;
  rp.es:=Seg(buf);
  rp.bx:=Ofs(buf);
  Intr($10,rp);
End;

Procedure RestoreVideoState(Var buf);
Begin
  rp.ax:=$4F04;
  rp.dl:=2;
  rp.cx:=$0F;
  rp.es:=Seg(buf);
  rp.bx:=Ofs(buf);
  Intr($10,rp);
End;

procedure SetBank(Bank:Word);
var WinNum:Word;
Begin
  winnum:=bank*64 Div VesaMode.Gran;
  rp.ax:=$4F05;
  rp.bx:=0;
  rp.dx:=winnum;
  Intr($10,rp);
  rp.ax:=$4F05;
  rp.bx:=1;
  rp.dx:=winnum;
  Intr($10,rp);
  LastBank := Bank;
end;

Function GetBank:Word;
Begin
  rp.ax:=$4F05;
  rp.bx:=$100;
  Intr($10,rp);
  GetBank:=rp.dx;
End;

Procedure SetLineLength(Var len:Word);
Begin
  rp.ax:=$4F06;
  rp.bl:=0;
  rp.cx:=len;
  Intr($10,rp); { dx:=maximum number of scan lines }
  len:=rp.cx;
End;

Function GetLineLength:Word;
Begin
  rp.ax:=$4F06;
  rp.bl:=1;
  Intr($10,rp); { dx:=maximum number of scan lines }
  GetLineLength:=rp.cx;
End;

Procedure SetDisplayStart(pixel,line:Word);
Begin
  rp.ax:=$4F07;
  rp.bx:=0;
  rp.cx:=pixel;
  rp.dx:=line;
  Intr($10,rp);
End;

Procedure GetDisplayStart(Var pixel,line:Word);
Begin
  rp.ax:=$4F07;
  rp.bx:=1;
  Intr($10,rp);
  pixel:=rp.cx;
  line:=rp.dx;
End;

{===============================}

Procedure SetClipArea(xl,yl,xh,yh:Integer);
Begin
  { Set the region of clipping }
  ClipRect.xl:=xl;
  ClipRect.yl:=yl;
  ClipRect.xh:=xh;
  ClipRect.yh:=yh;
End;

End.