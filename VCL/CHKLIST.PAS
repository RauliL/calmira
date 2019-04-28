{*********************************************************}
{                                                         }
{    Calmira System library 3.3                           }
{    by Li-Hsin Huang & Erwin Dokter                      }
{    released into the public domain may 2002             }
{                                                         }
{*********************************************************}

unit ChkList;

{ TCheckList is a listbox that acts as an array of checkboxes.  It
  draws each item like a 3D check box, using the Selected property
  to determine if an item is checked.  At design time, use the Items
  property to set the contents.

  This has many advantages over a large array or group of standard
  TCheckbox controls:

  1.  Less resources -- a listbox only uses one window handle.
  2.  Fast -- only one control is created and drawn.
  3.  Practically unlimited capacity, without using more resources.
  4.  Scrollable -- pack a large number of options into a small
      space in a dialog box.

  The check list was originally designed so that many Boolean variables
  can be set without the need to map each var to one TCheckbox, which is
  error prone and slow, so there are two additional methods to allow
  efficient data transfer.

  SetData - accepts an open array of Booleans which is used to set
    the Selected property.
  GetData - accepts an open array of Boolean pointers, which is
    assigned the values from the Selected property.
  RangeCheck - if True, a call to GetData or SetData will check that
    the size of the open array matches the size of the list.  This
    often catches out ommissions and inconsistencies.

  For long lists, you can use just paste a copy the SetData call,
  change the "Set" to a "Get" and add @ symbols in front of each
  boolean identifier.

  Example :

  var
    DebugInfo, LocalSymbols, SymbolInfo : Boolean;

  CheckList1.SetData([DebugInfo, LocalSymbols, SymbolInfo]);
  if ShowModal = mrOK then
  CheckList1.GetData([@DebugInfo, @LocalSymbols, @SymbolInfo]);

  Don't forget to distribute CHKLIST.RES, which contains the
  fake checkbox bitmaps.

  Changes:

  Version 3.1: Added IE4 style checkboxes. }

interface

uses
  SysUtils, WinTypes, WinProcs, Classes, Graphics, Controls,
  Forms, StdCtrls, Menus;

type
  PBoolean = ^Boolean;
  TCheckboxStyle = (csWin95, csIE4);

  TCheckList = class(TCustomListbox)
  private
    { Private declarations }
    FRangeCheck: Boolean;
    FHints: TStrings;
    FCheckboxStyle: TCheckboxStyle;
    procedure LoadCheckboxBitmaps;
    procedure ReloadCheckboxBitmaps;
    procedure Validate(n: Integer);
    procedure SetHints(Value: TStrings);
    procedure SetCheckboxStyle(Value: TCheckboxStyle);
  protected
    { Protected declarations }
    procedure CreateWnd; override;
    procedure DestroyWnd; override;
    procedure DrawItem(Index: Integer; Rect: TRect; State: TOwnerDrawState); override;
  public
    { Public declarations }
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure SetData(const b: array of Boolean);
    procedure GetData(const p: array of PBoolean);
  published
    { Published declarations }
    property RangeCheck: Boolean read FRangeCheck write FRangeCheck default True;
    property Hints: TStrings read FHints write SetHints;
    property CheckboxStyle: TCheckboxStyle read FCheckboxStyle write SetCheckboxStyle;
    property Align;
    property BorderStyle;
    property Color;
    property Columns;
    property Ctl3D;
    property DragCursor;
    property DragMode;
    property Enabled;
    property Font;
    property IntegralHeight;
    property ItemHeight;
    property Items;
    property ParentColor;
    property ParentCtl3D;
    property ParentFont;
    property ParentShowHint;
    property PopupMenu;
    property ShowHint;
    property Sorted;
    property TabOrder;
    property TabStop;
    property Visible;
    property OnClick;
    property OnDblClick;
    property OnDragDrop;
    property OnDragOver;
    property OnEndDrag;
    property OnEnter;
    property OnExit;
    property OnKeyDown;
    property OnKeyPress;
    property OnKeyUp;
    property OnMouseDown;
    property OnMouseMove;
    property OnMouseUp;
  end;

  ECheckListError = class(Exception);

