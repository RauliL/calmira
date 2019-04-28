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

unit ProgConv;

{ Program Group Converter.  This unit uses DDE to retrieve information
  about groups from Program Manager, and puts them into a listbox.
  When the user presses OK, each group is processed and the
  OnConvertProg event is triggered for each item that is converted.

  Some Windows setups don't seem to respond to this properly.  An
  alternative is reading in the group files, but the file format is
  pretty hideous. }

interface

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  Forms, Dialogs, StdCtrls, Buttons, ExtCtrls, DdeMan, Picbtn;

type
  TConvertProgEvent = procedure (Sender: TObject;
    const group, caption: TFilename; const data: string) of object;

  TConvertDlg = class(TForm)
    GroupList: TListBox;
    SortItems: TCheckBox;
    OKBtn: TPicBtn;
    CancelBtn: TPicBtn;
    Label1: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure OKBtnClick(Sender: TObject);
    procedure GroupListDblClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    OnConvertProg: TConvertProgEvent;
  end;

var
  ConvertDlg: TConvertDlg;

implementation

{$R *.DFM}

uses Strings, IniFiles, Start, StrtProp, MiscUtil, Settings, Desk, Locale;

{ For each group in the list, RequestData is called to retrieve the
  entire group contents as a long null terminated string.  Rather than
  parsing this, it is quicker to assign it to a string list, which
  separates it into lines, and even sorts them for you.  The first line
  is always the group name, so it is discarded. }

procedure TConvertDlg.FormCreate(Sender: TObject);
var
  p: PChar;
begin
  DdeMgr.AppName := 'CALMIRA';
  if StartPropDlg.Progman.OpenLink then
    try
      p := StartPropDlg.Progman.RequestData('Groups');
      GroupList.Items.SetText(p);
    finally
      StrDispose(p);
    end
  else
    ErrorMsgRes(SCannotFindProgman);
end;

procedure TConvertDlg.FormDestroy(Sender: TObject);
begin
  if IsShell and ShellDDE then
  begin
    StartPropDlg.Progman.ExecuteMacro('[ExitProgman(0)]', False);
    DdeMgr.AppName := 'PROGMAN';
  end;
end;

procedure TConvertDlg.OKBtnClick(Sender: TObject);
var
  progs: TStringList;
  p: PChar;
  i, j, iconindex, mode: Integer;
  caption, command, directory, iconfile: TFilename;
begin
  progs := TStringList.Create;
  try
    Desktop.SetCursor(crHourGlass);
    for i := 0 to GroupList.Items.Count - 1 do
    if GroupList.Selected[i] then
    begin
      progs.Clear;
      try
        p := StartPropDlg.Progman.RequestData(GroupList.Items[i]);
        with progs do begin
          Sorted := False;
          SetText(p);
          Delete(0); { Delete name of group }
          Sorted := SortItems.Checked;
        end;
      finally
        StrDispose(p);
      end;
      for j := 0 to progs.Count - 1 do
      begin
        caption := '';
        command := '';
        directory := '';
        iconfile := '';
        iconindex := 0;
        mode := 0;
        { Inspecting the data returned by Program Manager shows that
          the fields are separated by commas and the first two are
          enclosed in double quotes.  Some of the icon positions
          are ignored }
        Unformat(progs[j], '"%s","%s",%s,%s,%D,%D,%d,%D,%d',
          [@caption, 79, @command, 79, @directory, 79,
           @iconfile, 79, @iconindex, @mode]);
        if Assigned(OnConvertProg) then
          OnConvertProg(Self, Trim(GroupList.Items[i]), Trim(caption),
            PackStartInfo(command, directory, iconfile, mode, iconindex));
      end;
    end;
  finally
    progs.Free;
    Desktop.ReleaseCursor;
  end;
end;

procedure TConvertDlg.GroupListDblClick(Sender: TObject);
begin
  OKBtn.Click;
end;

end.

