program AVALON_MAIN;

uses avglob,
     dos,
     crt,
     modex,
     jervga,
     common,
     unitpcx,
     mtpunit,
     avunit,
     heapman;

procedure initialize;
begin
  for t1:=1 to 20 do
    monster [t1]. id:=0;
  for t1:=1 to 10 do
    human [t1]. id:=0;
  t1:=1;
  repeat
    monster [t1]. spritenr:=true;
    t1:=t1 + 1;
    monster [t1]. spritenr:=false;
    t1:=t1 + 1;
  until t1 >= 20;
  x:=23;
  y:=19;
  direction:=3;
  level:=1;
  chapter:=0;
  area:=FLD_VILLAGE;
  exp:=0;
  exp_nextlevel:=100;
  life:=100;
  maxlife:=100;
  monsters_killed:=0;
  money:=200;
  power:=10;
  defence:=5;
  weapon:=0;
  shield:=0;
  song. filename:='MTP\AVALON02.MTP';
  for t1:=1 to 20 do
  begin
    objects [t1]. name:='';
    objects [t1]. nr:=0;
  end;
  for t1:=1 to 50 do
  begin
    items [t1]. name:='';
    items [t1]. nr:=0
  end;
  for t1:=1 to 40 do
    event_happend [t1]:=false
End;

procedure MonsterHitsFirst;
Begin
  fleed:=False;
  for t3:=1 to 2 do
  begin
    if actmonster [t3]. name <> '' then
    begin
      SolidBox (11, 158, 249, 189, 1);
      font. SetFGColor (14);
      if (level in [29, 41, 42]) and (actmonster [1]. power = 500) then
        playsample ('WEAPONCA.VOC')
      else
        playsample ('ENERGY.VOC');
      TextBoxLine (160, Actmonster [t3]. name + ' attacks !!');
      font. SetFGColor (15);
      If random (10) < 2  then begin
        PlaySample ('helihit.voc');
        TextBoxLine (168, '...but mace dodges the attack !!');
        Delay (400);
      end
      else
      begin
        if (level in [29, 41, 42]) and (actmonster [1]. power = 500) then
          playsample ('WEAPONCB.VOC')
        else
          playsample ('GRNDHIT.VOC');
        t1:=round (random (round (actmonster [t3]. power / 2)) + actmonster [t3]. power / 2) - defence;
        blockpagetopage (0, 3, 0, 0, 79, 200, 4, 0);
        for t2:=1 to round (t1 / maxlife * 100) do
        begin
          ShowPage (3);
          WaitForRetrace;
          ShowPage (0);
        End;
        If t1 < 1 then
          t1:=1;
        If t1 < life then Dec (life, t1) else
        begin
          life:=0;
          ch:=#255;
          Mace_is_a_dead_man:=True
        End;
        TextBoxLine (168, Str2 (t1) + ' damage !!');
        Delay (600)
      End;
      SolidBox (11, 158, 249, 189, 1);
      SolidBox (71, 149, 244, 155, 1);
      DrawFrame (70, 148, 245, 156, 15);
      SolidBox (71, 149, 71 + Round (maxlife / 8), 155, 39);
      SolidBox (71, 149, 71 + Round (life / 8), 155, 09)
    end
  end
end;