procedure Register;

implementation

{$R *.RES}

var
  CheckedBmp, UncheckedBmp: TBitmap;

procedure TCheckList.LoadCheckboxBitmaps;
begin
  CheckedBmp := TBitmap.Create;
  UncheckedBmp := TBitmap.Create;
  if CheckboxStyle = csWin95 then
  begin
    CheckedBmp.Handle := LoadBitmap(HInstance, 'CHECKLISTCHECKED');
    UncheckedBmp.Handle := LoadBitmap(HInstance, 'CHECKLISTUNCHECKED');
  end
  else
  begin
    CheckedBmp.Handle := LoadBitmap(HInstance, 'CHECKLISTCHECKED2');
    UncheckedBmp.Handle := LoadBitmap(HInstance, 'CHECKLISTUNCHECKED2');
  end;
end;

procedure TCheckList.ReloadCheckboxBitmaps;
begin
  CheckedBmp.Free;
  UncheckedBmp.Free;
  LoadCheckboxBitmaps;
end;

constructor TCheckList.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  Style := lbOwnerDrawFixed;
  MultiSelect := True;
  ExtendedSelect := False;
  ItemHeight := 20;
  FRangeCheck := True;
  FHints := TStringList.Create;
  if CheckedBmp = nil then LoadCheckboxBitmaps;
end;

destructor TCheckList.Destroy;
begin
  FHints.Free;
  inherited Destroy;
end;

procedure TCheckList.SetHints(Value: TStrings);
begin
  FHints.Assign(value);
end;

procedure TcheckList.SetCheckboxStyle(Value: TCheckboxStyle);
begin
  FCheckboxStyle := Value;
  ReloadCheckboxBitmaps;
  Invalidate;
end;

procedure TCheckList.DrawItem(Index: Integer; Rect: TRect; State: TOwnerDrawState);
var
  bmp: TBitmap;
  h: Integer;
begin
  h := Rect.Bottom - Rect.Top;
  with Canvas do
  begin
    Font.Assign(self.Font);
    Brush.Color := Color;
    FillRect(Rect);
    if Selected[Index] then
      bmp := CheckedBmp else bmp := UncheckedBmp;
    Draw(4, Rect.Top + (h - bmp.Height) div 2, bmp);
    TextOut(Rect.Left + 22,
      Rect.Top + (h - Abs(Font.Height)) div 2 - 1, Items[Index]);
  end;
end;

procedure TCheckList.Validate(n: Integer);
begin
  if FRangeCheck then
    if n < Items.Count then
      raise ECheckListError.Create('Not enough elements in data array')
    else if n > Items.Count then
      raise ECheckListError.Create('Too many elements in data array')
end;

procedure TCheckList.SetData(const b: array of Boolean);
var
  i: Integer;
begin
  Validate(High(b) + 1);
  i := 0;
  while (i <= High(b)) and (i < Items.Count) do
  begin
    Selected[i] := b[i];
    Inc(i);
  end;
  TopIndex := 0;
  Invalidate;
end;

procedure TCheckList.GetData(const p: array of PBoolean);
var
  i: Integer;
begin
  Validate(High(p) + 1);
  i := 0;
  while (i <= High(p)) and (i < Items.Count) do
  begin
    p[i]^ := Selected[i];
    Inc(i);
  end;
end;

procedure TCheckList.DestroyWnd;
var
  i: Integer;
begin
  for i := 0 to Items.Count - 1 do
    Items.Objects[i] := TObject(LongBool(Selected[i]));
  inherited DestroyWnd;
end;

procedure TCheckList.CreateWnd;
var
  i: Integer;
begin
  inherited CreateWnd;
  for i := 0 to Items.Count - 1 do
    Selected[i] := LongBool(Items.Objects[i]);
end;

procedure DoneCheckList; far;
begin
  CheckedBmp.Free;
  UncheckedBmp.Free;
end;

procedure Register;
begin
  RegisterComponents('Calmira', [TCheckList]);
end;

initialization
  AddExitProc(DoneCheckList);
end.
