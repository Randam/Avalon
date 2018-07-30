unit avglob;

interface

uses common,
     modex;

type humantp = record
       id              : integer;
       x               : byte;
       y               : byte;
       spritenr        : boolean;
       dir             : byte;
       xplus           : integer;
       yplus           : integer;
     end;

     monstertp = record
       ID              : integer;
       x               : byte;
       y               : byte;
       spritenr        : boolean;
       dir             : byte;
       xplus           : integer;
       yplus           : integer;
       number          : byte;
     end;

     bigmonstertp = record
       Life            : integer;
       Power           : word;
       Defence         : word;
       maxlife         : word;
       Name            : string [20];
     end;

     shlddefTp = record
       name            : string [20];
       power           : word;
       price           : word;
       comment         : string [50];
     end;

     wepdeftp = record
       name            : string [20];
       power           : word;
       price           : word;
       fnr             : char;
       comment         : string [50];
     end;

     itemtp = record
       name            : string [20];
       price           : word;
       comment         : string [50];
     end;

     areatp = record
       name            : string [25];
       filen           : packed array [1..8] of char;
     end;

     SoundBufType = Array [1..65528] of Byte;

     objectstp = record
       name            : string [20];
       nr              : word;
     end;

const
    MAXITEMS        = 50;
    XCENTRE         = 500;

      { Characters }
      CHR_ALFA     = 01;    CHR_FLEUR    = 02;
      CHR_MARK     = 03;    CHR_TRACER   = 04;
      CHR_FRANK    = 05;    CHR_SASKIA   = 06;
      CHR_WILLY    = 07;    CHR_WALLY    = 08;
      CHR_JOHN     = 09;    CHR_SNAKE    = 10;
      CHR_CHICKEN1 = 11;    CHR_CHICKEN2 = 12;
      CHR_KREZNJRK = 13;    CHR_GUARDS   = 14;
      CHR_LEE      = 15;    CHR_SRAM     = 16;
      CHR_CAW      = 17;    CHR_KNARF    = 18;
      CHR_NEOREJ   = 19;    CHR_REDNAEL  = 20;
      CHR_CADDMAN  = 21;    CHR_RSNAKE   = 22;
      CHR_MACE     = 23;    CHR_DARKLORD = 24;
      CHR_WTSIGN   = 25;    CHR_CSIGN    = 26;

      { Textfile names }
      TXTFILE : Array [1..26] of String =
      ('ALFA    ',      'FLEUR   ',
       'MARK    ',      'TRACER  ',
       'FRANK   ',      'SASKIA  ',
       'WILLY   ',      'WALLY   ',
       'JOHN    ',      'SNAKE   ',
       'CHICKEN1',      'CHICKEN2',
       'KREZNJRK',      'GUARDS  ',
       'LEE     ',      'SRAM    ',
       'CAW     ',      'KNARF   ',
       'NEOREJ  ',      'REDNAEL ',
       'CADDMAN ',      'RSNAKE  ',
       'MACE    ',      'DARKLORD',
       'WTSIGN  ',      'CSIGN   ');


      { Areas }
      FLD_VILLAGE  = 01;    FLD_SHOP     = 02;
      FLD_HOUSE1   = 03;    FLD_HOUSE2   = 04;
      FLD_HOUSE3   = 05;    FLD_HOUSE4   = 06;
      FLD_HOUSE5   = 07;    FLD_WEAPONS  = 08;
      FLD_CADDMAN  = 09;    FLD_FOREST   = 10;
      FLD_CAVE     = 11;    FLD_BEACH1   = 12;
      FLD_BEACH2   = 13;    FLD_CAVE2    = 14;
      FLD_WATER    = 15;    FLD_WATERCAV = 16;
      FLD_DUNGEON  = 17;    FLD_ENTRANCE = 18;
      FLD_ALIENVIL = 19;    FLD_ALIENHOU = 20;
      FLD_CELLAR   = 21;    FLD_CASTLE1  = 22;
      FLD_CASTLE2  = 23;    FLD_CASTLE3  = 24;
      FLD_GARDEN   = 25;    FLD_SNOW     = 26;
      FLD_CAVEMNT  = 27;    FLD_DARKROOM = 28;
      FLD_GREYCAVE = 29;    FLD_ENTRDOWN = 30;
      FLD_WTENTR   = 31;    FLD_WTOWER   = 32;

      DE_AARDE = true;
      PLAT     = false;
      WIT      = false;
      GEEL     = true;

  arean : array [1..32] of areatp = (
    (name: 'The Village';              filen: 'CELLS   '),
    (name: 'Alfa''s Shop';             filen: 'HOUSECL2'),
    (name: 'Willy and Wally''s Home';  filen: 'HOUSECL2'),
    (name: 'Lee''s Home';              filen: 'HOUSECL2'),
    (name: 'Mace''s Home';             filen: 'HOUSECL2'),
    (name: 'John''s Home';             filen: 'HOUSECL2'),
    (name: 'Frank and Saskia''s Home'; filen: 'HOUSECL2'),
    (name: 'Mark''s Weaponstore';      filen: 'HOUSECL2'),
    (name: 'Caddman''s Home';          filen: 'HOUSECL2'),
    (name: 'The Forest';               filen: 'CELLS   '),
    (name: 'The Mine';                 filen: 'CAVECEL '),
    (name: 'The Beach';                filen: 'BEACH   '),
    (name: 'The Beach';                filen: 'BEACH   '),
    (name: 'Eastern Cave';             filen: 'CAVECEL '),
    (name: 'The Sea';                  filen: 'WATER2  '),
    (name: 'The Secret Cave';          filen: 'WATERCAV'),
    (name: 'The Dungeon';              filen: 'KERKER  '),
    (name: 'The Castle Entrance';      filen: 'ENTRANCE'),
    (name: 'The Alien Village';        filen: 'ALIENVIL'),
    (name: 'Alien House';              filen: 'ALIENHOU'),
    (name: 'The Cellar';               filen: 'CASTLE  '),
    (name: 'The Castle';               filen: 'CASTLE  '),
    (name: 'The Castle';               filen: 'CASTLE  '),
    (name: 'The Castle';               filen: 'CASTLE  '),
    (name: 'The Castle Garden';        filen: 'GARDEN  '),
    (name: 'The Mountains';            filen: 'SNOW    '),
    (name: 'The Endless Cave';         filen: 'CAVECEL '),
    (name: 'The Dark Room';            filen: 'CASTLE  '),
    (name: 'Gray Cave';                filen: 'GREYCAVE'),
    (name: 'The Castle Entrance';      filen: 'ENTRANCE'),
    (name: 'The White Tower Entrance'; filen: 'WTENTR  '),
    (name: 'The White Tower';          filen: 'WTOWERG '));

      weaponcon : array [0..11] of wepdeftp =
      ((name: 'NONE';           power:  10; price:     0; fnr: '1'; comment: ''),
       (name: 'KNIFE';          power:  20; price:   100; fnr: '2'; comment: 'This knife will enhance your power.'),
       (name: 'LONGBOW';        power:  35; price:   300; fnr: '3'; comment: 'This is good weapon for an amateur.'),
       (name: 'SHORT SWORD';    power:  50; price:   500; fnr: '4'; comment: 'This weapon was made of the finest steel.'),
       (name: 'AXE';            power:  60; price:   800; fnr: '5'; comment: 'They all love this one !'),
       (name: 'HEAVY AXE';      power:  80; price:  1000; fnr: '6'; comment: 'Go kick some ass with this baby !'),
       (name: 'HANDGUN';        power: 100; price:  1200; fnr: '8'; comment: 'A walter PPK, an old but reliable weapon.'),
       (name: 'SHOTGUN';        power: 120; price:  1500; fnr: '7'; comment: 'This one really makes life easier for you.'),
       (name: 'UZI';            power: 150; price:  3000; fnr: '9'; comment: 'You can really make a mess with this one.'),
       (name: 'LASERGUN';       power: 200; price:  5000; fnr: 'A'; comment: 'A state-of-the-art hi-tech weapon.'),
       (name: 'ROCKETLAUNCHER'; power: 270; price: 10000; fnr: 'B'; comment: 'Huhu...huhuuhuuhu !!!'),
       (name: 'VAPORIZER';      power: 500; price:     0; fnr: 'C'; comment: ''));

      shieldcon : array [0..10] of shlddeftp =
      ((name: 'NONE';              power:   5; price:     0; comment: ''),
       (name: 'AUSTRALIAN';        power:   8; price:   200; comment: 'A nice and comfortable suit.'),
       (name: 'LEATHER JACKET';    power:  12; price:   300; comment: 'High quality leather, you''ll like it.'),
       (name: 'TABBERT';           power:  20; price:   700; comment: 'Nice protection for your whole body.'),
       (name: 'CAMOUFLAGE OUTFIT'; power:  25; price:  1000; comment: 'The original from the US army.'),
       (name: 'IRON SHIELD';       power:  30; price:  1200; comment: 'Strong and very heavy defence.'),
       (name: 'BULLETPROOF VEST';  power:  35; price:  1500; comment: 'Plug ''n play !'),
       (name: 'STEEL COAT';        power:  40; price:  2300; comment: 'High quality stainless steel.'),
       (name: 'FORCE FIELD';       power:  45; price:  4000; comment: 'Nice defence with free batteries.'),
       (name: 'PLASMA SHIELD';     power:  50; price:  7000; comment: 'Great defence with 100% money-back warranty.'),
       (name: 'MATRIX OVERDRIVE';  power:  60; price: 10000; comment: 'The best ! Even Rambo uses it in Rambo MCIX !'));

      itemcon : array [1..13] of itemtp =
      ((name: 'HANDGRENADE';        price:    60; comment: 'A powerful weapon. Causes a nice explosion !'),
       (name: 'FIRST AID KIT';      price:    25; comment: 'Returns some of your life.'),
       (name: 'SMALL MEDIC KIT';    price:    50; comment: 'Useful to restore life in battle.'),
       (name: 'LARGE MEDIC KIT';    price:   100; comment: 'Restores more life than the SMALL one.'),
       (name: 'HEAVY GRENADE';      price:   200; comment: 'Power for professional killers.'),
       (name: 'MEDIA KIT 2000';     price:   500; comment: 'Restores all of your life.'),
       (name: 'PARALYSER';          price:   350; comment: 'Paralyses your ememy for some time.'),
       (name: 'LIGHT DEFPEN';       price:   150; comment: 'The Defence Penetrator lowers defence.'),
       (name: 'HEAVY DEFPEN';       price:   250; comment: 'This DEFPEN lowers lots of defence.'),
       (name: 'BABY POWERSUCKER';   price:   150; comment: 'Use this to lower the power of your opponent.'),
       (name: 'STRONG PW SUCKER';   price:   300; comment: 'The best attack neutraliser available.'),
       (name: 'HIV VIRUS';          price:   500; comment: 'Very effective virus. Be careful with it !'),
       (name: 'NUCLEAR MISSILE';    price: 10000; comment: 'Don''t ever use this....'));

