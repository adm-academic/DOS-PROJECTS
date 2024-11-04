{
  Fast VESA Unit v1.0
  (c) 1997 by NemO & sk
  Based on direct memory access.
}
{$f+}
unit FastVESA;
 interface
  type
   TVESAInfo    = record
                   Signature       : longint;
                   Version         : word;
                   OEMName         : pointer;
                   Capabilities    : longint;
                   Modes           : pointer;
                   Memory          : word;
                   Reserv          : array [1..236] of byte;
                  end;

   TVESAMode    = record
                   Attributes      : word;
                   WinAAttr        : byte;
                   WinBAttr        : byte;
                   WinGran         : word;
                   WinSize         : word;
                   WinASeg         : word;
                   WinBSeg         : word;
                   WinFunc         : procedure;
                   BytesPLine      : word;
                   Width           : word;
                   Height          : word;
                   CharWidth       : byte;
                   CharHeight      : byte;
                   Planes          : byte;
                   BitsPPixel      : byte;
                   Banks           : byte;
                   MemModel        : byte;
                   BankSize        : byte;
                   ImagePages      : byte;
                   Reserv1         : byte;
                   RedMaskSize     : byte;
                   RedFieldPos     : byte;
                   GreenMaskSize   : byte;
                   GreenFieldPos   : byte;
                   BlueMaskSize    : byte;
                   BlueFieldPos    : byte;
                   ResMaskSize     : byte;
                   ResFieldPos     : byte;
                   ColorModeInfo   : byte;
                   Reserv2         : array [1..216] of byte;
                  end;

   PImage       = ^TImage;
   TImage       = record
                   X,Y      : integer;
                   Data     : record end;
                  end;

  const
   VideoScr : pointer = Ptr($a000,0);
   ptNormal           = 0;
   ptNot              = 1;
   ptOverlay          = 2;
   ptXor              = 3;
   ptOr               = 4;
   ptAnd              = 5;

  var
   VESAInfo     : TVESAInfo;
   VESAMode     : TVESAMode;
   OldVideoMode : byte;
   CurrentBank  : word;
   IsVESA       : boolean;
   VESAError    : byte;

  procedure VESAInit;
  procedure VESADone;
  procedure GetVESAInfo;
  procedure GetVESAModeInfo(Mode : word);
  procedure SetVESAMode(Mode : word);
  function GetVESAMode : word;
  procedure SetVESABank(Bank : word);
  function GetVESABank : word;
  procedure ClearScreen(Color : byte);
  function GetMaxX : integer;
  function GetMaxY : integer;
  procedure OffMonitor;
  procedure OnMonitor;
  procedure Retrace;
  procedure PutPixel(X,Y : integer; Color : byte);
  function GetPixel(X,Y : integer) : byte;
  procedure Line(X1,Y1,X2,Y2 : integer; Color : byte);
  procedure Box(X1,Y1,X2,Y2 : integer; Color : byte; Filled : boolean);
  procedure Fill(X,Y : integer; Color,BorderColor : byte);
  procedure Circle(X,Y,R : integer; Color : byte);
  function ImageSize(X1,Y1,X2,Y2 : integer) : longint;
  procedure AllocateImage(var Image : PImage; X1,Y1,X2,Y2 : integer);
  procedure DeallocateImage(var Image : PImage);
  procedure GetImage(Image : PImage; X1,Y1,X2,Y2 : integer);
  procedure PutImage(Image : PImage; X1,Y1 : integer; PutType : byte);
  procedure SetRGBColor(Color,R,G,B : byte);
  procedure GetRGBColor(Color : byte; var R,G,B : byte);
  procedure SetRGBPalette(Palette : pointer;FirstColor,LastColor : byte);
  procedure GetRGBPalette(Palette : pointer;FirstColor,LastColor : byte);

 implementation

  function Sign(Testing : integer) : integer; assembler;
   asm
    cmp [Testing],0
    je @equal
    jl @lower
    mov ax,1
    jmp @exit
@equal:
    xor ax,ax
    jmp @exit
@lower:
    mov ax,-1
@exit:
   end;

  function Absol(X : integer) : integer; assembler;
   asm
    mov ax,[X]
    cmp ax,0
    jge @exit
    neg ax
