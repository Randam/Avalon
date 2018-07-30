program testxunit;

uses xmode, crt;

type
  buftp  = array [$0000..$FFFE] of byte;
  startp = record
             x : integer;
             y : byte
           end;

const
  star_start : array [1..2, 1..5] of startp = (
  ((x:010;y:100),(x:160;y:010),(x:250;y:050),(x:60;y:160),(x:190;y:190)),
  ((x:050;y:080),(x:120;y:040),(x:270;y:110),(x:80;y:190),(x:170;y:150)));

var
  pl               : array [0..255, 1..3] of byte;
  pr               : array [0..255, 1..3] of byte;
  r, g, b          : byte;
  t1, t2, t3       : byte;
  animation        : byte;
  y_picvil         : byte;
  layer1x, layer2x : integer;
  timer            : longint;
  ani_mace         : Word;
  ani_backgrnd     : word;
  buffer           : ^buftp;
  star_pos         : array [1..2, 1..5] of startp;

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

procedure get_bitmap (x1, y1, x2, y2 : integer);
var t1, t2 : integer;
begin
  for t1:=0 to y2 - y1 do
    for t2:=0 to x2 - x1 do
      buffer^ [t1 * (x2 - x1) + t2]:=read_point (x1 + t2, y1 + t1);
end;

procedure tcopy_bitmap (sourcepage, x1, y1, x2, y2, destpage, dx, dy : integer);
var tap : byte;
begin
  tap:=get_active_page;
  set_active_page (sourcepage);
  get_bitmap (x1, y1, x2, y2);
  set_active_page (destpage);
  tdraw_bitmap (buffer^ [0], dx, dy, x2 - x1, y2 - y1);
  set_active_page (tap)
end;

procedure mace_moves;
begin
  if keypressed or (ani_mace < 1) then
  begin
    animation:=0;
    exit;
  end;
  copy_bitmap (2, 180, 0, 320, 200 - ani_backgrnd, 3, 20, ani_backgrnd);
  tcopy_bitmap (2, 20, 0, 175, 200 - ani_mace, 3, 0, ani_mace);
  sync_display;
  copy_bitmap (3, 20, 0, 160, 200, 0, 20, 0);
  dec (ani_mace, 2);
  if ani_mace mod 8 = 0 then
    inc (ani_backgrnd);
end;

procedure multi_layer_scroll;
begin
  if keypressed then
    exit;
  if layer1x < 160 then
    copy_bitmap (2, layer1x, 0, layer1x + 160, 36, 0, 80, 20)
  else
  begin
    copy_bitmap (2, layer1x, 0, 319, 36, 0, 80, 20);
    copy_bitmap (2, 0, 0, 160 - (319 - layer1x), 36, 0, 80 + (319 - layer1x), 20);
  end;
  inc (layer1x, 1);
  if layer1x > 319 then
    layer1x:=0;
  if layer2x < 160 then
    copy_bitmap (2, layer2x, 37, layer2x + 160, 100, 0, 80, 57)
  else
  begin
    copy_bitmap (2, layer2x, 37, 319, 100, 0, 80, 57);
    copy_bitmap (2, 0, 37, 160 - (319 - layer2x), 100, 0, 79 + (319 - layer2x), 57);
  end;
  inc (layer2x, 2);
  if layer2x > 319 then
    layer2x:=0;
  sleep (1);
end;

procedure starfield;
var t1, t2 : integer;
    r,g,b  : byte;
begin
  if keypressed then
    exit;
  set_active_page (0);
  if not keypressed then
    sync_display;
  for t1:=1 to 2 do
    for t2:=1 to 5 do
    begin
      if read_point (star_pos [t1, t2]. x, star_pos [t1, t2]. y) in [253, 254] then
        set_point (star_pos [t1, t2]. x, star_pos [t1, t2]. y, 0);
      dec (star_pos [t1, t2]. x, t1);
      if star_pos [t1, t2]. x < 0 then
        star_pos [t1, t2]. x:=319;
      GetPal (read_point (star_pos [t1, t2]. x, star_pos [t1, t2]. y), r, g, b);
      if not keypressed and (r < 3) and (g < 3) and (b < 3) then
        set_point (star_pos [t1, t2]. x, star_pos [t1, t2]. y, t1 + 252);
    end
