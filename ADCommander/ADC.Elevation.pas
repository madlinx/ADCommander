unit ADC.Elevation;

interface

uses
  System.SysUtils, Winapi.Windows, Winapi.ActiveX, System.Win.ComObj, ADCommander_TLB;

type
  // Vista SDK - extended BIND_OPTS2 struct
  BIND_OPTS3 = record
    cbStruct:            DWORD;
    grfFlags:            DWORD;
    grfMode:             DWORD;
    dwTickCountDeadline: DWORD;
    dwTrackFlags:        DWORD;
    dwClassContext:      DWORD;
    locale:              LCID;
    pServerInfo:         PCOSERVERINFO;
    hwnd:                HWND;
  end;
  PBIND_OPTS3 = ^BIND_OPTS3;

type
  // Vista SDK - extended TOKEN_INFORMATION_CLASS enum
  TOKEN_INFORMATION_CLASS = (
    TokenICPad, // dummy padding element
    TokenUser,
    TokenGroups,
    TokenPrivileges,
    TokenOwner,
    TokenPrimaryGroup,
    TokenDefaultDacl,
    TokenSource,
    TokenType,
    TokenImpersonationLevel,
    TokenStatistics,
    TokenRestrictedSids,
    TokenSessionId,
    TokenGroupsAndPrivileges,
    TokenSessionReference,
    TokenSandBoxInert,
    TokenAuditPolicy,
    TokenOrigin,
    TokenElevationType,
    TokenLinkedToken,
    TokenElevation,
    TokenHasRestrictions,
    TokenAccessInformation,
    TokenVirtualizationAllowed,
    TokenVirtualizationEnabled,
    TokenIntegrityLevel,
    TokenUIAccess,
    TokenMandatoryPolicy,
    TokenLogonSid,
    MaxTokenInfoClass  // MaxTokenInfoClass should always be the last enum
  );

type
  TOKEN_ELEVATION = packed record
    TokenIsElevated: DWORD;
  end;
  PTOKEN_ELEVATION = ^TOKEN_ELEVATION;

function IsElevated: Boolean;

procedure CoCreateInstanceAsAdmin(
  AHWnd: HWND;              // parent for elevation prompt window
  const AClassID: TGUID;    // COM class guid
  const AIID: TGUID;        // interface id implemented by class
  out AObj                  // interface pointer
);

function IsProcessElevated: Boolean;
function RegisterUCMAComponents(AHandle: HWND; AClassID: PWideChar;
  AElevate: Boolean): HRESULT;
function UnregisterUCMAComponents(AHandle: HWND; AClassID: PWideChar;
  AElevate: Boolean): HRESULT;
function SaveControlEventsList(AHandle: HWND; AFileName: PWideChar;
  const AXMLStream: IUnknown; AElevate: Boolean): HRESULT;
function DeleteControlEventsList(AHandle: HWND; AFileName: PWideChar;
  AElevate: Boolean): HRESULT;
function CreateAccessDatabase(AHandle: HWND; AConnectionString: PWideChar;
  const AFieldCatalog: IUnknown; AElevate: Boolean): IUnknown;

implementation

function CoGetObject(pszName: PWideChar; pBindOptions: PBIND_OPTS3;
  const iid: TIID; out ppv
): HResult; stdcall; external 'ole32.dll' name 'CoGetObject';

function GetTokenInformation(TokenHandle: THandle;
  TokenInformationClass: TOKEN_INFORMATION_CLASS; TokenInformation: Pointer;
  TokenInformationLength: DWORD; var ReturnLength: DWORD
): BOOL; stdcall; external advapi32 name 'GetTokenInformation';

function IsElevated: Boolean;
var
  Token: THandle;
  Elevation: TOKEN_ELEVATION;
  Dummy: DWORD;
begin
  Result := False;

  if OpenProcessToken(GetCurrentProcess, TOKEN_QUERY, Token) then begin
    Dummy := 0;
    if GetTokenInformation(Token, TokenElevation, @Elevation,
      SizeOf(TOKEN_ELEVATION), Dummy)
    then
      Result := (Elevation.TokenIsElevated <> 0);

    CloseHandle(Token);
  end;
end;

procedure CoCreateInstanceAsAdmin(aHWnd: HWND; const aClassID, aIID: TGUID;
  out aObj);
var
  BO: BIND_OPTS3;
  MonikerName: String;
begin
  if (not IsElevated) then begin
    { Request elevated out-of-process instance. }
    MonikerName := 'Elevation:Administrator!new:' + GUIDToString(aClassID);

    FillChar(BO, SizeOf(BIND_OPTS3), 0);
    BO.cbStruct := SizeOf(BIND_OPTS3);
    BO.dwClassContext := CLSCTX_LOCAL_SERVER;
    BO.hwnd := aHWnd;

    OleCheck(CoGetObject(PWideChar(MonikerName), @BO, aIID, aObj));
  end else
    { Request normal in-process instance. }
    OleCheck(CoCreateInstance(aClassID, nil, CLSCTX_ALL, aIID, aObj));
