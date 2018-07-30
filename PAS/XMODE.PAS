{$F+}
unit xmode;

interface

uses DOS, GMUnit, crt2;

type songtp = record
       playing      : Boolean;
       filename     : String [20];
       fading       : Byte;
     end;

Var
     song              : SongTp;
     wavetable_on      : Boolean;

type pcxtype = object
     kenmerk,
     versie             : byte;
     gecomprimeerd      : boolean;
     bitsperpixel       : byte;
     raam               : record
                               links, boven, rechts, onder: word
                             end;
        horresolutie,
        verresolutie       : word;
        kleuren            : array [0..15] of record
                               rood, groen, blauw: byte
                             end;
        reserve            : byte;
        aantalvlakken      : byte;
        aantalbytesperlijn : word;
        paletinformatie    : word;
        reservearray       : array [1..58] of byte;
      end;
      arbyte = array[0..$FFFE] of byte;


      RGBColor   = record R,G,B :byte; end;
      VGAPalette = array[0..255] of RGBColor;

const
  mode_320x200 = 0;
  mode_320x400 = 1;
  mode_360x200 = 2;
  mode_360x400 = 3;
  mode_320x240 = 4;
  mode_320x480 = 5;
  mode_360x240 = 6;
  mode_360x480 = 7;

  xcentre      = 500;
  BUFFERLENGTE = $FFFE;
  KLAAR        : Boolean = false;
  TSR_ID    = $0013;

{ MiGTracker routines **************************************************** }
Procedure LoadSong (temp : String);
Procedure PlaySong;
Procedure StopSong;

{ mode X setup routines ************************************************** }
procedure set_vga_modex (mode, maxxpos, maxypos, pages : integer);
procedure set_modex (mode : byte);

{ basic graphics routines ************************************************ }
procedure clear_vga_screen (color : byte);
procedure set_point (xpos, ypos, color : integer);
function read_point (xpos, ypos : integer) : integer;
procedure fill_block (xpos1, ypos1, xpos2, ypos2, color : integer);
procedure draw_line (xpos1, ypos1, xpos2, ypos2, color : integer);

{ DAC color register routines ******************************************** }
procedure set_dac_register (regno, red, green, blue : byte);
procedure get_dac_register (regno : byte; var red : byte; var green : byte; blue : byte);

{ page flipping and scrolling routines *********************************** }
procedure set_active_page (pageno : byte);
function get_active_page : byte;
procedure set_display_page (pageno : byte);
function get_display_page : byte;
procedure set_window (displaypage, xoffset, yoffset : integer);
function get_x_offset : integer;
function get_y_offset : integer;
procedure sync_display;

{ text display routines ************************************************** }
procedure gprintc (charnum, xpos, ypos, colorf, colorb : integer);
procedure tgprintc (charnum, xpos, ypos, colorf : integer);
procedure print_str (var text; maxLen, xpos, ypos, colorf, colorb : integer);
procedure tprint_str (var text; maxlen, xpos, ypos, colorf : integer);
procedure set_display_font (var fontdata; fontnumber : integer);

procedure nicetextline (txt_page : byte; x : integer; y : byte; s : string; dy : Boolean);
procedure print_text (s : string; x, y, bcolor, fcolor : integer);
procedure tprint_text (s : string; x, y, color : integer);

{ sprite and VGA memory -> VGA memory copy routines ********************** }
procedure draw_bitmap (var image; xpos, ypos, width, height : integer);
procedure tdraw_bitmap (var image; xpos, ypos, width, height: integer);
procedure copy_page (sourcePage, destpage : integer);
procedure copy_bitmap (sourcepage, x1, y1, x2, y2, destpage, destx1, desty1 : integer);

{ PCX loader }
procedure load_pcx (posx, posy, breedte, hoogte : word; pcxnaam : string; palette : boolean);

{ misc. routines ********************************************************* }
procedure sleep (k : Byte);
{procedure start_timer (timeticks : word);
procedure wait_for_timer;}

implementation

{$L MODEX.OBJ}

