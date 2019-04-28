{**************************************************************************}
{                                                                          }
{    Calmira II shell for Microsoft® Windows(TM) 3.1                       }
{    Online! Release 3.3                                                  }
{    Copyright (C) 1998-2002 Calmira Online!                               }
{    Copyright (C) 1997-1998 Li-Hsin Huang                                 }
{                                                                          }
{    This program is free software; you can redistribute it and/or modify  }
{    it under the terms of the GNU General Public License as published by  }
{    the Free Software Foundation; either version 2 of the License, or     }
{    (at your option) any later version.                                   }
{                                                                          }
{    This program is distributed in the hope that it will be useful,       }
{    but WITHOUT ANY WARRANTY; without even the implied warranty of        }
{    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the         }
{    GNU General Public License for more details.                          }
{                                                                          }
{    You should have received a copy of the GNU General Public License     }
{    along with this program; if not, write to the Free Software           }
{    Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.             }
{                                                                          }
{**************************************************************************}

unit Start;

{ Start Menu

  TStartMenu is a popup menu that is owner-drawn, so that it has a 3D
  effect and small icons.  The small icons are stored in one large bitmap
  to conserve memory.  They are ordered in tree-traversal order, so when
  the start menu next loads, all the small icons are in the right places.

  TStartMenuItem is the class of menu item that is used for the start
  menu.  It has a Data property which holds a string containing
  encoded information about the item.  This data can be expanded with
  the ExtractStartInfo function. }

interface

uses Classes, SysUtils, Menus, Outline, Messages, WinTypes, Graphics, Forms;

type
  TStartFlags = (sfTop, sfBottom, sfSeparator, sfLarge,
    sfNoRightEdge, sfNoLeftEdge);

  TStartMenuItem = class(TMenuItem)
  private
    FData: PString;
    FHeight: Integer;
    TextLeft: Integer;
    function GetData: string;
    procedure SetData(const Value: string);
  public
    Flags: set of TStartFlags;
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure Click; override;
    procedure LoadGraphic; virtual; abstract;
    function GetWidth: Integer; virtual; abstract;
    procedure Paint(Canvas: TCanvas; Rect: TRect; State: Word);
    procedure PaintIcon(Canvas: TCanvas; const Rect: TRect; State: Word); virtual; abstract;
    property Data: string read GetData write SetData;
    property Height: Integer read FHeight write FHeight;
  end;

  TLargeMenuItem = class(TStartMenuItem)
  private
    FIcon: TIcon;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure LoadGraphic; override;
    function GetWidth: Integer; override;
    procedure PaintIcon(Canvas: TCanvas; const Rect: TRect; State: Word); override;
  end;

  TSmallMenuItem = class(TStartMenuItem)
  private
    FImgOffset: Word;
  public
    constructor Create(AOwner: TComponent); override;
    procedure LoadGraphic; override;
    function GetWidth: Integer; override;
    procedure PaintIcon(Canvas: TCanvas; const Rect: TRect; State: Word); override;
    property ImgOffset: Word read FImgOffset;
  end;

  TStartMenuItemClass = class of TStartMenuItem;

  TStartMacroEvent = procedure(Sender: TObject;
    const macro: string; params: string) of object;

  TMenuItemKind = (miSubMenu, miLeafNode, miAll);

  TStartMenu = class(TPopupMenu)
  private
    Canvas: TCanvas;
    Window: HWND;
    FOnStartMacro: TStartMacroEvent;
    procedure WndProc(var Message: TMessage);
    procedure SetOwnerDraw(menu: TMenuItem);
    function GetHeight: Integer;
    procedure HandleClick(Sender: TObject);
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure Configure;
    procedure Popup(X, Y: Integer; TrackLeft: Boolean);
    procedure Clear;
    function Find(const cap: string; Kind: TMenuItemKind): TMenuItem;
    procedure Load;
    procedure RunStartup;
    procedure RebuildFromOutline(Outline: TOutline);
    procedure AssignToOutline(Outline: TOutline);
    procedure PopupMenuItem(h: HMenu; X, Y: Integer; TrackLeft: Boolean);
    property OnStartMacro: TStartMacroEvent read FOnStartMacro write FOnStartMacro;
    property Height: Integer read GetHeight;
    property Helper: HWND read Window;
  end;

  TStartImages = class(TBitmap)
  private
    FNext: Integer;
  public
    function Add(bmp: TBitmap): Integer;
    function AddFrom(imgs: TStartImages; i: Integer): Integer;
    property Next: Integer read FNext write FNext;
  end;

  { TStartInfo is only slightly larger than a 255 char string, so
    placing it on the stack is OK, provided that there is no recursion  }
  TStartInfo = record
    Command: TFilename;
    Directory: TFilename;
    ShowMode: Integer;
    IconFile: TFilename;
    IconIndex: Integer;
  end;

