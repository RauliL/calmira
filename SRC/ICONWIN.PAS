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

unit IconWin;

{ Icon Windows unit.

  This form can show in two different modes; as Explorer or as
  a stand alone Icon Window.  The window's owner determines which
  mode is used.  When Explorer is the owner, the TreePanel will
  recieve the Explorer's outline as it's child.

  Fields

    FDir - the form's TDirectory object that holds a list of files and folders.

    SelSize - the size (in bytes) of all items selected

    FDragCopy - True if the current drag-and-drop should copy files if
      successful, False if the operation is a move.

    FSelected - the focused TDirItem

    FSelection - contains a list of selected TDirItems, but is only valid
      immediately after CompileSelection is called.

    FLocked - boolean that indicates if the form should not change its
      size automatically, probably due to the tree view being attached.

    DragJustEnded - flag that is set after OnDragEnd to stop deselections

    Stretching - true if the user is using the lasso to make a selection }

interface

uses
  SysUtils, WinTypes, Classes, Controls, Forms, Dialogs, Graphics, StdCtrls,
  ExtCtrls, Directry, Menus, MultiGrd, Dropclnt, DropServ, DragDrop, Settings,
  Grids, Messages, Progress, Resource, CalForm, ExtForm, StylSped, DynaMenu,
  NetDlgs, PathCmbo, SortHdr;

type
  TToolCommand = (tcParent, tcCreateFolder,
    tcConnect, tcDisconnect, tcCut, tcCopy, tcPaste,
    tcDelete, tcRename, tcProperties,
    tcLargeIcons, tcSmallIcons, tcDetails,
    tcSortByName, tcSortByType, tcSortBySize, tcSortByDate);
  TToolSet = set of TToolCommand;

  TIconWindow = class(TCalForm)
    TotalLabel: TLabel;
    SelLabel: TLabel;
    Grid: TMultiGrid;
    DropServer: TDropServer;
    DropClient: TDropClient;
    Header: TSortHeader;
    NetConnectDialog: TNetConnectDialog;
    NetDisconnectDialog: TNetDisconnectDialog;
    TreePanel: TPanel;
    DragPanel: TPanel;
    MainMenu: TMainMenu;
    FileMenu: TMenuItem;
    EditMenu: TMenuItem;
    ViewMenu: TMenuItem;
    ToolsMenu: TMenuItem;
    HelpMenu: TMenuItem;
    FileOpen: TMenuItem;
    FileOpenWith: TMenuItem;
    FileInspect: TMenuItem;
    N1: TMenuItem;
    FileNew: TMenuItem;
    FileNewFolder: TMenuItem;
    FileNewAlias: TMenuItem;
    N2: TMenuItem;
    FileDescribe: TMenuItem;
    FileDelete: TMenuItem;
    FileRename: TMenuItem;
    FileProperties: TMenuItem;
    N3: TMenuItem;
    File_Close: TMenuItem;
    EditCut: TMenuItem;
    EditCopy: TMenuItem;
    EditPaste: TMenuItem;
    N4: TMenuItem;
    EditSelectFiles: TMenuItem;
    EditSelectAll: TMenuItem;
    ViewToolbar: TMenuItem;
    N5: TMenuItem;
    ViewLargeIcons: TMenuItem;
    ViewSmallIcons: TMenuItem;
    ViewDetails: TMenuItem;
    N6: TMenuItem;
    ViewArrangeIcons: TMenuItem;
    ArrangeByName: TMenuItem;
    ArrangeByType: TMenuItem;
    ArrangeBySize: TMenuItem;
    ArrangeByDate: TMenuItem;
    N7: TMenuItem;
    Refresh1: TMenuItem;
    SetFilter1: TMenuItem;
    Options1: TMenuItem;
    ToolsFind: TMenuItem;
    ToolsRun: TMenuItem;
    N8: TMenuItem;
    ToolsConnect: TMenuItem;
    ToolsDisconnect: TMenuItem;
    N9: TMenuItem;
    ToolsGoto: TMenuItem;
    HelpContents: TMenuItem;
    HelpTopicSearch: TMenuItem;
    HelpTipoftheday: TMenuItem;
    N10: TMenuItem;
    HelpAbout: TMenuItem;
    ViewStatusbar: TMenuItem;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure FormPaint(Sender: TObject);
    procedure FormDragOver(Sender, Source: TObject; X, Y: Integer;
     State: TDragState; var Accept: Boolean);
    procedure FormDragDrop(Sender, Source: TObject; X, Y: Integer);
    procedure GridMouseDown(Sender: TObject; Button: TMouseButton;
     Shift: TShiftState; X, Y: Integer);
    procedure GridDragOver(Sender, Source: TObject; X, Y: Integer;
     State: TDragState; var Accept: Boolean);
    procedure GridDragDrop(Sender, Source: TObject; X, Y: Integer);
    procedure GridKeyPress(Sender: TObject; var Key: Char);
    procedure ObjectMenuPopup(Sender: TObject);
    procedure WinMenuPopup(Sender: TObject);
    procedure OpenClick(Sender: TObject);
    procedure DeleteClick(Sender: TObject);
    procedure CreateFolderClick(Sender: TObject);
    procedure OpenWithClick(Sender: TObject);
    procedure PropertiesClick(Sender: TObject);
    procedure GridCellSelected(Sender: TObject; Index : Integer; IsSelected: Boolean);
    procedure RenameClick(Sender: TObject);
    procedure RunClick(Sender: TObject);
    procedure SetFilterClick(Sender: TObject);
    procedure SortByClick(Sender: TObject);
    procedure GridKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure FormShow(Sender: TObject);
    procedure DuplicateClick(Sender: TObject);
    procedure GridDrawCell(Sender: TObject; Index: Integer;
      Rect: TRect; State: TGridDrawState);
    procedure GridSelectCell(Sender: TObject; Index: Integer;
      var CanSelect: Boolean);
    procedure DropServerFileDrop(Sender: TObject; X, Y: Integer;
      Target: Word);
    procedure TotalLabelMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure GridMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure GridEndDrag(Sender, Target: TObject; X, Y: Integer);
    procedure SelLabelMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure GridMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure DropClientDropFiles(Sender: TObject);
    procedure DropServerDeskDrop(Sender: TObject; X, Y: Integer;
      Target: Word);
    procedure GridSelect(Sender: TObject; Index: Integer);
    procedure InspectClick(Sender: TObject);
    procedure ViewAsClick(Sender: TObject);
    procedure FormMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure AliasPropClick(Sender: TObject);
    procedure FormHide(Sender: TObject);
    procedure DescribeClick(Sender: TObject);
    procedure FileSystemClick(Sender: TObject);
    procedure GridDblClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure NewAliasClick(Sender: TObject);
    procedure TotalLabelClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    { 3.1 }
    procedure HeaderSized(Sender: TObject; ASection, AWidth: Integer);
    procedure DragPanelMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure DragPanelMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure DragPanelMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure CloseClick(Sender: TObject);
    procedure SelectFilesClick(Sender: TObject);
    procedure SelectAllClick(Sender: TObject);
    procedure ToolbarClick(Sender: TObject);
    procedure StatusbarClick(Sender: TObject);
    procedure RefreshClick(Sender: TObject);
    procedure FindClick(Sender: TObject);
    procedure ConnectClick(Sender: TObject);
    procedure DisconnectClick(Sender: TObject);
    procedure ContentsClick(Sender: TObject);
    procedure TopicSearchClick(Sender: TObject);
    procedure TipofthedayClick(Sender: TObject);
    procedure AboutClick(Sender: TObject);
    { 3.1 Moved from Private }
    procedure CutClick(Sender: TObject);
    procedure CopyClick(Sender: TObject);
    procedure PasteClick(Sender: TObject);
    procedure ToolsGotoClick(Sender: TObject);
  private
    { Private declarations }
    FDir: TDirectory;
    Selsize: Longint;
    FDragCopy: Boolean;
    FSelected: TDirItem;
    FSelection: TFileList;
    FLocked: Boolean;
    DragJustEnded: Boolean;
    Stretching: Boolean;
    Corner, Anchor: TPoint;
    Narrow: Boolean;
    ShowingSelection: Boolean;
    ToolbarShowing: Boolean; { 2.2b }
    ToolButtons: array[TToolCommand] of TStyleSpeed; { 2.2b }
    SliderPanel: TPanel; { 3.1 }
    SliderDragging: Boolean; { 3.1 }
    PrevWindowState: TWindowState; { 3.11 }
    PathCombo: TPathComboBox; { 3.11 }
    BmpList: TBitmap; { 3.11 }
    StatusbarShowing: Boolean; { 3.2 }
    FloatingEdit: TEdit; { 3.2 }
    procedure Arrange(Sender: TObject);
    procedure InitFileOp(Op: TFileOperation);
    procedure DoneFileOp;
    function InitCopy(const dest: string): Boolean;
    function InitMove(const dest: string): Boolean;
    function InitDelete(const dest: string): Boolean;
    procedure AutoResize;
    procedure SizeHeader; { 3.1 }
    procedure SaveColWidths; { 3.1 }
    procedure SetDragCopy(copy: Boolean);
    procedure GridDrawList(Sender: TObject; Index: Integer;
      Rect: TRect; State: TGridDrawState);
    procedure GridDrawSmall(Sender: TObject; Index: Integer;
      Rect: TRect; State: TGridDrawState);
    procedure WMNCRButtonDown(var Msg: TWMNCRButtonDown); message WM_NCRBUTTONDOWN;
    procedure WMActivate(var Msg : TWMActivate); message WM_ACTIVATE;
    procedure SelectFileHandler(Sender: TObject;
      const FileSpec: string; Select: Boolean);
    procedure SearchFileHandler(Sender: TObject; const s: string);
    procedure InitTopLeft;
    procedure AssignCaption;
    procedure MarkItems(IsCopy: Boolean);
    procedure PasteItems(IntoFolder: Boolean);
    { 2.2 }
    procedure InitBlindFileOp(Op: TFileOperation; list: TFileList);
    procedure DoneBlindFileOp;
    function InitBlindCopy(const source: TFilename; list: TFileList): Boolean;
    function InitBlindMove(const source: TFilename; list: TFileList): Boolean;
    procedure ShowToolbar;
    procedure HideToolbar;
    { 2.2b }
    procedure RequireMenus;
    procedure AttachMenus;
    { 3.1 }
    procedure SetTreeWidth;
    { 3.11 }
    procedure ToolParentClick(Sender: TObject);
    procedure ToolLargeIconsClick(Sender: TObject);
    procedure ToolSmallIconsClick(Sender: TObject);
    procedure ToolDetailsClick(Sender: TObject);
    procedure ToolSortByTypeClick(Sender: TObject);
    procedure ToolSortByNameClick(Sender: TObject);
    procedure ToolSortBySizeClick(Sender: TObject);
    procedure ToolSortByDateClick(Sender: TObject);
    procedure ToolMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    { 3.12 }
    procedure BuildPathCombo;
    procedure PathComboDrawItem(Control: TWinControl; Index: Integer;
      Rect: TRect; State: TOwnerDrawState);
    procedure PathComboChange(Sender: TObject);
    { 3.2 }
    procedure ShowStatusbar;
    procedure HideStatusbar;
    procedure ShowFloatingEdit;
    procedure FloatingEditKeyPress(Sender: TObject; var Key: Char);
    procedure FloatingEditExit(Sender: TObject);
  protected
    { Protected declarations }
  public
    { Public declarations }
    DisplayMode: TDisplayMode; { 2.2b }
    constructor Init(AOwner: TComponent;
      const foldername, filter: TFilename);
    procedure DropInFolder(const foldername: TFilename);
    procedure DropInWindow(d: TDirectory);
    procedure DropAsAliases(const foldername: TFilename);
    procedure FolderRenamed(const previous, current: TFilename);
    function FileAt(X, Y: Integer; wholecell: Boolean): TDirItem;
    function CompileSelection(recurse: Boolean): TFileList;
    function CompileFilenames: TStringList;
    procedure ChangeDir(const foldername: string);
    function LoadDimensions: Boolean;
    procedure SaveDimensions;
    procedure Configure;
    procedure SettingsChanged(Changes: TSettingChanges); override;
    procedure RefreshWin;
    procedure UpdateStatusbar(TotalChanged, SelChanged: Boolean);
    procedure CopyToClipboard;
    procedure GotoItem(const Filename: string);
    function CalcSize(cols, rows: Integer): TPoint; { 2.2b removed class}
    class procedure CalcColWidths;
    procedure OpenParentFolder; { 2.2b }
    procedure SelectFromClipboard;
    property Dir: TDirectory read FDir;
    property Selected: TDirItem read FSelected write FSelected;
    property Selection: TFileList read FSelection;
    property DragCopy: Boolean read FDragCopy write SetDragCopy;
    property Locked: Boolean read FLocked write FLocked;
  end;

const
  MacroDisplayMode: Integer = 0;

