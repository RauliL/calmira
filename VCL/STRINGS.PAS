{*********************************************************}
{                                                         }
{    Calmira System library 3.3                           }
{    by Li-Hsin Huang & Erwin Dokter                      }
{    released into the public domain may 2002             }
{                                                         }
{*********************************************************}

unit Strings;

interface

uses Classes;

const
  Uppers = ['A'..'Z'];
  Lowers = ['a'..'z'];
  Alphas = Uppers + Lowers;
  Digits = ['0'..'9'];
  AlphaDigits = Alphas + Digits;
  OneItem : array[Boolean] of string[2] = ('s', '');

type
  TAttrStr = string[5];
  TUniqueStrings = class(TStringList)
    constructor Create;
  end;

function LowCase(c: Char): Char;
{ converts a character to lower case }

function InString(c: char; const s: string): Boolean;
{ Returns true if a character is present in a string.
  Probably faster than Pos. }

function CharCount(c: Char; const s: string): Integer;
{ Returns the number of occurences of c in S }

function IsBlank(const s: string): boolean;
{ Returns true if the string is empty or consists of spaces }

procedure Replace(var s: string; const old, new: string);
{ Replaces occurences of a substring with another substring }

function Capitalize(const s: string): string;
{ Converts a string to lowercase, then changes first letter
  to upper case -- 3.1 moved from Drives.pas }

function MakePath(const s: string): string;
{ Adds a trailing backslash to a directory name, if necessary }

function MakeDirname(const s: string): string;
{ Removes a trailing backslash from a directory name, if necessary }

function ExtractFileDir(const s: string): string;
{ Same as ExtractFilePath, but removes the trailing backslash }

function ExtractFileDrive(const s: string): string;
{ Return the drive part of a path, ie. 'C:' }

function FormatByte(Size: Longint; KBDecimals, MBDecimals: Integer): string;
{ Formats a number (assumed to be bytes) to display as bytes,
  KB or MB, for example "245 bytes", "1.60 KB", "44.10 MB" }

function FormatByteLong(Size: Longint): string;

function GetStrKey(const s: string): string;
function GetStrValue(const s: string): string;
{ Returns the left and right sides, respectively, of a string with the
  structure Key = Value }

function SetStrValue(const s, value: string): string;
{ If s contains an '=', the portion to the right of '=' is set
  to the value }

function FillString(c: char; n: Byte): string;
{ Returns a string of length n containing only the specified character }

function Unformat(const source, pattern: string; const args: array of const): Integer;
{ The opposite of Format, Unformat splits up a formatted source string
  into substrings and Integers.  It is an alternative to parsing when
  the format is known to be fixed.  The pattern parameter contains the format
  string, which is a combination of plain characters and format specifiers.

  The following specifiers are supported:

  %s   indicates that a string value is required
  %d   indicates that an integer value is required
  %S   indicates that a string value should be ignored
  %D   indicates that an integer value should be ignored

  Unformat compares the source with the pattern, and plain characters
  that do not match will raise an EConvertError.  When a format specifier
  is encountered in the pattern, an argument is fetched and used to
  store the result that is obtained from the source.  Then the comparison
  continues.

  For each %s, the args list must contain a pointer to a string variable,
  followed by an integer specifying the maximum length of the string.
  For each %d, the args list must contain a pointer to an integer variable.

  When the end of the source string is reached, the function returns
  without modifying the remaining arguments, so you might wish to initialize
  your variables to "default" values before the function call.

  Unformat returns the number of values it has extracted.

  Examples:

  var
    s1, s2: string[31];
    i: Integer;

  Unformat('[abc]123(def)', '[%s]%d(%s)', [@s1, 31, @i, @s2, 31]);
    (* s1 = 'abc', i = 123, s2 = 'def' *)

  Unformat('Hello, Universe!!!', '%s, %s%d', [@s1, 31, @s2, 31, @i]);
    (* s1 = 'Hello', s2 = 'Universe!!!', i is untouched *)

  Unformat('How much wood could a woodchuck chuck...',
           '%S %S %s could a %S %s...', [@s1, 31, @s2, 31]);
    (* s1 = 'wood', s2 = 'chuck' *) }

function FileParams(files: TStrings): string;
{ Assumes that the strings parameter contains a list of filename, and
  concatenates the names to form a single string suitable for passing
  as a command line parameter.  Filenames with no extension have an
  extra '.' appended to ensure correct interpretation }

function GetWord(var s: OpenString; delim: Char): string;
{ Skips characters and returns the next word in a string.  The word
  is deleted from the string }

function FirstWord(const s: string): string;
{ Returns first word of a string }

function StrPChar(var s: OpenString): PChar;
{ Converts a string to a PChar }

function AttrToStr(attr: Integer): TAttrStr;
{ Translates attribute value to a string, ie. (faArchive or faReadonly)
  returns 'AR' }

function RemoveSpaces(const s: string): string;
{ removes spaces form a string }

(*
function CharPosStart(const source :string; start: Integer; c:char) : Integer;
function CharPos(const source :string; c:char) : Integer;
*)

implementation

uses SysUtils, WinTypes;

