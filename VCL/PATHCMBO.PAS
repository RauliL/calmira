{*********************************************************}
{                                                         }
{    Calmira System library 3.3                           }
{    by Li-Hsin Huang & Erwin Dokter                      }
{    released into the public domain may 2002             }
{                                                         }
{*********************************************************}

unit PathCmbo;

{ Enhanced TComboBox control. }

interface

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Controls, StdCtrls,
  Graphics, Menus;

type
  TPathComboBox = class(TCustomComboBox)
  private
    { Private declarations }
    FDrawingEdit: Boolean;
    FItemHeight: Integer;
    FStyle: TComboBoxStyle;
    FPath: TFilename;
    procedure CNDrawItem(var Message: TWMDrawItem); message CN_DRAWITEM;
    procedure CNMeasureItem(var Message: TWMMeasureItem); message CN_MEASUREITEM;
    procedure WMMeasureItem(var Message: TWMMeasureItem); message WM_MEASUREITEM;
    procedure ClearSubLevels;
    function FindDriveIndex(const Drive: Char): Integer;
    procedure SetPath(const Value: TFilename);
    function GetPath: TFilename;
  protected
    { Protected declarations }
    procedure Change; override;
  public
    { Public declarations }
    property DrawingEdit: Boolean read FDrawingEdit;
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure BuildDrives;
    function GetItemPath(Index: Integer): string;
    property Path: TFilename read GetPath write SetPath;
  published
    { Published declarations }
    property Style; {Must be published before Items}
    property Color;
    property Ctl3D;
    property DragMode;
    property DragCursor;
    property DropDownCount;
    property Enabled;
    property Font;
    property ItemHeight;
    property Items;
    property MaxLength;
    property ParentColor;
    property ParentCtl3D;
    property ParentFont;
    property ParentShowHint;
    property PopupMenu;
    property ShowHint;
    property Sorted;
    property TabOrder;
    property TabStop;
    property Text;
    property Visible;
    property OnChange;
    property OnClick;
    property OnDblClick;
    property OnDragDrop;
    property OnDragOver;
    property OnDrawItem;
    property OnDropDown;
    property OnEndDrag;
    property OnEnter;
    property OnExit;
    property OnKeyDown;
    property OnKeyPress;
    property OnKeyUp;
    property OnMeasureItem;
  end;

procedure Register;

implementation

uses Strings;

procedure TPathComboBox.CNDrawItem(var Message: TWMDrawItem);
var
  State: TOwnerDrawState;
begin
  with Message.DrawItemStruct^ do
    { StdCtrl bugfix:
      Inflate OwnerDraw Rect when drawing in Edit. }
    if (rcItem.Bottom - rcItem.Top) <> FItemHeight then
    begin
      InflateRect(rcItem, 1, 1);
      FDrawingEdit := True;
    end
    else
      FDrawingEdit := False;
  inherited;
end;

procedure TPathComboBox.CNMeasureItem(var Message: TWMMeasureItem);
begin
  with Message.MeasureItemStruct^ do
  begin
    { StdCtrl bugfix:
      Decrease initial ItemHeight with 2 in order to force the proper
      height.  Called when the combobox is created. }
    itemHeight := FItemHeight - 2;
    if FStyle = csOwnerDrawVariable then
      MeasureItem(itemID, Integer(itemHeight));
  end;
end;

procedure TPathComboBox.WMMeasureItem(var Message: TWMMeasureItem);
begin
  { StdCtrl bugfix:
    This is where the listbox ItemHeight is assigned. }
  with Message do
  begin
    MeasureItemStruct^.itemHeight := FItemHeight;
    Result := 1;
  end;
end;

constructor TPathComboBox.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FStyle := csOwnerDrawFixed;
  FItemHeight := 16;
end;

destructor TPathComboBox.Destroy;
begin
  inherited Destroy;
end;

procedure TPathComboBox.ClearSubLevels;
var
  i: Integer;
begin
  for i := Items.Count - 1 downto 0 do
    if Longint(Items.Objects[i]) > 1 then Items.Delete(i);
end;

function TPathComboBox.FindDriveIndex(const Drive: Char): Integer;
var
  i: Integer;
begin
  for Result := 0 to Items.Count - 1 do
    if Pos(Upcase(Drive) + ':', Items[Result]) > 0 then Exit;
end;

function GetLevel(s: string): Integer;
var
  i: Integer;
begin
  Result := 0;
  for i := 1 to Length(s) do
    if s[i] = '\' then Inc(Result);
end;

procedure TPathComboBox.SetPath(const Value: TFilename);
var
  i, j, k: Integer;
  s: string[79];
begin
  ClearSubLevels;
  FPath := Value;
  if FPath = '' then
  begin
    ItemIndex := 0;
    Exit;
  end;
  s := Value;
  i := FindDriveIndex(s[1]);
  if Length(s) > 3 then
  begin
    j := GetLevel(s) + 1; { level }
    k := j - 1;
    while Length(s) > 3 do
    begin
      Items.InsertObject(i + 1, '(' + s + ')', Pointer(j));
      s := ExtractFileDir(s);
      Dec(j);
    end;
    ItemIndex := i + k;
  end
  else ItemIndex := i;
end;

function TPathComboBox.GetPath: TFilename;
begin
  Result := FPath;
end;

procedure TPathComboBox.Change;
begin
  if ItemIndex = 0 then
  begin
    ClearSubLevels;
    FPath := '';
  end
  else
    Path := GetItemPath(ItemIndex);
  inherited Change;
end;

procedure TPathComboBox.BuildDrives;
var
  Letter: Char;
begin
  FPath := '';
  Items.Clear;
  Items.AddObject('(root)', Pointer(0));
  for Letter := 'A' to 'Z' do
    if GetDriveType(Ord(Letter) - 65) <> 0 then
      Items.AddObject('(' + Letter + ':)', Pointer(1));
end;

function TPathComboBox.GetItemPath(Index: Integer): string;
begin
  Unformat(Items[Index], '%S(%s)', [@Result, 79]);
  if Length(Result) = 2 then AppendStr(Result, '\');
end;

procedure Register;
begin
  RegisterComponents('Calmira', [TPathComboBox]);
end;

end.

