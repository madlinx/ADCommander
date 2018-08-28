unit ADC.ScriptBtn;

interface

uses
  System.SysUtils, System.Classes, System.RegularExpressions, Winapi.ActiveX,
  Winapi.Windows, MSXML2_TLB, ADC.Types, ADC.ADObject, Dialogs;

type
  PADScriptButton = ^TADScriptButton;
  TADScriptButton = record
    Title: string;
    Description: string;
    Path: string;
    Parameters: string;
  private
    function IsWow64: Boolean;
    function DisableWow64FsRedirection(OldValue: LongBool): Boolean;
    function RevertWow64FsRedirection(OldValue: LongBool): Boolean;
  public
    procedure Execute(AObj: TADObject; AWow64FsRedirection: Boolean = True);
  end;

  TADScriptButtonList = class(TList)
  private
    FOwnsObjects: Boolean;
    procedure Notify(Ptr: Pointer; Action: TListNotification); override;
    function Get(Index: Integer): PADScriptButton;
  public
    constructor Create(AOwnsObjects: Boolean = True); reintroduce;
    destructor Destroy; override;
    function Add(Value: PADScriptButton): Integer;
    procedure Clear; override;
    procedure LoadFromFile(AFileName: TFileName);
    procedure SaveToFile(AFileName: TFileName);
    property Items[Index: Integer]: PADScriptButton read Get; default;
    property OwnsObjects: Boolean read FOwnsObjects write FOwnsObjects;
  end;

type
  TCreateScriptButtonProc = procedure (Sender: TObject; AButton: TADScriptButton) of object;
  TChangeScriptButtonProc = procedure (Sender: TObject; AButton: PADScriptButton) of object;

implementation

{ TADScriptButton }

function TADScriptButton.DisableWow64FsRedirection(OldValue: LongBool): Boolean;
type
  TWow64DisableWow64FsRedirection = function(var Wow64FsEnableRedirection:
    LongBool): LongBool; stdcall;
var
  hHandle: THandle;
  Wow64DisableWow64FsRedirection: TWow64DisableWow64FsRedirection;
begin
  Result := True;
  if not IsWow64 then Exit;
  try
    hHandle := GetModuleHandle('kernel32.dll');
    @Wow64DisableWow64FsRedirection := GetProcAddress(hHandle,
      'Wow64DisableWow64FsRedirection');

    if ((hHandle <> 0) and (@Wow64DisableWow64FsRedirection <> nil)) then
      Wow64DisableWow64FsRedirection(OldValue);
  except
    Result := False;
  end;
end;

procedure TADScriptButton.Execute(AObj: TADObject; AWow64FsRedirection: Boolean);
var
  regEx: TRegEx;
  StartInfo: TStartupInfo;
  ProcInfo: TProcessInformation;
  SA: SECURITY_ATTRIBUTES;
  sbParams: string;
  sbCmdLine: string;
  OldValue: LongBool;
  fSuccess: Boolean;
