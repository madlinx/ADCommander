unit tdADSIEnum;

interface

uses
  System.SysUtils, System.StrUtils, System.Classes, System.TypInfo, System.DateUtils,
  System.Math, System.SyncObjs,
  System.Generics.Collections, Winapi.Windows, Winapi.ActiveX, ActiveDs_TLB, MSXML2_TLB,
  JwaActiveDS, ADC.Types, ADC.DC, ADC.Attributes, ADC.ADObject, ADC.ADObjectList,
  ADC.Common, ADC.AD;

type
  TADSIEnum = class(TThread)
  private
    FSyncObject: TCriticalSection;
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
    procedure GetMaxPasswordAge;
    procedure SyncProgress;
    procedure SyncException;
    procedure Clear;
  protected
    destructor Destroy; override;
    procedure Execute; override;
    procedure DoProgress(AProgress: Integer); overload;
    procedure DoProgress; overload;
    procedure DoException(AMsg: string; ACode: ULONG);
  public
    constructor Create(ARootDSE: IADs; AAttrCatalog: TAttrCatalog;
      AOutList: TADObjectList<TADObject>; ASyncObject: TCriticalSection;
      AProgressProc: TProgressProc; AExceptionProc: TExceptionProc;
      CreateSuspended: Boolean = False); reintroduce;
  end;

implementation

{ TADObjectInfoEnum }

procedure TADSIEnum.Clear;
begin
  if Terminated and (FOutList <> nil)
    then FOutList.Clear;

  FProgressProc := nil;
  FExceptionProc := nil;
  FProgressValue := 0;
  FExceptionCode := 0;
  FExceptionMsg := '';
  FDomainDN := '';
  FDomainHostName := '';
  FMaxPwdAge_Secs := 0;
  FMaxPwdAge_Days := 0;
  FAttrCatalog := nil;
  FOutList := nil;
  FObj := nil;

  if Assigned(FSearchHandle)
    then FSearchRes.CloseSearchHandle(FSearchHandle);

  FSearchRes := nil;

  CoUninitialize;

  if FSyncObject <> nil then
  begin
    FSyncObject.Leave;
    FSyncObject := nil;
  end;
end;

constructor TADSIEnum.Create(ARootDSE: IADs; AAttrCatalog: TAttrCatalog;
  AOutList: TADObjectList<TADObject>; ASyncObject: TCriticalSection; AProgressProc: TProgressProc;
  AExceptionProc: TExceptionProc; CreateSuspended: Boolean);
var
  i: Integer;
  v: OleVariant;
begin
  inherited Create(CreateSuspended);
  FreeOnTerminate := True;

  FSyncObject := ASyncObject;
  FProgressProc := AProgressProc;
  FExceptionProc := AExceptionProc;

  if ARootDSE = nil then
  begin
    DoException('No server binding.', 0);
    Self.Terminate;
  end else
  begin
    v := ARootDSE.Get('defaultNamingContext');
    FDomainDN := VariantToStringWithDefault(v, '');
    VariantClear(v);

    v := ARootDSE.Get('dnsHostName');
    FDomainHostName := VariantToStringWithDefault(v, '');
    VariantClear(v);

    FAttrCatalog := AAttrCatalog;
    FOutList := AOutList;

    SetLength(FAttributes, FAttrCatalog.Count);
    for i := 0 to FAttrCatalog.Count - 1 do
    begin
      if FAttrCatalog[i]^.Name = ''
        then FAttributes[i] := '<Undefined>'
        else FAttributes[i] := FAttrCatalog[i]^.Name;
    end;

    { Заполняем свойства для плавающего окна }
    i := FAttrCatalog.Count;
    SetLength(FAttributes, Length(FAttributes) + 3);
    FAttributes[i] := 'displayName';
    FAttributes[i + 1] := 'title';
    FAttributes[i + 2] := 'physicalDeliveryOfficeName';
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
  hRes: HRESULT;
  SearchPrefs: array of ADS_SEARCHPREF_INFO;
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
    { Извлекаем срок действия пароля из политики домена }
    GetMaxPasswordAge;

    { Осуществляем поиск в домене атрибутов и их значений }
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

      { Если раскомментировать параметры ниже, то необходимо увеличить }
      { размер массива параметров SearchPrefs до необходимого          }

//      with SearchPrefs[3] do
//      begin
//        dwSearchPref  := ADS_SEARCHPREF_TOMBSTONE;
//        vValue.dwType := ADSTYPE_BOOLEAN;
//        vValue.__MIDL____MIDL_itf_ads_0000_00000000.Boolean := 1;
//      end;
//      with SearchPrefs[4] do
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
//        '(isDeleted=*)' +
      ')';

      DoProgress(0);

      FSearchRes.ExecuteSearch(
        PWideChar(objFilter),
        PWideChar(@FAttributes[0]),
        Length(FAttributes),
        Pointer(FSearchHandle)
      );

      { Обработка объектов }
      hRes := FSearchRes.GetNextRow(FSearchHandle);
      while (hRes <> S_ADS_NOMORE_ROWS) do
      begin
        if Terminated then Break;

        FObj := TADObject.Create;

        FObj.WriteProperties(
          FSearchRes,
          FSearchHandle,
          FAttrCatalog,
          FDomainHostName,
          FMaxPwdAge_Secs
        );

        FOutList.Add(FObj);
        DoProgress;
        hRes := FSearchRes.GetNextRow(Pointer(FSearchHandle));
      end;
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
    then FProgressProc(FObj, FProgressValue);
end;

procedure TADSIEnum.DoException(AMsg: string; ACode: ULONG);
begin
  FExceptionCode := ACode;
  FExceptionMsg := AMsg;
  Synchronize(SyncException);
end;

end.
