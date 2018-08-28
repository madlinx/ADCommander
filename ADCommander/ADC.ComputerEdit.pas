unit ADC.ComputerEdit;

interface

uses
  System.SysUtils, System.StrUtils, Winapi.ActiveX, JwaActiveDS, ActiveDS_TLB,
  Winapi.Windows, System.Variants, ADC.Types, ADC.LDAP, ADC.AD, ADC.Common,
  System.RegularExpressions;

type
  TMACAddrFormat = (gfSixOfTwo, gfThreeOfFour);
  TMACAddrSeparator = (gsDot, gsColon, gsHyphen);

type
  TMACAddr = type string;

type
  TComputerEdit = record
    dNSHostName: string;
    employeeID: string;
    IPv4: string;
    DHCP_Server: string;
    MAC_Address: TMACAddr;
    operatingSystem: string;
    operatingSystemHotfix: string;
    operatingSystemServicePack: string;
    operatingSystemVersion: string;
    procedure Clear;
  end;

  TMACAddrHelper = record helper for TMACAddr
  private
    function GetGroupLength(AValue: TMACAddrFormat): Integer;
    function GetSeparator(AValue: TMACAddrSeparator): string;
  public
    function Format(AFormat: TMACAddrFormat; ASeparator: TMACAddrSeparator;
      AUpperCase: Boolean = False): string;
  end;

  TComputerEditHelper = record helper for TComputerEdit
  private
    function GetAttrStrValue(AObj: IADs; AAttrName: string): string;
    procedure GenerateDSMod(AAttr: PChar; AValues: Pointer;
      ANumValues: Cardinal; AMod: PADS_ATTR_INFO);
    procedure GenerateLDAPStrMod(AAttr: PAnsiChar;
      AStrVals: Pointer; var AMod: PLDAPMod);
    function GetDomainDN(ALDAP: PLDAP): AnsiString;
    function GetDistinguishedNameByName(ARootDSE: IADS; AName: string): string; overload;
    function GetDistinguishedNameByName(ALDAP: PLDAP; AName: string): string; overload;
  public
    procedure GetExtendedInfo;
    procedure GetInfoDS(ARootDSE: IADS; ADN: string);
    procedure GetInfo(ARootDSE: IADS; ADN: string); overload;
    procedure GetInfo(ALDAP: PLDAP; ADN: string); overload;
    procedure GetInfoByNameDS(ARootDSE: IADS; AName: string);
    procedure GetInfoByName(ARootDSE: IADS; AName: string); overload;
    procedure GetInfoByName(ALDAP: PLDAP; AName: string); overload;
    procedure SetInfoDS(ARootDSE: IADS; ADN: string);
    procedure SetInfo(ARootDSE: IADS; ADN: string); overload;
    procedure SetInfo(ALDAP: PLDAP; ADN: string); overload;
  end;

implementation

{ TADComputerHelper }

procedure TComputerEditHelper.GetInfo(ARootDSE: IADS; ADN: string);
var
  dn: string;
  objComputer: IADs;
  hr: HRESULT;
  v: OleVariant;
  hostName: string;
begin
  Self.Clear;

  if ADN.IsEmpty
    then Exit;

  CoInitialize(nil);

  try
    v := ARootDSE.Get('dnsHostName');
    hostName := VariantToStringWithDefault(v, '');
    VariantClear(v);

    dn := ReplaceStr(ADN, '/', '\/');

    hr := ADsOpenObject(
      PChar(Format('LDAP://%s/%s', [hostName, dn])),
      nil,
      nil,
      ADS_SECURE_AUTHENTICATION or ADS_SERVER_BIND,
      IID_IADs,
      @objComputer
    );

    if Succeeded(hr) then
    begin
      employeeID                 := GetAttrStrValue(objComputer, 'employeeID');
      operatingSystem            := GetAttrStrValue(objComputer, 'operatingSystem');
      operatingSystemHotfix      := GetAttrStrValue(objComputer, 'operatingSystemHotfix');
      operatingSystemServicePack := GetAttrStrValue(objComputer, 'operatingSystemServicePack');
      operatingSystemVersion     := GetAttrStrValue(objComputer, 'operatingSystemVersion');
      dNSHostName                := GetAttrStrValue(objComputer, 'dNSHostName');
    end else raise Exception.Create(ADSIErrorToString);
  finally
    CoUninitialize;
  end;
