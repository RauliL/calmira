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

unit About;

interface

uses WinTypes, WinProcs, Classes, Graphics, Forms, Controls, StdCtrls,
  Buttons, ExtCtrls, Picbtn;

type
  TAboutBox = class(TForm)
    AppLogo: TImage;
    VersionLabel: TLabel;
    Copy1Label: TLabel;
    Copy2Label: TLabel;
    HomepageLabel: TLabel;
    Bevel1: TBevel;
    LicenceLabel: TLabel;
    LicenseBtn: TPicBtn;
    OKButton: TPicBtn;
    Bevel2: TBevel;
    Label3: TLabel;
    Label4: TLabel;
    MemLabel: TLabel;
    ResLabel: TLabel;
    AppTitle: TImage;
    procedure LicenseBtnClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure HomepageLabelClick(Sender: TObject);
    procedure AppLogoClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

{
var
  AboutBox: TAboutBox;
}

implementation

{$R *.DFM}

uses Strings, SysUtils, Files, MiscUtil, Settings, Fileman,
  Dialogs, Locale, Desk;

procedure TAboutBox.LicenseBtnClick(Sender: TObject);
var
  license : TFilename;
begin
  license := ApplicationPath + 'license.txt';
  if not FileExists(license) then
    MsgDialogRes(SCannotFindLicense, mtError, [mbOK], 0)
  else
    if FileExecute('open', 'notepad.exe', license, '',
      SW_SHOWMAXIMIZED) <= 32 then
        MsgDialogRes(SCannotRunNotepad, mtError, [mbOK], 0);
end;

procedure TAboutBox.FormCreate(Sender: TObject);
begin
  MemLabel.Caption := FormatByte(GetFreeSpace(0), 2, 2) + ' free';
  ResLabel.Caption := Format('System %d%%  GDI %d%%  User %d%%',
    [GetFreeSystemResources(GFSR_SYSTEMRESOURCES),
     GetFreeSystemResources(GFSR_GDIRESOURCES),
     GetFreeSystemResources(GFSR_USERRESOURCES)]);
  AppLogo.Picture.Bitmap.Handle := LoadBitmap(HInstance, 'LOGO');
  AppTitle.Picture.Bitmap.Handle := LoadBitmap(HInstance, 'TITLE');
  if FirstRun then
  begin
    Caption := LoadStr(SWelcome);
    FirstRun := False;
  end;
end;

procedure TAboutBox.HomepageLabelClick(Sender: TObject);
begin
  OKButton.Click;
  { 2.2 added http:// }
  OpenURL('http://www.calmira.org');
end;

procedure TAboutBox.AppLogoClick(Sender: TObject);
begin
  Desktop.Revert;
end;

end.

