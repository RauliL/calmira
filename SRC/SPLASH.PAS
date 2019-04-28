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

unit Splash;

{ This is actually the program's main form.  The Computer window can't
  be used because we need to see it minimized while the rest of the
  forms are on screen.

  Delphi insists on displaying the main form, so to allow the user
  to avoid the splash screen, the project source calls TotalHide
  to make sure that it cannot be seen }

interface

uses
  Classes, Controls, Forms, ExtCtrls, StdCtrls;

type
  TSplashForm = class(TForm)
    Panel: TPanel;
    AppLogo: TImage;
    VersionLabel: TLabel;
    Copy1Label: TLabel;
    Copy2Label: TLabel;
    AppTitle: TImage;
    procedure FormCreate(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
  private
    { Private declarations }
  public
    { Public declarations }
    procedure TotalHide;
  end;

var
  SplashForm: TSplashForm;

implementation

{$R *.DFM}

uses CompSys, Desk, ShutDown, Settings, MiscUtil, WinTypes, WinProcs;

procedure TSplashForm.FormCreate(Sender: TObject);
begin
  AppLogo.Picture.Bitmap.Handle := LoadBitmap(HInstance, 'LOGO');
  AppTitle.Picture.Bitmap.Handle := LoadBitmap(HInstance, 'TITLE');
end;

procedure TSplashForm.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
begin
  CanClose := InSendMessage;
end;

procedure TSplashForm.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  { 3.1 Show Quit dialog when ALT-F4 is pressed while splashform has focus }
  if (Key = VK_F4) and (ssAlt in Shift) then
  begin
    Key := 0;
    ShowModalDialog(TQuitDlg);
  end;
end;

procedure TSplashForm.TotalHide;
begin
  { Placing the form off the desktop is usually a good bet, but
    some utilities will drag it back on screen again so setting
    the height to zero is needed too }
  Position := poDesigned;
  Left := - Width;
  Height := 0;
  Panel.Free;
end;

end.

