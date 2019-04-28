{*********************************************************}
{                                                         }
{    Calmira System library 3.3                           }
{    by Li-Hsin Huang & Erwin Dokter                      }
{    released into the public domain may 2002             }
{                                                         }
{*********************************************************}

unit LabelSel;

{ TLabelSelect is an edit box descendant that places itself
  over TLabel controls so that users can select the label
  text and copy it.  Only one TLabelSelect is required per
  form, which uses fewer window handles if you have many labels.

  It is also useful for label captions that are too long to
  fit the width of the window -- TLabelSelect scrolls so they
  can see the rest of the text.

  To use this control :

  1. Drop one somewhere on your form.
  2. Select all relevant labels.
  3. If required, set the label's AutoSize property to False.
  4. Assign each label's OnMouseDown event to the same handler:
     if Button = mbLeft the LabelSelect1.Overlay(Sender as TLabel); }

interface

uses SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  Forms, Dialogs, StdCtrls;

type
  TLabelSelect = class(TEdit)
  private
    { Private declarations }
  protected
    { Protected declarations }
  public
    { Public declarations }
    constructor Create(AOwner: TComponent); override;
    procedure Overlay(L: TLabel);
  published
    { Published declarations }
  end;

procedure Register;

implementation

constructor TLabelSelect.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  ParentCtl3D := False;
  ParentShowHint := False;
  Ctl3D := False;
  AutoSelect := False;
  BorderStyle := bsNone;
  ReadOnly := True;
  ShowHint := True;
  Visible := False;
end;

procedure TLabelSelect.Overlay(L: TLabel);
begin
  Visible := False;
  if Parent <> L.Parent then Parent := L.Parent;
  BoundsRect := L.BoundsRect;
  Color := L.Color;
  Font := L.Font;
  Text := L.Caption;
  Hint := L.Hint;
  Visible := True;
  SetFocus;
end;

procedure Register;
begin
  RegisterComponents('Calmira', [TLabelSelect]);
end;

end.

