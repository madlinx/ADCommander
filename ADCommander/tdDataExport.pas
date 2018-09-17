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
    FCancelFlag: TSimpleEvent;
    FPauseFlag: TSimpleEvent;
    FWaitList: array of THandle;

    procedure Initialize(AOwner: HWND; ASourceList: TADObjectList<TADObject>;
      AAttrCatalog: TAttrCatalog; AFormat: TADCExportFormat; AFileName: TFileName;
      ASyncObject: TCriticalSection; AProgressProc: TProgressProc; AExceptionProc: TExceptionProc);
    procedure Clear;
    function GenerateFileName(AFileName: TFileName): TFileName;
    procedure SetPaused(APaused: Boolean);
    function GetPaused: Boolean;
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
    property Paused: Boolean read GetPaused write SetPaused;
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

function TADCExporter.GetPaused: Boolean;
begin
  Result := (FPauseFlag.WaitFor(0) <> wrSignaled);
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
  FObj           := nil;
  FProgressValue := 0;
  FExceptionCode := 0;
  FExceptionMsg  := '';

  FPauseFlag := TSimpleEvent.Create;
  FPauseFlag.SetEvent;

  FCancelFlag := TSimpleEvent.Create;
  FCancelFlag.ResetEvent;

  SetLength(FWaitList, 2);
  FWaitList[0] := FPauseFlag.Handle;
  FWaitList[1] := FCancelFlag.Handle;

  case FFormat of
    efAccess:
      FDBConnectionString := Format('Provider=%s;Data Source=%s;', [DB_PROVIDER_JET, FFileName]);
    efAccess2007:
      FDBConnectionString := Format('Provider=%s;Data Source=%s;', [DB_PROVIDER_ACE120, FFileName]);
    else
      FDBConnectionString := '';
  end;

  // Экспортируем только отображаемые поля, а также не экспортируем поле,
  // содержащее изображение пользователя т.к. лень было заморачиваться.
  // Да и по предыдущему опыту (реализовывал в ADUserInfo) знаю, что
  // если экспортировать изобрежения, то это занимает очень много времени
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
  FCancelFlag.Free;
  FPauseFlag.Free;

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
    if Terminated then
    begin
      FPauseFlag.ResetEvent;
      FCancelFlag.SetEvent;
    end;

    case WaitForMultipleObjects(2, @FWaitList[0], False, INFINITE) - WAIT_OBJECT_0 of
      0: if Terminated then Break;
      1: Break;
    end;

    FObj := o;

    // Определяем имя таблицы для вывода значений
    if o.IsUser
      then sTableName := EXPORT_TABNAME_USERS
    else if o.IsGroup
      then sTableName := EXPORT_TABNAME_GROUPS
    else
      sTableName := EXPORT_TABNAME_WORKSTATIONS;

    // Формируем строку заначений
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
//             sValue := '0x' + thumbnailPhoto.AsBinString;  // <- Не работает
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

    // Вставялем запись в таблицу
    oConnection.Execute(
      Format('INSERT INTO %s VALUES (%s)', [sTableName, sFieldValues])
    );

//    // Заполняем таблицу членства в группах безопасности
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
    DoProgress(Trunc(i * 100 / FSrc.Count));
  end;

  oConnection := Unassigned;
  oCatalog := nil;
  lstMembers.Free;
end;

procedure TADCExporter.DoDataExport_Excel;
var
  oExcelBook: Variant;
  oSheet: Variant;
  oColumns: Variant;
  oRows: Variant;
  oCell: Variant;
  o: TADObject;
  a: PADAttribute;
  idxUser: Integer;
  idxGroup: Integer;
  idxWorkstation: Integer;
  iRow: PInteger;
  iColumn: Integer;
  i: Integer;
  s: string;
begin
  oExcelBook := CreateExcelBook(
    FOwner,
    FAttrCat.AsIStream,
    False
  );

  i := 0;
  idxUser := 2;
  idxGroup := 2;
  idxWorkstation := 2;

  for o in FSrc do
  begin
    if Terminated then
    begin
      FPauseFlag.ResetEvent;
      FCancelFlag.SetEvent;
    end;

    case WaitForMultipleObjects(2, @FWaitList[0], False, INFINITE) - WAIT_OBJECT_0 of
      0: if Terminated then Break;
      1: Break;
    end;

    FObj := o;

    // Определяем лист и счетчик строк для вывода значений
    if o.IsUser then
    begin
      iRow := @idxUser;
      oSheet := oExcelBook.Workbooks[1].Worksheets[EXPORT_TABNAME_USERS]
    end else
    if o.IsGroup then
    begin
       iRow := @idxGroup;
       oSheet := oExcelBook.Workbooks[1].Worksheets[EXPORT_TABNAME_GROUPS]
    end else
    begin
      iRow := @idxWorkstation;
      oSheet := oExcelBook.Workbooks[1].Worksheets[EXPORT_TABNAME_WORKSTATIONS];
    end;

    // Формируем строку заначений
    iColumn := 1;

    for a in FAttrCat do
    begin
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
             then oSheet.Cells[iRow^, iColumn] := DateTimeToStr(o.lastLogon);
        1: if o.passwordExpiration > 0
             then oSheet.Cells[iRow^, iColumn] := DateTimeToStr(o.passwordExpiration);
        2: oSheet.Cells[iRow^, iColumn] := IntToStr(o.badPwdCount);
        3: oSheet.Cells[iRow^, iColumn] := IntToStr(o.groupType);
        4: oSheet.Cells[iRow^, iColumn] := IntToStr(o.userAccountControl);
        5: oSheet.Cells[iRow^, iColumn] := IntToStr(o.primaryGroupToken);
        6: oSheet.Cells[iRow^, iColumn] := o.thumbnailFileSize.AsString;
        else if CompareText('nearestEvent', a^.ObjProperty) <> 0
          then oSheet.Cells[iRow^, iColumn] := string(GetPropValue(o, a^.ObjProperty, True))
          else if o.nearestEvent > 0
            then oSheet.Cells[iRow^, iColumn] := DateToStr(o.nearestEvent);
      end;

      s := a^.ExcelCellFormat(oExcelBook);
      Inc(iColumn);
    end;

    Inc(iRow^);
    Inc(i);
    DoProgress(Trunc(i * 100 / FSrc.Count));
  end;

  SaveExcelBook(
    FOwner,
    oExcelBook,
    PChar(FFileName),
    ShortInt(FFormat),
    IsCreateFileElevationRequired(ExtractFileDir(FFileName))
  );

  oExcelBook := Null;
end;

procedure TADCExporter.SetPaused(APaused: Boolean);
begin
  if APaused then
    FPauseFlag.ResetEvent
  else
    FPauseFlag.SetEvent;
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
