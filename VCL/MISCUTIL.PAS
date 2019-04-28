{*********************************************************}
{                                                         }
{    Calmira System library 3.3                           }
{    by Li-Hsin Huang & Erwin Dokter                      }
{    released into the public domain may 2002             }
{                                                         }
{*********************************************************}

unit MiscUtil;

{ Some useful Delphi and Windows routines }

interface

uses Classes, SysUtils, Forms, WinTypes, IniFiles, Menus, Buttons,
  StdCtrls, Dialogs, ExtCtrls, Graphics, TabNotBk, Controls;

const
  MsgDialogSounds: Boolean = False;
  MaxHistorySize: Integer = 24;
  RepaintBeforeHourglass: Integer = 1;
  DarkIconStretch: Boolean = True;
  HQIconStretch: Boolean = False; { 3.1 }

var
  IconMesh: TBrush;

function Min(a, b: Integer): Integer;
function Max(a, b: Integer): Integer;
{ Returns the smaller and larger of two values respectively }

function Range(n, lower, upper: Integer): Integer;
{ Constrains n to a lower and upper limit }

function Sign(x: Integer): Integer;
{ Returns 1 if x > 0, -1 if x < 0 and 0 if x = 0 }

procedure DrawRect(Canvas: TCanvas; R: TRect);
{ Draws a rectangle using the current pen }

procedure Border3D(Canvas: TCanvas; R: TRect);
{ Draws a raised 3D border on a canvas, typically used in an
  OnPaint method of a TForm }

procedure RecessBevel(Canvas: TCanvas; R: TRect);
{ Draws a lowered 3D frame on a canvas, alternative to using
  bevels }

procedure Control3D(Canvas: TCanvas; Control: TControl);
{ Draw a lowered 3D border around a given control with no Ctl3D
  property of their own, alternative to using bevels }

