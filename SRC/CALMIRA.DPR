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

program Calmira;

uses
  Forms,
  WinProcs,
  WinTypes,
  SysUtils,
  Controls,
  Dialogs,
  MiscUtil,
  Classes,
  Buttons,
  IniFiles,
  Graphics,
  Strings,
  About in 'ABOUT.PAS' {About Dialog},
  FileProp in 'FILEPROP.PAS' {File Properties},
  DiskProp in 'DISKPROP.PAS' {Disk Properties},
  Progress in 'PROGRESS.PAS' {Progress Dialog},
  Replace in 'REPLACE.PAS' {Replace Dialog},
  Splash in 'SPLASH.PAS' {Splash Form},
  OpenFile in 'OPENFILE.PAS' {OpenFileDlg},
  RunProg in 'RUNPROG.PAS' {Run Dialog},
  Desk in 'DESK.PAS' {Desktop},
  CompSys in 'COMPSYS.PAS' {Computer Window},
  Shorts in 'SHORTS.PAS' {Shortcuts},
  Filter in 'FILTER.PAS' {Filter},
  WasteBin in 'WASTEBIN.PAS' {Bin Window},
  FileFind in 'FILEFIND.PAS' {Find Form},
  Iconic in 'ICONIC.PAS' {Iconic Classes},
  FileMan in 'FILEMAN.PAS' {File Management},
  Resource in 'RESOURCE.PAS' {Resources},
  Directry in 'DIRECTRY.PAS' {Directories},
  Settings in 'SETTINGS.PAS' {Settings},
  IconWin in 'ICONWIN.PAS' {Icon Window},
  Start in 'START.PAS' {Start Menu},
  ProgConv in 'PROGCONV.PAS' {Convert Dialog},
  Referenc in 'REFERENC.PAS' {References},
  Alias in 'ALIAS.PAS' {Aliases},
  Tree in 'TREE.PAS' {Explorer Tree},
  Shutdown in 'SHUTDOWN.PAS' {Shutdown dialog},
  CalForm in 'CALFORM.PAS' {Modeless windows},
  FourDos in 'FOURDOS.PAS' {4DOS Descriptions},
  RefEdit in 'REFEDIT.PAS' {Reference Editor},
  MenuEdit in 'MENUEDIT.PAS' {Menu Editor},
  StrtProp in 'STRTPROP.PAS' {Start Properties},
  DeskProp in 'DESKPROP.PAS' {Desktop Properties},
  BinProp in 'BINPROP.PAS' {Bin Properties},
  TaskProp in 'TASKPROP.PAS' {Taskbar Properties},
  SysProp in 'SYSPROP.PAS' {System Properties},
  FSysProp in 'FSYSPROP.PAS' {File System Properties},
  AskDrop in 'ASKDROP.PAS' {Drop Dialog},
  Select in 'SELECT.PAS' {Select File Dialog},
  Tips in 'TIPS.PAS' {Tips of the Day},
  Locale in 'LOCALE.PAS' {Localized strings},
  Task in 'TASK.PAS' {Taskbar},
  IncSrch in 'INCSRCH.PAS' {Incremental Search},
  Hooks in 'HOOKS.PAS' {Windows Hooks},
  CalMsgs in 'CALMSGS.PAS' {Calmira Messages},
  DynaMenu in 'DYNAMENU.PAS' {Dynamic Menu's},
  Taskman in 'TASKMAN.PAS' {Task Manager},
  Password in 'PASSWORD.PAS' {Password Dialog},
  Logon in 'LOGON.PAS' {Logon Dialog},
  GotoFld in 'GOTOFLD.PAS' {Goto Dialog};

{$R *.RES}
{$D Calmira II Online! Release}

procedure LoadAndRun;
var
  s: string;
begin
  { Reads and processes the Load= and Run= lines in WIN.INI.
    Each "word" on the line represents a program, which should be
    executed by the shell }
  with TIniFile.Create('win.ini') do
  try
    s := ReadString('Windows', 'Load', '');
    while s > '' do DefaultExec(GetWord(s, ' '), '', '', SW_SHOWMINNOACTIVE);
    s := ReadString('Windows', 'Run', '');
    while s > '' do DefaultExec(GetWord(s, ' '), '', '', SW_SHOWNORMAL);
  finally
    Free;
  end;
end;

procedure RunCmdLine;
var
  s: string;
  i: Integer;
begin
  { Execute command line parameter }
  if ParamCount >= 1 then
  begin
    s := '';
    for i := 2 to ParamCount do AppendStr(s, ParamStr(i) + ' ');
    DefaultExec(ParamStr(1), s, '', SW_SHOW);
  end;
end;

begin { Calmira }
  if (HPrevInst <> 0) then
  begin
    { Only run one instance of Calmira }
    PostMessage(FindWindow('TApplication', 'Calmira'),
      WM_CALMIRA, CM_PREVINSTANCE, 0);
    Exit;
  end;

  { 2.3 -- Show logon dialog if MultiUser enabled }
  CheckForLogon;
  WritePathDetermined;

  { Disable Windows error messages }
  LastErrorMode := SetErrorMode(SEM_FAILCRITICALERRORS);
  Screen.Cursor := crHourGlass;

  LoadSettings;
  LoadResources;

  { The Splash form is the main form (!!!) }
  Application.CreateForm(TSplashForm, SplashForm);
  with SplashForm do
    if ShowSplash then
    begin
      Show;
      Update;
    end;

  { Reset the cursor because TDesktop takes it over now }
  Screen.Cursor := crDefault;

  { Create and initialize main application components
    -- the ordering is significant! }
  Desktop := TDesktop.Create(Application);
  Desktop.SetCursor(crHourGlass);
  StartMenu := TStartMenu.Create(Application);
  Application.CreateForm(TComputer, Computer);
  Application.CreateForm(TBin, Bin);
  Application.CreateForm(TProgressBox, ProgressBox);
  Application.CreateForm(TTaskbar, Taskbar);

  TIconWindow.CalcColWidths;
  Desktop.Load;
  StartMenu.Load;
  SetErrorMode(LastErrorMode);

  SplashForm.TotalHide;
  Desktop.ReleaseCursor;

  { Load programs in win.ini's Load= and Run= lines, Startup folder
    and command line }
  if IsShell then LoadAndRun;
  if (IsShell or not ShellStartup) and
    (GetAsyncKeyState(VK_SHIFT) >= 0) then StartMenu.RunStartup;
  RunCmdLine;

  { Show About box the first time Calmira is run }
  if FirstRun then ShowModalDialog(TAboutBox);
  if ShowDailyTips and
    (DateToStr(Date) <> ini.ReadString('Calmira', 'DateLastRun', '')) then
      ShowModalDialog(TTipDialog);
  if RestoreSys then Computer.ShowNormal;

  Application.Run;
  if IsShell then ExitWindows(0, 0);
end.
