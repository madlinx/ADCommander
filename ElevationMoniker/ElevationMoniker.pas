unit ElevationMoniker;

{$WARN SYMBOL_PLATFORM OFF}

interface

uses
  Winapi.Windows, Winapi.ActiveX, System.Classes, System.Win.ComObj, ADCommander_TLB,
  System.SysUtils, System.Win.Registry, System.Variants, Vcl.AxCtrls, System.AnsiStrings,
  System.StrUtils, ADOX_TLB, ElevationMonikerFactory, MSXML2_TLB, ADC.Types, ADC.Attributes,
  ADC.ExcelEnum;

type
  TADCElevationMoniker = class(TTypedComObject, IElevationMoniker)
  private
    const KEY_WOW64: array [0..1] of DWORD = (KEY_WOW64_32KEY, KEY_WOW64_64KEY);
  private
    procedure GenerateFields(ATable: Table; const AFieldCatalog: IUnknown;
      APrimaryKeyName: string); overload;
    procedure GenerateFields(AWorksheet: IDispatch; const AFieldCatalog: IUnknown); overload;
  protected
    procedure RegisterUCMAComponents(AClassID: PWideChar); safecall;
    procedure UnregisterUCMAComponents(AClassID: PWideChar); safecall;
    procedure SaveControlEventsList(AFileName: PWideChar; const AXMLStream: IUnknown); safecall;
    procedure DeleteControlEventsList(AFileName: PWideChar); safecall;
    function CreateAccessDatabase(AConnectionString: PWideChar; const AFieldCatalog: IUnknown): IUnknown; safecall;
    function CreateExcelBook(const AFieldCatalog: IUnknown): IDispatch; safecall;
    procedure SaveExcelBook(const ABook: IDispatch; AFileName: PWideChar; AFormat: Shortint); safecall;
  public

  end;

implementation

uses System.Win.ComServ;

{ TADCElevationMoniker }

function TADCElevationMoniker.CreateAccessDatabase(AConnectionString: PWideChar;
  const AFieldCatalog: IUnknown): IUnknown;
var
  oCatalog: Catalog;
  oTable: Table;
begin
  Result := nil;
  try
    oCatalog := CoCatalog.Create;
    oCatalog.Create(string(AConnectionString));

    // Users
    oTable := CoTable.Create;;
    oTable.ParentCatalog := oCatalog;
    oTable.Name := EXPORT_TABNAME_USERS;
    GenerateFields(oTable, AFieldCatalog, 'UserID');
    oCatalog.Tables.Append(oTable);

    // Groups
    oTable := CoTable.Create;;
    oTable.ParentCatalog := oCatalog;
    oTable.Name := EXPORT_TABNAME_GROUPS;
    GenerateFields(oTable, AFieldCatalog, 'GroupID');
    oCatalog.Tables.Append(oTable);

    // Computers
    oTable := CoTable.Create;;
    oTable.ParentCatalog := oCatalog;
    oTable.Name := EXPORT_TABNAME_WORKSTATIONS;
    GenerateFields(oTable, AFieldCatalog, 'ComputerID');
    oCatalog.Tables.Append(oTable);

//    // Groups Membership
//    oTable := CoTable.Create;;
//    oTable.ParentCatalog := oCatalog;
//    oTable.Name := 'Membership';
//    oTable.Columns.Append('Group', adLongVarWChar, 0);
//    oTable.Columns.Append('Member', adLongVarWChar, 0);
//    oCatalog.Tables.Append(oTable);

    Result := oCatalog;
  finally
    oTable := nil;
  end;
end;

function TADCElevationMoniker.CreateExcelBook(const AFieldCatalog: IInterface): IDispatch;
var
  SaveAsFormat: Integer;
  oExcelBook: Variant;
  oSheet: Variant;
begin
  oExcelBook := CreateOleObject('Excel.Application');

  oExcelBook.Workbooks.Add(xlWBATWorksheet);
  oExcelBook.DisplayAlerts := False;
  oExcelBook.Calculation := xlCalculationManual;
  oExcelBook.EnableEvents := False;
  oExcelBook.ScreenUpdating := False;

  // Лист "Users"
  oExcelBook.ActiveWindow.SplitRow := 1;
