{*********************************************************}
{                                                         }
{    Calmira System library 3.3                           }
{    by Li-Hsin Huang & Erwin Dokter                      }
{    released into the public domain may 2002             }
{                                                         }
{*********************************************************}

unit TabPanel;

{ Windows 95 style Tab Control

  Use this component in conjuction with a TNoteBook to create a
  'property sheet' style page control. Place the notebook ON the
  tabpanel and set Align to alClient. Adding pages to the notebook,
  will automatically add the new pages to the tabpanel.

  Synchronize the controls in the tabpanel's OnChange Event:

    NoteBook.PageIndex := TabPanel.TabIndex;

  You can also put page initialization code in this event. Query
  the NewTab parameter to find out which page has been opened.

  To make the TabPanel respond to Ctrl-Tab, set the form's KeyPreview
  property to True and put the following code in the form's OnKeyDown
  event:

    if (Key = VK_TAB) and (ssCtrl in Shift) then
      TabPanel.SelectNext(not (ssShift in Shift));
  }

interface

uses SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  Forms, Dialogs, ExtCtrls, Tabs;

type
  TTabPanel = class(TCustomPanel)
  private
    { Private declarations }
    FTabs: TStrings;
    FTabHeight: Integer; { 3.11 }
    FTabIndex: Integer;
    FOnChange: TTabChangeEvent;
    FOnClick: TNotifyEvent;
    FNotebook: TNotebook;
    ChangingPage: Boolean;
    procedure SetTabs(Value: TStrings);
    procedure SetTabHeight(Value: Integer);
    procedure SetTabIndex(Value: Integer);
    procedure SetNotebook(Value: TNotebook);
    procedure HandlePageChange(Sender: TObject);
    procedure FreeHandlesOnPage(n: Integer);
    procedure InvalidateTabs;
    procedure CMFocusChanged(var Message: TCMFocusChanged); message CM_FOCUSCHANGED;
    procedure WMGetDlgCode(var Message: TWMGetDlgCode); message WM_GETDLGCODE;
  protected
    { Protected declarations }
    procedure Paint; override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure KeyDown(var Key: Word; Shift: TShiftState); override;
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
    function GetClientRect: TRect; override;
  public
    { Public declarations }
    constructor Create(Aowner: TComponent); override;
    destructor Destroy; override;
    procedure SelectNext(Direction: Boolean); { 3.11 }
  published
    { Published declarations }
    property Tabs: TStrings read FTabs write SetTabs;
    property TabHeight: Integer read FTabHeight write SetTabHeight;
    property TabIndex: Integer read FTabIndex write SetTabIndex;
    property Notebook: TNotebook read FNotebook write SetNotebook;
    property OnChange: TTabChangeEvent read FOnChange write FOnChange;
    property OnClick;
    property Align;
    property Color;
    property Enabled;
    property Font;
    property Hint;
    property ParentColor;
    property ParentFont;
    property ParentShowHint;
    property ShowHint;
    property TabOrder;
    property TabStop;
    property Visible;
  end;

procedure Register;

implementation

constructor TTabPanel.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
 {Font.Name := 'MS Sans Serif';
  Font.Size := 8;
  Font.Style := [];}
  ControlStyle := ControlStyle + [csDesignInteractive, csOpaque];
  FTabs := TStringList.Create;
  FTabs.Add('General');
  FTabHeight := 20;
end;

destructor TTabPanel.Destroy;
begin
  FTabs.Free;
  inherited Destroy;
end;

procedure TTabPanel.SetTabs(Value: TStrings);
begin
  FTabs.Assign(Value);
  Invalidate;
end;

procedure TTabPanel.SetTabHeight(Value: Integer);
var
  rect: TRect;
begin
  FTabHeight := Value;
  rect := GetClientRect;
  if (FNotebook <> nil) and (FNotebook.Align = alClient) then
    FNotebook.SetBounds(rect.Left, rect.Top,
      rect.Right - rect.Left, rect.Bottom - Rect.Top);
  Invalidate;
end;

procedure TTabPanel.SetTabIndex(Value: Integer);
var
  SilentChange: Boolean;
  Previous: Integer;
  Allow: Boolean;
begin
  if (Value >= 0) and (Value < FTabs.Count) and (Value <> FTabIndex) then
  begin
    Previous := FTabIndex;
    SilentChange := (csReading in ComponentState) or (csDestroying in ComponentState);
    if not SilentChange then
    begin
      if Assigned(FOnChange) then
      begin
        Allow := true;
        FOnChange(Self, Value, Allow);
        if not Allow then Exit;
      end;
    end;
    FTabIndex := Value;
    InvalidateTabs;
    if FNotebook <> nil then
    begin
      { blocks recursive calls to HandlePageChange }
      ChangingPage := True;
      FNotebook.PageIndex := TabIndex;
      ChangingPage := False;
    end;
    if not SilentChange then FreeHandlesOnPage(previous);
  end;
