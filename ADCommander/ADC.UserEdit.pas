unit ADC.UserEdit;

interface

uses
  System.SysUtils, Winapi.ActiveX, System.Variants, Winapi.Windows, ActiveDs_TLB,
  System.DateUtils, System.StrUtils, System.AnsiStrings, MSXML2_TLB, System.Classes,
  System.RegularExpressions, ADC.Types, ADC.Common, ADC.AD, ADC.LDAP, ADC.Elevation;

type
  TUserEdit = record
    cn: string[64];
    givenName: string;
    initials: string;
    sn: string;
    displayName: string;
    userPrincipalName: string;
    sAMAccountName: string;
    userWorkstations: string;
    description: string;
    employeeID: string;
    department: string;
    title: string;
    telephoneNumber: string;
    physicalDeliveryOfficeName: string;
    scriptPath: string;
    userAccountControl: Integer;
    ChangePwdAtLogon: Boolean;
    AccountIsLocked: Boolean;
    thumbnailPhoto: TImgByteArray;
    procedure Clear;
  end;

  TUserEditHelper = record helper for TUserEdit
  private
    procedure GenerateDSMod(AAttr: PChar; AValues: Pointer;
      ANumValues: Cardinal; AMod: PADS_ATTR_INFO);
    procedure GenerateLDAPStrMod(AAttr: PAnsiChar;
      AStrVals: Pointer; var AMod: PLDAPMod);
    procedure GenerateLDAPBerMod(AAttr: PAnsiChar; 
      ABerVals: Pointer; var AMod: PLDAPMod);
    procedure GetAttrBinValue(AObj: IADs; AAttrName: string; AOut: Pointer); overload;
    procedure GetAttrBinValue(AValue: PAnsiChar; ALength: Integer; AOut: Pointer); overload;
    function GetAttrStrValue(AObj: IADs; AAttrName: string): string;
    function GetAttrIntValue(AObj: IADs; AAttrName: string): Integer;
    function GetAttrDateValue(AObj: IADs; AAttrName: string): TDateTime; overload;
    function GetAttrDateValue(AValue: PAnsiChar): TDateTime; overload;
    function GetGroupByPrimaryGroupToken(ALDAP: PLDAP; AToken: Integer): PADGroup; overload;
    function GetGroupByPrimaryGroupToken(ARootDSE: IADS; AToken: Integer): PADGroup; overload;
    procedure EventListToByteArray(AList: TADEventList; var outXMLData: TXMLByteArray);
  public
    function CreateUserDS(ARootDSE: IADS; AOU: string): string;
    function CreateUser(ARootDSE: IADS; AOU: string): string; overload;
    function CreateUser(ALDAP: PLDAP; AOU: string): string; overload;
    procedure SetInfoDS(ARootDSE: IADS; ADN: string);
    procedure SetInfo(ARootDSE: IADS; ADN: string); overload;
    procedure SetInfo(ALDAP: PLDAP; ADN: string); overload;
    procedure GetInfoDS(ARootDSE: IADS; ADN: string);
    procedure GetInfo(ARootDSE: IADS; ADN: string); overload;
    procedure GetInfo(ALDAP: PLDAP; ADN: string); overload;
    procedure GetGroupList(ARootDSE: IADS; ADN: string; AList: TADGroupList); overload;
    procedure GetGroupList(ALDAP: PLDAP; ADN: string; AList: TADGroupList); overload;
    procedure SetGroupListDS(ARootDSE: IADS; AMemberDN: string; AList: TADGroupList);
    procedure SetGroupList(ARootDSE: IADS; AMemberDN: string; AList: TADGroupList); overload;
    procedure SetGroupList(ALDAP: PLDAP; AMemberDN: string; AList: TADGroupList); overload;
    procedure SetEventListDS(ARootDSE: IADS; ADN, AAttribute: string; AList: TADEventList);
    procedure SetEventList(ARootDSE: IADS; ADN, AAttribute: string; AList: TADEventList); overload;
    procedure SetEventList(ALDAP: PLDAP; ADN, AAttribute: string; AList: TADEventList); overload;
    procedure SetEventList(APath, AObjectSID: string; AList: TADEventList); overload;
    procedure SetEventList(AHandle: THandle; APath, AObjectSID: string; AList: TADEventList); overload;
  end;

implementation

{ TUserEdit }

procedure TUserEdit.Clear;
begin
  cn := '';
  givenName := '';
  initials := '';
  sn := '';
  displayName := '';
  userPrincipalName := '';
  sAMAccountName := '';
  userWorkstations := '';
  description := '';
  employeeID := '';
  department := '';
  title := '';
  telephoneNumber := '';
  physicalDeliveryOfficeName := '';
  scriptPath := '';
  userAccountControl := ADS_UF_NORMAL_ACCOUNT or ADS_UF_ACCOUNTDISABLE or ADS_UF_PASSWD_NOTREQD;
  ChangePwdAtLogon := True;
  AccountIsLocked := False;
  SetLength(thumbnailPhoto, 0);
end;

{ TUserEditHelper }

procedure TUserEditHelper.SetInfo(ARootDSE: IADS; ADN: string);
var
  v: OleVariant;
  hostName: string;
  dn: string;
  hr: HRESULT;
  IUser: IADsUser;
begin
  IUser := nil;

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
      IID_IADsUser,
      @IUser
    );

    if Succeeded(hr) then
    begin
      if Self.userAccountControl <> 0
        then IUser.Put('userAccountControl', Self.userAccountControl);

      if Self.userPrincipalName <> ''
        then IUser.Put('userPrincipalName', Self.userPrincipalName);

      if Self.sAMAccountName <> ''
        then IUser.Put('sAMAccountName', Self.sAMAccountName);

      if Self.givenName <> ''
        then IUser.Put('givenName', Self.givenName)
        else IUser.PutEx(ADS_PROPERTY_CLEAR, 'givenName', Null);

      if Self.initials <> ''
        then IUser.Put('initials', Self.initials)
        else IUser.PutEx(ADS_PROPERTY_CLEAR, 'initials', Null);

      if Self.sn <> ''
        then IUser.Put('sn', Self.sn)
        else IUser.PutEx(ADS_PROPERTY_CLEAR, 'sn', Null);

      if Self.displayName <> ''
        then IUser.Put('displayName', Self.displayName)
        else IUser.PutEx(ADS_PROPERTY_CLEAR, 'displayName', Null);

      if Self.description <> ''
        then IUser.Put('description', Self.description)
        else IUser.PutEx(ADS_PROPERTY_CLEAR, 'description', Null);

      if Self.employeeID <> ''
        then IUser.Put('employeeID', Self.employeeID)
        else IUser.PutEx(ADS_PROPERTY_CLEAR, 'employeeID', Null);

      if Self.department <> ''
        then IUser.Put('department', Self.department)
        else IUser.PutEx(ADS_PROPERTY_CLEAR, 'department', Null);

      if Self.title <> ''
        then IUser.Put('title', Self.title)
        else IUser.PutEx(ADS_PROPERTY_CLEAR, 'title', Null);

      if Self.telephoneNumber <> ''
        then IUser.Put('telephoneNumber', Self.telephoneNumber)
        else IUser.PutEx(ADS_PROPERTY_CLEAR, 'telephoneNumber', Null);

      if Self.physicalDeliveryOfficeName <> ''
        then IUser.Put('physicalDeliveryOfficeName', Self.physicalDeliveryOfficeName)
        else IUser.PutEx(ADS_PROPERTY_CLEAR, 'physicalDeliveryOfficeName', Null);

      if Self.userWorkstations <> ''
        then IUser.Put('userWorkstations', Self.userWorkstations)
        else IUser.PutEx(ADS_PROPERTY_CLEAR, 'userWorkstations', Null);

      if Self.ChangePwdAtLogon
        then IUser.Put('pwdLastSet', 0)
        else IUser.Put('pwdLastSet', -1);

      if Self.AccountIsLocked
        then IUser.Put('lockoutTime', 0);

      if Self.scriptPath <> ''
        then IUser.Put('scriptPath', Self.scriptPath)
        else IUser.PutEx(ADS_PROPERTY_CLEAR, 'scriptPath', Null);

      if Length(Self.thumbnailPhoto) > 0
        then IUser.Put('thumbnailPhoto', Self.thumbnailPhoto)
        else IUser.PutEx(ADS_PROPERTY_CLEAR, 'thumbnailPhoto', Null);

//      if SelectedDC.UserAttributeExists(fnEventList) then
//      try
//        if (EventStorage = USER_EVENT_STORAGE_AD) then
//          if Length(UserNewData.EvenList) > 0
//            then UserObject.Put(fnEventList, UserNewData.EvenList)
//            else UserObject.PutEx(ADS_PROPERTY_CLEAR, fnEventList, Null);
//      except
//  //      ADsGetLastError(ADSIError, @szErrorBuf[0], MAX_PATH, @szNameBuf[0], MAX_PATH);
//  //      ShowMessage(string(szNameBuf) + #13 + string(szErrorBuf));
//      end;

        // Не удалять! Пример записи даты в ActiveDirectory
  //    if SelectedDC.UserAttributeExists(fnControlDate) then
  //    try
  //      if UserNewData.ControlDate > 0
  //        then UserObject.Put(fnControlDate, IntToStr(DateTimeToADDate(UserNewData.ControlDate).QuadPart))
  //        else UserObject.PutEx(ADS_PROPERTY_CLEAR, fnControlDate, Null);
  //    except
  //      ADsGetLastError(ADSIError, @szErrorBuf[0], MAX_PATH, @szNameBuf[0], MAX_PATH);
  //      ShowMessage(string(szNameBuf) + #13 + string(szErrorBuf));
  //    end;

      IUser.SetInfo;
    end else raise Exception.Create(ADSIErrorToString);
  finally
    CoUninitialize;
  end;
end;

function TUserEditHelper.CreateUser(ARootDSE: IADS; AOU: string): string;
var
  v: OleVariant;
  hostName: string;
  hr: HRESULT;
  ICont: IADsContainer;
  IUser: IADsUser;
begin
  Result := '';
  ICont := nil;
  IUser := nil;

  if AOU.IsEmpty or Self.sAMAccountName.IsEmpty
    then Exit;

  CoInitialize(nil);

  try
    v := ARootDSE.Get('dnsHostName');
    hostName := VariantToStringWithDefault(v, '');
    VariantClear(v);

    hr := ADsOpenObject(
      PChar(Format('LDAP://%s/%s', [hostName, AOU])),
      nil,
      nil,
      ADS_SECURE_AUTHENTICATION or ADS_SERVER_BIND,
      IID_IADsContainer,
      @ICont
    );

    if Succeeded(hr) then
    begin
      IUser := ICont.Create(
        'user',
        'CN=' + ADEscapeReservedCharacters(Self.cn)
      ) as IADsUser;

      if IUser <> nil then
      begin
        IUser.Put('sAMAccountName', Self.sAMAccountName);
        IUser.SetInfo;
        v := IUser.Get('distinguishedName');
        Result := VariantToStringWithDefault(v, '');
        VariantClear(v);
      end else raise Exception.Create(ADSIErrorToString);
    end else raise Exception.Create(ADSIErrorToString);
  finally
    CoUninitialize;
  end;
end;

function TUserEditHelper.CreateUser(ALDAP: PLDAP; AOU: string): string;
var
  ldapDN: AnsiString;
  attrArray: array of PLDAPMod;
  valClass: array of PAnsiChar;
  valCN: array of PAnsiChar;
  valSAMAccountName: array of PAnsiChar;
  returnCode: ULONG;
  i: Integer;
