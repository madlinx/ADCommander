unit ADC.Types;

interface

uses
  Winapi.Windows, System.Classes, System.Generics.Collections, System.Generics.Defaults,
  System.SysUtils, System.DateUtils, Winapi.Messages, Vcl.Controls, Vcl.Graphics,
  System.RegularExpressions, System.StrUtils, System.AnsiStrings, Winapi.ActiveX,
  MSXML2_TLB, ActiveDs_TLB, ADOX_TLB, ADC.ExcelEnum;

const
  { Название приложения }
  APP_TITLE = 'AD Commander';
  APP_TITLE_JOKE = 'Zhigadlo AD Commander';

  ADC_SEARCH_PAGESIZE = 1000;

  { Имена таблиц для экспорта }
  EXPORT_TABNAME_USERS        = 'Users';
  EXPORT_TABNAME_GROUPS       = 'Groups';
  EXPORT_TABNAME_WORKSTATIONS = 'Workstations';

  { Разделы ini файла }
  INI_SECTION_GENERAL    = 'GENERAL';
  INI_SECTION_ATTRIBUTES = 'ATTRIBUTES';
  INI_SECTION_EVENTS     = 'EVENTS';
  INI_SECTION_EDITOR     = 'EDITOR';
  INI_SECTION_FLOATING   = 'FLOATING_WINDOW';
  INI_SECTION_MOUSE      = 'MOUSE';
  INI_SECTION_STATE      = 'STATE';
  INI_SECTION_DMRC       = 'DAMEWARE';
  INI_SECTION_PSEXEC     = 'PSEXEC';

  { Тип подключения DameWare }
  DMRC_CONNECTION_MRC = 0;
  DMRC_CONNECTION_RDP = 1;

  { Тип авторизации DameWare }
  DMRC_AUTH_PROPRIETARY = 0;
  DMRC_AUTH_WINNT       = 1;
  DMRC_AUTH_WINLOGON    = 2;
  DMRC_AUTH_SMARTCARD   = 3;
  DMRC_AUTH_CURRENTUSER = 4;

  { Используемый API }
  ADC_API_LDAP = 0;
  ADC_API_ADSI = 1;

  { Опции левой клавиши мыши }
  MOUSE_LMB_OPTION1 = 1;
  MOUSE_LMB_OPTION2 = 2;

  { Опции фильтра записей }
  FILTER_BY_ANY          = 0;
  FILTER_BY_NAME         = 1;

  { Типы аттрибутов AD }
  ATTR_TYPE_ANY                    = '_any_';
  ATTR_TYPE_UNDEFINED              = 'Undefined';
  ATTR_TYPE_DN_STRING              = 'DN';
  ATTR_TYPE_OID                    = 'OID';
  ATTR_TYPE_CASE_EXACT_STRING      = 'CaseExactString';
  ATTR_TYPE_CASE_IGNORE_STRING     = 'CaseIgnoreString';
  ATTR_TYPE_PRINTABLE_STRING       = 'PrintableString';
  ATTR_TYPE_NUMERIC_STRING         = 'NumericString';
  ATTR_TYPE_DN_WITH_BINARY         = 'DNWithBinary';
  ATTR_TYPE_BOOLEAN                = 'Boolean';
  ATTR_TYPE_INTEGER                = 'INTEGER';
  ATTR_TYPE_OCTET_STRING           = 'OctetString';
  ATTR_TYPE_UTC_TIME               = 'GeneralizedTime';
  ATTR_TYPE_DIRECTORY_STRING       = 'DirectoryString';
  ATTR_TYPE_PRESENTATION_ADDRESS   = 'PresentationAddress';
  ATTR_TYPE_DN_WITH_STRING         = 'DNWithString';
  ATTR_TYPE_NT_SECURITY_DESCRIPTOR = 'ObjectSecurityDescriptor';
  ATTR_TYPE_LARGE_INTEGER          = 'INTEGER8';
  ATTR_TYPE_SID_STRING             = 'OctetString';

  { Контрольные события }
  CTRL_EVENT_STORAGE_DISK = 0;
  CTRL_EVENT_STORAGE_AD   = 1;

  { Режим редактирования }
  ADC_EDIT_MODE_CREATE = 0;
  ADC_EDIT_MODE_CHANGE = 1;
  ADC_EDIT_MODE_DELETE = 2;

  { Парметры изображения пользователя }
  USER_IMAGE_EMPTY      = 0;
  USER_IMAGE_ASSIGNED   = 1;
  USER_IMAGE_MAX_WIDTH  = 96;
  USER_IMAGE_MAX_HEIGHT = 96;

  COLOR_SELBORDER: TColorRef = $00B16300; //RGB(0, 99, 177);
  COLOR_GRAY_TEXT: TColorRef = $333333;

  { При запуске нескольких копий приложения }
  EXEC_NEW_INSTANCE  = 1;
  EXEC_PROMPT_ACTION = 2;

  { Категория контейнера AD }
  AD_CONTCAT_CONTAINER = 1;
  AD_CONTCAT_ORGUNIT   = 2;

  { Объекты фильтра }
  FILTER_OBJECT_USER        = 1;  // 1 shl 0
  FILTER_OBJECT_GROUP       = 2;  // 1 shl 1
  FILTER_OBJECT_WORKSTATION = 4;  // 1 shl 2
  FILTER_OBJECT_DC          = 8;  // 1 shl 3

  { Текстовые константы }
  TEXT_NO_DATA = '<нет данных>';
  TEXT_FILE_NOT_FOUND = 'Файл не найден';

