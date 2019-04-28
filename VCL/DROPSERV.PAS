{*********************************************************}
{                                                         }
{    Calmira System library 3.3                           }
{    by Li-Hsin Huang & Erwin Dokter                      }
{    released into the public domain may 2002             }
{                                                         }
{*********************************************************}

unit DropServ;

{ If you ever need to drop files into other programs, this component
  can lend a hand, although it still requires some programming on your
  part.  In a control's OnMouseMove handler, call CanDrop to determine
  if if the cursor is over a suitable window.  In the OnEndDrag handler,
  call the DragFinished method.  If a drop is allowed, the OnFileDrop
  event is triggered which lets you assign the files to drop.

  AutoClear: Boolean; (inherited)
    If this is True, then the Files property is cleared after each
    drop is completed.

  Files: TStrings; (run-time only)
    Contains a list of files to drop into another program

  InternalDrop: Boolean;
    If this is set to True, OnFileDrag events will occur when the
    cursor is over a valid window belonging to your program.  If it is
    False, OnFileDrag only occurs when the cursor is over another program.
    Generally, you should use Delphi's own drag and drop handling and set
    this to False.

  DesktopDrop: Boolean;
    If this is set to True, you will receive an OnDesktopDrop event when
    the mouse is released over the desktop background or wallpaper.

  function CanDrop: Boolean;
    Returns True if the cursor is over something that can accept drops.
    Call this inside an OnMouseMove handler.  If the cursor is currently
    over a window, the call will trigger the OnFileDrag event to ask you
    for confirmation of the drop.

  procedure DragFinished;
    Call this inside an OnEndDrag handler.  If the cursor is over a
    suitable window and you have responded to the OnFileDrag event,
    then an OnFileDrop is triggered to let you assign the filenames.

  procedure DropFiles(Wnd: HWnd; AMousePos: TPoint);
    Encapsulates the WM_DROPFILES message and immediately causes a
    drop into the given window.  The strings in the Files property are
    contatenated into the required structure and a WM_DROPFILES message
    is sent to the given window.  The TPoint parameter lets you control
    the location of this forced drop.

  DropWindow: HWND; (read and run-tim only)
    Query this after calling CanDrop to find out which window or
    control is being dragged over.  Usefull for changing cursor.

  OnFileDrag
    Occurs when you call CanDrop and the cursor is over a window that
    accepts dropped files.  To permit the drop (if the user releases the
    mouse button), set the Accept property to True.  The Target parameter
    contains the handle of the window in question, and lets you perform
    your own tests before accepting.

  OnFileDrop
    Occurs when the user releases the mouse button over a window that
    accepts files and you call DragFinished method.  During this event,
    you must fill the Files property with the files you wish to drop
    (one file per line).  The drop takes place as soon as your handler
    finishes executing.

  OnDesktopDrop
    Occurs when the user releases the mouse button over the desktop.
    This is only a notification - TDropServer doesn't do anything
    afterwards.  The Target parameter contains the window handle of
    the desktop, in case you want to send any messages to it. }

interface

uses SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  Forms, Dialogs, DragDrop;

type
  TFileDragEvent = procedure (Sender: TObject; X, Y: Integer;
    Target: HWND; var Accept: Boolean) of object;

  TFileDropEvent = procedure (Sender: TObject; X, Y: Integer;
    Target: HWND) of object;

  TDropServerError = class(Exception);

  TDropServer = class(TDragDrop)
  private
    { Private declarations }
    DropPoint: TPoint;
    AllowDrop: Boolean;
    FInternalDrop: Boolean;
    FDesktopDrop: Boolean;
    FDropWindow: HWND;
    FOnFileDrag: TFileDragEvent;
    FOnFileDrop: TFileDropEvent;
    FOnDeskDrop: TFileDropEvent;
  protected
    { Protected declarations }
  public
    { Public declarations }
    procedure DropFiles(Wnd: HWnd; AMousePos: TPoint);
    function CanDrop: Boolean;
    procedure DragFinished;
  published
    { Published declarations }
    property InternalDrop: Boolean read FInternalDrop write FInternalDrop default False;
    property DesktopDrop: Boolean read FDesktopDrop write FDesktopDrop default False;
    property DropWindow: HWND read FDropWindow; { 3.11 }
    property OnFileDrag: TFileDragEvent read FOnFileDrag write FOnFileDrag;
    property OnFileDrop: TFileDropEvent read FOnFileDrop write FOnFileDrop;
    property OnDeskDrop: TFileDropEvent read FOnDeskDrop write FOnDeskDrop;
  end;

