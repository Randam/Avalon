{$A+,B-,D+,E+,F-,G+,I+,L+,N-,P-,Q-,R-,S-,T-,V-,X+,Y+}

Unit Modex;
Interface
Uses
  Common,
  DOS;

Const
  { Video Constants }
  SC_INDEX = $3C4;
  SC_RESET = 0;
  SC_CLOCK = 1;
  SC_MAPMASK = 2;
  SC_CHARMAP = 3;
  SC_MEMMODE = 4;

  CRTC_INDEX = $3D4;
  CRTC_H_TOTAL = 0;
  CRTC_H_DISPEND = 1;
  CRTC_H_BLANK = 2;
  CRTC_H_ENDBLANK = 3;
  CRTC_H_RETRACE = 4;
  CRTC_H_ENDRETRACE = 5;
  CRTC_V_TOTAL = 6;
  CRTC_OVERFLOW = 7;
  CRTC_ROWSCAN = 8;
  CRTC_MAXSCANLINE = 9;
  CRTC_CURSORSTART = 10;
  CRTC_CURSOREND = 11;
  CRTC_STARTHIGH = 12;
  CRTC_STARTLOW = 13;
  CRTC_CURSORHIGH = 14;
  CRTC_CURSORLOW = 15;
  CRTC_V_RETRACE = 16;
  CRTC_V_ENDRETRACE = 17;
  CRTC_V_DISPEND = 18;
  CRTC_OFFSET = 19;
  CRTC_UNDERLINE = 20;
  CRTC_V_BLANK = 21;
  CRTC_V_ENDBLANK = 22;
  CRTC_MODE = 23;
  CRTC_LINECOMPARE = 24;


  GC_INDEX = $3CE;
  GC_SETRESET = 0;
  GC_ENABLESETRESET = 1;
  GC_COLORCOMPARE = 2;
  GC_DATAROTATE = 3;
  GC_READMAP = 4;
  GC_MODE = 5;
  GC_MISCELLANEOUS = 6;
  GC_COLORDONTCARE = 7;
  GC_BITMASK = 8;

  ATR_INDEX = $3C0;
  ATR_MODE = 16;
  ATR_OVERSCAN = 17;
  ATR_COLORPLANEENABLE = 18;
  ATR_PELPAN = 19;
  ATR_COLORSELECT = 20;

  STATUS_REGISTER_1 = $3DA;

  PEL_WRITE_ADR = $3C8;
  PEL_READ_ADR = $3C7;
  PEL_DATA = $3C9;

  ViewPage : Word = 0;
  WritePage : Word = 0;

  LeftMask : Array[0..3] Of Byte = ($0F, $0E, $0C, $08);
  RightMask : Array[0..3] Of Byte = ($01, $03, $07, $0F);

  MODE200 = 0;
  MODE240 = 1;

  TRANSPARENT = $0000;
  XOR_WRITE = $8000;

  VPAGE1 = 0;
  VPAGE2 = 1;
  VPAGE3 = 2;
  VSCRATCH = 3;

  MISC_OUTPUT = $3C2;  {Miscellaneous Output register}
  MAP_MASK = $02;      {index of Map Mask Register}
  BIT_MASK = $08;      {index in GC of Bit Mask Register}
  READ_MAP = $04;      {index of Map Mask Register}

  {Event handler Constants}
  NULL_EVENT  = 0;
  KEY_EVENT = $0080;
  MOUSE_EVENT = $007F;

  MOUSE_MV = $0001;   { Mouse movement occurred }
  LB_PRESS = $0002;   { Left button pressed     }
  LB_OFF = $0004;     { Left button released    }
  RB_PRESS = $0008;   { Right button pressed    }
  RB_OFF = $0010;     { Right button released   }
  CB_OFF = $0020;     { Center button released  }
  CB_PRESS = $0040;   { Center button pressed   }

  SHIFT_PRESSED = $0008;  { key shift masks     }
  RSHIFT_PRESSED = $0010;
  LSHIFT_PRESSED = $0020;
  CTRL_PRESSED = $0040;
  ALT_PRESSED = $0080;

  NULLCHAR = 0;
  BS  = 8;
  TAB = 9;
  SftTAB = $0F00;
  LF = 10;
  CR = 13;
  ESC = 27;
  SPACE = 32;

  UpKey = $4800;
  DownKey = $5000;
  LeftKey = $4B00;
  RightKey = $4D00;
  PgUpKey = $4900;
  PgDnKey = $5100;
  HomeKey = $4700;
  EndKey  = $4F00;
  InsKey = $5200;
  DelKey = $5300;

  { grey keys }
  gUpKey = $48E0;
  gDownKey = $50E0;
  gLeftKey = $4BE0;
  gRightKey = $4DE0;

  F1 = $3B00;
  F2  = $3C00;
  F3  = $3D00;
  F4  = $3E00;
  F5  = $3F00;
  F6  = $4000;
  F7  = $4100;
  F8  = $4200;
  F9  = $4300;
  F10 = $4400;

  SftF1  = $5400;
  SftF2  = $5500;
  SftF3  = $5600;
  SftF4  = $5700;
  SftF5  = $5800;
  SftF6  = $5900;
  SftF7  = $5A00;
  SftF8  = $5B00;
  SftF9  = $5C00;
  SftF10  = $5D00;

  CtrlF1  = $5E00;
  CtrlF2  = $5F00;
  CtrlF3  = $6000;
  CtrlF4  = $6100;
  CtrlF5  = $6200;
  CtrlF6  = $6300;
  CtrlF7  = $6400;
  CtrlF8  = $6500;
  CtrlF9  = $6600;
  CtrlF10  = $6700;

  AltF1  = $6800;
  AltF2  = $6900;
  AltF3  = $6A00;
  AltF4  = $6B00;
  AltF5  = $6C00;
  AltF6  = $6D00;
  AltF7  = $6E00;
  AltF8  = $6F00;
  AltF9  = $7000;
  AltF10  = $7100;