//  oExcelBook.ActiveWindow.SplitColumn := 1;
  oExcelBook.ActiveWindow.FreezePanes := True;
  oExcelBook.Workbooks[1].WorkSheets[1].Name := EXPORT_TABNAME_USERS;
  oSheet := oExcelBook.Workbooks[1].Worksheets[EXPORT_TABNAME_USERS];
  GenerateFields(oSheet, AFieldCatalog);

  // Лист "Groups"
  oExcelBook.Workbooks[1].WorkSheets.Add(
    EmptyParam,     //Before: An object that specifies the sheet before which the new sheet is added.
    oSheet,         //After: An object that specifies the sheet after which the new sheet is added.
    1,              //Count: The number of sheets to be added. The default value is one.
    xlWorksheet     //Type: Specifies the sheet type. Can be one of the following XlSheetType constants: xlWorksheet, xlChart, xlExcel4MacroSheet, or xlExcel4IntlMacroSheet.
  );

  oExcelBook.ActiveWindow.SplitRow := 1;
  oExcelBook.ActiveWindow.FreezePanes := True;
  oExcelBook.Workbooks[1].WorkSheets[2].Name := EXPORT_TABNAME_GROUPS;
  oSheet := oExcelBook.Workbooks[1].Worksheets[EXPORT_TABNAME_GROUPS];
  GenerateFields(oSheet, AFieldCatalog);

  // Лист "Workstations"
  oExcelBook.Workbooks[1].WorkSheets.Add(
    EmptyParam,     //Before: An object that specifies the sheet before which the new sheet is added.
    oSheet,       //After: An object that specifies the sheet after which the new sheet is added.
    1,              //Count: The number of sheets to be added. The default value is one.
    xlWorksheet     //Type: Specifies the sheet type. Can be one of the following XlSheetType constants: xlWorksheet, xlChart, xlExcel4MacroSheet, or xlExcel4IntlMacroSheet.
  );

  oExcelBook.ActiveWindow.SplitRow := 1;
  oExcelBook.ActiveWindow.FreezePanes := True;
  oExcelBook.Workbooks[1].WorkSheets[3].Name := EXPORT_TABNAME_WORKSTATIONS;
  oSheet := oExcelBook.Workbooks[1].Worksheets[EXPORT_TABNAME_WORKSTATIONS];
  GenerateFields(oSheet, AFieldCatalog);

  Result := oExcelBook;
end;

procedure TADCElevationMoniker.DeleteControlEventsList(AFileName: PWideChar);
begin
  DeleteFileW(AFileName);
end;

procedure TADCElevationMoniker.GenerateFields(AWorksheet: IDispatch;
  const AFieldCatalog: IInterface);
var
  oSheet: Variant;
  oRows: Variant;
  oColumns: Variant;
  i: Integer;
  AttrCatalog: TAttrCatalog;
  OleStream: TOleStream;
  a: TADAttribute;
begin
  oSheet := AWorksheet;
  oSheet.EnableCalculation := False;

  oRows := oSheet.Rows;
  oRows.Rows[1].Font.Bold := True;
  oColumns := oSheet.Columns;

  OleStream := TOLEStream.Create((AFieldCatalog as IStream));
  AttrCatalog := TAttrCatalog.Create;
  AttrCatalog.LoadFromStream(OleStream);
  try
    for i := 0 to AttrCatalog.Count - 1 do
    begin
      a := AttrCatalog[i]^;
      oColumns.Columns[i + 1].ColumnWidth := a.ExcelColumnWidth;
      oColumns.Columns[i + 1].HorizontalAlignment := a.ExcelColumnAlignment;
      oColumns.Columns[i + 1].NumberFormat := a.ExcelCellFormat(oSheet.Application);
      oSheet.Cells[1, i + 1] := a.FieldName;
    end;
  finally
    OleStream.Free;
    AttrCatalog.Free;
  end;
end;

procedure TADCElevationMoniker.GenerateFields(ATable: Table;
  const AFieldCatalog: IInterface; APrimaryKeyName: string);
var
  i: Integer;
  k: Integer;
  s: string;
  FieldExists: Boolean;
  FieldName: string;
  FieldSize: Integer;
  oIndex: Index;
  AttrCatalog: TAttrCatalog;
  OleStream: TOleStream;
  a: PADAttribute;