function ExtractStartInfo(const s: string): TStartInfo;
function PackStartInfo(const command, directory, iconfile: TFilename;
  showmode, iconindex: Integer): string;

const
  IconTable: array[0..16] of string[15] =
    ('<none>', '<programs>', '<folder>', '<find>',
     '<run>', '<explorer>', '<shutdown>', '<settings>',
     '<help>', '<documents>', '<favorites>', '<internet>',
     '<system>', '<bin>', '<desktop>', '<taskbar>', '<control>');

  { Icon names that are not likely to be used in large menu items,
    point to an empty icon. }
  IconToRes: array[0..16] of string[15] =
    ('Empty', 'Programs', 'Folder', 'Find',
     'Run', 'Explorer', 'ShutDown', 'Settings',
     'Help', 'Documents', 'Favorites', 'Internet',
     'Computer', 'EmptyBin', 'Empty', 'Empty', 'Empty');

  IconToOffset: array[0..16] of Integer =
    (0, 16, 32, 48, 64, 80, 96, 112,
     128, 144, 160, 176, 192, 208, 224,
     240, 256);

const
  YieldDuringLoad: Boolean = False;

var
  StartMenu: TStartMenu;

implementation

uses Strings, IniFiles, Desk, Files, Directry, Dialogs, FileMan, Environs,
  Controls, MiscUtil, WinProcs, CompSys, Referenc, Settings, Resource,
  Streamer, Hooks, Internet, ShutDown;

{ TStartMenu and its items need to share some graphics objects, so they
  are global rather than parameters }

var
  Images: TStartImages;
  PrevImages: TStartImages; { 2.2 }
  PrevIndexList: TStringList; { 2.2 }
  CurrentIndexList: TStringList; { 2.2 }
  TempIcon: TIcon;
  SmallBmp: TBitmap;
  UsingCache: Boolean;
  Reloading: Boolean;
  FillMenu: Boolean;
  SmallItemHeight: Integer;
  MenuFontHeight: Integer;
  Banner: TResBitmap;
  BannerWidth: Integer;

const
  HighlightSilver: array[Boolean] of TColor = (clSilver, clNavy);

function TStartImages.Add(bmp: TBitmap): Integer;
begin
  if FNext + 16 > Width then Width := Width + (64 * 16);
  Result := FNext;
  Canvas.Draw(FNext, 0, bmp);
  Inc(FNext, 16);
end;

{ 2.2 }
function TStartImages.AddFrom(imgs: TStartImages; i: Integer): Integer;
begin
  if FNext + 16 > Width then Width := Width + (64 * 16);
  Result := FNext;
  Canvas.CopyRect(Bounds(FNext, 0, 16, 16), imgs.Canvas, Bounds(i, 0, 16, 16));
  Inc(FNext, 16);
end;

{ 2.2 }
procedure SaveIndexToFile(const filename: TFilename; s: TStrings);
var
  i: Integer;
  stream: TStreamer;
begin
  stream := TStreamer.Create(filename, fmCreate);
  try
    stream.WriteInteger(s.Count);
    for i := 0 to s.Count - 1 do
    begin
      stream.WriteString(s[i]);
      stream.WriteInteger(Longint(s.Objects[i]));
    end;
  finally
    stream.Free;
  end;
end;

{ 2.2 }
procedure LoadIndexFromFile(const filename: TFilename; s: TStrings);
var
  count, i: Integer;
  stream: TStreamer;
begin
  if not FileExists(filename) then Exit;
  stream := TStreamer.Create(filename, fmOpenRead);
  try
    count := stream.ReadInteger;
    for i := 0 to Count-1 do
      s.AddObject(stream.ReadString, TObject(Longint(stream.ReadInteger)));
  finally
    stream.Free;
  end;
end;

{ TStartMenuItem }

constructor TStartMenuItem.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FData := NullStr;
end;

destructor TStartMenuItem.Destroy;
begin
  DisposeStr(FData);
  inherited Destroy;
end;

procedure TStartMenuItem.Click;
begin
  if not (sfSeparator in Flags) then
  begin
    PlaySound(Sounds.Values['MenuClick']); { 3.0 }
    inherited Click;
  end;
