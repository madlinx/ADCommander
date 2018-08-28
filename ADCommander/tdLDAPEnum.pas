unit tdLDAPEnum;

interface

uses
  System.Classes, Winapi.Windows, System.SysUtils, System.AnsiStrings, System.TypInfo,
  System.DateUtils, Winapi.ActiveX, ADC.LDAP, JwaRpcdce, ActiveDs_TLB, MSXML2_TLB,
  System.SyncObjs, ADC.Types, ADC.DC, ADC.Attributes, ADC.ADObject, ADC.ADObjectList, ADC.Common,
  ADC.AD;

type
  TLDAPEnum = class(TThread)
  private
    FSyncObject: TCriticalSection;
    FProgressProc: TProgressProc;
    FExceptionProc: TExceptionProc;
    FProgressValue: Integer;
    FExceptionCode: ULONG;
    FExceptionMsg: string;
    FLDAP: PLDAP;
    FLDAPSearchResult: PLDAPMessage;
    FAttrCatalog: TAttrCatalog;
    FAttributes: array of PAnsiChar;
    FOutList: TADObjectList<TADObject>;
    FObj: TADObject;
    FDomainDN: AnsiString;
    FDomainHostName: AnsiString;
    FMaxPwdAge_Secs: Int64;
    FMaxPwdAge_Days: Int64;
    procedure SyncProgress;
    procedure SyncException;
    procedure Clear;
    procedure GetDomainDN(var ADomainDN, AHostName: AnsiString);
    procedure GetMaxPasswordAge(ABase: AnsiString);
    function FormatExtDNFlags(iFlagValue: Integer): PLDAPControl;
  protected
    destructor Destroy; override;
    procedure Execute; override;
    procedure DoProgress(AProgress: Integer); overload;
    procedure DoProgress; overload;
    procedure DoException(AMsg: string; ACode: ULONG);
  public
    constructor Create(AConnection: PLDAP; AAttrCatalog: TAttrCatalog;
      AOutList: TADObjectList<TADObject>; ASyncObject: TCriticalSection;
      AProgressProc: TProgressProc; AExceptionProc: TExceptionProc;
      CreateSuspended: Boolean = False); reintroduce;
  end;

implementation

{ TLDAPEnum }

procedure TLDAPEnum.Clear;
var
  i: Integer;
begin
  if Terminated and (FOutList <> nil)
    then FOutList.Clear;

  FLDAP := nil;
  FProgressProc := nil;
  FProgressValue := 0;
  FExceptionProc := nil;
  FExceptionCode := 0;
  FExceptionMsg := '';
  FAttrCatalog := nil;
  FDomainDN := '';
  FDomainHostName := '';
  FMaxPwdAge_Secs := 0;
  FMaxPwdAge_Days := 0;
  FOutList := nil;
  FObj := nil;

  if FLDAPSearchResult <> nil
    then ldap_msgfree(FLDAPSearchResult);

  for i := Low(FAttributes) to High(FAttributes) do
    System.AnsiStrings.StrDispose(FAttributes[i]);

  CoUninitialize;

  if FSyncObject <> nil then
  begin
    FSyncObject.Leave;
    FSyncObject := nil;
  end;
end;

constructor TLDAPEnum.Create(AConnection: PLDAP; AAttrCatalog: TAttrCatalog;
  AOutList: TADObjectList<TADObject>; ASyncObject: TCriticalSection;
  AProgressProc: TProgressProc; AExceptionProc: TExceptionProc;
  CreateSuspended: Boolean = False);
var
  i: Integer;
