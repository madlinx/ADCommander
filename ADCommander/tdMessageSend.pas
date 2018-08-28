unit tdMessageSend;

interface

uses
  System.Classes, System.RegularExpressions, Winapi.Windows, System.SysUtils,
  System.SyncObjs, Vcl.ComCtrls, Vcl.StdCtrls, ADC.Common;

type
  TMessageSendParam = record
    ExeName: string;
    Process_Timeout: Integer;
    Process_ShowWindow: Boolean;
    UseCredentials: Boolean;
    User: string;
    Password: string;
    Message_Recipient: string;
    Message_Text: string;
    Message_Timeout: Integer;
  end;

  TMessageSendOutputProc = procedure (ASender: TThread; AOutput: string) of object;
  TMessageSendExceptionProc = procedure (ASender: TThread; AMessage: string) of object;

type
  TMessageSendThread = class(TThread)
  private
    { Private declarations }
    FSyncObject: TCriticalSection;
    FhProcess: THandle;
    FExeName: string;
    FShowWindow: Boolean;
    FProcTimeout: Integer;
    FUseCredentials: Boolean;
    FUser: string;
    FPassword: string;
    FRecipient: string;
    FMessage: string;
    FMsgTimeout: Integer;
    FProcessOutput: AnsiString;
    FErrMessage: string;
    FCmdLine: string;
    FBatchFile: TFileName;
    FLog: TStringList;
    FOnProcessOutput: TMessageSendOutputProc;
    FOnException: TMessageSendExceptionProc;
    function ErrorToString(CommentStr: string; Error: Integer = 0): string;
    procedure PrepareCommandLine;
    procedure PrepareProcessOutput(ASecurityAttr: PSecurityAttributes;
      var InputRead, InputWrite, OutputRead, OutputWrite, ErrorWrite: THandle);
    function GetProcessOutputText(AOutputRead: THandle): string;
    function CreateBatchFile(const FileName, BatchCommand : string): TFileName;
    procedure SyncOutput;
    procedure SyncException;
  protected
    procedure Execute; override;
    procedure DoOutput(AOutput: AnsiString);
    procedure DoException(AMessage: string);
  public
    constructor Create(AParam: TMessageSendParam; ASyncObject: TCriticalSection);
    destructor Destroy; override;
    property hProcess: THandle read FhProcess;
    property OnProcessOutput: TMessageSendOutputProc read FOnProcessOutput write FOnProcessOutput;
    property OnException: TMessageSendExceptionProc read FOnException write FOnException;
  end;

implementation

{ TPsExecThread }

constructor TMessageSendThread.Create(AParam: TMessageSendParam;
  ASyncObject: TCriticalSection);
begin
  inherited Create(True);
  FreeOnTerminate := True;

  FLog := TStringList.Create;

  FSyncObject     := ASyncObject;
  FExeName        := AParam.ExeName;
  FShowWindow     := AParam.Process_ShowWindow;
  FUseCredentials := AParam.UseCredentials;
  FUser           := AParam.User;
  FPassword       := AParam.Password;
  FMessage        := AParam.Message_Text;
  FRecipient      := AParam.Message_Recipient;
  FMsgTimeout     := AParam.Message_Timeout;

  case AParam.Process_Timeout > 0 of
    True : FProcTimeout := AParam.Process_Timeout * 60000;
    False: FProcTimeout := INFINITE;
  end;

  if FShowWindow
    then FProcTimeout := INFINITE;
end;

procedure TMessageSendThread.Execute;
var
  OutputRead, OutputWrite: THandle;
  InputRead, InputWrite: THandle;
  ErrorWrite: THandle;
  StartInfo: TStartupInfo;
  ProcessInfo: TProcessInformation;
  waitResult: Cardinal;
  resSuccess: Boolean;
  SA: TSecurityAttributes;
