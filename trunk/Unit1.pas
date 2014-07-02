unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, CPortCtl, CPort, StdCtrls;

type
  TForm1 = class(TForm)
    cmprt1: TComPort;
    tmr1: TTimer;
    mmo1: TMemo;
    pnl1: TPanel;
    cmld1: TComLed;
    cbb1: TComComboBox;
    edt1: TEdit;
    btn1: TButton;
    procedure tmr1Timer(Sender: TObject);
    procedure cmprt1RxChar(Sender: TObject; Count: Integer);
    procedure cmprt1AfterOpen(Sender: TObject);
    procedure btn1Click(Sender: TObject);
    procedure edt1KeyPress(Sender: TObject; var Key: Char);
  private
    { Private declarations }
    function CreateFile(const FileName: string): TFileStream;
  public
    { Public declarations }
    lastV: double;
    OutputFile: TFileStream;
    buf: string;
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

procedure TForm1.tmr1Timer(Sender: TObject);
begin
  try
    cmprt1.Connected := true;
  except
  end;
end;

procedure TForm1.cmprt1RxChar(Sender: TObject; Count: Integer);
const CRLF: string = #13#10;
var s, s2: string;
    i: integer;
    v: Double;
begin
  cmprt1.ReadStr(s, Count);
  buf := buf + s;
  i := Pos(#13#10, buf);
  if i > 0 then begin
    s := Copy(buf, 1, i-1);
    Delete(buf, 1, i+1);
    s2 := DateTimeToStr(Now) + #9 + StringReplace(s, '.', ',', [rfReplaceAll]);
    if(s[1] in ['.', '0'..'9']) then begin
      i := Pos(#9, s);
      v := StrToFloat(Copy(s, 1, i-1));
      if Abs(v - lastV) > 0.05 then begin
        lastV := v;
        OutputFile.WriteBuffer(s2[1], Length(s2));
        OutputFile.WriteBuffer(CRLF[1], Length(CRLF));
      end;
    end else begin
      lastV := -1;
    end;
    mmo1.Lines.BeginUpdate;
    try
      while(mmo1.Lines.Count > 20) do mmo1.Lines.Delete(0);
      mmo1.Lines.Add(s2);
    finally
      mmo1.Lines.EndUpdate;
    end;
  end;
end;

procedure TForm1.cmprt1AfterOpen(Sender: TObject);
begin
  buf := '';
  lastV := -1;
end;

constructor TForm1.Create(AOwner: TComponent);
var s: string;
begin
  inherited;
  OutputFile := CreateFile('discharger.txt');
  s := 'START'#13#10;
  OutputFile.WriteBuffer(s[1], Length(s));
end;

destructor TForm1.Destroy;
begin
  OutputFile.Free;
  inherited;
end;

procedure TForm1.btn1Click(Sender: TObject);
var i: integer;
begin
  i := StrToInt(edt1.Text);
  cmprt1.WriteStr(IntToStr(i)+#13);
end;

procedure TForm1.edt1KeyPress(Sender: TObject; var Key: Char);
begin
  if Key = #13 then begin
    btn1.OnClick(Sender);
  end;
end;

function TForm1.CreateFile(const FileName: string): TFileStream;
var h: THandle;
begin
  // лучше штатного TFileStream тем, что не блокирует файл
  Result := nil;
  try
    h := Windows.CreateFile(PChar(FileName), {GENERIC_READ or } GENERIC_WRITE, FILE_SHARE_READ, nil, OPEN_ALWAYS, FILE_ATTRIBUTE_NORMAL, 0);
    if h = INVALID_HANDLE_VALUE then RaiseLastOSError;
    Result := TFileStream.Create(Integer(h));
    Result.Seek(0, soEnd);
  except
    Result.Free;
    raise;
  end;
end;

initialization
  DecimalSeparator := '.';

end.