var
  Xspare, YSpare: Integer;
  NameColWidth, SizeColWidth, TypeColWidth, DateColWidth, AttrColWidth: Integer;
  SampleDate, SampleTime: string[31];
  SharedObjectMenu, SharedWinMenu: TDynamicMenu; { 2.2b }

{
var
  IconWindow: TIconWindow;
}

implementation

{$R *.DFM}

uses ShellAPI, FileProp, DiskProp, Drives, Tree, Environs, Fileman,
  WasteBin, OpenFile, RunProg, Desk, FileFind, Filter, CompSys, Strings,
  MiscUtil, Files, WinProcs, Alias, FSysProp, Select, Clipbrd, Referenc,
  Locale, Embed, Iconic, Task, IncSrch, FourDOS, GotoFld, Tips, About,
  StrtProp;

type
  TEditOperation = (eoRenaming, eoDescribing);

const
  LabelDiv: Integer = 148;

  { 2.2b }
  M_OBJ_OPEN       = 1;
  M_OBJ_OPENWITH   = 2;
  M_OBJ_INSPECT    = 3;
  M_OBJ_CUT        = 4;
  M_OBJ_COPY       = 5;
  M_OBJ_PASTE      = 6;
  M_OBJ_DELETE     = 7;
  M_OBJ_RENAME     = 8;
  M_OBJ_DESCRIBE   = 9;
  M_OBJ_EDITALIAS  = 10;
  M_OBJ_DUPLICATE  = 11;
  M_OBJ_PROPERTIES = 12;

  { The tags of the Sort and Display items on the main menu must have
    these values set (1..7): }
  M_WIN_LARGEICONS   = 1;
  M_WIN_SMALLICONS   = 2;
  M_WIN_DETAILS      = 3;
  M_WIN_SORTBYNAME   = 4;
  M_WIN_SORTBYTYPE   = 5;
  M_WIN_SORTBYSIZE   = 6;
  M_WIN_SORTBYDATE   = 7;
  M_WIN_CUT          = 8;
  M_WIN_COPY         = 9;
  M_WIN_PASTE        = 10;
  M_WIN_SETFILTER    = 11;
  M_WIN_FILESYSTEM   = 12;
  M_WIN_CREATEFOLDER = 13;
  M_WIN_CREATEALIAS  = 14;

  { 3.1 }
  TOOLPARENT     = 0;
  TOOLNEWFOLDER  = 1;
  TOOLCONNECT    = 2;
  TOOLDISCONNECT = 3;
  TOOLCUT        = 4;
  TOOLCOPY       = 5;
  TOOLPASTE      = 6;
  TOOLDELETE     = 7;
  TOOLRENAME     = 8;
  TOOLPROPERTIES = 9;
  TOOLLARGEICONS = 10;
  TOOLSMALLICONS = 11;
  TOOLDETAILS    = 12;
  TOOLSORTNAME   = 13;
  TOOLSORTTYPE   = 14;
  TOOLSORTSIZE   = 15;
  TOOLSORTDATE   = 16;

  ToolbarIndex: array[TToolCommand] of Integer =
    (TOOLPARENT, TOOLNEWFOLDER,
     TOOLCONNECT, TOOLDISCONNECT,
     TOOLCUT, TOOLCOPY, TOOLPASTE,
     TOOLDELETE, TOOLRENAME, TOOLPROPERTIES,
     TOOLLARGEICONS, TOOLSMALLICONS, TOOLDETAILS,
     TOOLSORTNAME, TOOLSORTTYPE, TOOLSORTSIZE, TOOLSORTDATE);

var
  LastPath: TFilename;
  FileClipboard: TStringList;
  FileClipboardCopy: Boolean;
  EditOp: TEditOperation;

{ 2.2b }
procedure TIconWindow.RequireMenus;
begin
  if SharedObjectMenu = nil then
  begin
    SharedObjectMenu := TDynamicMenu.Create(Application);
    with SharedObjectMenu do
    begin
      AutoPopup := False;
      AddItem(LoadStr(SMObjOpen), Shortcut(VK_RETURN, []),
        False, True, M_OBJ_OPEN);
      AddItem(LoadStr(SMObjOpenWith), Shortcut(VK_RETURN, [ssCtrl]),
        False, True, M_OBJ_OPENWITH);
      AddItem(LoadStr(SMObjInspect), Shortcut(VK_RETURN, [ssShift]),
        False, True, M_OBJ_INSPECT);
      AddSeperator;
      AddItem(LoadStr(SMObjCut), 0, False, True, M_OBJ_CUT);
      AddItem(LoadStr(SMObjCopy), 0, False, True, M_OBJ_COPY);
      AddItem(LoadStr(SMObjPaste), 0, False, True, M_OBJ_PASTE);
      AddSeperator;
      AddItem(LoadStr(SMObjDelete), Shortcut(VK_DELETE, []),
        False, True, M_OBJ_DELETE);
      AddItem(LoadStr(SMObjRename), Shortcut(VK_F2, []),
        False, True, M_OBJ_RENAME);
      AddItem(LoadStr(SMObjDescribe), Shortcut(Ord('B'), [ssCtrl]),
        False, True, M_OBJ_DESCRIBE);
      AddItem(LoadStr(SMObjDuplicate), Shortcut(Ord('D'), [ssCtrl]),
        False, True, M_OBJ_DUPLICATE);
      AddItem(LoadStr(SMObjEditAlias), 0,
        False, True, M_OBJ_EDITALIAS);
      AddSeperator;
      AddItem(LoadStr(SMObjProperties), Shortcut(VK_RETURN, [ssAlt]),
        False, True, M_OBJ_PROPERTIES);
    end;
  end;
  if SharedWinMenu = nil then
  begin
    SharedWinMenu := TDynamicMenu.Create(Application);
    with SharedWinMenu do begin
      AutoPopup := False;
      AddItem(LoadStr(SMWinLargeIcons), 0, False, True, M_WIN_LARGEICONS);
      AddItem(LoadStr(SMWinSmallIcons), 0, False, True, M_WIN_SMALLICONS);
      AddItem(LoadStr(SMWinDetails), 0, False, True, M_WIN_DETAILS);
      AddSeperator;
      AddItem(LoadStr(SMWinSortByName), 0, False, True, M_WIN_SORTBYNAME);
      AddItem(LoadStr(SMWinSortByType), 0, False, True, M_WIN_SORTBYTYPE);
      AddItem(LoadStr(SMWinSortBySize), 0, False, True, M_WIN_SORTBYSIZE);
      AddItem(LoadStr(SMWinSortByDate), 0, False, True, M_WIN_SORTBYDATE);
      AddSeperator;
      AddItem(LoadStr(SMObjCut), 0, False, True, M_WIN_CUT);
      AddItem(LoadStr(SMObjCopy), 0, False, True, M_WIN_COPY);
      AddItem(LoadStr(SMObjPaste), 0, False, True, M_WIN_PASTE);
      AddSeperator;
      AddItem(LoadStr(SMWinSetFilter), 0, False, True, M_WIN_SETFILTER);
      AddItem(LoadStr(SMWinFileSystem), 0, False, True, M_WIN_FILESYSTEM);
      AddSeperator;
      AddItem(LoadStr(SMWinCreateFolder), Shortcut(VK_INSERT, []),
        False, True, M_WIN_CREATEFOLDER);
      AddItem(LoadStr(SMWinCreateAlias), Shortcut(Ord('L'), [ssCtrl]),
        False, True, M_WIN_CREATEALIAS);
    end;
  end;
end;

procedure TIconWindow.AttachMenus;
begin
  RequireMenus;
  Grid.PopupMenu := SharedObjectMenu;
  SharedObjectMenu.Attach([OpenClick, OpenWithClick, InspectClick,
    CutClick, CopyClick, PasteClick, DeleteClick, RenameClick,
    DescribeClick, DuplicateClick, AliasPropClick, PropertiesClick]);
  SharedWinMenu.Attach([ViewAsClick, ViewAsClick, ViewAsClick,
    SortByClick, SortByClick, SortByClick, SortByClick,
    CutClick, CopyClick, PasteClick, SetFilterClick, FileSystemClick,
    CreateFolderClick, NewAliasClick]);
  SharedObjectMenu.OnPopup := ObjectMenuPopup;
  SharedWinMenu.OnPopup := WinMenuPopup;
  SetMenuCheck([ArrangeByName,
                ArrangeByType,
                ArrangeBySize,
                ArrangeByDate], Integer(Dir.SortOrder)); { 3.1 }
  SetMenuCheck([SharedWinMenu.Element[M_WIN_SORTBYNAME],
                SharedWinMenu.Element[M_WIN_SORTBYTYPE],
                SharedWinMenu.Element[M_WIN_SORTBYSIZE],
                SharedWinMenu.Element[M_WIN_SORTBYDATE]], Integer(Dir.SortOrder));
  SetMenuCheck([ViewLargeIcons,
                ViewSmallIcons,
                ViewDetails], Integer(DisplayMode)); { 3.1 }
  SetMenuCheck([SharedWinMenu.Element[M_WIN_LARGEICONS],
                SharedWinMenu.Element[M_WIN_SMALLICONS],
                SharedWinMenu.Element[M_WIN_DETAILS]], Integer(DisplayMode));
end;

procedure TIconWindow.FormCreate(Sender: TObject);
begin
  if Owner = Explorer { 3.1 } then
  begin
    Icon.Assign(Icons.Get('Explorer')); { 3.11 }
    TreePanel.BevelOuter := bvNone;
    LoadPosition(ini, 'Explorer');
    DragPanel.Left := ini.ReadInteger('Explorer', 'TreeWidth', 180);
    SetTreeWidth;
  end
  else
  begin
    Icon.Assign(FolderIcon);
    TreePanel.Free;
    DragPanel.Free;
    with Header do SetBounds(4, Top, Self.ClientWidth - 8, Height);
    with Grid do SetBounds(4, Top, Self.ClientWidth - 8, Height);
  end;
  DeleteMenu(GetSystemMenu(Handle, False), SC_SIZE, MF_BYCOMMAND);
  FSelection := TFileList.Create;
  SelLabel.Left := LabelDiv;
  { 3.11 }
  if NetDriver = 0 then
  begin
    ToolsConnect.Free;
    ToolsDisconnect.Free;
    N9.Free;
  end;
  { 3.2 }
  StatusbarShowing := True;
  ViewStatusbar.Checked := True;
end;

procedure TIconWindow.FormDestroy(Sender: TObject);
begin
  Desktop.RemoveWindow(self);
  Dir.Free;
  FSelection.Free;
  BMPList.Free;
end;

function TIconWindow.LoadDimensions: Boolean;
var
  l, t, w, h: Integer;
  s: string[31];
begin
  { Loads positions and size from INI file }
  s := WindowPos.Values[Dir.Fullname];
  if s = '' then Result := False
  else
  try
    Result := Unformat(s, '%d,%d,%d,%d', [@l, @t, @w, @h]) = 4;
    if Result then
    begin
      SetBounds(l, t, w, h);
      Locked := True;
    end;
  except
    on EConvertError do;
  end;
end;

procedure TIconWindow.SaveDimensions;
begin
  WindowPos.Values[Dir.Fullname] :=
    Format('%d,%d,%d,%d', [Left, Top, Width, Height]);
end;

procedure TIconWindow.Configure;
var
  i: Integer;
begin
  Dir.Columns := DefaultColumns; { 3.1 }
  Color := Colors[ccWinFrame];
  with Grid do
  begin
    Visible := False;
    Color := Colors[ccIconBack];
    ThumbTrack := TrackThumb;
    if DisplayMode = dmDetails then
    begin
      DefaultColWidth := Width;
      DefaultRowHeight := LineHeight;
      OnDrawCell := GridDrawList;
    end
    else if DisplayMode = dmSmallIcons then
    begin
      if Header.Visible then
      begin
        SetBounds(Left, Top - 17, Width, Height + 17);
        Header.Visible := False;
      end;
      DefaultColWidth := NameColWidth + 24;
      DefaultRowHeight := LineHeight;
      OnDrawCell := GridDrawSmall;
    end
    else
    begin
      if Header.Visible then
      begin
        SetBounds(Left, Top - 17, Width, Height + 17);
        Header.Visible := False;
      end;
      DefaultColWidth := BrowseGrid.X;
      DefaultRowHeight := BrowseGrid.Y;
    end;
    Canvas.Font.Assign(GlobalFont);
    Visible := True;
  end;
  with CalcSize(2, 1) do
  begin
    MinimumWidth := X;
    MinimumHeight := Y;
  end;
  { 3.1 -- Moved from Init }
  if ShowBrowserToolbar then ShowToolbar
  else HideToolbar;
  { 3.2 }
  if ShowBrowserStatusbar then ShowStatusbar
  else HideStatusbar;
  { 3.11 }
  if BmpList <> nil then BmpList.Free;
  BmpList := TResBitmap.AlternateLoad('TREEBMPS', 'explrico.bmp');
  with BmpList do
    ReplaceBitmapColors(BmpList, Canvas.Pixels[0, Height - 1], clWindow);
  { 3.12 }
  if ToolbarShowing then for i := 0 to ComponentCount - 1 do
    if Components[i] is TStyleSpeed then
      if FlatToolbarButtons then TStyleSpeed(Components[i]).Style := sbFlat
      else TStyleSpeed(Components[i]).Style := sbWin95;

  Invalidate;
