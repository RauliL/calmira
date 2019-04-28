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

unit Runprog;

interface

uses Classes, Forms, Controls, Buttons, StdCtrls, Dialogs, Settings,
  ExtCtrls, SysUtils, Picbtn, SysMenu;

type
  TRunDlg = class(TForm)
    Label1: TLabel;
    Combo: TComboBox;
    OpenDialog: TOpenDialog;
    Image: TImage;
    BrowseBtn: TPicBtn;
    OKBtn: TPicBtn;
    CancelBtn: TPicBtn;
    Label2: TLabel;
    DosCommand: TCheckBox;
    DosSession: TCheckBox;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure OKBtnClick(Sender: TObject);
    procedure CancelBtnClick(Sender: TObject);
    procedure BrowseBtnClick(Sender: TObject);
    procedure DosSessionClick(Sender: TObject);
  private
    { Private declarations }
    Changed: Boolean;
    DefaultDir: TFilename;
  public
    { Public declarations }
  end;

procedure RunExecute(const command: string; const Dir: TFilename);

var
  RunDlg: TRunDlg; { 2.2 }

implementation

{$R *.DFM}

uses Files, WinProcs, WinTypes, MiscUtil, Resource, Environs,
  Strings, Fileman, Desk, Locale, Graphics;

procedure RunExecute(const command: string; const Dir: TFilename);
begin
  ShowHourglass;
  if RunDlg = nil then RunDlg := TRunDlg.Create(Application);
  with RunDlg do
  begin
    AssignHistoryText(Combo, command);
    if Dir > '' then DefaultDir := Dir
    else DefaultDir := Environment.Values['WINDIR'];
    Show;
  end;
end;

procedure TRunDlg.FormCreate(Sender: TObject);
begin
  Image.Picture.Icon.Assign(Icons.Get('RunDialog'));
  ini.ReadStrings('RunProgram', Combo.Items);
end;

procedure TRunDlg.FormDestroy(Sender: TObject);
begin
  if Changed then ini.WriteNewStrings('RunProgram', Combo.Items);
  RunDlg := nil;
end;

procedure TRunDlg.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := caFree;
end;

procedure TRunDlg.OKBtnClick(Sender: TObject);
var
  filename, newdir: TFilename;
  params: string;
begin
  Changed := AddHistory(Combo) or Changed;
  with Combo do
    if Text > '' then
    begin
      newdir := '';
      if DosSession.Checked then
      begin
        filename := ApplicationPath + 'dosrun.exe';
        params := Text;
        if MsgDialogRes(SNotifyEndWindows, mtInformation,
          [mbOK, mbCancel], 0) = mrOK then
          begin
            if Changed then ini.WriteNewStrings('RunProgram', Combo.Items);
            ExitWindowsExec(StrPChar(filename), StrPChar(params));
          end
        else Exit
      end
      else if DosCommand.Checked then
      begin
        filename := Environment.Values['COMSPEC'];
        params := '/c ' + Text;
      end
      else
      begin
        filename := FirstWord(EnvironSubst(Text));
        newdir := ExtractFileDir(filename);
        params := '';
        if Length(filename) < Length(Text) then
          params := Copy(Text, Length(filename) + 2, 255);
      end;
      if newdir = '' then newdir := DefaultDir;
      if (Length(filename) = 2) and (filename[1] in Alphas) and (filename[2] = ':') then
        AppendStr(filename, '\');
      if HDirectoryExists(filename) then
      begin
        Desktop.OpenFolder(filename);
        if RunAutoClose then Close;
      end
      else if (DefaultExec(filename, params, newdir, SW_SHOWNORMAL) > 32) and
        RunAutoClose then Close;
    end;
end;

procedure TRunDlg.CancelBtnClick(Sender: TObject);
begin
  Close;
end;

procedure TRunDlg.BrowseBtnClick(Sender: TObject);
begin
  if OpenDialog.Execute then
    Combo.Text := Lowercase(OpenDialog.Filename);
end;

procedure TRunDlg.DosSessionClick(Sender: TObject);
begin
  DosCommand.Enabled := not DosSession.Checked;
end;

end.