var
  pattern           : array [1..40 , 1..17 , 1..17] of byte;
  position          : array [1..100] of byte;
  startvoice        : array [1..16] of byte;
  voice             : array [1..15] of byte;
  startvolume       : array [1..16] of byte;
  startmode         : array [1..16] of boolean;
  voicechange       : array [1..21] of byte;
  volume            : array [1..16] of byte;
  mode              : array [1..15] of boolean;
  notehis           : array [1..15] of byte;
  lastpos,
  looppos,
  startspeed        : byte;
  speed             : byte;
  songname          : string [70];
  endofpattern      : boolean;
  time              : longint;
  {timer             : longint;}
  pos               : integer;
  x, y              : byte;
  s, t              : string;
  t1, t2, t3,
  t4                : integer;
  playpos           : byte;
  step,
  track,
  number            : integer;
  plusvalue         : integer;
  IntVec            : procedure;
  f                 : text;
  regs              : registers;
  equipment,
  resbasic          : pointer;
  TmpCX,
  env,
  stackseg,
  stackptr,
  stacksegsave,
  stackptrsave      : word;
  Herhaal, Teller,
  m, xx, yy, MaxX,
  MaxY              : word;
  PCX               : PCXType;
  buffer, Lijnx     : ^ArByte;
  PCX_Bestand       : File;
  BufSize           : word;
  Kleuren256        : array [0..255] of record
                        rood, groen, blauw : byte
                      end;
  PaletNr, ID       : byte;

procedure set_vga_modex (mode, maxxpos, maxypos, pages : integer); external;
procedure set_modex (mode : byte); external;
procedure clear_vga_screen (color : byte); external;
procedure set_point (xpos, ypos, color : integer); external;
function read_point (xpos, ypos : integer) : integer; external;
procedure fill_block (xpos1, ypos1, xpos2, ypos2, color : integer); external;
procedure draw_line (xpos1, ypos1, xpos2, ypos2, color : integer); external;
procedure set_dac_register (regno, red, green, blue : byte); external;
procedure get_dac_register (regno : byte; var red : byte; var green : byte; blue : byte); external;
procedure set_active_page (pageno : byte); external;
function get_active_page : byte; external;
procedure set_display_page (pageno : byte); external;
function get_display_page : byte; external;
procedure set_window (displaypage, xoffset, yoffset : integer); external;
function get_x_offset : integer; external;
function get_y_offset : integer; external;
procedure sync_display; external;
procedure gprintc (charnum, xpos, ypos, colorf, colorb : integer); external;
procedure tgprintc (charnum, xpos, ypos, colorf : integer); external;
procedure print_str (var text; maxLen, xpos, ypos, colorf, colorb : integer); external;
procedure tprint_str (var text; maxlen, xpos, ypos, colorf : integer); external;
procedure set_display_font (var fontdata; fontnumber : integer); external;
procedure draw_bitmap (var image; xpos, ypos, width, height : integer); external;
procedure tdraw_bitmap (var image; xpos, ypos, width, height: integer); external;
procedure copy_page (sourcePage, destpage : integer); external;
procedure copy_bitmap (sourcepage, x1, y1, x2, y2, destpage, destx1, desty1 : integer); external;

procedure print_text (s : string; x, y, bcolor, fcolor : integer);
var
  s1 : array[1..135] of char;
  i  : byte;
begin
  for i:=1 to length(s) do
    s1[i]:=s[i];
  print_str(s1, length(s), x, y,bcolor, fcolor);
end;

procedure tprint_text (s : string; x, y, color : integer);
var
  s1 : array[1..135] of char;
  i  : byte;
begin
  for i:=1 to length(s) DO
    s1[i]:=s[i];
  tprint_str(s1, length(s), x, y, color);
End;

procedure leesbuffer;
begin
  klaar:=klaar or EOF (pcx_bestand);
  blockread (pcx_bestand, buffer^, sizeof (buffer^), bufsize)
end;

procedure lees256kleuren;
begin
  seek (pcx_bestand, filesize (pcx_bestand) - 769);
  id:=0;
  blockread(pcx_bestand, id, 1);
  If id = 12 then
    with regs do
    begin
      blockRead (pcx_bestand, kleuren256, 768);
      for paletnr:=0 to 255 do
        with kleuren256 [paletnr] do
        begin
          rood:=Rood shr 2;
          groen:=groen shr 2;
          blauw:=blauw shr 2
        end;
        ax:=$1012;
        bx:=0;
        cx:=256;
        es:=seg (kleuren256);
        dx:=ofs (kleuren256);
        intr ($10, regs)
    end;
    seek (pcx_bestand, sizeof (pcx))
end;

procedure increment;
begin
  if teller < bufferlengte then
    inc (teller)
  else
  begin
    teller := 0;
    leesbuffer;
  end;
end;

procedure load_pcx;
begin
  new (buffer);
  maxx:=(breedte + posx) - 1;
  maxy:=(hoogte + posy) - 1;
  assign (pcx_bestand, pcxnaam);
  {$I-}
  reset (pcx_bestand, 1);
  {$I+}
  if ioresult = 0 then Begin
    blockread (pcx_bestand, pcx, sizeof (pcx));
    if palette = true then
      lees256kleuren;
    xx:=posx;
    yy:=posy;
    teller:=0;
    leesBuffer;
    while not klaar do
    begin
      if buffer^[Teller] and $C0 = $C0 then
      begin
        herhaal:=buffer^[Teller] - $C0;
        increment;
      end
      else
        herhaal:=1;
      for m:=1 to herhaal do
      begin
        if xx <= MaxX then
          set_point (xx, yy, Buffer^[Teller]);
        inc(xx);
      end;
      if xx >= pcx. aantalbytesperLijn + posx then
      begin
        xx:=posx;
        Inc(yy);
        If yy > MaxY then
          klaar:=true;
      end;
      increment;
    end;
    close (pcx_bestand);
    klaar:=false;
  end;
  dispose (buffer);