begin
  if AOU.IsEmpty or Self.sAMAccountName.IsEmpty
    then Exit;

  Result := '';

  ldapDN := Format('CN=%s,%s', [ADEscapeReservedCharacters(Self.cn), AOU]);

  SetLength(valClass, 5);
  valClass[0] := PAnsiChar('top');
  valClass[1] := PAnsiChar('person');
  valClass[2] := PAnsiChar('organizationalPerson');
  valClass[3] := PAnsiChar('user');

  SetLength(valCN, 2);
  valCN[0] := PAnsiChar(AnsiString(Self.cn));

  SetLength(valSAMAccountName, 2);
  valSAMAccountName[0] := PAnsiChar(AnsiString(Self.sAMAccountName));

  SetLength(attrArray, 4);

  New(attrArray[0]);
  with attrArray[0]^ do
  begin
    mod_op       := 0;
    mod_type     := PAnsiChar('objectClass');
    modv_strvals := @valClass[0];
  end;

  New(attrArray[1]);
  with attrArray[1]^ do
  begin
    mod_op       := 0;
    mod_type     := PAnsiChar('cn');
    modv_strvals := @valCN[0];
  end;

  New(attrArray[2]);
  with attrArray[2]^ do
  begin
    mod_op       := 0;
    mod_type     := PAnsiChar('sAMAccountName');
    modv_strvals := @valSAMAccountName[0];
  end;

  try
    returnCode := ldap_add_ext_s(
      ALDAP,
      PAnsiChar(ldapDN),
      @attrArray[0],
      nil,
      nil
    );

    if returnCode <> LDAP_SUCCESS
      then raise Exception.Create(ldap_err2string(returnCode));

    Result := ldapDN;
  finally
    for i := Low(attrArray) to High(attrArray) do
      if Assigned(attrArray[i])
        then Dispose(attrArray[i]);
  end;
end;

function TUserEditHelper.CreateUserDS(ARootDSE: IADS; AOU: string): string;
var
  v: OleVariant;
  hostName: string;
  hr: HRESULT;
  attrArray: array of ADS_ATTR_INFO;
  valClass: ADSVALUE;
  valsAMAccountName: ADSVALUE;
  IDir: IDirectoryObject;
  IDisp: IDispatch;
  IUser: IADsUser;
begin
  Result := '';
  IDir := nil;
  IUser := nil;

  if AOU.IsEmpty or Self.sAMAccountName.IsEmpty
    then Exit;

  CoInitialize(nil);

  try
    v := ARootDSE.Get('dnsHostName');
    hostName := VariantToStringWithDefault(v, '');
    VariantClear(v);

    SetLength(attrArray, 2);

    with attrArray[0] do
    begin
      pszAttrName   := 'objectClass';
      dwControlCode := ADS_ATTR_UPDATE;
      dwADsType     := ADSTYPE_CASE_IGNORE_STRING;
      pADsValues    := @valClass;
      dwNumValues   := 1;
    end;

    with attrArray[1] do
    begin
      pszAttrName   := 'sAMAccountName';
      dwControlCode := ADS_ATTR_UPDATE;
      dwADsType     := ADSTYPE_CASE_IGNORE_STRING;
      pADsValues    := @valsAMAccountName;
      dwNumValues   := 1;
    end;

    valClass.dwType := ADSTYPE_CASE_IGNORE_STRING;
    valClass.__MIDL____MIDL_itf_ads_0000_00000000.CaseIgnoreString := PChar('user');

    valsAMAccountName.dwType := ADSTYPE_CASE_IGNORE_STRING;
    valsAMAccountName.__MIDL____MIDL_itf_ads_0000_00000000.CaseIgnoreString := PChar(Self.sAMAccountName);

    hr := ADsOpenObject(
      PChar(Format('LDAP://%s/%s', [hostName, AOU])),
      nil,
      nil,
      ADS_SECURE_AUTHENTICATION or ADS_SERVER_BIND,
      IID_IDirectoryObject,
      @IDir
    );

    if Succeeded(hr) then
    begin
      hr := IDir.CreateDSObject(
        PChar('CN=' + ADEscapeReservedCharacters(Self.cn)),
        @attrArray[0],
        Length(attrArray),
        IDisp
      );

      if Succeeded(hr) then
      begin
        IDisp.QueryInterface(IID_IADsUser, IUser);
        v := IUser.Get('distinguishedName');
        Result := VariantToStringWithDefault(v, '');
        VariantClear(v);
      end else raise Exception.Create(ADSIErrorToString);
    end else raise Exception.Create(ADSIErrorToString);
  finally
    CoUninitialize;
  end;
end;

procedure TUserEditHelper.EventListToByteArray(AList: TADEventList;
  var outXMLData: TXMLByteArray);
var
  XMLDoc: IXMLDOMDocument;
  XMLRoot: IXMLDOMNode;
  XMLEvent: IXMLDOMNode;
  XMLNode: IXMLDOMNode;
  e: PADEvent;
  XMLStream: TStringStream;
begin
  XMLDoc := CoDOMDocument60.Create;
  XMLDoc.async := True;
  XMLDoc.loadXML('<EVENT_CATALOG></EVENT_CATALOG>');
  for e in AList do
  begin
    XMLEvent := XMLDoc.createNode(NODE_ELEMENT, 'event', '');

    XMLNode := XMLDoc.createNode(NODE_ELEMENT, 'date', '');
    XMLNode.text := FormatDateTime('dd/mm/yyyy', e^.Date);
    XMLEvent.appendChild(XMLNode);

    XMLNode := XMLDoc.createNode(NODE_ELEMENT, 'description', '');
    XMLNode.text := e^.Description;
    XMLEvent.appendChild(XMLNode);
    XMLRoot := XMLDoc.documentElement;
    XMLRoot.appendChild(XMLEvent);
  end;

  XMLStream := TStringStream.Create;
  try
    XMLDoc.save(TStreamAdapter.Create(XMLStream) as IStream);
    XMLStream.Seek(0, soFromBeginning);
    SetLength(outXMLData, XMLStream.size);
    XMLStream.ReadBuffer(outXMLData[0], Length(outXMLData));
  finally
    XMLStream.Free;
    XMLDoc := nil;
  end;
end;