{$ALIGN 8}

type
  TFloatingWindowStyle = (fwsLync, fwsSkype);

type
  TAdsValueArray = array[0..ANYSIZE_ARRAY-1] of ADSVALUE;
  PAdsValueArray = ^TAdsValueArray;

type
  TIPAddr = record
    FQDN : string;
    v4   : string;
    v6   : string;
  end;
  PIPAddr = ^TIPAddr;

  TDHCPInfo = record
    ServerNetBIOSName: string;
    ServerName: string;
    ServerAddress: string;
    HardwareAddress: string;
    IPAddress: TIPAddr;
    SubnetMask: string;
    LeaseExpires: TDateTime;
  end;
  PDHCPInfo = ^TDHCPInfo;

type
  PImgByteArray = ^TImgByteArray;
  TImgByteArray = array of Byte;

  TImgByteArrayHelper = record helper for TImgByteArray
    function AsBinString: string;
    function AsBinAnsiString: AnsiString;
  end;

type
  PXMLByteArray = ^TXMLByteArray;
  TXMLByteArray = array of Byte;

  TXMLByteArrayHelper = record helper for TXMLByteArray
    function AsBinString: string;
    function AsBinAnsiString: AnsiString;
  end;

type
  PADContainer = ^TADContainer;
  TADContainer = record
    name: string;
    systemFlags: Integer;
    allowedChildClasses: string;
    Category: Byte;
    DistinguishedName: string;
    CanonicalName: string;
    Path: string;
    procedure Clear;
  end;

  TOrganizationalUnitHelper = record helper for TADContainer
    function ExtractName: string;
    function CanBeDeleted: Boolean;
    function CanContainClass(AClass: string): Boolean;
  end;

type
  PADAttribute = ^TADAttribute;
  TADAttribute = packed record
    ID: Byte;
    Name: string[255];           { Имя атрибута Active Directory  }
    ObjProperty: string[255];    { Имя поля объекта TADObject     }
    Title: string[255];          { Текстовое описание атрибута    }
    Comment: string[255];        { Краткий комментарий к атрибуту }
    Visible: Boolean;            { Отображать столбец в списке    }
    Width: Word;                 { Ширина столбца в списке        }
    Alignment: TAlignment;       { Выравнивание при отображении   }
    BgColor: TColor;             { Цвет фона                      }
    FontColor: TColor;           { Цвет шрифта                    }
    ReadOnly: Boolean;           { Только для чтения              }
  end;

  TADAttributeHelper = record helper for TADAttribute
    function IsExportRequired: Boolean;
    function IsNotExported: Boolean;
    function FieldName: string;
    function ADODataType: DWORD;
    function ExcelColumnWidth: Integer;
    function ExcelColumnAlignment: Integer;
    function ExcelCellFormat(AExcel: Variant): string;
  end;