End;

procedure loadsong;
begin
  if not song. playing then
  begin
    assign (f, temp);
    reset (f);
    song. filename:=temp;
    for t1:=1 to 40 do
      for t2:=1 to 17 do
        for t3:=1 to 16 do
          readln (f, pattern [t1, t2, t3]);
    for t1:=41 to 60 do
      for t2:=1 to 17 do
        for t3:=1 to 16 do
          readln (f, t4);
    for t1:=1 to 100 do
      readln (f, position [t1]);
    for t1:=101 to 200 do
      readln (f, t4);
    readln (f, looppos);
    readln (f, lastpos);
    readln (f, startspeed);
    readln (f, songname);
    For t1:=1 to 16 do
    begin
      readln (f, startvoice [t1]);
      readln (f, t2);
      startmode [t1]:=(t2 = 1);
      readln (f, startvolume [t1])
    end;
    for t1:=1 to 20 do
      readln (f, voicechange [t1]);
    if ioresult > 0 then
      write ('failed!');
    close (f)
  end
End;

Procedure StopSong;
Begin
  If not wavetable_on then
    exit;
  If song. playing then
  begin
    Inline ($FA);
    Env:=memw [regs.ES:$2C];
    regs.AH:=$49;
    MsDos (regs);
    regs.ES:=Env;
    regs.AH:=$49;
    MsDos (regs);
    SwapVectors;
    SetIntVec ($1C, @IntVec);
    SwapVectors;
    SilenceAll;
    ResetGM;
    song. playing:=False;
    Inline ($FB);
  End;
End;

Procedure PlayNextStep (track, step : Byte);
Begin
  If not wavetable_on then
    exit;
  { 2 Drum Tracks }
  For t1:=16 to 17 do
  begin
    t2:=pattern [track, t1, step];
    If (t2 > 0) and (t2 < 96) then
    begin
      SilenceChannel (9);
      SetNoteOn (9, t2, volume [16] * 8);
    end;
    If (t2 > 95) and (t2 < 112) and (song. fading = 0) then
      volume [16]:=t2 - 96;
  End;
  { 15 Music Tracks }
  endofpattern:=False;
  For t1:=1 to 15 do
  begin
    t2:=pattern [track, t1, step];
    If (t2 > 180) and (t2 < 191) then
      speed:=t2 - 181;
    If pattern [track, t1, step + 1] = 191 then
      endofpattern:=True;
  End;
  For t1:=1 to 15 do
  begin
    t2:=pattern [track, t1, step];
    If (t2 > 96) and (t2 < 161) and (song. fading = 0) then
      volume [t1]:=t2 - 97;
    If (t2 > 160) and (t2 < 171) then
    begin
      If t1 < 10 then
        SetModulation (t1 - 1, (t2 - 161) * 14)
      else
        SetModulation (t1, (t2 - 161) * 14);
    End;
    If (t2 > 170) and (t2 < 181) then
    begin
      If t1 < 10 then
        SetChorus (t1 - 1, (t2 - 171) * 14)
      else
        SetChorus (t1, (t2 - 171) * 14);
    End;
    If (t2 > 224) and (t2 < 246) then
    begin
      voice [t1]:=voicechange [t2 - 225];
      If t1 < 10 then
        SetInstrument (t1 - 1, voicechange [t2 - 225] - 1)
      else
        SetInstrument (t1, voicechange [t2 - 225] - 1);
    End;
    If (t2 > 0) and (t2 < 97) then
    begin
      If t1 < 10 then
      begin
        If (mode [t1] = True) or (pattern [track, t1, step] = 96) then
          SetNoteOff (t1 - 1, notehis [t1], 127);
        If (mode [t1] = False) and (pattern [track, t1, step] = 96) then
          SilenceChannel (t1 - 1);
        If pattern [track, t1, step] < 96 then
        begin
          SetModulation (t1 - 1, 0);
          SetNoteOn (t1 - 1, pattern [track, t1, step] + 12 + plusvalue, volume [t1] * 2);
          notehis [t1]:=pattern [track, t1, step] + 12 + plusvalue;
        End;
      End
      else
      begin
        If (mode [t1] = True) or (pattern [track, t1, step] = 96) then
          SetNoteOff (t1, notehis [t1], 127);
        If (mode [t1] = False) and (pattern [track, t1, step] = 96) then
          SilenceChannel (t1);
        If pattern [track, t1, step] < 96 then
        begin
          SetModulation (t1, 0);
          SetNoteOn (t1, pattern [track, t1, step] + 12 + plusvalue, volume [t1] * 2);
          notehis [t1]:=pattern [track, t1, step] + 12 + plusvalue;
        End;
      End;
    End;
  End;
  For t1:=1 to 15 do
  begin
    t2:=pattern [track, t1, step];
    If (t2 > 191) and (t2 < 209) then
      plusvalue:=0 - (t2 - 192);
    If (t2 > 208) and (t2 < 225) then
      plusvalue:=t2 - 209
  End