end;

procedure start_timer (timeticks : LongInt);
begin
  timer:=longint (ptr ($40, $6c)^) + timeticks
end;

procedure wait_for_timer;
begin
  repeat
    if animation = 2 then
      multi_layer_scroll
    else
    if animation = 4 then
      starfield;
  until keypressed or (longint (ptr ($40, $6c)^) >= timer) or (longint (ptr ($40, $6c)^) < timer - 5000);
end;

procedure vilanimate;
begin
  if (longint (ptr ($40, $6c)^) mod 2 = 0) and (y_picvil > 0) and not keypressed then
  begin
    sync_display;
    dec (y_picvil, 1);
    copy_bitmap (2, 0, y_picvil, 319, y_picvil + 100, 0, 0, 7);
  end;
  if not keypressed then sync_display
end;

procedure nicetextline (txt_page : byte; x : integer; y : byte; s : string; dy : Boolean);
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
    If (copy (s, t, 1) <> ' ') and not keypressed then
      copy_bitmap (txt_page, tx, ty, tx + 6, ty + 11, get_active_page, x + t * 8, y);
    If dy then
      for t1:=1 to 7 do
      begin
        case animation of
        1 : vilanimate;
        2 : multi_layer_scroll;
        3 : mace_moves;
        4 : starfield;
        else sleep (1);
        end
      end
  End
End;

procedure grab_palette;
var t1 : integer;
begin
  for t1:=0 to 255 do
  begin
    getpal (t1, pl [t1, 1], pl [t1, 2], pl [t1, 3]);
    if t1 <> 15 then
      setpal (t1, 0, 0, 0)
  end;
end;

procedure fadein_without_font;
var t1,
    t2,
    t3 : integer;
begin
  if keypressed then
    exit;
  for t1:=0 to 255 do
    for t2:=1 to 3 do
      if pl [t1, t2] > 0 then
        pr [t1, t2]:=3
      else
        pr [t1, t2]:=0;
  for t1:=3 to 64 do
  begin
    for t2:=0 to 255 do
      if not keypressed and (t2 <> 15) and ((t2 < 253) or (animation < 4)) then
      begin
        set_dac_register (t2, pr [t2, 1], pr [t2, 2], pr [t2, 3]);
        if animation = 4 then
        begin
          setpal (254, 50, 50, 50);
          setpal (253, 20, 20, 20);
        end;
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
    for t3:=1 to 4 do
      if not keypressed then
        if animation = 4 then
          starfield
        else
          sync_display
  end
end;

Procedure fadeout;
var t1, t2 : integer;
begin
  if keypressed then
    exit;
  for t1:=0 to 255 do
    getpal (t1, pl [t1, 1], pl [t1, 2], pl [t1, 3]);
  for t1:=120 downto 1 do
  begin
    if animation = 2 then
      multi_layer_scroll
    else
    if animation = 4 then
      starfield
    else
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
  if keypressed then
    exit;
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
    if animation = 4 then
      starfield
    else
      sync_display
  end
end;


procedure textfadeout;
var t1 : integer;
begin
  if keypressed then
    exit;
  t1:=63;
  while (t1 > 0) and not keypressed do
  begin
    setpal (15, t1, 63, 63);
    dec (t1, 16);
    if animation = 2 then
      multi_layer_scroll
    else
      sync_display
  end;
  t1:=63;
  while (t1 > 0) and not keypressed do
  begin
    setpal (15, 0, t1, 63);
    dec (t1, 16);
    if animation = 2 then
      multi_layer_scroll
    else
    if animation = 4 then
      starfield
    else
      sync_display
  end;
  t1:=63;
  while (t1 > 0) and not keypressed do
  begin
    setpal (15, 0, 0, t1);
    dec (t1, 16);
    if animation = 2 then
      multi_layer_scroll
    else
      sync_display
  end
end;

