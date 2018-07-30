program enddemo;

uses dsp,xmode, crt, dos;

type
  buftp  = array [0..367] of byte;
  SoundBufType = Array [1..65528] of Byte;

var
  pl               : array [0..255, 1..3] of byte;
  pr               : array [0..255, 1..3] of byte;
  r, g, b          : byte;
  t1, t2, t3       : byte;
  buffer           : array [0..52] of ^buftp;
  timer            : longint;
  f                : text;
  s                : string;
  sounddat         : ^SoundBufType;
  fl               : File;
  st               : Word;
  freq             : Word;
  dsp_init_boolean : boolean;
  sound_on         : boolean;
  h : record
    signature        : array [1..19] of char;
    terminator       : byte;
    data_start       : word;
    version          : integer;
    id               : integer;
  end;
  d : record
    id               : byte;
    len              : array [1..3] of byte;
    sr               : byte;
    pack             : byte;
  end;
  texty              : array [1..10] of byte;

  letter             : integer;
  ch                 : char;
  stemp              : string [1];
  xletter            : word;
  tpage              : byte;
  lettery            : byte;
  current_page       : byte;
  Head               : Word   Absolute $0040:$001A;
  Tail               : Word   Absolute $0040:$001C;

const
  white = false;
  yellow  = true;
  xcentre = 500;

  letterx : array [0..52] of word =
  (12, 12, 13, 15, 08, 09, 14, 12, 05, 08, 12, 08, 12,
   11, 16, 14, 16, 13, 12, 10, 10, 10, 15, 11, 10, 11,

   09, 12, 08, 12, 10, 04, 10, 08, 05, 04, 08, 04, 12,
   09, 10, 11, 12, 07, 08, 07, 07, 08, 12, 08, 08, 09,
   06);

  txttotal = 114;

  txt : array [1..txttotal] of string =
  ('',
   '',
   '',
   '',
   '',
   '',
   '',
   '',
   '',
   '    And their story ends...',
   '',
   '',
   '',
   '',
   '   Mace and Fleur lived long',
   ' and the village was no longer',
   ' endangered by the Dark Lord.',
   '',
   '',
   '',
   '    Or so it seemed...',
   '',
   '',
   '',
   '     But appearances are',
   '         deceptive...',
   '',
   '',
   '',
   '',
   '',
   '    Maybe Mace will have to',
   '     fight again....',
   '',
   '  ..but that is another story.',
   '',
   '',
   '',
   '       This was Avalon',
   '',
   '        Copyright MiG',
   '',
   '',
   '',
   '          Code by',
   '',
   '          Jer Der',
   '',
   '',
   '',
   '      Music composed by',
   '',
   '          Jer Der',
   '          Tracer',
   '',
   '',
   '',
   '    Graphics performed by',
   '',
   '          Tracer',
   '',
   '',
   '',
   '   MiGTracker Pro Engine by',
   '',
   '          Jer Der',
   '',
   '',
   '',
   '      Character design',
   '',
   '          Tracer',
   '          Caw',
   '',
   '',
   '',
   '         Testing',
   '',
   '          Jer Der',
   '          Macc Maverick',
   '          Tracer',
   '          Lee',
   '          Sram',
   '',
   '',
   '',
   '   Moral and mental support',
   '',
   '          Herma',
   '          Rose',
   '          Fleur',
   '          Henk',
   '          Ietje',
   '          Wim',
   '',
   '',
   '        Thanks go to',
   '',
   '          Lee',
   '          Sram',
   '          Mark',
   '          Michael Jackson',
   '          The Pope',
   '',
   '          And you...',
   '',
   '',
   '',
   '',
   '          THE END',
   '',
   '',
   '',
   '');

Procedure ClrKey;
Begin
  Head:=Tail;
End;

procedure nicetextline (txt_page : byte; x : integer; y : byte; s : string; dy, color : boolean);
var
  t, u, t1, t2 : integer;
  tx, ty       : byte;
  ts           : String [1];
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
    If (copy (s, t, 1) <> ' ') then
    begin
      if color then
        inc (ty, 37);
      copy_bitmap (txt_page, tx, ty, tx + 6, ty + 11, get_active_page, x + t * 8, y);
      if dy then
        for t3:=1 to 6 do
          sync_display
    end
  end
