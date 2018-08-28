unit ADC.UCMAEvents;

interface

uses
   ActiveX, windows, ComObj, SysUtils;

type
  IUCMAEvents = interface(IDispatch)
    ['{7F0A6F02-8FA2-46DB-A444-6962635218D5}']
    procedure OnClientSignIn; safecall;
    procedure OnClientSignOut; safecall;
    procedure OnClientDisconnected; safecall;
    procedure OnSettingChanged; safecall;
    procedure OnContactInformationChanged; safecall;
    procedure OnUriChanged(const oldURI: WideString; const newURI: WideString); safecall;
  end;

type
  TUCMAEventClientSignIn = procedure(Sender: TObject) of object;
  TUCMAEventClientSignOut = procedure(Sender: TObject) of object;
  TUCMAEventClientDisconnected = procedure(Sender: TObject) of object;
  TUCMAEventSettingChanged = procedure(Sender: TObject) of object;
  TUCMAEventContactInformationChanged = procedure(Sender: TObject) of object;
  TUCMAEventUriChanged = procedure(Sender: TObject; oldURI, newURI: WideString) of object;

type
  TUCMAEventSink = class(TInterfacedObject, IUnknown, IDispatch)
  private
    FConnection: Integer;
    FIID: TGUID;
    FOnClientSignIn: TUCMAEventClientSignIn;
    FOnClientSignOut: TUCMAEventClientSignOut;
    FOnClientDisconnected: TUCMAEventClientDisconnected;
    FOnSettingChanged: TUCMAEventSettingChanged;
    FOnContactInformationChanged: TUCMAEventContactInformationChanged;
    FOnUriChanged: TUCMAEventUriChanged;
    function _AddRef: Integer; stdcall;
    function _Release: Integer; stdcall;
    function QueryInterface(const IID: TGUID; out Obj): HResult; stdcall;
    function GetTypeInfoCount(out Count: Integer): HResult; stdcall;
    function GetTypeInfo(Index, LocaleID: Integer; out TypeInfo): HResult;     stdcall;
    function GetIDsOfNames(const IID: TGUID; Names: Pointer;
      NameCount, LocaleID: Integer; DispIDs: Pointer): HResult; stdcall;
    function Invoke(DispID: Integer; const IID: TGUID; LocaleID: Integer;
      Flags: Word; var Params; VarResult, ExcepInfo, ArgErr: Pointer): HResult; stdcall;
  protected
     FSource: IUnknown;
     procedure DoClientSignIn; stdcall;
     procedure DoClientSignOut; stdcall;
     procedure DoClientDisconnected; stdcall;
     procedure DoSettingChanged; stdcall;
     procedure DoContactInformationChanged; stdcall;
     procedure DoUriChanged(const oldURI, newURI: string); stdcall;
  public
     constructor Create;
     procedure Connect(Source: IUnknown);
     procedure Disconnect;
     property OnClientSignIn: TUCMAEventClientSignIn read FOnClientSignIn write FOnClientSignIn;
     property OnClientSignOut: TUCMAEventClientSignOut read FOnClientSignOut write FOnClientSignOut;
     property OnClientDisconnected: TUCMAEventClientDisconnected read FOnClientDisconnected write FOnClientDisconnected;
     property OnSettingChanged: TUCMAEventSettingChanged read FOnSettingChanged write FOnSettingChanged;
     property OnContactInformationChanged: TUCMAEventContactInformationChanged read FOnContactInformationChanged write FOnContactInformationChanged;
     property OnUriChanged: TUCMAEventUriChanged read FOnUriChanged write FOnUriChanged;
   end;

implementation


{ TUCMAEventSink }

procedure TUCMAEventSink.Connect(Source: IInterface);
begin
  Assert(Source <> nil);
  Disconnect;
  try
    InterfaceConnect(Source, FIID, Self, FConnection);
    FSource := Source;
  except
    raise Exception.Create (Format ('Unable to connect %s.'#13'%s',
      ['UCMA Application', Exception(ExceptObject).Message]
    ));
  end;
