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
  TADCExportFormat = (
    efNone,
    efAccess,
    efAccess2007,
    efExcel,
    efExcel2007,
    efCommaSeparated
  );

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

    procedure Clear;
    function GenerateFileName(AFileName: TFileName): TFileName;
//    procedure CreateAccessDataBase;
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

  FOwner         := AOwner;
  FAPI           := ADC_API_ADSI;
  FLDAP          := nil;
  FRootDSE       := ARootDSE;
  FSrc           := ASourceList;
  FAttrCat       := AAttrCatalog;
  FFormat        := AFormat;
  FFileName      := GenerateFileName(AFileName);
  FSyncObject    := ASyncObject;
  FProgressProc  := AProgressProc;
  FExceptionProc := AExceptionProc;

  FDBConnectionString := '';
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

//  { Проверяем, можно ли создать файл }
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
//  { В CreateFile используем флаг FILE_FLAG_DELETE_ON_CLOSE, поэтому  }
//  { после вызова CloseHandle файл должен автоматически удалиться. Но }
//  { на всякий случай вызываем DeleteFile, чтобы на верняка...  ;)    }
//  CloseHandle(fHandle);
//  DeleteFile(PChar(res));
end;

procedure TADCExporter.Clear;
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

  FOwner         := AOwner;
  FAPI           := ADC_API_LDAP;
  FLDAP          := ALDAP;
  FRootDSE       := nil;
  FSrc           := ASourceList;
  FAttrCat       := AAttrCatalog;
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
begin
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

    // Определяем имя таблицы для вывода значений
    if o.IsUser
      then sTableName := 'Users'
    else if o.IsGroup
      then sTableName := 'Groups'
    else sTableName := 'Computers';

    // Формируем строку заначений
    j := 0;
    for a in FAttrCat do
    begin
      if not a^.Visible then Continue;
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
//             sValue := '0x' + thumbnailPhoto.AsBinString;
//             SetLength(thumbnailPhoto, 0);
//           end
        else sValue := QuotedStr(GetPropValue(o, a^.ObjProperty, True));
      end;



      if j = 1
        then sFieldValues := Format('%s', [sValue])
        else sFieldValues := sFieldValues + Format(',%s', [sValue]);
    end;

    // Вставялем запись в таблицу
    oConnection.Execute(
      Format('INSERT INTO %s VALUES (%s)', [sTableName, sFieldValues])
    );

    i := i + 1;
    DoProgress(Trunc(i * FSrc.Count / 100));
  end;

  oConnection.Close;
  oConnection := Null;
  oCatalog := nil;
end;

procedure TADCExporter.DoDataExport_Excel;
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








  { Сохраняем книгу Excel }
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