procedure Register;

implementation

type
  { Windows expects a WM_DROPFILES message to contain a memory
    handle with this structure as a header }
  PDropFileRec = ^TDropFileRec;
  TDropFileRec = record
    Size: Word;
    MousePos: TPoint;
    InNonClientArea: Boolean;
  end;

procedure TDropServer.DropFiles(Wnd: HWnd; AMousePos: TPoint);
var
  H: THandle;
  p: PDropFileRec;
  data: PChar;
  size: Word;
  i, count: Integer;
begin
  if Assigned(FOnFileDrop) then
    FOnFileDrop(self, AMousePos.x, AMousePos.y, Wnd);
  if Files.Count = 0 then Exit;
  { Thanks to Brian Andersen for this procedure's algorithm (it doesn't
    seem to be documented by Microsoft) }
  if GetWindowLong(Wnd, GWL_EXSTYLE) and WS_EX_ACCEPTFILES = 0 then
    Wnd := GetWindowWord(Wnd, GWW_HWNDPARENT);
  if GetWindowLong(Wnd, GWL_EXSTYLE) and WS_EX_ACCEPTFILES = 0 then
    raise TDropServerError.Create('This windows does not accept dropped files');
  WinProcs.ScreenToClient(Wnd, AMousePos);
  { Find the size of the buffer needed to hold the filenames }
  size := SizeOf(TDropFileRec) + 1;
  count := 0;
  while (size < 65276) and (count < Files.Count) do
  begin
    Inc(size, Length(Files[count]) + 1);
    Inc(count);
  end;
  { Allocate the buffer }
  H := GlobalAlloc(GMEM_SHARE or GMEM_MOVEABLE or GMEM_ZEROINIT, size);
  if H = 0 then raise TDropServerError.Create('Unable to allocate file drop buffer');
  p := GlobalLock(H);
  { Initialize the header info }
  with p^ do begin
    Size := SizeOf(TDropFileRec);
    MousePos := AMousePos;
    InNonClientArea := SendMessage(Wnd, WM_NCHITTEST, 0, Longint(AMousePos)) <> HTCLIENT;
  end;
  { Append the filenames to the buffer after advancing the pointer
    beyond the header }
  data := PChar(p) + Sizeof(TDropFileRec);
  for i := 0 to count - 1 do
  begin
     StrPCopy(data, Uppercase(Files[i]));
     Inc(data, Length(Files[i]) + 1);
  end;
  GlobalUnlock(H);
  { Drop the files }
  PostMessage(Wnd, WM_DROPFILES, H, 0);
  if AutoClear then Files.Clear;
end;

function AcceptsFiles(Wnd: HWnd): Boolean;
begin
  Result := (GetWindowLong(Wnd, GWL_EXSTYLE) and WS_EX_ACCEPTFILES <> 0)
    or (GetWindowLong(GetWindowWord(Wnd, GWW_HWNDPARENT), GWL_EXSTYLE)
    and WS_EX_ACCEPTFILES <> 0)
end;

function TDropServer.CanDrop: Boolean;
var
  p, q: TPoint;
begin
  GetCursorPos(p);
  AllowDrop := False;
  FDropWindow := WindowFromPoint(p);
  if ((FDropWindow = GetDesktopWindow) and DesktopDrop) then
  begin
    AllowDrop := True;
    DropPoint := p;
  end
  else if FDropWindow <> 0 then
  begin
    if (InternalDrop or (GetWindowTask(FDropWindow) <> GetCurrentTask)) and
      AcceptsFiles(FDropWindow) then
      begin
        AllowDrop := True;
        DropPoint := p;
        if Assigned(FOnFileDrag) then FOnFileDrag(self, p.x, p.y, FDropWindow, AllowDrop);
      end;
  end;
  Result := AllowDrop;
end;

procedure TDropServer.DragFinished;
begin
  if AllowDrop then
  begin
    if FDropWindow = GetDesktopWindow then
    begin
      if Assigned(FOnDeskDrop) then
        FOnDeskDrop(self, DropPoint.x, DropPoint.y, FDropWindow);
    end
    else DropFiles(FDropWindow, DropPoint);
  end;
  AllowDrop := False;
end;

procedure Register;
begin
  RegisterComponents('Calmira', [TDropServer]);
end;

end.