end;

procedure TTabPanel.SetNotebook(Value: TNotebook);
begin
  if (Value = nil) and (FNoteBook <> nil) then
    FNotebook.OnPageChanged := nil;
  FNotebook := Value;
  if (FNotebook <> nil) then
  begin
    Tabs := FNotebook.Pages;
    TabIndex := FNotebook.PageIndex;
    FNotebook.OnPageChanged := HandlePageChange;
  end;
end;

procedure TTabPanel.HandlePageChange(Sender: TObject);
var
  i: Integer;
begin
  if not ChangingPage then
  begin
    if (FNotebook.Pages.Count <> FTabs.Count) then
      FTabs.Assign(FNotebook.Pages);
    i := FNotebook.PageIndex;
    if (i >= 0) and (i < FTabs.Count) then
    begin
      FTabIndex := i;
      Invalidate;
    end;
  end;
end;

type
  TSurfaceWin = class(TWinControl);

procedure TTabPanel.FreeHandlesOnPage(n: Integer);
begin
  if (Notebook <> nil) and not (csDesigning in ComponentState) and
    (n >= 0) and (n < Notebook.Pages.Count) then
    begin
      { DestroyHandle introduces a small delay.  Calling Update first will
        repaint the tabbed notebook and hide the delay from the user }
      Update;
      TSurfaceWin(Notebook.Pages.Objects[n]).DestroyHandle;
    end;
end;

procedure TTabPanel.InvalidateTabs;
var
  R: TRect;
begin
  R := Rect(0, 0, Width, FtabHeight + 1);
  InvalidateRect(Handle, @R, false);
end;

procedure TTabPanel.CMFocusChanged(var Message: TCMFocusChanged);
begin
  inherited;
  InvalidateTabs;
end;

procedure TTabPanel.WMGetDlgCode(var message: TWMGetDlgCode);
begin
  inherited;
  message.Result := DLGC_WANTARROWS;
end;

procedure TTabPanel.Notification(AComponent: TComponent; Operation: TOperation);
begin
  inherited Notification(AComponent, Operation);
  if (AComponent = FNotebook) and (Operation = opRemove) then
    SetNotebook(nil);
end;

function TTabPanel.GetClientRect: TRect;
begin
  { Exclude the tabbed area }
  Result := Rect(0, FtabHeight, Width - 1, Height - 1);
end;

procedure TTabPanel.Paint;
var
  buffer: TBitmap;

procedure PaintShadowEdge(i, e: Integer; big: boolean);
begin
  with buffer.Canvas do if big then
  begin
    Pen.Color := clWindowFrame;
    MoveTo(e + 1, 2);
    LineTo(e + 1, FtabHeight);
    Pixels[e, 1] := Pen.Color;
    Pen.Color := clBtnShadow;
    MoveTo(e, 2);
    LineTo(e, FtabHeight + 1);
  end
  else
  begin
    Pen.Color := clWindowFrame;
    MoveTo(e - 1, 4);
    LineTo(e - 1, FTabHeight);
    Pixels[e - 2, 3] := Pen.Color;
    Pen.Color := clBtnShadow;
    MoveTo(e - 2, 4);
    LineTo(e - 2, FTabHeight);
  end;
end;

procedure PaintEdge(i, e: Integer);
begin
  with buffer.Canvas do if (i = TabIndex) then
  begin
    Pen.Color := clBtnHighlight;
    MoveTo(e, 2);
    LineTo(e, FTabHeight);
    Pixels[e + 1, 1] := Pen.Color;
  end
  else
  begin
    if (i = TabIndex + 1) then
      PaintShadowEdge(i, e, true)
    else
    begin
      Pen.Color := clBtnHighlight;
      MoveTo(e, 4);
      LineTo(e, FTabHeight);
      Pixels[e + 1, 3] := Pen.Color;
      if (i > 0) then PaintShadowEdge(i, e, false);
    end
  end
end;

var
  x1, x2, y, w, h, i, tx, ty: Integer;
  s: string;

