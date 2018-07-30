{$F+}
unit AVUNIT;

interface

uses avglob,
     crt,
     dos,
     modex,
     jervga,
     common,
     unitpcx,
     dsp,
     mtpunit,
     heapman;

procedure monster_uses_item;
procedure SetPal (Col,R,G,B : Byte);
procedure GetPal (Col : Byte; Var R,G,B : Byte);
procedure ClrKey;
procedure DrawFrame (x1, y1, x2, y2, c : Word);
function  Str2 (intV : LongInt) : String;
procedure Smfont;
procedure OutText (xn, yn : integer; sn : string);
procedure OpenTextBox;
procedure TitleScreen;
procedure TextLine (yx : Integer; sx : String; color : Byte);
procedure TextBoxLine (yx : Integer; sx : String);
procedure Show_Loading;
procedure FadeIn;
procedure FadeOut;
procedure Sleep (k : Word);
procedure PlaySample (filename : String);
procedure Speaker_Off;
procedure Init_DSP;
procedure DMA_Stop;
procedure NiceTextLine (x, y : Integer; s : string; dy : Boolean; font_in_gold : boolean);
procedure NiceTextLine2 (x, y : Integer; s : string; dy : Boolean);
procedure Game_Over;
procedure Showmenu;
procedure IntroScreen;
procedure IntroDemo;
procedure Blinking_Cursor;
procedure ShowExplosion (n : Byte; delaytime : Byte);
function  LeadingZero(w : Word) : String;
procedure Swiss_Watch;
procedure DrawMace (direction, xplus, yplus, mpage : Byte);
procedure DrawLee;
procedure WepDefMenu;
procedure MaceTriesToOpenDoor;
procedure StringFellowHawk (charnr : Byte);
procedure fadegamescreen;
procedure show_chapter;
procedure try_to_open_main_door (level : byte);
procedure mace_opens_door_with_master_key;
procedure mace_opens_main_door;
procedure start_timer (timeticks : LongInt);
procedure wait_for_timer (key : boolean);
procedure drawmysticbox (x1, y1, x2, y2, color : word);
procedure fake_game_over;
procedure object_found (o_name : string; o_number : byte; o_x : word; o_y : word; o_taken : string);
procedure add_object (objectsname : string; objectsnr : byte);
procedure remove_object (objectsnr : byte);
function  object_present (objectsnr : byte) : boolean;
procedure add_item (itemname : string; itemnr : byte);
procedure remove_item (itemnr : byte);
function item_present (itemnr : byte) : boolean;
procedure showscreen (x, y, xplus, yplus : integer);
procedure updatemonsters;
procedure drawmonsters;
procedure bigbossattack (fight_till_death : boolean);
procedure use_object;
procedure updateinfoscrn;
procedure mainmenu;
procedure use_item;
procedure showmonsterstatus (m : integer);
procedure powersuck (suckrate : byte);
procedure readdata;
procedure updatebars;
procedure showstatus (spos : integer);
procedure stereo;

Implementation

procedure stereo;
type
  songtp = record
    title : string [40];
    filen : string [8];
  end;

const
  songtotal = 26;
  songs : array [1..songtotal] of songtp = (
  (title:'The Mountains';     filen:'23'),
  (title:'The Dungeon';       filen:'25'),
  (title:'Weapon Shop';       filen:'03'),
  (title:'Gray Cave';         filen:'28'),
  (title:'Battle Music';      filen:'06'),
  (title:'Kreznjrk';          filen:'08'),
  (title:'Chapter Change';    filen:'01'),
  (title:'Entrances';         filen:'11'),
  (title:'The Dark Room';     filen:'10'),
  (title:'Castle BGM';        filen:'14'),
  (title:'Game Over';         filen:'13'),
  (title:'The Alien Village'; filen:'16'),
  (title:'The Cellar';        filen:'18'),
  (title:'The Castle Garden'; filen:'20'),
  (title:'Cave BGM';          filen:'15'),
  (title:'Empty Village';     filen:'21'),
  (title:'Village BGM';       filen:'02'),
  (title:'Item Shop';         filen:'04'),
  (title:'Forest BGM';        filen:'05'),
  (title:'The Sea';           filen:'09'),
  (title:'Main Door Opened';  filen:'12'),
  (title:'The Beach BGM';     filen:'24'),
  (title:'Avalon Story';      filen:'26'),
  (title:'Supermonster Tune'; filen:'07'),
  (title:'White Tower BGM';   filen:'31'),
  (title:'Avalon End';        filen:'34'));

