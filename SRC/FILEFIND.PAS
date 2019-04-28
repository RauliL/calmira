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

unit FileFind;

{ Find dialog

  Performs a recursive background search for the specified files,
  and adds the file details to a multi-column list box.  The fields
  are encoded and unformatted in the DrawItem handler.  This limits
  the number of entries, so for a greater capacity, consider moving
  the data into a TStringList and just adding null fields in the
  listbox (the string list probably uses more memory because it
  allocates lots of small blocks).

  The listbox is a drag-drop source, and has a separate global
  variable pointing to it.  This is so that drag-drop targets can
  check the source without dereferencing the FindForm variable,
  which may be nil when the dialog is not open. }

interface

uses WinTypes, WinProcs, Classes, Forms, Controls, Buttons, CalForm,
  ExtForm, StdCtrls, ExtCtrls, SysUtils, Menus, DragDrop, DropServ,
  Graphics, TabNotBk, Settings, TabPanel, Picbtn, Sysmenu, StylSped,
  Messages, SortHdr;

type
  TFindForm = class(TCalForm)
    Header: THeader;
    Menu: TPopupMenu;
    OpenParent: TMenuItem;
    Delete: TMenuItem;
    DropServer: TDropServer;
    Open: TMenuItem;
    N1: TMenuItem;
    Listbox: TListBox;
    FoundLabel: TLabel;
    SelLabel: TLabel;
    N2: TMenuItem;
    CopyFilenames: TMenuItem;
    CopyFileInfo: TMenuItem;
    OpenWith: TMenuItem;
    TabPanel: TTabPanel;
    Notebook: TNotebook;
    Label1: TLabel;
    FileEdit: TComboBox;
    StartEdit: TComboBox;
    Label2: TLabel;
    SubFolders: TCheckBox;
    SearchBtn: TPicBtn;
    Image: TImage;
    BrowseBtn: TStyleSpeed;
    Label3: TLabel;
    MatchCase: TCheckBox;
    ClearBtn: TPicBtn;
    TextEdit: TComboBox;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure SearchBtnClick(Sender: TObject);
    procedure ClearBtnClick(Sender: TObject); { 3.11 }
    procedure ListboxDrawItem(Control: TWinControl; Index: Integer;
      Rect: TRect; State: TOwnerDrawState);
    procedure HeaderSized(Sender: TObject; ASection, AWidth: Integer);
    procedure DeleteClick(Sender: TObject);
    procedure OpenParentClick(Sender: TObject);
    procedure MenuPopup(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure DropServerFileDrop(Sender: TObject; X, Y: Integer;
      Target: Word);
    procedure ListboxMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure ListboxEndDrag(Sender, Target: TObject; X, Y: Integer);
    procedure OpenClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure StartEditKeyPress(Sender: TObject; var Key: Char);
    procedure ListboxClick(Sender: TObject);
    procedure FormPaint(Sender: TObject);
    procedure BrowseBtnClick(Sender: TObject);
    procedure CopyFilenamesClick(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure FormResize(Sender: TObject);
    procedure OpenWithClick(Sender: TObject);
    procedure FormHide(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure ListboxMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
  private
    { Private declarations }
    Searching: Boolean;
    FSelection: TStringList;
    LocStart, SizeStart, DateStart: Integer;
    Changed: Boolean;
    FileSpecs: TStringList;
    SearchCount: Integer;
    procedure SearchFiles(const StartPath: TFilename);
    function SearchString(Str: string; FileName: TFilename): Longint; { 3.1 }
    procedure ExtractSearchMasks;
    procedure UpdateStatusBar;
    procedure PaintStatusbar; { 3.1 }
  public
    { Public declarations }
    function CompileSelection: TStringList;
    procedure SettingsChanged(Changes: TSettingChanges); override;
    function FilenameAt(i: Integer): TFilename;
    function IsFile(i: Integer): Boolean;
    property Selection: TStringList read FSelection;
  end;

  EFindError = class(Exception);

var
  FindForm: TFindForm;
  FindList: TListBox;

procedure FileFindExecute(const StartPath: string);

implementation

{$R *.DFM}

uses CompSys, Dialogs, Resource, Strings, MiscUtil, Tree, IconWin, OpenFile,
  Fileman, Drives, Desk, Files, Directry, Locale, Embed, Task;

procedure TFindForm.FormCreate(Sender: TObject);
begin
  DeleteMenu(GetSystemMenu(Handle, False), SC_SIZE, MF_BYCOMMAND);
  Icon.Assign(Icons.Get('FindDialog'));
  Image.Picture.Icon.Assign(Icon);
  Searching := False;
  Listbox.DragCursor := crDropFile;
  FSelection := TStringList.Create;
  FileSpecs := TStringList.Create;
  FileSpecs.Duplicates := dupIgnore;
  FindList := Listbox;
  Listbox.Font.Assign(GlobalFont); { 3.11 }
  Listbox.ItemHeight := LineHeight;
  LoadPosition(ini, 'Find Dialog');
  ini.ReadStrings('Search for', FileEdit.Items);
  ini.ReadStrings('Start from', StartEdit.Items);
  ini.readStrings('Find text', TextEdit.Items); { 3.11 }
  ini.ReadHeader('Find Dialog', Header);
  HeaderSized(Header, 0, Header.SectionWidth[0]);
  BrowseBtn.Glyph.Handle := LoadBitmap(HInstance, 'BBBROWSE'); { 3.1 }
end;

procedure TFindForm.FormDestroy(Sender: TObject);
begin
  ini.WriteHeader('Find Dialog', Header);
  if Changed then
  begin
    ini.WriteNewStrings('Search for', FileEdit.Items);
    ini.WriteNewStrings('Start from', StartEdit.Items);
    ini.WriteNewStrings('Find text', TextEdit.Items); { 3.11 }
  end;
  FSelection.Free;
  FileSpecs.Free;
  FindList := nil;
  FindForm := nil;
end;

procedure TFindForm.SearchBtnClick(Sender: TObject);
begin
  if Searching then
  begin
    Searching := False;
    Exit;
  end;
  with StartEdit do
  begin
    case Length(Text) of
      0   : Text := 'c:\';
      1..2: if Text[1] in Alphas then Text := Text[1] + ':\';
    else
      Text := MakePath(Lowercase(Text));
    end;
    if not FDirectoryExists(Text + '*.*') then Exit;
  end;
  ExtractSearchMasks;
  if FileSpecs.Count = 0 then raise EFindError.CreateRes(SSpecifyFiles);
  Changed := AddHistory(FileEdit) or AddHistory(StartEdit) or
    AddHistory(TextEdit); { 3.11 }
  Searching := True;
  Inc(SearchCount);
  SearchBtn.Caption := LoadStr(SStopSearch);
  ClearBtn.Enabled := False; { 3.11 }
  Notebook.Enabled := False;
  Listbox.Enabled := True;
  Desktop.SetCursor(crBusyPointer);
  PaintStatusbar;
  try
    SearchFiles(StartEdit.Text);
  finally
    Searching := False;
    SearchBtn.Caption := LoadStr(SStartSearch);
    ClearBtn.Enabled := True; { 3.11 }
    Notebook.Enabled := True;
    Listbox.Items.EndUpdate;
    Desktop.ReleaseCursor;
    PlaySound(Sounds.Values['NotifyCompletion']);
    ListBox.Enabled := Listbox.Items.Count > 0;
    UpdateStatusBar;
  end;
end;

{ buffers which are kept off the stack }
var
  ListEntry: string;
  SizeStr: string[15];
  iconimage: TIcon;

procedure TFindForm.SearchFiles(const StartPath: TFilename);
type
  { 2.2  moved variables from stack to heap }
  PSearchRec = ^TSearchRec;
  PFileSpec = ^TFileSpec;
  TFileSpec = string[12];
  PStackFrame = ^TStackFrame;
  TStackFrame = record
    rec: TSearchRec;
    spec: TFileSpec;
  end;
var
  SubstringMatch: boolean;
  code, i: Integer;
  rec: PSearchRec;
  spec: PFileSpec;
  frame: PStackFrame;
begin
  FoundLabel.Caption := Capitalize(StartPath); { 3.1 }
  Application.ProcessMessages;
  if not Searching or Application.Terminated then Abort;
  New(frame);
  rec := @(frame^.rec);
  spec := @(frame^.spec);
  try
    for i := 0 to FileSpecs.Count - 1 do
    begin
      { loop through wildcards }
      spec^ := FileSpecs[i];
      { 2.11 substring matching algorithm }
      SubstringMatch := Pos('.', spec^) = 0;
      if SubstringMatch then
        code := FindFirst(StartPath + '*.*', faAnyFile and not faVolumeID, rec^)
      else
        code := FindFirst(StartPath + Lowercase(spec^), faAnyFile and not faVolumeID, rec^);
      while code = 0 do
      begin
        Application.ProcessMessages;
        if not Searching or Application.Terminated then Abort;
        if rec^.name[1] <> '.' then
        begin
          rec^.name := Lowercase(rec^.name);
          if SubstringMatch and (Pos(spec^, rec^.name) = 0) then
          begin
            code := FindNext(rec^);
            Continue;
          end;
          { 3.1 We have a file match, now search for text }
          if (TextEdit.Text > '') and
            (SearchString(TextEdit.Text, StartPath + rec^.name) = -1) then
            begin
              code := FindNext(rec^);
              Continue;
            end;
          if rec^.attr and faDirectory > 0 then
            iconimage := TinyFolder
          else if ExtensionIn(Copy(ExtractFileExt(rec^.name), 2, 3), programs) then
            iconimage := TinyProg
          else
            iconimage := TinyFile;
          if rec^.attr and faDirectory > 0 then SizeStr := ''
          else SizeStr := FormatByte(rec^.size, ListKBDecimals, ListMBDecimals);
          ListEntry := Format('%s;%s;%s;%s', [rec^.name, MakeDirname(StartPath),
            sizestr, DateToStr(TimestampToDate(rec^.time))]);
          try
            with Listbox.Items do
              if ((FileSpecs.Count = 1) and (SearchCount = 1)) or
                (IndexOf(ListEntry) = -1) then
                begin
                  AddObject(ListEntry, iconimage);
                end;
          except
            on EOutOfResources do
            begin
              MsgDialogRes(SFindListboxFull, mtInformation, [mbOK], 0);
              Abort;
            end;
          end;
        end;
        code := FindNext(rec^);
      end;
      FindClose(rec^); { 3.11 }
    end;
    if SubFolders.Checked then
    begin
      { search subdirs }
      code := FindFirst(StartPath + '*.*', faDirectory, rec^);
      while code = 0 do
      begin
        if (rec^.Attr and faDirectory <> 0) and (rec^.name[1] <> '.') then
          SearchFiles(StartPath + Lowercase(rec^.name) + '\');
        code := FindNext(rec^);
      end;
      FindClose(rec^); { 3.11 }
    end;
  finally
    Dispose(frame);
  end;
end;

function TFindForm.SearchString(Str: string; FileName: TFilename): Longint;
const
  BufSize = 8192;
var
  Buffer: Pointer;
  BufPtr, BufEnd: Integer;
  Increment: Integer;
  Index: Longint;
  LastMode: Byte;
  F: File;
  c: Char;
begin
  Result := -1;
  AssignFile(F, FileName);
  LastMode := FileMode;
  FileMode := 0; { Set file access to read only }
  try
    Reset(F, 1);
  except
    FileMode := LastMode;
    Exit;
  end;
  GetMem(Buffer, BufSize);
  BufPtr := 0;
  BufEnd := 0;
  Index := 0;
  Increment := 1;
  if not MatchCase.Checked then Str := UpperCase(Str);
  try
    repeat
      if BufPtr >= BufEnd then
      begin
        Application.ProcessMessages;
        if not Searching or Application.Terminated then Abort;
        BlockRead(F, Buffer^, BufSize, BufEnd);
        BufPtr := 0;
      end;
      c := Char(Pointer(Longint(Buffer) + BufPtr)^);
      Inc(BufPtr);
      if not MatchCase.Checked and (c in Lowers) then c := UpCase(c);
      if c = Str[Increment] then
        Inc(Increment)
      else
      begin
        Inc(Index, Increment);
        Increment := 1;
      end;
      if Increment = (Length(Str) + 1) then
      begin
        Result := Index;
        Break;
      end;
    until BufEnd = 0;
  finally
    FreeMem(Buffer, BufSize);
    CloseFile(F);
    FileMode := LastMode;
  end;
end;

procedure TFindForm.ExtractSearchMasks;
var
  specs: TFilename;
begin
  specs := RemoveSpaces(FileEdit.Text);
  FileSpecs.Clear;
  if specs > '' then
    repeat FileSpecs.Add(GetWord(specs, ';')) until specs = '';
end;

procedure TFindForm.UpdateStatusBar;
begin
  FoundLabel.Caption := Format(SSItemsFound, [Listbox.Items.Count]);
  SelLabel.Caption := Format(SSFoundSelected, [Listbox.SelCount]);
  PaintStatusbar;
end;

procedure TFindForm.PaintStatusbar;
var
  R: TRect;
begin
  if Searching then
  begin
    SelLabel.Visible := False;
    R := Rect(3, Listbox.Top + Listbox.Height + 3,
      ClientWidth - 3, ClientHeight - 3);
    with Canvas do
    begin
      Brush.Color := Color;
      FillRect(R);
      Draw(ClientWidth - 17, ClientHeight - 17, Sizebox);
    end;
    Exit;
  end;
  SelLabel.Visible := True;
  R := Rect(3, ClientHeight - 21, SelLabel.Left - 8, ClientHeight - 3);
  RecessBevel(Canvas, R);
  R.Left := R.Right + 3;
  R.Right := ClientWidth - 3;
  RecessBevel(Canvas, R);
  if WindowState = wsNormal then
    Canvas.Draw(ClientWidth - 17, ClientHeight - 17, Sizebox);
end;

procedure TFindForm.ClearBtnClick(Sender: TObject); { 3.11 }
begin
  with Listbox do
  begin
    Items.Clear;
    Enabled := False;
    SearchCount := 0;
  end;
  UpdateStatusbar;
end;

procedure TFindForm.ListboxDrawItem(Control: TWinControl; Index: Integer;
  Rect: TRect; State: TOwnerDrawState);
var
  filename: string[15];
  location: TFilename;
  size: string[15];
  date: string[15];
begin
  with Listbox, Listbox.Canvas do
  begin
    FillRect(Rect);
    if FindDlgIcons then
    begin
      Draw(Rect.Left, Rect.Top, TIcon(Items.Objects[Index]));
      Inc(Rect.Left, 20);
    end;
    Inc(Rect.Top);
    Unformat(Items[Index], '%s;%s;%s;%s',
      [@filename, 15, @location, 79, @size, 15, @date, 15]);
    if UpcaseFirstChar then filename[1] := Upcase(filename[1]);
    location[1] := Upcase(location[1]);
    TextOut(Rect.Left + 2, Rect.Top, filename);
    TextOut(LocStart, Rect.Top, MinimizeName(location, Canvas, SizeStart - LocStart));
    TextOut(DateStart - 10 - TextWidth(size), Rect.Top, size);
    TextOut(DateStart, Rect.Top, date);
  end;
end;

procedure TFindForm.HeaderSized(Sender: TObject; ASection,
  AWidth: Integer);
begin
  GetHeaderDivisions(Header, [@LocStart, @SizeStart, @DateStart]);
  Listbox.Invalidate;
end;

function TFindForm.FilenameAt(i: Integer): TFilename;
var
  name: string[15];
  location: TFilename;
begin
  { The listbox stores the name and location the wrong way around... }
  Unformat(Listbox.Items[i], '%s;%s;', [@name, 15, @location, 79]);
  Result := MakePath(location) + name;
end;

function TFindForm.IsFile(i: Integer): Boolean;
begin
  Result := Listbox.Items.Objects[i] <> TinyFolder;
end;

function TFindForm.CompileSelection: TStringList;
var
  i: Integer;
begin
  FSelection.Clear;
  for i := 0 to Listbox.Items.Count - 1 do
    if Listbox.Selected[i] then FSelection.Add(FilenameAt(i));
  Result := FSelection;
end;

procedure TFindForm.DeleteClick(Sender: TObject);
var
  i: Integer;
  s: TFilename;
begin
  if not Searching then with Listbox do
  begin
    NoToAll;
    i := 0;
    Items.BeginUpdate;
    Desktop.SetCursor(crHourGlass);
    try
      for i := Items.Count - 1 downto 0 do
        if Selected[i] then
        begin
          if GetAsyncKeyState(VK_ESCAPE) < 0 then Break;
          s := FilenameAt(i);
          if IsFile(i) and EraseFile(s, -1) then
          begin
            Items.Delete(i);
            Desktop.RefreshList.Add(ExtractFileDir(s));
          end
        end;
    finally
      if not FileSysChangeOn { 3.2 } then Desktop.RefreshNow;
      Desktop.ReleaseCursor;
      Items.EndUpdate;
      Enabled := Items.Count > 0;
      UpdateStatusBar;
    end;
  end;
end;

procedure TFindForm.OpenParentClick(Sender: TObject);
var
  folder, filename: TFilename;
  w: TIconWindow;
begin
  with Listbox do
  if ItemIndex <> -1 then
  begin
    filename := FilenameAt(ItemIndex);
    folder := ExtractFileDir(filename);
    Desktop.OpenFolder(folder);
    w := Desktop.WindowOf(folder);
    if w <> nil then w.GotoItem(ExtractFilename(filename));
  end;
end;

procedure TFindForm.MenuPopup(Sender: TObject);
begin
  Open.Enabled := Listbox.ItemIndex <> -1;
  OpenWith.Enabled := Open.Enabled and IsFile(Listbox.ItemIndex);
  OpenParent.Enabled := Open.Enabled;
  Delete.Enabled := Open.Enabled;
end;

procedure TFindForm.FormShow(Sender: TObject);
begin
  if StartEdit.Text = '' then
    StartEdit.Text := LowerCase(Copy(GetCurrentDir, 1, 3));
  FileEdit.SetFocus;
  Taskbar.AddButton(Handle);
end;

procedure TFindForm.FormHide(Sender: TObject);
begin
  Taskbar.DeleteButton(Handle);
end;

procedure TFindForm.DropServerFileDrop(Sender: TObject; X, Y: Integer;
  Target: Word);
begin
  with DropServer.Files do
  begin
    Assign(CompileSelection);
    if IsPrintManager(Target) and (Count > 0) then
    begin
      PrintFile(Strings[0]);
      Clear;
    end;
  end;
end;

procedure TFindForm.ListboxMouseMove(Sender: TObject; Shift: TShiftState;
  X, Y: Integer);
begin
  if Listbox.Dragging then
    { 3.11 -- new DragCursor logic }
    if DropServer.CanDrop then
      ReplaceNodropCursor(HDropAlias)
    else
      RestoreNodropCursor;
end;

procedure TFindForm.ListboxEndDrag(Sender, Target: TObject; X,
  Y: Integer);
begin
  if GetAsyncKeyState(VK_LBUTTON) >= 0 then
    DropServer.DragFinished;
end;

procedure TFindForm.OpenClick(Sender: TObject);
var
  s: TFilename;
begin
  with Listbox do
    if ItemIndex <> -1 then
    begin
      s := FilenameAt(ItemIndex);
      if Items.Objects[ItemIndex] = TinyFolder then Desktop.OpenFolder(s)
      else DefaultExec(s, '', ExtractFileDir(s), SW_SHOWNORMAL);
    end;
end;

procedure TFindForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := caFree;
  SavePosition(ini, 'Find Dialog');
end;

procedure TFindForm.StartEditKeyPress(Sender: TObject; var Key: Char);
begin
  Key := LowCase(Key);
end;

procedure TFindForm.ListboxClick(Sender: TObject);
begin
  UpdateStatusBar;
end;

procedure TFindForm.FormPaint(Sender: TObject);
begin
  Border3D(Canvas, ClientRect);
  Control3D(Canvas, Header);
  PaintStatusbar;
end;

procedure TFindForm.BrowseBtnClick(Sender: TObject);
begin
  SubFolders.Checked := True;
  StartEdit.Text := SelectFolder(StartEdit.Text);
end;

procedure TFindForm.SettingsChanged(Changes: TSettingChanges);
begin
  if scFileSystem in Changes then Listbox.Invalidate;
  if scSystem in Changes then
  begin
    ini.ReadNewStrings('Search for', FileEdit.Items);
    ini.ReadNewStrings('Start from', StartEdit.Items);
  end;
end;

procedure TFindForm.CopyFilenamesClick(Sender: TObject);
var
  strings: TStringList;
  filename: string[15];
  location: TFilename;
  size: string[15];
  date: string[15];
  locwidth: Integer;
  i: Integer;
begin
  strings := TStringList.Create;
  try
    locwidth := Header.SectionWidth[1] div Canvas.TextWidth('n');
    with Listbox do
      for i := 0 to Items.Count - 1 do
        if Selected[i] then
          if LongBool(TComponent(Sender).Tag) then
          begin
            Unformat(Items[i], '%s;%s;%s;%s',
              [@filename, 15, @location, 79, @size, 15, @date, 15]);
            strings.Add(Format('%-12s %-*s %10s %s',
              [filename, locwidth, location, size, date]));
          end
          else strings.Add(FilenameAt(i));
    CopyStringsToClipboard(strings);
  finally
    strings.Free;
  end;
end;

procedure TFindForm.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  CanClose := not Searching;
end;

procedure TFindForm.FormResize(Sender: TObject);
begin
  if WindowState <> wsMinimized then begin
    StretchShift([TabPanel { 2.12 }, Header, FileEdit, StartEdit,
      TextEdit { 3.1 }], [stWidth]);
    StretchShift([SearchBtn, ClearBtn, BrowseBtn, Image], [stLeft]);
    StretchShift([Listbox], [stWidth, stHeight]);
    StretchShift([FoundLabel, SelLabel], [stTop]);
    Invalidate;
  end;
end;

procedure TFindForm.OpenWithClick(Sender: TObject);
var
  s: TFilename;
begin
  with Listbox do
    if (ItemIndex > -1) and IsFile(ItemIndex) then
    begin
      ShowHourGlass;
      s := TOpenFileDlg.Execute;
      if s > '' then OpenFileWith(FilenameAt(ItemIndex), s);
    end;
end;

procedure FileFindExecute(const StartPath: string);
begin
  ShowHourglass;
  if FindForm = nil then FindForm := TFindForm.Create(Application);
  with FindForm do begin
    if Searching then Searching := False;
    AssignHistoryText(FileEdit, '');
    AssignHistoryText(StartEdit, Lowercase(StartPath));
    WindowState := wsNormal;
    Show;
  end;
end;

procedure TFindForm.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if (Key = VK_TAB) and (ssCtrl in Shift) then
    TabPanel.SelectNext(not (ssShift in Shift));
end;

procedure TFindForm.ListboxMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
  i: Integer;
  p: TPoint;
begin
  if button <> mbRight then Exit;
  with ListBox do
  begin
    if Dragging then
      { 3.11 -- cancel file drag }
      EndDrag(False)
    else
    begin
      if Selected[ItemAtPos(Point(X, Y), True)] then
      begin
        GetCursorPos(p);
        Menu.Popup(p.x, p.y) { 2.2b }
      end;
    end;
  end;
end;

end.