begin
  inherited Create(CreateSuspended);
  FreeOnTerminate := True;

  FSyncObject := ASyncObject;
  FProgressProc := AProgressProc;
  FExceptionProc := AExceptionProc;

  if AConnection = nil then
  begin
    DoException('No server binding.', 0);
    Self.Terminate;
  end else
  begin
    FLDAP := AConnection;

    GetDomainDN(FDomainDN, FDomainHostName);

    FAttrCatalog := AAttrCatalog;
    FOutList := AOutList;

    SetLength(FAttributes, FAttrCatalog.Count + 1);
    for i := 0 to FAttrCatalog.Count - 1 do
      FAttributes[i] := System.AnsiStrings.StrNew(PAnsiChar(AnsiString(FAttrCatalog[i]^.Name)));

    { Заполняем свойства для плавающего окна }
    i := FAttrCatalog.Count;
    SetLength(FAttributes, Length(FAttributes) + 3);
    FAttributes[i] := System.AnsiStrings.StrNew(PansiChar('displayName'));
    FAttributes[i + 1] := System.AnsiStrings.StrNew(PansiChar('title'));
    FAttributes[i + 2] := System.AnsiStrings.StrNew(PansiChar('physicalDeliveryOfficeName'));
  end;
end;

destructor TLDAPEnum.Destroy;
begin

  inherited;
end;

procedure TLDAPEnum.DoException(AMsg: string; ACode: ULONG);
begin
  FExceptionCode := ACode;
  FExceptionMsg := AMsg;
  Synchronize(SyncException);
end;

procedure TLDAPEnum.DoProgress;
begin
  FProgressValue := FProgressValue + 1;
  Synchronize(SyncProgress);
end;

procedure TLDAPEnum.DoProgress(AProgress: Integer);
begin
  FProgressValue := AProgress;
  Synchronize(SyncProgress);
end;

procedure TLDAPEnum.Execute;
var
  returnCode: ULONG;
  errorCode: ULONG;
  ldapBase: AnsiString;
  ldapFilter: AnsiString;
  ldapCookie: PLDAPBerVal;
  ldapPage: PLDAPControl;
  ldapExtDN: PLDAPControl;
  ldapDeleted: PLDAPControl;
  ldapControls: array[0..1] of PLDAPControl;
  ldapServerControls: PPLDAPControl;
  ldapCount: ULONG;
  ldapEntry: PLDAPMessage;
  morePages: Boolean;
  i: Integer;
begin
  CoInitialize(nil);

  if FSyncObject <> nil then
  if not FSyncObject.TryEnter then
  begin
    FSyncObject := nil;
    FOutList := nil;
    Self.OnTerminate := nil;
    Self.Terminate;
  end;

  if Terminated then
  begin
    Clear;
    Exit;
  end;

  FOutList.Clear;

  try
    { Из подключения получаем DNS-имя КД }
    ldapBase := FDomainDN;

    { Получаем значение атрибута maxPwdAge, которое используем для расчета     }
    { срока действия пароля пользователя в секундах и днях (FMaxPwdAge_Seconds }
    { и FMaxPwdAge_Days соотв.) а затем используем одно из этих значений в     }
    { процедуре ProcessObjects для расчета даты окончания действия пароля      }
    GetMaxPasswordAge(ldapBase);

    { Формируем фильтр объектов AD }
    ldapFilter := '(|' +
      '(&(objectCategory=person)(objectClass=user))' +
      '(objectCategory=group)' +
      '(objectCategory=computer)' +
//      '(isDeleted=*)' +
    ')';

    ldapExtDN := nil;
    ldapCookie := nil;

    DoProgress(0);

    { Если раскомментировать параметры ниже, то необходимо увеличить     }
    { размер массива параметров ldapControls до необходимого.            }
    { Важно! Массив ldapControls null-terminated, поэтому последний      }
    { элемент должен быть равен nil, т.е. если используется, например,   }
    { 3 параметра, то размер массива 4 ([0..3]) и ldapControls[3] := nil }

//    New(ldapDeleted);
//    ldapDeleted^.ldctl_oid := '1.2.840.113556.1.4.417'; { LDAP_SERVER_SHOW_DELETED_OID }
//    ldapDeleted^.ldctl_iscritical := True;
//    ldapControls[1] := ldapDeleted;

