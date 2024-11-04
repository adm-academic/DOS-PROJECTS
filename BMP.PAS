				   UNIT BMP;
				   INTERFACE
const
 Red=0; Green=1; Blue=2;

PROCEDURE SBMI(FILEname:string; X,Y:Word; FDR:Integer);
implementation
uses dos,graph;
type
 TPaletteEntry = record {‚®Ø Ø†´®‚‡Î}
		 B,G,R:Byte;
		 Flags:Byte;
		 end;
 TBitmapFileHeader = record
		     bfType                           :word;
		     bfsize                           :longint;
		     bfReserved1                      :word;
		     bfReserved2                      :word;
		     bfOffBits                        :longint;
		     biSize                           :longint;
		     biWidth,BiHeight                 :longint;
		     BiPlanes                         :word;
		     bibitCount                       :word;
		     biCompression                    :longint;
		     biSizeImage                      :longint;
		     biXPelsPerMeter, biYPelsPerMeter :Longint;
		     biClrUsed, biCLrImportant        :longint;
		     end;
 TpPalArray =array[0..255, red..BLUE] of byte;
var
 F       :FILE;                            { BMP file }
 bfh     :TBitMapFileHeader;               {ß†£Æ´Æ¢Æ™ ‰†©´†}
 Pal     : array[0..256] of TPaletteEntry;



PROCEDURE OPENFILE(const bitmapname:string);
begin
 assign(f,bitmapname);
 reset(f,1);
end;

PROCEDURE CLOSEFILE;
begin
 Close(f);
end;

PROCEDURE ReadBMPFileHead;
begin
 BlockRead(f,BFH,SizeOf(BFH));
end;

PROCEDURE ReadPalette(PalSize:Integer);
var c:byte;
begin
 BLOCKREAD(f,Pal,Palsize*4);
end;

PROCEDURE SetPalette(PalSize:Integer; FirstDacReg:Integer);
var
 Palette : TpPalArray;
 reg     : registers;
 i       : byte;
begin
 If GetMaxColor>256 then exit;
 for i:=0 to palsize-1 do
 begin
  Palette[i,red]   := pal[i].r shr 2;
  Palette[i,green] := pal[i].g shr 2;
  Palette[i,blue]  := pal[i].b shr 2;
 end;

 Reg.ah:=$10;
 Reg.al:=$12;
 Reg.bx:=FirstDacReg;
 Reg.cx:=PalSize;
 Reg.dx:=Ofs(Palette);
 Reg.es:=Seg(Palette);
 Intr($10,Reg);
end;

{  ÇõÇéÑ 16-ñÇÖíçéÉé êàëìçKÄ}

PROCEDURE ShowImage4(palOffset:Integer; XStart,YStart:Word);
var
 Px,C0,C1                 :Byte;
 Lin4                     :array[0..1023] of byte;
 col                      : longint;
 width,height,xt,yt,w2    :word;
begin
 Seek(f,bfh.bfOffbits);
 width:=bfh.biwidth;
 height:=bfh.biHeight;
 while (width mod 8)<>0 do inc(Width);
 w2 := (bfh.biwidth-1) div 2;
 for yt:=height-1 downto 0 do
 begin
  blockRead(f,lin4,width div 2);
  for xt:=0 to w2 do
  begin
   px:=lin4[xt];
   c0:=Px shr 4;
   Px:=(px shr 4)+(Px shl 4);
   C1:=Px shr 4;
   Putpixel(Xstart+xt*2,ystart+yt,c0+PalOffset);
   PutPixel(Xstart+xt*2+1,ystart+yt,c1+paloffset)
  end
 end
end;

{BIBOD 256}
PROCEDURE ShowImage8(palOffset: integer; xstart,Ystart:WORD);
type
 TLin8=record
	x,y:word;
	data:array[0..1023] of byte;
       end;
var
 lin8                     : ^TLin8;
 i                        : integer;
 l,col                    :longint;
 width,height,xt,yt,sizeP :word;
begin
 width:=bfh.biwidth;
 height:=bfh.biheight;
 while (width mod 4)<>0 do inc(width);
 seek(f,bfh.bfoffbits);
 sizeP:=sizeof(Tlin8);
 getmem(lin8,sizep);
 lin8^.X:=bfh.biwidth-1;
 lin8^.Y:=0;
 for yt:= height-1   downto 0 do
 begin
  blockRead(f,lin8^.Data,width);
  for i:=0 to width-1 do
   putpixel(Xstart+i, Ystart+yt,lin8^.data[i]+palOffset)
  end;
 freeMem(lin8,sizep)
end;

PROCEDURE SBMI(FILEname:string; X,Y:Word; FDR:Integer);
var
 MaxC   :longint;
 xt,yt  :word;
begin
 OpenFile(FILEname);
 ReadBmpFileHead;
 case bfh.bibitcount of
  4: begin
      readpalette(16);
      setpalette(16,FDR);
      showimage4(fdr,x,y);
     end;

   8: begin
       readpalette(256);
       setpalette(256,fdr);
       showimage8(fdr,x,y);
      end;
 end;
 closefile;
 end;
end.










