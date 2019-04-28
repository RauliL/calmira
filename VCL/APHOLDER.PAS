{*********************************************************}
{                                                         }
{    Calmira System library 3.3                           }
{    by Li-Hsin Huang & Erwin Dokter                      }
{    released into the public domain may 2002             }
{                                                         }
{*********************************************************}

unit ApHolder;

{ TAppHolder is a simple container component that provides design-time
  access to TApplication's properties and events.  When the component
  is loaded, it assigns its data to TApplication.

  You can use it to automatically create event handlers for TApplication
  and TScreen just like events for visual controls -- just double click
  on the event.

  In addition, there is the OnWndProc event which is, in effect, a fast
  way to subclass the application's main window without going down to the
  API level.  If you create an OnWndProc event, this is triggered each
  time the application's WndProc is called, and you can process messages
  that never generate an OnMessage event because they are sent directly
  to the window procedure.

  For this event, return False to allow TApplication to continue processing
  the message, and True to stop TApplication handling it further.  It is
  especially useful to trap WM_ENDSESSION here so that your program can
  save its layout etc. before Windows shuts down. }

interface

uses SysUtils, WinTypes, WinProcs, Classes, Graphics, Controls, Forms;

type
  TAppHolder = class(TComponent)
  private
    { Private declarations }
    FHelpFile: string;
    FHint: string;
    FHintColor: TColor;
    FHintPause: Integer;
    FTitle: string;
    FOnActivate: TNotifyEvent;
    FOnDeactivate: TNotifyEvent;
    FOnException: TExceptionEvent;
    FOnHelp: THelpEvent;
    FOnHint: TNotifyEvent;
    FOnIdle: TIdleEvent;
    FOnMessage: TMessageEvent;
    FOnMinimize: TNotifyEvent;
    FOnRestore: TNotifyEvent;
    FOnShowHint: TShowHintEvent;
    FOnWndProc: TWindowHook;
    FOnActiveControlChange: TNotifyEvent;
    FOnActiveFormChange: TNotifyEvent;
  protected
    { Protected declarations }
    procedure Loaded; override;
  public
    { Public declarations }
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  published
    { Published declarations }
    property HelpFile: string read FHelpfile write FHelpFile;
    property Hint: string read FHint write FHint;
    property HintColor: TColor read FHintColor write FHintColor;
    property HintPause: Integer read FHintPause write FHintPause default 800;
    property Title: string read FTitle write FTitle;
    property OnActivate: TNotifyEvent read FOnActivate write FOnActivate;
    property OnDeactivate: TNotifyEvent read FOnDeactivate write FOnDeactivate;
    property OnException: TExceptionEvent read FOnException write FOnException;
    property OnHelp: THelpEvent read FOnHelp write FOnHelp;
    property OnHint: TNotifyEvent read FOnHint write FOnHint;
    property OnIdle: TIdleEvent read FOnIdle write FOnIdle;
    property OnMessage: TMessageEvent read FOnMessage write FOnMessage;
    property OnMinimize: TNotifyEvent read FOnMinimize write FOnMinimize;
    property OnRestore: TNotifyEvent read FOnRestore write FOnRestore;
    property OnShowHint: TShowHintEvent read FOnShowHint write FOnShowHint;
    property OnWndProc: TWindowHook read FOnWndProc write FOnWndProc;
    property OnActiveControlChange: TNotifyEvent read
      FOnActiveControlChange write FOnActiveControlChange;
    property OnActiveFormChange: TNotifyEvent read
      FOnActiveFormChange write FOnActiveFormChange;
  end;

procedure Register;

implementation

constructor TAppHolder.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FHintColor := $00C0FFFF;
  FHintPause := 800;
end;

destructor TAppHolder.Destroy;
begin
  if not (csDesigning in ComponentState) then begin
    with Application do
    begin
      OnActivate := nil;
      OnDeactivate := nil;
      OnException := nil;
      OnHelp := nil;
      OnHint := nil;
      OnIdle := nil;
      OnMessage := nil;
      OnMinimize := nil;
      OnRestore := nil;
      OnShowHint := nil;
      if Assigned(FOnWndProc) then UnHookMainWindow(FOnWndProc);
    end;
    with Screen do
    begin
      OnActiveControlChange := nil;
      OnActiveFormChange := nil;
    end;
  end;
  inherited Destroy;
end;

procedure TAppHolder.Loaded;
begin
  if not (csDesigning in ComponentState) then
  with Application do
  begin
    if FHelpFile > '' then HelpFile := ExtractFilePath(ExeName) + FHelpFile;
    if FHint > '' then Hint := FHint;
    HintColor := FHintColor;
    HintPause := FHintPause;
    if FTitle > '' then Title := FTitle;
    OnActivate := FOnActivate;
    OnDeactivate := FOnDeactivate;
    OnException := FOnException;
    OnHelp := FOnHelp;
    OnHint := FOnHint;
    OnIdle := FOnIdle;
    OnMessage := FOnMessage;
    OnMinimize := FOnMinimize;
    OnRestore := FOnRestore;
    OnShowHint := FOnShowHint;
    if Assigned(FOnWndProc) then HookMainWindow(FOnWndProc);
  end;
  with Screen do
  begin
    OnActiveControlChange := FOnActiveControlChange;
    OnActiveFormChange := FOnActiveFormChange;
  end;
end;

procedure Register;
begin
  RegisterComponents('Calmira', [TAppHolder]);
end;

end.

