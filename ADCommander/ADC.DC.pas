unit ADC.DC;

interface

uses
  System.SysUtils, System.Classes, System.Types, System.Variants, System.StrUtils,
  System.AnsiStrings, Winapi.Windows, Winapi.ActiveX, Vcl.ComCtrls, ActiveDs_TLB,
  JwaLmAccess, JwaLmApiBuf, ADC.LDAP, JwaDSGetDc, JwaActiveDS, ADC.Types,
  ADC.Common, ADC.AD;

type
  TDCInfo = class(TObject)
  private const
    ERROR_SUCCESS            = $0;
    ERROR_INVALID_DOMAINNAME = $4BC;
    ERROR_INVALID_FLAGS      = $3EC;
    ERROR_NOT_ENOUGH_MEMORY  = $8;
    ERROR_NO_SUCH_DOMAIN     = $54B;
  protected
    destructor Destroy; override;
  private
    FAdsApi: Byte;
    FName: string;
    FIPAddr: string;
    FAddr: string;
    FDomainDnsName: string;
    FDomainNetbiosName: string;
    FDomainGUID: TGUID;
    FDnsForestName: string;
    FSchemaAttributes: TStringList;
    procedure GetSchemaAttributes(AClass: array of string); overload;
    procedure GetSchemaAttributes(AConn: PLDAP; AClass: array of string); overload;
    function GetAttributeSyntax(AConn: PLDAP; AAttr: string): string;
  public
    class procedure EnumDomainControllers(const outDCList: TStrings; AdsApi: Byte);
    constructor Create(ADomain, ADCName: string; AAdsApi: Byte); reintroduce;
    function AttributeExists(AAttr: string): Boolean;
    procedure BuildTree(ATree: TTreeView);
    procedure RefreshData;
  published
    property AdsApi: Byte read FAdsApi write FAdsApi;
    property UserAttributes: TStringList read FSchemaAttributes;
    property DomainDnsName: string read FDomainDnsName;
    property Name: string read FName;
    property IPAddress: string read FIPAddr;
    property Address: string read FAddr;
    property DomainNetbiosName: string read FDomainNetbiosName;
    property DomainGUID: TGUID read FDomainGUID;
    property DnsForestName: string read FDnsForestName;
  end;

  function DsBind(DomainControllerName: LPCTSTR; DnsDomainName: LPCTSTR;
    var phDS: PHandle): DWORD; stdcall;
  function DsUnBind(var phDS: PHandle): DWORD; stdcall;

implementation
  function DsBind; external 'ntdsapi.dll' name 'DsBindW';
  function DsUnBind; external 'ntdsapi.dll' name 'DsUnBindW';


{ TDCInfo }

procedure TDCInfo.BuildTree(ATree: TTreeView);
function GetNode(ParentNode: TTreeNode; NodeName: string): TTreeNode;
var
  TmpNode: TTreeNode;
begin
  if ParentNode = nil
    then TmpNode := ATree.Items.GetFirstNode
    else TmpNode := ParentNode.GetFirstChild;

  while (TmpNode <> nil) and (CompareText(TmpNode.Text, NodeName) <> 0) do
    TmpNode := TmpNode.GetNextSibling;

  Result := TmpNode;
end;

var
  ldapConn: PLDAP;
  RootDSE: IADs;
  TmpStr: string;
  i, j: Integer;
  CanonicalNames, NodeNames: TStringList;
  Node, ParentNode: TTreeNode;
  ContData: POrganizationalUnit;
