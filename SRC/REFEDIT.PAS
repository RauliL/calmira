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

unit Refedit;

interface

uses Classes, Forms, Controls, Buttons, StdCtrls, ExtCtrls, Dialogs,
  StylSped, Icondlg, SysUtils, TabNotBk, Referenc, TabPanel, Picbtn;

type
  TRefEditDlg = class(TForm)
    IconDialog: TIconDialog;
    OpenDialog: TOpenDialog;
    TabPanel: TTabPanel;
    Notebook: TNotebook;
    CapEdit: TEdit;
    Label1: TLabel;
    TargetLabel: TLabel;
    TargetEdit: TEdit;
    Label2: TLabel;
    IconEdit: TEdit;
    BrowseIcon: TStyleSpeed;
    OKBtn: TPicBtn;
    CancelBtn: TPicBtn;
    HelpBtn: TPicBtn;
    BrowseTarget: TStyleSpeed;
    FilePanel: TPanel;
    Label3: TLabel;
    FolderEdit: TEdit;
    BrowseFolder: TStyleSpeed;
    Label4: TLabel;
    ShowCombo: TComboBox;
    DocFolder: TCheckBox;
    Bevel1: TBevel;
    Bevel2: TBevel;
    CaptionLabel: TLabel;
    TargetIcon: TImage;
    TargetBevel: TBevel;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure BrowseTargetClick(Sender: TObject);
    procedure BrowseFolderClick(Sender: TObject);
    procedure BrowseIconClick(Sender: TObject);
    procedure TargetLabelMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure TargetLabelMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    { 3.1 }
    procedure CapEditExit(Sender: TObject);
    procedure TargetEditExit(Sender: TObject);
  private
    { Private declarations }
    SaveHistory: Boolean;
    {FReference: TReference;}
    FRefKind: TReferenceKind;
    procedure AdjustTargetBevel;
    procedure SetRefKind(Value: TReferenceKind);
    procedure AssignTargetIcon; { 3.1 }
  public
    { Public declarations }
    {property Reference: TReference read FReference write FReference;}
    property RefKind: TReferenceKind read FRefKind write SetRefKind;
  end;

var
  RefEditDlg: TRefEditDlg;

function ExtractIconFile(const s: string): TFilename;
function ExtractIconIndex(const s: string): Integer;

implementation

{$R *.DFM}

uses Graphics, ShellAPI, Strings, Settings, WinProcs, WinTypes,
  Resource, Tree, MiscUtil, Locale, Environs;

function ExtractIconFile(const s: string): TFilename;
begin
  Result := '';
  Unformat(s, '%s(', [@Result, 79]);
end;

function ExtractIconIndex(const s: string): Integer;
begin
  Result := 0;
  Unformat(s, '%S(%d)', [@Result]);
end;

procedure TRefEditDlg.FormCreate(Sender: TObject);
begin
  Notebook.PageIndex := 0;
  ini.ReadStrings('IconSources', IconDialog.HistoryList);
  { 3.1 }
  BrowseTarget.Glyph.Handle := LoadBitmap(HInstance, 'BBBROWSE');
  BrowseIcon.Glyph.Handle := LoadBitmap(HInstance, 'BBBROWSE');
  BrowseFolder.Glyph.Handle := LoadBitmap(HInstance, 'BBBROWSE');
end;

procedure TRefEditDlg.FormDestroy(Sender: TObject);
begin
  if SaveHistory then
    ini.WriteNewStrings('IconSources', IconDialog.HistoryList);
end;

procedure TRefEditDlg.FormShow(Sender: TObject);
begin
  AdjustTargetBevel;
  ActiveControl := CapEdit;
end;

procedure TRefEditDlg.BrowseTargetClick(Sender: TObject);
begin
  case RefKind of
    rkDrive,
    rkFolder: TargetEdit.Text := SelectFolder(TargetEdit.Text);
    rkFile  : with OpenDialog do if Execute then
                TargetEdit.Text := LowerCase(Filename);
  end;
  AssignTargetIcon; { 3.1 }
  AdjustTargetBevel;
end;

procedure TRefEditDlg.BrowseFolderClick(Sender: TObject);
begin
  FolderEdit.Text := SelectFolder(FolderEdit.Text);
end;

procedure TRefEditDlg.BrowseIconClick(Sender: TObject);
begin
  with IconDialog do
  begin
    if IconEdit.Text > '' then Filename := ExtractIconFile(IconEdit.Text)
    else Filename := FirstWord(TargetEdit.Text);
    Index := ExtractIconIndex(IconEdit.Text);
    if Execute then
    begin
      IconEdit.Text := Format('%s(%d)', [Filename, Index]);
      SaveHistory := True;
      AssignTargetIcon; { 3.1 }
    end;
  end;
end;

procedure TRefEditDlg.TargetLabelMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  RefKind := TReferenceKind((Ord(RefKind) + 1) mod
    (Ord(High(TReferenceKind)) + 1));
  AssignTargetIcon;
  TargetBevel.Style := bsLowered;
end;

procedure TRefEditDlg.TargetLabelMouseUp(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  TargetBevel.Style := bsRaised;
end;

procedure TRefEditDlg.CapEditExit(Sender: TObject); { 3.1 }
begin
  CaptionLabel.Caption := CapEdit.Text;
end;

procedure TRefEditDlg.TargetEditExit(Sender: TObject); { 3.1 }
begin
  AssignTargetIcon;
end;

procedure TRefEditDlg.SetRefKind(Value: TReferenceKind);
const
  Captions: array[TReferenceKind] of Word =
    (SDriveRefPrompt, SFolderRefPrompt, SFileRefPrompt, SInternetRefPrompt);
  TextColors: array[Boolean] of TColor = (clGray, clBlack);
begin
  FRefKind := Value;
  TargetLabel.Caption := LoadStr(Captions[FRefKind]);
  FilePanel.Enabled := FRefKind = rkFile;
  FilePanel.Font.Color := TextColors[FRefKind = rkFile];
end;

procedure TRefEditDlg.AdjustTargetBevel; { 3.12 }
begin
  with TargetLabel do
    TargetBevel.SetBounds(Left - 2, Top - 2, 46, Height + 4);
end;

procedure TRefEditDlg.AssignTargetIcon; { 3.1 }
var
  LastKind: TReferenceKind;
begin
  { Use a reference object to do the icon searching }
  LastKind := FileRef.Kind;
  FileRef.Kind := RefKind;
  FileRef.Target := FirstWord(Lowercase(TargetEdit.Text));
  FileRef.IconFile := ExtractIconFile(IconEdit.Text);
  FileRef.IconIndex := ExtractIconIndex(IconEdit.Text);
  FileRef.AssignIcon(TargetIcon.Picture.Icon);
  FileRef.Kind := LastKind;
end;

end.

