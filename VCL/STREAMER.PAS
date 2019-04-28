{*********************************************************}
{                                                         }
{    Calmira System library 3.3                           }
{    by Li-Hsin Huang & Erwin Dokter                      }
{    released into the public domain may 2002             }
{                                                         }
{*********************************************************}

unit Streamer;

{ Combines Delphi's new stream system with some of Turbo Vision's
  useful stream facilities.  TStreamer avoids the need to use
  a TFiler object, and stores data directly to a binary file.

  Of course, it is unbuffered, but for small files, this is
  unecessary.  A more serious issue might be the lack of error
  checking, but then TStreamer can interpret any binary data file
  whereas TReader needs to find markers left by TWriter }

interface

uses Classes;

type
  TStreamer = class(TFileStream)
  public
    { Public declarations }
    procedure WriteInteger(i: Integer);
    procedure WriteBoolean(b: Boolean);
    procedure WriteString(const s: string);
    procedure WriteChar(c: Char);
    function ReadInteger: Integer;
    function ReadBoolean: Boolean;
    function ReadString: string;
    function ReadChar: Char;
  end;

implementation

procedure TStreamer.WriteInteger(i: Integer);
begin
  Write(i, SizeOf(i));
end;

procedure TStreamer.WriteBoolean(b: Boolean);
begin
  Write(b, SizeOf(b));
end;

procedure TStreamer.WriteString(const s: string);
begin
  Write(s[0], SizeOf(s[0]));
  Write(s[1], Ord(s[0]));
end;

procedure TStreamer.WriteChar(c: Char);
begin
  Write(c, SizeOf(c));
end;

function TStreamer.ReadInteger: Integer;
begin
  Read(Result, SizeOf(Result));
end;

function TStreamer.ReadBoolean: Boolean;
begin
  Read(Result, SizeOf(Result));
end;

function TStreamer.ReadString: string;
begin
  Read(Result[0], SizeOf(Result[0]));
  Read(Result[1], Ord(Result[0]));
end;

function TStreamer.ReadChar: Char;
begin
  Read(Result, SizeOf(Result));
end;

end.