@exit:
   end;

  procedure SameBank(X1,Y1,X2,Y2 : integer); assembler;
   asm
    mov ax,[Y1]
    mul [VESAMode.Width]
    add ax,[X1]
    adc dx,0
    mov bx,dx
    push ax
    mov ax,[Y2]
    mul [VESAMode.Width]
    add ax,[X2]
    adc dx,0
    cmp bx,dx
    je @equal
    mov cx,ax
    pop bx
    mov ax,0
    jmp @exit
@equal:
    pop bx
    mov ax,1
@exit:
   end;

  procedure VESAInit; assembler;
   asm
    push ax
    mov ah,0fh
    int 10h
    mov [OldVideoMode],al
    call GetVESAInfo
    cmp al,4fh
    jne @noVESA
    mov [IsVESA],1
    jmp @Exit
@noVESA:
    mov [IsVESA],0
@Exit:
    pop ax
   end;

  procedure VESADone; assembler;
   asm
    push ax
    mov al,[OldVideoMode]
    xor ah,ah
    int 10h
    pop ax
   end;

  procedure GetVESAInfo; assembler;
   asm
    push es
    push di
    mov ax,seg VESAInfo
    mov es,ax
    mov di,offset VESAInfo
    mov ax,4f00h
    int 10h
    pop di
    pop es
   end;

  procedure GetVESAModeInfo(Mode : word); assembler;
   asm
    cmp [IsVESA],0
    je @exit
    push ax
    push es
    push di
    push cx
    mov ax,seg VESAMode
    mov es,ax
    mov di,offset VESAMode
    mov ax,4f01h
    mov cx,[Mode]
    int 10h
    pop cx
    pop di
    pop es
    pop ax
@exit:
   end;

  procedure SetVESAMode(Mode : word); assembler;
   asm
    cmp [IsVESA],0
    je @exit;
    push ax
    push bx
    mov ax,4f02h
    mov bx,[Mode]
    int 10h
    push [Mode]
    call GetVESAModeInfo
    pop bx
    pop ax
@exit:
   end;

  function GetVESAMode : word; assembler;
   asm
    cmp [IsVESA],0
    je @exit
    push bx
    mov ax,4f03h
    int 10h
    mov ax,bx
    pop bx
@exit:
   end;

  procedure SetVESABank(Bank : word); assembler;
   asm
    cmp [IsVESA],0
    je @exit
    push ax
    push bx
    push cx
    push dx
    mov ax,[Bank]
    cmp ax,[CurrentBank]
    je @q
    mov [CurrentBank],ax
    mov bx,64
    mul bx
    div [VESAMode.WinGran]
    mov dx,ax
    push dx
    mov bx,0
    mov ax,4f05h
    int 10h
    mov ax,4f05h
    pop dx
    mov bx,1
    int 10h
@q:
    pop dx
    pop cx
    pop bx
    pop ax
@exit:
   end;

  function GetVESABank : word; assembler;
   asm
    cmp [IsVESA],0
    je @exit
    mov ax,[CurrentBank]
@exit:
   end;

  procedure ClearScreen(Color : byte); assembler;
   asm
    cmp [IsVESA],0
    je @exit
    push ax
    push es
    push di
    push cx
    push dx
    mov ax,[VESAMode.WinASeg]
    mov es,ax
    xor di,di
    mov bx,0
    mov ax,[VESAMode.Width]
    mul [VESAMode.Height]
    inc dx
    cld
@loop:
    push bx
    call SetVESABank
    mov cx,0ffffh
    mov al,[Color]
    rep stosb
    stosb
    inc bx
    cmp bx,dx
    jne @loop
    pop dx
    pop cx
    pop di
    pop es
    pop ax
@exit:
   end;

  function GetMaxX : integer; assembler;
   asm
    cmp [IsVESA],0
    je @exit
    mov ax,[VESAMode.Width]
    dec ax
@exit:
   end;

  function GetMaxY : integer; assembler;
   asm
    cmp [IsVESA],0
    je @exit
    mov ax,[VESAMode.Height]
    dec ax
@exit:
   end;

  procedure OffMonitor; assembler;
   asm
    cmp [IsVESA],0
    je @exit

@exit:
   end;

  procedure OnMonitor; assembler;
   asm
    cmp [IsVESA],0
    je @exit
@exit:
   end;

  procedure Retrace; assembler;
   asm
    cmp [IsVESA],0
    je @exit
    push dx
    push ax
    mov dx,3DAh
@l1:
    in al,dx
    and al,08h
    jnz @l1
