{*********************************************************}
{                                                         }
{    Calmira System library 3.3                           }
{    by Li-Hsin Huang & Erwin Dokter                      }
{    released into the public domain may 2002             }
{                                                         }
{*********************************************************}

unit DropClnt;

{ Allows Delphi programs to accept file drops from File Manager.
  Another ubiquitous component, but I couldn't find a freeware one
  with source code so I wrote my own.  Since I already had a handler
  for Application.OnMessage, I decided against low level subclassing.
  Consequently, you'll need to call TDropClient.CheckMessage inside
  the OnMessage handler.

  Files: TStrings; (inherited, run-time only)
    Contains a list of dropped files after another program has
    dropped them.  This list is cleared before each drop if the
    AutoClear property is True.

  AutoClear: Boolean (inherited)
    Determines whether to clear the Files list before a drop.

  Handle: HWND (read and run-time only)
    The window handle of the owning windowed control

  DropPos: TPoint (read and run-time only)
    The coordinates of the last drop, in the coordinate system
    of the owning windowed control (usually a TForm)

  OnDropFiles
    When this event occurs, the Files property contains a list of
    dropped files and DropPos contains the coordinates of the cursor
    when the drop occured.

  CheckMessage(var Msg: TMsg; var Handled: Boolean);
    You need to call this message in the application's OnMessage handler.
    It checks an application message record to see if it is a file drop
    message.  If so, the corresponding DropClient component is activated
    to trigger the OnDropFiles event which you can handle.
    Handled is set to True if the message has been processed. }

interface

uses SysUtils, WinTypes, WinProcs, Messages, Classes, Controls, Forms,
  Dialogs, DragDrop;

type
  TDropClient = class(TDragDrop)
  private
    { Private declarations }
    FDropPos: TPoint;
    FOnDropFiles: TNotifyEvent;
    FHandle: HWND;
  protected
    { Protected declarations }
    procedure Loaded; override;
    procedure ExtractFiles(Drop: THandle);
  public
    { Public declarations }
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    class procedure CheckMessage(var Msg: TMsg; var Handled: Boolean);
    property DropPos: TPoint read FDropPos;
  published
    { Published declarations }
    property OnDropFiles: TNotifyEvent read FOnDropFiles write FOnDropFiles;
    property Handle: HWND read FHandle;
  end;

procedure Register;

implementation

uses ShellAPI;

var
  Clients: TList;

constructor TDropClient.Create(AOwner: TComponent);
begin
  if not (AOwner is TWinControl) then
    raise EInvalidOperation.Create('Invalid TDropClient owner, must be owned by a windowed control');
  inherited Create(AOwner);
  Clients.Add(self);
end;

destructor TDropClient.Destroy;
begin
  Clients.Remove(self);
  inherited Destroy;
end;

procedure TDropClient.ExtractFiles(drop: THandle);
var
  fcount: Integer;
  s: array[0..127] of Char;
  i: Integer;
begin
  if AutoClear then Files.Clear;
  fcount := DragQueryFile(drop, $FFFF, @s, 127);
  for i := 0 to fcount - 1 do
  begin
    DragQueryFile(drop, i, @s, 127);
    Files.Add(Lowercase(StrPas(@s)));
  end;
  DragQueryPoint(drop, FDropPos);
  DragFinish(drop);
  if Assigned(FOnDropFiles) then FOnDropFiles(self);
end;

procedure TDropClient.Loaded;
begin
  inherited Loaded;
  FHandle := (Owner as TWinControl).Handle;
  DragAcceptFiles(FHandle, True);
end;

class procedure TDropClient.CheckMessage(var Msg: TMsg; var Handled: Boolean);
var
  L: PPointerList;
  i: Integer;
begin
  if Msg.Message = WM_DROPFILES then
  begin
    L := Clients.List;
    for i := 0 to Clients.Count-1 do
      with TDropClient(L^[i]) do if Handle = Msg.HWnd then
      begin
        try
          ExtractFiles(Msg.wParam);
        except
          on E: Exception do Application.HandleException(E);
        end;
        Handled := True;
        Exit;
      end;
  end;
end;

procedure Register;
begin
  RegisterComponents('Calmira', [TDropClient]);
end;

procedure Done; far;
begin
  Clients.Free;
end;

initialization
  Clients := TList.Create;
  AddExitProc(Done);
end.