constructor TUniqueStrings.Create;
begin
  inherited Create;
  Duplicates := dupIgnore;
  Sorted := True;
end;

function LowCase(c: Char): Char; assembler;
asm
        MOV     AL,c
        CMP     AL,'A'
        JB      @Finish
        CMP     AL,'Z'
        JA      @Finish
        ADD     AL,32
@Finish:
end;

function InString(c: Char; const s: string): Boolean; assembler;
asm
        XOR     AH,AH
        LES     DI,s
        MOV     AL,ES:[DI]
        INC     DI
        MOV     CH,AH
        MOV     CL,AL
        MOV     AL,c
        CLD
        REPNE   SCASB
        JNE     @@1
        INC     AH
@@1:    MOV     AL,AH
end;

function CharCount(c: Char; const s: string): Integer; assembler;
asm
        XOR     AH,AH
        LES     DI,s
        MOV     AL,ES:[DI]
        INC     DI
        MOV     CX,AX
        MOV     AL,c
        CLD
@@1:    REPNE   SCASB
        JNE     @@2
        INC     AH
        JMP     @@1
@@2:    MOV     AL,AH
        XOR     AH,AH
end;

function IsBlank(const s: string): boolean; assembler;
asm
        LES     DI,s
        SUB     CX,CX
        MOV     CL,BYTE PTR ES:[DI]
        JCXZ    @@1
        INC     DI
        CLD
        MOV     AL,32
        REP     SCASB
        JZ      @@1
        MOV     AL,False
        JMP     @@2
@@1:    MOV     AL,True
@@2:
end;

procedure Replace(var s: string; const old, new: string);
var
  i, l: Integer;
begin
  l := Length(old);
  i := Pos(old, s);
  while i > 0 do
  begin
    Delete(s, i, l);
    Insert(new, s, i);
    i := Pos(old, s);
  end;
end;

function Capitalize(const s: string): string;
begin
  Result := LowerCase(s);
  Result[1] := Upcase(Result[1]);
end;

function MakePath(const s: string): string;
begin
  Result := s;
  if Result[Length(Result)] <> '\' then AppendStr(Result, '\');
end;

