{*********************************************************}
{                                                         }
{    Calmira System library 3.3                           }
{    by Li-Hsin Huang & Erwin Dokter                      }
{    released into the public domain may 2002             }
{                                                         }
{*********************************************************}

unit Registry;

{ TRegistry is a simple wrapper object around ShellAPI's Registry
  calls, to make the registration database easier to access, much
  like TIniFile or TRegistry in Delphi 2.

  The interface is based on, and a subset of, TRegistry from Delphi 2.
  All basic functions in this unit are interface compatible with their
  Delphi 2 counterparts; except for EnumKey, which does not exsist in
  Delphi 2.

  Unlike TRegistry in Delphi 2, there is no need to open the keys
  beforehand. If you only need to occasionally read data from the
  registry, simply use ReadString with the full key specified, ie:

    Reg := TRegistry.Create;
    OpenCmd := Reg.ReadString('MyApp\shell\open\command');
    Reg.Free;

  Opening a key eliminates the need to pass the entire key name
  on subsequent calls:

    Reg := TRegistry.Create;
    Reg.OpenKey('MyApp\shell');
    OpenCmd  := Reg.ReadString('open\command');
    PrintCmd := Reg.ReadString('print\command');
    Reg.Free;

  Notice that key names never start with '\'.

  Opening a key will also speed up access when writing keys to the
  registry or when enumerating subkeys. Calling Closekey will flush
  all changes to the registry.

  You can open a subkey of a currently open key, in which case the
  old key is closed.

  Methods

    CloseKey - Closes a previously opened key.
    OpenKey - Opens a key and stores it's handle in the CurrentKey
      property. The CurentPath property contains a string of the
      currently open key. Returns True if successful.
    CreateKey - Creates a key in the registry. Returns True
      if successfull.
    DeleteKey - Deletes a key from the registry. Returns True
      if successfull.
    EnumKey - Enumerates all subkeys of the current key one by
      one. You have to increase Index for each successive call.
      Returns True as long as subkeys are found.
    GetKeyNames - Enumerates all subkeys of the current key and
      fills a TStrings with all subkey names.
    HasSubKeys - Returns True if current key has subkeys.
    KeyExists - Returns True if the specified key exists.
    ReadString - Reads a string value.
    ReadInteger - Reads an integer value.
    ReadBool - Reads a boolean value.
    WriteString - Writes a string value.
    WriteInteger - Writes an integer value.
    WriteBool - Writes a boolean value.

  Properties

    RootKey - Defaults to HKEY_CLASSES_ROOT.
      Hack: Set RootKey to 0 to dive below HKEY_CLASSES_ROOT.
      There's quite some hidden information there. The regular
      data can be found under the ".classes" key.
    CurrentKey - Handle of the currently open key.
    CurrentPath - String of the currently open key. }

interface

uses Classes, SysUtils, ShellAPI;

type
  ERegistryException = class(Exception);

  TRegistry = class(TObject)
  private
    { Private declarations }
    FRootKey: HKey;
    FCurrentKey: HKey;
    FCurrentPath: string;
  protected
    { Protected Declarations }
    function GetBaseKey: HKey;
  public
    { Public Declarations }
    constructor Create;
    destructor Destroy; override;
    procedure CloseKey;
    function OpenKey(const Key: string; CanCreate: Boolean): Boolean;
    function CreateKey(const Key: string): Boolean;
    function DeleteKey(const Key: string): Boolean;
    function EnumKey(const Index: Longint; var SubKey: string): Boolean;
    procedure GetKeyNames(Strings: TStrings);
    function HasSubKeys: Boolean;
    function KeyExists(const Key: string): Boolean;
    function ReadString(const Key: string): string;
    function ReadInteger(const Key: string): Integer;
    function ReadBool(const Key: string): Boolean;
    procedure WriteString(const Key, Value: string);
    procedure WriteInteger(const Key: string; Value: Integer);
    procedure WriteBool(const Key: string; Value: Boolean);
    property RootKey: HKey read FRootKey write FRootKey;
    property CurrentKey: HKey read FCurrentKey;
    property CurrentPath: string read FCurrentPath;
  end;

implementation

const
  SRegCreateError = 'Failed to create key %s';
  SRegWriteError  = 'Failed to write data to %s';

constructor TRegistry.Create;
begin
  FRootKey := HKEY_CLASSES_ROOT;
  FCurrentKey := 0;
  FCurrentPath := '';
end;

destructor TRegistry.Destroy;
begin
  CloseKey;
  inherited Destroy;
end;

