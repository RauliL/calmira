{*********************************************************}
{                                                         }
{    Calmira System library 3.3                           }
{    by Li-Hsin Huang & Erwin Dokter                      }
{    released into the public domain may 2002             }
{                                                         }
{*********************************************************}

unit Drives;

{ Disk drive functions }

interface

type
  TFileAttr = (ftReadOnly, ftHidden, ftSystem, ftVolumeID, ftDirectory,
    ftArchive, ftNormal);
  TFileType = set of TFileAttr;

  TDriveType = (dtUnknown, dtNoDrive, dtFloppy, dtFixed, dtNetwork, dtCDROM,
    dtRAM);

  TDriveRange = 'A'..'Z';
  TDriveFlag = (dfValid, dfFloppy, dfFixed, dfNetwork, dfCDROM, dfRAM,
    dfRemoveable, dfWriteable);
  TDriveFlags = set of TDriveFlag;
  TVolumeLabel = string[11];

const
  DriveDesc : array[TDriveType] of string[15] = ('Unknown drive', 'No drive',
    'Floppy drive', 'Hard drive', 'Network drive', 'CD-ROM drive', 'RAM drive');

var
  ValidDrives: set of TDriveRange;

function DriveNumber(Drive: Char): Integer;
{ Maps drive characters to Integers used by Delphi. A = 1, B = 2, ... }

function WinDriveNumber(Drive: Char): Integer;
{ Maps drive characters to Integers used by Windows. A = 0, B = 1, ... }

procedure DetectDrives;
{ Refreshes this unit's information about drives on the system.
  Called automatically during initialization. }

function SystemDrivesChanged: Boolean;
{ Returns True if driver are added or removed }

function FindDriveType(Drive: Char): TDriveType;
{ Detects the type of the specified drive }

function GuessDriveType(Drive: Char): TDriveType;
{ Returns the type of the drive without needing disk access --
  the information is obtained and stored during initialization }

function GetDriveFlags(drive: Char): TDriveFlags;
{ Returns the flag set for the given drive }