function MakeDirname(const s: string): string;
begin
  Result := s;
  if (Length(Result) <> 3) and (Result[Length(Result)] = '\') then
    Dec(Result[0]);
end;

function ExtractFileDir(const s: string): string;
begin
  Result := MakeDirName(ExtractFilePath(s));
end;

function ExtractFileDrive(const s: string): string;
begin
  if (Length(s) >= 2) and (s[2] = ':') then
    Result := Copy(s, 1, 2);
end;

function FormatByte(Size: Longint; KBDecimals, MBDecimals: Integer): string;
begin
  if size < 1024 then
    Result := Format('%d byte%s', [Size, OneItem[Size = 1]])
  else if size < 1048576 then
    Result := Format('%.*n KB', [KBDecimals, Size / 1024])
  else
    Result := Format('%.*n MB', [MBDecimals, Size / 1048576]);
end;

function FormatByteLong(Size: Longint): string;
begin
  Result := Format('%.0n byte%s', [Size * 1.0, OneItem[Size = 1]]);
end;

function GetStrKey(const s: string): string;
var
  i: Integer;
begin
  Result := s;
  i := Pos('=', Result);
  if i > 0 then Result[0] := Chr(i - 1);
end;

function GetStrValue(const s: string): string;
var
  i: Integer;
begin
  i := Pos('=', s);
  if i = 0 then Result := '' else Result := Copy(s, i + 1, Length(s) - i);
end;

function SetStrValue(const s, value: string): string;
var i: Integer;
begin
  i := Pos('=', s);
  if i = 0 then Result := s + '=' + value
  else Result := Copy(s, 1, i - 1) + '=' + value;
end;

function FillString(c: char; n: Byte): string; assembler;
asm
        MOV     CL,n
        XOR     CH,CH
        LES     DI,@result
        MOV     BYTE PTR ES:[DI], CL
        INC     DI
        MOV     AL,c
        CLD
        REP     STOSB
end;

function Unformat(const source, pattern: string; const args: array of const): Integer;

function Min(a, b: Integer): Integer; assembler;
asm
        MOV     AX,a
        CMP     AX,b
        JLE     @@1
        MOV     AX,b
@@1:
end;

var
  i, j, argindex, start, finish, maxlen: Integer;
  c: Char;
begin
  Result := 0;
  argindex := 0;
  i := 1;
  j := 1;
  while (i < Length(pattern)) and (j <= Length(source)) do
  begin
    if pattern[i] = '%' then
      case pattern[i+1] of
        'D': begin
               Inc(i, 2);
               while (j <= Length(source)) and
                 ((source[j] in Digits) or (source[j] = '-')) do Inc(j);
               Inc(Result);
             end;
        'S': begin
               Inc(i, 2);
               if i > Length(pattern) then break
               else
               begin
                 c := pattern[i];
                 while (j <= Length(source)) and (source[j] <> c) do Inc(j);
               end;
               Inc(Result);
             end;
        'd': begin
               if argindex > High(args) then
                 raise EConvertError.Create('Not enough arguments');
               Inc(i, 2);
               start := j;
               while (j <= Length(source)) and
                 ((source[j] in Digits) or (source[j] = '-')) do Inc(j);
               finish := j;
               if finish > start then
                 PInteger(args[argindex].VPointer)^ :=
                   StrToInt(Copy(source, start, finish - start));
               Inc(argindex);
               Inc(Result);
             end;
        's': begin
               if argindex > High(args) - 1 then
                 raise EConvertError.Create('Not enough arguments');
               if args[argindex + 1].VType <> vtInteger then
                 raise EConvertError.Create('No string size specified');
               maxlen := args[argindex+1].VInteger;
               Inc(i, 2);
               if i > Length(pattern) then
               begin
                 args[argindex].VString^ :=
                   Copy(source, j, Min(Length(source) + 1 - j, maxlen));
                 Inc(argindex);
                 break;
               end
               else
               begin
                 c := pattern[i];
                 start := j;
                 while (j <= Length(source)) and (source[j] <> c) do
                   Inc(j);
                 finish := j;
                 args[argindex].VString^ :=
                   Copy(source, start, Min(finish - start, maxlen));
                 Inc(argindex, 2);
               end;
               Inc(Result);
             end;
      else Inc(i);
      end
    else
      {if pattern[i] <> source[j] then
        raise EConvertError.Create('Pattern mismatch')
      else}
      begin
        Inc(i);
        Inc(j);
      end;
  end;
end;

function FileParams(files: TStrings): string;
var
  i: Integer;
begin
  Result := '';
  i := 0;
  while (i < files.Count) and (Length(Result) < 255) do
  begin
    if Pos('.', files[i]) = 0 then AppendStr(Result, files[i] + '. ')
    else AppendStr(Result, files[i] + ' ');
    Inc(i);
  end;
end;

function GetWord(var s: OpenString; delim: Char): string;
var
  i: Integer;
begin
  i := Pos(delim, s);
  if i = 0 then begin
    if Length(s) > 0 then
    begin
      Result := s;
      s := '';
    end
    else Result := '';
  end
  else
  begin
    Result := Copy(s, 1, i - 1);
    while (i <= Length(s)) and (s[i] = delim) do Inc(i);
    Delete(s, 1, i - 1);
  end;
end;

function FirstWord(const s: string): string;
var
  i: Integer;
begin
  Result := s;
  i := Pos(' ', Result);
  if i > 0 then Result[0] := Chr(i - 1);
end;

function StrPChar(var s: OpenString): PChar;
begin
  if Length(s) = High(s) then Dec(s[0]);
  s[Length(s) + 1] := #0;
  Result := @s[1];
end;

function AttrToStr(attr: Integer): TAttrStr; assembler;
asm
        LES     DI,@Result
        MOV     BX,DI
        XOR     AX,AX
        INC     DI
        MOV     CX,attr
        MOV     DX,CX
        AND     DX,faReadOnly
        JZ      @@1
        MOV     AL,'R'
        STOSB
        INC     AH
@@1:    MOV     DX,CX
        AND     DX, faHidden
        JZ      @@2
        MOV     AL,'H'
        STOSB
        INC     AH
@@2:    MOV     DX,CX
        AND     DX,faSysfile
        JZ      @@3
        MOV     AL,'S'
        STOSB
        INC     AH
@@3:    MOV     DX,CX
        AND     DX,faArchive
        JZ      @@4
        MOV     AL,'A'
        STOSB
        INC     AH
@@4:    MOV     DX, CX
        AND     DX, faDirectory
        JZ      @@5
        MOV     AL,'D'
        STOSB
        INC     AH
@@5:    MOV     BYTE PTR ES:[BX], AH
end;

function RemoveSpaces(const s: string): string;
var
  i: Integer;
begin
  Result := '';
  for i := 1 to Length(s) do
    if s[i] <> ' ' then
    begin
      Inc(Result[0]);
      Result[Ord(Result[0])] := s[i];
    end;
end;

(*
function CharPosStart(const source :string; start: Integer; c:char): Integer; assembler;
asm
        LES     DI,source
        MOV     AL,c
        SUB     AH, AH
        SUB     CX,CX
        MOV     CL,ES:[DI]
        INC     DI
        MOV     BX,DI
        MOV     DX,start
        CMP     DX,CX
        JA      @@1
        CMP     DX,0
        JE      @ZeroStart
        DEC     DX
@ZeroStart:
        ADD     DI,DX
        CLD
        REPNE   SCASB
        JNE     @@1
        SUB     DI,BX
        MOV     AX,DI
        JMP     @@2
@@1:    XOR     AX,AX
@@2:
end;

function CharPos(const source :string; c:char): Integer; assembler;
asm
        LES     DI,source
        MOV     AL,c
        SUB     AH,AH
        SUB     CX,CX
        MOV     CL,ES:[DI]
        INC     DI
        MOV     BX,DI
        CLD
        REPNE   SCASB
        JNE     @@1
        SUB     DI,BX
        MOV     AX,DI
        JMP     @@2
@@1:    XOR     AX,AX
@@2:
end;
*)

end.
