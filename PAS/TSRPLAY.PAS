{$M 2048, 0, 4096}
{$F+}

Program TsrPlay;

Uses Instr, FMdirect, Dos;

Var IntVec          : Procedure;
    f               : Text;
    teller1         : Integer;
    teller2         : Integer;
    posit           : Array [0..200] of Byte;
    regel           : String [80];
    lastpos         : Integer;
    musdat          : Array [-1..50 , 1..16] of String[40];
    dummy2          : Integer;
    Instru          : InsTp;
    speed           : Byte;
    songname        : String[80];
    dummy           : Integer;
    musicbuffer     : String[5];
    Pkopie          : Word;
    kanaal          : Byte;
    position        : Byte;
    track           : Byte;
    looppos         : Byte;
    temp            : String;
    startvoice      : Array [1..9] of Byte;
    voicevolume     : Array [1..16] of Byte;
    voicename       : Array [1..16] of String [20];
    voicecode       : Array [1..16] of String [9];
    voicedata       : Array [1..16] of InsTp;
    noot            : Byte;
    Octaaf          : Byte;
    teller3         : Integer;
    number          : Integer;
    time            : Longint;
    temp2           : String;
    teller4         : Integer;
    crunchstring    : String [51];
    f2              : File;
    transpose       : Byte;
    voicetone       : Array [1..16] of String [2];
    voiceoctave     : Array [1..16] of Integer;
    step            : Byte;
    regs            : Registers;

    equipment,
    resbasic        : Pointer;
    TmpCX,
    env,
    stackseg,
    stackptr,
    stacksegsave,
    stackptrsave    : Word;


Const
    musiccode : Array [1..12] of String [2] = ('C ', 'C#', 'D ', 'D#', 'E ', 'F ', 'F#', 'G ', 'G#', 'A ', 'A#', 'B ');
    TSR_ID    = $0012;

Procedure EndProg;
Begin
  WriteLn ('MiGtracker (isr) replayer version 0.9');
  WriteLn ('(c) 1995/1996 MiG Holland');
  WriteLn;
  WriteLn ('Usage:  TSRPLAY [SONGNAME.MIG] [\STOP]');
  WriteLn;
  Halt;
End;