end;

class procedure TIconWindow.CalcColWidths;
begin
  with Computer.Canvas do
  begin
    NameColWidth := ini.ReadInteger('File System', 'NameColWidth',
      TextWidth('Wwwwwwww.www') + ColumnPadding);
    SizeColWidth := ini.ReadInteger('File System', 'SizeColWidth',
      TextWidth('9,999.99 MB') + ColumnPadding);
    TypeColWidth := ini.ReadInteger('File System', 'TypeColWidth',
      TextWidth('Sample Filetype') + ColumnPadding); { 4.0 }
    DateColWidth := ini.ReadInteger('File System', 'DateColWidth',
      TextWidth(SampleDate) + TextWidth(SampleTime) + ColumnPadding);
    AttrColWidth := ini.ReadInteger('File System', 'AttrColWidth',
      TextWidth('Attributes') + ColumnPadding);
  end;
end;

constructor TIconWindow.Init(AOwner: TComponent;
  const foldername, filter: TFilename);
begin
  inherited Create(AOwner);
  { Icon windows always show a directory when opened, so a special
    constructor is needed to ensure that a valid directory name is used. }
  FDir := TDirectory.Create(MakePath(foldername));
  FDir.Filter := filter;
  FDir.OnUpdate := Arrange;
  FDir.Scan;
  AssignCaption;
  Desktop.AddWindow(Self);
  if MacroDisplayMode <> 0 then
  begin
    DisplayMode := TDisplayMode(MacroDisplayMode - 1);
    MacroDisplayMode := 0;
  end
  else DisplayMode := DefaultDisplay;
  Configure;
  AttachMenus;
  if Owner <> Explorer { 3.1 } then AutoResize;
  SizeHeader; { 3.1 }
  Arrange(Self);
  InitTopLeft;
end;

procedure TIconWindow.InitTopLeft;
var
  NextPos: Integer;
begin
  if Owner = Explorer then Exit; { 3.1 }
  if WindowOpen = woRandom then
    SetBounds(Random(Screen.Width - Width - 2),
      Random(Screen.Height - Height - 62), Width, Height)
  else if not ((WindowOpen = woSaved) and LoadDimensions) then
  begin
    if Screen.ActiveForm is TIconWindow then
    begin
      NextPos := GetSystemMetrics(SM_CYCAPTION) - 1;
      SetBounds(Screen.ActiveForm.Left + NextPos,
        Screen.ActiveForm.Top + NextPos, Width, Height);
    end
    else
    begin
      SetBounds((Screen.Width - Width) div 2,
        (Screen.Height - Height) div 2, Width, Height);
    end;
  end;
end;

function TIconWindow.CalcSize(cols, rows: Integer): TPoint;
begin
  Result.x := cols * BrowseGrid.X + XSpare;
  Result.y := rows * BrowseGrid.Y + YSpare;
  if ToolbarShowing then Inc(Result.y, 24);
  if StatusbarShowing then Inc(Result.y, 20);
end;

function GridDimensions(N: Integer): TPoint;
var
  i: Integer;
begin
  Result.X := 5;
  Result.Y := 4;
  if N >= Layouts[NumLayouts - 1].Upper then
    Result := Layouts[NumLayouts - 1].Size;
  for i := 0 to NumLayouts - 1 do
    with Layouts[i] do
      if (N >= Lower) and (N <= Upper) then
      begin
        Result := Size;
        Exit;
      end;
end;

procedure TIconWindow.AutoResize;
var
  size, cells: TPoint;
  details: TFileDetails;
begin
  { Changes the size of the window depending on the number of icons
    in the list }
  if WindowState <> wsNormal then Exit;
  cells := GridDimensions(Dir.Count);
  size := CalcSize(cells.X, cells.Y);
  if DisplayMode = dmDetails then
  begin
    details := Dir.Columns;
    size.x := 22 + NameColWidth + XSpare;
    if fdSize in details then Inc(size.x, SizeColWidth);
    if fdType in details then Inc(size.x, TypeColWidth);
    if fdDate in details then Inc(size.x, DateColWidth);
    if fdAttr in details then Inc(size.x, AttrColWidth);
    if UseDescriptions and (fdDesc in details) then
      if DescWidth > -1 then Inc(size.x, DescWidth)
      else Inc(size.x, (15 * BrowseGrid.X) div 10);
  end
  else if DisplayMode = dmSmallIcons then
    size.x := (24 + NameColWidth) * Max(2, cells.x - 2) + XSpare;
  { The OnResize event is only triggered when the bounds change, but
    as a convention, AutoResize needs to call Resize exactly once
    to reset some of the controls }
  if EqualRect(BoundsRect, Bounds(Left, Top, size.X, size.Y)) then Resize
  else SetBounds(Left, Top, size.X, size.Y);
end;

procedure TIconWindow.SizeHeader; { 3.1 }
var
  details: TFileDetails;
begin
  details := Dir.Columns;
  with Header do begin
    Sections.Clear;
    SectionWidth[Sections.Add(LoadStr(SCFilename))] := 18 + NameColWidth;
    if fdSize in details then
      SectionWidth[Sections.Add(LoadStr(SCSize))] := SizeColWidth;
    if fdType in details then
      SectionWidth[Sections.Add(LoadStr(SCType))] := TypeColWidth;
    if (fdDate in details) or (fdTime in details) then
      SectionWidth[Sections.Add(LoadStr(SCModified))] := DateColWidth;
    if fdAttr in details then
      SectionWidth[Sections.Add(LoadStr(SCAttributes))] := AttrColWidth;
    if UseDescriptions and (fdDesc in details) then
      Sections.Add(LoadStr(SCDescription))
    else
      Sections.Add(''); { 3.1b2 -- dummy column }
  end;
end;

procedure TIconWindow.SaveColWidths; { 3.1 }
begin
  ini.WriteInteger('File System', 'NameColWidth', NameColWidth);
  ini.WriteInteger('File System', 'SizeColWidth', SizeColWidth);
  ini.WriteInteger('File System', 'TypeColWidth', TypeColWidth);
  ini.WriteInteger('File System', 'DateColWidth', DateColWidth);
  ini.WriteInteger('File System', 'AttrColWidth', AttrColWidth);
end;

