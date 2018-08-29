unit tdADSIEnum;

interface

uses
  System.SysUtils, System.StrUtils, System.Classes, System.TypInfo, System.DateUtils,
  System.Math,
  System.Generics.Collections, Winapi.Windows, Winapi.ActiveX, ActiveDs_TLB, MSXML2_TLB,
  JwaActiveDS, ADC.Types, ADC.DC, ADC.Attributes, ADC.ADObject, ADC.ADObjectList,
  ADC.Common, ADC.AD;

type
  TADSIEnum = class(TThread)
  private
    FProgressProc: TProgressProc;
    FExceptionProc: TExceptionProc;
    FProgressValue: Integer;
    FExceptionCode: ULONG;
    FExceptionMsg: string;
    FDomainDN: string;
    FDomainHostName: string;
    FAttrCatalog: TAttrCatalog;
    FAttributes: array of WideString;
    FOutList: TADObjectList<TADObject>;
    FObj: TADObject;
    FSearchRes: IDirectorySearch;
    FSearchHandle: PHandle;
    FMaxPwdAge_Secs: Int64;
    FMaxPwdAge_Days: Int64;
    procedure FillEventList(AStringStream: TStringStream;
      AOutList: TStringList);
    procedure ProcessObjects;
    procedure SyncProgress;
    procedure SyncException;
    procedure Clear;
    procedure GetMaxPasswordAge;
    function TimestampToDateTime(ATime: ActiveDS_TLB._LARGE_INTEGER): TDateTime;
  protected
    destructor Destroy; override;
    procedure Execute; override;
    procedure DoProgress(AProgress: Integer); overload;
    procedure DoProgress; overload;
    procedure DoException(AMsg: string; ACode: ULONG);
  public
    constructor Create(ARootDSE: IADs; AAttrCatalog: TAttrCatalog;
      AOutList: TADObjectList<TADObject>; AProgressProc: TProgressProc;
      AExceptionProc: TExceptionProc; CreateSuspended: Boolean = False); reintroduce;
  end;

implementation

{ TADObjectInfoEnum }

procedure TADSIEnum.Clear;
begin
  if Terminated then FOutList.Clear;
  FProgressProc := nil;
  FExceptionProc := nil;
  FProgressValue := 0;
  FExceptionCode := 0;
  FExceptionMsg := '';
  FAttrCatalog := nil;
  FOutList.SortObjects;
  FOutList := nil;
  FObj := nil;
  FSearchRes.CloseSearchHandle(Pointer(FSearchHandle));
  CoUninitialize;
end;

constructor TADSIEnum.Create(ARootDSE: IADs; AAttrCatalog: TAttrCatalog;
  AOutList: TADObjectList<TADObject>; AProgressProc: TProgressProc;
  AExceptionProc: TExceptionProc; CreateSuspended: Boolean);
var
  i: Integer;
  v: OleVariant;
begin
  inherited Create(CreateSuspended);

  FreeOnTerminate := True;
  FAttrCatalog := AAttrCatalog;
  FOutList := AOutList;
  FOutList.Clear;
  FProgressProc := AProgressProc;
  FExceptionProc := AExceptionProc;

  if ARootDSE = nil then
  begin
    Self.Terminate;
    DoException('No server binding.', 0);
    Exit;
  end;

  v := ARootDSE.Get('defaultNamingContext');
  FDomainDN := VariantToStringWithDefault(v, '');
  VariantClear(v);

  v := ARootDSE.Get('dnsHostName');
  FDomainHostName := VariantToStringWithDefault(v, '');
  VariantClear(v);

  SetLength(FAttributes, FAttrCatalog.Count);
  for i := 0 to FAttrCatalog.Count - 1 do
  begin
    if FAttrCatalog[i]^.Name = ''
      then FAttributes[i] := '<Undefined>'
      else FAttributes[i] := FAttrCatalog[i]^.Name;
  end;
end;

destructor TADSIEnum.Destroy;
begin

  inherited;
end;

procedure TADSIEnum.DoProgress;
begin
  FProgressValue := FProgressValue + 1;
  Synchronize(SyncProgress);
end;