procedure TUserEditHelper.GenerateDSMod(AAttr: PChar; AValues: Pointer;
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

procedure TUserEditHelper.GenerateLDAPBerMod(AAttr: PAnsiChar;
  ABerVals: Pointer; var AMod: PLDAPMod);
begin
  New(AMod);
  with AMod^ do
  begin
    mod_type   := AAttr;
    mod_op     := LDAP_MOD_REPLACE or LDAP_MOD_BVALUES;
    modv_bvals := ABerVals;      
  end;
end;

procedure TUserEditHelper.GenerateLDAPStrMod(AAttr: PAnsiChar;
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

procedure TUserEditHelper.GetInfo(ARootDSE: IADS; ADN: string);
var
  dn: string;
  objUser: IADsUser;
  hr: HRESULT;
  v: OleVariant;
  hostName: string;
begin
  Self.Clear;

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
      @objUser
    );

    if Succeeded(hr) then
    begin
      cn                         := GetAttrStrValue(objUser, 'cn');
      givenName                  := GetAttrStrValue(objUser, 'givenName');
      initials                   := GetAttrStrValue(objUser, 'initials');
      sn                         := GetAttrStrValue(objUser, 'sn');
      displayName                := GetAttrStrValue(objUser, 'displayName');
      userPrincipalName          := GetAttrStrValue(objUser, 'userPrincipalName');
      sAMAccountName             := GetAttrStrValue(objUser, 'sAMAccountName');
      userWorkstations           := GetAttrStrValue(objUser, 'userWorkstations');
      description                := GetAttrStrValue(objUser, 'description');
      employeeID                 := GetAttrStrValue(objUser, 'employeeID');
      department                 := GetAttrStrValue(objUser, 'department');
      title                      := GetAttrStrValue(objUser, 'title');
      telephoneNumber            := GetAttrStrValue(objUser, 'telephoneNumber');
      physicalDeliveryOfficeName := GetAttrStrValue(objUser, 'physicalDeliveryOfficeName');
      scriptPath                 := GetAttrStrValue(objUser, 'scriptPath');
      userAccountControl         := GetAttrIntValue(objUser, 'userAccountControl');
      ChangePwdAtLogon           := CompareDateTime(GetAttrDateValue(objUser, 'pwdLastSet'), 0) = 0;
      AccountIsLocked            := CompareDateTime(GetAttrDateValue(objUser, 'lockoutTime'), 0) <> 0;

      GetAttrBinValue(objUser, 'thumbnailPhoto', @thumbnailPhoto);
//      GetAttrBinValue(objUser, '---', @Events);
    end else raise Exception.Create(ADSIErrorToString);
  finally
    CoUninitialize;
  end;
end;

procedure TUserEditHelper.GetAttrBinValue(AObj: IADs; AAttrName: string;
  AOut: Pointer);
type
  TAttrBinValue = array of Byte;
var
  v: OleVariant;
begin
  try
    SetLength(TAttrBinValue(AOut^), 0);

    v := AObj.Get(AAttrName);
    if not VarIsNull(v)
      then if VarIsArray(v)
        then SetLength(TAttrBinValue(AOut^), VarArrayHighBound(v, 1) - VarArrayLowBound(v,  1) + 1);

    if Length(TAttrBinValue(AOut^)) > 0
      then TAttrBinValue(AOut^) := v
  except

  end;

  VariantClear(v);
end;

procedure TUserEditHelper.GetAttrBinValue(AValue: PAnsiChar; ALength: Integer;
  AOut: Pointer);
type
  TAttrBinValue = array of Byte;
begin
  SetLength(TAttrBinValue(AOut^), ALength);
  Move(AValue^, TAttrBinValue(AOut^)[0], ALength);
end;

function TUserEditHelper.GetAttrDateValue(AValue: PAnsiChar): TDateTime;
var
  int64Value: Int64;
  LocalTime: TFileTime;
  SystemTime: TSystemTime;
  FileTime : TFileTime;
begin
//  Result := EncodeDate(1601,1,1);
  Result := 0;
  int64Value := StrToInt64Def(AValue, 0);
  if int64Value = 0 then Result := 0 else
  try
    {int64Value := LastLogon.HighPart;
    int64Value := int64Value shl 32;
    int64Value := int64Value + LastLogon.LowPart;}

    FileTime := TFileTime(int64Value);
    if FileTimeToLocalFileTime(FileTime, LocalTime) then
      if FileTimeToSystemTime(LocalTime, SystemTime) then
        Result := SystemTimeToDateTime(SystemTime);
  except
    Result := 0;
  end;
end;

function TUserEditHelper.GetAttrDateValue(AObj: IADs;
  AAttrName: string): TDateTime;
var
  v: OleVariant;
  d: TDateTime;
begin
  Result := 0;

  try
    v := AObj.Get(AAttrName);
    if not VarIsNull(v)
      then if VarIsType(v, VT_DISPATCH)
        then d := ADDateToDateTime(v);

    if CompareDate(d, 0) <> 0
      then Result := d;
  except

  end;

  VariantClear(v);
end;

function TUserEditHelper.GetAttrIntValue(AObj: IADs;
  AAttrName: string): Integer;
var
  v: OleVariant;
begin
  Result := 0;

  try
    v := AObj.Get(AAttrName);
    if not VarIsNull(v)
      then if VarIsOrdinal(v)
        then Result := StrToInt(VarToStr(v));
  except

  end;

  VariantClear(v);
end;

function TUserEditHelper.GetAttrStrValue(AObj: IADs;
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

procedure TUserEditHelper.GetGroupList(ARootDSE: IADS; ADN: string;
  AList: TADGroupList);
const
  S_ADS_NOMORE_ROWS = HRESULT($00005012);
var
  hostName: string;
  dn: string;
  hr: HRESULT;
  objUser: IADsUser;
  gID: Integer;
  objFilter: string;
  hRes: HRESULT;
  SearchBase: string;
  SearchPrefs: array of ADS_SEARCHPREF_INFO;
  SearchResult: IDirectorySearch;
  SearchHandle: PHandle;
  col: ADS_SEARCH_COLUMN;
  attrArray: array of WideString;
  g: PADGroup;
  v: OleVariant;
begin
  AList.Clear;

  CoInitialize(nil);

  try
    v := ARootDSE.Get('defaultNamingContext');
    if not VarIsNull(v)
      then SearchBase := VariantToStringWithDefault(v, '');
    VariantClear(v);

    v := ARootDSE.Get('dnsHostName');
    if not VarIsNull(v)
      then hostName := VariantToStringWithDefault(v, '');
    VariantClear(v);

    dn := ReplaceStr(ADN, '/', '\/');

    hr := ADsOpenObject(
      PChar(Format('LDAP://%s/%s', [hostName, dn])),
      nil,
      nil,
      ADS_SECURE_AUTHENTICATION or ADS_SERVER_BIND,
      IID_IADs,
      @objUser
    );

    if not Succeeded(hr)
      then raise Exception.Create(ADSIErrorToString);

    v := objUser.Get('primaryGroupID');
    if not VarIsNull(v)
      then if VarIsOrdinal(v)
        then gID := VarAsType(v, varInteger);
    VariantClear(v);

    { Получаем группу по умолчанию }
    g := GetGroupByPrimaryGroupToken(ARootDSE, gID);
    if Assigned(g) then
    begin
      g^.ImageIndex := 6;
      g^.Selected := True;
      g^.IsPrimary := True;
      case g^.groupType of
        -2147483640: g^.groupType := 8;
        -2147483646: g^.groupType := 2;
      end;
      AList.Add(g);
    end;

    { Получаем список групп в которых состоит пользователь }
    SetLength(attrArray, 5);
    attrArray[0] := PAnsiChar('distinguishedName');
    attrArray[1] := PAnsiChar('name');
    attrArray[2] := PAnsiChar('description');
    attrArray[3] := PAnsiChar('primaryGroupToken');
    attrArray[4] := PAnsiChar('groupType');

    hRes := ADsOpenObject(
      PChar('LDAP://' + hostName + '/' + SearchBase),
      nil,
      nil,
      ADS_SECURE_AUTHENTICATION or ADS_SERVER_BIND,
      IID_IDirectorySearch,
      @SearchResult
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

      hRes := SearchResult.SetSearchPreference(SearchPrefs[0], Length(SearchPrefs));

      if not Succeeded(hRes)
        then raise Exception.Create(ADSIErrorToString);

      objFilter := '(&' +
        '(objectclass=group)' +
        '(' +
           Format(
  //           'member:1.2.840.113556.1.4.1941:=%s',  { <- учитывая вложенность }
             'member=%s',
             [ADN]
           ) +
        ')' +
      ')';

      hRes := SearchResult.ExecuteSearch(
        PWideChar(objFilter),
        PWideChar(@attrArray[0]),
        Length(attrArray),
        Pointer(SearchHandle)
      );

      if not Succeeded(hRes)
        then raise Exception.Create(ADSIErrorToString);

      hRes := SearchResult.GetNextRow(SearchHandle);
      while (hRes <> S_ADS_NOMORE_ROWS) do
      begin
        New(g);

        g^.ImageIndex := 6;
        g^.Selected := True;
        g^.IsMember := True;
        g^.IsPrimary := False;

        hRes := SearchResult.GetColumn(SearchHandle, PWideChar(attrArray[0]), col);
        if Succeeded(hRes)
          then g^.distinguishedName := col.pAdsvalues^.__MIDL____MIDL_itf_ads_0000_00000000.DNString;
        SearchResult.FreeColumn(col);

        hRes := SearchResult.GetColumn(SearchHandle, PWideChar(attrArray[1]), col);
        if Succeeded(hRes)
          then g^.name := col.pAdsvalues^.__MIDL____MIDL_itf_ads_0000_00000000.CaseIgnoreString;
        SearchResult.FreeColumn(col);

        hRes := SearchResult.GetColumn(SearchHandle, PWideChar(attrArray[2]), col);
        if Succeeded(hRes)
          then g^.description := col.pAdsvalues^.__MIDL____MIDL_itf_ads_0000_00000000.CaseIgnoreString;
        SearchResult.FreeColumn(col);

        hRes := SearchResult.GetColumn(SearchHandle, PWideChar(attrArray[3]), col);
        if Succeeded(hRes)
          then g^.primaryGroupToken := col.pAdsvalues^.__MIDL____MIDL_itf_ads_0000_00000000.Integer;
        SearchResult.FreeColumn(col);

        hRes := SearchResult.GetColumn(SearchHandle, PWideChar(attrArray[4]), col);
        if Succeeded(hRes)
          then g^.groupType := col.pAdsvalues^.__MIDL____MIDL_itf_ads_0000_00000000.Integer;
        SearchResult.FreeColumn(col);

        case g^.groupType of
          -2147483640: g^.groupType := 8;
          -2147483646: g^.groupType := 2;
        end;

        AList.Add(g);
        hRes := SearchResult.GetNextRow(Pointer(SearchHandle));
      end;
    end else raise Exception.Create(ADSIErrorToString);
  finally
    SearchResult.CloseSearchHandle(Pointer(SearchHandle));
  end;
end;

function TUserEditHelper.GetGroupByPrimaryGroupToken(ALDAP: PLDAP;
  AToken: Integer): PADGroup;
var
  ldapBase: AnsiString;
  ldapFilter: AnsiString;
  ldapCookie: PLDAPBerVal;
  ldapPage: PLDAPControl;
  ldapControls: array[0..1] of PLDAPControl;
  ldapServerControls: PPLDAPControl;
  ldapEntry: PLDAPMessage;
  ldapValue: PPAnsiChar;
  ldapCount: ULONG;
  searchResult: PLDAPMessage;
  attrArray: array of PAnsiChar;
  errorCode: ULONG;
  returnCode: ULONG;
  morePages: Boolean;
  gID: Integer;
  dn: PAnsiChar;
begin
  Result := nil;
  gID := 0;

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
      then ldapBase := ldapValue^;
    ldap_value_free(ldapValue);
  end;

  if searchResult <> nil
    then ldap_msgfree(searchResult);

  SetLength(attrArray, 5);
  attrArray[0] := PAnsiChar('primaryGroupToken');
  attrArray[1] := PAnsiChar('name');
  attrArray[2] := PAnsiChar('description');
  attrArray[3] := PAnsiChar('groupType');
  attrArray[4] := nil;

  try
    { Формируем фильтр объектов AD }
    ldapFilter := '(objectclass=group)';

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
        PAnsiChar(@attrArray[0]),
        0,
        @ldapControls,
        nil,
        nil,
        0,
        SearchResult
      );

      if not (returnCode in [LDAP_SUCCESS, LDAP_PARTIAL_RESULTS])
        then raise Exception.Create('Failure during ldap_search_ext_s: ' + ldap_err2string(returnCode));

      returnCode := ldap_parse_result(
        ALDAP^,
        SearchResult,
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

      if (ldapCookie <> nil) and (ldapCookie^.bv_val <> nil) and (System.SysUtils.StrLen(ldapCookie^.bv_val) > 0)
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

      ldapEntry := ldap_first_entry(ALDAP, searchResult);
      while ldapEntry <> nil do
      begin
        ldapValue := ldap_get_values(ALDAP, ldapEntry, attrArray[0]);
        if ldapValue <> nil
          then gID := StrToIntDef(ldapValue^, 0);
        ldap_value_free(ldapValue);

        if gID = AToken then
        begin
          New(Result);

          Result^.IsMember := True;
          Result^.primaryGroupToken := gID;

          dn := ldap_get_dn(ALDAP, ldapEntry);
          if dn <> nil then Result^.distinguishedName := dn;
          ldap_memfree(dn);

          ldapValue := ldap_get_values(ALDAP, ldapEntry, attrArray[1]);
          if ldapValue <> nil
            then Result^.name := ldapValue^;
          ldap_value_free(ldapValue);

          ldapValue := ldap_get_values(ALDAP, ldapEntry, attrArray[2]);
          if ldapValue <> nil
            then Result^.description := ldapValue^;
          ldap_value_free(ldapValue);

          ldapValue := ldap_get_values(ALDAP, ldapEntry, attrArray[3]);
          if ldapValue <> nil
            then Result^.groupType := StrToIntDef(ldapValue^, 0);
          ldap_value_free(ldapValue);

          Break;
        end;
        ldapEntry := ldap_next_entry(ALDAP, ldapEntry);
      end;

      ldap_msgfree(SearchResult);
      SearchResult := nil;

      if Assigned(Result)
        then Break;
    until (morePages = False);

    ber_bvfree(ldapCookie);
    ldapCookie := nil;
  except
    on E: Exception do
    begin

    end;
  end;

  if searchResult <> nil
    then ldap_msgfree(searchResult);
end;

function TUserEditHelper.GetGroupByPrimaryGroupToken(ARootDSE: IADS;
  AToken: Integer): PADGroup;
const
  S_ADS_NOMORE_ROWS = HRESULT($00005012);
var
  hostName: string;
  hr: HRESULT;
  gID: Integer;
  objFilter: string;
  hRes: HRESULT;
  SearchBase: string;
  SearchPrefs: array of ADS_SEARCHPREF_INFO;
  SearchResult: IDirectorySearch;
  SearchHandle: PHandle;
  col: ADS_SEARCH_COLUMN;
  attrArray: array of WideString;
  v: OleVariant;
begin
  Result := nil;
  gID := 0;

  CoInitialize(nil);

  try
    v := ARootDSE.Get('defaultNamingContext');
    if not VarIsNull(v)
      then SearchBase := VariantToStringWithDefault(v, '');
    VariantClear(v);

    v := ARootDSE.Get('dnsHostName');
    if not VarIsNull(v)
      then hostName := VariantToStringWithDefault(v, '');
    VariantClear(v);

    { Получаем список групп в которых состоит пользователь }
    SetLength(attrArray, 5);
    attrArray[0] := PAnsiChar('primaryGroupToken');
    attrArray[1] := PAnsiChar('distinguishedName');
    attrArray[2] := PAnsiChar('name');
    attrArray[3] := PAnsiChar('description');
    attrArray[4] := PAnsiChar('groupType');

    hRes := ADsOpenObject(
      PChar('LDAP://' + hostName + '/' + SearchBase),
      nil,
      nil,
      ADS_SECURE_AUTHENTICATION or ADS_SERVER_BIND,
      IID_IDirectorySearch,
      @SearchResult
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

      hRes := SearchResult.SetSearchPreference(SearchPrefs[0], Length(SearchPrefs));

      if not Succeeded(hRes)
        then raise Exception.Create(ADSIErrorToString);

      objFilter := '(objectclass=group)';

      hRes := SearchResult.ExecuteSearch(
        PWideChar(objFilter),
        PWideChar(@attrArray[0]),
        Length(attrArray),
        Pointer(SearchHandle)
      );

      if not Succeeded(hRes)
        then raise Exception.Create(ADSIErrorToString);

      hRes := SearchResult.GetNextRow(SearchHandle);
      while (hRes <> S_ADS_NOMORE_ROWS) do
      begin
        hRes := SearchResult.GetColumn(SearchHandle, PWideChar(attrArray[0]), col);
        if Succeeded(hRes)
          then gID := col.pAdsvalues^.__MIDL____MIDL_itf_ads_0000_00000000.Integer;
        SearchResult.FreeColumn(col);

        if gID = AToken then
        begin
          New(Result);
          Result^.IsMember := True;
          Result^.primaryGroupToken := gID;

          hRes := SearchResult.GetColumn(SearchHandle, PWideChar(attrArray[1]), col);
          if Succeeded(hRes)
            then Result^.distinguishedName := col.pAdsvalues^.__MIDL____MIDL_itf_ads_0000_00000000.DNString;
          SearchResult.FreeColumn(col);

          hRes := SearchResult.GetColumn(SearchHandle, PWideChar(attrArray[2]), col);
          if Succeeded(hRes)
            then Result^.name := col.pAdsvalues^.__MIDL____MIDL_itf_ads_0000_00000000.CaseIgnoreString;
          SearchResult.FreeColumn(col);

          hRes := SearchResult.GetColumn(SearchHandle, PWideChar(attrArray[3]), col);
          if Succeeded(hRes)
            then Result^.description := col.pAdsvalues^.__MIDL____MIDL_itf_ads_0000_00000000.CaseIgnoreString;
          SearchResult.FreeColumn(col);

          hRes := SearchResult.GetColumn(SearchHandle, PWideChar(attrArray[4]), col);
          if Succeeded(hRes)
            then Result^.groupType := col.pAdsvalues^.__MIDL____MIDL_itf_ads_0000_00000000.Integer;
          SearchResult.FreeColumn(col);
        end;

        if Assigned(Result)
          then Break;

        hRes := SearchResult.GetNextRow(Pointer(SearchHandle));
      end;
    end else raise Exception.Create(ADSIErrorToString);
  except
    on E: Exception do
    begin

    end;
  end;

  SearchResult.CloseSearchHandle(Pointer(SearchHandle));
end;

procedure TUserEditHelper.GetGroupList(ALDAP: PLDAP; ADN: string;
  AList: TADGroupList);
var
  ldapBase: AnsiString;
  ldapFilter: AnsiString;
  ldapCookie: PLDAPBerVal;
  ldapPage: PLDAPControl;
  ldapControls: array[0..1] of PLDAPControl;
  ldapServerControls: PPLDAPControl;
  ldapEntry: PLDAPMessage;
  ldapValue: PPAnsiChar;
  ldapCount: ULONG;
  searchResult: PLDAPMessage;
  attrArray: array of PAnsiChar;
  errorCode: ULONG;
  returnCode: ULONG;
  morePages: Boolean;
  g: PADGroup;
  gID: Integer;
  dn: PAnsiChar;
begin
  AList.Clear;

  { Получаем primaryGroupID для пользователя }
  SetLength(attrArray, 2);
  attrArray[0] := PAnsiChar('primaryGroupID');
  attrArray[1] := nil;

  ldapBase := AnsiString(ADN);

  returnCode := ldap_search_ext_s(
    ALDAP,
    PAnsiChar(ldapBase),
    LDAP_SCOPE_BASE,
    PAnsiChar('(&(objectCategory=person)(objectClass=user))'),
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
      then gID := StrToIntDef(ldapValue^, 0);
    ldap_value_free(ldapValue);
  end;

  if searchResult <> nil
    then ldap_msgfree(searchResult);

  { Получаем DN имя домена }
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
      then ldapBase := ldapValue^;
    ldap_value_free(ldapValue);
  end;

  if searchResult <> nil
    then ldap_msgfree(searchResult);

  { Получаем группу по умолчанию }
  g := GetGroupByPrimaryGroupToken(ALDAP, gID);
  if Assigned(g) then
  begin
    g^.ImageIndex := 6;
    g^.Selected := True;
    g^.IsPrimary := True;
    case g^.groupType of
      -2147483640: g^.groupType := 8;
      -2147483646: g^.groupType := 2;
    end;

    AList.Add(g);
  end;

  { Получаем список групп в которых состоит пользователь }
  SetLength(attrArray, 5);
  attrArray[0] := PAnsiChar('name');
  attrArray[1] := PAnsiChar('description');
  attrArray[2] := PAnsiChar('primaryGroupToken');
  attrArray[3] := PAnsiChar('groupType');
  attrArray[4] := nil;

  try
    { Формируем фильтр объектов AD }
    ldapFilter :=
      '(&(objectclass=group)' +
      '(' +
         System.AnsiStrings.Format(
//           'member:1.2.840.113556.1.4.1941:=%s',  { <- учитывая вложенность }
           'member=%s',
           [ADN]
         ) +
      ')' +
    ')';

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
        PAnsiChar(@attrArray[0]),
        0,
        @ldapControls,
        nil,
        nil,
        0,
        SearchResult
      );

      if not (returnCode in [LDAP_SUCCESS, LDAP_PARTIAL_RESULTS])
        then raise Exception.Create('Failure during ldap_search_ext_s: ' + ldap_err2string(returnCode));

      returnCode := ldap_parse_result(
        ALDAP^,
        SearchResult,
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

      if (ldapCookie <> nil) and (ldapCookie^.bv_val <> nil) and (System.SysUtils.StrLen(ldapCookie^.bv_val) > 0)
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

      ldapEntry := ldap_first_entry(ALDAP, searchResult);
      while ldapEntry <> nil do
      begin
        New(g);
        g^.ImageIndex := 6;
        g^.Selected := True;
        g^.IsMember := True;
        g^.IsPrimary := False;
        dn := ldap_get_dn(ALDAP, ldapEntry);
        if dn <> nil then g^.distinguishedName := dn;
        ldap_memfree(dn);

        ldapValue := ldap_get_values(ALDAP, ldapEntry, attrArray[0]);
        if ldapValue <> nil
          then g^.name := ldapValue^;
        ldap_value_free(ldapValue);

        ldapValue := ldap_get_values(ALDAP, ldapEntry, attrArray[1]);
        if ldapValue <> nil
          then g^.description := ldapValue^;
        ldap_value_free(ldapValue);

        ldapValue := ldap_get_values(ALDAP, ldapEntry, attrArray[2]);
        if ldapValue <> nil
          then g^.primaryGroupToken := StrToIntDef(ldapValue^, 0);
        ldap_value_free(ldapValue);

        ldapValue := ldap_get_values(ALDAP, ldapEntry, attrArray[3]);
        if ldapValue <> nil
          then g^.groupType := StrToIntDef(ldapValue^, 0);
        ldap_value_free(ldapValue);

        case g^.groupType of
          -2147483640: g^.groupType := 8;
          -2147483646: g^.groupType := 2;
        end;

        AList.Add(g);
        ldapEntry := ldap_next_entry(ALDAP, ldapEntry);
      end;

      ldap_msgfree(SearchResult);
      SearchResult := nil;
    until (morePages = False);

    ber_bvfree(ldapCookie);
    ldapCookie := nil;
  finally
    if searchResult <> nil
      then ldap_msgfree(searchResult);
  end;
end;

procedure TUserEditHelper.GetInfo(ALDAP: PLDAP; ADN: string);
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

  if ALDAP = nil then Exit;

  SetLength(attrArray, 21);
  attrArray[0] := PAnsiChar('cn');
  attrArray[1] := PAnsiChar('givenName');
  attrArray[2] := PAnsiChar('initials');
  attrArray[3] := PAnsiChar('sn');
  attrArray[4] := PAnsiChar('displayName');
  attrArray[5] := PAnsiChar('userPrincipalName');
  attrArray[6] := PAnsiChar('sAMAccountName');
  attrArray[7] := PAnsiChar('userWorkstations');
  attrArray[8] := PAnsiChar('description');
  attrArray[9] := PAnsiChar('employeeID');
  attrArray[10] := PAnsiChar('department');
  attrArray[11] := PAnsiChar('title');
  attrArray[12] := PAnsiChar('telephoneNumber');
  attrArray[13] := PAnsiChar('physicalDeliveryOfficeName');
  attrArray[14] := PAnsiChar('scriptPath');
  attrArray[15] := PAnsiChar('userAccountControl');
  attrArray[16] := PAnsiChar('pwdLastSet');
  attrArray[17] := PAnsiChar('lockoutTime');
  attrArray[18] := PAnsiChar('thumbnailPhoto');
  attrArray[19] := PAnsiChar('---');

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
        'cn',
        'givenName',
        'initials',
        'sn',
        'displayName',
        'userPrincipalName',
        'sAMAccountName',
        'userWorkstations',
        'description',
        'employeeID',
        'department',
        'title',
        'telephoneNumber',
        'physicalDeliveryOfficeName',
        'scriptPath',
        'userAccountControl',
        'pwdLastSet',
        'lockoutTime',
        'thumbnailPhoto']
      ) of
        0: begin
          ldapValues := ldap_get_values(ALDAP, ldapEntry, attrArray[i]);
          if ldap_count_values(ldapValues) > 0
            then Self.cn := string(AnsiString(ldapValues^));
          ldap_value_free(ldapValues);
        end;

        1: begin
          ldapValues := ldap_get_values(ALDAP, ldapEntry, attrArray[i]);
          if ldap_count_values(ldapValues) > 0
            then Self.givenName := string(AnsiString(ldapValues^));
          ldap_value_free(ldapValues);
        end;

        2: begin
          ldapValues := ldap_get_values(ALDAP, ldapEntry, attrArray[i]);
          if ldap_count_values(ldapValues) > 0
            then Self.initials := string(AnsiString(ldapValues^));
          ldap_value_free(ldapValues);
        end;

        3: begin
          ldapValues := ldap_get_values(ALDAP, ldapEntry, attrArray[i]);
          if ldap_count_values(ldapValues) > 0
            then Self.sn := string(AnsiString(ldapValues^));
          ldap_value_free(ldapValues);
        end;

        4: begin
          ldapValues := ldap_get_values(ALDAP, ldapEntry, attrArray[i]);
          if ldap_count_values(ldapValues) > 0
            then Self.displayName := string(AnsiString(ldapValues^));
          ldap_value_free(ldapValues);
        end;

        5: begin
          ldapValues := ldap_get_values(ALDAP, ldapEntry, attrArray[i]);
          if ldap_count_values(ldapValues) > 0
            then Self.userPrincipalName := string(AnsiString(ldapValues^));
          ldap_value_free(ldapValues);
        end;

        6: begin
          ldapValues := ldap_get_values(ALDAP, ldapEntry, attrArray[i]);
          if ldap_count_values(ldapValues) > 0
            then Self.sAMAccountName := string(AnsiString(ldapValues^));
          ldap_value_free(ldapValues);
        end;

        7: begin
          ldapValues := ldap_get_values(ALDAP, ldapEntry, attrArray[i]);
          if ldap_count_values(ldapValues) > 0
            then Self.userWorkstations := string(AnsiString(ldapValues^));
          ldap_value_free(ldapValues);
        end;

        8: begin
          ldapValues := ldap_get_values(ALDAP, ldapEntry, attrArray[i]);
          if ldap_count_values(ldapValues) > 0
            then Self.description := string(AnsiString(ldapValues^));
          ldap_value_free(ldapValues);
        end;

        9: begin
          ldapValues := ldap_get_values(ALDAP, ldapEntry, attrArray[i]);
          if ldap_count_values(ldapValues) > 0
            then Self.employeeID := string(AnsiString(ldapValues^));
          ldap_value_free(ldapValues);
        end;

        10: begin
          ldapValues := ldap_get_values(ALDAP, ldapEntry, attrArray[i]);
          if ldap_count_values(ldapValues) > 0
            then Self.department := string(AnsiString(ldapValues^));
          ldap_value_free(ldapValues);
        end;

        11: begin
          ldapValues := ldap_get_values(ALDAP, ldapEntry, attrArray[i]);
          if ldap_count_values(ldapValues) > 0
            then Self.title := string(AnsiString(ldapValues^));
          ldap_value_free(ldapValues);
        end;

        12: begin
          ldapValues := ldap_get_values(ALDAP, ldapEntry, attrArray[i]);
          if ldap_count_values(ldapValues) > 0
            then Self.telephoneNumber := string(AnsiString(ldapValues^));
          ldap_value_free(ldapValues);
        end;

        13: begin
          ldapValues := ldap_get_values(ALDAP, ldapEntry, attrArray[i]);
          if ldap_count_values(ldapValues) > 0
            then Self.physicalDeliveryOfficeName := string(AnsiString(ldapValues^));
          ldap_value_free(ldapValues);
        end;

        14: begin
          ldapValues := ldap_get_values(ALDAP, ldapEntry, attrArray[i]);
          if ldap_count_values(ldapValues) > 0
            then Self.scriptPath := string(AnsiString(ldapValues^));
          ldap_value_free(ldapValues);
        end;

        15: begin
          ldapValues := ldap_get_values(ALDAP, ldapEntry, attrArray[i]);
          if ldap_count_values(ldapValues) > 0
            then Self.userAccountControl := StrToInt(string(AnsiString(ldapValues^)));
          ldap_value_free(ldapValues);
        end;

        16: begin
          ldapBerValues := ldap_get_values_len(ALDAP, ldapEntry, attrArray[i]);
          if (ldapBerValues <> nil) and (ldapBerValues^.bv_len > 0) then
          begin
            d := GetAttrDateValue(ldapBerValues^.bv_val);
            Self.ChangePwdAtLogon := CompareDateTime(d, 0) = 0;
          end;
          ldap_value_free_len(ldapBerValues);
        end;

        17: begin
          ldapBerValues := ldap_get_values_len(ALDAP, ldapEntry, attrArray[i]);
          if (ldapBerValues <> nil) and (ldapBerValues^.bv_len > 0) then
          begin
            d := GetAttrDateValue(ldapBerValues^.bv_val);
            Self.AccountIsLocked := CompareDateTime(d, 0) <> 0;
          end;
          ldap_value_free_len(ldapBerValues);
        end;

        18: begin
          ldapBerValues := ldap_get_values_len(ALDAP, ldapEntry, attrArray[i]);
          if (ldapBerValues <> nil) and (ldapBerValues^.bv_len > 0) then
          begin
            GetAttrBinValue(ldapBerValues^.bv_val, ldapBerValues^.bv_len, @Self.thumbnailPhoto);
          end;
          ldap_value_free_len(ldapBerValues);
        end;
      end;

    end;
    ldap_msgfree(searchResult);
    searchResult := nil;
  end;

  if searchResult <> nil
    then ldap_msgfree(searchResult);

  SetLength(attrArray, 0);
end;

procedure TUserEditHelper.GetInfoDS(ARootDSE: IADS; ADN: string);
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

    SetLength(attrArray, 20);
    attrArray[0] := PChar('cn');
    attrArray[1] := PChar('givenName');
    attrArray[2] := PChar('initials');
    attrArray[3] := PChar('sn');
    attrArray[4] := PChar('displayName');
    attrArray[5] := PChar('userPrincipalName');
    attrArray[6] := PChar('sAMAccountName');
    attrArray[7] := PChar('userWorkstations');
    attrArray[8] := PChar('description');
    attrArray[9] := PChar('employeeID');
    attrArray[10] := PChar('department');
    attrArray[11] := PChar('title');
    attrArray[12] := PChar('telephoneNumber');
    attrArray[13] := PChar('physicalDeliveryOfficeName');
    attrArray[14] := PChar('scriptPath');
    attrArray[15] := PChar('userAccountControl');
    attrArray[16] := PChar('pwdLastSet');
    attrArray[17] := PChar('lockoutTime');
    attrArray[18] := PChar('thumbnailPhoto');
    attrArray[19] := PChar('---');

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
        'cn',
        'givenName',
        'initials',
        'sn',
        'displayName',
        'userPrincipalName',
        'sAMAccountName',
        'userWorkstations',
        'description',
        'employeeID',
        'department',
        'title',
        'telephoneNumber',
        'physicalDeliveryOfficeName',
        'scriptPath',
        'userAccountControl',
        'pwdLastSet',
        'lockoutTime',
        'thumbnailPhoto']
      ) of
        0: Self.cn := attrEntries^.pADsValues.__MIDL____MIDL_itf_ads_0000_00000000.CaseIgnoreString;
        1: Self.givenName := attrEntries^.pADsValues.__MIDL____MIDL_itf_ads_0000_00000000.CaseIgnoreString;
        2: Self.initials := attrEntries^.pADsValues.__MIDL____MIDL_itf_ads_0000_00000000.CaseIgnoreString;
        3: Self.sn := attrEntries^.pADsValues.__MIDL____MIDL_itf_ads_0000_00000000.CaseIgnoreString;
        4: Self.displayName := attrEntries^.pADsValues.__MIDL____MIDL_itf_ads_0000_00000000.CaseIgnoreString;
        5: Self.userPrincipalName := attrEntries^.pADsValues.__MIDL____MIDL_itf_ads_0000_00000000.CaseIgnoreString;
        6: Self.sAMAccountName := attrEntries^.pADsValues.__MIDL____MIDL_itf_ads_0000_00000000.CaseIgnoreString;
        7: Self.userWorkstations := attrEntries^.pADsValues.__MIDL____MIDL_itf_ads_0000_00000000.CaseIgnoreString;
        8: Self.description := attrEntries^.pADsValues.__MIDL____MIDL_itf_ads_0000_00000000.CaseIgnoreString;
        9: Self.employeeID := attrEntries^.pADsValues.__MIDL____MIDL_itf_ads_0000_00000000.CaseIgnoreString;
        10: Self.department := attrEntries^.pADsValues.__MIDL____MIDL_itf_ads_0000_00000000.CaseIgnoreString;
        11: Self.title := attrEntries^.pADsValues.__MIDL____MIDL_itf_ads_0000_00000000.CaseIgnoreString;
        12: Self.telephoneNumber := attrEntries^.pADsValues.__MIDL____MIDL_itf_ads_0000_00000000.CaseIgnoreString;
        13: Self.physicalDeliveryOfficeName := attrEntries^.pADsValues.__MIDL____MIDL_itf_ads_0000_00000000.CaseIgnoreString;
        14: Self.scriptPath := attrEntries^.pADsValues.__MIDL____MIDL_itf_ads_0000_00000000.CaseIgnoreString;
        15: Self.userAccountControl := attrEntries^.pADsValues.__MIDL____MIDL_itf_ads_0000_00000000.Integer;

        16: begin
          Self.ChangePwdAtLogon := CompareDateTime(
            ADDateToDateTime(attrEntries^.pADsValues.__MIDL____MIDL_itf_ads_0000_00000000.LargeInteger),
            0
          ) = 0;
        end;

        17: begin
          Self.AccountIsLocked := CompareDateTime(
            ADDateToDateTime(attrEntries^.pADsValues.__MIDL____MIDL_itf_ads_0000_00000000.LargeInteger),
            0
          ) <> 0;
        end;

        18: begin
          SetLength(Self.thumbnailPhoto, attrEntries^.pADsValues.__MIDL____MIDL_itf_ads_0000_00000000.OctetString.dwLength);
          for j := 0 to Length(Self.thumbnailPhoto) - 1 do
          begin
            Self.thumbnailPhoto[j] := attrEntries^.pADsValues.__MIDL____MIDL_itf_ads_0000_00000000.OctetString.lpValue^;
            Inc(attrEntries^.pADsValues.__MIDL____MIDL_itf_ads_0000_00000000.OctetString.lpValue)
          end;
        end;
      end;

      Inc(i);
      Inc(attrEntries);
    end;
    Dec(attrEntries, i);
    FreeADsMem(attrEntries);
    SetLength(attrArray, 0);
  finally
    CoUninitialize;
  end;
end;

procedure TUserEditHelper.SetGroupListDS(ARootDSE: IADS; AMemberDN: string;
  AList: TADGroupList);
var
  v: OleVariant;
  hostName: string;
  dn: string;
  g: PADGroup;
  IDir: IDirectoryObject;
  hr: HRESULT;
  modArray: array of ADS_ATTR_INFO;
  i: Integer;
  valLength: Integer;
  valMember: array of ADSVALUE;
  valPrimaryGroupID: array of ADSVALUE;
  modCount: LongWord;
begin
  if AList = nil
    then Exit;

  CoInitialize(nil);

  { Перемещаем группу по умолчанию вверх списка, чтобы обработать  }
  { в первую очередь. Это важно, т.к. чтобы назначить пользователю }
  { группу по умолчанию, он должен быть включен в эту группу. Так  }
  { же нельзя исключить пользователя из группы, если для него эта  }
  { группа назначена группой по умолчанию.                         }
  if AList.PrimaryGroupIndex > 0
    then AList.Move(AList.PrimaryGroupIndex, 0);

  try
    v := ARootDSE.Get('dnsHostName');
    hostName := VariantToStringWithDefault(v, '');
    VariantClear(v);

    for g in AList do
    begin
      { Если выполняется условие g^.Selected = g^.IsMember, то это значит: }
      { 1. Группу нужно добавить, но она и так уже используется            }
      { 2. Группу нужно удалить, но она и так не используется              }
      { Естественно, в этом случае операций по добавлению/удалению групп   }
      { производить не нужно. Работаетм с g^.Selected <> g^.IsMember...    }
      if g^.Selected <> g^.IsMember then
      begin
        IDir := nil;

        dn := ReplaceStr(g^.distinguishedName, '/', '\/');

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
          SetLength(modArray, 1);

          SetLength(valMember, 1);
          valMember[0].dwType := ADSTYPE_CASE_IGNORE_STRING;
          valMember[0].__MIDL____MIDL_itf_ads_0000_00000000.CaseIgnoreString := PChar(AMemberDN);

          with modArray[0] do
          begin
            pszAttrName := 'member';

            if g^.Selected and not g^.IsMember
              then dwControlCode := ADS_ATTR_APPEND
              else dwControlCode := ADS_ATTR_DELETE;

            dwADsType     := valMember[0].dwType;
            pADsValues    := @valMember[0];
            dwNumValues   := Length(valMember);
          end;

          hr := IDir.SetObjectAttributes(
            @modArray[0],
            Length(modArray),
            modCount
          );

          if not Succeeded(hr)
            then raise Exception.Create(ADSIErrorToString);
        end else raise Exception.Create(ADSIErrorToString);
      end;

      { Если группа помечена как группа по умолчанию, то делаем ее группой }
      { по умолчанию для указанной учетной записи пользователя             }
      if g^.IsPrimary then
      begin
        IDir := nil;

        dn := ReplaceStr(AMemberDN, '/', '\/');

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
          SetLength(modArray, 1);

          SetLength(valPrimaryGroupID, 1);
          valPrimaryGroupID[0].dwType := ADSTYPE_INTEGER;
          valPrimaryGroupID[0].__MIDL____MIDL_itf_ads_0000_00000000.Integer := g^.primaryGroupToken;

          GenerateDSMod(
            PChar('primaryGroupID'),
            @valPrimaryGroupID[0],
            Length(valPrimaryGroupID),
            @modArray[0]
          );

          hr := IDir.SetObjectAttributes(
            @modArray[0],
            Length(modArray),
            modCount
          );

          if not Succeeded(hr)
            then raise Exception.Create(ADSIErrorToString);
        end else raise Exception.Create(ADSIErrorToString);
      end;
    end;
  finally
    CoUninitialize;
  end;
end;

procedure TUserEditHelper.SetGroupList(ARootDSE: IADS; AMemberDN: string;
  AList: TADGroupList);
var
  v: OleVariant;
  hostName: string;
  g: PADGroup;
  dn: string;
  hr: HRESULT;
  IGroup: IADsGroup;
  IUser: IADsUser;
begin
  if AList = nil
    then Exit;

  CoInitialize(nil);

  { Перемещаем группу по умолчанию вверх списка, чтобы обработать  }
  { в первую очередь. Это важно, т.к. чтобы назначить пользователю }
  { группу по умолчанию, он должен быть включен в эту группу. Так  }
  { же нельзя исключить пользователя из группы, если для него эта  }
  { группа назначена группой по умолчанию.                         }
  if AList.PrimaryGroupIndex > 0
    then AList.Move(AList.PrimaryGroupIndex, 0);

  try
    v := ARootDSE.Get('dnsHostName');
    hostName := VariantToStringWithDefault(v, '');
    VariantClear(v);

    for g in AList do
    begin
      { Если выполняется условие g^.Selected = g^.IsMember, то это значит: }
      { 1. Группу нужно добавить, но она и так уже используется            }
      { 2. Группу нужно удалить, но она и так не используется              }
      { Естественно, в этом случае операций по добавлению/удалению групп   }
      { производить не нужно. Работаетм с g^.Selected <> g^.IsMember...    }
      if g^.Selected <> g^.IsMember then
      begin
        IGroup := nil;
        dn := ReplaceStr(g^.distinguishedName, '/', '\/');

        hr := ADsOpenObject(
          PChar(Format('LDAP://%s/%s', [hostName, dn])),
          nil,
          nil,
          ADS_SECURE_AUTHENTICATION or ADS_SERVER_BIND,
          IID_IADsGroup,
          @IGroup
        );

        if Succeeded(hr) then
        begin
          dn := ReplaceStr(AMemberDN, '/', '\/');
          if g^.Selected and not g^.IsMember
            then IGroup.Add(Format('LDAP://%s/%s', [hostName, dn]))
            else IGroup.Remove(Format('LDAP://%s/%s', [hostName, dn]));
        end else raise Exception.Create(ADSIErrorToString);
      end;

      { Если группа помечена как группа по умолчанию, то делаем ее группой }
      { по умолчанию для указанной учетной записи пользователя             }
      if g^.IsPrimary then
      begin
        IUser := nil;
        dn := ReplaceStr(AMemberDN, '/', '\/');

        hr := ADsOpenObject(
          PChar(Format('LDAP://%s/%s', [hostName, dn])),
          nil,
          nil,
          ADS_SECURE_AUTHENTICATION or ADS_SERVER_BIND,
          IID_IADsUser,
          @IUser
        );

        if Succeeded(hr) then
        begin
          IUser.Put('primaryGroupID', g^.primaryGroupToken);
          IUser.SetInfo;
        end else raise Exception.Create(ADSIErrorToString);
      end;
    end;
  finally
    CoUninitialize;
  end;
end;

procedure TUserEditHelper.SetEventList(ARootDSE: IADS; ADN, AAttribute: string;
  AList: TADEventList);
var
  v: OleVariant;
  hostName: string;
  dn: string;
  hr: HRESULT;
  IUser: IADsUser;
  eData: TXMLByteArray;
begin
  IUser := nil;

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
      IID_IADsUser,
      @IUser
    );

    if Succeeded(hr) then
    begin
      Self.EventListToByteArray(Alist, eData);

      if Length(eData) > 0
        then IUser.Put(AAttribute, eData)
        else IUser.PutEx(ADS_PROPERTY_CLEAR, AAttribute, Null);

      IUser.SetInfo;
    end else raise Exception.Create(ADSIErrorToString);
  except

  end;

  CoUninitialize;