begin
  ATree.Items.BeginUpdate;
  ATree.Items.Clear;
  CanonicalNames := TStringList.Create;
  CanonicalNames.Sorted := True;
  NodeNames := TStringList.Create;
  NodeNames.StrictDelimiter := True;
  NodeNames.Delimiter := '/';

  case FAdsApi of
    ADC_API_LDAP: begin
      ldapConn := nil;
      ServerBinding(FName, ldapConn, TExceptionProc(nil));
      ADEnumContainers(ldapConn, CanonicalNames);
      ldap_unbind(ldapConn);
    end;

    ADC_API_ADSI: begin
      RootDSE := nil;
      ServerBinding(FName, @RootDSE, TExceptionProc(nil));
      ADEnumContainers(RootDSE, CanonicalNames);
      RootDSE := nil;
    end;
  end;

  for i := 0 to CanonicalNames.Count - 1 do
  begin
    NodeNames.DelimitedText := CanonicalNames[i];
    ParentNode := nil;
    for j := 0 to NodeNames.Count - 1 do
    begin
      Node := GetNode(ParentNode, NodeNames[j]);
      if Node = nil then
      begin
        TmpStr := '';
        New(ContData);
        ContData^ := POrganizationalUnit(CanonicalNames.Objects[i])^;
        Node := ATree.Items.AddChildObject(
          ParentNode,
          NodeNames[j],
          ContData
        );

        ContData^.Path := GetTreeNodePath(Node, TmpStr, '/');

        if Node.Parent = nil
          then Node.ImageIndex := 0
          else case ContData^.Category of
            AD_CONTCAT_CONTAINER: Node.ImageIndex := 1;
            AD_CONTCAT_ORGUNIT  : Node.ImageIndex := 2;
          end;

        Node.SelectedIndex := Node.ImageIndex;
      end;
      ParentNode := Node;
    end;
  end;
  if ATree.Items.Count > 0 then ATree.TopItem.Expand(False);
  ATree.Items.EndUpdate;

  for i := CanonicalNames.Count - 1 downto 0 do
    if CanonicalNames.Objects[i] <> nil then
    begin
      Dispose(POrganizationalUnit(CanonicalNames.Objects[i]));
      CanonicalNames.Objects[i] := nil;
    end;

  CanonicalNames.Free;
  NodeNames.Free;
end;

constructor TDCInfo.Create(ADomain, ADCName: string; AAdsApi: Byte);
begin
  FAdsApi := AAdsApi;
  FSchemaAttributes := TStringList.Create;
  FSchemaAttributes.Sorted := True;
  FDomainDnsName := ADomain;
  FName := ADCName;
  RefreshData;
end;

destructor TDCInfo.Destroy;
begin
  FSchemaAttributes.Free;
  inherited;
end;

class procedure TDCInfo.EnumDomainControllers(const outDCList: TStrings; AdsApi: Byte);
type
  PDomainsArray = ^TDomainsArray;
  TDomainsArray = array [1..100] of DS_DOMAIN_TRUSTS;
var
  i: Integer;
  dwRet: DWORD;
  hGetDc: THandle;
  pszDnsHostName: LPTSTR;
  ulSocketCount: UINT;
  rgSocketAddresses: LPSOCKET_ADDRESS;
  Domains: PDomainsArray;
  DomainInfo: TDCInfo;
