{*********************************************************}
{                                                         }
{    Calmira System library 3.3                           }
{    by Li-Hsin Huang & Erwin Dokter                      }
{    released into the public domain may 2002             }
{                                                         }
{*********************************************************}

unit NetDlgs;

{ The following is a set of Delphi components to access (at least some of)
  the networking dialogs that are build into Windows for Workgroups.
  These components provide access to both network drives and printers.

  Original unit written by Steve Trefethen.

  'Calmira-ized' by Erwin Dokter, ie. un-needed code has been
  stripped, the remainder optimized and a few bugs have been fixed.
  This to keep code as small and efficient as possible. }

interface

uses WinTypes, WinProcs, Classes, Forms;

type
  { TNetShareDialog }
  TNetShareDialog = class(TComponent)
  private
    FPrinter: Boolean;
    FPathName: PChar;
    function GetPathName: String;
    procedure SetPathName(Value: String);
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    function Execute: Boolean; virtual; abstract;
  published
    property PathName: String read GetPathName write SetPathName;
    property Printer: Boolean read FPrinter write FPrinter;
  end;

  { TNetShareAsDialog }
  TNetShareAsDialog = class(TNetShareDialog)
  public
    function Execute: Boolean; virtual;
  end;

  { TNetStopShareDialog }
  TNetStopShareDialog = class(TNetShareDialog)
  public
    function Execute: Boolean;
  end;

  { TNetConnectDialog }
  TNetConnectDialog = class(TComponent)
  private
    FPrinter: Boolean;
  public
    function Execute: Boolean;
  published
    property Printer: Boolean read FPrinter write FPrinter;
  end;

  { TNetDisonnectDialog }
  TNetDisconnectDialog = class(TComponent)
  private
    FPrinter: Boolean;
  public
    function Execute: Boolean;
  published
    property Printer: Boolean read FPrinter write FPrinter;
  end;

var
  NetDriver: THandle;
  ShareAsDialog: function(hwndParent: HWnd; iType: Word; lpszPath: PChar): Word;
  StopShareDialog: function(hwndParent: HWnd; iType: Word; lpszPath: PChar): Word;
  ConnectDialog: function(hwndParent: HWnd; iType: Word): Word;
  DisconnectDialog: function(hwndParent: HWnd; iType: Word): Word;
  GetShareName: function(lpszPath: PChar; lpszBuf: PChar; cbBuf: Word): Word;

function IsShared(Path: string): Boolean;
procedure Register;

implementation

uses SysUtils;

const
  WN_SUCCESS      = 0;
  WN_TYPE_DRIVE   = 1;
  WN_TYPE_PRINTER = 3;
  WN_CANCEL       = 12;

  { If localizing this unit, only these strings need translating: }
  EDriverNotLoaded = 'There is no network driver installed.';
  ENotSupportedMsg = 'This operation is not supported by your network driver.';

function CheckNetDriver: THandle;
var
  WNetGetCaps: function(Flags: Word): Word;
begin
  Result := 0;
  @WNetGetCaps := GetProcAddress(GetModuleHandle('USER'), 'WNETGETCAPS');
  if @WNetGetCaps <> nil then
    { get the address of the network driver }
    Result := WNetGetCaps($FFFF);
end;

{ TNetShareDialog }

constructor TNetShareDialog.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FPathName := nil;
end;

destructor TNetShareDialog.Destroy;
begin
  StrDispose(FPathName);
  inherited Destroy;
end;

function TNetShareDialog.GetPathName: String;
begin
  if FPathName = nil then
    Result := ''
  else
    Result := StrPas(FPathName);
end;

procedure TNetShareDialog.SetPathName(Value: String);
begin
  if FPathName <> nil then
    StrDispose(FPathName);
  FPathName := StrAlloc(Length(Value) + 1);
  StrPCopy(FPathName, Value);
end;

{ TNetShareAsDialog }

function TNetShareAsDialog.Execute: Boolean;
begin
  Result := False;
  if NetDriver > 0 then
  try
    if Printer then
      Result := ShareAsDialog(TForm(Owner).Handle, WN_TYPE_PRINTER,
        FPathName) = WN_SUCCESS
    else
      Result := ShareAsDialog(TForm(Owner).Handle, WN_TYPE_DRIVE,
        FPathName) = WN_SUCCESS;
  except
    raise Exception.Create(ENotSupportedMsg);
  end
  else
    raise Exception.Create(EDriverNotLoaded);
end;

{ TNetStopShareDialog }

function TNetStopShareDialog.Execute: Boolean;
begin
  Result := False;
  if NetDriver > 0 then
  try
    if Printer then
      Result := StopShareDialog(TForm(Owner).Handle, WN_TYPE_PRINTER,
        FPathName) = WN_SUCCESS
    else
      Result := StopShareDialog(TForm(Owner).Handle, WN_TYPE_DRIVE,
        FPathName) = WN_SUCCESS;
  except
    raise Exception.Create(ENotSupportedMsg);
  end
  else
    raise Exception.Create(EDriverNotLoaded);
end;

{ TNetConnectDialog }

function TNetConnectDialog.Execute: Boolean;
begin
  Result := False;
  if NetDriver > 0 then
  try
    if Printer then
      Result := ConnectDialog(TForm(Owner).Handle, WN_TYPE_PRINTER) = WN_SUCCESS
    else
      Result := ConnectDialog(TForm(Owner).Handle, WN_TYPE_DRIVE) = WN_SUCCESS;
  except
    raise Exception.Create(ENotSupportedMsg);
  end
  else
    raise Exception.Create(EDriverNotLoaded);
end;

{ TNetDisconnectDialog }

function TNetDisconnectDialog.Execute: Boolean;
begin
  Result := False;
  if NetDriver > 0 then
  try
    if Printer then
      Result := DisconnectDialog(TForm(Owner).Handle, WN_TYPE_PRINTER) = WN_SUCCESS
    else
      Result := DisconnectDialog(TForm(Owner).Handle, WN_TYPE_DRIVE) = WN_SUCCESS;
  except
    raise Exception.Create(ENotSupportedMsg);
  end
  else
    raise Exception.Create(EDriverNotLoaded);
end;

{ Public functions }

function IsShared(Path: string): Boolean;
var
  buf: array[0..32] of Char;
  p: array[0..79] of Char;
begin
  Result := False;
  if (NetDriver > 0) and (@GetShareName <> nil) then
  begin
    GetShareName(StrPCopy(p, UpperCase(Path)), buf, 32);
    Result := StrPas(buf)[1] = '\';
  end;
end;

procedure Register;
begin
  RegisterComponents('Dialogs', [TNetShareAsDialog, TNetStopShareDialog,
    TNetConnectDialog, TNetDisconnectDialog]);
end;

initialization
  NetDriver := CheckNetDriver;
  if NetDriver > 0 then
  begin
    @ShareAsDialog := GetProcAddress(NetDriver, 'WNETSHAREASDIALOG');
    @StopShareDialog := GetProcAddress(NetDriver, 'WNETSTOPSHAREDIALOG');
    @ConnectDialog := GetProcAddress(NetDriver, 'WNETCONNECTDIALOG');
    @DisconnectDialog := GetProcAddress(NetDriver, 'WNETDISCONNECTDIALOG');
    @GetShareName := GetProcAddress(NetDriver, 'WNETGETSHARENAME');
  end;
end.