begin {TTabPanel.Paint}
  buffer := TBitmap.Create;
  buffer.Width := Width;
  buffer.Height := FTabHeight + 1;
  try
    with Canvas do
    begin
      Brush.Style := bsSolid;
      Brush.Color := Color;
      FillRect(Rect(0, FTabHeight + 1, Width - 2, Height - 2));
      { top left highlight }
      Pen.Color := clBtnHighlight;
      MoveTo(0, FTabHeight);
      LineTo(0, Height - 1);
      { bottom right shadow }
      Pen.Color := clBtnShadow;
      MoveTo(1, Height - 2);
      LineTo(Width - 2, Height - 2);
      LineTo(Width - 2, FTabHeight);
      { bottom right edge }
      Pen.Color := clWindowFrame;
      MoveTo(Width - 1, FTabHeight);
      LineTo(Width - 1, Height - 1);
      LineTo(-1, Height - 1);
    end;
    with Buffer.Canvas do
    begin
      Brush.Style := bsSolid;
      Brush.Color := Color;
      FillRect(Rect(0, 0, Width, FTabHeight + 1));
      { Change the font here because TextWidth needs it very soon }
      Font.Assign(Self.Font);
    end;
    { This bit is quite tricky.
      x1 is the approximate left edge of the current tab
      x2 is the approximate right edge
      At the end of each iteration, x1 is assigned to x2, so the tabs
      move across the control. }
    x1 := 2;
    for i := 0 to Tabs.Count - 1 do
    begin
      s := Tabs[i];
      w := buffer.Canvas.TextWidth(s);
      h := buffer.Canvas.TextHeight(s);
      x2 := x1 + w + 12;
      if (i = TabIndex) then y := 0
      else y := 2;
      with buffer.Canvas do
      begin
        Brush.Style := bsClear;
        tx := x1 - 1 + (x2 - x1 - w) div 2;
        ty := y + 3;
        TextOut(tx, ty, s);
        if (i = TabIndex) and Focused then
          DrawFocusRect(Bounds(tx - 4, ty, w + 9, h + 2));
        Pen.Color := clBtnHighlight;
        if (i = FTabIndex - 1) then
        begin
          MoveTo(x1 + 2, y);
          LineTo(x2 - 1, y);
          PaintEdge(i, x1);
        end
        else if (i = FTabIndex + 1) then
        begin
          MoveTo(x1, y);
          LineTo(x2 - 2, y);
          PaintEdge(i, x1);
        end
        else if (i = FTabIndex) then
        begin
          MoveTo(x1, y);
          LineTo(x2, y);
          MoveTo(0, FTabHeight);
          LineTo(x1 - 1, FTabHeight);
          MoveTo(x2 + 1, FTabHeight);
          LineTo(Width - 1, FTabHeight);
          PaintEdge(i, x1 - 2);
        end
        else
        begin
          MoveTo(x1 + 2, y);
          LineTo(x2 - 2, y);
          PaintEdge(i, x1);
        end;
        Pixels[Width - 1, FTabHeight] := clWindowFrame;
      end;
      { Special case for rightmost tab edge }
      if (i = Tabs.Count - 1) then PaintShadowEdge(i, x2, i = TabIndex);
      x1 := x2;
      { Store the right hand edge of each tab in the Objects array so that
        the mouse handler can make use of it. }
      FTabs.Objects[i] := TObject(x1);
    end;
    Canvas.Draw(0, 0, buffer);
  finally
    buffer.Free;
  end;
end;

procedure TTabPanel.MouseDown(Button: TMouseButton; Shift: TShiftState;
  X, Y: Integer);
var
  i, OldIndex: Integer;
  Form: TForm;
begin
  inherited MouseDown(Button, Shift, X, Y);
  if ((Button = mbLeft) or (csDesigning in ComponentState)) and
    (Y < FTabHeight) then
  begin
    OldIndex := TabIndex;
    for i := 0 to FTabs.Count - 1 do
      if X < Longint(FTabs.Objects[i]) then
      begin
        TabIndex := i;
        if csDesigning in ComponentState then
        begin
          Form := GetParentForm(Self);
          if (Form <> nil) and (Form.Designer <> nil) then
            Form.Designer.Modified;
        end;
        Break;
      end;
    if OldIndex = TabIndex then SetFocus; { 3.11 }
  end;
end;

procedure TTabPanel.KeyDown(var Key: Word; Shift: TShiftState);
begin
  inherited KeyDown(Key, Shift);
  if Key = VK_RIGHT then
    TabIndex := (FTabIndex + 1) mod FTabs.Count
  else if Key = VK_LEFT then
    TabIndex := (FTabIndex + FTabs.Count - 1) mod FTabs.Count;
end;

{ 3.11 }

procedure TTabPanel.SelectNext(Direction: Boolean);
var
  NewIndex: Integer;
begin
  if Tabs.Count > 1 then
  begin
    NewIndex := TabIndex;
    if Direction then
      TabIndex := (FTabIndex + 1) mod FTabs.Count
    else
      TabIndex := (FTabIndex + FTabs.Count - 1) mod FTabs.Count;
  end;
end;

procedure Register;
begin
  RegisterComponents('Calmira', [TTabPanel]);
end;

end.
