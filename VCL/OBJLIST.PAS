{*********************************************************}
{                                                         }
{    Calmira System library 3.3                           }
{    by Li-Hsin Huang & Erwin Dokter                      }
{    released into the public domain may 2002             }
{                                                         }
{*********************************************************}

unit ObjList;

{ TObjectList is a simple descendant of TList that assumes each item
  is a descendant of TObject.  It defines two new methods :

  ClearObjects calls Free for each pointer before clearing the list.
  FreeObject calls Free for a list item before calling Delete.

  Destroy is overriden to free all objects. }

interface

uses Classes;

type
  TObjectList = class(TList)
  public
    { Public declarations }
    destructor Destroy; override;
    procedure ClearObjects;
    procedure FreeObject(i: Integer);
  end;

implementation

destructor TObjectList.Destroy;
begin
  ClearObjects;
  inherited Destroy;
end;

procedure TObjectList.ClearObjects;
var
  i: Integer;
begin
  for i := 0 to Count - 1 do TObject(List^[i]).Free;
  Clear;
end;

procedure TObjectList.FreeObject(i: Integer);
begin
  TObject(Items[i]).Free;
  Delete(i);
end;

end.

