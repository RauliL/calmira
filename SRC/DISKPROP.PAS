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

unit Diskprop;

interface

uses
  Classes, SysUtils, Graphics, Controls, Forms, StdCtrls, Buttons, ExtCtrls,
  TabNotBk, LabelSel, TabPanel, Picbtn, Drives, Win95pie, SortHdr;

type
  TDiskDialog = class(TForm)
    LabelSel: TLabelSelect;
    TabPanel: TTabPanel;
    Notebook: TNotebook;
    DriveImage: TImage;
    DriveLetter: TLabel;
    Label1: TLabel;
    Label11: TLabel;
    DriveTypeLabel: TLabel;
    Label12: TLabel;
    DriveSize: TLabel;
    DriveFree: TLabel;
    Label13: TLabel;
    Label14: TLabel;
    DriveUsed: TLabel;
    OKBtn: TPicBtn;
    VolLabel: TEdit;
    Bevel1: TBevel;
    CancelBtn: TPicBtn;
    HelpBtn: TPicBtn;
    Bevel2: TBevel;
    PieChart: TWin95PieChart;
    Panel1: TPanel;
    Panel2: TPanel;
    procedure FormShow(Sender: TObject);
    procedure DriveImageClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure DriveTypeLabelMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    { 2.2 }
    procedure VolLabelKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure VolLabelKeyPress(Sender: TObject; var Key: Char);
    procedure VolLabelKeyUp(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    { 3.1 }
    procedure OKBtnClick(Sender: TObject);
  private
    { Private declarations }
    VolChanged: Boolean;
  public
    { Public declarations }
    DriveType: TDriveType; { 2.2 }
    Drive: Char;           { 2.2 }
    procedure DetectLabel; { 2.2 }
    procedure SetLabel;    { 3.1 }
  end;

procedure DiskPropExecute(DriveChar: Char);

implementation

{$R *.DFM}

uses Strings, Resource, Settings, Files, Environs, WinTypes, FileMan, MiscUtil;

{
var
  DiskDialog: TDiskDialog;
}

procedure TDiskDialog.FormShow(Sender: TObject);
var
  dnum, percent: Integer;
  size, free: Longint;
begin
  { 2.2 }
  DriveLetter.Caption := 'Drive ' + Drive + ':';
  dnum := DriveNumber(Drive);
  DriveType := GuessDriveType(Drive);
  DriveTypeLabel.Caption := DriveDesc[DriveType];
  DriveImage.Picture.Icon := icons.Drive[DriveType];
  DetectLabel;
  if DriveType = dtCDROM then
    size := CDDiskSize(dnum) { 4.0 }
  else
    size := DiskSize(dnum);
  if size > 0 then
  begin
    free := DiskFree(dnum);
    DriveSize.Caption := FormatByte(size, 2, 2);
    if size > 1024 then DriveSize.Hint := FormatByteLong(size);
    DriveFree.Caption := FormatByte(free, 2, 2);
    if free > 1024 then DriveFree.Hint := FormatByteLong(free);
    DriveUsed.Caption := FormatByte(size - free, 2, 2);
    if (size - free) > 1024 then DriveUsed.Hint := FormatByteLong(size - free);
    if size > 1024 then
    begin
      size := size div 1024;
      free := free div 1024;
    end;
    PieChart.Maximum := size;
    PieChart.Value := size - free;
    DriveUsed.Caption := DriveUsed.Caption +
      '  (' + Format('%d%%', [PieChart.GetPercent]) + ')';
  end;
  { 3.0 / 3.1 }
  if not (dfWriteable in GetDriveFlags(Drive)) or (DriveType = dtNetwork) then
  begin
    VolLabel.ParentColor := True;
    VolLabel.ReadOnly := True;
  end;
end;

procedure TDiskDialog.DriveImageClick(Sender: TObject);
begin
  { 2.12 }
  Environment.Values['CURRENTDRIVE'] := DriveLetter.Caption[1];
  DefaultExecCommand(DiskProg, '', SW_SHOWNORMAL);
end;

procedure TDiskDialog.FormCreate(Sender: TObject);
begin
  Notebook.PageIndex := 0;
  VolChanged := False;
end;

procedure TDiskDialog.DriveTypeLabelMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  if Button = mbLeft then LabelSel.Overlay(Sender as TLabel);
end;

procedure TDiskDialog.VolLabelKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  VolChanged := True;
  { 2.2 }
  if (Key = VK_RETURN) then Key := 0;
end;

procedure TDiskDialog.VolLabelKeyPress(Sender: TObject; var Key: Char);
begin
  { 2.2 }
  if Key = #13 then Key := #0;
end;

procedure TDiskDialog.VolLabelKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  { 2.2 }
  if Key = VK_RETURN then Key := 0;
end;

procedure TDiskDialog.OKBtnClick(Sender: TObject);
begin
  if VolChanged then SetLabel;
end;

procedure TDiskDialog.DetectLabel;
begin
  { 2.2 }
  ShowHourglass;
  VolLabel.Text := GetVolumeLabel(drive);
  ShowArrow;
end;

procedure TDiskDialog.SetLabel;
begin
  { 2.2 }
  if (dfWriteable in GetDriveFlags(Drive)) and
    not (dfNetwork in GetDriveFlags(Drive)) then
    begin
      ShowHourglass;
      SetVolumeLabel(VolLabel.Text, Drive);
      VolChanged := False;
    end;
end;

procedure DiskPropExecute(DriveChar: Char);
begin
  ShowHourglass;
  with TDiskDialog.Create(Application) do
  try
    Drive := UpCase(DriveChar);
    ShowModal;
  finally
    Free;
  end;
end;

end.