end;

function TStartMenuItem.GetData: string;
begin
  Result := FData^;
end;

procedure TStartMenuItem.SetData(const Value: string);
begin
  if FData^ <> Value then AssignStr(FData, Value);
end;

procedure TStartMenuItem.Paint(Canvas: TCanvas; Rect: TRect; State: Word);
const
  WhiteBlack: array[Boolean] of TColor = (clMenuText, clHighlightText);
  GreySilver: array[Boolean] of TColor = (clBtnShadow, clBtnFace);
var
  y: Integer;
  text: TFileName;
  Focus: TRect;
begin
  { grab the DC that Windows provides }
  with Canvas, Rect do
  begin
    if sfLarge in Flags then Inc(Rect.Left, BannerWidth);
    Focus := Rect;
    if not (sfLarge in Flags) then Inc(Focus.Left, 2);
    Dec(Focus.Right, 1);
    if sfSeparator in Flags then
      State := State and not ODS_SELECTED;
    Brush.Color := Colors[ccStartmenu];
    if FillMenu then FillRect(Rect);
    if ColouredBar then
    begin
      Brush.Color := HighlightSilver[State and ODS_SELECTED > 0];
      FillRect(Focus);
    end;
    { Draw top of menu item }
    if sfTop in Flags then begin { 3.0 }
      Pen.Color := clBtnHighlight;
      MoveTo(Left, Top);
      LineTo(Right, Top);
      Pen.Color := clBtnFace;
      MoveTo(Left - 1, Top - 1);
      LineTo(Right + 1, Top - 1);
    end;
    { draw bottom of menu item }
    if sfBottom in flags then
    begin { 3.0 }
      Pen.Color := clBtnShadow;
      MoveTo(Left, Bottom - 1);
      LineTo(Right + 1, Bottom - 1);
    end;
    { draw seperator }
    if sfSeparator in Flags then
    begin
      Pen.Color := clBtnShadow;
      y := (Top + Bottom) div 2;
      MoveTo(Left, y);
      LineTo(Right, y);
      Pen.Color := clBtnHighlight;
      MoveTo(Left, y + 1);
      LineTo(Right, y + 1);
    end;
    if not (sfLarge in Flags) then
    begin
      { draw the left side highlight }
      Pen.Color := clBtnHighlight;
      MoveTo(Left, Top);
      LineTo(Left, Bottom);
    end
    else
      Dec(Rect.Left, BannerWidth);
    { Draw the left side border }
    Pen.Color := GreySilver[not (sfNoLeftEdge in Flags)];
    MoveTo(Left - 1, Top - 1);  { 3.0 }
    LineTo(Left - 1, Bottom); { 3.0 }
    if not (sfNoRightEdge in Flags) then
    begin
      { draw the right side border }
      Pen.Color := clBlack;
      MoveTo(Right + 1, Top - 1);
      LineTo(Right + 1, Bottom + 1);
    end;
    { Draw the right side shadow }
    Pen.Color := clBtnShadow;
    MoveTo(Right, Top);
    LineTo(Right, Bottom);
    { Prepare font for output, and prepare pen for drawing the
      bottom of the menu item }
    if State and ODS_SELECTED > 0 then
    begin
      if BoldSelect then Font.Style := [fsBold];
      Font.Color := WhiteBlack[ColouredBar or not BoldSelect];
    end
    else
    begin
      if BoldSelect then Font.Style := [];
      Font.Color := clMenuText;
    end;
    { Draw the text }
    if not (sfSeparator in Flags) then
    begin
      text := Caption;
      if text[1] = '*' then System.Delete(text, 1, 2); { 3.0 }
      DrawText(Canvas.Handle, @text[1], Ord(text[0]),
        Bounds(Left + TextLeft, Top + (HeightOf(Rect) - MenuFontHeight) div 2, 1, 1),
        DT_LEFT or DT_NOCLIP);
    end;
    PaintIcon(Canvas, Rect, State);
  end;
end;

{ TLargeMenuItem }

constructor TLargeMenuItem.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FIcon := TIcon.Create;
  FHeight := LargeItemHeight; { 3.0 }
  TextLeft := BannerWidth + 48; { 3.0 }
  Flags := [sfLarge];
end;

destructor TLargeMenuItem.Destroy;
begin
  FIcon.Free;
  inherited Destroy;
end;

procedure TLargeMenuItem.LoadGraphic;
var
  Command, IconFile: TFilename;
  i, IconIndex: Integer;
