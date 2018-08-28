unit tdDataExport;

interface

uses
  System.Classes, System.SysUtils, System.SyncObjs, Winapi.Windows, System.Win.ComObj,
  Winapi.ActiveX, System.IOUtils, System.Variants, Data.DB, Data.Win.ADODB, ActiveDs_TLB,
  Vcl.Imaging.jpeg, ADC.Types, ADC.AD, ADC.LDAP, ADC.ADObject, ADC.ADObjectList,
  ADC.Attributes, ADC.ExcelEnum;

const
  DB_PROVIDER_JET = 'Microsoft.Jet.OLEDB.4.0';
  DB_PROVIDER_ACE120 = 'Microsoft.ACE.OLEDB.12.0';

type
  TADExportFormat = (efNone, efAccess, efAccess2007, efExcel, efExcel2007, efCommaSeparated);

type
  TADExporter = class(TThread)
  private
    FAPI: Integer;
    FLDAP: PLDAP;
    FRootDSE: IADs;
    FSrc: TADObjectList<TADObject>;
    FAttrCat: TAttrCatalog;
    FFormat: TADExportFormat;
    FFileName: TFileName;
    FSyncObject: TCriticalSection;
    FProgressProc: TProgressProc;
    FExceptionProc: TExceptionProc;

    FDBConnection: TADOConnection;
    FDBCommand: TADOCommand;
    FDBTabGroups: TADOTable;
    FDBTabObjects: TADOTable;
    FObj: TADObject;
    FProgressValue: Integer;
    FExceptionCode: ULONG;
    FExceptionMsg: string;

    procedure Clear;
    function GetValidFileName(AFileName: TFileName): TFileName;
    function DBConnectionStr: string;
    procedure CreateDataBase;
    procedure SyncProgress;
    procedure SyncException;
    procedure DoProgress(AProgress: Integer);
    procedure DoException(AMsg: string; ACode: ULONG);
    procedure ExportData_Access;
    procedure ExportData_Excel;
  protected
    procedure Execute; override;
  public
    constructor Create(ARootDSE: IADs; ASourceList: TADObjectList<TADObject>;
      AAttrCatalog: TAttrCatalog; AFormat: TADExportFormat; AFileName: TFileName;
      ASyncObject: TCriticalSection; AProgressProc: TProgressProc; AExceptionProc: TExceptionProc;
      CreateSuspended: Boolean = False); reintroduce; overload;
    constructor Create(ALDAP: PLDAP; ASourceList: TADObjectList<TADObject>;
      AAttrCatalog: TAttrCatalog; AFormat: TADExportFormat; AFileName: TFileName;
      ASyncObject: TCriticalSection; AProgressProc: TProgressProc; AExceptionProc: TExceptionProc;
      CreateSuspended: Boolean = False); reintroduce; overload;
    property OnException: TExceptionProc read FExceptionProc write FExceptionProc;
    property OnProgress: TProgressProc read FProgressProc write FProgressProc;
  end;

implementation

{ TADExporter }

constructor TADExporter.Create(ARootDSE: IADs; ASourceList: TADObjectList<TADObject>;
  AAttrCatalog: TAttrCatalog; AFormat: TADExportFormat; AFileName: TFileName;
  ASyncObject: TCriticalSection; AProgressProc: TProgressProc; AExceptionProc: TExceptionProc;
  CreateSuspended: Boolean = False);
begin
  inherited Create(CreateSuspended);

  if (ARootDSE = nil) or (ASourceList = nil)
    then Self.Terminate;

  FAPI           := ADC_API_ADSI;
  FLDAP          := nil;
  FRootDSE       := ARootDSE;
  FSrc           := ASourceList;
  FAttrCat       := AAttrCatalog;
  FFormat        := AFormat;
  FFileName      := GetValidFileName(AFileName);
  FSyncObject    := ASyncObject;
  FProgressProc  := AProgressProc;
  FExceptionProc := AExceptionProc;
