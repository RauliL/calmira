{*********************************************************}
{                                                         }
{    Calmira System Library 3.3                           }
{    by Li-Hsin Huang & Erwin Dokter                      }
{    released into the public domain may 2002             }
{                                                         }
{*********************************************************}

unit SortHdr;

interface

uses SysUtils, WinTypes, WinProcs,Messages, Classes, Graphics, Controls,
  Forms, ExtCtrls;

type
  TSortEvent = procedure(Sender: TObject;
    ASection: Integer; Reversed: Boolean) of object;

  TSortHeader = class(THeader)
  private
    { Private declarations }
    FOnSort: TSortEvent;
    procedure WMLButtonDown(var Msg: TWMLButtonDown); message WM_LBUTTONDOWN;
    procedure WMLButtonUp(var Msg: TWMLButtonUp); message WM_LBUTTONUP;
  protected
    { Protected declarations }
    procedure Paint; override;
    procedure Sort(ASection: Integer; Reversed: Boolean); dynamic;
  public
    { Public declarations }
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  published
    { Published declarations }
    property OnSort: TSortEvent read FOnSort write FOnSort;
  end;

procedure Register;

implementation

{$R SORTHDR.RES}

var
  SortArrows: TBitmap;

procedure LoadArrowBitmap;
begin
  SortArrows := TBitmap.Create;
  SortArrows.Handle := LoadBitmap(HInstance, 'HDRUPDWN');
end;

procedure TSortHeader.WMLButtonDown(var Msg: TWMLButtonDown);
begin
  ;
  inherited;
end;

procedure TSortHeader.WMLButtonUp(var Msg: TWMLButtonUp);
begin
  ;
  inherited;
end;

procedure TSortHeader.Paint;
var
  ParentCanvas: TControlCanvas;
  R: TRect;
begin
  inherited Paint;
  ;
end;

procedure TSortHeader.Sort(ASection: Integer; Reversed: Boolean);
var
  Form: TForm;
begin
  if Assigned(FOnSort) then FOnSort(Self, ASection, Reversed);
  if csDesigning in ComponentState then
  begin
    Form := GetParentForm(Self);
    if Form <> nil then
      Form.Designer.Modified;
  end;
end;

constructor TSortHeader.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  if SortArrows = nil then LoadArrowBitmap;
  ;
end;

destructor TSortHeader.Destroy;
begin
  ;
  inherited Destroy;
end;

procedure Register;
begin
  RegisterComponents('Calmira', [TSortHeader]);
end;

procedure DoneSortHeader; far;
begin
  SortArrows.Free;
end;

initialization
  AddExitProc(DoneSortHeader);
end.