begin
  Command := '';
  IconFile := '';
  IconIndex := 0;
  Unformat(Data, '%s;%S;%D;%s;%d', [@Command, 79, @IconFile, 79, @IconIndex]);
  if IconFile = '' then
  begin
    if Count > 0 then
    begin
      { default group icon }
      FIcon.Assign(Icons.Get('Programs'));
      Exit;
    end;
    if IsURL(Command) then
    begin
      { 3.1 -- Internet icon }
      FIcon.Assign(Icons.Get('Internet'));
      Exit;
    end;
  end;
  if (IconFile > '') and (IconFile[1] = '<') then
  begin
    { Find an auxiliary image }
    i := 0;
    while i <= High(IconTable) do
      if CompareText(IconFile, IconTable[i]) = 0 then
      begin
        FIcon.Assign(Icons.Get(IconToRes[i]));
        Exit;
      end
      else Inc(i);
  end;
  { Use a reference object to do the icon searching }
  FileRef.Target := Lowercase(command);
  FileRef.IconFile := IconFile;
  FileRef.IconIndex := IconIndex;
  FileRef.AssignIcon(FIcon);
end;

function TLargeMenuItem.GetWidth: Integer;
begin
  Result := Images.Canvas.TextWidth(Caption) + BannerWidth + 40; { 3.0 }
end;

procedure TLargeMenuItem.PaintIcon(Canvas: TCanvas; const Rect: TRect;
  State: Word);
var
  i, y, w, h, t: Integer;
begin
  if not (sfSeparator in Flags) then
    Canvas.Draw(Rect.Left + BannerWidth + 8,
      Rect.Top + ((LargeItemHeight - 32) div 2), FIcon); { 3.0 }
  y := Banner.Height;
  i := Parent.Count - 1;
  with Parent do
  begin
    while (i >= 0) and (Items[i] <> self) do
    begin
      Dec(y, TStartMenuItem(Items[i]).Height);
      Dec(i);
    end;
  end;
  t := Rect.Top;
  h := Height;
  w := BannerWidth;
  if sfTop in Flags then with Canvas do
  begin
    { finish top of banner }
    Inc(t);
    Dec(h);
    Pen.Color := clBtnHighlight;
    MoveTo(Rect.Left, Rect.Top);
    LineTo(Rect.Left + w, Rect.Top);
    Pen.Color := clBtnFace;
    MoveTo(Rect.Left, Rect.Top-1);
    LineTo(Rect.Left + w, Rect.Top-1);
  end;
  { draw banner }
  BitBlt(Canvas.Handle, Rect.Left, t, w, h,
    Banner.Canvas.Handle, 0, Max(y - Height, 0), SRCCOPY);
end;

{ TSmallMenuItem }

constructor TSmallMenuItem.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FHeight := SmallItemHeight;
  TextLeft := 28; { 3.0 }
end;

procedure TSmallMenuItem.LoadGraphic;
var
  Command, IconFile: TFilename;
  src, dest: THandle;
  i, IconIndex: Integer;

procedure RegisterInIndex; { 2.2 }
begin
  CurrentIndexList.AddObject(Format('%s;%s;%d', [Command, IconFile, IconIndex]),
    TObject(Longint(FImgOffset)));
end;

begin
  Command := '';
  IconFile := '';
  IconIndex := 0;
  Unformat(Data, '%s;%S;%D;%s;%d', [@Command, 79, @IconFile, 79, @IconIndex]);
  if IconFile = '' then
  begin
    if Count > 0 then
    begin
      { default group bitmap }
      FImgOffset := 16;
      Exit;
    end;
    if IsURL(Command) then
    begin
      { 3.1 -- Internet bitmap }
      FImgOffset := 176;
      Exit;
    end;
  end;
  if (IconFile > '') and (IconFile[1] = '<') then
  begin
    { Find an auxiliary image }
    i := 0;
    while i <= High(IconTable) do
      if CompareText(IconFile, IconTable[i]) = 0 then System.Break
      else Inc(i);
    FImgOffset := IconToOffset[i];
    Exit;
  end;
  if UsingCache then
  begin
    { When this function is called, Images.Next points to where the
      small icon image should be placed }
    FImgOffset := Images.Next;
    Images.Next := Images.Next + 16;
    RegisterInIndex; { 2.2 }
    Exit;
  end;
  if Reloading then begin { 2.2 }
    i := PrevIndexList.IndexOf(Format('%s;%s;%d', [Command, IconFile, IconIndex]));
    if i > -1 then
    begin
      FImgOffset := Images.AddFrom(PrevImages, Longint(PrevIndexList.Objects[i]));
      RegisterInIndex;
      Exit;
    end;
  end;
  if CompareText(ExtractFileExt(IconFile), '.bmp') = 0 then
    SmallBmp.LoadFromFile(EnvironSubst(IconFile))
  else
  begin
    { Use a reference object to do the icon searching }
    FileRef.Target := Lowercase(Command);
    FileRef.IconFile := IconFile;
    FileRef.IconIndex := IconIndex;
    FileRef.AssignIcon(TempIcon);
    ShrinkIcon(TempIcon.Handle, SmallBmp, Colors[ccStartmenu]);
  end;
  { Add the new 16 x 16 image to the list and remember where you put it }
  FImgOffset := Images.Add(SmallBmp);
  RegisterInIndex; { 2.2 }