Type
  { Basic Graphic Types }
  PointType = Record
    x, y  : Word;
  End;

  PictHeader = Record     { header for picture objects - only good for  }
                          { screens of 64K or less.                     }
    height    : Word;    { height of picture in scanlines }
    width     : Word;    { width of picture in pixels }
    bytewidth : Word;    { Width of picture in bytes }
    data      : Pointer; { pointer to picture data }
  End;

  { For saving and restoring full screens }
  ScreenPic = Record
    planes : Array[0..3] Of Pointer;
  End;

  { Font Structures and Objects }
  PRFontWriteType = (PRBitMapped, PRBGIStroked);
  PRFontJust = (PRFJStart, PRFJCenter, PRFJEnd);
  PRFontDir = (PRFDAcross, PRFDUpDown);
  PRFontMem = (PRFLoaded, PRFLinked, PRFBios);
  PRFBiosFontType = (PRRom8x8, PRRom8x14, PRRom8x16);

  PRFDataPtr = ^PRFDataHeader;
  PRFDataHeader = Record
    FontType      : PRFontWriteType;
    NumberOfChar  : Word;  (* Number of characters in font  *)
    FirstChar     : Byte;  (* ASCII code of first character *)
    LastChar      : Byte;  (* ASCII Code of Last Character  *)
    WidestChar    : Byte;  (* Pixel Width of widest character *)

    FontByteWidth : Byte;  (* font width in bytes for bitmapped fonts *)

    (* For bitmapped fonts this gives the height in scan lines of the   *)
    (* font. For Stroked fonts this gives the height scaling of the     *)
    (* font when created.                                               *)
    FHeight       : Byte;

    (* For Stroked fonts only.  This is the width scaling factor.       *)
    FWidth        : Byte;

    (* The next three pointer will just contain garbage for dynamic     *)
    (* Fonts.  For Linked fonts they will contain pointers to the code  *)
    (* segment areas that contain the data.                             *)

    (* Array of widths for each character. For Stroked characters this  *)
    (* gives the number of line segments that it takes to form the      *)
    (* character.  For bitmapped characters this is the width for       *)
    (* porportional fonts                                               *)
    CWidth        : BytePtr;

    (* Gives offsets to where each character's information starts.  For *)
    (* bitmapped sets this is an incremented value that is dependent    *)
    (* upon the width of the bitmap.  For stroked fonts it points to    *)
    (* the start of the line segments.                                  *)
    COffset       : WordPtr;

    FontData      : Pointer;
  End;

  PRFontPtr = ^PRFontObj;
  PRFontObj = Object
    Data          : PRFDataHeader;
    FontDataSize  : Word;      (* Size of font data area for *)
                               (* deallocation               *)

    FontMem       : PRFontMem; (* file, memory font, or BIOS font *)
    BiosFontWidth : Byte;

    fgcolor       : Word;
    bgcolor       : Word;
    justification : PRFontJust;
    Direction     : PRFontDir;
    ULLoc         : Word;
    FontError     : Integer;

    Constructor FileInit(path : String);
    Constructor MemInit(info : PRFDataPtr);
    {Constructor BiosInit(Which : PRFBiosFontType);}
    Destructor Done;
    Procedure WriteAt(x, y : Word; Strg : String); Virtual;
    Procedure Write(strg : String);
    Function SetFGColor(color : Word) : Word;
    Function SetBGColor(color : Word) : Word;
    Procedure SetBothColor(cf, cb : Word);
    Procedure SetJust(j : PRFontJust);
    Procedure SetDir(d : PRFontDir);
    Function GetFGColor : Word;
    Function GetBGColor : Word;
    Function GetJust : PRFontJust;
    Function GetDir : PRFontDir;
    Function StrWidth(strg : String) : Word; Virtual;
    Function CharWidth(ch : Char) : Word; Virtual;
    Function FontHeight : Word; Virtual;
    Function RetError : Integer;
    Function CurrX : Word;
    Function CurrY : Word;
    Procedure SetCurrX(x : Word);
    Procedure SetCurrY(y : Word);
  End;

  { Event Handler Structures}
  EventRec = Record
    etype      : Word;
    key        : Word;
    x, y       : Word;     { for mouse events }
    ShiftFlags : Word;     { keyboard shift status }
    TimerTicks : LongInt;
  End;

  MouseCrsrPtr = ^MouseCrsr;
  MouseCrsr = Record
    hotx, hoty  : Word;
    bm          : Pointer;  { pointer to the picture }
  End;

  MouseRecord = Record
    event     : Word;
    x, y      : Word;
    btnstate  : Word;
    btncount  : Word;
    showing   : Integer;   { is mouse showing? }
    savebg    : Boolean;   { flag to save and restore background }
    LastClick : LongInt;
    DblClickWait : Word;
    curr_crsr : MouseCrsrPtr;
  End;

  { hotspot structure }
  PHotSpot = ^THotSpot;
  THotSpot = Record
    x1, y1, x2, y2 : Word;
    retvalue       : Integer;
  End;

Var
  ScreenWidth : Word;
  PageSize    : Word;
  RowTable    : Array[0..479] Of Word;
  PageTable   : Array[0..4] Of Word;
  BitInvTable : Array[0..255] Of Byte;

  rodent      : MouseRecord;
  ShiftArea   : WordPtr;
  TimerArea   : LongPtr;
  dflt_arrow  : MouseCrsr;

Function MinWord(x, y : Word) : Word;
Function MaxWord(x, y : Word) : Word;

{Basic Screen Routines}
Procedure SetMode(Which, width, pagesize : Word);
Procedure SetTextMode;
Procedure WritePixelX(x, y, color : Word);
Procedure Line(x1, y1, x2, y2, color : Word);
Procedure ClearPage(fillcolor : Word);
Procedure UsePage(pagenum : Word);
Procedure ShowPage(pagenum : Word);
Procedure FlipPage;
Procedure CopyPage(source, dest : Word);
Procedure SolidHLineX(y, x1, x2, color : Word);
Procedure SolidVLineX(x, y1, y2, color : Word);
Procedure SolidBox(x1, y1, x2, y2, color : Word);
Procedure BlockPageToPage(sourcepage, dest_page, startx, starty,
                          width, height, destx, desty : Word);

(*
  Copies from screen memory to screen memory using a mask to hide
  unwanted areas. Area has to start on a byte boundry.
*)
Procedure GetPicMask(Var pic : PictHeader; Var PicMask : BytePtr);
Procedure CopyScreenToScreenMaskedX(sourcepage,
                                    SourceStartX,
                                    SourceStartY,
                                    SourceWidth,
                                    SourceHeight,
                                    DestStartX,
                                    DestStartY,
                                    DestPageBase : Word;
                                    masks        : BytePtr);

Procedure GetPic(x, y, width, height : Word; Var pic : PictHeader);
Procedure PutPic(x, y : Word; Var p : PictHeader);
Procedure FreePic(Var pic : PictHeader);
Procedure PutMaskedPic(x, y : Word; Var p : PictHeader);
Procedure SetScreenBuffers(Var s : ScreenPic);
Procedure FreeScreenBuffers(Var s : ScreenPic);
Procedure PutScreen(page : Word; Var s : ScreenPic);
Procedure GetScreen(page : Word; Var s : ScreenPic);

{Event Handler Routines}
Function GetKey : Word;
Function InKey  : Word;
(*
  Must be called before the event handler is set up. This function locks
  the regions needed for the event handler to function.
*)
Procedure InitEvents;
Procedure SetEventMask(mask : Word);
Procedure CloseEvents;

(*
ÖÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ·
º Gets the next event in the queue. Returns TRUE if there is an event and º
º theEvent is filled. If no event is pending then function returns FALSE  º
º and theEvent is undefined.                                              º
ÓÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ½
*)
Function GetEvent(Var theEvent : EventRec) : Boolean;

(*
ÖÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ·
º Adds an event to the queue, and returns TRUE if was successful or FALSE º
º if the queue was full.                                                  º
ÓÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ½
*)
Function AddEvent(Var theEvent : EventRec) : Boolean;

(*
ÖÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ·
º This removes the oldest event added to the event queue.  It will return º
º TRUE if the event was removed, and FALSE if there were no events in the º
º queue to remove.                                                        º
ÓÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ½
*)
Function DiscardEvent : Boolean;

(*
//ÖÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ·
//º This removes all events from the event queue.  º
//ÓÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ½
*)
Procedure FlushEvents;

(*
//ÖÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ·
//º This returns TRUE if there is an event waiting in the queue, and  º
//º FALSE if there is not.  It does not affect the state of the queue º
//º or any unhandled events.                                          º
//ÓÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ½
*)
Function IsEventAvailable : Boolean;

Procedure MouseInit;
Procedure SetMouseLimits(x1, y1, x2, y2 : Word);
Procedure MouseSetCursor(Var mc : MouseCrsr);
Procedure SetMousePos(x, y : Word);
Procedure MouseRecPos;
Procedure MouseShow;
Procedure MouseHide;
Procedure PutMouseImage(x, y : Word);

{ These are here if you should want to use them. }
Procedure SetMouseParms;
Procedure SaveMouseBG(x, y : Word);
Procedure PutMouseBG;

Implementation

Const
  CRTParms  : Array[0..9] Of Word = (
    $0D06, { vertical total }
    $3E07, { overflow (bit 8 of vertical counts)}
    $4109, { cell height (2 to double-scan) }
    $EA10, { v sync start }
    $AC11, { v sync end and protect cr0-cr7 }
    $DF12, { vertical displayed }
    $0014, { turn off dword mode }
    $E715, { v blank start }
    $0616, { v blank end }
    $E317  { turn on byte mode }
  );

Const
  PRBiosFontArray : Array[PRFBiosFontType] Of Byte = (3, 2, 6);

  SizeOfEventQueue = 100;
  EventQueueTop = 99;

  dflt_crsr_data : Array[0..16 * 16 - 1] Of Byte = (
    { plane0 }
    $000F, $000F, $000F, $0000,
    $000F, $000F, $0000, $0000,
    $000F, $000F, $0000, $0000,
    $000F, $000F, $000F, $0000,
    $000F, $000F, $000F, $0000,
    $000F, $000F, $000F, $0000,
    $000F, $000F, $000F, $0000,
    $000F, $000F, $000F, $0000,
    $000F, $000F, $000F, $0000,
    $0000, $000F, $000F, $0000,
    $0000, $0000, $0000, $0000,
    $0000, $0000, $0000, $0000,
    $0000, $0000, $0000, $0000,
    $0000, $0000, $0000, $0000,
    $0000, $0000, $0000, $0000,
    $0000, $0000, $0000, $0000,

    { plane1 }
    $000F, $000F, $0000, $0000,
    $000F, $000F, $0000, $0000,
    $000F, $000F, $0000, $0000,
    $000F, $000F, $0000, $0000,
    $000F, $000F, $000F, $0000,
    $000F, $000F, $000F, $0000,
    $000F, $000F, $000F, $0000,
    $000F, $000F, $000F, $0000,
    $0000, $000F, $000F, $0000,
    $0000, $000F, $0000, $0000,
    $0000, $000F, $0000, $0000,
    $0000, $0000, $0000, $0000,
    $0000, $0000, $0000, $0000,
    $0000, $0000, $0000, $0000,
    $0000, $0000, $0000, $0000,
    $0000, $0000, $0000, $0000,

    { plane2 }
    $000F, $000F, $0000, $0000,
    $000F, $000F, $0000, $0000,
    $000F, $000F, $0000, $0000,
    $000F, $000F, $0000, $0000,
    $000F, $000F, $0000, $0000,
    $000F, $000F, $000F, $0000,
    $000F, $000F, $000F, $0000,
    $000F, $000F, $000F, $0000,
    $0000, $000F, $0000, $0000,
    $0000, $000F, $0000, $0000,
    $0000, $000F, $0000, $0000,
    $0000, $000F, $0000, $0000,
    $0000, $0000, $0000, $0000,
    $0000, $0000, $0000, $0000,
    $0000, $0000, $0000, $0000,
    $0000, $0000, $0000, $0000,

    { plane3 }
    $000F, $000F, $0000, $0000,
    $000F, $000F, $0000, $0000,
    $000F, $000F, $0000, $0000,
    $000F, $000F, $0000, $0000,
    $000F, $000F, $0000, $0000,
    $000F, $000F, $0000, $0000,
    $000F, $000F, $000F, $0000,
    $000F, $000F, $0000, $0000,
    $000F, $000F, $0000, $0000,
    $0000, $000F, $0000, $0000,
    $0000, $000F, $0000, $0000,
    $0000, $0000, $0000, $0000,
    $0000, $0000, $0000, $0000,
    $0000, $0000, $0000, $0000,
    $0000, $0000, $0000, $0000,
    $0000, $0000, $0000, $0000
  );

  MseMaskArray : Array[0..2] Of Word = (1, 2, 4);
  cm_ofs       : Array[0..3] Of Word = (0, 80, 160, 240);

Type
  TEventArr = Array[0..EventQueueTop] Of EventRec;
  PEventArr = ^TEventArr;

Var
  CurrPt          : PointType;
  EVENT_HEAD      : Word;
  EVENT_TAIL      : Word;
  PENDING_EVENTS  : Word;
  EventMask       : Word;
  MouseHere       : Boolean;
  HandlerIsActive : Boolean;
  crsr_masks      : Array[0..319] Of Byte;
  Event_Queue     : PEventArr;
  hx, hy          : Word;  { used for calculation speed in cursor clipping }

Procedure CopyPage(source, dest : Word); External;
{$L copypage.obj}

Procedure SolidHLineX(y, x1, x2, color : Word); External;
{$L hline.obj}

Procedure SolidVLineX(x, y1, y2, color : Word); External;
{$L vline.obj}

Function MinWord(x, y : Word) : Word;
Begin
  If x <= y Then
    MinWord := x
  Else
    MinWord := y;
End;

Function MaxWord(x, y : Word) : Word;
Begin
  If x >= y Then
    MaxWord := x
  Else
    MaxWord := y;
End;

Procedure Init240(width, psize : Word); Assembler;
ASM
  push  ds

  { Get the parameters from the stack. If 0, ignore and assume defaults }
  mov   bx, 320/4
  mov   ax, [width]
  or    ax, ax
  je    @@init1
  mov   bx, ax
@@init1:
  mov   [ScreenWidth], bx
  mov   bx, 320/4*240
  mov   ax, [psize]
  or    ax, ax
  je    @@init2
  mov   bx, ax
@@init2:
  mov   [PageSize], bx

  { Now set up the table of row addresses }

  lea   di, [RowTable]
  mov   cx, 480  { Set up 480 entries }
  mov   bx, [ScreenWidth]
  xor   ax, ax
@@init3:
  stosw
  add   ax, bx
  loop  @@init3

  { Set up the page table }
  xor   ax, ax
  mov   bx, [PageSize]
  lea   di, [PageTable]
  mov   cx, 4
@@init4:
  stosw
  add   ax, bx
  loop  @@init4

  { Initialize the bit inversion table }
  lea   di, [BitInvTable]
  mov   cx, 256
  xor   dx, dx
@@init5:
  mov   al, dl
  rcl   al, 1
  rcr   bl, 1
  rcl   al, 1
  rcr   bl, 1
  rcl   al, 1
  rcr   bl, 1
  rcl   al, 1
  rcr   bl, 1
  rcl   al, 1
  rcr   bl, 1
  rcl   al, 1
  rcr   bl, 1
  rcl   al, 1
  rcr   bl, 1
  rcl   al, 1
  rcr   bl, 1
  mov   al, bl
  stosb
  inc dx
  loop @@init5

  { Now set up the graphics mode }
  mov   ax, 13H
  int   10H { Set 320x200x256 }

  mov   dx, SC_INDEX
  mov   ax, 0604H
  out   dx, ax         {disable chain4 mode}
  mov   ax, 0100H
  out   dx, ax         {synchronous reset while switching clocks}

  mov   dx, MISC_OUTPUT
  mov   al,0E3H
  out   dx, al         {select 28 MHz dot clock & 60 Hz scanning rate}

  mov   dx, SC_INDEX
  mov   ax, 0300H
  out   dx, ax         {undo reset (restart sequencer)}

  mov   dx, CRTC_INDEX {reprogram the CRT Controller}
  mov   al, 11H        {VSync End reg contains register write}
  out   dx, al         { protect bit }
  inc   dx             {CRT Controller Data register}
  in    al, dx         {get current VSync End register setting}
  and   al, 7FH        {remove write protect on various}
  out   dx, al         {CRTC registers}
  dec   dx             {CRT Controller Index}
  cld
  push  ds
  mov   ax, SEG CRTParms
  mov   si, OFFSET CRTParms
  {mov   si, offset  ;point to CRT parameter table}
  mov   cx, 10 {CRT_PARM_LENGTH ;# of table entries}
@@SetCRTParmsLoop:
  lodsw                {get the next CRT Index/Data pair}
  out   dx, ax         {set the next CRT Index/Data pair}
  loop  @@SetCRTParmsLoop

  pop   ds
  mov   dx, SC_INDEX
  mov   ax, 0F02H
  out   dx, ax         {enable writes to all four planes}
  mov   ax, [SegA000]  {now clear all display memory, 8 pixels}
  mov   es, ax         {at a time}
  sub   di, di         {point ES:DI to display memory}
  sub   ax, ax         {clear to zero-value pixels}
  mov   cx, 8000H      {# of words in display memory}
  rep   stosw          {clear all of display memory}

  pop   ds
End;

Procedure Init200(width, psize : Word); Assembler;
ASM
  push  ds

  {Get the parameters from the stack. If 0, ignore and assume defaults}
  mov   bx, 320/4
  mov   ax, [width]
  or    ax, ax
  je    @@init1
  mov   bx, ax
@@init1:
  mov   [ScreenWidth], bx
  mov   bx, 320/4*200
  mov   ax, [psize]
  or    ax, ax
  je    @@init2
  mov   bx, ax
@@init2:
  mov   [PageSize], bx

  { Now set up the table of row addresses }

  lea   di, [RowTable]
  mov   cx, 400        { Set up 400 entries }
  mov   bx, [ScreenWidth]
  xor   ax, ax
@@init3:
  stosw
  add   ax, bx
  loop  @@init3

  { Set up the page table }
  xor   ax, ax
  mov   bx, [PageSize]
  lea   di, [PageTable]
  mov   cx, 4
@@init4:
  stosw
  add   ax, bx
  loop  @@init4

  { Initialize the bit inversion table }
  lea   di, [BitInvTable]
  mov   cx, 256
  xor   dx, dx
@@init5:
  mov   al, dl
  rcl   al, 1
  rcr   bl, 1
  rcl   al, 1
  rcr   bl, 1
  rcl   al, 1
  rcr   bl, 1
  rcl   al, 1
  rcr   bl, 1
  rcl   al, 1
  rcr   bl, 1
  rcl   al, 1
  rcr   bl, 1
  rcl   al, 1
  rcr   bl, 1
  rcl   al, 1
  rcr   bl, 1
  mov   al, bl
  stosb
  inc dx
  loop @@init5

  { Now set up the graphics mode }
  mov   ax, 13H
  int   10H  { Set 320x200x256 }

  mov   dx, 03C4H
  mov   al, 04
  out   dx, al
  inc   dx
  in    al, dx
  and   al, 0F7H
  or    al, 4
  out   dx, al
  mov   dx, 03C4H
  mov   al, 2
  out   dx, al
  inc   dx
  mov   al, 0FH
  out   dx, al
  mov   ax, [SegA000]
  mov   es, ax
  mov   ax, 0
  sub   di, di
  mov   dx, di
  mov   cx, 8000H
  cld
  repnz stosw
  mov   dx, 03D4H
  mov   al, 14H
  out   dx, al
  inc   dx
  in    al, dx
  and   al, 0BFH
  out   dx, al
  dec   dx
  mov   al, 17H
  out   dx, al
  inc   dx
  in    al, dx
  or    al, 40H
  out   dx, al

  pop   ds
End;

Procedure SetMode(Which, width, pagesize : Word);
Begin
  (*
  ClipX1 := 0;
  ClipY1 := 0;
  ClipX2 := 319;
  *)
  Case Which Of
    MODE240 :
    Begin
      Init240(width, pagesize);
      {ClipY2 := 239;}
    End;

    MODE200 :
    Begin
      Init200(width, pagesize);
      {ClipY2 := 199;}
    End;
  End;
End;

Procedure SetTextMode; Assembler;
ASM
  mov  ax, 3
  int  $10
End;

Procedure WritePixelX(x, y, color : Word); Assembler;
Var
  address : Word;
ASM
  lea     si, RowTable
  mov     bx, [y]
  shl     bx, 1
  add     si, bx
  mov     di, [si]
  mov     ax, [x]
  shr     ax, 2
  add     di, ax
  add     di, [WritePage]
  mov     ax, [SegA000]
  mov     es, ax                {starting address in es:di}
  mov     cl, [byte ptr x]
  and     cl, 03H               {pixels plane}
  mov     ax, 0100h + MAP_MASK  {al=index of Map Mask Register}
  shl     ah, cl                {set enable bit to pixel plane}
  mov     dx, SC_INDEX
  out     dx, ax                {enable writting only to pixels plane}
  mov     al, [byte ptr color]
  mov     [es:di], al           {draw pixel in selected color}
End;

Procedure Octant0(x, y, dx, dy : Word; XDir : Integer; color : Word);
Var
  DYx2, DYx2MinusDXx2, ErrorTerm : Integer;
Begin
  { Set up initial error term and values used inside drawing loop }
  DYx2 := dy Shl 1;
  DYx2MinusDXx2 := DYx2 - Integer(dx Shl 1);
  ErrorTerm := DYx2 - Integer(dx);

  { Draw the line }
  WritePixelX(x, y, color);
  While dx > 0 Do
  Begin
    Dec(dx);
    { See if it's time to advance the Y coordinate }
    If ErrorTerm >= 0 Then
    Begin
      { Advance the Y coordinate & adjust the error term back down }
      Inc(y);
      Inc(ErrorTerm, DYx2MinusDXx2);
    End
    Else
    Begin
      { Add to the error term }
      Inc(ErrorTerm, DYx2);
    End;
    Inc(x, XDir);        { advance the X coordinate }
    WritePixelX(x, y, color);
  End;
End;

Procedure Octant1(x, y, dx, dy : Word; XDir : Integer; color : Word);
Var
  DeltaXx2, DeltaXx2MinusDeltaYx2, ErrorTerm : Integer;
Begin
  { Set up initial error term and values used inside drawing loop }
  DeltaXx2 := dx Shl 1;
  DeltaXx2MinusDeltaYx2 := DeltaXx2 - Integer(dy Shl 1);
  ErrorTerm := DeltaXx2 - Integer(dy);

  WritePixelX(x, y, color);
  While dy > 0 Do
  Begin
    Dec(dy);
    { See if it's time to advance the X coordinate }
    If ErrorTerm >= 0 Then
    Begin
      { Advance the X coordinate & adjust the error term back down }
      Inc(x, XDir);
      Inc(ErrorTerm, DeltaXx2MinusDeltaYx2);
    End
    Else
    Begin
      { Add to the error term }
      Inc(ErrorTerm, DeltaXx2);
    End;
    Inc(y);            { advance the Y coordinate }
    WritePixelX(x, y, color);
  End;
End;

Procedure Line(x1, y1, x2, y2, color : Word);
Var
  dx, dy, inc1, inc2, inc3, d, x, y, xend, yend, tmp : Integer;
Begin
  If (x2 - x1) = 0 Then
  Begin
    SolidVLineX(x1, MinWord(y1, y2), MaxWord(y1, y2), color);
    Exit;
  End;
  If (y2 - y1) = 0 Then
  Begin
    SolidHLineX(y1, MinWord(x1, x2), MaxWord(x1, x2), color);
    Exit;
  End;

  dx := Abs(Integer(x2) - Integer(x1));
  dy := Abs(Integer(y2) - Integer(y1));

  If y1 > y2 Then
  Begin
    tmp := y1;
    y1 := y2;
    y2 := tmp;
    tmp := x1;
    x1 := x2;
    x2 := tmp;
  End;

  dx := x2 - x1;    { calculate the length of the line in each coordinate }
  dy := y2 - y1;
  if dx > 0 Then
  Begin
    If dx > dy Then
      Octant0(x1, y1, dx, dy, 1, color)
    Else
      Octant1(x1, y1, dx, dy, 1, color);
  End
  Else
  Begin
    dx := -dx;       { absolute value of dx }
    If dx > dy Then
      Octant0(x1, y1, dx, dy, -1, color)
    Else
      Octant1(x1, y1, dx, dy, -1, color);
  End;
End;

Procedure ClearPage(fillcolor : Word); Assembler;
ASM
  mov    di, [WritePage]
  mov    cx, [PageSize]   { cx=size of each plane in bytes}
  shr    cx, 1            { convert to a word count }

  mov    dx, SC_INDEX     { Sequence Control index reg}
  mov    ax, 0F02H
  out    dx, ax           { select all planes }

  mov    ax, [SegA000]
  mov    es, ax
  mov    al, [byte ptr fillcolor]      { get the color }
  mov    ah, al
  cld
  rep    stosw         { fill the page }
End;

Procedure UsePage(pagenum : Word); Assembler;
ASM
  mov    bx, [pagenum]
  and    bx, 3
  shl    bx, 1
  lea    si, PageTable
  add    si, bx
  mov    ax, [si]
  mov    [WritePage], ax
End;

Procedure ShowPage(pagenum : Word); Assembler;
ASM
  mov    bx, [pagenum]
  and    bx, 3
  shl    bx, 1
  lea    si, PageTable
  add    si, bx
  mov    cx, [si]
  mov    [ViewPage], cx { An ISR will set the VGA at the next retrace }

  mov    dx, 3DAH
@@Ret1:
  in     al, dx
  and    al, 1
  jnz    @@Ret1      {Wait for non-retrace}

  cli
  mov    al, 0CH
  mov    ah, ch
  mov    dx, CRTC_INDEX
  out    dx, ax      {set the displayed offset (high)}
  inc    al
  mov    ah, cl
  out    dx, ax      {set the displayed offset (low)}
  sti

  mov    dx, 3DAH
@@Ret2:
  in     al, dx
  and    al, 8
  jz     @@Ret2
End;

Procedure FlipPage; Assembler;
ASM
  mov    cx, [ViewPage]
  xchg   cx, [WritePage]
  mov    [ViewPage], cx  { An ISR will set the VGA at the next retrace }

  mov    dx, 3DAH
@@Ret1:
  in     al, dx
  test   al, 1
  jnz    @@Ret1       {Wait for display enable}

  cli
  mov    al, 0CH
  mov    ah, ch
  mov    dx, CRTC_INDEX
  out    dx, ax       {set the displayed offset (high)}
  inc    al
  mov    ah, cl
  out    dx, ax       {set the displayed offset (low)}
  sti

  mov    dx, 3DAH
@@Ret2:
  in     al, dx
  test   al, 8
  jz     @@Ret2       {Wait for the video card to use the address just set}
End;

Procedure SolidBox(x1, y1, x2, y2, color : Word);
Var
  ht : Word;
Begin
  ht := y2 - y1 + 1;
  While ht > 0 Do
  Begin
    SolidHLineX(y1, x1, x2, color);
    Dec(ht);
    Inc(y1);
  End;
End;

Procedure BlockPageToPage(sourcepage, dest_page, startx, starty,
                          width, height, destx, desty : Word); Assembler;
Var
  savesi, savedi : Word;
ASM
  push   ds

  mov    bx, [sourcepage]
  and    bl, 3
  shl    bx, 1

  mov    dx, word ptr[PageTable + bx]  { Find the source page address }
  mov    bx, [starty]
  shl    bx, 1
  mov    ax, word ptr[RowTable + bx]
  add    dx, ax
  mov    ax, [startx]
  shr    ax, 2
  add    dx, ax
  mov    [savesi], dx

  mov    bx, [dest_page]
  and    bl, 3
  shl    bx, 1
  mov    di, word ptr[PageTable + bx]  { Find the destination page address }
  mov    bx, [desty]
  shl    bx, 1
  mov    ax, word ptr[RowTable + bx]
  add    di, ax
  mov    ax, [destx]
  shr    ax, 2
  add    di, ax
  mov    [savedi], di

  mov    dx, 3CEH
  mov    ax, 0008H      { Set the bitmask to use the latch data. }
  out    dx, ax
  mov    dx, SC_INDEX
  mov    ax, 0F02H      { Use all four planes. }
  out    dx, ax
  mov    cx, [height]   { Get the height of the block }
  mov    ax, [SegA000]
  mov    es, ax
  mov    ds, ax
  mov    si, [savesi]
  cld
@@height_loop:
  push   cx
  mov    cx, [width]
  rep    movsb

  mov    si, [savesi]
  add    si, 80
  mov    [savesi], si
  mov    di, [savedi]
  add    di, 80
  mov    [savedi], di
  pop    cx
  loop   @@height_loop

  mov    dx, 3CEH
  mov    ax, 0FF08H  { Set the bitmask for only CPU data }
  out    dx, ax

  pop    ds
End;

Procedure GetPicMask(Var pic : PictHeader; Var PicMask : BytePtr);
Var
  size, i : Word;
  result, l1, l2, l3, l4, place : BytePtr;
Begin
  PicMask := Nil;
  size := (pic.bytewidth * pic.height);
  GetMem(result, size);
  If result = Nil Then
    Exit;
  FillChar(result^, size, 0);
  l1 := pic.data;
  l2 := Pointer(LongInt(pic.data) + size);
  l3 := Pointer(LongInt(pic.data) + (size Shl 1));
  l4 := Pointer(LongInt(pic.data) + (size * 3));
  place := result;
  For i := 0 To size - 1 Do
  Begin
    If l1^ > 0 Then
      place^ := place^ Or $01;
    If l2^ > 0 Then
      place^ := place^ Or $02;
    If l3^ > 0 Then
      place^ := place^ Or $04;
    If l4^ > 0 Then
      place^ := place^ Or $08;
    If i < (size - 1) Then
    Begin
      Inc(l1);
      Inc(l2);
      Inc(l3);
      Inc(l4);
    End;
    Inc(place);
  End;
  PicMask := result;
  {FreeMem (result, size);}
End;

Procedure CopyScreenToScreenMaskedX(sourcepage,
                                    SourceStartX,
                                    SourceStartY,
                                    SourceWidth,
                                    SourceHeight,
                                    DestStartX,
                                    DestStartY,
                                    DestPageBase : Word;
                                    masks        : BytePtr); Assembler;
Var
  savesi, savedi : Word;
ASM
  push   ds
  cld
  mov    dx, GC_INDEX     { set BitMask Register }
  mov    ax, BIT_MASK     { so that all data comes }
  out    dx, ax           { from latches }
  mov    ax, [SegA000]
  mov    es, ax

  mov    bx, [sourcepage]
  and    bl, 3
  shl    bx, 1
  mov    si, word ptr[PageTable + bx]  { Find the source page address }
  mov    bx, [SourceStartY]
  shl    bx, 1
  mov    ax, word ptr[RowTable + bx]
  add    si, ax
  mov    ax, [SourceStartX]
  shr    ax, 2
  add    si, ax
  mov    [savesi], si            { value will eventuall go into bx }

  mov    bx, [DestPageBase]
  and    bl, 3
  shl    bx, 1
  mov    di, word ptr[PageTable + bx]  { Find the destination page address }
  mov    bx, [DestStartY]
  shl    bx, 1
  mov    ax, word ptr[RowTable + bx]
  add    di, ax
  mov    ax, [DestStartX]
  shr    ax, 2
  add    di, ax
  mov    [savedi], di
  lds    si, [masks]
  mov    cx, [SourceHeight]        { set the height }

  mov    dx, SC_INDEX      { set Sequence Controller Address Register }
  mov    al, MAP_MASK      { to point to Map Mask Register }
  out    dx, al
  inc    dx                { dx = Seq Controller Data Register }

@height_loop:
  push   cx
  mov    cx, [SourceWidth]
  mov    bx, [savesi]
@line_loop:
  lodsb                { get mask for this four-pixel set }
  out    dx, al        { set the mask }
  mov    al, [es:bx]   { load latches with 4 pixels from source }
  stosb                { copy four pixel set to dest }
  inc    bx            { advance source pointer }
  loop   @line_loop

  add    [savesi], 80
  add    [savedi], 80
  mov    di, [savedi]
  pop    cx
  loop   @height_loop

  mov    dx, 3CEH
  mov    ax, 0FF08H  { Set the bitmask for only CPU data }
  out    dx, ax
  pop    ds
End;

Procedure GetPicX(x, y, bytewidth, height : Word;
                  buffer : Pointer; pagebase : Word); Assembler;
Var
  saveofs, nextline : Word;
  level, lcount     : Byte;
ASM
  push    ds

  cld
  mov     bx, [y]
  shl     bx, 1
  mov     dx, word ptr[RowTable + bx]
  mov     ax, [x]
  shr     ax, 2
  add     dx, ax
  add     dx, [pagebase]
  mov     ax, [SegA000]
  mov     si, dx
  mov     ds, ax            { starting address in ds:si }
  mov     [saveofs], si     { save the offset for later }
  mov     [nextline], si
  les     di, [buffer]      { load buffer pointer into es:di }

  mov     dx, GC_INDEX
  mov     al, 4
  out     dx, al
  inc     dx
  mov     ax, [x]
  and     al, 3
  mov     [level], al
  mov     [lcount], 0

@pic_get:
  out     dx, al
  mov     si, [saveofs]
  mov     [nextline], si
  mov     cx, [height]

@ht_loop:
  push    cx
  mov     si, [nextline]
  mov     ax, si
  add     ax, 80
  mov     [nextline], ax
  mov     cx, [bytewidth]
  repnz   movsb
  pop     cx
  loop    @ht_loop

  inc     [level]
  cmp     [level], 4
  jne     @check_count   { resetting bit plane so need to move }
  mov     [level], 0      { offsets over 1 }
  inc     [saveofs]
  inc     [nextline]
@check_count:
  mov     al, [level]
  inc     [lcount]
  cmp     [lcount], 4
  jl      @pic_get

@getpic_out:

  pop     ds
End;


Procedure GetPic(x, y, width, height : Word; Var pic : PictHeader);
Var
  check : LongInt;
Begin
  pic.height := height;
  pic.width := width;
  pic.bytewidth := (pic.width + 3) Shr 2;
  check := pic.height;
  check := (check * pic.bytewidth) Shl 2;
  If check < 65520 Then
  Begin
    GetMem(pic.data, Word(check));
    GetPicX(x, y, pic.bytewidth, pic.height, pic.data, WritePage);
  End
  Else
    FillChar(pic, SizeOf(PictHeader), 0);
End;

Procedure FreePic(Var pic : PictHeader);
Begin
  If pic. data <> Nil  Then
  Begin
    FreeMem(pic. data, pic. width * pic. height);
    pic. width := 0;
    pic. height := 0;
    pic. bytewidth := 0;
    pic. data := Nil;
  End;
End;

Procedure PutPicX(x, y, bytewidth, height, pixelwidth : Word;
                  buffer : Pointer; pagebase : Word); Assembler;
Var
  fullwidth, maxx : Word;
  widths          : LongInt;
  savesi, savedi  : Word;
  saveofs         : Word;
  level, lcount   : Byte;
  sw              : Word;
ASM
  push    ds

  mov     ax, [bytewidth]   { get the full width of this thing and }
  dec     ax
  shl     ax, 2             { and store it }
  inc     ax
  mov     [fullwidth], ax
  mov     ax, [x]           { get the maximum x value of the drawing }
  add     ax, [pixelwidth]
  mov     [maxx], ax

  mov     dx, [x]           { get the start of the line in dx }
  mov     bx, 0             { set the offset into widths }
  mov     cx, 4             { set the counter }
  mov     si, bp
  sub     si, 8
  mov     [sw], si
@width_loop:
  mov     al, [byte ptr bytewidth]
  mov     di, dx
  add     di, [fullwidth]
  cmp     di, [maxx]
  jg      @too_long
  jmp     @next_num
@too_long:
  dec     ax
@next_num:
  mov     [ss:si + bx], al
  inc     bx
  inc     dx
  loop    @width_loop

  mov     bx, [y]
  shl     bx, 1
  mov     di, word ptr[RowTable + bx]
  mov     ax, [x]
  shr     ax, 2
  add     di, ax
  add     di, [pagebase]
  mov     ax, [SegA000]
  mov     es, ax           { starting address in ds:si }
  lds     si, [buffer]     { load buffer pointer into es:di }

  mov     [savesi], si
  mov     [savedi], di
  mov     [saveofs], di

  { get frame width }
  mov     dx, SC_INDEX
  mov     al, MAP_MASK     { Set Sequence Controller Address Register }
  out     dx, al           { to Map Mask Register }
  inc     dx
  mov     cx, [x]
  and     cx, 3
  mov     al, 01H
  shl     al, cl
  mov     [level], al
  mov     [lcount], 0
  cld
@pic_put:
  out     dx, al
  xor     bx, bx
  mov     bl, [lcount]
  push    si
  mov     si, [sw]
  xor     cx, cx
  mov     cl, [ss:si + bx]
  pop     si
  mov     [fullwidth], cx
  mov     cx, [height]
@ht_loop:
  push    cx
  mov     cx, [fullwidth]
  repnz   movsb
@no_extra:
  pop     cx
  mov     si, [savesi]
  add     si, [bytewidth]
  mov     [savesi], si
  mov     di, [savedi]
  add     di, 80
  mov     [savedi], di
  loop    @ht_loop

  inc     [lcount]          { set next level }
  cmp     [lcount], 4
  je      @putpic_out      { have done all four planes now go out }
  shl     [level], 1        { go for next plane }
  cmp     [level], 10H
  jne     @next_plane
  mov     [level], 1        { set the plane back to 0 }
  inc     [saveofs]         { move ahead on screen }
@next_plane:
  mov     al, [level]
  mov     di, [saveofs]     { reset screen address }
  mov     [savedi], di
  jmp     @pic_put

@putpic_out:
  pop     ds
End;

Procedure PutPic(x, y : Word; Var p : PictHeader);
Begin
  If p.data <> Nil Then
    PutPicX(x, y, p.bytewidth, p.height, p.width, p.data, WritePage);
End;

Procedure PutMaskedPicX(x, y, bytewidth, height, pixelwidth : Word;
                        buffer : Pointer; pagebase : Word); Assembler;
Var
  fullwidth, maxx, savesi : Word;
  widths                  : LongInt;
  savedi, saveofs, sw     : Word;
  level, lcount           : Byte;
ASM
  push    ds

  mov     ax, [bytewidth]    { get the full width of this thing and }
  dec     ax
  shl     ax, 2              { and store it }
  inc     ax
  mov     [fullwidth], ax
  mov     ax, [x]            { get the maximum x value of the drawing }
  add     ax, [pixelwidth]
  mov     [maxx], ax

  mov     dx, [x]            { get the start of the line in dx }
  mov     bx, 0              { set the offset into widths }
  mov     cx, 4              { set the counter }
  mov     si, bp
  sub     si, 8
  mov     [sw], si
@width_loop:
  mov      al, [byte ptr bytewidth]
  mov      di, dx
  add      di, [fullwidth]
  cmp      di, [maxx]
  jg       @too_long
  jmp      @next_num
@too_long:
  dec      ax
@next_num:
  mov      [ss:si + bx], al
  inc      bx
  inc      dx
  loop     @width_loop

  mov     bx, [y]
  shl     bx, 1
  lea     si, RowTable
  mov     di, [si + bx]
  mov     ax, [x]
  shr     ax, 2
  add     di, ax
  add     di, [pagebase]
  mov     ax, [SegA000]
  mov     es, ax           { starting address in ds:si }
  lds     si, [buffer]     { load buffer pointer into es:di }
  mov     [savesi], si
  mov     [savedi], di
  mov     [saveofs], di

  { get frame width }
  mov     dx, SC_INDEX
  mov     al, MAP_MASK     { Set Sequence Controller Address Register }
  out     dx, al           { to Map Mask Register }
  inc     dx
  mov     cx, [x]
  and     cx, 3
  mov     al, 01H
  shl     al, cl
  mov     [level], al
  mov     [lcount], 0
  cld

@pic_put:
  out     dx, al
  xor     bx, bx
  mov     bl, [lcount]
  push    si
  mov     si, [sw]
  xor     cx, cx
  mov     cl, [ss:si + bx]
  pop     si
  mov     [fullwidth], cx
  mov     cx, [height]
@ht_loop:
  push    cx
  mov     cx, [fullwidth]
@line_loop:
  mov     al, [ds:si]
  cmp     al, 0
  je      @no_dot
  mov     [es:di], al
@no_dot:
  inc     si
  inc     di
  loop    @line_loop
@no_extra:
  pop     cx
  mov     si, [savesi]
  add     si, [bytewidth]
  mov     [savesi], si
  mov     di, [savedi]
  add     di, 80
  mov     [savedi], di
  loop    @ht_loop

  inc     [lcount]         { set next level }
  cmp     [lcount], 4
  je      @putpic_out      { have done all four planes now go out }
  shl     [level], 1       { go for next plane }
  cmp     [level], 10H
  jne     @next_plane
  mov     [level], 1       { set the plane back to 0 }
  inc     [saveofs]        { move ahead on screen }
@next_plane:
  mov     al, [level]
  mov     di, [saveofs]    { reset screen address }
  mov     [savedi], di
  jmp     @pic_put
@putpic_out:
  pop     ds
End;

Procedure PutMaskedPic(x, y : Word; Var p : PictHeader);
Begin
  If p.data <> Nil Then
    PutMaskedPicX(x, y, p.width, p.height, p.bytewidth, p.data, WritePage);
End;

Procedure SetScreenBuffers(Var s : ScreenPic);
Var
  x : Word;
Begin
  For x := 0 To 3 Do
    GetMem(s.planes[x], 80 * 240);
End;

Procedure FreeScreenBuffers(Var s : ScreenPic);
Var
  x : Word;
Begin
  For x := 0 To 3 Do
  Begin
    FreeMem(s.planes[x], 80 * 240);
    s.planes[x] := Nil;
  End;
End;

Procedure PutScreen(page : Word; Var s : ScreenPic);
Var
  p     : Pointer;
  x     : Word;
  plane : Byte;
Begin
  plane := 1;
  For x := 0 To 3 Do   { Go through each plane }
  Begin
    p := s.planes[x];
    ASM
      push   ds
      cld
      mov    ax, [SegA000]
      mov    es, ax
      mov    di, [page]   { move screen memory into es:di }
      lds    si, p

      { set up the byte plane }
      mov    dx, SC_INDEX
      mov    al, MAP_MASK     { Set Sequence Controller Address Register }
      out    dx, al           { to Map Mask Register }
      inc    dx
      mov    al, [plane]

      out    dx, al
      mov    cx, 9600
      repnz  movsw
      shl    [plane], 1
      pop    ds
    End;
  End;
End;

Procedure GetScreen(page : Word; Var s : ScreenPic);
Var
  p     : Pointer;
  x     : Word;
  plane : Byte;
Begin
  plane := 1;
  For x := 0 To 3 Do   { Go through each plane }
  Begin
    p := s.planes[x];
    ASM
      push   ds
      cld
      mov    ax, [SegA000]
      mov    ds, ax
      mov    si, [page]   { move screen memory into ds:si }
      les    di, p

      { set up the byte plane }
      mov    dx, SC_INDEX
      mov    al, MAP_MASK     { Set Sequence Controller Address Register }
      out    dx, al           { to Map Mask Register }
      inc    dx
      mov    al, [plane]

      out    dx, al
      mov    cx, 9600
      repnz  movsw
      shl    [plane], 1
      pop    ds
    End;
  End;
End;

Constructor PRFontObj.FileInit(path : String);
Var
  strg  : String[50];
  f     : File;
  x, y  : Word;
Begin
  FontError := 0;
  Assign(f, path);
  {$I-} Reset(f, 1); {$I-}
  If IOResult <> 0 Then
  Begin
    FontError := -1;
    Exit;
  End;
  (* check for signature *)
  BlockRead(f, strg, 26);
  If strg <> 'Powder River Font File' Then
  Begin
    FontError := -2;
    Exit;
  End;

  (* Throw away description string *)
  BlockRead(f, strg, 42);
  BlockRead(f, Data, SizeOf(Data));

  (* calculate size of width array and bring in *)
  GetMem(Data.CWidth, Data.NumberOfChar);
  BlockRead(f, Data.CWidth^, Data.NumberOfChar);

  FontDataSize := Data.FontByteWidth * Data.FHeight * Data.NumberOfChar;
  GetMem(Data.FontData, FontDataSize);
  BlockRead(f, Data.FontData^, FontDataSize);
  Close(f);
  FontMem := PRFLoaded;
  fgcolor := 15;
  bgcolor := Transparent;
  justification := PRFJStart;
  Direction := PRFDAcross;
  ULLoc := Data.FHeight;
End;

Constructor PRFontObj.MemInit(info : PRFDataPtr);
Var
  head : PRFDataPtr;
Begin
  head := Pointer(info);
  Move(head^, Data, SizeOf(PRFDataHeader));
  FontMem := PRFLinked;
  fgcolor := 255;
  bgcolor := Transparent;
  justification := PRFJStart;
  Direction := PRFDAcross;
End;

(*
Constructor PRFontObj.BiosInit(Which : PRFBiosFontType);
Var
  Width  : Byte;
  r      : Registers;
Begin
  Data.FontType := PRBitMapped;
  FontMem := PRFBios;
  With Data Do
  Begin
    NumberOfChar := 255;
    FirstChar := 0;
    LastChar := 255;
    Case Which Of
      PRRom8x8 :
      Begin
        FHeight := 8;
        BiosFontWidth := 8;
        FontByteWidth := 1;
      End;

      PRRom8x14 :
      Begin
        FHeight := 14;
        BiosFontWidth := 8;
        FontByteWidth := 1;
      End;

      PRRom8x16 :
      Begin
        FHeight := 16;
        BiosFontWidth := 8;
        FontByteWidth := 1;
      End;

    End;

    r.AH := $11;
    r.AL := $30;
    r.BH := PRBiosFontArray[Which];
    Intr($10, r);
    FontData := Ptr(r.ES, r.BP);
    CWidth := Nil;
    COffset := Nil;
  End;
  Data.WidestChar := BiosFontWidth;
  fgcolor := 15;
  bgcolor := Transparent;
  justification := PRFJStart;
  Direction := PRFDAcross;
End;
*)

Destructor PRFontObj.Done;
Begin
  Case FontMem Of
    PRFLinked, PRFBios : Exit;

    PRFLoaded :
    Begin
      FreeMem(Data.CWidth, Data.NumberOfChar);
      FreeMem(Data.FontData, FontDataSize);
    End;
  End;
End;

Function PRFontObj.StrWidth(strg : String) : Word;
Var
  Result, x, i : Word;
Begin
  Case FontMem Of
    PRFBios : Result := Length(strg) * BiosFontWidth;

    PRFLoaded, PRFLinked :
    Begin
      If Data.FontType = PRBitMapped Then
      Begin
        Result := 0;
        For x := 1 To Length(strg) Do
        Begin
          i := Ord(strg[x]) - Data.FirstChar;
          Inc(Result, ByteArrPtr(Data.CWidth)^[i]);
        End;
      End
      Else
      Begin
      End;
    End;
  End;
  StrWidth := Result;
End;

Function PRFontObj.CharWidth(ch : Char) : Word;
Var
  Result : Word;
Begin
  Case FontMem Of
    PRFBios : Result := BiosFontWidth;

    PRFLoaded, PRFLinked :
    Begin
      Result := 0;
      If (Ord(ch) >= Data.Firstchar) And (Ord(ch) <= Data.LastChar) Then
        result := ByteArrPtr(Data.CWidth)^[Ord(ch) - Data.FirstChar];
    End;
  End;
End;

Function PRFontObj.FontHeight : Word;
Begin
  FontHeight := Data.FHeight;
End;

Procedure PutBMChar(x, y, ByteWidth, ht : Word; bptr : Pointer; fgcolor : Word); Assembler;
{ARG pagebase:WORD, color:BYTE:2, cp:DWORD, ht:WORD, bwid:WORD, y:WORD, x:WORD = retbytes}
Var
  shift, lshift : Byte;
  swid          : Word;
  lastbyte      : Byte;
ASM
  push    ds

  { get shift value }
  mov     ax, [x]
  and     ax, 3
  mov     [shift], al

  mov     bx, [y]
  shl     bx, 1
  mov     di, word ptr[RowTable + bx]
  mov     ax, [x]
  shr     ax, 2
  add     di, ax
  add     di, [WritePage]
  mov     ax, [SegA000]
  mov     es, ax    { starting address in es:di }

  mov     dx, SC_INDEX
  mov     al, MAP_MASK
  out     dx, al         { set Sequence controller Address Register to Map Mask }
  inc     dx             { dx = Sequence controller Data Register }
  mov     ah, byte ptr[fgcolor]
  lds     si, [bptr]
  mov     cx, [ht]        { height of character in cx }
  cmp     [shift], 0
  jne     @shifted_char

@char_loop:
  push    cx              { save height }
  push    di              { save offset }

  mov     cx, [ByteWidth]  { move number of bytes in font to cx }
@line_loop:
  mov     al, [ds:si]
  push    cx
  mov     cx, 8
@rev_loop:
  rcl     al, 1
  rcr     bh, 1
  loop    @rev_loop
  mov     al, bh
  pop     cx
  and     al, 0FH         { upper half in al }
  shr     bh, 4           { lower half in bh }
  out     dx, al          { set Map Mask Register }
  mov     al, ah          { al = color }
  stosb                   { draw left nibble }
  mov     al, bh          { move in lower half }
  out     dx, al          { set Map Mask Register }
  mov     al, ah          { al = color }
  stosb                   { draw left nibble }
  inc     si
  loop    @line_loop

  pop     di
  pop     cx
  add     di, 80
  loop    @char_loop
  jmp     @char_out

@shifted_char:             { special handling for shifted characters }
  mov     al, 8
  sub     al, [shift]      { get left shift }
  mov     [lshift], al
  mov     bl, ah           { move the color into bh }
@schar_loop:
  push    cx
  push    di             { save screen position for line increment }

  mov     [lastbyte], 0
  mov     cx, [bytewidth]
@sline_loop:
  push    cx             { save for loop }
  mov     al, [ds:si]    { bit pattern in al }
  mov     cl, [shift]    { shift it }
  shr     al, cl
  mov     ah, [lastbyte] { last byte in ah }
  mov     cl, [lshift]   { get last byte }
  shl     ah, cl         { shift it left to retrieve extra bytes }
  or      al, ah         { combine them }

  push    cx
  mov     cx, 8
@srev_loop:
  rcl     al, 1
  rcr     bh, 1
  loop    @srev_loop
  mov     al, bh
  pop     cx
  and     al, 0FH         { upper half in al }
  shr     bh, 4           { lower half in bh }
  out     dx, al          { set Map Mask Register }
  mov     al, byte ptr[fgcolor]     { al = color }
  stosb                   { draw left nibble }
  mov     al, bh          { move in lower half }
  out     dx, al          { set Map Mask Register }
  mov     al, bl          { al = color }
  stosb                   { draw left nibble }
  mov     al, [ds:si]
  mov     [lastbyte], al
  pop     cx
  inc     si
  loop    @sline_loop

  { catch the last byte }
  mov     al, [lastbyte] { last byte in ah }
  mov     cl, [lshift]   { get last byte }
  shl     al, cl         { shift it left to retrieve extra bytes }

  push    cx
  mov     cx, 8
@lrev_loop:
  rcl     al, 1
  rcr     bh, 1
  loop    @lrev_loop
  mov     al, bh
  pop     cx

  and     al, 0FH         { upper half in al }
  shr     bh, 4           { lower half in bh }
  out     dx, al          { set Map Mask Register }
  mov     al, bl          { al = color }
  stosb                   { draw left nibble }
  mov     al, bh          { move in lower half }
  out     dx, al          { set Map Mask Register}
  mov     al, bl          { al = color }
  stosb                   { draw left nibble }

  pop    di
  pop    cx
  add    di, 80
  loop   @schar_loop
@char_out:
  pop     ds
End;

Procedure PRFontObj.Write(strg : String);
Var
  i, j      : Word;
  strlen    : Word;
  pwid, pht : Word;
  bptr      : BytePtr;

  (* clipping variables *)
  x, y    : Word;
  pixwid  : Integer;       (* width of the character in pixels *)
  bwid    : Word;          (* byte width of character to print *)
  ht      : Integer;       (* height of character              *)


Begin
  strlen := Length(strg);
  If Direction = PRFDAcross Then
  Begin
    pwid := StrWidth(strg);
    pht := FontHeight;
  End
  Else
  Begin
    pwid := Data.WidestChar;
    pht := Fontheight * strlen;
  End;
  Case Justification Of
    PRFJCenter :
      If Direction = PRFDAcross Then
        Dec(CurrPt.x, pwid Shr 1)
      Else
        Dec(CurrPt.y, pht Shr 1);

    PRFJEnd :
      If Direction = PRFDAcross Then
        Dec(CurrPt.x, pwid)
      Else
       Dec(CurrPt.y, pht)
  End;

  If bgcolor <> Transparent Then
  Begin
    SolidBox(CurrPt.x, CurrPt.y,
             CurrPt.x + pwid + 1, CurrPt.y + pht,
             bgcolor);
  End;

  For i := 1 To Length(strg) Do
  Begin
    If (Ord(strg[i]) >= Data.FirstChar) And (Ord(strg[i]) <= Data.LastChar) Then
    Begin
      j := Ord(strg[i]) - Data.FirstChar;
      bptr := Pointer(LongInt(Data.FontData) + (j *
                                                Data.FontByteWidth *
                                                Data.FHeight));
      x := CurrPt.x;
      y := CurrPt.y;
      ht := Data.FHeight;
      If ht > 0 Then
        PutBMChar(x, y, Data.FontByteWidth, ht, bptr, fgcolor);

      (* Adjust Current Point *)
      If Direction = PRFDAcross Then
      Begin
        If FontMem = PRFBios Then
          Inc(CurrPt.x, BiosFontWidth)
        Else
          Inc(CurrPt.x, ByteArrPtr(Data.CWidth)^[j]);
      End
      Else
        Inc(CurrPt.y, Data.FHeight);
    End;
  End;
End;

Procedure PRFontObj.WriteAt(x, y : Word; Strg : String);
Begin
  CurrPt.x := x;
  CurrPt.y := y;
  Write(strg);
  CurrPt.x := x;
  CurrPt.y := y;
End;

Function PRFontObj.SetFGColor(color : Word) : Word;
Var
  result : Word;
Begin
  result := fgcolor;
  fgcolor := color;
  SetFGColor := result;
End;

Function PRFontObj.SetBGColor(color : Word) : Word;
Var
  result : Word;
Begin
  result := bgcolor;
  bgcolor := color;
  SetBGColor := result;
End;

Procedure PRFontObj.SetBothColor(cf, cb : Word);
Begin
  fgcolor := cf;
  bgcolor := cb;
End;

Procedure PRFontObj.SetJust(j : PRFontJust);
Begin
  justification := j;
End;

Procedure PRFontObj.SetDir(d : PRFontDir);
Begin
  Direction := d;
End;

Function PRFontObj.GetFGColor : Word;
Begin
  GetFGColor := fgcolor;
End;

Function PRFontObj.GetBGColor : Word;
Begin
  GetBGColor := bgcolor;
End;

Function PRFontObj.GetJust : PRFontJust;
Begin
  GetJust := Justification;
End;

Function PRFontObj.GetDir : PRFontDir;
Begin
  GetDir := Direction;
End;

Function PRFontObj.CurrX : Word;
Begin
  CurrX := CurrPt.x;
End;

Function PRFontObj.CurrY : Word;
Begin
  CurrY := CurrPt.y;
End;

Procedure PRFontObj.SetCurrX(x : Word);
Begin
  CurrPt.x := x;
End;

Procedure PRFontObj.SetCurrY(y : Word);
Begin
  CurrPt.y := y;
End;

Function PRFontObj.RetError : Integer;
Begin
  RetError := FontError;
End;

Function GetKey : Word;
Var
  Result : Word;
Begin
  ASM
    mov  ah, 0
    int  16H
    cmp  al, 0
    je   @go_out
    mov  ah, 0
  @go_out:
    mov  Result, ax
  End;
  GetKey := Result;
End;{GetKey}

Function InKey : Word;
Var
  Result : Word;
Begin
  ASM
    mov  ah, 1
    int  16H
    jz   @no_key
    call getkey
    mov  Result, ax
    jmp  @go_out
  @no_key:
    mov  Result, 0
  @go_out:
  End;
  InKey := Result;
End;{InKey}

Var
  mse_bg    : Pointer;    { pointer to background save area }
  AreaSaved : Word;       { screen area saved }
  crsrs     : Array[0..3] Of Word;

(*
ÖÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ·
º void SetMouseParms(void);                                      º
º Sets up the pointers for the background and cursors.           º
ÓÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ½
*)
Procedure SetMouseParms; Assembler;
ASM
  { set the background pointer }
  mov    bx, 3
  shl    bx, 1
  mov    ax, word ptr[PageTable + bx]
  mov    [word ptr mse_bg], ax
  mov    bx, 0
  mov    cx, 4
  @c_loop:
  add    ax, 80     { go for next line on scratch page }
  lea    si, crsrs
  mov    [si + bx], ax
  add    bx, 2
  loop   @c_loop
End;

(*
ÖÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ·
º void SaveMouseBG(int x, int y);                                     º
º Saves the mouse background to screen four in an 80 pixel chunk.     º
º The area is hard coded to x = 0 y = 4 on the fourth screen and is   º
º saved in a single strip.                                            º
º                                                                     º
º The only time this routine will be used is when a single screen, or º
º a partial screen update is being used. When a full screen update is º
º being done the background will take care of itself.                 º
ÓÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ½
*)
Procedure SaveMouseBG(x, y : Word); Assembler;
Var
  savesi : Word;
ASM
  push   ds
  mov    di, word ptr[mse_bg]  { dest offset to area in di }

  { find screen area }
  mov    bx, [y]
  sub    bx, [hy]
  shl    bx, 1
  mov    si, word ptr[RowTable + bx]
  mov    ax, [x]
  sub    ax, [hx]
  shr    ax, 2
  add    si, ax
  add    si, [WritePage]
  mov    [AreaSaved], si

  mov    dx, GC_INDEX  { 3CEH }
  mov    ax, 0008H     { Set the bitmask to use the latch data. }
  out    dx, ax
  mov    dx, SC_INDEX
  mov    ax, 0F02H     { Use all four planes. }
  out    dx, ax
  mov    ax, [SegA000]
  mov    es, ax
  mov    ds, ax
  cld
  mov    cx, 16        { move the number of lines into cx }
  cli

@line_loop:
  mov    [savesi], si  { save the values of registers for line counting }
  push   cx
  mov    cx, 5         { make the width saved 20 bytes (4 * 5) }
  repnz  movsb         { this makes sure to get offset cursor positions }

  pop    cx
  mov    si, [savesi]
  add    si, 80
  loop   @line_loop

  sti
  mov    dx, GC_INDEX
  mov    ax, 0FF08H     { Set the bitmask for only CPU data }
  out    dx, ax
  pop    ds
End;

(*
ÖÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ·
º void PutMouseBG(void);                                 º
º Puts the background back that was saved in SaveMouseBG º
ÓÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ½
*)
Procedure PutMouseBG; Assembler;
Var
  savedi : WORD;
ASM
  push   ds
  mov    si, word ptr [mse_bg]  { offset to area in si }
  mov    di, [AreaSaved]        { saved pointer in di  }

  mov    dx, GC_INDEX  { 3CEH }
  mov    ax, 0008H     { Set the bitmask to use the latch data. }
  out    dx, ax
  mov    dx, SC_INDEX
  mov    ax, 0F02H     { Use all four planes. }
  out    dx, ax
  mov    ax, [SegA000]
  mov    es, ax
  mov    ds, ax
  cld
  mov    cx, 16        { move the number of lines into cx }
  cli

@@line_loop:
  mov    [savedi], di  { save the values of registers for line counting }
  push   cx
  mov    cx, 5         { make the width 20 bytes (4 * 5) }
  repnz  movsb

  pop    cx
  mov    di, [savedi]
  add    di, 80
  loop   @@line_loop

  sti
  mov    dx, GC_INDEX
  mov    ax, 0FF08H     { Set the bitmask for only CPU data }
  out    dx, ax
  pop    ds
End;

(*

  Procedure PutMouseImage(x, y : Word);

  Puts the mouse image on the screen. Clips the cursor to the visible
  screen.

*)
Procedure PutMouseImage(x, y : Word); Assembler;
Var
  crsrofs, mofs, savedi, ht : WORD;
ASM
  push    ds
  cld
  mov     ax, [SegA000]
  mov     es, ax

  { get the source page offset and save it }
  mov     bx, [x]
  and     bx, 3
  shl     bx, 1

  mov     si, word ptr[crsrs + bx]
  mov     [crsrofs], si
  mov     si, word ptr[cm_ofs + bx]  { get the offset in the cursor mask array }
  mov     [mofs], si

  { get the destination offset }
  mov     bx, [y]
  shl     bx, 1
  mov     di, word ptr[RowTable + bx]
  mov     ax, [x]
  shr     ax, 2
  add     di, ax
  add     di, [WritePage]
  mov     [savedi], di    { save the offset for later }

  { get the proper cursor mask pointer }
  mov     ax, SEG crsr_masks
  mov     ds, ax
  mov     si, OFFSET crsr_masks
  add     si, [mofs]

  { set up the video card for screen to screen transfer }
  mov    dx, GC_INDEX     { set BitMask Register }
  mov    ax, BIT_MASK     { so that all data comes }
  out    dx, ax           { from latches }
  mov    dx, SC_INDEX     { set Sequence Controller Address Register }
  mov    al, MAP_MASK     { to point to Map Mask Register }
  out    dx, al
  inc    dx               { dx = Seq Controller Data Register }

  mov    bx, [crsrofs]
  mov    cx, 16
  cli
@height_loop:
  push   cx
  mov    cx, 5
@line_loop:
  lodsb                { get mask for this four-pixel set }
  out    dx, al        { set the mask }
  mov    al, [es:bx]   { load latches with 4 pixels from source }
  stosb                { copy four pixel set to dest }
  inc    bx            { advance source pointer }
  loop   @line_loop

  add    [savedi], 80
  mov    di, [savedi]
  pop    cx
  loop   @height_loop

  mov    dx, 3CEH
  mov    ax, 0FF08H  { Set the bitmask for only CPU data }
  out    dx, ax
  sti
  pop    ds
End;

(*
ÖÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ·
º This is the routine that handles the work of maintaining the mouse º
º cursor and setting of the event handler for the mouse.             º
ÓÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ½
*)
Procedure MouseHandler(Flags, CS, IP, AX, BX, CX, DX, SI, DI, DS, ES, BP : Word); Interrupt;
Begin
  rodent.event := AX;
  rodent.btnstate := BX;
  rodent.x := CX;
  rodent.y := DX;
  rodent.x := rodent.x Shr 1;

  If rodent.showing = 0 Then  { mouse is showing and free to draw}
  Begin
    If (rodent.event And MOUSE_MV) <> 0 Then  { only worry about it if it moved }
    Begin
      If rodent.savebg Then
      Begin
        PutMouseBG;
        SaveMouseBG(rodent.x, rodent.y);
        PutMouseImage(rodent.x, rodent.y);
      End;
    End;
  End;
  If HandlerIsActive Then
  Begin
    If (EventMask And rodent.event) <> 0 Then
    Begin
      If(PENDING_EVENTS < (SizeOfEventQueue - 1)) Then
      Begin
        Event_Queue^[EVENT_TAIL].etype := rodent.event;
        Event_Queue^[EVENT_TAIL].ShiftFlags := ShiftArea^;
        Event_Queue^[EVENT_TAIL].x := rodent.x;
        Event_Queue^[EVENT_TAIL].y := rodent.y;
        Event_Queue^[EVENT_TAIL].TimerTicks := TimerArea^;
        { need to set up for double click in here somewhere }
        If EVENT_TAIL = SizeOfEventQueue Then
          Inc(EVENT_TAIL)
        Else
          EVENT_TAIL := 0;
        Inc(PENDING_EVENTS);
      End;
    End;
  End;
  inline($8B/$E5/$5D/$07/$1F/$5F/$5E/$5A/$59/$5B/$58/$CB);
End;

Procedure InitEvents;
Begin
  MouseInit;
  EVENT_HEAD := 0;
  EVENT_TAIL := 0;
  PENDING_EVENTS := 0;
  EventMask := 0;
  HandlerIsActive := False;
  GetMem(Event_Queue, SizeOf(EventRec) * SizeOfEventQueue);
End;

Procedure CloseEvents;
Begin
  FreeMem(Event_Queue, SizeOf(EventRec) * SizeOfEventQueue);
  SetEventMask(0);
End;

(*
 Installs the mouse handler by hooking into the driver
*)
Procedure InstallMouseHandler(mask, TaskSeg, TaskOfs : Word);
Var
  Regs : Registers;
Begin
  With Regs Do
  Begin
    AX := 12;
    CX := Mask;
    DX := TaskOfs;
    ES := TaskSeg;
  End;
  Intr($33, Regs);
End;

Procedure SetEventMask(mask : Word);
Begin
  If mask = 0 Then
  Begin
    HandlerIsActive := False;
    If MouseHere Then
      InstallMouseHandler(0, 0, 0);
  End
  Else
  Begin
    HandlerIsActive := True;
    If ((mask And $7F) > 0) And MouseHere Then
      InstallMouseHandler(mask And $7F Or MOUSE_MV, Seg(MouseHandler), Ofs(MouseHandler));
  End;
  EventMask := mask;
End;

Function GetEvent(Var theEvent : EventRec) : Boolean;
Var
  key  : Word;
Begin
  GetEvent := False;
  If (EventMask And KEY_EVENT) = KEY_EVENT Then
  Begin
    Repeat
      key := InKey;
      If key <> 0 Then
      Begin
        theEvent.etype := KEY_EVENT;
        theEvent.key := key;
        theEvent.ShiftFlags := ShiftArea^;
        theEvent.TimerTicks := TimerArea^;
        AddEvent(theEvent);
      End;
    Until key = 0;
  End;

  If PENDING_EVENTS = 0 Then
    Exit;

  theEvent := Event_Queue^[EVENT_HEAD];
  If EVENT_HEAD = EventQueueTop Then
    Inc(EVENT_HEAD)
  Else
    EVENT_HEAD := 0;
  Dec(PENDING_EVENTS);
  GetEvent := True;
End;

Function AddEvent(Var theEvent : EventRec) : Boolean;
Begin
  AddEvent := False;
  If PENDING_EVENTS = SizeOfEventQueue Then
    Exit;
  Event_Queue^[EVENT_TAIL] := theEvent;
  Inc(PENDING_EVENTS);
  If EVENT_TAIL = EventQueueTop Then
    Inc(EVENT_TAIL)
  Else
    EVENT_TAIL := 0;
  AddEvent := True;
End;

Function DiscardEvent : Boolean;
Begin
  DiscardEvent := False;
  If PENDING_EVENTS = 0 Then
    Exit;
  Inc(EVENT_HEAD);
  If EVENT_HEAD > EventQueueTop Then
    EVENT_HEAD := 0;
  Dec(PENDING_EVENTS);
  DiscardEvent := True;
End;

Procedure FlushEvents;
Begin
  PENDING_EVENTS := 0;
  EVENT_HEAD := 0;
  EVENT_TAIL := 0;
End;

Function IsEventAvailable : Boolean;
Begin
  IsEventAvailable := False;
  If PENDING_EVENTS > 0 Then
    IsEventAvailable := True;
End;


Procedure MouseInit;
Begin
  ASM
    mov   ax, 0
    int   $33
    cmp   ax, 0
    je    @no_mouse
    mov   [MouseHere], 1
    jmp   @all_done
    @no_mouse:
    mov   [MouseHere], 0
    @all_done:
  End;

  If MouseHere Then
  Begin
    rodent.DblClickWait := 6;
    rodent.event := 0;
    rodent.showing := -1;
    rodent.btnstate := 0;
    rodent.x := 160;
    rodent.y := 120;
    SetMouseParms;
    SetMouseLimits(0, 0, 319, 239);
    MouseSetCursor(dflt_arrow);
    InstallMouseHandler(MOUSE_MV, Seg(MouseHandler), Ofs(MouseHandler));
  End;
End;

Procedure MouseSetCursor(Var mc : MouseCrsr);
Var
  wasshowing       : Boolean;
  crsr, coff       : BytePtr;
  temp             : BytePtr;
  l1, l2, l3, l4   : BytePtr;
  i, j, k, oldpage : Integer;
  p                : PictHeader;
  Regs             : Registers;
Begin
  wasshowing := False;
  hx := mc.hotx; hy := mc.hoty;
  If MouseHere Then
  Begin
    If (rodent.showing = 0) And rodent.savebg Then
    Begin
      wasshowing := True;
      MouseHide;
    End;
    rodent.curr_crsr := @mc;
    With Regs Do
    Begin
      AX := 9;
      CX := hy;
      BX := hx;
      DX := 0;
      ES := 0;
    End;
    Intr($33, Regs);

    { set up cursor masks and offset cursors }
    GetMem(crsr, 320);
    p.width := 320;
    p.height := 1;
    p.bytewidth := 80;
    p.data := crsr;
    oldpage := WritePage;
    UsePage(VSCRATCH);
    FillChar(crsr_masks, 320, 0);
    For i := 0 To 3 Do
    Begin
      FillChar(crsr^, 320, 0);
      coff := Pointer(LongInt(crsr) + (i * 80));
      { make an offset cursor }
      temp := mc.bm;
      For k := i To 3 Do
      Begin
        For j := 0 To 15 Do
        Begin
          Move(temp^, coff^, 4);
          Inc(coff, 5);
          Inc(temp, 4);
        End;
      End;
      coff := Pointer(LongInt(crsr) + 1);
      For k := 0 To i - 1 Do
      Begin
        For j := 0 To 15 Do
        Begin
          Move(temp^, coff^, 4);
          Inc(coff, 5);
          Inc(temp, 4);
        End;
      End;

      { put the picture on the screen }
      PutPic(0, i + 1, p);

      { set up the picture masks }
      l1 := p.data;
      l2 := Pointer(LongInt(p.data) + 80);
      l3 := Pointer(LongInt(p.data) + 160);
      l4 := Pointer(LongInt(p.data) + 240);
      temp := Pointer(LongInt(@crsr_masks) + (i * 80));
      For j := 0 To 79 Do
      Begin
        If l1^ > 0 Then
          temp^ := temp^ Or $01;
        If l2^ > 0 Then
          temp^ := temp^ Or $02;
        If l3^ > 0 Then
          temp^ := temp^ Or $04;
        If l4^ > 0 Then
          temp^ := temp^ Or $08;
        Inc(temp);
        If j < 79 Then
        Begin
          Inc(l1);
          Inc(l2);
          Inc(l3);
          Inc(l4);
        End;
      End;
    End;
    UsePage(oldpage);
    FreeMem(crsr, 320);
    If wasshowing Then
      MouseShow;
  End;
End;

Procedure SetMouseLimits(x1, y1, x2, y2 : Word);
Begin
  If MouseHere Then
  Begin
    ASM
      mov   ax, 7    { Function 7 = set mouse x limit }
      mov   cx, [x1]
      shl   cx, 1
      mov   dx, [x2]
      shl   dx, 1
      int   $33

     mov   ax, 8    { Function 8 = set mouse y limit }
      mov   cx, [y1]
      mov   dx, [y2]
      int   $33
    End;
  End;
End;

Procedure SetMousePos(x, y : Word);
Begin
  If MouseHere Then
  Begin
    ASM
      shr  [x], 1
      mov  ax, 4    { Function 4 = set the mouse position }
      mov  cx, [x]
      mov  dx, [y]
      int  $33
    End;
  End;
End;

Procedure MouseRecPos;
Var
  btn, x, y : Word;
Begin
  If MouseHere Then
  Begin
    ASM
      mov   ax, 3;
      int   $33
      mov   [btn], bx
      shr   cx, 1     {adjust for resolution }
      mov   [x], cx
      mov   [y], dx
    End;
  End;
  rodent.btnstate := btn;
  rodent.x := x;
  rodent.y := y;
End;

Procedure MouseShow;
Begin
  If MouseHere Then
  Begin
    Inc(rodent.showing);
    If rodent.showing > 0 Then
      rodent.showing := 0;
    If rodent.showing = 0 Then
    Begin
      If rodent.savebg Then
      Begin
        SaveMouseBG(rodent.x, rodent.y);
        PutMouseImage(rodent.x, rodent.y);
      End;
    End;
  End;
End;

Procedure MouseHide;
Begin
  If MouseHere Then
  Begin
    If (rodent.showing <> 0) And rodent.savebg Then
      PutMouseBG;
    Dec(rodent.showing);
  End;
End;

BEGIN
  ShiftArea := Ptr(Seg0040, $17);
  TimerArea := Ptr(Seg0040, $6C);
  With dflt_arrow Do
  Begin
    HotX := 0;
    HotY := 0;
    bm := @dflt_crsr_data;
  End;
END.