procedure TRegistry.CloseKey;
begin
  if CurrentKey <> 0 then
  begin
    RegCloseKey(CurrentKey);
    FCurrentKey := 0;
    FCurrentPath := '';
  end;
end;

function TRegistry.GetBaseKey: HKey;
begin
  if CurrentKey <> 0 then Result := CurrentKey
  else Result := RootKey;
end;

function TRegistry.OpenKey(const Key: string; CanCreate: Boolean): Boolean;
var
  TempKey: HKey;
  CKey: array[0..255] of Char;
  S: string;
begin
  Result := RegOpenKey(GetBaseKey, StrPCopy(CKey, Key), TempKey)
    = ERROR_SUCCESS;
  if not Result and CanCreate and (Key > '') then
    Result := RegCreateKey(GetBaseKey, StrPCopy(CKey, Key), TempKey)
      = ERROR_SUCCESS;
  if Result then
  begin
    S := Key;
    if CurrentKey <> 0 then Insert(CurrentPath + '\', S, 1);
    { Close the current key, then store the key we just opened }
    CloseKey;
    FCurrentKey := TempKey;
    FCurrentPath := S;
  end;
end;

function TRegistry.CreateKey(const Key: string): Boolean;
var
  TempKey: HKey;
  CKey: array[0..255] of Char;
begin
  Result := RegCreateKey(GetBaseKey, StrPCopy(CKey, Key), TempKey)
    = ERROR_SUCCESS;
  if Result then RegCloseKey(TempKey)
  else raise ERegistryException.CreateFmt(SRegCreateError, [Key]);
end;

function TRegistry.DeleteKey(const Key: string): Boolean;
var
  CKey: array[0..255] of Char;
begin
  Result := RegDeleteKey(GetBaseKey, StrPCopy(CKey, Key)) = ERROR_SUCCESS;
end;

function TRegistry.EnumKey(const Index: Longint; var SubKey: string): Boolean;
var
  CSubKey: array[0..255] of Char;
begin
  SubKey := '';
  Result := RegEnumKey(GetBaseKey, Index, CSubKey, SizeOf(CSubKey) - 1)
    = ERROR_SUCCESS;
  if Result then SubKey := StrPas(CSubKey);
end;

procedure TRegistry.GetKeyNames(Strings: TStrings);
var
  I: Integer;
  S: string;
begin
  I := 0;
  while EnumKey(I, S) do
  begin
    Strings.Add(S);
    Inc(I);
  end;
end;

function TRegistry.HasSubKeys: Boolean;
var
  S: string;
begin
  Result := EnumKey(0, S);
end;

function TRegistry.KeyExists(const Key: string): Boolean;
var
  TempKey: HKey;
  CKey: array[0..255] of Char;
begin
  Result := RegOpenKey(GetBaseKey, StrPCopy(CKey, Key), TempKey)
    = ERROR_SUCCESS;
  if Result then RegCloseKey(TempKey);
end;

function TRegistry.ReadString(const Key: string): string;
var
  CKey, CValue: array[0..255] of Char;
  BufSize: Longint;
begin
  Result := '';
  BufSize := SizeOf(CValue) - 1;
  if RegQueryValue(GetBaseKey, StrPCopy(CKey, Key), CValue, BufSize)
    = ERROR_SUCCESS then Result := StrPas(CValue);
end;

function TRegistry.ReadInteger(const Key: string): Integer;
var
  IntStr: string;
begin
  IntStr := ReadString(Key);
  if CompareText(Copy(IntStr, 1, 2), '0x') = 0 then
    IntStr := '$' + Copy(IntStr, 3, 255);
  Result := StrToIntDef(IntStr, 0);
end;

function TRegistry.ReadBool(const Key: string): Boolean;
begin
  Result := ReadInteger(Key) <> 0;
end;

procedure TRegistry.WriteString(const Key, Value: string);
var
  CKey, CValue: array[0..255] of Char;
begin
  if RegSetValue(GetBaseKey, StrPCopy(CKey, Key), REG_SZ,
    StrPCopy(CValue, Value), Length(Value) + 1) <> ERROR_SUCCESS then
      raise ERegistryException.CreateFmt(SRegWriteError, [Key]);
end;

procedure TRegistry.WriteInteger(const Key: string; Value: Integer);
begin
  WriteString(Key, IntToStr(Value));
end;

procedure TRegistry.WriteBool(const Key: string; Value: Boolean);
const
  Values: array[Boolean] of string[1] = ('0', '1');
begin
  WriteString(Key, Values[Value]);
end;

end.

