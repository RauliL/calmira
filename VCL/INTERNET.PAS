{*********************************************************}
{                                                         }
{    Calmira System library 3.3                           }
{    by Li-Hsin Huang & Erwin Dokter                      }
{    released into the public domain may 2002             }
{                                                         }
{*********************************************************}

unit Internet;

{ This is a TDdeClientConv wrapper component, designed to
  talk to your browser in order to open URL's and capture
  it's current location. }

interface

uses Classes, DdeMan;

type
  TBrowserLink = class(TDdeClientConv)
  private
    { Private declarations }
    function BeginExchange(const NewTopic: string): Boolean;
    function ActivateBrowser: Boolean;
  protected
    { Protected declarations }
  public
    { Public declarations }
    constructor Create(AOwner: TComponent); override;
    procedure ReadServiceApplication;
    function OpenURL(const Url: string): Boolean;
    function IsBrowserLoaded: Boolean;
    function CaptureLocation(var Title, Url: OpenString): Boolean;
  end;

const
  URLPrefixes: string = 'http:// ftp:// gopher:// news: mailto: file:';

function IsURL(const s: string): Boolean;

procedure Register;

implementation

uses WinProcs, WinTypes, SysUtils, Strings, MiscUtil, Registry;

function IsURL(const s: string): Boolean;
var
  temp: string;
begin
  temp := URLPrefixes;
  Result := True;
  while temp > '' do
    if Pos(GetWord(temp, ' '), s) = 1 then Exit;
  Result := False;
end;

constructor TBrowserLink.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  ConnectMode := ddeManual;
  ReadServiceApplication;
end;

procedure TBrowserLink.ReadServiceApplication;
begin
  with TRegistry.Create do
  begin
    { 3.11 -- query registry for default browser }
    ServiceApplication :=
      ReadString(ReadString('.htm') + '\shell\open\ddeexec\Application');
    Free;
  end;
end;

function TBrowserLink.BeginExchange(const NewTopic: string): Boolean;
begin
  ShowHourGlass;
  SetLink(ExtractFilename(ServiceApplication), NewTopic);
  Result := OpenLink;
end;

function TBrowserLink.ActivateBrowser: Boolean;
begin
  Result := BeginExchange('WWW_Activate');
  if Result then
  try
    StrDispose(RequestData('0xFFFFFFFF,0x0'));
  finally
    CloseLink;
  end;
end;

function TBrowserLink.OpenURL(const Url: string): Boolean;
begin
  Result := ActivateBrowser and BeginExchange('WWW_OpenURL');
  if Result then
  try
    StrDispose(RequestData(Format('"%s",,0xFFFFFFFF,0x0,,,,', [Url])));
  finally
    CloseLink;
  end;
end;

var
  FoundModule: Boolean;

function FindBrowser(Wnd: HWnd; DDEModule: PChar): Bool; export;
var
  buf: array[0..127] of char;
begin
  GetModuleFilename(GetWindowWord(Wnd, GWW_HINSTANCE), buf, 127);
  FoundModule := StrPos(StrUpper(buf), StrUpper(DDEModule)) <> nil; { 3.11 }
  Result := not FoundModule;
end;

function TBrowserLink.IsBrowserLoaded: Boolean;
var
  buf: array[0..127] of Char;
begin
  FoundModule := False;
  StrPCopy(buf, ServiceApplication + '.EXE');
  EnumWindows(@FindBrowser, Longint(@buf));
  Result := FoundModule;
end;

function TBrowserLink.CaptureLocation(var Title, Url: OpenString): Boolean;
var
  Data: PChar;
  p: Integer;
begin
  Title := '';
  Url := '';
  Result := False;
  if not IsBrowserLoaded then Exit;
  Result := BeginExchange('WWW_GetWindowInfo');
  if Result then
  try
    Data := RequestData('0xFFFFFFFF');
    try
      Unformat(StrPas(Data), '"%s","%s"', [@Url, High(URL), @Title, High(Title)]);
      p := Pos('[', Title);
      if p > 0 then Title := Copy(Title, p + 1, Length(Title) - p - 1);
    finally
      StrDispose(Data);
    end;
  finally
    CloseLink;
  end;
end;

procedure Register;
begin
  RegisterComponents('Calmira', [TBrowserLink]);
end;

end.