Procedure Init;
begin
  poort:=$220;
  If Not TestFMchip then poort:=$240;
  Pkopie:=poort;
  poort:=Pkopie + 8;
  AfspeelMode (melodie);
  New (instru.ins);
  New (instru.sbi);

  For teller1:=1 to 16 do begin
    New (voicedata [teller1].ins);
    New (voicedata [teller1].sbi);
  End;

  temp:=paramstr (1);

  Assign (f, temp);
  Reset (f);
  If IOresult <> 0 then EndProg;
  Close (f);

  Assign (f, temp);
  Reset (f);

  teller1:=0;

  Repeat
    teller2:=1;

    Repeat
      ReadLn (f, crunchstring);

      If crunchstring = '*' then begin
	musdat [teller1, teller2]:=' -   -   -   -   -   -   -   -   -   - -  ';
      End else If crunchstring = '!' then begin
	teller2:=16;
	teller1:=50;
      End else begin
        teller4:=1;

        Repeat
          temp2:=copy (crunchstring, teller4, 1);


	  If temp2 [1] = '$' then begin
	    Delete (crunchstring, teller4, 1);
	    Insert (' -  ', crunchstring, teller4);
	  End;

	  teller4:=teller4 + 1;
	Until teller4 > 54;

        musdat [teller1, teller2]:=crunchstring;
      End;

     teller2:=teller2 + 1;
    Until (teller2 > 16);

    teller1:=teller1 + 1;
  Until (teller1 > 49);

  For teller1:=0 to 200 do ReadLn (f, posit [teller1]);

  For teller1:=1 to 9 do begin
    ReadLn (f, startvoice [teller1]);
  End;

  ReadLn (f, lastpos);
  ReadLn (f, speed);
  ReadLn (f, looppos);
  ReadLn (f, songname);

  For teller1:=1 to 16 do begin
    ReadLn (f, voicename [teller1]);
    ReadLn (f, voicecode [teller1]);
    ReadLn (f, voicevolume [teller1]);
    ReadLn (f, voicetone [teller1]);
    ReadLn (f, voiceoctave [teller1]);
  End;

  { Instrumenten }
  For teller1:=1 to 16 do begin
    ReadLn (f, instru.soort);
    ReadLn (f, instru.ins^.mode);
    ReadLn (f, instru.ins^.nummer);

    ReadLn (f, instru.ins^.modulator.ksl);
    ReadLn (f, instru.ins^.modulator.multi);
    ReadLn (f, instru.ins^.modulator.fb);
    ReadLn (f, instru.ins^.modulator.ar);
    ReadLn (f, instru.ins^.modulator.sl);
    ReadLn (f, instru.ins^.modulator.eg_typ);
    ReadLn (f, instru.ins^.modulator.dr);
    ReadLn (f, instru.ins^.modulator.rr);
    ReadLn (f, instru.ins^.modulator.tl);
    ReadLn (f, instru.ins^.modulator.am);
    ReadLn (f, instru.ins^.modulator.vib);
    ReadLn (f, instru.ins^.modulator.ksr);
    ReadLn (f, instru.ins^.modulator.fm);

    ReadLn (f, instru.ins^.carrier.ksl);
    ReadLn (f, instru.ins^.carrier.multi);
    ReadLn (f, instru.ins^.carrier.fb);
    ReadLn (f, instru.ins^.carrier.ar);
    ReadLn (f, instru.ins^.carrier.sl);
    ReadLn (f, instru.ins^.carrier.eg_typ);
    ReadLn (f, instru.ins^.carrier.dr);
    ReadLn (f, instru.ins^.carrier.rr);
    ReadLn (f, instru.ins^.carrier.tl);
    ReadLn (f, instru.ins^.carrier.am);
    ReadLn (f, instru.ins^.carrier.vib);
    ReadLn (f, instru.ins^.carrier.ksr);
    ReadLn (f, instru.ins^.carrier.fm);

    ReadLn (f, instru.ins^.MWafeSel);
    ReadLn (f, instru.ins^.CWafeSel);

    For teller2:=0 to 1 do begin
      ReadLn (f, instru.sbi^.snd [teller2]);
      ReadLn (f, instru.sbi^.ksltl [teller2]);
      ReadLn (f, instru.sbi^.ardr [teller2]);
      ReadLn (f, instru.sbi^.slrr [teller2]);
      ReadLn (f, instru.sbi^.ws [teller2]);
      ReadLn (f, instru.sbi^.fbfm [teller2]);
    End;

    For teller2:=0 to 3 do ReadLn (f, instru.sbi^.dummy [teller2]);
    KopieerIns (instru, voicedata [teller1]);
  End;

  Close (f);
  transpose:=0;
  poort:=Pkopie;

  For teller1:=1 to 9 do begin
    poort:=Pkopie + 8;
    ZetNootUit (teller1);
    StelInsIn (teller1, voicedata [startvoice [teller1]]);
    poort:=Pkopie;
    Volume (teller1, voicevolume [startvoice [teller1]] * 0.02);
  End;

End;

