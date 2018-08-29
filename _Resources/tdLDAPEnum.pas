unit tdLDAPEnum;

interface

uses
  System.Classes, Winapi.Windows, System.SysUtils, System.AnsiStrings, System.TypInfo,
  System.DateUtils, Winapi.ActiveX, ADC.LDAP, JwaRpcdce, ActiveDs_TLB, MSXML2_TLB,
  ADC.Types, ADC.DC, ADC.Attributes, ADC.ADObject, ADC.ADObjectList, ADC.Common,
  ADC.AD;

type
  TLDAPEnum = class(TThread)
  private
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
    FDomainHostName: string;
    FMaxPwdAge_Secs: Int64;
    FMaxPwdAge_Days: Int64;
    procedure FillEventList(AStringStream: TStringStream;
      AOutList: TStringList);
    procedure SyncProgress;
    procedure SyncException;
    procedure Clear;
    procedure ProcessObjects;
    function GetDomainDN: AnsiString;
    procedure GetMaxPasswordAge(ABase: AnsiString);
    function TimestampToDateTime(AAttrVal: PAnsiChar): TDateTime;
    function FormatExtDNFlags(iFlagValue: Integer): PLDAPControl;
  protected
    destructor Destroy; override;
    procedure Execute; override;
    procedure DoProgress(AProgress: Integer); overload;
    procedure DoProgress; overload;
    procedure DoException(AMsg: string; ACode: ULONG);
  public
    constructor Create(AConnection: PLDAP; AAttrCatalog: TAttrCatalog;
      AOutList: TADObjectList<TADObject>; AProgressProc: TProgressProc;
      AExceptionProc: TExceptionProc; CreateSuspended: Boolean = False); reintroduce;
  end;

implementation

{ TLDAPEnum }

procedure TLDAPEnum.ProcessObjects;
var
  ldapEntry: PLDAPMessage;
  ldapValues: PPAnsiChar;
  ldapBinValues: PPLDAPBerVal;
  attr: TADAttribute;
  i: Integer;
  dn: PAnsiChar;
  memStream: TMemoryStream;
  strStream: TStringStream;
  d: TDateTime;
