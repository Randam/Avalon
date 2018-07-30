Unit FMDirect;

Interface

Uses Instr;

Const
  Melodie       = True;       { de twee afspeel modes }
  Ritmisch      = False;
  { de frequenities voor de div. noten }
  FrLst : Array [0..11] Of Word = (343, 363, 385, 408,
                                   432, 458, 485, 514,
                                   544, 577, 611, 647);
  BassDrum  =  7;
  SnareDrum =  8;
  TomTom    =  9;
  TopCymbal = 10;
  HiHat     = 11;

Var
  Poort  : Word;

{ stel register in }
Procedure SchrijfFM (Reg, Value: Byte);
{ lees status register }
Function LeesFM : Byte;

{ voer timer test uit }
Function TestFMChip : Boolean;

{ stel afspeel mode in }
Procedure AfSpeelMode(M : Boolean);

{ stel volume op bepaald kanaal in }
Procedure ZetVolume(N : Byte; V : Real);
{ vraag volume van kanaal op }
Function GeefVolume(N : Byte) : Real;

{ speel een noot op een bepaald kanaal }
Procedure SpeelNoot(N : Byte; T : Word);
{ zet kanaal weer uit }
Procedure ZetNootUit(N : Byte);

{ stel instrument in }
Procedure StelInsIn(N : Byte; I : InsTp);

Implementation

Const
  { de 18 operator offsets }
  OpAd  : Array [1..18] Of Byte = (00,01,02,03,04,05,
                                   08,09,10,11,12,13,
                                   16,17,18,19,20,21);
  { de modulator operator offsets }
  Ins9  : Array [1..9] Of Byte  = (01,02,03,07,08,09,
                                   13,14,15);
  { de modulator + ritm. ins operator offsets }
  Ins11 : Array [1..11] Of Byte = (01,02,03,07,08,09,
                                   13,17,15,18,14);
Type
  VolumeRc = Record   { voor de volume instelling }
               KSLTL  : Array [0..1] Of Byte;
               Soort  : Byte;
               Waarde : Real;
             End;
  VolumeAr = Array [1..11] Of VolumeRc;
  Ar       = Array [1..11] Of Byte;   { hulp array }
  ArPt     = ^Ar;

Var
  Volumes     : VolumeAr;  { de volume instellingen }
  MelodieMode : Boolean;   { de afspeel mode }
  BasisIns    : ArPt;      { te gebruiken ins. tabel }
  PoortBD     : Byte;      { voor de ritm. ins. }

Procedure SChrijfFM(Reg, Value: Byte);
(* Writes a Byte to the specified FM Register *)
var
  I: Integer;
  Dummy: Byte;
Begin
  Port [poort] := Reg;       (* Set up the register  *)
  For I := 0 to 6 do
    Dummy := Port [poort];   (* Wait 12 cycles       *)
  Port [poort] := Value;        (* Write out the value  *)
  For I := 0 to 35 do
    Dummy := Port [poort];   (* Wait 84 cycles       *)
End;

Function LeesFM : Byte;

Begin
  LeesFM:=Port[Poort];          { lees data in }
End;

Function TestFMChip : Boolean;

Var
  S1, S2, T : Byte;

Begin
  SchrijfFM(1,0);    { wis test register }
  SchrijfFM(4,$60);  { zet doorvoer uit/stop tellers }
  SchrijfFM(4,$80);  { wis het statusregister  }
  S1 := LeesFM;      { lees status }
  SchrijfFM(2,$ff);  { stel teller 1 op 255 in }
  SchrijfFM(4,$21);  { doorvoer aan + start teller 1 }
  For T:=0 To 200 Do { wacht een tijdje }
    S2 := LeesFM;
  S2 := LeesFM;      { lees status }
  SchrijfFM(4,$60);  { zet doorvoer uit/stop tellers }
  SchrijfFM(4,$80);
  TestFMChip:=((S1 AND $E0)=0) AND ((S2 AND $E0)=$C0);
End;

Procedure AfSpeelMode(M : Boolean);

Begin
  MelodieMode:=M;    { stel mode in }
  SchrijfFM(8,0);    { zet CSM & SEL op 0 }
  If MelodieMode Then Begin
    BasisIns:=Addr(Ins9);          { gebruik 9 ins. }
    PoortBD:=PoortBD And (Not 32); { ritm. mode uit }
  End
  Else Begin
    BasisIns:=Addr(Ins11);         { gebruik 11 ins. }
    PoortBD:=PoortBD Or 32;        { ritm. mode aan }
  End;
End;

Function GeefRBit(N : Byte) : Byte;
{ geef de bij de ritmische instrument behorende bit }

Begin
  Case N Of
    BassDrum  : GeefRBit:=16;   { bit 4 }
    SnareDrum : GeefRBit:=8;    { bit 3 }
    TomTom    : GeefRBit:=4;    { bit 2 }
    TopCymbal : GeefRBit:=2;    { bit 1 }
    HiHat     : GeefRBit:=1;    { bit 0 }
  Else
    GeefRBit:=0;                { geen bit }
  End;