end;

procedure TUserEditHelper.SetEventList(ALDAP: PLDAP; ADN, AAttribute: string;
  AList: TADEventList);
var
  ldapBase: AnsiString;
  modArray: array of PLDAPMod;
  eData: TXMLByteArray;

  binEvents: AnsiString;
  bvEvents: berval;
  valEvents: array of PLDAPBerVal;

  returnCode: ULONG;
  i: Integer;
begin
  ldapBase := ADN;

  SetLength(modArray, 1);

  { events }
  Self.EventListToByteArray(Alist, eData);

  SetLength(modArray, Length(modArray) + 1);
  i := High(modArray) - 1;

  SetLength(valEvents, 2);
  binEvents := eData.AsBinAnsiString;
  with bvEvents do
  begin
    bv_len := Length(eData);
    bv_val := PAnsiChar(binEvents);
  end;
  valEvents[0] := @bvEvents;

  if Length(eData) > 0
    then GenerateLDAPBerMod(PAnsiChar(AnsiString(AAttribute)), @valEvents[0], modArray[i])
    else GenerateLDAPStrMod(PAnsiChar(AnsiString(AAttribute)), nil, modArray[i]);

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
  except

  end;

  for i := Low(modArray) to High(modArray) do
    if Assigned(modArray[i])
      then Dispose(modArray[i]);
