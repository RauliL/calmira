{*********************************************************}
{                                                         }
{    Calmira System library 3.3                           }
{    by Li-Hsin Huang & Erwin Dokter                      }
{    released into the public domain may 2002             }
{                                                         }
{*********************************************************}

unit DragDrop;

{ TDragDrop is an abstract base class for TDropServer and TDropClient.
  It defines the Files and AutoClear properties.  To add more
  funtionality to both TDropServer or TDropClient (e.g., methods to
  process filenames), write the code for TDragDrop instead. }

interface

uses SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  Forms, Dialogs;

type
  TDragDrop = class(TComponent)
  private
    { Private declarations }
    FFiles: TStrings;
    FAutoClear: Boolean;
    procedure SetFiles(list: TStrings);
  protected
    { Protected declarations }
  public
    { Public declarations }
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    property Files: TStrings read FFiles write SetFiles;
  published
    { Published declarations }
    property AutoClear: Boolean read FAutoClear write FAutoClear default True;
  end;

implementation

constructor TDragDrop.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FFiles := TStringList.Create;
  FAutoClear := True;
end;

destructor TDragDrop.Destroy;
begin
  FFiles.Free;
  inherited Destroy;
end;

procedure TDragDrop.SetFiles(list: TStrings);
begin
  FFiles.Assign(list);
end;

end.

