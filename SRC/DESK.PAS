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

unit Desk;

{ TDesktop

  TDesktop manages forms on the screen, and is an extension to Delphi's
  TScreen component.

  Changes: 3.11 -- removed WindowMenu.

  Fields

  FormList - temporary list to hold forms during processing
  WindowList - always contains a list of open icon windows
  RefreshList - a list of folders that have had their contents
    changed and need refreshing once an operation has finished
  CursorStack - holds the previous TCursor values

  Methods

  Load - Loads the desktop from the INI file
  Save - Saves the desktop to the INI file
  Refresh - refreshes the given folder if it is on screen
  RefreshNow - refreshes all windows in refresh list, then clears the list
  WindowOf - returns the icon window displaying the given folder,
    or nil if no such window exists
  OpenFolder - opens an icon window of the given folder, or brings
    an existing window to the front
  CloseSubWindows - closes all windows which show the given directory
    and all its subdirectories
  CloseLowerWindows - closes all windows which show subdirectories
    of the given directory
  ClosePathWindows - closes all windows showing parent directories
    of the given directory
  CloseOtherWindows - closes all windows except the one passed as parameter
  Cascade - cascades icon windows from the top left
  CloseWindows - closes all icon windows
  MinimizeWindows - minimizes all icon windows
  ArrangeIcons - mimics "Arrange Icons" from the Windows Task Manager
    except that shortcuts etc. are not moved.
  ArrangeShortcuts - Arranges Calmira's icons and shortcuts from the
    topleft to downright
  SnapToGrid - repositions icons so that they line up with an
    invisible grid
  RenameWindows - calls the FolderRenamed method for each icon window
  AddWindow - adds an entry to the window list and a new menu item
  RemoveWindow - reverses effects of AddWindow
  EnableForms - changes the Enabled property of all forms on screen
    except those needed to interact with the user during a file
    operation.  Simulates modal file operations.
  Revert - reloads the minimized positions of extended forms (TExtForm).
  NextForm - brings the bottom form to the front, typically when the
    user presses Ctrl-Tab
  SetCursor - saves the current cursor to the cursor stack and
    changes the screen's cursor.
  ReleaseCursor - Restores the previously displayed screen cursor
  Repaint - Repaints the entire desktop }

interface

uses Classes, IconWin, SysUtils, Graphics, Forms, WinTypes, Menus, Controls;

type
  TDesktop = class(TComponent)
  private
    FormList: TList;
    CursorStack: TList;
    WindowList: TStringList;
    function Each(FormClass: TFormClass): TList;
  public
    RefreshList: TStringList;
    CascadeDelta: Integer; { 2.2 made public }
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure Load;
    procedure Save;
    procedure Refresh(const foldername: TFilename);
    procedure RefreshNow;
    procedure UpdateFileWindow(const filename: TFilename);
    function WindowOf(const foldername: TFilename): TIconWindow;
    procedure OpenFolder(foldername: TFilename);
    procedure OpenFolderRefresh(const foldername: TFilename);
    procedure CloseSubWindows(const foldername: TFilename);
    procedure CloseLowerWindows(const foldername: TFilename);
    procedure ClosePathWindows(const foldername: TFilename);
    procedure CloseOtherWindows(Sender: TIconWindow);
    procedure Cascade;
    procedure CloseWindows;
    procedure MinimizeWindows; { 3.1 }
    procedure ArrangeIcons;
    procedure ArrangeShortcuts; { 3.1 }
    procedure SnapToGrid;
    procedure RenameWindows(const previous, current: TFilename);
    procedure AddWindow(Win: TIconWindow);
    procedure RemoveWindow(Win: TIconWindow);
    procedure EnableForms(Enable: Boolean);
    procedure Revert;
    procedure NextForm;
    procedure SetCursor(Cursor: TCursor);
    procedure ReleaseCursor;
    procedure ReleaseShortcuts;
    procedure CascadeList(wnds: TList);  { 2.2 }
    procedure TileVertList(wnds: TList); { 2.2 }
    procedure TileHorizList(wnds: TList); { 2.2 }
    procedure Repaint; { 3.1 moved from Compsys.pas }
  end;