end;

function TADExporter.DBConnectionStr: string;
var
  dbProvider: string;
begin
  case FFormat of
    efAccess: dbProvider := DB_PROVIDER_JET;
    efAccess2007: dbProvider := DB_PROVIDER_ACE120;
  end;

  Result := Format('Provider=%s;Data Source=%s;', [dbProvider, FFileName]);
end;

function TADExporter.GetValidFileName(AFileName: TFileName): TFileName;
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

  { ���������, ����� �� ������� ���� }
  fHandle := CreateFile(
    PChar(res),
    GENERIC_READ or GENERIC_WRITE,
    0,
    nil,
    CREATE_NEW,
    FILE_ATTRIBUTE_TEMPORARY or FILE_FLAG_DELETE_ON_CLOSE,
    0
  );

  if fHandle = INVALID_HANDLE_VALUE
    then Result := ''
    else Result := res;

  { � CreateFile ���������� ���� FILE_FLAG_DELETE_ON_CLOSE, �������  }
  { ����� ������ CloseHandle ���� ������ ������������� ���������. �� }
  { �� ������ ������ �������� DeleteFile, ����� �� �������...  ;)    }
  CloseHandle(fHandle);
  DeleteFile(PChar(res));
end;

procedure TADExporter.Clear;
begin
  FAPI           := -1;
  FLDAP          := nil;
  FRootDSE       := nil;
  FSrc           := nil;
  FAttrCat       := nil;
  FFormat        := efNone;
  FFileName      := '';
  FProgressProc  := nil;
  FExceptionProc := nil;

  CoUninitialize;

  if FDBTabGroups <> nil then
  begin
    FDBTabGroups.Close;
    FDBTabGroups.Free;
  end;

  if FDBTabObjects <> nil then
  begin
    FDBTabObjects.Close;
    FDBTabObjects.Free;
  end;

  if FDBCommand <> nil then
  begin
    FDBCommand.Free;
  end;

  if FDBConnection <> nil then
  begin
    FDBConnection.Close;
    FDBConnection.Free;
  end;

  if FSyncObject <> nil then
  begin
    FSyncObject.Leave;
    FSyncObject := nil;
  end;
end;

constructor TADExporter.Create(ALDAP: PLDAP; ASourceList: TADObjectList<TADObject>;
  AAttrCatalog: TAttrCatalog; AFormat: TADExportFormat; AFileName: TFileName;
  ASyncObject: TCriticalSection; AProgressProc: TProgressProc; AExceptionProc: TExceptionProc;
  CreateSuspended: Boolean = False);
begin
  inherited Create(CreateSuspended);

  if (ALDAP = nil) or (ASourceList = nil)
    then Self.Terminate;

  FAPI           := ADC_API_LDAP;
  FLDAP          := ALDAP;
  FRootDSE       := nil;
  FSrc           := ASourceList;
  FAttrCat       := AAttrCatalog;
  FFormat        := AFormat;
  FFileName      := GetValidFileName(AFileName);
  FSyncObject    := ASyncObject;
  FProgressProc  := AProgressProc;
  FExceptionProc := AExceptionProc;
end;

procedure TADExporter.CreateDataBase;
var
  Cat: OLEVariant;