end;

Procedure SetPal (Col,R,G,B : Byte); assembler;
  { This sets the Red, Green and Blue values of a certain color }
asm
   mov    dx,3c8h
   mov    al,[col]
   out    dx,al
   inc    dx
   mov    al,[r]
   out    dx,al
   mov    al,[g]
   out    dx,al
   mov    al,[b]
   out    dx,al
end;

Procedure GetPal (Col : Byte; Var R,G,B : Byte);
  { This gets the Red, Green and Blue values of a certain color }
Var
   rr,gg,bb : Byte;
Begin asm
      mov    dx,3c7h
      mov    al,col
      out    dx,al

      add    dx,2

      in     al,dx
      mov    [rr],al
      in     al,dx
      mov    [gg],al
      in     al,dx
      mov    [bb],al
   end;
   r:=rr;
   g:=gg;
   b:=bb;
end;

procedure get_bitmap (x1, y1, x2, y2 : integer; bufnr : byte);
var t1, t2 : integer;
begin
  for t1:=0 to y2 - y1 do
    for t2:=0 to x2 - x1 do
      buffer [bufnr]^ [t1 * (x2 - x1) + t2]:=read_point (x1 + t2, y1 + t1);
end;

procedure tcopy_bitmap (sourcepage, x1, y1, x2, y2, destpage, dx, dy : integer; bufnr : byte);
var tap : byte;
begin
  tap:=get_active_page;
  set_active_page (destpage);
  tdraw_bitmap (buffer [bufnr]^ [0], dx, dy, x2 - x1, y2 - y1);
  set_active_page (tap)
end;

procedure start_timer (timeticks : LongInt);
begin
  timer:=longint (ptr ($40, $6c)^) + timeticks
end;

procedure wait_for_timer;
begin
  repeat
  until (longint (ptr ($40, $6c)^) >= timer) or (longint (ptr ($40, $6c)^) < timer - 5000);
end;

procedure grab_palette;
var
  t1 : integer;
begin
  for t1:=0 to 255 do
  begin
    getpal (t1, pl [t1, 1], pl [t1, 2], pl [t1, 3]);
    if (t1 <> 44) and (t1 <> 45) and (t1 <> 60) then
      setpal (t1, 0, 0, 0)
  end;
end;

procedure fadein_without_font;
var t1,
    t2,
    t3 : integer;
begin
  for t1:=0 to 255 do
    for t2:=1 to 3 do
      if pl [t1, t2] > 0 then
        pr [t1, t2]:=3
      else
        pr [t1, t2]:=0;
  for t1:=3 to 64 do
  begin
    for t2:=0 to 255 do
      if (t2 <> 44) and (t2 <> 45) and (t2 <> 60) then
      begin
        set_dac_register (t2, pr [t2, 1], pr [t2, 2], pr [t2, 3]);
        inc (pr [t2, 1]);
        if pr [t2, 1] >= pl [t2, 1] then
          pr [t2, 1]:=pl [t2, 1];
        inc (pr [t2, 2]);
        if pr [t2, 2] >= pl [t2, 2] then
          pr [t2, 2]:=pl [t2, 2];
        inc (pr [t2, 3]);
        if pr [t2, 3] >= pl [t2, 3] then
          pr [t2, 3]:=pl [t2, 3];
      end;
      sync_display;
      sync_display;
      sync_display;
      sync_display
  end
end;

Procedure fadeout;
var t1, t2 : integer;
begin
  for t1:=0 to 255 do
    getpal (t1, pl [t1, 1], pl [t1, 2], pl [t1, 3]);
  for t1:=120 downto 1 do
  begin
    sync_display;
    for t2:=255 downto 0 do
    begin
      setpal (t2, pl [t2, 1], pl [t2, 2], pl [t2, 3]);
      dec (pl [t2, 1]);
      if pl [t2, 1] > 254 then
        pl [t2, 1]:=0;
      dec (pl [t2, 2]);
      if pl [t2, 2] > 254 then
        pl [t2, 2]:=0;
      dec (pl [t2, 3]);
      if pl [t2, 3] > 254 then
        pl [t2, 3]:=0
    end;
  end
