unit ElevationMoniker;

{$WARN SYMBOL_PLATFORM OFF}

interface

uses
  Winapi.Windows, Winapi.ActiveX, System.Classes, System.Win.ComObj, ADCommander_TLB,
  System.SysUtils, System.Win.Registry, System.Variants, Vcl.AxCtrls, System.AnsiStrings,
  System.StrUtils, ADOX_TLB, ElevationMonikerFactory, MSXML2_TLB, ADC.Types, ADC.Attributes;

type
  TADCElevationMoniker = class(TTypedComObject, IElevationMoniker)
  private
    const KEY_WOW64: array [0..1] of DWORD = (KEY_WOW64_32KEY, KEY_WOW64_64KEY);
  private
    procedure GenerateFields(ATable: Table; const AFieldCatalog: IUnknown;
      APrimaryKeyName: string); overload;
  protected
    procedure RegisterUCMAComponents(AClassID: PWideChar); safecall;
    procedure UnregisterUCMAComponents(AClassID: PWideChar); safecall;
    procedure SaveControlEventsList(AFileName: PWideChar; const AXMLStream: IUnknown); safecall;
    procedure DeleteControlEventsList(AFileName: PWideChar); safecall;
    function CreateAccessDatabase(AConnectionString: PWideChar;
      const AFieldCatalog: IUnknown): IUnknown; safecall;
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
    oTable.Name := 'Users';
    GenerateFields(oTable, AFieldCatalog, 'UserID');
    oCatalog.Tables.Append(oTable);

    // Groups
    oTable := CoTable.Create;;
    oTable.ParentCatalog := oCatalog;
    oTable.Name := 'Groups';
    GenerateFields(oTable, AFieldCatalog, 'GroupID');
    oCatalog.Tables.Append(oTable);

    // Computers
    oTable := CoTable.Create;;
    oTable.ParentCatalog := oCatalog;
    oTable.Name := 'Computers';
    GenerateFields(oTable, AFieldCatalog, 'ComputerID');
    oCatalog.Tables.Append(oTable);

    Result := oCatalog;
  finally
    oTable := nil;
  end;
end;

procedure TADCElevationMoniker.DeleteControlEventsList(AFileName: PWideChar);
begin
  DeleteFileW(AFileName);
end;

procedure TADCElevationMoniker.GenerateFields(ATable: Table;
  const AFieldCatalog: IInterface; APrimaryKeyName: string);
var
  i: Integer;
  k: Integer;
  s: string;
  FieldExists: Boolean;
  FieldName: string;
  oColumn: OLEVariant;
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
      if not a^.Visible
        then Continue;

      // Формируем имя поля
      s := IfThen(a^.Name = '', a^.Title, a^.Name);
      if s = '' then
      begin
        Inc(i);
        s := 'UnknownField';
      end;

      FieldName := s;

      // Ищем дубликаты и, если находим, то добавляем к имени порядковый номер
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

      // Добавляем поле в таблицу
      case IndexText(s,
        [
          'lastLogon',             { 0 }
          'pwdLastSet',            { 1 }
          'badPwdCount',           { 2 }
          'groupType',             { 3 }
          'userAccountControl',    { 4 }
          'primaryGroupToken',     { 5 }
          'thumbnailPhoto',        { 6 }
          'description'            { 7 }
        ]
      ) of
        0..1: ATable.Columns.Append(FieldName, adDate, 0);
        2..5: ATable.Columns.Append(FieldName, adInteger, 0);
        6: ATable.Columns.Append(FieldName, adLongVarBinary, 0);
        7: ATable.Columns.Append(FieldName, adLongVarWChar, 0);
        else ATable.Columns.Append(FieldName, adVarWChar, 255);
      end;

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