begin
  for i := 0 to outDCList.Count - 1 do
    if outDCList.Objects[i] <> nil then outDCList.Objects[i].Free;

  outDCList.Clear;

  dwRet := DsEnumerateDomainTrusts(
    nil,
    DS_DOMAIN_PRIMARY {or DS_DOMAIN_IN_FOREST or DS_DOMAIN_DIRECT_OUTBOUND},
    PDS_DOMAIN_TRUSTS(Domains),
    ulSocketCount
  );

  if dwRet = ERROR_SUCCESS then
  for i := 1 to ulSocketCount do
  begin
    dwRet := DsGetDcOpen(
      PChar(Domains[i].DnsDomainName),
      DS_NOTIFY_AFTER_SITE_RECORDS,
      nil,
      nil,
      nil,
      DS_FORCE_REDISCOVERY,
      hGetDc
    );

    if dwRet = ERROR_SUCCESS then
    begin
      while True do
      begin
        dwRet := DsGetDcNext(
          hGetDc,
          @ulSocketCount,
          @rgSocketAddresses,
          @pszDnsHostName
        );

        case dwRet of
          ERROR_SUCCESS: begin
            DomainInfo := TDCInfo.Create(Domains[i].DnsDomainName, pszDnsHostName, AdsApi);
            outDCList.AddObject(
              DomainInfo.DomainDnsName + '|' + DomainInfo.Name,
              DomainInfo
            );
            NetApiBufferFree(LPVOID(pszDnsHostName));
            LocalFree(UInt64(rgSocketAddresses));
          end;

          ERROR_NO_MORE_ITEMS: begin
            Break;
          end;

          ERROR_FILEMARK_DETECTED: begin
            {
            DS_NOTIFY_AFTER_SITE_RECORDS was specified in
            DsGetDcOpen and the end of the site-specific
            records was reached.
            }
            Continue;
          end;

          else begin
            Break;
          end;
        end;
      end;
      DsGetDcCloseW(hGetDc);
    end;
  end;
  NetApiBufferFree(Domains);
end;

procedure TDCInfo.GetSchemaAttributes(AConn: PLDAP; AClass:  array of string);
const
  AttrArray: array of AnsiString = [
    'subClassOf',
    'systemAuxiliaryClass',
    'mayContain',
    'mustContain',
    'systemMayContain',
    'systemMustContain'
  ];

var
  returnCode: ULONG;
  errorCode: ULONG;
  morePages: Boolean;
  ldapBase: AnsiString;
  ldapFilter: AnsiString;
  ldapCookie: PLDAPBerVal;
  ldapPage: PLDAPControl;
  ldapControls: array[0..1] of PLDAPControl;
  ldapServerControls: PPLDAPControl;
  ldapCount: ULONG;
  ldapSearchResult: PLDAPMessage;
  ldapAttributes: array of PAnsiChar;
  ldapEntry: PLDAPMessage;
  ldapValues: PPAnsiChar;
  i: Integer;
  ldapClass: string;
  attr: AnsiString;
