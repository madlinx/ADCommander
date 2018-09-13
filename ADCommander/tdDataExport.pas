unit tdDataExport;

interface

uses
  System.Classes, System.SysUtils, System.SyncObjs, Winapi.Windows, System.Win.ComObj,
  Winapi.ActiveX, System.IOUtils, System.Variants, Data.DB, Data.Win.ADODB, ActiveDs_TLB,
  Vcl.Imaging.jpeg, ADC.Types, ADC.AD, ADC.LDAP, ADC.ADObject, System.TypInfo, System.AnsiStrings,
  ADC.ADObjectList, ADC.Attributes, ADC.ExcelEnum, ADC.Common, ADOX_TLB, ADC.Elevation,
  ADC.ImgProcessor;

const
  DB_PROVIDER_JET = 'Microsoft.Jet.OLEDB.4.0';
  DB_PROVIDER_ACE120 = 'Microsoft.ACE.OLEDB.12.0';

type
  TADCExporter = class(TThread)
  private
    FOwner: HWND;
    FAPI: Integer;
    FLDAP: PLDAP;
    FRootDSE: IADs;
    FSrc: TADObjectList<TADObject>;
    FAttrCat: TAttrCatalog;
    FFormat: TADCExportFormat;
    FFileName: TFileName;
    FSyncObject: TCriticalSection;
    FProgressProc: TProgressProc;
    FExceptionProc: TExceptionProc;

    FDBConnectionString: string;
    FObj: TADObject;
    FProgressValue: Integer;
    FExceptionCode: ULONG;
    FExceptionMsg: string;

    procedure Initialize(AOwner: HWND; ASourceList: TADObjectList<TADObject>;
      AAttrCatalog: TAttrCatalog; AFormat: TADCExportFormat; AFileName: TFileName;
      ASyncObject: TCriticalSection; AProgressProc: TProgressProc; AExceptionProc: TExceptionProc);
    procedure Clear;
    function GenerateFileName(AFileName: TFileName): TFileName;
    procedure SyncProgress;
    procedure SyncException;
    procedure DoProgress(AProgress: Integer);
    procedure DoException(AMsg: string; ACode: ULONG);
    procedure DoDataExport_Access;
    procedure DoDataExport_Excel;
  protected
    procedure Execute; override;
  public
    constructor Create(AOwner: HWND; ARootDSE: IADs; ASourceList: TADObjectList<TADObject>;
      AAttrCatalog: TAttrCatalog; AFormat: TADCExportFormat; AFileName: TFileName;
      ASyncObject: TCriticalSection; AProgressProc: TProgressProc; AExceptionProc: TExceptionProc;
      CreateSuspended: Boolean = False); reintroduce; overload;
    constructor Create(AOwner: HWND; ALDAP: PLDAP; ASourceList: TADObjectList<TADObject>;
      AAttrCatalog: TAttrCatalog; AFormat: TADCExportFormat; AFileName: TFileName;
      ASyncObject: TCriticalSection; AProgressProc: TProgressProc; AExceptionProc: TExceptionProc;
      CreateSuspended: Boolean = False); reintroduce; overload;
    property OnException: TExceptionProc read FExceptionProc write FExceptionProc;
    property OnProgress: TProgressProc read FProgressProc write FProgressProc;
  end;

implementation

{ TADExporter }

constructor TADCExporter.Create(AOwner: HWND; ARootDSE: IADs; ASourceList: TADObjectList<TADObject>;
  AAttrCatalog: TAttrCatalog; AFormat: TADCExportFormat; AFileName: TFileName;
  ASyncObject: TCriticalSection; AProgressProc: TProgressProc; AExceptionProc: TExceptionProc;
  CreateSuspended: Boolean = False);
begin
  inherited Create(CreateSuspended);

  if (ARootDSE = nil) or (ASourceList = nil)
    then Self.Terminate;

  Initialize(
    AOwner,
    ASourceList,
    AAttrCatalog,
    AFormat,
    AFileName,
    ASyncObject,
    AProgressProc,
    AExceptionProc
  );

  FAPI := ADC_API_ADSI;
  FRootDSE := ARootDSE;
end;

function TADCExporter.GenerateFileName(AFileName: TFileName): TFileName;
var
  res: string;
  SaveAsName: string;
  SaveAsExt: string;
  SaveAsCount: Integer;
  fHandle: THandle;
begin
  res := AFileName;

  if FileExists(res) then
  begin
    SaveAsExt := ExtractFileExt(AFileName);
    SaveAsName := Copy(AFileName, 1, Length(AFileName) - Length(SaveAsExt));
    SaveAsCount := 1;

    repeat
      res := SaveAsName + ' (' + IntToStr(SaveAsCount) + ')' + SaveAsExt;
      Inc(SaveAsCount);
    until not FileExists(res);
  end;

  Result := res;

