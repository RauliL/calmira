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

unit Progress;

interface

uses SysUtils, Classes, Controls, Forms, StdCtrls, Buttons, ExtCtrls,
  BarGauge, Picbtn;

type
  TFileOperation = (foCopy, foMove, foDelete, foBinning,
    foRestoring, foEmptying);

  TProgressBox = class(TForm)
    Image: TImage;
    FileLabel: TLabel;
    FromText: TLabel;
    FromLabel: TLabel;
    ToText: TLabel;
    ToLabel: TLabel;
    CopiedLabel: TLabel;
    BytesLabel: TLabel;
    Gauge: TWin95Gauge;
    CancelBtn: TPicBtn;
    procedure CancelBtnClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormHide(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
    FAbortOp: Boolean;
    LastOp: TFileOperation;
    LastDisplayTime: Longint;
    ShowingBytes: Boolean;
  public
    { Public declarations }
    property AbortOp: Boolean read FAbortOp;
    procedure UpdateGauge;
    procedure UpdateLabel(const source, dest: TFilename);
    procedure Init(Op: TFileOperation; Count: Integer);
    procedure CheckForAbort;
    procedure Hide;
    procedure ChangeByteDisplay;
  end;

var
  ProgressBox: TProgressBox;

implementation

{$R *.DFM}

uses Settings, Strings, Desk, Replace, Locale, WinProcs, Resource, Files,
  MiscUtil;

const FileOpMessages: array[TFileOperation] of Word =
  (SProgressCopy, SProgressMove, SProgressDelete, SProgressBinning,
   SProgressRestoring, SProgressEmptying);

procedure TProgressBox.UpdateGauge;
begin
  Gauge.AddProgress(1);
end;

procedure TProgressBox.UpdateLabel(const source, dest: TFilename);
begin
  if LastOp >= foBinning then Exit;
  FileLabel.Caption := ExtractFilename(source);
  with FromLabel do
    Caption := MinimizeName(ExtractFileDir(source), Canvas, Width);
  with ToLabel do
    Caption := MinimizeName(ExtractFileDir(dest), Canvas, Width);
  FromLabel.Update;
  ToLabel.Update;
end;

procedure TProgressBox.Init(Op: TFileOperation; Count: Integer);
var
  i: Integer;
begin
  LastOp := Op;
  if Op in [foCopy, foMove] then
  begin
    FileLabel.Caption := '';
    FromText.Show;
    ToText.Show;
    FromLabel.Caption := '';
    FromLabel.Show;
    ToLabel.Caption := '';
    ToLabel.Show;
  end
  else
  begin
    FileLabel.Caption := 'Please wait...';
    FromText.Hide;
    FromLabel.Hide;
    ToText.Hide;
    ToLabel.Hide;
  end;
  ShowingBytes := False;
  BytesCopied := 0;
  ChangeByteDisplay;
  Caption := LoadStr(FileOpMessages[Op]);
  FAbortOp := False;
  Gauge.Progress := 0;
  Gauge.MaxValue := Count;
  Show;
  Update;
end;

procedure TProgressBox.CancelBtnClick(Sender: TObject);
begin
  FAbortOp := True;
end;

procedure TProgressBox.FormShow(Sender: TObject);
begin
  with Gauge do
  begin
    ForeColor := Colors[ccPercent];
    BackColor := Colors[ccPercentBack];
  end;
  Desktop.EnableForms(False);
end;

procedure TProgressBox.FormHide(Sender: TObject);
begin
  FAbortOp := False;
  Desktop.EnableForms(True);
  FreeAndNil(ReplaceBox);
  DestroyHandle;
end;

procedure TProgressBox.CheckForAbort;
var
  t: Longint;
begin
  { 2.2 }
  if (BytesCopied > 0) and not ShowingBytes then begin
    ShowingBytes := True;
    ChangeByteDisplay;
  end;
  if ShowingBytes then begin
    t := GetTickCount;
    if t - LastDisplayTime > 500 then begin
      BytesLabel.Caption := FormatByteLong(BytesCopied);
      LastDisplayTime := t;
    end;
  end;
  Application.ProcessMessages;
  if FAbortOp then Abort;
end;

procedure TProgressBox.Hide;
begin
  inherited Hide;
  DestroyHandle;
end;

procedure TProgressBox.FormCreate(Sender: TObject);
begin
  Image.Picture.Icon.Assign(Icons.Get('ProgressDialog'));
end;

procedure TProgressBox.ChangeByteDisplay;
begin
  if not (LastOp in [foMove, foCopy, foBinning, foRestoring]) then
    ShowingBytes := False;
  CopiedLabel.Visible := ShowingBytes;
  BytesLabel.Visible := ShowingBytes;
end;

end.