procedure monsterhit;
Begin
  Delay (600);
  ShowMonsterStatus (t4);
  t3:=1;
  Repeat
    if actmonster [t3]. life = 0 then
    begin
      If actmonster [t3]. name <> '' then begin
        Case Random (2) of
          1 : TextBoxLine (176, Actmonster [t3]. name + ' dies...');
          0 : TextBoxLine (176, Actmonster [t3]. name + ' collapses !');
          2 : TextBoxLine (176, Actmonster [t3]. name + ' is dead !!');
        End;
        Inc (monsters_killed);
        Actmonster [t3]. name:='';
        PlaySample ('geysir.voc');
        For t1:=9 to 135 do begin
          For t2:=t1 - 1 downto 8 do begin
            BlockPageToPage (0, 0, 16 + mX [t3], t1, 36, 1, 16 + mX [t3], t2);
          End;
          WaitForRetrace;
        End;
        SolidBox (11, 158, 249, 189, 1)
      End
    end
    else
    begin
      solidbox (11, 158, 249, 189, 1);
      font. setfgcolor (14);
      if (actmonster [1]. life < 2000) and (actmonster [1]. power = 500) and (level in [28, 29, 41]) then      begin
        TextBoxLine (160, 'Esor Amreh uses a DARK POISON !!');
        PlaySample ('hivvir1.voc');
        delay (100);
        PlaySample ('hivvir2.voc');
        delay (200);
        if level < 40 then
        begin
          mace_is_a_dead_man:=true;
          exit
        end
        else
        begin
          playsample ('helihit.voc');
          textboxline (173, '...But the DARK POTION dodges the attack !');
          delay (200);
          solidbox (11, 158, 249, 189, 1);
          level:=42
        end
      end;
      if paralized > 0 then
      begin
        textboxline (160, Actmonster [t3]. name + ' is paralysed !!');
        dec (paralized);
        sleep (50);
        solidbox (11, 158, 249, 189, 1)
      end
      else
      begin
        if (level > 20) and (random (10) < 1) then
          monster_uses_item
        else
        begin
          if (actmonster [1]. power = 500) and (level in [29, 41, 42]) then
            playsample ('WEAPONCA.VOC')
          else
            playsample ('ENERGY.VOC');
          TextBoxLine (160, Actmonster [t3]. name + ' attacks...');
          font. SetFGColor (15);
          If random (10) < 2  then
          begin
            PlaySample ('helihit.voc');
            TextBoxLine (168, '...but mace dodges the attack !!');
            Delay (400);
          End
          else
          begin
            if (actmonster [1]. power = 500) and (level in [29, 41, 42]) then
              playsample ('WEAPONCB.VOC')
            else
              playsample ('GRNDHIT.VOC');
            t1:=Round (Random (Round (Actmonster [t3]. power / 2)) + Actmonster [t3]. power / 2) - defence;
            BlockPageToPage (0, 3, 0, 0, 79, 200, 4, 0);
            For t2:=1 to round (t1 / maxlife * 100) do
            begin
              ShowPage (3);
              WaitForRetrace;
              ShowPage (0)
            End;
            If t1 < 1 then
              t1:=1;
            If t1 < life then
              dec (life, t1)
            else
            begin
              life:=0;
              ch:=#255;
              mace_is_a_dead_man:=true
            End;
            TextBoxLine (168, Str2 (t1) + ' damage !!');
            Delay (600)
          End;
          SolidBox (11, 158, 249, 189, 1);
          SolidBox (71, 149, 244, 155, 1);
          DrawFrame (70, 148, 245, 156, 15);
          SolidBox (71, 149, 71 + Round (maxlife / 8), 155, 39);
          SolidBox (71, 149, 71 + Round (life / 8), 155, 09)
        end
      end
    end;
    Inc (t3);
    t1:=1;
  Until (t3 > Mmax) or (ch = #255) or Mace_is_a_dead_man;
  If not Mace_is_a_dead_man then
  begin
    If ((Actmonster [1]. name = '') and (Actmonster [2]. name = '')) or
    ((Actmonster [1]. name = '') and (mMax = 1)) then
    begin
      actmonster [1]. power:=monsterbak [1]. power;
      actmonster [1]. defence:=monsterbak [1]. defence;
      actmonster [2]. power:=monsterbak [2]. power;
      actmonster [2]. defence:=monsterbak [2]. defence;
      t3:=0;
      t4:=0;
      For t1:=1 to mMax do
      begin
        t3:=t3 + Round ((Actmonster [t1]. power + Actmonster [t1]. defence) / 5);
        t4:=t4 + Round ((Actmonster [t1]. life + Actmonster [t1]. power) / 2);
      End;
      SolidBox (11, 158, 249, 189, 1);
      font. SetFGColor (15);
      TextBoxLine (160, 'Experience ' + Str2 (t3) + ' up.');
      font. SetFGColor (14);
      TextBoxLine (168, Str2 (t4) + ' gold taken.');
      exp:=exp + t3;
      money:=money + t4;
      font. SetFGColor (15);
      Blinking_Cursor;
      monster [hitmonster]. ID:=0;
      t1:=255
    End;
    ch:=#255
  End
End;

Procedure AttackScreen;
Var tsongfile    : String [20];
    whichmonster : Byte;
    powertmp     : Integer;
Begin
  for t1:=1 to 2 do
    actmonster [t1]. maxlife:=actmonster [t1]. life;
  paralized:=0;
  powertmp:=power;
  whichmonster:=1;
  Mace_is_a_dead_man:=False;
  tsongfile:=song. filename;
  if battle_music or supermonster then
    song. fading:=8;
  fadegamescreen;
  mX [2]:=148;
  OpenTextBox;
  if supermonster or battle_music then
    repeat until not song. playing;
  If supermonster then
    loadsong ('MTP\AVALON07.MTP')
  else
  if battle_music then
    loadsong ('MTP\AVALON06.MTP');
  playsong;
  font. SetFGColor (15);
  OutText (12, 150, 'MACE LIFE:');
  drawframe (70, 148, 245, 156, 15);
  solidbox (71, 149, 71 + round (maxlife /  8), 155, 39);
  solidbox (71, 149, 71 + round (life /  8), 155, 09);
  UsePage (3);
  Load_PCX (0, 0, 319, 199, MonsterFilename, False);
  UsePage (0);
  If monster [hitmonster]. number > 10 then begin
    mMax:=2;
    mX [1]:=0;
  End else begin
    mMax:=1;
    mX [1]:=72
  End;
  SetPal (252, 0, 0, 0);
  SetPal (253, 0, 0, 0);
  t1:=10;
  For t1:=1 to mMax do begin
    t2:=16 + mX [t1];
    While t2 < 155 + mX [t1] do begin
      SolidVLineX (t2, 16, 111, 251 + t1);
      Inc (t2, 6);
    End;
    t2:=16;
    While t2 < 114 do begin
      SolidHLineX (t2, 16 + mX [t1], 154 + mX [t1], 251 + t1);
      Inc (t2, 6);
    End;
    mNr [1]:=Trunc (monster [hitmonster]. number mod 10);
    If t1 = 2 then mNr [2]:=Trunc (monster [hitmonster]. number / 10);
    if mnr [t1] = 0 then
      mnr [t1]:=1;
    case mnr [t1] of
      1 :
      begin
        t4:=000;
        t5:=000
      end;
      2 :
      begin
        t4:=160;
        t5:=000
      end;
      3 :
      begin
        t4:=000;
        t5:=100
      end;
      4 :
      begin
        t4:=160;
        t5:=100
      end;
    end;
    UsePage (3);
    t2:=0;
    t3:=0;
    Repeat
      GetPic (t2 + t4, t3 + t5, 16, 16, pict_buffer);
      GetPicMask (pict_buffer, pict_mask);
      CopyScreenToScreenMaskedX (3, t2 + t4, t3 + t5, 4, 16, 8 + mX [t1] + t2, 16 + t3, 0, pict_mask);
      FreeMem (Pict_Mask, pict_buffer. height * pict_buffer. width);
      FreePic (pict_buffer);
      Inc (t2, 16);
      if t2 > 140 then begin
        t2:=0;
        inc (t3, 16)
      end;
    until t3 > 90;
    actmonster [t1]:=bigmonster [mNr [t1]];
    monsterbak [t1]:=actmonster [t1];
    ShowMonsterStatus (t1)
  end;
  if mMax = 1 then
    actmonster [2]. name:='';
  t1:=1;
  repeat
    if fleed then
    begin
      monsterhitsfirst;
      t1:=1
    end;
    fleed:=False;
    If Mace_is_a_dead_man then
      exit;
    ShowMenu;
    if t1 = 2 then
    begin
      blockpagetopage (0, 1, 0, 0, 80, 150, 0, 0);
      usepage (3);
      t3:=1;
      repeat
        DrawFrame (96, 25, 190, 127, 15);
        SolidBox  (97, 26, 189, 126, 1);
        SolidBox (97, 66, 188, 74, 4);
        for t1:=1 to 12 do
        begin
          If (t3 + t1 - 6 > 0) and (t3 + t1 - 6 < MAXITEMS + 1) then
          begin
            OutText (99, 27 + (t1 - 1) * 8, Str2 (t3 + t1 - 6));
            OutText (112, 27 + (t1 - 1) * 8, Items [t3 + t1 - 6]. name)
          end;
        End;
        BlockPageToPage (3, 0, 96, 24, 24, 105, 96, 24);
        ch:=Readkey;
        If ch = #0 then ch:=Readkey;
        If (ch = #72) and (t3 > 1) then begin
          Dec (t3);
          PlaySample ('WALL.VOC')
        End;
        If (ch = #80) and (t3 < MAXITEMS) then begin
          Inc (t3);
          PlaySample ('WALL.VOC');
        End;
      Until (ch = #27) or (ch = #13);
      UsePage (0);
      BlockPageToPage (1, 0, 0, 0, 80, 150, 0, 0);
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
        monsterhit
      end;
      solidBox (11, 168, 249, 189, 1)
    end
    else
    if t1 = 3 then
    begin
      usepage (0);
      showstatus (-40);
      t1:=3
    end
    else
    if t1 = 4 then
    begin
      if (not supermonster) and (actmonster [whichmonster]. name <> 'Sinnet Guardian') then
      begin
        if (random (10) > 5) and (actmonster [whichmonster]. life > life) then
        begin
          SolidBox (11, 158, 249, 189, 1);
          TextBoxLine (168, 'Mace flees but '+ Actmonster [whichmonster]. name + ' is faster !');
          Delay (500);
          SolidBox (11, 158, 249, 189, 1);
          t1:=4;
        end
        else
          t1:=255;
        fleed:=true;
      end
      else
      begin
        SolidBox (11, 158, 249, 189, 1);
        TextBoxLine (168, 'Mace flees but '+ Actmonster [whichmonster]. name + ' is faster !');
        Delay (500);
        SolidBox (11, 158, 249, 189, 1);
        fleed:=True;
        t1:=4
      End;
    End
    else
    if t1 = 1 then
    begin
      Treal:=35;
      t3:=0;
      If actmonster [whichmonster]. name <> '' then
        t4:=whichmonster
      else
      if actmonster [1]. name <> '' then t4:=1
      else
        t4:=2;
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
        If ch = #0 then begin
          ch:=Readkey;
          If (ch = #75) and (Actmonster [1]. name <> '') then begin
            t4:=1;
            Treal:=40;
            PlaySample ('enemyhit.voc');
          End;
          If (ch = #77) and (Mmax = 2) and (Actmonster [2]. name <> '') then begin
            t4:=2;
            Treal:=40;
            PlaySample ('enemyhit.voc');
          End;
        End;
        whichmonster:=t4;
        If (ch = #32) or (ch = #13) then begin
          PlaySample ('weapon' + weaponcon [weapon]. fnr + 'a.voc');
          { Hit the workers }
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
          MonsterHit
        End;
      Until (ch = #255) or (ch = #27) or Mace_is_a_dead_man;
      SetPal (252, 0, 0, 0);
      SetPal (253, 0, 0, 0);
    End
  Until (t1 = 255) or (Mace_is_a_dead_man);
  power:=powertmp;
  If not mace_is_a_dead_man then
  begin
    UsePage (1);
    Load_PCX (0, 0, 319, 199, arean [area]. filen, false);
    if battle_music or supermonster then
    begin
      stopsong;
      loadsong (tsongfile);
      playsong;
    end;
    ShowScreen (x, y, 0, 0);
    updateinfoscrn;
    t1:=hitmonster
  End
End;

procedure init_level;
begin
  reset (f);
  for t1:=0 to 99 do
    for t2:=0 to 99 do
    begin
      readln (f, field [t1, t2]);
      readln (f, trans [t1, t2]);
    end;
  for t1:=0 to 142 do
    readln (f, CellStatus [t1]);
  close (f);
  fadegamescreen;
  for t1:=1 to 20 do
    monster [t1]. ID:=0;
  for t1:=1 to 10 do
    human [t1]. ID:=0;
end;

Procedure GameLoop;
var
  exitlevel : boolean;
begin
  exitlevel:=false;
  clrkey;
  repeat
    UpdateMonsters;
    ShowScreen (x, y, 0, 0);
    For t1:=1 to 20 do begin
      If ((monster [t1]. x = x) and (monster [t1]. y = y)) or
      ((monster [t1]. x = x) and (monster [t1]. y = y + 1) and (monster [t1]. dir = 1)) or
      ((monster [t1]. x = x + 1) and (monster [t1]. y = y) and (monster [t1]. dir = 4)) then
      If (monster [t1]. ID > 0) and (touchedcount < 1) then
      begin
        hitmonster:=t1;
        supermonster:=false;
        AttackScreen;
        If fleed then Touchedcount:=30;
      End;
      If Mace_is_a_dead_man then exit;
    End;
    If Mace_is_a_dead_man then exit;
    For t1:=1 to 10 do begin
      TouchedHuman [t1]:=False;
      If (human [t1]. x = x) and (human [t1]. y = y) then TouchedHuman [t1]:=True;
      If (human [t1]. x = x) and (human [t1]. y = y + 1) and (human [t1]. dir = 1) then TouchedHuman [t1]:=True;
      If (human [t1]. x = x + 1) and (human [t1]. y = y) and (human [t1]. dir = 4) then TouchedHuman [t1]:=True;
      If human [t1]. ID = 0 then TouchedHuman [t1]:=False;
    End;
    If touchedcount > 0 then Dec (touchedcount, 1);
    If (Touchedcount < 1) then begin
      If TouchedHuman [1] = True then begin
        touchedcount:=30;
        Case Area of
          FLD_GREYCAVE : stringfellowhawk (CHR_CADDMAN);
          FLD_ALIENVIL : Begin
            StringFellowHawk (CHR_SRAM);
            If level = 17 then begin
              StringFellowHawk (CHR_SRAM);
              Dec (level);
            End else if level = 18 then begin
              If money >= 500 then begin
                stringfellowhawk (CHR_SRAM);
                inc (level);
                dec (money, 500);
                updateinfoscrn;
                object_found ('Translator', 1, 256, 0, 'received.')
              End else begin
                SolidBox (11, 146, 249, 189, 1);
                Dec (level, 2);
                Font. SetFGColor (14);
                OutText (15, 147, '[SRAM]');
                Font. SetFGColor (15);
                TextBoxLine (155, 'Yourg haven''t got enough gredits..');
                Blinking_Cursor;
                UpdateInfoScrn;
              End;
            End;
          End;
          FLD_ALIENHOU : Begin
            StringFellowHawk (CHR_KREZNJRK);
            If level = 15 then
              level:=16
            else
            if level = 19 then
              event_happend [27]:=true;
          end;
          FLD_VILLAGE : Begin
            if level in [5, 6] then
            begin
              showscreen (x, y, 0, 0);
              opentextbox;
              ch:=#255
            end;
            stringfellowhawk (CHR_TRACER);
            if level = 5 then
            begin
              stringfellowhawk (CHR_TRACER);
              dec (level);
              updateinfoscrn
            end
            else
            if level = 6 then
            begin
              stringfellowhawk (CHR_TRACER);
              object_found ('Torch', 9, 240+4*16, 17, 'received.');
              field [56, 8]:=52;
              level:=5;
              updateinfoscrn;
              level:=7
            end
          End;
          FLD_HOUSE5 : StringFellowHawk (CHR_SASKIA);
        End;
      End;
      If TouchedHuman [2] = True then begin
        touchedcount:=30;
        Case Area of
          FLD_ALIENHOU : Begin
            If level < 19 then StringFellowHawk (CHR_CAW) else begin
              If Object_Present (6) then begin
                levelbak:=level;
                StringFellowHawk (CHR_CAW);
                t4:=level;
                level:=levelbak;
                levelbak:=t4 - levelbak;
                SolidBox (11, 146, 249, 189, 1);
                If levelbak = 1 then begin
                  Font. SetFGColor (14);
                  OutText (15, 147, '[CAW]');
                  Font. SetFGColor (15);
                  TextBoxLine (155, 'Too bad...');
                  Blinking_Cursor;
                  UpdateInfoScrn;
                End else begin
                  Font. SetFGColor (14);
                  OutText (15, 147, '[CAW]');
                  Font. SetFGColor (15);
                  TextBoxLine (155, 'Thanks.. Here you are !');
                  Remove_Object (6);
                  Inc (money, 2000);
                  Blinking_Cursor;
                  UpdateInfoScrn;
                End;
              End else begin
                UsePage (0);
                OpenTextBox;
                Font. SetFGColor (14);
                OutText (15, 147, '[CAW]');
                Font. SetFGColor (15);
                TextBoxLine (155, 'Hi Mace, like my watch ?');
                Blinking_Cursor;
                UpdateInfoScrn;
              End;
            End;
          End;
          FLD_VILLAGE  : StringFellowHawk (CHR_FRANK);
          FLD_HOUSE2   : Begin
            StringFellowHawk (CHR_LEE);
            If level = 14 then Inc (level);
          End;
        End;
      End;
      If TouchedHuman [3] = True then begin
        touchedcount:=30;
        Case Area of
          FLD_Village : StringFellowHawk (CHR_WILLY);
          FLD_HOUSE1  : StringFellowHawk (CHR_WALLY);
        End;
      End;
      If Touchedhuman [4] = True then begin
        touchedcount:=30;
        Case Area of
          FLD_HOUSE4  : begin
            StringFellowHawk (CHR_JOHN);
            If level = 21 then begin
              Inc (level);
              object_found ('Spade', 10, 240, 34, 'obtained.')
            end
          End;
          FLD_VILLAGE : StringFellowHawk (CHR_CHICKEN1)
        End
      End;
      If Touchedhuman [5] = True then begin
        touchedcount:=30;
        Case Area of
          FLD_VILLAGE  : StringFellowHawk (CHR_CHICKEN2);
          FLD_CADDMAN  : begin
            if level = 50 then
              stringfellowhawk (CHR_MACE)
            else
              stringfellowhawk (CHR_CADDMAN);
            if level = 37 then
            begin
              level:=38;
              remove_object (17);
              object_found ('Dark Potion', 15, 240, 51, 'received.');
              showscreen (x, y, 0, 0);
              ch:=#255;
              stringfellowhawk (CHR_CADDMAN);
              area:=FLD_ENTRANCE;
              x:=18;
              y:=8;
              level:=39;
              direction:=2;
              ch:=#255;
              exitlevel:=true
            end
          end
        end
      end;
      If Touchedhuman [6] = True then begin
        touchedcount:=30;
        Case Area of
          FLD_VILLAGE  : StringFellowHawk (CHR_CHICKEN1);
        End;
      End;
      If Touchedhuman [7] = True then begin
        touchedcount:=30;
        case area of
          FLD_VILLAGE  : StringFellowHawk (CHR_CHICKEN2)
        end
      end
    end
  until keypressed or exitlevel;
  if mace_is_a_dead_man then
    exit;
  if not exitlevel then
    ch:=readkey;
  if (ch = #13) or (ch = #27) then
    mainmenu
  else
  if ch = #0 then
  begin
    ch:=readkey;
    If ch = #72 then
    begin
      if direction <> 3 then
      begin
        direction:=1;
        If (y > 00) and ((cellstatus [field [x, y - 1]] = 0)) then
        begin
          ShowScreen (x, y, 0, 1);
          y:=y - 1
        end
        else
          showscreen (x, y, 0, 0)
      end
      else
      begin
        direction:=2;
        showscreen (x, y, 0, 0)
      end;
    end
    else
    If ch = #77 then
    begin
      if direction < 4 then
      begin
        direction:=2;
        If (x < 99) and ((cellstatus [field [x + 1, y]] = 0)) then
        begin
          ShowScreen (x, y, 2, 0);
          x:=x + 1
        End
        else
          ShowScreen (x, y, 0, 0)
      end
      else
      begin
        direction:=3;
        showscreen (x, y, 0, 0)
      end
    End
    else
    If ch = #80 then
    begin
      if direction > 1 then
      begin
        direction:=3;
        If (y < 99) and ((cellstatus [field [x, y + 1]] = 0)) then begin
          ShowScreen (x, y, 0, 2);
          y:=y + 1
        End
        else
          showscreen (x, y, 0, 0)
      end
      else
      begin
        direction:=4;
        showscreen (x, y, 0, 0)
      end
    end
    else
    If ch = #75 then
    begin
      if direction <> 2 then
      begin
        direction:=4;
        If (x > 00) and ((cellstatus [field [x - 1, y]] = 0)) then begin
          ShowScreen (x, y, 1, 0);
          x:=x - 1
        End
        else
          ShowScreen (x, y, 0, 0);
      end
      else
      begin
        direction:=1;
        showscreen (x, y, 0, 0)
      end
    End
    else
    If ch = #59 then
    begin
      font. setfgcolor (14);
      showscreen (x, y, 0, 0);
      usepage (0);
      if wavetable_on then
      begin
        stopsong;
        outtext (12, 10, 'music: off');
        wavetable_on:=false
      End
      else
      begin
        outtext (12, 10, 'music: on');
        wavetable_on:=true;
        playsong
      end;
      sleep (50)
    end
    else
    if ch = #60 then
    begin
      showscreen (x, y, 0, 0);
      font. setfgcolor (14);
      usepage (0);
      if battle_music then
      begin
        battle_music:=false;
        outtext (12, 10, 'battle music: off')
      end
      else
      begin
        battle_music:=true;
        outtext (12, 10, 'battle music: on')
      end;
      sleep (50)
    end
    else
    if ch = #61 then
    begin
      font. setfgcolor (14);
      showscreen (x, y, 0, 0);
      usepage (0);
      if sound_on then
      begin
        outtext (12, 10, 'sound: off');
        sound_on:=false
      end
      else
      begin
        outtext (12, 10, 'sound: on');
        sound_on:=true
      end;
      sleep (50)
    end;
    If exp >= exp_nextlevel then begin
      exp:=0;
      PlaySample ('Tbeep.voc');
      If maxlife > 200 then
        Inc (maxlife, 100);
      Inc (maxlife, 100);
      If maxlife > 1384 then
        maxlife:=1384;
      life:=maxlife;
      exp_nextlevel:=exp_nextlevel * 2;
      UpdateInfoScrn;
    end
  end;
  if exitlevel then
    ch:=#255
end;

procedure fake_attack_screen;
begin
  song. fading:=8;
  repeat until not song. playing;
  usepage (0);
  t2:=72;
  t1:=71;
  loadsong ('MTP\AVALON07.MTP');
  playsong;
  repeat
    solidbox (8, t2, 311, t1, 0);
    waitforretrace;
    inc (t1, 4);
    dec (t2, 4);
  until t1 > 135;
  opentextbox;
  delay (700);
  showscreen (x, y, 0, 0);
  updateinfoscrn;
  stopsong;
end;

procedure RTN_Village;
var t1 : integer;
begin
  updateinfoscrn;
  if ((song. filename <> 'MTP\AVALON02.MTP') or not song. playing) and ((level < 33) or (level > 44) and (level < 50)) then
  begin
    while song. playing do
      song. fading:=8;
    loadsong ('MTP\AVALON02.MTP');
    playsong
  end
  else
  if ((song. filename <> 'MTP\AVALON21.MTP') or not song. playing) and (level in [33..44]) then
  begin
    while song. playing do
      song. fading:=8;
    loadsong ('MTP\AVALON21.MTP');
    playsong
  end
  else
  if ((song. filename <> 'MTP\AVALON34.MTP') or not song. playing) and (level = 50) then
  begin
    while song. playing do
      song. fading:=8;
    loadsong ('MTP\AVALON34.MTP');
    playsong
  end;
  usepage (1);
  load_pcx (0, 0, 320, 200, 'CELLS', false);
  usePage (2);
  load_pcx (0, 0, 320, 200, 'CHARPAG1', false);
  if level in [00..33] then
    assign (f, 'DAT\FIELD.DAT')
  else
  if level in [34..44] then
    assign (f, 'DAT\FIELD2.DAT')
  else
  if level in [45..49] then
    assign (f, 'DAT\FIELD3.DAT')
  else
  if level = 50 then
    assign (f, 'DAT\FIELD4.DAT');
  init_Level;
  { mensen }
  if (level < 31) or (level = 50) then
  begin
    if level < 27 then
    begin
      human [1]. ID:=17; human [1]. x:=27; human [1]. y:=22; {Tracer}
    end;
    human [2]. ID:=51; human [2]. x:=13; human [2]. y:=40;
    if level < 50 then
    begin
      human [3]. ID:=34; human [3]. x:=55; human [3]. y:=12
    end
    else
    begin
      human [3]. ID:=34; human [3]. x:=09; human [3]. y:=20;
    end
  end;
  { kippen }
  human [4]. ID:=170; human [4]. x:=40; human [4]. y:=45;
  human [5]. ID:=170; human [5]. x:=36; human [5]. y:=45;
  human [6]. ID:=170; human [6]. x:=44; human [6]. y:=43;
  human [7]. ID:=170; human [7]. x:=32; human [7]. y:=45;
  if ((level > 12) and (level < 41)) or (level = 50) then
  begin
    { Lee's deur open }
    field [12, 26]:=41;
    trans [12, 26]:=41;
    field [12, 27]:=42;
  End;
  If object_present (7) then
    field [75, 2]:=1;
  if level > 6 then
    field [56, 8]:=52;
  if (level = 50) and not event_happend [30] then
  begin
    event_happend [30]:=true;
    human [8]. ID:=153;
    human [8]. x:=03;
    human [8]. y:=59;
    human [8]. dir:=3;
    showscreen (x, y, 0, 0);
    level:=51;
    stringfellowhawk (CHR_CADDMAN);
    level:=50;
    for t1:=1 to 2 do
    begin
      dec (human [8]. y);
      start_timer (3);
      human [8]. dir:=1;
      human [8]. yplus:=8;
      human [8]. spritenr:=true;
      showscreen (x, y, 0, 0);
      wait_for_timer (false);
      human [8]. yplus:=0;
      human [8]. spritenr:=false;
      start_timer (3);
      wait_for_timer (false);
      showscreen (x, y, 0, 0)
    end;
    human [8]. ID:=0;
    showscreen (x, y, 0, 0);
  end;
  repeat
    GameLoop;
    if ch = #255 then
      exit;
    if (x = 82) and (y = 58) and (direction = 2) then
    begin
      { Mace uses boat to go to the mountains }
      direction:=0;
      t1:=83;
      while t1 < 96 do
      begin
        field [t1, 57]:=0;
        field [t1, 58]:=0;
        field [t1 + 1, 57]:=121;
        field [t1 + 1, 58]:=122;
        field [t1 + 2, 57]:=123;
        field [t1 + 2, 58]:=124;
        field [t1 + 3, 57]:=125;
        field [t1 + 3, 58]:=126;
        showscreen (t1, y, 0, 0);
        field [t1 + 1, 57]:=127;
        field [t1 + 1, 58]:=128;
        field [t1 + 2, 57]:=129;
        field [t1 + 2, 58]:=130;
        field [t1 + 3, 57]:=131;
        field [t1 + 3, 58]:=132;
        field [t1 + 4, 57]:=133;
        field [t1 + 4, 58]:=134;
        showscreen (t1, y, 2, 0);
        t1:=t1 + 1
      end;
      x:=34;
      direction:=2;
      area:=FLD_SNOW;
      ch:=#255;
      y:=85
    end;
    If (x = 56) and (y = 9) and (ch = #72) and (level < 7) then
    begin
      showscreen (x, y, 0, 0);
      opentextbox;
      textboxline (155, 'The sign says: "DANGER, DO NOT ENTER !"');
      blinking_cursor;
      updateinfoscrn;
    End;
    If (x = 8) and (y = 15) and (ch = #72) and (level < 31) then begin
      StringFellowHawk (CHR_FLEUR);
      If level = 1 then Inc (level);
      If level = 3 then begin
        Remove_Object (3);
        Inc (level)
      End
    End;
    if (x = 24) and (y = 19) and (ch = #72) and (level = 50) then
    begin
      stringfellowhawk (CHR_FLEUR);
      FadeOut;
      while song. playing do
        song. fading:=4;
      execute ('ENDDEMO.EXE', 'MIGCODE');
      clrkey;
      while keypressed do
        ch:=readkey;
      introscreen;
      gameover:=false;
      mace_is_a_dead_man:=true;
      clrkey;
      exit;
    end;
    if (x = 19) and (y = 42) and (ch = #72) and (level > 44) then
      stringfellowhawk (CHR_FLEUR);
    If (x = 75) and (y = 2) and (not object_present (7)) then
    begin
      field [75, 2]:=1;
      object_found ('Silver Key', 7, 240+2*16, 17, 'Found...')
    end
    else
    If (x = 9) and (y = 13) then begin
      ch:=#255;
      ShowScreen (x, y, 0, 0);
      x:=8;
      y:=6;
      Area:=FLD_HOUSE1
    End
    else
    If (x = 12) and (y = 26) then begin
      ch:=#255; ShowScreen (x, y, 0, 0);
      x:=10;
      y:=18;
      Area:=FLD_HOUSE2
    End
    else
    If (x = 23) and (y = 17) then begin
      ch:=#255; ShowScreen (x, y, 0, 0);
      x:=30;
      y:=20;
      Area:=FLD_HOUSE3
    End
    else
    If (x = 27) and (y = 26) then begin
      ch:=#255; ShowScreen (x, y, 0, 0);
      x:=15;
      y:=29;
      Area:=FLD_HOUSE4
    End
    else
    If (x = 12) and (y = 37) then begin
      ch:=#255; ShowScreen (x, y, 0, 0);
      x:=41;
      y:=8;
      Area:=FLD_HOUSE5
    End
    else
    If (x = 42) and (y = 38) then begin
      ch:=#255; ShowScreen (x, y, 0, 0);
      x:=28;
      y:=34;
      Area:=FLD_SHOP
    End
    else
    If (x = 51) and (y = 21) then begin
      ch:=#255; ShowScreen (x, y, 0, 0);
      x:=47;
      y:=19;
      Area:=FLD_WEAPONS
    End
    else
    If (x = 03) and (y = 57) then begin
      ch:=#255; ShowScreen (x, y, 0, 0);
      x:=2;
      y:=43;
      Area:=FLD_CADDMAN
    End
    else
    If (x = 88) and (y = 4) then begin
      ch:=#255; ShowScreen (x, y, 0, 0);
      x:=13;
      y:=95;
      Area:=FLD_FOREST
    End
    else
    If (x = 56) and (y = 8) then begin
      ch:=#255; ShowScreen (x, y, 0, 0);
      x:=5;
      y:=93;
      Area:=FLD_Cave
    End
    else
    if (x = 51) and (y = 51) and not event_happend [17] then
    begin
      ShowScreen (x, y, 0, 0);
      event_happend [17]:=True;
      OpenTextBox;
      Font. SetFGColor (14);
      PlaySample ('Tbeep2.voc');
      TextBoxLine (155, '2 PARALYSERS FOUND.');
      For t1:=1 to 2 do
        Add_Item ('PARALYSER', 7);
      Blinking_Cursor;
      UpdateInfoScrn
    end;
  Until (ch = #255) or (Mace_is_a_dead_man);
End;

Procedure RTN_Cave;
Begin
  updateinfoscrn;
  While song. playing do
    song. fading:=8;
  LoadSong ('MTP\AVALON15.MTP');
  PlaySong;
  UsePage (1);
  Load_PCX (0, 0, 319, 199, arean [FLD_CAVE]. filen, False);
  UsePage (2);
  Load_PCX (0, 0, 319, 199, 'charpag1', False);
  Assign (f, 'DAT\CAVE.DAT');
  init_level;
  t2:=1;
  For t1:=1 to 14 do begin
    monster [t1]. ID:=102;
    monster [t1]. Number:=t2;
    If random (10) > 3 then Inc (t2, 1);
    If t2 = 5 then t2:=1;
    If random (10) > 5 then Inc (monster [t1].number, (Random (3) + 1) * 10);
  End;
  monster [01]. x:=04; monster [01]. y:=80; monster [02]. x:=13; monster [02]. y:=80;
  monster [03]. x:=23; monster [03]. y:=81; monster [04]. x:=23; monster [04]. y:=66;
  monster [05]. x:=11; monster [05]. y:=39; monster [06]. x:=12; monster [06]. y:=41;
  monster [07]. x:=15; monster [07]. y:=42; monster [08]. x:=19; monster [08]. y:=44;
  monster [09]. x:=38; monster [09]. y:=08; monster [10]. x:=09; monster [10]. y:=65;
  monster [11]. x:=23; monster [11]. y:=74; monster [12]. x:=01; monster [12]. y:=90;
  monster [13]. x:=07; monster [13]. y:=29; monster [14]. x:=49; monster [14]. y:=50;
  bigmonster [1]. life:=30; bigmonster [1]. power:=25; bigmonster [1]. defence:=10; bigmonster [1]. name:='Rapton';
  bigmonster [2]. life:=40; bigmonster [2]. power:=35; bigmonster [2]. defence:=15; bigmonster [2]. name:='Norit';
  bigmonster [3]. life:=50; bigmonster [3]. power:=25; bigmonster [3]. defence:=15; bigmonster [3]. name:='Wasp';
  bigmonster [4]. life:=30; bigmonster [4]. power:=25; bigmonster [4]. defence:=10; bigmonster [4]. name:='Rapton';
  monsterfilename:='monstera';
  if level > 9 then begin
    field [28, 34]:=132;
    field [28, 35]:=133;
  end;
  if level >= 9 then
    field [16, 35]:=1;
  repeat
    gameloop;
    if ch = #255 then
      exit;
    If (x = 5) and (y = 94) then begin
      ch:=#255; ShowScreen (x, y, 0, 0);
      x:=56;
      y:=9;
      Area:=FLD_Village;
    End;
    If (x = 16) and (y = 36) and (level in [7, 8]) then begin
      level:=9;
      StringFellowHawk (CHR_SNAKE);
      monster [1]. number:=1;
      monsterfilename:='em1';
      bigmonster [1]. life:=100; bigmonster [1]. power:=50; bigmonster [1]. defence:=15; bigmonster [1]. name:='Snake';
      hitmonster:=1;
      supermonster:=true;
      AttackScreen;
      monsterfilename:='monstera';
      bigmonster [1]. life:=40; bigmonster [1]. power:=30; bigmonster [1]. defence:=10; bigmonster [1]. name:='Brown Curd';
      field [16, 35]:=1;
      ch:=#251
    End;
    If (x = 63) and (y = 30) then begin
      ch:=#255; ShowScreen (x, y, 0, 0);
      x:=10;
      y:=16;
      Area:=FLD_Beach1
    End;
    if (x = 42) and (y = 59) and not event_happend [1] then
    begin
      event_happend [1]:=True;
      object_found ('Pick-Axe', 13, 240+3*16, 34, 'aquired.')
    end
  Until (ch = #255) or (Mace_is_a_dead_man);
End;

Procedure RTN_Beach1;
Begin
  updateinfoscrn;
  if (song. filename <> 'MTP\AVALON24.MTP') or not song. playing then
  begin
    while song. playing do
      song. fading:=8;
    loadsong ('MTP\AVALON24.MTP');
    playsong
  end;
  UsePage (1);
  Load_PCX (0, 0, 319, 199, arean [FLD_BEACH1]. filen, False);
  UsePage (2);
  Load_PCX (0, 0, 319, 199, 'charpag1', False);
  Assign (f, 'DAT\beach1.dat');
  init_level;
  t2:=1;
  For t1:=1 to 20 do begin
    monster [t1]. ID:=102;
    monster [t1]. Number:=t2;
    If random (10) > 3 then Inc (t2, 1);
    If t2 = 5 then t2:=1;
    If t2 = 1 then if random (10) > 4 then t2:=Random (2) + 2;
    If random (10) > 5 then for t3:=1 to Random (3) + 1 do inc (monster [t1].number, 10);
  End;
  For t1:=1 to 10 do human [t1]. ID:=0;
  monster [01]. x:=60; monster [01]. y:=07; monster [02]. x:=58; monster [02]. y:=08;
  monster [03]. x:=60; monster [03]. y:=08; monster [04]. x:=58; monster [04]. y:=09;
  monster [05]. x:=60; monster [05]. y:=09; monster [06]. x:=58; monster [06]. y:=10;
  monster [07]. x:=60; monster [07]. y:=10; monster [08]. x:=58; monster [08]. y:=11;
  monster [09]. x:=60; monster [09]. y:=11; monster [10]. x:=58; monster [10]. y:=12;
  monster [11]. x:=60; monster [11]. y:=12; monster [12]. x:=58; monster [12]. y:=13;
  monster [13]. x:=60; monster [13]. y:=13; monster [14]. x:=58; monster [14]. y:=07;
  monster [15]. x:=62; monster [15]. y:=08; monster [16]. x:=30; monster [16]. y:=10;
  monster [17]. x:=62; monster [17]. y:=09; monster [18]. x:=45; monster [18]. y:=11;
  monster [19]. x:=62; monster [19]. y:=10; monster [20]. x:=32; monster [20]. y:=08;
  bigmonster [3]. life:=40; bigmonster [3]. power:=45; bigmonster [3]. defence:=10; bigmonster [3]. name:='Atomic Waste';
  bigmonster [2]. life:=50; bigmonster [2]. power:=40; bigmonster [2]. defence:=20; bigmonster [1]. name:='Brontosaurus';
  bigmonster [4]. life:=60; bigmonster [4]. power:=30; bigmonster [4]. defence:=15; bigmonster [4]. name:='Jellyfish';
  bigmonster [1]. life:=70; bigmonster [1]. power:=35; bigmonster [1]. defence:=10; bigmonster [2]. name:='Spectre';
  monsterfilename:='monsterc';
  Repeat
    GameLoop;
    if ch = #255 then
      exit;
    If (x = 10) and (y = 15) then begin
      ch:=#255; ShowScreen (x, y, 0, 0);
      x:=63;
      y:=29;
      Area:=FLD_Cave;
    End;
    If x > 89 then begin
      ch:=#255; ShowScreen (x, y, 0, 0);
      x:=10;
      Area:=FLD_Beach2;
    End;
  Until (area <> FLD_BEACH1) or (ch = #255) or (Mace_is_a_dead_man);
End;

Procedure RTN_Beach2;
Begin
  updateinfoscrn;
  if (song. filename <> 'MTP\AVALON24.MTP') or not song. playing then
  begin
    while song. playing do
      song. fading:=8;
    loadsong ('MTP\AVALON24.MTP');
    playsong
  end;
  usePage (1);
  load_pcx (0, 0, 319, 199, arean [FLD_BEACH2]. filen, false);
  UsePage (2);
  Load_PCX (0, 0, 319, 199, 'charpag1', False);
  Assign (f, 'DAT\beach2.dat');
  init_level;
  t2:=1;
  For t1:=1 to 10 do human [t1]. ID:=0;
  For t1:=1 to 20 do monster [t1]. ID:=0;
  If level > 14 then begin
    { Kreznjerk weg }
    field [83, 07]:=011;
    field [83, 08]:=011;
    { Deur naar alien-dorp open }
    field [82, 20]:=109;
    trans [82, 20]:=098;
  End;
  Repeat
    GameLoop;
    if ch = #255 then
      exit;
    If x < 10 then begin
      ch:=#255; ShowScreen (x, y, 0, 0);
      x:=89;
      Area:=FLD_Beach1;
    End else if (x = 90) and (y = 14) then begin
      ch:=#255; ShowScreen (x, y, 0, 0);
      x:=17;
      y:=93;
      Area:=FLD_Cave2;
    End else if (x = 83) and (y = 8) and (ch = #72) and (level < 15) then begin
      ShowScreen (x, y, 0, 0);
      if level = 10 then
      begin
        fake_attack_screen;
        loadsong ('MTP\AVALON08.MTP');
        playsong
      end;
      StringFellowHawk (CHR_KREZNJRK);
      If level = 10 then begin
        object_found ('Blue Crystal', 11, 240+1*16, 34, 'received.');
        level:=11;
        while song. playing do
          song. fading:=8;
        loadsong ('MTP\AVALON24.MTP');
        playsong
      End
    End;
    If (y < 6) and (level < 11) then
      y:=6;
    If (y < 5) then begin
      ch:=#255; ShowScreen (x, y, 0, 0);
      Dec (x, 31);
      y:=95;
      Area:=FLD_Water;
    End;
    If (x = 82) and (y = 24) then begin
      ch:=#255; ShowScreen (x, y, 0, 0);
      x:=52;
      y:=51;
      Area:=FLD_Alienvil;
    End;
  Until (area <> FLD_BEACH2) or (ch = #255) or (Mace_is_a_dead_man);
End;

Procedure RTN_Alienvil;
Begin
  updateinfoscrn;
  If song. filename <> 'MTP\AVALON16.MTP' then begin
    While song. playing do song. fading:=8;
    LoadSong ('MTP\AVALON16.MTP');
    PlaySong;
  End;
  UsePage (1);
  Load_PCX (0, 0, 319, 199, arean [FLD_ALIENVIL]. filen, False);
  UsePage (2);
  Load_PCX (0, 0, 319, 199, 'aliencha', False);
  Assign (f, 'DAT\alienvil.dat');
  init_level;
  t2:=1;
  For t1:=1 to 10 do human [t1]. ID:=0;
  For t1:=1 to 20 do monster [t1]. ID:=0;
  human [1]. ID:=17; human [1]. x:=32; human [1]. y:=90; human [1]. dir:= 1;
  Repeat
    GameLoop;
    if ch = #255 then
      exit;
    If (x = 52) and (y = 50) then begin
      ch:=#255; ShowScreen (x, y, 0, 0);
      x:=82;
      y:=23;
      Area:=FLD_Beach2;
    End else If (x = 43) and (y = 60) then begin
      ch:=#255; ShowScreen (x, y, 0, 0);
      x:=06;
      y:=03;
      direction:=3;
      Area:=FLD_Alienhou;
    End else If (x = 59) and (y = 63) then begin
      ch:=#255; ShowScreen (x, y, 0, 0);
      x:=29;
      y:=12;
      direction:=3;
      Area:=FLD_Alienhou;
    End else If (x = 62) and (y = 75) then begin
      ch:=#255; ShowScreen (x, y, 0, 0);
      x:=18;
      y:=20;
      direction:=3;
      Area:=FLD_Alienhou;
    End else If (x = 46) and (y = 86) then begin
      ch:=#255; ShowScreen (x, y, 0, 0);
      x:=05;
      y:=23;
      direction:=3;
      Area:=FLD_Alienhou;
    End else If (x = 30) and (y = 83) then begin
      ch:=#255; ShowScreen (x, y, 0, 0);
      x:=42;
      y:=25;
      direction:=3;
      Area:=FLD_Alienhou;
    End;
  Until (area <> FLD_ALIENVIL) or (ch = #255) or (Mace_is_a_dead_man);
End;

Procedure RTN_Alienhou;
Begin
  updateinfoscrn;
  If song. filename <> 'MTP\AVALON16.MTP' then begin
    While song. playing do song. fading:=8;
    LoadSong ('MTP\AVALON16.MTP');
    PlaySong;
  End;
  UsePage (1);
  Load_PCX (0, 0, 319, 199, arean [FLD_ALIENHOU]. filen, False);
  UsePage (2);
  Load_PCX (0, 0, 319, 199, 'aliencha', False);
  Assign (f, 'DAT\alienhou.dat');
  init_level;
  human [1]. ID:=51; human [1]. x:=06; human [1]. y:=10; human [1]. dir:=1;
  human [2]. ID:=17; human [2]. x:=20; human [2]. y:=22; human [2]. dir:=2;
  Repeat
    GameLoop;
    if ch = #255 then
      exit;
    If (x = 34) and (y = 10) and (ch = #72) then begin
      StringFellowHawk (CHR_KNARF);
      If level > 18 then begin
        SolidBox (11, 146, 249, 189, 1);
        DrawFrame (10, 145, 250, 190, 15);
        Font. SetFGColor (14);
        OutText (15, 147, '[KNARF]');
        Font. SetFGColor (15);
        TextBoxLine (155, 'Select the item you want to buy...');
        t2:=1;
        t3:=0;
        Repeat
          UsePage (3);
          DrawFrame (88, 8, 231, 122, 15);
          SolidBox (89, 9, 230, 121, 1);
          SolidBox (90, 5 + t2 * 8 + t3, 228, 12 + t2 * 8 + t3, 4);
          For t1:=1 to 13 do begin
            OutText (100, 6 + t1 * 8, itemcon [t1]. name);
            OutText (186, 6 + t1 * 8, '$ ' + Str2 (itemcon [t1]. price));
          End;
          BlockPageToPage (3, 8, 88, 1, 36, 124, 88, 10);
          If t3 = 0 then begin
            ch:=Readkey; If ch = #0 then ch:=Readkey;
              If (ch = #72) and (t2 > 1) then t3:= -1;
              If (ch = #80) and (t2 < 13) then t3:=1;
              If ch = #13 then begin
              PlaySample ('switch.voc');
              UsePage (0);
              SolidBox (11, 146, 249, 189, 1);
              DrawFrame (10, 145, 250, 190, 15);
              Font. SetFGColor (14);
              OutText (15, 147, '[KNARF]');
              Font. SetFGColor (15);
              TextBoxLine (155, 'The ' + itemcon [t2]. name + '.');
              TextBoxLine (163, itemcon [t2]. comment);
              TextBoxLine (179, 'Buy it ?');
              t4:=0;
              Repeat
                If t4 = 0 then begin
                  SolidBox (108, 178, 125, 185, 4);
                  SolidBox (128, 178, 145, 185, 1);
                End else begin
                  SolidBox (108, 178, 125, 185, 1);
                  SolidBox (128, 178, 145, 185, 4);
                End;
                OutText (110, 179, 'YES');
                OutText (130, 179, 'NO ');
                Repeat
                  ch:=Readkey; If ch = #0 then ch:=Readkey;
                Until (ch = #75) or (ch = #77) or (ch = #13) or (ch = #27);
                PlaySample ('wall.voc');
                If ch = #75 then t4:=0;
                If ch = #77 then t4:=1;
              Until (ch = #13) or (ch = #27);
              PlaySample ('switch.voc');
              If t4 = 0 then begin
                SolidBox (11, 146, 249, 189, 1);
                DrawFrame (10, 145, 250, 190, 15);
                Font. SetFGColor (14);
                OutText (15, 147, '[KNARF]');
                Font. SetFGColor (15);
                t5:=0;
                for t1:=1 to MAXITEMS do
                  if items [t1]. nr > 0 then
                    inc (t5);
                If t5 >= MAXITEMS then begin
                  TextBoxLine (155, 'You have too many items !');
                  Readkey;
                End else if money < itemcon [t2]. price then begin
                  TextBoxLine (155, 'You do not have enough money !');
                  Readkey;
                End else begin
                  TextBoxLine (155, 'Here you are !');
                  Add_item (itemcon [t2]. name, t2);
                  Readkey;
                  Dec (money, itemcon [t2]. price);
                End;
              End;
              SolidBox (11, 146, 249, 189, 1);
              DrawFrame (10, 145, 250, 190, 15);
              Font. SetFGColor (14);
              OutText (15, 147, '[KNARF]');
              Font. SetFGColor (15);
              OutText (15, 155, 'Select the item you want to buy.')
            end
          end
          else
          begin
            if t3 > 0 then
              inc (t3)
            else
              dec (t3);
            if (t3 = 8) or (t3 = -8) then
            begin
              if t3 > 0 then
                inc (t2)
              else
                dec (t2);
              t3:=0
            end
          end
        until (ch = #27);
        updateinfoscrn;
      end;
    end
    else
    if (x = 38) and (y = 23) and (ch = #72) then
    begin
      StringFellowHawk (CHR_NEOREJ);
      If level > 18 then begin
        SolidBox (11, 146, 249, 189, 1);
        DrawFrame (10, 145, 250, 190, 15);
        Font. SetFGColor (14);
        OutText (15, 147, '[NEOREJ]');
        Font. SetFGColor (15);
        TextBoxLine (155, 'Do you want to buy weapons or defence ?');
        WepDefMenu;
        If (ch = #13) and (t2 = 0) then begin
          OutText (15, 147, '[NEOREJ]');
          Font. SetFGColor (15);
          TextBoxLine (155, 'Select a weapon...');
          t2:=1;
          t3:=0;
          Repeat
            UsePage (3);
            WaitForRetrace;
            DrawFrame (88, 28, 232, 82, 15);
            SolidBox (89, 29, 231, 81, 1);
            SolidBox (90, 29 + t2 * 8 + t3, 230, 36 + t2 * 8 + t3, 4);
            For t1:=1 to 5 do
            begin
              OutText (100, 30 + t1 * 8, weaponcon [t1+5]. name);
              OutText (186, 30 + t1 * 8, '$ ' + Str2 (weaponcon [t1+5]. price));
            End;
            BlockPageToPage (3, 0, 88, 27, 37, 56, 88, 28);
            If t3 = 0 then begin
              ch:=Readkey;
              If ch = #0 then
                ch:=Readkey;
              If (ch = #72) and (t2 > 1) then
                t3:=-1;
              If (ch = #80) and (t2 < 5) then
                t3:=1;
              If ch = #13 then
              begin
                PlaySample ('switch.voc');
                UsePage (0);
                SolidBox (11, 146, 249, 189, 1);
                DrawFrame (10, 145, 250, 190, 15);
                Font. SetFGColor (14);
                OutText (15, 147, '[NEOREJ]');
                Font. SetFGColor (15);
                TextBoxLine (155, 'You''ve chosen the ' + weaponcon [t2+5]. name + '.');
                TextBoxLine (163, weaponcon [t2+5]. comment);
                TextBoxLine (179, 'Want to buy it ?');
                t4:=0;
                Repeat
                  If t4 = 0 then begin
                    SolidBox (108, 178, 125, 185, 4);
                    SolidBox (128, 178, 145, 185, 1);
                  End else begin
                    SolidBox (108, 178, 125, 185, 1);
                    SolidBox (128, 178, 145, 185, 4);
                  End;
                  OutText (110, 179, 'YES');
                  OutText (130, 179, 'NO ');
                  Repeat
                    ch:=Readkey; If ch = #0 then ch:=Readkey;
                  Until (ch = #75) or (ch = #77) or (ch = #13) or (ch = #27);
                  PlaySample ('wall.voc');
                  If ch = #75 then t4:=0;
                  If ch = #77 then t4:=1;
                Until (ch = #13) or (ch = #27);
                PlaySample ('switch.voc');
                If t4 = 0 then begin
                  SolidBox (11, 146, 249, 189, 1);
                  DrawFrame (10, 145, 250, 190, 15);
                  Font. SetFGColor (14);
                  OutText (15, 147, '[NEOREJ]');
                  Font. SetFGColor (15);
                  If money < weaponcon [t2+5]. price then begin
                    TextBoxLine (155, 'You can''t afford it !');
                    Readkey;
                  End else if weaponcon [t2+5]. power <= power then begin
                    TextBoxLine (155, 'You already have a better one !');
                    Readkey;
                  End else begin
                    TextBoxLine (155, 'Thank you ! Have fun with it !');
                    weapon:=t2+5;
                    power:=weaponcon [t2+5]. power;
                    Readkey;
                    Dec (money, weaponcon [t2+5]. price);
                  End;
                End;
                SolidBox (11, 146, 249, 189, 1);
                DrawFrame (10, 145, 250, 190, 15);
                Font. SetFGColor (14);
                OutText (15, 147, '[NEOREJ]');
                Font. SetFGColor (15);
                OutText (15, 155, 'Select a weapon...');
              End;
            End else begin
              If t3 > 0 then Inc (t3) else Dec (t3);
              If (t3 = 8) or (t3 = -8) then begin
                If t3 > 0 then Inc (t2) else Dec (t2);
                t3:=0;
              End;
            End;
          Until (ch = #27);
          UpdateInfoScrn;
        end
        else
        if (ch = #13) and (t2 = 1) then
        begin
          OutText (15, 147, '[NEOREJ]');
          Font. SetFGColor (15);
          TextBoxLine (155, 'Select a shield...');
          t2:=1;
          t3:=0;
          Repeat
            UsePage (3);
            WaitForRetrace;
            DrawFrame (88, 28, 232, 82, 15);
            SolidBox (89, 29, 231, 81, 1);
            SolidBox (90, 29 + t2 * 8 + t3, 230, 36 + t2 * 8 + t3, 4);
            For t1:=1 to 5 do begin
              OutText (100, 30 + t1 * 8, shieldcon [t1+5]. name);
              OutText (186, 30 + t1 * 8, '$ ' + Str2 (shieldcon [t1+5]. price));
            End;
            BlockPageToPage (3, 0, 88, 27, 37, 56, 88, 28);
            If t3 = 0 then begin
              ch:=Readkey; If ch = #0 then ch:=Readkey;
              If (ch = #72) and (t2 > 1) then t3:=-1;
              If (ch = #80) and (t2 < 5) then t3:=1;
              If ch = #13 then begin
                PlaySample ('switch.voc');
                UsePage (0);
                SolidBox (11, 146, 249, 189, 1);
                DrawFrame (10, 145, 250, 190, 15);
                Font. SetFGColor (14);
                OutText (15, 147, '[NEOREJ]');
                Font. SetFGColor (15);
                TextBoxLine (155, 'You''ve chosen the ' + shieldcon [t2+5]. name + '.');
                TextBoxLine (163, shieldcon [t2+5]. comment);
                TextBoxLine (179, 'Want to buy it ?');
                t4:=0;
                Repeat
                  If t4 = 0 then begin
                    SolidBox (108, 178, 125, 185, 4);
                    SolidBox (128, 178, 145, 185, 1);
                  End else begin
                    SolidBox (108, 178, 125, 185, 1);
                    SolidBox (128, 178, 145, 185, 4);
                  End;
                  OutText (110, 179, 'YES');
                  OutText (130, 179, 'NO ');
                  Repeat
                    ch:=Readkey; If ch = #0 then ch:=Readkey;
                  Until (ch = #75) or (ch = #77) or (ch = #13) or (ch = #27);
                  PlaySample ('wall.voc');
                  If ch = #75 then t4:=0;
                  If ch = #77 then t4:=1;
                Until (ch = #13) or (ch = #27);
                PlaySample ('switch.voc');
                If t4 = 0 then begin
                  SolidBox (11, 146, 249, 189, 1);
                  DrawFrame (10, 145, 250, 190, 15);
                  Font. SetFGColor (14);
                  OutText (15, 147, '[NEOREJ]');
                  Font. SetFGColor (15);
                  If money < shieldcon [t2+5]. price then begin
                    TextBoxLine (155, 'You do not have enough credits !');
                    Readkey;
                  End else if shieldcon [t2+5]. power <= defence then begin
                    TextBoxLine (155, 'You already have a better one !');
                    Readkey;
                  End else begin
                    TextBoxLine (155, 'Here you are !');
                    shield:=t2+5;
                    defence:=shieldcon [t2+5]. power;
                    Readkey;
                    Dec (money, shieldcon [t2+5]. price);
                  End;
                End;
                SolidBox (11, 146, 249, 189, 1);
                DrawFrame (10, 145, 250, 190, 15);
                Font. SetFGColor (14);
                OutText (15, 147, '[NEOREJ]');
                Font. SetFGColor (15);
                OutText (15, 155, 'Select a shield...')
              end
            end
            else
            begin
              If t3 > 0 then
                Inc (t3)
              else
                Dec (t3);
              If (t3 = 8) or (t3 = -8) then
              begin
                If t3 > 0 then
                    Inc (t2)
                  else
                    Dec (t2);
                t3:=0
              end
            end
          until (ch = #27)
        end
      end;
      UpdateInfoScrn
    end
    else
    if (x = 06) and (y = 2) then
    begin
      ch:=#255; ShowScreen (x, y, 0, 0);
      x:=43;
      y:=61;
      direction:=3;
      Area:=FLD_Alienvil
    end
    else
    if (x = 29) and (y = 11) then
    begin
      ch:=#255; ShowScreen (x, y, 0, 0);
      x:=59;
      y:=64;
      direction:=3;
      Area:=FLD_Alienvil
    end
    else
    if (x = 18) and (y = 19) then
    begin
      ch:=#255; ShowScreen (x, y, 0, 0);
      x:=62;
      y:=76;
      direction:=3;
      Area:=FLD_Alienvil
    end
    else
    if (x = 05) and (y = 22) then
    begin
      ch:=#255; ShowScreen (x, y, 0, 0);
      x:=46;
      y:=87;
      direction:=3;
      Area:=FLD_Alienvil
    end
    else
    if (x = 42) and (y = 24) then
    begin
      ch:=#255; ShowScreen (x, y, 0, 0);
      x:=30;
      y:=84;
      direction:=3;
      Area:=FLD_Alienvil
    end
  until (ch = #255) or (Mace_is_a_dead_man);
end;

Procedure RTN_Castle;
Begin
  updateinfoscrn;
  if area = FLD_Cellar then
  begin
    while song. playing do
      song. fading:=10;
    loadsong ('MTP\AVALON18.MTP');
    playsong
  end
  else
  If song. filename <> 'MTP\AVALON14.MTP' then
  begin
    while song. playing do
      song. fading:=8;
    loadsong ('MTP\AVALON14.MTP');
    playsong
  end;
  usepage (1);
  load_pcx (0, 0, 319, 199, 'castle', false);
  usePage (2);
  load_pcx (0, 0, 319, 199, 'cstlchar', false);
  case area of
    FLD_CASTLE1 : assign (f, 'DAT\CASTLE1.DAT');
    FLD_CASTLE2 : assign (f, 'DAT\CASTLE2.DAT');
    FLD_CASTLE3 : assign (f, 'DAT\CASTLE3.DAT');
    FLD_CELLAR  : assign (f, 'DAT\CELLAR .DAT')
  end;
  init_level;
  t2:=1;
  For t1:=1 to 14 do
  begin
    monster [t1]. ID:=102;
    monster [t1]. Number:=t2;
    if random (10) > 3 then
      inc (t2, 1);
    if t2 = 5 then
      t2:=1;
    if random (10) > 5 then
      inc (monster [t1].number, (Random (3) + 1) * 10)
  End;
  bigmonster [1]. life:=250; bigmonster [1]. power:=110; bigmonster [1]. defence:=30; bigmonster [1]. name:='Goblin';
  bigmonster [2]. life:=500; bigmonster [2]. power:=100; bigmonster [2]. defence:=20; bigmonster [2]. name:='Dark Guard';
  bigmonster [3]. life:=170; bigmonster [3]. power:=090; bigmonster [3]. defence:=40; bigmonster [3]. name:='Little Dragon';
  bigmonster [4]. life:=200; bigmonster [4]. power:=120; bigmonster [4]. defence:=45; bigmonster [4]. name:='Emitorian';
  monsterfilename:='cstlmnst';
  case area of
    FLD_CASTLE1 :
    begin
      monster [01]. x:=44; monster [01]. y:=82; monster [02]. x:=62; monster [02]. y:=83;
      monster [03]. x:=72; monster [03]. y:=89; monster [04]. x:=79; monster [04]. y:=94;
      monster [05]. x:=81; monster [05]. y:=88; monster [06]. x:=75; monster [06]. y:=82;
      monster [07]. x:=54; monster [07]. y:=77; monster [08]. x:=32; monster [08]. y:=72;
      monster [09]. x:=32; monster [09]. y:=77; monster [10]. x:=32; monster [10]. y:=85;
      monster [11]. x:=26; monster [11]. y:=80; monster [12]. x:=26; monster [12]. y:=63;
      monster [13]. x:=11; monster [13]. y:=62; monster [14]. x:=23; monster [14]. y:=96;
      monster [15]. x:=36; monster [15]. y:=96; monster [16]. x:=45; monster [16]. y:=95;
      monster [17]. x:=56; monster [17]. y:=95; monster [18]. x:=64; monster [18]. y:=90;
      monster [19]. x:=68; monster [19]. y:=91; monster [20]. x:=41; monster [20]. y:=67;
    end;
    FLD_CASTLE2 :
    begin
      monster [01]. x:=21; monster [01]. y:=69; monster [02]. x:=28; monster [02]. y:=96;
      monster [03]. x:=23; monster [03]. y:=80; monster [04]. x:=27; monster [04]. y:=68;
      monster [05]. x:=47; monster [05]. y:=62; monster [06]. x:=31; monster [06]. y:=77;
      monster [07]. x:=51; monster [07]. y:=70; monster [08]. x:=57; monster [08]. y:=95;
      monster [09]. x:=54; monster [09]. y:=82; monster [10]. x:=67; monster [10]. y:=96;
      monster [11]. x:=76; monster [11]. y:=89; monster [12]. x:=82; monster [12]. y:=70;
      monster [13]. x:=54; monster [13]. y:=68; monster [14]. x:=62; monster [14]. y:=77;
      monster [15]. x:=81; monster [15]. y:=96; monster [16]. x:=71; monster [16]. y:=77;
      monster [17]. x:=63; monster [17]. y:=95; monster [18]. x:=25; monster [18]. y:=89;
      monster [19]. x:=27; monster [19]. y:=78; monster [20]. x:=81; monster [20]. y:=89;
    end;
    FLD_CASTLE3 :
    begin
      monster [01]. x:=26; monster [01]. y:=69; monster [02]. x:=26; monster [02]. y:=79;
      monster [03]. x:=48; monster [03]. y:=67; monster [04]. x:=32; monster [04]. y:=80;
      monster [05]. x:=33; monster [05]. y:=90; monster [06]. x:=40; monster [06]. y:=95;
      monster [07]. x:=21; monster [07]. y:=96; monster [08]. x:=52; monster [08]. y:=95;
      monster [09]. x:=46; monster [09]. y:=88; monster [10]. x:=62; monster [10]. y:=88;
      monster [11]. x:=64; monster [11]. y:=95; monster [12]. x:=64; monster [12]. y:=82;
      monster [13]. x:=71; monster [13]. y:=94; monster [14]. x:=61; monster [14]. y:=77;
      monster [15]. x:=79; monster [15]. y:=89; monster [16]. x:=81; monster [16]. y:=77;
      monster [17]. x:=51; monster [17]. y:=77; monster [18]. x:=58; monster [18]. y:=77;
      monster [19]. x:=45; monster [19]. y:=82; monster [20]. x:=27; monster [20]. y:=75;
    end;
    FLD_CELLAR :
    begin
      monster [01]. x:=76; monster [01]. y:=90; monster [02]. x:=77; monster [02]. y:=90;
      monster [03]. x:=69; monster [03]. y:=58; monster [04]. x:=68; monster [04]. y:=58;
      monster [05]. x:=51; monster [05]. y:=95; monster [06]. x:=52; monster [06]. y:=95;
      monster [07]. x:=41; monster [07]. y:=97; monster [08]. x:=42; monster [08]. y:=97;
      for t1:=9 to 20 do
        monster [t1]. ID:=0;
    end
  end;
  if (area = FLD_Castle1) and event_happend [13] then
    field [69, 76]:=127;
  ShowPage (0);
  If (area = FLD_Castle2) and event_happend [7] then
    trans [19, 91]:=0;
  If event_happend [14] and (area = FLD_Castle1) then
  begin
    field [27, 88]:=29;
    field [27, 89]:=30;
    field [27, 90]:=31;
    trans [27, 88]:=29;
    trans [27, 89]:=30
  End;
  if (level > 25) and (area = FLD_CASTLE1) then
  begin
    field [37, 64]:=29;
    field [37, 65]:=30;
    field [37, 66]:=31;
    trans [37, 64]:=29;
    trans [37, 65]:=30
  end;
  if (level > 27) and (area = FLD_CASTLE1) then
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
    field [51, 81]:=82
  end;
  if (level in [41, 42, 43]) and (area = FLD_CASTLE1) then
    field [82, 91]:=91;
  repeat
    gameloop;
    if ch = #255 then
      exit;
    if (level in [41, 42, 43]) and (x = 81) and (y = 91) and (ch = #77) and (area = FLD_CASTLE1) then
      stringfellowhawk (CHR_CADDMAN);
    if (x in [63, 64]) and (y = 87) and (direction = 1) then
      stringfellowhawk (CHR_CSIGN);
    if (y < 43) then
    begin
      ch:=#255;
      showscreen (x, y, 0, 0);
      x:=22;
      y:=98;
      area:=FLD_DARKROOM
    end
    else
    if (y > 97) and (x > 49) and (x < 52) and (direction = 3) and (area = FLD_Castle1) then begin
      ch:=#255; ShowScreen (x, y, 0, 0);
      x:=19;
      y:=05;
      Area:=FLD_Entrance
    end
    else
    if (field [x, y] = 130) then begin
      ch:=#255; ShowScreen (x, y, 0, 0);
      Inc (y, 3); { Trapje op }
      Inc (area);
      direction:=1
    end
    else
    if (field [x, y] = 129) then begin
      ch:=#255; ShowScreen (x, y, 0, 0);
      Dec (y, 3); { Trapje af }
      Dec (area);
      direction:=1
    end;
    if area = FLD_Castle1 then
    begin
      if (x = 33) and (y = 57) and (direction = 1) and (level = 26) then
      begin
        level:=27;
        object_found ('Access-card', 4, 240+4*16, 0, 'Taken!')
      end;
      if (x = 53) and (y = 93) and (direction = 1) and not event_happend [8] then
      begin
        ShowScreen (x, y, 0, 0);
        object_found ('Lifejug', 12, 240+2*16, 32, 'Found!');
        event_happend [8]:=True
      end
      else
      if (x = 54) and (y = 93) and (direction = 1) and not event_happend [9] then
      begin
        ShowScreen (x, y, 0, 0);
        event_happend [9]:=True;
        Inc (money, 500);
        OpenTextBox;
        Font. SetFGColor (14);
        PlaySample ('Tbeep2.voc');
        TextBoxLine (155, '500 GOLD discovered !');
        Blinking_Cursor;
        UpdateInfoScrn
      End
      else
      if (x = 55) and (y = 93) and (direction = 1) and not event_happend [10] then
      begin
        ShowScreen (x, y, 0, 0);
        event_happend [10]:=True;
        OpenTextBox;
        Font. SetFGColor (14);
        PlaySample ('Tbeep2.voc');
        TextBoxLine (155, '3 HIV-VIRUSSES TAKEN.');
        For t1:=1 to 3 do
          Add_Item ('HIV VIRUS', 12);
        Blinking_Cursor;
        UpdateInfoScrn
      end
      else
      if (x = 57) and (y = 93) and (direction = 1) and (area = FLD_Castle1) then
      begin
        ShowScreen (x, y, 0, 0);
        UsePage (0);
        OpenTextBox;
        TextBoxLine (155, 'Mace looks inside the box.....');
        Delay (500);
        mace_is_a_dead_man:=true;
      End
      else
      if (x = 58) and (y = 93) and (direction = 1) and not event_happend [11] then
      begin
        ShowScreen (x, y, 0, 0);
        event_happend [11]:=True;
        OpenTextBox;
        Font. SetFGColor (14);
        PlaySample ('Tbeep2.voc');
        TextBoxLine (155, '2 LARGE MEDIC KITS FOUND.');
        for t1:=1 to 2 do
          Add_Item ('LARGE MEDIC KIT', 4);
        Blinking_Cursor;
        UpdateInfoScrn
      end
      else
      if (x = 59) and (y = 93) and (direction = 1) and not event_happend [12] then
      begin
        ShowScreen (x, y, 0, 0);
        event_happend [12]:=True;
        OpenTextBox;
        Font. SetFGColor (14);
        PlaySample ('Tbeep2.voc');
        TextBoxLine (155, 'HEAVY GRENADE found !');
        Add_Item ('HEAVY GRENADE', 5);
        Blinking_Cursor;
        UpdateInfoScrn
      end;
    end;
    if (x = 19) and (y = 91) and not event_happend [7] and (area = FLD_Castle2) then
    begin
      event_happend [7]:=True;
      trans [19, 91]:=0;
      Inc (money, 750);
      OpenTextBox;
      Font. SetFGColor (14);
      PlaySample ('Tbeep2.voc');
      TextBoxLine (155, '750 GOLD discovered !');
      Blinking_Cursor;
      UpdateInfoScrn
    end
    else
    if (x = 84) and (y > 89) and (y < 92) and (area = FLD_Castle1) then
    begin
      ch:=#255; ShowScreen (x, y, 0, 0);
      x:=10;
      Dec (y, 67);
      area:=FLD_DUNGEON
    end
    else
    if (x = 69) and (y = 76) and not event_happend [13] and (area = FLD_Castle1) then
    begin
      event_happend [13]:=True;
      object_found ('Golden Key', 14, 240+4*16, 33, 'Picked up.');
      field [69, 76]:=127
    end
    else
    if (x = 5) and (y = 55) and (area = FLD_CASTLE1) then
    begin
      ch:=#255;
      ShowScreen (x, y, 0, 0);
      x:=86;
      y:=09;
      area:=FLD_GARDEN
    end
    else
    if (x in [50, 51]) and (y = 46) and (level in [28, 41]) then
    begin
      showscreen (x, y, 0, 0);
      StringFellowHawk (CHR_TRACER);
      stopsong;
      monster [1]. number:=1;
      monsterfilename:='tracer';
      if level = 29 then
      begin
        bigmonster [1]. life:=3000;
        bigmonster [1]. power:=300;
        bigmonster [1]. defence:=0
      end
      else
      begin
        bigmonster [1]. life:=3000;
        bigmonster [1]. power:=500;
        bigmonster [1]. defence:=225;
      end;
      bigmonster [1]. name:='Esor Amreh';
      hitmonster:=1;
      supermonster:=true;
      attackscreen;
      if mace_is_a_dead_man and (life > 0) and (level < 40) then
        level:=31;
      bigmonster [1]. life:=250;
      bigmonster [1]. power:=110;
      bigmonster [1]. defence:=30;
      bigmonster [1]. name:='Goblin';
      monsterfilename:='cstlmnst';
      if (level > 40) and (not mace_is_a_dead_man) then
      begin
        showscreen (x, y, 0, 0);
        opentextbox;
        playsample ('beep2.voc');
        textboxline (155, 'VAPORIZOR TAKEN !!');
        blinking_cursor;
        weapon:=11;
        power:=500;
        updateinfoscrn
      end
    end
  Until (ch = #255) or (Mace_is_a_dead_man);
End;

Procedure RTN_Dungeon;
Begin
  updateinfoscrn;
  while song. playing do
    song. fading:=8;
  loadsong ('MTP\AVALON25.MTP');
  playsong;
  usepage (1);
  load_pcx (0, 0, 319, 199, 'KERKER', False);
  usepage (2);
  load_pcx (0, 0, 319, 199, 'CHARPAG1', False);
  if level < 44 then
    assign (f, 'DAT\DUNGEON.DAT')
  else
  if level = 44 then
    assign (f, 'DAT\DUNGEON2.DAT')
  else
    assign (f, 'DAT\DUNGEON3.DAT');
  init_level;
  t2:=1;
  for t1:=1 to 10 do
    human [t1]. ID:=0;
  for t1:=1 to 20 do
    monster [t1]. ID:=0;
  If level = 11 then begin
    Dec (y);
    OpenTextBox;
    StringFellowHawk (CHR_LEE);
    Inc (level);
    ShowScreen (x, y, 0, 0);
    StringFellowHawk (CHR_LEE);
    Inc (level);
    field [33, 28]:=61;
    for lee_walks:=1 to 13 do
    begin
      showscreen (x, y, 0, 0);
      delay (200);
    end;
    lee_walks:=0;
  end
  else
  if level > 12 then
    field [33, 28]:=61;
  repeat
    GameLoop;
    if ch = #255 then
      exit;
    if (x = 53) and (y = 20) and (ch = #75) then
    begin
      direction:=4;
      ShowScreen (x, y, 0, 0);
      StringFellowHawk (CHR_REDNAEL);
      if level = 20 then
        level:=21;
    end;
    if (x = 35) and (y = 31) then
    begin
      ch:=#255; ShowScreen (x, y, 0, 0);
      x:=57;
      y:=05;
      Area:=FLD_Entrance
    end else
    if (x = 09) and (y > 22) and (y < 25) then
    begin
      ch:=#255; ShowScreen (x, y, 0, 0);
      x:=83;
      Inc (y, 67);
      area:=FLD_Castle1
    end
    else
    if (level = 44) and (y = 18) and (ch = #72) then
    begin
      showscreen (x, y, 0, 0);
      case x of
        32 : stringfellowhawk (CHR_WALLY);
        33 : stringfellowhawk (CHR_WILLY);
        34 : stringfellowhawk (CHR_FRANK);
        35 : stringfellowhawk (CHR_SASKIA);
        36 : stringfellowhawk (CHR_JOHN)
      end
    end;
    if (level = 44) and (x = 36) and (y = 19) and (ch = #77) then
    begin
      showscreen (x, y, 0, 0);
      stringfellowhawk (CHR_CADDMAN);
      field [37, 19]:=61;
      human [1]. id:=153;
      human [1]. x:=37;
      human [1]. y:=19;
      human [1]. dir:=4;
      direction:=4;
      for x:=35 downto 34 do
      begin
        human [1]. xplus:=-8;
        human [1]. spritenr:=true;
        showscreen (x, y, 2, 0);
        delay (25);
        human [1].spritenr:=false;
        dec (human [1]. x);
        human [1]. xplus:=0;
        showscreen (x, y, 0, 0);
        delay (25)
      end;
      human [1]. dir:=3;
      direction:=3;
      for y:=20 to 23 do
      begin
        human [1].spritenr:=true;
        human [1]. yplus:=8;
        showscreen (x, y, 0, 1);
        delay (25);
        human [1].spritenr:=false;
        inc (human [1]. y);
        human [1]. yplus:=0;
        showscreen (x, y, 0, 0);
        delay (25);
      end;
      direction:=4;
      human [1]. dir:=4;
      for x:=33 downto 8 do
      begin
        human [1]. xplus:=-8;
        human [1].spritenr:=true;
        showscreen (x, y, 2, 0);
        delay (25);
        human [1].spritenr:=false;
        dec (human [1]. x);
        human [1]. xplus:=0;
        showscreen (x, y, 0, 0);
        delay (25)
      end;
      ch:=#255;
      x:=22;
      y:=98;
      area:=FLD_DARKROOM;
      direction:=1;
      human [1]. x:=22;
      human [1]. y:=99;
      human [1]. dir:=1;
      level:=45
    end
  Until (ch = #255) or (Mace_is_a_dead_man);
End;

Procedure RTN_Entrance;
Begin
  updateinfoscrn;
  While song. playing do song. fading:=8;
  LoadSong ('MTP\AVALON11.MTP');
  PlaySong;
  UsePage (1);
  If level < 20 then
    Load_PCX (0, 0, 319, 199, 'entrance', False)
  else
    Load_PCX (0, 0, 319, 199, 'entranc2', False);
  UsePage (2);
  Load_PCX (0, 0, 319, 199, 'charpag1', False);
  Assign (f, 'DAT\entrance.dat');
  init_level;
  if event_happend [5] then
  begin
    field [18, 05]:=069;
    field [18, 06]:=105;
    field [20, 05]:=091;
    field [20, 06]:=116
  end;
  if event_happend [6] then
  begin
    field [57, 4]:=001;
    trans [57, 4]:=142;
    field [57, 5]:=005
  end;
  if level > 19 then
  begin
    CellStatus [70]:=0;
    CellStatus [81]:=0;
    CellStatus [69]:=0
  end;
  if level = 39 then
  begin
    human [1]. ID:=153;
    human [1]. x:=19;
    human [1]. y:=08;
    human [1]. dir:=4;
    human [1]. xplus:=0;
    human [1]. yplus:=0;
    showscreen (x, y, 0, 0);
    stringfellowhawk (CHR_CADDMAN);
    human [1]. dir:=1;
    human [1]. spritenr:=true;
    updateinfoscrn;
    level:=41;
    for human [1]. y:=8 downto 3 do
    begin
      showscreen (x, y, 0, 0);
      start_timer (2);
      wait_for_timer (false);
      human [1]. spritenr:=false;
      human [1]. yplus:=-8;
      showscreen (x, y, 0, 0);
      start_timer (2);
      wait_for_timer (false);
      human [1]. spritenr:=true;
      human [1]. yplus:=0;
    end;
    human [1]. ID:=0
  end;
  Repeat
    GameLoop;
    if ch = #255 then
      exit;
    If (y > 50) and (x < 50) then begin
      ch:=#255; ShowScreen (x, y, 0, 0);
      x:=74;
      y:=05;
      Area:=FLD_Water;
    End;
    If (x = 57) and (y = 04) then begin
      ch:=#255; ShowScreen (x, y, 0, 0);
      x:=35;
      y:=30;
      Area:=FLD_Dungeon;
    End;
    If (x > 17) and (x < 21) and (y = 6) and not event_happend [5] then begin
      StringFellowHawk (CHR_GUARDS);
      event_happend [5]:=True;
      monster [1]. number:=11;
      monsterfilename:='guard2';
      bigmonster [1]. life:=500; bigmonster [1]. power:=100; bigmonster [1]. defence:=20; bigmonster [1]. name:='Dark Guard';
      hitmonster:=1;
      supermonster:=true;
      AttackScreen;
      field [18, 05]:=069;
      field [18, 06]:=105;
      field [20, 05]:=091;
      field [20, 06]:=116;
      ch:=#251;
      direction:=3;
    End;
    If (x > 17) and (x < 21) and (y < 5) and (ch = #72) and (level > 19) then begin
      ch:=#255; ShowScreen (x, y, 0, 0);
      x:=51;
      y:=97;
      Area:=FLD_Castle1;
    End;
  Until (ch = #255) or (Mace_is_a_dead_man);
End;

Procedure RTN_Entrdown;
Begin
  updateinfoscrn;
  While song. playing do song. fading:=8;
  LoadSong ('MTP\AVALON11.MTP');
  PlaySong;
  UsePage (1);
  Load_PCX (0, 0, 319, 199, 'ENTRANCE', False);
  UsePage (2);
  Load_PCX (0, 0, 319, 199, 'CHARPAG1', False);
  Assign (f, 'DAT\ENTRDOWN.DAT');
  init_level;
  Repeat
    GameLoop;
    if ch = #255 then
      exit;
    if (x = 59) and (y = 10) then
    begin
      showscreen (x, y, 0, 0);
      x:=75;
      y:=72;
      ch:=#255;
      area:=FLD_GREYCAVE
    end
    else
    if (x = 19) and (y = 18) then
    begin
      showscreen (x, y, 0, 0);
      x:=59;
      y:=03;
      ch:=#255;
      area:=FLD_CAVE2
    end
  Until (ch = #255) or (Mace_is_a_dead_man);
End;

Procedure RTN_WTENTR;
Begin
  updateinfoscrn;
  While song. playing do song. fading:=8;
  LoadSong ('MTP\AVALON11.MTP');
  PlaySong;
  UsePage (1);
  Load_PCX (0, 0, 319, 199, 'CELLS', False);
  UsePage (2);
  Load_PCX (0, 0, 319, 199, 'CHARPAG1', False);
  Assign (f, 'DAT\WTENTR.DAT');
  init_level;
  Repeat
    GameLoop;
    if ch = #255 then
      exit;
    if (x = 68) and (y = 13) then
    begin
      ch:=#255;
      showscreen (x, y, 0, 0);
      x:=20;
      y:=93;
      area:=FLD_WTOWER
    end
    else
    if (x = 17) and (y = 8) then
    begin
      ch:=#255;
      showscreen (x, y, 0, 0);
      x:=98;
      y:=80;
      area:=FLD_CAVE2
    end
  Until (ch = #255) or (Mace_is_a_dead_man);
End;

Procedure RTN_WTOWER;
Begin
  updateinfoscrn;
  While song. playing do song. fading:=8;
  LoadSong ('MTP\AVALON31.MTP');
  PlaySong;
  UsePage (1);
  Load_PCX (0, 0, 319, 199, 'WTOWERG', False);
  UsePage (2);
  Load_PCX (0, 0, 319, 199, 'WTOWCHAR', False);
  Assign (f, 'DAT\WTOWER.DAT');
  init_level;
  t2:=1;
  for t1:=1 to 20 do
  begin
    monster [t1]. id:=102;
    monster [t1]. number:=t2;
    if random (10) > 3 then
      inc (t2, 1);
    if t2 = 5 then
      t2:=1;
    if random (10) > 5 then
      inc (monster [t1].number, (Random (3) + 1) * 10)
  end;
  monster [01]. x:=26; monster [01]. y:=86; monster [02]. x:=25; monster [02]. y:=67;
  monster [03]. x:=16; monster [03]. y:=83; monster [04]. x:=25; monster [04]. y:=55;
  monster [05]. x:=17; monster [05]. y:=45; monster [06]. x:=16; monster [06]. y:=33;
  monster [07]. x:=39; monster [07]. y:=27; monster [08]. x:=25; monster [08]. y:=46;
  monster [09]. x:=35; monster [09]. y:=91; monster [10]. x:=46; monster [10]. y:=91;
  monster [11]. x:=61; monster [11]. y:=91; monster [12]. x:=68; monster [12]. y:=80;
  monster [13]. x:=74; monster [13]. y:=64; monster [14]. x:=74; monster [14]. y:=53;
  monster [15]. x:=90; monster [15]. y:=05; monster [16]. x:=52; monster [16]. y:=45;
  monster [17]. x:=54; monster [17]. y:=08; monster [18]. x:=39; monster [18]. y:=08;
  monster [19]. x:=21; monster [19]. y:=05; monster [20]. x:=66; monster [20]. y:=17;
  bigmonster [1]. life:=2000; bigmonster [1]. power:=300; bigmonster [1]. defence:=50; bigmonster [1]. name:='Sinnet Guardian';
  bigmonster [2]. life:=2000; bigmonster [2]. power:=300; bigmonster [2]. defence:=50; bigmonster [2]. name:='Sinnet Guardian';
  bigmonster [3]. life:=2000; bigmonster [3]. power:=300; bigmonster [3]. defence:=50; bigmonster [3]. name:='Sinnet Guardian';
  bigmonster [4]. life:=2000; bigmonster [4]. power:=300; bigmonster [4]. defence:=50; bigmonster [4]. name:='Sinnet Guardian';
  monsterfilename:='monsterh';
  if event_happend [29] then
    for t1:=25 downto 22 do
      field [12, t1]:=59;
  if level = 50 then
  begin
    field [16, 11]:=014;
    field [16, 12]:=015;
    field [17, 11]:=016;
    field [17, 12]:=005;
    field [18, 11]:=108;
    field [19, 11]:=005;
    field [19, 12]:=026;
    field [20, 11]:=017;
    field [20, 12]:=016;
    field [21, 11]:=122
  end;
  Repeat
    GameLoop;
    if ch = #255 then
      exit;
    if (x in [20, 21]) and (y = 94) then
    begin
      ch:=#255;
      showscreen (x, y, 0, 0);
      x:=68;
      y:=13;
      area:=FLD_WTENTR
    end
    else
    if (ch = #72) and (x in [19, 20]) and (y = 88) then
    begin
      showscreen (x, y, 0, 0);
      usepage (0);
      tmplevel:=level;
      if event_happend [28] then
        level:=2
      else
      begin
        event_happend [28]:=true;
        level:=1
      end;
      stringfellowhawk (CHR_WTSIGN);
      level:=tmplevel;
      updateinfoscrn
    end
    else
    if (ch = #72) and (x in [44, 45]) and (y = 7) then
    begin
      showscreen (x, y, 0, 0);
      tmplevel:=level;
      if event_happend [28] then
        level:=4
      else
      begin
        event_happend [28]:=true;
        level:=3
      end;
      stringfellowhawk (CHR_WTSIGN);
      level:=tmplevel;
      updateinfoscrn
    end
    else
    if (ch = #72) and (x = 13) and (y = 29) and (level < 49) then
    begin
      showscreen (x, y, 0, 0);
      tmplevel:=level;
      level:=5;
      stringfellowhawk (CHR_WTSIGN);
      playsample ('MEXPLODE.VOC');
      level:=6;
      stringfellowhawk (CHR_WTSIGN);
      if level = 8 then
      begin
        level:=tmplevel;
        opentextbox;
        font. setfgcolor (14);
        textboxline (160, '[TERMINAL]');
        font. setfgcolor (15);
        textboxline (175, 'PLEASE ENTER THE CODE: _ _ _ ');
        repeat
          ch:=readkey
        until ch in ['0'..'9'];
        s:=ch;
        font. setfgcolor (14);
        playsample ('VCOLLIDE.VOC');
        outtext (130, 175, ch);
        repeat
          ch:=readkey
        until ch in ['0'..'9'];
        s:=s + ch;
        playsample ('VCOLLIDE.VOC');
        outtext (140, 175, ch);
        repeat
          ch:=readkey
        until ch in ['0'..'9'];
        s:=s + ch;
        playsample ('VCOLLIDE.VOC');
        outtext (150, 175, ch);
        if s <> '052' then
        begin
          tmplevel:=level;
          level:=7;
          stringfellowhawk (CHR_WTSIGN);
          level:=tmplevel;
          playsample ('VEXPLODE.VOC');
          for tmplevel:=1 to 20 do
          begin
            showscreen (x, y, 1, 2);
            showscreen (x, y, 2, 1);
          end;
          mace_is_a_dead_man:=true;
          exit
        end
        else
        begin
          tmplevel:=level;
          level:=8;
          playsample ('IDOK.VOC');
          stringfellowhawk (CHR_WTSIGN);
          level:=tmplevel + 1;
          updateinfoscrn
        end
      end
      else
      begin
        level:=tmplevel;
        updateinfoscrn;
        ch:=#243
      end
    end
    else
    if (x = 12) and (y = 26) and (level = 49) and not event_happend [29] then
    begin
      event_happend [29]:=true;
      showscreen (x, y, 0, 0);
      playsample ('STONE.VOC');
      field [12, 25]:=59;
      showscreen (x, y, 0, 0);
      delay (200);
      playsample ('STONE.VOC');
      field [12, 24]:=59;
      showscreen (x, y, 0, 0);
      delay (200);
      playsample ('STONE.VOC');
      field [12, 23]:=59;
      showscreen (x, y, 0, 0);
      delay (200);
      playsample ('STONE.VOC');
      field [12, 22]:=59;
      showscreen (x, y, 0, 0)
    end
    else
    if (x = 18) and (y = 12) and (level < 50) then
    begin
      showscreen (x, y, 0, 0);
      while song. playing do
        song. fading:=8;
      loadsong ('MTP\DARKLORD.MTP');
      playsong;
      stringfellowhawk (CHR_DARKLORD);
      bigbossattack (true);
      level:=50;
      direction:=3;
      field [16, 11]:=014;
      field [16, 12]:=015;
      field [17, 11]:=016;
      field [17, 12]:=005;
      field [18, 11]:=108;
      field [19, 11]:=005;
      field [19, 12]:=026;
      field [20, 11]:=017;
      field [20, 12]:=016;
      field [21, 11]:=122;
      field [12, 25]:=059;
      field [12, 24]:=059;
      field [12, 23]:=059;
      field [12, 22]:=059;
      human [1]. ID:=17;
      human [1]. x:=18;
      human [1]. y:=19;
      human [1]. xplus:=0;
      human [1]. yplus:=0;
      human [1]. dir:=1;
      human [1]. spritenr:=true;
      updateinfoscrn;
      for human [1]. y:=19 downto 13 do
      begin
        human [1]. spritenr:=false;
        human [1]. yplus:=8;
        showscreen (x, y, 0, 0);
        start_timer (2);
        wait_for_timer (false);
        human [1]. spritenr:=true;
        human [1]. yplus:=0;
        showscreen (x, y, 0, 0);
        start_timer (2);
        wait_for_timer (false)
      end;
      stringfellowhawk (CHR_CADDMAN);
      human [1]. dir:=3;
      showscreen (x, y, 0, 0);
      usepage (0);
      t1:=8;
      t2:=311;
      repeat
        t1:=t1 + 2;
        t2:=t2 - 2;
        waitforretrace;
        solidvlinex (t1, 8, 135, 0);
        solidvlinex (t2, 8, 135, 0);
      until t1 >= 310;
      ch:=#255;
      area:=FLD_VILLAGE;
      direction:=1;
      x:=03;
      y:=60
    end
  Until (ch = #255) or (Mace_is_a_dead_man);
End;

Procedure RTN_Water;
Var current_page : Boolean;
Begin
  updateinfoscrn;
  While song. playing do song. fading:=8;
  LoadSong ('MTP\AVALON09.MTP');
  PlaySong;
  UsePage (1);
  Load_PCX (0, 0, 319, 199, 'water2', False);
  UsePage (2);
  If (y > 10) and (y < 52) then begin
    Load_PCX (0, 0, 319, 199, 'charpag2', false);
    current_page:=False;
  End else begin
    Load_PCX (0, 0, 319, 199, 'charpag3', False);
    current_page:=True;
  End;
  Assign (f, 'DAT\water.dat');
  init_level;
  t2:=1;
  For t1:=1 to 20 do begin
    monster [t1]. ID:=102;
    monster [t1]. Number:=t2;
    If random (10) > 3 then Inc (t2, 1);
    If t2 = 5 then t2:=1;
    If t2 = 1 then if random (10) > 4 then t2:=Random (2) + 2;
    If random (10) > 5 then for t3:=1 to Random (3) + 1 do inc (monster [t1].number, 10);
  End;
  For t1:=1 to 10 do human [t1]. ID:=0;
  monster [01]. x:=50; monster [01]. y:=28; monster [02]. x:=58; monster [02]. y:=38;
  monster [03]. x:=64; monster [03]. y:=44; monster [04]. x:=56; monster [04]. y:=44;
  monster [05]. x:=43; monster [05]. y:=40; monster [06]. x:=28; monster [06]. y:=45;
  monster [07]. x:=22; monster [07]. y:=35; monster [08]. x:=47; monster [08]. y:=47;
  monster [09]. x:=64; monster [09]. y:=44; monster [10]. x:=70; monster [10]. y:=41;
  monster [11]. x:=74; monster [11]. y:=32; monster [12]. x:=87; monster [12]. y:=31;
  monster [13]. x:=78; monster [13]. y:=42; monster [14]. x:=60; monster [14]. y:=18;
  monster [15]. x:=34; monster [15]. y:=17; monster [16]. x:=30; monster [16]. y:=32;
  monster [17]. x:=26; monster [17]. y:=24; monster [18]. x:=74; monster [18]. y:=38;
  monster [19]. x:=47; monster [19]. y:=34; monster [20]. x:=40; monster [20]. y:=28;
  bigmonster [1]. life:=80; bigmonster [1]. power:=50; bigmonster [1]. defence:=15; bigmonster [1]. name:='Butcher Perch';
  bigmonster [2]. life:=100;bigmonster [2]. power:=45; bigmonster [2]. defence:=20; bigmonster [2]. name:='Squirk';
  bigmonster [3]. life:=90; bigmonster [3]. power:=35; bigmonster [3]. defence:=20; bigmonster [3]. name:='Big Squid';
  bigmonster [4]. life:=90; bigmonster [4]. power:=50; bigmonster [4]. defence:=17; bigmonster [4]. name:='Morbitor';
  monsterfilename:='monsterd';
  ShowPage (0);
  Repeat
    GameLoop;
    if ch = #255 then
      exit;
    If (y > 10) and (y < 52) and current_page then begin
      UsePage (2);
      PlaySample ('squish.voc');
      Load_PCX (0, 0, 319, 199, 'charpag2', false);
      current_page:=False;
    End;
    If (((y < 11) and (x > 65)) or (y > 51)) and (not current_page) then begin
      UsePage (2);
      Load_PCX (0, 0, 319, 199, 'charpag3', false);
      current_page:=True;
    End;
    If (y > 95) then begin
      ch:=#255; ShowScreen (x, y, 0, 0);
      Inc (x, 31);
      y:=5;
      Area:=FLD_Beach2;
    End;
    If (x = 52) and (y = 10) then begin
      ch:=#255; ShowScreen (x, y, 0, 0);
      x:=33;
      y:=20;
      Area:=FLD_Watercav;
    End;
    If (y < 5) then begin
      ch:=#255; ShowScreen (x, y, 0, 0);
      x:=37;
      y:=50;
      Area:=FLD_Entrance;
    End;
  Until (ch = #255) or (Mace_is_a_dead_man);
End;

Procedure RTN_Watercav;
Var current_page : Boolean;
Begin
  updateinfoscrn;
  While song. playing do song. fading:=8;
  LoadSong ('MTP\AVALON09.MTP');
  PlaySong;
  UsePage (1);
  Load_PCX (0, 0, 319, 199, 'watercav', False);
  UsePage (2);
  If (y > 9 ) then begin
    Load_PCX (0, 0, 319, 199, 'charpag2', false);
    current_page:=False;
  End else begin
    Load_PCX (0, 0, 319, 199, 'charpag1', False);
    current_page:=True;
  End;
  Assign (f, 'DAT\watercav.dat');
  init_level;
  t2:=1;
  Repeat
    GameLoop;
    if ch = #255 then
      exit;
    If (y > 9) and  current_page then begin
      UsePage (2);
      PlaySample ('squish.voc');
      Load_PCX (0, 0, 319, 199, 'charpag2', false);
      current_page:=False;
    End;
    If (y < 10) and (not current_page) then begin
      UsePage (2);
      Load_PCX (0, 0, 319, 199, 'charpag1', false);
      current_page:=True;
    End;
    If (x = 33) and (y = 21) then begin
      ch:=#255; ShowScreen (x, y, 0, 0);
      x:=52;
      y:=11;
      Area:=FLD_water;
    End;
    If (x = 37) and (y = 2) and not event_happend [4] then begin
      event_happend [4]:=True;
      OpenTextBox;
      Font. SetFGColor (14);
      TextBoxLine (155, 'Mace opens the chest...');
      Delay (400);
      Font. SetFGColor (15);
      PlaySample ('Tbeep2.voc');
      TextBoxLine (163, '5 MEDIA KITS 2000 discovered !');
      For t1:=1 to 5 do Add_Item (itemcon [6]. name, 6);
      Blinking_Cursor;
      UpdateInfoScrn;
    End;
  Until (ch = #255) or (Mace_is_a_dead_man);
End;

Procedure RTN_Garden;
Begin
  updateinfoscrn;
  While song. playing do song. fading:=8;
  LoadSong ('MTP\AVALON20.MTP');
  PlaySong;
  UsePage (1);
  Load_PCX (0, 0, 319, 199, 'garden', False);
  UsePage (2);
  Load_PCX (0, 0, 319, 199, 'charpag1', false);
  Assign (f, 'DAT\garden.dat');
  init_level;
  t2:=1;
  For t1:=1 to 20 do begin
    monster [t1]. ID:=102;
    monster [t1]. Number:=t2;
    If random (10) > 3 then
      Inc (t2, 1);
    If t2 = 5 then t2:=1;
    If t2 = 1 then if random (10) > 4 then t2:=Random (2) + 2;
    If random (10) > 5 then for t3:=1 to Random (3) + 1 do inc (monster [t1].number, 10);
  End;
  For t1:=1 to 10 do human [t1]. ID:=0;
  monster [01]. x:=65; monster [01]. y:=25; monster [02]. x:=32; monster [02]. y:=34;
  monster [03]. x:=11; monster [03]. y:=36; monster [04]. x:=37; monster [04]. y:=38;
  monster [05]. x:=53; monster [05]. y:=45; monster [06]. x:=11; monster [06]. y:=44;
  monster [07]. x:=16; monster [07]. y:=60; monster [08]. x:=14; monster [08]. y:=89;
  monster [09]. x:=40; monster [09]. y:=57; monster [10]. x:=59; monster [10]. y:=65;
  monster [11]. x:=76; monster [11]. y:=70; monster [12]. x:=27; monster [12]. y:=72;
  monster [13]. x:=33; monster [13]. y:=80; monster [14]. x:=48; monster [14]. y:=80;
  monster [15]. x:=78; monster [15]. y:=81; monster [16]. x:=68; monster [16]. y:=92;
  monster [17]. x:=81; monster [17]. y:=40; monster [18]. x:=77; monster [18]. y:=35;
  monster [19]. x:=26; monster [19]. y:=07; monster [20]. x:=31; monster [20]. y:=14;
  bigmonster [1]. life:=500; bigmonster [1]. power:=150; bigmonster [1]. defence:=50; bigmonster [1]. name:='Trilobite';
  bigmonster [2]. life:=400; bigmonster [2]. power:=150; bigmonster [2]. defence:=40; bigmonster [2]. name:='Bulb';
  bigmonster [3]. life:=500; bigmonster [3]. power:=150; bigmonster [3]. defence:=50; bigmonster [3]. name:='Trilobite';
  bigmonster [4]. life:=400; bigmonster [4]. power:=150; bigmonster [4]. defence:=40; bigmonster [4]. name:='Bulb';
  monsterfilename:='monstere';
  if event_happend [15] then
  begin
    trans [85, 84]:=0;
    trans [84, 83]:=0;
    trans [86, 83]:=0;
    field [85, 85]:=0;
    field [84, 84]:=0;
    field [86, 84]:=0;
  end;
  if event_happend [16] then
  begin
    trans [34, 67]:=0;
    field [34, 68]:=0;
  end;
  Repeat
    GameLoop;
    if ch = #255 then
      exit;
    if ((x = 85) and ((y = 84) or (y = 86)) and not event_happend [15] and (direction = 3)) or
       ((x = 34) and ((y = 67) or (y = 69)) and not event_happend [16] and (direction = 3)) then
    begin
      showscreen (x, y, 0, 0);
      monster [1]. number:=1;
      monsterfilename:='em2';
      bigmonster [1]. life:=1000;
      bigmonster [1]. power:=250;
      bigmonster [1]. defence:=200;
      bigmonster [1]. name:='Living Tree';
      hitmonster:=1;
      supermonster:=true;
      attackscreen;
      if x = 85 then
      begin
        trans [85, 84]:=0;
        field [85, 85]:=0;
        showscreen (x, y, 0, 0);
        if not mace_is_a_dead_man then
        begin
          hitmonster:=1;
          supermonster:=true;
          attackscreen;
        end;
        trans [84, 83]:=0;
        field [84, 84]:=0;
        showscreen (x, y, 0, 0);
        if not mace_is_a_dead_man then
        begin
          hitmonster:=1;
          supermonster:=true;
          attackscreen;
        end;
        trans [86, 83]:=0;
        field [86, 84]:=0;
      end;
      monsterfilename:='monstere';
      bigmonster [1]. life:=500; bigmonster [1]. power:=150; bigmonster [1]. defence:=50; bigmonster [1]. name:='Trilobite';
      if x = 85 then
        event_happend [15]:=true
      else
      begin
        trans [34, 67]:=0;
        field [34, 68]:=0;
        event_happend [16]:=true
      end;
      ch:=#251
    end
    else
    if (x = 87) and (y = 9) then
    begin
      ch:=#255;
      showscreen (x, y, 0, 0);
      x:=06;
      y:=55;
      area:=FLD_CASTLE1
    end
  until (ch = #255) or (Mace_is_a_dead_man)
End;

procedure rtn_snow;
var t1 : integer;
begin
  updateinfoscrn;
  if song. filename <> 'MTP\AVALON23.MTP' then
  begin
    while song. playing do
      song. fading:=8;
    loadsong ('MTP\AVALON23.MTP');
    playsong
  end;
  usepage (1);
  load_pcx (0, 0, 319, 199, 'SNOW', false);
  usepage (2);
  load_pcx (0, 0, 319, 199, 'CHARPAG1', false);
  assign (f, 'DAT\SNOW.DAT');
  init_level;
  if object_present (2) then
    field [18, 70]:=12;
  if event_happend [18] then
    field [46, 40]:=45;
  if event_happend [19] then
    field [64, 36]:=38;
  if level = 34 then
  begin
    field [83, 25]:=45;
    field [82, 25]:=08;
  end
  else
  if level = 36 then
  begin
    field [79, 18]:=45;
    field [83, 25]:=10;
    field [82, 25]:=45;
  end
  else
  if level > 36 then
  begin
    field [83, 25]:=45;
    field [79, 18]:=45
  end;
  t2:=1;
  for t1:=1 to 20 do
  begin
    monster [t1]. id:=102;
    monster [t1]. number:=t2;
    If random (10) > 3 then
      inc (t2, 1);
    if t2 = 5 then
      t2:=1;
    if t2 = 1 then
      if random (10) > 4 then
        t2:=random (2) + 2;
    if random (10) > 5 then
      for t3:=1 to random (3) + 1 do
        inc (monster [t1].number, 10)
  end;
  monster [01]. x:=22; monster [01]. y:=47; monster [02]. x:=50; monster [02]. y:=42;
  monster [03]. x:=45; monster [03]. y:=55; monster [04]. x:=23; monster [04]. y:=57;
  monster [05]. x:=41; monster [05]. y:=62; monster [06]. x:=28; monster [06]. y:=71;
  monster [07]. x:=53; monster [07]. y:=68; monster [08]. x:=66; monster [08]. y:=67;
  monster [09]. x:=92; monster [09]. y:=62; monster [10]. x:=46; monster [10]. y:=77;
  monster [11]. x:=90; monster [11]. y:=73; monster [12]. x:=90; monster [12]. y:=50;
  monster [13]. x:=68; monster [13]. y:=50; monster [14]. x:=68; monster [14]. y:=58;
  monster [15]. x:=57; monster [15]. y:=53; monster [16]. x:=78; monster [16]. y:=56;
  monster [17]. x:=84; monster [17]. y:=50; monster [18]. x:=80; monster [18]. y:=38;
  monster [19]. x:=67; monster [19]. y:=38; monster [20]. x:=66; monster [20]. y:=32;
  bigmonster [1]. life:=700; bigmonster [1]. power:=150; bigmonster [1]. defence:=30; bigmonster [1]. name:='Pterodon';
  bigmonster [2]. life:=600; bigmonster [2]. power:=200; bigmonster [2]. defence:=10; bigmonster [2]. name:='Slymco';
  bigmonster [3]:=bigmonster [1];
  bigmonster [4]:=bigmonster [2];
  monsterfilename:='monsterf';
  repeat
    gameloop;
    if ch = #255 then
      exit;
    if (x = 83) and (y = 26) and (level = 33) then
    begin
      stringfellowhawk (CHR_RSNAKE);
      level:=34;
      field [83, 25]:=45;
      field [82, 25]:=08
    end
    else
    if (x = 79) and (y = 18) and (level = 34) then
    begin
      object_found ('White Flower', 17, 256+16, 51, 'Picked.');
      field [79, 18]:=45;
      field [83, 25]:=10;
      field [82, 25]:=45;
      level:=36
    end
    else
    if (x = 83) and (y = 24) and (level = 36) and (direction = 3) then
    begin
      stringfellowhawk (CHR_RSNAKE);
      monster [1]. number:=1;
      monsterfilename:='rsnake';
      bigmonster [1]. life:=5;
      bigmonster [1]. power:=400;
      bigmonster [1]. defence:=500;
      bigmonster [1]. name:='Rattlesnake';
      hitmonster:=1;
      supermonster:=true;
      attackscreen;
      bigmonster [1]:=bigmonster [3];
      monsterfilename:='monsterf';
      ch:=#0;
      field [83, 25]:=45;
      level:=37
    end
    else
    if (x = 18) and (y = 70) and not object_present (2) then
    begin
      field [18, 70]:=12;
      object_found ('Areascanner', 2, 240+2*16, 0, 'Found...')
    end
    else
    if (x = 46) and (y = 40) and not event_happend [18] then
    begin
      field [46, 40]:=45;
      event_happend [18]:=true;
      object_found ('Wooden piece', 16, 256, 54, 'Found.')
    end
    else
    if (x = 34) and (y = 85) and (direction = 4) then
    begin
      { Mace uses boat to go back to CADDMAN }
      direction:=0;
      t1:=33;
      while t1 > 4 do
      begin
        field [t1, 84]:=0;
        field [t1, 85]:=0;
        field [t1 - 1, 84]:=99;
        field [t1 - 1, 85]:=100;
        field [t1 - 2, 84]:=101;
        field [t1 - 2, 85]:=102;
        field [t1 - 3, 84]:=103;
        field [t1 - 3, 85]:=104;
        showscreen (t1, y, 0, 0);
        field [t1 - 1, 84]:=105;
        field [t1 - 1, 85]:=106;
        field [t1 - 2, 84]:=107;
        field [t1 - 2, 85]:=108;
        field [t1 - 3, 84]:=109;
        field [t1 - 3, 85]:=088;
        field [t1 - 4, 84]:=089;
        field [t1 - 4, 85]:=090;
        showscreen (t1, y, 1, 0);
        Dec (t1)
      end;
      x:=82;
      direction:=4;
      area:=FLD_VILLAGE;
      ch:=#255;
      y:=58
    end
    else
    if ((x = 87) and (y = 70)) or ((x = 68) and (y = 54)) or ((x = 49) and (y = 59)) then
    begin
      showscreen (x, y, 0, 0);
      ch:=#255;
      area:=FLD_CAVEMNT;
      case x of
      87 :
        begin
          x:=50;
          y:=98
        end;
      68 :
        begin
          x:=98;
          y:=45
        end;
      49 :
        begin
          x:=20;
          y:=12
        end
      end
    end
  until (ch = #255) or (mace_is_a_dead_man)
end;

procedure rtn_cavemnt;
begin
  updateinfoscrn;
  if (song. filename <> 'MTP\AVALON23.MTP') or not song. playing then
  begin
    while song. playing do
      song. fading:=8;
    loadsong ('MTP\AVALON23.MTP');
    playsong
  end;
  usepage (1);
  load_pcx (0, 0, 319, 199, 'CAVECEL', false);
  usepage (2);
  load_pcx (0, 0, 319, 199, 'CHARPAG1', false);
  assign (f, 'DAT\CAVEMNT.DAT');
  init_level;
  t2:=1;
  for t1:=1 to 14 do
  begin
    monster [t1]. id:=102;
    monster [t1]. number:=t2;
    If random (10) > 3 then
      inc (t2, 1);
    if t2 = 5 then
      t2:=1;
    if t2 = 1 then
      if random (10) > 4 then
        t2:=random (2) + 2;
    if random (10) > 5 then
      for t3:=1 to random (3) + 1 do
        inc (monster [t1].number, 10)
  end;
  monster [01]. x:=57; monster [01]. y:=89; monster [02]. x:=42; monster [02]. y:=89;
  monster [03]. x:=26; monster [03]. y:=46; monster [04]. x:=61; monster [04]. y:=68;
  monster [05]. x:=82; monster [05]. y:=37; monster [06]. x:=58; monster [06]. y:=37;
  monster [07]. x:=63; monster [07]. y:=18; monster [08]. x:=82; monster [08]. y:=06;
  monster [09]. x:=38; monster [09]. y:=39; monster [10]. x:=49; monster [10]. y:=59;
  monster [11]. x:=27; monster [11]. y:=61; monster [12]. x:=82; monster [12]. y:=47;
  monster [13]. x:=66; monster [13]. y:=85; monster [14]. x:=71; monster [14]. y:=43;
  bigmonster [1]. life:=300; bigmonster [1]. power:=200; bigmonster [1]. defence:=50; bigmonster [1]. name:='Master Sketon';
  bigmonster [2]. life:=300; bigmonster [2]. power:=150; bigmonster [2]. defence:=40; bigmonster [2]. name:='Dark Sketon';
  bigmonster [3]:=bigmonster [1];
  bigmonster [4]:=bigmonster [2];
  monsterfilename:='monsterg';
  repeat
    gameloop;
    if ch = #255 then
      exit;
    if ((x in [50, 51]) and (y = 99)) or ((x = 98) and (y = 46)) or ((x = 20) and (y = 13)) then
    begin
      showscreen (x, y, 0, 0);
      ch:=#255;
      area:=FLD_SNOW;
      if x in [50, 51] then
      begin
        x:=87;
        y:=71
      end
      else
      if x = 98 then
      begin
        x:=68;
        y:=55
      end
      else
      if x = 20 then
      begin
        x:=49;
        y:=60
      end
    end
  until (ch = #255) or (mace_is_a_dead_man)
end;

procedure RTN_Darkroom;
begin
  while song. playing do
    song. fading:=8;
  loadSong ('MTP\AVALON10.MTP');
  playsong;
  usePage (1);
  load_pcx (0, 0, 319, 199, 'castle', False);
  usePage (2);
  load_pcx (0, 0, 319, 199, 'charpag1', False);
  assign (f, 'DAT\darkroom.dat');
  init_level;
  updateinfoscrn;
  if event_happend [26] then
  begin
    for t1:=20 to 24 do
      for t2:=11 to 12 do
        field [t1, t2]:=61;
    field [19, 11]:=61;
    field [25, 11]:=61
  end;
  if (level = 45) then
  begin
    human [1]. x:=22;
    human [1]. y:=99;
    human [1]. dir:=1;
    human [1]. id:=153;
    for y:=96 downto 12 do
    begin
      human [1].spritenr:=true;
      human [1]. yplus:=-8;
      showscreen (x, y, 0, 2);
      delay (25);
      human [1].spritenr:=false;
      dec (human [1]. y);
      human [1]. yplus:=0;
      showscreen (x, y, 0, 0);
      delay (25);
    end;
    direction:=3;
    human [1]. spritenr:=true;
    human [1]. yplus:=-8;
    showscreen (x, y, 0, 0);
    delay (25);
    human [1].spritenr:=false;
    dec (human [1]. y);
    human [1]. yplus:=0;
    showscreen (x, y, 0, 0);
    delay (25);
    stringfellowhawk (CHR_MACE);
    direction:=4;
    dec (x);
    showscreen (x, y, 2, 0);
    delay (25);
    showscreen (x, y, 0, 0);
    delay (25);
    direction:=1;
    for y:=11 downto 8 do
    begin
      showscreen (x, y, 0, 2);
      delay (35);
      showscreen (x, y, 0, 0);
      delay (35)
    end;
    human [1]. dir:=4;
    human [1]. xplus:=-8;
    showscreen (x, y, 0, 0);
    dec (human [1]. x);
    human [1]. xplus:=0;
    delay (35);
    showscreen (x, y, 0, 0);
    human [1]. dir:=1;
    for human [1]. y:=12 downto 7 do
    begin
      human [1]. yplus:=8;
      delay (35);
      showscreen (x, y, 0, 0);
      human [1]. yplus:=0;
      delay (35);
      showscreen (x, y, 0, 0);
    end;
    ch:=#255;
    x:=04;
    y:=18;
    area:=FLD_GREYCAVE;
    exit
  end;
  repeat
    gameloop;
    if ch = #255 then
      exit;
    if (x = 22) and (y = 12) and not event_happend [26] then
    begin
      event_happend [26]:=true;
      stringfellowhawk (CHR_DARKLORD);
      bigbossattack (false);
      for t1:=20 to 24 do
        for t2:=11 to 12 do
          field [t1, t2]:=61;
      field [19, 11]:=61;
      field [25, 11]:=61;
      if not mace_is_a_dead_man then
      begin
        showscreen (x, y, 0, 0);
        stringfellowhawk (CHR_MACE)
      end
    end
    else
    if (x = 4) and (y = 80) and not event_happend [20] and (ch = #72) then
    begin
      showscreen (x, y, 0, 0);
      event_happend [20]:=true;
      opentextbox;
      font. setfgcolor (14);
      textboxline (155, 'Mace opens the chest...');
      delay (400);
      font. setFGColor (15);
      playsample ('TBEEP2.VOC');
      textboxline (163, '2 MEDIA KITS 2000 discovered !');
      add_item (itemcon [6]. name, 6);
      add_item (itemcon [6]. name, 6);
      blinking_cursor;
      updateInfoScrn
    end
    else
    if (x = 5) and (y = 80) and not event_happend [21] and (ch = #72) then
    begin
      showscreen (x, y, 0, 0);
      event_happend [21]:=true;
      opentextbox;
      font. setfgcolor (14);
      textboxline (155, 'Mace opens the chest...');
      delay (400);
      font. setFGColor (15);
      playsample ('TBEEP2.VOC');
      textboxline (163, itemcon [11]. name + ' FOUND !');
      add_item (itemcon [11]. name, 11);
      blinking_cursor;
      updateInfoScrn
    end
    else
    if (x = 6) and (y = 80) and not event_happend [22] and (ch = #72) then
    begin
      showscreen (x, y, 0, 0);
      event_happend [22]:=true;
      opentextbox;
      font. setfgcolor (14);
      textboxline (155, 'Mace opens the chest...');
      delay (400);
      font. setFGColor (15);
      playsample ('TBEEP2.VOC');
      textboxline (163, '1200 GOLD FOUND !');
      inc (money, 1200);
      blinking_cursor;
      updateInfoScrn
    end
    else
    if (x = 38) and (y = 80) and not event_happend [23] and (ch = #72) then
    begin
      showscreen (x, y, 0, 0);
      event_happend [23]:=true;
      opentextbox;
      font. setfgcolor (14);
      textboxline (155, 'Mace opens the chest...');
      delay (400);
      font. setFGColor (15);
      playsample ('TBEEP2.VOC');
      textboxline (163, itemcon [9]. name + ' FOUND !!');
      add_item (itemcon [9]. name, 9);
      blinking_cursor;
      updateInfoScrn
    end
    else
    if (x = 39) and (y = 80) and not event_happend [24] and (ch = #72) then
    begin
      showscreen (x, y, 0, 0);
      event_happend [24]:=true;
      opentextbox;
      font. setfgcolor (14);
      textboxline (155, 'Mace opens the chest...');
      delay (400);
      font. setFGColor (15);
      playsample ('TBEEP2.VOC');
      textboxline (163, itemcon [7]. name + ' FOUND !!');
      add_item (itemcon [7]. name, 7);
      blinking_cursor;
      updateInfoScrn
    end
    else
    if (x = 40) and (y = 80) and not (event_happend [25]) and (ch = #72) then
    begin
      showscreen (x, y, 0, 0);
      event_happend [25]:=true;
      opentextbox;
      font. setfgcolor (14);
      textboxline (155, 'Mace opens the chest...');
      delay (400);
      font. setFGColor (15);
      textboxline (163, '...but it''s a trap !!!!!!');
      blinking_cursor;
      hitmonster:=1;
      supermonster:=false;
      attackscreen
    end
    else
    if (y > 98) then
    begin
      ch:=#255;
      showscreen (x, y, 0, 0);
      x:=51;
      y:=43;
      area:=FLD_Castle1
    end
    else
    if (y < 8) then
    begin
      ch:=#255;
      showscreen (x, y, 0, 0);
      x:=04;
      y:=18;
      area:=FLD_GREYCAVE
    end;
  until (ch = #255) or (Mace_is_a_dead_man)
end;

procedure rtn_greycave;
begin
  while song. playing do
    song. fading:=8;
  loadSong ('MTP\AVALON28.MTP');
  playsong;
  usePage (1);
  load_pcx (0, 0, 319, 199, 'greycave', False);
  usePage (2);
  load_pcx (0, 0, 319, 199, 'charpag1', False);
  assign (f, 'DAT\greycave.dat');
  init_level;
  t2:=1;
  for t1:=1 to 14 do
  begin
    monster [t1]. id:=102;
    monster [t1]. number:=t2;
    If random (10) > 3 then
      inc (t2, 1);
    if t2 = 5 then
      t2:=1;
    if t2 = 1 then
      if random (10) > 4 then
        t2:=random (2) + 2;
    if random (10) > 5 then
      for t3:=1 to random (3) + 1 do
        inc (monster [t1].number, 10)
  end;
  monster [01]. x:=10; monster [01]. y:=45;
  monster [02]. x:=12; monster [02]. y:=95;
  monster [03]. x:=22; monster [03]. y:=95;
  monster [04]. x:=41; monster [04]. y:=94;
  monster [05]. x:=51; monster [05]. y:=84;
  monster [06]. x:=30; monster [06]. y:=61;
  monster [07]. x:=25; monster [07]. y:=70;
  monster [08]. x:=33; monster [08]. y:=51;
  monster [09]. x:=49; monster [09]. y:=50;
  monster [10]. x:=80; monster [10]. y:=61;
  monster [11]. x:=90; monster [11]. y:=61;
  monster [12]. x:=91; monster [12]. y:=49;
  monster [13]. x:=90; monster [13]. y:=23;
  monster [14]. x:=89; monster [14]. y:=23;
  monster [15]. x:=70; monster [15]. y:=32;
  monster [16]. x:=62; monster [16]. y:=20;
  monster [17]. x:=49; monster [17]. y:=16;
  monster [18]. x:=35; monster [18]. y:=28;
  monster [19]. x:=27; monster [19]. y:=41;
  bigmonster [1]. life:=800; bigmonster [1]. power:=330; bigmonster [1]. defence:=70; bigmonster [1]. name:='Fire Horse';
  bigmonster [2]. life:=800; bigmonster [2]. power:=300; bigmonster [2]. defence:=80; bigmonster [2]. name:='Burning Acid';
  bigmonster [3]:=bigmonster [1];
  bigmonster [4]:=bigmonster [2];
  monsterfilename:='firemon';
  updateinfoscrn;
  if level = 46 then
  begin
    human [1]. x:=33;
    human [1]. y:=78;
    human [1]. dir:=1;
    human [1]. id:=153;
  end
  else
  if level = 47 then
    field [39, 68]:=76
  else
  if level = 45 then
  begin
    human [1]. x:=07;
    human [1]. y:=16;
    human [1]. dir:=1;
    human [1]. id:=153;
    x:=7;
    y:=15;
    direction:=3;
    showscreen (x, y, 0, 0);
    stringfellowhawk (CHR_CADDMAN);
    object_found ('Walkie-talkie', 8, 288, 17, 'received.');
    human [1]. dir:=3;
    showscreen (x, y, 0, 0);
    for human [1]. y:=17 to 24 do
    begin
      human [1]. yplus:=-8;
      showscreen (x, y, 0, 0);
      delay (60);
      human [1]. yplus:=0;
      showscreen (x, y, 0, 0);
      delay (60);
    end;
    human [1]. x:=33;
    human [1]. y:=78;
    level:=46;
  end
  else
  if level > 47 then
  begin
    field [38, 67]:=130;
    field [38, 68]:=131;
    trans [38, 67]:=130
  end;
  repeat
    gameloop;
    if ch = #255 then
      exit;
    if (x = 91) and (y = 63) and (level = 46) then
    begin
      stringfellowhawk (CHR_MACE);
      human [1]. ID:=0;
      field [39, 68]:=76;
      level:=47
    end
    else
    if (x = 39) and (y = 69) and (level = 47) and (ch = #72) then
    begin
      stringfellowhawk (CHR_CADDMAN);
      field [39, 68]:=65;
      showscreen (x, y, 0, 0);
      delay (500);
      field [38, 67]:=97;
      field [38, 68]:=98;
      playsample ('SDOOR.VOC');
      showscreen (x, y, 0, 0);
      delay (450);
      field [38, 67]:=108;
      field [38, 68]:=109;
      playsample ('SDOOR.VOC');
      showscreen (x, y, 0, 0);
      delay (550);
      field [38, 67]:=119;
      field [38, 68]:=120;
      playsample ('SDOOR.VOC');
      showscreen (x, y, 0, 0);
      delay (500);
      field [38, 67]:=130;
      field [38, 68]:=131;
      playsample ('SDOOR.VOC');
      showscreen (x, y, 0, 0);
      delay (400);
      trans [38, 67]:=130;
      field [39, 68]:=76;
      showscreen (x, y, 0, 0);
      stringfellowhawk (CHR_MACE);
      level:=48
    end
    else
    if (x = 75) and (y = 73) then
    begin
      showscreen (x, y, 0, 0);
      x:=59;
      y:=11;
      ch:=#255;
      area:=FLD_ENTRDOWN
    end
    else
    if (x = 4) and (y = 19) then
    begin
      showscreen (x, y, 0, 0);
      x:=21;
      y:=10;
      ch:=#255;
      area:=FLD_DARKROOM
    end
    else
    if (x = 63) and (y = 60) and (level = 43) then
      level:=44
  until (ch = #255) or (Mace_is_a_dead_man)
end;

Procedure RTN_Cave2;
Begin
  While song. playing do song. fading:=8;
  LoadSong ('MTP\AVALON15.MTP');
  PlaySong;
  UsePage (1);
  Load_PCX (0, 0, 319, 199, 'cavecel', False);
  UsePage (2);
  Load_PCX (0, 0, 319, 199, 'charpag1', False);
  Assign (f, 'DAT\CAVEBO.DAT');
  init_level;
  t2:=1;
  For t1:=1 to 14 do begin
    monster [t1]. ID:=102;
    monster [t1]. Number:=t2;
    If random (10) > 3 then Inc (t2, 1);
    If t2 = 5 then t2:=1;
    If t2 = 1 then if random (10) > 4 then t2:=Random (2) + 2;
    If random (10) > 5 then for t3:=1 to Random (3) + 1 do inc (monster [t1].number, 10);
  End;
  monster [01]. x:=17; monster [01]. y:=43; monster [02]. x:=17; monster [02]. y:=44;
  monster [03]. x:=17; monster [03]. y:=45; monster [04]. x:=17; monster [04]. y:=44;
  monster [05]. x:=12; monster [05]. y:=67; monster [06]. x:=21; monster [06]. y:=71;
  monster [07]. x:=36; monster [07]. y:=75; monster [08]. x:=41; monster [08]. y:=78;
  monster [09]. x:=39; monster [09]. y:=85; monster [10]. x:=27; monster [10]. y:=89;
  monster [11]. x:=06; monster [11]. y:=95; monster [12]. x:=04; monster [12]. y:=81;
  monster [13]. x:=16; monster [13]. y:=76; monster [14]. x:=48; monster [14]. y:=70;
  bigmonster [3]. life:=40; bigmonster [3]. power:=45; bigmonster [3]. defence:=10; bigmonster [3]. name:='Atomic Waste';
  bigmonster [2]. life:=50; bigmonster [2]. power:=40; bigmonster [2]. defence:=20; bigmonster [1]. name:='Brontosaurus';
  bigmonster [4]. life:=60; bigmonster [4]. power:=30; bigmonster [4]. defence:=15; bigmonster [4]. name:='Jellyfish';
  bigmonster [1]. life:=70; bigmonster [1]. power:=35; bigmonster [1]. defence:=10; bigmonster [2]. name:='Spectre';
  monsterfilename:='monsterc';
  UpdateInfoScrn;
  ShowPage (0);
  t2:=1;
  For t1:=01 to 10 do human [t1]. ID:=0;
  For t1:=15 to 20  do monster [t1]. ID:=0;
  Repeat
    GameLoop;
    if ch = #255 then
      exit;
    If (x = 17) and (y = 94) then begin
      ch:=#255; ShowScreen (x, y, 0, 0);
      x:=90;
      y:=15;
      Area:=FLD_Beach2;
    End;
    If (x = 11) and (y = 94) then begin
      If not event_happend [2] then begin
        event_happend [2]:=True;
        OpenTextBox;
        Font. SetFGColor (14);
        TextBoxLine (155, 'Mace opens the chest...');
        Delay (400);
        Font. SetFGColor (15);
        PlaySample ('Tbeep2.voc');
        TextBoxLine (163, '500 Gold found !');
        Inc (money, 500);
        Blinking_Cursor;
        UpdateInfoScrn;
      End;
    End;
    If (x = 58) and (y = 90) then begin
      If not event_happend [3] then begin
        event_happend [3]:=True;
        OpenTextBox;
        Font. SetFGColor (14);
        TextBoxLine (155, 'Mace opens the chest...');
        Delay (400);
        Font. SetFGColor (15);
        PlaySample ('Tbeep2.voc');
        TextBoxLine (163, itemcon [5]. name + ' found !!');
        Add_Item (itemcon [5]. name, 5);
        Blinking_Cursor;
        UpdateInfoScrn;
      End;
    End
    else
    if (x = 60) and (y = 3) then
    begin
      ch:=#255;
      showscreen (x, y, 0, 0);
      x:=20;
      y:=18;
      Area:=FLD_ENTRDOWN
    end
    else
    if (x = 98) and (y = 80) then
    begin
      ch:=#255;
      showscreen (x, y, 0, 0);
      x:=17;
      y:=09;
      area:=FLD_WTENTR
    end;
  Until (ch = #255) or (Mace_is_a_dead_man);
End;

Procedure RTN_Forest;
Begin
  While song. playing do song. fading:=8;
  LoadSong ('MTP\AVALON05.MTP');
  PlaySong;
  UsePage (1);
  Load_PCX (0, 0, 319, 199, 'CELLS', False);
  UsePage (2);
  Load_PCX (0, 0, 319, 199, 'charpag1', False);
  Assign (f, 'DAT\forest.dat');
  init_level;
  updateinfoscrn;
  t2:=1;
  For t1:=1 to 20 do begin
    monster [t1]. ID:=102;
    monster [t1]. Number:=t2;
    If random (10) > 3 then Inc (t2, 1);
    If t2 = 5 then t2:=1;
    If t2 = 1 then if random (10) > 4 then t2:=Random (2) + 2;
    If random (10) > 5 then for t3:=1 to Random (3) + 1 do inc (monster [t1].number, 10);
  End;
  monster [01]. x:=13; monster [01]. y:=88; monster [02]. x:=32; monster [02]. y:=94;
  monster [03]. x:=46; monster [03]. y:=94; monster [04]. x:=46; monster [04]. y:=88;
  monster [05]. x:=39; monster [05]. y:=86; monster [06]. x:=29; monster [06]. y:=84;
  monster [07]. x:=23; monster [07]. y:=79; monster [08]. x:=10; monster [08]. y:=81;
  monster [09]. x:=07; monster [09]. y:=78; monster [10]. x:=06; monster [10]. y:=72;
  monster [11]. x:=09; monster [11]. y:=61; monster [12]. x:=12; monster [12]. y:=34;
  monster [13]. x:=30; monster [13]. y:=39; monster [14]. x:=43; monster [14]. y:=44;
  monster [15]. x:=75; monster [15]. y:=44; monster [16]. x:=92; monster [16]. y:=52;
  monster [17]. x:=80; monster [17]. y:=61; monster [18]. x:=54; monster [18]. y:=71;
  monster [19]. x:=46; monster [19]. y:=54; monster [20]. x:=74; monster [20]. y:=54;
  bigmonster [3]. life:=10; bigmonster [3]. power:=20; bigmonster [3]. defence:=5; bigmonster [3]. name:='Attack bees';
  bigmonster [2]. life:=20; bigmonster [2]. power:=15; bigmonster [2]. defence:=8; bigmonster [2]. name:='Mad beetle';
  bigmonster [4]. life:=30; bigmonster [4]. power:=30; bigmonster [4]. defence:=10; bigmonster [4]. name:='Green slime';
  bigmonster [1]. life:=25; bigmonster [1]. power:=25; bigmonster [1]. defence:=2; bigmonster [1]. name:='Bad bug';
  monsterfilename:='monsterb';
  Repeat
    GameLoop;
    if ch = #255 then
      exit;
    if level > 2 then
      field [73, 53]:=1;
    If (x = 73) and (y = 53) and (level = 2) then begin
      object_found ('Necklace', 3, 240+3*16, 0, 'Found...');
      level:=3
    End
    else
    If (x = 13) and (y = 96) then begin
      ch:=#255;
      x:=88;
      y:=05;
      Area:=FLD_Village;
    End;
  Until (ch = #255) or (Mace_is_a_dead_man);
End;

procedure RTN_Houses;
begin
  updateinfoscrn;
  PlaySample ('opendoor.voc');
  if (area = FLD_SHOP) then
  begin
    while song. playing do
      song. fading:=8;
    loadsong ('MTP\AVALON04.MTP');
    playsong
  end
  else
  if (area = FLD_WEAPONS) then
  begin
    while song. playing do
      song. fading:=8;
    loadsong ('MTP\AVALON03.MTP');
    playsong
  end
  else
  if ((song. filename <> 'MTP\AVALON02.MTP') or not song.playing) and (level < 33) then
  begin
    while song. playing do
      song. fading:=8;
    loadsong ('MTP\AVALON02.MTP');
    playsong
  end
  else
  if ((song. filename <> 'MTP\AVALON21.MTP') or not song.playing) and (level in [33..49]) then
  begin
    while song. playing do
      song. fading:=8;
    loadsong ('MTP\AVALON21.MTP');
    playsong
  end
  else
  if ((song. filename <> 'MTP\AVALON34.MTP') or not song. playing) and (level = 50) then
  begin
    while song. playing do
      song. fading:=8;
    loadsong ('MTP\AVALON34.MTP');
    playsong
  end;
  UsePage (1);
  Load_PCX (0, 0, 319, 200, 'HOUSECL2', False);  { cellpage   }
  assign (f, 'DAT\house1.dat');                 { field data }
  init_level;
  UsePage (2);
  Load_PCX (0, 0, 319, 199, 'charpag1', False);
  human [1]. ID:=068;
  human [1]. x:=46;
  human [1]. y:=03;
  human [2]. ID:=085;
  human [2]. x:=12;
  human [2]. y:=15;
  human [3]. ID:=136;
  human [3]. x:=09;
  human [3]. y:=02;
  human [4]. ID:=119;
  human [4]. x:=08;
  human [4]. y:=28;
  human [5]. ID:=153;
  human [5]. x:=09;
  human [5]. y:=43;
  human [5]. dir:=1;
  if level = 50 then
  begin
    field [12, 11]:=123;
    field [12, 12]:=124 { stereo }
  end;
  if area = FLD_CADDMAN then
    trans [11, 42]:=66;
  Repeat
    GameLoop;
    if ch = #255 then
      exit;
    If (x = 30) and (y = 28) and (ch = #72) then begin
      StringFellowHawk (CHR_ALFA);
      SolidBox (11, 146, 249, 189, 1);
      DrawFrame (10, 145, 250, 190, 15);
      Font. SetFGColor (14);
      OutText (15, 147, '[ALFA]');
      Font. SetFGColor (15);
      TextBoxLine (155, 'Select the item you want to buy...');
      t2:=1;
      t3:=0;
      Repeat
        UsePage (3);
        DrawFrame (88, 8, 231, 122-56, 15);
        SolidBox (89, 9, 230, 121-56, 1);
        SolidBox (90, 5 + t2 * 8 + t3, 228, 12 + t2 * 8 + t3, 4);
        For t1:=1 to 6 do begin
          OutText (100, 6 + t1 * 8, itemcon [t1]. name);
          OutText (186, 6 + t1 * 8, '$ ' + Str2 (itemcon [t1]. price));
        End;
        BlockPageToPage (3, 8, 88, 1, 36, 124-56, 88, 10);
        If t3 = 0 then begin
          ch:=Readkey; If ch = #0 then ch:=Readkey;
            If (ch = #72) and (t2 > 1) then t3:= -1;
            If (ch = #80) and (t2 < 6) then t3:=1;
            If ch = #13 then begin
              PlaySample ('switch.voc');
              UsePage (0);
              SolidBox (11, 146, 249, 189, 1);
              DrawFrame (10, 145, 250, 190, 15);
              Font. SetFGColor (14);
              OutText (15, 147, '[ALFA]');
              Font. SetFGColor (15);
              TextBoxLine (155, 'The ' + itemcon [t2]. name + '.');
              TextBoxLine (163, itemcon [t2]. comment);
              TextBoxLine (179, 'Buy it ?');
              t4:=0;
              Repeat
                If t4 = 0 then begin
                  SolidBox (108, 178, 125, 185, 4);
                  SolidBox (128, 178, 145, 185, 1);
                End else begin
                  SolidBox (108, 178, 125, 185, 1);
                  SolidBox (128, 178, 145, 185, 4);
                End;
                OutText (110, 179, 'YES');
                OutText (130, 179, 'NO ');
                repeat
                  ch:=readkey;
                  if ch = #0 then
                    ch:=Readkey;
                until (ch = #75) or (ch = #77) or (ch = #13) or (ch = #27);
                PlaySample ('wall.voc');
                If ch = #75 then t4:=0;
                If ch = #77 then t4:=1;
              Until (ch = #13) or (ch = #27);
              PlaySample ('switch.voc');
              If t4 = 0 then begin
                SolidBox (11, 146, 249, 189, 1);
                DrawFrame (10, 145, 250, 190, 15);
                Font. SetFGColor (14);
                OutText (15, 147, '[ALFA]');
                Font. SetFGColor (15);
                t5:=0;
                For t1:=1 to MAXITEMS do if Items [t1]. nr > 0 then Inc (t5);
                If t5 > MAXITEMS  - 1 then begin
                  TextBoxLine (155, 'You have too many items !');
                  Readkey;
                End else if money < itemcon [t2]. price then begin
                  TextBoxLine (155, 'You do not have enough money !');
                  Readkey;
                End else begin
                  TextBoxLine (155, 'Here you are !');
                  Add_item (itemcon [t2]. name, t2);
                  Readkey;
                  Dec (money, itemcon [t2]. price);
                End;
              End;
              SolidBox (11, 146, 249, 189, 1);
              DrawFrame (10, 145, 250, 190, 15);
              Font. SetFGColor (14);
              OutText (15, 147, '[ALFA]');
              Font. SetFGColor (15);
              OutText (15, 155, 'Select the item you want to buy.');
            End;
          End else begin
            If t3 > 0 then Inc (t3) else Dec (t3);
            If (t3 = 8) or (t3 = -8) then begin
              If t3 > 0 then Inc (t2) else Dec (t2);
              t3:=0;
            End;
          End;
        Until (ch = #27);
        UpdateInfoScrn;
    End;
    If (x = 57) and (y = 16) and (ch = #72) then begin
      StringFellowHawk (CHR_MARK);
      SolidBox (11, 146, 249, 189, 1);
      DrawFrame (10, 145, 250, 190, 15);
      Font. SetFGColor (14);
      OutText (15, 147, '[MARK]');
      Font. SetFGColor (15);
      TextBoxLine (155, 'Do you wanna buy weapons or defence material ?');
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
            ch:=readkey;
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
      if (ch = #13) and (t2 = 0) then
      begin
        outtext (15, 147, '[MARK]');
        font. setfgcolor (15);
        textboxline (155, 'Please select the weapon of your choice...');
        t2:=1;
        t3:=0;
        repeat
          UsePage (3);
          WaitForRetrace;
          DrawFrame (88, 28, 232, 82, 15);
          SolidBox (89, 29, 231, 81, 1);
          SolidBox (90, 29 + t2 * 8 + t3, 230, 36 + t2 * 8 + t3, 4);
          For t1:=1 to 5 do begin
            OutText (100, 30 + t1 * 8, weaponcon [t1]. name);
            OutText (186, 30 + t1 * 8, '$ ' + Str2 (weaponcon [t1]. price));
          End;
          BlockPageToPage (3, 0, 88, 27, 37, 56, 88, 28);
          If t3 = 0 then begin
            ch:=Readkey; If ch = #0 then ch:=Readkey;
            If (ch = #72) and (t2 > 1) then t3:= -1;
            If (ch = #80) and (t2 < 5) then t3:=1;
            If ch = #13 then begin
              PlaySample ('switch.voc');
              UsePage (0);
              SolidBox (11, 146, 249, 189, 1);
              DrawFrame (10, 145, 250, 190, 15);
              Font. SetFGColor (14);
              OutText (15, 147, '[MARK]');
              Font. SetFGColor (15);
              TextBoxLine (155, 'You''ve chosen the ' + weaponcon [t2]. name + '.');
              TextBoxLine (163, weaponcon [t2]. comment);
              TextBoxLine (179, 'Wanna buy it ?');
              t4:=0;
              Repeat
                If t4 = 0 then begin
                  SolidBox (108, 178, 125, 185, 4);
                  SolidBox (128, 178, 145, 185, 1);
                End else begin
                  SolidBox (108, 178, 125, 185, 1);
                  SolidBox (128, 178, 145, 185, 4);
                End;
                OutText (110, 179, 'YES');
                OutText (130, 179, 'NO ');
                Repeat
                  ch:=Readkey; If ch = #0 then ch:=Readkey;
                Until (ch = #75) or (ch = #77) or (ch = #13) or (ch = #27);
                PlaySample ('wall.voc');
                If ch = #75 then t4:=0;
                If ch = #77 then t4:=1;
              Until (ch = #13) or (ch = #27);
              PlaySample ('switch.voc');
              If t4 = 0 then begin
                SolidBox (11, 146, 249, 189, 1);
                DrawFrame (10, 145, 250, 190, 15);
                Font. SetFGColor (14);
                OutText (15, 147, '[MARK]');
                Font. SetFGColor (15);
                If money < weaponcon [t2]. price then begin
                  TextBoxLine (155, 'You cannot afford it !');
                  Readkey;
                End else if weaponcon [t2]. power <= power then begin
                  TextBoxLine (155, 'You already have a better one !');
                  Readkey;
                End else begin
                  TextBoxLine (155, 'Thank you ! Have fun with it !');
                  weapon:=t2;
                  power:=weaponcon [t2]. power;
                  Readkey;
                  Dec (money, weaponcon [t2]. price);
                End;
              End;
              SolidBox (11, 146, 249, 189, 1);
              DrawFrame (10, 145, 250, 190, 15);
              Font. SetFGColor (14);
              OutText (15, 147, '[MARK]');
              Font. SetFGColor (15);
              OutText (15, 155, 'Please select the weapon of your choice...');
            End;
          End else begin
            If t3 > 0 then Inc (t3) else Dec (t3);
            If (t3 = 8) or (t3 = -8) then begin
              If t3 > 0 then Inc (t2) else Dec (t2);
              t3:=0;
            End;
          End;
        Until (ch = #27);
        UpdateInfoScrn;
      End
      else
      if (ch = #13) and (t2 = 1) then begin
        OutText (15, 147, '[MARK]');
        Font. SetFGColor (15);
        TextBoxLine (155, 'Please select a shield of your choice...');
        t2:=1;
        t3:=0;
        Repeat
          UsePage (3);
          WaitForRetrace;
          DrawFrame (88, 28, 232, 82, 15);
          SolidBox (89, 29, 231, 81, 1);
          SolidBox (90, 29 + t2 * 8 + t3, 230, 36 + t2 * 8 + t3, 4);
          For t1:=1 to 5 do begin
            OutText (100, 30 + t1 * 8, shieldcon [t1]. name);
            OutText (186, 30 + t1 * 8, '$ ' + Str2 (shieldcon [t1]. price));
          End;
          BlockPageToPage (3, 0, 88, 27, 37, 56, 88, 28);
          If t3 = 0 then begin
            ch:=Readkey; If ch = #0 then ch:=Readkey;
            If (ch = #72) and (t2 > 1) then t3:=-1;
            If (ch = #80) and (t2 < 5) then t3:=1;
            If ch = #13 then begin
              PlaySample ('switch.voc');
              UsePage (0);
              SolidBox (11, 146, 249, 189, 1);
              DrawFrame (10, 145, 250, 190, 15);
              Font. SetFGColor (14);
              OutText (15, 147, '[MARK]');
              Font. SetFGColor (15);
              TextBoxLine (155, 'You''ve chosen the ' + shieldcon [t2]. name + '.');
              TextBoxLine (163, shieldcon [t2]. comment);
              TextBoxLine (179, 'Wanna buy it ?');
              t4:=0;
              Repeat
                If t4 = 0 then begin
                  SolidBox (108, 178, 125, 185, 4);
                  SolidBox (128, 178, 145, 185, 1);
                End else begin
                  SolidBox (108, 178, 125, 185, 1);
                  SolidBox (128, 178, 145, 185, 4);
                End;
                OutText (110, 179, 'YES');
                OutText (130, 179, 'NO ');
                Repeat
                  ch:=Readkey; If ch = #0 then ch:=Readkey;
                Until (ch = #75) or (ch = #77) or (ch = #13) or (ch = #27);
                PlaySample ('wall.voc');
                if ch = #75 then
                  t4:=0;
                if ch = #77 then
                  t4:=1;
              Until (ch = #13) or (ch = #27);
              PlaySample ('switch.voc');
              If t4 = 0 then begin
                SolidBox (11, 146, 249, 189, 1);
                DrawFrame (10, 145, 250, 190, 15);
                Font. SetFGColor (14);
                OutText (15, 147, '[MARK]');
                Font. SetFGColor (15);
                If money < shieldcon [t2]. price then begin
                  TextBoxLine (155, 'You don''t have enough money !');
                  Readkey;
                End else if shieldcon [t2]. power <= defence then begin
                  TextBoxLine (155, 'You already have a better one !');
                  Readkey;
                End else begin
                  TextBoxLine (155, 'Thank you very much !');
                  shield:=t2;
                  defence:=shieldcon [t2]. power;
                  Readkey;
                  Dec (money, shieldcon [t2]. price);
                End;
              End;
              SolidBox (11, 146, 249, 189, 1);
              DrawFrame (10, 145, 250, 190, 15);
              Font. SetFGColor (14);
              OutText (15, 147, '[MARK]');
              Font. SetFGColor (15);
              OutText (15, 155, 'Please select the shield of your choice...');
            End;
          End else begin
            If t3 > 0 then Inc (t3) else Dec (t3);
            If (t3 = 8) or (t3 = -8) then begin
              If t3 > 0 then Inc (t2) else Dec (t2);
              t3:=0
            End
          End
        until (ch = #27)
      end;
      UpdateInfoScrn;
    End;
    If ((x = 8) and (y = 7)) then begin
      ch:=#255; ShowScreen (x, y, 0, 0);
      x:=9;
      y:=14;
      Area:=FLD_Village
    End else if (x = 41) and (y = 9) then begin
      ch:=#255; ShowScreen (x, y, 0, 0);
      x:=12;
      y:=38;
      Area:=FLD_Village
    End else if (x = 10) and (y = 19) then begin
      ch:=#255; ShowScreen (x, y, 0, 0);
      x:=12;
      y:=27;
      Area:=FLD_Village
    End else if (x = 30) and (y = 21) then begin
      ch:=#255; ShowScreen (x, y, 0, 0);
      x:=23;
      y:=19;
      Area:=FLD_Village
    End else if (x = 15) and (y = 30) then begin
      ch:=#255; ShowScreen (x, y, 0, 0);
      x:=27;
      y:=27;
      Area:=FLD_Village
    End else if (x = 28) and (y = 35) then begin
      ch:=#255; ShowScreen (x, y, 0, 0);
      x:=42;
      y:=39;
      Area:=FLD_Village
    End else if (x = 47) and (y = 20) then begin
      ch:=#255; ShowScreen (x, y, 0, 0);
      x:=51;
      y:=22;
      Area:=FLD_Village
    End
    else
    if (x = 02) and (y = 44) then
    begin
      ch:=#255; ShowScreen (x, y, 0, 0);
      x:=3;
      y:=58;
      Area:=FLD_Village
    end
    else
    if (x = 12) and (y = 12) and (level = 50) and (direction = 1) then
      stereo;
  Until (ch = #255) or (Mace_is_a_dead_man);
  PlaySample ('opendoor.voc');
End;

procedure mace_almost_died;
begin
   fake_game_over;
   loadsong ('MTP\AVALON21.MTP');
   playsong;
   area:=FLD_CADDMAN;
   x:=11;
   y:=42;
   direction:=0;
   delay (400);
   usepage (0);
   load_pcx (0, 0, 319, 199, 'SCREEN2', true);
   usepage (1);
   clearpage (0);
   showscreen (x, y, 0, 0);
   stringfellowhawk (CHR_CADDMAN);
   level:=32;
   usepage (1);
   load_pcx (0, 0, 319, 200, 'HOUSECL2', False);
   assign (f, 'DAT\house1.dat');
   usepage (2);
   load_pcx (0, 0, 319, 199, 'charpag1', False);
   init_level;
   human [1]. x:=9;
   human [1]. y:=42;
   human [1]. dir:=2;
   human [1]. ID:=153;
   showscreen (x, y, 0, 0);
   ch:=#255;
   stringfellowhawk (CHR_CADDMAN);
   mace_is_a_dead_man:=false;
   x:=10;
   level:=33;
   direction:=4
end;

begin
  { start read config file }
  assign (f, 'avalon.cfg');
  reset (f);
  for t1:=1 to 3 do
    readln (f, s);
  readln (f, t1);
  battle_music:=(t1 = 1);
  readln (f, s);
  readln (f, t1);
  wavetable_on:=(t1 = 1);
  readln (f, s);
  readln (f, t1);
  sound_on:=(t1 = 1);
  close (f);
  { end read config file }

  darklord:=false;
  animation:=false;
  gameover:=true;
  waterflow:=110;
  with Regs do
  begin
    AX:=$0305;
    BH:=0;
    BL:=0;
    Intr ($16, Regs)
  end;
  if sound_on then
  begin
    init_dsp;
    dma_stop
  end;
  introscreen;
  repeat
    titlescreen;
    if t1 > 0 then
    begin
      t2:=t1;
      readdata
    end
    else
      initialize;
    usepage (3);
    clearpage (0);
    usepage (0);
    showpage (3);
    load_pcx (0, 0, 319, 199, 'SCREEN2', true);
    repeat
      show_loading;
      case Area of
        FLD_VILLAGE  : rtn_village;
        FLD_HOUSE1   : rtn_houses;
        FLD_HOUSE2   : rtn_houses;
        FLD_HOUSE3   : rtn_houses;
        FLD_HOUSE4   : rtn_houses;
        FLD_HOUSE5   : rtn_houses;
        FLD_SHOP     : rtn_houses;
        FLD_WEAPONS  : rtn_houses;
        FLD_CADDMAN  : rtn_houses;
        FLD_FOREST   : rtn_forest;
        FLD_CAVE     : rtn_cave;
        FLD_CAVE2    : rtn_cave2;
        FLD_BEACH1   : rtn_beach1;
        FLD_BEACH2   : rtn_beach2;
        FLD_WATER    : rtn_water;
        FLD_WATERCAV : rtn_watercav;
        FLD_CASTLE1  : rtn_castle;
        FLD_ENTRANCE : rtn_entrance;
        FLD_DUNGEON  : rtn_dungeon;
        FLD_ALIENVIL : rtn_alienvil;
        FLD_ALIENHOU : rtn_alienhou;
        FLD_CASTLE2  : rtn_castle;
        FLD_CASTLE3  : rtn_castle;
        FLD_CELLAR   : rtn_castle;
        FLD_GARDEN   : rtn_garden;
        FLD_SNOW     : rtn_snow;
        FLD_CAVEMNT  : rtn_cavemnt;
        FLD_DARKROOM : rtn_darkroom;
        FLD_GREYCAVE : rtn_greycave;
        FLD_ENTRDOWN : rtn_entrdown;
        FLD_WTENTR   : rtn_wtentr;
        FLD_WTOWER   : rtn_wtower
      end;
      if mace_is_a_dead_man and (level = 31) then
        mace_almost_died
    until Mace_is_a_dead_man;
    if gameover then
      game_over
    else
      gameover:=true;
    mace_is_a_dead_man:=false;
  until de_aarde = plat
End.