end;

function TSmallMenuItem.GetWidth : Integer;
begin
  Result := Images.Canvas.TextWidth(Caption) + 24; { 3.0 }
end;

procedure TSmallMenuItem.PaintIcon(Canvas: TCanvas; const Rect: TRect;
  State: Word);
begin
  if not (sfSeparator in Flags) then
    if ColouredBar and (State and ODS_SELECTED > 0) then with Canvas do
    begin
      Pen.Color := Colors[ccStartmenu];
      with Rect do Rectangle(Left + 7, Top + 1, Left + 25, Top + 18);
      BitBlt(Canvas.Handle, Rect.Left + 8, Rect.Top + 2, 16, 16,
        Images.Canvas.Handle, ImgOffset, 0, SRCCOPY);
      FloodFill(Rect.Left + 7, Rect.Top + 1, ColorToRGB(Colors[ccStartmenu]),
        fsSurface);
    end
    else
      BitBlt(Canvas.Handle, Rect.Left + 8, Rect.Top + 2, 16, 16,
        Images.Canvas.Handle, ImgOffset, 0, SRCCOPY);
end;

{ TStartMenu }

constructor TStartMenu.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  Window := AllocateHWnd(WndProc);
  Canvas := TCanvas.Create;
  Canvas.Brush.Color := Colors[ccStartmenu];
  { A convenient place to create global objects! }
  Images := TStartImages.Create;
  TempIcon := TIcon.Create;
  SmallBmp := InitBitmap(TBitmap.Create, 16, 16, clSilver);
  Banner := TResBitmap.AlternateLoad('BANNER', 'banner.bmp');
  BannerWidth := Banner.Width;
  CurrentIndexList := TStringList.Create; { 2.2 }
  Configure;
end;

destructor TStartMenu.Destroy;
begin
  Canvas.Free;
  Images.Free;
  TempIcon.Free;
  SmallBmp.Free;
  Banner.Free;
  DeallocateHWnd(Window);
  { 2.2 }
  CurrentIndexList.Free;
  PrevIndexList.Free;
  PrevImages.Free;
  inherited Destroy;
end;

procedure TStartMenu.Configure;
const
  FontStyles: array[Boolean] of TFontStyles = ([], [fsBold]);