var
    x,
    y,
    x_cell,
    y_cell             : byte;
    number,
    t1,
    t2,
    t3,
    t4,
    t5                 : integer;
    ch                 : char;
    s                  : string;
    f                  : text;
    monster            : array [1..20] of monstertp;
    human              : array [1..10] of humantp;
    bigmonster         : array [1..4] of bigMonstertp;
    chapter,
    area               : byte;
    time1,
    time2              : longInt;
    touchedHuman       : array [1..10] of boolean;
    touchedcount       : byte;
    mnr                : array [1..2] of byte;
    mx                 : array [1..2] of byte;
    mmax               : byte;
    treal              : real;
    actmonster         : array [1..2] of bigmonstertp;
    monsterbak         : array [1..2] of bigmonstertp;
    mace_is_a_dead_man : boolean;
    event_Happend      : array [1..40] of boolean;
    fleed              : boolean;
    candle             : boolean;
    candle_count       : byte;
    lee_walks          : byte;
    levelbak           : word;
    tmpower            : integer;
    gameover           : boolean;
    waterflow          : byte;
    battle_music       : boolean;
    paralized          : byte;
    monsterfilename    : string;
    Field              : Array [-10..110 , -10..110] of Byte;
    Trans              : Array [-10..110 , -10..110] of Byte;
    CellStatus         : Array [0..142] of Byte;
    sounddat           : ^SoundBufType;
    fl                 : File;
    st                 : Word;
    freq               : Word;
    Objects            : array [1..20] of objectstp;
    Items              : array [1..MAXITEMS] of objectstp;
    h : Record
      signature        : Array [1..19] of Char;
      Terminator       : Byte;
      data_start       : Word;
      version          : Integer;
      id               : Integer;
    End;
    d : Record
      id               : Byte;
      len              : Array [1..3] of Byte;
      sr               : Byte;
      pack             : Byte;
    End;
    Head            : Word   Absolute $0040:$001A;
    Tail            : Word   Absolute $0040:$001C;
    font            : PrFontObj;
    pict_buffer     : PictHeader;
    pict_mask       : BytePtr;
    pl              : Array [0..255, 1..3] of Byte;
    pr              : Array [0..255, 1..3] of Byte;
    r,
    g,
    b               : Byte;
    moonwalk,
    exitdemo        : Boolean;
    timer           : Longint;
    hitmonster      : integer;
    supermonster,
    darklord        : boolean;
    balk            : array [1..16] of byte;
    animation       : boolean;
    sound_on        : boolean;
    dsp_init_boolean: boolean;
    cloud_x1        : word;
    cloud_x2        : word;
    tmplevel        : word;

{ Player's values }
    direction          : byte;
    exp,
    exp_nextlevel,
    life               : word;
    maxlife            : word;
    money              : longint;
    power              : word;
    defence            : word;
    weapon             : word;
    shield             : word;
    monsters_killed    : longint;
    playing_time       : longint;
    level              : word;
    old_chapter        : byte;

implementation

begin
end.