@l2:
    in al,dx
    and al,08h
    jz  @l2
    pop ax
    pop dx
@exit:
   end;

  procedure PutPixel(X,Y : integer; Color : byte); assembler;
   asm
    cmp [IsVESA],0
    je @exit
    push ax
    push bx
    push dx
    push es
    push di
    mov ax,[Y]
    mov bx,[VESAMode.Height]
    cmp ax,bx
    jge @badcoord
    mov dx,[X]
    mov bx,[VESAMode.Width]
    cmp dx,bx
    jge @badcoord
    mul bx
    add ax,[X]
    adc dx,0
    mov di,ax
    push dx
    call SetVESABank
    mov bx,[VESAMode.WinASeg]
    mov es,bx
    mov al,[Color]
    stosb
@badcoord:
    pop di
    pop es
    pop dx
    pop bx
    pop ax
@exit:
   end;

  function GetPixel(X,Y : integer) : byte; assembler;
   asm
    cmp [IsVESA],0
    je @exit
    push ds
    push si
    push bx
    push dx
    mov ax,[Y]
    mov bx,[VESAMode.Width]
    mul bx
    add ax,[X]
    adc dx,0
    mov si,ax
    push dx
    call SetVESABank
    mov bx,[VESAMode.WinASeg]
    mov ds,bx
    lodsb
    pop dx
    pop bx
    pop si
    pop ds
@exit:
   end;

  procedure Line(X1,Y1,X2,Y2 : integer; Color : byte); assembler;
   var
    Dly,Dx1,Dy1,Dx2,Dy2 : integer;
   asm
    cmp [IsVESA],0
    je @exit
    push ax
    push bx
    push cx
    push dx
    push si
    push di
    mov cx,[X1]
    mov dx,[Y1]
    mov di,[X2]{Dx:=X2-X1;}
    sub di,cx
    mov ax,[Y2]{Dy:=Y2-Y1;}
    sub ax,dx
    mov [Dly],ax
    push di{Dx1:=SGN(Dx);}
    call Sign
    mov [Dx1],ax
    mov [Dx2],ax{Dx2:=SGN(Dx);}
    push [Dly]{Dy1:=SGN(Dy);}
    call Sign
    mov [Dy1],ax
    mov [Dy2],0{Dy2:=0;}
    push di{Dx:=ABS(Dx);}
    call Absol
    mov di,ax
    push [Dly]{Dy:=ABS(Dy);}
    call Absol
    mov [Dly],ax
    cmp di,ax{If Dx<=Dy Then}
    jg @cont
    mov [Dx2],0  {Dx2:=0;}
    mov ax,[Dy1]  {Dy2:=SGN(Dy);}
    mov [Dy2],ax
    mov ax,[Dly]  {Dx:=ABS(Dy);}
    xchg ax,di  {Dy:=ABS(Dx);}
    mov [Dly],ax
@cont:
    mov si,0 {s:=0;}
    mov bx,0{For i:=0 To Dx Do}
@loop:
    push cx
    push dx
    push word [Color]
    call putpixel   {putpixel(X1,Y1,Color);}
    add si,[Dly]   {s:=s+Dy;}
    cmp si,di    {If s<dx Then}
    jge @otherway
    add cx,[Dx2]     {X1:=X1+Dx2;}
    add dx,[Dy2]     {Y1:=Y1+Dy2;}
    jmp @cont2
@otherway:
    sub si,di     {s:=s-Dx;}
    add cx,[Dx1]     {X1:=X1+Dx1;}
    add dx,[Dy1]     {Y1:=Y1+Dy1;}
@cont2:
    inc bx
    cmp bx,di
    jle @loop
    pop di
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
@exit:
   end;

  procedure Box(X1,Y1,X2,Y2 : integer; Color : byte; Filled : boolean); assembler;
   asm
    cmp [IsVESA],0
    je @exit
    cmp [Filled],1
    je @fill
    push [X1]
    push [Y1]
    push [X2]
    push [Y1]
    push word [Color]
    call Line
    push [X1]
    push [Y1]
    push [X1]
    push [Y2]
    push word [Color]
    call Line
    push [X1]
    push [Y2]
    push [X2]
    push [Y2]
    push word [Color]
    call Line
    push [X2]
    push [Y1]
    push [X2]
    push [Y2]
    push word [Color]
    call Line
    jmp @exit
