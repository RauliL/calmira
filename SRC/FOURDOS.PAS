{**************************************************************************}
{                                                                          }
{    Calmira II shell for Microsoft® Windows(TM) 3.1                       }
{    Online! Release 3.3                                                  }
{    Copyright (C) 1998-2002 Calmira Online!                               }
{    Copyright (C) 1997-1998 Li-Hsin Huang                                 }
{                                                                          }
{    This program is free software; you can redistribute it and/or modify  }
{    it under the terms of the GNU General Public License as published by  }
{    the Free Software Foundation; either version 2 of the License, or     }
{    (at your option) any later version.                                   }
{                                                                          }
{    This program is distributed in the hope that it will be useful,       }
{    but WITHOUT ANY WARRANTY; without even the implied warranty of        }
{    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the         }
{    GNU General Public License for more details.                          }
{                                                                          }
{    You should have received a copy of the GNU General Public License     }
{    along with this program; if not, write to the Free Software           }
{    Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.             }
{                                                                          }
{**************************************************************************}

unit FourDOS;

{ 4DOS file descriptions

  The main problem with supporting descriptions is maintaining consistency.
  An obvious solution would be to associate a PString with each TDirItem
  object.  But considering the turmoil during copying and moving, keeping
  track of everything would be very difficult during updating. Also, not
  all files are shown at once (depending on the filter), so the need to
  reconcile the disk file with the memory descriptions would complicate
  matters.

  Hence the current implementation uses a centralized approach.  The
  entire set of descriptions is kept inside a TStringList, one for each
  TDirectory.  When we need to find a description, the list must be
  searched, but updating is OK since there are no pointers floating around
  as with the PString approach, and consistency is guaranteed because each
  TStringList exactly mirrors a descript.ion file.

  The Directry unit contains optimizations to avoid accessing the list
  when it is already known that an object doesn't have a description.  A
  further speedup is obtained by storing a pointer to the TDirItem
  object so that a full string search occurs rarely.

  This unit assumes that a "description" is the entire string following the
  first space character.  Actually, there may be 04 markers (Ctrl-D) in the
  text which indicates extra data maintained by programs other than 4DOS.
  These are filtered and maintained by each TDirItem because it would be
  too complicated to regard the data as another "column" when replacing the
  strings in the list.

  4DOS is a registered trademark of JP Software Inc. }

interface

uses Classes, SysUtils;

type
  TDescriptions = class(TStringList)
  private
    FModified: Boolean;
  protected
    procedure Changed; override;
  public
    function Get(const filename: string; Item: TObject): string;
    procedure Put(const filename: string; Item: TObject;
      const value: string);
    procedure LoadFromPath(const path: TFilename);
    procedure SaveToPath(const path: TFilename);
    property Modified: Boolean read FModified;
  end;

procedure MergeDescriptionFiles(TargetDir, SourceDir : TFilename);

var
  SharedDesc : TDescriptions;
  { a special shared description file used during copying }

implementation

uses Directry, Strings, Settings;

procedure TDescriptions.Changed;
begin
  inherited Changed;
  FModified := True;
end;

function TDescriptions.Get(const filename: string;
  Item: TObject): string;
var
  i, p, compare: Integer;
  s: string;
begin
  { Retrieves a file description.  If the Item parameter is nil,
    the object pointers are ignored. }
  Result := '';
  if Count = 0 then Exit;
  if Item = nil then i := -1
  else i:= IndexOfObject(Item);
  if i > -1 then
  begin
    { found an object match }
    s := Strings[i];
    p := Pos(' ', s);
    Result := Copy(s, p + 1, 255);
  end
  else
  begin
    { must do a string search }
    for i := 0 to Count - 1 do
    begin
      s := Strings[i];
      p := Pos(' ', s);
      if CompareText(Copy(s, 1, p - 1), filename)= 0 then
      begin
        Objects[i] := Item;
        Result := Copy(s, p + 1, 255);
        Exit;
      end
    end;
  end;
end;

procedure TDescriptions.Put(const filename: string; Item: TObject;
  const value: string);
var
  i, p: Integer;
  s: string;
begin
  if Item = nil then i := -1
  else i := IndexOfObject(Item);
  if i > -1 then
    { found an object match }
    if value = '' then Delete(i)
    else Strings[i] := Format('%s %s', [filename, value])
  else
  begin
    { must do a string search }
    for i := 0 to Count - 1 do
    begin
      s := Strings[i];
      p := Pos(' ', s);
      if CompareText(Copy(s, 1, p-1), filename) = 0 then
      begin
        if value = '' then Delete(i)
        else
        begin
          Objects[i] := Item;
          Strings[i] := Format('%s %s', [filename, value]);
        end;
        Exit;
      end;
    end;
    if value > '' then
      AddObject(filename + ' ' + value, Item);
  end;
end;

procedure TDescriptions.LoadFromPath(const path: TFilename);
var
  rec: TSearchRec;
  code: Integer;
begin
  Clear;
  FModified := False;
  code := FindFirst(path + DescriptionFile, faHidden, rec);
  {if code = -3 then
    raise EScanError.CreateFmt('Cannot open %s', [MakeDirname(path)])
  else} if code = 0 then
    inherited LoadFromFile(path + DescriptionFile);
  FindClose(rec); { 3.11 }
end;

procedure TDescriptions.SaveToPath(const path: TFilename);
var
  filename: TFilename;
begin
  if FModified then
  begin
    filename := path + DescriptionFile;
    if Count = 0 then DeleteFile(filename)
    else
    begin
      FileSetAttr(filename, faArchive);
      inherited SaveToFile(filename);
      FileSetAttr(filename, faArchive or faHidden);
    end;
    FModified := False;
  end;
end;

procedure MergeDescriptionFiles(TargetDir, SourceDir: TFilename);
var
  src, dest: TDescriptions;
  s: string;
  i, p: Integer;
begin
  src := TDescriptions.Create;
  dest := TDescriptions.Create;
  AppendStr(TargetDir, '\');
  AppendStr(SourceDir, '\');
  try
    src.LoadFromPath(SourceDir);
    dest.LoadFromPath(TargetDir);
    for i := src.Count - 1 downto 0 do
    begin
      s := src[i];
      p := Pos(' ', s);
      if p > 0 then dest.Put(Copy(s, 1, p - 1), nil, Copy(s, p + 1, 255));
    end;
    dest.SaveToPath(TargetDir);
  finally
    src.Free;
    dest.Free;
  end;
end;

procedure DoneFourDOS; far;
begin
  SharedDesc.Free;
end;

initialization
  AddExitProc(DoneFourDOS);
  SharedDesc := TDescriptions.Create;
end.