end;

procedure TComputerEditHelper.GenerateDSMod(AAttr: PChar; AValues: Pointer;
  ANumValues: Cardinal; AMod: PADS_ATTR_INFO);
begin
  with AMod^ do
  begin
    pszAttrName   := AAttr;
    case ANumValues of
      0: begin
        dwControlCode := ADS_ATTR_CLEAR;
        dwADsType     := ADSTYPE_INVALID;
        pADsValues    := nil;
      end;

      else begin
        dwControlCode := ADS_ATTR_UPDATE;
        dwADsType     := PADSVALUE(AValues)^.dwType;
        pADsValues    := AValues;
      end;
    end;
    dwNumValues   := ANumValues;
  end;
end;

procedure TComputerEditHelper.GenerateLDAPStrMod(AAttr: PAnsiChar;
  AStrVals: Pointer; var AMod: PLDAPMod);
begin
  New(AMod);
  with AMod^ do
  begin
    mod_type     := AAttr;
    mod_op       := LDAP_MOD_REPLACE;
    modv_strvals := AStrVals;
  end;
end;

function TComputerEditHelper.GetAttrStrValue(AObj: IADs;
  AAttrName: string): string;
var
  v: OleVariant;
begin
  Result := '';

  try
    v := AObj.Get(AAttrName);
    if not VarIsNull(v)
      then Result := VarToStr(v)
  except

  end;

  VariantClear(v);
end;

function TComputerEditHelper.GetDistinguishedNameByName(ALDAP: PLDAP;
  AName: string): string;
const
  Attributes: array of PAnsiChar = [PAnsiChar('distinguishedName'), nil];
var
  DomainDN: AnsiString;
  DomainHostName: AnsiString;
  returnCode: ULONG;
  errorCode: ULONG;
  ldapSearchResult: PLDAPMessage;
  ldapBase: AnsiString;
  ldapFilter: AnsiString;
  ldapCookie: PLDAPBerVal;
  ldapPage: PLDAPControl;
  ldapControls: array[0..1] of PLDAPControl;
  ldapServerControls: PPLDAPControl;
  ldapCount: ULONG;
  ldapEntry: PLDAPMessage;
  morePages: Boolean;
  dn: PAnsiChar;
  i: Integer;
