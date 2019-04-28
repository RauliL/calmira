{*********************************************************}
{                                                         }
{    Calmira System library 3.3                           }
{    by Li-Hsin Huang & Erwin Dokter                      }
{    released into the public domain may 2002             }
{                                                         }
{*********************************************************}

unit IconDlg;

{ The 'missing' dialog.  Execute will display a modal dialog showing all
  icons in a given file, and allows the user to browse other files.
  Returns filename and icon index. }

interface

uses SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  Forms, Dialogs, StdCtrls, Grids, Buttons, Picbtn;

type
  TIconDialog = class(TComponent)
  private
    { Private declarations }
    FFilename: TFilename;
    FIndex: Word;
    FHistory: TStrings;
    procedure SetHistory(Value: TStrings);
  protected
    { Protected declarations }
  public
    { Public declarations }
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    function Execute: Boolean;
  published
    { Published declarations }
    property Filename: TFilename read FFilename write FFilename;
    property Index: Word read FIndex write FIndex default 0;
    property HistoryList: TStrings read FHistory write SetHistory;
  end;

type
  TIconSelForm = class(TForm)
    FileEdit: TComboBox;
    Grid: TDrawGrid;
    Label1: TLabel;
    Label2: TLabel;
    OpenDialog: TOpenDialog;
    OKBtn: TPicBtn;
    CancelBtn: TPicBtn;
    BrowseBtn: TPicBtn;
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure GridDrawCell(Sender: TObject; Col, Row: Longint; Rect: TRect;
      State: TGridDrawState);
    procedure GridSelectCell(Sender: TObject; Col, Row: Longint;
      var CanSelect: Boolean);
    procedure BrowseBtnClick(Sender: TObject);
    procedure FileEditExit(Sender: TObject);
    procedure GridDblClick(Sender: TObject);
    procedure OKBtnClick(Sender: TObject); { 3.11 }
  private
    { Private declarations }
    Icons: TList;
    FIconIndex: Integer;
    FIconFilename: TFilename; { 3.11 }
    procedure SearchFile(const Filename: TFilename);
  public
    { Public declarations }
    property IconIndex: Integer read FIconIndex write FIconIndex;
    property IconFilename: TFilename read FIconFilename
      write FIconFilename; { 3.11 }
  end;

const
  NotifyNoIcons: Boolean = False;

var
  IconSelForm: TIconSelForm;

procedure Register;

implementation

{$R *.DFM}

uses MiscUtil, Environs, ShellAPI;

{ Icon Dialog component}

constructor TIconDialog.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FFilename := '';
  FIndex := 0;
  FHistory := TStringList.Create;
end;

destructor TIconDialog.Destroy;
begin
  FHistory.Free;
  inherited Destroy;
end;

procedure TIconDialog.SetHistory(Value: TStrings);
begin
  FHistory.Assign(Value);
end;

function TIconDialog.Execute: Boolean;
begin
  with TIconSelForm.Create(Application) do
  try
    IconFilename := Filename;
    IconIndex := Index;
    FileEdit.Items.Assign(FHistory);
    if ShowModal = mrOK then
    begin
      Result := True;
      Filename := IconFilename;
      Index := Grid.Col;
      with FHistory do
      begin
        if IndexOf(Filename) = -1 then Insert(0, Filename);
        while (Count > 0) and (Count > MaxHistorySize) do Delete(Count - 1);
      end;
    end
    else Result := False;
  finally
    Release;
  end;
end;

{ Select Icon Dialog form }

procedure TIconSelForm.SearchFile(const Filename: TFilename);
var
  i: Integer;
  h: HIcon;
  s: array[0..79] of Char;
begin
  IconFilename := Lowercase(Filename);
  Update;
  h := ExtractIcon(HInstance, StrPCopy(s, EnvironSubst(IconFilename)), 0);
  if h <= 1 then
  begin
    StrPCopy(s, Application.ExeName);
    IconFilename := Lowercase(Application.ExeName);
    if NotifyNoIcons then
      MessageDlg(Format('There are no icons in this file. Please choose ' +
        'one from %s', [ExtractFilename(IconFilename)]),
        mtInformation, [mbOK], 0);
  end
  else DestroyIcon(h);
  FileEdit.Text := IconFilename; { 3.11 }
  Screen.Cursor := crHourGlass;
  try
    for i := 0 to Icons.Count - 1 do DestroyIcon(Word(Icons[i]));
    Icons.Clear;
    i := 0;
    h := ExtractIcon(HInstance, s, i);
    while h > 1 do
    begin
      Icons.Add(Pointer(h));
      Inc(i);
      h := ExtractIcon(HInstance, s, i);
    end;
    Grid.ColCount := Icons.Count;
    if IconIndex >= Icons.Count then IconIndex := Icons.Count - 1;
    Grid.Col := IconIndex;
    IconIndex := 0;
  finally
    Screen.Cursor := crDefault;
  end;
  Grid.Invalidate;
end;

procedure TIconSelForm.FormCreate(Sender: TObject);
begin
  Icons := TList.Create;
  IconFilename := '';
  IconIndex := 0;
end;

procedure TIconSelForm.FormShow(Sender: TObject);
begin
  if IconFilename = '' then begin
    IconFilename := LowerCase(Application.ExeName);
    IconIndex := 0;
  end;
  FileEdit.Text := IconFilename;
  SearchFile(IconFilename);
end;

procedure TIconSelForm.FormDestroy(Sender: TObject);
var
  i: Integer;
begin
  for i := 0 to Icons.Count - 1 do DestroyIcon(Word(Icons[i]));
end;

procedure TIconSelForm.GridDrawCell(Sender: TObject; Col, Row: Longint;
  Rect: TRect; State: TGridDrawState);
begin
  if Col < Icons.Count then
    DrawIcon(Grid.Canvas.Handle, Rect.Left + 4, Rect.Top + 4, HIcon(Icons[Col]));
end;

procedure TIconSelForm.GridSelectCell(Sender: TObject; Col, Row: Longint;
  var CanSelect: Boolean);
begin
  CanSelect := Col < Icons.Count;
end;

procedure TIconSelForm.BrowseBtnClick(Sender: TObject);
begin
  with OpenDialog do
  begin
    Filename := IconFilename;
    if Execute then SearchFile(Filename);
  end;
end;

procedure TIconSelForm.FileEditExit(Sender: TObject);
begin
  if CompareText(FileEdit.Text, IconFilename) <> 0 then
    SearchFile(FileEdit.Text);
end;

procedure TIconSelForm.GridDblClick(Sender: TObject);
begin
  OKBtn.Click;
end;

procedure TIconSelForm.OKBtnClick(Sender: TObject);
begin
  if ActiveControl = FileEdit then
  begin
    ModalResult := mrNone;
    Grid.SetFocus;
  end;
end;

procedure Register;
begin
  RegisterComponents('Dialogs', [TIconDialog]);
end;

end.