end;

procedure TUserEditHelper.SetEventList(APath, AObjectSID: string;
  AList: TADEventList);
var
  xmlFileName: TFileName;
  xmlBin: TXMLByteArray;
  xmlStream: TStringStream;
  xmlDoc: IXMLDOMDocument;
begin
  if (not DirectoryExists(APath)) or (AObjectSID.IsEmpty)
    then Exit;

  xmlFileName := Format(
    '%s%s.xml',
    [System.SysUtils.IncludeTrailingPathDelimiter(APath), AObjectSID]
  );

  if AList.Count = 0 then
  begin
    {
       Для чего в имени файла '\\?\UNC\' и '\\?\':
       https://msdn.microsoft.com/en-us/library/windows/desktop/aa363915(v=vs.85).aspx
       https://msdn.microsoft.com/en-us/library/windows/desktop/aa365247(v=vs.85).aspx
    }
    if TRegEx.IsMatch(xmlFileName, '^\\\\.*')
      then xmlFileName := TRegEx.Replace(xmlFileName, '^\\\\', '\\\\?\\UNC\\') else
    if TRegEx.IsMatch(xmlFileName, '^[A-Za-z]:\\.*')
      then xmlFileName := '\\?\' + xmlFileName;

    DeleteFileW(PChar(xmlFileName));
  end else
  begin
    Self.EventListToByteArray(AList, xmlBin);
    xmlDoc := CoDOMDocument60.Create;
    xmlStream := TStringStream.Create;
    try
      xmlStream.WriteData(xmlBin, Length(xmlBin));
      xmlStream.Seek(0, soFromBeginning);
      XMLDoc.async := False;
      xmlDoc.load(TStreamAdapter.Create(xmlStream) as IStream);
      if xmlDoc.parseError.errorCode = 0
        then xmlDoc.save(xmlFileName);
    except

    end;
    xmlDoc := nil;
    xmlStream.Free;
  end;