//    ldapExtDN := FormatExtDNFlags(1);
//    ldapControls[2] := ldapExtDN;

    { Постраничный поиск объектов AD }
    repeat
      if Terminated then Break;

      returnCode := ldap_create_page_control(
        FLDAP,
        ADC_SEARCH_PAGESIZE,
        ldapCookie,
        1,
        ldapPage
      );

      if returnCode <> LDAP_SUCCESS
        then raise Exception.Create('Failure during ldap_create_page_control: ' + ldap_err2string(returnCode));

      ldapControls[0] := ldapPage;

      returnCode := ldap_search_ext_s(
        FLDAP,
        PAnsiChar(ldapBase),
        LDAP_SCOPE_SUBTREE,
        PAnsiChar(ldapFilter),
        PAnsiChar(@FAttributes[0]),
        0,
        @ldapControls,
        nil,
        nil,
        0,
        FLDAPSearchResult
      );

      if not (returnCode in [LDAP_SUCCESS, LDAP_PARTIAL_RESULTS])
        then raise Exception.Create('Failure during ldap_search_ext_s: ' + ldap_err2string(returnCode));

      returnCode := ldap_parse_result(
        FLDAP^,
        FLDAPSearchResult,
        @errorCode,
        nil,
        nil,
        nil,
        ldapServerControls,
        False
      );

      if ldapCookie <> nil then
      begin
        ber_bvfree(ldapCookie);
        ldapCookie := nil;
      end;

      returnCode := ldap_parse_page_control(
        FLDAP,
        ldapServerControls,
        ldapCount,
        ldapCookie
      );

      if (ldapCookie <> nil) and (ldapCookie.bv_val <> nil) and (System.SysUtils.StrLen(ldapCookie.bv_val) > 0)
        then morePages := True
        else morePages := False;

      if ldapServerControls <> nil then
      begin
         ldap_controls_free(ldapServerControls);
         ldapServerControls := nil;
      end;

      ldapControls[0]:= nil;
      ldap_control_free(ldapPage);
      ldapPage := nil;

      { Обработка объектов }
      ldapEntry := ldap_first_entry(FLDAP, FLDAPSearchResult);
      while ldapEntry <> nil do
      begin
        if Terminated then Break;

        FObj := TADObject.Create;
        FObj.WriteProperties(
          FLDAP,
          ldapEntry,
          FAttrCatalog,
          string(FDomainHostName),
          FMaxPwdAge_Secs
        );

        FOutList.Add(FObj);
        ldapEntry := ldap_next_entry(FLDAP, ldapEntry);
        DoProgress;
      end;

      ldap_msgfree(FLDAPSearchResult);
      FLDAPSearchResult := nil;
    until (morePages = False);

    ber_bvfree(ldapCookie);
    Dispose(ldapDeleted);
    Dispose(ldapExtDN);
    ldapCookie := nil;
  except
    on E: Exception do
    begin
      DoException(E.Message, returnCode);
      Clear;
    end;
  end;

  Clear;
end;

procedure TLDAPEnum.GetDomainDN(var ADomainDN, AHostName: AnsiString);
var
  attr: PAnsiChar;
  attrArray: array of PAnsiChar;
  returnCode: ULONG;
  searchResult: PLDAPMessage;
  ldapEntry: PLDAPMessage;
  ldapValue: PPAnsiChar;
begin
  SetLength(attrArray, 3);
  attrArray[0] := PAnsiChar('defaultNamingContext');
  attrArray[1] := PAnsiChar('dnsHostName');
  attrArray[2] := nil;

  returnCode := ldap_search_ext_s(
    FLDAP,
    nil,
    LDAP_SCOPE_BASE,
    PAnsiChar('(objectclass=*)'),
    PAnsiChar(@attrArray[0]),
    0,
    nil,
    nil,
    nil,
    0,
    searchResult
  );

  if (returnCode = LDAP_SUCCESS) and (ldap_count_entries(FLDAP, searchResult) > 0 ) then
  begin
    ldapEntry := ldap_first_entry(FLDAP, searchResult);
    ldapValue := ldap_get_values(FLDAP, ldapEntry, attrArray[0]);
    if ldapValue <> nil
      then ADomainDN := ldapValue^;
    ldap_value_free(ldapValue);

    ldapValue := ldap_get_values(FLDAP, ldapEntry, attrArray[1]);
    if ldapValue <> nil
      then AHostName := ldapValue^;
    ldap_value_free(ldapValue);
  end;

  if searchResult <> nil
    then ldap_msgfree(searchResult);