Procedure PlayNextStep (track, step : Byte);
Begin

  { Behandeling v/h CMD kanaal }
  temp:=copy (musdat [track, step], 37, 2);

  If temp = 'SPD' then begin
    Val (copy (musdat [track, step], 40, 1), speed, dummy);
  End;

  If temp = 'UP:' then begin
    Val (copy (musdat [track, step], 39, 2), transpose, dummy);
  End;

  If temp = 'DN:' then begin
    Val (copy (musdat [track, step], 39, 2), transpose, dummy);
    transpose:=transpose * - 1
  End;

  { Behandeling noten & events }
  kanaal:=1;
  teller1:=1;

  Repeat
    musicbuffer:=copy (musdat [track, step], teller1, 2);
    dummy:=0;
    For teller3:=1 to 12 do if musicbuffer = musiccode [teller3] then dummy:=teller3;

    If (dummy > 0) then begin

    teller3:=dummy;
    musicbuffer:=copy (musdat [track, step], teller1 + 2, 1);
    Val (musicbuffer, octaaf, dummy);
    noot:=octaaf * 12 + teller3 - 1;
    If copy (musdat [track, step], teller1 + 3, 1) <> '*' then ZetNootUit (kanaal);
    noot:=noot + transpose;
    If (noot < 0) then noot:=0;
    SpeelNoot (kanaal, noot + transpose);
  End;

  musicbuffer:=copy (musdat [track, step], teller1, 3);
  If musicbuffer = 'OFF' then ZetNootUit (kanaal);

  If copy (musicbuffer, 1, 1) = 'V' then begin
    temp:=copy (musicbuffer, 2, 2);
    Val (temp, dummy2, dummy);
    Volume (kanaal, dummy2 * 0.02);
  End;

  If copy (musicbuffer, 1, 1) = 'I' then begin
    temp:=copy (musicbuffer, 2, 2);
    Val (temp, teller4, dummy);
    StelInsIn (kanaal, voicedata [teller4]);
    Volume (kanaal, voicevolume [teller4] * 0.02);
  End;

  If copy (musicbuffer, 1, 1) = 'M' then begin
    temp:=copy (musicbuffer, 2, 2);
    Val (temp, teller4, dummy);
    Volume (kanaal, 0);
    ZetNootUit (kanaal);
    StelInsIn (kanaal, voicedata [teller4]);
    Volume (kanaal, voicevolume [teller4] * 0.02);

    For teller3:=1 to 12 do if voicetone [teller4] = musiccode [teller3] then noot:=teller3;
      noot:=noot + (12 * voiceoctave [teller4]);
      SpeelNoot (kanaal, noot);
    End;

    kanaal:=kanaal + 1;
    teller1:=teller1 + 4;
  Until (teller1 >= 37);

  { Behandeling 'END' event }

  If copy (musdat [track, step], 46, 3) = 'END' then begin
    step:=1;
    track:=track + 1;
  End;

End;

Procedure Afspeler; Interrupt;
begin
  If time + (10 - speed) <= LongInt (Ptr ($40, $6C)^) then begin
    track:=posit [number]; { Track }
    PlayNextStep (track, step);
    step:=step + 1;

    If step > 16 then begin
      step:=1;
      number:=number + 1;
      If (number > lastpos) and (looppos < 255) then number:=looppos;
    End;

    time:=Longint (Ptr ($40, $6c)^);
  End;

  Inline ($9C);
  IntVec;
End;

Procedure equiphandler (AX, BX, CX, DX, SI, DI, DS, ES, BP : Word); Interrupt;
Begin
  TmpCX:=CX;
  Inline ($9C/$FF/$1E/equipment);

  asm
    MOV [BP + 0CH], CX
    MOV [BP + 10H], AX
  End;

  If TmpCX = TSR_ID then CX:=TSR_ID or $FF00;
  ES:=PrefixSeg;
End;

Procedure Quit (AX, BX, CX, DX, SI, DI, DS, ES, BP : Word); Interrupt;
Begin
  Inline ($FA); { Disable interrupt}
  StackSegSave:=Sseg;
  StackPtrSave:=Sptr;

  Asm
    MOV SS, [StackSeg]
    MOV SP, [StackPtr]
  End;

  Inline ($FB); { Enable interrupt }
  regs.CX:=TSR_ID;
  Intr ($11, regs);
  Env:=memw [regs.ES:$2C];
  regs.AH:=$49;
  MsDos (regs);
  regs.ES:=Env;
  regs.AH:=$49;
  MsDos (regs);
  SetIntVec ($11, equipment);
  SetIntVec ($1C, @IntVec);
  SetIntVec ($18, resbasic);

  For teller1:=1 to 9 do begin
    ZetNootUit (teller1);
    Volume (teller1, 0);
  End;

  Halt;
End;

{ H O O F D P R O G R A M M A }

Begin
  If paramcount < 1 then EndProg;
  Regs.CX:=TSR_ID;
  Intr ($11, regs);
  If regs.CX = TSR_ID or $FF00 then

  begin
    Intr ($18, regs);
    Halt;
  end;

  Init;
  If IOresult <> 0 then EndProg;
  number:=0; { Positie teller }
  step:=1; { Step teller }
  time:=LongInt (Ptr ($40, $6C)^);

  GetIntVec ($11, equipment);
  SetIntVec ($11, @equiphandler);

  GetIntVec ($1C, @IntVec);
  SetIntVec ($1C, Addr (Afspeler));

  GetIntVec ($18, resbasic);
  SetIntVec ($18, @quit);

  SwapVectors;

  StackSeg:=Sseg;
  StackPtr:=SPtr;
  regs.AH:=$34;
  MsDos (regs);
  Keep (0);
End.









