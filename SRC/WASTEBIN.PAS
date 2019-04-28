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

unit Wastebin;

{ Wastepaper bin

  TTrash object

  This is an abstract base class that defines how a piece of trash
  is stored, deleted and restored.  The code for performing the disk
  operations is placed in the descendants, TFileTrash and TFolderTrash.

  Methods

    Create - initializes a new object from a TDirItem that is about
      to be binned.
    Load - initializes a new object from an entry in the INI file.
    RestoreTo - moves the trash back into "normal" disk space.
      A pathname is required and if none is given, the object is
      moved back to where it originally came from.
    Delete - removes the item from disk, freeing up space
    Draw - paints a row of the bin's listbox.  The integer parameters
      specify where the size and date fields begin

  Protected methods

    These are called to implement disk operations.

    DoTrash - moves a TDirItem to the bin (currently implemented in the
      base class).
    DoDelete - called by Delete
    DoRestore - called by RestoreTo
    GetIcon - returns the TIcon to represent the trash item.
    CanReplaceFile - called by RestoreTo if the destination already
      exists.  TFileTrash asks for confirmation, TFolderTrash just
      raises an exception.

  Properties

    Filename - the full name of the original file or folder
    Tempname - the current name of the file or folder
    Size - for files, this gives the file size.  For folders, this is
      the total size of the structure including sub-folders
    Date - a string containing the formatted date
    Release - True if the trash object should be removed from the bin
      the next time it is updated -- either because the referenced
      file/folder has been deleted or restored, or is otherwise invalid.

  TBin form

  When items are dropped from a TIconWindow, the TDirItems are
  converted into TTrash objects, which are stored into the INI file
  and recreated the next time the program loads.  The trash is kept
  in Listbox.Items.Objects during normal use.

  Methods

    UpdateBin - deletes all TTrash objects with their Release flag
      set to True, then changes the form's icon to show if there is
      something in the bin.
    SaveTrash - deletes unwanted trash according to the BinAction
      setting, and writes the remaining filenames to the INI file.
      This is usually called when the program ends.
    RestoreTo - calles the RestoreTo method of every selected
      TTrash object }

interface

uses SysUtils, Classes, Controls, Forms, Dialogs, StdCtrls, Buttons, Messages,
  Fileman, ExtCtrls, Menus, Dropclnt, DragDrop, WinTypes, CalForm, ExtForm, 
  Graphics, Directry, Settings, Sysmenu, SortHdr;