end;

procedure TUserEditHelper.SetEventList(AHandle: THandle; APath, AObjectSID: string;
  AList: TADEventList);
var
  xmlFileName: TFileName;
  xmlBin: TXMLByteArray;
  xmlStream: TStringStream;
begin
  if (not DirectoryExists(APath)) or (AObjectSID.IsEmpty)
    then Exit;

  xmlFileName := Format(
    '%s%s.xml',
    [System.SysUtils.IncludeTrailingPathDelimiter(APath), AObjectSID]
  );

  if AList.Count = 0 then
  begin
    {
       Для чего в имени файла '\\?\UNC\' и '\\?\':
       https://msdn.microsoft.com/en-us/library/windows/desktop/aa363915(v=vs.85).aspx
       https://msdn.microsoft.com/en-us/library/windows/desktop/aa365247(v=vs.85).aspx
    }
    if TRegEx.IsMatch(xmlFileName, '^\\\\.*')
      then xmlFileName := TRegEx.Replace(xmlFileName, '^\\\\', '\\\\?\\UNC\\') else
    if TRegEx.IsMatch(xmlFileName, '^[A-Za-z]:\\.*')
      then xmlFileName := '\\?\' + xmlFileName;

    DeleteControlEventsList(
      AHandle,
      PChar(xmlFileName),
      IsCreateFileElevationRequired(APath)
    );
  end else
  begin
    Self.EventListToByteArray(AList, xmlBin);
    xmlStream := TStringStream.Create;
    try
      xmlStream.WriteData(xmlBin, Length(xmlBin));
      xmlStream.Seek(0, soFromBeginning);
      SaveControlEventsList(
        AHandle,
        PChar(xmlFileName),
        TStreamAdapter.Create(xmlStream) as IStream,
        IsCreateFileElevationRequired(APath)
      );
    except

    end;
    xmlStream.Free;
  end;

end;

procedure TUserEditHelper.SetEventListDS(ARootDSE: IADS; ADN, AAttribute: string;
  AList: TADEventList);
var
  eData: TXMLByteArray;
  v: OleVariant;
  hostName: string;
  dn: string;
  IDir: IDirectoryObject;
  hr: HRESULT;
  modArray: array of ADS_ATTR_INFO;
  i: Integer;
  valLength: Integer;
  valEvents: array of ADSVALUE;
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
      Self.EventListToByteArray(Alist, eData);

      SetLength(modArray, Length(modArray) + 1);
      i := High(modArray);

      SetLength(valEvents, 1);
      valEvents[0].dwType := ADSTYPE_OCTET_STRING;
      with valEvents[0].__MIDL____MIDL_itf_ads_0000_00000000.OctetString do
      begin
        dwLength := Length(eData);
        lpValue := @eData[0];
      end;

      if Length(eData) = 0
        then valLength := 0
        else valLength := Length(valEvents);

      GenerateDSMod(
        PChar(AAttribute),
        @valEvents[0],
        valLength,
        @modArray[i]
      );

      hr := IDir.SetObjectAttributes(
        @modArray[0],
        Length(modArray),
        modCount
      );

      if not Succeeded(hr)
        then raise Exception.Create(ADSIErrorToString);
    end else raise Exception.Create(ADSIErrorToString);
  except

  end;

  CoUninitialize;
end;

procedure TUserEditHelper.SetGroupList(ALDAP: PLDAP; AMemberDN: string;
  AList: TADGroupList);
var
  ldapBase: AnsiString;
  g: PADGroup;
  modArray: array of PLDAPMod;
  valMember: array of PAnsiChar;
  returnCode: ULONG;
  i: Integer;
begin
  if AList = nil
    then Exit;

  { Перемещаем группу по умолчанию вверх списка, чтобы обработать  }
  { в первую очередь. Это важно, т.к. чтобы назначить пользователю }
  { группу по умолчанию, он должен быть включен в эту группу. Так  }
  { же нельзя исключить пользователя из группы, если для него эта  }
  { группа назначена группой по умолчанию.                         }
  if AList.PrimaryGroupIndex > 0
    then AList.Move(AList.PrimaryGroupIndex, 0);

  for g in AList do
  begin
    { Если выполняется условие g^.Selected = g^.IsMember, то это значит: }
    { 1. Группу нужно добавить, но она и так уже используется            }
    { 2. Группу нужно удалить, но она и так не используется              }
    { Естественно, в этом случае операций по добавлению/удалению групп   }
    { производить не нужно. Работаетм с g^.Selected <> g^.IsMember...    }
    if g^.Selected <> g^.IsMember then
    try
      ldapBase := AnsiString(g^.distinguishedName);

      SetLength(modArray, 2);
      SetLength(valMember, 2);
      valMember[0] := PAnsiChar(AnsiString(AMemberDN));

      New(modArray[0]);
      with modArray[0]^ do
      begin
        mod_type := 'member';

        if g^.Selected and not g^.IsMember
          then mod_op := LDAP_MOD_ADD
          else mod_op := LDAP_MOD_DELETE;

        modv_strvals := @valMember[0];
      end;

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

      SetLength(modArray, 0);
    end;

    { Если группа помечена как группа по умолчанию, то делаем ее группой }
    { по умолчанию для указанной учетной записи пользователя             }
    if g^.IsPrimary then
    try
      ldapBase := AnsiString(AMemberDN);

      SetLength(modArray, 2);
      SetLength(valMember, 2);
      valMember[0] := PAnsiChar(AnsiString(IntToStr(g^.primaryGroupToken)));

      GenerateLDAPStrMod(
        PAnsiChar('primaryGroupID'),
        @valMember[0],
        modArray[0]
      );

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

      SetLength(modArray, 0);
    end;
  end;
