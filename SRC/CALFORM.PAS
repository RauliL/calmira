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

unit CalForm;

{ TCalForm is the common ancestor of most of Calmira's modeless windows,
  and you should use it for other modeless windows that you add.

  The main feature is the use of WMSettingsChanged to trigger the
  SettingsChanged method.  Descendants override this to adjust their
  properties depending on which settings have been modified.

  3.1 -- All StretchShift and related methods are moved to ExtForm. }

interface

uses Forms, ExtForm, Messages, Classes, Controls, WinProcs, WinTypes,
  CalMsgs, Settings;

type
  TCalForm = class(TExtForm)
  private
    { Private declarations }
    procedure WMSettingsChanged(var Msg: TMessage); message WM_SETTINGSCHANGED;
  protected
    { Protected declarations }
    procedure CreateParams(var Params: TCreateParams); override;
  public
    { Public declarations }
    procedure SettingsChanged(Changes: TSettingChanges); virtual;
  end;

implementation

procedure TCalForm.WMSettingsChanged(var Msg: TMessage);
begin
  SettingsChanged(TSettingChanges(Msg.wParam));
end;

procedure TCalForm.CreateParams(var Params: TCreateParams);
begin
  inherited CreateParams(Params);
  if DesktopParent then Params.WndParent := GetDesktopWindow;
end;

procedure TCalForm.SettingsChanged(Changes: TSettingChanges);
begin
end;

end.