var
  Desktop : TDesktop;

implementation

uses Directry, WinProcs, Shorts, WasteBin, CompSys, Settings, Resource,
  Strings, Locale, FileFind, Files, MiscUtil, Drives, Tree, Progress,
  Replace, CalForm, Start, ExtForm, FileMan, Dialogs, Task;

constructor TDesktop.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FormList := TList.Create;
  CursorStack := TList.Create;
  RefreshList := TUniqueStrings.Create;
  WindowList := TUniqueStrings.Create;
  CascadeDelta := GetSystemMetrics(SM_CXFRAME) + GetSystemMetrics(SM_CXSIZE);
end;

destructor TDesktop.Destroy;
var
  i: Integer;
begin
  FormList.Free;
  CursorStack.Free;
  RefreshList.Free;
  with WindowList do
    for i := 0 to Count - 1 do Objects[i].Free;
  WindowList.Free;
  ArrangeIconicWindows(GetDesktopWindow);
  inherited Destroy;
end;

{ The Each method is useful for finding all the forms of a particular
  type.  It copies them to FormList and returns this list -- this is
  important because we can't reliably close forms while iterating
  through the Screen.Forms property, even when going backwards }

function TDesktop.Each(FormClass: TFormClass): TList;
var
  i: Integer;
begin
  FormList.Clear;
  with Screen do
    for i := 0 to FormCount - 1 do
      if Forms[i] is FormClass then FormList.Add(Forms[i]);
  Result := FormList;
end;

{ OpenFolder encapsulates the process of displaying a new icon window.
  If the window already exists, it is brought forward.  When the user
  chooses to use a single window for all browsing, then any existing
  window is forced to change its directory path.

  While it might seem useful to return the window object, TIconWindow
  could raise an exception and destroy itself if an invalid path is
  specified AND discard the exception, leaving the caller with an
  invalid pointer.  So it is safer to not return anything. }

procedure TDesktop.OpenFolder(foldername: TFilename);
var
  IconWindow: TIconWindow;
  cur: TFilename;
  i: Integer;
begin
  foldername := Lowercase(Trim(foldername));
  IconWindow := WindowOf(foldername);
  if IconWindow = nil then
  begin
    { 3.12 -- changed VK_MENU to VK_CONTROL }
    if BrowseSame xor (GetAsyncKeyState(VK_CONTROL) < 0) then
      with Screen do
        for i := 0 to FormCount - 1 do
          if (Forms[i] is TIconWindow) and not
            (TIconWindow(Forms[i]).Owner = Explorer) { 3.1 } then
              with TIconWindow(Forms[i]) do
              begin
                ChangeDir(foldername);
                SetFocus;
                Exit;
              end;
    if HDirectoryExists(foldername) then
      TIconWindow.Init(Application, foldername, DefaultFilter).Show
    else ErrorMsgResFmt(SCannotOpenFolder, [foldername]);
  end
  else IconWindow.ShowNormal;
end;

procedure TDesktop.OpenFolderRefresh(const foldername: TFilename);
var
  w: TIconWindow;
begin
  w := Desktop.WindowOf(foldername);
  if w <> nil then with w do
  begin
    RefreshWin;
    ShowNormal;
    Exit;
  end;
  Desktop.OpenFolder(foldername)
end;

function TDesktop.WindowOf(const foldername: TFilename): TIconWindow;
var
  i: Integer;
begin
  i := WindowList.IndexOf(foldername);
  if i <> -1 then Result := TIconWindow(WindowList.Objects[i])
  else Result := nil;
end;

{ A "subwindow" is thought of like a "subset", i.e., the window itself
  or any windows showing subdirectories }