begin
  ldapEntry := ldap_first_entry(FLDAP, FLDAPSearchResult);
  while ldapEntry <> nil do
  begin
    if Terminated then Break;
    FObj := TADObject.Create;
    FObj.DomainHostName := FDomainHostName;

    for i := 0 to FAttrCatalog.Count - 1 do
    begin
      attr := FAttrCatalog[i]^;
      if attr.ObjProperty = 'nearestEvent' then
      begin
        ldapBinValues := ldap_get_values_len(FLDAP, ldapEntry, PAnsiChar(AnsiString(attr.Name)));
        if (ldapBinValues <> nil) and (ldapBinValues^.bv_len > 0) then
        begin
          strStream := TStringStream.Create;
          try
            strStream.Write(
              ldapBinValues^.bv_val^,
              ldapBinValues^.bv_len
            );
            strStream.Seek(0, soFromBeginning);
            FillEventList(strStream, FObj.events);
          finally
            strStream.Free;
          end;
        end;
        ldap_value_free_len(ldapBinValues);
      end else
      case IndexText(attr.Name,
        [
          'lastLogon',             { 0 }
          'pwdLastSet',            { 1 }
          'badPwdCount',           { 2 }
          'groupType',             { 3 }
          'userAccountControl',    { 4 }
          'objectSid',             { 5 }
          'thumbnailPhoto',        { 6 }
          'distinguishedName',     { 7 }
          'primaryGroupToken'      { 8 }
        ]
      ) of
        0: begin                   { lastLogon }
          ldapBinValues := ldap_get_values_len(FLDAP, ldapEntry, PAnsiChar(AnsiString(attr.Name)));
          if (ldapBinValues <> nil) and (ldapBinValues^.bv_len > 0)
            then SetFloatProp(FObj, string(attr.ObjProperty), Self.TimestampToDateTime(ldapBinValues^.bv_val));
          ldap_value_free_len(ldapBinValues);
        end;

        1: begin                   { pwdLastSet }
          ldapBinValues := ldap_get_values_len(FLDAP, ldapEntry, PAnsiChar(AnsiString(attr.Name)));
          if (ldapBinValues <> nil) and (ldapBinValues^.bv_len > 0) then
          begin
            d := Self.TimestampToDateTime(ldapBinValues^.bv_val);
            if d > 0
              then SetFloatProp(FObj, string(attr.ObjProperty), IncSecond(d, FMaxPwdAge_Secs))
              else SetFloatProp(FObj, string(attr.ObjProperty), 0)
          end;
          ldap_value_free_len(ldapBinValues);
        end;

        2..4: begin                { badPwdCount, groupType, userAccountControl }
          ldapBinValues := ldap_get_values_len(FLDAP, ldapEntry, PAnsiChar(AnsiString(attr.Name)));
          if (ldapBinValues <> nil) and (ldapBinValues^.bv_len > 0)
            then SetPropValue(FObj, string(attr.ObjProperty), StrToIntDef(ldapBinValues^.bv_val, 0));
          ldap_value_free_len(ldapBinValues);
        end;

        5: begin                   { objectSid }
          ldapBinValues := ldap_get_values_len(FLDAP, ldapEntry, PAnsiChar(AnsiString(attr.Name)));
          if (ldapBinValues <> nil) and (ldapBinValues^.bv_len > 0)
            then SetPropValue(FObj, string(attr.ObjProperty), SIDToString(ldapBinValues^.bv_val));
          ldap_value_free_len(ldapBinValues);
        end;

        6: begin                   { thumbnailPhoto }
          ldapBinValues := ldap_get_values_len(FLDAP, ldapEntry, PAnsiChar(AnsiString(attr.Name)));
          if (ldapBinValues <> nil) and (ldapBinValues^.bv_len > 0) then
          begin
            memStream := TMemoryStream.Create;
            try
              memStream.Write(
                ldapBinValues^.bv_val^,
                ldapBinValues^.bv_len
              );
              memStream.Seek(0, soFromBeginning);
              FObj.thumbnailPhoto.LoadFromStream(memStream);
            finally
              memStream.Free;
            end;
          end;
          ldap_value_free_len(ldapBinValues);
        end;

        7: begin                   { distinguishedName }
          dn := ldap_get_dn(FLDAP, ldapEntry);
          if dn <> nil then SetPropValue(FObj, string(attr.ObjProperty), string(dn));
          ldap_memfree(dn);
        end;

        8: begin                  { primaryGroupToken }
          ldapBinValues := ldap_get_values_len(FLDAP, ldapEntry, PAnsiChar(AnsiString(attr.Name)));
          if (ldapBinValues <> nil) and (ldapBinValues^.bv_len > 0)
            then SetPropValue(FObj, string(attr.ObjProperty), StrToIntDef(ldapBinValues^.bv_val, 0));
          ldap_value_free_len(ldapBinValues);
        end;

        else begin                 { Все текстовые атрибуты }
          ldapValues := ldap_get_values(FLDAP, ldapEntry, PAnsiChar(AnsiString(attr.Name)));
          if ldap_count_values(ldapValues) > 0
            then SetPropValue(FObj, string(attr.ObjProperty), string(AnsiString(ldapValues^)));
          ldap_value_free(ldapValues);
        end;
      end;
    end;
    FOutList.Add(FObj);
    ldapEntry := ldap_next_entry(FLDAP, ldapEntry);
    DoProgress;
  end;
end;

procedure TLDAPEnum.Clear;
var
  i: Integer;
begin
  if Terminated
    then FOutList.Clear
    else FOutList.SortObjects;
  FLDAP := nil;
  FProgressProc := nil;
  FProgressValue := 0;
  FExceptionProc := nil;
  FExceptionCode := 0;
  FExceptionMsg := '';
  FAttrCatalog := nil;
  FMaxPwdAge_Secs := 0;
  FMaxPwdAge_Days := 0;
  FOutList := nil;
  FObj := nil;
  if FLDAPSearchResult <> nil
    then ldap_msgfree(FLDAPSearchResult);
  for i := Low(FAttributes) to High(FAttributes) do
    System.AnsiStrings.StrDispose(FAttributes[i]);
end;

