{*********************************************************}
{                                                         }
{    Calmira System library 3.3                           }
{    by Li-Hsin Huang & Erwin Dokter                      }
{    released into the public domain may 2002             }
{                                                         }
{*********************************************************}

unit Slider;

{ Slider / TrackBar component for Delphi 1. }

interface

uses SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls;

type
  TSliderOrientation = (slHorizontal, slVertical);
  TSlider = class(TCustomControl)
  private
    { Private declarations }
    Thumb: TRect;               { Current thumb position             }
    MemDC: HDC;                 { DC for saving area under the thumb }
    Bitmap: HBitmap;            { Bitmap handle for saved area.      }
    Capture: boolean;           { Whether it's currently being moved }
    CapturePoint: TPoint;       { Position at start of Capture.      }
    CaptureValue: Integer;      { Value at start of Capture.         }
    fTrackWidth: Integer;
    fTrackColor: TColor;
    fOrientation: TSliderOrientation;
    fThumbHeight: Integer;
    fThumbColor: TColor;
    fFocusColor: TColor;
    fMin: Integer;
    fMax: Integer;
    fValue: Integer;
    fChange: TNotifyEvent;
    fCtl3D: Boolean;
    fShowTicks: Boolean;
    fFrequency: Integer;
    procedure SetTrackWidth(value: Integer);
    procedure SetTrackColor(value: TColor);
    procedure SetOrientation(value: TSliderOrientation);
    procedure SetThumbHeight(value: Integer);
    procedure SetThumbColor(value: TColor);
    procedure SetFocusColor(value: TColor);
    procedure SetMin(avalue: Integer);
    procedure SetMax(avalue: Integer);
    procedure SetValue(value: Integer);
    procedure SetCtl3D(value: Boolean);
    procedure SetShowTicks(value: Boolean);
    procedure SetFrequency(value: Integer);
    procedure CMFocusChanged(var Message: TCMFocusChanged); message CM_FOCUSCHANGED;
    procedure WMGetDlgCode(var Message: TWMGetDlgCode); message WM_GETDLGCODE;
    {procedure WMPaint(var Message:TWMPaint); message WM_PAINT;}
  protected
    { Protected declarations }
    procedure Paint; override;
    procedure DrawThumb(FirstDraw: Boolean); virtual;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
    procedure KeyDown(var Key: Word; Shift: TShiftState); override;
  public
    { Public declarations }
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  published
    { Published declarations }
    property TrackWidth: Integer read fTrackWidth write SetTrackWidth default 10;
    property TrackColor: TColor read fTrackColor write SetTrackColor default clWhite;
    property ThumbHeight: Integer read fThumbHeight write SetThumbHeight default 10;
    property ThumbColor: TColor read fThumbColor write SetThumbColor default clBtnFace;
    property FocusColor: TColor read fFocusColor write SetFocusColor default clWhite;
    property Orientation: TSliderOrientation read fOrientation write SetOrientation
      default slVertical;
    property Minimum: Integer read fMin write SetMin default 0;
    property Maximum: Integer read fMax write SetMax default 100;
    property Value: Integer read fValue write SetValue default 0;
    property Ctl3D: Boolean read fCtl3D write SetCtl3D default True;
    property ShowTicks: Boolean read fShowTicks write SetShowTicks default True;
    property Frequency: Integer read fFrequency write SetFrequency default 10;
    property OnChange: TNotifyEvent read fChange write fChange;
    property Color;
    property Enabled;
    property HelpContext;
    property Hint;
    property ParentShowHint;
    property ShowHint;
    property TabOrder;
    property TabStop;
    property Tag;
    property Visible;
    property OnClick;
    property OnDragDrop;
    property OnDragOver;
    property OnEndDrag;
    property OnEnter;
    property OnExit;
    property OnMouseDown;
    property OnMouseMove;
    property OnMouseUp;
    property OnKeyDown;
    property OnKeyPress;
    property OnKeyUp;
  end;

procedure Register;

implementation

var
  Pattern: TBitmap;
  SliderCount: Integer;

procedure CreateBrushPattern(const bgColor, fgColor: TColor);
var
  X, Y: Integer;
begin
  Pattern := TBitmap.Create;
  Pattern.Width := 8;
  Pattern.Height := 8;
  with Pattern.Canvas do
  begin
    Brush.Style := bsSolid;
    Brush.Color := bgColor;
    FillRect(Rect(0, 0, Pattern.Width, Pattern.Height));
    for Y := 0 to 7 do
      for X := 0 to 7 do
        if (Y mod 2) = (X mod 2) then  { toggles between even/odd pixles }
          Pixels[X, Y] := fgColor;     { on even/odd rows }
  end;
end;

constructor TSlider.Create(AOwner: TComponent);
begin
  inherited Create (AOwner);
  fTrackWidth := 10;
  fTrackColor := clWhite;
  fThumbHeight := 10;
  fThumbColor := clBtnFace;
  fFocusColor := clWhite;
  fOrientation := slVertical;
  fMin := 0;
  fMax := 100;
  fValue := 0;
  fCtl3D := True;
  fShowTicks := true;
  fFrequency := 10;
  fChange := nil;
  Capture := False;
  Width := 24;
  Height := 100;
  Inc(SliderCount);
end;

destructor TSlider.Destroy;
begin
  if Bitmap <> 0 then DeleteObject(Bitmap);
  if MemDC <> 0 then DeleteDC(MemDC);
  Dec(SliderCount);
  if SliderCount = 0 then
  begin
    Pattern.Free;
    Pattern := nil;
  end;
  inherited Destroy;
end;

procedure TSlider.SetTrackWidth(value: Integer);
begin
  if fTrackWidth <> value then
  begin
    fTrackWidth := value;
    Invalidate;
  end;
end;

procedure TSlider.SetOrientation(value: TSliderOrientation);
begin
  if value <> fOrientation then
  begin
    fOrientation := value;
    Invalidate;
  end;
end;

procedure TSlider.SetTrackColor(value: TColor);
begin
  if value <> fTrackColor then
  begin
    fTrackColor := value;
    Invalidate;
  end;
end;

procedure TSlider.SetThumbHeight(value: Integer);
begin
  if value <> fThumbHeight then
  begin
    fThumbHeight := value;
    Invalidate;
  end;
end;

procedure TSlider.SetThumbColor(value: TColor);
begin
  if value <> fThumbColor then
  begin
    fThumbColor := value;
    Invalidate;
  end;
end;

procedure TSlider.SetFocusColor(value: TColor);
begin
  if value <> fFocusColor then
  begin
    fFocusColor := value;
    Pattern.Free;
    Pattern := nil;
    Invalidate;
  end;
end;

procedure TSlider.SetMin(avalue: Integer);
begin
  if avalue <> fMin then
  begin
    fMin := avalue;
    if Value < fMin then Value := fMin;
    Invalidate;
  end;
end;

procedure TSlider.SetMax(avalue: Integer);
begin
  if avalue <> fMax then
  begin
    fMax := avalue;
    if Value > fMax then Value := fMax;
    Invalidate;
  end;
end;

procedure TSlider.SetValue(value: Integer);
begin
  if value < Minimum then value := Minimum
  else if value > Maximum then value := Maximum;
  if value <> fValue then
  begin
    fValue := value;
    if Assigned(fChange) then OnChange(self);
    DrawThumb(false);
  end;
end;

procedure TSlider.SetCtl3D(value: boolean);
begin
  if value <> fCtl3D then
  begin
    fCtl3D := value;
    Invalidate;
  end;
end;

procedure TSlider.SetShowTicks(value: Boolean);
begin
  if value <> fShowTicks then
  begin
    fShowTicks := value;
    Invalidate;
  end;
end;

procedure TSlider.SetFrequency(value: Integer);
begin
  if value < 1 then value := 1;
  if value > (fMax - fMin) then value := fMax - fMin;
  if value <> fFrequency then
  begin
    fFrequency := Value;
    Invalidate;
  end;
end;

procedure TSlider.CMFocusChanged(var Message: TCMFocusChanged);
begin
  inherited;
  DrawThumb(false);
end;

procedure TSlider.WMGetDlgCode(var Message: TWMGetDlgCode);
begin
  inherited;
  Message.Result := DLGC_WANTARROWS;
end;

procedure TSlider.Paint;
var
  TickPos: Integer;
  Rect: TRect;
  i: Integer;
begin
  with Canvas do
  begin
    { Create memory DC for save bitmap }
    if MemDC = 0 then MemDC := CreateCompatibleDC(Canvas.Handle);
    { Create thumb & bitmap for vertical slider }
    if Orientation = slVertical then
    begin
      if Bitmap = 0 then
        Bitmap := CreateCompatibleBitmap(Canvas.Handle, Width, ThumbHeight);
      Rect.top := 0;
      Rect.bottom := Height;
      Rect.left := (Width - TrackWidth) div 2;
      Rect.Right := Rect.Left + TrackWidth;
    end
    else
    begin
      { Create thumb & bitmap for horizontal slider }
      if Bitmap = 0 then
        Bitmap := CreateCompatibleBitmap(Canvas.Handle, ThumbHeight, Height);
      Rect.top := (Height - TrackWidth) div 2;
      Rect.bottom := Rect.Top + TrackWidth;
      Rect.left := 0;
      Rect.Right := Width
    end;
    { Draw track }
    with Rect do
    begin
      Brush.Color := TrackColor;
      if Ctl3D then
      begin
        FillRect(rect);
        Pen.Color := clWindowFrame;
        MoveTo(left + 1, bottom - 2);
        LineTo(left + 1, top + 1);
        LineTo(right - 2, top + 1);
        Pen.Color := clBtnFace;
        LineTo(right - 2, bottom - 2);
        LineTo(left + 1, bottom - 2);
        Pen.Color := clBtnShadow;
        MoveTo(left, bottom - 1);
        LineTo(left, top);
        LineTo(right - 1, top);
        Pen.Color := clBtnHighLight;
        LineTo(right - 1, bottom - 1);
        LineTo(left, bottom - 1);
      end
      else begin
        { Not Ctl3D - do a simple rectangle }
        Pen.Color := clWindowFrame;
        Rectangle (left, top, right, bottom);
      end;
    end;
    if ShowTicks then
      { Draw the ticks... }
      if Orientation = slVertical then
        { ... vertically }
        with Canvas do
        begin
          i := Maximum + 1;
          while i >= Minimum do
          begin
            TickPos := (LongInt(Height - ThumbHeight) * LongInt(i - Minimum)
              div (Maximum - Minimum)) + (ThumbHeight div 2);
            if Ctl3D then Pen.Color := clBtnHighlight
            else Pen.Color := clWindowFrame;
            MoveTo(0, TickPos);
            LineTo(Rect.Left div 2, TickPos);
            MoveTo(Width, TickPos);
            LineTo(Rect.Right + ((Width - Rect.Right) div 2), TickPos);
            if Ctl3D then
            begin
              Pen.Color := clBtnShadow;
              MoveTo(0, TickPos - 1);
              LineTo(Rect.Left div 2, TickPos - 1);
              MoveTo(Width, TickPos - 1);
              LineTo(Rect.Right + ((Width - Rect.Right) div 2), TickPos - 1);
            end;
            Dec(i, Frequency);
          end;
        end
      else
        { ... or horizontally }
        with Canvas do
        begin
          i := Minimum - 1;
          while i <= Maximum do
          begin
            TickPos := (LongInt(Width - ThumbHeight) * LongInt(i - Minimum)
              div (Maximum - Minimum)) + (ThumbHeight div 2);
            if Ctl3D then Pen.Color := clBtnShadow
            else Pen.Color := clWindowFrame;
            MoveTo(TickPos, 0);
            LineTo(TickPos, Rect.Top div 2);
            MoveTo(TickPos, Height);
            LineTo(TickPos, Rect.Bottom + ((Height - Rect.Bottom) div 2));
            if Ctl3D then
            begin
              Pen.Color := clBtnHighlight;
              MoveTo(TickPos + 1, 0);
              LineTo(TickPos + 1, Rect.Top div 2);
              MoveTo(TickPos + 1, Height);
              LineTo(TickPos + 1, Rect.Bottom + ((Height - Rect.Bottom) div 2));
           end;
           Inc(i, Frequency);
          end;
        end;
  end;
  { Now draw the thumb. }
  DrawThumb(true);
end;

procedure TSlider.DrawThumb(FirstDraw: Boolean);
var
  BasePos: Integer;
  OldBmp: HBitmap;
  OldThumb: TRect;
begin
  if csLoading in ComponentState then Exit;
  OldBmp := SelectObject(MemDC, Bitmap);
  { Save current thumb rectangle }
  OldThumb := Thumb;
  if Orientation = slVertical then
  begin
    { Calculate new thumb rectangle }
    BasePos := LongInt(Height - ThumbHeight) * LongInt(Value - Minimum)
      div (Maximum - Minimum);
    Thumb.left := 0;
    Thumb.right := Width;
    Thumb.Bottom := Height - BasePos;
    Thumb.top := Thumb.Bottom - ThumbHeight;
    { Rub out old thumb }
    if not FirstDraw then with OldThumb do
      BitBlt(Canvas.Handle, Left, Top, Width, ThumbHeight, MemDC, 0, 0, SRCCOPY);
    { Save what's underneath }
    with Thumb do
      BitBlt(MemDC, 0, 0, Width, ThumbHeight, Canvas.Handle, Left, Top, SRCCOPY);
  end
  else
  begin
    { Calculate new thumb rectangle for horizontal slider}
    BasePos := LongInt(Width - ThumbHeight) * LongInt(Value - Minimum)
      div (Maximum - Minimum);
    Thumb.left := BasePos;
    Thumb.Right := Thumb.left + ThumbHeight;
    Thumb.Top := 0;
    Thumb.Bottom := Height;
    { Rub out old thumb }
    if not FirstDraw then with OldThumb do
      BitBlt(Canvas.Handle, Left, Top, ThumbHeight, Height, MemDC, 0, 0, SRCCOPY);
    { Save what's underneath }
    with Thumb do
      BitBlt(MemDC, 0, 0, ThumbHeight, Height, Canvas.Handle, Left, Top, SRCCOPY);
  end;
  { Draw the thumb }
  with Canvas, Thumb do
  begin
    if Focused then
    begin
      if Pattern = nil then CreateBrushPattern(ThumbColor, FocusColor);
      Brush.Bitmap := Pattern;
    end
    else Brush.Color := ThumbColor;
    if Ctl3D then
    begin
      FillRect(Thumb);
      Pen.Color := clBtnHighlight;
      MoveTo(Left, Bottom - 2);
      LineTo(Left, Top);
      LineTo(Right - 1, Top);
      Pen.Color := clWindowFrame;
      MoveTo(Left, Bottom - 1);
      LineTo(Right - 1, Bottom - 1);
      Lineto(Right - 1, Top - 1);
      Pen.Color := clBtnShadow;
      MoveTo(Left + 1, Bottom - 2);
      LineTo(Right - 2, Bottom - 2);
      LineTo(Right - 2, Top);
    end
    else
    begin
      Pen.Color := clWindowFrame;
      Rectangle(left, top, right, bottom);
    end;
  end;
  SelectObject(MemDC, OldBmp);
end;

procedure TSlider.MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  inherited MouseDown(Button, Shift, X, Y);
  if not Focused then SetFocus;
  if (Button = mbLeft) and PtInRect(Thumb, Point(X, Y)) then
  begin
    Capture := True;
    CapturePoint := Point(X, Y);
    CaptureValue := Value;
  end
  else if (Button = mbLeft) then
  begin
    if Orientation = slVertical then
      if Y > Thumb.Top then
        Value := Value - Frequency
      else
        Value := Value + Frequency
    else
      if X < Thumb.Left then
        Value := Value - Frequency
      else
        Value := Value + Frequency;
    if Value < Minimum then Value := Minimum;
    if Value > Maximum then Value := Maximum;
  end;
end;

procedure TSlider.MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  inherited MouseUp(Button, Shift, X, Y);
  if (Button = mbLeft) then Capture := False;
end;

procedure TSlider.MouseMove(Shift: TShiftState; X, Y: Integer);
begin
  inherited MouseMove(shift, X, Y);
  if Capture then
    if Orientation = slVertical then
      Value := CaptureValue + LongInt(Maximum - Minimum)
        * LongInt(CapturePoint.Y - Y) div (Height - ThumbHeight)
    else
      Value := CaptureValue + LongInt(Maximum - Minimum)
        * LongInt(X - CapturePoint.X) div (Width - ThumbHeight);
end;

procedure TSlider.KeyDown(var Key: Word; Shift: TShiftState);
begin
  inherited KeyDown(Key, Shift);
  if Orientation = slVertical then
    case Key of
      VK_UP   : Value := Value + Frequency;
      VK_DOWN : Value := Value - Frequency;
      VK_HOME : Value := Maximum;
      VK_END  : Value := Minimum;
    end
  else
    case Key of
      VK_LEFT : Value := Value - Frequency;
      VK_RIGHT: Value := Value + Frequency;
      VK_HOME : Value := Minimum;
      VK_END  : Value := Maximum;
    end;
  if Value < Minimum then Value := Minimum;
  if Value > Maximum then Value := Maximum;
end;


procedure Register;
begin
  RegisterComponents('Calmira', [TSlider]);
end;

end.
