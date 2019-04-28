{*********************************************************}
{                                                         }
{    Calmira System library 3.3                           }
{    by Li-Hsin Huang & Erwin Dokter                      }
{    released into the public domain may 2002             }
{                                                         }
{*********************************************************}

unit PicBtn;

interface

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  Forms, Dialogs, StdCtrls, Buttons;

type
  TPicBtn = class(TBitBtn)
  private
    { Private declarations }
  protected
    { Protected declarations }
    procedure Loaded; override;
  public
    { Public declarations }
  published
    { Published declarations }
  end;

const
  PicBtnGlyphs: Boolean = False;
  PicBtnHeightDelta: Integer = 2;

procedure PicBtnGlyphsChanged;
procedure Register;

implementation

procedure TPicBtn.Loaded;
begin
  inherited Loaded;
  if not PicBtnGlyphs and not (csDesigning in ComponentState) and (Glyph <> nil) then
  begin
    Glyph := nil;
    Margin := -1;
    Height := Height - PicBtnHeightDelta;
  end
  else
    Margin := 4;
  Spacing := -1;
end;

procedure PicBtnGlyphsChanged;
begin
  MsgDlgGlyphs := PicBtnGlyphs;
  if MsgDlgGlyphs then MsgDlgBtnSize.Y := 25 else MsgDlgBtnSize.Y := 23;
end;

procedure Register;
begin
  RegisterComponents('Calmira', [TPicBtn]);
end;

end.