end;

function IsProcessElevated: Boolean;
begin
  Result := IsElevated;
end;

function RegisterUCMAComponents(AHandle: HWND; AClassID: PWideChar;
  AElevate: Boolean): HRESULT;
var
  Moniker: IElevationMoniker;
begin
  Result := E_FAIL;
  try
    if AElevate then
      { Create elevated COM object instance. }
      CoCreateInstanceAsAdmin(
        AHandle,
        CLASS_ElevationMoniker,
        IID_IElevationMoniker,
        Moniker
      )
    else
      { Create non-elevated COM object instance. }
      Moniker := CoElevationMoniker.Create;
  except
    on E: Exception do begin
//      MessageBox(
//        AHandle,
//        PWideChar(E.Message),
//        PWideChar('COM object instantiation failed: ' + E.ClassName),
//        MB_OK or MB_ICONERROR
//      );

      Exit;
    end;
  end;

  Result := S_OK;

  { Attempt to register components }
  Moniker.RegisterUCMAComponents(AClassID);
end;

function UnregisterUCMAComponents(AHandle: HWND; AClassID: PWideChar;
  AElevate: Boolean): HRESULT;
var
  Moniker: IElevationMoniker;
begin
  Result := E_FAIL;
  try
    if AElevate then
      { Create elevated COM object instance. }
      CoCreateInstanceAsAdmin(
        AHandle,
        CLASS_ElevationMoniker,
        IID_IElevationMoniker,
        Moniker
      )
    else
      { Create non-elevated COM object instance. }
      Moniker := CoElevationMoniker.Create;
  except
    on E: Exception do begin
//      MessageBox(
//        AHandle,
//        PWideChar(E.Message),
//        PWideChar('COM object instantiation failed: ' + E.ClassName),
//        MB_OK or MB_ICONERROR
//      );

      Exit;
    end;
  end;

  Result := S_OK;

  { Attempt to unregister components }
  Moniker.UnregisterUCMAComponents(AClassID);
end;

function SaveControlEventsList(AHandle: HWND; AFileName: PWideChar;
  const AXMLStream: IUnknown; AElevate: Boolean): HRESULT;
var
  Moniker: IElevationMoniker;
begin
  Result := E_FAIL;
  try
    if AElevate then
      { Create elevated COM object instance. }
      CoCreateInstanceAsAdmin(
        AHandle,
        CLASS_ElevationMoniker,
        IID_IElevationMoniker,
        Moniker
      )
    else
      { Create non-elevated COM object instance. }
      Moniker := CoElevationMoniker.Create;
  except
    on E: Exception do begin
//      MessageBox(
//        AHandle,
//        PWideChar(E.Message),
//        PWideChar('COM object instantiation failed: ' + E.ClassName),
//        MB_OK or MB_ICONERROR
//      );

      Exit;
    end;
  end;

  Result := S_OK;

  Moniker.SaveControlEventsList(AFileName, AXMLStream);
end;

function DeleteControlEventsList(AHandle: HWND; AFileName: PWideChar;
  AElevate: Boolean): HRESULT;
var
  Moniker: IElevationMoniker;
begin
  Result := E_FAIL;
  try
    if AElevate then
      { Create elevated COM object instance. }
      CoCreateInstanceAsAdmin(
        AHandle,
        CLASS_ElevationMoniker,
        IID_IElevationMoniker,
        Moniker
      )
    else
      { Create non-elevated COM object instance. }
      Moniker := CoElevationMoniker.Create;
  except
    on E: Exception do begin
//      MessageBox(
//        AHandle,
//        PWideChar(E.Message),
//        PWideChar('COM object instantiation failed: ' + E.ClassName),
//        MB_OK or MB_ICONERROR
//      );

      Exit;
    end;
  end;

  Result := S_OK;

  Moniker.DeleteControlEventsList(AFileName);
end;

function CreateAccessDatabase(AHandle: HWND; AConnectionString: PWideChar;
  const AFieldCatalog: IUnknown; AElevate: Boolean): IUnknown;
var
  Moniker: IElevationMoniker;
begin
  Result := nil;
  try
    if AElevate then
      { Create elevated COM object instance. }
      CoCreateInstanceAsAdmin(
        AHandle,
        CLASS_ElevationMoniker,
        IID_IElevationMoniker,
        Moniker
      )
    else
      { Create non-elevated COM object instance. }
      Moniker := CoElevationMoniker.Create;
  except
    on E: Exception do begin
//      MessageBox(
//        AHandle,
//        PWideChar(E.Message),
//        PWideChar('COM object instantiation failed: ' + E.ClassName),
//        MB_OK or MB_ICONERROR
//      );

      Exit;
    end;
  end;

  Result := Moniker.CreateAccessDatabase(AConnectionString, AFieldCatalog);
end;

end.