constructor TLDAPEnum.Create(AConnection: PLDAP; AAttrCatalog: TAttrCatalog;
  AOutList: TADObjectList<TADObject>; AProgressProc: TProgressProc;
  AExceptionProc: TExceptionProc; CreateSuspended: Boolean = False);
var
  i: Integer;
begin
  inherited Create(CreateSuspended);

  FreeOnTerminate := True;
  FLDAP := AConnection;
  FAttrCatalog := AAttrCatalog;
  FOutList := AOutList;
  FOutList.Clear;
  FProgressProc := AProgressProc;
  FExceptionProc := AExceptionProc;

  if AConnection = nil then
  begin
    Self.Terminate;
    DoException('No server binding.', 0);
    Exit;
  end;

  SetLength(FAttributes, FAttrCatalog.Count + 1);
  for i := 0 to FAttrCatalog.Count - 1 do
    FAttributes[i] := System.AnsiStrings.StrNew(PAnsiChar(AnsiString(FAttrCatalog[i]^.Name)));
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
  ldapControls: array[0..1] of PLDAPControl;
  ldapServerControls: PPLDAPControl;
  ldapCount: ULONG;
  morePages: Boolean;
  i: Integer;
begin
  try
    if Terminated
      then raise Exception.Create('No server binding.');

    { Из подключения получаем DNS-имя КД }
    ldapBase := GetDomainDN;

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
    ')';

    ldapExtDN := nil;
    ldapCookie := nil;

    DoProgress(0);

//    ldapExtDN := FormatExtDNFlags(1);
    ldapControls[1] := ldapExtDN;

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
         ldap_controls_free(ldapServerControls^);
         ldapServerControls := nil;
      end;

      ldapControls[0]:= nil;
      ldap_control_free(ldapPage^);
      ldapPage := nil;

      ProcessObjects;

      ldap_msgfree(FLDAPSearchResult);
      FLDAPSearchResult := nil;
    until (morePages = False);

    ber_bvfree(ldapCookie);
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

function TLDAPEnum.GetDomainDN: AnsiString;
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
      then Result := ldapValue^;
    ldap_value_free(ldapValue);

    ldapValue := ldap_get_values(FLDAP, ldapEntry, attrArray[1]);
    if ldapValue <> nil
      then FDomainHostName := ldapValue^;
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

procedure TLDAPEnum.FillEventList(AStringStream: TStringStream;
  AOutList: TStringList);
var
  XMLDoc: IXMLDOMDocument;
  XMLNodeList: IXMLDOMNodeList;
  XMLNode: IXMLDOMNode;
  i: Integer;
  eventString: string;
begin
  AOutList.Clear;
  XMLDoc := CoDOMDocument60.Create;
  try
    XMLDoc.async := False;
    XMLDoc.load(TStreamAdapter.Create(AStringStream) as IStream);
    if XMLDoc.parseError.errorCode = 0 then
    begin
      XMLNodeList := XMLDoc.documentElement.selectNodes('event');
      for i := 0 to XMLNodeList.length - 1 do
      begin
        XMLNode := XMLNodeList.item[i].selectSingleNode('date');
        eventString := XMLNode.text;
        XMLNode := XMLNodeList.item[i].selectSingleNode('description');
        eventString := eventString + '=' + XMLNode.text;
        AOutList.Add(eventString);
      end;
    end;
  finally
    XMLDoc := nil;
  end;
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
    then FProgressProc(FProgressValue);
end;

function TLDAPEnum.TimestampToDateTime(AAttrVal: PAnsiChar): TDateTime;
var
  int64Value: Int64;
  LocalTime: TFileTime;
  SystemTime: TSystemTime;
  FileTime : TFileTime;
begin
  int64Value := StrToInt64Def(AAttrVal, 0);
  if int64Value = 0 then Result := 0 else
  try
    {int64Value := LastLogon.HighPart;
    int64Value := int64Value shl 32;
    int64Value := int64Value + LastLogon.LowPart;}
    Result := EncodeDate(1601,1,1);
    FileTime := TFileTime(int64Value);
    if FileTimeToLocalFileTime(FileTime, LocalTime) then
      if FileTimeToSystemTime(LocalTime, SystemTime) then
        Result := SystemTimeToDateTime(SystemTime);
  except
    Result := 0;
  end;
end;

end.