begin
  for t1:=1 to 2 do
    for t2:=1 to 5 do
      star_pos [t1, t2]:=star_start [t1, t2];
  animation:=0;
  set_modex (mode_320x200);
  loadsong ('MTP\AVALON26.MTP');
  playsong;
  set_active_page (1);
  load_pcx (0, 0, 319, 199, 'PCX\FONT.PCX', false);
  setpal (254, 50, 50, 50);
  setpal (253, 20, 20, 20);
  set_active_page (0);
  animation:=4;
  start_timer (5);
  wait_for_timer;
  start_timer (145);
  nicetextline (1, 20, 80, 'IT IS THE YEAR 3045 AD', true);
  nicetextline (1, 20, 92, '23:41 EARTH TIME......', true);
  wait_for_timer;
  start_timer (200);
  setpal (15, 63, 63, 63);
  nicetextline (1, 20, 120, 'THE FEW SURVIVORS OF A RACE', true);
  nicetextline (1, 20, 132, 'CALLED HUMANS ARE APPROACHING', true);
  nicetextline (1, 20, 144, 'THEIR FINAL DESTINY...', true);
  wait_for_timer;
  textfadeout;
  clear_vga_screen (0);
  setpal (15, 63, 63, 63);
  start_timer (5);
  nicetextline (1, 20, 120, '...AVALON', true);
  set_active_page (2);
  load_pcx (0, 0, 320, 199, 'PCX\DEMOPIC1.PCX', true);
  setpal (254, 50, 50, 50);
  setpal (253, 20, 20, 20);
  grab_palette;
  copy_bitmap (2, 0, 0, 319, 120, 0, 0, 0);
  set_active_page (0);
  if not keypressed then
    fadein_without_font;
  wait_for_timer;
  textfadeout;
  start_timer (260);
  fill_block (0, 120, 319, 199, 0);
  setpal (15, 63, 63, 63);
  nicetextline (1, 20, 120, 'AFTER THE DESTRUCTION OF EARTH', true);
  nicetextline (1, 20, 132, 'THIS PLANET, WHICH WAS BELIEVED', true);
  nicetextline (1, 20, 144, 'TO HAVE AN EARTH-LIKE CLIMATE,', true);
  nicetextline (1, 20, 156, 'WAS THEIR ONLY HOPE..', true);
  wait_for_timer;
  textfadeout;
  fill_block (0, 120, 320, 199, 0);
  setpal (15, 63, 63, 63);
  for t1:=100 downto 1 do
    if not keypressed then
    begin
      copy_bitmap (0, 0, t1 - 1, 319, t1 + 100, 0, 0, t1);
      if animation = 4 then
        starfield
      else
        sync_display
    end;
  start_timer (225);
  nicetextline (1, 20, 20, 'THE LANDING WAS SUCCESFULL', true);
  nicetextline (1, 20, 32, 'AND THE COLONISTS AWOKE FROM', true);
  nicetextline (1, 20, 44, 'THEIR 251-YEARS OF SLEEP..', true);
  nicetextline (1, 20, 68, 'A NEW LIFE AHEAD OF THEM.', true);
  wait_for_timer;
  fadeout;
  clear_vga_screen (0);
  set_active_page (2);
  load_pcx (0, 0, 319, 199, 'PCX\VILLAGE3.PCX', true);
  animation:=1;
  y_picvil:=99;
  set_active_page (0);
  start_timer (240);
  nicetextline (1, 20, 120, 'WITHIN THREE YEARS THE FIRST', true);
  nicetextline (1, 20, 132, 'VILLAGE AROSE ON AVALON.', true);
  nicetextline (1, 20, 156, 'THE COLONISTS HAD NOTHING', true);
  nicetextline (1, 20, 168, 'TO FEAR ON THIS FRIENDLY PLANET.', true);
  wait_for_timer;
  start_timer (100);
  fadeoutpicture;
  for t1:=120 downto 20 do
  begin
    if not keypressed then
    begin
      copy_bitmap (0, 0, t1, 319, t1 + 79, 0, 0, t1 - 1);
      sync_display
    end
  end;
  wait_for_timer;
  start_timer (60);
  nicetextline (1, 20, 100, 'OR SO IT SEEMED...', true);
  wait_for_timer;
  textfadeout;
  start_timer (125);
  clear_vga_screen (0);
  set_active_page (2);
  if not keypressed then
  begin
    load_pcx (0, 0, 319, 199, 'PCX\EYE.PCX', true);
    grab_palette;
    set_active_page (0);
    copy_bitmap (2, 0, 0, 319, 199, 0, 0, 0)
  end;
  nicetextline (1, 20, 50, 'BUT APPEARANCES ARE DECEPTIVE...', true);
  fadein_without_font;
  wait_for_timer;
  fadeout;
  start_timer (240);
  clear_vga_screen (0);
  set_active_page (2);
  set_display_page (0);
  if not keypressed then
    load_pcx (0, 0, 320, 199, 'PCX\LAYER1.PCX', true);
  layer1x:=0;
  layer2x:=0;
  animation:=2;
  set_active_page (0);
  nicetextline (1, 20, 130, 'AND WHEN THE VILLAGE WAS SUDDENLY', true);
  nicetextline (1, 20, 142, 'ATTACKED BY HORRIBLE CREATURES,', true);
  nicetextline (1, 20, 154, 'THEY COULD BARELY HOLD....', true);
  wait_for_timer;
  textfadeout;
  fill_block (0, 130, 320, 199, 0);
  setpal (15, 63, 63, 63);
  start_timer (140);
  nicetextline (1, 20, 130, 'MANY COLONISTS HAD DIED BEFORE THE', true);
  nicetextline (1, 20, 142, 'MONSTERS COULD BE DRIVEN BACK.', true);
  wait_for_timer;
  fadeout;
  animation:=0;
  clear_vga_screen (0);
  setpal (15, 63, 63, 63);
  start_timer (230);
  nicetextline (1, 20, 050, 'PARALIZED BY THE MONSTER ATTACK,', true);
  nicetextline (1, 20, 062, 'THE COLONISTS WERE NOT ABLE', true);
  nicetextline (1, 20, 074, 'TO REORGANISE THEIR DEFENCE.', true);
  wait_for_timer;
  start_timer (200);
  nicetextline (1, 20, 098, 'IF THE ALIENS WOULD COME AGAIN,', true);
  nicetextline (1, 20, 110, 'THE COLONISTS WOULD MOST CERTAINLY', true);
  nicetextline (1, 20, 122, 'BE SLAUGHTERED...', true);
  wait_for_timer;
  textfadeout;
  if not keypressed then
  begin
    clear_vga_screen (0);
    set_active_page (2);
    load_pcx (0, 0, 320, 200, 'PCX\SKY1.PCX', true);
    set_active_page (0)
  end;
  new (buffer);
  ani_backgrnd:=0;
  ani_mace:=160;
  start_timer (150);
  nicetextline (1, 160, 20, 'THERE WAS BUT', true);
  nicetextline (1, 160, 32, 'ONE MAN CAPABLE', true);
  nicetextline (1, 160, 44, 'OF DEFEATING', true);
  nicetextline (1, 160, 56, 'THE MONSTERS...', true);
  wait_for_timer;
  start_timer (150);
  nicetextline (1, 160, 100, 'A BRAVE MAN,', true);
  nicetextline (1, 160, 112, 'WITH NOTHING', true);
  nicetextline (1, 160, 124, 'TO LOSE.....', true);
  wait_for_timer;
  animation:=0;
  start_timer (180);
  for t1:=1 to 100 do
    mace_moves;
  nicetextline (1, 160, 148, 'YOU...', true);
  wait_for_timer;
  fadeout;
  clear_vga_screen (0);
  setpal (15, 63, 63, 63);
  start_timer (100);
  nicetextline (1, 36, 100, 'PREPARE TO MEET YOUR DESTINY', true);
  wait_for_timer;
  For t1:=0 to 255 do
    GetPal (t1, pl [t1, 1], pl [t1, 2], pl [t1, 3]);
  for t2:=0 to 63 do
  begin
    for t1:=0 to 255 do
    begin
      SetPal (t1, pl [t1, 1], pl [t1, 2], pl [t1, 3]);
      for t3:=1 to 3 do
      begin
        Inc (pl [t1, t3]);
        If pl [t1, t3] > 63 then
          pl [t1, t3]:=63;
      end;
    end;
    if not keypressed then
      sync_display;
  end;
  song. fading:=8;
  for t1:=63 downto 0 do
  begin
    for t2:=0 to 255 do
      setPal (t2, t1, t1, t1);
    sleep (1);
  end;
  while song. playing and not keypressed do
    song. fading:=5;
  stopsong;
end.