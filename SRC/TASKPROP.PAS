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

unit Taskprop;

interface

uses WinTypes, WinProcs, Classes, Graphics, Forms, Controls, Buttons,
  StdCtrls, Chklist, TabNotBk, ExtCtrls, Spin, StylSped, TabPanel, Picbtn,
  SortHdr, Slider;

type
  TTaskPropDlg = class(TForm)
    TabPanel: TTabPanel;
    Notebook: TNotebook;
    CheckList: TCheckList;
    Label1: TLabel;
    Header1: THeader;
    AppTrayList: TListBox;
    AddAppBtn: TStyleSpeed;
    RemoveBtn: TStyleSpeed;
    Label3: TLabel;
    Header2: THeader;
    ExcludeList: TListBox;
    AddExclusionBtn: TStyleSpeed;
    RemoveExcludeBtn: TStyleSpeed;
    OKBtn: TPicBtn;
    CancelBtn: TPicBtn;
    HelpBtn: TPicBtn;
    Bevel4: TBevel;
    Label4: TLabel;
    Label9: TLabel;
    Label10: TLabel;
    ModifyBtn: TStyleSpeed;
    ModifyExclusionBtn: TStyleSpeed;
    Label11: TLabel;
    PixelsEdit: TSpinEdit;
    SlowDownEdit: TSpinEdit;
    Bevel1: TBevel;
    Bevel2: TBevel;
    procedure FormCreate(Sender: TObject);
    procedure OKBtnClick(Sender: TObject);
    procedure AppTrayListDrawItem(Control: TWinControl; Index: Integer;
      Rect: TRect; State: TOwnerDrawState);
    procedure AddAppBtnClick(Sender: TObject);
    procedure RemoveBtnClick(Sender: TObject);
    procedure Header1Sized(Sender: TObject; ASection, AWidth: Integer);
    procedure ExcludeListDrawItem(Control: TWinControl; Index: Integer;
      Rect: TRect; State: TOwnerDrawState);
    procedure Header2Sized(Sender: TObject; ASection, AWidth: Integer);
    procedure AddExclusionBtnClick(Sender: TObject);
    procedure RemoveExcludeBtnClick(Sender: TObject);
    procedure AppTrayListKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure ExcludeListKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure ModifyBtnClick(Sender: TObject);
    procedure ModifyExclusionBtnClick(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

{
var
  TaskPropDlg: TTaskPropDlg;
}

implementation

{$R *.DFM}

uses Settings, Strings, Dialogs, SysUtils, Locale, MiscUtil;

procedure TTaskPropDlg.FormCreate(Sender: TObject);
begin
  CheckList.Color := Colors[ccChecklist];
  Notebook.PageIndex := 0;
  CheckList.SetData([DisableTaskbar, StayVisible, ShrinkMax, Clock24, PopupRes, PopupDate,
    Animate, FullAnimate { 3.0 }, ButtonHints, ArrangeMin, HideMinApps, IconWindowTask,
    ExplorerTask, FullFolderPath, DocNameFirst, DocNameLower, ShowRealSysMenu]);
  CheckList.Hints.Assign(CheckList.Items); { 3.1 }
  (*
  slUpSpeed.Value := UpSpeed; { 3.0 }
  slDownSpeed.Value := DownSpeed; { 3.0 }
  *)
  PixelsEdit.Value := AnimatePixels; { 3.11 }
  SlowDownEdit.Value := AnimateSlowDown; { 3.11 }
  ini.ReadSectionValues('Applet Tray', AppTrayList.Items);
  ini.ReadStrings('Exclude', ExcludeList.Items);
  EnableControlList([OKBtn, Notebook], CanEditSettings); { 2.2 }
end;

procedure TTaskPropDlg.OKBtnClick(Sender: TObject);
begin
  CheckList.GetData([@DisableTaskbar, @StayVisible, @ShrinkMax, @Clock24, @PopupRes, @PopupDate,
     @Animate, @FullAnimate { 3.0 }, @ButtonHints, @ArrangeMin, @HideMinApps, @IconWindowTask,
     @ExplorerTask, @FullFolderPath, @DocNameFirst, @DocNameLower, @ShowRealSysMenu]);
  (*
  UpSpeed := slUpSpeed.Value; { 3.0 }
  DownSpeed := slDownSpeed.Value; { 3.0 }
  *)
  AnimatePixels := PixelsEdit.Value; { 3.11 }
  AnimateSlowDown := SlowDownEdit.Value; { 3.11 }
  SaveTaskProp;
  ini.EraseSection('Applet Tray');
  ini.EraseSection('Exclude');
  ini.WriteSectionValues('Applet Tray', AppTrayList.Items);
  ini.WriteStrings('Exclude', ExcludeList.Items);
  AnnounceSettingsChanged([scTaskbar]);
end;

procedure TTaskPropDlg.AppTrayListDrawItem(Control: TWinControl;
  Index: Integer; Rect: TRect; State: TOwnerDrawState);
begin
  with AppTrayList do
  begin
    Canvas.FillRect(Rect);
    Canvas.TextOut(Rect.Left + 2, Rect.Top + 1, GetStrKey(Items[Index]));
    Canvas.TextOut(Header1.SectionWidth[0], Rect.Top + 1, GetStrValue(Items[Index]));
  end;
end;

procedure TTaskPropDlg.AddAppBtnClick(Sender: TObject);
var
  s: string;
begin
  s := '';
  if InputQuery(LoadStr(SAddApplet), LoadStr(SAppletFormat), s) and
    (s > '') then AppTrayList.Items.Add(s);
end;

procedure TTaskPropDlg.ModifyBtnClick(Sender: TObject);
var
  s : string;
begin
  with AppTrayList do
    if ItemIndex <> -1 then
    begin
      s := Items[ItemIndex];
      if InputQuery(LoadStr(SModifyApplet), LoadStr(SAppletFormat), s) and
        (s > '') then Items[ItemIndex] := s;
    end;
end;

procedure TTaskPropDlg.RemoveBtnClick(Sender: TObject);
begin
  with AppTrayList do
    if ItemIndex <> -1 then Items.Delete(ItemIndex);
end;

procedure TTaskPropDlg.Header1Sized(Sender: TObject; ASection,
  AWidth: Integer);
begin
  AppTrayList.Invalidate;
end;

procedure TTaskPropDlg.ExcludeListDrawItem(Control: TWinControl;
  Index: Integer; Rect: TRect; State: TOwnerDrawState);
var
  s: string[79];
begin
  with ExcludeList do
  begin
    Canvas.FillRect(Rect);
    s := Items[Index];
    Canvas.TextOut(Rect.Left + 2, Rect.Top + 1, GetWord(s, ' '));
    Canvas.TextOut(Header2.SectionWidth[0], Rect.Top + 1, s);
  end;
end;

procedure TTaskPropDlg.Header2Sized(Sender: TObject; ASection,
  AWidth: Integer);
begin
  ExcludeList.Invalidate;
end;

procedure TTaskPropDlg.AddExclusionBtnClick(Sender: TObject);
var
  s: string;
begin
  s := '';
  if InputQuery(LoadStr(SAddExclusion), LoadStr(SModuleClass), s) and
    (s > '') then ExcludeList.Items.Add(s);
end;

procedure TTaskPropDlg.ModifyExclusionBtnClick(Sender: TObject);
var
  s : string;
begin
  with ExcludeList do
    if ItemIndex <> -1 then
    begin
      s := Items[ItemIndex];
      if InputQuery(LoadStr(SModifyExclusion), LoadStr(SModuleClass), s) and
        (s > '') then Items[ItemIndex] := s;
    end;
end;

procedure TTaskPropDlg.RemoveExcludeBtnClick(Sender: TObject);
begin
  with ExcludeList do
    if ItemIndex <> -1 then Items.Delete(ItemIndex);
end;

procedure TTaskPropDlg.AppTrayListKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_INSERT then AddAppBtnClick(Sender);
  if Key = VK_DELETE then RemoveBtnClick(Sender);
end;

procedure TTaskPropDlg.ExcludeListKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_INSERT then AddExclusionBtnClick(Sender);
  if Key = VK_DELETE then RemoveExcludeBtnClick(Sender);
end;

procedure TTaskPropDlg.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if (Key = VK_TAB) and (ssCtrl in Shift) then
    TabPanel.SelectNext(not (ssShift in Shift));
end;

end.