end;

procedure TUserEditHelper.SetInfo(ALDAP: PLDAP; ADN: string);
var
  ldapBase: AnsiString;
  modArray: array of PLDAPMod;
  valUserAccountControl: array of PAnsiChar;
  valUserPrincipalName: array of PAnsiChar;
  valSAMAccountName: array of PAnsiChar;
  valGivenName: array of PAnsiChar;
  valInitials: array of PAnsiChar;
  valSn: array of PAnsiChar;
  valDisplayName: array of PAnsiChar;
  valDescription: array of PAnsiChar;
  valEmployeeID: array of PAnsiChar;
  valDepartment: array of PAnsiChar;
  valTitle: array of PAnsiChar;
  valTelephoneNumber: array of PAnsiChar;
  valPhysicalDeliveryOfficeName: array of PAnsiChar;
  valUserWorkstations: array of PAnsiChar;
  valScriptPath: array of PAnsiChar;

  binThumbnailPhoto: AnsiString;
  bvThumbnailPhoto: berval;
  valThumbnailPhoto: array of PLDAPBerVal;

  binPwdLastSet: AnsiString;
  bvPwdLastSet: berval;
  valPwdLastSet: array of PLDAPBerVal;

  binLockoutTime: AnsiString;
  bvLockoutTime: berval;
  valLockoutTime: array of PLDAPBerVal;

  returnCode: ULONG;
  i: Integer;
begin
  ldapBase := ADN;

  SetLength(modArray, 1);

  { userAccountControl }
  if Self.userAccountControl <> 0 then
  begin
    SetLength(modArray, Length(modArray) + 1);
    i := High(modArray) - 1;

    SetLength(valUserAccountControl, 2);
    valUserAccountControl[0] := PAnsiChar(AnsiString(IntToStr(Self.userAccountControl)));

    GenerateLDAPStrMod(PAnsiChar('userAccountControl'), @valUserAccountControl[0], modArray[i]);
  end;

  { userPrincipalName }
  if Self.userPrincipalName <> '' then
  begin
    SetLength(modArray, Length(modArray) + 1);
    i := High(modArray) - 1;

    SetLength(valUserPrincipalName, 2);
    valUserPrincipalName[0] := PAnsiChar(AnsiString(Self.userPrincipalName));

    GenerateLDAPStrMod(PAnsiChar('userPrincipalName'), @valUserPrincipalName[0], modArray[i]);
  end;

  { sAMAccountName }
  if Self.sAMAccountName <> '' then
  begin
    SetLength(modArray, Length(modArray) + 1);
    i := High(modArray) - 1;

    SetLength(valSAMAccountName, 2);
    valSAMAccountName[0] := PAnsiChar(AnsiString(Self.sAMAccountName));

    GenerateLDAPStrMod(PAnsiChar('sAMAccountName'), @valSAMAccountName[0], modArray[i]);
  end;

  { givenName }
  SetLength(modArray, Length(modArray) + 1);
  i := High(modArray) - 1;

  SetLength(valGivenName, 2);
  valGivenName[0] := PAnsiChar(AnsiString(Self.givenName));

  if Self.givenName <> ''
    then GenerateLDAPStrMod(PAnsiChar('givenName'), @valGivenName[0], modArray[i])
    else GenerateLDAPStrMod(PAnsiChar('givenName'), nil, modArray[i]);

  { initials }
  SetLength(modArray, Length(modArray) + 1);
  i := High(modArray) - 1;

  SetLength(valInitials, 2);
  valInitials[0] := PAnsiChar(AnsiString(Self.initials));

  if Self.initials <> ''
    then GenerateLDAPStrMod(PAnsiChar('initials'), @valInitials[0], modArray[i])
    else GenerateLDAPStrMod(PAnsiChar('initials'), nil, modArray[i]);

  { sn }
  SetLength(modArray, Length(modArray) + 1);
  i := High(modArray) - 1;

  SetLength(valSn, 2);
  valSn[0] := PAnsiChar(AnsiString(Self.sn));

  if Self.sn <> ''
    then GenerateLDAPStrMod(PAnsiChar('sn'), @valSn[0], modArray[i])
    else GenerateLDAPStrMod(PAnsiChar('sn'), nil, modArray[i]);

  { displayName }
  SetLength(modArray, Length(modArray) + 1);
  i := High(modArray) - 1;

  SetLength(valDisplayName, 2);
  valDisplayName[0] := PAnsiChar(AnsiString(Self.displayName));

  if Self.displayName <> ''
    then GenerateLDAPStrMod(PAnsiChar('displayName'), @valDisplayName[0], modArray[i])
    else GenerateLDAPStrMod(PAnsiChar('displayName'), nil, modArray[i]);

  { description }
  SetLength(modArray, Length(modArray) + 1);
  i := High(modArray) - 1;

  SetLength(valDescription, 2);
  valDescription[0] := PAnsiChar(AnsiString(Self.description));

  if Self.description <> ''
    then GenerateLDAPStrMod(PAnsiChar('description'), @valDescription[0], modArray[i])
    else GenerateLDAPStrMod(PAnsiChar('description'), nil, modArray[i]);

  { employeeID }
  SetLength(modArray, Length(modArray) + 1);
  i := High(modArray) - 1;

  SetLength(valEmployeeID, 2);
  valEmployeeID[0] := PAnsiChar(AnsiString(Self.employeeID));

  if Self.employeeID <> ''
    then GenerateLDAPStrMod(PAnsiChar('employeeID'), @valEmployeeID[0], modArray[i])
    else GenerateLDAPStrMod(PAnsiChar('employeeID'), nil, modArray[i]);

  { department }
  SetLength(modArray, Length(modArray) + 1);
  i := High(modArray) - 1;

  SetLength(valDepartment, 2);
  valDepartment[0] := PAnsiChar(AnsiString(Self.department));

  if Self.department <> ''
    then GenerateLDAPStrMod(PAnsiChar('department'), @valDepartment[0], modArray[i])
    else GenerateLDAPStrMod(PAnsiChar('department'), nil, modArray[i]);

  { title }
  SetLength(modArray, Length(modArray) + 1);
  i := High(modArray) - 1;

  SetLength(valTitle, 2);
  valTitle[0] := PAnsiChar(AnsiString(Self.title));

  if Self.title <> ''
    then GenerateLDAPStrMod(PAnsiChar('title'), @valTitle[0], modArray[i])
    else GenerateLDAPStrMod(PAnsiChar('title'), nil, modArray[i]);

  { telephoneNumber }
  SetLength(modArray, Length(modArray) + 1);
  i := High(modArray) - 1;

  SetLength(valTelephoneNumber, 2);
  valTelephoneNumber[0] := PAnsiChar(AnsiString(Self.telephoneNumber));

  if Self.telephoneNumber <> ''
    then GenerateLDAPStrMod(PAnsiChar('telephoneNumber'), @valTelephoneNumber[0], modArray[i])
    else GenerateLDAPStrMod(PAnsiChar('telephoneNumber'), nil, modArray[i]);

  { physicalDeliveryOfficeName }
  SetLength(modArray, Length(modArray) + 1);
  i := High(modArray) - 1;

  SetLength(valPhysicalDeliveryOfficeName, 2);
  valPhysicalDeliveryOfficeName[0] := PAnsiChar(AnsiString(Self.physicalDeliveryOfficeName));

  if Self.physicalDeliveryOfficeName <> ''
    then GenerateLDAPStrMod(PAnsiChar('physicalDeliveryOfficeName'), @valPhysicalDeliveryOfficeName[0], modArray[i])
    else GenerateLDAPStrMod(PAnsiChar('physicalDeliveryOfficeName'), nil, modArray[i]);

  { userWorkstations }
  SetLength(modArray, Length(modArray) + 1);
  i := High(modArray) - 1;

  SetLength(valUserWorkstations, 2);
  valUserWorkstations[0] := PAnsiChar(AnsiString(Self.userWorkstations));

  if Self.userWorkstations <> ''
    then GenerateLDAPStrMod(PAnsiChar('userWorkstations'), @valUserWorkstations[0], modArray[i])
    else GenerateLDAPStrMod(PAnsiChar('userWorkstations'), nil, modArray[i]);

  { pwdLastSet }
  SetLength(modArray, Length(modArray) + 1);
  i := High(modArray) - 1;

  SetLength(valPwdLastSet, 2);

  if Self.ChangePwdAtLogon
    then binPwdLastSet := '0'
    else binPwdLastSet := '-1';

  with bvPwdLastSet do
  begin
    bv_len := Length(binPwdLastSet);
    bv_val := PAnsiChar(binPwdLastSet);
  end;
  valPwdLastSet[0] := @bvPwdLastSet;

  GenerateLDAPBerMod(PAnsiChar('pwdLastSet'), @valPwdLastSet[0], modArray[i]);

  { lockoutTime }
  if Self.AccountIsLocked then
  begin
    SetLength(modArray, Length(modArray) + 1);
    i := High(modArray) - 1;

    SetLength(valLockoutTime, 2);

    binLockoutTime := '0';

    with bvLockoutTime do
    begin
      bv_len := Length(binLockoutTime);
      bv_val := PAnsiChar(binLockoutTime);
    end;
    valLockoutTime[0] := @bvLockoutTime;

    GenerateLDAPBerMod(PAnsiChar('lockoutTime'), @valLockoutTime[0], modArray[i]);
  end;

  { scriptPath }
  SetLength(modArray, Length(modArray) + 1);
  i := High(modArray) - 1;

  SetLength(valScriptPath, 2);
  valScriptPath[0] := PAnsiChar(AnsiString(Self.scriptPath));

  if Self.scriptPath <> ''
    then GenerateLDAPStrMod(PAnsiChar('scriptPath'), @valScriptPath[0], modArray[i])
    else GenerateLDAPStrMod(PAnsiChar('scriptPath'), nil, modArray[i]);

  { thumbnailPhoto }
  SetLength(modArray, Length(modArray) + 1);
  i := High(modArray) - 1;

  SetLength(valThumbnailPhoto, 2);
  binThumbnailPhoto := Self.thumbnailPhoto.AsBinAnsiString;
  with bvThumbnailPhoto do
  begin
    bv_len := Length(Self.thumbnailPhoto);
    bv_val := PAnsiChar(binThumbnailPhoto);
  end;
  valThumbnailPhoto[0] := @bvThumbnailPhoto;

  if Length(Self.thumbnailPhoto) > 0
    then GenerateLDAPBerMod(PAnsiChar('thumbnailPhoto'), @valThumbnailPhoto[0], modArray[i])
    else GenerateLDAPStrMod(PAnsiChar('thumbnailPhoto'), nil, modArray[i]);

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

