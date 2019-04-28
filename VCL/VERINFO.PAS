{*********************************************************}
{                                                         }
{    Calmira System library 3.3                           }
{    by Li-Hsin Huang & Erwin Dokter                      }
{    released into the public domain may 2002             }
{                                                         }
{*********************************************************}

unit VerInfo;

{ TVersion extracts version information using the functions in VER.DLL.
  Under Windows 3.1, this only finds resources compiled by Microsoft's
  resource compiler. Later Windows version also read resources compiled
  by Borland's resource compiler.

  After calling Create, the HasData property tells you whether any
  information was found.  If it is True, you can access the fields
  using the other properties or the GetVersionInfo function. }

interface

uses SysUtils, WinTypes, Ver;

type
  TVersionInfo = (viCompanyName, viComments, viFileDescription,
    viFileVersion, viInternalName, viLegalCopyright,
    viLegalTrademarks, viOriginalFilename, viPrivateBuild,
    viProductName, viProductVersion, viSpecialBuild,
    viWOWVersion { 3.1 });

TVersion = class
  private
    { Private declarations }
    Handle: Longint;
    BufferSize: Integer;
    Buffer: PChar;
    TransTable: PLongint;
    FixedInfo: ^TVS_FIXEDFILEINFO;
    FHasData: Boolean;
    function GetString(i: Integer): string;
    function GetFileOS: string;
    function GetFileType: string;
    function GetFileSubType: string;
  public
    { Public declarations }
    constructor Create(const filename: TFilename);
    destructor Destroy; override;
    function GetVersionInfo(VerKind: TVersionInfo): String;
    property HasData: Boolean read FHasData;
    property CompanyName: string index 0 read GetString;
    property Comments: string index 1 read GetString;
    property FileDescription: string index 2 read GetString;
    property FileVersion: string index 3 read GetString;
    property InternalName: string index 4 read GetString;
    property LegalCopyright: string index 5 read GetString;
    property LegalTrademarks: string index 6 read GetString;
    property OriginalFilename: string index 7 read GetString;
    property PrivateBuild: string index 8 read GetString;
    property ProductName: string index 9 read GetString;
    property ProductVersion: string index 10 read GetString;
    property SpecialBuild: string index 11 read GetString;
    property WOWVersion: string index 12 read GetString; { 3.1 }
    property FileOS: string read GetFileOS;
    property FileType: string read GetFileType;
    property FileSubType: string read GetFileSubType;
  end;

implementation

uses WinProcs;

const
  VerNameArray: array[TVersionInfo] of PChar =
    ('\CompanyName', '\Comments', '\FileDescription', '\FileVersion',
     '\InternalName', '\LegalCopyright', '\LegalTrademarks',
     '\OriginalFilename', '\PrivateBuild', '\ProductName',
     '\ProductVersion', '\SpecialBuild', '\WOW Version' { 3.1 });

constructor TVersion.Create(const filename: TFilename);
var
  filestr: array[0..79] of Char;
  len: word;
begin
  BufferSize := GetFileVersionInfoSize(StrPCopy(filestr, filename), Handle);
  if BufferSize > 0 then
  begin
    Buffer := AllocMem(BufferSize);
    if GetFileVersionInfo(filestr, Handle, BufferSize, Buffer) and
      VerQueryValue(Buffer, '\VarFileInfo\Translation', Pointer(TransTable), len) then
    begin
       FHasData := True;
       VerQueryValue(Buffer, '\', Pointer(FixedInfo), len);
    end;
  end;
end;

destructor TVersion.Destroy;
begin
  if BufferSize > 0 then FreeMem(Buffer, BufferSize);
end;

function TVersion.GetVersionInfo(VerKind: TVersionInfo): string;
var
  buf: PChar;
  len: Word;
begin
  Result := '';
  if not FHasData then Exit;
  Result := Format('\StringFileInfo\%.4x%.4x%s'#0, [LoWord(TransTable^),
    HiWord(TransTable^), VerNameArray[VerKind]]);
  len := 127;
  if VerQueryValue(Buffer, @Result[1], Pointer(buf), len) then
    Result := StrPas(buf)
  else
    Result := '';
end;

function TVersion.GetString(i: Integer): string;
begin
  if FHasData then Result := GetVersionInfo(TVersionInfo(i))
  else Result := '';
end;

function TVersion.GetFileOS: string;
var
  OS: Longint;
begin
  Result := '';
  if not FHasData then Exit;
  OS := FixedInfo^.dwFileOS;
  { case cannot be used with LongInt type }
  if OS = VOS_UNKNOWN then Result := 'Unknown'
  else if OS = VOS_DOS then Result := 'MS-DOS'
  else if OS = VOS_NT then Result := 'Windows NT'
  else if OS = VOS__WINDOWS16 then Result := '16-bit Windows'
  else if OS = VOS__WINDOWS32 then Result := '32-bit Windows'
  else if OS = VOS_DOS_WINDOWS16 then Result := '16-bit Windows with MS-DOS'
  else if OS = VOS_DOS_WINDOWS32 then Result := '32-bit Windows with MS-DOS'
  else if OS = VOS_NT_WINDOWS32 then Result := '32-bit Windows NT';
end;

function TVersion.GetFileType: string;
begin
  Result := '';
  if FHasData then
    case FixedInfo^.dwFileType of
      VFT_UNKNOWN    : Result := 'Unknown';
      VFT_APP        : Result := 'Application';
      VFT_DLL        : Result := 'Dynamic link library';
      VFT_DRV        : Result := 'Device driver';
      VFT_FONT       : Result := 'Font';
      VFT_VXD        : Result := 'Virtual device driver';
      VFT_STATIC_LIB : Result := 'Static link library';
    end;
end;

function TVersion.GetFileSubType: string;
begin
  Result := '';
  if not FHasData then Exit;
  if FixedInfo^.dwFileType = VFT_DRV then
    case FixedInfo^.dwFileSubType of
      VFT2_UNKNOWN         : Result := 'Unknown';
      VFT2_DRV_COMM        : Result := 'Communications';
      VFT2_DRV_PRINTER     : Result := 'Printer';
      VFT2_DRV_KEYBOARD    : Result := 'Keyboard';
      VFT2_DRV_LANGUAGE    : Result := 'Language';
      VFT2_DRV_DISPLAY     : Result := 'Display';
      VFT2_DRV_MOUSE       : Result := 'Mouse';
      VFT2_DRV_NETWORK     : Result := 'Network';
      VFT2_DRV_SYSTEM      : Result := 'System';
      VFT2_DRV_INSTALLABLE : Result := 'Installable';
      VFT2_DRV_SOUND       : Result := 'Sound';
    end
  else if FixedInfo^.dwFileType = VFT_FONT then
    case FixedInfo^.dwFileSubType of
      VFT2_FONT_RASTER   : Result := 'Raster';
      VFT2_FONT_VECTOR   : Result := 'Vector';
      VFT2_FONT_TRUETYPE : Result := 'TrueType';
    end;
end;

end.