procedure TDesktop.CloseSubWindows(const foldername: TFilename);
var
  f: TIconWindow;
begin
  f := WindowOf(foldername);
  if f <> nil then f.Close;
  CloseLowerWindows(foldername);
end;

procedure TDesktop.CloseLowerWindows(const foldername: TFilename);
var
  i: Integer;
begin
  with Each(TIconWindow) do
    for i := 0 to Count - 1 do
      if IsAncestorDir(foldername, TIconWindow(Items[i]).Dir.Fullname) then
        TIconWindow(Items[i]).Close;
end;

procedure TDesktop.ClosePathWindows(const foldername: TFilename);
var
  i: Integer;
begin
  with Each(TIconWindow) do
    for i := 0 to Count - 1 do
      if IsAncestorDir(TIconWindow(Items[i]).Dir.Fullname, foldername) then
        TIconWindow(Items[i]).Close;
end;

procedure TDesktop.Refresh(const foldername: TFilename);
var
  f: TIconWindow;
begin
  f := WindowOf(Foldername);
  if f <> nil then f.RefreshWin;
end;

{ TScreen is organised such that the topmost form has the lowest index.
  To cascade using the current Z-order, the loop must go backwards to
  prevent exposing windows underneath (they take a long time to redraw).
  Try a forward loop and see! }

procedure TDesktop.Cascade;
var
  i, tl: Integer;
  size: TPoint;
begin
  tl := 0;
  with Each(TIconWindow) do
    for i := Count - 1 downto 0 do
      with TIconWindow(Items[i]) do
      begin
        size := CalcSize(5, 4);
        if WindowState <> wsMinimized then
        begin
          SetBounds(tl, tl, size.x, size.y);
          Inc(tl, CascadeDelta);
          if tl + size.x > Screen.Width then tl := 0;
        end;
      end;
end;

procedure TDesktop.CloseWindows;
var
  i: Integer;
begin
  with Each(TIconWindow) do
    for i := 0 to Count - 1 do TIconWindow(Items[i]).Close;
end;

procedure TDesktop.MinimizeWindows;
var
  i: Integer;
begin
  with Each(TIconWindow) do
    for i := 0 to Count - 1 do TIconWindow(Items[i]).WindowState := wsMinimized;
end;

procedure TDesktop.CloseOtherWindows(Sender: TIconWindow);
var
  i: Integer;
begin
  with Each(TIconWindow) do
    for i := 0 to Count - 1 do
      if Items[i] <> Sender then TIconWindow(Items[i]).Close;
end;

function EnumMinWindows(Wnd: HWnd; List: TList): Bool; export;
begin
  if IsWindowVisible(Wnd) and (GetWindowLong(Wnd, GWL_STYLE) and
    WS_MINIMIZEBOX > 0) then List.Add(Pointer(Wnd));
  Result := True;
end;

{ Firstly, this procedure calculates the dimensions of the icon grid, and
  where to put the bottom row (depending on whether the taskbar is showing).
  For each window, it checks that it doesn't belong to a fixed object.
  Then it slots the icon into the right place, and calculates the position
  of the next icon.

  Icons with a Y coordinate of Screen.Height are usually the ones hidden by
  the taskbar, so they are left alone.  (-1, -1) tells Windows to find
  a position when the form is next minimized }

procedure TDesktop.ArrangeIcons;
var
  Wnd: HWND;
  List: TList;
  NextPos: TPoint;
  XSpacing, YSpacing, FarLeft, i: Integer;
  Control: TWinControl;