@fill:
    push ax
    push dx
    push bx
    push es
    push di
    les di,VideoScr
    mov bx,[Y2]
    cmp bx,[Y1]
    jge @cont
    mov ax,[Y1]
    mov [Y2],ax
    mov [Y1],bx
    mov bx,ax
    sub bx,[Y1]
@cont:
    mov dx,[Y1]
    inc bx
@loop:
    push dx
    push bx
    push [X1]
    push dx
    push [X2]
    push dx
    call SameBank
    cmp ax,1
    je @same
    xor di,di
    push dx
    call SetVESABank
    mov al,[Color]
    rep stosb
    mov cx,bx
    neg cx
    dec dx
    mov di,bx
    jmp @cont1
@same:
    mov di,bx
    mov cx,[X2]
    sub cx,[X1]
@cont1:
    push dx
    call SetVESABank
    mov al,[Color]
    rep stosb
    pop bx
    pop dx
    inc dx
    cmp dx,bx
    jne @loop
    pop bx
    pop dx
    pop ax
@exit:
   end;

  procedure Fill(X,Y : integer; Color,BorderColor : byte); assembler;
   asm
    cmp [IsVESA],0
    je @exit
@exit:
   end;

  procedure Circle(X,Y,R : integer; Color : byte); assembler;
   asm
    cmp [IsVESA],0
    je @exit
@exit:
   end;

  function ImageSize(X1,Y1,X2,Y2 : integer) : longint; assembler;
   asm
    cmp [IsVESA],0
    je @exit
    push bx
    mov ax,[X2]
    sub ax,[X1]
    mov bx,[Y2]
    sub bx,[Y1]
    mul bx
    pop bx
@exit:
   end;

  procedure AllocateImage(var Image : PImage; X1,Y1,X2,Y2 : integer);
   begin
    if not IsVESA then exit;
    GetMem(Image,4+ImageSize(X1,Y1,X2,Y2));

   end;

  procedure DeallocateImage(var Image : PImage);
   begin
    if Image=nil then exit;
    FreeMem(Image,4+Image^.X*Image^.Y);
   end;

  procedure GetImage(Image : PImage; X1,Y1,X2,Y2 : integer); assembler;
   var
    OldDS       : word;
   asm
    cmp [IsVESA],0
    je @exit
    push ax
    push dx
    push bx
    push es
    push di
    push ds
    push si
    les di,Image
    mov [OldDS],ds
    mov ax,[VESAMode.WinASeg]
    mov ds,ax
    xor si,si
    cld
    mov bx,[X2]
    cmp bx,[X1]
    jge @cont
    xchg bx,[X1]
    mov [X2],bx
@cont:
    mov ax,[X2]
    sub ax,[X1]
    stosw
    mov bx,[Y2]
    cmp bx,[Y1]
    jge @cont1
    mov ax,[Y1]
    mov [Y2],ax
    mov [Y1],bx
    mov bx,ax
@cont1:
    mov ax,[Y2]
    sub ax,[Y1]
    stosw
    mov dx,[Y1]
    inc bx
@loop:
    push dx
    push bx
    push ds
    push si
    mov ds,[OldDS]
    push [X1]
    push dx
    push [X2]
    push dx
    call SameBank
    pop si
    pop ds
    cmp ax,1
    je @same
    push cx
    dec dx
    push ds
    mov ds,[OldDS]
    push dx
    call SetVESABank
    pop ds
    mov cx,bx
    mov si,bx
    neg cx
    rep movsb
    xor si,si
    pop cx
    inc dx
    jmp @cont2
@same:
    mov si,bx
    mov cx,[X2]
    sub cx,[X1]
@cont2:
    push ds
    mov ds,[OldDS]
    push dx
    call SetVESABank
    pop ds
    rep movsb
    pop bx
    pop dx
    inc dx
    cmp dx,bx
    jne @loop
    pop si
    pop ds
    pop di
    pop es
    pop bx
    pop dx
    pop ax
@exit:
   end;

  procedure PutImage(Image : PImage; X1,Y1 : integer; PutType : byte); assembler;
   var
    X2,Y2       : integer;
    OldDS       : word;
   asm
    cmp [IsVESA],0
    je @exit
    push ds
    push si
    push es
    push di
    push ax
    push bx
    push cx
    push dx
    mov [OldDS],ds
    mov es,[VESAMode.WinASeg]
    lds si,Image
    mov cx,[X1]
    mov dx,[Y1]
    lodsw
    add ax,cx
    mov [X2],ax
    lodsw
    add ax,dx
    mov [Y2],ax