//  { ���������, ����� �� ������� ���� }
//  fHandle := CreateFile(
//    PChar(res),
//    GENERIC_READ or GENERIC_WRITE,
//    0,
//    nil,
//    CREATE_NEW,
//    FILE_ATTRIBUTE_TEMPORARY or FILE_FLAG_DELETE_ON_CLOSE,
//    0
//  );
//
//  if fHandle = INVALID_HANDLE_VALUE
//    then Result := ''
//    else Result := res;
//
//  { � CreateFile ���������� ���� FILE_FLAG_DELETE_ON_CLOSE, �������  }
//  { ����� ������ CloseHandle ���� ������ ������������� ���������. �� }
//  { �� ������ ������ �������� DeleteFile, ����� �� �������...  ;)    }
//  CloseHandle(fHandle);
//  DeleteFile(PChar(res));
end;

procedure TADCExporter.Initialize(AOwner: HWND;
  ASourceList: TADObjectList<TADObject>; AAttrCatalog: TAttrCatalog;
  AFormat: TADCExportFormat; AFileName: TFileName;
  ASyncObject: TCriticalSection; AProgressProc: TProgressProc;
  AExceptionProc: TExceptionProc);
var
  a: PADAttribute;
begin
  FOwner         := AOwner;
  FAPI           := -1;
  FLDAP          := nil;
  FRootDSE       := nil;
  FSrc           := ASourceList;
  FAttrCat       := TAttrCatalog.Create(False);
  FFormat        := AFormat;
  FFileName      := GenerateFileName(AFileName);
  FSyncObject    := ASyncObject;
  FProgressProc  := AProgressProc;
  FExceptionProc := AExceptionProc;

  case FFormat of
    efAccess:
      FDBConnectionString := Format('Provider=%s;Data Source=%s;', [DB_PROVIDER_JET, FFileName]);
    efAccess2007:
      FDBConnectionString := Format('Provider=%s;Data Source=%s;', [DB_PROVIDER_ACE120, FFileName]);
    else
      FDBConnectionString := '';
  end;

  // ������������ ������ ������������ ����, � ����� �� ������������ ����,
  // ���������� ����������� ������������ �.�. ���� ���� ��������������.
  // �� � �� ����������� ����� (������������ � ADUserInfo) ����, ���
  // ���� �������������� �����������, �� ��� �������� ����� ����� �������
  for a in AAttrCatalog do
    if (a^.IsExportRequired) or ((a^.Visible) and (not a^.IsNotExported))
      then FAttrCat.Add(a);
end;

procedure TADCExporter.Clear;
begin
  FAPI           := -1;
  FLDAP          := nil;
  FRootDSE       := nil;
  FSrc           := nil;
  FFormat        := efNone;
  FFileName      := '';
  FProgressProc  := nil;
  FExceptionProc := nil;
  FAttrCat.Free;

  CoUninitialize;

  if FSyncObject <> nil then
  begin
    FSyncObject.Leave;
    FSyncObject := nil;
  end;
end;

constructor TADCExporter.Create(AOwner: HWND; ALDAP: PLDAP; ASourceList: TADObjectList<TADObject>;
  AAttrCatalog: TAttrCatalog; AFormat: TADCExportFormat; AFileName: TFileName;
  ASyncObject: TCriticalSection; AProgressProc: TProgressProc; AExceptionProc: TExceptionProc;
  CreateSuspended: Boolean = False);
begin
  inherited Create(CreateSuspended);

  if (ALDAP = nil) or (ASourceList = nil)
    then Self.Terminate;

  Initialize(
    AOwner,
    ASourceList,
    AAttrCatalog,
    AFormat,
    AFileName,
    ASyncObject,
    AProgressProc,
    AExceptionProc
  );

  FAPI := ADC_API_LDAP;
  FLDAP := ALDAP;
end;

procedure TADCExporter.DoException(AMsg: string; ACode: ULONG);
begin
  FExceptionCode := ACode;
  FExceptionMsg := AMsg;
  Synchronize(SyncException);
end;

procedure TADCExporter.DoProgress(AProgress: Integer);
begin
  FProgressValue := AProgress;
  Synchronize(SyncProgress);
end;

procedure TADCExporter.Execute;
begin
  CoInitialize(nil);

  if FSyncObject <> nil then
  if not FSyncObject.TryEnter then
  begin
    FSyncObject := nil;
    Self.OnTerminate := nil;
    Self.Terminate;
  end;

  if Terminated then
  begin
    Clear;
    Exit;
  end;

  try
    case FFormat of
      efAccess..efAccess2007: begin
        DoDataExport_Access;
      end;

      efExcel..efExcel2007: begin
        DoDataExport_Excel;
      end;

      efCommaSeparated: begin
        DoDataExport_Excel;
      end;
    end;
  except
    on E: Exception do
    begin
      DoException(E.Message, 0);
    end;
  end;

  Clear;
end;

procedure TADCExporter.DoDataExport_Access;
var
  oCatalog: Catalog;
  oConnection: OleVariant;
  sTableName: string;
  sFieldValues: string;
  sValue: string;
  a: PADAttribute;
  i: Integer;
  j: Integer;
  o: TADObject;
  thumbnailPhoto: TImgByteArray;
  lstMembers: TADGroupMemberList;