begin
  XSpacing := GetSystemMetrics(SM_CXICONSPACING);
  YSpacing := GetSystemMetrics(SM_CYICONSPACING);
  FarLeft := (XSpacing - 32) div 2;
  NextPos.X := FarLeft;
  NextPos.Y := Screen.Height - (32 + MinAppHeight);
  List := TList.Create;
  try
    EnumWindows(@EnumMinWindows, Longint(list));
    for i := 0 to List.Count - 1 do
    begin
      Wnd := Longint(List[i]);
      control := FindControl(Wnd);
      if (Control = Computer) or (Control = Bin) or (Control is TShort) or
        not IsWindowVisible(Wnd) { 2.2 } then Continue;
      if GetMinPosition(Wnd).y < Screen.Height then
        if not IsIconic(Wnd) then
          MoveDesktopIcon(Wnd, Point(-1, -1))
        else
        begin
          MoveDesktopIcon(Wnd, NextPos);
          Inc(NextPos.X, XSpacing);
          if NextPos.X > Screen.Width then
          begin
            Dec(NextPos.Y, YSpacing);
            NextPos.X := FarLeft;
          end
        end;
    end;
  finally
    List.Free;
  end;
end;

procedure TDesktop.ArrangeShortcuts;
var
  Wnd: HWND;
  List: TList;
  NextPos: TPoint;
  XSpacing, YSpacing, TopMost, i: Integer;
  Control: TWinControl;
begin
  XSpacing := DeskGrid.X;
  YSpacing := DeskGrid.Y;
  TopMost := 2;
  NextPos.X := ((XSpacing - 32) div 2) + 2;
  NextPos.Y := TopMost;
  List := TList.Create;
  try
    { move Computer and Bin icons first }
    Wnd := Computer.Handle;
    if GetMinPosition(Wnd).x > 0 then
    begin
      MoveDesktopIcon(Wnd, NextPos);
      Inc(NextPos.Y, YSpacing);
    end;
    Wnd := Bin.Handle;
    if GetMinPosition(Wnd).x > 0 then
    begin
      MoveDesktopIcon(Wnd, NextPos);
      Inc(NextPos.Y, YSpacing);
    end;
    { move shortcuts }
    EnumWindows(@EnumMinWindows, Longint(List));
    for i := 0 to List.Count - 1 do
    begin
      Wnd := Longint(list[i]);
      control := FindControl(wnd);
      if (Control is TShort) or not IsWindowVisible(Wnd) then
      begin
        MoveDesktopIcon(Wnd, NextPos);
        Inc(NextPos.Y, YSpacing);
        if NextPos.Y > Screen.Height then
        begin
          Inc(NextPos.X, XSpacing);
          NextPos.Y := TopMost;
        end
      end;
    end;
  finally
    List.Free;
  end;
end;

{ SnapToGrid uses a bit of modulo maths to determine the closest square.
  The Snap function is given a coordinate and a grid size, and returns
  where the coordinate should snap to. }

procedure TDesktop.SnapToGrid;
var
  Wnd: HWND;
  List: TList;
  MinPos: TPoint;
  XSpacing, YSpacing, XOffset, i: Integer;

function Nearest(value, lower, upper: Integer): Integer;
begin
  if (value - lower) < (upper - value) then Result := lower
  else Result := upper;
end;

function Snap(p, grid: Integer): Integer;
begin
  Result := p;
  if p mod grid <> 0 then
    Result := Nearest(p, p - (p mod grid), p + grid - (p mod grid));
end;

begin
  XSpacing := DeskGrid.X;
  YSpacing := DeskGrid.Y;
  List := TList.Create;
  try
    EnumWindows(@EnumMinWindows, Longint(list));
    for i := 0 to List.Count - 1 do
    begin
      Wnd := Longint(List[i]);
      MinPos := GetMinPosition(wnd);
      with MinPos do
      if (X > -32) and (Y > -32) and (Y < Screen.Height) then
      begin
        XOffset := ((XSpacing - 32) div 2) + 2;
        X := Snap(X - XOffset, XSpacing) + XOffset;
        Y := Snap(Y - 2, YSpacing) + 2;
        MoveDesktopIcon(Wnd, MinPos);
      end;
    end;
  finally
    List.Free;
  end;
end;

