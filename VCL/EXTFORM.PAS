{*********************************************************}
{                                                         }
{    Calmira System library 3.3                           }
{    by Li-Hsin Huang & Erwin Dokter                      }
{    released into the public domain may 2002             }
{                                                         }
{*********************************************************}

unit ExtForm;

{ Defines TExtForm, which is a TForm with facilities for saving its
  size and position.  The additional property MinPosition allows the
  form to appear as an icon at a specified position (i.e., setting
  it also shows the form).

  3.1 -- Moved from CalForm: The StretchShift method adjusts the controls
  on a form when it is resized.  Call it from the OnResize handler.

  Finally, ShowNormal is provided to make it easier to display a
  window, whatever state it is in. }

interface

uses Forms, Classes, Controls, WinTypes, Messages, IniFiles;

type
  TStretchFlag = (stLeft, stTop, stWidth, stHeight);
  TStretchFlags = set of TStretchFlag;

type
  TExtForm = class(TForm)
  private
    FLastMinPosition: TPoint;
    FMinimumWidth: Integer;
    FMinimumHeight: Integer;
    OldClientWidth: Integer;
    OldClientHeight: Integer;
    SizeDelta: TPoint;
    function GetMinPosition: TPoint;
    procedure SetMinPosition(pt: TPoint);
    procedure WMGetMinMaxInfo(var Message: TWMGetMinMaxInfo); message WM_GETMINMAXINFO;
    procedure WMGetDlgCode(var Message: TWMGetDlgCode); message WM_GETDLGCODE;
  protected
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState;
      X, Y: Integer); override;
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
    procedure Loaded; override;
    procedure Resize; override;
  public
    procedure ShowNormal;
    procedure EnableControls(Enable: Boolean);
    procedure StretchShift(const C: array of TControl; Flags: TStretchFlags);
    procedure LoadMinPosition(ini: TIniFile; const section: string);
    procedure LoadPosition(ini: TIniFile; const section: string);
    procedure SavePosition(ini: TIniFile; const section: string);
    property MinimumWidth: Integer read FMinimumWidth write FMinimumWidth;
    property MinimumHeight: Integer read FMinimumHeight write FMinimumHeight;
    property MinPosition: TPoint read GetMinPosition write SetMinPosition;
    property LastMinPosition: TPoint read FLastMinPosition;
  end;

const
  { some magic numbers! }
  SC_SIZELEFT        = SC_SIZE + 1;
  SC_SIZERIGHT       = SC_SIZE + 2;
  SC_SIZETOP         = SC_SIZE + 3;
  SC_SIZETOPLEFT     = SC_SIZE + 4;
  SC_SIZETOPRIGHT    = SC_SIZE + 5;
  SC_SIZEBOTTOM      = SC_SIZE + 6;
  SC_SIZEBOTTOMLEFT  = SC_SIZE + 7;
  SC_SIZEBOTTOMRIGHT = SC_SIZE + 8;
  SC_DRAGMOVE        = SC_SIZE + 9;

implementation

uses WinProcs;

function TExtForm.GetMinPosition: TPoint;
var
  place: TWindowPlacement;
begin
  place.Length := SizeOf(place);
  GetWindowPlacement(Handle, @place);
  Result := place.ptMinPosition;
end;

procedure TExtForm.SetMinPosition(pt: TPoint);
var
  place: TWindowPlacement;
begin
  with Screen do
  begin
    if pt.x >= Width then pt.x := Width - 48;
    if pt.y >= Height then pt.y := Height - 48;
  end;
  if Visible then Invalidate;
  place.Length := SizeOf(place);
  GetWindowPlacement(Handle, @place);
  place.ptMinPosition := pt;
  place.Flags := place.Flags or WPF_SETMINPOSITION;
  place.ShowCmd := SW_SHOWMINNOACTIVE;
  SetWindowPlacement(Handle, @place);
  Visible := True;
  FLastMinPosition := pt;
end;

procedure TExtForm.WMGetMinMaxInfo(var Message: TWMGetMinMaxInfo);
begin
  inherited;
  with Message.MinMaxInfo^ do
  begin
    { 3.11 added ptMaxSize }
    if BorderStyle = bsSingle then
    begin
      ptMaxSize.X := Screen.Width + 2;
      ptMaxSize.Y := Screen.Height + 2;
    end;
    ptMinTrackSize.X := FMinimumWidth;
    ptMinTrackSize.Y := FMinimumHeight;
  end;
end;

procedure TExtForm.WMGetDlgCode(var Message: TWMGetDlgCode);
begin
  inherited;
  message.Result := DLGC_WANTTAB;
