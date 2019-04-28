{$M 4096,0,0}
program DirExist;

{ Note: this program is for MS-DOS Turbo Pascal, not Delphi }

uses WinDOS, Strings;

function IsRoot(s: string): Boolean;
begin
  s[1] := UpCase(s[1]);
  IsRoot := ((Length(s) = 3) and (s[1] >= 'A') and (s[1] <= 'Z') and
    (s[2] = ':') and (s[3] = '\'))
    or ((s[1] = '.') and (s[2] = '.'))
    or (s = '\');
end;

var
  buf: array[0..255] of Char;
  filename: string;
  SR: TSearchRec;

begin
  filename := ParamStr(1);
  if filename = '' then Halt(0);
  if IsRoot(filename) then Halt(1);
  FindFirst(StrPCopy(buf, filename), faDirectory, SR);
  if (DosError = 0) and (SR.Attr and faDirectory <> 0) then Halt(1)
  else Halt(0);
end.
