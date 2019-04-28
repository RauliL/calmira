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

unit Debug;

interface

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  Forms, Dialogs, StdCtrls, Menus, CalForm;

type
  TConsole = class(TForm)
    Listbox: TListBox;
    procedure ListboxKeyPress(Sender: TObject; var Key: Char);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
  private
    { Private declarations }
    TimeMark: Longint;
  public
    { Public declarations }
    function StartTimer: Longint;
    function StopTimer: Longint;
    procedure Print(const s: string);
    procedure PrintStrings(s: TStrings);
  end;

var
  Console: TConsole;

implementation

{$R *.DFM}

uses MiscUtil;

procedure TConsole.ListboxKeyPress(Sender: TObject; var Key: Char);
begin
  if UpCase(Key) = 'C' then Listbox.Items.Clear;
  if UpCase(Key) = 'S' then Listbox.Items.SaveToFile(ChangeFileExt(ParamStr(0), '.DBG'));
end;

procedure TConsole.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
 CanClose := False;
end;

function TConsole.StartTimer: Longint;
begin
  TimeMark := GetTimerCount;
  Result := TimeMark;
end;

function TConsole.StopTimer: Longint;
begin
  Result := GetTimerCount;
  Print(IntToStr(Result - TimeMark));
end;

procedure TConsole.Print(const s: string);
begin
  with Listbox do
  begin
    Items.Add(s);
    ItemIndex := Items.Count - 1;
  end;
end;

procedure TConsole.PrintStrings(s: TStrings); { 2.2 }
begin
  with Listbox do begin
    Items.AddStrings(s);
    ItemIndex := Items.Count - 1;
  end;
end;

initialization
  Console := TConsole.Create(Application);
  Console.Show;
end.