type
  PADGroupMember = ^TADGroupMember;
  TADGroupMember = record
    Selected: Boolean;
    SortKey: Integer;
    name: string;
    sAMAccountName: string;
    distinguishedName: string;
    primaryGroupID: Integer;
  end;

  TADGroupMemberList = class(TList)
  private
    FOwnsObjects: Boolean;
    function Get(Index: Integer): PADGroupMember;
  public
    constructor Create(AOwnsObjects: Boolean = True); reintroduce;
    destructor Destroy; override;
    function Add(Value: PADGroupMember): Integer;
    procedure Clear; override;
    procedure SetSelected(AIndex: Integer; ASelected: Boolean);
    function SelCount: Integer;
    function ContainsGroups: Boolean;
    function ContainsMember(AMemberDN: string): Boolean;
    property Items[Index: Integer]: PADGroupMember read Get; default;
    property OwnsObjects: Boolean read FOwnsObjects write FOwnsObjects;
  end;

type
  PADGroup = ^TADGroup;
  TADGroup = record
    ImageIndex: Integer;
    Selected: Boolean;
    IsMember: Boolean;
    IsPrimary: Boolean;
    distinguishedName: string;
    name: string;
    description: string;
    primaryGroupToken: Integer;
    groupType: Integer;
  end;

  TADGroupList = class(TList)
  protected
    procedure Notify(Ptr: Pointer; Action: TListNotification); override;
  private
    FOwnsObjects: Boolean;
    function Get(Index: Integer): PADGroup;
    function GetPrimaryGroupName: string;
    function GetPrimaryGroupIndex: integer;
  public
    constructor Create(AOwnsObjects: Boolean = True); reintroduce;
    destructor Destroy; override;
    function Add(Value: PADGroup): Integer;
    procedure Clear; override;
    function GetPrimaryGroup: PADGroup;
    procedure SetGroupAsPrimary(AToken: Integer);
    procedure SetSelected(AIndex: Integer; ASelected: Boolean);
    function IndexOf(AToken: Integer): Integer; overload;
    property OwnsObjects: Boolean read FOwnsObjects write FOwnsObjects;
    property Items[Index: Integer]: PADGroup read Get; default;
    property PrimaryGroupName: string read GetPrimaryGroupName;
    property PrimaryGroupIndex: integer read GetPrimaryGroupIndex;
  end;

type
  PADEvent = ^TADEvent;
  TADEvent = record
    ID: Integer;
    Date: TDate;
    Description: string;
    procedure Clear;
  end;

  TADEventList = class(TList)
  private
    FOwnsObjects: Boolean;
    procedure Notify(Ptr: Pointer; Action: TListNotification); override;
    function GenerateItemID: Integer;
    function Get(Index: Integer): PADEvent;
  public
    constructor Create(AOwnsObjects: Boolean = True); reintroduce;
    destructor Destroy; override;
    function Add(Value: PADEvent): Integer;
    procedure Clear; override;
    function GetNearestEvent: TDate;
    function GetEventByID(AID: Integer): PADEvent;
    property Items[Index: Integer]: PADEvent read Get; default;
    property OwnsObjects: Boolean read FOwnsObjects write FOwnsObjects;
  end;

type
  TProgressProc = procedure (AItem: TObject; AProgress: Integer) of object;
  TExceptionProc = procedure (AMsg: string; ACode: ULONG) of object;
  TSelectContainerProc = procedure (Sender: TObject; ACont: TADContainer) of object;
  TCreateUserProc = procedure (Sender: TObject; AOpenEditor: Boolean) of object;
  TChangeComputerProc = procedure (Sender: TObject) of object;
  TChangeUserProc = procedure (Sender: TObject) of object;
  TPwdChangeProc = procedure (Sender: TObject; AChangeOnLogon: Boolean) of object;
  TSelectGroupProc = procedure (Sender: TObject; AGroupList: TADGroupList) of object;
  TSelectGroupMemberProc = procedure (Sender: TObject; AMemberList: TADGroupMemberList) of object;
  TApplyWorkstationsProc = procedure (Sender: TObject; AWorkstations: string) of object;
  TChangeEventProc = procedure (Sender: TObject; AMode: Byte; AEvent: TADEvent) of object;
  TCreateOrganizationalUnitProc = procedure (ANewDN: string) of object;

  TQueryFullProcessImageName = function (Process: THandle; Flags: DWORD;
    Buffer: LPTSTR; Size: PDWORD): DWORD; stdcall;

