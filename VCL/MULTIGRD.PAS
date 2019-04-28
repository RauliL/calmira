{*********************************************************}
{                                                         }
{    Calmira System library 3.3                           }
{    by Li-Hsin Huang & Erwin Dokter                      }
{    released into the public domain may 2002             }
{                                                         }
{*********************************************************}

unit MultiGrd;

{ TMultiGrid component

  Properties

  Selected - determines if a given cell is highlighted
  SelCount - determines how many cells are highlighted in the grid
  Multi - true if the grid is in "multi-select" mode
  AllowMulti - enables or disables multiple selections
  Limit - the valid range for the grid.  Cells with an index outside
    of Limit will not be painted and cannot be selected with the mouse.
  Focus - determines which cell has the dotted box draw around it
  ThumbTrack - controls the goThumbTracking element of TCustomGrid
    (the inherited Options property is not made public)
  DropFocus - determines which cell has a focus rect drawn around it
    during drag and drop.  Set to -1 to hide the drop focus.

  Methods

  SelectAll and DeselectAll - highlights and unhighlights all cells in
    the grid, up to Limit
  CellIndex - returns the linear index of a given row and column
  Reset - deselects all cells without generating events and redraws
    the control Use this to initialize between different phases of use.
  Select - moves the focus to the given cell and selects it
  MouseToCell - returns the index of the cell at the given pixel position
  SetSize - changes the number of columns and rows while preserving the
    current selection.  If you modify the ColCount and RowCount
    properties directly, all selections are lost.
  SizeGrid - automatically adjusts the number of columns and rows to
    fit the current grid size

  Events

  OnSelectCell - occurs just before a cell is selected (like TDrawGrid's
     OnSelectCell event).  You have the chance to cancel this operation.

  OnSelect - occurs after the user has selected a cell by left clicking
     with the mouse (or moving the cursor keys).  Typically you would
     use this event to respond to a single or multiple selection.  This
     event occurs only once for each mouse click.

  OnCellSelected - occurs after the highlight of a cell is turned on or
     off, either by the user or by the program assigning a value to the
     Selected property.  If the user selects a range of cells by using
     the Shift key, this event occurs once for every cell that has its
     highlight changed.

  OnDrawCell - same as OnDrawCell for a TDrawGrid except that an integer
     cell index is used }

interface

uses SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  Forms, Dialogs, Grids, Menus, StdCtrls;