end;

procedure TLDAPEnum.GetMaxPasswordAge(ABase: AnsiString);
const
  ONE_HUNDRED_NANOSECOND = 0.000000100;
  SECONDS_IN_DAY         = 86400;
var
  attr: PAnsiChar;
  attrArray: array of PAnsiChar;
  returnCode: ULONG;
  searchResult: PLDAPMessage;
  ldapEntry: PLDAPMessage;
  ldapBinValues: PPLDAPBerVal;
begin
  SetLength(attrArray, 2);
  attrArray[0] := PAnsiChar('maxPwdAge');

  returnCode := ldap_search_ext_s(
    FLDAP,
    PAnsiChar(ABase),
    LDAP_SCOPE_BASE,
    PAnsiChar('objectCategory=domain'),
    PAnsiChar(@attrArray[0]),
    0,
    nil,
    nil,
    nil,
    0,
    searchResult
  );

  if (returnCode = LDAP_SUCCESS) and (ldap_count_entries(FLDAP, searchResult) > 0 ) then
  begin
    ldapEntry := ldap_first_entry(FLDAP, searchResult);
    ldapBinValues := ldap_get_values_len(FLDAP, ldapEntry, PAnsiChar('maxPwdAge'));
    if (ldapBinValues <> nil) and (ldapBinValues^.bv_len > 0) then
    begin
      FMaxPwdAge_Secs := Abs(Round(ONE_HUNDRED_NANOSECOND * StrToInt64Def(ldapBinValues^.bv_val, 0)));
      FMaxPwdAge_Days := Round(FMaxPwdAge_Secs / SECONDS_IN_DAY);
    end;
    ldap_value_free_len(ldapBinValues);
  end;

  if searchResult <> nil
    then ldap_msgfree(searchResult);
end;

function TLDAPEnum.FormatExtDNFlags(iFlagValue: Integer): PLDAPControl;
const
  LDAP_SERVER_EXTENDED_DN_OID = '1.2.840.113556.1.4.529';
var
  pber: PBerElement;
  pLControl: PLDAPControl;
  pldctrl_value: PBERVAL;
  res: Integer;
begin
  pber := nil;
  pLControl := nil;
  pldctrl_value := nil;
  res := -1;
  if iFlagValue <> 0 then iFlagValue := 1;

  pber := ber_alloc_t(LBER_USE_DER);
  if pber = nil then
  begin
    Result := nil;
    Exit;
  end;

  New(pLControl);
  ZeroMemory(pLControl, SizeOf(LDAPControl));

  if pLControl= nil then
  begin
    Dispose(pLControl);
    ber_free(pber, 1);
    Result := nil
  end;

  ber_printf(pber, AnsiString('{i}'), iFlagValue);

  res := ber_flatten(pber, pldctrl_value);
  ber_free(pber, 1);
  if res <> 0 then
  begin
    Dispose(pLControl);
    Result := nil;
    Exit;
  end;

  pLControl.ldctl_oid := PAnsiChar(LDAP_SERVER_EXTENDED_DN_OID);
  pLControl.ldctl_iscritical := True;
  New(pLControl.ldctl_value.bv_val);
  ZeroMemory(pLControl.ldctl_value.bv_val, pldctrl_value.bv_len);
  CopyMemory(
    pLControl.ldctl_value.bv_val,
    pldctrl_value.bv_val,
    pldctrl_value.bv_len
  );
  pLControl.ldctl_value.bv_len := pldctrl_value.bv_len;

  ber_bvfree(PLDAPBerVal(pldctrl_value));

  Result := pLControl;
end;

procedure TLDAPEnum.SyncException;
begin
  if Assigned(FExceptionProc)
    then FExceptionProc(FExceptionMsg, FExceptionCode);
end;

procedure TLDAPEnum.SyncProgress;
begin
  if Assigned(FProgressProc)
    then FProgressProc(FObj, FProgressValue);
end;

end.