procedure TDesktop.RefreshNow;
var
  i: Integer;
begin
  if (RefreshList.Count = 0) or ProgressBox.Showing { 3.2 } then Exit;
  with Each(TIconWindow) do
  begin
    for i := 0 to Count - 1 do
      if RefreshList.IndexOf(TIconWindow(Items[i]).Dir.Fullname) <> -1 then
        TIconWindow(Items[i]).RefreshWin;
  end;
  RefreshList.Clear;
end;

procedure TDesktop.RenameWindows(const previous, current: TFilename);
var
  i: Integer;
begin
  with Each(TIconWindow) do
    for i := 0 to Count - 1 do
      TIconWindow(Items[i]).FolderRenamed(previous, current);
end;

{ Just as TForm informs TScreen when it is created or destroyed, so
  TIconWindow informs TDesktop.  All icon windows are stored in a
  sorted string list, and the sort ordering is useful when maintaining
  a popup menu. }

procedure TDesktop.AddWindow(Win: TIconWindow);
begin
  WindowList.AddObject(Win.Dir.Fullname, Win);
end;

procedure TDesktop.RemoveWindow(Win: TIconWindow);
var
  i: Integer;
begin
  with WindowList do
  begin
    i := IndexOfObject(Win);
    if i <> -1 then Delete(i);
  end;
end;

{ EnableForms takes the place of EnableTaskWindows.  All forms are disabled
  or enabled except the ones which can be active during a file operation.
  This gives the appearance of a modal state. }

procedure TDesktop.EnableForms(Enable: Boolean);
var
  i: Integer;
  f: TForm;
begin
  with Screen do
    for i := 0 to FormCount - 1 do
    begin
      f := Forms[i];
      if (f <> ProgressBox) and (f <> ReplaceBox) then
        f.Enabled := Enable;
    end;
end;

{ The desktop is responsible for loading shortcuts and previously
  opened icon windows.  To prevent errors from slowing down the loading,
  only folders which exist on fixed drives are processed }

procedure TDesktop.Load;
var
  i: Integer;
  s: TShort;
  strings: TStringList;
  IconWindow: TIconWindow;
  fname: TFilename;
begin
  { load shortcuts }
  for i := 0 to ini.ReadInteger('Desktop', 'NumShorts', 0) - 1 do
  begin
    s := TShort.Create(Application);
    s.LoadFromIni(ini, 'Shortcut' + IntToStr(i));
  end;
  { load saved icon windows }
  strings := TStringList.Create;
  try
    ini.ReadStrings('Folders', strings);
    for i := strings.Count - 1 downto 0 do
    begin
      fname := strings[i];
      if fname[1] = '*' then
      begin { 3.1 }
        Delete(fname, 1, 1);
        if Desktop.WindowOf(fname) <> nil then Continue;
        if not (dfRemoveable in GetDriveFlags(fname[1])) and
          ((Length(fname) = 3) or HDirectoryExists(fname)) then
            OpenExplorer(fname);
      end
      else
      begin
        if Desktop.WindowOf(fname) <> nil then Continue;
        if not (dfRemoveable in GetDriveFlags(fname[1])) and
          ((Length(fname) = 3) or HDirectoryExists(fname)) then
          begin
            IconWindow := TIconWindow.Init(Application, fname, DefaultFilter);
            with IconWindow do
            begin
              LoadDimensions;
              Show;
              Update;
            end;
          end;
      end;
    end;
  finally
    strings.Free;
  end;
end;

procedure TDesktop.Save;
var
  i: Integer;