begin
  OleStream := TOLEStream.Create((AFieldCatalog as IStream));
  AttrCatalog := TAttrCatalog.Create();
  AttrCatalog.LoadFromStream(OleStream);
  try
//    ATable.Columns.Append(APrimaryKeyName, adInteger, 0);
//    ATable.Columns[APrimaryKeyName].Properties['AutoIncrement'].Value := True;
//
//    oIndex := CoIndex.Create;
//    oIndex.Name := 'ObjectID';
//    oIndex.Unique := True;
//    oIndex.PrimaryKey := True;
//    oIndex.Columns.Append(APrimaryKeyName, adInteger, 0);
//
//    ATable.Indexes.Append(oIndex, Null);

    for a in AttrCatalog do
    begin
      // Формируем имя поля
      s := a^.FieldName;
      FieldName := s;

      // Ищем дубликаты и, если находим, добавляем к имени порядковый номер
      k := 1;
      while True do
      begin
        FieldExists := False;
        for i := 0 to ATable.Columns.Count - 1 do
        if CompareText(ATable.Columns[i].Name, FieldName) = 0 then
        begin
          Inc(k);
          FieldExists := True;
          FieldName := Format('%s (%d)', [s, k]);
          Break;
        end;

        if not FieldExists then Break;
      end;

      //Добавляем поле в таблицу
      case a^.ADODataType of
        adLongVarWChar: FieldSize := 255;
        else FieldSize := 0;
      end;

      ATable.Columns.Append(FieldName, a^.ADODataType, FieldSize);
      ATable.Columns[FieldName].Properties['Nullable'].Value := True;
    end;
  finally
    oIndex := nil;
    OleStream.Free;
    AttrCatalog.Free;
  end;
end;

procedure TADCElevationMoniker.RegisterUCMAComponents(AClassID: PWideChar);
const
  ProgID = 'ADCommander.UCMA';
  ClassName = 'ADCommander.UCMA.UCMAContact';
var
  Reg: TRegistry;
  Res: Boolean;
  Key: DWORD;