procedure TIconWindow.Arrange(Sender: TObject);
begin
  { Called after a directory's contents have changed }
  if not (csDestroying in ComponentState) then
  begin
    UpdateStatusbar(True, False);
    Selsize := 0;
    with Grid, Dir do
    begin
      Reset;          { clear the grid }
      Limit := Count; { set the selection extent }
      SizeGrid;       { adjust the rows and columns to fit }
      { The focus might be out of bounds after files have been deleted }
      if (Focus >= Count) and (Count > 0) then Focus := Count - 1;
      GridSelect(self, Focus);
    end;
  end;
end;

procedure TIconWindow.FormResize(Sender: TObject);
var
  GridBottom: Integer;
  NowNarrow: Boolean;
  NewWidth: Integer;
  tc: TToolCommand;
begin
  if WindowState <> wsMinimized then
  begin
    { 2.2b }
    if TreePanel <> nil then
      StretchShift([TreePanel, DragPanel], [stHeight]); { 3.1 }
    StretchShift([Header], [stWidth]); { 3.1 }
    StretchShift([Grid], [stWidth, stHeight]);
    StretchShift([TotalLabel, SelLabel], [stTop]);
    NowNarrow := (LabelDiv * 2 > ClientWidth) or SingleStatus;
    if (Narrow <> NowNarrow) and Visible { 3.1 fix } then
    begin
      Narrow := NowNarrow;
      if Narrow then UpdateStatusbar(True, False)
      else UpdateStatusbar(True, True);
    end;
    SelLabel.Visible := not Narrow;
    case DisplayMode of
      dmLargeIcons: NewWidth := BrowseGrid.X;
      dmSmallIcons: NewWidth := NameColWidth + 24;
      dmDetails      : NewWidth := Width - 2;
    end;
    { TCustomGrid doesn't compare the current column width with a new
      setting, so DefaultColWidth should be assigned only when required }
    with Grid do
      if DefaultColWidth <> NewWidth then DefaultColWidth := NewWidth;
    Grid.SizeGrid;
    { 3.0 -- Hide buttons if window is too narrow }
    if ToolbarShowing then
      for tc := Low(TToolCommand) to High(TToolCommand) do
        { 3.11 -- fix GPF when no network buttons present }
        if ToolButtons[tc] <> nil then
          if (ToolButtons[tc].Left + ToolButtons[tc].Width + 3) < ClientWidth then
            ToolButtons[tc].Show
          else
            ToolButtons[tc].Hide;
    Invalidate;
  end;
  { 3.11 }
  if WindowState <> PrevWindowState then
  begin
    case WindowState of
      wsNormal   : PlaySound(Sounds.Values['WindowRestore']);
      wsMinimized: PlaySound(Sounds.Values['WindowMinimize']);
      wsMaximized: PlaySound(Sounds.Values['WindowMaximize']);
    end;
    PrevWindowState := WindowState;
  end;
end;

procedure TIconWindow.FormPaint(Sender: TObject);
var
  R: TRect;
  x: Integer;
  tc: TToolCommand;
begin
  Border3D(Canvas, ClientRect);
  Control3D(Canvas, Header);
  if StatusbarShowing { 3.2 } then
  begin
    if Narrow then
      R := Rect(3, ClientHeight - 21, ClientWidth - 3, ClientHeight - 3)
    else
    begin
      R := Rect(3, ClientHeight - 21, LabelDiv - 8, ClientHeight - 3);
      RecessBevel(Canvas, R);
      R.Left := r.Right + 3;
      R.Right := ClientWidth - 3;
    end;
    RecessBevel(Canvas, R);
    { Draw the resize "grip" }
    if WindowState = wsNormal then
      Canvas.Draw(ClientWidth - 17, ClientHeight - 17, Sizebox);
  end;
end;

function TIconWindow.FileAt(X, Y: Integer; WholeCell: Boolean): TDirItem;
var
  r: TRect;
  i: Integer;
begin
  { Returns the item at the given mouse coordinates (grid coordinate system).
    If WholeCell is true, the entire grid box tested for containment,
    otherwise only the icon + caption area (approximately) is tested }
  Result := nil;
  if Dir.Count = 0 then Exit;
  i := Grid.MouseToCell(X, Y);
  r := Grid.CellBounds(i);
  if not WholeCell then
    if Displaymode = dmLargeIcons then
    begin
      InflateRect(r, -((WidthOf(r) - 36) div 2), 0);
      r.Bottom := r.Top + 50;
    end
    else
      r.Right := r.left + 24 + Grid.Canvas.TextWidth(TDirItem(Dir[i]).Filename);
  if PtInRect(r, Point(X, Y)) and (i < Dir.Count) then
    Result := TDirItem(Dir[i]);
end;

procedure TIconWindow.GridDragOver(Sender, Source: TObject; X, Y: Integer;
  State: TDragState; var Accept: Boolean);
var
  f: TDirItem;
  DropInIcon: Boolean;
  NewDrop: Integer;
begin
  { Scroll the grid if the cursor is floating over the top or
    bottom scrollbutton }
  with Grid do
    if (VisibleRowCount < RowCount) then
    begin
      if (X > Width - GetSystemMetrics(SM_CXVSCROLL)) and
        (Y < GetSystemMetrics(SM_CYVSCROLL)) and
        (TopRow > 0) then
          TopRow := TopRow - 1
      else if (X > Width - GetSystemMetrics(SM_CXVSCROLL)) and
        (Y > Height - GetSystemMetrics(SM_CYVSCROLL)) and
        (TopRow < RowCount - VisibleRowCount) then
          TopRow := TopRow + 1;
    end;
  if Source = Computer.Grid then Accept := False
  else
  begin
    { This bit is tricky...when the cursor is over a suitable icon,
      the focus box is turned on.  However, when it is not over a suitable
      icon, Accept can still be True because the drop target becomes
      the window.  That is, Accept and DropInIcon are independent }
    f := FileAt(X, Y, True);
    DropInIcon := (f <> nil) and f.AcceptsDrops;
    NewDrop := Grid.MouseToCell(X, Y);
    Accept := (Source <> Sender) or ((NewDrop <> Grid.Focus) and DropInIcon);
    with Grid do
      if not (Accept and DropInIcon) or (State = dsDragLeave) then
        DropFocus := -1
      else
        DropFocus := NewDrop;
  end;
end;

procedure TIconWindow.GridDragDrop(Sender, Source: TObject; X, Y: Integer);
var
  target: TDirItem;
  w: TIconWindow;
begin
  Grid.DropFocus := -1;
  target := FileAt(X, Y, True);
  if (target <> nil) and target.AcceptsDrops then
    target.DragDrop(Source)
  else if Source is TMultiGrid then
  begin
    w := (TMultiGrid(Source).Owner as TIconWindow);
    { 3.11 -- chenged VK_SHIFT to VK_MENU }
    if GetAsyncKeyState(VK_MENU) < 0 then w.DropAsAliases(Dir.Fullname)
    else w.DropInWindow(Dir)
  end
  else if Source = Bin.Listbox then
    Bin.RestoreTo(Dir.Fullname)
  else if Source = FindList then
    ProcessFiles(FindForm.CompileSelection, Dir.Fullname);
end;

procedure TIconWindow.InitFileOp(Op: TFileOperation);
begin
  { Begings a file operation by initialising the progress display,
    cursor and file manager }
  Desktop.SetCursor(crBusyPointer);
  CompileSelection(True);
  NoToAll;
  ProgressBox.Init(Op, Selection.FileCount);
  if UseDescriptions and Simul4DOS then
    Dir.Desc.LoadFromPath(Dir.Path);
end;

procedure TIconWindow.DoneFileOp;
begin
  ProgressBox.Hide;
  if not FileSysChangeOn { 3.2 } then Desktop.RefreshNow;
  Desktop.ReleaseCursor;
  PlaySound(Sounds.Values['NotifyCompletion']);
  if Application.Active then SetFocus;
  NoToAll;
end;

function TIconWindow.InitCopy(const dest: string): Boolean;
begin
  Result := not (ConfirmCopyStart and (MsgDialogResFmt(SQueryCopyItems,
    [Grid.SelCount, OneItem[Grid.SelCount = 1], Dir.Fullname, dest],
    mtConfirmation, [mbYes, mbNo], 0) <> mrYes));
  if Result then InitFileOp(foCopy);
end;

function TIconWindow.InitMove(const dest: string): Boolean;
begin
  Result := not (ConfirmMoveStart and (MsgDialogResFmt(SQueryMoveItems,
    [Grid.SelCount, OneItem[Grid.SelCount = 1], Dir.Fullname, dest],
    mtConfirmation, [mbYes, mbNo], 0) <> mrYes));
  if Result then InitFileOp(foMove);
end;

procedure TIconWindow.InitBlindFileOp(Op: TFileOperation; list: TFileList);
begin
  Desktop.SetCursor(crBusyPointer);
  NoToAll;
  ProgressBox.Init(Op, list.FileCount);
end;

procedure TIconWindow.DoneBlindFileOp;
begin
  ProgressBox.Hide;
  if not FileSysChangeOn { 3.2 } then Desktop.RefreshNow;
  Desktop.ReleaseCursor;
  PlaySound(Sounds.Values['NotifyCompletion']);
  if Application.Active then SetFocus;
  NoToAll;
end;

function TIconWindow.InitBlindCopy(const source: TFilename; list: TFileList): Boolean;
begin
  Result := not (ConfirmCopyStart and (MsgDialogResFmt(SQueryCopyItems,
    [list.Count, OneItem[list.Count = 1], source, Dir.Fullname],
    mtConfirmation, [mbYes, mbNo], 0) <> mrYes));
  if Result then InitBlindFileOp(foCopy, list);
end;

function TIconWindow.InitBlindMove(const source: TFilename; list: TFileList): Boolean;
begin
  Result := not (ConfirmMoveStart and (MsgDialogResFmt(SQueryMoveItems,
    [list.Count, OneItem[list.Count = 1], source, Dir.Fullname],
    mtConfirmation, [mbYes, mbNo], 0) <> mrYes));
  if Result then InitBlindFileOp(foMove, list);
end;

function TIconWindow.InitDelete(const dest: string): Boolean;
begin
  Result := not (ConfirmDelStart and (MsgDialogResFmt(SQueryDeleteItems,
    [Grid.Selcount, OneItem[Grid.SelCount = 1], dest],
    mtConfirmation, [mbYes, mbNo], 0) <> mrYes));
  if Result then InitFileOp(foDelete);
end;

procedure TIconWindow.DropInFolder(const foldername: TFilename);
var
  i: Integer;
  path: TFilename;
begin
  { Copies or moves selected items from this window into a
    specified folder.  If the folder is being shown in an icon window,
    DropInWindow should be used instead. }
  path := MakePath(foldername);
  if path = Dir.Path then
  begin
    ErrorMsgRes(SCannotPutToSelf);
    Exit;
  end;
  case DragCopy of
    True : if not InitCopy(foldername) then Exit;
    False: if not InitMove(foldername) then Exit;
  end;
  try
    if DragCopy then
      for i := 0 to Selection.count - 1 do
        TDirItem(Selection[i]).CopyToPath(path)
    else
      for i := 0 to Selection.Count - 1 do
        TDirItem(Selection[i]).MoveToPath(path);
  finally
    if not DragCopy then Dir.Flush;
    DoneFileOp;
  end;
end;

procedure TIconWindow.DropInWindow(d: TDirectory);
var
  i: Integer;
begin
  { Copies or moves selected items from this window into another window,
    represented by its directory object }
  if d = Dir then
  begin
    ErrorMsgRes(SCannotPutToSelf);
    exit;
  end;
  if UseDescriptions and Simul4DOS then
    d.Desc.LoadFromPath(d.Path);
  case DragCopy of
    False: if not InitMove(d.Fullname) then Exit;
    True : if not InitCopy(d.Fullname) then Exit;
  end;
  try
    if DragCopy then
       for i := 0 to Selection.count-1 do
         TDirItem(Selection[i]).CopyToDirectory(d)
    else
       for i := 0 to Selection.count-1 do
         TDirItem(Selection[i]).MoveToDirectory(d);
  finally
    if not DragCopy then Dir.Flush;
    d.Flush;
    DoneFileOp;
  end;
end;

{ 2.2b }
procedure TIconWindow.ObjectMenuPopup(Sender: TObject);
var
  valid: Boolean;
  IsFile: Boolean;
begin
  { Hide inappropriate menu items, depending on the currently
    "focused" object.  }
  valid := Selected <> nil;
  IsFile := Selected is TFileItem;
  with Sender as TDynamicMenu do
  begin
    Element[M_OBJ_OPEN].Visible := valid;
    Element[M_OBJ_OPENWITH].Visible := IsFile;
    Element[M_OBJ_INSPECT].Visible := IsFile and (InspectProg > '');
    Element[M_OBJ_DESCRIBE].Visible := UseDescriptions;
    Element[M_OBJ_DUPLICATE].Visible := Selected is TFile;
    Element[M_OBJ_EDITALIAS].Visible := Selected is TAlias;
    Element[M_OBJ_RENAME].Visible := valid;
    Element[M_OBJ_DELETE].Visible := valid;
    Element[M_OBJ_PROPERTIES].Visible := valid;
  end;
end;

procedure TIconWindow.WinMenuPopup(Sender: TObject);
begin
  SharedWinMenu.Element[M_WIN_SETFILTER].Checked := Dir.Filter <> DefaultFilter;
end;

procedure TIconWindow.OpenClick(Sender: TObject);
begin
  { 3.2 -- File > Open always captures the ENTER key, it must be
    forwarded here if the Edit is active }
  if (FloatingEdit <> nil) and FloatingEdit.Visible then
  begin
    FloatingEdit.Perform(WM_CHAR, VK_RETURN, 0);
    Exit;
  end;
  if Grid.Focused and (Selected <> nil) then
    if (Owner = Explorer) and (Selected is TFolder) then
      { 3.1 Tree followes attached Icon Window }
      Explorer.Travel(Selected.Fullname)
    else
      Selected.Open
  else
end;

procedure TIconWindow.DeleteClick(Sender: TObject);
var
  i: Integer;
begin
  { 3.2 -- File > Delete always captures the DELETE key, it must be
    forwarded here if the Edit is active }
  if (FloatingEdit <> nil) and FloatingEdit.Visible then
  begin
    FloatingEdit.Perform(WM_KEYDOWN, VK_DELETE, 0);
    Exit;
  end;
  if Grid.SelCount = 0 then Exit;
  if DeleteToBin and not ((BinAction = baDelete) or (GetAsyncKeyState(VK_SHIFT) < 0)
    or (dfRemoveable in GetDriveFlags(Dir.Path[1]))) then
      { 3.11 -- Ask before moving to the bin }
      if not (ConfirmDelStart and (MsgDialogResFmt(SQueryBinItems,
        [Grid.Selcount, OneItem[Grid.SelCount = 1], Dir.Fullname],
        mtConfirmation, [mbYes, mbNo], 0) <> mrYes)) then
          Bin.FormDragDrop(Bin, Grid, 1, 1)
        else
          Exit
  else if InitDelete(Dir.Fullname) then
  try
    for i := 0 to Selection.Count - 1 do TDirItem(Selection[i]).Delete;
  finally
    Dir.Flush;
    DoneFileOp;
  end;
end;

procedure TIconWindow.RenameClick(Sender: TObject); { 3.0 }
var
  s: TFilename;
begin
  if Selected <> nil then with Selected do
  (*
  begin
    s := Filename;
    if InputQuery(FmtLoadStr(SRename, [Filename]), LoadStr(SNewFilename), s) then
    begin
      if UseDescriptions and Simul4DOS then
        Dir.Desc.LoadFromPath(Dir.Path);
      Filename := Lowercase(s);
    end;
  end;
  *)
  begin
    s := Filename;
    EditOp := eoRenaming;
    if FloatingEdit = nil then ShowFloatingEdit;
    with FloatingEdit do
    begin
      Text := s;
      Show;
      SetFocus;
    end;
  end;
end;

procedure TIconWindow.CreateFolderClick(Sender: TObject);
var
  s: TFilename;
  i: Integer;
begin
  (*
  s := '';
  if InputQuery(LoadStr(SCreateFolder), LoadStr(SNewFolderName), s) then
    Dir.CreateFolder(Lowercase(s));
  *)
  s := 'fldr';
  i := 1;
  while HDirectoryExists(MakePath(Dir.Fullname) + s) do
  begin
    s := 'fldr' + IntToStr(i);
    Inc(i);
  end;
  Dir.CreateFolder(s);
  GotoItem(s);
  RenameClick(Sender);
end;

procedure TIconWindow.ShowFloatingEdit;
var
  Rect: TRect;
begin
  FloatingEdit := TEdit.Create(Self);
  with FloatingEdit do
  begin
    Parent := Grid;
    Ctl3D := False;
    if EditOp = eoRenaming then MaxLength := 12;
    OEMConvert := True;
    OnExit := FloatingEditExit;
    OnKeyPress := FloatingEditKeyPress;
    Rect := Grid.CellBounds(Grid.Focus);
    if DisplayMode = dmLargeIcons then
    begin
      Top := Rect.Top + 34;
      Left := Rect.Left;
      Height := HeightOf(Rect) - 34;
      Width := WidthOf(Rect) + 2;
    end
    else
    begin
      Top := Rect.Top - 2;
      Left := Rect.Left + 20;
      Height := 20;
      Width := 100;
    end;
  end;
end;

procedure TIconWindow.FloatingEditKeyPress(Sender: TObject; var Key: Char);
var
  s: TFilename;
begin
  case Key of
    Char(VK_ESCAPE):
      with FloatingEdit do
      begin
        Key := #0;
        FreeAndNil(FloatingEdit);
        Grid.SetFocus;
        Exit;
      end;
    Char(VK_RETURN):
      with FloatingEdit do
      begin
        Key := #0;
        s := Text;
        FreeAndNil(FloatingEdit);
        Grid.SetFocus;
        { moved from RenameClick }
        if UseDescriptions and Simul4DOS then
          Dir.Desc.LoadFromPath(Dir.Path);
        Selected.Filename := Lowercase(s);
        Dir.Update;
      end;
  end;
end;

procedure TIconWindow.FloatingEditExit(Sender: TObject);
begin
  FreeAndNil(FloatingEdit);
  Grid.SetFocus;
end;

procedure TIconWindow.GridMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
  p: TPoint;
  r: TRect;
begin
  if ssDouble in Shift then Exit;
  if Button = mbLeft then
  begin
    if (FileAt(X, Y, False) <> nil) and (Grid.SelCount > 0) then
    with Grid do
    begin
      { Start dragging when clicking over an icon }
      DragCopy := DefDragCopy {xor (ssAlt in Shift)};
      Computer.DragTimer.Enabled := True; { 3.11 }
      BeginDrag(False);
    end
    else with Grid do
    begin
      { Start lasso selection when clicking over empty space }
      Stretching := True;
      Update;
      Anchor := Point(X, Y);
      Corner := Anchor;
      with ClientRect do
      begin
        r.TopLeft := ClientToScreen(TopLeft);
        r.BottomRight := ClientToScreen(Bottomright);
        ClipCursor(@r);
      end;
    end;
  end
  else if Grid.Dragging then
    { Toggle move/copy when right clicking during file drag
      3.11 -- now cancels file drag }
    Grid.EndDrag(False)
  else if not Stretching then with Grid do begin
    { Display appropriate context menu }
    GetCursorPos(p);
    if FileAt(X, Y, False) = nil then
      SharedWinMenu.Popup(p.x, p.y) { 2.2b }
    else
    begin
      AllowMulti := False;
      Select(MouseToCell(X, Y));
      AllowMulti := True;
      if SelCount > 0 then
      begin
        if ssAlt in Shift then FileProperties.Click
        else if ssCtrl in Shift then FileOpenWith.Click
        else if ssShift in Shift then FileInspect.Click
        else SharedObjectMenu.Popup(p.x, p.y);
      end;
    end;
  end;
end;

procedure TIconWindow.FormDragOver(Sender, Source: TObject; X, Y: Integer;
  State: TDragState; var Accept: Boolean);
begin
  Accept := (Source <> Grid) and (Source <> Computer.Grid);
end;

procedure TIconWindow.OpenWithClick(Sender: TObject);
var
  s: TFilename;
begin
  if not (Selected is TFileItem) then Exit;
  ShowHourGlass;
  s := TOpenFileDlg.Execute;
  if s > '' then OpenFileWith(Selected.Fullname, s);
end;

procedure TIconWindow.PropertiesClick(Sender: TObject);
begin
  if Grid.SelCount > 0 then
  begin
    ShowHourglass;
    with TFilePropDlg.Create(Application) do
    try
      if Grid.Selcount = 1 then SetItem(Selected)
      else SetItem(CompileSelection(True));
      ShowModal;
    finally
      Free;
    end;
  end;
end;

procedure TIconWindow.GridCellSelected(Sender: TObject; Index : Integer;
  IsSelected: Boolean);
var
  s: Longint;
begin
  { Called once for each selection or deselection in the grid.  If the
    user selects 100 files in one go, this is called 100 times, so keep
    the code short }
  if Index < Dir.Count then
  begin
    s := TDirItem(Dir[Index]).Size;
    if IsSelected then Inc(Selsize, s)
    else Dec(Selsize, s);
  end;
end;

procedure TIconWindow.GridKeyPress(Sender: TObject; var Key: Char);
var
  c: Char;
  i, foc: Integer;
  found: Boolean;
  sel: Boolean;
begin
  case Key of
    { optimized Case statement in ascending order of ASCII value }
    ' ': if Grid.Focus < Dir.Count then
         begin
           { 2.11 fix }
           foc := Grid.Focus;
           sel := not Grid.Selected[foc];
           Grid.Selected[foc] := sel;
           UpdateStatusbar(False, True);
           if sel then Selected := TDirItem(Dir[foc])
           else Selected := nil;
         end;
    '*': Desktop.CloseOtherWindows(self);
    '+': Desktop.CloseLowerWindows(Dir.Fullname);
    ',': with Grid do { 2.12 }
           if SelCount = Dir.Count then DeselectAll else SelectAll;
    '-': Desktop.ClosePathWindows(Dir.Fullname);
    '.': with TIncSearchDlg.Create(Application) do
         try
           OnSearch := SearchFileHandler;
           ShowModal;
         finally
           Free;
         end;
    '/': Desktop.CloseWindows;
    '?': SetFilterClick(Sender);
    'D': ArrangeByDate.Click;
    'E': ViewDetails.Click;
    'G': ViewLargeIcons.Click;
    'M': ViewSmallIcons.Click;
    'N': ArrangeByName.Click;
    'S': ArrangeBySize.Click;
    'T': ArrangeByType.Click;
    '\': if Owner = Explorer then
           { 3.1 Tree followes attached Icon Window }
           Explorer.Travel(Dir.Path[1] + ':\')
         else
           Desktop.OpenFolder(Dir.Path[1] + ':\');
  else
  if not (Key in Uppers) then
    { Jump to the next object which begins with this character }
    with Dir do if Count > 1 then
    begin
      c := LowCase(Key);
      foc := Grid.Focus;
      i := (foc + 1) mod Count;
      while (i <> foc) and (LowCase(TDirItem(List^[i]).GetTitle[1]) <> c) do
        i := (i + 1) mod Count;
      if i <> foc then Grid.Select(i);
    end;
  end;
end;

procedure TIconWindow.FormDragDrop(Sender, Source: TObject; X, Y: Integer);
begin
  if Source is TMultiGrid then
    TIconWindow(TMultiGrid(Source).Owner).DropInWindow(Dir)
  else if Source = Bin.Listbox then
    Bin.RestoreTo(Dir.Fullname)
  else if Source = FindList then
    ProcessFiles(FindForm.CompileSelection, Dir.Fullname);
end;

procedure TIconWindow.RefreshWin;
var
  SaveSelected: string[12];
begin
  SaveSelected := '';
  if Selected <> nil then SaveSelected := Selected.Filename;
  try
    Dir.Scan;
    if not Locked then AutoResize;
    Arrange(Self);
    if SaveSelected > '' then GotoItem(SaveSelected)
  except
    on EScanError do
    begin
      Dir.Flush; { 3.1 }
      { Show message instead of raising, because the runtime
        does not handle the exception (why?) }
      ErrorMsgResFmt(SCannotOpenFolder, [Dir.Fullname]);
    end;
  end;
  { 3.11 }
  Environment.Values['CURRENTFOLDER'] := Dir.Fullname;
  Environment.Values['CURRENTDRIVE'] := Dir.Fullname[1];
end;

procedure TIconWindow.RunClick(Sender: TObject);
var
  path: string[79];
begin
  if Selected <> nil then
  begin
    { 3.1 -- Copy entire path to run dialog }
    path := Dir.Fullname + '\' + Selected.Filename;
    if Pos('\\', path) > 0 then Delete(path, 3, 1);
    RunExecute(path, Dir.Fullname);
  end
  else
    RunExecute('', Dir.Fullname);
end;

procedure TIconWindow.DropAsAliases(const foldername : TFilename);
var
  i: Integer;
begin
  ShowHourGlass;
  for i := 0 to Dir.Count - 1 do
    if Grid.Selected[i] then
      with TDirItem(Dir[i]) do
        WriteAlias(MakePath(foldername) + ChangeFileExt(Filename, AliasExtension));
end;

procedure TIconWindow.SetFilterClick(Sender: TObject);
begin
  ShowHourglass;
  with TFilterDialog.Create(Application) do
  try
    if Execute(Dir) = mrOK then RefreshWin;
    SetFilter1.Checked := Dir.Filter <> DefaultFilter;
  finally
    Free;
  end;
end;

procedure TIconWindow.SortByClick(Sender: TObject);
var
  item: TDirItem;
  code: Integer; { 2.2b }
begin
  { Handles all "sorting" menu item events }
  with Sender as TMenuItem do
    if not Checked then
    begin
      { save focused item }
      item := nil;
      if Grid.Focus < Dir.Count then item := TDirItem(Dir.Items[Grid.Focus]);
      { 2.2b }
      code := Tag - M_WIN_SORTBYNAME;
      SetMenuCheck([ArrangeByName,
                    ArrangeByType,
                    ArrangeBySize,
                    ArrangeByDate], code); { 3.1 }
      SetMenuCheck([SharedWinMenu.Element[M_WIN_SORTBYNAME],
                    SharedWinMenu.Element[M_WIN_SORTBYTYPE],
                    SharedWinMenu.Element[M_WIN_SORTBYSIZE],
                    SharedWinMenu.Element[M_WIN_SORTBYDATE]], code);
      if ToolBarShowing then
        SetButtonState([ToolButtons[tcSortByName],
                        ToolButtons[tcSortByType],
                        ToolButtons[tcSortBySize],
                        ToolButtons[tcSortByDate]], code);
      Dir.SortOrder := TSortOrder(code);
      Dir.Sort;
      if item <> nil then Grid.Focus := Dir.IndexOf(item);
      Arrange(Sender);
      RefreshCursor;
    end;
end;

function TIconWindow.CompileSelection(recurse: Boolean): TFileList;
var
  i: Integer;
begin
  { Fills a TFileList with the current selection.  Recurse controls
    whether subdirectories have their content sizes counted.  Use
    this instead of the TDirectory object when items may be moved
    or deleted }
  Desktop.SetCursor(crHourGlass);
  with Selection do
  begin
    Clear;
    Capacity := max(Capacity, Grid.SelCount);
    Selection.DeepScan := recurse;
    for i := 0 to Dir.Count-1 do
      if Grid.Selected[i] then Selection.Add(Dir[i]);
  end;
  Desktop.ReleaseCursor;
  Result := Selection;
end;

procedure TIconWindow.MarkItems(IsCopy: Boolean);
var
  i: Integer;
begin
  FileClipboard.Clear;
  if Grid.SelCount > 0 then
  begin
    FileClipboardCopy := IsCopy;
    FileClipboard.Add(Dir.Path);
    for i := 0 to Dir.Count - 1 do
      if Grid.Selected[i] then FileClipboard.Add(TDirItem(Dir.Items[i]).Filename);
  end;
end;

procedure TIconWindow.SelectFromClipboard;
var
  filename: string[12];
  i, index: Integer;
begin
  if FileClipboard.Count > 1 then
  begin
    Grid.DeselectAll;
    for i := 1 to FileClipboard.Count-1 do
      if Dir.Find(FileClipboard[i], index) then
        Grid.Selected[index] := True;
  end;
end;

procedure TIconWindow.PasteItems(IntoFolder: Boolean); { 2.2b }
var
  path: TFilename;
  w: TIconWindow;
  SourceDir, TargetDir: TDirectory;
  SourceSelection: TFileList;
  i, index: Integer;
begin
  if FileClipboard.Count <= 1 then Exit;
  IntoFolder := IntoFolder and (Selected is TFolder) and
    HDirectoryExists(Selected.Fullname);
  path := FileClipboard[0];
  if (IntoFolder and (path = MakePath(Selected.Fullname)))
    or (not IntoFolder and (path = Dir.Path)) then
    begin
      ErrorMsgRes(SCannotPutToSelf);
      Exit;
    end;
  if IntoFolder then
  begin
    TargetDir := TDirectory.Create(MakePath(Selected.Fullname));
    TargetDir.Scan;
  end
  else TargetDir := Dir;
  w := Desktop.WindowOf(ExtractFileDir(path));
  if w <> nil then
  begin
    { Source window exists }
    w.SelectFromClipboard;
    w.DragCopy := FileClipboardCopy;
    w.DropInWindow(TargetDir);
    SetFocus;
    if not FileClipboardCopy then FileClipboard.Clear;
    if IntoFolder then TargetDir.Free;
    Exit;
  end;
  { No source window is open }
  SourceDir := TDirectory.Create(path);
  SourceDir.Scan;
  SourceSelection := TFileList.Create;
  SourceSelection.DeepScan := True;
  for i := 1 to FileClipboard.Count-1 do
    if SourceDir.Find(FileClipboard[i], index) then
      SourceSelection.Add(SourceDir.Items[index]);
  case FileClipboardCopy of
    True : if not InitBlindCopy(SourceDir.Fullname, SourceSelection) then Exit;
    False: if not InitBlindMove(SourceDir.Fullname, SourceSelection) then Exit;
  end;
  try
    if FileClipboardCopy then
      for i := 0 to SourceSelection.count - 1 do
        TDirItem(SourceSelection[i]).CopyToDirectory(TargetDir)
    else
      for i := 0 to SourceSelection.count - 1 do
        TDirItem(SourceSelection[i]).MoveToDirectory(TargetDir);
  finally
    DoneBlindFileOp;
    SourceDir.Flush;
    Dir.Flush;
    SourceDir.Free;
    if IntoFolder then TargetDir.Free;
    SourceSelection.Free;
  end;
end;

procedure TIconWindow.OpenParentFolder; { 2.2b }
var
  s: TFilename;
begin
  s := ExtractFileDir(Dir.Fullname);
  if Length(Dir.Path) > 3 then
    if (Owner = Explorer) and (Explorer.SelectedFolder <> s) then
      { 3.1 Tree follows attached Icon Window }
      Explorer.Travel(s)
    else
      Desktop.OpenFolder(s)
  else
    Computer.ShowNormal;
end;

procedure TIconWindow.GridKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
var
  item: TMenuItem;
  s: TFilename;
begin
  { Handle keyboard commands not in menus }
  if (Shift = [ssCtrl, ssShift]) and (Chr(Key) in ValidDrives) then
    { Ctrl+Alt+Letter opens the root directory }
    if Owner = Explorer then
      { 3.1 Tree followes attached Icon Window }
      Explorer.Travel(LowCase(Chr(Key)) + ':\')
    else
      Desktop.OpenFolder(LowCase(Chr(Key)) + ':\')
  else if Shift = [ssCtrl] then
    case key of
      Ord('F'): FileFindExecute(Dir.Fullname);
      Ord('O'): Computer.ExecuteMacro(self, '$Folder', '');
      Ord('P'): begin
                  s := '';
                  if Selected <> nil then s := Selected.Fullname;
                  if InputQuery(LoadStr(SPrintFile), LoadStr(SFilename), s) then
                    PrintFile(s);
                end;
      Ord('U'): DefaultExecCommand(UndeleteProg, Dir.Fullname, SW_SHOWNORMAL);
      Ord('Z'): CopyToClipboard; { 2.2 moved to Ctrl+Z }
      VK_F5   : Desktop.Cascade;
    end
  else if Shift = [ssShift] then
    case key of
      VK_DELETE: DeleteClick(Sender);
      VK_F5    : Desktop.ArrangeIcons;
    end
  else if Shift = [] then
    case Key of
      VK_BACK  : OpenParentFolder; { 2.2b }
      VK_F3    : FileFindExecute(Dir.Fullname);
      VK_F4    : if PathCombo <> nil then with PathCombo do
                 begin
                   DroppedDown := not DroppedDown;
                   if DroppedDown then SetFocus;
                 end;
      VK_F12   : Application.Minimize;
    end;
end;

procedure TIconWindow.FormShow(Sender: TObject);
begin
  PlaySound(Sounds.Values['WindowOpen']);
  if IconWindowTask then Taskbar.AddButton(Handle);
end;

procedure TIconWindow.DuplicateClick(Sender: TObject);
var
  s: string;
begin
  if not (Selected is TFileItem) then exit;
  (*
  s := '';
  if InputQuery(FmtLoadStr(SDuplicateFile, [Selected.Filename]),
    LoadStr(SNewFilename), s) then
    begin
      (Selected as TFileItem).Duplicate(Lowercase(s));
      Dir.Update;
    end;
  *)
  s := ExtractFilename(MangleFilename(Dir.Path, Selected.Filename));
  (Selected as TFileItem).Duplicate(Lowercase(s));
  GotoItem(s);
  RenameClick(Sender);
end;

procedure TIconWindow.GridDrawCell(Sender: TObject; Index: Integer;
  Rect: TRect; State: TGridDrawState);
begin
  TDirItem(Dir[Index]).Draw(Grid.Canvas, Rect, State);
end;

procedure TIconWindow.GridDrawSmall(Sender: TObject; Index: Integer;
  Rect: TRect; State: TGridDrawState);
begin
  TDirItem(Dir[Index]).DrawSmall(Grid.Canvas, Rect, State);
end;

procedure TIconWindow.GridDrawList(Sender: TObject; Index: Integer;
  Rect: TRect; State: TGridDrawState);
begin
  TDirItem(Dir[Index]).DrawAsList(Grid.Canvas, Rect, State)
end;

procedure TIconWindow.GridSelectCell(Sender: TObject; Index: Integer;
  var CanSelect: Boolean);
begin
  CanSelect := not Stretching;
end;

procedure TIconWindow.DropServerFileDrop(Sender: TObject; X, Y: Integer;
  Target: Word);
var
  i: Integer;
begin
  with DropServer.Files do
  begin
    if Grid.SelCount > 0 then
      for i := 0 to Dir.Count-1 do
        if Grid.Selected[i] then Add(TDirItem(Dir[i]).Fullname);
    if IsPrintManager(Target) and (Count > 0) then
    begin
      PrintFile(Strings[0]);
      Clear;
    end;
  end;
end;

procedure TIconWindow.TotalLabelMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  if ssShift in Shift then SelLabelMouseDown(Self, Button, Shift, X, Y)
  else if Button = mbRight then DiskPropExecute(Upcase(Dir.Path[1]));
end;

procedure TIconWindow.GridMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
  r, s: TRect;
  i, count, topitem: Integer;
begin
  if Button <> mbLeft then Exit;
  ClipCursor(nil);
  with Grid do
  begin
    count := SelCount;
    if Stretching then
    begin
      { Select files inside lasso }
      Stretching := False;
      r := NormalizeRect(Anchor, Corner);
      Canvas.DrawFocusRect(r);
      topitem := Toprow * ColCount;
      for i := topitem to Min(Dir.Count,
        topitem + (VisibleColCount * (VisibleRowCount + 1))) - 1 do
        begin
          s := CellBounds(i);
          if Intersects(r, s) then Selected[i] := True;
        end;
    end;
    { Deselect when the user clicks in an empty area, provided that
      no new files were selected and a drag hasn't just finished }
    if (count = SelCount) and not DragJustEnded and
      (FileAt(X, Y, True) = nil) and (Dir.Count > 0) then
        DeselectAll;
    GridSelect(self, Focus);
  end;
  DragJustEnded := False;
end;

procedure TIconWindow.GridEndDrag(Sender, Target: TObject; X, Y: Integer);
begin
  Computer.DragTimer.Enabled := False; { 3.11 }
  DragJustEnded := True;
  if GetAsyncKeyState(VK_LBUTTON) >= 0 then
    DropServer.DragFinished;
end;

procedure TIconWindow.SelLabelMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  i: Integer;
  k: Word;
begin
  if Button = mbLeft then with Grid do
  begin
    if ssCtrl in Shift then
    begin
      for i := 0 to Dir.Count - 1 do Selected[i] := not Selected[i];
      UpdateStatusbar(False, True);
    end
    else if SelCount = 0 then SelectAll
    else DeselectAll;
  end
  else if Button = mbRight then
  begin
    { fake a Ctrl+S shortcut }
    k := Ord('S');
    GridKeyDown(Grid, k, [ssCtrl]);
  end;
end;

procedure TIconWindow.GridMouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
var
  NewDragCopy: Boolean;
begin
  if Grid.Dragging then
  begin
    { 3.11 -- new DragCursor logic }
    if DropServer.CanDrop then
      ReplaceNodropCursor(HDropAlias)
    else
    begin
      RestoreNodropCursor;
      if (ssAlt in Shift) or ((StartPropDlg <> nil) and
        (DropServer.DropWindow = StartPropDlg.Outline.Handle)) then
          Grid.DragCursor := crDropAlias
      else
      begin
        NewDragCopy := DefDragCopy;
        if ssCtrl in Shift then NewDragCopy := True
        else if ssShift in Shift then NewDragCopy := False;
        if (Grid.DragCursor = crDropAlias) or (NewDragCopy <> DragCopy) then
          DragCopy := NewDragCopy;
      end;
    end;
  end
  else if Stretching then
  begin
    { erase previous lasso and redraw }
    Grid.Canvas.DrawFocusRect(NormalizeRect(Anchor, Corner));
    Corner := Point(X, Y);
    Grid.Canvas.DrawFocusRect(NormalizeRect(Anchor, Corner));
  end;
end;

procedure TIconWindow.DropClientDropFiles(Sender: TObject);
var
  target: TDirItem;
begin
  with DropClient do
    if (WindowState <> wsMinimized) and PtInRect(Grid.BoundsRect, DropPos) then
    begin
      target := FileAt(DropPos.x, DropPos.y, True);
      if (target <> nil) and target.AcceptsDrops then target.DragDrop(Files)
      else ProcessFiles(Files, Dir.Fullname)
    end
    else ProcessFiles(Files, Dir.Fullname)
end;

procedure TIconWindow.FolderRenamed(const previous, current: TFilename);
var
  s: TFilename;
begin
  { Search for the ancestor which has been renamed and change that
    part of the string to the new name }
  s := Dir.Fullname;
  if (previous = s) or IsAncestorDir(previous, s) then
  begin
    System.Delete(s, 1, Length(previous));
    Desktop.RemoveWindow(self);
    Dir.Path := current + s + '\';
    AssignCaption;
    Desktop.AddWindow(self);
  end;
end;

procedure TIconWindow.DropServerDeskDrop(Sender: TObject; X, Y: Integer;
  Target: Word);
begin
  if (Selected <> nil) and CanEditSettings { 2.2 } then
    Selected.CreateShortcut.MinPosition := Point(X - 16, Y - 16);
end;

procedure TIconWindow.WMNCRButtonDown(var Msg: TWMNCRButtonDown);
begin
  inherited;
  {with Msg do
    if HitTest = HTSYSMENU then
    begin
      ConstructPathMenu;
      PathMenu.Popup(XCursor, YCursor);
    end;}
end;

function TIconWindow.CompileFilenames: TStringList;
var
  i: Integer;
begin
  { Just returns a new list of filenames.  Compare CompileSelection method }
  Result := TStringList.Create;
  for i := 0 to Dir.Count-1 do
    if Grid.Selected[i] then Result.Add(TDirItem(Dir[i]).Fullname);
end;

procedure TIconWindow.SetDragCopy(copy: Boolean);
const
  DragCursors: array[Boolean, Boolean] of TCursor =
    ((crDropFile, crDropMulti), (crDropCopy, crDropMultiCopy ));
begin
  { Sets the cursor shape depending on whether copy mode is on, and
    how many items are selected }
  FDragCopy := copy;
  with Grid do DragCursor := DragCursors[FDragCopy, SelCount > 1];
  RefreshCursor;
end;

procedure TIconWindow.GridSelect(Sender: TObject; Index: Integer);
begin
  { Called whenever the selection has changed }
  if (index < Dir.Count) and (Grid.SelCount > 0) then
    Selected := TDirItem(Dir[index])
  else
  begin
    Selected := nil;
    if Dir.Count = 0 then Grid.Focus := 0;
  end;
  UpdateStatusBar(False, True);
end;

procedure TIconWindow.InspectClick(Sender: TObject);
begin
  if (Selected is TFileItem) and (InspectProg > '') then
    OpenFileWith(Selected.Fullname, InspectProg);
end;

procedure TIconWindow.ChangeDir(const foldername: string);
begin
  if foldername = Dir.Fullname then Exit;
  Desktop.RemoveWindow(self);
  Dir.Path := MakePath(foldername);
  AssignCaption;
  Desktop.AddWindow(self);
  RefreshWin;
  with Grid do
  begin
    if TopRow > 0 then
    begin
      Update;
      TopRow := 0;
    end;
    Focus := 0;
  end;
  { 3.11 }
  if PathCombo <> nil then PathCombo.Path := foldername;
end;

procedure TIconWindow.ViewAsClick(Sender: TObject);
begin
  with Sender as TMenuItem do
    DisplayMode := TDisplayMode(Tag - M_WIN_LARGEICONS);
  SetMenuCheck([ViewLargeIcons,
                ViewSmallIcons,
                ViewDetails], Integer(DisplayMode)); { 3.1 }
  SetMenuCheck([SharedWinMenu.Element[M_WIN_LARGEICONS],
                SharedWinMenu.Element[M_WIN_SMALLICONS],
                SharedWinMenu.Element[M_WIN_DETAILS]], Integer(DisplayMode));
  if ToolBarShowing then
    SetButtonState([ToolButtons[tcLargeIcons],
                    ToolButtons[tcSmallIcons],
                    ToolButtons[tcDetails]], Integer(DisplayMode));
  with Grid do
  begin
    Visible := False;
    if DisplayMode = dmDetails then
    begin
      if not Header.Visible then
      begin
        { 3.1 }
        SetBounds(Left, Top + 17, Width, Height - 17);
        Header.Visible := True;
      end;
      DefaultRowHeight := LineHeight;
      OnDrawCell := GridDrawList;
    end
    else if DisplayMode = dmSmallIcons then
    begin
      if Header.Visible then
      begin
        { 3.1 }
        SetBounds(Left, Top - 17, Width, Height + 17);
        Header.Visible := False;
      end;
      DefaultRowHeight := LineHeight;
      OnDrawCell := GridDrawSmall;
    end
    else
    begin
      if Header.Visible then
      begin
        { 3.1 }
        SetBounds(Left, Top - 17, Width, Height + 17);
        Header.Visible := False;
      end;
      DefaultRowHeight := BrowseGrid.Y;
      OnDrawCell := GridDrawCell;
    end;
    if not Locked and (WindowState = wsNormal) then AutoResize
    else Resize;
    Visible := True;
    SetFocus;
  end;
end;

procedure TIconWindow.FormMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
  p: TPoint;
begin
  if Button = mbRight then
  begin
    GetCursorPos(p);
    SharedWinMenu.Popup(p.X, p.Y);
  end;
end;

procedure TIconWindow.AliasPropClick(Sender: TObject);
begin
  if Selected is TAlias then TAlias(Selected).Edit;
end;

procedure TIconWindow.WMActivate(var Msg: TWMActivate);
begin
  inherited;
  if Msg.Active = WA_INACTIVE then
  begin
    if FloatingEdit <> nil then FreeAndNil(FloatingEdit);
    Application.HintPause := NormalHintPause;
  end
  else
    Application.HintPause := HintDelay;
end;

procedure TIconWindow.FormHide(Sender: TObject);
begin
  if IconWindowTask then Taskbar.DeleteButton(Handle);
end;

procedure TIconWindow.DescribeClick(Sender: TObject);
var
  i: Integer;
begin
  if Grid.Selcount = 0 then Exit;
  if UseDescriptions and Simul4DOS then
    Dir.Desc.LoadFromPath(Dir.Path);
  ShowHourglass;
  CompileSelection(False);
  for i := 0 to Selection.count - 1 do
    if not TDirItem(Selection[i]).EditDescription then Break;
  Dir.Desc.SaveToPath(Dir.Path);
  Grid.Invalidate;
end;

procedure TIconWindow.FileSystemClick(Sender: TObject);
begin
  ShowModalDialog(TFileSysPropDlg);
end;

procedure TIconWindow.SettingsChanged(Changes: TSettingChanges);
begin
  if [scSystem, scFileSystem, scDesktop, scDisplay] * Changes <> [] then
  begin
    Configure;
    { 3.1 }
    AssignCaption;
    SizeHeader;
  end;
  if sc4DOS in Changes then RefreshWin;
  Grid.Setfocus;
end;

procedure TIconWindow.GridDblClick(Sender: TObject);
begin
  if (GetAsyncKeyState(VK_SHIFT) < 0) and (Selected is TFolder) then
    OpenExplorer(Selected.Fullname)
  else if (GetAsyncKeyState(VK_MENU) < 0) then
    PropertiesClick(Sender) { 3.11 }
  else
    OpenClick(Sender);
end;

procedure TIconWindow.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := caFree;
  PlaySound(Sounds.Values['WindowClose']);
  { 3.1 }
  SaveColWidths;
  if Owner = Explorer then
  begin
    SavePosition(ini, 'Explorer');
    ini.WriteInteger('Explorer', 'TreeWidth', DragPanel.Left);
    Explorer.Close;
  end
  else if WindowOpen = woSaved then SaveDimensions;
  { 3.11 }
  Environment.Values['CURRENTFOLDER'] := '';
  Environment.Values['CURRENTDRIVE'] := '';
end;

procedure TIconWindow.NewAliasClick(Sender: TObject);
const
  NewAliasKind: array[Boolean] of TReferenceKind =
    (rkFile, rkInternet);
var
  Icon: TIcon;
  F: TFilename;
  R: TReference;
begin
  ShowHourglass;
  R := TAliasReference.Create;
  with R do
  try
    Kind := NewAliasKind[Computer.BrowserLink.IsBrowserLoaded];
    if AssignFromExternal then
    begin
      F := MangleFilename(Dir.Path,
        MakeValidFilename(Copy(Caption, 1, 8)) + AliasExtension);
      if not (dfWriteable in GetDriveFlags(F[1]))then
        Exit;
      Icon := TIcon.Create;
      try
        AssignIcon(Icon);
        TAlias.Store(F, R, Icon);
        Desktop.UpdateFileWindow(F);
        GotoItem(ExtractFilename(F));
        RenameClick(Sender);
      finally
        Icon.Free;
      end;
    end
  finally
    Free;
  end;
end;

procedure TIconWindow.UpdateStatusbar(TotalChanged, SelChanged: Boolean);
begin
  ShowingSelection := False;
  if (SelChanged and Narrow and (Grid.SelCount = 0)) or TotalChanged then
    TotalLabel.Caption := Format(SSNumObjects,
      [Dir.Count, OneItem[Dir.Count = 1], FormatByte(Dir.Size, 2, 2)]);
  if SelChanged then
    if Narrow and (Grid.SelCount > 0) then
    begin
      TotalLabel.Caption := Format(SelectionLabels[Grid.SelCount = 1],
        [Grid.SelCount, FormatByte(Selsize, 2, 2)]);
      ShowingSelection := True;
    end
    else
      SelLabel.Caption := Format(SelectionLabels[Grid.SelCount = 1],
        [Grid.SelCount, FormatByte(Selsize, 2, 2)]);
end;

procedure TIconWindow.TotalLabelClick(Sender: TObject);
begin
  if GetAsyncKeyState(VK_SHIFT) >= 0 then RefreshWin;
end;

procedure TIconWindow.CopyToClipboard;
var
  strings: TStrings;
  details: TFileDetails;
  item: TDirItem;
  i: Integer;
  s: string;
begin
  if Grid.SelCount = 0 then
    Clipboard.AsText := Dir.Path + Dir.Filter
  else
  begin
    strings := TStringList.Create;
    try
      strings.Add(LoadStr(SDirectoryOf) + Dir.Fullname);
      if not (DisplayMode = dmDetails) then
      begin
        for i := 0 to Dir.Count-1 do
          if Grid.Selected[i] then
            strings.Add(TDirItem(Dir[i]).GetTitle)
      end
      else
      begin
        details := Dir.Columns;
        for i := 0 to Dir.Count - 1 do
          if Grid.Selected[i] then
          begin
            item := TDirItem(Dir[i]);
            s := Format('%-12s', [item.Filename]);
            if fdSize in details then
            begin
              if item is TFolder then
                AppendStr(s, ' <DIR>     ')
              else AppendStr(s, Format(' %10s',
                [FormatByte(item.Size, ListKBDecimals, ListMBDecimals)]));
            end;
            if fdDate in details then
              AppendStr(s, Format(' %*s',
                [Length(SampleDate), DateToStr(item.TimeStamp)]));
            if fdTime in details then
              AppendStr(s,Format(' %*s',
                [Length(SampleTime), ShortTimeToStr(item.TimeStamp)]));
            if fdAttr in details then
              AppendStr(s, Format(' %-4s', [AttrToStr(item.Attr and not faDirectory)]));
            if UseDescriptions and (fdDesc in details) then
              AppendStr(s, ' ' + item.Description);
            strings.Add(s);
          end;
      end;
      CopyStringsToClipboard(strings);
    finally
      strings.Free;
    end;
  end;
end;

procedure TIconWindow.GotoItem(const Filename: string);
var
  i: Integer;
begin
  if Dir.Find(Filename, i) then with Grid do
  begin
    Select(i);
    Selected[i] := True;
  end;
end;

procedure TIconWindow.AssignCaption;
var
  folder, buf: string[79];
  des: TDescriptions;
begin
  folder := Dir.Fullname;
  TotalLabel.Hint := folder;
  buf := GlobalCaptions.Values[folder];
  if (buf = '') and DescCaptions and (Length(folder) > 3) then
  begin
    des := TDescriptions.Create;
    { 2.11 fix }
    des.LoadFromPath(ExtractFilePath(folder));
    buf := des.Get(Extractfilename(folder), nil);
    des.Free;
  end;
  if ShortWinCaptions or (buf > '') then
  begin
    if buf = '' then
    begin
      if Length(folder) = 3 then
        buf := MakeDriveName(GuessDriveType(Dir.Path[1]), Dir.Path[1])
      else
      begin
        buf := ExtractFilename(folder);
        if UpcaseFirstChar then buf[1] := Upcase(buf[1]);
      end;
    end;
    Caption := buf;
  end
  else
  begin
    folder[1] := Upcase(folder[1]); { 3.1 }
    Caption := folder;
  end;
  if Owner = Explorer then Caption := 'Exploring ' + Caption; { 3.1 }
end;

procedure TIconWindow.SearchFileHandler(Sender: TObject; const s: string);
var
  i: Integer;
  cap: string[31];
  found: Boolean;
begin
  if s = '' then Exit;
  for i := 0 to Dir.Count-1 do
  begin
    if SharedWinMenu.Element[M_WIN_LARGEICONS].Checked then
      cap := TDirItem(Dir[i]).GetTitle
    else cap := TDirItem(Dir[i]).Filename;
    if s[Length(s)] = ' ' then
      found := CompareText(Copy(s, 1, Length(s) - 1), cap) = 0
    else found := Pos(s, Lowercase(cap)) = 1;
    if found then
    begin
      GotoItem(TDirItem(Dir[i]).Filename);
      Exit;
    end;
  end;
end;

{ 3.11 }
procedure TIconWindow.PathComboDrawItem(Control: TWinControl;
  Index: Integer; Rect: TRect; State: TOwnerDrawState);

function GetLastFolder(s: string): string;
var
  i: Integer;
begin
  for i := Length(s) downto 1 do
    if s[i] = '\' then
    begin
      Result := Copy(s, i + 1, 255);
      Delete(Result, Length(Result), 1);
      Exit;
    end;
end;

var
  L, BmpListX, BtnWidth: Integer;
  s: string;
begin
  with PathCombo.Canvas do
  begin
    L := Integer(PathCombo.Items.Objects[Index]);
    s := PathCombo.Items[Index];
    BtnWidth := GetSystemMetrics(SM_CXVSCROLL);
    if L > 1 then
    begin
      s := GetLastFolder(s);
      if UpcaseFirstChar then s[1] := UpCase(s[1]);
    end;
    Brush.Color := clWindow;
    FillRect(Rect);
    if not PathCombo.DrawingEdit then with Rect do
      Left := Left + L * 8;
    if Index = 0 then
      { computer icon }
      BmpListX := 0
    else if L = 1 then with PathCombo do
      { drive icons}
      BmpListX := Succ(Ord(GuessDriveType(GetItemPath(Index)[1]))) * 16
    else if PathCombo.GetItemPath(Index) = Dir.Fullname then
      { open folder icon }
      BmpListX := 128
    else
      { closed folder icon }
      BmpListX := 144;
    CopyRect(Bounds(Rect.Left + 2, Rect.Top, 16, 16), BmpList.Canvas,
      Bounds(BmpListX, 0, 16, 16));
    Inc(Rect.Left, 20);
    Rect.Right := Rect.Left + TextWidth(s) + 4;
    { prevent text being drawn over button }
    if Rect.Right > PathCombo.Width - BtnWidth - 1 then
      Rect.Right := PathCombo.Width - BtnWidth - 1;
    if odSelected in State then
    begin
      Brush.Color := clHighlight;
      Font.Color := clHighlightText;
      FillRect(Rect);
    end;
    TextRect(Rect, Rect.Left + 2, Rect.Top +
      Integer(Screen.PixelsPerInch = 96), s);
    if odFocused in State then DrawFocusRect(Rect);
  end;
end;

{ 3.11 }
procedure TIconWindow.PathComboChange(Sender: TObject);
var
  s: string[79];
begin
  with PathCombo do
    if ItemIndex = 0 then
      Computer.ShowNormal
    else
    begin
      s := GetItemPath(ItemIndex);
      if Self.Owner = Explorer then
        Explorer.Travel(s)
      else
        Desktop.OpenFolder(s);
    end;
end;

{ 3.11 }
procedure TIconWindow.BuildPathCombo;
var
  i: Integer;
  Letter: Char;
  DriveType: TDriveType;
  title: string[63];
begin
  if PathCombo <> nil then with PathCombo do
  begin
    BuildDrives;
    Items[0] := Computer.Caption;
    for i := 1 to Items.Count - 1 do
    begin
      Letter := Items[i][2];
      DriveType := GuessDriveType(Letter);
      if DriveType <> dtNoDrive then
      begin
        case DriveType of
          dtFloppy,
          dtCDROM  : {if ShowRemovableVolume then
                      title := Trim(GetVolumeLabel(Letter))
                      else} title := '';
          dtFixed,
          dtNetwork: title := Trim(GetNetworkVolume(Letter));
          dtRAM    : title := Trim(GetVolumeLabel(Letter));
        end;
        if title = '' then
          title := MakeDriveName(DriveType, Letter)
        else
          title := Format('%s (%s:)', [title, Letter]);
        Items[i] := title;
      end;
    end;
  end;
end;

{ 2.2b }
procedure TIconWindow.ShowToolbar;
var
  ToolRes: TBitmap;
  x: Integer;

procedure AddPathCombo; { 3.11 }
begin
  PathCombo := TPathComboBox.Create(Self);
  with PathCombo do
  begin
    Style := csOwnerDrawFixed;
    Cursor := crArrow;
    DropDownCount := 10;
    ItemHeight := 16;
    Parent := Self;
    OnDrawItem := PathComboDrawItem;
    OnChange := PathComboChange;
    SetBounds(x + 1, 4, 190, 20);
    BuildPathCombo;
    Path := Dir.Fullname;
  end;
  Inc(x, PathCombo.Width + 2);
end;

procedure AddToolbarButton(command: TToolCommand; const HintStr: string;
  Group: Integer; AddSeperator: Boolean; ClickHandler: TNotifyEvent);
var
  button: TStyleSpeed;
  ToolRect: TRect;
begin
  button := TStyleSpeed.Create(Self);
  ToolRect := Bounds(ToolbarIndex[command] * 16, 0, 16 ,16);
  with button do
  begin
    SetBounds(x, 3, 22, 22);
    AllowAllUp := False;
    Cursor := crArrow;
    GroupIndex := Group;
    Hint := HintStr;
    Parent := Self;
    Seperator := AddSeperator;
    ShowHint := True;
    OnClick := ClickHandler;
    OnMouseMove := ToolMouseMove;
    { 3.1 }
    if FlatToolbarButtons then
      Style := sbFlat
    else
      Style := sbWin95;
    with Glyph do
    begin
      Height := 16;
      Width := 16;
      Canvas.CopyRect(Bounds(0, 0, 16, 16), ToolRes.Canvas, ToolRect);
    end;
  end;
  ToolButtons[command] := button;
  Inc(x, button.Width);
end;

begin {ShowToolbar}
  if not ToolbarShowing then
  begin
    ToolbarShowing := True;
    LockWindowUpdate(Handle);
    { 3.1 }
    ToolRes := TResBitmap.AlternateLoad('TOOLBMPS', 'toolico.bmp');
    if TreePanel <> nil then
    begin
      with TreePanel do SetBounds(Left, 27, Width, Height - 24);
      with DragPanel do SetBounds(Left, 28, Width, Height - 24);
    end;
    Header.Top := 28;
    { /3.1 }
    with Grid do SetBounds(Left, Top + 24, Width, Height - 24);
    x := 3;
    AddPathCombo;
    Inc(x, 8);
    AddToolbarButton(tcParent, LoadStr(STHintParent), 0, True, ToolParentClick);
    AddToolbarButton(tcCreateFolder, LoadStr(STHintNewFolder), 0, False, CreateFolderClick);
    Inc(x, 8);
    if NetDriver > 0 then
    begin
      AddToolbarButton(tcConnect, LoadStr(STHintConnect), 0, True, ConnectClick);
      AddToolbarButton(tcDisconnect, LoadStr(STHintDisconnect), 0, False, DisconnectClick);
      Inc(x, 8);
    end;
    AddToolbarButton(tcCut, LoadStr(STHintCut), 0, True, CutClick);
    AddToolbarButton(tcCopy, LoadStr(STHintCopy), 0, False, CopyClick);
    AddToolbarButton(tcPaste, LoadStr(STHintPaste), 0, False, PasteClick);
    Inc(x, 8);
    AddToolbarButton(tcDelete, LoadStr(STHintDelete), 0, True, DeleteClick);
    AddToolbarButton(tcRename, LoadStr(STHintRename), 0, False, RenameClick);
    AddToolbarButton(tcProperties, LoadStr(STHintProperties), 0, False, PropertiesClick);
    Inc(x, 8);
    AddToolbarButton(tcLargeIcons, LoadStr(STHintLargeIcons), 1, True, ToolLargeIconsClick);
    AddToolbarButton(tcSmallIcons, LoadStr(STHintSmallIcons), 1, False, ToolSmallIconsClick);
    AddToolbarButton(tcDetails, LoadStr(STHintDetails), 1, False, ToolDetailsClick);
    Inc(x, 8);
    AddToolbarButton(tcSortByName, LoadStr(STHintSortName), 2, True, ToolSortByNameClick);
    AddToolbarButton(tcSortByType, LoadStr(STHintSortType), 2, False, ToolSortByTypeClick);
    AddToolbarButton(tcSortBySize, LoadStr(STHintSortSize), 2, False, ToolSortBySizeClick);
    AddToolbarButton(tcSortByDate, LoadStr(STHintSortDate), 2, False, ToolSortByDateClick);
    SetButtonState([ToolButtons[tcLargeIcons],
                    ToolButtons[tcSmallIcons],
                    ToolButtons[tcDetails]], Integer(DisplayMode));
    SetButtonState([ToolButtons[tcSortByName],
                    ToolButtons[tcSortByType],
                    ToolButtons[tcSortBySize],
                    ToolButtons[tcSortByDate]], Integer(DefaultSort));
    LockWindowUpdate(0);
    { 3.1 }
    ViewToolbar.Checked := True;
    ToolRes.Free;
  end;
end;

procedure TIconWindow.HideToolbar;
var
  tc: TToolCommand;
  i: Integer;
begin
  if ToolbarShowing then
  begin
    ToolbarShowing := False;
    LockWindowUpdate(Handle);
    FreeAndNil(PathCombo); { 3.11 }
    for tc := Low(TToolCommand) to High(TToolCommand) do ToolButtons[tc].Free;
    FillChar(ToolButtons, SizeOf(ToolButtons), 0);
    if TreePanel <> nil then
    begin
      with TreePanel do SetBounds(Left, 3, Width, Height + 24);
      with DragPanel do SetBounds(Left, 4, Width, Height + 24);
    end;
    Header.Top := 4;
    { /3.1 }
    with Grid do SetBounds(Left, Top - 24, Width, Height + 24);
    LockWindowUpdate(0);
    ViewToolbar.Checked := False; { 3.1 }
  end;
end;

procedure TIconWindow.ShowStatusBar;
begin
  if not StatusbarShowing then
  begin
    StatusbarShowing := True;
    if TreePanel <> nil then
    begin
      with TreePanel do Height := Height - 20;
      with DragPanel do Height := Height - 20;
    end;
    with Grid do Height := Height - 20;
    ViewStatusbar.Checked := True;
    Invalidate;
  end;
end;

procedure TIconWindow.HideStatusbar;
begin
  if StatusbarShowing then
  begin
    StatusbarShowing := False;
    if TreePanel <> nil then
    begin
      with TreePanel do Height := Height + 20;
      with DragPanel do Height := Height + 20;
    end;
    with Grid do Height := Height + 20;
    ViewStatusbar.Checked := False;
    Invalidate;
  end;
end;

procedure TIconWindow.ToolParentClick(Sender: TObject);
begin
  OpenParentFolder;
end;

procedure TIconWindow.ToolLargeIconsClick(Sender: TObject);
begin
  ViewLargeIcons.Click;
end;

procedure TIconWindow.ToolSmallIconsClick(Sender: TObject);
begin
  ViewSmallIcons.Click;
end;

procedure TIconWindow.ToolDetailsClick(Sender: TObject);
begin
  ViewDetails.Click;
end;

procedure TIconWindow.ToolSortByNameClick(Sender: TObject);
begin
  ArrangeByName.Click;
end;

procedure TIconWindow.ToolSortByTypeClick(Sender: TObject);
begin
  ArrangeByType.Click;
end;

procedure TIconWindow.ToolSortBySizeClick(Sender: TObject);
begin
  ArrangeBySize.Click;
end;

procedure TIconWindow.ToolSortByDateClick(Sender: TObject);
begin
  ArrangeByDate.Click;
end;

procedure TIconWindow.ToolMouseMove(Sender: TObject; Shift: TShiftState;
  X, Y: Integer);
begin
  Cursor := crDefault;
end;

procedure TIconWindow.FormActivate(Sender: TObject);
begin
  AttachMenus;
  { 3.11 }
  Environment.Values['CURRENTFOLDER'] := Dir.Fullname;
  Environment.Values['CURRENTDRIVE'] := Dir.Fullname[1];
end;

procedure TIconWindow.CutClick(Sender: TObject);
begin
  MarkItems(False);
end;

procedure TIconWindow.CopyClick(Sender: TObject);
begin
  MarkItems(True);
end;

procedure TIconWindow.PasteClick(Sender: TObject);
begin
  PasteItems(Selected is TFolder);
end;

{ 3.1 }

procedure TIconWindow.HeaderSized(Sender: TObject; ASection,
  AWidth: Integer);
var
  details: TFileDetails;
  i: Integer;
begin
  if DisplayMode <> dmDetails then Exit;
  NameColWidth := Header.SectionWidth[0] - 18;
  details := dir.Columns;
  i := 1;
  if fdSize in details then
  begin
    SizeColWidth := Header.SectionWidth[i];
    Inc(i);
  end;
  if fdType in details then
  begin
    TypeColWidth := Header.SectionWidth[i];
    Inc(i);
  end;
  if (fdDate in details) or (fdTime in details) then
  begin
    DateColWidth := Header.SectionWidth[i];
    Inc(i);
  end;
  if fdAttr in details then
    AttrColWidth := Header.SectionWidth[i];
  Grid.Invalidate;
end;

procedure TIconWindow.DragPanelMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  if Button = mbLeft then
  begin
    SliderPanel := TPanel.Create(Self);
    with SliderPanel do
    begin
      Parent := Self;
      BevelInner := bvNone;
      BevelOuter := bvNone;
      Caption := '';
      Color := clBlack;
      Cursor := crHSplit;
      SetBounds(DragPanel.Left, DragPanel.Top,
        DragPanel.Width, DragPanel.Height);
      Visible := True;
    end;
    SliderDragging := True;
  end;
end;

procedure TIconWindow.DragPanelMouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Integer);
var
  ALeft : Integer;
begin
  if SliderDragging then
  begin
    ALeft := DragPanel.Left + X - 1;
    if ALeft < (TreePanel.Left + 80) then
      ALeft := TreePanel.Left + 80
    else if ALeft > (Grid.Left + Grid.Width - 80) then
      ALeft := Grid.Left + Grid.Width - 80;
    SliderPanel.Left := ALeft;
    SliderPanel.Invalidate;
  end;
end;

procedure TIconWindow.DragPanelMouseUp(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  if SliderDragging then
  begin
    SliderDragging := False;
    SliderPanel.Visible := False;
    DragPanel.Left := SliderPanel.Left;
    SetTreeWidth;
    SliderPanel.Free;
    Invalidate;
  end;
end;

procedure TIconWindow.SetTreeWidth;
begin
  TreePanel.Width := DragPanel.Left - 3;
  Header.SetBounds(DragPanel.Left + 4, Header.Top,
    ClientWidth - DragPanel.Left - 8, Header.Height);
  Grid.SetBounds(DragPanel.Left + 4, Grid.Top,
    ClientWidth - DragPanel.Left - 8, Grid.Height);
end;

procedure TIconWindow.SelectFileHandler(Sender: TObject;
  const FileSpec: string; Select: Boolean);
var
  i: Integer;
begin
  for i := 0 to Dir.Count - 1 do
    if WildCardMatch(TDirItem(Dir[i]).Filename, FileSpec) then
      Grid.Selected[i] := Select;
  GridSelect(Self, Grid.Focus);
end;

procedure TIconWindow.CloseClick(Sender: TObject);
begin
  Close;
end;

procedure TIconWindow.SelectFilesClick(Sender: TObject);
begin
  with TSelectFileDlg.Create(Application) do
  try
    OnSelectFiles := SelectFileHandler;
    ShowModal;
  finally
    Free;
  end;
end;

procedure TIconWindow.SelectAllClick(Sender: TObject);
begin
  with Grid do
    if SelCount = Dir.Count then DeselectAll
    else SelectAll;
end;

procedure TIconWindow.ToolbarClick(Sender: TObject);
begin
  if ToolbarShowing then HideToolbar
  else ShowToolbar;
end;

procedure TIconWindow.StatusbarClick(Sender: TObject);
begin
  if StatusbarShowing then HideStatusbar
  else ShowStatusbar;
end;

procedure TIconWindow.RefreshClick(Sender: TObject);
begin
  RefreshWin;
  if Owner = Explorer then Explorer.RefreshTreeClick(Sender);
  if PathCombo <> nil then with PathCombo do { 3.11 }
  begin
    BuildPathCombo;
    Path := Dir.Fullname;
  end;
end;

procedure TIconWindow.FindClick(Sender: TObject);
begin
  FileFindExecute(Dir.Fullname);
end;

procedure TIconWindow.ConnectClick(Sender: TObject);
begin
  if NetConnectDialog.Execute then
  begin
    DetectDrives;
    Computer.RefreshSys.Click;
    if Explorer <> nil then Explorer.RefreshTreeClick(Self);
    if PathCombo <> nil then with PathCombo do { 3.11 }
    begin
      BuildPathCombo;
      Path := Dir.Fullname;
    end;
  end;
end;

procedure TIconWindow.DisconnectClick(Sender: TObject);
begin
  if NetDisconnectDialog.Execute then
  begin
    DetectDrives;
    Computer.RefreshSys.Click;
    if Explorer <> nil then Explorer.RefreshTreeClick(Self);
    if PathCombo <> nil then with PathCombo do { 3.11 }
    begin
      BuildPathCombo;
      Path := Dir.Fullname;
    end;
  end;
end;

procedure TIconWindow.ToolsGotoClick(Sender: TObject);
var
  s: string;
begin
  s := '';
  if GotoFolder(s) then
    if Owner = Explorer then
      Explorer.Travel(s)
    else
      Desktop.OpenFolder(s);
end;

procedure TIconWindow.ContentsClick(Sender: TObject);
begin
  Application.HelpContext(ActiveControl.HelpContext);
end;

procedure TIconWindow.TopicSearchClick(Sender: TObject);
const
  EmptyString: PChar = '';
begin
  Application.HelpCommand(HELP_PARTIALKEY, Longint(EmptyString));
end;

procedure TIconWindow.TipofthedayClick(Sender: TObject);
begin
  ShowModalDialog(TTipDialog);
end;

procedure TIconWindow.AboutClick(Sender: TObject);
begin
  ShowModalDialog(TAboutBox);
end;

procedure DoneIconWin; far;
begin
  FileClipboard.Free;
end;

initialization
  FileClipboard := TStringList.Create;
  Xspare := 12 + GetSystemMetrics(SM_CYVSCROLL);
  Yspare := 12 + GetSystemMetrics(SM_CYCAPTION) +
    GetSystemMetrics(SM_CYMENU); { 3.1 }
  SampleDate := DateToStr(EncodeDate(2000, 12, 12));
  SampleTime := ShortTimeToStr(EncodeTime(12, 0, 0, 0));
  if Screen.PixelsPerInch > 96 then LabelDiv := 172;
  AddExitProc(DoneIconWin);
end.