procedure TADSIEnum.Execute;
var
  objFilter: string;
  pDomain: IADsDomain;
  hRes: HRESULT;
  SearchPrefs: array of ADS_SEARCHPREF_INFO;
begin
  CoInitialize(nil);
  try
    if Terminated
      then raise Exception.Create('No server binding.');

    { »звлекаем срок действи€ парол€ из политики домена }
    GetMaxPasswordAge;

    { ќсуществл€ем поиск в домене атрибутов и их значений }
    hRes := ADsOpenObject(
      PChar('LDAP://' + FDomainHostName + '/' + FDomainDN),
      nil,
      nil,
      ADS_SECURE_AUTHENTICATION or ADS_SERVER_BIND,
      IID_IDirectorySearch,
      @FSearchRes
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
//      with SearchPrefs[3] do
//      begin
//        dwSearchPref  := ADS_SEARCHPREF_EXTENDED_DN;
//        vValue.dwType := ADSTYPE_INTEGER;
//        vValue.__MIDL____MIDL_itf_ads_0000_00000000.Integer := 1;
//      end;

      hRes := FSearchRes.SetSearchPreference(SearchPrefs[0], Length(SearchPrefs));

      objFilter := '(|' +
        '(&(objectCategory=person)(objectClass=user))' +
        '(objectCategory=group)' +
        '(objectCategory=computer)' +
      ')';

      DoProgress(0);

      FSearchRes.ExecuteSearch(
        PWideChar(objFilter),
        PWideChar(@FAttributes[0]),
        Length(FAttributes),
        Pointer(FSearchHandle)
      );

      ProcessObjects;
    end;
    Clear;
  except
    on E: Exception do
    begin
      DoException(E.Message, hRes);
      Clear;
    end;
  end;
end;

procedure TADSIEnum.DoProgress(AProgress: Integer);
begin
  FProgressValue := AProgress;
  Synchronize(SyncProgress);
end;

procedure TADSIEnum.FillEventList(
  AStringStream: TStringStream; AOutList: TStringList);
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

procedure TADSIEnum.GetMaxPasswordAge;
const
  ONE_HUNDRED_NANOSECOND = 0.000000100;
  SECONDS_IN_DAY         = 86400;
var
  hRes: HRESULT;
  pDomain: IADs;
  v: OleVariant;
  d: LARGE_INTEGER;
begin
  hRes := ADsOpenObject(
    PChar('LDAP://' + FDomainHostName + '/' + FDomainDN),
    nil,
    nil,
    ADS_SECURE_AUTHENTICATION or ADS_SERVER_BIND,
    IID_IADs,
    @pDomain
  );

  if Succeeded(hRes) then
  begin
    v := pDomain.Get('maxPwdAge');
    d.HighPart := (IDispatch(v) as IADsLargeInteger).HighPart;
    d.LowPart := (IDispatch(v) as IADsLargeInteger).LowPart;
    VariantClear(v);
    if d.LowPart = 0 then
    begin
	    FMaxPwdAge_Secs := 0;
      FMaxPwdAge_Days := 0;
    end else
    begin
      d.QuadPart := d.HighPart;
      d.QuadPart := d.QuadPart shl 32;
      d.QuadPart := d.QuadPart + d.LowPart;

      FMaxPwdAge_Secs := Abs(Round(d.QuadPart * ONE_HUNDRED_NANOSECOND));
      FMaxPwdAge_Days := Round(FMaxPwdAge_Secs / SECONDS_IN_DAY);
    end;
  end;

  pDomain := nil;
end;

procedure TADSIEnum.SyncException;
begin
  if Assigned(FExceptionProc)
    then FExceptionProc(FExceptionMsg, FExceptionCode);
end;

procedure TADSIEnum.SyncProgress;
begin
  if Assigned(FProgressProc)
    then FProgressProc(FProgressValue);
end;

function TADSIEnum.TimestampToDateTime(
  ATime: ActiveDS_TLB._LARGE_INTEGER): TDateTime;
var
  int64Value: Int64;
  LocalTime: TFileTime;
  SystemTime: TSystemTime;
  FileTime : TFileTime;
begin
  int64Value := ATime.QuadPart;
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

procedure TADSIEnum.ProcessObjects;
var
  i: Integer;
  hRes: HRESULT;
  col: ADS_SEARCH_COLUMN;
  attr: TADAttribute;
  memStream: TMemoryStream;
  strStream: TStringStream;
  d: TDateTime;
begin
  hRes := FSearchRes.GetNextRow(FSearchHandle);
  while (hRes <> S_ADS_NOMORE_ROWS) do
  begin
    if Terminated then Break;

    FObj := TADObject.Create;
    FObj.DomainHostName := FDomainHostName;
    for i := 0 to FAttrCatalog.Count - 1 do
    begin
      attr := FAttrCatalog[i]^;
      hRes := FSearchRes.GetColumn(FSearchHandle, PWideChar(string(attr.Name)), col);
      if Succeeded(hRes) then
      if attr.ObjProperty = 'nearestEvent' then
      begin
        strStream := TStringStream.Create;
        try
          strStream.Write(
            col.pAdsvalues^.__MIDL____MIDL_itf_ads_0000_00000000.OctetString.lpValue^,
            col.pAdsvalues^.__MIDL____MIDL_itf_ads_0000_00000000.OctetString.dwLength
          );
          strStream.Seek(0, soFromBeginning);
          FillEventList(strStream, FObj.events);
        finally
          strStream.Free;
        end;
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
          SetFloatProp(
            FObj,
            string(attr.ObjProperty),
            Self.TimestampToDateTime(col.pAdsvalues^.__MIDL____MIDL_itf_ads_0000_00000000.LargeInteger)
          );
        end;

        1: begin                   { pwdLastSet }
          begin
            d := Self.TimestampToDateTime(col.pAdsvalues^.__MIDL____MIDL_itf_ads_0000_00000000.LargeInteger);
            if d > 0
              then SetFloatProp(FObj, string(attr.ObjProperty), IncSecond(d, FMaxPwdAge_Secs))
              else SetFloatProp(FObj, string(attr.ObjProperty), 0)
          end;
        end;

        2..4: begin                { badPwdCount, groupType, userAccountControl }
          SetOrdProp(
            FObj,
            string(attr.ObjProperty),
            col.pAdsvalues^.__MIDL____MIDL_itf_ads_0000_00000000.Integer
          );
        end;

        5: begin                   { objectSid }
          SetPropValue(
            FObj,
            string(attr.ObjProperty),
            SIDToString(col.pAdsvalues^.__MIDL____MIDL_itf_ads_0000_00000000.OctetString.lpValue)
          );
        end;

        6: begin                   { thumbnailPhoto }
            memStream := TMemoryStream.Create;
            try
              memStream.Write(
                col.pAdsvalues^.__MIDL____MIDL_itf_ads_0000_00000000.OctetString.lpValue^,
                col.pAdsvalues^.__MIDL____MIDL_itf_ads_0000_00000000.OctetString.dwLength
              );
              memStream.Seek(0, soFromBeginning);
              FObj.thumbnailPhoto.LoadFromStream(memStream);
            finally
              memStream.Free;
            end;
        end;

        7: begin                   { distinguishedName }
          SetPropValue(
            FObj,
            string(attr.ObjProperty),
            string(col.pAdsvalues^.__MIDL____MIDL_itf_ads_0000_00000000.CaseIgnoreString)
          );
        end;
                                   { primaryGroupToken }
        8: begin
          SetOrdProp(
            FObj,
            string(attr.ObjProperty),
            col.pAdsvalues^.__MIDL____MIDL_itf_ads_0000_00000000.Integer
          );
        end

        else begin                 { ¬се текстовые атрибуты }
          SetPropValue(
            FObj,
            string(attr.ObjProperty),
            string(col.pAdsvalues^.__MIDL____MIDL_itf_ads_0000_00000000.CaseIgnoreString)
          );
        end;
      end;

      FSearchRes.FreeColumn(col);
    end;
    FOutList.Add(FObj);
    DoProgress;
    hRes := FSearchRes.GetNextRow(Pointer(FSearchHandle));
  end;
end;

procedure TADSIEnum.DoException(AMsg: string; ACode: ULONG);
begin
  FExceptionCode := ACode;
  FExceptionMsg := AMsg;
  Synchronize(SyncException);
end;

end.