end;

procedure TExtForm.MouseDown(Button: TMouseButton; Shift: TShiftState;
  X, Y: Integer);
var
  Cmd: Word;
begin
  inherited MouseDown(Button, Shift, X, Y);
  if (WindowState <> wsNormal) or (Button = mbRight) then Exit;
  ReleaseCapture;
  if (x <= 16) and (y <= 16) then Cmd := SC_SIZETOPLEFT
  else if (x <= 16) and (y >= ClientHeight - 16) then Cmd := SC_SIZEBOTTOMLEFT
  else if (x >= ClientWidth - 16) and (y <= 16) then Cmd := SC_SIZETOPRIGHT
  else if (x >= ClientWidth - 16) and (y >= ClientHeight - 16) then Cmd := SC_SIZEBOTTOMRIGHT
  else if (x <= 4) then Cmd := SC_SIZELEFT
  else if (y <= 4) then Cmd := SC_SIZETOP
  else if (x >= ClientWidth - 4) then Cmd := SC_SIZERIGHT
  else if (y >= ClientHeight - 4) then Cmd := SC_SIZEBOTTOM
  else Cmd := 0;
  Perform(WM_SYSCOMMAND, Cmd, 0);
end;

procedure TExtForm.MouseMove(Shift: TShiftState; X, Y: Integer);
begin
  inherited MouseMove(Shift, X, Y);
  Cursor := crDefault;
  if WindowState <> wsNormal then Exit;
  if ((x <= 16) and (y <= 16)) or ((x >= ClientWidth - 16) and
    (y >= ClientHeight - 16)) then Cursor := crSizeNWSE
  else if ((x >= ClientWidth - 16) and (y <= 16)) or ((x <= 16) and
    (y >= ClientHeight - 16)) then Cursor := crSizeNESW
  else if (x <= 4) or (x >= ClientWidth - 4) then Cursor := crSizeWE
  else if (y <= 4) or (y >= ClientHeight - 4) then Cursor := crSizeNS;
end;

procedure TExtForm.Loaded;
begin
  inherited Loaded;
  FMinimumWidth := Width;
  FMinimumHeight := Height;
  OldClientWidth := ClientWidth;
  OldClientHeight := ClientHeight;
end;

procedure TExtForm.Resize;
begin
  if WindowState <> wsMinimized { 3.0 } then
  begin
    SizeDelta.X := ClientWidth - OldClientWidth;
    SizeDelta.Y := ClientHeight - OldClientHeight;
    OldClientWidth := ClientWidth;
    OldClientHeight := ClientHeight;
  end;
  inherited Resize;
end;

procedure TExtForm.ShowNormal;
begin
  WindowState := wsNormal;
  Show;
end;

procedure TExtForm.EnableControls(Enable: Boolean);
var
  i: Integer;
begin
  for i := 0 to ControlCount - 1 do Controls[i].Enabled := Enable;
end;

procedure TExtForm.StretchShift(const C: array of TControl;
  Flags: TStretchFlags);
var
  i, L, T, W, H: Integer;
begin
  for i := 0 to High(C) do with C[i] do
  begin
    L := Left;
    T := Top;
    W := Width;
    H := Height;
    if stLeft in Flags then Inc(L, SizeDelta.x);
    if stTop in Flags then Inc(T, SizeDelta.y);
    if stWidth in Flags then Inc(W, SizeDelta.x);
    if stHeight in Flags then Inc(H, SizeDelta.y);
    SetBounds(L, T, W, H);
  end;
end;

procedure TExtForm.LoadMinPosition(ini: TIniFile; const section: string);
begin
  MinPosition := Point(ini.ReadInteger(section, 'MinLeft', 128),
    ini.ReadInteger(section, 'MinTop', 128));
end;

procedure TExtForm.LoadPosition(ini: TIniFile; const section: string);
begin
  with ini do SetBounds(
    ReadInteger(section, 'Left', Left),
    ReadInteger(section, 'Top', Top),
    ReadInteger(section, 'Width', Width),
    ReadInteger(section, 'Height', Height));
end;

procedure TExtForm.SavePosition(ini: TIniFile; const section: string);
begin
  with ini do
  begin
    WriteInteger(section, 'Left', Left);
    WriteInteger(section, 'Top', Top);
    WriteInteger(section, 'Width', Width);
    WriteInteger(section, 'Height', Height);
    with MinPosition do
    begin
      WriteInteger(section, 'MinLeft', X);
      WriteInteger(section, 'MinTop', Y);
    end;
  end;
end;

end.