begin
  if AObj = nil
    then Exit;

  sbParams := Format(' %s ', [Self.Parameters]);

  sbParams := regEx.Replace(
    sbParams,
    '(?<=\s)-hn(?=\s)',
    Format('"%s"', [AObj.DomainHostName])
  );

  sbParams := regEx.Replace(
    sbParams,
    '(?<=\s)-an(?=\s)',
    Format('"%s"', [AObj.sAMAccountName])
  );

  sbParams := regEx.Replace(
    sbParams,
    '(?<=\s)-dn(?=\s)',
    Format('"%s"', [AObj.distinguishedName])
  );

  sbCmdLine := 'wscript "' + Self.Path + '" ' + sbParams;

  with SA do
  begin
    nLength := SizeOf(SECURITY_ATTRIBUTES);
    bInheritHandle := True;
    lpSecurityDescriptor := nil;
  end;

  FillChar(StartInfo, SizeOf(StartInfo), #0);
  FillChar(ProcInfo, SizeOf(StartInfo), #0);

  with StartInfo do
  begin
    cb := SizeOf(StartInfo);
    dwFlags := STARTF_USESHOWWINDOW;
    wShowWindow := SW_HIDE;
  end;

  if not AWow64FsRedirection then DisableWow64FsRedirection(OldValue);

  fSuccess := CreateProcess(
    nil,
    PChar(sbCmdLine),
    @SA,
    @SA,
    False,
    0,
    nil,
    nil,
    StartInfo,
    ProcInfo
  );

  if not AWow64FsRedirection then RevertWow64FsRedirection(OldValue);
  if fSuccess then
  begin
////    WaitForSingleObject(ProcInfo.hProcess, INFINITE);
//    case WaitForSingleObject(ProcInfo.hProcess, 15000) of
//      WAIT_TIMEOUT : ;
//      WAIT_FAILED  : ;
//      else ;
//    end;
    CloseHandle(ProcInfo.hProcess);
    CloseHandle(ProcInfo.hThread);
  end else
  begin
    raise Exception.Create(SysErrorMessage(GetLastError));
  end;
end;

function TADScriptButton.IsWow64: Boolean;
type
  LPFN_ISWOW64PROCESS = function(hProcess: THandle; var Wow64Process: BOOL): BOOL; stdcall;
var
  fnIsWow64Process: LPFN_ISWOW64PROCESS;
  bIsWow64: BOOL;
begin
  Result := False;
  fnIsWow64Process := LPFN_ISWOW64PROCESS(GetProcAddress(GetModuleHandle('kernel32'), 'IsWow64Process'));
  if Assigned(fnIsWow64Process) then
  begin
    bIsWow64 := False;
    if fnIsWow64Process(GetCurrentProcess(), bIsWow64) then
      Result := bIsWow64;
  end;
end;

function TADScriptButton.RevertWow64FsRedirection(OldValue: LongBool): Boolean;
type
  TWow64RevertWow64FsRedirection = function(var
    Wow64RevertWow64FsRedirection: LongBool): LongBool; stdcall;
var
  hHandle: THandle;
  Wow64RevertWow64FsRedirection: TWow64RevertWow64FsRedirection;
begin
  Result := true;
  if not IsWow64 then Exit;
  try
    hHandle := GetModuleHandle('kernel32.dll');
    @Wow64RevertWow64FsRedirection := GetProcAddress(hHandle,
      'Wow64RevertWow64FsRedirection');

    if ((hHandle <> 0) and (@Wow64RevertWow64FsRedirection <> nil)) then
      Wow64RevertWow64FsRedirection(OldValue);
  except
    Result := False;
  end;
end;

{ TADScriptButtonList }

function TADScriptButtonList.Add(Value: PADScriptButton): Integer;
begin
  Result := inherited Add(Value);
end;

procedure TADScriptButtonList.Clear;
var
  i: Integer;
begin
  for i := Self.Count - 1 downto 0 do
    Self.Delete(i);

  inherited Clear;
end;

constructor TADScriptButtonList.Create(AOwnsObjects: Boolean);
begin
  inherited Create;

  FOwnsObjects := AOwnsObjects;
end;

destructor TADScriptButtonList.Destroy;
begin

  inherited;
end;

function TADScriptButtonList.Get(Index: Integer): PADScriptButton;
begin
  Result := PADScriptButton(inherited Get(Index));
end;

procedure TADScriptButtonList.LoadFromFile(AFileName: TFileName);
var
  xmlFileName: TFileName;
  XMLStream: TStringStream;
  XMLDoc: IXMLDOMDocument;
  XMLNodeList: IXMLDOMNodeList;
  XMLNode: IXMLDOMNode;
  i: Integer;
  s: PADScriptButton;
  eventString: string;
begin
  Self.Clear;

  xmlFileName := AFileName;

  if not FileExists(AFileName) then Exit;

  XMLStream := TStringStream.Create;
  try
    XMLStream.LoadFromFile(xmlFileName);
    XMLDoc := CoDOMDocument60.Create;
    XMLDoc.async := False;
    XMLDoc.load(TStreamAdapter.Create(XMLStream) as IStream);
    if XMLDoc.parseError.errorCode = 0 then
    begin
      XMLNodeList := XMLDoc.documentElement.selectNodes('script');
      for i := 0 to XMLNodeList.length - 1 do
      begin
        New(s);

        XMLNode := XMLNodeList.item[i].selectSingleNode('title');
        s^.Title := XMLNode.text;

        XMLNode := XMLNodeList.item[i].selectSingleNode('description');
        s^.Description := XMLNode.text;

        XMLNode := XMLNodeList.item[i].selectSingleNode('path');
        s^.Path := XMLNode.text;

        XMLNode := XMLNodeList.item[i].selectSingleNode('parameters');
        s^.Parameters := XMLNode.text;

        Self.Add(s);
      end;
    end;
  finally
    XMLStream.Free;
  end;
end;

procedure TADScriptButtonList.Notify(Ptr: Pointer; Action: TListNotification);
begin
  inherited;

  case Action of
    lnAdded: begin

    end;

    lnExtracted: begin

    end;

    lnDeleted: begin
      if FOwnsObjects
        then Dispose(PADScriptButton(Ptr))
    end;
  end;

end;

procedure TADScriptButtonList.SaveToFile(AFileName: TFileName);
var
  xmlFileName: TFileName;
  xmlBin: TXMLByteArray;
  xmlStream: TStringStream;
  xmlDoc: IXMLDOMDocument;
  xmlRoot: IXMLDOMNode;
  xmlEvent: IXMLDOMNode;
  xmlNode: IXMLDOMNode;
  s: PADScriptButton;
begin
  xmlFileName := AFileName;

  XMLStream := TStringStream.Create;
  XMLDoc := CoDOMDocument60.Create;
  try
    XMLDoc.async := True;
    XMLDoc.loadXML('<SCRIPT_BUTTONS></SCRIPT_BUTTONS>');
    for s in Self do
    begin
      XMLEvent := XMLDoc.createNode(NODE_ELEMENT, 'script', '');

      XMLNode := XMLDoc.createNode(NODE_ELEMENT, 'title', '');
      XMLNode.text := s^.Title;
      XMLEvent.appendChild(XMLNode);

      XMLNode := XMLDoc.createNode(NODE_ELEMENT, 'description', '');
      XMLNode.text := s^.Description;
      XMLEvent.appendChild(XMLNode);

      XMLNode := XMLDoc.createNode(NODE_ELEMENT, 'path', '');
      XMLNode.text := s^.Path;
      XMLEvent.appendChild(XMLNode);

      XMLNode := XMLDoc.createNode(NODE_ELEMENT, 'parameters', '');
      XMLNode.text := s^.Parameters;
      XMLEvent.appendChild(XMLNode);

      XMLRoot := XMLDoc.documentElement;
      XMLRoot.appendChild(XMLEvent);
    end;

    XMLDoc.save(xmlFileName);
  finally
    XMLStream.Free;
    XMLDoc := nil;
  end;
end;

end.
