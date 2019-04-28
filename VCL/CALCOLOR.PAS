{*********************************************************}
{                                                         }
{    Calmira System Library 4.0                           }
{    by Li-Hsin Huang & Erwin Dokter                      }
{    released into the public domain may 2002             }
{                                                         }
{*********************************************************}

unit CalColor;

interface

uses Classes, Graphics;

const
  clInfoBk = TColor($02E0FFFF);
  clNone = TColor($02FFFFFF);
  clCream = TColor($F0FBFF);
  clMoneyGreen = TColor($C0DCC0);
  clSkyBlue = TColor($F0CAA6);

function IdentToCalColor(const Ident: string; var Color: Longint): Boolean;
function CalColorToString(Color: TColor): string;
function StringToCalColor(S: string): TColor;
procedure GetCalColorValues(Proc: TGetStrProc);

implementation

uses SysUtils;

type
  TColorEntry = record
    Value: TColor;
    Name: PChar;
  end;

const
  CalColors: array[0..4] of TColorEntry = (
    (Value: clInfoBk; Name: 'clInfoBk'),
    (Value: clNone; Name: 'clNone'),
    (Value: clCream; Name: 'clCream'),
    (Value: clMoneyGreen; Name: 'clMoneyGreen'),
    (Value: clSkyBlue; Name: 'clSkyBlue'));

function CalColorToString(Color: TColor): string;
var
  I: Integer;
begin
  if not ColorToIdent(Color, Result) then begin
    for I := Low(CalColors) to High(CalColors) do
      if CalColors[I].Value = Color then
      begin
        Result := StrPas(CalColors[I].Name);
        Exit;
      end;
    FmtStr(Result, '$%.8x', [Color]);
  end;
end;

function IdentToCalColor(const Ident: string; var Color: Longint): Boolean;
var
  I: Integer;
  Text: array[0..63] of Char;
begin
  StrPLCopy(Text, Ident, SizeOf(Text) - 1);
  for I := Low(CalColors) to High(CalColors) do
    if StrIComp(CalColors[I].Name, Text) = 0 then begin
      Color := CalColors[I].Value;
      Result := True;
      Exit;
    end;
  Result := IdentToColor(Ident, Color);
end;

function StringToCalColor(S: string): TColor;
begin
  if not IdentToCalColor(S, Longint(Result)) then
    Result := StringToColor(S);
end;

procedure GetCalColorValues(Proc: TGetStrProc);
var
  I: Integer;
begin
  for I := Low(CalColors) to High(CalColors) do Proc(StrPas(CalColors[I].Name));
end;

end.
