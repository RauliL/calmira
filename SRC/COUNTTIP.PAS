program CountTip;

{ This is a Turbo Pascal program to run from a DOS box.  Redirect
  standard input to this program, and it will count the number of
  tips in a file.  It ignores the first line (which should contain
  a number), blank lines, and lines beginning with a semi-colon.

  It also checks that there is a full stop or exclamation mark
  at the end of each string, to try and catch out those which are
  longer than 255 characters.  }


function CheckString(const s: string): Boolean;
var
  i: Integer;
begin
  i := Length(s);
  while (i > 0) and (s[i] = ' ') and (s[i] <> '.') do
    Dec(i);
  CheckString := (s[i] = '.') or (s[i] = '!');
end;


var
  Count, Lines : Integer;
  s : string;
begin
  Readln;
  Count := 0;
  Lines := 1;
  while not Eof do
  begin
    Readln(s);
    Inc(Lines);
    if (s > '') and (s[1] <> ';') then begin
      Inc(Count);
      if not CheckString(s) then
        Writeln('Unterminated string at line ', Lines);
    end;
  end;
  Writeln('I''ve found ', Count, ' tips.');
end.
