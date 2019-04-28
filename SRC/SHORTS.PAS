{**************************************************************************}
{                                                                          }
{    Calmira II shell for Microsoft® Windows(TM) 3.1                       }
{    Online! Release 3.3                                                  }
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

unit Shorts;

{ Shortcuts are implemented as ordinary forms that stay minimized.
  Each shortcut contains a TReference which handles the interaction
  with the main engine.  TDesktop is responsible for loading and
  saving shortcuts. }

interface

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Controls,
  Forms, Dialogs, Dropclnt, DragDrop, IniFiles, Referenc, CalForm, CalMsgs,
  Sysmenu, Settings;

type
  TShort = class(TCalForm)
    DropClient: TDropClient;
    SystemMenu: TSystemMenu;
    procedure FormDragDrop(Sender, Source: TObject; X, Y: Integer);
    procedure FormDragOver(Sender, Source: TObject; X, Y: Integer;
      State: TDragState; var Accept: Boolean);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure DropClientDropFiles(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure FormDestroy(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
  private
    { Private declarations }
    FRef: TReference;
    LastMouseDown: Longint;
    procedure WMQueryOpen(var Msg: TWMQueryOpen); message WM_QUERYOPEN;
    procedure WMOpenShort(var Msg: TMsg); message WM_OPENSHORT;
    procedure WMCommand(var Msg: TMessage); message WM_COMMAND;
    procedure WMSysCommand(var Msg: TWMSysCommand); message WM_SYSCOMMAND;
    procedure WMPaint(var Msg: TWMPaint); message WM_PAINT;
    procedure WMMouseActivate(var Msg: TWMMouseActivate); message WM_MOUSEACTIVATE;
    procedure WMLButtonDblClk(var Msg: TWMLButtonDblClk); message WM_LBUTTONDBLCLK;
    procedure WMNCRButtonDown(var Msg: TWMNCRButtonDown); message WM_NCRBUTTONDOWN;
    procedure RefChange(Sender: TObject);
  public
    { Public declarations }
    property Ref: TReference read FRef;
    procedure SettingsChanged(Changes: TSettingChanges); override;
    procedure LoadFromIni(ini: TIniFile; const section: string);
    procedure SaveToIni(ini: TIniFile; const section : string);
  end;

implementation

{$R *.DFM}

uses Desk, Resource, IconWin, ShellAPI, FileMan, MultiGrd, WasteBin, FileFind,
  Drives, Files, Strings, MiscUtil, CompSys, Graphics, Locale, ShutDown;

const
  SC_PROPERTIES = SC_VSCROLL + 1024;
  QueryClose: Boolean = False;

procedure TShort.WMMouseActivate(var Msg: TWMMouseActivate);
begin
  { To prevent shortcuts being moved when the icon is dragged,
    the mouse down message is thrown away.  To catch double clicks,
    the DoubleClickSpeed from WIN.INI is used to time each message. }
  if StickyShorts or OneClickShorts then with Msg do
    if MouseMsg = WM_LBUTTONDOWN then
    begin
      Result := MA_NOACTIVATEANDEAT;
      if OneClickShorts or (GetTimerCount < LastMouseDown + DoubleClickSpeed) then
        Perform(WM_OPENSHORT, 0, 0);
    end
    else inherited
  else inherited;
  LastMouseDown := GetTimerCount;
end;

procedure TShort.WMLButtonDblClk(var Msg: TWMLButtonDblClk);
begin
  PostMessage(Handle, WM_OPENSHORT, 0, 0);
end;

procedure TShort.WMNCRButtonDown(var Msg: TWMNCRButtonDown);
var
  p: TPoint;
begin
  GetCursorPos(p);
  TrackPopupMenu(SystemMenu.Handle, TPM_LEFTALIGN or TPM_RIGHTBUTTON, p.X, p.Y, 0, Handle, nil);
end;

procedure TShort.WMQueryOpen(var Msg: TWMQueryOpen);
begin
  { New windows cannot be opened when inside SendMessage, so
    an extra message must be posted to remind the shortcut to open.
    0 is returned to keep the shortcut iconic }
  Msg.Result := 0;
  PostMessage(Handle, WM_OPENSHORT, 0, 0);
end;

procedure TShort.WMOpenShort(var Msg: TMsg);
begin
  Ref.Open;
end;

procedure TShort.WMCommand(var Msg: TMessage);
begin
  with Msg do PostMessage(Handle, WM_SYSCOMMAND, wParam, MakeLong(1, 1));
end;

procedure TShort.WMSysCommand(var Msg: TWMSysCommand);
var
  P: TPoint;
  R: TRect;
begin
  with Msg do
    case CmdType and $FFF0 of
      SC_CLOSE      : QueryClose := True;
      SC_PROPERTIES : if CanEditSettings then Ref.Edit;
      SC_RESTORE    :
        begin
          { This extra code fixes the Alt-Tab activation bug.  Previously,
            Alt-Tabbing to Calmira when a shortcut was last active would
            generate an SC_RESTORE and open the shortcut again.

            We can now tell if this message was generated by Alt+Tab by
            examining the cursor position.  The "physical" cursor must be
            within the icon's boundaries, and also, Windows will provide
            a positive cursor feedback in XPos and YPos if the Open
            command was selected from the popup menu }
          GetCursorPos(P);
          with MinPosition do R := Bounds(X, Y, 32, 32);
          if not PtInRect(R, P) and (XPos = 0) and (YPos = 0) then Exit;
        end;
    end;
  inherited;
  QueryClose := False;
end;

procedure TShort.WMPaint(var Msg: TWMPaint);
begin
  inherited;
  if ShortArrows then
    Canvas.Draw(0, 32 - ShortArrow.Height, ShortArrow);
end;

procedure TShort.FormDragDrop(Sender, Source: TObject; X, Y: Integer);
begin
  Ref.DragDrop(Source);
end;

procedure TShort.FormDragOver(Sender, Source: TObject; X, Y: Integer;
  State: TDragState; var Accept: Boolean);
begin
  Accept := (Source <> Computer.Grid) and ((Source <> Bin.Listbox) or
    (Ref.Kind <> rkFile));
end;

procedure TShort.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := caFree;
end;

procedure TShort.FormCreate(Sender: TObject);
var
  buf: array[0..31] of Char;
begin
  with SystemMenu do
  begin
    { 3.11 re-ordered }
    DeleteCommand(SC_SIZE);
    DeleteCommand(SC_MINIMIZE);
    DeleteCommand(SC_MAXIMIZE);
    DeleteCommand(SC_TASKLIST);
    Delete(2);
    LoadString(HInstance, SMenuShortcutOpen, buf, 31);
    Rename(SC_RESTORE, buf);
    InsertSeperator(1);
    LoadString(HInstance, SMenuShortcutMove, buf, 31);
    Rename(SC_MOVE, buf);
    LoadString(HInstance, SMenuShortcutRemove, buf, 31);
    Rename(SC_CLOSE, buf);
    LoadString(HInstance, SMenuShortcutProperties, buf, 31);
    Insert(5, buf, SC_PROPERTIES);
  end;
  FRef := TShortcutReference.Create;
  FRef.OnChange := RefChange;
end;

procedure TShort.DropClientDropFiles(Sender: TObject);
begin
  Ref.AcceptFiles(DropClient.Files);
end;

procedure TShort.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  { QueryClose is set to True when the user deletes the shortcut
    from the popup menu.  During shutdown, this is False so shortcuts
    are closed without asking }
  CanClose := not QueryClose or (CanEditSettings and (not ConfirmDelShort
    or (MsgDialogResFmt(SQueryDeleteShortcut, [Caption],
    mtConfirmation, mbOKCancel, 0) = mrOK)));
end;

procedure TShort.RefChange(Sender: TObject);
begin
  Ref.AssignIcon(Icon);
  Caption := Ref.Caption;
end;

procedure TShort.LoadFromIni(ini: TIniFile; const section: string);
begin
  Ref.LoadFromIni(ini, section);
  MinPosition := Point(ini.ReadInteger(section, 'Left', 128),
    ini.ReadInteger(section, 'Top', 128));
  Update;
end;

procedure TShort.SaveToIni(ini: TIniFile; const section: string);
begin
  Ref.SaveToIni(ini, section);
  with MinPosition do
  begin
    ini.WriteInteger(section, 'Left', x);
    ini.WriteInteger(section, 'Top', y);
  end;
end;

procedure TShort.FormDestroy(Sender: TObject);
begin
  FRef.Free;
end;

procedure TShort.SettingsChanged(Changes: TSettingChanges);
begin
  if [scDesktop, scDisplay] * Changes <> [] then Repaint;
end;

procedure TShort.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  { 3.1 Show Quit dialog when ALT-F4 is pressed while shortcut has focus }
  if (Key = VK_F4) and (ssAlt in Shift) then
  begin
    Key := 0;
    ShowModalDialog(TQuitDlg);
  end;
  if Key = VK_DELETE then
  begin
    QueryClose := True;
    Close;
  end;
end;

end.