begin
  try
    Cat := CreateOleObject('ADOX.Catalog');
    Cat.Create(DBConnectionStr);
  finally
    Cat := Null;
  end;

  FDBCommand.CommandText:=
      'CREATE TABLE OBJECTS' +
      '(' +
        '[srvCounter] COUNTER,' +
        '[userPictureJPEG] LONGBINARY,' +
        '[name] STRING (255),' +
        '[sAMAccountName] STRING (255),' +
        '[employeeID] STRING (255),' +
        '[title] STRING (255),' +
        '[telephoneNumber] STRING (255),' +
        '[lastLogonComputer] STRING (255),' +
        '[description] LONGTEXT,' +
        '[userWorkstations] LONGTEXT,' +
        '[physicalDeliveryOfficeName] STRING (255),' +
        '[department] STRING (255),' +
        '[mail] STRING (255),' +
        '[canonicalName] LONGTEXT,' +
        '[distinguishedName] LONGTEXT,' +
        '[lastLogon] DATETIME,'+
        '[pwdExpirationDate] DATETIME,' +
        '[badPwdCount] INTEGER,' +
        '[userAccountControl] INTEGER,' +
        '[objectSid] STRING (255),' +
        'PRIMARY KEY ([srvCounter])'+
      ')';
  FDBCommand.Execute;

  FDBCommand.CommandText:=
      'CREATE TABLE GROUPS' +
      '(' +
        '[srvCounter] COUNTER,' +
        '[userSID] STRING (255),' +
        '[adsPath] LONGTEXT,' +
        '[description] LONGTEXT,' +
        '[name] STRING (255),' +
        '[groupType] STRING (255),' +
        '[IsPrimary] BIT DEFAULT 0 NOT NULL,' +
        '[primaryGroupToken] NUMERIC,' +
  //      '[schema] LONGTEXT,' +
  //      '[parent] LONGTEXT,' +
  //      '[GUID] STRING (255),' +
  //      '[class] STRING (255),' +
        'PRIMARY KEY ([srvCounter])' +
      ')';
  FDBCommand.Execute;
end;

procedure TADExporter.DoException(AMsg: string; ACode: ULONG);
begin
  FExceptionCode := ACode;
  FExceptionMsg := AMsg;
  Synchronize(SyncException);
end;

procedure TADExporter.DoProgress(AProgress: Integer);
begin
  FProgressValue := AProgress;
  Synchronize(SyncProgress);
end;

procedure TADExporter.Execute;
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
    if FFileName = ''
      then raise Exception.Create('���������� ������� ����, ���� ������� �������� ��� �����.');

    case FFormat of
      efAccess..efAccess2007: begin
        FDBConnection := TADOConnection.Create(nil);
        FDBConnection.ConnectionString := DBConnectionStr;

        FDBCommand := TADOCommand.Create(nil);
        FDBCommand.Connection := FDBConnection;

        FDBTabObjects := TADOTable.Create(nil);
        FDBTabObjects.TableName := 'OBJECTS';
        FDBTabObjects.Connection := FDBConnection;

        FDBTabGroups := TADOTable.Create(nil);
        FDBTabGroups.TableName := 'GROUPS';
        FDBTabGroups.Connection := FDBConnection;

        ExportData_Access;
      end;

      efExcel..efExcel2007: begin
        ExportData_Excel;
      end;

      efCommaSeparated: begin
        ExportData_Excel;
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

procedure TADExporter.ExportData_Access;
var
  i: Integer;
  o: TADObject;
begin
  CreateDataBase;
  FDBConnection.Open;

  FDBTabObjects.Open;
  FDBTabObjects.Insert;

  FDBTabGroups.Open;
  FDBTabGroups.Insert;

  i := 0;

  for o in FSrc do
  begin
    if Terminated then Break;

    FObj := o;

    FDBTabObjects.FieldByName('name').AsString := o.name;

    FDBTabObjects.Append;

    i := i + 1;
    DoProgress(Trunc(i * FSrc.Count / 100));
  end;
end;

procedure TADExporter.ExportData_Excel;
var
  userPictureJPEG: TJPEGImage;
  userPictureStream: TMemoryStream;
  SaveAsFormat: Integer;
  ExcelApp: Variant;
  SheetObj: Variant;
  SheetGrp: Variant;
  ColSet: Variant;
  RowSet: Variant;
  idxObj: Integer;
  idxGrp: Integer;
  i, j: Integer;
  dataSize: Extended;
  dataSizeUnit: string;
  hr: HRESULT;