End;

Procedure Afspeler; Interrupt;
begin
  If not wavetable_on then exit;
  song. playing:=True;
  For t1:=1 to 15 do If t1 < 10 then SetInstrument (t1 - 1, voice [t1] - 1) else SetInstrument (t1, voice [t1] - 1);
  playpos:=step;
  If (time + (10 - speed) <= LongInt (Ptr ($40, $6C)^)) then begin
    track:=position [number];
    PlayNextStep (track, step);
    t2:=0;
    For t1:=1 to 16 do begin
      Dec (volume [t1], song. fading);
      If volume [t1] > 100 then volume [t1]:=0 else t2:=1;
    End;
    If t2 = 0 then StopSong else begin
      step:=step + 1;
      If endofpattern or (step > 16) then begin
        step:=1;
        number:=number + 1;
        If (number > lastpos) and (looppos > 0) then number:=looppos;
      End;
      time:=Longint (Ptr ($40, $6c)^);
      If (number > 200) then number:=1;
    End;
    Inline ($9C);
    IntVec;
  End;
End;

Procedure PlaySong;
Begin
  If not wavetable_on then exit;
  song. fading:=0;
  ResetGM;
  SilenceAll;
  For t1:=1 to 15 do begin
    If t1 < 10 then SetInstrument (t1 - 1, startvoice [t1] - 1) else SetInstrument (t1, startvoice [t1] - 1);
    voice [t1]:=startvoice [t1];
    volume [t1]:=startvolume [t1];
    mode [t1]:=startmode [t1];
  End;
  volume [16]:=15;
  plusvalue:=0;
  speed:=startspeed;
  number:=1; { Positie teller }
  step:=1; { Step teller }
  SwapVectors;
  time:=LongInt (Ptr ($40, $6C)^);
  GetIntVec ($1C, @IntVec);
  SetIntVec ($1C, Addr (Afspeler));
  SwapVectors;
  StackSeg:=Sseg;
  StackPtr:=SPtr;
  regs.AH:=$34;
  MsDos (regs);
End;

Procedure Sleep (k : Byte);
Begin
  If not keypressed then
  begin
    For k:=1 to k do
      sync_display;
  end;
end;

procedure nicetextline (txt_page : byte; x : integer; y : byte; s : string; dy : Boolean);
var
  t, u   : integer;
  tx, ty : byte;
  ts     : String [1];
Const
  sn : Packed Array [1..22] of Char = '-:.,!?"&()[]0123456789';
Begin
  If x = xcentre then
    x:=159 - (length (s) * 4);
  For t:=1 to length (s) do
  begin
    If (copy (s, t, 1) >= 'a') and (copy (s, t, 1) <= 'z') then
    begin
      ts:=Copy (s, t, 1);
      tx:=(Ord (ts [1]) - 97) * 8;
      ty:=2;
    End;
    If (copy (s, t, 1) >= 'A') and (copy (s, t, 1) <= 'Z') then
    begin
      ts:=copy (s, t, 1);
      tx:=(Ord (ts [1]) - 65) * 8;
      ty:=14;
    End;
    For u:=1 to 22 do
    begin
      If copy (s, t, 1) = copy (sn, u, 1) then
      begin
        tx:=(u - 1) * 8;
        ty:=25
      End;
    End;
    If (copy (s, t, 1) <> ' ') and not keypressed then
      copy_bitmap (txt_page, tx, ty, tx + 6, ty + 11, get_active_page, x + t * 8, y);
    If dy then
      Sleep (8)
  End
End;

{procedure start_timer (timeticks : word);
begin
  timer:=longint (ptr ($40, $6c)^) + timeticks
end;

procedure wait_for_timer;
begin
  repeat
  until keypressed or (longint (ptr ($40, $6c)^) >= timer) or (longint (ptr ($40, $6c)^) < timer - 5000);
end;}

begin
  wavetable_on:=true;
end.