begin
  lstMembers := TADGroupMemberList.Create;

  oCatalog := CreateAccessDatabase(
    FOwner,
    PChar(FDBConnectionString),
    FAttrCat.AsIStream,
    IsCreateFileElevationRequired(ExtractFileDir(FFileName))
  ) as Catalog;

  if oCatalog = nil then
  begin
    Self.Terminate;
    Exit;
  end;

  oConnection := oCatalog.Get_ActiveConnection;

  i := 0;
  for o in FSrc do
  begin
    if Terminated then Break;

    FObj := o;

    // ���������� ��� ������� ��� ������ ��������
    if o.IsUser
      then sTableName := EXPORT_TABNAME_USERS
    else if o.IsGroup
      then sTableName := EXPORT_TABNAME_GROUPS
    else
      sTableName := EXPORT_TABNAME_WORKSTATIONS;

    // ��������� ������ ���������
    j := 0;
    for a in FAttrCat do
    begin
      Inc(j);
      case IndexText(a^.Name,
        [
          'lastLogon',             { 0 }
          'pwdLastSet',            { 1 }
          'badPwdCount',           { 2 }
          'groupType',             { 3 }
          'userAccountControl',    { 4 }
          'primaryGroupToken',     { 5 }
          'thumbnailPhoto'         { 6 }
        ]
      ) of
        0: if o.lastLogon > 0
             then sValue := QuotedStr(FormatDateTime('yyyy-mm-dd hh:nn:ss', o.lastLogon))
             else sValue := 'Null';
        1: if o.passwordExpiration > 0
             then sValue := QuotedStr(FormatDateTime('yyyy-mm-dd hh:nn:ss', o.passwordExpiration))
             else sValue := 'Null';
        2: sValue := QuotedStr(IntToStr(o.badPwdCount));
        3: sValue := QuotedStr(IntToStr(o.groupType));
        4: sValue := QuotedStr(IntToStr(o.userAccountControl));
        5: sValue := QuotedStr(IntToStr(o.primaryGroupToken));
        6: sValue := 'Null'
//        6: if o.thumbnailFileSize = 0 then sValue := 'Null' else
//           begin
//             TImgProcessor.ImageToByteArray(o.thumbnailPhoto, @thumbnailPhoto);
//             sValue := '0x' + thumbnailPhoto.AsBinString;  // <- �� ��������
//             SetLength(thumbnailPhoto, 0);
//           end
        else if CompareText('nearestEvent', a^.ObjProperty) <> 0
          then sValue := QuotedStr(GetPropValue(o, a^.ObjProperty, True))
          else if o.nearestEvent > 0
            then sValue := QuotedStr(FormatDateTime('yyyy-mm-dd hh:nn:ss', o.nearestEvent))
            else sValue := 'Null';
      end;

      if j = 1
        then sFieldValues := Format('%s', [sValue])
        else sFieldValues := sFieldValues + Format(',%s', [sValue]);
    end;

    // ��������� ������ � �������
    oConnection.Execute(
      Format('INSERT INTO %s VALUES (%s)', [sTableName, sFieldValues])
    );

//    // ��������� ������� �������� � ������� ������������
//    if o.IsGroup then
//    begin
//      case FAPI of
//        ADC_API_LDAP: o.GetGroupMembers(FLDAP, lstMembers);
//        ADC_API_ADSI: o.GetGroupMembers(lstMembers);
//      end;
//
//      for j := 0 to lstMembers.Count - 1 do
//      begin
//        sFieldValues := QuotedStr(o.distinguishedName) + ',' + QuotedStr(lstMembers[j].distinguishedName);
//        oConnection.Execute(
//          Format('INSERT INTO %s VALUES (%s)', ['Membership', sFieldValues])
//        );
//      end;
//    end;

    i := i + 1;
    DoProgress(Trunc(i * FSrc.Count / 100));
  end;

  oConnection.Close;
  oConnection := Null;
  oCatalog := nil;
  lstMembers.Free;
end;

procedure TADCExporter.DoDataExport_Excel;
var
  oExcelBook: Variant;
  oSheet: Variant;
  oColumns: Variant;
  oRows: Variant;
  idxObj: Integer;
  idxGrp: Integer;
  i, j: Integer;
  dataSize: Extended;
  dataSizeUnit: string;
  hr: HRESULT;
begin
  oExcelBook := CreateExcelBook(
    FOwner,
    FAttrCat.AsIStream,
    False
  );



  SaveExcelBook(
    FOwner,
    oExcelBook,
    PChar(FFileName),
    ShortInt(FFormat),
    IsCreateFileElevationRequired(ExtractFileDir(FFileName))
  );

  oExcelBook := Null;
end;

procedure TADCExporter.SyncException;
begin
  if Assigned(FExceptionProc)
    then FExceptionProc(FExceptionMsg, FExceptionCode);
end;

procedure TADCExporter.SyncProgress;
begin
  if Assigned(FProgressProc)
    then FProgressProc(FObj, FProgressValue);
end;

end.