//  listGroups: TObjectList<TUserGroup>;
//  pUser: IADsUser;
//  objUser: TADUserData;
//  objGroup: TUserGroup;
begin
  ExcelApp := CreateOleObject('Excel.Application');

//  listGroups := TObjectList<TUserGroup>.Create;
  ExcelApp.Workbooks.Add(xlWBATWorksheet);
  ExcelApp.DisplayAlerts := False;
  ExcelApp.Calculation := xlCalculationManual;
  ExcelApp.EnableEvents := False;
  ExcelApp.ScreenUpdating := False;
  ExcelApp.ActiveWindow.SplitRow := 1;
  ExcelApp.ActiveWindow.SplitColumn := 1;
  ExcelApp.ActiveWindow.FreezePanes := True;
  ExcelApp.Workbooks[1].WorkSheets[1].Name := 'Objects';
  SheetObj := ExcelApp.Workbooks[1].Worksheets['Objects'];
  SheetObj.EnableCalculation := False;

  ColSet := SheetObj.Columns;
  {}

  RowSet := SheetObj.Rows;
  RowSet.Rows[1].Font.Bold := True;
  {}

  ExcelApp.Workbooks[1].WorkSheets.Add(
    EmptyParam,     //Before: An object that specifies the sheet before which the new sheet is added.
    SheetObj,       //After: An object that specifies the sheet after which the new sheet is added.
    1,              //Count: The number of sheets to be added. The default value is one.
    xlWorksheet     //Type: Specifies the sheet type. Can be one of the following XlSheetType constants: xlWorksheet, xlChart, xlExcel4MacroSheet, or xlExcel4IntlMacroSheet.
  );

  ExcelApp.ActiveWindow.SplitRow := 1;
  ExcelApp.ActiveWindow.FreezePanes := True;
  ExcelApp.Workbooks[1].WorkSheets[2].Name := 'Groups';
  SheetGrp := ExcelApp.Workbooks[1].Worksheets['Groups'];
  SheetGrp.EnableCalculation := False;

  ColSet := SheetGrp.Columns;
  {}

  RowSet := SheetGrp.Rows;
  RowSet.Rows[1].Font.Bold := True;
  {}








  { ��������� ����� Excel }
  SheetObj.EnableCalculation := True;
  SheetGrp.EnableCalculation := True;
  SheetObj.Activate;

  case FFormat of
    efExcel2007      : SaveAsFormat := xlWorkbookDefault;
    efExcel          : SaveAsFormat := xlExcel8;
    efCommaSeparated : SaveAsFormat := xlCSVWindows;
  end;

  ExcelApp.ActiveWorkBook.SaveAs(
    FFileName,        // Filename
    SaveAsFormat,     // FileFormat
    EmptyParam,       // Password
    EmptyParam,       // WriteResPassword
    False,            // ReadOnlyRecommended
    False,            // CreateBackup
    EmptyParam,       // AccessMode
    EmptyParam,       // ConflictResolution
    False,            // AddToMru
    EmptyParam,       // TextCodepage
    EmptyParam,       // TextVisualLayout
    EmptyParam        // Local
  );

  ExcelApp.Calculation := xlCalculationAutomatic;
  ExcelApp.EnableEvents := True;
  ExcelApp.ScreenUpdating := True;
  ExcelApp.DisplayAlerts := True;
  ExcelApp.ActiveWorkbook.RunAutoMacros(2);
  ExcelApp.ActiveWorkbook.Close(False);
  ExcelApp := Null;
//  listGroups.Free;
end;

procedure TADExporter.SyncException;
begin
  if Assigned(FExceptionProc)
    then FExceptionProc(FExceptionMsg, FExceptionCode);
end;

procedure TADExporter.SyncProgress;
begin
  if Assigned(FProgressProc)
    then FProgressProc(FObj, FProgressValue);
end;

end.
