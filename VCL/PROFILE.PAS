{*********************************************************}
{                                                         }
{    Calmira System library 3.3                           }
{    by Li-Hsin Huang & Erwin Dokter                      }
{    released into the public domain may 2002             }
{                                                         }
{*********************************************************}

unit Profile;

{ TProfile is a simple extension of TIniFile that can read and
  write string lists, and properties of fonts and headers.
  It also contains 'missing' methods ported from D2 IniFiles.

  The strings and headers are stored in the way Delphi stores
  INI lists, e.g.

  [Strings]
  Count=2
  S0=abc
  S1=def

  Fonts are written so that the values can easily be edited, e.g.

  [Main window]
  FontName=MS Sans Serif
  FontSize=8
  FontStyle=Bold Italic }

interface

uses IniFiles, Classes, Graphics, ExtCtrls;

type
  TProfile = class(TIniFile)
  public
    { Public declarations }
    procedure DeleteKey(const Section, Ident: string); { 3.0 }
    procedure ReadSections(S: TStrings); { 3.1 }
    procedure WriteSectionValues(const Section: string; S: TStrings);
    procedure ReadStrings(const Section: string; S: TStrings);
    procedure ReadNewStrings(const Section: string; S: TStrings);
    procedure WriteStrings(const Section: string; S: TStrings);
    procedure WriteNewStrings(const Section: string; S: TStrings);
    function ReadColor(const Section, Ident: string; Default: TColor): TColor;
    procedure WriteColor(const Section, Ident: string; Value: TColor);
    function ReadFont(const Section: string; Font: TFont): TFont;
    procedure WriteFont(const Section: string; Font: TFont);
    function ReadHeader(const Section: string; Header: THeader): THeader;
    procedure WriteHeader(const Section: string; Header: THeader);
  end;

implementation

uses SysUtils, WinProcs, Strings;

procedure TProfile.DeleteKey(const Section, Ident: string); { 3.0 }
var
  CSection: array[0..127] of Char;
  CIdent: array[0..127] of Char;
  CFileName: array[0..79] of Char;
begin
  WritePrivateProfileString(StrPLCopy(CSection, Section, SizeOf(CSection) - 1),
    StrPLCopy(CIdent, Ident, SizeOf(CIdent) - 1), nil,
    StrPLCopy(CFileName, FileName, SizeOf(CFileName) - 1));
end;

procedure TProfile.ReadSections(S: TStrings); { 3.1 }
{ The method Delphi uses under Win32 (section = nil) to get
  all the section names, does not work under 16-bit Windows.
  We have to scan the file ourselves. }
var
  f: TextFile;
  str: string;
begin
  AssignFile(f, FileName);
  try
    Reset(f);
    while not Eof(f) do
    begin
      Readln(f, str);
      if (str > '') and (str[1] = '[') then
        S.Add(Copy(str, 2, Length(str) - 2));
    end;
  finally
    CloseFile(f);
  end;
end;

procedure TProfile.WriteSectionValues(const Section: string; S: TStrings);
var
  i: Integer;
begin
  for i := 0 to S.Count - 1 do
    WriteString(Section, GetStrKey(S[i]), GetStrValue(S[i]));
end;

procedure TProfile.ReadStrings(const Section: string; S: TStrings);
var
  i: Integer;
begin
  for i := 0 to ReadInteger(Section, 'Count', 0) - 1 do
    S.Add(ReadString(section, 'S' + IntToStr(i), ''));
end;

procedure TProfile.ReadNewStrings(const Section: string; S: TStrings);
begin
  S.Clear;
  ReadStrings(Section, S);
end;

procedure TProfile.WriteStrings(const Section: string; S: TStrings);
var
  i: Integer;
begin
  WriteInteger(Section, 'Count', S.Count);
  for i := 0 to S.Count - 1 do
    WriteString(Section, 'S' + IntToStr(i), S[i]);
end;

procedure TProfile.WriteNewStrings(const Section: string; S: TStrings);
begin
  EraseSection(Section);
  WriteStrings(Section, S);
end;

function TProfile.ReadColor(const Section, Ident: string;
  Default: TColor): TColor;
begin
  try
    Result := StringToColor(ReadString(Section, Ident,
      ColorToString(Default)));
  except
    Result := Default;
  end;
end;

procedure TProfile.WriteColor(const Section, Ident: string; Value: TColor);
begin
  WriteString(Section, Ident, ColorToString(Value));
end;

function TProfile.ReadFont(const Section: string; Font: TFont): TFont;
var
  s: string[32];
  fs: TFontStyles;
begin
  Result := Font;
  with Result do
  begin
    Name := ReadString(Section,  'FontName', Name);
    Size := ReadInteger(Section, 'FontSize', Size);
    Color := ReadColor(Section, 'FontColor', Color);
    fs := [];
    s := Lowercase(ReadString(Section, 'FontStyle', ''));
    if s > '' then
    begin
      if Pos('bold', s) > 0 then Include(fs, fsBold);
      if Pos('italic', s) > 0 then Include(fs, fsItalic);
      if Pos('underline', s) > 0 then Include(fs, fsUnderline);
      if Pos('strikeout', s) > 0 then Include(fs, fsStrikeOut);
    end;
    Style := fs;
  end;
end;

procedure TProfile.WriteFont(const Section: string; Font: TFont);
var
  s: string[32];
begin
  with Font do begin
    WriteString(Section, 'FontName', Name);
    WriteInteger(Section, 'FontSize', Size);
    WriteColor(Section, 'FontColor', Color);
    s := '';
    if fsBold in Style then AppendStr(s, 'Bold ');
    if fsItalic in Style then AppendStr(s, 'Italic ');
    if fsUnderline in Style then AppendStr(s, 'Underline ');
    if fsStrikeOut in Style then AppendStr(s, 'Strikeout ');
    WriteString(Section, 'FontStyle', s);
  end;
end;

function TProfile.ReadHeader(const Section: string; Header: THeader): THeader;
var
  i, w: Integer;
begin
  Result := Header;
  for i := 0 to ReadInteger(Section, 'SectionCount', 1) - 1 do
    with Result do
      if i < Sections.Count then
      begin
        w := ReadInteger(Section, 'Section' + IntToStr(i), -1);
        if w > -1 then SectionWidth[i] := w;
      end;
end;

procedure TProfile.WriteHeader(const Section: string; Header: THeader);
var
  i: Integer;
begin
  with Header do
  begin
    WriteInteger(Section, 'SectionCount', Sections.Count);
    for i := 0 to Sections.Count - 1 do
      WriteInteger(Section, 'Section' + IntToStr(i), SectionWidth[i]);
  end;
end;

end.