type
  TBooleanList = array[0..65528] of Boolean;
  PBooleanList = ^TBooleanList;

  EGridError = class(Exception);

  TGridSelectEvent = procedure (Sender: TObject; Index: Integer) of object;

  TCellSelectedEvent = procedure (Sender: TObject; Index: Integer;
     IsSelected: Boolean) of object;

  TMultiDrawCellEvent = procedure (Sender: TObject; Index: Integer; Rect: TRect;
     State: TGridDrawState) of object;

  TMultiSelectCellEvent = procedure (Sender: TObject; Index: Integer;
     var CanSelect: Boolean) of object;

  TMultiGrid = class(TCustomGrid)
  private
    { Private declarations }
    FSelected: PBooleanList;
    FSelCount: Integer;
    FSelColor: TColor;
    FMulti: Boolean;
    FAllowMulti: Boolean;
    FOnSelect: TGridSelectEvent;
    FOnCellSelected: TCellSelectedEvent;
    FOnDrawCell: TMultiDrawCellEvent;
    FOnSelectCell: TMultiSelectCellEvent;
    FOnTopLeftChange: TNotifyEvent;
    FUpdates: Integer;
    FLimit: Integer;
    FDropFocus: Integer;
    FSelAnchor: Integer;
    function GetSelected(i: Integer): Boolean;
    procedure SetSelected(i: Integer; Sel: Boolean);
    function GetFocus: Integer;
    procedure SetFocus(i: Integer);
    procedure SetMulti(m: Boolean);
    procedure SetSelColor(value: TColor);
    function GetThumbTrack: Boolean;
    procedure SetThumbTrack(value: Boolean);
    procedure SetDropFocus(value: Integer);
  protected
    { Protected declarations }
    procedure SizeChanged(OldColCount, OldRowCount: Longint); override;
    procedure DrawCell(ACol, ARow: Longint; ARect: TRect;
      AState: TGridDrawState); override;
    procedure CellSelected(i: Integer; IsSelected: Boolean); virtual;
    function SelectCell(ACol, ARow: Longint): Boolean; override;
    procedure TopLeftChanged; override;
    procedure BeginUpdate;
    procedure EndUpdate;
  public
    { Public declarations }
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure SelectAll;
    procedure DeselectAll;
    function CellIndex(ACol, ARow: Longint): Integer;
    procedure Reset;
    procedure SetSize(AColCount, ARowCount: Longint);
    procedure SizeGrid;
    procedure Select(Index: Integer);
    function MouseToCell(X, Y: Integer): Integer;
    function CellBounds(i: Integer): TRect;
    property SelCount: Integer read FSelCount;
    property Selected[i: Integer]: Boolean read GetSelected write SetSelected;
    property Multi: Boolean read FMulti write SetMulti;
    property DropFocus: Integer read FDropFocus write SetDropFocus;
    property Canvas;
    property TopRow;
    property LeftCol;
    property VisibleRowCount;
    property VisibleColCount;
  published
    { Published declarations }
    property Focus: Integer read GetFocus write SetFocus;
    property OnSelect: TGridSelectEvent read FOnSelect write FOnSelect;
    property OnCellSelected: TCellSelectedEvent read FOnCellSelected write FOnCellSelected;
    property OnDrawCell: TMultiDrawCellEvent read FOnDrawCell write FOnDrawCell;
    property OnSelectCell: TMultiSelectCellEvent read FOnSelectCell write FOnSelectCell;
    property OnTopLeftChange: TNotifyEvent read FOnTopLeftChange write FOnTopLeftChange;
    property AllowMulti: Boolean read FAllowMulti write FAllowMulti;
    property Limit: Integer read FLimit write FLimit;
    property SelColor: TColor read FSelColor write SetSelColor;
    property ThumbTrack: Boolean read GetThumbTrack write SetThumbTrack default False;
    property DefaultColWidth;
    property DefaultRowHeight;
    property RowCount;
    property ColCount;
    property Color;
    property Ctl3D;
    property DefaultDrawing;
    property DragCursor;
    property DragMode;
    property Enabled;
    property Font;
    property GridLineWidth;
    property ParentColor;
    property ParentCtl3D;
    property ParentFont;
    property ParentShowHint;
    property PopupMenu;
    property ShowHint;
    property Scrollbars;
    property TabOrder;
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

procedure Register;

implementation

uses MiscUtil;

constructor TMultiGrid.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FixedRows := 0;
  FixedCols := 0;
  DefaultDrawing := False;
  GridLineWidth := 0;
  Options := Options - [goRangeSelect];
  FDropFocus := -1;
  FMulti := False;
  FAllowMulti := True;
  FSelColor := clHighlight;
  FSelected := AllocMem(RowCount * ColCount);
  FSelAnchor := -1;
end;

destructor TMultiGrid.Destroy;
begin
  FreeMem(FSelected, RowCount * ColCount);
  inherited Destroy;
end;

function TMultiGrid.GetSelected(i: Integer): Boolean;
begin
  if (i >= 0) and (i < ColCount * RowCount) then Result := FSelected^[i]
  else raise EListError.Create('Index out of range');
end;

procedure TMultiGrid.SetSelected(i: Integer; Sel: Boolean);
begin
  if (i >= 0) and (i < ColCount * RowCount) then
  begin
    if FSelected^[i] <> Sel then
    begin
      FSelected^[i] := Sel;
      if Sel then
      begin
        Inc(FSelCount);
        if not FMulti and (FSelcount > 1) then
        begin
          FAllowMulti := True;
          FMulti := True;
        end;
      end
      else Dec(FSelCount);
      InvalidateCell(i mod ColCount, i div ColCount);
      if Assigned(FOnCellSelected) then FOnCellSelected(self, i, Sel);
    end
  end
  else raise EGridError.Create('Index of out range');
end;

{ BeginUpdate and EndUpdate

  These are internal methods used to prevent the grid from redrawing
  when some shuffling of properties is taking place.  When TMultiGrid
  is in an "updating" state, OnSelectCell and OnDrawCell are bypassed }

