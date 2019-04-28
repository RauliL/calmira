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

unit GotoFld;

interface

uses WinTypes, Messages, Classes, Graphics, Controls, Forms, Dialogs, StdCtrls,
  Buttons, PicBtn, ExtCtrls, SysMenu;

type
  TGotoDlg = class(TForm)
    Image: TImage;
    Label1: TLabel;
    OKBtn: TPicBtn;
    CancelBtn: TPicBtn;
    Combo: TComboBox;
    Label2: TLabel;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

function GotoFolder(var folder: string): Boolean;

var
  GotoDlg: TGotoDlg;

implementation

uses SysUtils, Environs, Files, MiscUtil, Resource, Locale, Settings;

{$R *.DFM}

var
  Changed: Boolean;

function GotoFolder(var folder: string): Boolean;
var
  s: string[79];
begin
  Result := False;
  ShowHourglass;
  if GotoDlg = nil then GotoDlg := TGotoDlg.Create(Application);
  with GotoDlg do
  begin
    AssignHistoryText(Combo, folder);
    repeat
      ShowModal;
      if ModalResult = mrOK then
      begin
        s := LowerCase(ExpandFoldername(EnvironSubst(Combo.Text), Winpath[1]));
        if HDirectoryExists(s) then
        begin
          Changed := AddHistory(Combo) or Changed;
          Result := True;
          folder := s;
        end
        else
          ErrorMsgResFmt(SCannotOpenFolder, [Combo.Text]);
      end;
    until (ModalResult = mrCancel) or Result;
    Close;
  end;
end;

procedure TGotoDlg.FormCreate(Sender: TObject);
begin
  Image.Picture.Icon.Assign(Icons.Get('GotoDialog'));
  ini.ReadStrings('GotoFolder', Combo.Items);
end;

procedure TGotoDlg.FormDestroy(Sender: TObject);
begin
  if Changed then ini.WriteNewStrings('GotoFolder', Combo.Items);
  GotoDlg := nil;
end;

procedure TGotoDlg.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := caFree;
end;

end.