const
  snd_Sync      = $0000;  { play synchronously (default) }
  snd_Async     = $0001;  { play asynchronously }
  snd_NoDefault = $0002;  { don't use default sound }
  snd_Memory    = $0004;  { lpszSoundName points to a memory file }
  snd_Loop      = $0008;  { loop the sound until next sndPlaySound }
  snd_NoStop    = $0010;  { don't stop any currently playing sound }

function sndPlaySound(lpszSoundName: PChar; uFlags: Word): Bool;
{ 3.11 -- This function is declared here instead of using MMSystem,
  which may cause buggy initialization }

procedure PlaySound(const filename: TFilename);
{ Plays the specified WAV file as a sound effect.  If the filename
  is '<none>', nothing is played }

function Intersects(const R, S: TRect): Boolean;
{ Returns True if the two rectangles intersect }

function NormalizeRect(p, q: TPoint): TRect;
{ Returns a rectangle defined by any two points.  When dragging a
  selection box with a mouse, the fixed corner and the moving
  corner may not always be top left and bottom right respectively.
  This function creates a valid TRect out of them }

function TimeStampToDate(FileDate: Longint): TDateTime;
{ Converts a DOS timestamp to TDateTime.  If the timestamp is invalid
  (some programs use invalid stamps as markers), the current date
  is returned instead of raising EConvertError }

function GetRadioIndex(const R: array of TRadioButton): Integer;
procedure SetRadioIndex(const R: array of TRadioButton; index: Integer);
function GetMenuCheck(const M: array of TMenuItem): Integer;
procedure SetMenuCheck(const M: array of TMenuItem; index: Integer);
function GetButtonState(const B: array of TSpeedButton): Integer; { 3.0 }
procedure SetButtonState(const B: array of TSpeedButton; index: Integer); { 3.0 }
{ These routines are useful for setting and querying the state of
  several controls.  Use them to simulate arrays and as an alternative
  to TRadioGroup. }

{ 3.1 }
function GetFlag(const Data: Pointer; Flag: Longint): Boolean;
function SetFlag(const Data: Pointer; Flag: Longint): Pointer;
function ClearFlag(const Data: Pointer; Flag: Longint): Pointer;
function ToggleFlag(const Data: Pointer; Flag: Longint): Pointer;
{ These routines let you directly manipulate bits in a data property,
  which many Delphi components, like grids and outlines have.  They
  usually hold a pointer to a data object in memory, but is often
  (ab)used to store flags instead.  Declare your flags using the
  represented bit values; 1, 2, 4, 8, 16, 32, etc... }

procedure RefreshCursor;
{ Updates the cursor image when you have changed the Cursor or DragCursor
  property of a control }

procedure UpdateScreen;
{ Forces all vivible windows to repaint }

procedure ShowHourGlass;
{ Displays the hourglass cursor immediately }

procedure ShowArrow;
{ Displays the standard arrow }

function AddHistory(Combo: TComboBox): Boolean;
{ Adds a combo box's Text string to its listbox, but only if the
  string is not empty and not already present in the list.  The item is
  inserted at the top of the list, and if there are more than 24 items,
  the bottom one is removed.  Returns true if the list is modified }

procedure AssignHistoryText(Combo: TCombobox; const NewText: string);

function MsgDialog(const Msg: string; AType: TMsgDlgType;
  AButtons: TMsgDlgButtons; HelpCtx: Longint): Word;
function MsgDialogRes(Ident: Word; AType: TMsgDlgType;
  AButtons: TMsgDlgButtons; HelpCtx: Longint): Word;
function MsgDialogResFmt(Ident: Word; const Args: array of const;
  AType: TMsgDlgType; AButtons: TMsgDlgButtons; HelpCtx: Longint): Word;
{ Calls the MessageDialog function, but also plays a suitable sound
  effect from the Control Panel settings.  The MsgDialogSounds variable
  enables the sounds }

procedure ErrorMsg(const msg: string);
procedure ErrorMsgRes(Ident: Word);
procedure ErrorMsgResFmt(Ident: Word; const Args: array of const);
{ Displays a message dialog box indicating an error }

function ShowModalDialog(FormClass: TFormClass): TModalResult;
{ A very simple way of displaying a dynamic modal form -- just pass the
  form's class name e.g. TForm1, and an instance will be created,
  shown as a modal dialog and then destroyed. }

function InitBitmap(ABitmap: TBitmap; AWidth, AHeight: Integer;
  Color: TColor): TBitmap;
{ Initialises the bitmap's dimensions and fills it with the chosen colour }

procedure ShrinkIcon(H: HIcon; Glyph: TBitmap; BGColor: TColor); { 3.0 }
{ Shrinks a 32 x 32 icon down to a 16 x 16 bitmap }

procedure ShadeIcon(ACanvas: TCanvas; AIcon: TIcon; X, Y: Integer;
  AColor: TColor);
{ Shades an icon giving it the appearence of being selected }

procedure ReplaceBitmapColors(bitmap: TBitmap; source, dest: TColor); { 3.11 }
{ Changes pixels from one color to another }

function CreateBrushPattern(const bgColor, fgColor: TColor): TBitmap; { 3.1 }
{ Creates an 8 by 8 mesh pattern to use in brushes }

function MinimizeString(const s: string; Canvas: TCanvas;
  target: Integer): string; { 3.11 }
{ Given a string and a target width, truncate it so that it fits
  comfortably within the target.  First check if it fits.  If it doesn't,
  keep chopping the end off until it does and append three dots to it. }

procedure Sleep(MSec: Longint); { 3.1 }
{ Suspend the current procedure for a specified number of milliseconds.
  Other processes are not blocked and messages are still processed.
  Also works when Application is nil. }

procedure Delay(MSec: Longint); { 3.11 }
{ Same as Sleep, but blocks ALL processes(!)  Use if Sleep causes GPF. }

function GetTimerCount: Longint;
{ Acurate alternative to GetTickCount }

procedure WaitTick;
{ wait for the next tick from the clock.  Handy for timing
  looping scroll events.  This is a BLOCKING loop! }

procedure CopyStringsToClipboard(strings: TStrings);

function ShortTimeToStr(Time: TDateTime): string;

procedure FreePageHandles(Notebook: TNotebook);

function GetMinPosition(Wnd: HWND): TPoint;

procedure MoveDesktopIcon(Wnd: HWND; pt: TPoint);

procedure GetHeaderDivisions(H: THeader; A: array of PInteger);

procedure EnableControlList(C: array of TControl; Enable: Boolean);

{ Various (ported) routines from later SysUtils versions }

procedure Beep;
procedure FreeAndNil(var Obj);

function HeightOf(const r: TRect): Integer;
function WidthOf(const r: TRect): Integer;
{ Return height or width of a rect }

function Trim(const s: string): string;
function TrimLeft(const s: string): string;
function TrimRight(const s: string): string;
{ Trims a string form leading and/or trailing spaces and nulls }

function GetCurrentDir: TFilename;
{ GetCurrentDir returns the current directory. }

function SetCurrentDir(const Dir: TFilename): Boolean;
{ SetCurrentDir sets the current directory. Returns True if
  the directory was successfully changed. }

function CreateDir(const Dir: TFilename): Boolean;
{ CreateDir creates a new directory. Returns True if it the
  directory was successfully created. }

function RemoveDir(const Dir: TFilename): Boolean;
{ RemoveDir deletes an existing empty directory. Returns
  True if the directory was successfully deleted. }

implementation

uses WinProcs, Messages, ShellAPI, Strings, Clipbrd, ToolHelp;

function Min(a, b: Integer): Integer; assembler;
asm
        MOV     AX,a
        CMP     AX,b
        JLE     @@1
        MOV     AX,b
@@1:
end;

function Max(a, b: Integer): Integer; assembler;
asm
        MOV     AX,a
        CMP     AX,b
        JGE     @@1
        MOV     AX,b
@@1:
end;

function Range(n, lower, upper: Integer): Integer; assembler;
asm
        MOV     AX,n
        CMP     AX,lower
        JGE     @@1
        MOV     AX,lower
        JMP     @finish
@@1:    CMP     AX,upper
        JLE     @finish
        MOV     AX,upper
        JMP     @finish
@@2:    MOV     AX,lower
@finish:
end;

function Sign(x: Integer): Integer; assembler;
asm
        MOV     AX,X
        CMP     AX,0
        JL      @@1
        JG      @@2
        XOR     AX,AX
        JMP     @finish
@@1:    MOV     AX,-1
        JMP     @finish
@@2:    MOV     AX,1
@finish:
end;

procedure DrawRect(Canvas: TCanvas; R: TRect);
begin
  with R do
    Canvas.PolyLine([Point(Left, Top), Point(Right, Top),
      Point(Right, Bottom), Point(Left, Bottom), Point(Left, Top)]);
end;

procedure Border3D(Canvas: TCanvas; R: TRect);
begin
  Frame3D(Canvas, R, clBtnHighlight, clBtnShadow, 1);
end;

procedure RecessBevel(Canvas: TCanvas; R: TRect);
begin
  Frame3D(Canvas, R, clBtnShadow, clBtnHighlight, 1);
end;

procedure Control3D(Canvas: TCanvas; Control: TControl);
var
  R: TRect;
begin
  R := Control.BoundsRect;
  InflateRect(R, 1, 1);
  RecessBevel(Canvas, R);
end;

function sndPlaySound; external 'MMSYSTEM' index 2;

procedure PlaySound(const filename: TFilename);
var
  buf: array[0..79] of Char;
begin
  if filename = '' then
    sndPlaySound(nil, SND_ASYNC)
  else if CompareText(filename, '<none>') <> 0 then
    sndPlaySound(StrPCopy(buf, filename), SND_ASYNC or SND_NODEFAULT);
end;

function Intersects(const R, S: TRect): Boolean;
var
  dummy: TRect;
begin
  Result := IntersectRect(dummy, R, S) <> 0;
end;

function NormalizeRect(p, q: TPoint): TRect; assembler;
asm
        MOV     AX,p.x
        MOV     BX,p.y
        MOV     CX,q.x
        MOV     DX,q.y
        CMP     AX,CX
        JLE     @@1
        XCHG    AX,CX
@@1:    CMP     BX,DX
        JLE     @@2
        XCHG    BX,DX
@@2:    LES     DI,@Result
        MOV     TRect(ES:[DI]).Left,AX
        MOV     TRect(ES:[DI]).Top,BX
        MOV     TRect(ES:[DI]).Right,CX
        MOV     TRect(ES:[DI]).Bottom,DX
end;

function TimeStampToDate(FileDate: Longint): TDateTime;
begin
  try
    Result := FileDateToDateTime(FileDate)
  except
    on EConvertError do Result := Date;
  end;
end;

function GetRadioIndex(const R: array of TRadioButton): Integer;
begin
  for Result := 0 to High(R) do
    if R[Result].Checked then Exit;
  Result := -1;
end;

procedure SetRadioIndex(const R: array of TRadioBUtton; index: Integer);
var
  i: Integer;
begin
  for i := 0 to High(R) do
    R[i].Checked := i = index;
end;

function GetMenuCheck(const M: array of TMenuItem): Integer;
begin
  for Result := 0 to High(M) do
    if M[Result].Checked then Exit;
  Result := -1;
end;

procedure SetMenuCheck(const M: array of TMenuItem; index: Integer);
var
  i: Integer;
begin
  for i := 0 to High(M) do
    M[i].Checked := i = index;
end;

function GetButtonState(const B: array of TSpeedButton): Integer;
begin
  for Result := 0 to High(B) do
    if B[Result].Down then Exit;
  Result := -1;
end;

procedure SetButtonState(const B: array of TSpeedButton; index: Integer);
var
  i: Integer;
begin
  for i := 0 to High(B) do
    B[i].Down := i = index;
end;

function GetFlag(const Data: Pointer; Flag: Longint): Boolean;
begin
  Result := Longint(Data) and Flag <> 0;
end;

function SetFlag(const Data: Pointer; Flag: Longint): Pointer;
begin
  Result := Pointer(Longint(Data) or Flag);
end;

function ClearFlag(const Data: Pointer; Flag: Longint): Pointer;
begin
  Result := Pointer(Longint(Data) and not Flag);
end;

function ToggleFlag(const Data: Pointer; Flag: Longint): Pointer;
begin
  Result := Pointer(Longint(Data) xor Flag);
end;

procedure RefreshCursor;
var
  p: TPoint;
begin
  GetCursorPos(p);
  SetCursorPos(p.x, p.y);
end;

function DoUpdateWindow(Wnd: HWND; lParam: Longint): Bool; export;
begin
  UpdateWindow(Wnd);
  Result := True;
end;

procedure UpdateScreen;
begin
  case RepaintBeforeHourglass of
    1: EnumTaskWindows(GetCurrentTask, @DoUpdateWindow, 0);
    2: EnumWindows(@DoUpdateWindow, 0);
  end;
end;

procedure ShowHourGlass;
begin
  UpdateScreen;
  SetCursor(LoadCursor(0, IDC_WAIT));
end;

procedure ShowArrow;
begin
  SetCursor(LoadCursor(0, IDC_ARROW));
end;

function AddHistory(Combo: TComboBox): Boolean;
var
  i: Integer;
  s: string;
begin
  Result := False;
  with Combo, Combo.Items do
    if Text <> '' then
    begin
      i := IndexOf(Text);
      if i = -1 then
      begin
        Result := True;
        Insert(0, Text)
      end
      else if i > 0 then
      begin
        { Same as Exchange(i, 0), but Exchange can clear the
          Text property if the text is the string at i }
        Result := True;
        s := Text;
        Delete(i);
        Insert(0, s);
        Text := s;
      end;
      while (Count > 0) and (Count > MaxHistorySize) do
      begin
        Result := True;
        Delete(Count - 1);
      end;
    end;
end;

procedure AssignHistoryText(Combo: TCombobox; const NewText: string);
begin
  with Combo do
  begin
    if NewText > '' then Text := NewText;
    if (Text = '') and (Items.Count >= 1) then Text := Items[0];
  end;
end;

function MsgDialog(const Msg: string; AType: TMsgDlgType;
  AButtons: TMsgDlgButtons; HelpCtx: Longint): Word;
const
  Sound: array[TMsgDlgType] of Word =
    (MB_ICONEXCLAMATION, MB_ICONHAND, MB_OK, MB_ICONQUESTION, 0);
begin
  if MsgDialogSounds and (AType < mtCustom) then MessageBeep(Sound[AType]);
  Result := MessageDlg(Msg, AType, AButtons, HelpCtx);
end;

function MsgDialogRes(Ident: Word; AType: TMsgDlgType;
  AButtons: TMsgDlgButtons; HelpCtx: Longint): Word;
begin
  Result := MsgDialog(LoadStr(Ident), AType, AButtons, HelpCtx);
end;

function MsgDialogResFmt(Ident: Word; const Args: array of const;
  AType: TMsgDlgType; AButtons: TMsgDlgButtons; HelpCtx: Longint): Word;
begin
  Result := MsgDialog(FmtLoadStr(Ident, Args), AType, AButtons, HelpCtx);
end;

procedure ErrorMsg(const msg: string);
begin
  MsgDialog(msg, mtError, [mbOK], 0);
end;

procedure ErrorMsgRes(Ident: Word);
begin
  MsgDialog(LoadStr(Ident), mtError, [mbOK], 0);
end;

procedure ErrorMsgResFmt(Ident: Word; const Args : array of const);
begin
  MsgDialog(FmtLoadStr(Ident, Args), mtError, [mbOK], 0);
end;

function ShowModalDialog(FormClass: TFormClass): TModalResult;
begin
  ShowHourGlass;
  with FormClass.Create(Application) do
    try
      Result := ShowModal;
    finally
      Free;
    end;
end;

function InitBitmap(ABitmap: TBitmap; AWidth, AHeight: Integer;
  Color: TColor): TBitmap;
begin
  { initializes a bitmap with width, height and background colour }
  with ABitmap do
  begin
    Width := AWidth;
    Height := AHeight;
    Canvas.Brush.Color := Color;
    Canvas.FillRect(Rect(0, 0, Width, Height));
  end;
  Result := ABitmap;
end;

procedure ShrinkIcon(H: HIcon; Glyph: TBitmap; BGColor: TColor);
const
  DarkStretch: array[Boolean] of Integer =
    (STRETCH_DELETESCANS, STRETCH_ANDSCANS);
var
  bmp: TBitmap;
  a, i, j: Integer;
  src, dest: HDC;
  OldStretch: Integer;
  r, g, b: array [1..4] of Byte;
  p: array[1..4] of TColorRef;
  rdest, gdest, bdest: Byte;
  pdest: TColorRef;
begin
  bmp := InitBitmap(TBitmap.Create, 32, 32, BGColor);
  DrawIcon(bmp.Canvas.Handle, 0, 0, H);
  try
    with Glyph do
    begin
      Width := 16;
      Height := 16;
      src := bmp.Canvas.Handle;
      dest := Canvas.Handle;
      if HQIconStretch then
      begin
        { Routine using averaging/mixing algorithm, producing high
          quality 16x16 icons -- use only with 256 or more colors }
        for i := 0 to 15 do
          for j := 0 to 15 do
          begin
            p[1] := GetPixel(src, i shl 1, j shl 1);
            p[2] := GetPixel(src, (i shl 1) + 1, j shl 1);
            p[3] := GetPixel(src, i shl 1, (j shl 1) + 1);
            p[4] := GetPixel(src, (i shl 1) + 1, (j shl 1) + 1);
            for a := 1 to 4 do
            begin
              r[a] := p[a] and $000000FF;
              g[a] := (p[a] and $0000FF00) shr 8;
              b[a] := (p[a] and $00FF0000) shr 16;
            end;
            rdest := (r[1] + r[2] + r[3] + r[4]) div 4;
            gdest := (g[1] + g[2] + g[3] + g[4]) div 4;
            bdest := (b[1] + b[2] + b[3] + b[4]) div 4;
            pdest := RGB(rdest, gdest, bdest);
            SetPixel(dest, i, j, pdest);
          end;
      end
      else
      begin
        { Routine using Window's own StretchBlt function, which
          gives rather poor results, IMHO... }
        OldStretch := SetStretchBltMode(dest, DarkStretch[DarkIconStretch]);
        StretchBlt(dest, 0, 0, 16, 16, src, 0, 0, 32, 32, SRCCOPY);
        SetStretchBltMode(dest, OldStretch);
      end;
    end;
  finally
    bmp.Free;
  end;
end;

var
  XorBmp, MaskBMP: TBitmap;

procedure ShadeIcon(ACanvas: TCanvas; AIcon: TIcon; X, Y: Integer;
  AColor: TColor);
begin
  if IconMesh = nil then
  begin
    IconMesh := TBrush.Create;
    IconMesh.Bitmap := CreateBrushPattern(clWhite, AColor);
  end;
  if XorBmp = nil then
  begin
    XorBmp := TBitmap.Create;
    InitBitmap(XorBmp, 32, 32, clBlack);
    MaskBmp := TBitmap.Create;
    InitBitmap(MaskBmp, 32, 32, clWhite);
  end;
  with XorBmp.Canvas do
  begin
    WinProcs.FillRect(Handle, Rect(0, 0, 32, 32), Brush.Handle);
    DrawIcon(Handle, 0, 0, AIcon.Handle);
  end;
  with MaskBmp.Canvas do
  begin
    WinProcs.FillRect(Handle, Rect(0, 0, 32, 32), Brush.Handle);
    { create a mask by drawing the icon twice, the second time
      using the SRCINVERT flag }
    DrawIcon(Handle, 0, 0, AIcon.Handle);
    BitBlt(Handle, 0, 0, 32, 32, XorBmp.Canvas.Handle, 0, 0, SRCINVERT);
    { draw the mesh over the mask using AND, leaving a neat mesh
      in the form of the mask }
    SelectObject(Handle, IconMesh.Handle);
    PatBlt(Handle, 0, 0, 32, 32, $FA0089);
    { finally draw the mask over the original icon using AND }
    BitBlt(ACanvas.Handle, X, Y, 32, 32, Handle, 0, 0, SRCAND);
  end;
end;

procedure ReplaceBitmapColors(bitmap: TBitmap; source, dest: TColor);
var
  i, j: Integer;
begin
  if source <> dest then
    with bitmap do
      for i := 0 to Width - 1 do
        for j := 0 to Height - 1 do
          if Canvas.Pixels[i, j] = source then Canvas.Pixels[i, j] := dest;
end;

function CreateBrushPattern(const bgColor, fgColor: TColor): TBitmap;
var
  X, Y: Integer;
begin
  Result := TBitmap.Create;
  Result.Width := 8;
  Result.Height := 8;
  with Result.Canvas do
  begin
    Brush.Color := bgColor;
    FillRect(Rect(0, 0, Result.Width, Result.Height));
    for Y := 0 to 7 do
      for X := 0 to 7 do
        if (Y mod 2) = (X mod 2) then  { toggles between even/odd pixles }
          Pixels[X, Y] := fgColor;     { on even/odd rows }
  end;
end;

function MinimizeString(const s: string; Canvas: TCanvas;
  target: Integer): string;
var
  bmp: TBitmap;
begin
  { 3.12 -- Bugfix:
    A seperate canvas is created, because in rare occasions, calling
    TextWidth on a visible canvas, will hang the system. }
  Result := s;
  bmp := TBitmap.Create;
  with bmp.Canvas do
  try
    Font.Assign(Canvas.Font);
    if (TextWidth(Result) <= target) then Exit;
    Dec(target, TextWidth('...'));
    { To avoid calling Canvas.TextWidth too many times, the string
      is cut in half if the width is over twice the desired target. }
    while (TextWidth(Result) > target * 2) and (Ord(Result[0]) > 1) do
      Dec(Result[0], Ord(Result[0]) div 2);
    while (TextWidth(Result) > target) and (Ord(Result[0]) > 0) do
      Dec(Result[0]);
    if Ord(Result[0]) > 0 then AppendStr(Result, '...');
  finally
    Free;
  end;
end;

procedure Sleep(MSec: Longint);
var
  Present, Future: Longint;
  Msg: TMsg;
begin
  Present := GetTimerCount;
  Future := Present + MSec;
  if Application = nil then
  repeat
    if PeekMessage(Msg, 0, 0, 0, PM_REMOVE) then
    begin
      TranslateMessage(Msg);
      DispatchMessage(Msg);
    end;
  until GetTimerCount >= Future
  else
  repeat
    Application.ProcessMessages;
  until GetTimerCount >= Future;
end;

procedure Delay(MSec: Longint);
var
  Present, Future: Longint;
begin
  Present := GetTimerCount;
  Future := Present + MSec;
  repeat
    {do nothing}
  until GetTimerCount >= Future;
end;

function GetTimerCount: Longint;
var
  TI: TTimerInfo;
begin
  TI.dwSize := SizeOf(TI);
  TimerCount(@TI);
  Result := TI.dwmsThisVM;
end;

procedure WaitTick;
var
  Tick: Longint;
begin
  Tick := GetTickCount;
  while Tick = GetTickCount do {nothing};
end;

procedure CopyStringsToClipboard(strings: TStrings);
var
  P: PChar;
begin
  P := strings.GetText;
  Clipboard.SetTextBuf(P);
  StrDispose(P);
end;

function ShortTimeToStr(Time: TDateTime): string;
begin
  DateTimeToString(Result, ShortTimeFormat, Time);
end;

type
  TSurfaceWin = class(TWinControl);

procedure FreePageHandles(Notebook: TNotebook);
begin
  with Notebook do
  begin
    LockWindowUpdate(Handle);
    try
      TSurfaceWin(Pages.Objects[PageIndex]).DestroyHandle;
    finally
      LockWindowUpdate(0);
    end;
  end;
end;

function GetMinPosition(Wnd: HWND): TPoint;
var
  place: TWindowPlacement;
begin
  { Returns minimized icon coordinates.  Those which haven't been minimized
    before can have -1 values, in which case Windows picks a suitable
    position when required }
  place.Length := sizeof(place);
  GetWindowPlacement(Wnd, @place);
  Result := place.ptMinPosition;
end;

procedure MoveDesktopIcon(Wnd: HWND; pt: TPoint);
var
  place: TWindowPlacement;
begin
  { Repositions a window's icon.  If the window is minimized,
    it must be hidden before being moved to ensure that the
    desktop background is updated }
  place.Length := sizeof(place);
  GetWindowPlacement(Wnd, @place);
  with place.ptMinPosition do
    if (x = pt.x) and (y = pt.y) then Exit;
  place.ptMinPosition := pt;
  place.Flags := place.Flags or WPF_SETMINPOSITION;
  if IsIconic(Wnd) then
  begin
    ShowWindow(Wnd, SW_HIDE);
    place.ShowCmd := SW_SHOWMINNOACTIVE;
  end
  else place.ShowCmd := SW_SHOWNA;
  SetWindowPlacement(Wnd, @place);
end;

procedure GetHeaderDivisions(H: THeader; A: array of PInteger);
var
  i, w: Integer;
begin
  with H do
  begin
    i := 0;
    w := 0;
    while (i <= High(A)) and (i < Sections.Count) do
    begin
      Inc(w, SectionWidth[i]);
      if A[i] <> nil then A[i]^ := w;
      Inc(i);
    end;
  end;
end;

procedure EnableControlList(C: array of TControl; Enable: Boolean);
var
  i: Integer;
begin
  for i := 0 to High(C) do C[i].Enabled := Enable;
end;

procedure Beep;
begin
  MessageBeep(0);
end;

procedure FreeAndNil(var Obj);
var
  P: TObject;
begin
  P := TObject(Obj);
  TObject(Obj) := nil;
  P.Free;
end;

function HeightOf(const r: TRect): Integer;
begin
  Result := r.Bottom - r.Top;
end;

function WidthOf(const r: TRect): Integer;
begin
  Result := r.Right - r.Left;
end;

function Trim(const s: string): string;
var
  i, l: Integer;
begin
  l := Length(s);
  i := 1;
  while (i <= l) and (s[i] <= ' ') do Inc(i);
  if i > l then Result := '' else
  begin
    while s[l] <= ' ' do Dec(l);
    Result := Copy(s, i, l - i + 1);
  end;
end;

function TrimLeft(const s: string): string;
var
  i: Integer;
begin
  i := 1;
  while (i <= Length(s)) and (s[i] <= ' ') do Inc(i);
  Result := Copy(s, i, 255);
end;

function TrimRight(const s: string): string;
var
  i: Integer;
begin
  i := Length(s);
  while (i > 0) and (s[i] <= ' ') do Dec(i);
  Result := Copy(s, 1, i);
end;

function GetCurrentDir: TFilename;
begin
  GetDir(0, Result);
end;

{$I-}
function SetCurrentDir(const Dir: TFilename): Boolean;
begin
  ChDir(Dir);
  Result := IOResult = 0;
end;

function CreateDir(const Dir: TFilename): Boolean;
begin
  MkDir(Dir);
  Result := IOResult = 0;
end;

function RemoveDir(const Dir: TFilename): Boolean;
begin
  RmDir(Dir);
  Result := IOResult = 0;
end;
{$I+}

procedure DoneMiscUtil; far;
begin
  IconMesh.Free;
  MaskBmp.Free;
  XorBmp.Free;
end;

initialization
  AddExitProc(DoneMiscUtil);
end.