procedure TUserEditHelper.SetInfoDS(ARootDSE: IADS; ADN: string);
var
  v: OleVariant;
  hostName: string;
  dn: string;
  IDir: IDirectoryObject;
  hr: HRESULT;
  modArray: array of ADS_ATTR_INFO;
  i: Integer;
  valLength: Integer;
  valUserAccountControl: array of ADSVALUE;
  valUserPrincipalName: array of ADSVALUE;
  valSAMAccountName: array of ADSVALUE;
  valGivenName: array of ADSVALUE;
  valInitials: array of ADSVALUE;
  valSn: array of ADSVALUE;
  valDisplayName: array of ADSVALUE;
  valDescription: array of ADSVALUE;
  valEmployeeID: array of ADSVALUE;
  valDepartment: array of ADSVALUE;
  valTitle: array of ADSVALUE;
  valTelephoneNumber: array of ADSVALUE;
  valPhysicalDeliveryOfficeName: array of ADSVALUE;
  valUserWorkstations: array of ADSVALUE;
  valScriptPath: array of ADSVALUE;
  valPwdLastSet: array of ADSVALUE;
  valLockoutTime: array of ADSVALUE;
  valThumbnailPhoto: array of ADSVALUE;
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
      { userAccountControl }
      if Self.userAccountControl <> 0 then
      begin
        SetLength(modArray, Length(modArray) + 1);
        i := High(modArray);

        SetLength(valUserAccountControl, 1);
        valUserAccountControl[0].dwType := ADSTYPE_INTEGER;
        valUserAccountControl[0].__MIDL____MIDL_itf_ads_0000_00000000.Integer := Self.userAccountControl;

        GenerateDSMod(
          PChar('userAccountControl'),
          @valUserAccountControl[0],
          Length(valUserAccountControl),
          @modArray[i]
        );
      end;

      { userPrincipalName }
      if not Self.userPrincipalName.IsEmpty then
      begin
        SetLength(modArray, Length(modArray) + 1);
        i := High(modArray);

        SetLength(valUserPrincipalName, 1);
        valUserPrincipalName[0].dwType := ADSTYPE_CASE_IGNORE_STRING;
        valUserPrincipalName[0].__MIDL____MIDL_itf_ads_0000_00000000.CaseIgnoreString := PChar(Self.userPrincipalName);

        GenerateDSMod(
          PChar('userPrincipalName'),
          @valUserPrincipalName[0],
          Length(valUserPrincipalName),
          @modArray[i]
        );
      end;

      { sAMAccountName }
      if not Self.sAMAccountName.IsEmpty then
      begin
        SetLength(modArray, Length(modArray) + 1);
        i := High(modArray);

        SetLength(valSAMAccountName, 1);
        valSAMAccountName[0].dwType := ADSTYPE_CASE_IGNORE_STRING;
        valSAMAccountName[0].__MIDL____MIDL_itf_ads_0000_00000000.CaseIgnoreString := PChar(Self.sAMAccountName);

        GenerateDSMod(
          PChar('sAMAccountName'),
          @valSAMAccountName[0],
          Length(valSAMAccountName),
          @modArray[i]
        );
      end;

      { givenName }
      SetLength(modArray, Length(modArray) + 1);
      i := High(modArray);

      SetLength(valGivenName, 1);
      valGivenName[0].dwType := ADSTYPE_CASE_IGNORE_STRING;
      valGivenName[0].__MIDL____MIDL_itf_ads_0000_00000000.CaseIgnoreString := PChar(Self.givenName);

      if Self.givenName.IsEmpty
        then valLength := 0
        else valLength := Length(valGivenName);

      GenerateDSMod(
        PChar('givenName'),
        @valGivenName[0],
        valLength,
        @modArray[i]
      );

      { initials }
      SetLength(modArray, Length(modArray) + 1);
      i := High(modArray);

      SetLength(valInitials, 1);
      valInitials[0].dwType := ADSTYPE_CASE_IGNORE_STRING;
      valInitials[0].__MIDL____MIDL_itf_ads_0000_00000000.CaseIgnoreString := PChar(Self.initials);

      if Self.initials.IsEmpty
        then valLength := 0
        else valLength := Length(valInitials);

      GenerateDSMod(
        PChar('initials'),
        @valInitials[0],
        valLength,
        @modArray[i]
      );

      { sn }
      SetLength(modArray, Length(modArray) + 1);
      i := High(modArray);

      SetLength(valSn, 1);
      valSn[0].dwType := ADSTYPE_CASE_IGNORE_STRING;
      valSn[0].__MIDL____MIDL_itf_ads_0000_00000000.CaseIgnoreString := PChar(Self.sn);

      if Self.sn.IsEmpty
        then valLength := 0
        else valLength := Length(valSn);

      GenerateDSMod(
        PChar('sn'),
        @valSn[0],
        valLength,
        @modArray[i]
      );

      { displayName }
      SetLength(modArray, Length(modArray) + 1);
      i := High(modArray);

      SetLength(valDisplayName, 1);
      valDisplayName[0].dwType := ADSTYPE_CASE_IGNORE_STRING;
      valDisplayName[0].__MIDL____MIDL_itf_ads_0000_00000000.CaseIgnoreString := PChar(Self.displayName);

      if Self.displayName.IsEmpty
        then valLength := 0
        else valLength := Length(valDisplayName);

      GenerateDSMod(
        PChar('displayName'),
        @valDisplayName[0],
        valLength,
        @modArray[i]
      );

      { description }
      SetLength(modArray, Length(modArray) + 1);
      i := High(modArray);

      SetLength(valDescription, 1);
      valDescription[0].dwType := ADSTYPE_CASE_IGNORE_STRING;
      valDescription[0].__MIDL____MIDL_itf_ads_0000_00000000.CaseIgnoreString := PChar(Self.description);

      if Self.description.IsEmpty
        then valLength := 0
        else valLength := Length(valDescription);

      GenerateDSMod(
        PChar('description'),
        @valDescription[0],
        valLength,
        @modArray[i]
      );

      { employeeID }
      SetLength(modArray, Length(modArray) + 1);
      i := High(modArray);

      SetLength(valEmployeeID, 1);
      valEmployeeID[0].dwType := ADSTYPE_CASE_IGNORE_STRING;
      valEmployeeID[0].__MIDL____MIDL_itf_ads_0000_00000000.CaseIgnoreString := PChar(Self.employeeID);

      if Self.employeeID.IsEmpty
        then valLength := 0
        else valLength := Length(valEmployeeID);

      GenerateDSMod(
        PChar('employeeID'),
        @valEmployeeID[0],
        valLength,
        @modArray[i]
      );

      { department }
      SetLength(modArray, Length(modArray) + 1);
      i := High(modArray);

      SetLength(valDepartment, 1);
      valDepartment[0].dwType := ADSTYPE_CASE_IGNORE_STRING;
      valDepartment[0].__MIDL____MIDL_itf_ads_0000_00000000.CaseIgnoreString := PChar(Self.department);

      if Self.department.IsEmpty
        then valLength := 0
        else valLength := Length(valDepartment);

      GenerateDSMod(
        PChar('department'),
        @valDepartment[0],
        valLength,
        @modArray[i]
      );

      { title }
      SetLength(modArray, Length(modArray) + 1);
      i := High(modArray);

      SetLength(valTitle, 1);
      valTitle[0].dwType := ADSTYPE_CASE_IGNORE_STRING;
      valTitle[0].__MIDL____MIDL_itf_ads_0000_00000000.CaseIgnoreString := PChar(Self.title);

      if Self.title.IsEmpty
        then valLength := 0
        else valLength := Length(valTitle);

      GenerateDSMod(
        PChar('title'),
        @valTitle[0],
        valLength,
        @modArray[i]
      );

      { telephoneNumber }
      SetLength(modArray, Length(modArray) + 1);
      i := High(modArray);

      SetLength(valTelephoneNumber, 1);
      valTelephoneNumber[0].dwType := ADSTYPE_CASE_IGNORE_STRING;
      valTelephoneNumber[0].__MIDL____MIDL_itf_ads_0000_00000000.CaseIgnoreString := PChar(Self.telephoneNumber);

      if Self.telephoneNumber.IsEmpty
        then valLength := 0
        else valLength := Length(valTelephoneNumber);

      GenerateDSMod(
        PChar('telephoneNumber'),
        @valTelephoneNumber[0],
        valLength,
        @modArray[i]
      );

      { physicalDeliveryOfficeName }
      SetLength(modArray, Length(modArray) + 1);
      i := High(modArray);

      SetLength(valPhysicalDeliveryOfficeName, 1);
      valPhysicalDeliveryOfficeName[0].dwType := ADSTYPE_CASE_IGNORE_STRING;
      valPhysicalDeliveryOfficeName[0].__MIDL____MIDL_itf_ads_0000_00000000.CaseIgnoreString := PChar(Self.physicalDeliveryOfficeName);

      if Self.physicalDeliveryOfficeName.IsEmpty
        then valLength := 0
        else valLength := Length(valPhysicalDeliveryOfficeName);

      GenerateDSMod(
        PChar('physicalDeliveryOfficeName'),
        @valPhysicalDeliveryOfficeName[0],
        valLength,
        @modArray[i]
      );

      { userWorkstations }
      SetLength(modArray, Length(modArray) + 1);
      i := High(modArray);

      SetLength(valUserWorkstations, 1);
      valUserWorkstations[0].dwType := ADSTYPE_CASE_IGNORE_STRING;
      valUserWorkstations[0].__MIDL____MIDL_itf_ads_0000_00000000.CaseIgnoreString := PChar(Self.userWorkstations);

      if Self.userWorkstations.IsEmpty
        then valLength := 0
        else valLength := Length(valUserWorkstations);

      GenerateDSMod(
        PChar('userWorkstations'),
        @valUserWorkstations[0],
        valLength,
        @modArray[i]
      );

      { pwdLastSet }
      SetLength(modArray, Length(modArray) + 1);
      i := High(modArray);

      SetLength(valPwdLastSet, 1);
      valPwdLastSet[0].dwType := ADSTYPE_LARGE_INTEGER;

      if Self.ChangePwdAtLogon
        then valPwdLastSet[0].__MIDL____MIDL_itf_ads_0000_00000000.LargeInteger.QuadPart := 0
        else valPwdLastSet[0].__MIDL____MIDL_itf_ads_0000_00000000.LargeInteger.QuadPart := -1;

      GenerateDSMod(
        PChar('pwdLastSet'),
        @valPwdLastSet[0],
        1,
        @modArray[i]
      );

      { lockoutTime }
      if Self.AccountIsLocked then
      begin
        SetLength(modArray, Length(modArray) + 1);
        i := High(modArray);

        SetLength(valLockoutTime, 1);
        valLockoutTime[0].dwType := ADSTYPE_LARGE_INTEGER;

        valLockoutTime[0].__MIDL____MIDL_itf_ads_0000_00000000.LargeInteger.QuadPart := 0;

        GenerateDSMod(
          PChar('lockoutTime'),
          @valLockoutTime[0],
          1,
          @modArray[i]
        );
      end;

      { scriptPath }
      SetLength(modArray, Length(modArray) + 1);
      i := High(modArray);

      SetLength(valScriptPath, 1);
      valScriptPath[0].dwType := ADSTYPE_CASE_IGNORE_STRING;
      valScriptPath[0].__MIDL____MIDL_itf_ads_0000_00000000.CaseIgnoreString := PChar(Self.scriptPath);

      if Self.scriptPath.IsEmpty
        then valLength := 0
        else valLength := Length(valScriptPath);

      GenerateDSMod(
        PChar('scriptPath'),
        @valScriptPath[0],
        valLength,
        @modArray[i]
      );

      { thumbnailPhoto }
      SetLength(modArray, Length(modArray) + 1);
      i := High(modArray);

      SetLength(valThumbnailPhoto, 1);
      valThumbnailPhoto[0].dwType := ADSTYPE_OCTET_STRING;
      with valThumbnailPhoto[0].__MIDL____MIDL_itf_ads_0000_00000000.OctetString do
      begin
        dwLength := Length(Self.thumbnailPhoto);
        lpValue := @Self.thumbnailPhoto[0];
      end;

      if Length(Self.thumbnailPhoto) = 0
        then valLength := 0
        else valLength := Length(valScriptPath);

      GenerateDSMod(
        PChar('thumbnailPhoto'),
        @valThumbnailPhoto[0],
        valLength,
        @modArray[i]
      );

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

end.

