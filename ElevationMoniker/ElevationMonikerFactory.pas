unit ElevationMonikerFactory;

interface

uses
  System.SysUtils, System.Win.ComObj, Winapi.Windows, System.Win.ComConst;

type
  TElevationMonikerFactory = class(TTypedComObjectFactory)
private
  FLocalizedStringResId: AnsiString;
  FIconResId: AnsiString;
public
  constructor Create(const ANameResourceId: AnsiString; const AIconResourceId: AnsiString;
    AComServer: TComServerObject; ATypedComClass: TTypedComClass; const AClassID: TGUID;
    AInstancing: TClassInstancing; AThreadingModel: TThreadingModel = tmSingle);
  procedure UpdateRegistry(ARegister: Boolean); override;
end;

implementation

function ConvertStringSecurityDescriptorToSecurityDescriptor(
  StringSecurityDescriptor: PAnsiChar;
  StringSDRevision: Cardinal;
  var SecurityDescriptor: PSecurityDescriptor;
  var SecurityDescriptorSize: Cardinal
): LongBool; stdcall; external advapi32 name 'ConvertStringSecurityDescriptorToSecurityDescriptorA';

procedure CreateRegKeyEx(const AKey, AValueName, AValue: AnsiString;
  APtr: Pointer; ALen: Integer; AValueType: Cardinal = REG_SZ;
  ARootKey: DWORD = HKEY_CLASSES_ROOT);
var
  Handle: HKEY;
  Status, Disposition: Integer;
  V: DWORD;
begin
  Status := RegCreateKeyExA(
    ARootKey,
    PAnsiChar(AKey),
    0,
    '',
    REG_OPTION_NON_VOLATILE,
    KEY_READ or KEY_WRITE,
    nil,
    Handle,
    @Disposition
  );

  if (Status = 0) then
  begin
    try
      case AValueType of
        REG_SZ: begin
          Status := RegSetValueExA(
            Handle,
            PAnsiChar(AValueName),
            0,
            AValueType,
            PAnsiChar(AValue),
            Length(AValue) + 1
          );
        end;

        REG_BINARY: begin
          Status := RegSetValueExA(
            Handle,
            PAnsiChar(AValueName),
            0,
            AValueType,
            APtr,
            ALen
          );
        end;

        REG_DWORD: begin
          V := StrToInt(AValue);
          Status := RegSetValueExA(
            Handle,
            PAnsiChar(AValueName),
            0,
            AValueType,
            @V,
            SizeOf(DWORD)
          );
        end;
      else
        raise Exception.CreateFmt(
          'Unsupported registry value type (%d)!', [AValueType]
        );
      end;
    finally
      RegCloseKey(Handle);
    end;
  end;

  if (Status <> 0) then
    raise EOleRegistrationError.CreateRes(@SCreateRegKeyError);
end;

procedure SetAccessPermissionsForLUAServer(const AKey, AValueName: AnsiString);
const
  SDDL_REVISION_1 = 1;
var
  PSD: PSecurityDescriptor;
  L: Cardinal;
  Handle: HKEY;
  hr: HRESULT;
begin
  { Request local call permissions for InteractiveUser and System. }
  if not ConvertStringSecurityDescriptorToSecurityDescriptor(
    'O:BAG:BAD:(A;;0x3;;;IU)(A;;0x3;;;SY)',
    SDDL_REVISION_1,
    PSD,
    L
  ) then RaiseLastOSError;

  try
    hr := RegOpenKeyExA(
      HKEY_CLASSES_ROOT,
      PAnsiChar(AKey),
      0,
      KEY_READ or KEY_WRITE,
      Handle
    );

    if hr = ERROR_SUCCESS then
    begin
      try
        hr := RegSetValueExA(
          Handle,
          PAnsiChar(AValueName),
          0,
          REG_BINARY,
          PSD,
          L
        );

        if hr <> ERROR_SUCCESS
          then RaiseLastOSError;
      finally
        RegCloseKey(Handle);
      end;
    end else RaiseLastOSError;
  finally
    LocalFree(Cardinal(PSD));
  end;
end;

{ TElevationMonikerFactory }

constructor TElevationMonikerFactory.Create(const ANameResourceId: AnsiString;
  const AIconResourceId: AnsiString; AComServer: TComServerObject;
  ATypedComClass: TTypedComClass; const AClassID: TGUID; AInstancing: TClassInstancing;
  AThreadingModel: TThreadingModel);
begin
  inherited Create(
    AComServer,
    ATypedComClass,
    AClassID,
    AInstancing,
    AThreadingModel
  );

  { Save the id of the resource, that holds the application name and icon. }
  FLocalizedStringResId := ANameResourceId;
  FIconResId := AIconResourceId;
end;

procedure TElevationMonikerFactory.UpdateRegistry(ARegister: Boolean);
var
  ID, ClassKey, FullFileName, FileName: AnsiString;
begin
  ID := GUIDToString(Self.ClassID);
  ClassKey := 'CLSID\' + ID;
  FullFileName := ComServer.ServerFileName;
  FileName := ExtractFileName(FullFileName);
  try
    if ARegister then
    begin
      inherited UpdateRegistry(ARegister);

      { DLL out-of-process hosting requirements. }
      CreateRegKey('AppID\' + ID, '', Description);
      CreateRegKey('AppID\' + ID, 'DllSurrogate', '');
      CreateRegKey('AppID\' + FileName, 'AppID', ID);

      { Over-The-Shoulder activation requirements. }
      SetAccessPermissionsForLUAServer('AppID\' + ID, 'AccessPermission');

      { COM object elevation requirements. }
      CreateRegKey(ClassKey, 'AppID', ID);
      CreateRegKey(ClassKey, 'LocalizedString', '@' + FullFileName + ',-' + FLocalizedStringResId);
      CreateRegKey(ClassKey + '\Elevation', 'IconReference', '@' + FullFileName + ',-' + FIconResId);
      CreateRegKeyEx(ClassKey + '\Elevation', 'Enabled', '1', nil, 0, REG_DWORD);
    end else
    begin
      DeleteRegKey(ClassKey + '\Elevation');
      DeleteRegKey('AppID\' + ID);
      DeleteRegKey('AppID\' + FileName);
      inherited UpdateRegistry(aRegister);
    end;
  except
    on E: EOleRegistrationError do raise;
    on E: Exception do raise EOleRegistrationError.Create(E.Message, 0, E.HelpContext);
  end;
end;

end.