type
  TTrashDate = string[15];

  TTrash = class
  protected
    FFilename: TFilename;
    FTempname: TFilename;
    FSize: Longint;
    FDate: TTrashDate;
    FRelease : Boolean;
    procedure DoTrash(Item: TDirItem); virtual;
    function DoDelete: Boolean; virtual; abstract;
    function DoRestore(const dest: TFilename): Boolean; virtual; abstract;
    function GetIcon: TIcon; virtual; abstract;
    function CanReplaceFile(const s: TFilename): Boolean; virtual; abstract;
  public
    constructor Create(Item: TDirItem); virtual;
    constructor Load(const AFilename, ATempname: TFilename); virtual;
    procedure Draw(Canvas: TCanvas; Rect: TRect;
       LocStart, SizeStart, DateStart: Integer);
    function Delete: Boolean;
    procedure RestoreTo(dest: TFilename);
    property Filename: TFilename read FFilename;
    property Tempname: TFilename read FTempname;
    property Size: Longint read FSize;
    property Date: TTrashDate read FDate;
    property Release: Boolean read FRelease;
  end;

  TFolderTrash = class(TTrash)
  protected
    function DoDelete: Boolean; override;
    function DoRestore(const dest: TFilename): Boolean; override;
    function GetIcon: TIcon; override;
    function CanReplaceFile(const s: TFilename): Boolean; override;
  public
    constructor Create(Item: TDirItem); override;
    constructor Load(const AFilename, ATempname: TFilename); override;
  end;

  TFileTrash = class(TTrash)
  protected
    function DoDelete: Boolean; override;
    function DoRestore(const dest: TFilename): Boolean; override;
    function GetIcon: TIcon; override;
    function CanReplaceFile(const s: TFilename): Boolean; override;
  public
    constructor Create(Item: TDirItem); override;
  end;

  TTrashClass = class of TTrash;

  TBin = class(TCalForm)
    Listbox: TListBox;
    Menu: TPopupMenu;
    Delete: TMenuItem;
    Empty: TMenuItem;
    Header: THeader;
    N1: TMenuItem;
    Properties: TMenuItem;
    Restore: TMenuItem;
    StatusLabel1: TLabel;
    StatusLabel2: TLabel;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormDragOver(Sender, Source: TObject; X, Y: Integer;
      State: TDragState; var Accept: Boolean);
    procedure FormCreate(Sender: TObject);
    procedure FormDragDrop(Sender, Source: TObject; X, Y: Integer);
    procedure DeleteClick(Sender: TObject);
    procedure EmptyClick(Sender: TObject);
    procedure HeaderSized(Sender: TObject; ASection, AWidth: Integer);
    procedure ListboxDrawItem(Control: TWinControl; Index: Integer;
      Rect: TRect; State: TOwnerDrawState);
    procedure FormResize(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormPaint(Sender: TObject);
    procedure PropertiesClick(Sender: TObject);
    procedure RestoreClick(Sender: TObject);
    procedure MenuPopup(Sender: TObject);
    procedure ListboxDblClick(Sender: TObject);
    procedure ListboxClick(Sender: TObject);
    procedure GripMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure StatusLabel2MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
  private
    { Private declarations }
    LocStart, SizeStart, DateStart: Integer;
    procedure WMSysCommand(var Msg: TWMSysCommand); message WM_SYSCOMMAND;
    procedure WMNCRButtonDown(var Msg: TWMNCRButtonDown); message WM_NCRBUTTONDOWN;
  public
    { Public declarations }
    procedure UpdateBin;
    procedure SaveTrash;
    procedure RestoreTo(const foldername: TFilename);
    procedure Configure;
    procedure ReadINISettings;
    procedure SettingsChanged(Changes: TSettingChanges); override;
    procedure UpdateStatusBar;
  end;

  EBinError = class(Exception);

const
  SC_EMPTYBIN = SC_VSCROLL + 1024;
  DefaultBin: TFilename = '';

var
  Bin: TBin;

implementation

{$R *.DFM}

uses IconWin, Desk, MultiGrd, Resource, Progress, FileFind, ShellAPI,
  IniFiles, Files, MiscUtil, Drives, Strings, CompSys, WinProcs,
  BinProp, Locale, Embed, ShutDown;

const
  IsFolderToTrash : array[Boolean] of TTrashClass = (TFileTrash, TFolderTrash);
  { returns the appropriate class to use depending on whether the
    source is a folder or not }

var
  BinFolders: TStringList;

function GetBinFolder(const filename: TFilename): TFilename;
begin
  { Decides which directory a file or folder should be stored in }
  Result := BinFolders.Values[filename[1]];
  if Result = '' then Result := DefaultBin;
end;

{ TTrash }

constructor TTrash.Create(Item: TDirItem);
begin
  inherited Create;
  FRelease := False;
  FFilename := Item.Fullname;
  FSize := Item.Size;
  FDate := DateToStr(Item.TimeStamp);
end;

procedure TTrash.DoTrash(Item : TDirItem);
begin
  { Suppresses all user confirmation before trashing the item }
  YesToAll;
  try
    try
      Item.MoveAndRename(FTempName);
    except
      { don't show special message if user presses Cancel }
      on EAbort do
        raise;
      on Exception do
        raise EBinError.Create(FmtLoadStr(SCannotMoveToBin, [Filename]));
    end;
  finally
    NoToAll;
  end;
end;

constructor TTrash.Load(const AFilename, ATempname: TFilename);
var
  rec: TSearchRec;
begin
  inherited Create;
  FRelease := False;
  FFilename := AFilename;
  FTempname := ATempname;
  FRelease := FindFirst(Tempname, faAnyFile, rec) <> 0;
  FSize := rec.size;
  FDate := DateToStr(TimeStampToDate(rec.time));
  FindClose(rec); { 3.11 }
end;

procedure TTrash.RestoreTo(dest: TFilename);
begin
  { Calls ForceDirectories to make sure that the destination folder
    exists before restoring.  Strictly speaking, more than one icon
    window may be invalidated by this procedure, but it's not important
    enough to worry about, so only the destination window is refreshed }
  if dest = '' then dest := ExtractFilePath(Filename)
  else dest := MakePath(dest);
  ForceDirectories(dest);
  AppendStr(dest, ExtractFilename(Filename));
  if FFileExists(dest) and not CanReplaceFile(dest) then Exit;
  try
    DoRestore(dest);
    FRelease := True;
  except
    raise EBinError.Create(FmtLoadStr(SCannotRestoreItem, [Filename]));
  end;
  Desktop.RefreshList.Add(ExtractFileDir(dest));
end;

function TTrash.Delete: Boolean;
begin
  YesToAll;
  try
    try
      FileSetAttr(TempName, 0);
      Result := DoDelete;
    except
      Result := False;
      raise;
    end;
  finally
    FRelease := Result;
    NoToAll;
  end;
end;

procedure TTrash.Draw(Canvas: TCanvas; Rect: TRect;
  LocStart, SizeStart, DateStart: Integer);
var
  namestr, sizestr: string[15];
begin
  with Canvas do
  begin
    FillRect(Rect);
    sizestr := FormatByte(Size, ListKBDecimals, ListMBDecimals);
    namestr := ExtractFilename(Filename);
    if BinIcons then
    begin
      { The abstract function GetIcon is called to retrieve a folder or
        file image }
      Draw(Rect.Left + 2, Rect.Top, GetIcon);
      Inc(Rect.Left, 20);
    end;
    Inc(Rect.Top);
    TextOut(Rect.Left + 2, Rect.Top, namestr);
    TextOut(LocStart, Rect.Top, MinimizeName(MakeDirname(Copy(Filename, 1,
      Length(Filename) - Length(namestr))), Canvas, SizeStart - LocStart));
    TextOut(DateStart - 10 - TextWidth(sizestr), Rect.Top, sizestr);
    TextOut(DateStart, Rect.Top, Date);
  end;
end;

{ TFolderTrash }

constructor TFolderTrash.Create(Item: TDirItem);
begin
  { The file manager's directory copying facilities will update the
    BytesTransferred variable for a quick way to find the total size }
  inherited Create(Item);
  FTempname := MangleFilename(GetBinFolder(FFilename), ExtractFilename(FFilename));
  BytesTransferred := 0;
  DoTrash(Item);
  FSize := BytesTransferred;
end;

constructor TFolderTrash.Load(const AFilename, ATempname: TFilename);
begin
  inherited Load(AFilename, ATempname);
  FSize := DirInfo(Tempname, True).Size;
end;

function TFolderTrash.DoDelete: Boolean;
begin
  Result := DeleteDirectory(FTempname);
end;

function TFolderTrash.DoRestore(const dest: TFilename): Boolean;
begin
  Result := MoveDirectory(Tempname, dest);
end;

function TFolderTrash.GetIcon: TIcon;
begin
  Result := TinyFolder;
end;

function TFolderTrash.CanReplaceFile(const s: TFilename): Boolean;
begin
  raise EBinError.CreateResFmt(SCannotRestoreFolderOverFile, [s]);
end;

{ TFileTrash }

constructor TFileTrash.Create(Item: TDirItem);
begin
  inherited Create(Item);
  FTempname := MangleFilename(GetBinFolder(FFilename), ExtractFilename(FFilename));
  DoTrash(Item);
end;

function TFileTrash.DoDelete: Boolean;
begin
  Result := DeleteFile(FTempname);
end;

function TFileTrash.DoRestore(const dest: TFilename): Boolean;
begin
  Result := MoveFile(Tempname, dest, faAnyFile);
end;

function TFileTrash.GetIcon: TIcon;
begin
  Result := TinyFile;
end;

function TFileTrash.CanReplaceFile(const s: TFilename): Boolean;
begin
  case MsgDialogResFmt(SQueryReplaceFile, [s], mtConfirmation,
    mbYesNoCancel, 0) of
      mrYes   : Result := True;
      mrNo    : Result := False;
      mrCancel: Abort;
  end;
end;

{ TBin }

procedure TBin.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := caMinimize;
  if WindowState = wsMinimized then ShowModalDialog(TQuitDlg); { 3.1 }
end;

procedure TBin.FormDragOver(Sender, Source: TObject; X, Y: Integer;
  State: TDragState; var Accept: Boolean);
begin
   Accept := (Source is TMultiGrid) and (Source <> Computer.Grid) and
     (Source <> FindList);
end;

procedure TBin.FormCreate(Sender: TObject);
var
  i: Integer;
  t: TTrash;
  s: TFilename;
  rec: TSearchRec;
begin
  DeleteMenu(GetSystemMenu(Handle, False), SC_SIZE, MF_BYCOMMAND);
  { 2.2 -- moved from initialization }
  DefaultBin := Lowercase(FileWritePath { 2.2 } + 'bin');
  if not FDirectoryExists(DefaultBin) then
  begin
    CreateDir(DefaultBin);
    FileSetAttr(DefaultBin, faHidden);
  end;
  AppendStr(DefaultBin, '\');
  BinFolders := TStringList.Create;
  WindowState := wsMinimized;
  Listbox.DragCursor := crDropFile;
  ReadINISettings;
  ini.ReadSection('Trash', Listbox.Items);
  with Listbox.Items do
    for i := 0 to Count - 1 do
    begin
      s := Strings[i];
      FindFirst(s, faAnyFile and not faVolumeID, rec);
      t := IsFolderToTrash[rec.attr and faDirectory > 0].Load(
        ini.ReadString('Trash', s, ''), s);
      Strings[i] := t.Filename;
      Objects[i] := t;
      FindClose(rec); { 3.11 }
    end;
  UpdateBin;
  MinimumWidth := 128;
  MinimumHeight := 128;
  LoadMinPosition(ini, 'Bin');
  LoadPosition(ini, 'Bin');
  Configure;
end;

procedure TBin.Configure;
begin
  Caption := BinCaption;
  Color := Colors[ccWinFrame];
  Listbox.Font.Assign(GlobalFont); { 3.11 }
  Listbox.ItemHeight := LineHeight;
  if Caption = '' then
    Hide
  else
  begin
    Show;
    Resize;
    Update;
  end;
end;

{ The bin accepts drops from icon windows only.  For each item selected,
  a corresponding TTrash object is created, which is responsible for
  moving the original.  Filenames and trash objects are stored in the
  listbox }

procedure TBin.FormDragDrop(Sender, Source: TObject; X, Y: Integer);
var
  win: TIconWindow;
  waste: TTrash;
  item: TDirItem;
  i: Integer;
begin
  win := (Source as TMultiGrid).Owner as TIconWindow;
  try
    if BinAction = baDelete then
      win.DeleteClick(Sender) { 2.2b }
    else with win.CompileSelection(False) do
    begin
      Desktop.SetCursor(crHourGlass);
      ProgressBox.Init(foBinning, Count);
      for i := 0 to Count - 1 do
      begin
        item := TDirItem(Items[i]);
        waste := IsFolderToTrash[item is TFolder].Create(item);
        Listbox.Items.AddObject(waste.Filename, waste);
        ProgressBox.UpdateGauge;
        ProgressBox.CheckForAbort;
      end;
    end;
  finally
    UpdateBin;
    ProgressBox.Hide;
    win.Dir.Flush;
    Desktop.ReleaseCursor;
    PlaySound(Sounds.Values['BinDropFiles']);
  end;
end;

{ Called before the program quits, and also deletes unwanted trash.
  UpdateBin and FormDestroy are responsible for freeing the TTrash
  objects when they are not needed. }

procedure TBin.SaveTrash;
var
  i: Integer;
  used, space: Longint;
begin
  ini.WriteHeader('Bin', Header);
  with Listbox.Items do
  try
    { count how many bytes are used }
    used := 0;
    for i := 0 to Count - 1 do Inc(used, TTrash(Objects[i]).Size);
    case BinAction of
      baCollect: space := Longint(BinCapacity) * 1024 * 1024;
      baEmpty  : space := -1;
    end;
    { keep deleting until within the limit }
    i := 0;
    while (used > space) and (i < Count) do
    begin
      with TTrash(Objects[i]) do
        if Delete then Dec(used, Size);
      Inc(i);
    end;
  finally
    { clear out deleted entries... }
    UpdateBin;
  end;
end;

procedure TBin.UpdateBin;
var
  i: Integer;
begin
  { Free unused trash objects }
  i := 0;
  with Listbox.Items do
  begin
    for i := Count - 1 downto 0 do
      if TTrash(Objects[i]).Release then
      begin
        Objects[i].Free;
        Delete(i);
      end;
    { Change the icon }
    if Count = 0 then Icon.Assign(icons.Get('EmptyBin'))
    else Icon.Assign(icons.Get('FullBin'));
  end;
  with Listbox do
  begin
    Itemindex := -1;
    Enabled := Items.Count > 0;
  end;
  UpdateStatusBar;
  { 3.0 -- moved from SaveTrash -- save remaineder to INI }
  with Listbox.Items do begin
    ini.EraseSection('Trash');
    for i := 0 to Count - 1 do with TTrash(Objects[i]) do
      ini.WriteString('Trash', Tempname, Filename);
  end;
end;

procedure TBin.RestoreTo(const foldername: TFilename);
var
  i, Count: Integer;
  path: TFilename;
begin
  { if no folder is specified, trash is restored to its original location }
  try
    with Listbox do
    begin
      for i := 0 to Items.Count - 1 do Inc(Count, Integer(Selected[i]));
      ProgressBox.Init(foRestoring, Count);
      if foldername = '' then path := '' else path := MakePath(foldername);
      for i := 0 to Items.Count - 1 do
      begin
        if Selected[i] then TTrash(Items.Objects[i]).RestoreTo(path);
        ProgressBox.UpdateGauge;
        ProgressBox.CheckForAbort;
      end;
    end;
  finally
    UpdateBin;
    ProgressBox.Hide;
    if not FileSysChangeOn { 3.2 } then Desktop.RefreshNow;
    PlaySound(Sounds.Values['BinRestore']);
  end;
end;

procedure TBin.DeleteClick(Sender: TObject);
var
  i: Integer;
begin
  with Listbox.Items do
    for i := 0 to Count - 1 do
      if Listbox.Selected[i] then TTrash(Objects[i]).Delete;
  UpdateBin;
end;

procedure TBin.EmptyClick(Sender: TObject);
var
  i: Integer;
begin
  { 3.11 -- Ask before emptying the bin }
  if (Listbox.Items.Count = 0) or (MsgDialogResFmt(SQueryDeleteItems,
    [Listbox.Items.Count, OneItem[Listbox.Items.Count = 1], 'the Bin'],
    mtConfirmation, [mbYes, mbNo], 0) <> mrYes) then Exit;
  ProgressBox.Init(foEmptying, Listbox.Items.Count);
  try
    PlaySound(Sounds.Values['BinEmpty']);
    with Listbox.Items do
      for i := 0 to Count - 1 do
      begin
        TTrash(Objects[i]).Delete;
        ProgressBox.UpdateGauge;
        ProgressBox.CheckForAbort;
      end;
  finally
    UpdateBin;
    ProgressBox.Hide;
  end;
end;

procedure TBin.WMSysCommand(var Msg: TWMSysCommand);
begin
  inherited;
  if Msg.CmdType and $FFF0 = SC_EMPTYBIN then Empty.Click;
end;

procedure TBin.WMNCRButtonDown(var Msg: TWMNCRButtonDown);
begin
  with Msg do
    if (WindowState = wsMinimized) then
      Menu.Popup(XCursor, YCursor)
    else inherited;
end;

procedure TBin.HeaderSized(Sender: TObject; ASection, AWidth: Integer);
begin
  GetHeaderDivisions(Header, [@LocStart, @SizeStart, @DateStart]);
  Listbox.Invalidate;
end;

procedure TBin.ListboxDrawItem(Control: TWinControl; Index: Integer;
  Rect: TRect; State: TOwnerDrawState);
begin
  with Listbox do
    TTrash(Items.Objects[Index]).Draw(Canvas, Rect, LocStart, SizeStart, DateStart);
end;

procedure TBin.FormResize(Sender: TObject); { 2.2 }
begin
  if WindowState <> wsMinimized { 3.0 } then
  begin
    StretchShift([Header], [stWidth]);
    StretchShift([Listbox], [stWidth, stHeight]);
    StretchShift([StatusLabel1], [stTop]);
    StretchShift([StatusLabel2], [stTop, stWidth]);
    Invalidate;
  end;
end;

procedure TBin.FormDestroy(Sender: TObject);
var
  i: Integer;
begin
  with Listbox.Items do
    for i := 0 to Count - 1 do Objects[i].Free;
  BinFolders.Free;
end;

procedure TBin.ReadINISettings;
var
  i: Integer;
begin
  ini.ReadHeader('Bin', Header);
  HeaderSized(Header, 0, Header.SectionWidth[0]);
  BinFolders.Clear;
  ini.ReadSectionValues('Bin Locations', BinFolders);
  for i := 0 to BinFolders.Count - 1 do
    BinFolders[i] := MakePath(BinFolders[i]);
end;

procedure TBin.FormPaint(Sender: TObject);
var
  R: TRect;
begin
  Border3D(Canvas, ClientRect);
  Control3D(Canvas, Header);
  { 3.1 }
  R := Rect(3, ClientHeight - 21, StatusLabel2.Left - 8, ClientHeight - 3);
  RecessBevel(Canvas, R);
  R.Left := R.Right + 3;
  R.Right := ClientWidth - 3;
  RecessBevel(Canvas, R);
  if WindowState = wsNormal then
    Canvas.Draw(ClientWidth - 17, ClientHeight - 17, Sizebox);
end;

procedure TBin.PropertiesClick(Sender: TObject);
begin
  ShowModalDialog(TBinPropDlg);
end;

procedure TBin.RestoreClick(Sender: TObject);
begin
  RestoreTo('');
end;

procedure TBin.MenuPopup(Sender: TObject);
begin
  with Listbox do
  begin
    Restore.Enabled := SelCount > 0;
    Delete.Enabled := SelCount > 0;
    Empty.Enabled := Items.Count > 0;
  end;
end;

procedure TBin.SettingsChanged(Changes: TSettingChanges);
begin
  if scIniFile in Changes then ReadINISettings;
  if [scSystem, scDisplay, scDesktop, scBin] * Changes <> [] then Configure;
end;

procedure TBin.ListboxDblClick(Sender: TObject);
begin
  with Listbox do
    if (ItemIndex <> -1) and (Items.Objects[ItemIndex] is TFolderTrash) then
      Desktop.OpenFolder(TFolderTrash(Items.Objects[ItemIndex]).TempName);
end;

procedure TBin.UpdateStatusBar; { 2.2 }
var
  ItemSize: Longint;
  TotalSize: Longint;
  SelectedSize: Longint;
  i: Integer;
begin
  TotalSize := 0;
  SelectedSize := 0;
  with Listbox do
    for i := 0 to Items.Count - 1 do
    begin
      ItemSize := TTrash(Items.Objects[i]).Size;
      Inc(TotalSize, ItemSize);
      if Selected[i] then Inc(SelectedSize, ItemSize);
    end;
  StatusLabel1.Caption := Format(SSNumObjects, [Listbox.Items.Count,
    OneItem[Listbox.Items.Count = 1], FormatByte(TotalSize, 2, 2)]);
  StatusLabel2.Caption := Format(SelectionLabels[Listbox.SelCount = 1],
    [Listbox.SelCount, FormatByte(SelectedSize, 2, 2)]);
end;

procedure TBin.ListboxClick(Sender: TObject);
begin
  UpdateStatusBar; { 2.2 }
end;

procedure TBin.GripMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  if Button = mbLeft then
  begin
    ReleaseCapture;
    Perform(WM_SYSCOMMAND, SC_SIZEBOTTOMRIGHT, 0);
  end;
end;

procedure TBin.StatusLabel2MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
  select: Boolean;
  i: Integer;
begin
  with Listbox do
  begin
    select := SelCount = 0;
    for i := 0 to Items.Count - 1 do Selected[i] := select;
  end;
end;

end.

