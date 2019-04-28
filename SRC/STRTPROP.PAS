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

unit Strtprop;

{ Start Menu Properties Dialog

  The main control is a TOutline that contains a copy of the start
  menu.  Each outline node contains a pointer to a dynamic 255 char
  string that stores additional data.  The string size is fixed
  because TOutlineNode's Data property cannot be used easily with
  AssignStr, which requires a var parameter. }

interface

uses WinTypes, WinProcs, Classes, Graphics, Forms, Controls, Buttons,
  StdCtrls, Menus, Grids, Outline, TabNotBk, SysUtils, Chklist, StylSped,
  Scrtree, Messages, CalForm, ExtForm, Settings, ExtCtrls, TabPanel, Picbtn,
  Spin, DdeMan;

type
  TStartPropDlg = class(TCalForm)
    OutlineMenu: TPopupMenu;
    AddItem: TMenuItem;
    InsertItem: TMenuItem;
    EditItem: TMenuItem;
    DeleteItem: TMenuItem;
    ExpandItem: TMenuItem;
    CollapseItem: TMenuItem;
    N1: TMenuItem;
    Convert: TMenuItem;
    cbModified: TCheckBox;
    TabPanel: TTabPanel;
    Notebook: TNotebook;
    AddBtn: TStyleSpeed;
    InsertBtn: TStyleSpeed;
    EditBtn: TStyleSpeed;
    DeleteBtn: TStyleSpeed;
    ConvertBtn: TStyleSpeed;
    Outline: TScrollTree;
    Bevel1: TBevel;
    Label1: TLabel;
    Win31Menu: TRadioButton;
    Win95Menu: TRadioButton;
    NewStyles: TCheckList;
    PrefList: TCheckList;
    Label2: TLabel;
    OKBtn: TPicBtn;
    CancelBtn: TPicBtn;
    HelpBtn: TPicBtn;
    Label3: TLabel;
    LrgItmHeight: TSpinEdit;
    Label4: TLabel;
    ExportBtn: TStyleSpeed;
    ExpandAll: TMenuItem;
    N2: TMenuItem;
    Export: TMenuItem;
    N3: TMenuItem;
    ExpandBranch: TMenuItem;
    Progman: TDdeClientConv; { 3.0 }
    procedure OutlineDragDrop(Sender, Source: TObject; X, Y: Integer);
    procedure OutlineDragOver(Sender, Source: TObject; X, Y: Integer;
      State: TDragState; var Accept: Boolean);
    procedure OutlineEndDrag(Sender, Target: TObject; X, Y: Integer);
    procedure OutlineMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure AddItemClick(Sender: TObject);
    procedure InsertItemClick(Sender: TObject);
    procedure EditItemClick(Sender: TObject);
    procedure DeleteItemClick(Sender: TObject);
    procedure ExpandItemClick(Sender: TObject);
    procedure CollapseItemClick(Sender: TObject);
    procedure ConvertClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure OKBtnClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure OutlineDrawItem(Control: TWinControl; Index: Integer;
      Rect: TRect; State: TOwnerDrawState);
    procedure CancelBtnClick(Sender: TObject);
    procedure OutlineDblClick(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure Win31MenuClick(Sender: TObject);
    procedure NewStylesClick(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure OutlineMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure ExpandAllClick(Sender: TObject);
    procedure ExpandBranchClick(Sender: TObject);
    procedure ExportClick(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure OutlineMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure FormPaint(Sender: TObject);
    {procedure ModifiedMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);} { 2.2 }
  private
    { Private declarations }
    DragItem: Longint;
    ProgramsMenu: Longint;
    CurrentGroup: Longint;
    {IconsChanged: Boolean;} { 2.2 }
    procedure ConvertProgItem(Sender: TObject; const group,
      caption: TFilename; const data: string);
    function AddOutlineNode(index : Longint; const cap, data: string;
      Op: TAttachMode): Longint;
    function FindChildNode(ParentNode: Longint; const caption: string): Longint;
    procedure DisposeNode(node: TOutlineNode);
    function MenuNodeAt(X, Y: Integer): Longint;
    procedure DDECreateGroup(const s: string);
    procedure DDEShowGroup(const s: string);
    procedure DDEDeleteGroup(const s: string);
    procedure DDEAddItem(const Command, Caption, IconFile: TFilename;
      IconIndex, X, Y: Integer; Directory: TFilename);
    procedure DDEDeleteItem(const s: string);
  public
    { Public declarations }
    procedure Configure;
    procedure SettingsChanged(Changes: TSettingChanges); override;
    { 3.11 }
    procedure ProcessDDECommands; { 3.11 made public }
    procedure GetGroups(s: TStrings);
  end;

var
  StartPropDlg: TStartPropDlg;
  NewStartItems: TStringList;
  ShellDDEBuf: TStringList;

implementation

{$R *.DFM}

uses Start, ProgConv, MenuEdit, MultiGrd, IconWin, Directry, Files,
  CompSys, MiscUtil, Dialogs, Strings, Desk, Resource, Locale, Task;

procedure TStartPropDlg.OutlineDragDrop(Sender, Source: TObject; X,
  Y: Integer);
const
  Attach: array[Boolean] of TAttachMode = (oaInsert, oaAddChild);
var
  dest: Longint;
  i: Integer;
begin
  Outline.DropFocus := -1;
  dest := Outline.GetItemAt(X, Y);
  { Handle drops from icon windows or from outline itself }
  if Source is TMultiGrid then
    with (TMultiGrid(Source).Owner as TIconWindow).CompileSelection(False) do
      for i := 0 to Count - 1 do
        with TDirItem(Items[i]) do
          AddOutlineNode(dest, GetTitle, GetStartInfo, oaAddChild)
  else with Outline, Items[DragItem] do
    if GetAsyncKeyState(VK_CONTROL) < 0 then
      AddOutlineNode(dest, Text, PString(Data)^,
        Attach[GetAsyncKeyState(VK_MENU) < 0])
    else
    begin
      Collapse;
      MoveTo(dest, Attach[GetAsyncKeyState(VK_MENU) < 0]);
    end;
  cbModified.State := cbGrayed; { 3.0 }
end;

procedure TStartPropDlg.OutlineDragOver(Sender, Source: TObject;
  X, Y: Integer; State: TDragState; var Accept: Boolean);
begin
  { Scroll the outline if the cursor is floating over the top or
    bottom scrollbutton }
  with Outline do
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
  Accept := ((Sender = Source) or (Source is TMultiGrid) and
    (Source <> Computer.Grid)) and (Outline.GetItemAt(X, Y) > 0);
  with Outline do
    if not Accept or (State = dsDragLeave) then DropFocus := -1
    else DropFocus := GetCellAt(X, Y);
end;

procedure TStartPropDlg.OutlineEndDrag(Sender, Target: TObject;
  X, Y: Integer);
begin
  Computer.DragTimer.Enabled := False; { 3.11 }
  ClipCursor(nil);
end;

function TStartPropDlg.MenuNodeAt(X, Y : Integer): Longint;
var
  P: Integer;
begin
  Result := Outline.GetItem(X, Y);
  if Result > 0 then with Outline.Items[Result] do
  begin
    P := (Level - 1) { 3.0 } * 18 + 2;
    if HasItems and (X >= P) and (X <= P + 12) then Exit;
  end;
  Result := 0;
end;

procedure TStartPropDlg.OutlineMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  r: TRect;
  i: Longint;
  p: TPoint;
begin
  if ssDouble in Shift then Exit
  else if Button = mbRight then with Outline do
  begin
    if Dragging then EndDrag(False)
    else
    begin
      { Select the item under the cursor and popup menu }
      if GetCaptureControl <> nil then Exit;
      i := GetItem(X, Y);
      if i > 0 then SelectedItem := i;
      GetCursorPos(p);
      OutlineMenu.Popup(p.X, p.Y);
    end;
  end
  else with Outline do
  begin
    DragItem := GetItem(X, Y);
    if (DragItem > 0) and (MenuNodeAt(X, Y) = 0) then
    begin
      with Self.ClientRect do
      begin
        r.TopLeft := Self.ClientToScreen(TopLeft);
        r.BottomRight := Self.ClientToScreen(Bottomright);
        ClipCursor(@r);
      end;
      { 3.11 }
      DragCursor := crDropFile;
      Computer.DragTimer.enabled := True;
      BeginDrag(False);
    end;
  end
end;

procedure TStartPropDlg.AddItemClick(Sender: TObject);
begin
  with MenuEditDlg do
    if EditItem(LoadStr(SAddMenuItem), '', ';;;;') = mrOK then
      AddOutlineNode(Outline.SelectedItem, CaptionEdit.Text, DataString, oaInsert);
end;

procedure TStartPropDlg.InsertItemClick(Sender: TObject);
begin
  with Outline, MenuEditDlg do
    if SelectedItem = 0 then AddItem.Click
    else if EditItem(LoadStr(SInsertMenuItem), '', ';;;;') = mrOK then
      AddOutlineNode(SelectedItem, CaptionEdit.Text, DataString, oaAddChild);
end;

procedure TStartPropDlg.EditItemClick(Sender: TObject);
var
  node: TOutlineNode;
begin
  ShowHourglass;
  with Outline, MenuEditDlg do
    if (SelectedItem > 0) then
    begin
      node := Items[SelectedItem];
      if EditItem(LoadStr(SMenuItemProperties), node.Text,
        PString(node.Data)^) = mrOK then
      begin
        PString(node.Data)^ := DataString;
        node.Text := CaptionEdit.Text;
        cbModified.State := cbGrayed; { 3.0 }
      end;
    end;
end;

procedure TStartPropDlg.DisposeNode(node: TOutlineNode);
var
  i: Longint;
begin
  { Recursive procedure to free dynamic strings }
  Dispose(PString(node.Data));
  i := node.GetFirstChild;
  while i <> -1 do
  begin
    DisposeNode(Outline.Items[i]);
    i := node.GetNextChild(i);
  end;
end;

procedure TStartPropDlg.DeleteItemClick(Sender: TObject);
var
  node: TOutlineNode;
  i: Longint;
begin
  with Outline do
    if SelectedItem > 0 then
    begin
      node := Items[SelectedItem];
      if node.HasItems and (MsgDialogRes(SQueryDeleteMenu,
        mtConfirmation, [mbYes, mbNo], 0) <> mrYes) then Exit;
      DisposeNode(node);
      DeleteSelectedNode;
      cbModified.State := cbGrayed; { 3.0 }
    end;
end;

procedure TStartPropDlg.ExpandItemClick(Sender: TObject);
begin
  with Outline do Items[SelectedItem].Expand;
end;

procedure TStartPropDlg.ExpandBranchClick(Sender: TObject);
begin
  with Outline do Items[SelectedItem].FullExpand;
end;

procedure TStartPropDlg.CollapseItemClick(Sender: TObject);
begin
  with Outline do Items[SelectedItem].Collapse;
end;

procedure TStartPropDlg.ExpandAllClick(Sender: TObject);
begin
  Outline.FullExpand;
end;

procedure TStartPropDlg.ConvertClick(Sender: TObject);
begin
  ShowHourGlass;
  with TConvertDlg.Create(Application) do
  try
    OnConvertProg := ConvertProgItem;
    ShowModal;
  finally
    Free;
  end;
end;

procedure TStartPropDlg.ConvertProgItem(Sender: TObject;
  const group, caption: TFilename; const data: string);
var
  i, parentnode: Longint;
begin
  with Outline do
  begin
    { Find existing submenu containing the group }
    parentnode := GetTextItem(group);
    if parentnode = 0 then
    begin
      { Create a new group node and add the item to it }
      parentnode := AddOutlineNode(SelectedItem, group, ';;;;', oaAdd);
      AddOutlineNode(parentnode, caption, data, oaAddChild);
    end
    else
    begin
      { An existing group has been found.  Now look for a matching
        menu item, and update it if found.  Otherwise, just add
        another item }
      i := Items[parentnode].GetFirstChild;
      while i <> -1 do
        if CompareText(Items[i].Text, caption) = 0 then
        begin
          PString(Items[i].Data)^ := data;
          Exit;
        end
        else i := Items[parentnode].GetNextChild(i);
      AddOutlineNode(parentnode, caption, data, oaAddChild);
    end;
  end;
end;

function TStartPropDlg.AddOutlineNode(index: Longint;
  const cap, data: string; Op: TAttachMode): Longint;
var
  p: PString;
begin
  { Add a new outline node with a dynamic string as the Data }
  New(p);
  p^ := data;
  case Op of
    oaAdd      : Result := Outline.AddObject(index, cap, p);
    oaAddChild : Result := Outline.AddChildObject(index, cap, p);
    oaInsert   : Result := Outline.InsertObject(index, cap, p);
  end;
  Outline.Items[Result].FullExpand;
  Outline.SelectedItem := Result; { 3.11 }
  cbModified.State := cbGrayed; { 3.0 }
end;

function TStartPropDlg.FindChildNode(ParentNode: Longint; const caption: string): Longint;
var
  node: TOutlineNode;
begin
  with Outline do
  begin
    node := Items[ParentNode];
    Result := node.GetFirstChild;
    while Result > -1 do
    begin
      if Items[Result].Text = caption then Exit
      else Result := node.GetNextChild(Result);
    end;
    Result := 0;
  end;
end;

procedure TStartPropDlg.FormCreate(Sender: TObject);
var
  i: Integer;
begin
  { A menu editor dialog is created here to speed up editing }
  PrefList.Color := Colors[ccChecklist];
  Notebook.PageIndex := 0;
  MenuEditDlg := TMenuEditDlg.Create(Application);
  StartMenu.AssignToOutline(Outline);
  with NewStartItems do
  begin
    for i := 0 to Count - 1 do AddOutlineNode(0, GetStrKey(Strings[i]),
      GetStrValue(Strings[i]), oaAdd);
    Clear;
  end;
  with Outline do
  begin
    SetUpdateState(False);
    Canvas.Pen.Color := clGray;
    Items[1].Expand; { 3.11 }
  end;
  Configure;
  if StartMenu3D then Win95Menu.Checked := True
  else Win31Menu.Checked := True;
  LrgItmHeight.Value := LargeItemHeight; { 3.0 }
  NewStyles.SetData([LargeRootMenu, ColouredBar, BoldSelect]);
  PrefList.SetData([ShellStartup, StartMouseUp, ShellDDE, { 2.2 } Win95Keyboard]);
  cbModified.Checked := False;
  LoadPosition(ini, 'Start Menu Properties');
  {ProcessDDECommands;} { 3.11 }
  ProgramsMenu := Outline.GetTextItem(ini.ReadString('Start Menu',
    'ProgramsGroup', '&Programs')); { 3.11 }
  EnableControlList([OKBtn, Notebook], CanEditSettings); { 2.2 }
end;

procedure TStartPropDlg.Configure;
const
  BtnStyle: array[Boolean] of TSpeedStyle = (sbWin95, sbFlat);
begin
  with Outline do
  begin
    ThumbTracking := TrackThumb;
    ItemHeight := LineHeight;
    Canvas.Font.Assign(GlobalFont);
    { 3.1 }
    ReplaceBitmapColors(PictureClosed, PictureClosed.Canvas.Pixels[0,
      PictureClosed.Height - 1], Color);
    ReplaceBitmapColors(PictureOpen, PictureOpen.Canvas.Pixels[0,
      PictureOpen.Height - 1], Color);
  end;
  { 4.0 }
  EditBtn.Style := BtnStyle[FlatToolbarButtons];
  AddBtn.Style := BtnStyle[FlatToolbarButtons];
  InsertBtn.Style := BtnStyle[FlatToolbarButtons];
  DeleteBtn.Style := BtnStyle[FlatToolbarButtons];
  ConvertBtn.Style := BtnStyle[FlatToolbarButtons];
  ExportBtn.Style := BtnStyle[FlatToolbarButtons];
end;

procedure TStartPropDlg.FormDestroy(Sender: TObject);
var
  i: Longint;
begin
  if IsShell and ShellDDE then
    DdeMgr.AppName := 'PROGMAN';
  with Outline do
    for i := 1 to ItemCount do Dispose(PString(Items[i].Data));
  FreeAndNil(MenuEditDlg);
  StartPropDlg := nil;
end;

procedure TStartPropDlg.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  Action := caFree;
  SavePosition(ini, 'Start Menu Properties');
end;

procedure TStartPropDlg.OKBtnClick(Sender: TObject);
begin
  StartMenu3D := Win95Menu.Checked;
  LargeItemHeight := LrgItmHeight.Value; { 3.0 }
  NewStyles.GetData([@LargeRootMenu, @ColouredBar, @BoldSelect]);
  PrefList.GetData([@ShellStartup, @StartMouseUp, @ShellDDE, { 2.2 } @Win95Keyboard]);
  SaveStartProp;
  Taskbar.Configure;
  if not (cbModified.State = (cbUnchecked)) { 3.0 } then
  begin
    YieldDuringLoad := True;
    Cursor := crHourglass;
    try
      EnableControls(False);
      DeleteFile(FileWritePath + 'BMPCACHE.BMP');
      if cbModified.Checked then
        DeleteFile(FileWritePath + 'IMGINDEX.DAT'); { 3.0 }
      StartMenu.RebuildFromOutline(Outline);
    finally
      EnableControls(True);
      YieldDuringLoad := False;
      Cursor := crDefault;
      PlaySound(Sounds.Values['NotifyCompletion']);
    end;
  end;
  Close;
  AnnounceSettingsChanged([scStartMenu]);
end;

procedure TStartPropDlg.OutlineDrawItem(Control: TWinControl;
  Index: Integer; Rect: TRect; State: TOwnerDrawState);
var
  item: TOutlineNode;
  x, y: Integer;
  Focus: TRect;
begin
  { Fast outline drawing with no BrushCopy. }
  with Outline do
  begin
    index := GetItem(0, Rect.Top);
    item := Items[index];
    x := Rect.Left + item.Level * 18 + 2;
    y := (Rect.Top + Rect.Bottom) div 2;
    with Canvas do
    begin
      Brush.Color := Color;
      FillRect(Rect);
      if odSelected in State then
      begin { 3.0 }
        Brush.Color := clHighlight;
        Font.Color := clHighlightText;
        Focus := Rect;
        Focus.Left := x + 18;
        Focus.Right := Focus.Left + TextWidth(item.Text) + 4;
        FillRect(Focus);
      end
      else Font.Color := clWindowText;
      if item.HasItems then
        if item.Expanded then Draw(x, Rect.Top, PictureOpen)
        else Draw(x, Rect.Top, PictureClosed)
      else Draw(x, Rect.Top + 1, PictureLeaf);
      TextOut(x + 20, Rect.Top + 1, item.Text);
      if odSelected in State then DrawFocusRect(Focus);
      { Draw horizontal line connecting node to branch }
      MoveTo(x - 2, y);
      Dec(x, 12);
      DottedLineTo(x, y);
      { Draw vertical line, it's length depending on whether
        this node has additional siblings }
      if Item.Parent.GetLastChild = Item.Index then
        DottedLineTo(x, Rect.Top-1)
      else if index = 1 then
        DottedLineTo(x, Rect.Bottom) { 3.0 }
      else
      begin
        MoveTo(x, Rect.Top);
        DottedLineTo(x, Rect.Bottom);
      end;
      { Draw a suitable plus/minus picture depending on if
        there are subitems }
      if Item.HasItems then
        if item.Expanded then
          Draw(x - 4, y - 4, PictureMinus)
        else
          Draw(x - 4, y - 4, PicturePlus);
      { Loop back to the root through all parent nodes, drawing a
        vertical line if the parent has child nodes to be drawn
        below this node }
      item := item.Parent;
      while (Item <> nil) and (Item.Parent <> nil) do
      begin
        Dec(x, 18);
        if Item.Parent.GetLastChild > Item.Index then
        begin
          MoveTo(x, Rect.Top);
          DottedLineTo(x, Rect.Bottom);
        end;
        item := item.Parent;
      end;
    end;
  end;
end;

procedure TStartPropDlg.CancelBtnClick(Sender: TObject);
begin
  Close;
end;

procedure TStartPropDlg.SettingsChanged(Changes: TSettingChanges);
begin
  if [scDesktop, scDisplay, scFileSystem, scSystem] * Changes <> [] then
    Configure;
end;

procedure TStartPropDlg.OutlineDblClick(Sender: TObject);
begin
  with Outline do
    if (SelectedItem > 0) and not Items[SelectedItem].HasItems then
      EditBtn.Click;
end;

procedure TStartPropDlg.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
begin
  CanClose := Controls[0].Enabled;
end;

procedure TStartPropDlg.Win31MenuClick(Sender: TObject);
begin
  NewStyles.Enabled := Win95Menu.Checked;
  LrgItmHeight.Enabled := Win95Menu.Checked;
  cbModified.State := cbGrayed; { 3.0 }
end;

procedure TStartPropDlg.NewStylesClick(Sender: TObject);
begin
  if NewStyles.ItemIndex = 0 then begin
    cbModified.State := cbGrayed; { 3.0 }
  end;
end;

procedure TStartPropDlg.FormResize(Sender: TObject);
begin
  StretchShift([cbModified], [stTop]);
  StretchShift([HelpBtn, CancelBtn, OKBtn], [stLeft, stTop]);
  StretchShift([TabPanel { 2.12 }, Outline], [stWidth, stHeight]);
  StretchShift([Bevel1, PrefList], [stWidth]);
end;

procedure TStartPropDlg.OutlineMouseUp(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  item: Longint;
begin
  if (Button = mbLeft) and not (ssDouble in Shift) then
  begin
    item := MenuNodeAt(X, Y);
    if item > 0 then with Outline.Items[item] do
      Expanded := not Expanded;
  end;
end;

procedure TStartPropDlg.DDECreateGroup(const s: string);
var
  item: Longint;
begin
  item := FindChildNode(ProgramsMenu, s);
  if item = 0 then item := AddOutlineNode(ProgramsMenu, s, '', oaAddChild)
  else
  begin
    Outline.Items[item].FullExpand;
    Outline.SelectedItem := item; { 3.11 }
  end;
  CurrentGroup := item;
end;

procedure TStartPropDlg.DDEShowGroup(const s: string);
var
  item: Longint;
begin
  item := FindChildNode(ProgramsMenu, s);
  if item > 0 then
  begin
    Outline.Items[item].FullExpand;
    Outline.SelectedItem := item; { 3.11 }
    CurrentGroup := item;
  end;
end;

procedure TStartPropDlg.DDEDeleteGroup(const s: string);
var
  item: Longint;
begin
  item := FindChildNode(ProgramsMenu, s);
  if item > 0 then Outline.Delete(item);
end;

procedure TStartPropDlg.DDEAddItem(const Command, Caption, IconFile: TFilename;
  IconIndex, X, Y: Integer; Directory: TFilename);
begin
  if Directory = '' then Directory := ExtractFileDir(Command);
  AddOutlineNode(CurrentGroup, Caption, PackStartInfo(Command, Directory,
    IconFile, 0, IconIndex), oaAddChild);
end;

procedure TStartPropDlg.DDEDeleteItem(const s: string);
var
  item: Longint;
begin
  item := FindChildNode(CurrentGroup, s);
  if item > 0 then Outline.Delete(item);
end;

function GetStrParam(var s: string): TFilename;
var
  i: Integer;
begin
  if (s = '') or (s[1] = ')') or (s[1] = ']') then Result := ''
  else
  begin
    if s[1] = '"' then begin
      i := 2;
      while (i < Length(s)) and (s[i] <> '"') do Inc(i);
      Result := Copy(s, 2, i - 2);
      if (i < Length(s)) and (s[i + 1] = ',') then Inc(i);
    end
    else
    begin
      i := 1;
      while (i < Length(s)) and (s[i] <> ',') and (s[i] <> ')') do Inc(i);
      Result := Copy(s, 1, i - 1);
    end;
    Delete(s, 1, i);
  end;
end;

function GetIntParam(var s: string): Integer;
var
  i: Integer;
  field: string[15];
begin
  if (s = '') or (s[1] = ')') or (s[1] = ']') then Result := 0
  else
  begin
    i := 1;
    while (i < Length(s)) and ((s[i] in Digits) or (s[i] = '-')) do Inc(i);
    Result := StrToIntDef(Copy(s, 1, i - 1), 0);
    Delete(s, 1, i);
  end;
end;

const
  CommandPrefixes : array[0..5] of string[15] =
    ('[CreateGroup(', '[ShowGroup(', '[DeleteGroup(',
     '[AddItem(', '[ReplaceItem(', '[DeleteItem(');

function ParseCommand(var s: string): Integer;
var
  t: string[15];
begin
  for Result := 0 to High(CommandPrefixes) do
  begin
    t := Copy(s, 1, Length(CommandPrefixes[Result]));
    if CompareText(CommandPrefixes[Result], t) = 0 then
    begin
      Delete(s, 1, Length(CommandPrefixes[Result]));
      Exit;
    end;
  end;
  Result := -1;
end;

procedure TStartPropDlg.ProcessDDECommands;
var
  i,p : Integer;
  s: string;
begin
  if (StartPropDlg = nil) or (ProgramsMenu <= 0) or (ShellDDEBuf.Count = 0) then
  begin
    { 2.12 }
    ShellDDEBuf.Clear;
    Exit;
  end;
  i := 0;
  while i < ShellDDEBuf.Count do
  begin
    s := ShellDDEBuf[i];
    case ParseCommand(s) of
      0: DDECreateGroup(GetStrParam(s));
      1: DDEShowGroup(GetStrParam(s));
      2: DDEDeleteGroup(GetStrParam(s));
      3: DDEAddItem(GetStrParam(s), GetStrParam(s), GetStrParam(s),
           GetIntParam(s), GetIntParam(s), GetIntParam(s), GetStrParam(s));
      4: DDEDeleteItem(GetStrParam(s));
      5: DDEDeleteItem(GetStrParam(s));
    end;
    p := Pos('][', s);
    if p > 0 then
    begin
      Delete(s, 1, p);
      if s > '' then ShellDDEBuf.Insert(i + 1, s);
    end;
    Inc(i);
  end;
  ShellDDEBuf.Clear;
  cbModified.State := cbGrayed;
end;

procedure TStartPropDlg.GetGroups(s: TStrings);
var
  node: TOutlineNode;
  item: Longint;
begin
  CurrentGroup := ProgramsMenu;
  node := Outline.Items[ProgramsMenu];
  node.Expand;
  item := node.GetFirstChild;
  while item > -1 do
  begin
    if Outline.Items[item].HasItems then
      s.Add(Outline.Items[item].Text);
    item := node.GetNextChild(item);
  end;
end;

const
  ProgmanOpen: Boolean = False;

procedure TStartPropDlg.ExportClick(Sender: TObject);
var
  MacroList: TStringList;
  cmd: array[0..255] of Char;
  group, node: TOutlineNode;
  index: Longint;
begin
  MacroList := TStringList.Create;
  try
    DdeMgr.AppName := 'CALMIRA';
    if not ProgmanOpen then ProgmanOpen := Progman.OpenLink;
    if ProgmanOpen then
      with Outline do
      begin
        if (SelectedItem > 0) and Items[SelectedItem].HasItems then
        begin
          group := Items[SelectedItem];
          index := group.GetFirstChild;
          while index > -1 do
          begin
            node := Items[index];
            with ExtractStartInfo(PString(node.Data)^) do
              if Command > '' then
                MacroList.Add(Format('[AddItem("%s","%s",%s,%d,,,%s,,%d)]',
                  [Command, node.Text, IconFile, IconIndex, Directory,
                   Integer(ShowMode = 1)]));
            index := group.GetNextChild(index);
          end;
          if Macrolist.Count > 0 then
          begin
            StrPCopy(cmd, Format('[CreateGroup("%s")]', [group.Text]));
            Progman.ExecuteMacro(cmd, False);
            while Macrolist.Count > 0 do
            begin
              StrPCopy(cmd, MacroList[0]);
              Progman.ExecuteMacro(cmd, False);
              MacroList.Delete(0);
            end
          end;
        end;
      end
      else
        ErrorMsgRes(SCannotFindProgman);
  finally
    MacroList.Free;
  end;
end;

procedure TStartPropDlg.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if (Key = VK_TAB) and (ssCtrl in Shift) then
    TabPanel.SelectNext(not (ssShift in Shift));
end;

procedure TStartPropDlg.OutlineMouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Integer);
const
  DragCursors: array[Boolean, Boolean] of TCursor =
    ((crDropFile, crDropCopy), (crDropFolder, crDropFolderCopy ));
begin
  with Outline do if Dragging then
  begin
    DragCursor := DragCursors[ssAlt in Shift, ssCtrl in Shift];
  end;
end;

procedure TStartPropDlg.FormPaint(Sender: TObject);
begin
  Canvas.Draw(ClientWidth - 14, ClientHeight - 14, Sizebox);
end;

procedure DoneStartProp; far;
begin
  NewStartItems.Free;
  ShellDDEBuf.Free;
end;

initialization
  NewStartItems := TStringList.Create;
  ShellDDEBuf := TStringList.Create;
  AddExitProc(DoneStartProp);
end.