function GetUserNameEx(NameFormat: DWORD; lpNameBuffer: LPSTR; var nSize: DWORD): Boolean; stdcall;

implementation

function GetUserNameEx; external 'secur32.dll' name 'GetUserNameExA';

{ TADGroupMemberList }

function TADGroupMemberList.Add(Value: PADGroupMember): Integer;
begin
  Result := inherited Add(Value);
end;

procedure TADGroupMemberList.Clear;
var
  i: Integer;
begin
  if FOwnsObjects
    then for i := Self.Count - 1 downto 0 do
      Dispose(Self.Items[i]);

  inherited Clear;
end;

function TADGroupMemberList.ContainsGroups: Boolean;
var
  i: Integer;
begin
  Result := False;

  for i := 0 to Self.Count - 1 do
  if Self.Items[i]^.SortKey = 1 then
  begin
    Result := True;
    Break;
  end;
end;

function TADGroupMemberList.ContainsMember(AMemberDN: string): Boolean;
var
  i: Integer;
begin
  Result := False;

  for i := 0 to Self.Count - 1 do
  if CompareText(Self.Items[i]^.distinguishedName, AMemberDN) = 0 then
  begin
    Result := True;
    Break;
  end;
end;

constructor TADGroupMemberList.Create(AOwnsObjects: Boolean);
begin
  inherited Create;

  FOwnsObjects := AOwnsObjects;
end;

destructor TADGroupMemberList.Destroy;
begin
  Clear;
  inherited;
end;

function TADGroupMemberList.Get(Index: Integer): PADGroupMember;
begin
  Result := PADGroupMember(inherited Get(Index));
end;

function TADGroupMemberList.SelCount: Integer;
var
  i: Integer;
  res: Integer;
begin
  res := 0;

  for i := 0 to Self.Count - 1 do
    if Self.Items[i]^.Selected
      then Inc(res);

  Result := res;
end;

procedure TADGroupMemberList.SetSelected(AIndex: Integer; ASelected: Boolean);
begin
  try
    Self.Items[AIndex]^.Selected := ASelected;
  except

  end;
end;

{ TOrganizationalUnit }

procedure TADContainer.Clear;
begin
  Category := 0;
  name := '';
  systemFlags := 0;
  DistinguishedName := '';
  CanonicalName := '';
  Path := '';
end;

{ TImgByteArrayHelper }

function TImgByteArrayHelper.AsBinAnsiString: AnsiString;
begin
  SetString(Result, PAnsiChar(@Self[0]), Length(Self));
end;

function TImgByteArrayHelper.AsBinString: string;
begin
  SetString(Result, PWideChar(@Self[0]), Length(Self) div 2);
end;

{ TXMLByteArrayHelper }

function TXMLByteArrayHelper.AsBinAnsiString: AnsiString;
begin
  SetString(Result, PAnsiChar(@Self[0]), Length(Self));
end;

function TXMLByteArrayHelper.AsBinString: string;
begin
  SetString(Result, PWideChar(@Self[0]), Length(Self) div 2);
end;

{ TADGroupList }

function TADGroupList.Add(Value: PADGroup): Integer;
begin
  Result := inherited Add(Value);
end;

procedure TADGroupList.Clear;
var
  i: Integer;
begin
  if FOwnsObjects
    then for i := Self.Count - 1 downto 0 do
      Dispose(Self.Items[i]);

  inherited Clear;
end;

constructor TADGroupList.Create(AOwnsObjects: Boolean = True);
begin
  inherited Create;

  FOwnsObjects := AOwnsObjects;
end;

destructor TADGroupList.Destroy;
begin

  inherited Destroy;
end;

function TADGroupList.Get(Index: Integer): PADGroup;
begin
  Result := PADGroup(inherited Get(Index));
end;

function TADGroupList.GetPrimaryGroup: PADGroup;
var
  i: Integer;
begin
  i := Self.PrimaryGroupIndex;
  if i > -1
    then Result := Self[i]
    else Result := nil;
end;

function TADGroupList.GetPrimaryGroupIndex: integer;
var
  g: PADGroup;
begin
  Result := -1;

  for g in Self do
  if g^.IsPrimary then
  begin
    Result := Self.IndexOf(g);
    Break;
  end;