function IsDriveString(const s: string): Boolean;
{ Returns True if string is in the form of 'C:\' }

function IsCDROM(DriveNum: Integer): Boolean;
{ Returns true if the drive is a CD-ROM drive }

function IsRAMDrive(DriveNum: Integer): Boolean;
{ Returns true if the drive is a RAM disk }

function GetNetworkVolume(Drive: Char): string;
{ Returns the network name of the drive if available, otherwise
  just returns the volume label }

function GetVolumeLabel(Drive: Char): TVolumeLabel;
{ Returns the volume label of the disk }

procedure SetVolumeLabel(NewLabel: TVolumeLabel; Drive: Char);
{ Sets the volume label of the disk }

procedure DeleteVolumeLabel(Drive: Char);
{ Deletes the volume label of the disk }

function CDDiskSize(DriveNum: Integer): Longint;
{ Return the ammount of data on a CD-ROM disk }

implementation

uses SysUtils, WinProcs, WinTypes, Strings, MiscUtil;

var
  DriveFlags: array[TDriveRange] of TDriveFlags;
  DriveTypes: array[TDriveRange] of TDriveType;

function DriveNumber(Drive: Char): Integer;
begin
  { A = 1, B = 2 ... }
  Result := Ord(UpCase(Drive)) - Ord('A') + 1;
end;

function WinDriveNumber(Drive: Char): Integer;
begin
  { A = 0, B = 1 ... }
  Result := DriveNumber(Drive) - 1;
end;

procedure DetectDrives;
var
  d: Char;
begin
  ValidDrives := [];
  for d := 'A' to 'Z' do
  begin
    DriveTypes[d] := FindDriveType(d);
    case DriveTypes[d] of
      dtNoDrive : DriveFlags[d] := [];
      dtUnknown : DriveFlags[d] := [dfValid, dfFixed, dfWriteable];
      dtFloppy  : DriveFlags[d] := [dfValid, dfFloppy, dfRemoveable, dfWriteable];
      dtFixed   : DriveFlags[d] := [dfValid, dfFixed, dfWriteable];
      dtNetwork : DriveFlags[d] := [dfValid, dfNetwork, dfWriteable];
      dtCDROM   : DriveFlags[d] := [dfValid, dfCDROM, dfRemoveable];
      dtRAM     : DriveFlags[d] := [dfValid, dfRAM, dfWriteable];
    end;
    if dfValid in DriveFlags[d] then Include(ValidDrives, d);
  end;
end;

function SystemDrivesChanged: Boolean;
var
  d: Char;
begin
  Result := False;
  for d := 'A' to 'Z' do
    if (DriveTypes[d] = dtNoDrive) xor (GetDriveType(WinDriveNumber(d)) = 0) then
    begin
      Result := True;
      Exit;
    end;
end;

function FindDriveType(Drive: Char): TDriveType;
var
  n: Integer;
begin
  n := WinDriveNumber(Drive);
  case GetDriveType(n) of
    0               : Result := dtNoDrive;
    DRIVE_REMOVABLE : Result := dtFloppy;
    DRIVE_FIXED     : if IsRAMDrive(n) then Result := dtRAM
                      else Result := dtFixed;
    DRIVE_REMOTE    : if IsCDROM(n) then Result := dtCDROM
                      else Result := dtNetwork;
  end;
end;

function GuessDriveType(Drive: Char): TDriveType;
begin
  Drive := UpCase(Drive);
  if Drive in ['A'..'Z'] then Result := DriveTypes[Drive]
  else Result := dtNoDrive;
end;

function GetDriveFlags(Drive: Char): TDriveFlags;
begin
  Drive := UpCase(Drive);
  if Drive in ['A'..'Z'] then Result := DriveFlags[Drive]
  else Result := [];
end;

function IsDriveString(const s: string): Boolean;
begin
  Result := (Length(s) = 3) and (UpCase(s[1]) in ['A'..'Z'])
    and (s[2] = ':') and (s[3] = '\');
end;

function IsCDROM(DriveNum: Integer): Boolean; assembler;
asm
        MOV     AX,1500h  { look for MSCDEX }
        XOR     BX,BX
        INT     2Fh
        OR      BX,BX
        JZ      @Finish
        MOV     AX,150Bh  { check for using CD driver }
        MOV     CX,DriveNum
        INT     2Fh
        OR      AX,AX
@Finish:
end;

function IsRAMDrive(DriveNum: Integer): Boolean; assembler;
var
  Temp: Boolean;
asm
        MOV     Temp,False
        PUSH    DS
        MOV     BX,SS
        MOV     DS,BX
        SUB     SP,0200h
        MOV     BX,SP
        MOV     AX,DriveNum
        MOV     CX,1
        XOR     DX,DX
        INT     25h  { read boot sector }
        ADD     SP,2
        JC      @@1
        MOV     BX,SP
        CMP     BYTE PTR SS:[BX+15h],0F8h  { reverify fixed disk }
        JNE     @@1
        CMP     BYTE PTR SS:[BX+10h],1  { check for single FAT }
        JNE     @@1
        MOV     Temp,True
@@1:    ADD     SP,0200h
        POP     DS
        MOV     AL,Temp
end;

function GetNetworkVolume(Drive: Char): string;
const
  LocalName: array[0..2] of Char = 'C:' + #0;
var
  BufSize: Word;
  Buf: array[0..128] of Char;
  s1: string[12];
  s2: string[79];
begin
  LocalName[0] := Drive;
  BufSize := 127;
  if WNetGetConnection(LocalName, Buf, @BufSize) = WN_SUCCESS then
  begin { 3.1 New format }
    if Pos('/', StrPas(Buf)) > 0 then
      Unformat(StrPas(Buf), '%s/%s', [@s1, 15, @s2, 79])
    else
      Unformat(StrPas(Buf), '\\%s\%s', [@s1, 15, @s2, 79]);
    Result := Capitalize(s2) + ' on ''' + Capitalize(s1) + '''';
  end
  else
    Result := Capitalize(Trim(GetVolumeLabel(Drive)));
end;

{ Procedures for getting, setting and deleting and deleting volume
  labels from a floppy or hard disk.  GetVolumeLabel uses FindFirst
  function.  SetVolumeLabel and DeleteVolumeLabel involves calling
  DOS interrupt 21h, functions 16h and 13h respectively. Since
  Windows does not support function 16h, it must be called using
  DPMI interrupt 31h, function 300h. }

type
  EDPMIError = class(Exception);
  EVolumeLabelError = class(Exception);

  PRealModeRegs = ^TRealModeRegs;
  TRealModeRegs = record
    case Integer of
      0: (EDI, ESI, EBP, EXX, EBX, EDX, ECX, EAX: Longint;
          Flags, ES, DS, FS, GS, IP, CS, SP, SS: Word);
      1: (DI, DIH, SI, SIH, BP, BPH, XX, XXH: Word;
          case Integer of
            0: (BX, BXH, DX, DXH, CX, CXH, AX, AXH: Word);
            1: (BL, BH, BLH, BHH, DL, DH, DLH, DHH,
                CL, CH, CLH, CHH, AL, AH, ALH, AHH: Byte));
  end;

  PExtendedFCB = ^TExtendedFCB;
  TExtendedFCB = Record
    ExtendedFCBflag: Byte;
    Reserved1      : array[1..5] of Byte;
    Attr           : Byte;
    DriveID        : Byte;
    FileName       : array[1..8] of Char;
    FileExt        : array[1..3] of Char;
    CurrentBlockNum: Word;
    RecordSize     : Word;
    FileSize       : LongInt;
    PackedDate     : Word;
    PackedTime     : Word;
    Reserved2      : array[1..8] of Byte;
    CurrentRecNum  : Byte;
    RandomRecNum   : LongInt;
  end;

{ RealModeInt invokes int 31h function 0300h to simulate
  a real mode interrupt from protected mode. }

procedure RealModeInt(Int: Byte; var Regs: TRealModeRegs);
var
  ErrorFlag: Boolean;
begin
  asm
    MOV     ErrorFlag,0      { assume success }
    MOV     AX,0300h         { function 300h }
    MOV     BL,Int           { real mode interrupt to execute }
    XOR     BH,BH            { (bh=0) required }
    XOR     CX,CX            { stack words to copy, assume zero }
    LES     DI,Regs          { es:di = Regs }
    INT     31h              { DPMI int 31h }
    JNC     @@End            { carry flag set on error }
  @@Error:
    MOV     ErrorFlag,1      { return false on error }
  @@End:
  end;
  if ErrorFlag then
    raise EDPMIError.Create('Failed to execute DPMI interrupt');
end;

procedure PadVolumeLabel(var Volume: TVolumeLabel);
var
  i: Integer;
begin
  for i := Length(Volume) + 1 to 11 do Volume[i] := ' ';
  Volume[0] := Chr(11);
end;

function GetVolumeLabel(Drive: Char): TVolumeLabel;
var
  rec: TSearchRec;
begin
  Result := '';
  if FindFirst(Drive + ':\*.*', faVolumeID, rec) = 0 then
  begin
    Result := rec.Name;
    if Pos('.', Result) > 0 then Delete(Result, 9, 1);
    PadVolumeLabel(Result);
  end;
  FindClose(rec); { 3.11 }
end;

procedure DeleteVolumeLabel(Drive: Char);
var
  CurName: TVolumeLabel;
  FCB: TExtendedFCB;
  ErrorFlag: WordBool;
begin
  { procedure deletes volume label from given drive }
  ErrorFlag := False;
  CurName := GetVolumeLabel(Drive); { get current volume label }
  FillChar(FCB, SizeOf(FCB), 0);    { initialize FCB with zeros }
  with FCB do
  begin
    ExtendedFCBflag := $FF;         { always }
    Attr := faVolumeID;             { Volume ID attribute }
    DriveID := DriveNumber(Drive);  { Drive number }
    Move(CurName[1], FileName, 8);  { must enter volume label }
    Move(CurName[9], FileExt, 3);
  end;
  asm
    PUSH    DS                      { preserve ds }
    MOV     AX,SS                   { put seg of FCB (ss) in ds }
    MOV     DS,AX
    LEA     DX,FCB                  { put offset of FCB in dx }
    MOV     AX,1300h                { function 13h (delete file) }
    CALL    DOS3Call                { invoke int 21h }
    POP     DS                      { restore ds }
    CMP     AL,00h                  { check for success }
    JE      @@End
  @@Error:                          { set flag on error }
    MOV     ErrorFlag,1
  @@End:
  end;
  if ErrorFlag then
    raise EVolumeLabelError.Create('Unable to delete volume label');
end;

procedure SetVolumeLabel(NewLabel: TVolumeLabel; Drive: Char);
var
  Regs: TRealModeRegs;
  FCB: PExtendedFCB;
  ErrorFlag: WordBool;
  Buf: Longint;
begin
  if NewLabel = '' then begin
    DeleteVolumeLabel(Drive);
    Exit;
  end;
  PadVolumeLabel(NewLabel);
  if GetVolumeLabel(Drive) <> '' then           { if has label... }
    DeleteVolumeLabel(Drive);                   { delete label }
  Buf := GlobalDOSAlloc(SizeOf(PExtendedFCB));  { allocate real buffer }
  try
    FCB := Ptr(LoWord(Buf), 0);
    FillChar(FCB^, SizeOf(FCB), 0);             { init FCB with zeros }
    with FCB^ do
    begin
      ExtendedFCBflag := $FF;                   { required }
      Attr := faVolumeID;                       { Volume ID attribute }
      DriveID := DriveNumber(Drive);            { Drive number }
      Move(NewLabel[1], FileName, 8);           { set new label }
      Move(NewLabel[9], FileExt, 3);
    end;
    FillChar(Regs, SizeOf(Regs), 0);
    with Regs do                                { SEGMENT of FCB }
    begin
      DS := HiWord(Buf);                        { offset = zero }
      DX := 0;
      AX := $1600;                              { function 16h }
    end;
    RealModeInt($21, Regs);                     { create file }
    if (Regs.AL <> 0) then                      { check for success }
      raise EVolumeLabelError.Create('Unable to create volume label');
    { 4.0 -- the created 'file' must be closed }
    FillChar(Regs, SizeOf(Regs), 0);
    with Regs do                                { SEGMENT of FCB }
    begin
      DS := HiWord(Buf);                        { offset = zero }
      DX := 0;
      AX := $1000;                              { function 10h }
    end;
    RealModeInt($21, Regs);                     { close file }
    if (Regs.AL <> 0) then                      { check for success }
      raise EVolumeLabelError.Create('Unable to close volume label');
  finally
    GlobalDOSFree(LoWord(Buf));
  end;
end;

{ CDDiskSize retrieves the ammount of data on a CD-ROM disk by quering
  the number of sectors from the MSCDEX driver. }

type
  PReq_Hdr = ^TReq_Hdr;
  TReq_Hdr = record
    Length       : Byte;
    SubUnit      : Byte;
    Command      : Byte;
    Status       : Word;
    Reserved1    : Longint;
    Reserved2    : Longint;
    Descriptor   : Byte;
    TransferAddr : Pointer;
    TransferBytes: Word;
  end;
  PReq_Blk = ^TReq_Blk;
  TReq_Blk = array[0..7] of Byte;

function CDDiskSize(DriveNum: Integer): Longint;
var
  Buf: Longint;
  Regs: TRealModeRegs;
  Req_Hdr, RMReq_Hdr: PReq_Hdr;
  Req_Blk, RMReq_Blk: PReq_Blk;
  VolSize: Longint;
begin
  Result := -1;
  Dec(DriveNum);
  if not IsCDROM(DriveNum) then Exit;
  Buf := GlobalDOSAlloc(32);
  try
    { get protected mode pointers }
    Req_Hdr := Ptr(LoWord(Buf), 0);
    Req_Blk := Ptr(LoWord(Buf), $0014);
    { get real mode pointers }
    RMReq_Hdr := Ptr(HiWord(Buf), 0);
    RMReq_Blk := Ptr(HiWord(Buf), $0014);
    with Regs do
    begin
      { query number of sectors }
      FillChar(Regs, SizeOf(Regs), 0);
      FillChar(Req_Hdr^, SizeOf(Req_Hdr), 0);
      FillChar(Req_Blk^, SizeOf(Req_Blk), 0);
      Req_Hdr^.Length := SizeOf(Req_Hdr);  { length of Req_Hdr }
      Req_Hdr^.Command := $03;             { IOCTL_READ }
      Req_Hdr^.TransferAddr := RMReq_Blk;
      Req_Hdr^.TransferBytes := $0005;
      Req_Blk^[0] := $08;  { MSCDEX_GetVolSize }
      AX := $1510;         { MSCDEX_DRIVER_REQ }
      CX := DriveNum;
      ES := HiWord(Longint(RMReq_Hdr));
      BX := LoWord(Longint(RMReq_Hdr));
      RealModeInt($2F, Regs);
      Move(Req_Blk^[1], VolSize, 4);
      Result := VolSize * 2048;
    end;
  finally
    GlobalDOSFree(LoWord(Buf));
  end;
end;

initialization
  DetectDrives;
end.