begin
  FillMenu := BoldSelect or ColouredBar or (ColorToRGB(clMenu) <>
    Colors[ccStartmenu]);
  ini.ReadFont('Start menu', Canvas.Font);
  HighLightSilver[False] := Colors[ccStartmenu];
  HighlightSilver[True] := Colors[ccStartHighlight];
  { When Windows sends WM_MEASUREITEM messages, the start menu has
    no valid canvas to measure the text widths.  So it utilises
    the canvas from a bitmap by setting it's font and, later,
    calling it's TextWidth method }
  with Images.Canvas.Font do
  begin
    Assign(Canvas.Font);
    Style := FontStyles[BoldSelect];
    MenuFontHeight := Abs(Height);
    SmallItemHeight := 20;
    if MenuFontHeight > 12 then inc(SmallItemHeight, MenuFontHeight - 10); { 3.0 }
  end;
  { When BoldSelect is on, menu items need to be wider to accomodate
    the font.  So when BoldSelect changes, the start menu must be
    "invalidated" so that Windows sends more WM_MEASUREITEM messages
    to find the new widths }
  if StartMenu3D then SetOwnerDraw(Items);
  SetWin95KeyEnabled(Win95Keyboard); { 2.2 }
end;

procedure TStartMenu.Clear;
begin
  with Items do while Count > 0 do Items[0].Free;
end;

procedure TStartMenu.SetOwnerDraw(menu: TMenuItem);
const
  Breaks: array[Boolean] of Word = (0, MF_MENUBREAK);
var
  i, NumSections, NumItems, FirstBreak, FinalBreak: Integer;
  item: TMenuItem;
  IsBreak: Boolean;
  s: string[79];
begin
  { Recurses through the menu tree, setting each item to owner-draw.
    With the 4th parameter of ModifyMenu, don't confuse the Handle
    with the Command }
  NumItems := menu.Count;
  s := menu.Caption;
  if (Length(s) >= 2) and (s[1] = '*') then
  begin
    NumSections := Max(Ord(s[2]) - Ord('0'), 2);
    FirstBreak := ((NumItems + 1) div NumSections);
    FinalBreak := ((NumItems + 1) div NumSections) * (NumSections - 1);
  end
  else
    NumSections := 1;
  for i := 0 to NumItems - 1 do
  begin
    item := menu.Items[i];
    IsBreak := (i > 0) and (NumSections > 1) and
      (i mod ((NumItems+1) div NumSections) = 0);
    if item.Count > 0 then
    begin
      ModifyMenu(menu.Handle, i, MF_BYPOSITION or MF_OWNERDRAW or MF_POPUP or
        Breaks[IsBreak], item.Handle, Pointer(item));
      SetOwnerDraw(item);
    end
    else
      ModifyMenu(menu.Handle, i, MF_BYPOSITION or MF_OWNERDRAW or
        Breaks[IsBreak], item.Command, Pointer(item));
    if IsBreak then
    begin
      Include(TStartMenuItem(item).Flags, sfTop);
      if i > 1 then Include(TStartMenuItem(menu.Items[i-1]).Flags, sfBottom);
    end;
    if (NumSections > 1) then
    begin
      if (i < FinalBreak) then
        Include(TStartMenuItem(item).Flags, sfNoRightEdge);
      if (i >= FirstBreak) then
        Include(TStartMenuItem(item).Flags, sfNoLeftEdge);
    end;
  end;
end;

procedure TStartMenu.Load;
var
  startini: TIniFile;

procedure AddToMenu(menu: TMenuItem; const section: string);
const
  LargeSmall: array[Boolean] of TStartMenuItemClass =
    (TSmallMenuItem, TLargeMenuItem);
var
  names: TStringList;
  item : TStartMenuItem;
  s: string;
  i: Integer;
begin
  { Reads an entire INI file section, turns each entry into
    a menu item, and adds the items to the menu parameter }
  names := TStringList.Create;
  menu.Caption := ExtractFilename(section);
  try
    startini.ReadSection(section, names);
    for i := 0 to names.Count - 1 do
    begin
      item := LargeSmall[LargeRootMenu and (menu = Items)].Create(self);
      s := names[i];
      item.Data := startini.ReadString(section, s, '');
      if s[Length(s)] = '*' then
      begin
        Dec(s[0]);
        AddToMenu(item, Format('%s\%s', [section, s]));
      end
      else item.OnClick := HandleClick;
      item.Caption := s;
      menu.Add(item);
      if YieldDuringLoad then Application.ProcessMessages;
    end;
  finally
    names.Free;
  end;
end;

procedure AssignBitmaps(menu: TMenuItem);
var
  item: TStartMenuItem;
  i: Integer;
begin
  { AssignBitmaps recursively travels the tree, calling PutBitmap
    for each menu item.  It also calculates the menu item's flags
    used when painting.  The Tag stores the item's height. }
  for i := 0 to menu.Count - 1 do
  begin
    item := TStartMenuItem(menu.Items[i]);
    with item do
    begin
      if i = 0 then Include(Flags, sfTop);
      if i = menu.Count - 1 then Include(Flags, sfBottom);
      if (Caption > '') and (Caption[1] = '-') then
      begin
        Include(Flags, sfSeparator);
        Height := SmallItemHeight div 2;
      end;
      LoadGraphic;
    end;
    if item.Count > 0 then AssignBitmaps(item);
    if YieldDuringLoad then Application.ProcessMessages;
  end;
end;

const
  BusyCursors: array[Boolean] of TCursor = (crHourGlass, crBusyPointer);

var
  Defaults: TResBitmap;
  CacheFile: TFilename;

begin {TStartMenu.Load}
  Clear;
  startini := TIniFile.Create(StartFile);
  Desktop.SetCursor(BusyCursors[YieldDuringLoad]);
  AddToMenu(Items, 'Start');
  CacheFile := FileWritePath + 'BMPCACHE.BMP';
  try
    if StartMenu3D then
    begin
      with Banner do
        if LargeRootMenu and Empty then Reload;
      { 3.11 -- load preset pictures now, because we need it's width }
      Defaults := TResBitmap.AlternateLoad('STARTBMPS', 'startdef.bmp');
      if FileExists(CacheFile) then
      begin
        UsingCache := True;
        Images.LoadFromFile(CacheFile);
      end
      else
      begin
        { copy preset pictures into cache bitmap }
        UsingCache := False;
        with Defaults do
          ReplaceBitmapColors(Defaults, Canvas.Pixels[0, Defaults.Height - 1],
            Colors[ccStartmenu]); { 3.1 }
        InitBitmap(Images, 64 * 16, 16, Colors[ccStartmenu]);
        Images.Canvas.Draw(0, 0, Defaults);
      end;
      { skip over preset pictures }
      Images.Next := Defaults.Width;
      Defaults.Free;
      AssignBitmaps(Items);
      SetOwnerDraw(Items);
      if not UsingCache then with Images do
      begin
        { chop off any empty space at the end before saving file }
        Width := Next;
        SaveToFile(CacheFile);
      end;
      { 4.0 }
      if not FileExists(FileWritePath + 'IMGINDEX.DAT') or Reloading  then
        SaveIndexToFile(FileWritePath + 'IMGINDEX.DAT', CurrentIndexList);
      CurrentIndexList.Clear;
    end
    else DeleteFile(CacheFile);
    if not (StartMenu3D and LargeRootMenu) then Banner.FreeImage;
  finally
    startini.Free;
    Desktop.ReleaseCursor;
  end;
end;

function TStartMenu.GetHeight: Integer;
var
  i: Integer;
begin
  Result := 2;
  if StartMenu3D then
    for i := 0 to Items.Count - 1 do
      Inc(Result, TStartMenuItem(Items[i]).Height)
  else
    Inc(Result, Items.Count * GetSystemMetrics(SM_CYMENU));
end;

procedure TStartMenu.RebuildFromOutline(Outline: TOutline);
var
  startini: TIniFile;
  section: string[127];
  i: Integer;
begin
  DeleteFile(StartFile);
  PrevIndexList := TStringList.Create;
  LoadIndexFromFile(FileWritePath + 'IMGINDEX.DAT', PrevIndexList);
  PrevImages := Images;
  Images := TStartImages.Create;
  Reloading := True;
  { This routine works on the outline from the Start Properties dialog.
    It assumes that each outline node has a dynamic string pointed to by
    the Data property }
  startini := TIniFile.Create(StartFile);
  try
    with Outline do
      for i := 1 to ItemCount do with Items[i] do
      begin
        if Level = 1 then section := 'Start'
        else section := 'Start\' + Parent.FullPath;
        if HasItems then
          startini.WriteString(section, Text + '*', PString(Data)^)
        else
          startini.WriteString(section, Text, PString(Data)^);
      end;
  finally
    startini.Free;
    Load;
    Reloading := False;
    FreeAndNil(PrevImages);
    FreeAndNil(PrevIndexList);
  end;
end;

procedure TStartMenu.AssignToOutline(Outline: TOutline);

procedure Translate(menu: TMenuItem; dest: Longint);
var
  item : TStartMenuItem;
  node: Longint;
  p: PString;
  i: Integer;
begin
  with menu do
    for i := 0 to Count - 1 do
    begin
      New(p);
      item := Items[i] as TStartMenuItem;
      p^ := item.Data;
      node := Outline.AddChildObject(dest, item.Caption, TObject(p));
      if item.Count > 0 then Translate(item, node);
    end;
end;

begin
  Translate(Items, 0);
end;

procedure TStartMenu.HandleClick(Sender: TObject);
var
  filename, params: TFilename;
begin
  with ExtractStartInfo((Sender as TStartMenuItem).Data) do
  begin
    filename := command;
    params := '';
    Unformat(command, '%s %s', [@filename, 79, @params, 79]);
    if (filename[1] = '$') and Assigned(FOnStartMacro) then
      FOnStartMacro(self, EnvironSubst(filename), EnvironSubst(params))
    else
    begin
      LastIconFile := iconfile;
      LastIconIndex := iconindex;
      LastInstance := DefaultExec(filename, params, directory,
        ShowCmdsEx(showmode));
    end;
  end;
end;

procedure TStartMenu.RunStartup;
var
  i: Integer;
  item: TMenuItem;
  snd: string[79];
begin
  item := Find(ini.ReadString('Start Menu', 'StartupGroup', 'Startup'),
    miSubMenu);
  if item <> nil then with item do
  begin
    { disable MenuClick sound }
    snd := Sounds.Values['MenuClick'];
    Sounds.Values['MenuClick'] := '<none>';
    for i := 0 to Count - 1 do Items[i].Click;
    Sounds.Values['MenuClick'] := snd;
  end;
end;

procedure TStartMenu.PopupMenuItem(h: HMenu; X, Y: Integer; TrackLeft: Boolean);
const
  Flags: array[TPopupAlignment] of Word = (TPM_LEFTALIGN, TPM_RIGHTALIGN,
    TPM_CENTERALIGN);
  Tracks: array[Boolean] of Word = (TPM_RIGHTBUTTON, TPM_LEFTBUTTON);
var
  SaveFocus: HWnd;
begin
  if YieldDuringLoad then Exit;
  SaveFocus := GetFocus;
  SetFocus(Window);
  TrackPopupMenu(h, Flags[Alignment] or Tracks[TrackLeft], X, Y,
    0, Window, nil);
  if IsWindow(SaveFocus) and IsWindowVisible(SaveFocus) then
    WinProcs.SetFocus(SaveFocus);
end;

procedure TStartMenu.Popup(X, Y: Integer; TrackLeft: Boolean);
begin
  PopupMenuItem(Items.Handle, X, Y, TrackLeft);
end;

procedure TStartMenu.WndProc(var Message: TMessage);
var
  m: TMenuItem;
  i: Integer;
begin
  try
    case Message.Msg of
      WM_DRAWITEM:
        with TDRAWITEMSTRUCT(Pointer(Message.lParam)^) do
        begin
          Canvas.Handle := hDC;
          TStartMenuItem(itemData).Paint(Canvas, rcItem, itemState);
          Canvas.Handle := 0;
        end;
      WM_MEASUREITEM:
        with TMEASUREITEMSTRUCT(Pointer(Message.lParam)^) do
        begin
          itemHeight := TStartMenuItem(itemData).Height;
          itemWidth := TStartMenuItem(itemData).GetWidth;
        end;
      WM_COMMAND:
        DispatchCommand(Message.wParam);
      WM_MENUCHAR:
        begin
          if Items.Handle = HiWord(Message.lParam) then m := Items
          else m := FindItem(HiWord(Message.lParam), fkHandle);
          if m <> nil then
            for i := 0 to m.Count - 1 do
              if IsAccel(Message.wParam, TStartMenuItem(m[i]).Caption) then
              begin
                Message.Result := MakeLong(i, 2);
                Exit;
              end;
          Message.Result := 0;
          Exit;
        end;
      WM_CLOSE: { 3.1 }
        begin
          Message.Result := 0;
          ShowModalDialog(TQuitDlg);
          Exit;
        end;
    end;
    with Message do Result := DefWindowProc(Window, Msg, wParam, lParam);
  except
    Application.HandleException(Self);
  end;
end;

function ExtractStartInfo(const s: string): TStartInfo;
begin
  FillChar(Result, SizeOf(Result), 0);
  if Unformat(s, '%s;%s;%d;%s;%d', [@Result.command, 79, @Result.directory, 79,
    @Result.showmode, @Result.iconfile, 79, @Result.iconindex]) = 1 then
      Result.command := '';
end;

function PackStartInfo(const command, directory, iconfile: TFilename;
  showmode, iconindex: Integer): string;
begin
  Result := Format('%s;%.79s;%d;%.79s;%d',
    [command, directory, showmode, iconfile, iconindex]);
end;

function TStartMenu.Find(const cap: string; Kind: TMenuItemKind): TMenuItem;

function FindCap(node: TMenuItem): TMenuItem;
var
  i: Integer;
  item: TMenuItem;
begin
  Result := nil;
  for i := 0 to node.Count - 1 do
  begin
    item := node.Items[i];
    if ((Kind = miAll) or ((item.Count = 0) = (Kind = miLeafNode)))
      and (CompareText(item.Caption, cap) = 0) then
        Result := item
    else if item.Count > 0 then Result := FindCap(item);
    if Result <> nil then Exit;
  end;
end;

begin { TStartMenu.Find }
  Result := FindCap(items);
end;

end.

