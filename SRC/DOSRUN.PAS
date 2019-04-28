{$M 1536, 0, 0}
program dosrun;

{ Note : this program is for MS-DOS Turbo Pascal, not Delphi }

uses dos;

var
  ProgramName, CmdLine: string;
  Dir: DirStr;
  Name: NameStr;
  Ext: ExtStr;
  i: Integer;

begin
  FSplit(ParamStr(1), Dir, Name, Ext);
  Delete(Dir, Length(Dir), 1);
  if Ext = '' then Ext := '.exe';
  ProgramName := Name + Ext;
  if ParamCount > 1 then
    for i := 2 to ParamCount do
      CmdLine := CmdLine + ParamStr(i) + ' ';
  ChDir(Dir);
  If IOResult <> 0 then Halt(1);
  Exec(ProgramName, CmdLine);
end.
