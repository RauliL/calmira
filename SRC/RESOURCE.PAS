{**************************************************************************}
{                                                                          }
{    Calmira II shell for Microsoft® Windows(TM) 3.1                       }
{    Online! Release 3.3                                                  }
{    Copyright (C) 1998-2002 Calmira Online!                               }
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

unit Resource;

{ Icons, cursors and some bitmaps are handled by this module.

  TIconList manages a large number of icons extracted from
  different files.  By keeping track of where each icon comes from,
  it ensures that a particular icon is only loaded once, thus saving
  memory and disk accesses.  Icons are loaded only when they are
  required.

  The icon cache is only maintained for "document" files, because they
  are likely to appear often.  Keeping icons for programs would just
  waste memory because they are only used once or twice.

  The icon list is a string list, with each string associated with an
  icon object, which may be nil. For example,

    bmp   [ an icon ]
    txt   [   nil   ]
    bat   [   nil   ]

  ExtensionMap holds a list of file extensions and where the
  representative icon is stored.  For example

    bmp=c:\windows\pbrush.exe(0)
    txt=c:\windows\notepad.exe
    bat=c:\windows\notepad.exe

  FileMap holds a list of filenames, and the objects array holds
  icon objects, which can also be nil.

    c:\windows\pbrush.exe(0)  [ an icon ]
    c:\windows\notepad.exe(0) [   nil   ]

  When Get() is called, the icon list searches itself for a matching
  key.  If it finds a match plus an icon, the icon is returned, making
  the access fast.  If it finds a match but a nil pointer, the search
  extends to ExtensionMap.

  With the data above, Get('bat') will find NIL, so it looks at the
  extensions and finds the reference to Notepad.  Looking through FileMap
  shows that no icon is available for Notepad, so it must be extracted.
  The two nils encountered are overwritten with the TIcon object.

  4.0 -- Closely related to the icons are the file type descriptions.
  These are stored in FileTypes and loaded from the ini file and the
  registry when LoadRegisteredIcons is called.

    bmp=Bitmap Image
    txt=Text File
    bat=MS-DOS Batch File }

interface

uses WinTypes, Graphics, Classes, Drives, ObjList, Strings;

type
  TIconlist = class(TUniqueStrings)
  private
    ExtensionMap, FileMap, FileTypes: TStringList;
    Store: TObjectList;
    function GetDriveIcon(dtype: TDriveType): TIcon;
  public
    constructor Create;
    destructor Destroy; override;
    procedure AddIcon(const s: string; Icon: TIcon);
    procedure DelayLoad(const key: string; filename: string);
    function Get(const s: string): TIcon;
    function GetType(const s: string): string;
    property Drive[dtype: TDriveType]: TIcon read GetDriveIcon;
  end;

  TResBitmap = class(TBitmap)
  private
    ResID: PChar;
    ExternalFile: string[12];
  public
    constructor Load(BitmapName: PChar);
    constructor AlternateLoad(BitmapName: PChar; const Filename: string);
    procedure Reload;
  end;

const
  crDropFile       = -20;
  crDropCopy       = -21;
  crDropMulti      = -22;
  crDropMultiCopy  = -23;
  crDropAlias      = -24;
  crFinger         = -25;
  crBusyPointer    = -26;
  crTerminate      = -27;
  crDropFolder     = -28;
  crDropFolderCopy = -29;

var
  Icons: TIconList;
  FolderIcon : TIcon;
  FileIcon   : TIcon;
  ProgIcon   : TIcon; { 3.1 -- was LetterIcon }
  DOSIcon    : TIcon;
  TinyFile   : TIcon;
  TinyFolder : TIcon;
  TinyProg   : TIcon;
  Sizebox    : TResBitmap;
  ShortArrow : TResBitmap;
  AliasArrow : TResBitmap;
  HDropAlias : HCursor;
  HNoDrop    : HCursor;

procedure ReplaceNodropCursor(cursor: HCursor);
procedure RestoreNodropCursor;
procedure LoadResources;

implementation

{$R ICONS.RES}
{$R BITMAPS.RES}
{$R CURSORS.RES}

uses SysUtils, WinProcs, ShellAPI, IniFiles, Forms, Controls,
  Locale, Files, MiscUtil, Settings, Environs, Registry;

{ TIconList }

