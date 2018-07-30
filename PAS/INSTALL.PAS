program Avalon_install;

uses boxes, crt, heapman;

var
  f        : text;
  s        : string;
  t1, t2   : integer;
  menu     : byte;
  port,
  dma,
  irq,
  gmport,
  musicon,
  soundon,
  battleon : word;
  ch       : char;

Function Val2 (s : String) : Integer;
Var w1, w2 : Integer;
Begin
  Val (s, w1, w2);
  Val2:=w1;
End;

begin
  with c do
  begin
    bg:=0;
    fg:=15;
    bc:=1
  end;
  textmode (10);
  specialbox (1, 1, 80, 21, $1F, 'READ THIS FIRST');
  textcolor (15);
  gotoxy (3, 3);
  writeln ('This is the Avalon sound configuration utility.');
  textcolor (14);
  gotoxy (3, 5);
  writeln ('Before you play Avalon, you should check if the settings are correct');
  gotoxy (3, 6);
  writeln ('for your system.');
  gotoxy (3, 8);
  writeln ('The MIDI music was designed to work on any soundcard supporting Wavetable.');
  gotoxy (3, 9);
  writeln ('The music was tested on: AWE 32, SB 32, AWE 64 VE, AWE 64 Gold and');
  gotoxy (3, 10);
  writeln ('Roland Sound Canvas with SB 16. It will also work on external MIDI devices,');
  gotoxy (3, 11);
  writeln ('such as keyboards and synthesizers if they are GM compatible.');
  gotoxy (3, 13);
  writeln ('For the Soundblaster compatible cards with 2 or 8 MB RAM soundfonts are');
  gotoxy (3, 14);
  writeln ('included in the AVALON\SFONT directory. You can load those in the');
  gotoxy (3, 15);
  writeln ('AWE Control Panel.');
  gotoxy (3, 17);
  writeln ('Notice that the sound test, if the settings are incorrect could cause ');
  gotoxy (3, 18);
  writeln ('a computer "HANG".');
  gotoxy (3, 20);
  textcolor (51);
  writeln ('                           PRESS A KEY TO CONTINUE');
  readkey;
  clrscr;
  specialbox (20, 5, 60, 21, $1F, 'AVALON SETUP');
  textcolor (15);
  assign (f, 'AVALON.CFG');
  reset (f);
    for t1:=1 to 3 do
      readln (f, s);
    readln (f, t1);
    battleon:=t1;
    readln (f, s);
    readln (f, t1);
    musicon:=t1;
    readln (f, s);
    readln (f, t1);
    soundon:=t1;
  close (f);
  assign (f, 'GMPORT.CFG');
  reset (f);
    readln (f, s);
    gmport:=val2 ('$' + s);
  close (f);
  assign (f, 'SOUND.CFG');
  reset (f);
    readln (f, s);
    port:=val2 ('$' + s);
    readln (f, irq);
    readln (f, dma);
  close (f);
  menu:=1;
  repeat
    repeat
      gotoxy (22, 07);
      if menu = 1 then
        textbackground (1)
      else
        textbackground (0);
      writeln ('Sound             ');
      textbackground (0);
      gotoxy (22, 08);
      if menu = 2 then
        textbackground (1)
      else
        textbackground (0);
      writeln ('Background Music  ');
      gotoxy (22, 09);
      if menu = 3 then
        textbackground (1)
      else
        textbackground (0);
      writeln ('Battletune        ');
      gotoxy (22, 11);
      if menu = 4 then
        textbackground (1)
      else
        textbackground (0);
      writeln ('General Midi Port ');
      gotoxy (22, 13);
      if menu = 5 then
        textbackground (1)
      else
        textbackground (0);
      writeln ('Soundblaster Port ');
      gotoxy (22, 14);
      if menu = 6 then
        textbackground (1)
      else
        textbackground (0);
      writeln ('Soundblaster IRQ  ');
      gotoxy (22, 15);
      if menu = 7 then
        textbackground (1)
      else
        textbackground (0);
      writeln ('Soundblaster DMA  ');
      textcolor (15);
      gotoxy (43, 07);
      if soundon = 1 then
        textbackground (4)
      else
        textbackground (0);
      write ('ON ');
      textbackground (0);
      write (' ');
      if soundon = 2 then
        textbackground (4)
      else
        textbackground (0);
      write ('OFF');
      textbackground (0);
      gotoxy (43, 08);
      if musicon = 1 then
        textbackground (4)
      else
        textbackground (0);
      write ('ON ');
      textbackground (0);
      write (' ');
      if musicon = 2 then
        textbackground (4)
      else
        textbackground (0);
      write ('OFF');
      textbackground (0);
      gotoxy (43, 09);
      if battleon = 1 then
        textbackground (4)
      else
        textbackground (0);
      write ('ON ');
      textbackground (0);
      write (' ');
      if battleon = 2 then
        textbackground (4)
      else
        textbackground (0);
      write ('OFF');
      textbackground (0);
      gotoxy (43, 11);
      if gmport = $330 then
        textbackground (4)
      else
        textbackground (0);
      write ('330');
      textbackground (0);
      write (' ');
      if gmport = $331 then
        textbackground (4)
      else
        textbackground (0);
      write ('331');
      textbackground (0);
      write (' ');
      if gmport = $341 then
        textbackground (4)
      else
        textbackground (0);
      write ('341');
      gotoxy (43, 13);
      if port = $220 then
        textbackground (4)
      else
        textbackground (0);
      write ('220');
      textbackground (0);
      write (' ');
      if port = $240 then
        textbackground (4)
      else
        textbackground (0);
      write ('240');
      textbackground (0);
      gotoxy (45, 14);
      if irq = 5 then
        textbackground (4)
      else
        textbackground (0);
      write ('5');
      textbackground (0);
      write ('   ');
      if irq = 7 then
        textbackground (4)
      else
        textbackground (0);
      write ('7');
      textbackground (0);
      write ('   ');
      if irq = 9 then
        textbackground (4)
      else
        textbackground (0);
      write ('9');
      textbackground (0);
      gotoxy (45, 15);
      if dma = 0 then
        textbackground (4)
      else
         textbackground (0);
      write ('0');
      textbackground (0);
      write ('   ');
      if dma = 1 then
        textbackground (4)
      else
        textbackground (0);
      write ('1');
      textbackground (0);
      write ('   ');
      if dma = 2 then
        textbackground (4)
      else
        textbackground (0);
      write ('2');
      textbackground (0);
      gotoxy (22, 17);
      if menu = 8 then
        textbackground (1)
      else
        textbackground (0);
      writeln ('Sound Test        ');
      gotoxy (22, 18);
      if menu = 9 then
        textbackground (1)
      else
        textbackground (0);
      writeln ('Music Test        ');
      gotoxy (22, 20);
      if menu = 10 then
        textbackground (1)
      else
        textbackground (0);
      writeln ('Exit and Save Settings');
    until keypressed;
    ch:=readkey;
    if (ch = #13) or (ch = #32) then
    begin
      case menu of
        1 :
        begin
          if soundon = 1 then
            soundon:=2
          else
            soundon:=1
        end;
        2 :
        begin
          if musicon = 1 then
            musicon:=2
          else
            musicon:=1

        end;
        3 :
        begin
          if battleon = 1 then
            battleon:=2
          else
            battleon:=1
        end;
        4 :
        begin
          if gmport = $330 then
            gmport:=$331
          else
          if gmport = $331 then
            gmport:=$341
          else
            gmport:=$330;
        end;
        5 :
        begin
          if port = $220 then
            port:=$240
          else
            port:=$220
        end;
        6 :
        begin
          if irq = 5 then
            irq:=7
          else
          if irq = 7 then
            irq:=9
          else
            irq:=5;
        end;
        7 :
        begin
          if dma = 0 then
            dma:=1
          else
          if dma = 1 then
            dma:=2
          else
            dma:=0;
        end;
        8 : execute ('SOUNDTST.EXE', '');
        9 : execute ('MUSICTST.EXE', '')
      end
    end
    else
    if ch = #0 then
    begin
      ch:=readkey;
      if ch = #72 then
      begin
        dec (menu);
        if menu < 1 then menu:=10
      end;
      if ch = #80 then
      begin
        inc (menu);
        if menu > 10 then menu:=1
      end;
    end;
  until ((menu = 10) and ((ch = #13) or (ch = #32))) or (ch = #27);
  if ch <> #27 then
  begin
    assign (f, 'AVALON.CFG');
    rewrite (f);
      writeln (f, 'Avalon Configuration File');
      writeln (f, '-------------------------');
      writeln (f, 'Battle Music (1 = ON 2 = OFF)');
      writeln (f, battleon);
      writeln (f, 'Background Music (1 = ON 2 = OFF)');
      writeln (f, musicon);
      writeln (f, 'Sound (1 = ON 2 = OFF)');
      writeln (f, soundon);
    close (f);
    assign (f, 'GMPORT.CFG');
    rewrite (f);
      case gmport of
        $330 : writeln (f, 330);
        $331 : writeln (f, 331);
        $341 : writeln (f, 341)
      end;
    close (f);
    assign (f, 'SOUND.CFG');
    rewrite (f);
      if port = $220 then
        writeln (f, 220)
      else
        writeln (f, 240);
      writeln (f, irq);
      writeln (f, dma);
    close (f);
  end;
  textmode (CO80)
end.
