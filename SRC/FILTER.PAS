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

unit Filter;

interface

uses
  Classes, Controls, Forms, StdCtrls, Buttons, ExtCtrls, Directry, Picbtn;

type
  TFilterDialog = class(TForm)
    Label1: TLabel;
    FilterEdit: TComboBox;
    OKBtn: TPicBtn;
    CancelBtn: TPicBtn;
    cbHidSys: TCheckBox;
    Label2: TLabel;
    Image: TImage;
    procedure FormCreate(Sender: TObject);
    procedure OKBtnClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    function Execute(Dir : TDirectory): TModalResult;
  end;

{
var
  FilterDialog: TFilterDialog;
}

implementation

{$R *.DFM}

uses SysUtils, Settings, MiscUtil, Strings, Resource;

function TFilterDialog.Execute(Dir: TDirectory): TModalResult;
var
  details: TFileDetails;
  i: Integer;
  b: array[0..4] of Boolean;
  hidsys: Boolean;
begin
  FilterEdit.Text := Dir.Filter;
  cbHidSys.Checked := Dir.Mask and faHidden <> 0;
  Result := ShowModal;
  if Result = mrOK then
  begin
    Dir.Filter := FilterEdit.Text;
    Dir.Mask := DirectoryMasks[cbHidSys.Checked];
  end;
end;

procedure TFilterDialog.FormCreate(Sender: TObject);
begin
  Image.Picture.Icon.Assign(Icons.Get('MultiFile'));
  ini.ReadStrings('Browser Filters', FilterEdit.Items);
end;

procedure TFilterDialog.OKBtnClick(Sender: TObject);
begin
  with FilterEdit do
  begin
    Text := RemoveSpaces(Text);
    if Text = '' then Text := DefaultFilter;
  end;
  if AddHistory(FilterEdit) then
    ini.WriteNewStrings('Browser Filters', FilterEdit.Items);
end;

end.

