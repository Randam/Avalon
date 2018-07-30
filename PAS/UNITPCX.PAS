Unit UnitPCX;

{ only 256 colors pcx-images }

INTERFACE

Uses dos,modeX;

Const
  BufferLengte = $FFFE;
  Klaar    : boolean = false;

Type PcxType = Object
        Kenmerk, Versie: byte;
        Gecomprimeerd: boolean;
        BitsPerPixel: byte;
        Raam: Record Links, Boven, Rechts, Onder: word End;
        HorResolutie, VerResolutie: word;
        Kleuren: array[0..15] of Record Rood, Groen, Blauw: byte End;
        Reserve: byte;
        AantalVlakken: byte;
        AantalBytesPerLijn: word;
        PaletInformatie: word;
        ReserveArray: array[1..58] of byte;
      End;
      ArByte = array[0..$FFFE] of byte;


      RGBColor   = record R,G,B :byte; end;
      VGAPalette = array[0..255] of RGBColor;


Var
  Herhaal,Teller,m,
  xx,yy,MaxX,MaxY       :word;
  PCX                   :PCXType;
  Buffer,Lijnx          :^ArByte;
  PCX_Bestand           :File;
  BufSize               :word;
  Regs                  :Registers;
  Kleuren256            :array[0..255] of Record Rood,Groen,Blauw :byte End;
  PaletNr,ID            :byte;


Procedure load_pcx (posx,posy,breedte,hoogte :word;pcxnaam :string; palette : Boolean);


IMPLEMENTATION

Procedure LeesBuffer;

Begin
  Klaar := Klaar or EOF(PCX_Bestand);
  BlockRead(PCX_Bestand, Buffer^, SizeOf(Buffer^), BufSize)
End;

Procedure Lees256Kleuren;
Begin
  Seek(PCX_Bestand, FileSize(PCX_Bestand) - 769);
  ID := 0;
  BlockRead(PCX_Bestand, ID, 1);
  If ID = 12 then With Regs do Begin
    BlockRead(PCX_Bestand, Kleuren256, 768);
    For PaletNr := 0 to 255 do With Kleuren256[PaletNr] do Begin
      Rood := Rood shr 2; Groen := Groen shr 2; Blauw := Blauw shr 2
    End;
    AX := $1012;
    BX := 0;
    CX := 256;
    ES := Seg(Kleuren256);
    DX := Ofs(Kleuren256);
    Intr($10, Regs)
  end;
  seek(PCX_Bestand, SizeOf(PCX))
end;

Procedure Increment;

Begin
  If Teller < BufferLengte then Inc (Teller)
  else Begin
    Teller := 0;
    LeesBuffer;
  End;
End;

Procedure Load_PCX;
Begin
  New (buffer);
  MaxX :=(breedte+posx)-1; MaxY :=(hoogte+posy)-1;
  Assign (PCX_Bestand,'PCX\' + pcxnaam + '.pcx');
  {$I-} Reset(PCX_Bestand, 1); {$I+}
  if ioresult = 0 then Begin
    BlockRead(PCX_Bestand, PCX, SizeOf(PCX));
    If palette = True then Lees256Kleuren;
    xx:=posx; yy:=posy; Teller:=0;
    LeesBuffer;
    While not Klaar do Begin
      If Buffer^[Teller] and $C0 = $C0 then Begin
        Herhaal := Buffer^[Teller] - $C0;
        Increment;
      End
      else Herhaal := 1;
      For m := 1 to Herhaal do Begin
        If xx <= MaxX then WritePixelX(xx, yy, Buffer^[Teller]);
        Inc(xx);
      End;
      If xx >= pcx.AantalBytesPerLijn + posx then Begin
        xx := posx; Inc(yy);
        If yy > MaxY then Klaar := true;
      End;
      Increment;
    End;
    close (pcx_bestand);
    klaar :=false;
  End;
  Dispose (buffer);
End;

Begin
End.