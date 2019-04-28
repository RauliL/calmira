{*********************************************************}
{                                                         }
{    Calmira System library 3.3                           }
{    by Li-Hsin Huang & Erwin Dokter                      }
{    released into the public domain may 2002             }
{                                                         }
{*********************************************************}

unit Files;

{ Medium level file utilities }

interface

uses Classes, WinTypes, SysUtils, Graphics;

type
  TDirInfo = record
    files: Integer;
    dirs: Integer;
    size: Longint;
  end;

  TDropInfo = record
    files: TStringList;
    posn: TPoint;
  end;

  EFileIOError = class(Exception);

  EFileMoveError = class(EFileIOError);
  EInsufficientSpace = class(EFileIOError);

  EFileNotFound = class(EFileIOError);
  EPathNotFound = class(EFileIOError);
  EAccessDenied = class(EFileIOError);

  EReadAccessDenied = class(EAccessDenied);
  EWriteAccessDenied = class(EAccessDenied);

  EReadFileNotFound = class(EFileNotFound);
  EWriteFileNotFound = class(EFileNotFound);

  EReadPathNotFound = class(EPathNotFound);
  EWritePathNotFound = class(EPathNotFound);

const
  { Use this to convert a "ShowMinimized" variable into a command }
  ShowCmds: array[Boolean] of Word = (SW_SHOWNORMAL, SW_MINIMIZE);
  BackgroundProc: procedure = nil;
  InvalidFilenameChars = [' ', '"', '/', '\', ':', ';', '|', '=', ','];

const
  { FindFirst/FindNext return codes }
  ERROR_SUCCESS           = 0;
  ERROR_FILE_NOT_FOUND    = -2;
  ERROR_PATH_NOT_FOUND    = -3;
  ERROR_ACCESS_DENIED     = -5;
  ERROR_INVALID_HANDLE    = -6;
  ERROR_NOT_ENOUGH_MEMORY = -8;
  ERROR_BAD_ENVIRONMENT   = -10;
  ERROR_BAD_FORMAT        = -11;
  ERROR_NO_MORE_FILES     = -18;

var
  ApplicationPath: TFilename;
  WinPath: TFilename;
  BytesCopied: Longint;

procedure FindFiles(const FileSpec: TFilename; attrib: Word; List: TStrings);
{ Executes a FindFirst/FindNext loop using the given file specifications.
  The search results are added to the strings object }

function DirInfo(const Dirname: TFilename; Subs: Boolean): TDirInfo;
{ Returns a record giving information about the specified directory.
  If Subs is True, this information includes details taken from
  subdirectories. }

function HDirectoryExists(const Filename: TFilename): Boolean;
{ Same as DirectoryExists in FileCtrl except that hidden ones are detected }

function FDirectoryExists(const Filename: TFilename): Boolean;
function FFileExists(const Filename: TFilename): Boolean;
function FFileCreate(const Filename: TFilename): Integer;
function FFileOpen(const Filename: TFilename; mode: word): Integer;
{ These functions perform the same tasks as those without the
  F prefix but raise an EPathNotFound exception if the parent
  directory doesn't exist.  Typically, this catches situations when a
  floppy disk is not in the drive. }

procedure FileCopy(const Filename, Destname: TFilename);
{ Copies any file while preserving the attributes and DOS timestamp.
  If there is not enough room on the destination disk, EInsufficientSpace
  is raised and if the destination has been created then it is deleted. }

procedure FileMove(const Filename, Destname: TFilename);
{ Moves a file, first by attempting a rename (which is fast), and
  then by copying the file and deleting the original. }

function FileExecute(const Operation, FileName, Params, DefaultDir: string;
  ShowCmd: Word): THandle;
{ Encapsulates the API ShellExecute function using Pascal strings }

function RandomFilename(const path, prefix, ext: TFilename): TFilename;
{ Generates a random filename in the given path (you must add
  a trailing backslash), which does not already exist.  The prefix
  can be up to 4 characters and the extension is optional.

  For example, RandomFilename('c:\temp\', 'abcd', 'txt') will
  return filenames like 'abcd4723.txt' }

function IsAncestorDir(const parent, child: TFilename): Boolean;
{ Returns True if the first parameter is an an ancestor directory
  of the second parameter.  This function just analyses the strings,
  and doesn't check the disk. }

function IsValidFilename(const s: TFilename): Boolean;
{ Returns True if the string is a valid 8.3 character MS-DOS filename }

function WildcardMatch(const filename, wildcard: string): Boolean;
{ Returns True if the filename is specified by the wildcard }

function ShowCmdsEx(n: Integer): Word;
{ Converts and integer into a ShowWindow command.  Returns SW_MINIMIZE
  if n is 1, SW_SHOWMAXIMIZED if n is 2, SW_HIDE is n is 3, and
  SW_SHOWNORMAL otherwise.  Use it with FileExecute and similar commands }

function QualifiedFilename(const s: TFilename): TFilename;
function MakeValidFilename(const s: TFilename): TFilename;

function MangleFilename(const path, original: TFilename): TFilename;
{ Appends a twiddle (tilde) and number to the end of a filename
  when a naming conflict occurs.  For example, if autoexec.bat exists,
  the second copy in the bin is called autoex~1.bat }

function CouldBeFolder(const s: TFilename): Boolean;
function ExpandFoldername(const s: TFilename; drive : Char): TFilename;

{ 3.11 taken from FileCtrl }

function MinimizeName(const Filename: TFileName; Canvas: TCanvas;
  MaxLen: Integer): TFileName;
procedure CutFirstDirectory(var S: TFileName);
function DirectoryExists(Name: TFilename): Boolean;
procedure ForceDirectories(Dir: TFilename);

implementation

uses ShellAPI, WinProcs, Strings;

procedure FindFiles(const Filespec: TFilename; attrib: Word; List: TStrings);
var
  rec: TSearchRec;
  code: Integer;
begin
  code := FindFirst(Filespec, attrib, rec);
  while code = ERROR_SUCCESS do
  begin
    List.Add(rec.name);
    code := FindNext(rec);
  end;
  FindClose(rec); { 3.11 }
end;

function HDirectoryExists(const Filename: TFilename): Boolean;
var
  rec: TSearchRec;
begin
  Result := ((Length(Filename) = 3) and CouldBeFolder(Filename))
    or (FindFirst(Filename, faDirectory or faHidden or faSysFile
    or faReadOnly, rec) = 0) and (rec.Attr and faDirectory <> 0);
  FindClose(rec); { 3.11 }
end;

function FDirectoryExists(const Filename: TFilename): Boolean;
var
  rec: TSearchRec;
  code: Integer;
begin
  code := FindFirst(Filename, faDirectory or faHidden or
    faSysFile or faReadOnly, rec);
  if code = ERROR_PATH_NOT_FOUND then
    raise EPathNotFound.CreateFmt('Path %s not found.', [ExtractFilePath(Filename)])
  else
    Result := code = ERROR_SUCCESS;
  FindClose(rec); { 3.11 }
end;

function FFileExists(const Filename: TFilename): Boolean;
var
  rec: TSearchRec;
  code: Integer;
begin
  code := FindFirst(Filename, faAnyFile and
    not (faVolumeID or faDirectory), rec);
  if code = ERROR_PATH_NOT_FOUND then
    raise EPathNotFound.CreateFmt('Path %s not found.', [ExtractFilePath(Filename)])
  else
    Result := code = ERROR_SUCCESS;
  FindClose(rec); { 3.11 }
end;

function FFileCreate(const Filename: TFilename): Integer;
var
  s: string;
begin
  Result := FileCreate(Filename);
  if Result < 0 then
  begin
    s := 'Unable to create ' + Filename;
    case Result of
      ERROR_ACCESS_DENIED : raise EWriteAccessDenied.Create(s + ': Access denied.');
      ERROR_PATH_NOT_FOUND: raise EWritePathNotFound.Create(s + ': Path not found.');
    else raise EFCreateError.Create(s);
    end;
  end;
end;

function FFileOpen(const Filename: TFilename; mode: word): Integer;
var
  s: string;
begin
  Result := FileOpen(Filename, mode);
  if Result < 0 then
  begin
    s := 'Unable to open ' + Filename;
    case Result of
      ERROR_ACCESS_DENIED : raise EReadAccessDenied.Create(s + ': Access denied.');
      ERROR_PATH_NOT_FOUND: raise EReadPathNotFound.Create(s + ': Path not found.');
      ERROR_FILE_NOT_FOUND: raise EReadFileNotFound.Create(s + ': File not found.');
    else raise EFOpenError.Create(s);
    end;
  end;
end;

procedure FileCopy(const Filename, Destname: TFilename);
const
  CopyBufSize: Word = 8192;
var
  source, dest, attr: Integer;
  Bytes, TimeStamp: Longint;
  Success: Boolean;
  CopyBuf: Pointer;
begin
  attr := FileGetAttr(Filename);
  source := FFileOpen(Filename, fmShareDenyWrite);
  try
    Success := False;
    TimeStamp := FileGetDate(source);
    dest := FFileCreate(Destname);
    try
      GetMem(CopyBuf, CopyBufSize);
      try
        repeat
          Bytes := FileRead(Source, CopyBuf^, CopyBufSize);
          if (Bytes > 0) and (FileWrite(Dest, CopyBuf^, Bytes) <> Bytes) then
            raise EInsufficientSpace.CreateFmt('Insufficient disk space to copy %s to %s', [Filename, Destname]);
          Inc(BytesCopied, Bytes);
          if Assigned(BackgroundProc) then BackgroundProc;
        until Bytes < CopyBufSize;
        Success := True;
      finally
        FreeMem(CopyBuf, CopyBufSize);
      end;
    finally
      if Success then
      begin
        FileSetDate(dest, TimeStamp);
        FileSetAttr(Destname, attr);
      end;
      FileClose(dest);
      if not Success then DeleteFile(Destname);
    end;
  finally
    FileClose(source);
  end;
end;

procedure FileMove(const Filename, Destname: TFilename);
begin
  if not RenameFile(FileName, Destname) then
  begin
    if FileGetAttr(FileName) and faReadOnly = faReadOnly then
      raise EFileMoveError.Create('Unable to move ' + FileName);
    FileCopy(FileName, Destname);
    if not DeleteFile(FileName) then
    begin
      FileSetAttr(Destname, 0);
      DeleteFile(Destname);
      raise EFileMoveError.Create('Unable to move ' + Filename);
    end;
  end;
end;

function FileExecute(const Operation, FileName, Params, DefaultDir: string;
  ShowCmd: Word): THandle;
var
  zFileName, zParams, zDir, zOper: array[0..127] of Char;
begin
  SetCursor(LoadCursor(0, IDC_WAIT));
  Result := ShellExecute(0, StrPCopy(zOper, Operation),
    StrPCopy(zFileName, FileName), StrPCopy(zParams, Params),
    StrPCopy(zDir, DefaultDir), ShowCmd);
end;

function DirInfo(const Dirname: TFilename; Subs : Boolean): TDirInfo;
var
  rec: TSearchRec;
  code: Integer;
begin
  Result.files := 0;
  Result.dirs := 0;
  Result.size := 0;
  code := FindFirst(Dirname + '\*.*', faAnyfile and not faVolumeID, rec);
  while code = 0 do
  begin
    Inc(Result.size, rec.size);
    if rec.attr and faDirectory <> 0 then
    begin
      if rec.name[1] <> '.' then
      begin
        Inc(Result.dirs);
        if Subs then with DirInfo(Dirname + '\' + rec.name, true) do
        begin
          Inc(Result.files, files);
          Inc(Result.dirs, dirs);
          Inc(Result.size, size);
        end;
      end
    end
    else Inc(Result.files);
    code := FindNext(rec);
  end;
  FindClose(rec); { 3.11 }
end;

function RandomFilename(const path, prefix, ext: TFilename): TFilename;
var
  i: Integer;
begin
  i := Random(10000);
  repeat
    Inc(i);
    Result := Format('%s%.4s%d%s', [path, prefix, i, ext]);
  until not FileExists(Result);
end;

function IsAncestorDir(const parent, child: TFilename): Boolean;
begin
  if (child[0] <= parent[0]) or (child[1] <> parent[1]) then
    Result := False
  else
    Result := (parent[0] = #3) or (Pos(parent + '\', child) = 1);
end;

function IsValidFilename(const s: TFilename): Boolean;
var
  i: Integer;
  seendot: Boolean;
begin
  i := 1;
  Result := Length(s) <= 12;
  seendot := False;
  while (i <= Length(s)) and Result do
  begin
    if s[i] = '.' then
    begin
      Result := not seendot and (i <= 9) and (Length(s) - i <= 3);
      seendot := True;
    end
    else
      Result := not (s[i] in InvalidFilenameChars);
    Inc(i);
  end;
  Result := Result and (seendot or (Length(s) <= 8));
end;

function ShowCmdsEx(n: Integer): Word;
begin
  case n of
    1: Result := SW_MINIMIZE;
    2: Result := SW_SHOWMAXIMIZED;
    3: Result := SW_HIDE;
  else
    Result := SW_SHOWNORMAL;
  end;
end;

function QualifiedFilename(const s: TFilename) : TFilename;
begin
  Result := s;
  if ExtractFileExt(Result) = '' then AppendStr(Result, '.');
end;

function MakeValidFilename(const s: TFilename): TFilename;
var
  i: Integer;
begin
  Result := '';
  for i := 1 to Length(s) do
    if not (s[i] in InvalidFilenameChars) then
      AppendStr(Result, s[i]);
end;

function WildcardMatch(const filename, wildcard: string): Boolean;
var
  i, j: Integer;
begin
  Result := True;
  if wildcard = '*.*' then Exit; { 4.0 all files match }
  i := 1;
  j := 1;
  while (i <= Length(filename)) and (j <= Length(wildcard)) and Result do
  begin
    case wildcard[j] of
      '?' : begin
              Result := filename[i] <> '.';
              Inc(i);
              Inc(j);
            end;
      '*' : begin
              while (i <= Length(filename)) and (filename[i] <> '.') do Inc(i);
              Inc(j);
            end;
      else
      begin
        Result := filename[i] = wildcard[j];
        Inc(i);
        Inc(j);
      end;
    end;
  end;
  Result := Result and (i = Length(filename) + 1) and (j = Length(wildcard) + 1);
end;

function MangleFilename(const path, original: TFilename): TFilename;
var
  n, p: Integer;
  body: string[8];
  ext: string[3];
  num: string[5];
  R: TSearchRec;
begin
  p := Pos('.', original);
  if p = 0 then
  begin
    body := original;
    ext := '';
  end
  else
  begin
    body := Copy(original, 1, p - 1);
    ext := Copy(original, p + 1, 255);
  end;
  Result := path + original;
  n := 0;
  while FindFirst(Result, faAnyFile and not faVolumeID, R) = 0 do
  begin
    Inc(n);
    num := IntToStr(n);
    Result := Format('%s%s~%d.%s', [Path, Copy(body, 1, 7 - Length(num)), n, ext]);
    FindClose(R); { 3.11 }
  end;
  if Result[Length(Result)] = '.' then Dec(Result[0]);
end;

function CouldBeFolder(const s: TFilename): Boolean;
begin
  Result := (Length(s) >= 3) and (s[1] in Alphas) and (s[2] = ':') and (s[3] = '\');
end;

function ExpandFoldername(const s: TFilename; drive : Char): TFilename;
const
  Fmts: array[Boolean] of string[7] = ('%s:\%s', '%s:%s');
begin
  Result := s;
  if not CouldBeFolder(Result) then
  begin
    if (Length(Result) = 2) and (Result[1] in Alphas) and (Result[2] = ':') then
      AppendStr(Result, '\')
    else
      Result := Format(Fmts[(Result > '') and (Result[1] = '\')], [drive, Result]);
  end;
end;

function MinimizeName(const Filename: TFileName; Canvas: TCanvas;
  MaxLen: Integer): TFileName;
var
  Drive: string[3];
  Dir: TFileName;
  Name: TFileName;
  Ext: TFileName;
  P: Integer;
begin
  Result := FileName;
  Dir := ExtractFilePath(Result);
  Name := ExtractFileName(Result);
  P := Pos('.', Name);
  if P > 0 then Name[0] := Chr(P - 1);
  Ext := ExtractFileExt(Result);
  if Dir[2] = ':' then
  begin
    Drive := Copy(Dir, 1, 2);
    Dir := Copy(Dir, 3, 255);
  end else Drive := '';
  while ((Dir <> '') or (Drive <> '')) and (Canvas.TextWidth(Result) > MaxLen) do
  begin
    if Dir = '\...\' then
    begin
      Drive := '';
      Dir := '...\';
    end else if Dir = '' then Drive := ''
    else CutFirstDirectory(Dir);
    Result := Drive + Dir + Name + Ext;
  end;
end;

procedure CutFirstDirectory(var S: TFileName);
var
  Root: Boolean;
  P: Integer;
begin
  if S = '\' then S := ''
  else begin
    if S[1] = '\' then
    begin
      Root := True;
      S := Copy(S, 2, 255);
    end else Root := False;
    if S[1] = '.' then S := Copy(S, 5, 255);
    P := Pos('\',S);
    if P <> 0 then S := '...\' + Copy(S, P + 1, 255)
    else S := '';
    if Root then S := '\' + S;
  end;
end;

function DirectoryExists(Name: TFilename): Boolean;
var
  SR: TSearchRec;
begin
  if Name[Length(Name)] = '\' then Dec(Name[0]);
  if (Length(Name) = 2) and (Name[2] = ':') then
    Name := Name + '\*.*';
  Result := FindFirst(Name, faDirectory, SR) = 0;
  Result := Result and (SR.Attr and faDirectory <> 0);
end;

procedure ForceDirectories(Dir: TFilename);
begin
  if Dir[Length(Dir)] = '\' then Dec(Dir[0]);
  if (Length(Dir) < 3) or DirectoryExists(Dir) then Exit;
  ForceDirectories(ExtractFilePath(Dir));
  MkDir(Dir);
end;

initialization
  ApplicationPath := ExtractFilePath(ParamStr(0));
  WinPath[0] := Chr(GetWindowsDirectory(@WinPath[1], 79));
  WinPath := MakePath(WinPath);
end.