begin
  SetCursor(crHourGlass);
  Computer.SavePosition(ini, 'Computer');
  Bin.SavePosition(ini, 'Bin');
  Bin.SaveTrash;
  with ini do
  begin
    { save open icon windows }
    EraseSection('Folders');
    if SaveWindows then with Each(TIconWindow) do
    begin
      WriteInteger('Folders', 'Count', Count);
      for i := 0 to Count - 1 do
      begin
        if TIconWindow(Items[i]).Owner = Explorer { 3.1 } then
          WriteString('Folders', 'S' + IntToStr(i),
            '*' + TIconWindow(Items[i]).Dir.Fullname)
        else
        begin
          TIconWindow(Items[i]).SaveDimensions;
          WriteString('Folders', 'S' + IntToStr(i),
            TIconWindow(Items[i]).Dir.Fullname);
        end;
      end;
      WriteSectionValues('Window positions', WindowPos);
    end;
    { save shortcuts }
    for i := 0 to ReadInteger('Desktop', 'NumShorts', 0) - 1 do
      EraseSection('Shortcut' + IntToStr(i));
    with Each(TShort) do
    begin
      WriteInteger('Desktop', 'NumShorts', Count);
      for i := 0 to Count - 1 do
        TShort(Items[i]).SaveToIni(ini, 'Shortcut' + IntToStr(i));
    end;
  end;
  ReleaseCursor;
end;

{ This is useful if the user accidentally presses Arrange Icons from the
  Windows task manager (which also arranges shortcuts!).  Since TExtForm
  saves its last icon position, it can be told to move itself back.  }

procedure TDesktop.Revert;
var
  i: Integer;
begin
  Computer.MinPosition := Computer.LastMinPosition;
  Bin.MinPosition := Bin.LastMinPosition;
  with Each(TShort) do
    for i := 0 to Count - 1 do
      with TShort(Items[i]) do MinPosition := LastMinPosition;
end;

{ NextForm is called when the user presses Ctrl-Tab.  When a form is
  brought to the front, it sticks itself at the top of Screen.Forms.
  This makes it difficult to select the next form in Z-order (you end
  up flipping between two forms!), so we must bring forward the form
  at the very bottom of the pack }

procedure TDesktop.NextForm;
var
  f: TForm;
  i: Integer;
begin
  with Screen do
    for i := FormCount - 1 downto 0 do
    begin
      f := Forms[i];
      if f.Visible and IsWindowEnabled(f.Handle) and (f <> Screen.ActiveForm) and
        (f <> Application.MainForm) and not (f is TShort) then
        begin
          f.BringToFront;
          f.WindowState := wsNormal;
          Exit;
        end;
    end;
end;

{ SetCursor and ReleaseCursor are extremely useful to prevent the wrong
  cursor from being displayed after a try...finally block.  If a "busy"
  operation sets the hourglass cursor and calls another busy function,
  the second function would reset the cursor to crDefault after it
  finished.  Of course, the first operation might still be busy, so a
  stack based approach is needed to maintain the right cursor. }

procedure TDesktop.SetCursor(Cursor: TCursor);
begin
  CursorStack.Add(Pointer(Screen.Cursor));
  Screen.Cursor := Cursor;
end;

procedure TDesktop.ReleaseCursor;
begin
  with CursorStack do
    if Count > 0 then
    begin
      Screen.Cursor := TCursor(Items[Count - 1]);
      Delete(Count - 1);
    end;
end;

procedure TDesktop.ReleaseShortcuts;
var
  i: Integer;
begin
  with Each(TShort) do
    for i := 0 to Count - 1 do
      TShort(Items[i]).Free;
end;

procedure TDesktop.UpdateFileWindow(const filename: TFilename);
var
  rec : TSearchRec;
  w: TIconWindow;
  i: Integer;
begin
  w := Desktop.WindowOf(ExtractFileDir(filename));
  if w <> nil then with w do
  begin
    if FindFirst(filename, faAnyFile, rec) = 0 then
    with Dir do
    begin
      if Find(ExtractFilename(filename), i) then FreeObject(i);
      AddItem(rec);
      Update;
    end;
    FindClose(rec); { 3.11 }
  end;
end;

function CanArrangeWindow(Wnd: HWnd): Boolean;  { 2.2 }
var
  R: TRect;