begin
  if not Assigned(AConn) then Exit;

  ldapCookie := nil;
  ldapSearchResult := nil;

  ldapBase := 'CN=Schema,CN=Configuration,' + System.AnsiStrings.ReplaceText('DC=' + FDomainDnsName, '.', ',DC=');

  { Формируем набор атрибутов }
  SetLength(ldapAttributes, Length(AttrArray) + 1);
  for i := Low(AttrArray) to High(AttrArray) do
    ldapAttributes[i] := PAnsiChar(AttrArray[i]);

  for ldapClass in AClass do
  try
    { Формируем фильтр объектов AD }
    ldapFilter := '(&(objectCategory=classSchema)(lDAPDisplayName=' + ldapClass + '))';

    ldapCookie := nil;

    { Постраничный поиск объектов AD }
    repeat
      returnCode := ldap_create_page_control(
        AConn,
        1000,
        ldapCookie,
        1,
        ldapPage
      );

      if returnCode <> LDAP_SUCCESS
        then raise Exception.Create('Failure during ldap_create_page_control.');

      ldapControls[0] := ldapPage;
      ldapControls[1] := nil;

      returnCode := ldap_search_ext_s(
        AConn,
        PAnsiChar(ldapBase),
        LDAP_SCOPE_ONELEVEL,
        PAnsiChar(ldapFilter),
        PAnsiChar(@ldapAttributes[0]),
        0,
        nil,//@ldapControls,
        nil,
        nil,
        0,
        ldapSearchResult
      );

      if not (returnCode in [LDAP_SUCCESS, LDAP_PARTIAL_RESULTS])
        then raise Exception.Create('Failure during ldap_search_ext_s.');

      returnCode := ldap_parse_result(
        AConn^,
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
        AConn,
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

      { Обработка результатов. Присутствует рекурсия! }
      ldapEntry := ldap_first_entry(AConn, ldapSearchResult);
      while ldapEntry <> nil do
      begin
        for attr in AttrArray do
        begin
          i := 0;
          ldapValues := ldap_get_values(AConn, ldapEntry, PAnsiChar(attr));
          if Assigned(ldapValues) then
          case IndexText(attr, ['subClassOf', 'systemAuxiliaryClass']) of
            0: begin
              { Если текущий класс и его родитель не равны, то...    }
              { Например класс "top" в поле "subClassOf" содержит    }
              { себя же - "top", рекурсию в этом случае не выполняем }
              if CompareText(ldapClass, string(ldapValues^)) <> 0
                then GetSchemaAttributes(AConn, [ldapValues^])
            end;

            1: begin
              while ldapValues^ <> nil do
              begin
                GetSchemaAttributes(AConn, [ldapValues^]);
                Inc(ldapValues);
                Inc(i);
              end;
              Dec(ldapValues, i);
            end;

            else begin
              while ldapValues^ <> nil do
              begin
                FSchemaAttributes.Add(ldapValues^ + '=' + GetAttributeSyntax(AConn, ldapValues^));
                Inc(ldapValues);
                Inc(i);
              end;
              Dec(ldapValues, i);
            end;
          end;
          ldap_value_free(ldapValues);
        end;

        ldapEntry := ldap_next_entry(AConn, ldapEntry);
      end;

      ldap_msgfree(ldapSearchResult);
      ldapSearchResult := nil;
    until (morePages = False);

    ber_bvfree(ldapCookie);
    ldapCookie := nil;
  except;

  end;

  if ldapSearchResult <> nil
    then ldap_msgfree(ldapSearchResult);
end;

function TDCInfo.GetAttributeSyntax(AConn: PLDAP; AAttr: string): string;
var
  returnCode: ULONG;
  ldapBase: AnsiString;
  ldapFilter: AnsiString;
  ldapSearchResult: PLDAPMessage;
  ldapAttributes: array of PAnsiChar;
  ldapEntry: PLDAPMessage;
  ldapValues: PPAnsiChar;
  syntax: string;
begin
  if not Assigned(AConn) then Exit;

  ldapBase := 'CN=Schema,CN=Configuration,' + System.AnsiStrings.ReplaceText('DC=' + FDomainDnsName, '.', ',DC=');

  { Формируем фильтр объектов AD }
  ldapFilter := '(&(objectCategory=attributeSchema)(lDAPDisplayName=' + AAttr + '))';

  { Формируем набор атрибутов }
  SetLength(ldapAttributes, 2);
  ldapAttributes[0] := PAnsiChar('attributeSyntax');
  ldapAttributes[1] := nil;

  try
    returnCode := ldap_search_s(
      AConn,
      PAnsiChar(ldapBase),
      LDAP_SCOPE_ONELEVEL,
      PAnsiChar(ldapFilter),
      PAnsiChar(@ldapAttributes[0]),
      0,
      ldapSearchResult
    );

    if returnCode <> LDAP_SUCCESS
      then raise Exception.Create(ldap_err2string(returnCode));

    { Обработка результатов }
    ldapEntry := ldap_first_entry(AConn, ldapSearchResult);
    while ldapEntry <> nil do
    begin
      ldapValues := ldap_get_values(AConn, ldapEntry, ldapAttributes[0]);
      if Assigned(ldapValues) then syntax := ldapValues^ else syntax := '';
      case IndexText(syntax,
        [
           '2.5.5.0',   { Undefined }
           '2.5.5.1',   { Object(DN-DN) }
           '2.5.5.2',   { String(Object-Identifier) }
           '2.5.5.3',   { Case-Sensitive String }
           '2.5.5.4',   { CaseIgnoreString(Teletex) }
           '2.5.5.5',   { String(IA5) }
           '2.5.5.6',   { String(Numeric) }
           '2.5.5.7',   { Object(DN-Binary) }
           '2.5.5.8',   { Boolean }
           '2.5.5.9',   { Integer }
           '2.5.5.10',  { String(Octet) }
           '2.5.5.11',  { String(UTC-Time) }
           '2.5.5.12',  { String(Unicode) }
           '2.5.5.13',  { Object(Presentation-Address) }
           '2.5.5.14',  { Object(DN-String) }
           '2.5.5.15',  { String(NT-Sec-Desc) }
           '2.5.5.16',  { LargeInteger }
           '2.5.5.17'   { String(Sid) }
        ]

      ) of
         0: Result := ATTR_TYPE_UNDEFINED;
         1: Result := ATTR_TYPE_DN_STRING;
         2: Result := ATTR_TYPE_OID;
         3: Result := ATTR_TYPE_CASE_EXACT_STRING;
         4: Result := ATTR_TYPE_CASE_IGNORE_STRING;
         5: Result := ATTR_TYPE_PRINTABLE_STRING;
         6: Result := ATTR_TYPE_NUMERIC_STRING;
         7: Result := ATTR_TYPE_DN_WITH_BINARY;
         8: Result := ATTR_TYPE_BOOLEAN;
         9: Result := ATTR_TYPE_INTEGER;
        10: Result := ATTR_TYPE_OCTET_STRING;
        11: Result := ATTR_TYPE_UTC_TIME;
        12: Result := ATTR_TYPE_DIRECTORY_STRING;
        13: Result := ATTR_TYPE_PRESENTATION_ADDRESS;
        14: Result := ATTR_TYPE_DN_WITH_STRING;
        15: Result := ATTR_TYPE_NT_SECURITY_DESCRIPTOR;
        16: Result := ATTR_TYPE_LARGE_INTEGER;
        17: Result := ATTR_TYPE_SID_STRING;
        else Result := syntax;
      end;

      ldap_value_free(ldapValues);

      ldapEntry := ldap_next_entry(AConn, ldapEntry);
    end;

    ldap_msgfree(ldapSearchResult);
    ldapSearchResult := nil;
  except

  end;

  if ldapSearchResult <> nil
    then ldap_msgfree(ldapSearchResult);
  ldapSearchResult := nil;
end;

procedure TDCInfo.GetSchemaAttributes(AClass: array of string);
var
  i: Integer;
  hr: HRESULT;
  objClassName: string;
  objIADs: IADs;
  objSchema: IADsContainer;
  objClass: IADsClass;
  objProperty: IADsProperty;
  pathName: string;
begin
  CoInitialize(nil);

  for objClassName in AClass do
  try
    pathName := Format('LDAP://%s/Schema/%s', [FName, objClassName]);

    hr := ADsOpenObject(
      PChar(pathName),
      nil,
      nil,
      ADS_SECURE_AUTHENTICATION or ADS_SERVER_BIND,
      IID_IADsClass,
      @objClass
    );

    if hr <> S_OK
      then raise Exception.Create('TDCInfo.GetSchemaUserAttributes: ADsOpenObject');

    hr := ADsOpenObject(
      PChar(objClass.Parent),
      nil,
      nil,
      ADS_SECURE_AUTHENTICATION or ADS_SERVER_BIND,
      IID_IADsContainer,
      @objSchema
    );

    if SUCCEEDED(hr) then
    begin
      if VarIsArray(objClass.MandatoryProperties) then
      for i := VarArrayLowBound(objClass.MandatoryProperties, 1)
      to VarArrayHighBound(objClass.MandatoryProperties, 1) do
      begin
        objProperty := objSchema.GetObject('Property', objClass.MandatoryProperties[i]) as IADsProperty;
        FSchemaAttributes.Add(
          Format(
            '%s=%s',
            [objClass.MandatoryProperties[i], objProperty.Syntax]
          )
        );
      end;

      if VarIsArray(objClass.OptionalProperties) then
      for i := VarArrayLowBound(objClass.OptionalProperties, 1)
      to VarArrayHighBound(objClass.OptionalProperties, 1) do
      begin
        objProperty := objSchema.GetObject('Property', objClass.OptionalProperties[i]) as IADsProperty;
        FSchemaAttributes.Add(
          Format(
            '%s=%s',
            [objClass.OptionalProperties[i], objProperty.Syntax]
          )
        );
      end;
    end;
  except
    on e:Exception do
    begin
      OutputDebugString(PChar(e.Message));
      Continue;
    end;
  end;

  CoUninitialize;
end;

procedure TDCInfo.RefreshData;
var
  res: DWORD;
  pdcInfo: PDOMAIN_CONTROLLER_INFO;
  ldapConn: PLDAP;
  RootDSE: IADs;
  i: Integer;
begin
  res := DsGetDcName(
    PChar(FName),
    PChar(FDomainDnsName),
    nil,
    nil,
    DS_IS_DNS_NAME or DS_RETURN_FLAT_NAME,
    pdcInfo
  );

  case res of
    Self.ERROR_SUCCESS: begin
      Self.FDomainNetbiosName := pdcInfo.DomainName;
      case pdcInfo.DomainControllerAddressType of
        DS_NETBIOS_ADDRESS: Self.FAddr := StringReplace(pdcInfo.DomainControllerAddress, '\\', '', []);
        DS_INET_ADDRESS: Self.FIPAddr := StringReplace(pdcInfo.DomainControllerAddress, '\\', '', []);
      end;

      if Self.FAddr.IsEmpty
        then Self.FAddr := StringReplace(pdcInfo.DomainControllerName, '\\', '', []);
    end;

    Self.ERROR_INVALID_DOMAINNAME: ;
    Self.ERROR_INVALID_FLAGS: ;
    Self.ERROR_NOT_ENOUGH_MEMORY: ;
    Self.ERROR_NO_SUCH_DOMAIN: ;
    else ;
  end;

  NetApiBufferFree(pdcInfo);

  res := DsGetDcName(
    PChar(FName),
    PChar(FDomainDnsName),
    nil,
    nil,
    DS_IS_DNS_NAME or DS_RETURN_DNS_NAME or DS_IP_REQUIRED,
    pdcInfo
  );

  case res of
    Self.ERROR_SUCCESS: begin
      Self.FDomainGUID := pdcInfo.DomainGuid;
      Self.FDnsForestName := pdcInfo.DnsForestName;
      case pdcInfo.DomainControllerAddressType of
        DS_NETBIOS_ADDRESS: Self.FAddr := StringReplace(pdcInfo.DomainControllerAddress, '\\', '', []);
        DS_INET_ADDRESS: Self.FIPAddr := StringReplace(pdcInfo.DomainControllerAddress, '\\', '', []);
      end;
    end;
    Self.ERROR_INVALID_DOMAINNAME: ;
    Self.ERROR_INVALID_FLAGS: ;
    Self.ERROR_NOT_ENOUGH_MEMORY: ;
    Self.ERROR_NO_SUCH_DOMAIN: ;
    else ;
  end;

  NetApiBufferFree(pdcInfo);

  FSchemaAttributes.Clear;
  case FAdsApi of
    ADC_API_LDAP: begin
      ldapConn := nil;
      ServerBinding(FName, ldapConn, TExceptionProc(nil));
      GetSchemaAttributes(ldapConn, ['Computer', 'User', 'Group']);
      ldap_unbind(ldapConn);
    end;

    ADC_API_ADSI: begin
      GetSchemaAttributes(['Computer', 'User', 'Group']);
    end;
  end;
end;

function TDCInfo.AttributeExists(AAttr: string): Boolean;
begin
  Result := FSchemaAttributes.IndexOfName(AAttr) > -1;
end;

end.
