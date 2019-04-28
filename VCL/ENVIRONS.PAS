{*********************************************************}
{                                                         }
{    Calmira System library 3.3                           }
{    by Li-Hsin Huang & Erwin Dokter                      }
{    released into the public domain may 2002             }
{                                                         }
{*********************************************************}

unit Environs;

{ This unit initializes by filling the Environment string list with
  the current DOS environment.  You can retrieve individual settings
  using TStrings's Values[] property.

  The EnvironSubst function processes a string and substitutes all
  environment variable names with the actual values, in the same way
  that MS-DOS does. }

interface

uses Classes, SysUtils, WinProcs;

function EnvironSubst(const s: string): string;

var
  Environment: TStringList;

implementation

function EnvironSubst(const s: string): string;
var
  i, j: Integer;
  value: string[128];
begin
  Result := s;
  i := 1;
  while (i < Length(Result)) do
  begin
    while (i < Length(Result)) and (Result[i] <> '%') do Inc(i);
    j := i + 1;
    while (j <= Length(Result)) and (Result[j] <> '%') do Inc(j);
    if (i < Length(Result)) and (j <= Length(Result)) then
    begin
      value := Environment.Values[Copy(Result, i + 1, j - i - 1)];
      Delete(Result, i, j - i + 1);
      Insert(value, Result, i);
      Inc(i, Length(value) - 1);
    end;
    Inc(i);
  end;
end;

procedure InitEnvirons;
var
  p: PChar;
begin;
  Environment := TStringList.Create;
  p := GetDOSEnvironment;
  while p^ <> #0 do
  begin
    Environment.Add(StrPas(p));
    Inc(p, StrLen(p) + 1);
  end;
end;

procedure DoneEnvirons; far;
begin
  Environment.Free;
end;

initialization
  InitEnvirons;
  AddExitProc(DoneEnvirons);
end.