begin
  if FSyncObject <> nil then
  if not FSyncObject.TryEnter then
  begin
    FSyncObject := nil;
    Self.OnTerminate := nil;
    Exit;
  end;

  FLog.Add(
    #13#10 +
    'Конфигурирование параметров безопасности...'
  );

  DoOutput(FLog.Text);

  with SA do
  begin
    nLength := SizeOf(SECURITY_ATTRIBUTES);
    bInheritHandle := True;
    lpSecurityDescriptor := nil;
  end;

  FillChar(StartInfo, SizeOf(TStartupInfo), #0);
  FillChar(ProcessInfo, SizeOf(TProcessInformation), #0);

  try
    if not FShowWindow then PrepareProcessOutput(
        @SA,
        InputRead,
        InputWrite,
        OutputRead,
        OutputWrite,
        ErrorWrite
    );

    with StartInfo do
    begin
      cb := SizeOf(TStartupInfo);
      dwFlags := STARTF_USESHOWWINDOW;
      case FShowWindow of
        True: begin
          wShowWindow := SW_SHOWNORMAL;
        end;

        False: begin
          dwFlags := dwFlags or STARTF_USESTDHANDLES;
          wShowWindow := SW_HIDE;
          hStdInput := InputRead;
          hStdOutput := OutputWrite;
          hStdError := ErrorWrite;
        end;
      end;
    end;

    FLog.Add(
      #13#10 +
      'Отправка сообщения на ' + FRecipient + '...'
    );

    DoOutput(FLog.Text);

    PrepareCommandLine;

    resSuccess := CreateProcess(
        nil,
        PChar(FCmdLine),
        @SA,
        @SA,
        not FShowWindow,
        CREATE_NEW_CONSOLE,
        nil,
        nil,
        StartInfo,
        ProcessInfo
    );

    if not resSuccess
      then raise Exception.Create(ErrorToString('CreateProcess', GetLastError));

    FhProcess := ProcessInfo.hProcess;

    waitResult := WaitForSingleObject(ProcessInfo.hProcess, FProcTimeout);

    case waitResult of
      WAIT_TIMEOUT : begin
        TerminateProcess(ProcessInfo.hProcess, 0);
        raise Exception.Create('Время ожидания завершения процесса истекло.');
      end;

      WAIT_FAILED : begin
        TerminateProcess(ProcessInfo.hProcess, 0);
        raise Exception.Create(ErrorToString('WaitForSingleObject', GetLastError));
      end;
    end;

    FLog.Add(
      #13#10 +
      'Операция выполнена.'
    );

    if not FShowWindow
      then DoOutput(GetProcessOutputText(OutputRead))
      else DoOutput(FLog.Text);
  except
    on E: Exception do
    begin
      FLog.Add(
        #13#10 +
        E.Message
      );

      DoOutput(FLog.Text);

      DoException(E.Message);
    end;
  end;

  FhProcess := 0;

  if FileExists(FBatchFile)
    then DeleteFile(FBatchFile);

  FBatchFile := '';

  CloseHandle(OutputRead);
  CloseHandle(OutputWrite);
  CloseHandle(InputRead);
  CloseHandle(InputWrite);
  CloseHandle(ErrorWrite);
  CloseHandle(ProcessInfo.hThread);
  CloseHandle(ProcessInfo.hProcess);

  if FSyncObject <> nil then
  begin
    FSyncObject.Leave;
    FSyncObject := nil;
  end;
end;

function TMessageSendThread.GetProcessOutputText(
  AOutputRead: THandle): string;
const
  BufferSize = 1048576;
var
  Buffer: PAnsiChar;
  BytesRead: DWORD;
  res: Boolean;
  BytesCount: Integer;
  sOutput: AnsiString;
begin
  Buffer := AllocMem(BufferSize);

  repeat
    BytesCount := 0;
    BytesRead := 0;

    res := ReadFile(AOutputRead, Buffer[0], BufferSize, BytesRead, nil);

    if (not res) or (BytesRead = 0) or (Terminated)
      then Break;

    Buffer[BytesRead] := #0;

    while BytesCount < BytesRead do
    begin
      sOutput := sOutput + Buffer[BytesCount];
      BytesCount := BytesCount + 1;

      sOutput := sOutput + Buffer[BytesCount];
      BytesCount := BytesCount + 1;

      { Если текущий #13 и следующий #13 или #10, то пропускаем их }
      { увеличивая счетчик прочтенных байт еще на 1                }
      if (Buffer[BytesCount] = #13)
        then if (Buffer[BytesCount + 1] = #10) or (Buffer[BytesCount + 1] = #13)
          then BytesCount := BytesCount + 1
    end;
  until True;

  FreeMem(Buffer, BufferSize);

  Result := sOutput;
end;

procedure TMessageSendThread.PrepareCommandLine;
begin
  FCmdLine := Format('"%s" /accepteula \\%s ', [FExeName, FRecipient]);
  if FUseCredentials then
  begin
    FCmdLine := FCmdLine + Format('-u %s -p %s ', [FUser, FPassword]);
  end;
  case FMsgTimeout = 0 of
    True : FCmdLine := FCmdLine + Format('msg * "%s"', [FMessage]);
    False: FCmdLine := FCmdLine + Format('msg /time:%d * "%s"', [FMsgTimeout, FMessage]);
  end;

  if FShowWindow then
  begin
    FBatchFile := CreateBatchFile('psexec.bat', FCmdLine);
    FCmdLine := Format('cmd /a /k "%s"', [FBatchFile]);
  end;
end;

procedure TMessageSendThread.PrepareProcessOutput(ASecurityAttr: PSecurityAttributes;
  var InputRead, InputWrite, OutputRead, OutputWrite, ErrorWrite: THandle);
var
  OutputReadTmp: THandle;
  InputWriteTmp: THandle;
  res: Boolean;
begin
  try
    res := CreatePipe(OutputReadTmp, OutputWrite, ASecurityAttr, 0);

    if not res
      then raise Exception.Create(ErrorToString('CreatePipe', GetLastError));

    res := DuplicateHandle(
        GetCurrentProcess(),
        OutputWrite,
        GetCurrentProcess(),
        @ErrorWrite,
        0,
        True,
        DUPLICATE_SAME_ACCESS
    );

    if not res
      then raise Exception.Create(ErrorToString('DuplicateHandle', GetLastError));

    res := CreatePipe(InputRead, InputWriteTmp, ASecurityAttr, 0);

    if not res
      then raise Exception.Create(ErrorToString('CreatePipe', GetLastError));

    res := DuplicateHandle(
        GetCurrentProcess(),
        OutputReadTmp,
        GetCurrentProcess(),
        @OutputRead,
        0,
        False,
        DUPLICATE_SAME_ACCESS
    );

    if not res
      then raise Exception.Create(ErrorToString('DuplicateHandle', GetLastError));

    res := DuplicateHandle(
        GetCurrentProcess(),
        InputWriteTmp,
        GetCurrentProcess(),
        @InputWrite,
        0,
        False,
        DUPLICATE_SAME_ACCESS
    );

    if not res
      then raise Exception.Create(ErrorToString('DuplicateHandle', GetLastError));
  finally
    CloseHandle(OutputReadTmp);
    CloseHandle(InputWriteTmp);
  end;
end;

procedure TMessageSendThread.SyncException;
begin
  if Assigned(FOnException)
    then FOnException(Self, FErrMessage);
end;

procedure TMessageSendThread.SyncOutput;
begin
  if Assigned(FOnProcessOutput)
    then FOnProcessOutput(Self, FProcessOutput);
end;

function TMessageSendThread.CreateBatchFile(const FileName, BatchCommand : string): TFileName;
var
  Stream: TFileStream;
  BatchFile: TFileName;
  BatchCmd: AnsiString;
begin
  Result := '';
  BatchFile := TempDirPath + FileName;
  BatchCmd := '@echo off' + #13#10
            + 'chcp 1251 >nul' + #13#10
            + BatchCommand  + #13#10
            + '@echo on';
  Stream:= TFileStream.Create(BatchFile, fmCreate);
  try
    Stream.WriteBuffer(Pointer(BatchCmd)^, Length(BatchCmd));
    Result := BatchFile;
  finally
    Stream.Free;
  end;
end;

destructor TMessageSendThread.Destroy;
begin
  FLog.Free;
  inherited;
end;

procedure TMessageSendThread.DoException(AMessage: string);
begin
  FErrMessage := AMessage;
  Synchronize(SyncException);
end;

procedure TMessageSendThread.DoOutput(AOutput: AnsiString);
begin
  FProcessOutput := AOutput;
  Synchronize(SyncOutput);
end;

function TMessageSendThread.ErrorToString(CommentStr: string; Error: Integer = 0): string;
const
  ErrorMessage: string = '%s [%d] - %s';
var
  Buffer: PChar;
begin
  if Error = 0
    then Error := GetLastError;

  FormatMessage(
      FORMAT_MESSAGE_ALLOCATE_BUFFER or FORMAT_MESSAGE_FROM_SYSTEM,
      nil,
      Error,
      MAKELANGID(LANG_NEUTRAL, SUBLANG_DEFAULT),
      @Buffer,
      0,
      nil
  );

  Result := Format(ErrorMessage, [CommentStr, Error, string(Buffer)]);
end;

end.