End;

Procedure StelOperatorIn(N,M : Byte; I : SBIFormaat);
{ stel modulator of carrier op kanaal N in }

Var
  H : Byte;

Begin
  H:=OpAd[BasisIns^[N]+3*M];    { bepaal oper. poort }
  SchrijfFM(H+$20,I.Snd[M]);    { stel AM/VIB/... in  }
  SchrijfFM(H+$60,I.ARDR[M]);   { stel AR + DR in }
  SchrijfFM(H+$80,I.SLRR[M]);   { stel SL + RR in }
  SchrijfFM(H+$E0,I.WS[M]);     { stel WS in }
  Volumes[N].KSLTL[M]:=I.KSLTL[M];  { kopieer volume }
  If (M=0) And (MelodieMode OR (N<8)) Then Begin
    SchrijfFM(N-1+$C0,I.FBFM[0]);   { stel FM + FB in }
    Volumes[N].Soort:=I.FBFM[0] AND 1;  { synth. type }
  End;
End;

Procedure ZetVolume(N : Byte; V : Real);

Var
  KSL,
  TL,
  B    : Byte;

Begin
  If MelodieMode Or (N<8) Then Begin { carrier }
    B:=BasisIns^[N];           { bepaal oper. offset }
    KSL:= Volumes[N].KSLTL[1] And 192; { kopieer KSL }
    TL:=(Volumes[N].KSLTL[1] And 63) Xor 63;
    TL:=Round(V*TL);             { nieuwe volume }
    If TL>63 Then TL:=63;        { te groot ? }
    SchrijfFM($40+OpAd[B+3],KSL OR (TL XOR 63));
  End;
  If (Volumes[N].Soort=1) Or       { addi. synthese ? }
     (Not MelodieMode And (N>7)) Then Begin   { ritm. ? }
    KSL:=Volumes[N].KSLTL[0] And 192;       { ja }
    TL:=(Volumes[N].KSLTL[0] And 63) Xor 63;
    TL:=Trunc(V*TL);     { stel modulator of ritm. in }
    If TL>63 Then TL:=63;
    SchrijfFM($40+OpAd[B],KSL OR (TL XOR 63));
  End
  Else
    SchrijfFM($40+OpAd[B],Volumes[N].KSLTL[0]);
  Volumes[N].Waarde:=V;
End;

Function GeefVolume(N : Byte) : Real;

Begin
  GeefVolume:=Volumes[N].Waarde;
End;

Procedure StelInsIn(N : Byte; I : InsTp);

Var
  C : InsTp;
  P : ArPt;
  V : Real;

Begin
  KopieerIns(I,C);          { gebruik kopie }
  INSNaarSBI(C);            { gebruik SBI formaat }
  V := GeefVolume(N);       { stel volume tijdelijk }
  ZetVolume(N,0.0);            { op 0 in               }
  StelOperatorIn(N,0,C.SBI^);   { verwerk modulator }
  If MelodieMode Or (N<8) Then
    StelOperatorIn(N,1,C.SBI^); { en evt. carrier   }
  ZetVolume(N,V);              { herstel volume }
  VerwijderIns(C);          { verwijder kopie }
End;

Procedure SpeelNoot(N : Byte; T : Word);

Var
  FNr : Word;
  Blk : Byte;

Begin
  FNr := FrLst[T Mod 12];        { bepaal frequentie }
  Blk := ((T Div 12) And 7) Shl 2;  { en oktaaf      }
  If MelodieMode Or (N<8) Then Begin { stel in + zet }
    SchrijfFM($A0+N-1,FNr and 255);  { noot aan }
    SchrijfFM($B0+N-1,(FNr Shr 8) Or Blk Or 32);
  End;
  If Not MelodieMode And (N=TomTom) Then Begin
    SchrijfFM($A8,FNr And 255);     { stel alleen in }
    SchrijfFM($B8,(FNr Shr 8) Or Blk);
  End;
  If Not MelodieMode And (N>6) Then Begin
    PoortBD:=PoortBD Or GeefRBit(N); { verwerk ritm. }
    SchrijfFM($BD,PoortBD)           { instrument    }
  End;
End;

Procedure ZetNootUit(N : Byte);

Begin
  If MelodieMode Or (N<8) Then
    SchrijfFM($B0+N-1,0);
  If Not MelodieMode And (N>6) Then Begin
    PoortBD := PoortBD And (Not GeefRBit(N));
    SchrijfFM($BD,PoortBD);
  End;
End;

Var
  K : Byte;

Begin
  Poort:=$388;
  PoortBD:=0;
  For K:=1 To 11 Do
    Volumes[K].Waarde:=0;
End.
