Program FIELD_EDITOR;

Uses Crt,ModeX, JerVGA, Common, UnitPCX;

Var Field           : Array [-10..110 , -10..110] of Byte;
    Trans           : Array [-10..110 , -10..110] of Byte;
    CellStatus      : Array [0..142] of Byte;
    x,
    y,
    x_cell,
    y_cell,
    current_number,
    current_trans,
    number          : Byte;
    font            : PrFontObj;
    t1,
    t2              : Integer;
    ch              : Char;
    pict_buffer     : PictHeader;
    pict_mask       : BytePtr;
    s               : String;
    f               : Text;
    csrpos : record
      x         : integer;
      y         : integer;
    end;

Procedure smfont; External;
{$L smfont.obj}

Procedure Initialize;
Begin
  WriteLn ('Running program at level 0001:4653. Please standby...');
  SetMode (MODE200, 0, 0);
  Font. Meminit (@SMFONT);
  Font. SetFGColor (15);
  GetPic (0, 0, 16, 16, pict_buffer);
  current_number:=0;
  For t1:=0 to 99 do For t2:=0 to 99 do begin
    Field [t1, t2]:=0;
    Trans [t1, t2]:=0;
  End;
End;

Procedure LoadCells;
Begin
  UsePage (0);
  Load_PCX (0, 0, 319, 199, 'screen2', True);
  UsePage (1);
  Load_PCX (0, 0, 319, 199, paramStr(1), True)
End;

Procedure DrawFrame (x1, y1, x2, y2, c : Word);
Begin
  SolidHlineX (y1, x1, x2, c);
  SolidHlineX (y2, x1, x2, c);

  SolidVlineX (x1, y1, y2, c);
  SolidVlineX (x2, y1, y2, c);
End;

Procedure ShowCursor (x_pos, y_pos, page : Byte);
Begin
  BlockPageToPage (page, 3, x_pos, y_pos, 4, 16, 0, 0);
  UsePage (page);
  DrawFrame (x_pos, y_pos, x_pos + 15, y_pos + 15, 15);
  WaitForRetrace;
  BlockPageToPage (3, page, 0, 0, 4, 16, x_pos, y_pos);
  WaitForRetrace;
End;