@loopY:
    mov cx,[X1]

@loopX:

    lodsb
    push ax
    push dx
    push ds
    mov ds,[OldDS]
    mov ax,dx
    mov bx,dx
    mul [VESAMode.Width]
    add ax,cx
    adc dx,0
    push dx
    call SetVESABank
    pop ds
    pop dx
    mov di,ax
    pop ax

    cmp [PutType],2
    jg @getpix
    je @cont1
    cmp [PutType],1
    jne @cont5
    not ax
    jmp @cont5

@cont1:
    cmp ax,0
    je @cont6
    jmp @cont5

@getpix:
    mov bx,ax
    push ds
    push si
    mov ax,es
    mov ds,ax
    mov si,di
    lodsb
    pop si
    pop ds

    cmp [PutType],3
    jne @cont3
    xor ax,bx
    jmp @cont5

@cont3:
    cmp [PutType],4
    jne @cont4
    or ax,bx
    jmp @cont5

@cont4:
    cmp [PutType],5
    jne @cont5
    and ax,bx

@cont5:
    stosb
@cont6:
    push ds
    mov ds,[OldDS]
    inc cx
    cmp cx,[VESAMode.Width]
    pop ds
    jne @notborder
    mov ax,[X2]
    sub ax,cx
    add si,ax
    jmp @checkY

@notborder:
    cmp cx,[X2]
    jne @loopX

@checkY:
    push ds
    mov ds,[OldDS]
    inc dx
    cmp dx,[VESAMode.Height]
    pop ds
    jne @notbottom
    jmp @enddrawing

@notbottom:
    cmp dx,[Y2]
    jne @loopY

@enddrawing:
    pop dx
    pop cx
    pop bx
    pop ax
    pop di
    pop es
    pop si
    pop ds
@exit:
   end;

  procedure SetRGBColor(Color,R,G,B : byte); assembler;
   asm
    cmp [IsVESA],0
    je @exit
    push dx
    push ax
    mov dx,3c8h
    mov al,[Color]
    out dx,al
    inc dx
    mov al,[R]
    out dx,al
    mov al,[G]
    out dx,al
    mov al,[B]
    out dx,al
    pop ax
    pop dx
@exit:
   end;

  procedure GetRGBColor(Color : byte;var R,G,B : byte); assembler;
   asm
    cmp [IsVESA],0
    je @exit
    push ax
    push dx
    push es
    push di
    mov dx,3c7h
    mov al,[Color]
    out dx,al
    add dx,2
    in al,dx
    les di,R
    mov es:[di],al
    in al,dx
    les di,G
    mov es:[di],al
    in al,dx
    les di,B
    mov es:[di],al
    pop di
    pop es
    pop dx
    pop ax
@exit:
   end;

  procedure SetRGBPalette(Palette : pointer;FirstColor,LastColor : byte); assembler;
   asm
    cmp [IsVESA],0
    je @exit
    push ds
    push si
    push dx
    push ax
    push bx
    push cx
    lds si,Palette
    mov cl,[FirstColor]
    mov al,[LastColor]
    sub al,cl
    mov bl,3
    mul bl
    mov bx,si
    add bx,ax
    add bx,3
    cld
@loop:
    mov dx,3c8h
    mov al,cl
    out dx,al
    inc dx
    lodsb
    out dx,al
    lodsb
    out dx,al
    lodsb
    out dx,al
    inc cl
    cmp si,bx
    jne @loop
    pop cx
    pop bx
    pop ax
    pop dx
    pop si
    pop ds
@exit:
   end;

  procedure GetRGBPalette(Palette : pointer;FirstColor,LastColor : byte); assembler;
   asm
    cmp [IsVESA],0
    je @exit
    push es
    push di
    push dx
    push ax
    push bx
    push cx
    les di,Palette
    mov cl,[FirstColor]
    mov al,[LastColor]
    sub al,cl
    mov bl,3
    mul bl
    mov bx,di
    add bx,ax
    add bx,3
    cld
@loop:
    mov dx,3c7h
    mov al,cl
    out dx,al
    add dx,2
    in al,dx
    stosb
    in al,dx
    stosb
    in al,dx
    stosb
    inc cl
    cmp di,bx
    jne @loop
    pop cx
    pop bx
    pop ax
    pop dx
    pop di
    pop es
@exit:
   end;

 end.