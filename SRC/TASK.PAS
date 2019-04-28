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

unit Task;

{ Many thanks to Panenka Vaclav for implementing the enhanced taskbar
  that can be moved and resized.

  Also thanks to Jiri Sobotka for implementing Applet system menu's. }

interface

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls, Forms,
  Buttons, ExtCtrls, Stylsped, Menus, CalMsgs, Hooks, StdCtrls, Profile,
  Referenc;

type
  TWindowType = (wtGeneral, wtFindForm, wtTaskman, wtIconWindow, wtExplorer);

  TTaskButton = class(TStyleSpeed)
  private
    FWindow: HWnd;
    FTask: THandle;
    FWindowType: TWindowType;
    FWinControl: TWinControl;
    procedure SetWindow(value: HWND);
  public
    constructor Create(AOwner: TComponent); override;
    procedure RefreshCaption;
    procedure AssignGlyph;
    function MinimizeCaption(s: string): string;
    property Window: HWND read FWindow write SetWindow;
    property Task: THandle read FTask;
    property WindowType: TWindowType read FWindowType;
    property WinControl: TWinControl read FWinControl write FWinControl;
  end;

  TButtonList = class(TList)
  private
    function GetButtons(i: Integer): TTaskButton;
  public
    property Buttons[i: Integer]: TTaskButton read GetButtons;
  end;

  TApplet = class(TGraphicControl)
  private
    FPressed : Boolean;
    procedure SetPressed(Value: boolean);
  protected
    FGlyph: TBitmap;
    procedure Paint; override;
    property Pressed: Boolean read FPressed write SetPressed;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  end;

  TTrayProgram = class(TApplet)
  private
    FModuleFile: TFilename;
    FCommand: string;
    procedure HideAppIcon;
  public
    procedure SetProgram(const command: string);
    procedure Click; override;
    procedure CheckModule;
    { 3.0 }
    constructor Create(AOwner: TComponent); override;
    procedure MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
  end;

  TTrayAlias = class(TApplet)
  private
    FFilename: TFilename;
    FRef: TAliasReference;
  public
    constructor Create(AOwner: TComponent; filename: TFilename);
    destructor Destroy; override;
    procedure Click; override;
  end;

  { 4.0 }
  TQuickButton = class(TStyleSpeed)
  private
    FTrayAlias: TTrayAlias;
  public
    constructor Create(AOwner: TComponent; filename: TFilename);
    destructor Destroy; override;
    procedure DragDrop(Sender, Source: TObject; X, Y: Integer);
    procedure DragOver(Sender, Source: TObject; X, Y: Integer;
      State: TDragState; var Accept: Boolean);
    procedure MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure Click; override;
  end;

  TTaskbar = class(TForm)
    TaskMenu: TPopupMenu;
    TaskRestore: TMenuItem;
    TaskMinimize: TMenuItem;
    TaskMaximize: TMenuItem;
    TaskClose: TMenuItem;
    StartButton: TStyleSpeed;
    SysMenu: TPopupMenu;
    Clock: TPanel;
    HintTimer: TTimer;
    HideTaskbar1: TMenuItem;
    StayVisible1: TMenuItem;
    N1: TMenuItem;
    TaskbarProperties: TMenuItem;
    StartProperties: TMenuItem;
    N2: TMenuItem;
    Spy: TMenuItem;
    Terminate: TMenuItem;
    N3: TMenuItem;
    TaskManager: TMenuItem;
    N4: TMenuItem;
    MinimizeAll1: TMenuItem;
    QuickBar: TPanel;
    TrayMenu: TPopupMenu;
    TrayOpen: TMenuItem;
    TrayProperties: TMenuItem;
    N5: TMenuItem;
    N6: TMenuItem;
    TrayAdd: TMenuItem;
    TrayRemove: TMenuItem;
    procedure FormCreate(Sender: TObject);
    procedure FormMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure FormPaint(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure TaskRestoreClick(Sender: TObject);
    procedure TaskMinimizeClick(Sender: TObject);
    procedure TaskMaximizeClick(Sender: TObject);
    procedure TaskCloseClick(Sender: TObject);
    procedure TaskMenuPopup(Sender: TObject);
    procedure TerminateClick(Sender: TObject);
    procedure StartButtonMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure SysMenuPopup(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure ClockMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure ClockMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure ClockMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure StayVisible1Click(Sender: TObject);
    procedure HideTaskbar1Click(Sender: TObject);
    procedure HintTimerTimer(Sender: TObject);
    procedure SpyClick(Sender: TObject);
    procedure StartPropertiesClick(Sender: TObject);
    procedure TaskbarPropertiesClick(Sender: TObject);
    procedure ClockDblClick(Sender: TObject);
    procedure StartButtonClick(Sender: TObject);
    procedure FormDragOver(Sender, Source: TObject; X, Y: Integer;
      State: TDragState; var Accept: Boolean);
    procedure StartButtonMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure FormMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure StartButtonMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure FormShow(Sender: TObject);
    procedure FormHide(Sender: TObject);
    procedure FormDblClick(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    { 3.1 }
    procedure MinimizeAll1Click(Sender: TObject);
    procedure TaskManagerClick(Sender: TObject);
    { 4.0 }
    procedure TrayOpenClick(Sender: TObject);
    procedure TrayAddClick(Sender: TObject);
    procedure TrayRemoveClick(Sender: TObject);
    procedure TrayPropertiesClick(Sender: TObject);
  private
    { Private declarations }
    Excludes: TStringList;
    HintWindow: THintWindow;
    HintControl: TControl;
    Pressed: Integer;
    InTaskClick: Boolean;
    HiddenList: TList;
    OneRowHeight: Integer;
    WasDragged: Boolean;
    MenuHelper: HWnd; { 2.2 }
    procedure TaskClick(Sender: TObject);
    procedure TaskButtonMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure WMMouseActivate(var Msg: TWMMouseActivate); message WM_MOUSEACTIVATE;
    procedure WMEnable(var Msg: TWMEnable); message WM_ENABLE;
    procedure WMDropFiles(var Msg: TWMDropFiles); message WM_DROPFILES;
    procedure WMSysCommand(var Msg: TWMSysCommand); message WM_SYSCOMMAND;
    procedure ShellWndCreate(var Msg: TMessage); message WM_SHELLWNDCREATE;
    procedure ShellWndDestroy(var Msg: TMessage); message WM_SHELLWNDDESTROY;
    procedure WMMouseHook(var Msg: TMessage); message WM_MOUSEHOOK;
    procedure WMHideQuery(var Msg: TMessage); message WM_HIDEQUERY;
    procedure WMWinActivate(var Msg: TMessage); message WM_WINACTIVE;
    procedure WMAddButton(var Msg: TMessage); message WM_ADDBUTTON;
    function TaskToButton(task: THandle): Integer;
    function WndToButton(Wnd: HWnd): Integer;
    function ShouldExclude(Wnd: HWND): Boolean;
    procedure SetMouseMonitor;
    procedure TaskButtonDragOver(Sender, Source: TObject; X, Y: Integer;
      State: TDragState; var Accept: Boolean);
    procedure TaskButtonDragDrop(Sender, Source: TObject; X, Y: Integer);
    { 2.2 }
    procedure UpdateStartButtonState;
    procedure PositionChanged;
    procedure SysMenuWndProc(var Message: TMessage);
    { 3.0 }
    procedure ShowRealSystemMenu(p: TPoint);
  protected
    { Protected declarations }
    procedure CreateParams(var Params: TCreateParams); override;
  public
    { Public declarations }
    ButtonList: TButtonList;
    BarShowing: Boolean;
    procedure TimerTimer; { 3.11 -- called from Computer timer }
    procedure ShowBar;
    procedure HideBar;
    procedure Press(Wnd: HWND);
    procedure RefreshCaptions;
    procedure RefreshButtons;
    procedure ArrangeButtons;
    procedure UpdateButtons;
    procedure UpdateApplets;
    procedure AddButton(Wnd: HWND);
    procedure DeleteButton(Wnd: HWND);
    procedure Configure;
    procedure ActivateHint(p: TPoint);
    procedure CancelHint;
    procedure SetClock(const s: string);
    procedure StartKeyPopup;
    procedure MinimizeAll;
    procedure ShowMinimized(Wnd: HWND);
    procedure MinimizeList(wnds: TList); { 2.2 }
  end;

var
  Taskbar: TTaskbar;

function IsProperTaskWindow(Wnd: HWND): Boolean;

implementation

uses ShellAPI, ToolHelp, Strings, Settings, Files, Start, Desk, Compsys,
  MiscUtil, IconWin, Tree, Resource, MultiGrd, FileFind, Environs, Streamer,
  Locale, Dialogs, Strtprop, TaskProp, FileMan, Taskman, ShutDown, Alias,
  Drives, WasteBin;

{$R *.DFM}

var
  YTop: Integer; { 2.2 }
  YLimit: Integer;
  ChangingRows: Boolean; { 2.2 }
  UseMouseHook: Boolean;
  ConciseDT: string[127];
  FullDT: string[127];
  ExplorerBmp: TBitmap;
  FolderBmp: TBitmap;
  FindBmp: TBitmap; { 3.1 }
  TaskBmp: TBitmap;

procedure RaiseWindow(Wnd: HWnd);
var
  p: TPoint;
begin
  { Shifts a minimized window up a little }
  p := GetMinPosition(Wnd);
  if (p.y > YLimit - MinAppHeight) and (p.y < Screen.Height) then
  begin
    p.y := YLimit - MinAppHeight;
    MoveDesktopIcon(Wnd, p);
  end;
end;

function TButtonList.GetButtons(i: Integer): TTaskButton;
begin
  Result := TTaskButton(Items[i]);
end;

procedure GetModuleAndClass(Wnd: HWND; var f, c: OpenString);
begin
  { Fills two strings with the module and class names of a window }
  f[0] := Chr(GetModuleFilename(GetWindowWord(Wnd, GWW_HINSTANCE), @f[1], High(f) - 1));
  c[0] := Chr(GetClassName(Wnd, @c[1], High(c) - 1));
end;

function IsTaskbarButtonWindow(Wnd: HWND): Boolean; { 2.2 renamed }
var
  Style: Longint;
begin
  { Returns true if the window qualifies as a "Task" }
  Style := GetWindowLong(Wnd, GWL_STYLE);
  Result := (GetWindowWord(Wnd, GWW_HWNDPARENT) = 0) and
    Bool(GetWindowTextLength(Wnd)) and ((Style and WS_SYSMENU <> 0) or
    (Style and WS_MINIMIZEBOX <> 0) or (Style and WS_MAXIMIZEBOX <> 0) or
    (Style and WS_THICKFRAME <> 0));
end;

function IsProperTaskWindow(Wnd: HWND): Boolean; { 2.2 }
begin
  Result := IsTaskbarButtonWindow(Wnd) and
    ((GetWindowTask(Wnd) <> GetCurrentTask) or (Wnd = Application.Handle));
end;

function IsVisibleTaskWindow(Wnd: HWND): Boolean;
begin
  Result := IsTaskbarButtonWindow(Wnd) and IsWindowVisible(Wnd);
end;

function IsHiddenTaskWindow(Wnd: HWND): Boolean;
begin
  Result := IsTaskbarButtonWindow(Wnd) and not IsWindowVisible(Wnd);
end;

function EnumWinProc(Wnd: HWnd; Taskbar: TTaskbar): Bool; export;
begin
  { Adds all visible task windows to the bar }
  if IsVisibleTaskWindow(Wnd) then
  begin
    Taskbar.Perform(WM_SHELLWNDCREATE, Wnd, 0);
    if IsIconic(Wnd) then Taskbar.Perform(WM_HIDEQUERY, Wnd, 0);
  end;
  Result := True;
end;

{ TTaskButton }

constructor TTaskButton.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  Style := sbWin95;
  Margin := 2;
  Spacing := 2;
  GroupIndex := 1;
  AllowAllUp := True; { 3.11 }
end;

procedure TTaskButton.SetWindow(value: HWND);
begin
  FWindow := value;
  FTask := GetWindowTask(FWindow);
  FWinControl := FindControl(FWindow);
  if FWinControl is TFindForm then FWindowType := wtFindForm
  else if FWinControl is TTaskManager then FWindowType := wtTaskman
  else if FWinControl is TIconWindow then
  begin
    if TIconWindow(FWinControl).Owner = Explorer { 3.1 } then
      FWindowType := wtExplorer
    else FWindowType := wtIconWindow;
  end
  else FWindowType := wtGeneral;
  AssignGlyph;
  RefreshCaption;
end;

procedure TTaskButton.AssignGlyph;
var
  m, c: string[127];
  h: HIcon;
begin
  if FWindowType = wtFindForm then Glyph.Assign(FindBmp)
  else if FWindowType = wtTaskman then Glyph.Assign(TaskBmp)
  else if (IconWindowTask or ExplorerTask) and (FWindowType <> wtGeneral) then
    case FWindowType of
      wtExplorer  : Glyph.Assign(ExplorerBmp);
      wtIconWindow: Glyph.Assign(FolderBmp);
    end
  else
  begin
    Application.ProcessMessages;
    { 3.1 -- Get the window's class icon }
    h := GetClassWord(Window, GCW_HICON);
    if h = 0 then
      { if none, ask Calmira to provide one }
      h := ProvideLastIcon(GetWindowWord(Window, GWW_HINSTANCE));
    if h <= 1 then
    begin
      { if all fails, extract icon from file }
      GetModuleAndClass(Window, m, c);
      h := ExtractIcon(HInstance, StrPChar(m), 0);
      ShrinkIcon(h, Glyph, Color);
      DestroyIcon(h);
    end
    else ShrinkIcon(h, Glyph, Color);
    Glyph.Canvas.Pixels[0, 15] := Color; { 3.11 }
  end;
end;

function TTaskButton.MinimizeCaption(s: string): string;
var
  i, target: Integer;
  app, doc: string[79];
begin
  if DocNameFirst then
  begin
    i := Pos(' - ', s);
    if i > 0 then
    begin
      app := Copy(s, 1, i - 1);
      doc := Copy(s, i + 3, 255);
      if DocNameLower then doc := Lowercase(doc);
      s := Format('%s - %s', [doc, app]);
    end;
  end;
  target := Width - 6;
  if not Glyph.Empty then Dec(target, 18);
  Result := MinimizeString(s, Canvas, target);
end;

procedure TTaskButton.RefreshCaption;
var
  s: string[127];
begin
  s[0] := Chr(GetWindowText(Window, @s[1], 126));
  if (FWindowType = wtIconWindow) then
  begin
    Hint := TIconWindow(WinControl).Dir.Fullname;
    if not FullFolderPath and (Length(s) > 3) and (s[2] = ':') and (s[3] = '\') then
      s := ExtractFilename(s);
  end
  else Hint := s;
  Caption := MinimizeCaption(s);
end;

{ Routine for finding a window belonging to a module -- the module handle,
  not instance handle, is given so GetWindowWord can't be used }

var FoundWindow: HWND;

function WinModuleProc(Wnd: HWnd; Filename: PChar): Bool; export;
var
  buf: array[0..127] of char;
begin
  if IsProperTaskWindow(Wnd) { 2.2 } then
  begin
    GetModuleFilename(GetWindowWord(Wnd, GWW_HINSTANCE), buf, 127);
    if StrComp(Filename, buf) = 0 then
    begin
      FoundWindow := Wnd;
      Result := False;
      Exit;
    end;
  end;
  FoundWindow := 0;
  Result := True;
end;

{ TApplet }

constructor TApplet.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FGlyph := TBitmap.Create;
  SetBounds(0, 0, 20, 20);
  Align := alLeft;
end;

destructor TApplet.Destroy;
begin
  FGlyph.Free;
  inherited Destroy;
end;

procedure TApplet.Paint;
var
  R: TRect;
  X, Y: Integer;
begin
  R := ClientRect;
  Canvas.Draw(2, 2, FGlyph);
  if not FPRessed then with Canvas do
  begin
    for X := 2 to 18 do
      for y := 2 to 18 do
        if (Y mod 2) = (X mod 2) then
          Pixels[X, Y] := Color;
  end;
end;

procedure TApplet.SetPressed(Value: Boolean);
begin
  if FPressed <> Value then
  begin
    FPressed := Value;
    Invalidate;
  end;
end;

{ TTrayProgram }

procedure TTrayProgram.SetProgram(const command: string);
var
  h: HIcon;
  p: Integer;
begin
  FCommand := command;
  FModuleFile := Uppercase(command);
  p := Pos(' ', FModuleFile);
  if p > 1 then FModuleFile[0] := Chr(p - 1);
  h := ExtractIcon(HInstance, StrPChar(FModuleFile), 0);
  if h > 1 then
  begin
    ShrinkIcon(h, FGlyph, Taskbar.Color);
    DestroyIcon(h);
  end;
  HideAppIcon;
end;

procedure TTrayProgram.HideAppIcon;
begin
  EnumWindows(@WinModuleProc, Longint(@FModuleFile[1]));
  if FoundWindow > 0 then MoveDesktopIcon(FoundWindow, Point(0, Screen.Height));
end;

procedure TTrayProgram.Click;
var
  filename, newdir: TFilename;
  params: string;
begin
  if GetModuleHandle(@FModuleFile[1]) > 0 then
  begin
    { Re-activate the utility }
    EnumWindows(@WinModuleProc, Longint(@FModuleFile[1]));
    if FoundWindow > 0 then
      if IsIconic(FoundWindow) then ShowWindow(FoundWindow, SW_RESTORE)
      else BringWindowToTop(FoundWindow);
  end
  else
  begin
    { Run a new instance
      3.01 -- Better way of executing applets then
      WinExec(StrPChar(FCommand), SW_SHOWNORMAL); }
    filename := FirstWord(EnvironSubst(FCommand));
    newdir := ExtractFileDir(filename);
    params := '';
    if Length(filename) < Length(FCommand) then
      params := Copy(FCommand, Length(filename) + 2, 255);
    if newdir = '' then newdir := Environment.Values['WINDIR'];
    DefaultExec(filename, params, newdir, SW_SHOWNORMAL);
    HideAppIcon;
    Pressed := True;
  end;
end;

procedure TTrayProgram.CheckModule;
begin
  Pressed := GetModuleUsage(GetModuleHandle(@FModuleFile[1])) > 0;
  if Pressed then HideAppIcon; { 3.2 }
end;

constructor TTrayProgram.Create(AOwner: TComponent); { 3.0 }
begin
  inherited Create(AOwner);
  OnMouseDown := MouseDown;
end;

procedure TTrayProgram.MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer); { 3.0 }
var
  p: TPoint;
begin
  if Button = mbRight then
  begin
    if GetModuleHandle(@FModuleFile[1]) > 0 then
    begin
      EnumWindows(@WinModuleProc, Longint(@FModuleFile[1]));
      if FoundWindow > 0 then
      begin
        DisableMouseMonitor;
        GetCursorPos(p);
        Taskbar.TaskMenu.Tag:=FoundWindow;
        if ShowRealSysMenu then
        begin
          { An applet's system menu usually pops up left of the mouse,
            to prevent an item being selected when the mouse button
            is released, we move the menu one pixel to the left }
          Dec(p.X);
          Taskbar.ShowRealSystemMenu(p);
        end
        else Taskbar.TaskMenu.Popup(p.X, p.Y);
        EnableMouseMonitor;
      end;
    end;
  end;
end;

{ TTrayAlias }

constructor TTrayAlias.Create(AOwner: TComponent; filename : TFilename);
var
  s: TStreamer;
  Icon: TIcon;
begin
  inherited Create(AOwner);
  FFilename := filename;
  FRef := TAliasReference.Create;
  Icon := TIcon.Create;
  s := TStreamer.Create(filename, fmOpenRead);
  try
    s.ReadString;
    FRef.LoadFromStream(s);
    Hint := FRef.Caption;
    FRef.AssignIcon(Icon);
    ShrinkIcon(Icon.Handle, FGlyph, Taskbar.Color);
    FGlyph.Canvas.Pixels[0, 15] := Taskbar.Color;
  finally
    s.Free;
    Icon.Free;
  end;
end;

destructor TTrayAlias.Destroy;
begin
  FRef.Free;
  inherited Destroy;
end;

procedure TTrayAlias.Click;
begin
  FRef.Open;
end;

{ Quick button }

constructor TQuickButton.Create(AOwner: TComponent; filename: TFilename);
begin
  inherited Create(AOwner);
  SetBounds(0, 0, 22, 22);
  Style := sbFlat;
  FTrayAlias := TTrayAlias.Create(AOwner, filename);
  Glyph := FTrayAlias.FGlyph;
  Hint := FTrayAlias.Hint;
  OnDragDrop := DragDrop;
  OnDragOver := DragOver;
  OnMouseDown := MouseDown;
end;

destructor TQuickButton.Destroy;
begin
  FTrayAlias.Free;
  inherited Destroy;
end;

procedure TQuickButton.MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
  p: TPoint;
begin
  if Button = mbRight then
  begin
    DisableMouseMonitor;
    GetCursorPos(p);
    Taskbar.TrayMenu.Tag := Longint(Sender);
    Taskbar.TrayMenu.Popup(p.X, p.Y);
    EnableMouseMonitor;
  end;
end;

procedure TQuickButton.DragDrop(Sender, Source: TObject; X, Y: Integer);
begin
  FTrayAlias.FRef.DragDrop(Source);
end;

procedure TQuickButton.DragOver(Sender, Source: TObject; X, Y: Integer;
  State: TDragState; var Accept: Boolean);
begin
  Accept := (Source <> Computer.Grid) and ((Source <> Bin.Listbox) or
    (FTrayAlias.FRef.Kind <> rkFile));
end;

procedure TQuickButton.Click;
begin
  FTrayAlias.FRef.Open;
end;

{ Main taskbar }

procedure TTaskbar.FormCreate(Sender: TObject);
var
  i, irows: Integer;
  Wnd: HWND;
  buf: TFilename;
begin
  Pressed := -1;
  SetCallBackWnd(Handle);
  HintWindow := THintWindow.Create(Application);
  HintWindow.Visible := False;
  if Screen.PixelsPerInch > 96 then
    StartButton.Width := StartButton.Width + 8;
  Desktop.SetCursor(crHourGlass);
  try
    ExplorerBmp := TBitmap.Create;
    FolderBmp := TBitmap.Create;
    FindBmp := TBitmap.Create;
    TaskBmp := TBitmap.Create;
    ExplorerBmp := TResBitmap.AlternateLoad('EXPLORERBMP', 'taskexp.bmp');
    FolderBmp := TResBitmap.AlternateLoad('FOLDERBMP', 'taskfold.bmp');
    FindBmp := TResBitmap.AlternateLoad('FINDBMP', 'taskfind.bmp');
    TaskBmp := TResBitmap.AlternateLoad('TASKBMP', 'tasktask.bmp');
    OneRowHeight := 24;
    Height := Height + ((RowCount - 1) * OneRowHeight);
    ChangingRows := False;
    if not TopTaskbar then
      Setbounds(0, Screen.Height - 1, Screen.Width, Height)
    else
      Setbounds(0, - Height - 1, Screen.Width, Height); { 2.2 }
    ButtonList := TButtonList.Create;
    HiddenList := TList.Create;
    Configure;
    StartButton.OnDragOver := Computer.FormDragOver;
    StartButton.OnDragDrop := Computer.FormDragDrop;
    PositionChanged;
    StartTaskMonitor;
    if UseMouseHook then StartMouseMonitor;
    SetWndHook;
    if DisableTaskbar then Exit;
    if StayVisible1.Checked then ShowBar else HideBar;
    EnumWindows(@EnumWinProc, Longint(self));
  finally
    Desktop.ReleaseCursor;
    DragAcceptFiles(Handle, True);
  end;
end;

procedure TTaskbar.CreateParams(var Params: TCreateParams);
begin
  inherited CreateParams(Params);
  Params.WndParent := GetDesktopWindow;
end;

procedure TTaskbar.WMMouseHook(var Msg: TMessage);
begin
  { Called by the DLL when the cursor leaves the taskbar }
  if not StayVisible1.Checked and (GetCapture = 0) and BarShowing
    and not (Cursor = crTerminate) { 3.0 } then HideBar
  else if ButtonHints and HintWindow.Visible then CancelHint;
end;

procedure TTaskbar.FormMouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
begin
  if Cursor = crTerminate then Exit; { 3.0 }
  if Cursor = crDrag then
  begin  { 2.2 }
    if TopTaskbar and (Y > Height) then
    begin
      Setbounds(0, Screen.Height - ClientHeight + 2, Screen.Width, Height);
      WasDragged := True;
    end
    else if (not TopTaskbar) and (Y < 0) then
    begin
      Setbounds(0, -2, Screen.Width, Height);
      WasDragged := True;
    end
  end
  else if BarShowing and ((TopTaskbar and (Y <= Height - 2) and (Y >= Height - 4))
    or (not TopTaskbar and (Y >= 0) and (Y <= 2))) then Cursor := crSizeNS
  else
  begin
    if (Cursor = crSizeNS) and ChangingRows then
    begin
      if TopTaskbar then
      begin
        if (Y > Height) and (Height < Screen.Height div 2) then
        begin
          Height := Height + OneRowHeight;
          Inc (RowCount);
          WasDragged := True;
          Invalidate;
        end
        else if (Y < (Height - OneRowHeight)) and (RowCount > 1) then
        begin
          Height := Height - OneRowHeight;
          Dec (RowCount);
          WasDragged := True;
          Invalidate;
        end
      end
      else
      begin
        if (Y < 0 - OneRowHeight div 2) and (Height < Screen.Height div 2) then
        begin
          Top := Top - OneRowHeight;
          Height := Height + OneRowHeight;
          Inc (RowCount);
          WasDragged := True;
        end
        else if (Y > OneRowHeight div 2) and (RowCount > 1) then
        begin
          Top := Top + OneRowHeight;
          Height := Height - OneRowHeight;
          Dec (RowCount);
          WasDragged := True;
        end;
      end;
    end
    else if Cursor = crSizeNS then Cursor := crDefault;
    if not BarShowing then ShowBar;
    CancelHint;
  end;
end;

function TTaskbar.TaskToButton(task: THandle): Integer;
begin
  { Returns the button index for a given task handle, -1 if the
    task is not shown on the bar }
  with ButtonList do
    for Result := 0 to Count - 1 do
      if task = Buttons[Result].Task then Exit;
  Result := -1;
end;

function TTaskbar.WndToButton(Wnd: HWnd): Integer;
begin
  { Returns the button index for a given window handle, -1 if the
    task is not shown on the bar }
  with ButtonList do
    for Result := 0 to Count - 1 do
      if Wnd = Buttons[Result].Window then Exit;
  Result := -1;
end;

procedure TTaskbar.Press(Wnd: HWND);
var
  i: Integer;
begin
  { Called when a window receives a WM_ACTIVATE message.  If there is
    a button for that window or the task it belongs to, then that
    button is pressed }
  if IsIconic(Wnd) then Exit;
  i := WndToButton(Wnd);
  if i = -1 then i := TaskToButton(GetWindowTask(Wnd));
  with ButtonList do
    if i > -1 then
      Buttons[i].Down := True
    else if (Pressed > -1) and (Pressed < Count) then
      Buttons[Pressed].Down := False;
  Pressed := i;
end;

procedure TTaskbar.UpdateButtons;
begin
  RefreshButtons;
  ArrangeButtons;
  Press(GetActiveWindow);
end;

procedure TTaskbar.TimerTimer;
const
  MouseButtons: array[Boolean] of Word = (VK_LBUTTON, VK_RBUTTON);
begin
  if DisableTaskbar then Exit;
  if GetAsyncKeyState(MouseButtons[Bool(GetSystemMetrics(SM_SWAPBUTTON))]) >= 0 then
    SetClock(FormatDateTime(ConciseDT, Now));
  if BarShowing then
  begin
    UpdateButtons;
    UpdateApplets;
  end;
end;

procedure TTaskbar.ShowBar;
var
  i: Integer;
  Wnd: HWND;
begin
  if DisableTaskbar then Exit;
  UpdateButtons;
  UpdateApplets; { 3.1 }
  BarShowing := True;
  SetClock(FormatDateTime(ConciseDT, Now));
  if not StartButton.Visible and FullAnimate then
    for i := 0 to ControlCount - 1 do Controls[i].Show;
  { Move the form up several pixels at a time and then show the buttons }
  if Animate then
  begin
    if TopTaskbar then
    begin { 2.2 }
      i := - ClientHeight + 1;
      while i < -2 do
      begin
        Top := i;
        Update; { 3.0 }
        Inc(i, RowCount * AnimatePixels);
        Delay(AnimateSlowDown); { 3.11 }
      end;
    end
    else
    begin { 2.2 }
      i := Screen.Height - 1;
      while i > Screen.Height - ClientHeight + 2 do
      begin
        Top := i;
        Update; { 3.0 }
        Dec(i, RowCount * AnimatePixels);
        Delay(AnimateSlowDown); { 3.11 }
      end;
    end
  end;
  if TopTaskbar then Top := -2 { 2.2 }
  else Top := Screen.Height - ClientHeight + 2;
  Update; { 3.11 }
  if not StartButton.Visible then
    for i := 0 to ControlCount-1 do Controls[i].Show;
  if Cursor <> crDrag then SetMouseMonitor;
end;

procedure TTaskbar.HideBar;
var i: Integer;
begin
  { Suspends the taskbar until it is re-activated by the mouse }
  CancelHint;
  BarShowing := False;
  if not FullAnimate then for i := 0 to ControlCount - 1 do
    Controls[i].Hide; { 3.0 }
  if Animate then
  begin
    if TopTaskbar then
    begin { 2.2 }
      i := -2;
      while i > -ClientHeight + 1 do
      begin
        Top := i;
        Update; { 3.0 }
        Dec(i, RowCount * AnimatePixels);
        Delay(AnimateSlowDown * 2); { 3.11 }
      end;
    end
    else
    begin { 2.2 }
      i := Screen.Height - ClientHeight + 2;
      while i < Screen.Height - 1 do
      begin
        Top := i;
        Update; { 3.0 }
        Inc(i, RowCount * AnimatePixels);
        Delay(AnimateSlowDown * 2); { 3.11 }
      end;
    end
  end;
  if TopTaskbar then Top := -ClientHeight + 1 { 2.2 }
  else Top := Screen.Height - 1;
  Update; { 3.11 }
  if StartButton.Visible then
    for i := 0 to ControlCount - 1 do Controls[i].Hide;
  DisableMouseMonitor;
end;

procedure TTaskbar.FormPaint(Sender: TObject);

procedure DrawDevider(const x: Integer);
begin
  with Canvas do
  begin
    Pen.Color := clBtnShadow;
    MoveTo(x, 4);
    LineTo(x, 26);
    Pen.Color := clBtnHighlight;
    MoveTo(x + 1, 4);
    LineTo(x + 1, 26);
  end;
end;

begin
  with Canvas do
  begin
    { Draw a border across the top }
    Pen.Color := clBtnHighlight;
    MoveTo(0, 1);
    LineTo(ClientWidth, 1);
    Pen.Color := clBtnFace;
    MoveTo(0, 0);
    LineTo(ClientWidth, 0);
    { Draw a border across the bottom }
    Pen.Color := clBtnShadow;
    MoveTo(0, ClientHeight - 2);
    LineTo(ClientWidth, ClientHeight - 2);
    Pen.Color := clWindowFrame;
    MoveTo(0, ClientHeight - 1);
    LineTo(ClientWidth, ClientHeight - 1);
    { Draw deviders }
    DrawDevider(QuickBar.Left - 5);
    DrawDevider(QuickBar.Left + QuickBar.Width + 3);
    DrawDevider(Clock.Left - 5);
  end;
end;

procedure TTaskbar.ArrangeButtons;
var
  i, t, h, w, x, avail, spare, remaining, perRow: Integer;
begin
  { w is the width of a button plus the gap to its right}
  if ButtonList.Count = 0 then Exit;
  avail := ClientWidth - StartButton.Width - QuickBar.Width - Clock.Width - 24;
  spare := RowCount - 1;
  case ButtonList.Count of
    1..3: w := avail div 3;
  else
    begin
      if ButtonList.Count mod RowCount <= Spare then
        perRow := ButtonList.Count div RowCount
      else
        perRow := (ButtonList.Count div RowCount) + 1;
      perRow := Max(perRow, 3);
      w := avail div Max(1, perRow);
    end;
  end;
  if w > 196 then w := 196;
  { x is initialised to the left side of the first button }
  x := QuickBar.Left + QuickBar.Width + 8;
  t := StartButton.Top;
  h := StartButton.Height;
  remaining := avail div w;
  with ButtonList do
    for i := 0 to Count - 1 do
    begin
      if remaining = 1 then
        { make sure last button doesn't exceed the taskbar }
        Buttons[i].SetBounds(x, t, Min(w - 3, Clock.Left - x + Clock.Width), h)
      else Buttons[i].SetBounds(x, t, w - 3, h);
      Dec(remaining);
      if remaining = 0 then
      begin
        x := 2;
        Inc(t, OneRowHeight);
        remaining := avail div w;
        if spare > 0 then Inc(remaining);
      end
      else Inc(x, w);
    end;
  RefreshCaptions;
end;

procedure TTaskbar.RefreshCaptions;
var
  i: Integer;
begin
  with ButtonList do
    for i := 0 to Count - 1 do Buttons[i].RefreshCaption;
end;

procedure TTaskbar.RefreshButtons;
var
  i, j: Integer;
  Wnd: HWND;
  FoundDupe: Boolean;
begin
  { remove any windows that no longer exist or have disappeared }
  i := 0;
  with ButtonList do
    for i := Count - 1 downto 0 do
    begin
      Wnd := Buttons[i].Window;
      FoundDupe := False;
      j := i - 1;
      while (j >= 0) and not FoundDupe do
      begin
        FoundDupe := Buttons[j].Window = Wnd;
        Dec(j);
      end;
      if FoundDupe or ((Buttons[i].WindowType = wtGeneral) and (not IsWindow(Wnd)
        or not IsWindowVisible(Wnd) or (GetWindowTextLength(Wnd) = 0))) then
        begin
          Buttons[i].Free;
          Delete(i);
        end;
    end;
end;

procedure TTaskbar.AddButton(Wnd: HWND);
var
  button: TTaskButton;
begin
  button := TTaskButton.Create(Self);
  InsertControl(button);
  with button do
  begin
    Left := -64;
    Window := Wnd;
    OnClick := TaskClick;
    OnMouseDown := TaskButtonMouseDown;
    OnMouseMove := ClockMouseMove;
    OnDragOver := TaskButtonDragOver;
    OnDragDrop := TaskButtonDragDrop;
    BoldOnDown := True; { 3.11 }
  end;
  if not IsWindow(Wnd) or (WndToButton(Wnd) <> -1) then
  begin
    button.Free;
    Exit;
  end;
  button.Down := True;
  ButtonList.Add(button);
  if BarShowing then ArrangeButtons;
end;

procedure TTaskbar.DeleteButton(Wnd: HWND);
var
  i: Integer;
begin
  { When Wnd is destroyed, look for a button with the matching window
    and remove it, then rearrange the other buttons }
  with ButtonList do
    for i := 0 to Count - 1 do if Buttons[i].Window = Wnd then
    begin
      Buttons[i].Free;
      Delete(i);
      ArrangeButtons;
      Exit;
    end;
end;

procedure TTaskbar.TaskClick(Sender: TObject);
var
  Wnd: HWND;
begin
  { This is the event handler for normal task buttons.
    Disabled child windows are skipped in case they cover up the
    active window (e.g. if an icon window covers up a modal dialog,
    there is no way to end the modal state) }
  Wnd := TTaskButton(Sender).Window;
  if not IsWindowEnabled(Wnd) and
    (TTaskButton(Sender).WindowType <> wtGeneral) then
    begin
      MessageBeep(MB_ICONHAND); { 3.0 }
      Exit;
    end;
  if (Wnd = GetActiveWindow) or (Wnd = GetWindow(GetActiveWindow, GW_OWNER))then
    ShowWindow(Wnd, SW_MINIMIZE) { 3.11 }
  else
  begin
    { The SendMessage trick is required to access full screen DOS boxes
      because of a bug (solution provided by Microsoft) }
    InTaskClick := True;
    SendMessage(Wnd, WM_ACTIVATE, WA_ACTIVE, MakeLong(Wnd, Word(True)));
    InTaskClick := False;
    if IsIconic(Wnd) then ShowWindow(Wnd, SW_RESTORE)
    else BringWindowToTop(Wnd);
  end;
end;

function TTaskbar.ShouldExclude(Wnd: HWND): Boolean;
var
  fname, cname: string[127];
begin
  { Returns True if Wnd should be excluded from the bar }
  GetModuleAndClass(Wnd, fname, cname);
  fname := ExtractFilename(fname);
  Result := (Excludes.IndexOf(fname) > -1) or
    (Excludes.IndexOf(Format('%s %s', [fname, cname])) > -1);
end;

procedure TTaskbar.ShellWndCreate(var Msg: TMessage);
begin
  { Called by the shell hook when a top-level window is created }
  with msg do
    if not ShouldExclude(wParam) then
      if IsHiddenTaskWindow(wParam) then
        HiddenList.Add(Pointer(wParam))
      else if IsVisibleTaskWindow(wParam) then
      begin
        AddButton(wParam);
        if IsIconic(wParam) then Perform(WM_HIDEQUERY, wParam, 0);
      end;
  UpdateApplets; { 3.2 }
end;

procedure TTaskbar.ShellWndDestroy(var Msg: TMessage);
var
  i: Integer;
begin
  { Called by the shell hook when a top-level window is destroyed }
  i := HiddenList.IndexOf(Pointer(msg.wParam));
  if i > -1 then HiddenList.Delete(i)
  else DeleteButton(msg.wParam);
end;

procedure TTaskbar.FormDestroy(Sender: TObject);
var
  i: Integer;
begin
  StopMouseMonitor;
  StopTaskMonitor;
  UnhookWndHook;
  { Apps which have had their icon moved off the screen must be restored
    properly.  If Calmira is active, then its ArrangeIcons function is
    called, but the icons must be moved above Screen.Height so that
    Calmira knows that they are not supposed to be hidden }
  for i := 0 to ButtonList.Count - 1 do
    MoveDesktopIcon(ButtonList.Buttons[i].Window,
      Point(0, Screen.Height - 1));
  Desktop.ArrangeIcons;
  Excludes.Free;
  HiddenList.Free;
  ButtonList.Free;
  ExplorerBmp.Free;
  FolderBmp.Free;
  FindBmp.Free;
  TaskBmp.Free;
end;

procedure TTaskbar.FormMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
const
  MouseButtons: array[Boolean] of Word = (VK_LBUTTON, VK_RBUTTON);
var
  control: TControl;
  i: Integer;
  p: TPoint;
begin
  { "Terminate" mode distinguished by the cursor being crTerminate }
  if Cursor = crTerminate then
  begin
    if Button = mbLeft then
    begin
      control := ControlAtPos(Point(X, Y), True);
      if (control is TTaskButton) and (TTaskButton(control).Task <> GetCurrentTask) then
        if MsgDialog(Format(LoadStr(SQueryTerminate), [TTaskButton(control).Caption]),
          mtWarning, [mbYes, mbNo], 0) = mrYes then
            TerminateApp(TTaskButton(control).Task, NO_UAE_BOX);
    end;
    for i := 0 to ControlCount-1 do Controls[i].Enabled := True;
    Cursor := crDefault;
  end
  else
  begin
    if (Button = mbRight) then
      if (GetAsyncKeyState(MouseButtons[Bool(GetSystemMetrics(SM_SWAPBUTTON))]) < 0) then
        Computer.Perform(WM_DESKACTIVATE, 0, 0)
      else
      begin
        DisableMouseMonitor;
        GetCursorPos(p);
        SysMenu.Popup(p.X, p.Y);
        SetMouseMonitor;
      end;
    if (Button = mbLeft) then
    begin
      if Cursor <> crSizeNS then
      begin
        Cursor := crDrag; { 2.2 }
        SetCursor(Screen.Cursors[crDrag]);
        RefreshCursor;
      end
      else
      begin
        ChangingRows := True;
      end;
      WasDragged := False;
    end;
  end;
end;

procedure TTaskbar.TaskButtonMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
  p: TPoint;
begin
  { To remember which button the right mouse button was pressed over,
    the Tag is used rather than using the PopupComponent property --
    just in case the button gets deleted before the menu click occurs }
  if Button = mbLeft then Exit;
  TaskMenu.Tag := (Sender as TTaskButton).Window; { save window handle }
  DisableMouseMonitor;
  GetCursorPos(p);
  { 2.3 Original code moved to ShowRealSystemMenu procedure below }
  if ShowRealSysMenu then ShowRealSystemMenu(p) { 2.2 }
  else TaskMenu.Popup(p.X, p.Y);
  SetMouseMonitor;
end;

{ Next procedure was extracted from TTaskbar.TaskButtonMouseDown
  method above, because now it is used by both the taskbar buttons
  and applet tray programs (if applet is running) }

procedure TTaskbar.ShowRealSystemMenu(p: TPoint); { 3.0 }
const
  EnableFlags: array[Boolean] of Word = (MF_GRAYED, MF_ENABLED);
var
  m: HMenu;
  Wnd: HWND;
  Style: Longint;
  Zoomed, Iconic, E: Boolean;
begin
  { 2.2 uses the window's own system menu.  For some reason, calling
    TrackPopupMenu with the window itself as a parameter doesn't work
    properly, so a helper window is used to collect the WM_COMMAND
    messages and relay them to the target window }
  Wnd := TaskMenu.Tag;
  Zoomed := IsZoomed(Wnd);
  Iconic := IsIconic(Wnd);
  Style := GetWindowLong(Wnd, GWL_STYLE);
  E := IsWindowEnabled(Wnd);
  m := GetSystemMenu(TaskMenu.Tag, False);
  EnableMenuItem(m, SC_RESTORE, MF_BYCOMMAND or EnableFlags[E and (Zoomed or Iconic)]);
  EnableMenuItem(m, SC_MOVE, MF_BYCOMMAND or EnableFlags[E and not Zoomed]);
  EnableMenuItem(m, SC_SIZE, MF_BYCOMMAND or EnableFlags[E and not
    (Zoomed { 3.0 } or Iconic or (Style and WS_THICKFRAME = 0))]);
  EnableMenuItem(m, SC_MINIMIZE, MF_BYCOMMAND or EnableFlags[E and not Iconic and (Style and WS_MINIMIZEBOX <> 0)]);
  EnableMenuItem(m, SC_MAXIMIZE, MF_BYCOMMAND or EnableFlags[E and not Zoomed and (Style and WS_MAXIMIZEBOX <> 0)]);
  EnableMenuItem(m, SC_CLOSE, MF_BYCOMMAND or EnableFlags[E]);
  SendMessage(Wnd, WM_INITMENUPOPUP, m, MakeLong(0, 1));
  TrackPopupMenu(m, TPM_LEFTALIGN or TPM_RIGHTBUTTON, p.X, p.Y, 0, MenuHelper, nil);
end;

procedure TTaskbar.TaskRestoreClick(Sender: TObject);
begin
  ShowWindow(TaskMenu.Tag, SW_RESTORE);
end;

procedure TTaskbar.TaskMinimizeClick(Sender: TObject);
begin
  CloseWindow(TaskMenu.Tag);
end;

procedure TTaskbar.TaskMaximizeClick(Sender: TObject);
begin
  ShowWindow(TaskMenu.Tag, SW_SHOWMAXIMIZED);
end;

procedure TTaskbar.TaskCloseClick(Sender: TObject);
begin
  PostMessage(TaskMenu.Tag, WM_CLOSE, 0, 0);
end;

procedure TTaskbar.TaskMenuPopup(Sender: TObject);
var
  Wnd: HWND;
  Style: Longint;
  Zoomed, Iconic, E: Boolean;
begin
  with TaskMenu do
  begin
    Wnd := Tag;
    Zoomed := IsZoomed(Wnd);
    Iconic := IsIconic(Wnd);
    Style := GetWindowLong(Wnd, GWL_STYLE);
    E := IsWindowEnabled(Wnd);
    TaskRestore.Enabled := E and (Zoomed or Iconic);
    TaskMinimize.Enabled := E and not Iconic and (Style and WS_MINIMIZEBOX <> 0);
    TaskMaximize.Enabled := E and not Zoomed and (Style and WS_MAXIMIZEBOX <> 0);
    TaskClose.Enabled := E;
  end;
end;

procedure TTaskbar.TerminateClick(Sender: TObject);
var
  i: Integer;
begin
  { Start terminate mode by disabling buttons and setting crTerminate cursor }
  StartButton.Enabled := False;
  with ButtonList do for i := 0 to Count - 1 do
  begin
    Buttons[i].Down := False;
    Buttons[i].Enabled := False;
  end;
  Cursor := crTerminate;
  Pressed := -1;
end;

procedure TTaskbar.SysMenuPopup(Sender: TObject);
begin
  Terminate.Enabled := ButtonList.Count > 0;
end;

procedure TTaskbar.FormResize(Sender: TObject);
begin
  Clock.Left := ClientWidth - Clock.Width - 2;
end;

procedure TTaskbar.UpdateApplets;
var
  i: Integer;
begin
  with Clock do
    for i := 0 to ControlCount - 1 do
      if Controls[i] is TTrayProgram then
        TTrayProgram(Controls[i]).CheckModule;
end;

procedure TTaskbar.ClockMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  SetClock(IntToStr(GetFreeSpace(0) div 1024) + ' KB');
end;

procedure TTaskbar.ClockMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  SetClock(FormatDateTime(ConciseDT, Now));
end;

procedure TTaskbar.ClockMouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
begin
  if Cursor = crTerminate then Exit; { 3.0 }
  Cursor := crDefault;
  if (Sender = HintControl) or ((Sender is TTaskButton) and not ButtonHints) or
    ((Sender = Clock) and not (PopupRes or PopupDate)) then Exit;
  HintControl := Sender as TControl;
  if Hintwindow.Visible then
    ActivateHint(HintControl.ClientToScreen(Point(X, Y)))
  else HintTimer.Enabled := True;
end;

procedure TTaskbar.WMSysCommand(var Msg: TWMSysCommand);
begin
  if Msg.CmdType = SC_SCREENSAVE then HideBar
  else if Msg.CmdType = SC_CLOSE then Exit;
  inherited;
end;

procedure TTaskbar.WMDropFiles(var Msg: TWMDropFiles);
var
  p: TPoint;
  i: Integer;
  Wnd: HWND;
  control: TControl;
begin
  inherited;
  { Find the target window and check that it accepts files before
    forwarding the message on }
  DragQueryPoint(Msg.Drop, p);
  control := ControlAtPos(p, False);
  if control <> nil then with ButtonList do
  begin
    i := IndexOf(control);
    if (i > -1) and (Buttons[i].WindowType = wtGeneral) then begin
      Wnd := Buttons[i].Window;
      if GetWindowLong(Wnd, GWL_EXSTYLE) and WS_EX_ACCEPTFILES <> 0 then begin
        PostMessage(Wnd, WM_DROPFILES, Msg.Drop, Msg.Unused);
        Exit;
      end;
    end;
  end;
  { release files after an error }
  DragFinish(Msg.Drop);
  MessageBeep(MB_ICONHAND);
end;

type
  TProtectedControl = class(TControl);

procedure TTaskbar.Configure;

procedure AddApplet(applet: TGraphicControl);
begin
  with Clock do
  begin
    Alignment := taRightJustify;
    Left := Left - 20;
    Width := Width + 20;
  end;
  applet.Parent := Clock;
  applet.Left := Clock.ControlCount * 20;
  TProtectedControl(applet).OnMouseMove := ClockMouseMove;
end;

procedure AddQuickBtn(applet: TGraphicControl);
begin
  with QuickBar do
    Width := Width + 22;
  applet.Parent := QuickBar;
  applet.Left := (QuickBar.ControlCount - 1) * 22;
  TProtectedControl(applet).OnMouseMove := ClockMouseMove;
end;

var
  i: Integer;
  s: string;
  tp: TTrayProgram;
  TrayApps: TStringList;
begin
  { reads settings and adjusts controls to reflect the changes }
  Excludes.Free;
  Excludes := TStringList.Create;
  with ini do
  begin
    Color := Colors[ccTaskbar];
    ReadStrings('Exclude', Excludes);
    HintTimer.Interval := ReadInteger('Taskbar', 'HintDelay', 800);
    UseMouseHook := ReadBool('Taskbar', 'UseMouseHook', True);
    StayVisible1.Checked := StayVisible;
    if Clock24 then
      ConciseDT := ReadString('Taskbar', '24HourFormat', 'h:mm')
    else
      ConciseDT := ReadString('Taskbar', '12HourFormat', 'h:mm AM/PM');
    FullDT := ReadString('Taskbar', 'FullDateTime', 'dddd, mmmm d, yyyy');
    with StartButton do
    begin
      Caption := ReadString('Start button', 'Caption', 'Start');
      Left := ReadInteger('Start button', 'Left', Left);
      Width := ReadInteger('Start button', 'Width', Width);
      s := FileWritePath + 'STARTBTN.BMP';
      if not FileExists(s) then
        s := ApplicationPath + 'STARTBTN.BMP';
      if FileExists(s) then Glyph.LoadFromFile(s);
    end;
    with QuickBar do
    begin
      BevelOuter := bvNone;
      Left := StartButton.Left + StartButton.Width + 8;
    end;
    ReadFont('Taskbar', Font);
    ReadFont('Start button', StartButton.Font);
  end;
  SetMaxEnabled(StayVisible1.Checked and ShrinkMax);
  { Clear Calmira buttons if they have been turned off, and also
    adjust button states }
  with ButtonList do
    for i := Count - 1 downto 0 do with Buttons[i] do
      if (not IconWindowTask and (WindowType = wtIconWindow)) or
        (not ExplorerTask and (WindowType = wtExplorer)) then
      begin
        Free;
        ButtonList.Delete(i)
      end
      else
      begin
        GroupIndex := 1;
        Down := False;
      end;
  { Clear the Applet Tray }
  with Clock do
  begin
    i := ControlCount * 20;
    Left := Left + i;
    Width := Width - i;
    while ControlCount > 0 do Controls[0].Free;
  end;
  Clock.Alignment := taCenter;
  { Load Applet Tray programs }
  TrayApps := TStringList.Create;
  ini.ReadSectionValues('Applet Tray', TrayApps);
  for i := 0 to TrayApps.Count - 1 do
  begin
    s := TrayApps[i];
    tp := TTrayProgram.Create(Self);
    tp.SetProgram(GetStrValue(EnvironSubst(s)));
    tp.Hint := GetStrKey(s);
    AddApplet(tp);
    Excludes.Add(ExtractFilename(GetStrValue(s)));
  end;
  { Clear the QuickBar }
  with QuickBar do
  begin
    Width := 0;
    while ControlCount > 0 do Controls[0].Free;
  end;
  { Load QuickBar aliases }
  TrayApps.Clear;
  FindFiles(FileWritePath { 2.2a } + 'TRAY\*' + AliasExtension,
    faAnyFile and not faDirectory, TrayApps);
  for i := 0 to TrayApps.Count - 1 do
    AddQuickBtn(TQuickButton.Create(Self, FileWritePath { 3.1 bugfix } +
      'TRAY\' + TrayApps[i]));
  TrayApps.Free;
  Invalidate;
  TimerTimer;
end;

procedure TTaskbar.StayVisible1Click(Sender: TObject);
begin
  StayVisible1.Checked := not StayVisible1.Checked;
  SetMaxEnabled(StayVisible1.Checked and ShrinkMax);
  SetMouseMonitor;
end;

procedure TTaskbar.HideTaskbar1Click(Sender: TObject);
begin
  HideBar;
end;

procedure TTaskbar.SetMouseMonitor;
begin
  if not TopTaskBar then
  begin
    if HintWindow.Visible or ((Top < (Screen.Height - 1)) and
      not StayVisible1.Checked) then EnableMouseMonitor
    else DisableMouseMonitor;
  end
  else
    if HintWindow.Visible or ((Top > (-Height + 1)) and
      not StayVisible1.Checked) then EnableMouseMonitor
    else DisableMouseMonitor;
end;

procedure TTaskbar.CancelHint;
begin
  with HintWindow do
  begin
    Visible := False;
    if HandleAllocated then ShowWindow(Handle, SW_HIDE);
  end;
  HintControl := nil;
  SetMouseMonitor;
end;

procedure TTaskbar.ActivateHint(P: TPoint);
var
  HintStr: string;
  fname, cname: string[127];
  buf: array[0..255] of Char;
  rect: TRect;
begin
  if HintControl = nil then Exit;
  if HintWindow.HandleAllocated then ShowWindow(HintWindow.Handle, SW_HIDE);
  if HintControl = Clock then
  begin
    HintStr := '';
    if PopupDate then AppendStr(Hintstr, FormatDateTime(FullDT, Now));
    if PopupRes then AppendStr(Hintstr, #13#10 +
      Format('System %d%%  GDI %d%%  User %d%%',
      [GetFreeSystemResources(GFSR_SYSTEMRESOURCES),
       GetFreeSystemResources(GFSR_GDIRESOURCES),
       GetFreeSystemResources(GFSR_USERRESOURCES)]));
  end
  else if HintControl is TTaskButton then
  begin
    HintStr := HintControl.Hint;
    if Spy.Checked then
    begin
      GetModuleAndClass(TTaskButton(HintControl).Window, fname, cname);
      AppendStr(HintStr, #13#10 +
        Format('Module = %s  Class = %s', [LowerCase(ExtractFilename(fname)), cname]));
    end;
  end
  else HintStr := HintControl.Hint;
  { 3.11 hint positioning redone to accomodate multi-line hints,
    now calculates the width of the hint based on HintStr and MaxWidth. }
  rect := Bounds(0, 0, Screen.Width, 0);
  DrawText(HintWindow.Canvas.Handle, StrPCopy(buf, HintStr), -1, rect,
    DT_CALCRECT or DT_LEFT or DT_WORDBREAK or DT_NOPREFIX);
  { 2.2 }
  if TopTaskbar then
    OffsetRect(rect, HintControl.ClientToScreen(Point(0, 0)).X,
      HintControl.ClientToScreen(Point(0, 0)).Y + OneRowHeight + 4)
  else
    OffsetRect(rect, HintControl.ClientToScreen(Point(0, 0)).X,
      HintControl.ClientToScreen(Point(0, 0)).Y - HeightOf(rect) - 8);
  Inc(rect.Right, 6);
  Inc(rect.Bottom, 2);
  with HintWindow do
  begin
    Color := Application.HintColor; { 2.2 }
    ActivateHint(rect, HintStr);
    Visible := True;
  end;
  EnableMouseMonitor;
end;

procedure TTaskbar.HintTimerTimer(Sender: TObject);
var
  P: TPoint;
  Control: TControl;
begin
  GetCursorPos(P);
  Control := FindDragTarget(P, True);
  if Control = HintControl then ActivateHint(P);
  HintTimer.Enabled := False;
end;

procedure TTaskbar.SpyClick(Sender: TObject);
begin
  with Spy do Checked := not Checked;
end;

procedure TTaskbar.WMHideQuery(var Msg: TMessage);
var
  i: Integer;
begin
  if HideMinApps then
  begin
    i := WndToButton(Msg.wParam);
    if i > -1 then
    begin
      MoveDesktopIcon(Msg.wParam, Point(0, Screen.Height));
      Exit;
    end;
  end;
  if ArrangeMin then RaiseWindow(Msg.wParam);
end;

procedure TTaskbar.WMWinActivate(var Msg: TMessage);
var
  i: Integer;
begin
  if not InTaskClick then
  begin
    i := HiddenList.IndexOf(Pointer(Msg.wParam));
    if (i > -1) and IsVisibleTaskWindow(Msg.wParam) then
    begin
      if not ShouldExclude(msg.wParam) then
        PostMessage(Handle, WM_ADDBUTTON, Word(HiddenList[i]), 0);
      HiddenList.Delete(i);
    end
    else Press(Msg.WParam);
  end;
end;

procedure TTaskbar.WMMouseActivate(var Msg: TWMMouseActivate);
begin
  Msg.Result := MA_NOACTIVATE;
end;

procedure TTaskbar.WMAddButton(var Msg: TMessage);
begin
  AddButton(Msg.wParam);
  Press(Msg.wParam);
end;

procedure TTaskbar.StartPropertiesClick(Sender: TObject);
begin
  Computer.ConfigStartMenu.Click;
end;

procedure TTaskbar.TaskbarPropertiesClick(Sender: TObject);
begin
  Computer.ConfigTaskbar.Click;
end;

procedure TTaskbar.SetClock(const s: string);
begin
  with Clock do
    if ControlCount > 0 then Caption := s + '  ' else Caption := s;
end;

procedure TTaskbar.WMEnable(var Msg: TWMEnable);
begin
  inherited;
  SetWindowLong(Handle, GWL_STYLE, GetWindowLong(Handle, GWL_STYLE) and
    not WS_DISABLED);
end;

procedure TTaskbar.ClockDblClick(Sender: TObject);
var
  buf: array[0..255] of Char;
begin
  WinExec(StrPCopy(buf, EnvironSubst(ini.ReadString('Taskbar', 'AdjustClock',
    'control.exe main.cpl Date/Time'))), SW_SHOWNORMAL);
end;

procedure TTaskbar.StartKeyPopup;
var
  temp: Boolean;
begin
  if StartButton.Down then Exit;
  if not BarShowing then ShowBar;
  StartButton.Down := True;
  temp := StartMouseUp;
  StartMouseUp := True;
  StartButton.Click;
  StartMouseUp := temp;
end;

function MinimizeProperTasks(Wnd: HWnd; lParam: Longint): Bool; export; { 2.2 }
begin
  if IsProperTaskWindow(Wnd) and IsWindowVisible(Wnd) and
    not (Wnd = Application.Handle) { 3.0 } then
      Taskbar.ShowMinimized(Wnd);
  Result := True;
end;

procedure TTaskbar.MinimizeAll; { 2.2 }
begin
  EnumWindows(@MinimizeProperTasks, 0);
end;

procedure TTaskbar.ShowMinimized(Wnd: HWND);
begin
  if not IsIconic(Wnd) and (GetWindowLong(Wnd, GWL_STYLE) and
    WS_MINIMIZEBOX <> 0) then
    begin
      ShowWindow(Wnd, SW_SHOWMINIMIZED);
      Perform(WM_HIDEQUERY, Wnd, 0);
    end;
end;

procedure TTaskbar.MinimizeList(wnds: TList);
var
  i: Integer;
begin
  for i := 0 to wnds.Count - 1 do ShowMinimized(HWnd(wnds[i]));
end;

procedure TTaskbar.UpdateStartButtonState;
var
  p: TPoint;
begin
  GetCursorPos(p);
  with StartButton do
    if not (PtInRect(ClientRect, ScreenToClient(p)) {and MousePressed}) then
      Down := False;
end;

procedure TTaskbar.StartButtonClick(Sender: TObject);
var
  p: TPoint;
  Msg: TMessage;
  MousePressed: Boolean;
begin
  if StartMouseUp and StartButton.Down then
  begin
    DisableMouseMonitor;
    if TopTaskbar then { 2.2 }
      StartMenu.Popup(StartButton.Left, StartButton.Height + 2, True)
    else
      StartMenu.Popup(StartButton.Left, Top - StartMenu.Height + 3, True);
    UpdateStartButtonState;
    GetCursorPos(p);
    if not (StayVisible1.Checked or PtInRect(BoundsRect, p)) then HideBar;
    SetMouseMonitor;
  end;
end;

procedure TTaskbar.StartButtonMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
  p: TPoint;
begin
  if Button = mbRight then
  begin
    DisableMouseMonitor;
    GetCursorPos(p);
    SysMenu.Popup(p.X, p.Y);
    SetMouseMonitor;
  end
  else if not StartMouseUp then
  begin
    { Restore start button state by simulating a mouse click }
    DisableMouseMonitor;
    StartButton.Down := True;
    Update;
    { 2.2 }
    if TopTaskbar then
      StartMenu.Popup(StartButton.Left, Height div RowCount - 3, True)
    else
      StartMenu.Popup(StartButton.Left, Top - StartMenu.Height + 3, True);
    PostMessage(Handle, WM_LBUTTONUP, 0,
      MakeLong(StartButton.Left + X, StartButton.Top + Y));
  end;
end;

procedure TTaskbar.TaskButtonDragOver(Sender, Source: TObject; X,
  Y: Integer; State: TDragState; var Accept: Boolean);
var
  IconWindow: TIconWindow;
begin
  with Sender as TTaskButton do
  begin
    if not Down then
    begin { 3.11 -- activate window when dragging over button }
      Down := True;
      Click;
    end;
    if WindowType = wtIconWindow then
    begin
      IconWindow := WinControl as TIconWindow;
      IconWindow.FormDragOver(IconWindow, Source, X, Y, State, Accept);
    end
    else if (WindowType = wtGeneral) and ((Source = FindList) or
      ((Source is TMultiGrid) and (Source <> Computer.Grid))) then
        Accept := GetWindowLong(Window, GWL_EXSTYLE) and WS_EX_ACCEPTFILES <> 0;
  end;
end;

procedure TTaskbar.TaskButtonDragDrop(Sender, Source: TObject; X,
  Y: Integer);
var
  IconWindow: TIconWindow;
begin
  with Sender as TTaskButton do
    if WindowType = wtIconWindow then
    begin
      IconWindow := WinControl as TIconWindow;
      IconWindow.FormDragDrop(IconWindow, Source, X, Y);
    end
    else if WindowType = wtGeneral then
      if (Source is TMultiGrid) and (Source <> Computer.Grid) then
        (TMultiGrid(Source).Owner as TIconWindow).DropServer.DropFiles(Window, Point(1,1))
      else if Source = FindList then
        FindForm.DropServer.DropFiles(Window, Point(1,1));
end;

procedure TTaskbar.FormDragOver(Sender, Source: TObject; X, Y: Integer;
  State: TDragState; var Accept: Boolean);
begin
  Accept := False;
  if not BarShowing then ShowBar;
end;

procedure TTaskbar.StartButtonMouseUp(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  p: TPoint;
begin
  if StartMouseUp then UpdateStartButtonState
  else
  begin
    GetCursorPos(p);
    SetMouseMonitor;
    if not (StayVisible1.Checked or PtInRect(BoundsRect, p)) then HideBar;;
  end;
end;

procedure TTaskbar.PositionChanged;
begin
  if not TopTaskbar then
  begin
    YTop := 0;
    YLimit := Screen.Height - (ClientHeight - 2);
  end
  else
  begin
    YTop := ClientHeight - 2;
    YLimit := Screen.Height;
  end;
  SetYLimit(YTop, YLimit);
end;

procedure TTaskbar.FormMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  if Cursor = crDrag then
  begin { 2.2 }
    Cursor := crDefault;
    if not WasDragged then Exit;
    TopTaskbar := Top = -2;
    PositionChanged;
    ini.WriteBool ('Taskbar', 'TopTaskbar', TopTaskbar);
    ArrangeButtons;
    Invalidate;
  end
  else if Cursor = crSizeNS then
  begin { 2.2 }
    Cursor := crDefault;
    ChangingRows := False;
    PositionChanged;
    ini.WriteInteger('Taskbar', 'RowCount', RowCount);
    ArrangeButtons;
    Invalidate;
  end;
end;

procedure TTaskbar.StartButtonMouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Integer);
begin
  Cursor := crDefault;
end;

procedure TTaskbar.SysMenuWndProc(var Message: TMessage);
begin
  with Message do
    if (Msg = WM_COMMAND) and (TaskMenu.Tag <> 0) then
    begin
      PostMessage(TaskMenu.Tag, WM_SYSCOMMAND, wParam, lParam);
      TaskMenu.Tag := 0;
      Result := 0;
    end
    else Result := DefWindowProc(MenuHelper, Msg, wParam, lParam);
end;

procedure TTaskbar.FormShow(Sender: TObject);
begin
  MenuHelper := AllocateHWnd(SysMenuWndProc);
end;

procedure TTaskbar.FormHide(Sender: TObject);
begin
  DeallocateHWnd(MenuHelper);
  MenuHelper := 0;
end;

procedure TTaskbar.FormDblClick(Sender: TObject);
begin
  Computer.Perform(WM_DESKACTIVATE, 0, 0);
end;

{ 3.1 }

procedure TTaskbar.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if (Key = VK_F4) and (ssAlt in Shift) then
  begin
    Key := 0;
    ShowModalDialog(TQuitDlg);
  end;
end;

procedure TTaskbar.MinimizeAll1Click(Sender: TObject);
begin
  Desktop.MinimizeWindows;
  MinimizeAll;
end;

procedure TTaskbar.TaskManagerClick(Sender: TObject);
begin
  OpenTaskManager;
end;

{ 4.0 }

procedure SaveAlias(const filename: TFilename; ref: TReference);
var
  icon: TIcon;
  s: TStreamer;
begin
  icon := TIcon.Create;
  s := TStreamer.Create(filename, fmCreate);
  try
    s.WriteString(AliasSignature);
    ref.AssignIcon(icon);
    ref.SaveToStream(s);
    icon.SaveToStream(s);
  finally
    icon.Free;
    s.Free;
  end;
end;

procedure TTaskbar.TrayOpenClick(Sender: TObject);
begin
  TQuickButton(TrayMenu.Tag).Click;
end;

procedure TTaskbar.TrayAddClick(Sender: TObject);
const
  NewAliasKind: array[Boolean] of TReferenceKind =
    (rkFile, rkInternet);
var
  F: TFilename;
  R: TReference;
begin
  if CheckDialogModal then Exit;
  ShowHourglass;
  R := TAliasReference.Create;
  with R do
  try
    Kind := NewAliasKind[Computer.BrowserLink.IsBrowserLoaded];
    if AssignFromExternal then
    begin
      F := MangleFilename(FileWritePath + 'TRAY\',
        MakeValidFilename(Copy(Caption, 1, 8)) + AliasExtension);
      if not (dfWriteable in GetDriveFlags(F[1]))then
        Exit;
      SaveAlias(F, R);
      Configure;
    end
  finally
    Free;
  end;
end;

procedure TTaskbar.TrayRemoveClick(Sender: TObject);
begin
  if EraseFile(LowerCase(TQuickButton(TrayMenu.Tag).FTrayAlias.FFilename),
    -1) then Configure;
end;

procedure TTaskbar.TrayPropertiesClick(Sender: TObject);
var
  t: TTrayAlias;
begin
  if CheckDialogModal then Exit;
  ShowHourglass;
  t := TQuickButton(TrayMenu.Tag).FTrayAlias;
  if t.FRef.Edit = mrOK then
  begin
    SaveAlias(t.FFilename, t.FRef);
    Configure;
  end;
end;

end.