begin
  try
    ldapBase := GetDomainDN(ALDAP);

    { Формируем фильтр объектов AD }
    ldapFilter := Format(
        '(&(objectCategory=computer)(cn=%s))',
        [AName]
    );

    ldapCookie := nil;

    { Постраничный поиск объектов AD }
    repeat
      returnCode := ldap_create_page_control(
        ALDAP,
        ADC_SEARCH_PAGESIZE,
        ldapCookie,
        1,
        ldapPage
      );

      if returnCode <> LDAP_SUCCESS
        then raise Exception.Create('Failure during ldap_create_page_control: ' + ldap_err2string(returnCode));

      ldapControls[0] := ldapPage;
      ldapControls[1] := nil;

      returnCode := ldap_search_ext_s(
        ALDAP,
        PAnsiChar(ldapBase),
        LDAP_SCOPE_SUBTREE,
        PAnsiChar(ldapFilter),
        PAnsiChar(@Attributes[0]),
        0,
        @ldapControls,
        nil,
        nil,
        0,
        ldapSearchResult
      );

      if not (returnCode in [LDAP_SUCCESS, LDAP_PARTIAL_RESULTS])
        then raise Exception.Create('Failure during ldap_search_ext_s: ' + ldap_err2string(returnCode));

      returnCode := ldap_parse_result(
        ALDAP^,
        ldapSearchResult,
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
        ALDAP,
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

      { Обработка объекта }
      ldapEntry := ldap_first_entry(ALDAP, ldapSearchResult);
      while ldapEntry <> nil do
      begin
        dn := ldap_get_dn(ALDAP, ldapEntry);
        if dn <> nil
          then Result := dn;
        ldap_memfree(dn);

        ldapEntry := ldap_next_entry(ALDAP, ldapEntry);
      end;

      ldap_msgfree(ldapSearchResult);
      ldapSearchResult := nil;
    until (morePages = False);

    ber_bvfree(ldapCookie);
    ldapCookie := nil;
  except

  end;

  if ldapSearchResult <> nil
    then ldap_msgfree(ldapSearchResult);
end;

function TComputerEditHelper.GetDomainDN(ALDAP: PLDAP): AnsiString;
var
  attr: PAnsiChar;
  attrArray: array of PAnsiChar;
  returnCode: ULONG;
  searchResult: PLDAPMessage;
  ldapEntry: PLDAPMessage;
  ldapValue: PPAnsiChar;
begin
  SetLength(attrArray, 2);
  attrArray[0] := PAnsiChar('defaultNamingContext');
  attrArray[1] := nil;

  returnCode := ldap_search_ext_s(
    ALDAP,
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

  if (returnCode = LDAP_SUCCESS) and (ldap_count_entries(ALDAP, searchResult) > 0 ) then
  begin
    ldapEntry := ldap_first_entry(ALDAP, searchResult);
    ldapValue := ldap_get_values(ALDAP, ldapEntry, attrArray[0]);
    if ldapValue <> nil
      then Result := ldapValue^;
    ldap_value_free(ldapValue);
  end;

  if searchResult <> nil
    then ldap_msgfree(searchResult);
end;

procedure TComputerEditHelper.GetExtendedInfo;
var
  infoIP: PIPAddr;
  infoDHCP: PDHCPInfo;
  sFormat: string;
  sSrvName: string;
begin
  New(infoIP);
  New(infoDHCP);

  if not Self.dNSHostName.IsEmpty then
  begin
    GetIPAddress(Self.dNSHostName, infoIP);
    GetDHCPInfo(Self.dNSHostName, infoDHCP);
  end;

  IPv4 := IfThen(
    infoIP^.v4.IsEmpty,
    infoDHCP^.IPAddress.v4,
    infoIP^.v4
  );

  sSrvName := IfThen(
    infoDHCP^.ServerName.IsEmpty,
    infoDHCP^.ServerNetBIOSName,
    infoDHCP^.ServerName
  );

  sFormat := IfThen(sSrvName.IsEmpty, '%s', '%s ( %s )');

  MAC_Address := infoDHCP^.HardwareAddress;
  DHCP_Server := Format(
    sFormat,
    [infoDHCP^.ServerAddress, sSrvName]
  );

  Dispose(infoIP);
  Dispose(infoDHCP);
end;

function TComputerEditHelper.GetDistinguishedNameByName(ARootDSE: IADS;
  AName: string): string;
const
  Attributes: array of WideString = ['distinguishedName'];
var
  v: OleVariant;
  DomainDN: string;
  DomainHostName: string;
  SearchRes: IDirectorySearch;
  SearchHandle: PHandle;
  objFilter: string;
  hRes: HRESULT;
  SearchPrefs: array of ADS_SEARCHPREF_INFO;
  col: ADS_SEARCH_COLUMN;
  dn: string;
begin
  if (ARootDSE = nil) or AName.IsEmpty
    then Exit;

  CoInitialize(nil);

  v := ARootDSE.Get('defaultNamingContext');
  DomainDN := VariantToStringWithDefault(v, '');
  VariantClear(v);

  v := ARootDSE.Get('dnsHostName');
  DomainHostName := VariantToStringWithDefault(v, '');
  VariantClear(v);

  try
    { Осуществляем поиск в домене атрибутов и их значений }
    hRes := ADsOpenObject(
      PChar('LDAP://' + DomainHostName + '/' + DomainDN),
      nil,
      nil,
      ADS_SECURE_AUTHENTICATION or ADS_SERVER_BIND,
      IID_IDirectorySearch,
      @SearchRes
    );

    if Succeeded(hRes) then
    begin
      SetLength(SearchPrefs, 3);
      with SearchPrefs[0] do
      begin
        dwSearchPref  := ADS_SEARCHPREF_PAGESIZE;
        vValue.dwType := ADSTYPE_INTEGER;
        vValue.__MIDL____MIDL_itf_ads_0000_00000000.Integer := ADC_SEARCH_PAGESIZE;
      end;
      with SearchPrefs[1] do
      begin
        dwSearchPref  := ADS_SEARCHPREF_PAGED_TIME_LIMIT;
        vValue.dwType := ADSTYPE_INTEGER;
        vValue.__MIDL____MIDL_itf_ads_0000_00000000.Integer := 60;
      end;
      with SearchPrefs[2] do
      begin
        dwSearchPref  := ADS_SEARCHPREF_SEARCH_SCOPE;
        vValue.dwType := ADSTYPE_INTEGER;
        vValue.__MIDL____MIDL_itf_ads_0000_00000000.Integer := ADS_SCOPE_SUBTREE;
      end;

      hRes := SearchRes.SetSearchPreference(SearchPrefs[0], Length(SearchPrefs));

      objFilter := Format(
          '(&(objectCategory=computer)(cn=%s))',
          [AName]
      );

      SearchRes.ExecuteSearch(
        PWideChar(objFilter),
        PWideChar(@Attributes[0]),
        Length(Attributes),
        Pointer(SearchHandle)
      );

      { Обработка объекта }
      hRes := SearchRes.GetNextRow(SearchHandle);
      while (hRes <> S_ADS_NOMORE_ROWS) do
      begin
        hRes := SearchRes.GetColumn(SearchHandle, PWideChar(Attributes[0]), col);
        if Succeeded(hRes)
          then Result := col.pADsValues^.__MIDL____MIDL_itf_ads_0000_00000000.CaseIgnoreString;

        SearchRes.FreeColumn(col);
        hRes := SearchRes.GetNextRow(Pointer(SearchHandle));
      end;
    end;
  except

  end;

  SearchRes.CloseSearchHandle(Pointer(SearchHandle));
end;

procedure TComputerEditHelper.GetInfo(ALDAP: PLDAP; ADN: string);
var
  i: Integer;
  attr: PAnsiChar;
  attrArray: array of PAnsiChar;
  returnCode: ULONG;
  searchResult: PLDAPMessage;
  ldapEntry: PLDAPMessage;
  ldapValues: PPAnsiChar;
  ldapBerValues: PPLDAPBerVal;
  d: TDateTime;
begin
  Self.Clear;

  if (ALDAP = nil) or ADN.IsEmpty
    then Exit;

  SetLength(attrArray, 7);
  attrArray[0] := PAnsiChar('employeeID');
  attrArray[1] := PAnsiChar('operatingSystem');
  attrArray[2] := PAnsiChar('operatingSystemHotfix');
  attrArray[3] := PAnsiChar('operatingSystemServicePack');
  attrArray[4] := PAnsiChar('operatingSystemVersion');
  attrArray[5] := PAnsiChar('dNSHostName');

  returnCode := ldap_search_ext_s(
    ALDAP,
    PAnsiChar(AnsiString(ADN)),
    LDAP_SCOPE_BASE,
    nil,
    PAnsiChar(@attrArray[0]),
    0,
    nil,
    nil,
    nil,
    0,
    searchResult
  );

  if (returnCode = LDAP_SUCCESS) and (ldap_count_entries(ALDAP, searchResult) > 0 ) then
  begin
    ldapEntry := ldap_first_entry(ALDAP, searchResult);
    if ldapEntry <> nil then
    for i := Low(attrArray) to High(attrArray) do
    begin
      case IndexText(attrArray[i], [
        'employeeID',
        'operatingSystem',
        'operatingSystemHotfix',
        'operatingSystemServicePack',
        'operatingSystemVersion',
        'dNSHostName']
      ) of
        0: begin
          ldapValues := ldap_get_values(ALDAP, ldapEntry, attrArray[i]);
          if ldap_count_values(ldapValues) > 0
            then Self.employeeID := string(AnsiString(ldapValues^));
          ldap_value_free(ldapValues);
        end;

        1: begin
          ldapValues := ldap_get_values(ALDAP, ldapEntry, attrArray[i]);
          if ldap_count_values(ldapValues) > 0
            then Self.operatingSystem := string(AnsiString(ldapValues^));
          ldap_value_free(ldapValues);
        end;

        2: begin
          ldapValues := ldap_get_values(ALDAP, ldapEntry, attrArray[i]);
          if ldap_count_values(ldapValues) > 0
            then Self.operatingSystemHotfix := string(AnsiString(ldapValues^));
          ldap_value_free(ldapValues);
        end;

        3: begin
          ldapValues := ldap_get_values(ALDAP, ldapEntry, attrArray[i]);
          if ldap_count_values(ldapValues) > 0
            then Self.operatingSystemServicePack := string(AnsiString(ldapValues^));
          ldap_value_free(ldapValues);
        end;

        4: begin
          ldapValues := ldap_get_values(ALDAP, ldapEntry, attrArray[i]);
          if ldap_count_values(ldapValues) > 0
            then Self.operatingSystemVersion := string(AnsiString(ldapValues^));
          ldap_value_free(ldapValues);
        end;

        5: begin
          ldapValues := ldap_get_values(ALDAP, ldapEntry, attrArray[i]);
          if ldap_count_values(ldapValues) > 0
            then Self.dNSHostName := LowerCase(string(AnsiString(ldapValues^)));
          ldap_value_free(ldapValues);
        end;
      end;
    end;
    ldap_msgfree(searchResult);
    searchResult := nil;
  end;

  if searchResult <> nil
    then ldap_msgfree(searchResult);
end;

procedure TComputerEditHelper.GetInfoByName(ARootDSE: IADS; AName: string);
var
  dn: string;
begin
  dn := GetDistinguishedNameByName(ARootDSE, AName);
  GetInfo(ARootDSE, dn);
end;

procedure TComputerEditHelper.GetInfoByName(ALDAP: PLDAP; AName: string);
var
  dn: string;
begin
  dn := GetDistinguishedNameByName(ALDAP, AName);
  GetInfo(ALDAP, dn);
end;

procedure TComputerEditHelper.GetInfoByNameDS(ARootDSE: IADS; AName: string);
var
  dn: string;
begin
  dn := GetDistinguishedNameByName(ARootDSE, AName);
  GetInfoDS(ARootDSE, dn);
end;

procedure TComputerEditHelper.GetInfoDS(ARootDSE: IADS; ADN: string);
var
  v: OleVariant;
  hostName: string;
  dn: string;
  IDir: IDirectoryObject;
  hr: HRESULT;
  attrArray: array of PWideChar;
  attrEntries: PADS_ATTR_INFO;
  attrCount: LongWord;
  i: Integer;
  j: Integer;
begin
  Self.Clear;

  if ADN.IsEmpty
    then Exit;

  IDir := nil;
  attrEntries := nil;

  CoInitialize(nil);

  try
    v := ARootDSE.Get('dnsHostName');
    hostName := VariantToStringWithDefault(v, '');
    VariantClear(v);

    dn := ReplaceStr(ADN, '/', '\/');

    hr := ADsOpenObject(
      PChar(Format('LDAP://%s/%s', [hostName, dn])),
      nil,
      nil,
      ADS_SECURE_AUTHENTICATION or ADS_SERVER_BIND,
      IID_IDirectoryObject,
      @IDir
    );

    if not Succeeded(hr)
        then raise Exception.Create(ADSIErrorToString);

    SetLength(attrArray, 6);
    attrArray[0] := PChar('employeeID');
    attrArray[1] := PChar('operatingSystem');
    attrArray[2] := PChar('operatingSystemHotfix');
    attrArray[3] := PChar('operatingSystemServicePack');
    attrArray[4] := PChar('operatingSystemVersion');
    attrArray[5] := PChar('dNSHostName');

    hr := IDir.GetObjectAttributes(
      @attrArray[0],
      Length(attrArray),
      @attrEntries,
      @attrCount
    );

    if not Succeeded(hr)
      then raise Exception.Create(ADSIErrorToString);

    i := 0;
    while i < attrCount  do
    begin
      case IndexText(attrEntries^.pszAttrName, [
        'employeeID',
        'operatingSystem',
        'operatingSystemHotfix',
        'operatingSystemServicePack',
        'operatingSystemVersion',
        'dNSHostName']
      ) of
        0: Self.employeeID := attrEntries^.pADsValues.__MIDL____MIDL_itf_ads_0000_00000000.CaseIgnoreString;
        1: Self.operatingSystem := attrEntries^.pADsValues.__MIDL____MIDL_itf_ads_0000_00000000.CaseIgnoreString;
        2: Self.operatingSystemHotfix := attrEntries^.pADsValues.__MIDL____MIDL_itf_ads_0000_00000000.CaseIgnoreString;
        3: Self.operatingSystemServicePack := attrEntries^.pADsValues.__MIDL____MIDL_itf_ads_0000_00000000.CaseIgnoreString;
        4: Self.operatingSystemVersion := attrEntries^.pADsValues.__MIDL____MIDL_itf_ads_0000_00000000.CaseIgnoreString;
        5: Self.dNSHostName := attrEntries^.pADsValues.__MIDL____MIDL_itf_ads_0000_00000000.CaseIgnoreString;
      end;

      Inc(i);
      Inc(attrEntries);
    end;
    Dec(attrEntries, i);
    FreeADsMem(attrEntries);
  finally
    CoUninitialize;
  end;
end;

procedure TComputerEditHelper.SetInfo(ARootDSE: IADS; ADN: string);
var
  v: OleVariant;
  hostName: string;
  dn: string;
  hr: HRESULT;
  IComputer: IADsComputer;
begin
  IComputer := nil;

  CoInitialize(nil);

  try
    v := ARootDSE.Get('dnsHostName');
    hostName := VariantToStringWithDefault(v, '');
    VariantClear(v);

    dn := ReplaceStr(ADN, '/', '\/');

    hr := ADsOpenObject(
      PChar(Format('LDAP://%s/%s', [hostName, dn])),
      nil,
      nil,
      ADS_SECURE_AUTHENTICATION or ADS_SERVER_BIND,
      IID_IADsComputer,
      @IComputer
    );

    if Succeeded(hr) then
    begin
      if Self.employeeID <> ''
        then IComputer.Put('employeeID', Self.employeeID)
        else IComputer.PutEx(ADS_PROPERTY_CLEAR, 'employeeID', Null);

      IComputer.SetInfo;
    end else raise Exception.Create(ADSIErrorToString);
  finally
    CoUninitialize;
  end;
end;

procedure TComputerEditHelper.SetInfo(ALDAP: PLDAP; ADN: string);
var
  ldapBase: AnsiString;
  modArray: array of PLDAPMod;
  valEmployeeID: array of PAnsiChar;
  returnCode: ULONG;
  i: Integer;
begin
  ldapBase := ADN;

  SetLength(modArray, 1);

  { employeeID }
  SetLength(modArray, Length(modArray) + 1);
  i := High(modArray) - 1;

  SetLength(valEmployeeID, 2);
  valEmployeeID[0] := PAnsiChar(AnsiString(Self.employeeID));

  if Self.employeeID <> ''
    then GenerateLDAPStrMod(PAnsiChar('employeeID'), @valEmployeeID[0], modArray[i])
    else GenerateLDAPStrMod(PAnsiChar('employeeID'), nil, modArray[i]);

  try
    returnCode := ldap_modify_ext_s(
      ALDAP,
      PAnsiChar(ldapBase),
      @modArray[0],
      nil,
      nil
    );

    if returnCode <> LDAP_SUCCESS
      then raise Exception.Create(ldap_err2stringW(returnCode));
  finally
    for i := Low(modArray) to High(modArray) do
      if Assigned(modArray[i])
        then Dispose(modArray[i]);
  end;
end;

procedure TComputerEditHelper.SetInfoDS(ARootDSE: IADS; ADN: string);
var
  v: OleVariant;
  hostName: string;
  dn: string;
  IDir: IDirectoryObject;
  hr: HRESULT;
  modArray: array of ADS_ATTR_INFO;
  i: Integer;
  valLength: Integer;
  valEmployeeID: array of ADSVALUE;
  modCount: LongWord;
begin
  IDir := nil;

  CoInitialize(nil);

  try
    v := ARootDSE.Get('dnsHostName');
    hostName := VariantToStringWithDefault(v, '');
    VariantClear(v);

    dn := ReplaceStr(ADN, '/', '\/');

    hr := ADsOpenObject(
      PChar(Format('LDAP://%s/%s', [hostName, dn])),
      nil,
      nil,
      ADS_SECURE_AUTHENTICATION or ADS_SERVER_BIND,
      IID_IDirectoryObject,
      @IDir
    );

    if Succeeded(hr) then
    begin
      { employeeID }
      if not Self.employeeID.IsEmpty then
      begin
        SetLength(modArray, Length(modArray) + 1);
        i := High(modArray);

        SetLength(valEmployeeID, 1);
        valEmployeeID[0].dwType := ADSTYPE_CASE_IGNORE_STRING;
        valEmployeeID[0].__MIDL____MIDL_itf_ads_0000_00000000.CaseIgnoreString := PChar(Self.employeeID);

        GenerateDSMod(
          PChar('employeeID'),
          @valEmployeeID[0],
          Length(valEmployeeID),
          @modArray[i]
        );
      end;

      hr := IDir.SetObjectAttributes(
        @modArray[0],
        Length(modArray),
        modCount
      );

      if not Succeeded(hr)
        then raise Exception.Create(ADSIErrorToString);
    end else raise Exception.Create(ADSIErrorToString);
  finally
    CoUninitialize;
  end;
end;

{ TADComputer }

procedure TComputerEdit.Clear;
begin
//  dNSHostName := '';
//  employeeID := '';
//  IPv4 := '';
//  DHCP_Server := '';
//  MAC_Address := '';
//  operatingSystem := '';
//  operatingSystemHotfix := '';
//  operatingSystemServicePack := '';
//  operatingSystemVersion := '';
  FillChar(Self, SizeOf(TComputerEdit), #0);
end;

{ TMACAddrHelper }

function TMACAddrHelper.Format(AFormat: TMACAddrFormat;
  ASeparator: TMACAddrSeparator; AUpperCase: Boolean): string;
var
  s: string;
  regEx: TRegEx;
begin
  s := StringReplace(Self, '-', '', [rfReplaceAll]);
  regEx := TRegEx.Create('(.{' + IntToStr(GetGroupLength(AFormat)) + '})(?!$)');

  if AUpperCase
    then Result := UpperCase(regEx.Replace(s, '$1' + GetSeparator(ASeparator)))
    else Result := LowerCase(regEx.Replace(s, '$1' + GetSeparator(ASeparator)));
end;

function TMACAddrHelper.GetGroupLength(AValue: TMACAddrFormat): Integer;
begin
  case Avalue of
    gfSixOfTwo: Result := 2;
    gfThreeOfFour: Result := 4;
    else Result := 2;
  end;
end;

function TMACAddrHelper.GetSeparator(AValue: TMACAddrSeparator): string;
begin
  case Avalue of
    gsDot   : Result := '.';
    gsColon : Result := ':';
    gsHyphen: Result := '-';
    else      Result := '-'
  end;
end;

end.
