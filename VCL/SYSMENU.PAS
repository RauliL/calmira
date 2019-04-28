{*********************************************************}
{                                                         }
{    Calmira System library 3.3                           }
{    by Li-Hsin Huang & Erwin Dokter                      }
{    released into the public domain may 2002             }
{                                                         }
{*********************************************************}

unit SysMenu;

{ TSystemMenu provides a thin wrapper for the Windows API menu functions,
  and is used to change a form's system menu.  It's most useful in the
  OnCreate handler, when you can modify the menu before the form appears.
  Mainly, it saves you having to remember (or look up) the multitude of
  parameters. }

interface

uses SysUtils, WinTypes, WinProcs, Messages, Classes, Controls, Forms;

type
  TSystemMenu = class(TComponent)
  private
    { Private declarations }
    FHandle : HMenu;
  protected
    { Protected declarations }
    procedure Loaded; override;
  public
    { Public declarations }
    procedure Reset;
    procedure Add(Caption: PChar; Command: Word);
    procedure AddLoadStr(Ident, Command: Word);
    procedure Insert(Index: Integer; Caption: PChar; Command: Word);
    procedure AddSeparator;
    procedure InsertSeperator(Index: Integer); { 3.11 }
    procedure Delete(Index: Integer);
    procedure DeleteCommand(Command: Word);
    procedure Rename(Command: Word; Caption: PChar);
    procedure ReAssign(OldCommand, NewCommand: Word; Caption: PChar);
    property Handle: HMenu read FHandle;
  published
    { Published declarations }
  end;

procedure Register;

implementation

procedure TSystemMenu.Loaded;
begin
  inherited Loaded;
  FHandle := GetSystemMenu((Owner as TForm).Handle, False);
end;

procedure TSystemMenu.Reset;
begin
  FHandle := GetSystemMenu((Owner as TForm).Handle, True);
end;

procedure TSystemMenu.Add(Caption: PChar; Command: Word);
begin
  AppendMenu(FHandle, MF_ENABLED, Command, Caption);
end;

procedure TSystemMenu.AddLoadStr(Ident, Command: Word);
var
  buf: array[0..79] of Char;
begin
  LoadString(HInstance, Ident, Buf, 79);
  Add(buf, Command);
end;

procedure TSystemMenu.AddSeparator;
begin
  AppendMenu(FHandle, MF_SEPARATOR, 0, nil);
end;

procedure TSystemMenu.InsertSeperator(Index: Integer);
begin
  InsertMenu(FHandle, Index, MF_BYPOSITION or MF_SEPARATOR, 0, nil);
end;

procedure TSystemMenu.Delete(Index: Integer);
begin
  DeleteMenu(FHandle, Index, MF_BYPOSITION);
end;

procedure TSystemMenu.DeleteCommand(Command: Word);
begin
  DeleteMenu(FHandle, Command, MF_BYCOMMAND);
end;

procedure TSystemMenu.Rename(Command: Word; Caption: PChar);
begin
  ModifyMenu(FHandle, Command, MF_BYCOMMAND, Command, Caption);
end;

procedure TSystemMenu.ReAssign(OldCommand, NewCommand: Word; Caption: PChar);
begin
  ModifyMenu(FHandle, OldCommand, MF_BYCOMMAND, NewCommand, Caption);
end;

procedure TSystemMenu.Insert(Index: Integer; Caption: PChar; Command: Word);
begin
  InsertMenu(FHandle, Index, MF_BYPOSITION, Command, Caption);
end;

procedure Register;
begin
  RegisterComponents('Calmira', [TSystemMenu]);
end;

end.
