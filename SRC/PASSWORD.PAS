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

unit Password;

interface

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  Forms, Dialogs, StdCtrls, Buttons, Picbtn;

type
  TPasswordDlg = class(TForm)
    Edit1: TEdit;
    Edit2: TEdit;
    Edit3: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    OKBtn: TPicBtn;
    CancelBtn: TPicBtn;
    procedure OKBtnClick(Sender: TObject);
  private
    { Private declarations }
    previous: string;
  public
    { Public declarations }
    procedure InitNewUser;
    procedure InitChangePassword(const OldPassword: string);
  end;

var
  PasswordDlg: TPasswordDlg;

function EncryptPassword(const s: string): string;
function DecryptPassword(const s: string): string;
function IsValidLogin(const s: string): Boolean;

implementation

{$R *.DFM}

uses MiscUtil, Strings, Locale;

function Rotate(const s: string): string;
var
  i: Integer;
begin
  Result[0] := s[0];
  for i := 1 to Length(s) do
  case s[i] of
    'A'..'M',
    'a'..'m': Result[i] := Chr(Ord(s[i]) + 13);
    'N'..'Z',
    'n'..'z': Result[i] := Chr(Ord(s[i]) - 13);
  else
    Result[i] := s[i];
  end;
end;

function EncryptPassword(const s: string): string;
var
  i: Integer;
  t: string;
begin
  Result := '';
  t := Rotate(s);
  for i := 1 to Length(t) do AppendStr(Result, IntToHex(Ord(t[i]), 2));
end;

function DecryptPassword(const s: string): string;
var
  i: Integer;
begin
  Result := '';
  i := 1;
  while i < Length(s) do
  begin
    AppendStr(Result, Chr(StrToInt('$' + Copy(s, i, 2))));
    Inc(i, 2);
  end;
  Result := Rotate(Result);
end;

function IsValidLogin(const s: string): Boolean;
var
  i: Integer;
begin
  Result := True;
  if (Length(s) = 0) or (Length(s) > 8) then Result := False;
  for i := 1 to Length(s) do
    if not (s[i] in AlphaDigits) then Result := False;
end;

procedure TPasswordDlg.InitNewUser;
begin
  previous := '';
  Caption := LoadStr(SCreateNewUser);
  Label1.Caption := LoadStr(SUserName);
  Label2.Caption := LoadStr(SEnterPassword);
  Label3.Caption := LoadStr(SConfirmPassword);
  Edit1.PasswordChar := #0;
end;

procedure TPasswordDlg.InitChangePassword(const OldPassword: string);
begin
  previous := OldPassword;
  Caption := LoadStr(SChangePassword);
  Label1.Caption := LoadStr(SEnterOldPassword);
  Label2.Caption := LoadStr(SEnterNewPassword);
  Label3.Caption := LoadStr(SConfirmNewPassword);
  Edit1.PasswordChar := '*';
end;

procedure TPasswordDlg.OKBtnClick(Sender: TObject);
begin
  if not IsValidLogin(Edit1.Text) and (Caption = LoadStr(SCreateNewUser)) then
    MsgDialogRes(SInvalidUserName, mtError, [mbOK], 0)
  else if ((previous = '') or (Edit1.Text = previous)) and (Edit2.Text = Edit3.Text) then
    ModalResult := mrOK
  else if (previous > '') and (Edit1.Text <> previous) then
    MsgDialogRes(SInvalidOldPassword, mtError, [mbOK], 0)
  else
    MsgDialogRes(SPasswordMismatch, mtError, [mbOK], 0);
end;

end.