constructor TIconList.Create;
begin
  inherited Create;
  Store := TObjectList.Create;
  ExtensionMap := TUniqueStrings.Create;
  FileMap := TUniqueStrings.Create;
  FileTypes := TUniqueStrings.Create;
  FileTypes.Sorted := False;
end;

destructor TIconList.Destroy;
begin
  Store.Free;
  ExtensionMap.Free;
  FileMap.Free;
  FileTypes.Free;
  inherited Destroy;
end;

procedure TIconList.AddIcon(const s: string; Icon: TIcon);
begin
  AddObject(s, Icon);
  Store.Add(Icon);
end;

procedure TIconList.DelayLoad(const key: string; filename: string);
begin
  Add(key);
  if ExtensionMap.Values[key] = '' then
  begin
    filename := EnvironSubst(filename);
    ExtensionMap.Add(Format('%s=%s', [key, filename]));
    FileMap.Add(filename);
    {FileTypes.Add(Format('%s=%s', [key, filetype]));}
  end;
end;

function TIconList.Get(const s: string): TIcon;
var
  i, j, index: Integer;
  filename: TFilename;
  h: HIcon;
begin
  i := IndexOf(s);
  if i > -1 then
  begin
    Result := TIcon(Objects[i]);
    if Result = nil then
    begin
      { no icon in main list }
      j := FileMap.IndexOf(ExtensionMap.Values[s]);
      if j = -1 then
        { shouldn't really happen! }
        j := FileMap.Add(ExtensionMap.Values[s]);
      if FileMap.Objects[j] = nil then
      begin
        { try to extract icon }
        filename := '';
        index := 0;
        Unformat(FileMap[j], '%s(%d)', [@filename, 79, @index]);
        h := ExtractIcon(HInstance, StrPChar(filename), index);
        if h > 1 then
        begin
          { a new icon has been found }
          Result := TIcon.Create;
          Result.Handle := h;
          Store.Add(Result);
          FileMap.Objects[j] := Result;
          Objects[i] := Result
        end
        else
        begin
          { the file doesn't contain an icon so assign default }
          Result := FileIcon;
          FileMap.Objects[j] := FileIcon;
          Objects[i] := FileIcon;
        end;
      end
      else
      begin
        { Found an icon in FileMap }
        Result := TIcon(FileMap.Objects[j]);
        Objects[i] := Result;
      end;
    end;
  end
  else
  begin
    if s = 'Empty' then Result := nil { 3.2 }
    else Result := FileIcon;
  end;
end;

function TIconList.GetType(const s: string): string;
begin
  Result := FileTypes.Values[s];
  if Result = '' then
    Result := UpperCase(s) + LoadStr(SCFile);
  if Result[1] = ' ' then System.Delete(Result, 1, 1);
end;

function TIconList.GetDriveIcon(dtype: TDriveType): TIcon;
const
  DriveIdents: array[TDriveType] of string[15] =
    ('HardDrive', 'HardDrive', 'FloppyDrive', 'HardDrive',
     'NetworkDrive', 'CDROMDrive', 'RamDrive');
begin
  Result := Get(DriveIdents[dtype]);
end;

{ TResBitmap }

constructor TResBitmap.Load(BitmapName: PChar);
begin
  inherited Create;
  ResID := BitmapName;
  ExternalFile := '';
  Reload;
end;

constructor TResBitmap.AlternateLoad(BitmapName: PChar; const Filename: string);
begin
  inherited Create;
  ResID := BitmapName;
  ExternalFile := Filename;
  Reload;
end;

procedure TResBitmap.ReLoad;
var
  bitmapfile: TFilename;
begin
  { 3.0 - Look in user's directory first }
  if (ExternalFile > '') then
  begin
    bitmapfile := FileWritePath + ExternalFile;
    if not FileExists(bitmapfile) then
      bitmapfile := ApplicationPath + ExternalFile;
    if FileExists(bitmapfile) then LoadFromFile(bitmapfile)
    else Handle := LoadBitmap(HInstance, ResID);
  end
  else Handle := LoadBitmap(HInstance, ResID);
end;

function LoadSystemIcon(const key, alt: string; ResID: PChar): TIcon;
begin
  Result := TIcon.Create;
  with Icons do
  begin
    if IndexOf(alt) > -1 then Result.Assign(Get(alt))
    else Result.Handle := LoadIcon(HInstance, ResID);
    AddIcon(key, Result);
  end;
end;

(*
function LoadProgmanIcon(const key, alt: string; index: Integer): TIcon;
var
  buf: array[0..79] of Char;
begin
  Result := TIcon.Create;
  with Icons do
  begin
    if IndexOf(alt) > -1 then Result.Assign(Get(alt))
    else Result.Handle := ExtractIcon(HInstance,
      StrPCopy(buf, WinPath + 'progman.exe'), index);
    AddIcon(key, Result);
  end;
end;
*)

procedure LoadSystemIcons;
begin
  FolderIcon  := LoadSystemIcon('Folder', '_folder', 'FOLDERICON');
  FileIcon    := LoadSystemIcon('File', '_file', 'FILEICON');
  ProgIcon    := LoadSystemIcon('Program', '_prog', 'PROGICON');
  TinyFolder  := LoadSystemIcon('TinyFolder', '_tfolder', 'TINYFOLDERICON');
  TinyFile    := LoadSystemIcon('TinyFile', '_tfile', 'TINYFILEICON');
  TinyProg    := LoadSystemIcon('TinyProg', '_tprog', 'TINYPROGICON');
  LoadSystemIcon('MultiFile', '_multi', 'MULTIFILEICON');
  LoadSystemIcon('HardDrive', '_hard', 'HARDICON');
  LoadSystemIcon('FloppyDrive', '_floppy', 'FLOPPYICON');
  LoadSystemIcon('CDROMDrive', '_cdrom', 'CDROMICON');
  LoadSystemIcon('NetworkDrive', '_network', 'NETWORKICON');
  LoadSystemIcon('RamDrive', '_ramdisk', 'RAMDISKICON');
  LoadSystemIcon('EmptyBin', '_emptbin', 'BINICON');
  LoadSystemIcon('FullBin', '_fullbin', 'FULLBINICON');
  LoadSystemIcon('Computer', '_compute', 'COMPUTERICON');
  LoadSystemIcon('Explorer', '_explore', 'EXPLORERICON');
  LoadSystemIcon('FindDialog', '_finddlg', 'FINDDLGICON');
  LoadSystemIcon('RunDialog', '_rundlg', 'RUNDLGICON');
  LoadSystemIcon('Internet', '_internt', 'INTERNETICON');
  LoadSystemIcon('ShutDownDialog', '_shutdn', 'SHUTDOWNICON');
  { 3.1 }
  LoadSystemIcon('ProgressDialog', '_progres', 'PROGRESSICON');
  LoadSystemIcon('GotoDialog', '_gotodlg', 'GOTODLGICON');
  LoadSystemIcon('TaskManager', '_taskman', 'TASKMANICON');
  { Start menu icons }
  LoadSystemIcon('Programs', '', 'SMGROUPICON');
  LoadSystemIcon('Find', '', 'SMFINDICON');
  LoadSystemIcon('Run', '', 'SMRUNICON');
  LoadSystemIcon('ShutDown', '', 'SMSHUTDOWNICON');
  LoadSystemIcon('Settings', '', 'SMSETTINGSICON');
  LoadSystemIcon('Help', '', 'SMHELPICON');
  LoadSystemIcon('Documents', '', 'SMDOCICON');
  LoadSystemIcon('Favorites', '', 'SMFAVICON');
end;

procedure LoadUserIcons;
var
  key: string[31];
  temp: TStringList;
  i: Integer;
  path, filename: TFilename;
begin
  temp := TStringList.Create;
  try
    { Find all *.ICO files in the home directory (or directory specified in
      the UserIcons value).  Discard their file extensions and add the
      filenames to the internal lists }
    path := ini.ReadString('File System', 'UserIcons', FileWritePath);
    path := MakePath(path);
    FindFiles(path + '*.ico', faArchive or faReadOnly, temp);
    for i := 0 to temp.Count - 1 do
    begin
      Unformat(Lowercase(temp[i]), '%s.', [@key, 31]);
      Icons.DelayLoad(key, Format('%s%s(0)', [path, temp[i]]));
    end;
    { Add all entries from the [Icons] section }
    temp.Clear;
    ini.ReadSectionValues('Icons', temp);
    for i := 0 to temp.Count - 1 do
    begin
      Unformat(Lowercase(temp[i]), '%s=%s', [@key, 31, @filename, 79]);
      Icons.DelayLoad(key, filename);
    end;
  finally
    temp.Free;
  end;
end;

procedure LoadRegisteredIcons;
var
  ext: string[15];
  progname: TFilename;
  i, index: Integer;
  temp: TStringList;
  reg: TRegistry;
  key: string;
begin
  temp := TStringList.Create;
  reg := TRegistry.Create;
  ini.ReadSectionValues('File Types', Icons.FileTypes);
  try
    { 3.1 -- Query the registry for registered file types }
    with reg do
    begin
      OpenKey('', False);
      i := 0;
      while EnumKey(i, key) do
      begin
        if key[1] = '.' then
        begin
          progname := ReadString(key + '\shell\open\command');
          if progname = '' then
            progname := ReadString(ReadString(key) + '\DefaultIcon');
          if progname = '' then
            progname := ReadString(ReadString(key) + '\shell\open\command');
          if progname > '' then
          begin
            Icons.FileTypes.Add(Copy(key, 2, 3) + '=' + ReadString(ReadString(Key)));
            temp.Add(Copy(key, 2, 3) + '=' + progname);
          end;
        end;
        Inc(i);
      end;
    end;
    for i := 0 to temp.Count - 1 do
    begin
      Index := 0;
      if Pos(',', temp[i]) > 0 then
        Unformat(LowerCase(temp[i]), '%s=%s,%d', [@ext, 15, @progname, 79, @index])
      else
        Unformat(LowerCase(temp[i]), '%s=%s ', [@ext, 15, @progname, 79]);
      if ExtractFilePath(progname) = '' then progname := WinPath + progname;
      Icons.DelayLoad(ext, progname + '(' + IntToStr(index) + ')');
    end;
  finally
    temp.Free;
    reg.Free;
  end;
end;

procedure LoadCursors;
begin
  with Screen do
  begin
    HDropAlias := LoadCursor(HInstance, 'DROPFILEALIAS');
    HNoDrop := LoadCursor(HInstance, 'DRAGFILE');
    Cursors[crDropFile] := LoadCursor(HInstance, 'DROPFILE');
    Cursors[crDropMulti] := LoadCursor(HInstance, 'DROPMULTIFILE');
    Cursors[crDropCopy] := LoadCursor(HInstance, 'DROPFILECOPY');
    Cursors[crDropMultiCopy] := LoadCursor(HInstance, 'DROPMULTIFILECOPY');
    Cursors[crDropAlias] := HDropAlias;
    Cursors[crNoDrop] := HNoDrop;
    Cursors[crFinger] := LoadCursor(HInstance, 'FINGER');
    Cursors[crBusyPointer] := LoadCursor(HInstance, 'BUSYPOINTER');
    Cursors[crTerminate] := LoadCursor(HInstance, 'TERMINATE');
    Cursors[crDropFolder] := LoadCursor(HInstance, 'DROPFOLDER');
    Cursors[crDropFolderCopy] := LoadCursor(HInstance, 'DROPFOLDERCOPY');
  end;
end;

{ 3.11 -- These functions change and restore the crNodrop cursors
  while dragging, eliminating the need to use SetCursor, which causes
  flickering becuase the default drag handler also uses SetCursor. }

var
  Faking: Boolean;

procedure ReplaceNodropCursor(cursor: HCursor);
begin
  if not Faking then
  begin
    Screen.Cursors[crNodrop] := CopyIcon(HInstance, cursor);
    Faking := True;
  end;
end;

procedure RestoreNodropCursor;
begin
  if Faking then
  begin
    Screen.Cursors[crNodrop] := CopyIcon(HInstance, HNoDrop);
    Faking := False;
  end;
end;

procedure LoadResources;
begin
  LoadUserIcons;
  LoadSystemIcons;
  LoadRegisteredIcons;
  LoadCursors;
end;

procedure InitResources;
begin
  Icons := TIconList.Create;
  SizeBox := TResBitmap.AlternateLoad('SIZEBOX', 'sizebox.bmp');
  ShortArrow := TResBitmap.AlternateLoad('SHORTARROW', 'arrow.bmp');
  AliasArrow := TResBitmap.AlternateLoad('SHORTARROW', 'arrow.bmp');
end;

procedure DoneResources; far;
begin
  Icons.Free;
  Sizebox.Free;
  ShortArrow.Free;
  AliasArrow.Free;
end;

initialization
  InitResources;
  AddExitProc(DoneResources);
end.

