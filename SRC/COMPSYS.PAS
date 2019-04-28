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

unit Compsys;

{ Computer unit

  This form is the "acting" main form, even though Application.MainForm
  actually points to the splash screen.  TComputer handles system
  messages and other operations which are global to Calmira.  Desktop
  interaction is handled here too but most tasks are delegated to
  TDesktop to perform. }

interface

uses SysUtils, WinTypes, Messages, Classes, Controls, Forms, Dialogs,
  Iconic, Menus, DragDrop, Dropclnt, Multigrd, DropServ, CalMsgs, Hooks,
  Grids, Start, Apholder, ObjList, ExtForm, CalForm, DdeMan, Settings,
  Sysmenu, Internet, ExtCtrls, StdCtrls;

type
  TComputer = class(TCalForm)
    WindowMenu: TPopupMenu;
    About: TMenuItem;
    HelpContents: TMenuItem;
    Find: TMenuItem;
    Grid: TMultiGrid;
    App: TAppHolder;
    DropServer: TDropServer;
    RefreshSys: TMenuItem;
    DesktopMenu: TPopupMenu;
    DeskProperties: TMenuItem;
    DeskArrangeIcons: TMenuItem;
    DeskClearDesktop: TMenuItem;
    DeskCloseBrowsers: TMenuItem;
    ConfigFileSystem: TMenuItem;
    ConfigDesktop: TMenuItem;
    ConfigStartMenu: TMenuItem;
    ConfigBin: TMenuItem;
    ConfigTaskbar: TMenuItem;
    ObjectMenu: TPopupMenu;
    Properties: TMenuItem;
    CreateAlias: TMenuItem;
    SysProperties: TMenuItem;
    DeskCascadeBrowsers: TMenuItem;
    DeskLineUpIcons: TMenuItem;
    N2: TMenuItem;
    TopicSearch: TMenuItem;
    N5: TMenuItem;
    DeskFind: TMenuItem;
    DeskRun: TMenuItem;
    Run: TMenuItem;
    DeskOpen: TMenuItem;
    DeskExplore: TMenuItem;
    DeskMinimizePrograms: TMenuItem;
    DeskArrange: TMenuItem;
    NewShort: TMenuItem;
    NewFileShort: TMenuItem;
    NewFolderShort: TMenuItem;
    NewNetShort: TMenuItem;
    Open: TMenuItem;
    BrowserLink: TBrowserLink;
    Timer: TTimer;
    DragTimer: TTimer;
    NewDriveShort: TMenuItem;
    DeskRepaint: TMenuItem;
    Tipoftheday1: TMenuItem;
    Help1: TMenuItem;
    Progman: TDdeServerConv;
    {Groups: TDdeServerItem;}
    DeskRestoreShortcuts: TMenuItem;
    N1: TMenuItem;
    N4: TMenuItem;
    DeskArrangeShortcuts: TMenuItem;
    N6: TMenuItem;
    N7: TMenuItem;
    DeskMinimizeBrowsers: TMenuItem;
    N8: TMenuItem;
    StatusLabel: TLabel;
    Settings: TMenuItem;
    N9: TMenuItem;
    N3: TMenuItem;
    Explore: TMenuItem;
    OpenFolder: TMenuItem;
    N10: TMenuItem;
    procedure FormDestroy(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure GridDblClick(Sender: TObject);
    procedure CreateAliasClick(Sender: TObject);
    procedure PropertiesClick(Sender: TObject);
    procedure AboutClick(Sender: TObject);
    procedure HelpContentsClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FindClick(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure GridDrawCell(Sender: TObject; Index: Integer; Rect: TRect;
      State: TGridDrawState);
    procedure GridSelectCell(Sender: TObject; Index: Integer;
      var CanSelect: Boolean);
    procedure DropServerFileDrag(Sender: TObject; X, Y: Integer;
      Target: Word; var Accept: Boolean);
    procedure GridMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure DropServerDeskDrop(Sender: TObject; X, Y: Integer;
      Target: Word);
    procedure AppException(Sender: TObject; E: Exception);
    procedure AppShowHint(var HintStr: OpenString; var CanShow: Boolean;
      var HintInfo: THintInfo);
    procedure GridMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure AppMessage(var Msg: TMsg; var Handled: Boolean);
    procedure GridEndDrag(Sender, Target: TObject; X, Y: Integer);
    procedure AppActivate(Sender: TObject);
    procedure AppDeactivate(Sender: TObject);
    procedure RefreshSysClick(Sender: TObject);
    procedure FormPaint(Sender: TObject);
    procedure DeskPropertiesClick(Sender: TObject);
    procedure DeskArrangeIconsClick(Sender: TObject);
    procedure DeskArrangeShortcutsClick(Sender: TObject);
    procedure DeskRestoreShortcutsClick(Sender: TObject);
    procedure DeskClearDesktopClick(Sender: TObject);
    procedure DeskMinimizeBrowsersClick(Sender: TObject);
    procedure DeskCloseBrowsersClick(Sender: TObject);
    procedure ConfigDesktopClick(Sender: TObject);
    procedure ConfigStartMenuClick(Sender: TObject);
    procedure ConfigBinClick(Sender: TObject);
    procedure ConfigTaskbarClick(Sender: TObject);
    procedure ConfigFileSystemClick(Sender: TObject);
    procedure ObjectMenuPopup(Sender: TObject);
    procedure SysPropertiesClick(Sender: TObject);
    procedure DeskCascadeBrowsersClick(Sender: TObject);
    procedure DeskLineUpIconsClick(Sender: TObject);
    procedure TopicSearchClick(Sender: TObject);
    function AppWndProc(var Message: TMessage): Boolean;
    procedure DeskOpenClick(Sender: TObject);
    procedure RunClick(Sender: TObject);
    procedure DeskExploreClick(Sender: TObject);
    procedure GridKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure FormDragOver(Sender, Source: TObject; X, Y: Integer;
      State: TDragState; var Accept: Boolean);
    procedure FormDragDrop(Sender, Source: TObject; X, Y: Integer);
    procedure DeskMinimizeProgramsClick(Sender: TObject);
    procedure NewNetShortClick(Sender: TObject);
    procedure TimerTimer(Sender: TObject);
    procedure DragTimerTimer(Sender: TObject); { 3.11 }
    procedure DeskRepaintClick(Sender: TObject);
    procedure Tipoftheday1Click(Sender: TObject);
    procedure ProgmanOpen(Sender: TObject);
    procedure ProgmanExecuteMacro(Sender: TObject; Msg: TStrings);
    procedure ProgmanClose(Sender: TObject);
  private
    { Private declarations }
    Selected: TComputerIcon;
    FItems: TObjectList;
    procedure WMCommand(var Msg: TWMCommand); message WM_COMMAND;
    procedure WMSysCommand(var Msg: TWMSysCommand); message WM_SYSCOMMAND;
    procedure WMSysColorChange(var Msg: TWMSysColorChange); message WM_SYSCOLORCHANGE; { 3.25 }
    procedure WMNCRButtonDown(var Msg: TWMNCRButtonDown); message WM_NCRBUTTONDOWN;
    procedure WMDeskMenu(var Msg: TMessage); message WM_DESKMENU;
    procedure WMDeskActivate(var Msg: TMessage); message WM_DESKACTIVATE;
    procedure WMKeyboardHook(var Msg: TMessage); message WM_KEYBOARDHOOK;
    procedure WMKeyboardAction(var Msg: TMessage); message WM_KEYBOARDACTION;
    procedure WMWindowsKey(var Msg : TMessage); message WM_WINDOWSKEY; { 2.2 }
    procedure WMWindowsKeyAct(var Msg: TMessage); message WM_WINDOWSKEYACT; { 2.2 }
    procedure WMFileSysChange(var Msg: TMessage); message WM_FILESYSCHANGE; { 3.2 }
  public
    { Public declarations }
    procedure Configure;
    procedure SettingsChanged(Changes: TSettingChanges); override;
    procedure ExecuteMacro(Sender: TObject; const macro: string; params: string);
    procedure ExecuteScript(const filename: TFilename; EraseFile: Boolean);
    property Items: TObjectList read FItems;
  end;

(*
const
  { Custom system menu commands }
  SC_ARRANGEICONS    = SC_VSCROLL + 1024;
  SC_CLEARDESKTOP    = SC_VSCROLL + 1056;
  SC_CLOSEBROWSERS   = SC_VSCROLL + 1088;
  SC_ABOUT           = SC_VSCROLL + 1120;
  SC_CASCADEBROWSERS = SC_VSCROLL + 1152;
  SC_LINEUPICONS     = SC_VSCROLL + 1184;
  SC_PROPERTIES      = SC_VSCROLL + 1216;
*)

var
  Computer: TComputer;
  LastErrorMode: Integer;
  LastDeskClick: TPoint;
  FileSysChangeOn: Boolean;

function IsDialogModal: Boolean;
function CheckDialogModal: Boolean;
procedure KeyCommand(const title: string);
function ProvideLastIcon(Instance: Word): HIcon;

implementation

{$R *.DFM}

uses Desk, Shorts, DiskProp, Directry, About, IconWin, WinProcs, Drives,
  FileFind, IniFiles, Resource, Strings, MiscUtil, Files, FileMan, Environs,
  WasteBin, Graphics, Tree, ShutDown, RunProg, Referenc, ChkList, ShellAPI,
  StrtProp, DeskProp, TaskProp, SysProp, FSysProp, BinProp, ClipBrd, Tips,
  Locale, Task, TaskMan, Embed, GotoFld;

{ This unit is responsible for opening various non-modal windows.
  Inconsistencies will arise if non-modal icon windows are opened while
  a modal dialog is showing, so the IsDialogModal function is used. }

function IsDialogModal: Boolean;
begin
  Result := not IsWindowEnabled(Application.MainForm.Handle);
end;

function CheckDialogModal: Boolean;
var
  Msg: string[79];
begin
  Result := IsDialogModal;
  if Result then
  begin
    if Screen.ActiveForm = nil then
      Msg := LoadStr(SCloseUnnamedDialog)
    else
      Msg := FmtLoadStr(SCloseSpecificDialog, [Screen.ActiveForm.Caption]);
    MsgDialog(Msg, mtInformation, [mbOK], 0);
  end;
end;

procedure TComputer.FormDestroy(Sender: TObject);
begin
  StopFileMonitor; { 3.2 }
  ReleaseDesktopHook;
  FItems.Free;
end;

procedure TComputer.FormResize(Sender: TObject);
begin
  if WindowState <> wsMinimized { 3.0 } then
  begin
    StretchShift([Grid], [stWidth, stHeight]);
    StretchShift([StatusLabel], [stTop]);
    Grid.SizeGrid; { 3.1a }
    Selected := nil;
    Invalidate;
  end;
end;

procedure TComputer.GridDblClick(Sender: TObject);
begin
  if Selected <> nil then Selected.Open;
end;

procedure TComputer.CreateAliasClick(Sender: TObject);
var
  filename : TFilename;
begin
  if Selected is TDrive then
    filename := 'c:\drive' + LowCase(TDrive(Selected).Letter) + AliasExtension
  else
    filename := ChangeFileExt(TProgram(Selected).Filename, AliasExtension);
  Selected.WriteAlias(Lowercase(filename));
end;

procedure TComputer.PropertiesClick(Sender: TObject);
begin
  if Selected is TDrive then DiskPropExecute(TDrive(Selected).Letter);
end;

procedure TComputer.AboutClick(Sender: TObject);
begin
  ShowModalDialog(TAboutBox);
end;

procedure TComputer.AppException(Sender: TObject; E: Exception);
begin
  { Use MessageDialog to display exception messages because
    the forms look nicer in a small font }
  MsgDialog(E.Message, mtError, [mbOK], E.HelpContext);
end;

procedure TComputer.WMCommand(var Msg: TWMCommand);
var
  item: TMenuItem;
begin
  item := StartMenu.FindItem(Msg.ItemID, fkCommand);
  if item <> nil then item.Click;
  inherited;
end;

procedure TComputer.WMSysCommand(var Msg: TWMSysCommand);
begin
  case Msg.CmdType and $FFF0 of
    SC_RESTORE         : if SystemDrivesChanged then
                           RefreshSys.Click;
   {SC_ARRANGEICONS    : DeskArrange.Click;
    SC_CLEARDESKTOP    : DeskClearDesktop.Click;
    SC_CLOSEBROWSERS   : DeskCloseBrowsers.Click;
    SC_ABOUT           : About.Click;
    SC_CASCADEBROWSERS : DeskCascadeBrowsers.Click;
    SC_LINEUPICONS     : DeskLineUpIcons.Click;
    SC_PROPERTIES      : SysProperties.Click;}
  end;
  inherited;
end;

procedure TComputer.WMSysColorChange(var Msg: TWMSysColorChange);
begin
  AnnounceSettingsChanged([scDisplay, scDesktop]);
  inherited;
end;

procedure TComputer.HelpContentsClick(Sender: TObject);
begin
  Application.HelpJump('Contents');
end;

procedure TComputer.FormCreate(Sender: TObject);
var
  i: Integer;
begin
  DeleteMenu(GetSystemMenu(Handle, False), SC_SIZE, MF_BYCOMMAND);
  Icon.Assign(Icons.Get('Computer'));
  if IsShell and ShellDDE then DdeMgr.AppName := 'PROGMAN'
  else DdeMgr.AppName := 'CALMIRA';
  FItems := TObjectList.Create;
  AppActivate(Self);
  { 3.11 -- cleaned up the popup menu
  with SystemMenu do begin
    AddSeparator;
    AddLoadStr(SMenuCascadeBrowsers, SC_CASCADEBROWSERS);
    AddLoadStr(SMenuArrangeIcons, SC_ARRANGEICONS);
    AddLoadStr(SMenuLineUpIcons, SC_LINEUPICONS);
    AddLoadStr(SMenuCloseBrowsers, SC_CLOSEBROWSERS);
    AddLoadStr(SMenuClearDesktop, SC_CLEARDESKTOP);
    AddSeparator;
    AddLoadStr(SMenuProperties, SC_PROPERTIES);
    AddLoadStr(SMenuAbout, SC_ABOUT);
    DeleteCommand(SC_SIZE);
  end;}
  StartMenu.OnStartMacro := ExecuteMacro;
  RefreshSys.Click;
  MinimumWidth := 128;
  MinimumHeight := 128;
  LoadMinPosition(ini, 'Computer');
  LoadPosition(ini, 'Computer');
  Configure;
end;

procedure TComputer.Configure;
begin
  Caption := ComputerCaption;
  Color := Colors[ccWinFrame];
  with Grid do
  begin
    Visible := False;
    Color := Colors[ccIconBack];
    SelColor := Colors[ccIconSel];
    DefaultColWidth := BrowseGrid.X;
    DefaultRowHeight := BrowseGrid.Y;
    Font.Assign(GlobalFont);
    Canvas.Font.Assign(Font);
    Visible := True;
  end;
  if ShowDeskMenu then SetDesktopHook(Handle)
  else ReleaseDesktopHook;
  if GlobalHotkeys then SetKeyboardHook(Handle)
  else ReleaseKeyboardHook;
  SetRCloseEnabled(RightClose);
  SetRButtonUpClose(RButtonUpClose);
  { 3.11 }
  Timer.Interval := ini.ReadInteger('Calmira', 'TimerInterval', 1000);
  Application.HintColor := ini.ReadColor('Calmira',
    'HintColor', $00C0FFFF);
  { 3.12 }
  if Caption = '' then
    Hide
  else
  begin
    Show;
    Resize;
    Update;
  end;
  { 3.2 }
  if FileSysChange then
    FileSysChangeOn := StartFileMonitor(Handle)
  else
  begin
    StopFileMonitor;
    FileSysChangeOn := False;
  end;
  FreeAndNil(IconMesh);
end;

procedure TComputer.FindClick(Sender: TObject);
begin
  if CheckDialogModal then Exit;
  FileFindExecute('');
end;

procedure TComputer.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  { Always ask before a shell is closed down.  The InSendMessage is
    there for a reason: a slight problem arises when Windows Setup tries
    to restart Windows -- the call to ExitWindows returns false, so
    Calmira doesn't quit and Setup backs off.  The trick is to detect
    when Setup is the "caller" using InSendMessage }
  if InSendMessage then Desktop.Save;
end;

procedure TComputer.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := caMinimize;
  if WindowState = wsMinimized then ShowModalDialog(TQuitDlg); { 3.1 }
end;

procedure TComputer.WMNCRButtonDown(var Msg: TWMNCRButtonDown);
begin
  with Msg do
    if (WindowState = wsMinimized) then
      if (HitTest = HTSYSMENU) or CompIconStart then
        StartMenu.Popup(XCursor, YCursor, False)
      else
        WindowMenu.Popup(XCursor, YCursor)
    else inherited;
end;

procedure TComputer.GridDrawCell(Sender: TObject; Index: Integer;
  Rect: TRect; State: TGridDrawState);
begin
  if Index < FItems.Count then
    TComputerIcon(FItems[Index]).Draw(Grid.Canvas, Rect, State);
end;

procedure TComputer.GridSelectCell(Sender: TObject; Index: Integer;
  var CanSelect: Boolean);
begin
   CanSelect := Index < FItems.Count;
   if CanSelect then Selected := TComputerIcon(FItems[Index])
   else Selected := nil;
end;

procedure TComputer.DropServerFileDrag(Sender: TObject; X, Y: Integer;
  Target: Word; var Accept: Boolean);
begin
  Accept := Target = GetDesktopWindow;
end;

procedure TComputer.GridMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
  i: Integer;
  p: TPoint;
  r : TRect;
begin
  if ssDouble in Shift then Exit;
  if Button = mbLeft then
  begin
    if Selected <> nil then Grid.BeginDrag(False)
  end
  else if not Grid.Dragging then
  begin
    { popup one of the menus depending on whether the cursor
      is directly over an icon }
    i := Grid.MouseToCell(X, Y);
    r := Grid.CellBounds(i);
    InflateRect(r, -((WidthOf(r) - 36) div 2), 0);
    r.Bottom := r.Top + 50;
    GetCursorPos(p);
    if PtInRect(r, Point(x, y)) and (i < Items.Count) then
    begin
      Grid.Select(i);
      ObjectMenu.Popup(p.x, p.y)
    end
    else WindowMenu.Popup(p.X, p.Y);
  end
  else
    Grid.EndDrag(False);
end;

procedure TComputer.DropServerDeskDrop(Sender: TObject; X, Y: Integer;
  Target: Word);
begin
  if CanEditSettings { 2.2 } then
    Selected.CreateShortcut.MinPosition := Point(X - 16, Y - 16);
end;

procedure TComputer.AppShowHint(var HintStr: OpenString;
  var CanShow: Boolean; var HintInfo: THintInfo);
var
  f: TDirItem;
  w: TIconWindow;
  i: Integer;
begin
  { Handles popup file hints.  A hint is shown only when there
    is no dragging taking place, otherwise the hint window will
    interfere with the focus rect.  The hint is shown slightly
    below the cursor and is forced to hide or change once the
    cursor leaves the current cell. }
  with HintInfo do
    if (HintControl is TMultiGrid) and FileHints then
      with TMultiGrid(HintControl) do
      begin
        if not (Owner is TIconWindow) then Exit;
        w := TIconWindow(Owner);
        if (GetCaptureControl <> nil) or (w.DisplayMode = dmDetails)
          then Exit; { 2.2b }
        f := w.FileAt(CursorPos.X, CursorPos.Y, True);
        CanShow := f <> nil;
        if not CanShow then Exit;
        CursorRect := CellBounds(MouseToCell(CursorPos.X, CursorPos.Y));
        with ClientToScreen(CursorPos) do HintPos := Point(X, Y + 16);
        HintStr := f.Hint;
      end;
end;

procedure TComputer.GridMouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
begin
  if Grid.Dragging then
    { 3.11 -- new DragCursor logic }
    if DropServer.CanDrop then
      ReplaceNodropCursor(HDropAlias)
    else
      RestoreNodropCursor;
end;

function EnumTitleProc(Wnd: HWND; caption: PString): Bool; export;
var
  buf: TCaption;
begin
  Result := True;
  buf[0] := Chr(GetWindowText(Wnd, @buf[1], 78));
  if CompareText(buf, caption^) = 0 then
  begin
    SendMessage(Wnd, WM_ACTIVATE, WA_ACTIVE, MakeLong(Wnd, Word(True)));
    if IsIconic(Wnd) then ShowWindow(Wnd, SW_RESTORE)
    else BringWindowToTop(Wnd);
    Result := False;
  end
end;

procedure KeyCommand(const title: string);
var
  i: Integer;
  f: TForm;
  p: TPoint;
  item: TMenuItem;
begin
  { First look for a matching form caption }
  with Screen do
    for i := 0 to FormCount - 1 do
    begin
      f := Forms[i];
      if CompareText(f.Caption, title) = 0 then
      begin
        if f is TShort then f.Perform(WM_OPENSHORT, 0, 0)
        else if f.Visible and f.Enabled then
        begin
          f.WindowState := wsNormal;
          f.BringToFront;
        end;
        Exit;
      end;
    end;
  item := StartMenu.Find(title, miAll);
  if item <> nil then
  begin
    if item.Count = 0 then item.Click
    else
    begin
      GetCursorPos(p);
      StartMenu.PopupMenuItem(item.Handle, p.x, p.y, True);
    end
  end
  else if CouldBeFolder(title) and HDirectoryExists(title) then
    Desktop.OpenFolder(title)
  else if CompareText(title, 'Start') = 0 then
    Taskbar.StartKeyPopup
  else
    EnumWindows(@EnumTitleProc, Longint(@title));
end;

procedure TComputer.WMKeyboardHook(var Msg: TMessage);
var
  i: Integer;
begin
  i := KeyMaps.IndexOfObject(TObject(Shortcut(Msg.wParam,
    KeyDataToShiftState(Msg.lParam))));
  Msg.Result := Integer(i > -1);
  if Msg.Result > 0 then PostMessage(Handle, WM_KEYBOARDACTION, i, 0);
end;

procedure TComputer.WMKeyboardAction(var Msg: TMessage);
begin
  if not IsDialogModal then
  try
    KeyCommand(KeyMaps[Msg.wParam]);
  except
    on E: Exception do Application.HandleException(E);
  end;
end;

procedure TComputer.AppMessage(var Msg: TMsg; var Handled: Boolean);
var
  Atom: TAtom;
  buf: array[0..79] of Char;
  foldername: TFilename;
begin
  with Msg do
    case Message of
      WM_KEYDOWN:
        { Check for keyboard shortcuts. }
        if not IsDialogModal then
          if not GlobalHotKeys and IsHotKey(Msg.wParam, Msg.lParam) then
            Perform(WM_KEYBOARDHOOK, Msg.wParam, Msg.lParam);
      WM_DROPFILES:
        TDropClient.CheckMessage(Msg, Handled);
      $C000..$FFFF:
        { registered messages }
        if Message = WM_CALMIRA then
        begin
          Handled := True;
          case wParam of
            CM_PREVINSTANCE:
              begin
                BringToFront;
                WindowState := wsNormal;
              end;
            CM_EXPLORER: { 3.1 }
              begin
                if Msg.lParam > 0 then
                begin
                  Atom := msg.lParam;
                  GlobalGetAtomName(Atom, buf, 79);
                  GlobalDeleteAtom(Atom);
                  foldername := StrPas(buf);
                  if buf[0]= '*' then OpenExplorer(StrPas(@buf[1]))
                  else if CouldBeFolder(foldername) then
                    Desktop.OpenFolder(foldername)
                  else if  Pos('..', foldername) = 1 then
                    Desktop.OpenFolder(MakeDirname(ExtractFilePath(GetCurrentDir)
                      + Copy(foldername, 4, 255)))
                  else if (foldername > '') and (foldername[1] in Alphas) then
                    Desktop.OpenFolder(MakePath(GetCurrentDir) + foldername)
                  else
                    Desktop.OpenFolder(ExpandFoldername(foldername, GetCurrentDir[1]));
                end
                else OpenExplorer('');
              end;
            CM_TASKMAN: { 2.2 }
              OpenTaskManager;
            CM_STARTPROP: { 3.1 }
              ConfigStartMenu.Click;
            CM_TOGGLEDESKTOP: { 4.0 }
              begin
                Desktop.MinimizeWindows;
                Taskbar.MinimizeAll;
              end;
            CM_RELOADOPTIONS:
              AnnounceSettingsChanged([scSystem, scFileSystem,
                scDesktop, scStartMenu, scBin, scTaskbar,
                scDisplay, scINIFile, sc4DOS, scDevices]);
          end;
        end;
    end;
end;

procedure TComputer.GridEndDrag(Sender, Target: TObject; X, Y: Integer);
begin
  if GetAsyncKeyState(VK_LBUTTON) >= 0 then
    DropServer.DragFinished;
end;

procedure ExecuteFolderMacro(mode: Integer; params: string);
var
  foldername: TFilename;
  filespec: string[12];
  IconWindow: TIconWindow;
begin
  MacroDisplayMode := mode;
  if params = '' then
    if not GotoFolder(params) then Exit;
  if (Pos('*', params) > 0) or (Pos('?', params) > 0) then
  begin
    filespec := ExtractFilename(params);
    foldername := ExtractFileDir(params);
  end
  else
  begin
    filespec := DefaultFilter;
    foldername := params;
  end;
  if ConfirmFolder(foldername) <> mrYes then Exit;
  IconWindow := Desktop.WindowOf(foldername);
  if IconWindow = nil then
    (*
    if (Length(filename) = 2) and (filename[1] in Alphas) and (filename[2] = ':') then
      AppendStr(filename, '\');
    if HDirectoryExists(filename) then
    begin
      Desktop.OpenFolder(filename);
    *)
    TIconWindow.Init(Application, Lowercase(foldername),
      Lowercase(filespec)).Show
  else with IconWindow do
  begin
    Dir.Filter := filespec;
    RefreshWin;
    ShowNormal;
  end;
end;

const
  MacroList : array[0..22] of PChar =
    ({0}'$Help',
     {1}'$System',
     {2}'$Bin',
     {3}'$Run',
     {4}'$Explore',
     {5}'$Find',
     {6}'$Shutdown',
     {7}'$SystemProp',
     {8}'$DesktopProp',
     {9}'$FileSystemProp',
     {10}'$TaskbarProp',
     {11}'$BinProp',
     {12}'$StartMenuProp',
     {13}'$CascadeBrowsers',
     {14}'$ArrangeIcons',
     {15}'$LineUpIcons',
     {16}'$CloseBrowsers',
     {17}'$ClearDesktop',
     {18}'$MinimizePrograms',
     {19}'$Folder',
     {20}'$LargeIconFolder',
     {21}'$SmallIconFolder',
     {22}'$ListFolder');

function FindCommand(const Cmds: array of PChar; const s: string): Integer;
var
  buf: array[0..255] of Char;
begin
  for Result := 0 to High(Cmds) do
    if StrIComp(Cmds[Result], StrPCopy(buf, s)) = 0 then Exit;
  Result := -1;
end;

procedure TComputer.ExecuteMacro(Sender : TObject; const macro: string; params : string);
var
  CommandID : Integer;
begin
  if CheckDialogModal then Exit;
  CommandID := FindCommand(MacroList, macro);
  case CommandID of
    0: Application.HelpJump('Contents'); { 3.1 }
    1: ShowNormal;
    2: Bin.ShowNormal; { 3.1 }
    3: RunExecute(params, ''); { 2.2 }
    4: OpenExplorer(params); { 3.0 }
    5: FileFindExecute(params); { 2.2 }
    6: ShowModalDialog(TQuitDlg);
    7: SysProperties.Click;
    8: ConfigDesktop.Click;
    9: ConfigFileSystem.Click;
    10: ConfigTaskbar.Click;
    11: ConfigBin.Click;
    12: ConfigStartMenu.Click;
    { 3.1a -- re-arranged macro's }
    13: DeskCascadeBrowsers.Click;
    14: DeskArrangeIcons.Click;
    15: DeskLineUpIcons.Click;
    16: DeskCloseBrowsers.Click;
    17: DeskClearDesktop.Click;
    18: DeskMinimizePrograms.Click;
    19..22: ExecuteFolderMacro(CommandID - 19, params);
  else
    MsgDialogResFmt(SUnknownCommand, [macro], mtError, [mbOK], 0);
  end;
end;

function ProvideLastIcon(Instance: Word): HIcon;
begin
  { If the last program the user executed matches the given instance
    handle, then an icon is extracted if the user specified a
    particular one }
  Result := 0;
  if Instance = LastInstance then
  begin
    if LastIconFile > '' then Result := ExtractIcon(HInstance,
      StrPChar(LastIconFile), LastIconIndex);
    LastInstance := 0;
    LastIconFile := '';
    LastIconIndex := 0;
  end;
end;

procedure TComputer.AppActivate(Sender: TObject);
begin
  LastErrorMode := SetErrorMode(SEM_FAILCRITICALERRORS);
end;

procedure TComputer.AppDeactivate(Sender: TObject);
begin
  SetErrorMode(LastErrorMode);
end;

procedure TComputer.RefreshSysClick(Sender: TObject);
var
  drive: Char;
  progs: TStringList;
  progname: TFilename;
  p: TProgram;
  i: Integer;
begin
  Selected := nil;
  FItems.ClearObjects;
  DetectDrives;
  { Add the disk drives }
  for drive := 'A' to 'Z' do
    if drive in ValidDrives then FItems.Add(TDrive.Create(drive));
  { Add the program "shortcuts" }
  progs := TStringList.Create;
  try
    ini.ReadSection('Programs', progs);
    for i := 0 to progs.Count - 1 do
    begin
      progname := EnvironSubst(progs[i]);
      if FileExists(progname) then
      begin
        p := TProgram.Create(progname);
        p.Caption := ini.ReadString('Programs', progs[i], ExtractFilename(progs[i]));
        FItems.Add(p);
      end;
    end;
  finally
    progs.Free;
  end;
  with Grid do
  begin
    Reset;
    Limit := FItems.Count;
    SizeGrid;
    Focus := 0;
  end;
  StatusLabel.Caption := Format(SSNumObjects, [FItems.Count,
    OneItem[FItems.Count = 1], '']); { 3.1 }
  Invalidate;
end;

procedure TComputer.FormPaint(Sender: TObject);
var
  R: TRect;
begin
  Border3D(Canvas, ClientRect);
  { 3.1 }
  R := Rect(3, ClientHeight - 21, ClientWidth - 3, ClientHeight - 3);
  RecessBevel(Canvas, R);
  if WindowState = wsNormal then
    Canvas.Draw(ClientWidth - 17, ClientHeight - 17, Sizebox);
end;

procedure TComputer.WMDeskMenu(var Msg: TMessage);
begin
  LastDeskClick := TPoint(Msg.lParam);
  with TPoint(Msg.lParam) do DesktopMenu.Popup(X, Y);
end;

procedure TComputer.DeskPropertiesClick(Sender: TObject);
begin
  ConfigDesktop.Click;
end;

procedure TComputer.DeskArrangeIconsClick(Sender: TObject);
begin
  Desktop.ArrangeIcons;
end;

procedure TComputer.DeskArrangeShortcutsClick(Sender: TObject);
begin
  Desktop.ArrangeShortcuts;
end;

procedure TComputer.DeskRestoreShortcutsClick(Sender: TObject);
begin
  Desktop.Revert; { 2.2 }
end;

procedure TComputer.DeskClearDesktopClick(Sender: TObject);
begin
  if not (CheckDialogModal or DesktopParent) then Application.Minimize;
end;

procedure TComputer.DeskMinimizeBrowsersClick(Sender: TObject);
begin
  if not CheckDialogModal then Desktop.MinimizeWindows;
end;

procedure TComputer.DeskCloseBrowsersClick(Sender: TObject);
begin
  if not CheckDialogModal then Desktop.CloseWindows;
end;

procedure TComputer.ConfigDesktopClick(Sender: TObject);
begin
  if not CheckDialogModal then ShowModalDialog(TDeskPropDlg);
end;

procedure TComputer.ConfigStartMenuClick(Sender: TObject);
begin
  if CheckDialogModal then Exit;
  ShowHourglass;
  if StartPropDlg = nil then
    StartPropDlg := TStartPropDlg.Create(Application);
  StartPropDlg.Show;
end;

procedure TComputer.ConfigBinClick(Sender: TObject);
begin
  if not CheckDialogModal then ShowModalDialog(TBinPropDlg);
end;

procedure TComputer.ConfigTaskbarClick(Sender: TObject);
begin
  if not CheckDialogModal then ShowModalDialog(TTaskPropDlg);
end;

procedure TComputer.ConfigFileSystemClick(Sender: TObject);
begin
  if not CheckDialogModal then ShowModalDialog(TFileSysPropDlg);
end;

procedure TComputer.ObjectMenuPopup(Sender: TObject);
begin
  CreateAlias.Enabled := Selected <> nil;
  Properties.Enabled := Selected is TDrive;
end;

procedure TComputer.SysPropertiesClick(Sender: TObject);
begin
  if not CheckDialogModal then ShowModalDialog(TSysPropDlg);
end;

procedure TComputer.DeskCascadeBrowsersClick(Sender: TObject);
begin
  if not CheckDialogModal then Desktop.Cascade;
end;

procedure TComputer.DeskLineUpIconsClick(Sender: TObject);
begin
  Desktop.SnapToGrid;
end;

procedure TComputer.TopicSearchClick(Sender: TObject);
const
  EmptyString: PChar = '';
begin
  Application.HelpCommand(HELP_PARTIALKEY, Longint(EmptyString));
end;

function TComputer.AppWndProc(var Message: TMessage): Boolean;
begin
  Result := False;
  with Message do
    case Msg of
      { The Delphi 1.0 VCL neglects to handle the WM_ENDSESSION message,
        giving Calmira no chance to clean up and save it's state.
        Calling Halt seems crude, but it actually calls all ExitProcs. }
      WM_ENDSESSION: if Bool(wParam) then Halt;
      { Another Delphi 1.0 VCL bug: When a MainMenu is not on the main
        form, it will never recieve ALT accelerators.  True is returned
        to prevent WndProc from sending the key to the main form. }
      CM_APPSYSCOMMAND: AppWndProc {Result} := Screen.ActiveForm.Menu <> nil;
    end;
end;

procedure TComputer.SettingsChanged(Changes: TSettingChanges);
begin
  if [scSystem, scFileSystem, scDesktop, scDisplay] * Changes <> [] then
    Configure;
  if [scDevices, scINIFile] * Changes <> [] then RefreshSys.Click;
  { 3.1 }
  if (scStartMenu in Changes) { 3.1 } and IsShell and ShellDDE then
    DdeMgr.AppName := 'PROGMAN'
  else DdeMgr.AppName := 'CALMIRA';
end;

procedure TComputer.DeskOpenClick(Sender: TObject);
begin
  if not CheckDialogModal then ExecuteMacro(self, '$Folder', '');
end;

procedure TComputer.RunClick(Sender: TObject);
begin
  if not CheckDialogModal then RunExecute('', '');
end;

procedure TComputer.DeskExploreClick(Sender: TObject);
begin
  if not CheckDialogModal then OpenExplorer('');
end;

procedure TComputer.GridKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
var
  item: TMenuItem;
begin
  item := WindowMenu.FindItem(Shortcut(Key, Shift), fkShortcut);
  if item <> nil then item.Click;
end;

procedure TComputer.FormDragOver(Sender, Source: TObject; X, Y: Integer;
  State: TDragState; var Accept: Boolean);
begin
  Accept := (Source is TMultiGrid) and (TMultiGrid(Source).Owner is TIconWindow);
end;

procedure TComputer.FormDragDrop(Sender, Source: TObject; X, Y: Integer);
var
  i: Integer;
begin
  with ((Source as TMultiGrid).Owner as TIconWindow).CompileSelection(False) do
    for i := 0 to Count-1 do
      with TDirItem(Items[i]) do
        NewStartItems.Values[GetTitle] := GetStartInfo;
end;

procedure TComputer.DeskMinimizeProgramsClick(Sender: TObject);
begin
  Desktop.MinimizeWindows;
  Taskbar.MinimizeAll;
end;

procedure TComputer.WMDeskActivate(var Msg: TMessage);
var
  i: Integer;
begin
  { 2.2 }
  with Application do
    if IsIconic(Handle) then ShowWindow(Handle, SW_RESTORE);
  if CheckDialogModal then Exit;
  with Screen do
    for i := FormCount - 1 downto 0 do
      if Forms[i] is TShort then ShowWindow(Forms[i].Handle, SW_SHOWNA);
  ShowWindow(Bin.Handle, SW_SHOWNA);
  ShowWindow(Self.Handle, SW_SHOWNA);
end;

procedure TComputer.NewNetShortClick(Sender: TObject);
begin
  if CanEditSettings { 2.2 } then with TShort.Create(Application) do
  begin
    Ref.Kind := TReferenceKind((Sender as TComponent).Tag);
    if Ref.AssignFromExternal then
    begin
      Caption := Ref.Caption;
      Ref.AssignIcon(Icon);
      MinPosition := LastDeskClick;
    end
    else Free;
  end;
end;

const
  RunningScript : Boolean = False;

procedure TComputer.ExecuteScript(const filename: TFilename; EraseFile: Boolean);
var
  lines: TStringList;
  next: Integer;

procedure ProcessStart;
var
  command: string;
  dir: TFilename;
  i: Integer;
begin
  dir := lines[next];
  SetCurrentDir(dir);
  i := next + 1;
  while (i < lines.Count) and (lines[i] <> '') do
  begin
    command := lines[i];
    DefaultExec(Lowercase(GetWord(command, ' ')), command, dir, SW_SHOWNORMAL);
    Inc(i);
  end;
  next := i;
end;

const
  ScriptCmds : array[0..4] of PChar = ('Explore', 'Folder', 'Start',
    'Activate', 'Macro');
var
  currentdir: TFilename;
  s: string;
  i: Integer;
begin
  if RunningScript then Exit;
  RunningScript := True;
  lines := TStringList.Create;
  try
    lines.LoadFromFile(filename);
    if EraseFile then DeleteFile(filename);
    for i := 0 to lines.Count - 1 do lines[i] := Trim(lines[i]);
    next := 0;
    while next < lines.Count do
    begin
      s := lines[next];
      if s > '' then Inc(next);
      case FindCommand(ScriptCmds, s) of
        0: OpenExplorer(lines[next]);
        1: begin
             currentdir := lines[next];
             Inc(next);
             s := lines[next];
             if CouldBeFolder(s) then
               Desktop.OpenFolder(s)
             else if  Pos('..', s) = 1 then
               Desktop.OpenFolder(MakeDirname(ExtractFilePath(currentdir) +
                 Copy(s, 4, 255)))
             else if (s > '') and (s[1] in Alphas) then
               Desktop.OpenFolder(MakePath(currentdir) + s)
             else
               Desktop.OpenFolder(ExpandFoldername(s, currentdir[1]));
           end;
        2: ProcessStart;
        3: KeyCommand(lines[next]);
        4: begin
             s := lines[next];
             ExecuteMacro(self, GetWord(s, ' '), s);
           end;
      end;
      Inc(next);
    end;
  finally
    lines.Free;
    RunningScript := False;
  end;
end;

{ 3.11 -- Calmira uses one 'global' timer to fire several events }
procedure TComputer.TimerTimer(Sender: TObject);
var
  h : Integer;
begin
  { refresh Taskbar }
  TaskBar.TimerTimer;
  { check for script file and execute }
  if EnableDosScripts and not RunningScript and FileExists(DOSScriptFilename) then
    if not IsDialogModal then
    begin
      h := FileOpen(DosScriptFilename, fmShareDenyWrite);
      if h > 0 then
      begin
        FileClose(h);
        ExecuteScript(DOSScriptFilename, True);
      end;
    end
    else MessageBeep(MB_ICONHAND);
  { 3.2 refresh icon windows (FileSysChange) }
  if FileSysChangeOn then Desktop.RefreshNow;
end;

procedure TComputer.DragTimerTimer(Sender: TObject);
begin
  RefreshCursor;
end;

procedure TComputer.DeskRepaintClick(Sender: TObject);
begin
  Desktop.Repaint;
end;

procedure TComputer.Tipoftheday1Click(Sender: TObject);
begin
  ShowModalDialog(TTipDialog);
end;

procedure TComputer.WMWindowsKey(var Msg: TMessage); { 2.2 }
begin
  PostMessage(Handle, WM_WINDOWSKEYACT, 0, 0);
end;

procedure TComputer.WMWindowsKeyAct(var Msg: TMessage); { 2.2 }
begin
  Taskbar.StartKeyPopup;
end;

{ WM_FILESYSCHANGE wParam values:
  DOS, WIN
    0, $3C,  Create file
       $5A,  Create unique file
       $5B,  Create new file
    1, $41:  Delete file
    2, $56:  Rename/move file/directory
    3, $43:  Get/set file attrs
             (no event for GET file attr from a WinApp)
    7, $39:  Create directory
       $6C:  Extended open
    8, $3A:  Delete directory
       $57:  Set file date/time
             (Schulman mentions this, but it doesn't happen) }

procedure TComputer.WMFileSysChange(var Msg: TMessage); { 3.2 }
begin
  with Msg do
  begin
    Result := 0;
    Desktop.RefreshList.Add(ExtractFileDir(StrPas(PChar(lParam))));
    if Hi(wParam) in [$02, $56] then
      Desktop.RefreshList.Add(ExtractFileDir(StrPas(StrEnd(PChar(lParam)) + 1)));
  end;
end;

{ 3.11 -- Progman DDE macro's send by setup programs are now
  handled as they happen. }

procedure TComputer.ProgmanOpen(Sender: TObject);
{var
  GroupList: TStringList;}
begin
  if CheckDialogModal then Exit;
  ShowHourglass;
  if StartPropDlg = nil then
    StartPropDlg := TStartPropDlg.Create(Application);
  (*
  GroupList := TStringList.Create;
  try
    StartPropDlg.GetGroups(GroupList);
    Groups.Lines.Assign(GroupList);
  finally
    StartPropDlg.Show;
    GroupList.Free;
  end;
  *)
end;

procedure TComputer.ProgmanClose(Sender: TObject);
begin
  {Groups.Lines.Clear;}
end;

procedure TComputer.ProgmanExecuteMacro(Sender: TObject; Msg: TStrings);
begin
  ShellDDEBuf.AddStrings(Msg);
  if StartPropDlg <> nil then StartPropDlg.ProcessDDECommands;
end;

end.

