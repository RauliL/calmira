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

program Explorer;

{$R *.RES}
{$D Calmira Explorer Launcher}

uses SysUtils, WinTypes, WinProcs, CalMsgs;

var
  Calmira: HWnd;
  Atom: TAtom;
  buf: array[0..79] of Char;
  path: string[79];

begin
  Calmira := FindWindow('TApplication', 'Calmira');
  if Calmira = 0 then Exit;
  if (ParamStr(1) > '') and (Calmira > 0) then
  begin
    if LowerCase(ParamStr(1)) = '/e' then
      path := '*' + ParamStr(2)
    else
      path := ParamStr(1);
    Atom := GlobalAddAtom(StrLower(StrPCopy(buf, path)));
    PostMessage(Calmira, WM_CALMIRA, CM_EXPLORER, Atom);
  end
  else PostMessage(Calmira, WM_CALMIRA, CM_EXPLORER, 0);
end.