end;

Procedure fadeoutpicture;
var t1, t2 : integer;
Begin
  for t1:=0 to 255 do
    getpal (t1, pl [t1, 1], pl [t1, 2], pl [t1, 3]);
  for t1:=120 downto 1 do
  begin
    for t2:=255 downto 0 do
    begin
      if t2 <> 15 then
      begin
        setpal (t2, pl [t2, 1], pl [t2, 2], pl [t2, 3]);
        dec (pl [t2, 1]);
        if pl [t2, 1] > 254 then
          pl [t2, 1]:=0;
        dec (pl [t2, 2]);
        if pl [t2, 2] > 254 then
          pl [t2, 2]:=0;
        dec (pl [t2, 3]);
        if pl [t2, 3] > 254 then
          pl [t2, 3]:=0;
      end
    end;
    start_timer (1);
    wait_for_timer
  end
end;

procedure wait;
begin
  start_timer (10);
  wait_for_timer;
end;

Procedure DMA_Stop;
Begin
  DMAStop
End;

Procedure Speaker_Off;
Begin
  SpeakerOff
End;

Procedure Init_DSP;
Begin
  if not DSP_INIT_BOOLEAN then
  begin
    dsp_init_boolean:=true;
    New(SoundDat);
    ResetDSP(2);
    SpeakerOn
  end
End;