end;

constructor TUCMAEventSink.Create;
begin
  FIID := IUCMAEvents;
  inherited Create;
end;

procedure TUCMAEventSink.Disconnect;
begin
  if (FSource = nil)
    then Exit;

  try
    InterfaceDisconnect(FSource, FIID, FConnection);
    FSource := nil;
  except
    Pointer(FSource) := nil;
  end;
end;

procedure TUCMAEventSink.DoClientDisconnected;
begin
  if Assigned(OnClientDisconnected )
    then OnClientDisconnected(Self);
end;

procedure TUCMAEventSink.DoClientSignIn;
begin
  if Assigned(OnClientSignIn)
    then OnClientSignIn(Self);
end;

procedure TUCMAEventSink.DoClientSignOut;
begin
  if Assigned(OnClientSignOut)
    then OnClientSignOut(Self);
end;

procedure TUCMAEventSink.DoContactInformationChanged;
begin
  if Assigned(OnContactInformationChanged)
    then OnContactInformationChanged(Self);
end;

procedure TUCMAEventSink.DoSettingChanged;
begin
  if Assigned(OnSettingChanged)
    then OnSettingChanged(Self);
end;

procedure TUCMAEventSink.DoUriChanged(const oldURI, newURI: string);
begin
  if Assigned(OnUriChanged)
    then OnUriChanged(Self, oldURI, newURI);
end;

function TUCMAEventSink.GetIDsOfNames(const IID: TGUID; Names: Pointer;
  NameCount, LocaleID: Integer; DispIDs: Pointer): HResult;
begin
  Result := E_NOTIMPL;
end;

function TUCMAEventSink.GetTypeInfo(Index, LocaleID: Integer;
  out TypeInfo): HResult;
begin
  Pointer(TypeInfo) := nil;
  Result := E_NOTIMPL;
end;

function TUCMAEventSink.GetTypeInfoCount(out Count: Integer): HResult;
begin
  Count := 0;
  Result := E_NOTIMPL;
end;

function TUCMAEventSink.Invoke(DispID: Integer; const IID: TGUID; LocaleID: Integer;
  Flags: Word; var Params; VarResult, ExcepInfo, ArgErr: Pointer): HResult;
begin
  { Params:    PDispParams }
  { VarResult: Variant     }
  { ExcepInfo: TExcepInfo  }
  { ArgErr:    DWORD       }

  Result := DISP_E_MEMBERNOTFOUND;

  case DispID of
    1000: begin
      DoClientSignIn;
      Result:= S_OK;
    end;

    1001: begin
      DoClientSignOut;
      Result:= S_OK;
    end;

    1002: begin
      DoClientDisconnected;
      Result:= S_OK;
    end;

    1003: begin
      DoSettingChanged;
      Result:= S_OK;
    end;

    1004: begin
      DoContactInformationChanged;
      Result:= S_OK;
    end;

    1005: begin
      { The arguments are passed in the array rgvarg[ ], with the number of    }
      { arguments passed in cArgs. The arguments in the array should be placed }
      { from last to first, so rgvarg[0] has the last argument and             }
      { rgvarg[cArgs -1] has the first argument.                               }
      { https://msdn.microsoft.com/en-us/library/windows/desktop/ms221653(v=vs.85).aspx }

      DoUriChanged(
        TDispParams(Params).rgvarg^[1].bstrval,
        TDispParams(Params).rgvarg^[0].bstrval
      );
      Result:= S_OK;
    end;
  end;
end;

function TUCMAEventSink.QueryInterface(const IID: TGUID; out Obj): HResult;
begin
  if GetInterface(IID, Obj) then
    Result:= S_OK
  else if IsEqualIID(IID, FIID) then
    Result:= QueryInterface(IDispatch, Obj)
  else
    Result:= E_NOINTERFACE;
end;

function TUCMAEventSink._AddRef: Integer;
begin
  Result := 2;
end;

function TUCMAEventSink._Release: Integer;
begin
  Result := 1;
end;

end.