procedure TMultiGrid.BeginUpdate;
begin
  Inc(FUpdates);
end;

procedure TMultiGrid.EndUpdate;
begin
  if FUpdates > 0 then Dec(FUpdates);
end;

function TMultiGrid.GetFocus: Integer;
begin
  Result := Row * ColCount + Col;
end;

procedure TMultiGrid.SetFocus(i: Integer);
begin
  if i < RowCount * ColCount then
  begin
    BeginUpdate;
    Row := i div ColCount;
    Col := i mod ColCount;
    EndUpdate;
  end;
end;

procedure TMultiGrid.SetMulti(m: Boolean);
begin
  if FMulti <> m then
  begin
    if m then
    begin
      FAllowMulti := True;
      FMulti := True;
    end
    else
    begin
      if SelCount > 0 then DeselectAll;
      FMulti := False;
    end;
  end;
end;

function TMultiGrid.CellBounds(i: Integer): TRect;
begin
  Result := CellRect(i mod ColCount, i div ColCount);
end;

procedure TMultiGrid.SetSelColor(value: TColor);
begin
  if FSelColor <> value then
  begin
    FSelColor := value;
    if SelCount > 0 then Invalidate;
  end;
end;

procedure TMultiGrid.SetSize(AColCount, ARowCount: Longint);
var
  f: Integer;
  p: PBooleanList;
  bufsize: Word;
begin
  if (AColCount = ColCount) and (ARowCount = RowCount) then Exit;
  if AColCount = 0 then AColCount := 1;
  if ARowCount = 0 then ARowCount := 1;
  { The current selection is copied to a temporary buffer and then
    restored once the inherited sizing is complete }
  BeginUpdate;
  f := Focus;
  bufsize := Min(AColCount * ARowCount, ColCount * RowCount);
  p := AllocMem(bufsize);
  try
    Move(FSelected^, p^, bufsize);
    ColCount := AColCount;
    RowCount := ARowCount;
    Move(p^, FSelected^, bufsize);
    Focus := f;
  finally
    FreeMem(p, bufsize);
    EndUpdate;
    Invalidate;
  end;
end;

procedure TMultiGrid.SizeGrid;
var
  c, r: Longint;
begin
  { try to display without the scroll bar first }
  c := Width div DefaultColWidth;
  if c = 0 then Inc(c);
  r := Limit div c;
  if Limit mod c > 0 then Inc(r);
  { if the computed row count exceeds the number of rows that
    can be displayed, take the scroll bar width into account and
    recalculate }
  if (Height - 4) div DefaultRowHeight < r then
  begin
    c := (Width - GetSystemMetrics(SM_CXVSCROLL)) div DefaultColWidth;
    if c = 0 then Inc(c);
    r := Limit div c;
    if Limit mod c > 0 then Inc(r);
  end;
  SetSize(c, r);
end;

procedure TMultiGrid.SizeChanged(OldColCount, OldRowCount: Longint);
begin
  inherited SizeChanged(OldColCount, OldRowCount);
  FreeMem(FSelected, OldColCount * OldRowCount);
  FSelected := AllocMem(ColCount * RowCount);
end;

procedure TMultiGrid.CellSelected(i: Integer; IsSelected: Boolean);
begin
  Selected[i] := IsSelected;
  InvalidateCell(i mod ColCount, i div ColCount);
  if Assigned(FOnCellSelected) then FOnCellSelected(self, i, IsSelected);
end;

function TMultiGrid.CellIndex(ACol, ARow: Longint): Integer;
begin
  Result := ARow * ColCount + ACol;
end;

procedure TMultiGrid.Reset;
begin
  FillChar(FSelected^, ColCount * RowCount, False);
  FSelcount := 0;
  FMulti := False;
  Invalidate;
end;

function TMultiGrid.SelectCell(ACol, ARow: Longint): Boolean;
var
  i, j, index, lower, upper, temp: Integer;