begin
  Reg := TRegistry.Create();
  Reg.RootKey := HKEY_CLASSES_ROOT;

  for Key in KEY_WOW64 do
  begin
    Reg.Access := KEY_WRITE or Key;

    { [HKEY_CLASSES_ROOT\ADCommander.UCMA] }
    Res := Reg.OpenKey(ProgID, True);
    if Res then
    begin
      Reg.WriteString('', ClassName);
    end;
    Reg.CloseKey;

    { [HKEY_CLASSES_ROOT\ADCommander.UCMA\CLSID] }
    Res := Reg.OpenKey(ProgID + '\CLSID', True);
    if Res then
    begin
      Reg.WriteString('', AClassID);
    end;
    Reg.CloseKey;

    { [HKEY_CLASSES_ROOT\CLSID\%ClassID%] }
    Res := Reg.OpenKey('CLSID\' + AClassID, True);
    if Res then
    begin
      Reg.WriteString('', ClassName);
    end;
    Reg.CloseKey;

    { [HKEY_CLASSES_ROOT\CLSID\%ClassID%\InprocServer32] }
    Res := Reg.OpenKey('CLSID\' + AClassID + '\InprocServer32', True);
    if Res then
    begin
      Reg.WriteString('', 'mscoree.dll');
      Reg.WriteString('ThreadingModel', 'Both');
      Reg.WriteString('Class', ClassName);
      Reg.WriteString('Assembly', 'adcmd.ucma, Version=1.0.0.0, Culture=neutral, PublicKeyToken=null');
      Reg.WriteString('RuntimeVersion', 'v2.0.50727');
    end;
    Reg.CloseKey;

    { [HKEY_CLASSES_ROOT\CLSID\%ClassID%\InprocServer32\1.0.0.0] }
    Res := Reg.OpenKey('CLSID\' + AClassID + '\InprocServer32\1.2.0.0', True);
    if Res then
    begin
      Reg.WriteString('Class', ClassName);
      Reg.WriteString('Assembly', 'adcmd.ucma, Version=1.0.0.0, Culture=neutral, PublicKeyToken=null');
      Reg.WriteString('RuntimeVersion', 'v2.0.50727');
    end;
    Reg.CloseKey;

    { [HKEY_CLASSES_ROOT\CLSID\%ClassID%\ProgId] }
    Res := Reg.OpenKey('CLSID\' + AClassID + '\ProgId', True);
    if Res then
    begin
      Reg.WriteString('', ProgId);
    end;
    Reg.CloseKey;

    Res := Reg.OpenKey('CLSID\' + AClassID + '\Implemented Categories\{62C8FE65-4EBB-45E7-B440-6E39B2CDBF29}', True);
    Reg.CloseKey;
  end;
  Reg.Free;
end;

procedure TADCElevationMoniker.SaveControlEventsList(AFileName: PWideChar; const AXMLStream: IInterface);
var
  xmlDoc: IXMLDOMDocument;
begin
  xmlDoc := CoDOMDocument60.Create;
  try
    xmlDoc.async := False;
    xmlDoc.load(AXMLStream as IStream);
    if xmlDoc.parseError.errorCode = 0
      then xmlDoc.save(string(AFileName));
  except

  end;
  xmlDoc := nil;
end;

procedure TADCElevationMoniker.SaveExcelBook(const ABook: IDispatch;
  AFileName: PWideChar; AFormat: Shortint);
var
  SaveAsFormat: Integer;
  ExcelApp: Variant;
  i: Integer;
begin
  ExcelApp := ABook;

  for i := 1 to ExcelApp.WorkBooks[1].Worksheets.Count do
    ExcelApp.WorkBooks[1].Worksheets[i].EnableCalculation := True;

  ExcelApp.WorkBooks[1].Worksheets[1].Activate;

  case TADCExportFormat(AFormat) of
    efExcel2007      : SaveAsFormat := xlWorkbookDefault;
    efExcel          : SaveAsFormat := xlExcel8;
    efCommaSeparated : SaveAsFormat := xlCSVWindows;
    else               SaveAsFormat := xlExcel8;
  end;

  ExcelApp.ActiveWorkBook.SaveAs(
    string(AFileName),  // Filename
    SaveAsFormat,       // FileFormat
    EmptyParam,         // Password
    EmptyParam,         // WriteResPassword
    False,              // ReadOnlyRecommended
    False,              // CreateBackup
    EmptyParam,         // AccessMode
    EmptyParam,         // ConflictResolution
    False,              // AddToMru
    EmptyParam,         // TextCodepage
    EmptyParam,         // TextVisualLayout
    EmptyParam          // Local
  );

  ExcelApp.Calculation := xlCalculationAutomatic;
  ExcelApp.EnableEvents := True;
  ExcelApp.ScreenUpdating := True;
  ExcelApp.DisplayAlerts := True;
  ExcelApp.ActiveWorkbook.RunAutoMacros(2);
  ExcelApp.ActiveWorkbook.Close(False);
end;

procedure TADCElevationMoniker.UnregisterUCMAComponents(AClassID: PWideChar);
const
  ProgID = 'ADCommander.UCMA';
var
  Reg: TRegistry;
  Res: Boolean;
  Key: DWORD;
begin
  Reg := TRegistry.Create();
  Reg.RootKey := HKEY_CLASSES_ROOT;

  for Key in KEY_WOW64 do
  begin
    Reg.Access := KEY_WRITE or Key;
    Res := Reg.DeleteKey(ProgID + '\CLSID');
    Res := Reg.DeleteKey(ProgID);
    Res := Reg.DeleteKey('CLSID\' + AClassID + '\Implemented Categories\{62C8FE65-4EBB-45E7-B440-6E39B2CDBF29}');
    Res := Reg.DeleteKey('CLSID\' + AClassID + '\Implemented Categories');
    Res := Reg.DeleteKey('CLSID\' + AClassID + '\ProgId');
    Res := Reg.DeleteKey('CLSID\' + AClassID + '\InprocServer32\1.2.0.0');
    Res := Reg.DeleteKey('CLSID\' + AClassID + '\InprocServer32');
    Res := Reg.DeleteKey('CLSID\' + AClassID);
    Reg.CloseKey;
  end;
  Reg.Free;
end;

initialization
  TElevationMonikerFactory.Create(
    '101', // resource string id
    '102', // resource icon id
    ComServer,
    TADCElevationMoniker,
    CLASS_ElevationMoniker,
    ciMultiInstance,
    tmApartment
  );
end.