begin
  Result := False;
  if IsWindow(Wnd) then
  begin
    GetWindowRect(Wnd, R);
    Result := IsWindowVisible(Wnd) and not (IsRectEmpty(R) or IsIconic(Wnd));
  end;
end;

procedure TDesktop.CascadeList(wnds: TList); { 2.2 }
var
  i, tl, w, h: Integer;
  R: TRect;
  Wnd, LastWnd: HWnd;
begin
  tl := 0;
  w := (Screen.Width * 3) div 4;
  h := Screen.Height div 2;
  LastWnd := HWND_BOTTOM;
  for i := wnds.Count - 1 downto 0 do
  begin
    Wnd := HWnd(wnds[i]);
    if CanArrangeWindow(Wnd) then
    begin
      if IsZoomed(Wnd) then ShowWindow(Wnd, SW_RESTORE);
      GetWindowRect(Wnd, R);
      if tl + w > Screen.Width then tl := 0;
      SetWindowPos(Wnd, 0, tl, tl, w, h, SWP_SHOWWINDOW);
      LastWnd := Wnd;
      Inc(tl, CascadeDelta);
    end;
  end;
end;

procedure TDesktop.TileHorizList(wnds: TList); { 2.2 }
var
  Available, i, j, h, y, Wnd, WinCount: Integer;
begin
  WinCount := 0;
  for i := 0 to wnds.Count - 1 do
    if CanArrangeWindow(HWnd(wnds[i])) then Inc(WinCount);
  if WinCount = 0 then Exit;
  Available := Screen.Height;
  y := 0;
  if Taskbar.StayVisible1.Checked then
  begin
    Dec(Available, Taskbar.Height);
    if TopTaskbar then y := Taskbar.Height;
  end;
  h := Available div WinCount;
  j := 0;
  for i := 0 to wnds.Count - 1 do
  begin
    Wnd := HWnd(wnds[i]);
    if CanArrangeWindow(Wnd) then
    begin
      if IsZoomed(Wnd) then ShowWindow(Wnd, SW_RESTORE);
      Inc(j);
      if j = WinCount then Inc(h, Available mod WinCount);
      SetWindowPos(Wnd, 0, 0, y, Screen.Width, h, SWP_NOZORDER or SWP_SHOWWINDOW);
      Inc(y, h);
    end;
  end;
end;

procedure TDesktop.TileVertList(wnds: TList); { 2.2 }
var
  Available, i, j, h, w, x, y, Wnd, WinCount: Integer;
begin
  WinCount := 0;
  for i := 0 to wnds.Count - 1 do
    if CanArrangeWindow(HWnd(wnds[i])) then Inc(WinCount);
  if WinCount = 0 then Exit;
  Available := Screen.Width;
  j := 0;
  x := 0;
  y := 0;
  h := Screen.Height;
  w := Available div WinCount;
  if Taskbar.StayVisible1.Checked then
  begin
    h := Screen.Height - Taskbar.Height;
    if TopTaskbar then y := Taskbar.Height;
  end;
  for i := 0 to wnds.Count - 1 do
  begin
    Wnd := HWnd(wnds[i]);
    if CanArrangeWindow(Wnd) then
    begin
      if IsZoomed(Wnd) then ShowWindow(Wnd, SW_RESTORE);
      Inc(j);
      if j = WinCount then Inc(w, Available mod WinCount);
      SetWindowPos(Wnd, 0, x, y, w, h, SWP_NOZORDER or SWP_SHOWWINDOW);
      Inc(x, w);
    end;
  end;
end;

procedure TDesktop.Repaint;
begin
  RedrawWindow(0, nil, 0, RDW_ERASE or RDW_FRAME or RDW_ALLCHILDREN or
    RDW_INTERNALPAINT or RDW_INVALIDATE or RDW_ERASENOW or RDW_UPDATENOW);
end;

end.