Procedure PlaySample (filename : String);
Begin
  if not sound_on then
    exit;
  {$I-}
  assign(fl, 'VOC\' + filename);
  reset(fl, 1);
  blockread(fl, h, 26);
  blockread(fl, d, 6);
  seek(fl, h.data_start);
  freq := round(1000000 / (256 - d.sr));
  st   := ord(d.len[3]) + ord(d.len[2]) * 256 + ord(d.len[1]) * 256 * 256;
  blockread(Fl, SoundDat^, ST);
  PlayBack (SoundDat, st, freq);
  Close (fl);
  {$I+}
End;

procedure coolline (x, y : word; s : string; yl : byte);
var
  t1, t2, t3 : integer;
begin
  for t1:=1 to length (s) do
  begin
     stemp:=copy (s, t1, 1);
     ch:=stemp [1];
     if ord (ch) <> 32 then
     begin
       if ord (ch) in [65..91] then
       begin
         lettery:=2;
         letter:=ord (ch) - 65
       end
       else
       if ord (ch) in [97..123] then
       begin
         lettery:=27;
         letter:=ord (ch) - 97 + 26;
       end
       else
       if ord (ch) = 46 then
       begin
         letter:=52;
         lettery:=52
       end;
       xletter:=0;
       if letter in [01..25] then
       begin
         for t2:=0 to letter - 1 do
           inc (xletter, letterx [t2])
       end
       else
       if letter in [26..51] then
       begin
         for t2:=26 to letter - 1 do
           inc (xletter, letterx [t2])
       end;
       tcopy_bitmap (1, xletter, lettery, xletter + letterx [letter], lettery + yl, get_active_page, x, y, letter);
       inc (x, letterx [letter] + 1);
     end
     else
       inc (x, 12)
  end
end;

procedure get_all_characters;
begin
  tpage:=get_active_page;
  set_active_page (1);
  s:='ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz.';
  for t1:=1 to length (s) do
  begin
     stemp:=copy (s, t1, 1);
     ch:=stemp [1];
     if ord (ch) <> 32 then
     begin
       if ord (ch) in [65..91] then
       begin
         lettery:=2;
         letter:=ord (ch) - 65
       end
       else
       if ord (ch) in [97..123] then
       begin
         lettery:=27;
         letter:=ord (ch) - 97 + 26;
       end
       else
       if ord (ch) = 46 then
       begin
         letter:=52;
         lettery:=52;
       end;
       xletter:=0;
       if letter in [01..25] then
         for t2:=0 to letter - 1 do
           inc (xletter, letterx [t2])
       else
       if letter in [26..51] then
       begin
         for t2:=26 to letter - 1 do
           inc (xletter, letterx [t2])
       end;
       new (buffer [letter]);
       get_bitmap (xletter, lettery, xletter + letterx [letter], lettery + 23, letter);
     end
  end;
  set_active_page (tpage)
end;

procedure textfadeout;
var t1 : integer;
begin
  t1:=63;
  while t1 > 0 do
  begin
    setpal (60, t1, 63, 63);
    dec (t1, 16);
    sync_display
  end;
  t1:=63;
  while t1 > 0 do
  begin
    setpal (60, 0, t1, 63);
    dec (t1, 16);
    sync_display
  end;
  t1:=63;
  while t1 > 0 do
  begin
    setpal (60, 0, 0, t1);
    dec (t1, 16);
    sync_display
  end
end;

begin
  if paramstr (1) <> 'MIGCODE' then
  begin
    writeln ('This application cannot be run stand-alone.');
    halt
  end;
  assign (f, 'avalon.cfg');
  reset (f);
  for t1:=1 to 3 do
    readln (f, s);
  readln (f, t1);
  readln (f, s);
  readln (f, t1);
  readln (f, s);
  readln (f, t1);
  sound_on:=(t1 = 1);
  close (f);
  if sound_on then
  begin
    init_dsp;
    speakeron;
    dma_stop
  end;
  set_modex (mode_320x200);
  loadsong ('MTP\ENDDEMO.MTP');
  playsong;
  set_active_page (1);
  load_pcx (0, 0, 319, 199, 'PCX\FONT3.PCX', false);
  set_active_page (2);
  load_pcx (0, 0, 320, 200, 'PCX\FACE3.PCX', true);
  set_active_page (0);
  set_display_page (0);
  nicetextline (1, 64, 80, '(The next morning...)', true, white);
  for t1:=1 to 250 do
    sync_display;
  textfadeout;
  wait;
  clear_vga_screen (0);
  setpal (60, 255, 255, 255);
  copy_bitmap (2, 116, 44, 157, 86, 0, 0, 20);
  nicetextline (1, 52, 20, '[FLEUR]', false, yellow);
  nicetextline (1, 52, 32, '(MACE... MACE !!', true, white);
  wait;
  nicetextline (1, 52, 44, 'What-s that noise ?)', true, white);
  start_timer (40);
  wait_for_timer;
  copy_bitmap (2, 60, 43, 107, 86, 0, 40, 100);
  nicetextline (1, 92, 100, '[MACE]', false, yellow);
  nicetextline (1, 92, 112, '(I don-t know.', true, white);
  wait;
  nicetextline (1, 92, 124, 'But don-t worry !', true, white);
  wait;
  nicetextline (1, 92, 136, 'I-ll take a look.)', true, white);
  start_timer (40);
  wait_for_timer;
  playsample ('OPENDOOR.VOC');
  wait;
  wait;
  clear_vga_screen (0);
  copy_bitmap (2, 12, 43, 59, 86, 0, 0, 20);
  nicetextline (1, 52, 20, '[MACE]', false, yellow);
  nicetextline (1, 52, 32, '(Lee ! How nice to see you.)', true, white);
  start_timer (40);
  wait_for_timer;
  copy_bitmap (2, 200, 44, 239, 86, 0, 40, 100);
  nicetextline (1, 92, 100, '[LEE]', false, yellow);
  nicetextline (1, 92, 112, '(Hello Mace, hello Fleur !', true, white);
  wait;
  nicetextline (1, 92, 124, 'Have you two slept well ?)', true, white);
  start_timer (40);
  wait_for_timer;
  clear_vga_screen (0);
  copy_bitmap (2, 60, 43, 107, 86, 0, 0, 20);
  nicetextline (1, 52, 20, '[MACE]', false, yellow);
  nicetextline (1, 52, 32, '(Can you tell us what that noise', true, white);
  nicetextline (1, 52, 44, 'is outside ? It-s not those', true, white);
  nicetextline (1, 52, 56, 'creatures again, is it ?)', true, white);
  start_timer (40);
  wait_for_timer;
  copy_bitmap (2, 200, 44, 239, 86, 0, 40, 100);
  nicetextline (1, 92, 100, '[LEE]', false, yellow);
  nicetextline (1, 92, 112, '(No, the creatures are gone.', true, white);
  wait;
  nicetextline (1, 92, 124, 'Thanks to you...)', true, white);
  start_timer (40);
  wait_for_timer;
  clear_vga_screen (0);
  copy_bitmap (2, 200, 44, 239, 86, 0, 0, 20);
  nicetextline (1, 52, 20, '[LEE]', false, yellow);
  nicetextline (1, 52, 32, '(The sound you are hearing,', true, white);
  wait;
  nicetextline (1, 52, 44, 'is because of the party !', true, white);
  wait;
  nicetextline (1, 52, 56, 'We-re celebrating your victory.', true, white);
  wait;
  nicetextline (1, 52, 68, 'Will you two join us ?)', true, white);
  start_timer (40);
  wait_for_timer;
  copy_bitmap (2, 12, 43, 59, 86, 0, 40, 100);
  nicetextline (1, 92, 100, '[MACE]', false, yellow);
  nicetextline (1, 92, 112, '(Of course we will !', true, white);
  wait;
  nicetextline (1, 92, 124, 'Won-t we, Fleur ?)', true, white);
  start_timer (40);
  wait_for_timer;
  clear_vga_screen (0);
  copy_bitmap (2, 116, 44, 157, 86, 0, 0, 20);
  nicetextline (1, 52, 20, '[FLEUR]', false, yellow);
  nicetextline (1, 52, 32, '(Sure.', true, white);
  wait;
  nicetextline (1, 52, 44, 'Let-s go !)', true, white);
  start_timer (40);
  wait_for_timer;
  fadeout;
  while song. playing do
    song. fading:=4;
  stopsong;
  set_modex (mode_320x200);
  set_active_page (1);
  load_pcx (0, 0, 320, 200, 'PCX\ENDFONT.PCX', true);
  get_all_characters;
  set_active_page (2);
  load_pcx (0, 0, 320, 200, 'PCX\DARKCSTL.PCX', false);
  set_active_page (3);
  set_display_page (0);
  loadsong ('MTP\FOUNTAIN.MTP');
  playsong;
  grab_palette;
  t1:=1;
  repeat
    t3:=20;
    repeat
      copy_bitmap (2, 0, 0, 320, 200, 3, 0, 0);
      for t2:=2 to 10  do
        coolline (0, t2 * 20 - t3, txt [t1 + (t2 - 1)], 23);
      inc (t3, 1);
      copy_bitmap (3, 0, 15, 320, 182, 0, 0, 15);
      sync_display;
      sync_display;
    until (t3 > 39);
    inc (t1);
    if t1 = 23 then
    begin
      fadein_without_font;
      start_timer (24);
      wait_for_timer
    end;
  until (t1 > txttotal - 9);
  clrkey;
  readkey;
  for t1:=0 to 255 do
    getpal (t1, pl [t1, 1], pl [t1, 2], pl [t1, 3]);
  for t2:=0 to 63 do
  begin
    for t1:=0 to 255 do
    begin
      setpal (t1, pl [t1, 1], pl [t1, 2], pl [t1, 3]);
      for t3:=1 to 3 do
      begin
        inc (pl [t1, t3]);
        if pl [t1, t3] > 63 then
          pl [t1, t3]:=63;
      end
    end;
    if not keypressed then
    begin
      sync_display;
      sync_display
    end
  end;
  song. fading:=4;
  for t1:=63 downto 0 do
  begin
    for t2:=0 to 255 do
      setPal (t2, t1, t1, t1);
    sleep (2)
  end;
  while song.playing do
    song.fading:=4;
  clrkey
end.