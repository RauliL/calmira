{*********************************************************}
{                                                         }
{    Calmira System library 3.3                           }
{    by Li-Hsin Huang & Erwin Dokter                      }
{    released into the public domain may 2002             }
{                                                         }
{*********************************************************}

unit BarGauge;

{ TBarGauge is a simplified version of Borland's sample TGauge, but is around
  10 times faster at drawing, because it doesn't bother to draw the
  clever "inverse" text effect.  Use it for speed critical stuff.

  Note: Calmira 2.1 and up use the newer TWin95Bar instead of TBarGauge. }

interface

uses SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  Forms, Dialogs, StdCtrls;

type
  TBarKind = (bkHorizontal, bkVertical);

  TAbstractBar = class(TGraphicControl)
  private
    FKind: TBarKind;
    FForeColor: TColor;
    FBackColor: TColor;
    procedure SetMinValue(Value: Longint);
    procedure SetMaxValue(Value: Longint);
    procedure SetKind(Value: TBarKind);
    procedure SetForeColor(Value: TColor);
    procedure SetBackColor(Value: TColor);
  protected
    FMinValue: Longint;
    FMaxValue: Longint;
    FCurValue: Longint;
    procedure SetProgress(Value: Longint); virtual;
  public
    constructor Create(AOwner: TComponent); override;
    procedure AddProgress(Value: Longint);
    function GetPercentDone: Integer;
  published
    property PercentDone: Integer read GetPercentDone;
    property Kind: TBarKind read FKind write SetKind default bkHorizontal;
    property MinValue: Longint read FMinValue write SetMinValue default 0;
    property MaxValue: Longint read FMaxValue write SetMaxValue default 100;
    property ForeColor: TColor read FForeColor write SetForeColor default clBlack;
    property BackColor: TColor read FBackColor write SetBackColor default clWhite;
    property Align;
    property Progress: Longint read FCurValue write SetProgress;
    property ParentShowHint;
    property ShowHint;
    property Enabled;
    property Visible;
  end;

  TBarGauge = class(TAbstractBar)
  private
    { Private declarations }
    FShowText: Boolean;
    FBorderStyle: TBorderStyle;
    FCtl3D: Boolean;
    procedure SetShowText(Value: Boolean);
    procedure SetBorderStyle(Value: TBorderStyle);
    procedure SetCtl3D(Value: Boolean);
  protected
    { Protected declarations }
    procedure Paint; override;
  public
    { Public declarations }
    constructor Create(AOwner: TComponent); override;
  published
    { Published declarations }
    property Ctl3D: Boolean read FCtl3D write SetCtl3D default True;
    property ShowText: Boolean read FShowText write SetShowText default True;
    property Font;
    property BorderStyle: TBorderStyle read FBorderStyle write SetBorderStyle default bsSingle;
    property ParentFont;
  end;

  TWin95Gauge = class(TAbstractBar)
  protected
    procedure Paint; override;
    procedure SetProgress(Value: Longint); override;
    function GetSegments: Integer;
  public
    procedure SetBounds(ALeft, ATop, AWidth, AHeight: Integer); override;
  end;

procedure Register;

implementation

uses ExtCtrls;

{ TAbstractBar}

constructor TAbstractBar.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  ControlStyle := ControlStyle + [csOpaque];
  FMinValue := 0;
  FMaxValue := 100;
  FCurValue := 0;
  FForeColor := clNavy;
  FBackColor := clSilver;
  Width := 100;
  Height := 100;
end;

function TAbstractBar.GetPercentDone: Integer;
begin
  if (FMaxValue = FMinValue) or (FCurValue = FMinValue) then Result := 0
  else Result := Trunc((FCurValue - FMinValue) / (FMaxValue - FMinValue) * 100);
end;

procedure TAbstractBar.SetMinValue(Value: Longint);
begin
  if Value <> FMinValue then
  begin
    FMinValue := Value;
    Repaint;
  end;
end;

procedure TAbstractBar.SetMaxValue(Value: Longint);
begin
  if Value <> FMaxValue then
  begin
    FMaxValue := Value;
    Repaint;
  end;
end;

procedure TAbstractBar.SetProgress(Value: Longint);
var
  PrevPercent: Integer;
begin
  if (FCurValue <> Value) and (Value >= FMinValue) and (Value <= FMaxValue) then
  begin
    PrevPercent := GetPercentDone;
    FCurValue := Value;
    if GetPercentDone <> PrevPercent then Repaint;
  end;
end;

procedure TAbstractBar.SetKind(Value: TBarKind);
begin
  if Value <> FKind then
  begin
    FKind := Value;
    Repaint;
  end;
end;

procedure TAbstractBar.AddProgress(Value: Longint);
begin
  Progress := FCurValue + Value;
end;

procedure TAbstractBar.SetForeColor(Value: TColor);
begin
  if Value <> FForeColor then
  begin
    FForeColor := Value;
    Repaint;
  end;
