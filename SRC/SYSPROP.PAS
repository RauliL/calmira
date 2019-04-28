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

unit Sysprop;

interface

uses WinTypes, WinProcs, Classes, Graphics, Forms, Controls, Buttons,
  StdCtrls, ExtCtrls, Chklist, TabNotBk, Grids, StylSped, Outline, Spin,
  Scrtree, Dialogs, Settings, CalForm, ExtForm, TabPanel, Picbtn, Profile;

type
  TSysPropDlg = class(TForm)
    TabPanel: TTabPanel;
    Notebook: TNotebook;
    Bevel1: TBevel;
    Label2: TLabel;
    CapEdit: TEdit;
    Label12: TLabel;
    HistoryCombo: TComboBox;
    ClearHistBtn: TStyleSpeed;
    Label1: TLabel;
    PrefList: TCheckList;
    Outline: TScrollTree;
    AddBtn: TStyleSpeed;
    RemoveBtn: TStyleSpeed;
    SaveBtn: TStyleSpeed;
    OKBtn: TPicBtn;
    CancelBtn: TPicBtn;
    HelpBtn: TPicBtn;
    Bevel5: TBevel;
    rbShareSettings: TRadioButton;
    rbMultiProfiles: TRadioButton;
    UserList: TListBox;
    AddUserBtn: TStyleSpeed;
    ChangePasswordBtn: TStyleSpeed;
    RemoveUserBtn: TStyleSpeed;
    Label10: TLabel;
    ModifyBtn: TStyleSpeed;
    cbNoAnonUser: TCheckBox;
    cbApplyChanges: TCheckBox;
    Bevel6: TBevel;
    BrowserEdit: TEdit;
    Bevel7: TBevel;
    Label11: TLabel;
    PrefixEdit: TEdit;
    Label13: TLabel;
    BrowserBtn: TStyleSpeed;
    DefLabel: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    OpenDialog: TOpenDialog;
    SndOutline: TScrollTree;
    Label5: TLabel;
    Bevel2: TBevel;
    Label6: TLabel;
    Label7: TLabel;
    SoundEdit: TComboBox;
    SoundBtn: TStyleSpeed;
    PlayBtn: TStyleSpeed;
    StopBtn: TStyleSpeed;
    OpenSoundDialog: TOpenDialog;
    procedure FormCreate(Sender: TObject);
    procedure OKBtnClick(Sender: TObject);
    procedure OutlineDrawItem(Control: TWinControl; Index: Integer;
      Rect: TRect; State: TOwnerDrawState);
    procedure AddBtnClick(Sender: TObject);
    procedure RemoveBtnClick(Sender: TObject);
    procedure ModifyBtnClick(Sender: TObject);
    procedure OutlineClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure SaveBtnClick(Sender: TObject);
    procedure OutlineMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure ClearHistBtnClick(Sender: TObject);
    procedure OutlineDblClick(Sender: TObject);
    procedure TabPanelChange(Sender: TObject; NewTab: Integer;
      var AllowChange: Boolean);
    { 2.2a }
    procedure AddUserBtnClick(Sender: TObject);
    procedure RemoveUserBtnClick(Sender: TObject);
    procedure ChangePasswordBtnClick(Sender: TObject);
    { 3.01 }
    procedure rbMultiProfilesClick(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure BrowserBtnClick(Sender: TObject);
    { 4.0 }
    procedure SoundBtnClick(Sender: TObject);
    procedure PlayBtnClick(Sender: TObject);
    procedure StopBtnClick(Sender: TObject);
  private
    { Private declarations }
    FilledOutline: Boolean;
    AdvancedChanged: Boolean;
    Histories: TStringList;
    UserIni: TProfile;
  public
    { Public declarations }
  end;

{
var
  SysPropDlg: TSysPropDlg;
}

implementation

uses Drives, MiscUtil, CompSys, SysUtils, Strings, IconDlg, Locale, Embed,
  FileMan, Password, CalMsgs, Registry, Internet, Environs;

{$R *.DFM}

procedure TSysPropDlg.FormCreate(Sender: TObject);
var
  code, i: Integer;
  rec: TSearchRec;
begin
  PrefList.Color := Colors[ccChecklist];
  Notebook.PageIndex := 0;
  CapEdit.Text := ComputerCaption;
  Histories := TStringList.Create;
  ini.ReadSectionValues('History lists', Histories);
  for i := 0 to Histories.Count - 1 do
    HistoryCombo.Items.Add(GetStrKey(Histories[i]));
  PrefList.SetData(
    [ShowSplash, RestoreSys, SysWinQuit, MsgDialogSounds,
     TrackThumb, GlobalHotkeys, NotifyNoIcons, EnableDosScripts,
     EnableWinScripts, ShowDailyTips, CompIconStart,
     DarkIconStretch, HQIconStretch { 3.1 }, PicBtnGlyphs { 2.12 },
     ShowShutDownBMP { 3.0 }]);
  UserIni := TProfile.Create(BasePath + 'calusers.ini');
  { 3.0 -- Moved from TabPanelChange: }
  UserIni.ReadSection('Users', UserList.Items);
  rbMultiProfiles.Checked := UserIni.ReadBool('Settings', 'MultipleProfiles', False);
  { 3.01 }
  cbNoAnonUser.Checked := UserIni.ReadBool('Settings', 'NoAnonUser', False);
  cbNoAnonUser.Enabled := rbMultiProfiles.Checked;
  { 3.1 }
  cbApplyChanges.Checked := False;
  { 3.11 }
  BrowserBtn.Glyph.Handle := LoadBitmap(HInstance, 'BBBROWSE');
  with Computer.BrowserLink do
  begin
    ReadServiceApplication;
    DefLabel.Caption := ServiceApplication;
  end;
  BrowserEdit.Text := Browser;
  PrefixEdit.Text := URLPrefixes;
  { 4.0 Sounds }
  SoundBtn.Glyph.Handle := LoadBitmap(HInstance, 'BBBROWSE');

  with SoundEdit do
  begin
    code := FindFirst(Environment.Values['WINDIR'] + '\*.WAV', 0, rec);
    while code = 0 do
    begin
      Items.Add(LowerCase(rec.Name));
      code := FindNext(rec);
    end;
    FindClose(rec);
  end;

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
    ReplaceBitmapColors(PictureLeaf, PictureLeaf.Canvas.Pixels[0,
      PictureLeaf.Height - 1], Color);
  end;
  EnableControlList([OKBtn, Notebook], CanEditSettings); { 2.2 }
end;

procedure TSysPropDlg.OKBtnClick(Sender: TObject);
begin
  ComputerCaption := CapEdit.Text;
  PrefList.GetData(
    [@ShowSplash, @RestoreSys, @SysWinQuit, @MsgDialogSounds,
     @TrackThumb, @GlobalHotKeys, @NotifyNoIcons, @EnableDosScripts,
     @EnableWinScripts, @ShowDailyTips, @CompIconStart,
     @DarkIconStretch, @HQIconStretch { 3.1 }, @PicBtnGlyphs { 2.12 },
     @ShowShutDownBMP { 3.0 }]);
  Browser := BrowserEdit.Text; { 3.11 }
  URLPrefixes := PrefixEdit.Text; { 3.11 }
  SaveSystemProp;
  MultipleProfiles := rbMultiProfiles.Checked;
  UserIni.WriteBool('Settings', 'MultipleProfiles',
    (rbMultiProfiles.Checked) and (UserList.Items.Count > 0));
  { 3.01 }
  UserIni.WriteBool('Settings', 'NoAnonUser', cbNoAnonUser.Checked);
  if AdvancedChanged and (MsgDialogRes(SQuerySaveAdvanced,
    mtConfirmation, [mbYes, mbNo], 0) = mrYes) then SaveBtn.Click;
  AnnounceSettingsChanged([scSystem]);
end;

procedure TSysPropDlg.OutlineDrawItem(Control: TWinControl; Index: Integer;
  Rect: TRect; State: TOwnerDrawState);
var
  item: TOutlineNode;
  Focus: TRect;
  x: Integer;
begin
  with Outline do begin
    Index := GetItem(0, Rect.Top);
    item := Items[Index];
    x := Rect.Left + (item.Level - 1) * 18 + 2;
    with Canvas do begin
      Brush.Color := Color;
      FillRect(Rect);
      if odSelected in State then begin { 3.0 }
        Brush.Color := clHighlight;
        Font.Color := clHighlightText;
        Focus := Rect;
        Focus.Left := x + 18;
        Focus.Right := Focus.Left + TextWidth(item.Text) + 4;
        FillRect(Focus);
      end
      else Font.Color := clWindowText;
      if odSelected in State then DrawFocusRect(Focus);
      TextOut(x + 20, Rect.Top + 2, item.Text);
      if item.Level = 1 then
        if item.Expanded then
          Draw(x, Rect.Top + 1, PictureOpen)
        else
          Draw(x, Rect.Top + 1, PictureClosed)
      else
        Draw(x, Rect.Top + 1, PictureLeaf);
    end;
  end;
end;

procedure TSysPropDlg.AddBtnClick(Sender: TObject);
var
  s: string;
  item: TOutlineNode;
begin
  s := '';
  if InputQuery(LoadStr(SAddAdvanced), LoadStr(SIdentValue), s) then
  begin
    AdvancedChanged := True;
    with Outline do
      if SelectedItem > 0 then
      begin
        item := Items[SelectedItem];
        if item.Level = 1 then AddChild(SelectedItem, s)
        else Insert(SelectedItem, s);
      end
      else Add(0, s);
  end;
end;

procedure TSysPropDlg.RemoveBtnClick(Sender: TObject);
begin
  with Outline do
    if ChildNodeSelected then
    begin
      Delete(SelectedItem);
      AdvancedChanged := True;
    end;
end;

procedure TSysPropDlg.ModifyBtnClick(Sender: TObject);
var
  s: string;
  item: TOutlineNode;
begin
  with Outline do
  begin
    if ChildNodeSelected then begin
      item := Items[SelectedItem];
      s := item.Text;
      if InputQuery(LoadStr(SModifyAdvanced), LoadStr(SIdentValue), s) then
      begin
        item.Text := s;
        AdvancedChanged := True;
      end;
    end;
  end;
end;

procedure TSysPropDlg.OutlineClick(Sender: TObject);
begin
  with Outline do
    RemoveBtn.Enabled := (SelectedItem > 0) and (Items[SelectedItem].Level > 1);
  ModifyBtn.Enabled := RemoveBtn.Enabled;
end;

procedure TSysPropDlg.FormDestroy(Sender: TObject);
begin
  Histories.Free;
  UserIni.Free;
end;

procedure TSysPropDlg.SaveBtnClick(Sender: TObject);
var
  i: Longint;
begin
  ShowHourglass;
  with ini do
    for i := 1 to Outline.ItemCount do
      with Outline.Items[i] do
        if Level = 1 then EraseSection(Text)
        else WriteString(Parent.Text, GetStrKey(Text), GetStrValue(Text));
  AdvancedChanged := False;
  { 3.1 }
  if cbApplyChanges.Checked then
    PostMessage(Application.Handle, WM_CALMIRA, CM_RELOADOPTIONS, 0);
end;

procedure TSysPropDlg.OutlineMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
  i: Longint;
begin
  if x < 22 then with Outline do
  begin
    i := GetItem(X, Y);
    if i > 0 then with Items[i] do
      if Level = 1 then Expanded := not Expanded;
  end;
end;

procedure TSysPropDlg.ClearHistBtnClick(Sender: TObject);
begin
  ini.EraseSection(Histories.Values[HistoryCombo.Text]);
end;

procedure TSysPropDlg.OutlineDblClick(Sender: TObject);
begin
  ModifyBtn.Click;
end;

procedure TSysPropDlg.TabPanelChange(Sender: TObject; NewTab: Integer;
  var AllowChange: Boolean);
var
  sections, strings: TStringList;
  i, j: Integer;
  node: Longint;
  s: string[127];
begin
  if (NewTab = 4) {Advanced} and not FilledOutline then
  begin
    ShowHourGlass;
    sections := TUniqueStrings.Create;
    { 3.1 eliminated [Advanced] section }
    ini.ReadSections(sections);
    strings := TStringList.Create;
    try
      with Outline do
      begin
        Canvas.Font.Assign(Font);
        ThumbTracking := TrackThumb;
        for i := 0 to sections.Count - 1 do Add(0, sections[i]);
        BeginUpdate;
        for i := 0 to sections.Count - 1 do
        begin
          s := sections[i];
          node := GetTextItem(s);
          strings.Clear;
          ini.ReadSectionValues(s, strings);
          for j := 0 to strings.Count - 1 do AddChild(node, strings[j]);
        end;
        EndUpdate;
        Click;
      end;
    finally
      sections.Free;
      strings.Free;
      FilledOutline := True;
    end;
  end
end;

{ 3.01 }
procedure TSysPropDlg.rbMultiProfilesClick(Sender: TObject);
begin
  cbNoAnonUser.Enabled := rbMultiProfiles.Checked;
end;

{ 2.2a }
procedure TSysPropDlg.AddUserBtnClick(Sender: TObject);
begin
  with TPasswordDlg.Create(Application) do
  try
    InitNewUser;
    ShowModal;
    if ModalResult = mrOK then
    begin
      if UserList.Items.IndexOf(Edit1.Text) = -1 then begin
        UserList.Items.Add(Edit1.Text);
        UserIni.WriteString('Users', Edit1.Text, EncryptPassword(Edit2.Text));
        rbMultiProfiles.Checked := True; { 3.0 }
      end;
    end;
  finally
    Free;
  end;
end;

{ 2.2a }
procedure TSysPropDlg.RemoveUserBtnClick(Sender: TObject);
var
  password: string;
begin
  with UserList do begin
    password := '';
    if (ItemIndex >= 0) and InputQuery('Remove user', 'Password:', password) then
    begin
      if DecryptPassword(UserIni.ReadString('Users', Items[ItemIndex], '')) = password then
      begin
        UserIni.DeleteKey('Users', Items[ItemIndex]); { 3.0 }
        Items.Delete(ItemIndex);
        if Items.Count = 0 then rbShareSettings.Checked := True; { 3.0 }
      end
      else MsgDialog('Invalid password', mtError, [mbOK], 0);
    end;
  end;
end;

{ 2.2a }
procedure TSysPropDlg.ChangePasswordBtnClick(Sender: TObject);
begin
  with UserList do if ItemIndex >= 0 then
    with TPasswordDlg.Create(Application) do
    try
      InitChangePassword(DecryptPassword(UserIni.ReadString('Users',
        Items[ItemIndex], '')));
      ShowModal;
      if ModalResult = mrOK then
      begin
        UserIni.WriteString('Users', Items[ItemIndex], EncryptPassword(Edit2.Text));
      end;
    finally
      Free;
    end;
end;

procedure TSysPropDlg.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if (Key = VK_TAB) and (ssCtrl in Shift) then
    TabPanel.SelectNext(not (ssShift in Shift));
end;

procedure TSysPropDlg.BrowserBtnClick(Sender: TObject);
begin
  with OpenDialog do if Execute then
    BrowserEdit.Text := LowerCase(Filename);
end;

procedure TSysPropDlg.SoundBtnClick(Sender: TObject);
begin
  with OpenSoundDialog do
    if Execute then SoundEdit.Text := LowerCase(FileName);
end;

procedure TSysPropDlg.PlayBtnClick(Sender: TObject);
begin
  PlaySound(SoundEdit.Text);
end;

procedure TSysPropDlg.StopBtnClick(Sender: TObject);
begin
  PlaySound('');
end;

end.