end;

function TADGroupList.GetPrimaryGroupName: string;
var
  g: PADGroup;
begin
  Result := '';

  for g in Self do
  if g^.IsPrimary then
  begin
    Result := g^.name;
    Break;
  end;
end;

function TADGroupList.IndexOf(AToken: Integer): Integer;
var
  g: PADGroup;
begin
  Result := -1;

  for g in Self do
  if g^.primaryGroupToken = AToken then
  begin
    Result := IndexOf(g);
    Break;
  end;
end;

procedure TADGroupList.Notify(Ptr: Pointer; Action: TListNotification);
begin
  case Action of
    lnAdded: ;
    lnExtracted: ;
    lnDeleted: ;
  end;

  inherited;
end;

procedure TADGroupList.SetGroupAsPrimary(AToken: Integer);
var
  g: PADGroup;
begin
  for g in Self do
    g^.IsPrimary := g^.primaryGroupToken = AToken;
end;

procedure TADGroupList.SetSelected(AIndex: Integer; ASelected: Boolean);
begin
  try
    Self.Items[AIndex]^.Selected := ASelected;
  except

  end;
end;

{ TADEventList }

function TADEventList.Add(Value: PADEvent): Integer;
begin
  Result := inherited Add(Value);
end;

procedure TADEventList.Clear;
var
  i: Integer;
begin
  for i := Self.Count - 1 downto 0 do
    Self.Delete(i);

  inherited Clear;
end;

constructor TADEventList.Create(AOwnsObjects: Boolean);
begin
  inherited Create;

  FOwnsObjects := AOwnsObjects;
end;

destructor TADEventList.Destroy;
begin

  inherited;
end;

function TADEventList.GenerateItemID: Integer;
var
  id: Integer;
begin
  id := 0;

  repeat
    id := id + 1;
  until (Self.GetEventByID(id) = nil) or (id > Self.Count);

  Result := id;
end;

function TADEventList.Get(Index: Integer): PADEvent;
begin
  Result := PADEvent(inherited Get(Index));
end;

function TADEventList.GetEventByID(AID: Integer): PADEvent;
var
  e: PADEvent;
begin
  Result := nil;

  for e in Self do
  begin
    if e^.ID = AID then
    begin
      Result := e;
      Break;
    end;
  end;
end;

function TADEventList.GetNearestEvent: TDate;
var
  e: PADEvent;
  res: TDate;
begin
  if Self.Count > 0
    then res := Self[0]^.Date
    else res := 0;

  for e in Self do
    if CompareDate(e^.Date, res) < 0
      then res := e^.Date;

  Result := res;
end;

procedure TADEventList.Notify(Ptr: Pointer; Action: TListNotification);
begin
  inherited;

  case Action of
    lnAdded: begin
      PADEvent(Ptr)^.ID := Self.GenerateItemID;
    end;

    lnExtracted: begin
      PADEvent(Ptr)^.ID := 0;
    end;

    lnDeleted: begin
      if FOwnsObjects
        then Dispose(PADEvent(Ptr))
    end;
  end;
end;

{ TADEvent }

procedure TADEvent.Clear;
begin
  ID := 0;
  Date := 0;
  Description := '';
end;

{ TOrganizationalUnitHelper }

function TOrganizationalUnitHelper.CanBeDeleted: Boolean;
const
  FLAG_DISALLOW_DELETE = $80000000;
begin
  Result := Self.systemFlags and FLAG_DISALLOW_DELETE = 0;
end;

function TOrganizationalUnitHelper.CanContainClass(AClass: string): Boolean;
var
  valList: TStringList;
begin
  valList := TStringList.Create;
  valList.CaseSensitive := False;
  valList.Delimiter := ',';
  valList.DelimitedText := Self.allowedChildClasses;
  Result := valList.IndexOf(AClass) > -1;
  valList.Free;
end;

function TOrganizationalUnitHelper.ExtractName: string;
var
  RegEx: TRegEx;
begin
  RegEx := TRegEx.Create('(?<=[\\\/])[^\\\/]+$', [roIgnoreCase]);
  Result := RegEx.Match(Self.CanonicalName).Value
end;

{ TADAttributeHelper }