begin
  s:=song. filename;
  showscreen (x, y, 0, 0);
  usepage (0);
  drawframe (96, 10, 190, 23, 15);
  solidbox (97, 11, 189, 22, 1);
  font. setfgcolor (14);
  outtext (109, 14, 'SELECT A TRACK');
  font. setfgcolor (15);
  usepage (3);
  t3:=1;
  repeat
    drawframe (96, 25, 190, 127, 15);
    solidbox  (97, 26, 189, 126, 1);
    solidbox (97, 66, 188, 74, 4);
    for t1:=1 to 12 do
      if (t3 + t1 - 6 > 0) and (t3 + t1 - 6 < songtotal + 1) then
        outtext (100, 27 + (t1 - 1) * 8, songs [t3 + t1 - 6]. title);
    blockpagetopage (3, 0, 96, 24, 24, 105, 96, 24);
    ch:=Readkey;
    if ch = #0 then
      ch:=readkey;
    if (ch = #72) and (t3 > 1) then
    begin
      dec (t3);
      playsample ('WALL.VOC')
    end;
    if (ch = #80) and (t3 < songtotal) then
    begin
      inc (t3);
      playsample ('WALL.VOC')
    end;
    if ch = #13 then
    begin
      stopsong;
      loadsong ('MTP\AVALON' + songs [t3]. filen + '.MTP');
      playsong
    end
  until ch = #27;
  stopsong;
  loadsong (s);
  playsong;
  usePage (0)
end;

procedure monster_uses_item;
var
  a   : integer;
  rnd : byte;
begin
  randomize;
  if level > 42 then
    rnd:=random (5) + 1
  else
    if random (10) > 5 then
      rnd:=1
    else
      rnd:=2;
  case rnd of
  1 :
    begin
      textboxline (160, actmonster [t3]. name + ' uses a SMALL MEDIC KIT !');
      playsample ('THEAL.VOC');
      for a:=1 to 100 do
      begin
        inc (actmonster [t3]. life);
        showmonsterstatus (t3);
        waitforretrace
      end
    end;
  2 :
    begin
      textboxline (160, actmonster [t3]. name + ' uses a LARGE MEDIC KIT !');
      playsample ('THEAL.VOC');
      for a:=1 to 200 do
      begin
        inc (actmonster [t3]. life);
        showmonsterstatus (t3);
        if a mod 2 = 0 then
          waitforretrace
      end
    end;
  3 :
    begin
      textboxline (160, actmonster [t3]. name + ' uses a BABY PW SUCKER !!');
      playsample ('pwsuck.voc');
      for a:=1 to 25 do
      begin
        inc (actmonster [t3]. power);
        dec (power);
        showmonsterstatus (t3);
        waitforretrace
      end;
      if power < 0 then
        power:=0;
      textboxline (168, '...and sucks 25 power !');
    end;
  4 :
    begin
      textboxline (160, actmonster [t3]. name + ' uses a STRONG PW SUCKER !!');
      playsample ('pwsuck.voc');
      for a:=1 to 75 do
      begin
        inc (actmonster [t3]. power);
        dec (power);
        showmonsterstatus (t3);
        waitforretrace
      end;
      if power < 0 then
        power:=0;
      textboxline (168, '...and sucks 75 power !');
      delay (500)
    end;
  else
    begin
      a:=actmonster [t3]. maxlife - actmonster [t3]. life;
      if a > 0 then
      begin
        textboxline (160, actmonster [t3]. name + ' uses a MEDIC KIT 2000 !');
        playsample ('MED2000.VOC')
      end
      else
      begin
        textboxline (160, actmonster [t3]. name + ' uses a LARGE MEDIC KIT !!');
        playsample ('THEAL.VOC');
        a:=200
      end;
      for a:=1 to a do
      begin
        inc (actmonster [t3]. life);
        showmonsterstatus (t3);
        if a mod 2 = 0 then
          waitforretrace
      end
    end
  end;
  delay (400);
  solidbox (11, 158, 249, 189, 1);
end;

procedure showdarklordstatus;
begin
  usepage (0);
  solidbox  (90, 116, 230, 132, 1);
  drawframe (90, 116, 230, 132, 15);
  font. setfgcolor (14);
  outtext (92, 118, 'Dark Lord');
  font. setfgcolor (15);
  outtext (164, 118, 'Life: ' + Str2 (Actmonster [1]. life));
  outtext (092, 126, 'Power: ' + Str2 (Actmonster [1]. power));
  outtext (164, 126, 'Defence: ' + Str2 (Actmonster [1]. defence))
end;

procedure darklordhit;
Begin
  Delay (600);
  showmonsterstatus (t4);
  t3:=1;
  if actmonster [t3]. life = 0 then
  begin
    If actmonster [t3]. name <> '' then
    begin
      textboxline (176, Actmonster [t3]. name + ' is no more...');
      usepage (0);
      inc (monsters_killed);
      actmonster [t3]. name:='';
      playsample ('GEYSIR.VOC');
      for t1:=9 to 135 do
      begin
        for t2:=t1 - 1 downto 8 do
          blockpagetopage (0, 0, 16, t1, 74, 1, 16, t2);
        waitforretrace
      end;
      solidbox (11, 158, 249, 189, 1);
      t1:=255;
      ch:=#255
    end
  end
  else
  begin
    solidbox (11, 158, 249, 189, 1);
    font. setfgcolor (14);
    if paralized > 0 then
    begin
      textboxline (160, 'The Dark Lord is paralysed !!');
      dec (paralized, 2);
      sleep (50);
      solidbox (11, 158, 249, 189, 1)
    end
    else
    begin
      if random (10) < 2 then
        monster_uses_item
      else
      begin
        playsample ('ENERGY.VOC');
        textboxline (160, Actmonster [t3]. name + ' strikes...');
        font. SetFGColor (15);
        if random (10) < 2  then
        begin
          playsample ('helihit.voc');
          textboxline (168, '...but mace dodges the attack !');
          delay (400);
        end
        else
        begin
          playsample ('WEAPONCB.VOC');
          t1:=Round (Random (Round (Actmonster [t3]. power / 2)) + Actmonster [t3]. power / 2) - defence;
          blockpagetopage (0, 3, 0, 0, 79, 200, 4, 0);
          for t2:=1 to round (t1 / maxlife * 100) do
          begin
            showpage (3);
            waitforretrace;
            showpage (0)
          end;
          if t1 < 1 then
          t1:=1;
          if t1 < life then
            dec (life, t1)
          else
          begin
            life:=0;
            ch:=#255;
            mace_is_a_dead_man:=true
          end;
          textboxline (168, Str2 (t1) + ' damage !!');
          delay (600)
        end;
        solidbox (11, 158, 249, 189, 1);
        solidbox (71, 149, 244, 155, 1);
        drawframe (70, 148, 245, 156, 15);
        solidbox (71, 149, 71 + Round (maxlife / 8), 155, 39);
        solidbox (71, 149, 71 + Round (life / 8), 155, 09)
      end
    end
  end;
  if not Mace_is_a_dead_man then
  begin
    If Actmonster [1]. name = '' then
    begin
      actmonster [1]. power:=monsterbak [1]. power;
      actmonster [1]. defence:=monsterbak [1]. defence;
      actmonster [2]. power:=monsterbak [2]. power;
      actmonster [2]. defence:=monsterbak [2]. defence;
      t3:=0;
      t4:=0;
      t3:=t3 + Round ((Actmonster [1]. power + Actmonster [1]. defence) / 5);
      t4:=t4 + Round ((Actmonster [1]. life + Actmonster [1]. power) / 2);
      solidbox (11, 158, 249, 189, 1);
      font. setfgcolor (15);
      textboxline (160, 'Experience ' + str2 (level * 150) + ' up.');
      font. setfgcolor (14);
      textboxline (168, str2 (level * 200) + ' gold taken.');
      exp:=exp + level * 150;
      money:=money + level * 200;
      font. SetFGColor (15);
      blinking_cursor;
      updateinfoscrn;
      t1:=255;
      ch:=#255;
    end;
  end
end;

procedure bigbossattack (fight_till_death : boolean);
var tsongfile    : String [20];
    powertmp     : Integer;
begin
  inc (level);
  darklord:=true;
  actmonster [1]. name:='Dark Lord';
  if fight_till_death then
  begin
    actmonster [1]. life:=4000;
    actmonster [1]. power:=550;
    actmonster [1]. maxlife:=4000;
    actmonster [1]. defence:=250;
  end
  else
  begin
    actmonster [1]. life:=2000;
    actmonster [1]. power:=500;
    actmonster [1]. maxlife:=2000;
    actmonster [1]. defence:=250;
  end;
  paralized:=0;
  powertmp:=power;
  tsongfile:=song. filename;
  if battle_music or supermonster then
    song. fading:=8;
  fadegamescreen;
  opentextbox;
  loadsong ('MTP\AVALON07.MTP');
  playsong;
  font. SetFGColor (15);
  outText (12, 150, 'MACE LIFE:');
  drawframe (70, 148, 245, 156, 15);
  solidbox (71, 149, 71 + round (maxlife /  8), 155, 39);
  solidbox (71, 149, 71 + round (life /  8), 155, 09);
  usepage (3);
  if fight_till_death then
    monsterfilename:='finalbs2'
  else
    monsterfilename:='finalbs';
  load_pcx (0, 0, 319, 199, monsterfilename, false);
  usepage (0);
  setpal (252, 0, 0, 0);
  t1:=0;
  t2:=16;
  while t2 < 306 do
  begin
    solidvlineX (t2, 16, 111, 252);
    inc (t2, 6)
  end;
  t2:=16;
  while t2 < 114 do
  begin
    solidhlinex (t2, 16, 303, 252);
    inc (t2, 6)
  end;
  t4:=16;
  t5:=0;
  usepage (3);
  t2:=0;
  t3:=0;
  repeat
    getpic (t2 + t4, t3 + t5, 16, 16, pict_buffer);
    getpicmask (pict_buffer, pict_mask);
    copyscreentoscreenmaskedx (3, t2 + t4, t3 + t5, 4, 16, 16 + t2, 16 + t3, 0, pict_mask);
    freemem (pict_mask, pict_buffer. height * pict_buffer. width);
    freepic (pict_buffer);
    inc (t2, 16);
    if t2 > 280 then
    begin
      t2:=0;
      inc (t3, 16)
    end;
  until t3 > 106;
  actmonster [t1]:=bigmonster [mNr [t1]];
  monsterbak [t1]:=actmonster [t1];
  showdarklordstatus;
  t1:=1;
  mmax:=1;
  mX [1]:=176;
  repeat
    fleed:=False;
    if mace_is_a_dead_man then
      exit;
    showmenu;
    if t1 = 2 then
    begin
      blockpagetopage (0, 1, 0, 0, 80, 150, 0, 0);
      usepage (3);
      t3:=1;
      repeat
        drawframe (96, 25, 190, 127, 15);
        solidbox  (97, 26, 189, 126, 1);
        solidbox (97, 66, 188, 74, 4);
        for t1:=1 to 12 do
          if (t3 + t1 - 6 > 0) and (t3 + t1 - 6 < MAXITEMS + 1) then
          begin
            outtext (99, 27 + (t1 - 1) * 8, Str2 (t3 + t1 - 6));
            outtext (112, 27 + (t1 - 1) * 8, Items [t3 + t1 - 6]. name)
          end;
        blockpagetopage (3, 0, 96, 24, 24, 105, 96, 24);
        ch:=Readkey;
        if ch = #0 then
          ch:=readkey;
        if (ch = #72) and (t3 > 1) then
        begin
          dec (t3);
          playsample ('WALL.VOC')
        end;
        if (ch = #80) and (t3 < MAXITEMS) then
        begin
          inc (t3);
          playsample ('WALL.VOC')
        end;
      until (ch = #27) or (ch = #13);
      usePage (0);
      blockpagetopage (1, 0, 0, 0, 80, 150, 0, 0);
      t1:=2;
      if ch = #13 then
      begin
        if items [t3]. nr <> 12 then
          use_item;
        t1:=2;
        if actmonster [1]. name <> '' then
          t4:=1
        else
          t4:=2;
        darklordhit
      end;
      solidbox (11, 168, 249, 189, 1);
      t1:=2
    end
    else
    if t1 = 3 then
    begin
      usepage (0);
      showstatus (-40);
      t1:=3
    end;
    if t1 = 4 then
    begin
      SolidBox (11, 158, 249, 189, 1);
      TextBoxLine (168, 'Mace tries to flee.. but fails !!');
      delay (500);
      solidbox (11, 158, 249, 189, 1);
      t1:=4
    end
    else
    if t1 = 1 then
    begin
      Treal:=10;
      t3:=0;
      t4:=1;
      ClrKey;
      Repeat
        Repeat
          If (t3 = 0) then Treal:=Treal + 0.4;
          If (t3 = 1) then Treal:=Treal - 0.4;
          If Treal >= 40 then t3:=1;
          If Treal <= 15  then t3:=0;
          If t4 = 1 then begin
            SetPal (252, Round (Treal), 0, 0);
            SetPal (253, 0, 0, 0);
          End else begin
            SetPal (253, Round (Treal), 0, 0);
            SetPal (252, 0, 0, 0);
          End;
          WaitForRetrace;
        Until Keypressed;
        ch:=Readkey;
        If (ch = #32) or (ch = #13) then begin
          PlaySample ('weapon' + weaponcon [weapon]. fnr + 'a.voc');
          BlockPageToPage (0, 3, 0, 0, 80, 200, 0, 0);
          UsePage (0);
          SolidBox (11, 158, 249, 189, 1);
          font. SetFGColor (14);
          TextBoxLine (160, 'Mace strikes...');
          Delay (300);
          font. SetFGColor (15);
          If (random (10) < 1) and (Actmonster [t4]. power * 1.5 > power) and (paralized = 0) then
          begin
            PlaySample ('helihit.voc');
            TextBoxLine (168, Actmonster [t4]. name + ' dodges attack !!');
          End
          else
          begin
            PlaySample ('weapon' + weaponcon [weapon]. fnr + 'b.voc');
            For t2:=1 to 15 do
            begin
              If t4 = 1 then
              begin
                WaitForRetrace;
                SetPal (252, 63, 0, 0);
                WaitForRetrace;
                SetPal (252, 0, 0, 0);
                WaitForRetrace;
              End
              else
              begin
                SetPal (253, 63, 0, 0);
                WaitForRetrace;
                SetPal (253, 0, 0, 0);
                WaitForRetrace;
              End;
              If Random (2) <> 1 then
              begin
                BlockPageToPage (3, 0, 15 + mX [t4], 16, 36, 118, 16 + mX [t4], 16);
                WaitForRetrace;
                BlockPageToPage (3, 0, 16 + mX [t4], 16, 36, 118, 16 + mX [t4], 16);
              End;
            End;
            t1:=Round (Random (Round (power / 2)) + Power / 2) - Actmonster [t4]. defence;
            If t1 < 1 then
              t1:=1;
            If t1 < Actmonster [t4]. life then
              Actmonster [t4]. life:=Actmonster [t4]. life - t1
            else
            begin
              t1:=Actmonster [t4]. life;
              Actmonster [t4]. life:=0;
            End;
            TextBoxLine (168, Actmonster [t4]. name + ' ' + Str2 (t1) + ' damage !!');
          End;
          DarkLordHit;
          ch:=#255;
        End;
      until (ch = #255) or (ch = #27) or Mace_is_a_dead_man;
      SetPal (252, 0, 0, 0);
      SetPal (253, 0, 0, 0);
    end;
    if (t1 > 3) and (t1 <> 255) then
      t1:=1;
  Until (t1 = 255) or (Mace_is_a_dead_man);
  power:=powertmp;
  usepage (1);
  if level < 49 then
    load_pcx (0, 0, 319, 199, 'CASTLE', false)
  else
    load_pcx (0, 0, 319, 199, 'WTOWERG', false);
  if not mace_is_a_dead_man then
  begin
    stopsong;
    if level < 49 then
      loadsong ('MTP\AVALON10.MTP')
    else
      loadsong ('MTP\AVALON31.MTP');
    playsong;
    if level < 49 then
      showscreen (x, y, 0, 0);
    updateinfoscrn
  end;
  darklord:=false
end;

procedure readdata;
begin
  song. filename:='';
  stopsong;
  assign (f, 'SAV\SAVEGAM' + STR2 (t2) + '.SAV');
  reset (f);
  readln (f, direction);
  readln (f, exp);
  readln (f, exp_nextlevel);
  readln (f, life);
  readln (f, maxlife);
  readln (f, money);
  readln (f, power);
  readln (f, defence);
  readln (f, weapon);
  readln (f, shield);
  readln (f, t2);
  fleed:=(t2 = 1);
  for t1:=1 to 40 do
  begin
    readln (f, t2);
    event_happend [t1]:=(t2 = 1)
  end;
  for t1:=1 to 20 do
  begin
    readln (f, objects [t1]. name);
    readln (f, objects [t1]. nr);
  end;
  for t1:=1 to 50 do
  begin
    readln (f, items [t1]. name);
    readln (f, items [t1]. nr);
  end;
  readln (f, touchedcount);
  readln (f, area);
  readln (f, chapter);
  readln (f, level);
  readln (f, x);
  readln (f, y);
  readln (f, monsters_killed);
  readln (f, playing_time);
  close (f);
end;

procedure sucker (mr : integer; suckrate : byte);
var magicpower : integer;
begin
  magicpower:=actmonster [mr]. power - (25 * suckrate) + 1;
  if magicpower < 1 then
    magicpower:=1;
  for t1:=actmonster [mr]. power downto magicpower do
    if actmonster [mr]. power > 0 then
    begin
      inc (power);
      dec (actmonster [mr]. power);
      if actmonster [mr]. name <> '' then
        showmonsterstatus (mr);
      waitforretrace;
      waitforretrace
  end;
end;

procedure powersuck (suckrate : byte);
begin
  playsample ('pwsuck.voc');
  blockpagetopage (0, 3, 0, 0, 80, 120, 0, 0);
  showpage (0);
  for t3:=1 to 8 do
  begin
    t2:=57;
    t1:=56;
    while t1 > 9 do
    begin
      blockpagetopage (0, 0, 8, t1, 76, 1, 8, t1 + 1);
      blockpagetopage (0, 0, 8, t2, 76, 1, 8, t2 - 1);
      dec (t1, t3);
      inc (t2, t3);
    end;
    for t5:=1 to 5 do
      waitforretrace;
  end;
  usepage (0);
  tmpower:=power;
  if actmonster [1]. name <> '' then
    sucker (1, suckrate);
  if actmonster [2]. name <> '' then
    sucker (2, suckrate);
  font. setfgcolor (14);
  textboxline (172, 'Mace sucks ' + Str2 (power - tmpower) + ' power !!');
  delay (400);
  blockpagetopage (3, 0, 0, 0, 80, 120, 0, 0)
end;

procedure showmonsterstatus (m : integer);
begin
  if not darklord then
  begin
    if actmonster [m]. name <> '' then
    begin
      usepage (0);
      solidbox  (16 + mX [m], 116, 155 + mX [m], 132, 1);
      drawframe (16 + mX [m], 116, 155 + mX [m], 132, 15);
      font. setfgcolor (14);
      outtext (18 + mX [m], 118, actmonster [m]. name);
      font. setfgcolor (15);
      outtext (92 + mX [m], 118, 'Life: ' + Str2 (Actmonster [m]. life));
      outtext (18 + mX [m], 126, 'Power: ' + Str2 (Actmonster [m]. power));
      outtext (92 + mX [m], 126, 'Defence: ' + Str2 (Actmonster [m]. defence))
    end
  end
  else
    showdarklordstatus
end;

procedure use_item;
var
  tmpower : word;
  itemchs : integer;

begin
  solidbox (11, 158, 249, 189, 1);
  font. setfgcolor (14);
  textboxline (163, 'Mace uses a ' + items [t3]. name + '...');
  delay (400);
  itemchs:=items [t3]. nr;
  case itemchs of
    01 :
    begin
      showexplosion (5, 25);
      for t1:=1 to 2 do
      begin
        if actmonster [t1]. defence < 100 then
          dec (actmonster [t1]. life, 100 - actmonster [t1]. defence);
        if actmonster [t1]. life < 0 then
          actmonster [t1]. life:=0;
      end;
      if actmonster [1]. name <> '' then
        showmonsterstatus (1);
      if actmonster [2]. name <> '' then
        showmonsterstatus (2);
      ch:=#100
    End;
    02 : begin
      playsample ('THEAL.VOC');
      t2:=life + 100;
      if t2 > maxlife then
        t2:=maxlife;
      for t1:=life to t2 do
      begin
        drawframe (70, 148, 245, 156, 15);
        solidbox (71, 149, 71 + Round (maxlife /  8), 155, 39);
        solidbox (71, 149, 71 + Round (life /  8), 155, 09);
        inc (life);
        if life mod 2 = 0 then
          waitforretrace
      end;
      delay (300);
      ch:=#255;
    end;
    03 : Begin
      PlaySample ('Theal.voc');
      t2:=life + 200;
      If t2 > maxlife then t2:=maxlife;
      For t1:=life to t2 do begin
        DrawFrame (70, 148, 245, 156, 15);
        SolidBox (71, 149, 71 + Round (maxlife /  8), 155, 39);
        SolidBox (71, 149, 71 + Round (life /  8), 155, 09);
        Inc (life);
        if life mod 2 = 0 then WaitForRetrace;
      End;
      Delay (300);
      ch:=#255;
    End;
    04 : Begin
      PlaySample ('Theal.voc');
      t2:=life + 500;
      If t2 > maxlife then t2:=maxlife;
      For t1:=life to t2 do
      begin
        DrawFrame (70, 148, 245, 156, 15);
        SolidBox (71, 149, 71 + Round (maxlife /  8), 155, 39);
        SolidBox (71, 149, 71 + Round (life /  8), 155, 09);
        Inc (life);
        if life mod 2 = 0 then WaitForRetrace;
      End;
      Delay (300);
      ch:=#255;
    End;
    05 : Begin
      ShowExplosion (10, 15);
      For t1:=1 to 2 do begin
        If actmonster [t1]. defence < 200 then
          Dec (actmonster [t1]. life, 200 - actmonster [t1]. defence);
        If actmonster [t1]. life < 0 then
          actmonster [t1]. life:=0;
        If actmonster [t1]. name <> '' then
          ShowMonsterStatus (t1)
      End;
    End;
    06 : Begin
      PlaySample ('med2000.voc');
      t2:=maxlife;
      For t1:=life to t2 do begin
        DrawFrame (70, 148, 245, 156, 15);
        SolidBox (71, 149, 71 + Round (maxlife /  8), 155, 39);
        SolidBox (71, 149, 71 + Round (life /  8), 155, 09);
        Inc (life);
        if life mod 2 = 0 then
          waitforretrace
      End;
      life:=Maxlife;
      Delay (600);
      ch:=#255;
    End;
    07 : begin
      if (monsterfilename = 'rsnake') then
      begin
        textboxline (171, '...but it doesn''t work !!');
        sleep (50)
      end
      else
      begin
        playsample ('miggone.voc');
        sleep (30);
        usepage (0);
        paralized:=4;
      end
    end;
    08 : Begin
      PlaySample ('defpen1.voc');
      UsePage (0);
      For t1:=0 to 255 do GetPal (t1, pl [t1, 1], pl [t1, 2], pl [t1, 3]);
      For t1:=0 to 255 do SetPal (t1, 255, 255, 255);
      For t1:=0 to 255 do for t2:=1 to 3 do pr [t1, t2]:=63;
      For t1:=1 to 64 do begin
        For t2:=0 to 255 do begin
          SetPal (t2, pr [t2, 1], pr [t2, 2], pr [t2, 3]);
          Dec (pr [t2, 1]); If pr [t2, 1] <= pl [t2, 1] then pr [t2, 1]:=pl [t2, 1];
          Dec (pr [t2, 2]); If pr [t2, 2] <= pl [t2, 2] then pr [t2, 2]:=pl [t2, 2];
          Dec (pr [t2, 3]); If pr [t2, 3] <= pl [t2, 3] then pr [t2, 3]:=pl [t2, 3];
        End;
        WaitForRetrace;
      End;
      for t1:=1 to 2 do begin
        Dec (actmonster [t1]. defence, 50);
        If actmonster [t1]. defence > 60000 then
          actmonster [t1]. defence:=0;
        If actmonster [t1]. name <> '' then
          ShowMonsterStatus (t1)
      End
    End;
    09 : Begin
      PlaySample ('defpen2.voc');
      UsePage (0);
      For t1:=0 to 255 do GetPal (t1, pl [t1, 1], pl [t1, 2], pl [t1, 3]);
      For t1:=0 to 255 do SetPal (t1, 255, 255, 255);
      For t1:=0 to 255 do for t2:=1 to 3 do pr [t1, t2]:=63;
      For t1:=1 to 64 do begin
        For t2:=0 to 255 do begin
          SetPal (t2, pr [t2, 1], pr [t2, 2], pr [t2, 3]);
          Dec (pr [t2, 1]); If pr [t2, 1] <= pl [t2, 1] then pr [t2, 1]:=pl [t2, 1];
          Dec (pr [t2, 2]); If pr [t2, 2] <= pl [t2, 2] then pr [t2, 2]:=pl [t2, 2];
          Dec (pr [t2, 3]); If pr [t2, 3] <= pl [t2, 3] then pr [t2, 3]:=pl [t2, 3];
        End;
        WaitForRetrace
      End;
      For t1:=1 to 2 do begin
        Dec (actmonster [t1]. defence, 75);
        If actmonster [t1]. defence > 60000 then
          actmonster [t1]. defence:=0;
        If actmonster [t1]. name <> '' then
          ShowMonsterStatus (t1)
      End;
    End;
    10 :
    if (monsterfilename = 'tracer') or
    (((monsterfilename = 'finalbs') or (monsterfilename = 'finalbs2')) and (actmonster [1]. power < 400)) then
    begin
      textboxline (171, '...but it doesn''t work !!');
      sleep (50)
    end
    else
      powersuck (2);
    11 :
    if (monsterfilename = 'tracer') or
    (((monsterfilename = 'finalbs') or (monsterfilename = 'finalbs2')) and (actmonster [1]. power < 400)) then
    begin
      textboxline (171, '...but it has no effect !!');
      sleep (50)
    end
    else
      powersuck (3);
    12 : Begin
      PlaySample ('hivvir1.voc');
      UsePage (0);
      For t1:=0 to 255 do GetPal (t1, pl [t1, 1], pl [t1, 2], pl [t1, 3]);
      For t1:=0 to 255 do SetPal (t1, 255, 255, 255);
      For t1:=0 to 255 do for t2:=1 to 3 do pr [t1, t2]:=63;
      For t1:=1 to 64 do begin
        For t2:=0 to 255 do begin
          SetPal (t2, pr [t2, 1], pr [t2, 2], pr [t2, 3]);
          Dec (pr [t2, 1]); If pr [t2, 1] <= pl [t2, 1] then pr [t2, 1]:=pl [t2, 1];
          Dec (pr [t2, 2]); If pr [t2, 2] <= pl [t2, 2] then pr [t2, 2]:=pl [t2, 2];
          Dec (pr [t2, 3]); If pr [t2, 3] <= pl [t2, 3] then pr [t2, 3]:=pl [t2, 3];
        End;
        WaitForRetrace;
      End;
      PlaySample ('hivvir2.voc');
      Delay (500);
      if area <> FLD_WTOWER then
        for t1:=1 to 20 do
          monster [t1]. ID:=0
    end;
    13 : mace_is_a_dead_man:=true;
  end;
  remove_item (itemchs);
  usepage (0);
  solidbox (11, 158, 249, 189, 1)
end;

procedure showstatus (spos : integer);
begin
  blockpagetopage (0, 3, spos+100, 16, 51, 105, spos+100, 16);
  solidbox (spos+100, 16, spos+300, 120, 1);
  drawframe (spos+100, 16, spos+300, 120, 15);
  font. setfgcolor (15);
  outtext (spos+114, 24, 'WEAPON:');
  outtext (spos+114, 32, 'SHIELD:');
  font. setfgcolor (14);
  outtext (spos+184, 24, weaponcon [weapon]. name);
  outtext (spos+184, 32, shieldcon [shield]. name);
  font. setfgcolor (15);
  outtext (spos+114, 48, 'GAME PROGRESS:');
  drawframe (spos+184, 47, spos+286, 54, 15);
  solidbox (spos+185, 48, spos+185 + trunc (level / 50 * 100), 53, 12);
  font. setfgcolor (14);
  outtext (spos+187, 48, str2 (trunc (level / 50 * 100)));
  outtext (spos+288, 48, '%');
  font. setfgcolor (15);
  outtext (spos+114, 64, 'POWER:');
  outtext (spos+114, 72, 'DEFENCE:');
  font. setfgcolor (14);
  outtext (spos+184, 64, str2 (power));
  outtext (spos+184, 72, str2 (defence));
  font. setfgcolor (15);
  outtext (spos+114, 88, 'MACE LIFE:');
  if life > maxlife then
    life:=maxlife;
  solidbox (spos+185, 88, spos+185 + trunc (life / maxlife * 100), 93, 09);
  drawframe (spos+184, 87, spos+286, 94, 15);
  font. setfgcolor (14);
  outtext (spos+187, 88, str2 (life) + ' / ' + str2 (maxlife));
  font. setfgcolor (15);
  outtext (spos+114, 104, 'MONEY:');
  outtext (spos+114, 112, 'EXPERIENCE:');
  s:=copy ('000000' + str2 (exp), length (str2 (exp)), 7);
  font. SetFGColor (14);
  outtext (spos+184, 112, s);
  font. setfgcolor (15);
  outtext (spos+224, 112, '/');
  s:=copy ('000000' + str2 (exp_nextlevel), Length (str2 (exp_nextlevel)), 7);
  font. SetFGColor (14);
  outtext (spos+234, 112, s);
  s:=copy ('0000000' + str2 (money), Length (str2 (money)), 8);
  outtext (spos+184, 104, s);
  font. setfgcolor (15);
  outtext (spos+210, 64, 'TOTAL KILLS:');
  outtext (spos+210, 72, 'CHAPTER:');
  font. setfgcolor (14);
  outtext (spos+280, 64, str2 (monsters_killed));
  s:=copy ('0' + Str2 (chapter), length (str2 (chapter)), 3);
  outtext (spos+280, 72, s);
  readkey;
  t2:=120;
  for t1:=16 to 68 do
  begin
    solidhlinex (t1 + 1, spos+100, spos+300, 15);
    solidhlinex (t2 - 1, spos+100, spos+300, 15);
    blockpagetopage (3, 0, spos+100, t1, 51, 1, spos+100, t1);
    blockpagetopage (3, 0, spos+100, t2, 51, 1, spos+100, t2);
    dec (t2);
    if t1 mod 3 = 0 then
    waitforretrace
  end;
  blockpagetopage (3, 0, spos+100, 16, 51, 105, spos+100, 16)
end;

procedure mainmenu;
begin
  t2:=0;
  t5:=0;
  PlaySample ('switch.voc');
  UsePage (3);
  Repeat
    WaitForRetrace;
    DrawFrame (16, 16, 75, 76, 15);
    font. SetFGColor (15);
    SolidBox  (17, 17, 74, 75, 1);
    SolidBox (22, t2 * 8 + 23 + t5, 70, t2 * 8 + 30 + t5, 4);
    OutText (24, 24, 'OBJECTS');
    OutText (24, 32, 'ITEMS');
    OutText (24, 40, 'STATUS');
    OutText (24, 48, 'LOAD GAME');
    OutText (24, 56, 'SAVE GAME');
    OutText (24, 64, 'EXIT');
    BlockPageToPage (3, 0, 16, 16, 15, 61, 24, 24);
    if t5 = 0 then
    begin
      ch:=readkey;
      if ch = #0 then
        ch:=Readkey;
      If (ch = #72) and (t2 > 0) then t5:=-1;
      If (ch = #80) and (t2 < 5) then t5:=1;
    End
    else
    begin
      if t5 > 0 then
        inc (t5)
      else
        dec (t5);
      if (t5 = 8) or (t5 = -8) then
      begin
        if t5 > 0 then
          inc (t2)
        else
          dec (t2);
        if t2 > 5 then
          t2:=0;
        if t2 < 0 then
          t2:=5;
        t5:=0
      end
    end
  until (ch = #13) or (ch = #27);
  if ch = #27 then
    ch:=#240
  else
  begin
    playsample ('switch.voc');
    case t2 of
      5 : begin
        usepage (0);
        drawframe (120, 48, 200, 62, 15);
        solidBox  (121, 49, 199, 61, 1);
        outtext (123, 53, 'EXIT GAME ?  Y/N');
        ch:=Readkey;
        gameover:=false;
        mace_is_a_dead_man:=(Upcase (ch) = 'Y');
        If mace_is_a_dead_man then
        Begin
          song. fading:=8;
          FadeOut
        End
      End;
      0 : begin
        t3:=1;
        repeat
          usepage (3);
          drawframe (96, 25, 190, 127, 15);
          solidbox  (97, 26, 189, 126, 1);
          solidbox (97, 66, 188, 85, 4);
          for t1:=1 to 5 do
          begin
            if (t3 + t1 - 3 > 0) and (t3 + t1 - 3 < 21) then
            begin
              drawframe (99, 27 + (t1 - 1) * 20, 116, 44 + (t1 - 1) * 20, 15);
              if objects [t3 + t1 - 3]. nr <> 0 then
                outtext (118, 34 + (t1 - 1) * 20, objects [t3 + t1 - 3]. name);
              t4:=trunc (objects [t3 + t1 - 3]. nr / 5);
              t5:=objects [t3 + t1 - 3]. nr mod 5;
              blockpagetopage (2, 3, t5 * 16 + 240, t4 * 17, 4, 16, 101, 28 + (t1 - 1) * 20);
            end
          end;
          blockpagetopage (3, 0, 96, 24, 24, 105, 96, 24);
          ch:=readkey;
          if ch = #0 then
            ch:=Readkey;
          if (ch = #72) and (t3 > 1) then
          begin
            dec (t3);
            playsample ('WALL.VOC');
          end;
          if (ch = #80) and (t3 < 20) then
          begin
            inc (t3);
            playsample ('WALL.VOC');
          end;
        until (ch = #27) or (ch = #13);
        if (ch = #13) and (objects [t3]. nr > 0) then
          use_object;
      end;
      1 : begin
        UsePage (3);
        t3:=1;
        repeat
          drawframe (96, 25, 190, 127, 15);
          solidbox  (97, 26, 189, 126, 1);
          solidbox (97, 66, 188, 74, 4);
          for t1:=1 to 12 do
          begin
            if (t3 + t1 - 6 > 0) and (t3 + t1 - 6 < MAXITEMS + 1) then
            begin
              outtext (99, 27 + (t1 - 1) * 8, Str2 (t3 + t1 - 6));
              outtext (112, 27 + (t1 - 1) * 8, Items [t3 + t1 - 6]. name)
            end
          end;
          BlockPageToPage (3, 0, 96, 24, 24, 105, 96, 24);
          ch:=Readkey;
          if ch = #0 then
            ch:=Readkey;
          if (ch = #72) and (t3 > 1) then
          begin
            dec (t3);
            playsample ('WALL.VOC');
          end;
          if (ch = #80) and (t3 < MAXITEMS) then
          begin
            inc (t3);
            playsample ('WALL.VOC');
          end;
        until (ch = #27) or (ch = #13);
        if (ch = #13) and ((items [t3]. nr in [1..4, 6, 12, 13])) then
        begin
          usepage (0);
          use_item;
          updateinfoscrn;
          ch:=#240
        end;
      end;
      2 :
        begin
          usepage (0);
          showstatus (0)
        end;
      4 : Begin
        t2:=1;
        t3:=0;
        font. SetFGColor (15);
        Repeat
          UsePage (3);
          DrawFrame (88, 28, 159, 85, 15);
          SolidBox (89, 29, 158, 84, 1);
          SolidBox (90, 29 + t2 * 8 + t3, 157, 36 + t2 * 8 + t3, 4);
          For t1:=1 to 5 do OutText (97, 30 + t1 * 8, 'SAVE GAME  ' + Str2 (t1));
          BlockPageToPage (3, 0, 88, 27, 18, 59, 88, 28);
          If t3 = 0 then begin
            ch:=Readkey; If ch = #0 then ch:=Readkey;
            If (ch = #72) and (t2 > 1) then t3:= -1;
            If (ch = #80) and (t2 < 5) then t3:=1;
            If ch = #13 then begin
              UsePage (0);
              DrawFrame (120, 48, 220, 62, 15);
              SolidBox  (121, 49, 219, 61, 1);
              OutText (123, 53, 'SAVING GAME DATA...');
              Delay (1000);
              Assign (f, 'SAV\SAVEGAM' + STR2 (t2) + '.SAV');
              ReWrite (f);
              WriteLn (f, direction);
              WriteLn (f, exp);
              WriteLn (f, exp_nextlevel);
              WriteLn (f, life);
              WriteLn (f, maxlife);
              WriteLn (f, money);
              WriteLn (f, power);
              WriteLn (f, defence);
              WriteLn (f, weapon);
              WriteLn (f, shield);
              If fleed then WriteLn (f, 1) else WriteLn (f, 0);
              For t1:=1 to 40 do begin
                If event_happend [t1] then WriteLn (f, 1) else WriteLn (f, 0);
              End;
              For t1:=1 to 20 do begin
                WriteLn (f, Objects [t1]. name);
                WriteLn (f, Objects [t1]. nr)
              End;
              For t1:=1 to 50 do begin
                WriteLn (f, Items [t1]. name);
                WriteLn (f, Items [t1]. nr)
              End;
              WriteLn (f, touchedcount);
              WriteLn (f, area);
              WriteLn (f, chapter);
              WriteLn (f, level);
              WriteLn (f, x);
              WriteLn (f, y);
              WriteLn (f, monsters_killed);
              WriteLn (f, playing_time);
              Close (f);
            End;
          End else begin
            If t3 > 0 then Inc (t3) else Dec (t3);
            WaitForRetrace;
            If (t3 = 8) or (t3 = -8) then begin
              If t3 > 0 then Inc (t2) else Dec (t2);
              t3:=0;
            End;
          End;
        Until (ch = #27) or (ch = #13);
        ch:=#60;
        UpdateInfoScrn;
      End;
      3 : Begin
        t2:=1;
        t3:=0;
        font. SetFGColor (15);
        Repeat
          UsePage (3);
          DrawFrame (88, 28, 159, 85, 15);
          SolidBox (89, 29, 158, 84, 1);
          SolidBox (90, 29 + t2 * 8 + t3, 157, 36 + t2 * 8 + t3, 4);
          For t1:=1 to 5 do
            outtext (97, 30 + t1 * 8, 'LOAD GAME  ' + Str2 (t1));
          BlockPageToPage (3, 0, 88, 27, 18, 59, 88, 28);
          if t3 = 0 then
          begin
            ch:=Readkey;
            If ch = #0 then
              ch:=Readkey;
            if (ch = #72) and (t2 > 1) then
              t3:=-1;
            if (ch = #80) and (t2 < 5) then
              t3:=1;
            if ch = #13 then
            begin
              usepage (0);
              drawframe (120, 48, 220, 62, 15);
              solidbox  (121, 49, 219, 61, 1);
              outtext (123, 53, 'LOADING GAME DATA...');
              delay (1000);
              readdata;
              ch:=#255
            end
          End else begin
            If t3 > 0 then Inc (t3) else Dec (t3);
            WaitForRetrace;
            If (t3 = 8) or (t3 = -8) then begin
              If t3 > 0 then Inc (t2) else Dec (t2);
              t3:=0;
            end
          end
        Until (ch = #27) or (ch = #13) or (ch = #255)
      end
    end
  end
end;

Procedure UpdateInfoScrn;
begin
  UsePage (0);
  SolidBox (10, 145, 250, 190, 1);
  font. SetFGColor (15);
  OutText (12, 150, 'MACE LIFE:');
  DrawFrame (70, 148, 245, 156, 15);
  SolidBox (71, 149, 71 + Round (maxlife /  8), 155, 39);
  SolidBox (71, 149, 71 + Round (life /  8), 155, 09);
  s:=Copy ('000000' + Str2 (exp), Length (Str2 (exp)), 7);
  OutText (12, 162, 'EXP: ');
  font. SetFGColor (14);
  OutText (34, 162, s);
  font. SetFGColor (15);
  OutText (74, 162, '/');
  s:=Copy ('000000' + Str2 (exp_nextlevel), Length (Str2 (exp_nextlevel)), 7);
  font. SetFGColor (14);
  OutText (84, 162, s);
  font. SetFGColor (15);
  OutText (150, 171, 'MONEY:');
  font. SetFGColor (14);
  s:=Copy ('0000000' + Str2 (money), Length (Str2 (money)), 8);
  OutText (183, 171, s);
  font. SetFGColor (15);
  OutText (12, 171, 'POWER:');
  OutText (12, 180, 'DEFENCE:');
  font. SetFGColor (14);
  OutText (60, 171, Str2 (power));
  OutText (60, 180, Str2 (defence));
  font. SetFGColor (15);
  OutText (150, 162, 'CHAPTER:');
  font. SetFGColor (14);
  s:=Copy ('0' + Str2 (chapter), Length (Str2 (chapter)), 3);
  OutText (193, 162, s);
  font. SetFGColor (15);
  OutText (90, 180, 'AREA:');
  font. SetFGColor (14);
  OutText (118, 180, arean [area]. name);
End;

procedure use_object;
begin
  opentextbox;
  Font. SetFGColor (15);
  TextBoxLine (155, 'Mace uses the ' + Objects [t3]. name + '...');
  font. setfgcolor (14);
  Delay (400);
  if (x = 64) and (y = 37) and (objects [t3]. nr = 16) then
  begin
    remove_object (16);
    event_happend [19]:=true;
    field [64, 36]:=38;
    playsample ('bulithit.voc');
    textboxline (163, '...to repair the missing step.');
    blinking_cursor;
    updateinfoscrn
  end
  else
  if (objects [t3]. nr = 2) and (area in [FLD_CAVE, FLD_CAVEMNT, FLD_CAVE2,
  FLD_WATERCAV, FLD_GREYCAVE]) then
  begin
    clrkey;
    solidbox (8, 8, 311, 136, 0);
    playsample ('areas.voc');
    for t1:=0 to 99 do
    begin
      for t2:=0 to 99 do
      begin
        writepixelx ((t1 * 2) + 50, t2 + 16, field [t1, t2]);
        writepixelx ((t1 * 2) + 51, t2 + 16, field [t1, t2])
      end
    end;
    repeat
      solidbox (x * 2 + 49, y + 15, x * 2 + 51, y + 17, 1);
      waitforretrace;
      waitforretrace;
      solidbox (x * 2 + 49, y + 15, x * 2 + 51, y + 17, 14);
      waitforretrace;
    until keypressed;
    ch:=readkey;
    showscreen (x, y, 0, 0)
  end
  else
  if objects [t3]. nr = 6 then
    swiss_watch
  else
  if objects [t3]. nr = 5 then
  begin
    if (area = FLD_Castle1) and ((x = 50) or (x = 51)) and (y = 81) then
      try_to_open_main_door (level)
    else
    if (area = FLD_Castle1) and (x = 37) and (y = 66) and (level = 25) then
    begin
      field [37, 64]:=29;
      field [37, 65]:=30;
      field [37, 66]:=31;
      trans [37, 64]:=29;
      trans [37, 65]:=30;
      playsample ('OPENDOOR.VOC');
      level:=26;
      mace_opens_door_with_master_key;
      showscreen (x, y, 0, 0)
    end
    else
    begin
      showscreen (x, y, 0, 0);
      usepage (0);
      textboxline (163, '...but it''s futile.');
      blinking_cursor
    end;
  end
  else
  if (objects [t3]. nr = 4) and (area = FLD_Castle1) and
     (level = 27) and ((x = 50) or (x = 51)) and (y = 81) then
  begin
    field [50, 79]:=69;
    trans [50, 79]:=69;
    field [51, 79]:=80;
    trans [51, 79]:=80;
    field [50, 80]:=70;
    trans [50, 80]:=70;
    field [51, 80]:=81;
    trans [51, 80]:=81;
    field [50, 81]:=71;
    field [51, 81]:=82;
    level:=28;
    playsample ('opendoor.voc');
    mace_opens_main_door;
  end
  else
  if (objects [t3]. nr = 10) and (area = FLD_Garden) then
    if field [x, y] = 0 then
    begin
      textboxline (163,'...to dig a hole in the ground !');
      direction:=1;
      showscreen (x, y, 0, 0);
      playsample ('bulithit.voc');
      sleep (45);
      playsample ('bulithit.voc');
      field [x, y]:=128;
      if (x = 41) and (y = 93) and (level in [22, 23]) then
      begin
        level:=25;
        object_found ('Master Key', 5, 240, 17, 'discovered!')
      end
    end
    else
    begin
      showscreen (x, y, 0, 0);
      usepage (0);
      textboxline (163, '...but the ground is not soft enough to dig.');
      blinking_cursor
    end
  else
  if (objects [t3]. nr = 14) and (area = FLD_Castle1) and (x = 27) and (y = 90) and not event_happend [14] then
  begin
    field [27, 88]:=29;
    field [27, 89]:=30;
    field [27, 90]:=31;
    trans [27, 88]:=29;
    trans [27, 89]:=30;
    event_happend [14]:=true;
    playsample ('opendoor.voc');
    showscreen (x, y, 0, 0)
  End else If (area = FLD_Forest) and (x = 8) and (y = 30) and not Object_Present (6) and (objects [t3]. nr = 7) then begin
    TextBoxLine (163, 'The Silver Key opens the chest !');
    Delay (200);
    object_found ('Swiss Watch', 6, 240+1*16,17, 'Found...');
    UpdateInfoScrn
  End else if (objects [t3]. nr = 11) and event_happend [5] and (x = 19) and (y = 6) and (area = FLD_Entrance) then begin
    If level < 12 then begin
      TextBoxLine (163, '...but it has no effect !');
      Blinking_cursor
    end
    else
    if not event_happend [27] then
    begin
      MaceTriesToOpenDoor;
      if level = 13 then
        level:=14
    end
    else
    begin
      { Castle doors are opening }
      SolidBox (11, 147, 249, 189, 1);
      OutText (15, 147, '[MACE]');
      Font. SetFGColor (15);
      TextBoxLine (155, 'HYEER GOYH HOMNJEYK !!');
      blinking_cursor;
      SolidBox (11, 155, 249, 189, 1);
      Font.SetFGColor (14);
      ShowScreen (x, y, 0, 0);
      Delay (200);
      UsePage (0);
      TextBoxLine (163, 'The castle door is opening...');
      PlaySample ('cdoor1.voc');
      For t1:=79 downto 32 do begin
        UsePage (0);
        SolidHLineX (t1, 137, 174, 0);
        DrawMace (direction, 0, 0, 0);
        For t2:=1 to 2 do
          waitforretrace;
      End;
      Delay (500);
      UsePage (1);
      Load_PCX (0, 0, 319, 199, 'entranc2', False);
      CellStatus [70]:=0;
      CellStatus [81]:=0;
      CellStatus [69]:=0;
      ShowScreen (x, y, 0, 0);
      UpdateInfoScrn;
      Inc (level);
    End;
  End
  else
  if (x = 57) and (y = 05) and (area = FLD_ENTRANCE) and (Objects [t3]. nr = 13) and not event_happend [6] then
  begin
    event_happend [6]:=True;
    TextBoxLine (163, '...to create a nice big hole in the wall !');
    Delay (400);
    direction:=1;
    ShowScreen (x, y, 0, 0);
    PlaySample ('bulithit.voc');
    Delay (500);
    PlaySample ('bulithit.voc');
    field [57, 4]:=1;
    trans [57, 4]:=142;
    ShowScreen (x, y, 0, 0);
    Delay (200);
    PlaySample ('bulithit.voc');
    field [57, 5]:=5;
    ShowScreen (x, y, 0, 0);
    Delay (600);
    PlaySample ('bulithit.voc');
    Delay (100);
  end
  else
  if (x = 28) and (y = 34) and (area = FLD_CAVE) and (Objects [t3]. nr = 13) and (level < 10) then
  begin
    TextBoxLine (163, '...to chop away the stone !');
    Delay (400);
    field [28, 34]:=99;
    field [28, 35]:=100;
    ShowScreen (x, y, 0, 0);
    PlaySample ('bulithit.voc');
    Delay (300);
    PlaySample ('bulithit.voc');
    Delay (100);
    field [28, 34]:=110;
    field [28, 35]:=111;
    ShowScreen (x, y, 0, 0);
    PlaySample ('bulithit.voc');
    Delay (400);
    field [28, 34]:=121;
    field [28, 35]:=122;
    ShowScreen (x, y, 0, 0);
    PlaySample ('bulithit.voc');
    Delay (400);
    PlaySample ('bulithit.voc');
    field [28, 34]:=132;
    field [28, 35]:=133;
    UpdateInfoScrn;
    level:=10;
  end
  else
  begin
    Font. SetFGColor (14);
    textboxline (163, 'But it''s futile !');
    blinking_cursor
  End;
  UpdateInfoScrn;
  t2:=0;
end;

Procedure DrawMonsters;
Var charx : byte;
Begin
  UsePage (2);
  For t1:=1 to 10 do begin
    If (human [t1]. ID < 255) and (human [t1]. ID > 0) then begin
      Case human [t1]. dir of
        1 : charX:=32;
        2 : charX:=64;
        3 : charX:=00;
        4 : charX:=96;
      End;
      If human [t1]. spritenr = True then
        Inc (charX, 16);
      If (human [t1]. x > x - 10) and (human [t1]. x < x + 10) and
      (human [t1]. y > y - 05) and (human [t1]. y < y + 04) then begin
        t3:=(human [t1]. x - x + 9) * 16 + 8 + human [t1]. xplus;
        t4:=(human [t1]. y - y + 4) * 16 + 8 + human [t1]. yplus;
        GetPic (charX, human [t1]. ID, 16, 16, pict_buffer);
        GetPicMask (pict_buffer, pict_mask);
        CopyScreenToScreenMaskedX (2, charX, human [t1]. ID, 4, 16, t3, t4, 3, pict_mask);
        FreeMem (Pict_Mask, pict_buffer. height * pict_buffer. width);
        FreePic (pict_buffer);
      End;
    End;
  End;
  if level = 50 then
  begin
    for t1:=1 to 20 do
      monster [t1]. ID:=0;
    exit;
  end;
  For t1:=1 to 20 do begin
    If (monster [t1]. ID < 255) and (monster [t1]. ID > 0) then begin
      Case monster [t1]. dir of
        1 : charX:=32;
        2 : charX:=64;
        3 : charX:=00;
        4 : charX:=96;
      End;
      If monster [t1]. spritenr = True then Inc (charX, 16);
      If (monster [t1]. x > x - 10) and (monster [t1]. x < x + 10) and
      (monster [t1]. y > y - 05) and (monster [t1]. y < y + 04) then begin
        t3:=(monster [t1]. x - x + 9) * 16 + 8 + monster [t1]. xplus;
        t4:=(monster [t1]. y - y + 4) * 16 + 8 + monster [t1]. yplus;
        GetPic (charX, monster [t1]. ID, 16, 16, pict_buffer);
        GetPicMask (pict_buffer, pict_mask);
        CopyScreenToScreenMaskedX (2, charX, monster [t1]. ID, 4, 16, t3, t4, 3, pict_mask);
        FreeMem (Pict_Mask, pict_buffer. height * pict_buffer. width);
        FreePic (pict_buffer);
      End;
    End;
  End;
  UsePage (1);
End;

Procedure UpdateMonsters;
Begin
  If (Longint (Ptr ($40, $6c)^) > time1) or (Longint (Ptr ($40, $6c)^) < time1 - 50) then begin
    Inc (waterflow);
    If waterflow > 117 then waterflow:=110;
    UsePage (0);
    If ((area <= FLD_WEAPONS) or (area = FLD_ALIENVIL) or event_happend [8]) and (life < maxlife) then begin
      Inc (life, 2);
      SolidBox (71, 149, 71 + Round (life /  8), 155, 09);
    End;
    time1:=Longint (Ptr ($40, $6c)^) + 2;
    If not ((area >= FLD_Castle1) and (area <= FLD_Castle3) or (area = FLD_GARDEN) or (area = FLD_WTOWER)) then Inc (time1, 1);
    For t1:=1 to 20 do begin
      If (monster [t1]. ID > 0) and (monster [t1]. ID < 255) then begin
        If (monster [t1]. xplus <> 0) or (monster [t1]. yplus <> 0) then begin
          If (monster [t1]. dir = 1) then begin
            If (area = FLD_Water) and (monster [t1]. y > 11) then Dec (monster [t1]. y);
            If area <> FLD_Water then Dec (monster [t1]. y);
          End;
          If monster [t1]. dir = 2 then Inc (monster [t1]. x);
          If (monster [t1]. dir = 3) then begin
            If (monster [t1]. y < 51) and (area = FLD_Water) then Inc (monster [t1]. y);
            If area <> FLD_Water then Inc (monster [t1]. y);
          End;
          If monster [t1]. dir = 4 then Dec (monster [t1]. x);
          monster [t1]. xplus:=0; monster [t1]. yplus:=0;
        End else begin
          t2:=0;
          If (monster [t1]. x > x - 6) and (monster [t1]. x < x + 6) and
          (monster [t1]. y > y - 6) and (monster [t1]. y < y + 6) then begin
            If (monster [t1]. x < x) and (CellStatus [field [monster [t1]. x + 1, monster [t1]. y]] = 0) then begin
              monster [t1]. yplus:=0; monster [t1]. xplus:=8;
              monster [t1]. dir:=2;
              t2:=1;
            End;
            If (monster [t1]. y < y) and (CellStatus [field [monster [t1]. x, monster [t1]. y + 1]] = 0) then begin
              monster [t1]. yplus:=8; monster [t1]. xplus:=0;
              monster [t1]. dir:=3;
              t2:=1;
            End;
            If (monster [t1]. x > x) and (CellStatus [field [monster [t1]. x - 1, monster [t1]. y]] = 0) then begin
              monster [t1]. yplus:=0; monster [t1]. xplus:=-8;
              monster [t1]. dir:=4;
              t2:=1;
            End;
            If (monster [t1]. y > y) and (CellStatus [field [monster [t1]. x, monster [t1]. y - 1]] = 0) then begin
              monster [t1]. yplus:=-8; monster [t1]. xplus:=0;
              monster [t1]. dir:=1;
              t2:=1;
            End;
          End;
          If t2 = 0 then begin
            t2:=Random (4);
            If t2 = 0 then t2:=4;
            If (t2 = 1) and (CellStatus [field [monster [t1]. x, monster [t1]. y - 1]] = 0) then begin
              monster [t1]. yplus:=-8; monster [t1]. xplus:=0;
              monster [t1]. dir:=1;
            End;
            If (t2 = 2) and (CellStatus [field [monster [t1]. x + 1, monster [t1]. y]] = 0) then begin
              monster [t1]. xplus:=8; monster [t1]. yplus:=0;
              monster [t1]. dir:=2;
            End;
            If (t2 = 3) and (CellStatus [field [monster [t1]. x, monster [t1]. y + 1]] = 0) then begin
              monster [t1]. yplus:=8; monster [t1].xplus:=0;
              monster [t1]. dir:=3;
            End;
            If (t2 = 4) and (CellStatus [field [monster [t1]. x - 1, monster [t1]. y]] = 0) then begin
              monster [t1]. xplus:=-8; monster [t1]. yplus:=0;
              monster [t1]. dir:=4;
            End;
          End;
        End;
      End;
    End;
    For t1:=1 to 20 do begin
      If monster [t1]. spritenr = True then monster [t1]. spritenr:=False else monster [t1]. spritenr:=True;
    End;
  End;
  If (Longint (Ptr ($40, $6c)^) > time2) then begin
    time2:=Longint (Ptr ($40, $6c)^) + 5;
    For t1:=1 to 10 do begin
      If (human [t1]. ID > 0) and (human [t1]. ID < 255) then begin
        If (human [t1]. xplus <> 0) or (human [t1]. yplus <> 0) then begin
          If human [t1]. dir = 1 then Dec (human [t1]. y, 1);
          If human [t1]. dir = 2 then Inc (human [t1]. x, 1);
          If human [t1]. dir = 3 then Inc (human [t1]. y, 1);
          If human [t1]. dir = 4 then Dec (human [t1]. x, 1);
          human [t1]. xplus:=0; human [t1]. yplus:=0;
        End else begin
          t2:=Random (4);
          If t2 = 0 then t2:=4;
          If (t2 = 1) and (CellStatus [field [human [t1]. x, human [t1]. y - 1]] = 0) then begin
            human [t1]. yplus:=-8; human [t1]. xplus:=0;
            human [t1]. dir:=1;
          End;
          If (t2 = 2) and (CellStatus [field [human [t1]. x + 1, human [t1]. y]] = 0) then begin
            human [t1]. xplus:=8; human [t1]. yplus:=0;
            human [t1]. dir:=2;
          End;
          If (t2 = 3) and (CellStatus [field [human [t1]. x, human [t1]. y + 1]] = 0) then begin
            human [t1]. yplus:=8; human [t1].xplus:=0;
            human [t1]. dir:=3;
          End;
          If (t2 = 4) and (CellStatus [field [human [t1]. x - 1, human [t1]. y]] = 0) then begin
            human [t1]. xplus:=-8; human [t1]. yplus:=0;
            human [t1]. dir:=4;
          End;
        End;
      End;
    End;
    For t1:=1 to 10 do begin
      If human [t1]. spritenr = True then human [t1]. spritenr:=False else human [t1]. spritenr:=True;
    End;
  End;
End;

Procedure ShowScreen (x, y, xplus, yplus : integer);
var
  t1, t2, t3, t4 : integer;
Begin
  start_timer (1);
  if ((chapter = 0) and (level = 01)) or
     ((chapter = 1) and (level = 07)) or
     ((chapter = 2) and (level = 20)) or
     ((chapter = 3) and (level = 28)) or
     ((chapter = 4) and (level = 41)) or
     ((chapter = 5) and (level = 48)) then
  begin
    inc (chapter);
    show_chapter;
    if level = 0 then
      level:=1;
    usepage (0)
  end;
  if candle_count = 0 then
  begin
    if candle then
      candle:=false
    else
      candle:=true;
    candle_count:=5;
  End
  else
    dec (candle_count);
  UsePage (1);
  If Area in [FLD_CAVE, FLD_CAVE2, FLD_CAVEMNT] then begin
    t4:=x - 3;
    t5:=x + 3;
  End else begin
    t4:=x - 9;
    t5:=x + 9;
  End;
  inc (cloud_x1, 1);
  if cloud_x1 > 302 then
    cloud_x1:=0;
  if cloud_x1 mod 2 = 0 then
    inc (cloud_x2, 1);
  if cloud_x2 > 302 then
    cloud_x2:= 0;
  if area = FLD_WTOWER then
  begin
    if xplus = 1 then
    begin
      blockpagetopage (2, 3, 0, 118, (304 - cloud_x1) div 4, 81, 00 + cloud_x1, 08);
      blockpagetopage (2, 3, 304 - cloud_x1, 118, cloud_x1 div 4, 81, 00, 08);
      blockpagetopage (2, 3, 0, 118, (304 - cloud_x2) div 4, 81, 00 + cloud_x2, 84);
      blockpagetopage (2, 3, 304 - cloud_x2, 118, cloud_x2 div 4, 81, 00, 84)
    end
    else
    if xplus = 2 then
    begin
      blockpagetopage (2, 3, 0, 118, (304 - cloud_x1) div 4, 81, 16 + cloud_x1, 08);
      blockpagetopage (2, 3, 304 - cloud_x1, 118, cloud_x1 div 4, 81, 16, 08);
      blockpagetopage (2, 3, 0, 118, (304 - cloud_x2) div 4, 81, 16 + cloud_x2, 84);
      blockpagetopage (2, 3, 304 - cloud_x2, 118, cloud_x2 div 4, 81, 16, 84)
    end
    else
    if yplus = 1 then
    begin
      blockpagetopage (2, 3, 0, 118, (304 - cloud_x1) div 4, 81, 08 + cloud_x1, 00);
      blockpagetopage (2, 3, 304 - cloud_x1, 118, cloud_x1 div 4, 81, 08, 00);
      blockpagetopage (2, 3, 0, 118, (304 - cloud_x2) div 4, 81, 08 + cloud_x2, 76);
      blockpagetopage (2, 3, 304 - cloud_x2, 118, cloud_x2 div 4, 81, 08, 76)
    end
    else
    if yplus = 2 then
    begin
      blockpagetopage (2, 3, 0, 118, (304 - cloud_x1) div 4, 81, 08 + cloud_x1, 16);
      blockpagetopage (2, 3, 304 - cloud_x1, 118, cloud_x1 div 4, 81, 08, 16);
      blockpagetopage (2, 3, 0, 118, (304 - cloud_x2) div 4, 81, 08 + cloud_x2, 92);
      blockpagetopage (2, 3, 304 - cloud_x2, 118, cloud_x2 div 4, 81, 08, 92)
    end
    else
    begin
      blockpagetopage (2, 3, 0, 118, (304 - cloud_x1) div 4, 81, 08 + cloud_x1, 08);
      blockpagetopage (2, 3, 304 - cloud_x1, 118, cloud_x1 div 4, 81, 08, 08);
      blockpagetopage (2, 3, 0, 118, (304 - cloud_x2) div 4, 81, 08 + cloud_x2, 84);
      blockpagetopage (2, 3, 304 - cloud_x2, 118, cloud_x2 div 4, 81, 08, 84)
    end
  end;
  if (area = FLD_WTOWER) then
  begin
    usepage (3);
    solidbox (0, 170, 320, 185, 125);
    solidbox (304, 0, 319, 199, 125);
    usepage (1)
  end;
  for t1:=t4 to t5 do
    for t2:=y - 4 to y + 3 do
    begin
      number:=Field [t1, t2];
      if (number = 1) and (area = FLD_GARDEN) then
        number:=waterflow;
      if (number = 63) and (area in [FLD_DUNGEON..FLD_CASTLE3, FLD_GREYCAVE, FLD_VILLAGE, FLD_DARKROOM, FLD_WTOWER]) then
        if candle then
          number:=64;
      x_cell:=Trunc (number / 11);
      y_cell:=number mod 11;
      x_cell:=x_cell * 16 + (x_cell * 4);
      y_cell:=y_cell * 17;
      if not ((area = FLD_WTOWER) and (number < 2)) then
        blockpagetopage (1, 3, x_cell, y_cell, 4, 16, ((t1 - x) * 16) + 152, ((t2 - y) * 16 + 72));
    end;
  If lee_walks > 0 then
    drawlee;
  drawmonsters;
  DrawMace (direction, xplus, yplus, 3);
  for t1:=x - 9 to x + 9 do For t2:=y - 4 to y + 3 do
  begin
    number:=Trans [t1, t2];
    if number > 1 then
    begin
      x_cell:=Trunc (number / 11);
      y_cell:=number mod 11;
      x_cell:=x_cell * 16 + (x_cell * 4);
      y_cell:=y_cell * 17;
      GetPic (x_cell, y_cell, 16, 16, pict_buffer);
      GetPicMask (pict_buffer, pict_mask);
      CopyScreenToScreenMaskedX (1, x_cell, y_cell, 4, 16, ((t1 - x) * 16) + 152, ((t2 - y) * 16) + 72, 3, pict_mask);
      FreeMem (Pict_Mask, pict_buffer. height * pict_buffer. width);
      FreePic (pict_buffer)
    end
  end;
  If xplus = 1 then begin
    UsePage (1);
    t1:=x - 10;
    For t2:=y - 4 to y + 3 do begin
      number:=Field [t1, t2];
      x_cell:=Trunc (number / 11);
      y_cell:=number mod 11;
      x_cell:=x_cell * 16 + (x_cell * 4);
      y_cell:=y_cell * 17;
      if not ((area = FLD_WTOWER) and (number < 2)) then
        BlockPageToPage (1, 3, x_cell, y_cell, 4, 16, ((t2 - y) * 16) + 152, 170);
      number:=Trans [t1, t2];
      If number > 2 then begin
        x_cell:=Trunc (number / 11);
        y_cell:=number mod 11;
        x_cell:=x_cell * 16 + (x_cell * 4);
        y_cell:=y_cell * 17;
        GetPic (x_cell, y_cell, 16, 16, pict_buffer);
        GetPicMask (pict_buffer, pict_mask);
        CopyScreenToScreenMaskedX (1, x_cell, y_cell, 4, 16, ((t2 - y) * 16) + 152, 170, 3, pict_mask);
        FreeMem (Pict_Mask, pict_buffer. height * pict_buffer. width);
        FreePic (pict_buffer);
      End;
      BlockPageToPage (3, 3, ((t2 - y) * 16) + 160, 170, 2, 16, 0, ((t2 - y) * 16 + 72));
    End;
    If Area in [FLD_CAVE, FLD_CAVE2, FLD_CAVEMNT] then begin
      UsePage (3);
      SolidBox (104, 0, 200, 40, 16);
      SolidBox (104, 113, 200, 153, 16);
      SolidBox (0, 0, 104, 145, 16);
      SolidBox (200, 0, 319, 145, 16);
      UsePage (1);
      For t1:=0 to 5 do for t2:=0 to 4 do begin
        GetPic (t1 * 16, t2 * 16 + 109, 16, 16, pict_buffer);
        GetPicMask (pict_buffer, pict_mask);
        CopyScreenToScreenMaskedX (1, t1 * 16, t2 * 16 + 109, 4, 16, t1 * 16 + 104, t2 * 16 + 36, 3, pict_mask);
        FreeMem (Pict_Mask, pict_buffer. height * pict_buffer. width);
        FreePic (pict_buffer);
      End;
    End;
    BlockPageToPage (3, 0, 0, 8, 76, 128, 8, 8);
  End;
  If xplus = 2 then begin
    UsePage (1);
    t1:=x + 10;
    For t2:=y - 4 to y + 3 do begin
      number:=Field [t1, t2];
      x_cell:=Trunc (number / 11);
      y_cell:=number mod 11;
      x_cell:=x_cell * 16 + (x_cell * 4);
      y_cell:=y_cell * 17;
      if not ((area = FLD_WTOWER) and (number < 2)) then
        BlockPageToPage (1, 3, x_cell, y_cell, 4, 16, ((t2 - y) * 16) + 152, 170);
      number:=Trans [t1, t2];
      If number > 2 then begin
        x_cell:=Trunc (number / 11);
        y_cell:=number mod 11;
        x_cell:=x_cell * 16 + (x_cell * 4);
        y_cell:=y_cell * 17;
        GetPic (x_cell, y_cell, 16, 16, pict_buffer);
        GetPicMask (pict_buffer, pict_mask);
        CopyScreenToScreenMaskedX (1, x_cell, y_cell, 4, 16, ((t2 - y) * 16) + 152, 170, 3, pict_mask);
        FreeMem (Pict_Mask, pict_buffer. height * pict_buffer. width);
        FreePic (pict_buffer);
      End;
      BlockPageToPage (3, 3, ((t2 - y) * 16) + 152, 170, 2, 16, 312, ((t2 - y) * 16 + 72));
    End;
    If Area in [FLD_CAVE, FLD_CAVE2, FLD_CAVEMNT] then begin
      UsePage (3);
      SolidBox (120, 0, 216, 40, 16);
      SolidBox (120, 113, 216, 153, 16);
      SolidBox (0, 0, 120, 145, 16);
      SolidBox (216, 0, 319, 145, 16);
      UsePage (1);
      For t1:=0 to 5 do for t2:=0 to 4 do begin
        GetPic (t1 * 16, t2 * 16 + 109, 16, 16, pict_buffer);
        GetPicMask (pict_buffer, pict_mask);
        CopyScreenToScreenMaskedX (1, t1 * 16, t2 * 16 + 109, 4, 16, t1 * 16 + 120, t2 * 16 + 36, 3, pict_mask);
        FreeMem (Pict_Mask, pict_buffer. height * pict_buffer. width);
        FreePic (pict_buffer);
      End;
    End;
    BlockPageToPage (3, 0, 16, 8, 76, 128, 8, 8);
  End;
  If yplus = 1 then begin
    UsePage (1);
    t2:=y - 5;
    For t1:=x - 9 to x + 9 do begin
      number:=Field [t1, t2];
      x_cell:=Trunc (number / 11);
      y_cell:=number mod 11;
      x_cell:=x_cell * 16 + (x_cell * 4);
      y_cell:=y_cell * 17;
      if not ((area = FLD_WTOWER) and (number < 2)) then
        BlockPageToPage (1, 3, x_cell, y_cell, 4, 16, ((t1 - x) * 16) + 152, 170);
      number:=Trans [t1, t2];
      If number > 2 then begin
        x_cell:=Trunc (number / 11);
        y_cell:=number mod 11;
        x_cell:=x_cell * 16 + (x_cell * 4);
        y_cell:=y_cell * 17;
        GetPic (x_cell, y_cell, 16, 16, pict_buffer);
        GetPicMask (pict_buffer, pict_mask);
        CopyScreenToScreenMaskedX (1, x_cell, y_cell, 4, 16, ((t1 - x) * 16) + 152, 170, 3, pict_mask);
        FreeMem (Pict_Mask, pict_buffer. height * pict_buffer. width);
        FreePic (pict_buffer);
      End;
    End;
    BlockPageToPage (3, 3, 8, 178, 76, 8, 8, 0);
    If Area in [FLD_CAVE, FLD_CAVE2, FLD_CAVEMNT] then begin
      UsePage (3);
      SolidBox (112, 0, 208, 32, 16);
      SolidBox (112, 105, 208, 153, 16);
      SolidBox (0, 0, 112, 145, 16);
      SolidBox (208, 0, 311, 145, 16);
      UsePage (1);
      For t1:=0 to 5 do for t2:=0 to 4 do begin
        GetPic (t1 * 16, t2 * 16 + 109, 16, 16, pict_buffer);
        GetPicMask (pict_buffer, pict_mask);
        CopyScreenToScreenMaskedX (1, t1 * 16, t2 * 16 + 109, 4, 16, t1 * 16 + 112, t2 * 16 + 28, 3, pict_mask);
        FreeMem (Pict_Mask, pict_buffer. height * pict_buffer. width);
        FreePic (pict_buffer);
      End;
    End;
    BlockPageToPage (3, 0, 8, 0, 76, 128, 8, 8);
  End;
  If yplus = 2 then begin
    UsePage (1);
    t2:=y + 4;
    For t1:=x - 9 to x + 9 do begin
      number:=Field [t1, t2];
      x_cell:=Trunc (number / 11);
      y_cell:=number mod 11;
      x_cell:=x_cell * 16 + (x_cell * 4);
      y_cell:=y_cell * 17;
      if not ((area = FLD_WTOWER) and (number < 2)) then
        BlockPageToPage (1, 3, x_cell, y_cell, 4, 16, ((t1 - x) * 16) + 152, 136);
      number:=Trans [t1, t2];
      If number > 2 then begin
        x_cell:=Trunc (number / 11);
        y_cell:=number mod 11;
        x_cell:=x_cell * 16 + (x_cell * 4);
        y_cell:=y_cell * 17;
        GetPic (x_cell, y_cell, 16, 16, pict_buffer);
        GetPicMask (pict_buffer, pict_mask);
        CopyScreenToScreenMaskedX (1, x_cell, y_cell, 4, 16, ((t1 - x) * 16) + 152, 136, 3, pict_mask);
        FreeMem (Pict_Mask, pict_buffer. height * pict_buffer. width);
        FreePic (pict_buffer);
      End;
    End;
    If Area in [FLD_CAVE, FLD_CAVE2, FLD_CAVEMNT] then begin
      UsePage (3);
      SolidBox (112, 0, 208, 48, 16);
      SolidBox (112, 121, 208, 153, 16);
      SolidBox (0, 0, 112, 153, 16);
      SolidBox (208, 0, 311, 153, 16);
      UsePage (1);
      For t1:=0 to 5 do for t2:=0 to 4 do begin
        GetPic (t1 * 16, t2 * 16 + 109, 16, 16, pict_buffer);
        GetPicMask (pict_buffer, pict_mask);
        CopyScreenToScreenMaskedX (1, t1 * 16, t2 * 16 + 109, 4, 16, t1 * 16 + 112, t2 * 16 + 44, 3, pict_mask);
        FreeMem (Pict_Mask, pict_buffer. height * pict_buffer. width);
        FreePic (pict_buffer)
      End
    End;
    BlockPageToPage (3, 0, 8, 16, 76, 128, 8, 8);
  End;
  If (xplus = 0) and (yplus = 0) then begin
    If Area in [FLD_CAVE, FLD_CAVE2, FLD_CAVEMNT] then begin
      UsePage (3);
      SolidBox (112, 0, 208, 40, 16);
      SolidBox (112, 113, 208, 153, 16);
      SolidBox (0, 0, 112, 153, 16);
      SolidBox (208, 0, 311, 153, 16);
      UsePage (1);
      For t1:=0 to 5 do for t2:=0 to 4 do begin
        GetPic (t1 * 16, t2 * 16 + 109, 16, 16, pict_buffer);
        GetPicMask (pict_buffer, pict_mask);
        CopyScreenToScreenMaskedX (1, t1 * 16, t2 * 16 + 109, 4, 16, t1 * 16 + 112, t2 * 16 + 36, 3, pict_mask);
        FreeMem (Pict_Mask, pict_buffer. height * pict_buffer. width);
        FreePic (pict_buffer)
      End
    End;
    BlockPageToPage (3, 0, 8, 8, 76, 128, 8, 8);
  end;
  wait_for_timer (false)
End;

procedure object_found (o_name   : string;
                        o_number : byte;
                        o_x      : word;
                        o_y      : word;
                        o_taken  : string);
begin
  usepage (0);
  playsample ('Tbeep2.voc');
  solidbox (119, 50, 199, 72, 0);
  drawframe (119, 50, 199, 72, 15);
  blockpagetopage (2, 0, o_x, o_y, 4, 16, 124, 52);
  font. SetfgColor (14);
  outtext (142, 55, o_name);
  font. setfgcolor (15);
  OutText (142, 63, o_taken);
  clrkey;
  delay (1000);
  add_object (o_name, o_number);
  ch:=Readkey
end;

procedure reorganise_objects;
var t1, t2 : byte;
begin
  for t1:=20 downto 2 do
    if objects [t1]. nr <> 0 then
      if objects [t1 - 1]. nr = 0 then
        for t2:=t1 to 20 do
        begin
          objects [t2 - 1]:=objects [t2];
          objects [t2]. nr:=0;
          objects [t2]. name:=''
        end
end;

procedure add_object (objectsname : string; objectsnr : byte);
begin
  reorganise_objects;
  t4:=0;
  for t5:=1 to 20 do
    if (Objects [t5]. nr = 0) and (t4 = 0) then
    begin
      objects [t5]. name:=objectsname;
      objects [t5]. nr:=objectsnr;
      t4:=1
    end
end;

procedure remove_object (objectsnr : Byte);
Begin
  t4:=0;
  for t5:=1 to 20 do
    if (objects [t5]. nr) = (objectsnr) then
    begin
      objects [t5]. nr:=0;
      objects [t5]. name:= '';
      t4:=1
    end;
  reorganise_objects
end;

function object_present (objectsnr : Byte) : boolean;
begin
  object_present:=false;
  for t5:=1 to 20 do
    if objects [t5]. nr = objectsnr then
      object_present:=true
end;

procedure reorganise_items;
var t1, t2 : byte;
begin
  for t1:=MAXITEMS downto 2 do
    if items [t1]. nr <> 0 then
      if items [t1 - 1]. nr = 0 then
        for t2:=t1 to MAXITEMS do
        begin
          items [t2 - 1]:=items [t2];
          items [t2]. nr:=0;
          items [t2]. name:=''
        end
end;

Procedure Add_Item (itemname : String; itemnr : Byte);
Begin
  reorganise_items;
  t4:=0;
  For t5:=1 to MAXITEMS do begin
    If (Items [t5]. nr = 0) and (t4 = 0) then begin
      Items [t5]. name:=itemname;
      Items [t5]. nr:=itemnr;
      t4:=1
    End
  End
End;

procedure remove_item (itemnr : byte);
begin
  t5:=1;
  while t5 < MAXITEMS do
  begin
    if items [t5]. nr = itemnr then
    begin
      items [t5]. nr:=0;
      items [t5]. name:= '';
      t5:=MAXITEMS
    end
    else
      inc (t5)
  end;
  reorganise_items
end;

Function Item_Present (itemnr : Byte) : Boolean;
Begin
  item_present:=false;
  For t5:=1 to MAXITEMS do
    if Items [t5]. nr = itemnr then
      item_present:=true
End;

procedure drawmysticbox (x1, y1, x2, y2, color : word);
var xx1, yy1, xx2, yy2 : real;
begin
  xx1:=0;
  yy1:=0;
  xx2:=319;
  yy2:=199;
  while (xx1 < x1) do
  begin
    drawframe (trunc (xx1), trunc (yy1), trunc (xx2), trunc (yy2), 0);
    xx1:=xx1 + 6;
    yy1:=yy1 + (y1 / x1) * 6;
    xx2:=xx2 - ((319 - x2) / x1) * 6;
    yy2:=yy2 - ((199 - y2) / x1) * 6;
    drawframe (trunc (xx1), trunc (yy1), trunc (xx2), trunc (yy2), color);
    waitforretrace;
  end;
  drawframe (trunc (xx1), trunc (yy1), trunc (xx2), trunc (yy2), 0);
  drawframe (x1, y1, x2, y2, color)
end;

procedure mace_opens_door_with_master_key;
begin
  usepage (0);
  textboxline (163, 'The Master Key opens the door...');
  blinking_cursor;
  solidbox (11, 147, 249, 189, 1);
  outtext (15, 147, '[MACE]');
  font. setFGColor (15);
  textboxLine (155, 'So that''s what this key was for !');
  blinking_cursor
end;

procedure mace_opens_main_door;
var tmpsong : string [40];
begin
  while song. playing do
    song. fading:=8;
  tmpsong:=song. filename;
  loadsong ('MTP\AVALON12.MTP');
  playsong;
  usepage (0);
  textboxline (163, 'The Access-card opens the main door !');
  sleep (100);
  solidbox (11, 147, 249, 189, 1);
  outtext (15, 147, '[MACE]');
  font. setFGColor (15);
  textboxLine (155, 'Dark Lord... here I come !');
  blinking_cursor;
  while song. playing do
    song. fading:=8;
  loadsong (tmpsong);
  playsong
end;

procedure try_to_open_main_door (level : byte);
begin
  textboxline (163, 'But it doesn''t work, there is no key-hole !');
  blinking_cursor;
  solidbox (11, 147, 249, 189, 1);
  outtext (15, 147, '[MACE]');
  font. setFGColor (15);
  if level < 27 then
  begin
    textboxLine (155, 'What !? Was REDNAEL lying ?');
    textboxline (163, 'I can''t believe it !')
  end
  else
  begin
    textboxline (155, 'mmm...');
    textboxline (163, 'Maybe I should try the access-card...')
  end;
  blinking_cursor
end;

procedure start_timer (timeticks : LongInt);
begin
  timer:=longint (ptr ($40, $6c)^) + timeticks
end;

procedure wait_for_timer (key : boolean);
begin
  if key then
    repeat until (longint (ptr ($40, $6c)^) >= timer) or (longint (ptr ($40, $6c)^) < timer - 5000) or keypressed
  else
    repeat until (longint (ptr ($40, $6c)^) >= timer) or (longint (ptr ($40, $6c)^) < timer - 5000)
end;

procedure fadegamescreen;
begin
  showpage (0);
  usepage (0);
  for t1:=0 to 15 do
  begin
    t2:=8;
    while t2 < 136 do
    begin
      solidhlinex (t1 + t2, 8, 311, 0);
      inc (t2, 16)
    end;
    show_loading;
    waitforretrace
  end;
  solidbox (120, 48, 220, 62, 0)
end;

procedure show_chapter;
var tempsfm : string [40];
begin
  clrkey;
  song. fading:=8;
  tempsfm:=song. filename;
  fadegamescreen;
  while song. playing do
    song. fading:=8;
  stopsong;
  loadsong ('MTP\AVALON01.MTP');
  playsong;
  usepage (3);
  load_pcx (0, 0, 320, 200, 'CHAPTERS', false);
  usepage (0);
  blockpagetopage (3, 0, 0, 0, 40, 50, 90, 50);
  blockpagetopage (3, 0, (chapter - 1) * 42, 51, 10, 32, 194, 50);
  start_timer (120);
  wait_for_timer (false);
  stopsong;
  loadsong (tempsfm);
  playsong;
  fadegamescreen;
end;

Procedure StringFellowHawk (charnr : Byte);
Begin
  usepage (0);
  if ch <> #255 then
  begin
    ShowScreen (x, y, 0, 0);
    OpenTextBox;
  end
  else
  begin
    solidbox (11, 146, 249, 189, 1);
    drawframe (10, 145, 250, 190, 15)
  end;
  ch:=#0;
  Assign (f, 'TDF\' + txtfile [charnr] + '.TDF');
  Reset (f);
  t3:=0;
  Repeat
    ReadLn (f, s);
    If s = '*' then begin
      ReadLn (f, t1);
      ReadLn (f, t2);
      If (level >= t1) and (level <= t2) then t3:=1;
    End
  Until t3 = 1;
  Repeat
    font. SetFGColor (14);
    ReadLn (f, s); OutText (15, 147, s);
    For t1:=1 to Length (s) do If Copy (s, t1, 1) = 'Û' then begin t4:=0; t5:=t1; end;
    font. SetFGColor (15);
    Delay (100);
    t5:=0;
    ReadLn (f, s); TextBoxLine (155, s);
    For t1:=1 to Length (s) do If Copy (s, t1, 1) = 'Û' then begin t4:=1; t5:=t1; end;
    ReadLn (f, s); TextBoxLine (163, s);
    For t1:=1 to Length (s) do If Copy (s, t1, 1) = 'Û' then begin t4:=2; t5:=t1; end;
    ReadLn (f, s); TextBoxLine (171, s);
    For t1:=1 to Length (s) do If Copy (s, t1, 1) = 'Û' then begin t4:=3; t5:=t1; end;
    ReadLn (f, s);
    ch:=#0;
    If s = '&' then begin
      { Menu YES / NO }
      t1:=1;
      Repeat
        If t1 = 1 then begin
          SolidBox (15, 171, 35, 177, 13);
          OutText (18, 172, 'YES');
          SolidBox (40, 171, 60, 177, 1);
          OutText (43, 172, 'NO');
        End else begin
          SolidBox (15, 171, 35, 177, 1);
          OutText (18, 172, 'YES');
          SolidBox (40, 171, 60, 177, 13);
          OutText (43, 172, 'NO');
        End;
        ch:=Readkey;
        If ch = #0 then ch:=Readkey;
        If ch = #75 then t1:=1;
        If ch = #77 then t1:=2;
        PlaySample ('wall.voc');
      Until (ch = #13) or (ch = #32);
      PlaySample ('switch.voc');
      ch:=#255;
      Inc (level);
      If t1 = 1 then
        Inc (level)
    End;
    If ch <> #255 then begin
      TextBoxLine (179, s);
      For t1:=1 to Length (s) do If Copy (s, t1, 1) = 'Û' then begin t4:=4; t5:=t1; end;
      ReadLn (f, s);
      t3:=1;
      Repeat
        If (Longint (Ptr ($40, $6c)^) / 2 = Round (LongInt (Ptr ($40, $6c)^) / 2)) then begin
          If t2 = 0 then begin
            t2:=1;
            If t3 = 1 then t3:=15 else t3:=1;
              SolidBox (t5 * 5 + 11, t4 * 8 + 148, t5 * 5 + 15, t4 * 8 + 152, t3);
            End
          End else t2:=0;
        Until Keypressed;
      ch:=Readkey;
      SolidBox (11, 146, 249, 189, 1)
    End;
  Until (s = '*') or (ch = #255);
  Close (f);
  if ch <> #255 then
    updateinfoscrn
End;

Procedure MaceTriesToOpenDoor;
Begin
  SolidBox (11, 147, 249, 189, 1);
  Font. SetFGColor (14);
  OutText (15, 147, '[MACE]');
  Font. SetFGColor (15);
  TextBoxLine (155, '...EEERRRHHH OOORRRHHH HMMMMMJJJ !!');
  Blinking_cursor;
  SolidBox (11, 155, 249, 189, 1);
  Font.SetFGColor (15);
  TextBoxLine (155, 'No effect..');
  TextBoxLine (163, 'Damn !');
  Blinking_cursor;
End;

procedure wepdefmenu;
begin
  t2:=0;
  repeat
    if t2 = 0 then
    begin
      SolidBox (20, 170, 80, 178, 4);
      SolidBox (20, 178, 80, 186, 1);
    end
    else
    begin
      SolidBox (20, 170, 80, 178, 1);
      SolidBox (20, 178, 80, 186, 4);
    end;
    OutText (23, 171, 'WEAPONS');
    OutText (23, 179, 'DEFENCE');
    repeat
      ch:=Readkey;
      if ch = #0 then
        ch:=Readkey;
    until (ch = #72) or (ch = #80) or (ch = #13) or (ch = #27);
    playsample ('wall.voc');
    if ch = #72 then
      t2:=0;
    if ch = #80 then
      t2:=1;
  until (ch = #13) or (ch = #27);
  playsample ('switch.voc');
  solidbox (11, 146, 249, 189, 1);
  drawframe (10, 145, 250, 190, 15);
  font. setfgcolor (14);
end;

Procedure DrawLee;
Const
  leeX : Array [1..13] of Byte = (120, 120, 120, 120, 120, 120, 128, 136, 144, 152, 152, 152, 152);
  leeY : Array [1..13] of Byte = (056, 064, 072, 080, 088, 088, 088, 088, 088, 088, 088, 096, 104);
  leeD : Array [1..13] of Byte = (003, 003, 003, 003, 003, 002, 002, 002, 002, 002, 003, 003, 003);

Begin
  Case leeD [lee_walks] of
    1 : t1:=32;
    2 : t1:=64;
    3 : t1:=00;
    4 : t1:=96;
  End;
  If (lee_walks / 2) = Trunc (lee_walks / 2) then Inc (t1, 16);
  If lee_walks > 6 then direction:=3 else if lee_walks > 2 then direction:=4;
  UsePage (2);
  GetPic (t1, 85, 16, 16, pict_buffer);
  GetPicMask (pict_buffer, pict_mask);
  CopyScreenToScreenMaskedX (2, t1, 85, 4, 16, leeX [lee_walks], leeY [lee_walks], 3, pict_mask);
  FreeMem (Pict_Mask, pict_buffer. height * pict_buffer. width);
  FreePic (pict_buffer);
end;

procedure drawmace (direction, xplus, yplus, mpage : Byte);
var maceX, maceY, charX : Byte;
begin
  UsePage (2);
  maceX:=152;
  maceY:=72;
  case direction of
    1 : charX:=32;
    2 : charX:=64;
    3 : charX:=00;
    4 : charX:=96
  end;
  If xplus = 1 then Dec (maceX, 8);
  If yplus = 1 then Dec (maceY, 8);
  If xplus = 2 then Inc (maceX, 8);
  If yplus = 2 then Inc (maceY, 8);
  If (xplus > 0) or (yplus > 0) then
    charX:=charX + 16;
  if direction > 0 then
  begin
    GetPic (charX, 0, 16, 16, pict_buffer);
    GetPicMask (pict_buffer, pict_mask);
    CopyScreenToScreenMaskedX (2, charX, 0, 4, 16, maceX, maceY, mpage, pict_mask);
    FreeMem (Pict_Mask, pict_buffer. height * pict_buffer. width);
    FreePic (pict_buffer)
  end;
  usepage (1)
end;

Procedure Swiss_Watch;
Var
  h, m, s, hund : Word;
Begin
  Font. SetFGColor (14);
  GetTime (h, m, s, hund);
  TextBoxLine (163, 'It is now ' + LeadingZero (h) + ':' + LeadingZero (m) + ':' +
    LeadingZero (s) + '.' + LeadingZero (hund) + ' Avalon time.');
  Blinking_Cursor;
End;

Function LeadingZero(w : Word) : String;
Var
  s : String;
Begin
  Str(w : 0, s);
  If Length(s) = 1 then
    s:='0' + s;
  LeadingZero:=s;
end;

Procedure ShowExplosion (n : Byte; delaytime : Byte);
Const eframeX : Array [1..11] of Byte = (000, 066, 132, 198, 000, 066, 132, 198, 000, 066, 132);
      eframeY : Array [1..11] of Byte = (000, 000, 000, 000, 061, 061, 061, 061, 122, 122, 122);
Var   xf, yf : Word;
      xs, ys : Word;
Begin
  UsePage (3);
  Load_PCX (0, 0, 320, 200, 'explosy', False);
  For t2:=1 to n do begin
    PlaySample ('expl.voc');
    xs:=Random (240) + 20;
    ys:=Random (80) + 20;
    For t1:=1 to 11 do begin
      xf:=0;
      yf:=0;
      Repeat
        GetPic (eframeX [t1] + xf, eframeY [t1] + yf, 16, 16, pict_buffer);
        GetPicMask (pict_buffer, pict_mask);
        CopyScreenToScreenMaskedX (3,  eframeX [t1] + xf, eframeY [t1] + yf,
         4, 16, xs + xf,  ys + yf, 0, pict_mask);
        FreeMem (Pict_Mask, pict_buffer. height * pict_buffer. width);
        FreePic (pict_buffer);
        Inc (xf, 16);
        If xf > 63 then begin
          xf:=0;
          Inc (yf, 16);
        End;
      Until yf > 47;
      Delay (delaytime);
      WaitForRetrace;
      BlockPageToPage (1, 0, 0, 0, 80, 150, 0, 0);
    End;
  End;
  UsePage (0);
  Delay (1000);
End;

procedure IntroScreen;
begin
  settextmode;
  write ('Loading...');
  setmode (MODE200, 0, 0);
  showpage (1);
  usepage (0);
  Load_PCX (0, 0, 319, 199, 'introscr', true);
  clrkey;
  playsample ('S_MOOD.VOC');
  for t1:=0 to 255 do
    getpal (t1, pl [t1, 1], pl [t1, 2], pl [t1, 3]);
  for t1:=0 to 255 do
    setpal (t1, 0, 0, 0);
  showpage (0);
  for t1:=255 downto 1 do
  begin
    setPal (t1, pl [t1, 1], pl [t1, 2], pl [t1, 3]);
    delay (1)
  end;
  t1:=0;
  while (t1 < 400) and not keypressed do
  begin
    inc (t1);
    waitforretrace;
  end;
  if t1 > 200 then
  begin
    for t2:=1 to 63 do
    begin
      for t1:=1 to 255 do
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
        waitforretrace;
    end;
    for t1:=63 downto 1 do
    begin
      for t2:=1 to 255 do
        setpal (t2, t1, t1, t1);
      if not keypressed then
        waitforretrace;
    end
  end
end;

Procedure IntroFadeOut;
Begin
  for t1:=20 to 99 do
  begin
    if not keypressed then
    begin
      waitforretrace;
      updatebars
    end;
    for t2:=t1 - 1 downto 0 do
      if not keypressed then
        blockpagetopage (0, 0, 0, t1, 80, 1, 0, t2)
  end
end;

procedure updatebars;
var
  t1,
  t2,
  t3    : integer;
begin
  for t1:=1 to 16 do
  begin
    if song. channel [t1] then
    begin
      balk [t1]:=100;
      song. channel [t1]:=false;
      solidbox ((t1 - 1) * 20, 100, (t1 * 20 - 10), 200, 0)
    end;
    t2:=balk [t1];
    for t3:=16 to 39 do
    begin
      if t2 < 200 then
      begin
        solidHlineX (t2, (t1 - 1) * 20, t1 * 20 - 10, t3);
        solidHlineX (t2 + 1, (t1 - 1) * 20, t1 * 20 - 10, t3)
      end;
      inc (t2, 1)
    end;
    for t3:=38 downto 16 do
    begin
      if t2 < 200 then
      begin
        solidHlineX (t2, (t1 - 1) * 20, t1 * 20 - 10, t3);
        solidHlineX (t2 + 1, (t1 - 1) * 20, t1 * 20 - 10, t3)
      end;
      inc (t2, 1)
    end;
    solidHlineX (balk [t1] - 1, (t1 - 1) * 20, t1 * 20 - 10, 0);
    if balk [t1] < 200 then
      inc (balk [t1], 1)
  end
end;

procedure introdemo;
begin
  for t1:=1 to 16 do
    balk [t1]:=200;
  fadeout;
  exitdemo:=false;
  animation:=true;
  showpage (0);
  usepage (0);
  clearpage (0);
  usepage (1);
  load_pcx (0, 0, 319, 199, 'FONT', true);
  UsePage (0);
  NiceTextLine (Xcentre, 050, 'AVALON', false, geel);
  SolidHLineX (62, 159-20, 159+29, 176);
  Sleep (200);
  NiceTextLine (Xcentre, 080, '(C) 1997-1998 MiG', true, wit);
  Sleep (300);
  IntroFadeOut;
  NiceTextLine (Xcentre, 050, 'CODING', true, geel);
  NiceTextLine (Xcentre, 075, 'Jer Der', true, wit);
  Sleep (300);
  IntroFadeOut;
  NiceTextLine (Xcentre, 050, 'GRAPHICS', true, geel);
  NiceTextLine (Xcentre, 075, 'Tracer', true, wit);
  Sleep (300);
  introfadeout;
  nicetextline (Xcentre, 035, 'MUSIC', true, geel);
  nicetextline (xcentre, 060, 'Jer Der', true, wit);
  nicetextline (xcentre, 075, 'Tracer', true, wit);
  sleep (300);
  introfadeout;
  nicetextline (xcentre, 005, 'TESTING & BUG REPORTS', true, geel);
  nicetextline (xcentre, 030, 'Lee', true, wit);
  nicetextline (xcentre, 045, 'Sram', true, wit);
  nicetextline (xcentre, 060, 'Jer Der', true, wit);
  nicetextline (xcentre, 075, 'Tracer', true, wit);
  sleep (300);
  IntroFadeOut;
  nicetextline (xcentre, 050, 'MIGTRACKER PRO MUSIC ENGINE', true, geel);
  nicetextline (xcentre, 075, 'Jer Der', true, wit);
  sleep (200);
  introfadeout;
  if not keypressed then
    fadeout;
  animation:=false
end;

Procedure Blinking_Cursor;
Begin
  t3:=1;
  Repeat
    If (Longint (Ptr ($40, $6c)^) / 2 = Round (LongInt (Ptr ($40, $6c)^) / 2)) then begin
      If t2 = 0 then begin
        t2:=1;
        If t3 = 1 then t3:=15 else t3:=1;
        SolidBox (15, 178, 19, 182, t3);
      End;
    End else t2:=0;
  Until Keypressed;
  ch:=Readkey;
End;

Procedure ShowMenu;
var
  choise   : integer;
const
  MenuItem : Array [1..4] of String = ('A T T A C K', 'U S E   I T E M', 'S T A T U S', 'F L E E');
begin
  choise:=t1;
  Repeat
    For t1:=1 to 4 do begin
      WaitForRetrace;
      If choise = t1 then font. SetFGColor (14) else font. SetFGColor (15);
      OutText (116, 154 + t1 * 7, MenuItem [t1]);
    End;
    t1:=0;
    t2:=1;
    Repeat
      BlockPageToPage (2, 0, 132, t1 * 12, 3, 11, 100, 151 + choise * 7);
      t1:=t1 + t2;
      If (t1 = 5) or (t1 = 0) then t2:=t2 * -1;
      For t3:=1 to 4 do
        WaitForRetrace;
    Until Keypressed;
    t3:=choise;
    PlaySample ('wall.voc');
    ch:=Readkey;
    If ch = #0 then ch:=Readkey;
    If (ch = #72) and (choise > 1) then Dec (choise, 1);
    If (ch = #80) and (choise < 4) then Inc (choise, 1);
    If choise <> t3 then
      SolidBox (100, 157, 111, 189, 1);
  Until (ch = #13) or (ch = #32);
  t1:=choise;
End;

Procedure Game_Over;
Begin
  StopSong;
  PlaySample ('bombexpl.voc');
  UsePage (1);
  Load_PCX (0, 0, 320, 200, 'GO', True);
  For t1:=0 to 255 do GetPal (t1, pl [t1, 1], pl [t1, 2], pl [t1, 3]);
  For t1:=0 to 255 do SetPal (t1, 255, 255, 255);
  ShowPage (1);
  For t1:=0 to 255 do for t2:=1 to 3 do pr [t1, t2]:=63;
  For t1:=1 to 64 do begin
    For t2:=0 to 255 do begin
      SetPal (t2, pr [t2, 1], pr [t2, 2], pr [t2, 3]);
      Dec (pr [t2, 1]); If pr [t2, 1] <= pl [t2, 1] then pr [t2, 1]:=pl [t2, 1];
      Dec (pr [t2, 2]); If pr [t2, 2] <= pl [t2, 2] then pr [t2, 2]:=pl [t2, 2];
      Dec (pr [t2, 3]); If pr [t2, 3] <= pl [t2, 3] then pr [t2, 3]:=pl [t2, 3];
    End;
    WaitForRetrace;
  End;
  For t1:=1 to 100 do WaitForRetrace;
  LoadSong ('MTP\AVALON13.MTP');
  PlaySong;
  If Keypressed then Readkey;
  For t1:=1 to 40 do WaitForRetrace;
  Readkey;
  StopSong;
End;

procedure fake_game_over;
Begin
  StopSong;
  PlaySample ('bombexpl.voc');
  UsePage (0);
  clearpage (0);
  For t1:=0 to 255 do GetPal (t1, pl [t1, 1], pl [t1, 2], pl [t1, 3]);
  For t1:=0 to 255 do SetPal (t1, 255, 255, 255);
  ShowPage (0);
  For t1:=0 to 255 do for t2:=1 to 3 do pr [t1, t2]:=63;
  For t1:=1 to 64 do begin
    For t2:=0 to 255 do begin
      SetPal (t2, pr [t2, 1], pr [t2, 2], pr [t2, 3]);
      Dec (pr [t2, 1]); If pr [t2, 1] <= pl [t2, 1] then pr [t2, 1]:=pl [t2, 1];
      Dec (pr [t2, 2]); If pr [t2, 2] <= pl [t2, 2] then pr [t2, 2]:=pl [t2, 2];
      Dec (pr [t2, 3]); If pr [t2, 3] <= pl [t2, 3] then pr [t2, 3]:=pl [t2, 3];
    End;
    WaitForRetrace;
  End;
End;


Procedure FadeOut;
Begin
  For t1:=0 to 255 do GetPal (t1, pl [t1, 1], pl [t1, 2], pl [t1, 3]);
  For t1:=120 downto 1 do begin
    For t2:=255 downto 0 do begin
      SetPal (t2, pl [t2, 1], pl [t2, 2], pl [t2, 3]);
      Dec (pl [t2, 1]); If pl [t2, 1] > 254 then pl [t2, 1]:=0;
      Dec (pl [t2, 2]); If pl [t2, 2] > 254 then pl [t2, 2]:=0;
      Dec (pl [t2, 3]); If pl [t2, 3] > 254 then pl [t2, 3]:=0;
    End;
    if animation then
      updatebars;
    WaitForRetrace;
  End;
End;

Procedure FadeIn;
Begin
  For t1:=0 to 255 do GetPal (t1, pl [t1, 1], pl [t1, 2], pl [t1, 3]);
  For t1:=0 to 255 do SetPal (t1, 0, 0, 0);
  For t1:=0 to 255 do for t2:=1 to 3 do pr [t1, t2]:=0;
  ShowPage (0);
  For t1:=1 to 64 do begin
    For t2:=0 to 255 do begin
      SetPal (t2, pr [t2, 1], pr [t2, 2], pr [t2, 3]);
      Inc (pr [t2, 1]); If pr [t2, 1] >= pl [t2, 1] then pr [t2, 1]:=pl [t2, 1];
      Inc (pr [t2, 2]); If pr [t2, 2] >= pl [t2, 2] then pr [t2, 2]:=pl [t2, 2];
      Inc (pr [t2, 3]); If pr [t2, 3] >= pl [t2, 3] then pr [t2, 3]:=pl [t2, 3];
    End;
    if not keypressed then
      for t3:=1 to 2 do
        waitforretrace;
  End;
End;

procedure sleep (k : word);
var
  eind : word;
begin
  eind:=k;
  k:=1;
  while not keypressed and (k < eind) do
  begin
    inc (k);
    waitforretrace;
    if animation then
      updatebars
  end
end;

Procedure DMA_Stop;
Begin
  if sound_on then
    DMAStop
End;

Procedure Speaker_Off;
Begin
  if sound_on then
    SpeakerOff
End;

Procedure Init_DSP;
Begin
  if sound_on and not DSP_INIT_BOOLEAN then
  begin
    dsp_init_boolean:=true;
    New(SoundDat);
    ResetDSP(2);
    SpeakerOn
  end
End;

Procedure Show_Loading;
Begin
  UsePage (0);
  Font. SetFGColor (15);
  DrawFrame (120, 48, 220, 62, 15);
  SolidBox  (121, 49, 219, 61, 1);
  OutText (123, 53, 'LOADING GAME DATA...');
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

Procedure smfont; External;
{$L smfont.obj}

procedure OutText;
var
  fgcol : Integer;
begin
  fgcol:=font. getfgcolor;
  font. setfgcolor (0);
  font. writeat (xn + 1, yn + 1, sn);
  font. setfgcolor (fgcol);
  font. writeat (xn, yn, sn);
end;

Procedure TextLine (yx : Integer; sx : String; color : Byte);
Var xx : Integer;
Begin
  xx:=Round (160 - Length (sx) * 2.5);
  t2:=xx;
  For t1:=1 to Length (sx) do begin
    SolidBox (t2, yx, t2 + 4, yx + 4, color);
    OutText (t2, yx, Copy (sx, t1, 1));
    t2:=t2 + 5;
    SolidBox (t2, yx, t2 + 4, yx + 4, 15);
    If Copy (sx, t1, 1) <> ' ' then begin
      Delay (60);
    End;
    SolidBox (t2, yx, t2 + 4, yx + 4, color);
  End;
  Delay (50);
End;

Procedure TextBoxLine (yx : Integer; sx : String);
var
  stopnow : boolean;
  pt1,
  pt2     : integer;


Begin
  stopnow:=false;
  pt2:=15;
  for pt1:=1 to Length (sx) do
  begin
    if keypressed then
    begin
      ch:=Readkey;
      stopnow:=true
    end;
    solidbox (pt2, yx, pt2 + 4, yx + 4, 1);
    outtext (pt2, yx, Copy (sx, pt1, 1));
    pt2:=pt2 + 5;
    solidbox (pt2, yx, pt2 + 4, yx + 4, 15);
    If (Copy (sx, pt1, 1) <> ' ') and not stopnow then
      delay (40);
    solidbox (pt2, yx, pt2 + 4, yx + 4, 1)
  end;
  Delay (30)
end;

procedure opentextbox;
var
  erica_terpstra : boolean;
  pt1,
  pt2,
  pt3,
  pt4            : integer;
const   vet = True;
        dik = False;
begin
  usepage (0);
  pt3:=167;
  pt4:=167;
  pt2:=130;
  pt1:=130;
  repeat
    DrawFrame (pt2, pt4, pt1, pt3, 15);
    If erica_terpstra = vet then begin
      waitforretrace;
      erica_terpstra:=dik;
    end
    else
      erica_terpstra:=vet;
    SolidBox (pt2, pt4, pt1, pt3, 1);
    dec (pt2, 2);
    inc (pt1, 2);
    if (pt4 > 145) then
      dec (pt4, 1);
    if (pt3 < 190) then
      inc (pt3, 1)
  until (pt1 >= 250);
  solidbox (11, 146, 249, 189, 1);
  drawframe (10, 145, 250, 190, 15);
  clrkey
end;

Procedure SetPal; assembler;
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

Procedure GetPal;
  { This gets the Red, Green and Blue values of a certain color }
Var
   rr,gg,bb : Byte;
Begin
   asm
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
   r := rr;
   g := gg;
   b := bb;
end;

Procedure ClrKey;
Begin
  Head:=Tail;
End;

Procedure DrawFrame;
Begin
  SolidHlineX (y1, x1, x2, c);
  SolidHlineX (y2, x1, x2, c);
  SolidVlineX (x1, y1, y2, c);
  SolidVlineX (x2, y1, y2, c);
End;

Function Str2;
Begin
  Str (intV, s);
  Str2:=s;
End;

procedure write_config_file;
begin
  { start write config file }
  assign (f, 'avalon.cfg');
  rewrite (f);
  writeln (f, 'AVALON Configuration file');
  writeln (f, '-------------------------');
  writeln (f, 'Battle Music (1 = ON 2 = OFF)');
  if battle_music then
    t1:=1
  else
    t1:=2;
  writeln (f, t1);
  writeln (f, 'Background Music (1 = ON 2 = OFF)');
  if wavetable_on then
    t1:=1
  else
    t1:=2;
  writeln (f, t1);
  writeln (f, 'Sound (1 = ON 2 = OFF)');
  if sound_on then
    t1:=1
  else
    t1:=2;
  writeln (f, t1);
  close (f);
  { end write config file }
end;

Procedure TitleScreen;
Var r,
    g,
    b,
    lg : Byte;

begin
  dma_stop;
  stopsong;
  loadsong ('MTP\VOICE.MTP');
  playsong;
  clrkey;
  repeat
    lg:=0;
    usepage (1);
    clearpage (255);
    usepage (0);
    showpage (1);
    load_pcx (0, 0, 320, 200, 'VOORPL~1', true);
    fadein;
    start_timer (200);
    wait_for_timer (true);
    fadeout;
    if not keypressed then
      introdemo
  until keypressed;
  ch:=readkey;
  repeat
    UsePage (0);
    ClearPage (0);
    UsePage (1);
    Load_PCX (0, 0, 319, 199, 'font2', true);
    ShowPage (2);
    UsePage (0);
    SetPal (255, 0, 0, 225);
    showpage (0);
    drawmysticbox (114, 75, 207, 132, 15);
    SolidBox (114, 75, 207, 132, 255);
    DrawFrame (114, 75, 207, 132, 15);
    NiceTextLine2 (120, 080, 'NEW GAME', false);
    NiceTextLine2 (120, 092, 'LOAD GAME', false);
    NiceTextLine2 (120, 104, 'OPTIONS', false);
    NiceTextLine2 (120, 116, 'EXIT', False);
    BlockPageToPage (1, 0, 0, 50, 3, 12, 116, 80);
    t2:=1;
    Repeat
      t3:=0;
      Clrkey;
      Repeat
        Case t2 of
          1 : BlockPageToPage (1, 0, t3 * 12, 50, 3, 12, 116, 080);
          2 : BlockPageToPage (1, 0, t3 * 12, 50, 3, 12, 116, 092);
          3 : BlockPageToPage (1, 0, t3 * 12, 50, 3, 12, 116, 104);
          4 : BlockPageToPage (1, 0, t3 * 12, 50, 3, 12, 116, 116);
       End;
        Inc (t3);
        If t3 > 8 then
          t3:=0;
        Sleep (5);
      Until Keypressed;
      ch:=Readkey;
      If ch = #0 then
        ch:=Readkey;
      If (ch = #72) and (t2 > 1) then
        Dec (t2);
      If (ch = #80) and (t2 < 4) then
        Inc (t2);
      SolidBox (116, 80, 126, 131, 255);
      if sound_on then
      begin
        init_dsp;
        dma_stop
      end;
      PlaySample ('LAND02.VOC');
    Until (ch = #13) or (ch = #32);
    PlaySample ('SWITCH.VOC');
    Case t2 of
      1 : Begin
        song. fading:=8;
        fadeout;
        While song. playing do song. fading:=10;
        Execute ('INTRODEM.EXE', 'MIGCODE');
        ch:=#255
      End;
      2 : Begin
        UsePage (0);
        ClearPage (0);
        UsePage (1);
        Load_PCX (0, 0, 1, 1, 'water2', True);
        UsePage (0);
        t2:=1;
        t3:=0;
        font. SetFGColor (15);
        usepage (0);
        clearpage (0);
        drawmysticbox (88+40, 28+40, 159+40, 85+40, 15);
        Repeat
          UsePage (3);
          DrawFrame (88, 28, 159, 85, 15);
          SolidBox (89, 29, 158, 84, 1);
          SolidBox (90, 29 + t2 * 8 + t3, 157, 36 + t2 * 8 + t3, 4);
          For t1:=1 to 5 do
            OutText (97, 30 + t1 * 8, 'LOAD GAME  ' + Str2 (t1));
          BlockPageToPage (3, 0, 88, 27, 18, 59, 88+40, 28+40);
          If t3 = 0 then
          Begin
            ch:=Readkey;
            If ch = #0 then
              ch:=Readkey;
            If (ch = #72) and (t2 > 1) then
              t3:= -1;
            If (ch = #80) and (t2 < 5) then
              t3:=1
          End else begin
            If t3 > 0 then
              Inc (t3)
            else
              Dec (t3);
            WaitForRetrace;
            If (t3 = 8) or (t3 = -8) then
            Begin
              If t3 > 0 then
                Inc (t2)
              else
                Dec (t2);
              t3:=0;
            End;
          End
        Until (ch = #13) or (ch = #32);
        lg:=t2;
        PlaySample ('SWITCH.VOC');
        ch:=#255
      End;
      3 :
      begin
        drawmysticbox (94, 75, 227, 132, 15);
        t2:=1;
        repeat
          SolidBox (95, 76, 226, 131, 255);
          DrawFrame (94, 75, 227, 132, 15);
          if sound_on then
            NiceTextLine2 (100, 080, 'SOUND      ON ', false)
          else
            NiceTextLine2 (100, 080, 'SOUND      OFF', false);
          if wavetable_on then
            NiceTextLine2 (100, 092, 'BGM        ON ', false)
          else
            NiceTextLine2 (100, 092, 'BGM        OFF', false);
          if battle_music then
            NiceTextLine2 (100, 104, 'BATTLEMUS  ON ', false)
          else
            nicetextline2 (100, 104, 'BATTLEMUS  OFF', false);
          NiceTextLine2 (100, 116, 'BACK', False);
          repeat
            begin
              t3:=0;
              clrkey;
              repeat
                BlockPageToPage (1, 0, t3 * 12, 50, 3, 12, 96, 080 + (t2 - 1) * 12);
                Inc (t3);
                If t3 > 8 then
                  t3:=0;
                Sleep (5);
              Until Keypressed;
              ch:=Readkey;
              If ch = #0 then
                ch:=Readkey;
              If (ch = #72) and (t2 > 1) then
                Dec (t2);
              If (ch = #80) and (t2 < 4) then
                Inc (t2);
              SolidBox (96, 80, 106, 131, 255);
              PlaySample ('LAND02.VOC');
            End;
          Until (ch = #13) or (ch = #32);
          PlaySample ('SWITCH.VOC');
          if t2 = 1 then
          begin
            if sound_on then
              sound_on:=false
            else
            begin
              sound_on:=true;
              init_dsp;
              dma_stop
            end
          end
          else
          if t2 = 2 then
          begin
            if wavetable_on then
            begin
              stopsong;
              wavetable_on:=false
            end
            else
            begin
              wavetable_on:=true;
              playsong
            end
          end
          else
          if t2 = 3 then
          begin
            if battle_music then
              battle_music:=false
            else
              battle_music:=true
          end
        until t2 = 4;
        write_config_file
      end;
      4 : Begin
        StopSong;
        SetTextMode;
        Halt
      End
    End;
  until ch = #255;
  song. fading:=8;
  FadeOut;
  t1:=lg;
  StopSong
end;

Procedure NiceTextLine (x, y : Integer; s : string; dy : Boolean; font_in_gold : boolean);
Var
  t, u   : integer;
  tx, ty : byte;
  ts     : String [1];
Const
  sn : Packed Array [1..22] of Char = '-:.,!?"&()[]0123456789';
Begin
  If x = xcentre then x:=159 - (length (s) * 4);
  For t:=1 to length (s) do begin
    If (copy (s, t, 1) >= 'a') and (copy (s, t, 1) <= 'z') then begin
      ts:=Copy (s, t, 1);
      tx:=(Ord (ts [1]) - 97) * 8;
      ty:=2;
    End;
    If (copy (s, t, 1) >= 'A') and (copy (s, t, 1) <= 'Z') then begin
      ts:=copy (s, t, 1);
      tx:=(Ord (ts [1]) - 65) * 8;
      ty:=14;
    End;
    For u:=1 to 22 do begin
      If copy (s, t, 1) = copy (sn, u, 1) then begin
        tx:=(u - 1) * 8;
        ty:=25
      End;
    End;
    If (copy (s, t, 1) <> ' ') and not keypressed then
      if not font_in_gold then
        BlockPageToPage (1, 0, tx, ty, 2, 12, x + t * 8, y)
      else
        blockpagetopage (1, 0, tx, ty + 37, 2, 12, x + t * 8, y);
    If dy then
      Sleep (8)
  End
End;

Procedure NiceTextLine2 (x, y : Integer; s : string; dy : Boolean);
Var
  t, u   : integer;
  tx, ty : byte;
  ts     : String [1];
Const
  sn : Packed Array [1..22] of Char = '-:.,!?"&()[]0123456789';
Begin
  If x = xcentre then x:=159 - (length (s) * 4);
  For t:=1 to length (s) do begin
    If (copy (s, t, 1) >= 'a') and (copy (s, t, 1) <= 'z') then begin
      ts:=Copy (s, t, 1);
      tx:=(Ord (ts [1]) - 97) * 8;
      ty:=2
    End;
    If (copy (s, t, 1) >= 'A') and (copy (s, t, 1) <= 'Z') then begin
      ts:=copy (s, t, 1);
      tx:=(Ord (ts [1]) - 65) * 8;
      ty:=14
    End;
    For u:=1 to 22 do begin
      If copy (s, t, 1) = copy (sn, u, 1) then begin
        tx:=(u - 1) * 8;
        ty:=25
      End;
    End;
    If (copy (s, t, 1) <> ' ') then
      BlockPageToPage (1, 0, tx, ty, 2, 12, x + t * 8, y);
    If dy then Sleep (8)
  End
End;


Begin
  Font. Meminit (@SMFONT);
  Font. SetFGColor (15)
End.