begin
  if FUpdates > 0 then
  begin
    Result := True;
    exit;
  end;
  index := ARow * ColCount + ACol;
  Result := index < Limit;
  if Result and Assigned(FOnSelectCell) then
    FOnSelectCell(self, index, Result);
  if Result then
  begin
    if AllowMulti and (Focused and (GetAsyncKeyState(VK_CONTROL) < 0)) then
    begin
      { Ctrl-click.  Invert selection of target cell }
      FMulti := True;
      Selected[index] := not Selected[index];
      FSelAnchor := -1;
    end
    else if AllowMulti and (Focused and (GetKeyState(VK_SHIFT) < 0)) then
    begin
      { Shift-click.  Select range of cells }
      FMulti := True;
      if FSelAnchor = -1 then FSelAnchor := Row * ColCount + Col;
      lower := FSelAnchor;
      upper := index;
      if lower > upper then
      begin
        temp := lower;
        lower := upper;
        upper := temp;
      end;
      for i := 0 to Limit - 1 do
        Selected[i] := (i >= lower) and (i <= upper);
    end
    else
    begin
      { normal click -- no Ctrl or Shift }
      FSelAnchor := -1;
      if FMulti then
      begin
        if not FSelected^[index] then
        begin
          { turn off multi mode }
          FMulti := False;
          for i := 0 to Limit - 1 do Selected[i] := False;
          Selected[index] := True;
        end;
      end
      else
      begin
        { change highlighted cell }
        i := Row * ColCount + Col;
        Selected[i] := False;
        Selected[index] := True;
      end;
    end;
    if Assigned(FOnSelect) then FOnSelect(self, index);
  end;
end;

procedure TMultiGrid.Select(Index: Integer);
var
  ACol, ARow, c, r: Longint;
begin
  c := Col; r := Row;
  if SelectCell(Index mod ColCount, Index div ColCount) then
  begin
    Focus := Index;
    InvalidateCell(c, r);
    Update;
  end;
end;

procedure TMultiGrid.DrawCell(ACol, ARow: Longint; ARect: TRect;
  AState: TGridDrawState);
var
  i: Integer;
begin
  if FUpdates > 0 then Exit;
  i := ARow * ColCount + ACol;
  with Canvas do
  begin
    if not FSelected^[i] then
    begin
      Brush.Color := Color;
      Font.Color := clWindowText;
      if not DefaultDrawing then FillRect(ARect);
    end
    else
    begin
      Brush.Color := clHighlight;
      Font.Color := clHighlightText;
    end;
    if DefaultDrawing then FillRect(ARect);
  end;
  if FSelected^[i] then Include(AState, gdSelected)
  else Exclude(AState, gdSelected);
  Exclude(AState, gdFixed);
  if (i < Limit) and Assigned(FOnDrawCell) then
    FOnDrawCell(self, i, ARect, AState);
end;

procedure TMultiGrid.DeselectAll;
var
  i: Integer;
begin
  for i := 0 to Limit - 1 do Selected[i] := False;
  if Assigned(FOnSelect) then FOnSelect(self, Focus);
end;

procedure TMultiGrid.SelectAll;
var
  i: Integer;
begin
  for i := 0 to Limit-1 do Selected[i] := True;
  if Assigned(FOnSelect) then FOnSelect(self, Focus);
end;

function TMultiGrid.MouseToCell(X, Y: Integer): Integer;
begin
  with MouseCoord(X, Y) do Result := Y * ColCount + X;
end;

procedure TMultiGrid.TopLeftChanged;
begin
  if Assigned(FOnTopLeftChange) then FOnTopLeftChange(self);
end;

function TMultiGrid.GetThumbTrack: Boolean;
begin
  Result := goThumbTracking in Options;
end;

procedure TMultiGrid.SetThumbTrack(value: Boolean);
begin
  if value then Options := Options + [goThumbTracking]
  else Options := Options - [goThumbTracking];
end;

procedure TMultiGrid.SetDropFocus(value: Integer);
begin
  if FDropFocus <> Value then
  begin
    if FDropFocus <> -1 then
      Canvas.DrawFocusRect(CellBounds(FDropFocus));
    if value <> -1 then
      Canvas.DrawFocusRect(CellBounds(value));
    FDropFocus := value;
  end;
end;

procedure Register;
begin
  RegisterComponents('Calmira', [TMultiGrid]);
end;

end.