function TADAttributeHelper.ADODataType: DWORD;
begin
   case IndexText(Self.Name,
     [
        'lastLogon',             { 0 }
        'pwdLastSet',            { 1 }
        'badPwdCount',           { 2 }
        'groupType',             { 3 }
        'userAccountControl',    { 4 }
        'primaryGroupToken',     { 5 }
        'thumbnailPhoto',        { 6 }
        'description',           { 7 }
        'distinguishedName',     { 8 }
        'canonicalName'          { 9 }
     ]
   ) of
     0..1: Result := adDate;
     2..5: Result := adInteger;
     6:    Result := adLongVarBinary;
     7..9: Result := adLongVarWChar;
     else if CompareText('nearestEvent', Self.ObjProperty) = 0
       then Result := adDate
       else Result := adVarWChar;
   end;
end;

function TADAttributeHelper.ExcelColumnAlignment: Integer;
begin
  case IndexText(Self.Name,
     [
        'lastLogon',             { 0 }
        'pwdLastSet',            { 1 }
        'badPwdCount'            { 2 }
     ]
   ) of
     0..2: Result := xlCenter;
     else if CompareText('nearestEvent', Self.ObjProperty) = 0
       then Result := xlCenter
       else Result := xlLeft;
   end;
end;

function TADAttributeHelper.ExcelCellFormat(AExcel: Variant): string;
begin
  case IndexText(Self.Name,
     [
        'lastLogon',             { 0 }
        'pwdLastSet',            { 1 }
        'badPwdCount',           { 2 }
        'groupType',             { 3 }
        'userAccountControl',    { 4 }
        'primaryGroupToken'      { 5 }
     ]
   ) of
     0: Result := xlGetDateTimeFormat(AExcel);
     1: Result := xlGetDateTimeFormat(AExcel);
     2: Result := xlGetNumberFormat(AExcel, 0);
     else if CompareText('nearestEvent', Self.ObjProperty) = 0
       then Result := xlGetDateFormat(AExcel)
       else Result := '@';
   end;
end;

function TADAttributeHelper.ExcelColumnWidth: Integer;
begin
  case IndexText(Self.Name,
    [
       'name',                         { 0 }
       'sAMAccountName',               { 1 }
       'employeeID',                   { 2 }
       'title',                        { 3 }
       'telephoneNumber',              { 4 }
       'lastLogonComputer',            { 5 }
       'description',                  { 6 }
       'userWorkstations',             { 7 }
       'physicalDeliveryOfficeName',   { 8 }
       'department',                   { 9 }
       'mail',                         { 10 }
       'canonicalName',                { 11 }
       'distinguishedName',            { 12 }
       'lastLogon',                    { 13 }
       'pwdLastSet',                   { 14 }
       'badPwdCount',                  { 15 }
       'userAccountControl',           { 16 }
       'objectSid'                     { 17 }
    ]
  ) of
    0: Result := 25;
    1: Result := 25;
    2: Result := 11;
    3: Result := 25;
    4: Result := 17;
    5: Result := 17;
    6: Result := 45;
    7: Result := 20;
    8: Result := 45;
    9: Result := 45;
    10: Result := 25;
    11: Result := 45;
    12: Result := 45;
    13: Result := 19;
    14: Result := 19;
    15: Result := 5;
    16: Result := 10;
    17: Result := 45;
    else if CompareText('nearestEvent', Self.ObjProperty) = 0
      then Result := 11
      else Result := 25;
  end;
end;

function TADAttributeHelper.FieldName: string;
var
  s: string;
begin
  if CompareText('nearestEvent', Self.ObjProperty) = 0
    then s := 'NearestEvent'
    else if CompareText('passwordExpiration', Self.ObjProperty) = 0
      then s := 'PasswordExpiration'
      else s := IfThen(Self.Name = '', Self.Title, Self.Name);

  Result := IfThen(s.IsEmpty, 'UntitledField', s);
end;

function TADAttributeHelper.IsExportRequired: Boolean;
begin
  Result := (CompareText('distinguishedName', Self.Name) = 0);
end;

function TADAttributeHelper.IsNotExported: Boolean;
begin
  Result := ( not Self.IsExportRequired ) and
    ( CompareText(Self.Name, 'thumbnailPhoto') = 0 )
end;

end.
