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

unit Taskman;

interface

uses SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  Forms, ExtForm, Dialogs, Buttons, StylSped, StdCtrls, Grids, Multigrd,
  Sysmenu, Menus, ExtCtrls, TabPanel, PicBtn, SortHdr;

type
  TTaskManager = class(TExtForm)
    TabPanel: TTabPanel;
    Notebook: TNotebook;
    SwitchToBtn: TStyleSpeed;
    EndTaskBtn: TStyleSpeed;
    Header: THeader;
    NewTaskBtn: TStyleSpeed;
    TaskLabel: TLabel;
    MemLabel: TLabel;
    TaskMenu: TPopupMenu;
    TaskSwitchTo: TMenuItem;
    TaskHide: TMenuItem;
    N1: TMenuItem;
    N2: TMenuItem;
    TaskMinimize: TMenuItem;
    TaskCascade: TMenuItem;
    TaskTileHorizontal: TMenuItem;
    TaskTileVertical: TMenuItem;
    N3: TMenuItem;
    TaskEndTask: TMenuItem;
    TaskTerminateTask: TMenuItem;
    TaskNewTask: TMenuItem;
    TaskRefresh: TMenuItem;
    Timer: TTimer;
    Grid: TMultiGrid;
    Bevel: TBevel;
    procedure FormDestroy(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure GridDrawCell(Sender: TObject; Index: Integer; Rect: TRect;
      State: TGridDrawState);
    procedure GridKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure GridMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure GridMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure FormPaint(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure HeaderSized(Sender: TObject; ASection, AWidth: Integer);
    procedure TaskMenuPopup(Sender: TObject);
    procedure TaskSwitchToClick(Sender: TObject);
    procedure TaskMinimizeClick(Sender: TObject);
    procedure TaskCascadeClick(Sender: TObject);
    procedure TaskTileHorizontalClick(Sender: TObject);
    procedure TaskTileVerticalClick(Sender: TObject);
    procedure TaskEndTaskClick(Sender: TObject);
    procedure TaskTerminateTaskClick(Sender: TObject);
    procedure TaskHideClick(Sender: TObject);
    procedure TaskNewTaskClick(Sender: TObject);
    procedure TaskRefreshClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormHide(Sender: TObject);
    procedure TimerTimer(Sender: TObject);
  private
    { Private declarations }
    LastActiveWindow: HWnd;
    WindowList: TList;
    TaskList: TStringList;
    procedure Configure;
    procedure AddTask(Wnd: HWnd);
    function SelectedWnd: HWnd;
    function SelectedTask: THandle;
    function GetWindowList: TList;
  public
    { Public declarations }
  end;

var
  TaskManager: TTaskManager;

procedure OpenTaskManager;

implementation

uses ToolHelp, Task, Desk, Settings, MiscUtil, Locale, Resource, Embed,
  Strings, ShellAPI, CalMsgs, RunProg;

{$R *.DFM}

procedure OpenTaskManager;
begin
  if TaskManager = nil then
    TaskManager := TTaskManager.Create(Application);
  TaskManager.Show;
end;

type
  TTaskItem = class
  public
    Wnd: HWnd;
    Icon: TIcon;
    Module: array[0..79] of Char; { 3.1 }
    constructor Create(handle: HWnd);
    destructor Destroy; override;
  end;

constructor TTaskItem.Create(handle: HWnd);
var
  h: HIcon;
begin
  Wnd := handle;
  Icon := TIcon.Create;
  GetModuleFilename(GetWindowWord(Wnd, GWW_HINSTANCE), Module, SizeOf(Module) - 1);
  { 3.1 Get window's class icon }
  h := GetClassWord(Wnd, GCW_HICON);
  if h = 0 then
  begin
    { Extract icon form file }
    h := ExtractIcon(HInstance, Module, 0);
    if h > 1 then
    begin
      Icon.Handle := CopyIcon(Hinstance, h);
      DestroyIcon(h);
      Exit;
    end
    { Use the Windows icon }
    else h := ProgIcon.Handle;
  end;
  Icon.Handle := CopyIcon(Hinstance, h);
end;

destructor TTaskItem.Destroy;
begin
  Icon.Free;
  inherited Destroy;
end;

procedure TTaskManager.FormDestroy(Sender: TObject);
var
  i: Integer;
begin
  with TaskList do
    for i := 0 to Count - 1 do Objects[i].Free;
  WindowList.Free;
  TaskList.Free;
  TaskManager := nil;
end;

procedure TTaskManager.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  Action := caFree;
  SavePosition(ini, 'Task Manager');
end;

procedure TTaskManager.AddTask(Wnd: HWnd);
var
  s: string[127];
begin
  s[0] := Chr(GetWindowText(Wnd, @s[1], SizeOf(s) - 3));
  if not IsWindowVisible(Wnd) then AppendStr(s, ' (Hidden)');
  TaskList.AddObject(s, TTaskItem.Create(Wnd));
end;

procedure TTaskManager.FormCreate(Sender: TObject);
begin
  DeleteMenu(GetSystemMenu(Handle, False), SC_SIZE, MF_BYCOMMAND);
  WindowList := TList.Create;
  TaskList := TStringList.Create;
  TaskList.Duplicates := dupAccept;
  TaskList.Sorted := False;
  MinimumWidth := 292;
  MinimumHeight := 218;
  LoadPosition(ini, 'Task Manager');
  Configure;
end;

function EnumWinProc(Wnd: HWnd; tm: TTaskManager): Bool; export;
begin
  { Adds all task windows to the manager }
  if IsProperTaskWindow(Wnd) then tm.AddTask(Wnd);
  Result := True;
end;

procedure TTaskManager.Configure;
var
  i, count: Integer;
  s: string;
  o: TObject;
begin
  with TaskList do
    for i := 0 to Count - 1 do Objects[i].Free;
  WindowList.Clear;
  TaskList.Clear;
  Grid.Focus := 0;
  Grid.DeselectAll;
  EnumWindows(@EnumWinProc, Longint(self));
  count := TaskList.Count;
  i := 0;
  while i < count do
  begin
    if not IsWindowVisible(TTaskItem(TaskList.Objects[i]).Wnd) then
    begin
      s := TaskList[i];
      o := TaskList.Objects[i];
      TaskList.Delete(i);
      TaskList.AddObject(s, o);
      Dec(count);
    end;
    Inc(i);
  end;
  for i := 0 to TaskList.Count - 1 do
    WindowList.Add(TObject(Longint(TTaskItem(TaskList.Objects[i]).Wnd)));
  LastActiveWindow := GetActiveWindow;
  with Grid do
  begin
    DefaultColWidth := Width - 2;
    Limit := TaskList.Count;
    RowCount := Limit;
    Canvas.Font.Assign(GlobalFont);
    DefaultRowHeight := LineHeight;
  end;
  TaskLabel.Caption := Format(SSNumTasks, [TaskList.Count,
    OneItem[TaskList.Count = 1]]);
  MemLabel.Caption := FormatByte(GetFreeSpace(0), 2, 2) + ' free';
end;

function TTaskManager.SelectedWnd: HWnd;
begin
  Result := 0;
  if Grid.Selected[Grid.Focus] { 4.0 } then
    Result := HWnd(TTaskItem(TaskList.Objects[Grid.Focus]).Wnd);
end;

function TTaskManager.SelectedTask : THandle;
begin
  Result := GetWindowTask(SelectedWnd);
end;

function TTaskManager.GetWindowList: TList;
var
  i: Integer;
begin
  WindowList.Clear;
  with Grid do
    for i := 0 to TaskList.Count - 1 do
      if Selected[i] or (SelCount < 1) and not
        (HWnd(TTaskItem(TaskList.Objects[i]).Wnd) = Application.Handle) { 3.0 }
          then WindowList.Add(TObject(Longint(TTaskItem(TaskList.Objects[i]).Wnd)));
  Result := WindowList;
end;

procedure TTaskManager.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if (Key = VK_ESCAPE) and not (ssCtrl in Shift) then Close;
end;

procedure TTaskManager.GridDrawCell(Sender: TObject; Index: Integer;
  Rect: TRect; State: TGridDrawState);
var
  Task: TTaskItem;
  Glyph: TBitmap;
  FocusRect: TRect;
begin
  with Grid, Canvas do
  begin
    Task := TaskList.Objects[Index] as TTaskItem;
    Glyph := TBitmap.Create;
    ShrinkIcon(Task.Icon.Handle, Glyph, Color);
    Draw(Rect.Left + 2, Rect.Top, Glyph);
    FocusRect := Rect;
    Inc(FocusRect.Left, 20);
    FocusRect.Right := FocusRect.Left + TextWidth(TaskList[Index]) + 4;
    if gdSelected in State then FillRect(FocusRect);
    TextOut(Rect.Left + 22, Rect.Top + 1, TaskList[Index]);
    if gdFocused in State then DrawFocusRect(FocusRect);
    Brush.Color := Color;
    Font.Color := clWindowText;
    with Rect do
      FillRect(Classes.Rect(Header.SectionWidth[0], Top, Right, Bottom));
    TextOut(Header.SectionWidth[0] + 2, Rect.Top + 1,
      LowerCase(ExtractFilename(StrPas(Task.Module))));
    Glyph.Free;
  end;
end;

procedure TTaskManager.GridKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  case Key of
    VK_RETURN: TaskSwitchTo.Click;
    VK_ESCAPE: if not (ssCtrl in Shift) then Close;
    Ord('A') : if ssCtrl in Shift then with Grid do
                 if SelCount > 0 then DeselectAll else SelectAll;
    VK_F5    : Configure;
  end;
end;

procedure TTaskManager.GridMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
  p: TPoint;
begin
  GetCursorPos(p);
  if Button = mbRight then
  begin
    with Grid do Select(MouseToCell(X, Y));
    TaskMenu.Popup(p.x, p.y);
  end;
end;

procedure TTaskManager.GridMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
  i: Integer;
begin
  with Grid do
  begin
    i := MouseToCell(X, Y);
    if (SelCount = Limit) and not PtInRect(CellBounds(i), Point(X, Y)) then
      DeselectAll;
  end;
end;

procedure TTaskManager.FormPaint(Sender: TObject);
var
  R: TRect;
begin
  Border3D(Canvas, ClientRect);
  R := Rect(3, ClientHeight - 21, MemLabel.Left - 8, ClientHeight - 3);
  RecessBevel(Canvas, R);
  R.Left := R.Right + 3;
  R.Right := ClientWidth - 3;
  RecessBevel(Canvas, R);
  if WindowState = wsNormal then
    Canvas.Draw(ClientWidth - 17, ClientHeight - 17, Sizebox);
end;

procedure TTaskManager.FormResize(Sender: TObject);
begin
  if WindowState <> wsMinimized then begin
    StretchShift([Header, Bevel], [stWidth]);
    StretchShift([EndTaskBtn, SwitchToBtn, NewTaskBtn], [stLeft, stTop]);
    StretchShift([TabPanel, Grid], [stWidth, stHeight]);
    StretchShift([TaskLabel, MemLabel], [stTop]);
    with Grid do
      DefaultColWidth := Width - 2;
    Invalidate;
  end;
end;

procedure TTaskManager.HeaderSized(Sender: TObject; ASection,
  AWidth: Integer);
begin
  Grid.Invalidate;
end;

procedure TTaskManager.TaskMenuPopup(Sender: TObject);
var
  Wnd: HWnd;
begin
  Wnd := SelectedWnd;
  if Wnd = 0 then Exit;
  if IsWindowVisible(Wnd) then
    TaskHide.Caption := 'H&ide'
  else
    TaskHide.Caption := 'Unh&ide'
end;

procedure TTaskManager.TaskSwitchToClick(Sender: TObject);
var
  Wnd: HWnd;
begin
  Wnd := SelectedWnd;
  if Wnd = 0 then Exit;
  if not IsWindowEnabled(Wnd) then
  begin
    MessageBeep(MB_ICONHAND);
    Exit;
  end;
  SendMessage(Wnd, WM_ACTIVATE, WA_ACTIVE, MakeLong(Wnd, Word(True)));
  if IsIconic(Wnd) then ShowWindow(Wnd, SW_RESTORE)
  else BringWindowToTop(Wnd);
end;

procedure TTaskManager.TaskHideClick(Sender: TObject);
var
  Wnd: HWnd;
begin
  Wnd := SelectedWnd;
  if Wnd = 0 then Exit;
  if IsWindowVisible(Wnd) then
  begin
    ShowWindow(Wnd, SW_HIDE);
    Taskbar.DeleteButton(Wnd);
  end
  else
  begin
    ShowWindow(Wnd, SW_SHOWNA);
    Taskbar.AddButton(Wnd);
    if IsIconic(Wnd) then Taskbar.Perform(WM_HIDEQUERY, Wnd, 0);
  end;
  if IsWindow(LastActiveWindow) then SetActiveWindow(LastActiveWindow);
  Timer.Enabled := True;
end;

procedure TTaskManager.TaskMinimizeClick(Sender: TObject);
begin
  Taskbar.MinimizeList(GetWindowList);
end;

procedure TTaskManager.TaskCascadeClick(Sender: TObject);
begin
  Desktop.CascadeList(GetWindowList);
end;

procedure TTaskManager.TaskTileHorizontalClick(Sender: TObject);
begin
  Desktop.TileHorizList(GetWindowList);
end;

procedure TTaskManager.TaskTileVerticalClick(Sender: TObject);
begin
  Desktop.TileVertList(GetWindowList);
end;

procedure TTaskManager.TaskEndTaskClick(Sender: TObject);
begin
  if SelectedWnd <> 0 then
  begin
    if SelectedWnd = Application.Handle then
    begin
      Close;
      Application.Terminate;
    end
    else
    begin
      PostMessage(SelectedWnd, WM_CLOSE, 0, 0);
      Timer.Enabled := True;
    end;
  end;
end;

procedure TTaskManager.TaskTerminateTaskClick(Sender: TObject);
begin
  if SelectedTask <> 0 then
  begin
    if MsgDialog(Format(LoadStr(SQueryTerminate), [TaskList[Grid.Focus]]),
      mtWarning, [mbYes, mbNo], 0) = mrYes then
      begin
        TerminateApp(SelectedTask, NO_UAE_BOX);
        Timer.Enabled := True;
      end;
  end;
end;

procedure TTaskManager.TaskNewTaskClick(Sender: TObject);
begin
  RunExecute('', '');
end;

procedure TTaskManager.TaskRefreshClick(Sender: TObject);
begin
  Configure;
end;

procedure TTaskManager.FormShow(Sender: TObject);
begin
  TaskBar.AddButton(Handle);
end;

procedure TTaskManager.FormHide(Sender: TObject);
begin
  Timer.Enabled := False;
  TaskBar.DeleteButton(Handle);
end;

procedure TTaskManager.TimerTimer(Sender: TObject);
begin
  Timer.Enabled := False;
  TaskManager.Configure;
end;

end.