Begin
  Initialize;
  LoadCells;
  x:=0;
  y:=0;
  csrpos. x:=-1;
  Repeat
    UsePage (1);
    For t1:=x - 9 to x + 9 do For t2:=y - 4 to y + 3 do begin
      number:=Field [t1, t2];
      x_cell:=Trunc (number / 11);
      y_cell:=number mod 11;
      x_cell:=x_cell * 16 + (x_cell * 4);
      y_cell:=y_cell * 17;
      If Trans [t1, t2] < 2 then begin
        BlockPageToPage (1, 0, x_cell, y_cell, 4, 16, ((t1  - x) * 16) + 152, ((t2 - y) * 16 + 72));
      end else begin
        BlockPageToPage (1, 1, x_cell, y_cell, 4, 16, 300, 0);
        number:=Trans [t1, t2];
        x_cell:=Trunc (number / 11);
        y_cell:=number mod 11;
        x_cell:=x_cell * 16 + (x_cell * 4);
        y_cell:=y_cell * 17;
        GetPic (x_cell, y_cell, 16, 16, pict_buffer);
        GetPicMask (pict_buffer, pict_mask);
        CopyScreenToScreenMaskedX (1, x_cell, y_cell, 4, 16, 300, 0, 1, pict_mask);
        FreeMem (Pict_Mask, pict_buffer. height * pict_buffer. width);
        FreePic (pict_buffer);
        BlockPageToPage (1, 0, 300, 0, 4, 16, ((t1  - x) * 16) + 152, ((t2 - y) * 16 + 72));
      End;
      usepage (0);
      if (csrpos. x = t1) and (csrpos. y = t2) and (csrpos. x > -1) then
        SolidBox (((t1  - x) * 16) + 154, ((t2 - y) * 16 + 74), ((t1  - x) * 16) + 165, ((t2 - y) * 16 + 85), 15);
      usepage (1);
    End;
    Repeat
      ShowCursor (152, 72, 0);
    Until Keypressed;
    ch:=Readkey;
    If ch = #32 then Field [x, y]:=current_number;
    If ch = #13 then if current_trans = Trans [x, y] then Trans [x, y]:=0 else Trans [x, y]:=current_trans;
    If ch = #0 then begin
      ch:=Readkey;
      If ch = #61 then begin
        SolidBox (8, 144, 311, 191, 0);
        Str (x, s);
        Font. WriteAt (100, 167, 'x: ' + s);
        Str (y, s);
        Font. WriteAt (130, 167, 'y: ' + s);
        Str (field [x, y], s);
        Font. WriteAt (160, 167, 'c: ' + s);
      End;
      If ch = #62 then begin
        BlockPageToPage (1, 2, 0, 0, 80, 200, 0, 0);
        ShowPage (2);
        UsePage (2);
        For number:=0 to 142 do begin
          If CellStatus [number] = 1 then begin
            x_cell:=Trunc (number / 11);
            y_cell:=number mod 11;
            x_cell:=x_cell * 16 + (x_cell * 4);
            y_cell:=y_cell * 17;
            DrawFrame (x_cell + 1, y_cell + 1, x_cell + 14, y_cell + 14, 3);
          End;
        End;
        x_cell:=0;
        y_cell:=0;
        Repeat
          Repeat
            ShowCursor (x_cell * 16 + (x_cell * 4), y_cell * 16 + y_cell, 2);
          Until Keypressed;
          ch:=Readkey;
          If (ch = #72) and (y_cell > 00) then y_cell:=y_cell - 1;
          If (ch = #77) and (x_cell < 12) then x_cell:=x_cell + 1;
          If (ch = #80) and (y_cell < 10) then y_cell:=y_cell + 1;
          If (ch = #75) and (x_cell > 00) then x_cell:=x_cell - 1;
          t1:=x_cell;
          t2:=y_cell;
          If (ch = #32) then begin
            number:=x_cell * 11 + y_cell;
            x_cell:=Trunc (number / 11);
            y_cell:=number mod 11;
            x_cell:=x_cell * 16 + (x_cell * 4);
            y_cell:=y_cell * 17;
            If CellStatus [number] = 0 then begin
              DrawFrame (x_cell + 1, y_cell + 1, x_cell + 14, y_cell + 14, 3);
              CellStatus [number]:=1;
            End else begin
              BlockPageToPage (1, 2, x_cell, y_cell, 4, 16, x_cell, y_cell);
              CellStatus [number]:=0;
            End;
            x_cell:=t1;
            y_cell:=t2;
          End;
        Until (ch = #62) or (ch = #27);
        ShowPage (0);
        UsePage (0);
      End;
      If ch = #63 then begin
        SetTextMode;
        WriteLn ('S A V I N G   A   F I L E');
        WriteLn ('-------------------------');
        WriteLn ('Input filename please, no extension, RETURN to confirm.');
        Write ('>');
        ReadLn (s);
        If s <> '' then begin
          WriteLn;
          s:='dat\' + s + '.dat';
          WriteLn ('Now saving data in ' + s);
          Assign (f, s);
          ReWrite (f);
          For t1:=0 to 99 do For t2:=0 to 99 do begin
            WriteLn (f, Field [t1, t2]);
            WriteLn (f, Trans [t1, t2]);
          End;
          For t1:=0 to 142 do begin
            WriteLn (f, CellStatus [t1]);
          End;
          Close (f);
          WriteLn ('Save sequence completed.');
        End;
        WriteLn ('Press a key to return to the editor...');
        ch:=Readkey;
        SetMode (MODE200, 0, 0);
        LoadCells;
        ShowPage (0);
      End;
      if ch = #65 then
      begin
        if (csrpos. x = x) and (csrpos. y = y) then
          csrpos. x:=-1
        else
        if csrpos. x < 0 then
        begin
          csrpos. x:=x;
          csrpos. y:=y
        end
        else
          if (csrpos. x <= x) and (csrpos. y <= y) then
          begin
            for t1:=csrpos. x to x do
              for t2:=csrpos. y to y do
                field [t1, t2]:=current_number;
              csrpos. x:=-1
            end
      end;
      if ch = #66 then
      begin
        if (csrpos. x = x) and (csrpos. y = y) then
          csrpos. x:=-1
        else
        if csrpos. x < 0 then
        begin
          csrpos. x:=x;
          csrpos. y:=y
        end
        else
          if (csrpos. x <= x) and (csrpos. y <= y) then
          begin
            for t1:=csrpos. x to x do
              for t2:=csrpos. y to y do
                trans [t1, t2]:=current_trans;
            csrpos. x:=-1
          end
      end;
      If ch = #64 then begin
        SetTextMode;
        WriteLn ('L O A D I N G   A   F I L E');
        WriteLn ('-------------------------');
        WriteLn ('!!WARNING!! your current data will be destroyed !');
        WriteLn ('Input filename please, no extension, RETURN to confirm.');
        Write ('>');
        ReadLn (s);
        If s <> '' then begin
          WriteLn;
          s:='dat\' + s + '.dat';
          WriteLn ('Now loading data from ' + s);
          Assign (f, s);
          Reset (f);
          For t1:=0 to 99 do For t2:=0 to 99 do begin
            ReadLn (f, Field [t1, t2]);
            ReadLn (f, Trans [t1, t2]);
          End;
          For t1:=0 to 142 do begin
            ReadLn (f, CellStatus [t1]);
          End;
          Close (f);
          WriteLn ('Loading sequence completed.');
        End;
        WriteLn ('Press a key to return to the editor...');
        ch:=Readkey;
        SetMode (MODE200, 0, 0);
        LoadCells;
        ShowPage (0);
      End;
      If (ch = #72) and (y > 00) then y:=y - 1;
      If (ch = #77) and (x < 99) then x:=x + 1;
      If (ch = #80) and (y < 99) then y:=y + 1;
      If (ch = #75) and (x > 00) then x:=x - 1;
      If ch = #59 then begin
        ShowPage (1);
        UsePage (1);
        x_cell:=Trunc (current_number / 11);
        y_cell:=current_number mod 11;
        Repeat
          Repeat
            ShowCursor (x_cell * 16 + (x_cell * 4), y_cell * 16 + y_cell, 1);
          Until Keypressed;
          ch:=Readkey;
          If (ch = #72) and (y_cell > 00) then y_cell:=y_cell - 1;
          If (ch = #77) and (x_cell < 12) then x_cell:=x_cell + 1;
          If (ch = #80) and (y_cell < 10) then y_cell:=y_cell + 1;
          If (ch = #75) and (x_cell > 00) then x_cell:=x_cell - 1;
        Until (ch = #59) or (ch = #32);
        ShowPage (0);
        UsePage (0);
        current_number:=x_cell * 11 + y_cell;
      End;
      If ch = #60 then begin
        ShowPage (1);
        UsePage (1);
        x_cell:=Trunc (current_trans / 11);
        y_cell:=current_trans mod 11;
        Repeat
          Repeat
            ShowCursor (x_cell * 16 + (x_cell * 4), y_cell * 16 + y_cell, 1);
          Until Keypressed;
          ch:=Readkey;
          If (ch = #72) and (y_cell > 00) then y_cell:=y_cell - 1;
          If (ch = #77) and (x_cell < 12) then x_cell:=x_cell + 1;
          If (ch = #80) and (y_cell < 10) then y_cell:=y_cell + 1;
          If (ch = #75) and (x_cell > 00) then x_cell:=x_cell - 1;
        Until (ch = #60) or (ch = #32) or (ch = #13);
        ShowPage (0);
        UsePage (0);
        current_trans:=x_cell * 11 + y_cell;
      End;
    End;
  Until ch = #27;
  SetTextMode;
End.