end;

procedure TAbstractBar.SetBackColor(Value: TColor);
begin
  if Value <> FBackColor then
  begin
    FBackColor := Value;
    Repaint;
  end;
end;

{ TBarGauge }

constructor TBarGauge.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  ControlStyle := ControlStyle + [csFramed];
  { default values }
  FShowText := True;
  FBorderStyle := bsSingle;
  FForeColor := clBlack;
  FBackColor := clWhite;
  FCtl3D := True;
end;

procedure TBarGauge.SetShowText(Value: Boolean);
begin
  if Value <> FShowText then
  begin
    FShowText := Value;
    Repaint;
  end;
end;

procedure TBarGauge.SetBorderStyle(Value: TBorderStyle);
begin
  if Value <> FBorderStyle then
  begin
    FBorderStyle := Value;
    Repaint;
  end;
end;

procedure TBarGauge.SetCtl3D(Value: Boolean);
begin
  if Value <> FCtl3D then
  begin
    FCtl3D := Value;
    Repaint;
  end;
end;

procedure TBarGauge.Paint;
var
  r: TRect;
  x, y: Integer;
  s: string[4];
begin
  r := ClientRect;
  with Canvas do
  begin
    if BorderStyle = bsSingle then
    begin
      if Ctl3D then Frame3D(Canvas, r, clBtnShadow, clBtnHighlight, 1);
      Frame3D(Canvas, r, clBlack, clBlack, 1);
    end;
    if Kind = bkHorizontal then
    begin
      x := MulDiv(r.Right - r.Left, PercentDone, 100);
      Brush.Color := ForeColor;
      FillRect(Rect(r.Left, r.Top, r.Left + x, r.Bottom));
      Brush.Color := BackColor;
      FillRect(Rect(r.Left + x, r.Top, r.Right, r.Bottom));
    end
    else
    begin
      y := MulDiv(r.Bottom - r.Top, PercentDone, 100);
      Brush.Color := ForeColor;
      FillRect(Rect(r.Left, r.Bottom - y, r.Right, r.Bottom));
      Brush.Color := BackColor;
      FillRect(Rect(r.Left, r.Top, r.Right, r.Bottom - y));
    end;
    if ShowText then
    begin
      s := Format('%d%%', [PercentDone]);
      Brush.Style := bsClear;
      Font.Assign(Self.Font);
      with r do
      begin
        x := (Width + 1 - TextWidth(s)) div 2;
        y := (Height + 1 - TextHeight(s)) div 2;
      end;
      TextRect(r, x, y, S);
    end;
  end;
end;

{ TWin95Gauge}

procedure TWin95Gauge.Paint;
var
  r: TRect;
  i: Integer;
begin
  r := ClientRect;
  Frame3D(Canvas, r, clBtnShadow, clBtnHighlight, 1);
  { Set r to the boundaries of the first segment }
  InflateRect(r, -1, -1);
  if Kind = bkHorizontal then r.Right := R.Left + 8
  else r.Bottom := r.Top + 8;
  with Canvas do
  begin
    Brush.Color := ForeColor;
    if Kind = bkHorizontal then
      for i := 1 to GetSegments do
      begin
        FillRect(r);
        OffsetRect(r, 10, 0);
      end
    else
      for i := 0 to GetSegments do
      begin
        FillRect(r);
        OffsetRect(r, 0, 10);
      end;
    { It is assumed that the background is the same colour as the
      component's parent, usually clBtnFace, otherwise this painting
      method doesn't work properly.  To prevent flickering, only
      the portion of the gauge without segments is filled with the
      background colour -- the gaps in between segments are not
      painted at all.  This code can be fixed by drawing on a
      temporary bitmap. }
    r.Right := Width - 3;
    Brush.Color := BackColor;
    FillRect(r);
  end;
end;

function TWin95Gauge.GetSegments: Integer;
begin
  Result := Trunc(Round((GetPercentDone / 100) * ((Width - 3) div 10)));
end;

procedure TWin95Gauge.SetProgress(Value: Longint);
var
  PrevSegments: Integer;
begin
  if (FCurValue <> Value) and (Value >= FMinValue) and (Value <= FMaxValue) then
  begin
    PrevSegments := GetSegments;
    FCurValue := Value;
    if GetSegments <> PrevSegments then Repaint;
  end;
end;

procedure TWin95Gauge.Setbounds(ALeft, ATop, AWidth, AHeight: Integer);

procedure CheckDimension(var X: Integer);
begin
  if (X - 3) mod 10 <> 0 then X := (((X - 3) div 10) * 10) + 3;
end;

begin
  if Kind = bkHorizontal then CheckDimension(AWidth)
  else CheckDimension(AHeight);
  inherited SetBounds(ALeft, ATop, AWidth, AHeight);
end;

procedure Register;
begin
  RegisterComponents('Calmira', [TBarGauge, TWin95Gauge]);
end;

end.

