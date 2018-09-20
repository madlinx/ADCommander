unit ADC.ADObject;

interface

uses
  System.SysUtils, System.Classes, System.DateUtils, System.StrUtils, System.Types,
  System.Variants, System.AnsiStrings, Vcl.Imaging.jpeg, Winapi.ActiveX, Winapi.Windows,
  System.TypInfo, System.RegularExpressions, ActiveDs_TLB, MSXML2_TLB, JwaActiveDS,
  ADC.LDAP, ADC.Types, ADC.NetInfo, ADC.AD, ADC.Common, ADC.Attributes;

type
  TADObjectType = (otUnknown, otUser, otGroup, otWorkstation, otDomainController,
    otRODomainController);

type
  TADObject = class(TObject)
  strict private
    type
      TImgFileSize = type Int64;
      TImgFileSizeHelper = record helper for TImgFileSize
        function AsString: string;
      end;

    type
      TADDate = type System.TDateTime;
      TADDateHelper = record helper for TADDate
        function AsString(AccCtrl: Integer): string; overload;
        function AsString(DefValue: string): string; overload;
        function AsString: string; overload;
        function AsDateString: string; overload;
      end;

    type
      TADGroupType = type Integer;
      TADGroupTypeHelper = record helper for TADGroupType
        function AsString: string;
      end;

    type
      TADAccCtrl = type Integer;
      TADAccCtrlHelper = record helper for TADAccCtrl
        function AsString: string;
      end;
  private
    FSelected: Boolean;
    FAttribute01: string;
    FAttribute02: string;
    FAttribute03: string;
    FAttribute04: string;
    FAttribute05: string;
    FAttribute06: string;
    FAttribute07: string;
    FAttribute08: string;
    FAttribute09: string;
    FAttribute10: string;
    FAttribute11: string;
    FAttribute12: string;
    FAttribute13: string;
    FAttribute14: string;
    FAttribute15: string;
    FName: string;
    { Поля для плавающего окна }
    FDisplayName: string;
    FTitle: string;
    FPhysicalDeliveryOfficeName: string;
    { ------------------------ }
    FLastLogon: TADDate;
    FThumbnailPhoto: TJPEGImage;
    FBadPwdCount: Integer;
    FPasswordExpiration: TADDate;
    FEvents: TADEventList;
    FThumbnailPhotoSize: TImgFileSize;
    FNearestEvent: TADDate;
    FSAMAccountName: string;
    FCanonicalName: string;
    FDistinguishedName: string;
    FDNSHostName: string;
    FMsRTCSIP_PrimaryUserAddress: string;
    FObjectSid: string;
    FUserAccountControl: TADAccCtrl;
    FGroupType: TADGroupType;
    FPrimaryGroupToken: Integer;
    FDomainHostName: string;
    FOnRefresh: TNotifyEvent;
    function GetSystemFlags: Integer; overload;
    function GetSystemFlags(ALDAP: PLDAP): Integer; overload;
    procedure OnThumbnailPhotoChange(Sender: TObject);
    procedure ClearThumbnailPhoto;
    function GetSortPosition: Integer;
    function GetADSIPath_LDAP: string;
    procedure SetDNSHostName(const Value: string);
    procedure Clear;
    function GetParentDistinguishedName: string;
    function GetParentCanonicalName: string;
  protected
    destructor Destroy; override;
  public
    constructor Create; reintroduce; overload;
    function ObjectType: TADObjectType;
    function IsUser: Boolean;
    function IsWorkstation: Boolean;
    function IsDomainController: Boolean;
    function IsRODomainController: Boolean;
    function IsGroup: Boolean;
    function IsDisabled: Boolean;
    function IsAccountLocked: Boolean;
    function IsPasswordNeverExpires: Boolean;
    property OnRefresh: TNotifyEvent read FOnRefresh write FOnRefresh;
  published
    property Selected: Boolean read FSelected write FSelected;
    property Attribute01: string read FAttribute01 write FAttribute01;
    property Attribute02: string read FAttribute02 write FAttribute02;
    property Attribute03: string read FAttribute03 write FAttribute03;
    property Attribute04: string read FAttribute04 write FAttribute04;
    property Attribute05: string read FAttribute05 write FAttribute05;
    property Attribute06: string read FAttribute06 write FAttribute06;
    property Attribute07: string read FAttribute07 write FAttribute07;
    property Attribute08: string read FAttribute08 write FAttribute08;
    property Attribute09: string read FAttribute09 write FAttribute09;
    property Attribute10: string read FAttribute10 write FAttribute10;
    property Attribute11: string read FAttribute11 write FAttribute11;
    property Attribute12: string read FAttribute12 write FAttribute12;
    property Attribute13: string read FAttribute13 write FAttribute13;
    property Attribute14: string read FAttribute14 write FAttribute14;
    property Attribute15: string read FAttribute15 write FAttribute15;
    property name: string read FName write FName;
    { Свойства для плавающего окна }
    property displayName: string read FDisplayName write FDisplayName;
    property title: string read FTitle write FTitle;
    property physicalDeliveryOfficeName: string read FPhysicalDeliveryOfficeName write FPhysicalDeliveryOfficeName;
    { ---------------------------- }
    property lastLogon: TADDate read FLastLogon write FLastLogon;
    property badPwdCount: Integer read FBadPwdCount write FBadPwdCount;
    property passwordExpiration: TADDate read FPasswordExpiration write FPasswordExpiration;
    property thumbnailPhoto: TJPEGImage read FThumbnailPhoto;
    property thumbnailFileSize: TImgFileSize read FThumbnailPhotoSize;
    property events: TADEventList read FEvents;
    property nearestEvent: TADDate read FNearestEvent;
    property canonicalName: string read FCanonicalName write FCanonicalName;
    property distinguishedName: string read FDistinguishedName write FDistinguishedName;
    property dNSHostName: string read FDNSHostName write SetDNSHostName;
    property sAMAccountName: string read FSAMAccountName write FSAMAccountName;
    property msRTCSIP_PrimaryUserAddress: string read FMsRTCSIP_PrimaryUserAddress write FMsRTCSIP_PrimaryUserAddress;
    property objectSid: string read FObjectSid write FObjectSid;
    property userAccountControl: TADAccCtrl read FUserAccountControl write FUserAccountControl;
    property groupType: TADGroupType read FGroupType write FGroupType;
    property primaryGroupToken: Integer read FPrimaryGroupToken write FPrimaryGroupToken;
    property DomainHostName: string read FDomainHostName write FDomainHostName;
    property systemFlags: Integer read GetSystemFlags;
    property SortPosition: Integer read GetSortPosition;
    property ParentDistinguishedName: string read GetParentDistinguishedName;
    property ParentCanonicalName: string read GetParentCanonicalName;
  end;

type
  TADObjectHelper = class helper for TADObject
  private
    procedure FillEventList(AStringStream: TStringStream);
    function UTF16LE(AValue: string): string;
    function GetDomainHostName(ALDAP: PLDAP): string; overload;
    function GetDomainHostName(ARootDSE: IADs): string; overload;
    function GetDomainDN(ALDAP: PLDAP): string; overload;
    function GetDomainDN(ARootDSE: IADs): string; overload;
    function GetMaxPasswordAge(ALDAP: PLDAP): Int64; overload;
    function GetMaxPasswordAge(ARootDSE: IADs): Int64; overload;
    function TimestampToDateTime(AAttrVal: PAnsiChar): TDateTime; overload;
    function TimestampToDateTime(ATime: ActiveDS_TLB._LARGE_INTEGER): TDateTime; overload;
    function DateTimeToTimestamp(ATime: TDateTime): ActiveDS_TLB._LARGE_INTEGER;
  public
    procedure LoadEventsFromFile(AStorageDir: string);
    procedure WriteProperties(ALDAP: PLDAP; AEntry: PLDAPMessage; AAttrCat: TAttrCatalog;
      ADomainHostName: string; AMaxPwdAge: Int64); overload;
    procedure WriteProperties(ASearchRes: IDirectorySearch; ASearchHandle: PHandle; AAttrCat: TAttrCatalog;
      ADomainHostName: string; AMaxPwdAge: Int64); overload;
    procedure Refresh(ALDAP: PLDAP; AAttrCat: TAttrCatalog; RaiseEvent: Boolean = True); overload;
    procedure Refresh(ARootDSE: IADs; AAttrCat: TAttrCatalog; RaiseEvent: Boolean = True); overload;
    procedure GetGroupMembers(ALDAP: PLDAP; AMembers: TADGroupMemberList;
      AChainSearch: Boolean); overload;
    procedure GetGroupMembers(AMembers: TADGroupMemberList;
      AChainSearch: Boolean); overload;
    procedure AddGroupMember(ALDAP: PLDAP; AMemberDN: string); overload;
    procedure AddGroupMember(AMemberDN: string); overload;
    procedure RemoveGroupMember(ALDAP: PLDAP; AMemberDN: string); overload;
    procedure RemoveGroupMember(AMemberDN: string); overload;
    function SetUserPassword(ALDAP: PLDAP; APassword: string; AChangeOnLogon, AUnblock: Boolean): Boolean; overload;
    function SetUserPassword(ANewPassword: string; AChangeOnLogon, AUnblock: Boolean): Boolean; overload;
    function GetGroupDescription: string; overload;
    function GetGroupDescription(ALDAP: PLDAP): string; overload;
    function SetGroupDescription(AValue: string): Boolean; overload;
    function SetGroupDescription(ALDAP: PLDAP; AValue: string): Boolean; overload;
    function ChangeDisabledState(ALDAP: PLDAP): Boolean; overload;
    function ChangeDisabledState: Boolean; overload;
    function Rename(ANewName: string): Boolean; overload;
    function Rename(ALDAP: PLDAP; ANewName: string): Boolean; overload;
    function Move(AParent: string): Boolean; overload;
    function Move(ALDAP: PLDAP; AParent: string): Boolean; overload;
    function Delete: Boolean; overload;
    function Delete(ALDAP: PLDAP): Boolean; overload;
  end;

implementation

{ TADObject }

procedure TADObject.Clear;
begin
  FAttribute01 := '';
  FAttribute02 := '';
  FAttribute03 := '';
  FAttribute04 := '';
  FAttribute05 := '';
  FAttribute06 := '';
  FAttribute07 := '';
  FAttribute08 := '';
  FAttribute09 := '';
  FAttribute10 := '';
  FAttribute11 := '';
  FAttribute12 := '';
  FAttribute13 := '';
  FAttribute14 := '';
  FAttribute15 := '';
  FName := '';
  FDisplayName := '';
  FTitle := '';
  FPhysicalDeliveryOfficeName := '';
  FLastLogon := 0;
  Self.ClearThumbnailPhoto;
  FBadPwdCount := 0;
  FPasswordExpiration := 0;
  FEvents.Clear;
  FThumbnailPhotoSize := 0;
  FNearestEvent := 0;
  FSAMAccountName := '';
  FCanonicalName := '';
  FDistinguishedName := '';
  FDNSHostName := '';
  FMsRTCSIP_PrimaryUserAddress := '';
  FObjectSid := '';
  FUserAccountControl := 0;
  FGroupType := 0;
  FPrimaryGroupToken := 0;
  FDomainHostName := '';
end;

procedure TADObject.ClearThumbnailPhoto;
var
  MemStream: TMemoryStream;
  EmptyJPEG: TJPEGImage;
begin
  MemStream := TMemoryStream.Create;
  EmptyJPEG := TJPEGImage.Create;
  try
    {  Используем TMemoryStream т.к. только в этом случае          }
    {  вызывается событие OnChange для FThumbnailPhoto.            }
    {  Метод TJPEGImage.Assign(...) событие OnChange не вызывает.  }

    EmptyJPEG.SaveToStream(MemStream);
    MemStream.Seek(0, soFromBeginning);
    FThumbnailPhoto.LoadFromStream(MemStream);
  finally
    MemStream.Free;
    EmptyJPEG.Free;
  end;
end;

constructor TADObject.Create;
begin
  FSelected := False;
  FThumbnailPhoto := TJPEGImage.Create;
  with FThumbnailPhoto do
  begin
    CompressionQuality := 100;
    Smoothing := True;
    OnChange := OnThumbnailPhotoChange;
  end;

  FEvents := TADEventList.Create;
end;

destructor TADObject.Destroy;
begin
  FEvents.Free;
  FThumbnailPhoto.Free;
  inherited;
end;

function TADObject.GetADSIPath_LDAP: string;
var
  dn: string;
begin
  { ADSI requires that the forward slash character "/" also be escaped }
  { in distinguished names in most scripts where distinguished names   }
  { are used to bind to objects in Active Directory:                   }
  { https://social.technet.microsoft.com/wiki/contents/articles/5312.active-directory-characters-to-escape.aspx }

  dn := ReplaceStr(Self.distinguishedName, '/', '\/');

  if FDomainHostName.IsEmpty
    then Result := Format('LDAP://%s', [dn])
    else Result := Format('LDAP://%s/%s', [FDomainHostName, dn]);
end;

function TADObject.GetParentCanonicalName: string;
var
  regEx: TRegEx;
  res: string;
begin
  regEx := TRegEx.Create('^(.*)(?<=[^\\])\/', [roNone]);
  res := regEx.Match(Self.canonicalName).Value;
  if res[Length(res)] = '/'
    then System.Delete(res, Length(res), 1);
  Result := res;
end;

function TADObject.GetParentDistinguishedName: string;
var
  regEx: TRegEx;
  res: string;
begin
  regEx := TRegEx.Create('(?<=[,])[a-zA-Z]+=.*', [roNone]);
  res := regEx.Match(Self.distinguishedName).Value;
  Result := res;
end;

function TADObject.GetSortPosition: Integer;
begin
  if Self.IsUser then Result := 1
    else if Self.IsGroup then Result := 2
      else if Self.IsDomainController then Result := 3
        else if Self.IsRODomainController then Result := 4
          else if Self.IsWorkstation then Result := 5
end;

function TADObject.GetSystemFlags(ALDAP: PLDAP): Integer;
var
  ldapBase: AnsiString;
  attrArray: array of PAnsiChar;
  returnCode: ULONG;
  searchResult: PLDAPMessage;
  ldapEntry: PLDAPMessage;
  ldapBinValues: PPLDAPBerVal;
begin
  SetLength(attrArray, 2);
  attrArray[0] := PAnsiChar('systemFlags');

  ldapBase := Self.distinguishedName;

  returnCode := ldap_search_ext_s(
    ALDAP,
    PAnsiChar(ldapBase),
    LDAP_SCOPE_BASE,
    nil,
    PAnsiChar(@attrArray[0]),
    0,
    nil,
    nil,
    nil,
    0,
    searchResult
  );

  if (returnCode = LDAP_SUCCESS) and (ldap_count_entries(ALDAP, searchResult) > 0 ) then
  begin
    {FLAG_DISALLOW_DELETE | FLAG_DOMAIN_DISALLOW_RENAME | FLAG_DOMAIN_DISALLOW_MOVE}
    ldapEntry := ldap_first_entry(ALDAP, searchResult);
    ldapBinValues := ldap_get_values_len(ALDAP, ldapEntry, attrArray[0]);
    if (ldapBinValues <> nil) and (ldapBinValues^.bv_len > 0)
      then Result := StrToIntDef(ldapBinValues^.bv_val, 0)
      else Result := 0;
    ldap_value_free_len(ldapBinValues);
  end;

  if searchResult <> nil
    then ldap_msgfree(searchResult);
end;

function TADObject.GetSystemFlags: Integer;
var
  Obj: IADs;
  hr: HRESULT;
  res: OleVariant;
begin
  {FLAG_DISALLOW_DELETE | FLAG_DOMAIN_DISALLOW_RENAME | FLAG_DOMAIN_DISALLOW_MOVE}
  CoInitialize(nil);

  hr := ADsOpenObject(
    PChar(Self.GetADSIPath_LDAP),
    nil,
    nil,
    ADS_SECURE_AUTHENTICATION or ADS_SERVER_BIND,
    IID_IADs,
    @Obj
  );

  if Succeeded(hr) then
  try
    res := Obj.Get('systemFlags');
    if VarIsNull(res)
      then Result := 0
      else if VarIsOrdinal(res)
        then Result := StrToInt(VarToStr(res));
  except
    Result := 0;
  end;
  CoUninitialize;
end;

function TADObject.IsAccountLocked: Boolean;
var
  Obj: IADsUser;
  hr: HRESULT;
begin
  Result := False;
  if not Self.IsUser then Exit;

  CoInitialize(nil);

  hr := ADsOpenObject(
    PChar(Self.GetADSIPath_LDAP),
    nil,
    nil,
    ADS_SECURE_AUTHENTICATION or ADS_SERVER_BIND,
    IID_IADsUser,
    @Obj
  );

  if Succeeded(hr) then
  try
    Result := Obj.IsAccountLocked;
  except

  end;
  CoUninitialize;
end;

function TADObject.IsDisabled: Boolean;
begin
  Result := Self.userAccountControl and ADS_UF_ACCOUNTDISABLE = ADS_UF_ACCOUNTDISABLE;
end;

function TADObject.IsGroup: Boolean;
begin
  Result := Self.groupType <> 0;
end;

function TADObject.IsRODomainController: Boolean;
begin
  Result := (Self.userAccountControl and ADS_UF_WORKSTATION_TRUST_ACCOUNT = ADS_UF_WORKSTATION_TRUST_ACCOUNT)
    and (Self.userAccountControl and ADS_UF_PARTIAL_SECRETS_ACCOUNT = ADS_UF_PARTIAL_SECRETS_ACCOUNT);
end;

function TADObject.IsDomainController: Boolean;
begin
  Result := Self.userAccountControl and ADS_UF_SERVER_TRUST_ACCOUNT = ADS_UF_SERVER_TRUST_ACCOUNT;
end;

function TADObject.IsUser: Boolean;
begin
  Result := Self.userAccountControl and ADS_UF_NORMAL_ACCOUNT = ADS_UF_NORMAL_ACCOUNT;
end;

function TADObject.IsWorkstation: Boolean;
begin
  Result := (Self.userAccountControl and ADS_UF_WORKSTATION_TRUST_ACCOUNT = ADS_UF_WORKSTATION_TRUST_ACCOUNT)
    and (Self.userAccountControl and ADS_UF_PARTIAL_SECRETS_ACCOUNT = 0);
end;

function TADObject.ObjectType: TADObjectType;
begin
  if Self.IsUser
    then Result := otUser
  else if Self.IsGroup
    then Result := otGroup
  else if Self.IsWorkstation
    then Result := otWorkstation
  else if Self.IsDomainController
    then Result := otDomainController
  else if Self.IsRODomainController
    then Result := otRODomainController
  else Result := otUnknown;
end;

procedure TADObject.OnThumbnailPhotoChange(Sender: TObject);
var
  mStream: TMemoryStream;
  i: Integer;
  dataSize: Extended;
  dataSizeUnit: string;
begin
  mStream := TMemoryStream.Create;
  try
    FThumbnailPhoto.SaveToStream(mStream);
    FThumbnailPhotoSize := mStream.Size;
  finally
    mStream.Free;
  end;
end;

function TADObject.IsPasswordNeverExpires: Boolean;
begin
  Result := FUserAccountControl and ADS_UF_DONT_EXPIRE_PASSWD = ADS_UF_DONT_EXPIRE_PASSWD;
end;

procedure TADObject.SetDNSHostName(const Value: string);
begin
  FDNSHostName := LowerCase(Value);
end;

{ TADObject.TImgFileSizeHelper }

function TADObject.TImgFileSizeHelper.AsString: string;
var
  i: Integer;
  imgSize: Extended;
  imgSizeUnit: string;
begin
  imgSize := Self;
  imgSizeUnit := 'Б';
  i := 0;
  if imgSize >= 1024 then
  repeat
    imgSize := imgSize / 1024;
    Inc(i);
    case i of
      1: imgSizeUnit := 'КБ';
      2: imgSizeUnit := 'МБ';
      3: imgSizeUnit := 'ГБ';
      4: imgSizeUnit := 'TБ';
    end;
  until (i = 4) or (imgSize < 1024);

  if imgSize > 0
    then Result := Format('%.2f %s', [imgSize, imgSizeUnit])
    else Result := '';
end;

{ TADObject.TADDateHelper }

function TADObject.TADDateHelper.AsString(AccCtrl: Integer): string;
begin
  case Self > 0 of
    True : if AccCtrl and ADS_UF_DONT_EXPIRE_PASSWD = 0
      then Result := FormatDateTime('dd/mm/yyyy hh:nn:ss', Self)
      else Result := 'Не ограничен';
    False: Result := '<нет>';
  end;
end;

function TADObject.TADDateHelper.AsString(DefValue: string): string;
begin
  case Self > 0 of
    True : Result := FormatDateTime('dd/mm/yyyy hh:nn:ss', Self);
    False: Result := DefValue;
  end;
end;

function TADObject.TADDateHelper.AsDateString: string;
begin
  case Self > 0 of
    True : Result := FormatDateTime('dd/mm/yyyy', Self);
    False: Result := '';
  end;
end;

function TADObject.TADDateHelper.AsString: string;
begin
  case Self > 0 of
    True : Result := FormatDateTime('dd/mm/yyyy hh:nn:ss', Self);
    False: Result := '';
  end;
end;

{ TADObject.TAccCtrlHelper }

function TADObject.TADAccCtrlHelper.AsString: string;
begin
  case Self of
    0        : Result := '';
    512      : Result := 'Enabled Account';
    514      : Result := 'Disabled Account';
    528      : Result := 'Enabled, Lockout';
    530      : Result := 'Disabled, Lockout';
    544      : Result := 'Enabled, Password Not Required';
    546      : Result := 'Disabled, Password Not Required';
    4096     : Result := 'Workstation/server';
    4098     : Result := 'Workstation/server, Disabled';
    4128     : Result := 'Workstation/server, Password Not Required';
    66048    : Result := 'Enabled, Password Doesn''t Expire';
    66050    : Result := 'Disabled, Password Doesn''t Expire';
    66080    : Result := 'Enabled, Password Doesn''t Expire & Not Required';
    66082    : Result := 'Disabled, Password Doesn''t Expire & Not Required';
    69632    : Result := 'Workstation/server, Password Doesn''t Expire';
    262656   : Result := 'Enabled, Smartcard Required';
    262658   : Result := 'Disabled, Smartcard Required';
    262688   : Result := 'Enabled, Smartcard Required, Password Not Required';
    262690   : Result := 'Disabled, Smartcard Required, Password Not Required';
    328192   : Result := 'Enabled, Smartcard Required, Password Doesn''t Expire';
    328194   : Result := 'Disabled, Smartcard Required, Password Doesn''t Expire';
    328224   : Result := 'Enabled, Smartcard Required, Password Doesn''t Expire & Not Required';
    328226   : Result := 'Disabled, Smartcard Required, Password Doesn''t Expire & Not Required';
    528416   : Result := 'Workstation/server, Trusted For Delegation, Password Not Required';
    532480   : Result := 'Domain controller, Trusted For Delegation';
    590336   : Result := 'Enabled, User Cannot Change Password, Password Never Expires';
    83890176 : Result := 'Domain controller, Trusted For Delegation, RODC';
    else     Result := IntToStr(Self);
  end;
end;

{ TADObject.TGroupTypeHelper }

function TADObject.TADGroupTypeHelper.AsString: string;
begin
  case Self of
    0           : Result := '';
    2           : Result := 'Global Distribution Group';
    4           : Result := 'Local Distribution Group';
    5           : Result := 'BuiltIn Domain Local Group';
    8           : Result := 'Universal Distribution Group';
    -2147483640 : Result := 'Universal Security Group';
    -2147483643 : Result := 'BuiltIn Group';
    -2147483644 : Result := 'Local Security Group';
    -2147483646 : Result := 'Global Security Group';
    else Result := IntToStr(Self);
  end;
end;


{ TADObjectHelper }

function TADObjectHelper.ChangeDisabledState(ALDAP: PLDAP): Boolean;
var
  ldapBase: AnsiString;
  ldapValue: AnsiString;
  ldapValues: array of PAnsiChar;
  ldapMod: PLDAPMod;
  ldapModArray: array of PLDAPMod;
  returnCode: ULONG;
  UF: Integer;
begin
  Result := False;

  ldapBase := Self.distinguishedName;

  SetLength(ldapModArray, 2);
  New(ldapMod);

  ldapModArray[0] := ldapMod;
  ldapModArray[1] := nil;
  SetLength(ldapValues, 2);

  ldapMod^.mod_op := LDAP_MOD_REPLACE;
  ldapMod^.mod_type := PAnsiChar('userAccountControl');
  ldapMod^.modv_strvals := @ldapValues[0];

  case Self.userAccountControl and ADS_UF_ACCOUNTDISABLE <> 0 of
    True : UF := Self.userAccountControl xor ADS_UF_ACCOUNTDISABLE;
    False: UF := Self.userAccountControl or ADS_UF_ACCOUNTDISABLE;
  end;

  ldapValues[0] := PAnsiChar(AnsiString(IntToStr(UF)));
  ldapValues[1] := nil;

  try
    returnCode := ldap_modify_s(
      ALDAP,
      PAnsiChar(ldapBase),
      @ldapModArray[0]
    );

    if returnCode <> LDAP_SUCCESS
      then raise Exception.Create(ldap_err2string(returnCode));

    Result := True;
  finally
    Dispose(ldapMod);
  end;
end;

function TADObjectHelper.DateTimeToTimestamp(
  ATime: TDateTime): ActiveDS_TLB._LARGE_INTEGER;
var
  int64Value: LARGE_INTEGER;
  LocalTime: TFileTime;
  SystemTime: TSystemTime;
  FileTime : TFileTime;
begin
  Result.QuadPart := 0;
  DateTimeToSystemTime(Now, SystemTime);
  if SystemTimeToFileTime(SystemTime, LocalTime)
    then if LocalFileTimeToFileTime(LocalTime, FileTime)
      then begin
        int64Value.LowPart := FileTime.dwLowDateTime;
        int64Value.HighPart := FileTime.dwHighDateTime;
        Result.QuadPart := int64Value.QuadPart;
      end;
end;

function TADObjectHelper.Delete: Boolean;
var
  Obj: IADs;
  objClass: string;
  objRelativeName: string;
  objCont: IADsContainer;
  hr: HRESULT;
begin
  Result := False;

  CoInitialize(nil);

  try
    hr := ADsOpenObject(
      PChar(Self.GetADSIPath_LDAP),
      nil,
      nil,
      ADS_SECURE_AUTHENTICATION or ADS_SERVER_BIND,
      IID_IADs,
      @Obj
    );

    if Succeeded(hr) then
    begin
      objClass := Obj.Class_;
      objRelativeName := Obj.Name;

      hr := ADsOpenObject(
        PChar(Obj.Parent),
        nil,
        nil,
        ADS_SECURE_AUTHENTICATION or ADS_SERVER_BIND,
        IID_IADsContainer,
        @objCont
      );

      if Succeeded(hr) then
      begin
        objCont.Delete(
          objClass,
          objRelativeName
        );
      end else raise Exception.Create(ADSIErrorToString);
    end else raise Exception.Create(ADSIErrorToString);

    Result := True;
  finally
    CoUninitialize;
  end;
end;

function TADObjectHelper.Delete(ALDAP: PLDAP): Boolean;
var
  ldapDN: AnsiString;
  returnCode: ULONG;
begin
  Result := False;

  ldapDN := Self.distinguishedName;

  try
    returnCode := ldap_delete_ext_s(
      ALDAP,
      PAnsiChar(ldapDN),
      nil,
      nil
    );

    if returnCode <> LDAP_SUCCESS
      then raise Exception.Create(ldap_err2string(returnCode));

    Result := True;
  finally

  end;
end;

procedure TADObjectHelper.AddGroupMember(ALDAP: PLDAP; AMemberDN: string);
var
  ldapBase: AnsiString;
  g: PADGroup;
  modArray: array of PLDAPMod;
  valMember: array of PAnsiChar;
  returnCode: ULONG;
  i: Integer;
begin
  if not Self.IsGroup then Exit;

  try
    ldapBase := AnsiString(Self.distinguishedName);

    SetLength(modArray, 2);
    SetLength(valMember, 2);
    valMember[0] := PAnsiChar(AnsiString(AMemberDN));

    New(modArray[0]);
    with modArray[0]^ do
    begin
      mod_type := 'member';
      mod_op := LDAP_MOD_ADD;
      modv_strvals := @valMember[0];
    end;

    returnCode := ldap_modify_ext_s(
      ALDAP,
      PAnsiChar(ldapBase),
      @modArray[0],
      nil,
      nil
    );

    if returnCode <> LDAP_SUCCESS
      then raise Exception.Create(ldap_err2stringW(returnCode));
  finally
    for i := Low(modArray) to High(modArray) do
      if Assigned(modArray[i])
        then Dispose(modArray[i]);

    SetLength(modArray, 0);
  end;
end;

procedure TADObjectHelper.AddGroupMember(AMemberDN: string);
var
  oGroup: IADSGroup;
  hr: HRESULT;
  memberDN: string;
begin
  if not Self.IsGroup then Exit;

  CoInitialize(nil);
  try
    hr := ADsOpenObject(
      PChar(Self.GetADSIPath_LDAP),
      nil,
      nil,
      ADS_SECURE_AUTHENTICATION or ADS_SERVER_BIND,
      IID_IADsGroup,
      @oGroup
    );

    if Succeeded(hr) then
    begin
      memberDN := ReplaceStr(AMemberDN, '/', '\/');

      if FDomainHostName.IsEmpty
        then memberDN := Format('LDAP://%s', [memberDN])
        else memberDN := Format('LDAP://%s/%s', [FDomainHostName, memberDN]);

      oGroup.Add(memberDN);
    end else raise Exception.Create(ADSIErrorToString);
  finally
    CoUnInitialize;
  end;
end;

function TADObjectHelper.ChangeDisabledState: Boolean;
var
  Obj: IADs;
  hr: HRESULT;
  UF: Integer;
begin
  Result := False;
  UF := Self.userAccountControl;
  CoInitialize(nil);

  try
    hr := ADsOpenObject(
      PChar(Self.GetADSIPath_LDAP),
      nil,
      nil,
      ADS_SECURE_AUTHENTICATION or ADS_SERVER_BIND,
      IID_IADs,
      @Obj
    );

    if Succeeded(hr) then
    begin
      case Self.userAccountControl and ADS_UF_ACCOUNTDISABLE <> 0 of
        True : UF := Self.userAccountControl xor ADS_UF_ACCOUNTDISABLE;
        False: UF := Self.userAccountControl or ADS_UF_ACCOUNTDISABLE;
      end;
      Obj.Put('userAccountControl', UF);
      Obj.SetInfo;
    end else raise Exception.Create(ADSIErrorToString);

    Result := True;
  finally
    CoUninitialize;
  end;
end;

procedure TADObjectHelper.FillEventList(AStringStream: TStringStream);
var
  XMLDoc: IXMLDOMDocument;
  XMLNodeList: IXMLDOMNodeList;
  XMLNode: IXMLDOMNode;
  i: Integer;
  e: PADEvent;
begin
  Self.FEvents.Clear;
  XMLDoc := CoDOMDocument60.Create;
  try
    XMLDoc.async := False;
    XMLDoc.load(TStreamAdapter.Create(AStringStream) as IStream);
    if XMLDoc.parseError.errorCode = 0 then
    begin
      XMLNodeList := XMLDoc.documentElement.selectNodes('event');
      for i := 0 to XMLNodeList.length - 1 do
      begin
        New(e);
        XMLNode := XMLNodeList.item[i].selectSingleNode('date');
        e^.Date := StrToDateTimeDef(XMLNode.text, 0);
        XMLNode := XMLNodeList.item[i].selectSingleNode('description');
        e^.Description := XMLNode.text;
        Self.FEvents.Add(e);
      end;
    end;
    Self.events.SortList(SortEvents);
    FNearestEvent := Self.events.GetNearestEvent;
  finally
    XMLDoc := nil;
  end;
end;

function TADObjectHelper.TimestampToDateTime(AAttrVal: PAnsiChar): TDateTime;
var
  int64Value: Int64;
  LocalTime: TFileTime;
  SystemTime: TSystemTime;
  FileTime : TFileTime;
begin
  int64Value := StrToInt64Def(AAttrVal, 0);
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

procedure TADObjectHelper.Refresh(ALDAP: PLDAP; AAttrCat: TAttrCatalog; RaiseEvent: Boolean = True);
var
  i: Integer;
  attr: PAnsiChar;
  attrArray: array of PAnsiChar;
  returnCode: ULONG;
  searchResult: PLDAPMessage;
  ldapEntry: PLDAPMessage;
  ldapValue: PPAnsiChar;
begin
  if ALDAP = nil then Exit;

  SetLength(attrArray, AAttrCat.Count + 1);
  for i := 0 to AAttrCat.Count - 1 do
    attrArray[i] := System.AnsiStrings.StrNew(PAnsiChar(AnsiString(AAttrCat[i]^.Name)));

  returnCode := ldap_search_ext_s(
    ALDAP,
    PAnsiChar(AnsiString(Self.distinguishedName)),
    LDAP_SCOPE_BASE,
    nil,
    PAnsiChar(@attrArray[0]),
    0,
    nil,
    nil,
    nil,
    0,
    searchResult
  );

  if (returnCode = LDAP_SUCCESS) and (ldap_count_entries(ALDAP, searchResult) > 0 ) then
  begin
    ldapEntry := ldap_first_entry(ALDAP, searchResult);
    if ldapEntry <> nil then
    begin
      Self.WriteProperties(
        ALDAP,
        ldapEntry,
        AAttrCat,
        GetDomainHostName(ALDAP),
        GetMaxPasswordAge(ALDAP)
      );

      if Assigned(Self.OnRefresh)
        then if RaiseEvent
          then OnRefresh(Self);
    end;
    ldap_msgfree(searchResult);
    searchResult := nil;
  end;

  if searchResult <> nil
    then ldap_msgfree(searchResult);
end;

function TADObjectHelper.GetMaxPasswordAge(ALDAP: PLDAP): Int64;
const
  ONE_HUNDRED_NANOSECOND = 0.000000100;
  SECONDS_IN_DAY         = 86400;
var
  attr: PAnsiChar;
  attrArray: array of PAnsiChar;
  returnCode: ULONG;
  searchResult: PLDAPMessage;
  ldapBase: AnsiString;
  ldapEntry: PLDAPMessage;
  ldapBinValues: PPLDAPBerVal;
begin
  Result := 0;

  if ALDAP = nil then Exit;

  ldapBase := GetDomainDN(ALDAP);

  SetLength(attrArray, 2);
  attrArray[0] := PAnsiChar('maxPwdAge');

  returnCode := ldap_search_ext_s(
    ALDAP,
    PAnsiChar(ldapBase),
    LDAP_SCOPE_BASE,
    PAnsiChar('objectCategory=domain'),
    PAnsiChar(@attrArray[0]),
    0,
    nil,
    nil,
    nil,
    0,
    searchResult
  );

  if (returnCode = LDAP_SUCCESS) and (ldap_count_entries(ALDAP, searchResult) > 0 ) then
  begin
    ldapEntry := ldap_first_entry(ALDAP, searchResult);
    ldapBinValues := ldap_get_values_len(ALDAP, ldapEntry, PAnsiChar('maxPwdAge'));
    if (ldapBinValues <> nil) and (ldapBinValues^.bv_len > 0) then
    begin
      Result := Abs(Round(ONE_HUNDRED_NANOSECOND * StrToInt64Def(ldapBinValues^.bv_val, 0)));
//      Result := Round(FMaxPwdAge_Secs / SECONDS_IN_DAY);
    end;
    ldap_value_free_len(ldapBinValues);
  end;

  if searchResult <> nil
    then ldap_msgfree(searchResult);
end;

function TADObjectHelper.GetDomainHostName(ALDAP: PLDAP): string;
var
  attr: PAnsiChar;
  attrArray: array of PAnsiChar;
  returnCode: ULONG;
  searchResult: PLDAPMessage;
  ldapEntry: PLDAPMessage;
  ldapValue: PPAnsiChar;
begin
  Result := '';

  if ALDAP = nil then Exit;

  SetLength(attrArray, 2);
  attrArray[0] := PAnsiChar('dnsHostName');
  attrArray[1] := nil;

  returnCode := ldap_search_ext_s(
    ALDAP,
    nil,
    LDAP_SCOPE_BASE,
    PAnsiChar('(objectclass=*)'),
    PAnsiChar(@attrArray[0]),
    0,
    nil,
    nil,
    nil,
    0,
    searchResult
  );

  if (returnCode = LDAP_SUCCESS) and (ldap_count_entries(ALDAP, searchResult) > 0 ) then
  begin
    ldapEntry := ldap_first_entry(ALDAP, searchResult);
    ldapValue := ldap_get_values(ALDAP, ldapEntry, attrArray[0]);
    if ldapValue <> nil
      then Result := ldapValue^;
    ldap_value_free(ldapValue);
  end;

  if searchResult <> nil
    then ldap_msgfree(searchResult);
end;

function TADObjectHelper.GetDomainDN(ALDAP: PLDAP): string;
var
  attr: PAnsiChar;
  attrArray: array of PAnsiChar;
  returnCode: ULONG;
  searchResult: PLDAPMessage;
  ldapEntry: PLDAPMessage;
  ldapValue: PPAnsiChar;
begin
  Result := '';

  if ALDAP = nil then Exit;

  SetLength(attrArray, 2);
  attrArray[0] := PAnsiChar('defaultNamingContext');
  attrArray[1] := nil;

  returnCode := ldap_search_ext_s(
    ALDAP,
    nil,
    LDAP_SCOPE_BASE,
    PAnsiChar('(objectclass=*)'),
    PAnsiChar(@attrArray[0]),
    0,
    nil,
    nil,
    nil,
    0,
    searchResult
  );

  if (returnCode = LDAP_SUCCESS) and (ldap_count_entries(ALDAP, searchResult) > 0 ) then
  begin
    ldapEntry := ldap_first_entry(ALDAP, searchResult);
    ldapValue := ldap_get_values(ALDAP, ldapEntry, attrArray[0]);
    if ldapValue <> nil
      then Result := ldapValue^;
    ldap_value_free(ldapValue);
  end;

  if searchResult <> nil
    then ldap_msgfree(searchResult);
end;

function TADObjectHelper.GetDomainDN(ARootDSE: IADs): string;
var
  i: Integer;
  v: OleVariant;
begin
  Result := '';

  if ARootDSE = nil then Exit;

  v := ARootDSE.Get('defaultNamingContext');
  Result := VariantToStringWithDefault(v, '');
  VariantClear(v);
end;

function TADObjectHelper.GetDomainHostName(ARootDSE: IADs): string;
var
  i: Integer;
  v: OleVariant;
begin
  Result := '';

  if ARootDSE = nil then Exit;

  v := ARootDSE.Get('dnsHostName');
  Result := VariantToStringWithDefault(v, '');
  VariantClear(v);
end;

procedure TADObjectHelper.GetGroupMembers(ALDAP: PLDAP;
  AMembers: TADGroupMemberList; AChainSearch: Boolean);
var
  ldapBase: AnsiString;
  ldapFilter: AnsiString;
  filterMemberOf: AnsiString;
  ldapCookie: PLDAPBerVal;
  ldapPage: PLDAPControl;
  ldapControls: array[0..1] of PLDAPControl;
  ldapServerControls: PPLDAPControl;
  ldapEntry: PLDAPMessage;
  ldapValue: PPAnsiChar;
  ldapBinValues: PPLDAPBerVal;
  ldapCount: ULONG;
  searchResult: PLDAPMessage;
  attrArray: array of PAnsiChar;
  errorCode: ULONG;
  returnCode: ULONG;
  morePages: Boolean;
  m: PADGroupMember;
  dn: PAnsiChar;
begin
  AMembers.Clear;

  if not Self.IsGroup then Exit;

  SetLength(attrArray, 2);
  attrArray[0] := PAnsiChar('defaultNamingContext');
  attrArray[1] := nil;

  returnCode := ldap_search_ext_s(
    ALDAP,
    nil,
    LDAP_SCOPE_BASE,
    PAnsiChar('(objectclass=*)'),
    PAnsiChar(@attrArray[0]),
    0,
    nil,
    nil,
    nil,
    0,
    searchResult
  );

  if (returnCode = LDAP_SUCCESS) and (ldap_count_entries(ALDAP, searchResult) > 0 ) then
  begin
    ldapEntry := ldap_first_entry(ALDAP, searchResult);
    ldapValue := ldap_get_values(ALDAP, ldapEntry, attrArray[0]);
    if ldapValue <> nil
      then ldapBase := ldapValue^;
    ldap_value_free(ldapValue);
  end;

  if searchResult <> nil
    then ldap_msgfree(searchResult);

  SetLength(attrArray, 5);
  attrArray[0] := PAnsiChar('name');
  attrArray[1] := PAnsiChar('sAMAccountName');
  attrArray[2] := PAnsiChar('groupType');
  attrArray[3] := PAnsiChar('primaryGroupID');
  attrArray[4] := nil;

  try
    { Формируем фильтр объектов AD }
    case AChainSearch of
      True:  filterMemberOf := '(memberOf:1.2.840.113556.1.4.1941:=%s)(primaryGroupID=%d)';
      False: filterMemberOf := '(memberOf=%s)(primaryGroupID=%d)';
    end;

    ldapFilter := '(&' +
      '(|(objectclass=group)(&(objectCategory=person)(objectClass=user)))' +
      '(|' +
         System.AnsiStrings.Format(
           filterMemberOf,
           [Self.distinguishedName, Self.primaryGroupToken]
         ) +
      ')' +
    ')';

    ldapCookie := nil;

    { Постраничный поиск объектов AD }
    repeat
      returnCode := ldap_create_page_control(
        ALDAP,
        ADC_SEARCH_PAGESIZE,
        ldapCookie,
        1,
        ldapPage
      );

      if returnCode <> LDAP_SUCCESS
        then raise Exception.Create('Failure during ldap_create_page_control: ' + ldap_err2string(returnCode));

      ldapControls[0] := ldapPage;
      ldapControls[1] := nil;

      returnCode := ldap_search_ext_s(
        ALDAP,
        PAnsiChar(ldapBase),
        LDAP_SCOPE_SUBTREE,
        PAnsiChar(ldapFilter),
        PAnsiChar(@attrArray[0]),
        0,
        @ldapControls,
        nil,
        nil,
        0,
        SearchResult
      );

      if not (returnCode in [LDAP_SUCCESS, LDAP_PARTIAL_RESULTS])
        then raise Exception.Create('Failure during ldap_search_ext_s: ' + ldap_err2string(returnCode));

      returnCode := ldap_parse_result(
        ALDAP^,
        SearchResult,
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
        ALDAP,
        ldapServerControls,
        ldapCount,
        ldapCookie
      );

      if (ldapCookie <> nil) and (ldapCookie^.bv_val <> nil) and (System.SysUtils.StrLen(ldapCookie^.bv_val) > 0)
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

      ldapEntry := ldap_first_entry(ALDAP, searchResult);
      while ldapEntry <> nil do
      begin
        New(m);
        m^.Selected := False;

        dn := ldap_get_dn(ALDAP, ldapEntry);
        if dn <> nil then m^.distinguishedName := dn;
        ldap_memfree(dn);

        ldapValue := ldap_get_values(ALDAP, ldapEntry, attrArray[0]);
        if ldapValue <> nil
          then m^.name := ldapValue^;
        ldap_value_free(ldapValue);

        ldapValue := ldap_get_values(ALDAP, ldapEntry, attrArray[1]);
        if ldapValue <> nil
          then m^.sAMAccountName := ldapValue^;
        ldap_value_free(ldapValue);

        ldapValue := ldap_get_values(ALDAP, ldapEntry, attrArray[2]);
        if ldapValue <> nil
          then m^.SortKey := 1
          else m^.SortKey := 2;
        ldap_value_free(ldapValue);

        ldapBinValues := ldap_get_values_len(ALDAP, ldapEntry, attrArray[3]);
        if (ldapBinValues <> nil) and (ldapBinValues^.bv_len > 0)
          then m^.primaryGroupID := StrToIntDef(ldapBinValues^.bv_val, 0);
        ldap_value_free_len(ldapBinValues);

        AMembers.Add(m);
        ldapEntry := ldap_next_entry(ALDAP, ldapEntry);
      end;

      ldap_msgfree(SearchResult);
      SearchResult := nil;
    until (morePages = False);

    ber_bvfree(ldapCookie);
    ldapCookie := nil;
  except
    on E: Exception do
    begin

    end;
  end;

  if searchResult <> nil
    then ldap_msgfree(searchResult);
end;

function TADObjectHelper.GetGroupDescription: string;
var
  hRes: HRESULT;
  pObj: IADs;
  v: OleVariant;
begin
  Result := '';

  if not Self.IsGroup then Exit;

  CoInitialize(nil);

  try
    hRes := ADsOpenObject(
      PChar(Self.GetADSIPath_LDAP),
      nil,
      nil,
      ADS_SECURE_AUTHENTICATION or ADS_SERVER_BIND,
      IID_IADs,
      @pObj
    );

    if Succeeded(hRes) then
    begin
      v := pObj.Get('description');
      Result := VarToStr(v);
      VariantClear(v);
    end else raise Exception.Create(ADSIErrorToString);
  except

  end;

  CoUninitialize;
end;

function TADObjectHelper.GetGroupDescription(ALDAP: PLDAP): string;
var
  ldapBase: AnsiString;
  attrArray: array of PAnsiChar;
  returnCode: ULONG;
  searchResult: PLDAPMessage;
  ldapEntry: PLDAPMessage;
  ldapValue: PPAnsiChar;
begin
  Result := '';

  if not Self.IsGroup then Exit;

  SetLength(attrArray, 2);
  attrArray[0] := PAnsiChar('description');
  attrArray[1] := nil;

  ldapBase := Self.distinguishedName;

  returnCode := ldap_search_ext_s(
    ALDAP,
    PAnsiChar(ldapBase),
    LDAP_SCOPE_BASE,
    nil,
    PAnsiChar(@attrArray[0]),
    0,
    nil,
    nil,
    nil,
    0,
    searchResult
  );

  if (returnCode = LDAP_SUCCESS) and (ldap_count_entries(ALDAP, searchResult) > 0 ) then
  begin
    ldapEntry := ldap_first_entry(ALDAP, searchResult);
    ldapValue := ldap_get_values(ALDAP, ldapEntry, attrArray[0]);
    if ldapValue <> nil
      then Result := ldapValue^
      else Result := '';
    ldap_value_free(ldapValue);
  end;

  if searchResult <> nil
    then ldap_msgfree(searchResult);
end;

procedure TADObjectHelper.GetGroupMembers(AMembers: TADGroupMemberList;
  AChainSearch: Boolean);
var
  regEx: TRegEx;
  regExMatches: TMatchCollection;
  regExMatch: TMatch;
  objFilter: string;
  filterMemberOf: string;
  pDomain: IADsDomain;
  hRes: HRESULT;
  SearchBase: string;
  SearchPrefs: array of ADS_SEARCHPREF_INFO;
  SearchResult: IDirectorySearch;
  SearchHandle: PHandle;
  col: ADS_SEARCH_COLUMN;
  attrArray: array of WideString;
  m: PADGroupMember;
begin
  AMembers.Clear;

  if not Self.IsGroup then Exit;

  regEx := tRegEx.Create('DC=\w{1,}?\b', [roIgnoreCase]);
  regExMatches := regEx.Matches(Self.distinguishedName);
  for regExMatch in regExMatches do
    SearchBase := SearchBase + IfThen(SearchBase.IsEmpty, '', ',') + regExMatch.Value;

  SetLength(attrArray, 5);
  attrArray[0] := 'name';
  attrArray[1] := 'sAMAccountName';
  attrArray[2] := 'distinguishedName';
  attrArray[3] := 'groupType';
  attrArray[4] := 'primaryGroupID';

  CoInitialize(nil);
  try
    hRes := ADsOpenObject(
      PChar('LDAP://' + Self.DomainHostName + '/' + SearchBase),
      nil,
      nil,
      ADS_SECURE_AUTHENTICATION or ADS_SERVER_BIND,
      IID_IDirectorySearch,
      @SearchResult
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

      hRes := SearchResult.SetSearchPreference(SearchPrefs[0], Length(SearchPrefs));

      if not Succeeded(hRes)
        then raise Exception.Create(ADSIErrorToString);

      case AChainSearch of
        True:  filterMemberOf := '(memberOf:1.2.840.113556.1.4.1941:=%s)(primaryGroupID=%d)';
        False: filterMemberOf := '(memberOf=%s)(primaryGroupID=%d)';
      end;

      objFilter := '(&' +
        '(|(objectclass=group)(&(objectCategory=person)(objectClass=user)))' +
        '(|' +
           System.AnsiStrings.Format(
             filterMemberOf,
             [Self.distinguishedName, Self.primaryGroupToken]
           ) +
        ')' +
      ')';

      hRes := SearchResult.ExecuteSearch(
        PWideChar(objFilter),
        PWideChar(@attrArray[0]),
        Length(attrArray),
        Pointer(SearchHandle)
      );

      if not Succeeded(hRes)
        then raise Exception.Create(ADSIErrorToString);

      hRes := SearchResult.GetNextRow(SearchHandle);
      while (hRes <> S_ADS_NOMORE_ROWS) do
      begin
        New(m);
        m^.Selected := False;

        hRes := SearchResult.GetColumn(SearchHandle, PWideChar(attrArray[0]), col);
        if Succeeded(hRes)
          then m^.name := col.pAdsvalues^.__MIDL____MIDL_itf_ads_0000_00000000.CaseIgnoreString;
        SearchResult.FreeColumn(col);

        hRes := SearchResult.GetColumn(SearchHandle, PWideChar(attrArray[1]), col);
        if Succeeded(hRes)
          then m^.sAMAccountName := col.pAdsvalues^.__MIDL____MIDL_itf_ads_0000_00000000.CaseIgnoreString;
        SearchResult.FreeColumn(col);

        hRes := SearchResult.GetColumn(SearchHandle, PWideChar(attrArray[2]), col);
        if Succeeded(hRes)
          then m^.distinguishedName := col.pAdsvalues^.__MIDL____MIDL_itf_ads_0000_00000000.CaseIgnoreString;
        SearchResult.FreeColumn(col);

        hRes := SearchResult.GetColumn(SearchHandle, PWideChar(attrArray[3]), col);
        if Succeeded(hRes)
          then m^.SortKey := 1
          else m^.SortKey := 2;
        SearchResult.FreeColumn(col);

        hRes := SearchResult.GetColumn(SearchHandle, PWideChar(attrArray[4]), col);
        if Succeeded(hRes)
          then m^.primaryGroupID := col.pAdsvalues^.__MIDL____MIDL_itf_ads_0000_00000000.Integer;
        SearchResult.FreeColumn(col);

        AMembers.Add(m);
        hRes := SearchResult.GetNextRow(Pointer(SearchHandle));
      end;
    end else raise Exception.Create(ADSIErrorToString);;
  except
    on E: Exception do
    begin

    end;
  end;

  SearchResult.CloseSearchHandle(Pointer(SearchHandle));
end;

function TADObjectHelper.GetMaxPasswordAge(ARootDSE: IADs): Int64;
const
  ONE_HUNDRED_NANOSECOND = 0.000000100;
  SECONDS_IN_DAY         = 86400;
var
  hRes: HRESULT;
  pDomain: IADs;
  v: OleVariant;
  d: LARGE_INTEGER;
begin
  Result := 0;

  if ARootDSE = nil then Exit;

  hRes := ADsOpenObject(
    PChar('LDAP://' + GetDomainHostName(ARootDSE) + '/' + GetDomainDN(ARootDSE)),
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
	    Result := 0;
    end else
    begin
      d.QuadPart := d.HighPart;
      d.QuadPart := d.QuadPart shl 32;
      d.QuadPart := d.QuadPart + d.LowPart;

      Result := Abs(Round(d.QuadPart * ONE_HUNDRED_NANOSECOND));
//      Result := Round(FMaxPwdAge_Secs / SECONDS_IN_DAY);
    end;
  end;

  pDomain := nil;
end;

procedure TADObjectHelper.LoadEventsFromFile(AStorageDir: string);
var
  fName: TFileName;
  XMLStream: TStringStream;
  i: Integer;
  eventString: string;
begin
  fName := IncludeTrailingBackslash(AStorageDir) + Self.objectSid + '.xml';
  if not FileExists(fName) then Exit;

  XMLStream := TStringStream.Create;
  try
    XMLStream.LoadFromFile(fName);
    Self.FillEventList(XMLStream);
  finally
    XMLStream.Free;
  end;
end;

function TADObjectHelper.Move(AParent: string): Boolean;
var
  Obj: IADs;
  objCont: IADsContainer;
  hr: HRESULT;
begin
  Result := False;

  CoInitialize(nil);

  try
    hr := ADsOpenObject(
      PChar(Format('LDAP://%s/%s', [FDomainHostName, AParent])),
      nil,
      nil,
      ADS_SECURE_AUTHENTICATION or ADS_SERVER_BIND,
      IID_IADsContainer,
      @objCont
    );

    if Succeeded(hr) then
    begin
      Obj := objCont.MoveHere(
        Self.GetADSIPath_LDAP,
        ''
      ) as IADs;
      Obj.GetInfo;

      Self.Clear;
      Self.distinguishedName := Obj.Get('distinguishedName');
    end else raise Exception.Create(ADSIErrorToString);

    Result := True;
  finally
    CoUninitialize;
  end;
end;

function TADObjectHelper.Move(ALDAP: PLDAP; AParent: string): Boolean;
var
  rdn: AnsiString;
  newParent: AnsiString;
  returnCode: ULONG;
  regEx: TRegEx;
begin
  Result := False;

  newParent := AParent;

  regEx := TRegEx.Create(',[a-zA-Z]+=.*$', [roNone]);
  rdn := regEx.Replace(Self.distinguishedName, '');

  try
    returnCode := ldap_rename_ext_s(
      ALDAP,
      PAnsiChar(AnsiString(Self.distinguishedName)),
      PAnsiChar(rdn),
      PAnsiChar(newParent),
      1,
      nil,
      nil
    );

    if returnCode <> LDAP_SUCCESS
      then raise Exception.Create(ldap_err2string(returnCode));

    Self.Clear;
    Self.distinguishedName := Format('%s,%s', [rdn, newParent]);
    Result := True;
  finally

  end;
end;

procedure TADObjectHelper.Refresh(ARootDSE: IADs; AAttrCat: TAttrCatalog; RaiseEvent: Boolean = True);
var
  i: Integer;
  objFilter: string;
  pDomain: IADsDomain;
  hRes: HRESULT;
  SearchRes: IDirectorySearch;
  SearchPrefs: array of ADS_SEARCHPREF_INFO;
  SearchHandle: PHandle;
  attrArray: array of WideString;
begin
  if ARootDSE = nil then Exit;

  { Осуществляем поиск в домене атрибутов и их значений }
  hRes := ADsOpenObject(
    PChar('LDAP://' + GetDomainHostName(ARootDSE) + '/' + GetDomainDN(ARootDSE)),
    nil,
    nil,
    ADS_SECURE_AUTHENTICATION or ADS_SERVER_BIND,
    IID_IDirectorySearch,
    @SearchRes
  );

  if Succeeded(hRes) then
  begin
    SetLength(SearchPrefs, 2);
    with SearchPrefs[0] do
    begin
      dwSearchPref  := ADS_SEARCHPREF_PAGESIZE;
      vValue.dwType := ADSTYPE_INTEGER;
      vValue.__MIDL____MIDL_itf_ads_0000_00000000.Integer := ADC_SEARCH_PAGESIZE;
    end;
    with SearchPrefs[1] do
    begin
      dwSearchPref  := ADS_SEARCHPREF_SEARCH_SCOPE;
      vValue.dwType := ADSTYPE_INTEGER;
      vValue.__MIDL____MIDL_itf_ads_0000_00000000.Integer := ADS_SCOPE_SUBTREE;
    end;

    hRes := SearchRes.SetSearchPreference(SearchPrefs[0], Length(SearchPrefs));

    objFilter := '(distinguishedName=' + Self.distinguishedName + ')';

    SetLength(attrArray, AAttrCat.Count);
    for i := 0 to AAttrCat.Count - 1 do
    begin
      if AAttrCat[i]^.Name = ''
        then attrArray[i] := '<Undefined>'
        else attrArray[i] := AAttrCat[i]^.Name;
    end;

    SearchRes.ExecuteSearch(
      PWideChar(objFilter),
      PWideChar(@attrArray[0]),
      Length(attrArray),
      Pointer(SearchHandle)
    );

    { Обработка объектов }
    hRes := SearchRes.GetNextRow(SearchHandle);
    if hRes <> S_ADS_NOMORE_ROWS then
    begin
      Self.WriteProperties(
        SearchRes,
        SearchHandle,
        AAttrCat,
        GetDomainHostName(ARootDSE),
        GetMaxPasswordAge(ARootDSE)
      );

      if Assigned(Self.OnRefresh)
        then if RaiseEvent
          then OnRefresh(Self);
    end;
    SearchRes.CloseSearchHandle(Pointer(SearchHandle));
  end;
end;

procedure TADObjectHelper.RemoveGroupMember(ALDAP: PLDAP; AMemberDN: string);
var
  ldapBase: AnsiString;
  g: PADGroup;
  modArray: array of PLDAPMod;
  valMember: array of PAnsiChar;
  returnCode: ULONG;
  i: Integer;
begin
  if not Self.IsGroup then Exit;

  try
    ldapBase := AnsiString(Self.distinguishedName);

    SetLength(modArray, 2);
    SetLength(valMember, 2);
    valMember[0] := PAnsiChar(AnsiString(AMemberDN));

    New(modArray[0]);
    with modArray[0]^ do
    begin
      mod_type := 'member';
      mod_op := LDAP_MOD_DELETE;
      modv_strvals := @valMember[0];
    end;

    returnCode := ldap_modify_ext_s(
      ALDAP,
      PAnsiChar(ldapBase),
      @modArray[0],
      nil,
      nil
    );

    if returnCode <> LDAP_SUCCESS
      then raise Exception.Create(ldap_err2stringW(returnCode));
  finally
    for i := Low(modArray) to High(modArray) do
      if Assigned(modArray[i])
        then Dispose(modArray[i]);

    SetLength(modArray, 0);
  end;
end;

procedure TADObjectHelper.RemoveGroupMember(AMemberDN: string);
var
  oGroup: IADSGroup;
  hr: HRESULT;
  memberDN: string;
begin
  if not Self.IsGroup then Exit;

  CoInitialize(nil);
  try
    hr := ADsOpenObject(
      PChar(Self.GetADSIPath_LDAP),
      nil,
      nil,
      ADS_SECURE_AUTHENTICATION or ADS_SERVER_BIND,
      IID_IADsGroup,
      @oGroup
    );

    if Succeeded(hr) then
    begin
      memberDN := ReplaceStr(AMemberDN, '/', '\/');

      if FDomainHostName.IsEmpty
        then memberDN := Format('LDAP://%s', [memberDN])
        else memberDN := Format('LDAP://%s/%s', [FDomainHostName, memberDN]);

      oGroup.Remove(memberDN);
    end else raise Exception.Create(ADSIErrorToString);
  finally
    CoUnInitialize;
  end;
end;

function TADObjectHelper.Rename(ANewName: string): Boolean;
var
  Obj: IADs;
  objCont: IADsContainer;
  hr: HRESULT;
  newRDN: string;
begin
  Result := False;

  CoInitialize(nil);

  try
    hr := ADsOpenObject(
      PChar(Self.GetADSIPath_LDAP),
      nil,
      nil,
      ADS_SECURE_AUTHENTICATION or ADS_SERVER_BIND,
      IID_IADs,
      @Obj
    );

    if Succeeded(hr) then
    begin
      hr := ADsOpenObject(
        PChar(Obj.Parent),
        nil,
        nil,
        ADS_SECURE_AUTHENTICATION or ADS_SERVER_BIND,
        IID_IADsContainer,
        @objCont
      );

      if Succeeded(hr) then
      begin
        newRDN := Format('CN=%s', [ADEscapeReservedCharacters(ANewName)]);
        Obj := objCont.MoveHere(
          Self.GetADSIPath_LDAP,
          newRDN
        ) as IADs;
        Obj.GetInfo;

        Self.Clear;
        Self.distinguishedName := Obj.Get('distinguishedName');
      end else raise Exception.Create(ADSIErrorToString);
    end else raise Exception.Create(ADSIErrorToString);

    Result := True;
  finally
    CoUninitialize;
  end;
end;

function TADObjectHelper.Rename(ALDAP: PLDAP; ANewName: string): Boolean;
var
  dnParent: string;
  newRDN: AnsiString;
  returnCode: ULONG;
begin
  Result := False;

  dnParent := Self.ParentDistinguishedName;
  newRDN := Format('CN=%s', [ADEscapeReservedCharacters(ANewName)]);

  try
    returnCode := ldap_rename_ext_s(
      ALDAP,
      PAnsiChar(AnsiString(Self.distinguishedName)),
      PAnsiChar(AnsiString(newRDN)),
      nil,
      1,
      nil,
      nil
    );

    if returnCode <> LDAP_SUCCESS
      then raise Exception.Create(ldap_err2string(returnCode));

    Self.Clear;
    Self.distinguishedName := Format('%s,%s', [newRDN, dnParent]);
    Result := True;
  finally

  end;
end;

function TADObjectHelper.SetUserPassword(ALDAP: PLDAP; APassword: string;
  AChangeOnLogon, AUnblock: Boolean): Boolean;
var
  ldapBase: AnsiString;
  ldapPwd: string;
  ldapMod: PLDAPMod;
  ldapModArray: array of PLDAPMod;
  ldapUnicodePwd: berval;
  ldapUnicodePwdValues: array of PLDAPBerVal;

  binUnicodePwd: AnsiString;
  bvUnicodePwd: berval;
  valUnicodePwd: array of PLDAPBerVal;

  binPwdLastSet: AnsiString;
  bvPwdLastSet: berval;
  valPwdLastSet: array of PLDAPBerVal;

  binLockoutTime: AnsiString;
  bvLockoutTime: berval;
  valLockoutTime: array of PLDAPBerVal;

  ldapLockoutTime: PAnsiChar;
  ldapLockoutTimeValues: array of PAnsiChar;
  returnCode: ULONG;
  i: Integer;
begin
  { Изменять пароль средствами LDAP довольно проблематично, }
  { т.к. необходимо соблюсти массу условий по безопасности: }
  { https://msdn.microsoft.com/en-us/library/cc223247.aspx  }
  { Короче, код ниже должен работать (по идее :D ), если    }
  { правильно насторить TLS/SSL/SASL на КД и подключение по }
  { LDAP. Я не проверил, т.к. не хотелось возиться с        }
  { настройками. При изменени пароля "вываливается"         }
  { исключение LDAP_UNWILLING_TO_PERFORM. Стоит отметить,   }
  { что запрос на смену пароля при первом входе и           }
  { разблокировка учетной записи работают без проблем,      }
  { просто закомментируйте блок "Изменение пароля".         }

  Result := False;

  if not Self.IsUser
    then raise Exception.Create('Объект должен принадлежать типу "User"');

  ldapBase := Self.distinguishedName;
  ldapPwd := UTF16LE(APassword);
  SetLength(ldapModArray, 1);

  { Изменение пароля }
  SetLength(valUnicodePwd, 2);

  binUnicodePwd := AnsiString(ldapPwd);

  with bvPwdLastSet do
  begin
    bv_len := Length(binUnicodePwd);  //или Length(binUnicodePwd) * SizeOf(WCHAR)?
    bv_val := PAnsiChar(binUnicodePwd);
  end;
  valUnicodePwd[0] := @bvUnicodePwd;

  New(ldapMod);
  with ldapMod^ do
  begin
    mod_op     := LDAP_MOD_REPLACE or LDAP_MOD_BVALUES;
    mod_type   := 'unicodePwd';
    modv_bvals := @valUnicodePwd[0];
  end;

  SetLength(ldapModArray, Length(ldapModArray) + 1);
  ldapModArray[High(ldapModArray) - 1] := ldapMod;

  { Запрос на смену пароля при первом входе }
  if AChangeOnLogon then
  begin
    SetLength(valPwdLastSet, 2);

    binPwdLastSet := '0';

    with bvPwdLastSet do
    begin
      bv_len := Length(binPwdLastSet);
      bv_val := PAnsiChar(binPwdLastSet);
    end;
    valPwdLastSet[0] := @bvPwdLastSet;

    New(ldapMod);
    with ldapMod^ do
    begin
      mod_op     := LDAP_MOD_REPLACE or LDAP_MOD_BVALUES;
      mod_type   := 'pwdLastSet';
      modv_bvals := @valPwdLastSet[0];
    end;

    SetLength(ldapModArray, Length(ldapModArray) + 1);
    ldapModArray[High(ldapModArray) - 1] := ldapMod;
  end;

  { Разблокировать учетную запись }
  if AUnblock then
  begin
    SetLength(valLockoutTime, 2);

    binLockoutTime := '0';

    with bvLockoutTime do
    begin
      bv_len := Length(binLockoutTime);
      bv_val := PAnsiChar(binLockoutTime);
    end;
    valLockoutTime[0] := @bvLockoutTime;

    New(ldapMod);
    with ldapMod^ do
    begin
      mod_op     := LDAP_MOD_REPLACE or LDAP_MOD_BVALUES;
      mod_type   := 'lockoutTime';
      modv_bvals := @valLockoutTime[0];
    end;

    SetLength(ldapModArray, Length(ldapModArray) + 1);
    ldapModArray[High(ldapModArray) - 1] := ldapMod;
  end;

  ldapModArray[High(ldapModArray)] := nil;

  try
    returnCode := ldap_modify_s(
      ALDAP,
      PAnsiChar(ldapBase),
      @ldapModArray[0]
    );

    if returnCode <> LDAP_SUCCESS
      then raise Exception.Create(ldap_err2string(returnCode));

    Result := True;
  finally
    for i := High(ldapModArray) downto Low(ldapModArray) do
      if Assigned(ldapModArray[i]) then Dispose(ldapModArray[i]);
  end;
end;

function TADObjectHelper.SetGroupDescription(AValue: string): Boolean;
var
  Obj: IADs;
  hr: HRESULT;
begin
  Result := False;

  if not Self.IsGroup
    then raise Exception.Create('Объект должен принадлежать типу "Group"');

  CoInitialize(nil);

  try
    hr := ADsOpenObject(
      PChar(Self.GetADSIPath_LDAP),
      nil,
      nil,
      ADS_SECURE_AUTHENTICATION or ADS_SERVER_BIND,
      IID_IADs,
      @Obj
    );

    if Succeeded(hr) then
    begin
      if AValue.IsEmpty
        then Obj.PutEx(ADS_PROPERTY_CLEAR, 'description', Null)
        else Obj.Put('description', AValue);
      Obj.SetInfo;
    end else raise Exception.Create(ADSIErrorToString);

    Result := True;
  finally
    CoUninitialize;
  end;
end;

function TADObjectHelper.SetGroupDescription(ALDAP: PLDAP;
  AValue: string): Boolean;
var
  ldapBase: AnsiString;
  ldapValue: AnsiString;
  ldapValues: array of PAnsiChar;
  ldapMod: PLDAPMod;
  ldapModArray: array of PLDAPMod;
  returnCode: ULONG;
begin
  Result := False;

  if not Self.IsGroup
    then raise Exception.Create('Объект должен принадлежать типу "Group"');

  ldapBase := Self.distinguishedName;

  SetLength(ldapModArray, 2);
  New(ldapMod);

  ldapModArray[0] := ldapMod;
  ldapModArray[1] := nil;
  SetLength(ldapValues, 2);

  ldapMod^.mod_op := LDAP_MOD_REPLACE;
  ldapMod^.mod_type := PAnsiChar('description');
  if AValue.IsEmpty
    then ldapMod^.modv_strvals := nil
    else ldapMod^.modv_strvals := @ldapValues[0];

  ldapValue := AValue;
  ldapValues[0] := PAnsiChar(ldapValue);
  ldapValues[1] := nil;

  try
    returnCode := ldap_modify_s(
      ALDAP,
      PAnsiChar(ldapBase),
      @ldapModArray[0]
    );

    if returnCode <> LDAP_SUCCESS
      then raise Exception.Create(ldap_err2string(returnCode));

    Result := True;
  finally
    Dispose(ldapMod);
  end;
end;

function TADObjectHelper.SetUserPassword(ANewPassword: string;
  AChangeOnLogon, AUnblock: Boolean): Boolean;
var
  Obj: IADsUser;
  hr: HRESULT;
  oleVar: OleVariant;
begin
  Result := False;

  if not Self.IsUser
    then raise Exception.Create('Объект должен принадлежать типу "User"');

  CoInitialize(nil);

  try
    hr := ADsOpenObject(
      PChar(Self.GetADSIPath_LDAP),
      nil,
      nil,
      ADS_SECURE_AUTHENTICATION or ADS_SERVER_BIND,
      IID_IADsUser,
      @Obj
    );

    if Succeeded(hr) then
    begin
      Obj.SetPassword(ANewPassword);

      if AChangeOnLogon then
      begin
        oleVar := 0;
        Obj.Put('pwdLastSet', oleVar);
        VariantClear(oleVar);
      end;

      if AUnblock then
      begin
        oleVar := 0;
        Obj.Put('lockoutTime', oleVar);
        VariantClear(oleVar);
      end;

      Obj.SetInfo;
      Result := True;
    end else raise Exception.Create(ADSIErrorToString);
  finally
    CoUninitialize;
  end;
end;

function TADObjectHelper.TimestampToDateTime(
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

function TADObjectHelper.UTF16LE(AValue: string): string;
const
  B64 = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/';
var
  pwd: string;
  i: Integer;
  j: Integer;
  c: Char;
  sRes: string;
  sHex: string;
  sWord: string;
  intLen: Integer;
  intTerm: Integer;
  lngValue: Integer;
  lngTemp: Integer;
  lngChar: Integer;
  s64: string;
begin
  Result := '';

  if AValue.IsEmpty then Exit;

  pwd := Format('"%s"', [AValue]);

  { Convert a text string into a string of unicode hexadecimal bytes. }
  for i := 1 to Length(pwd) do
  begin
    c := pwd[i];
    sHex := sHex + Format('%.2x00', [Ord(c)]);
  end;

  intLen := Length(sHex);

  { Pad with zeros to multiple of 3 bytes. }
  intTerm := intLen mod 6;
  case intTerm of
    2: begin
      sHex := sHex + '0000';
      intLen := intLen + 4;
    end;

    4: begin
      sHex := sHex + '00';
      intLen := intLen + 2;
    end;
  end;

  { Parse into groups of 3 hex bytes. }
  i := 0;
  j := 1;
  sWord := '';

  while j <= intLen do
  begin
    i := i + 1;
    sWord := sWord + Copy(sHex, j, 2);
    if i = 3 then
    begin
      { Convert 3 8-bit bytes into 4 6-bit characters. }
      lngValue := StrToInt('$' + sWord);

      lngTemp := Trunc(lngValue / 64);
      lngChar := lngValue - (64 * lngTemp);
      s64 := Copy(B64, lngChar + 1, 1);
      lngValue := lngTemp;

      lngTemp := Trunc(lngValue / 64);
      lngChar := lngValue - (64 * lngTemp);
      s64 := Copy(B64, lngChar + 1, 1) + s64;
      lngValue := lngTemp;

      lngTemp := Trunc(lngValue / 64);
      lngChar := lngValue - (64 * lngTemp);
      s64 := Copy(B64, lngChar + 1, 1) + s64;

      s64 := Copy(B64, lngTemp + 1, 1) + s64;

      sRes := sRes + s64;
      i := 0;
      sWord := ''
    end;
    j := j + 2;
  end;

  {  Account for padding. }
  case intTerm of
    2: Result := Copy(sRes, 1, Length(sRes) - 2) + '==';
    4: Result := Copy(sRes, 1, Length(sRes) - 1) + '=';
    else Result := sRes;
  end;
end;

procedure TADObjectHelper.WriteProperties(ASearchRes: IDirectorySearch;
  ASearchHandle: PHandle; AAttrCat: TAttrCatalog; ADomainHostName: string; AMaxPwdAge: Int64);
var
  i: Integer;
  hRes: HRESULT;
  col: ADS_SEARCH_COLUMN;
  attr: TADAttribute;
  memStream: TMemoryStream;
  strStream: TStringStream;
  d: TDateTime;
begin
  Self.Clear;
  Self.DomainHostName := ADomainHostName;

  for i := 0 to AAttrCat.Count - 1 do
  begin
    attr := AAttrCat[i]^;
    hRes := ASearchRes.GetColumn(ASearchHandle, PWideChar(string(attr.Name)), col);
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
        Self.FillEventList(strStream);
      except

      end;
      strStream.Free;
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
          Self,
          string(attr.ObjProperty),
          Self.TimestampToDateTime(col.pAdsvalues^.__MIDL____MIDL_itf_ads_0000_00000000.LargeInteger)
        );
      end;

      1: begin
        d := Self.TimestampToDateTime(col.pAdsvalues^.__MIDL____MIDL_itf_ads_0000_00000000.LargeInteger);
        if d > 0
          then SetFloatProp(Self, string(attr.ObjProperty), IncSecond(d, AMaxPwdAge))
          else SetFloatProp(Self, string(attr.ObjProperty), 0)
      end;

      2..4: begin                { badPwdCount, groupType, userAccountControl }
        SetOrdProp(
          Self,
          string(attr.ObjProperty),
          col.pAdsvalues^.__MIDL____MIDL_itf_ads_0000_00000000.Integer
        );
      end;

      5: begin                   { objectSid }
        SetPropValue(
          Self,
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
          Self.thumbnailPhoto.LoadFromStream(memStream);
        except

        end;
        memStream.Free;
      end;

      7: begin                   { distinguishedName }
        SetPropValue(
          Self,
          string(attr.ObjProperty),
          string(col.pAdsvalues^.__MIDL____MIDL_itf_ads_0000_00000000.CaseIgnoreString)
        );
      end;
                                   { primaryGroupToken }
      8: begin
        SetOrdProp(
          Self,
          string(attr.ObjProperty),
          col.pAdsvalues^.__MIDL____MIDL_itf_ads_0000_00000000.Integer
        );
      end

      else begin                 { Все текстовые атрибуты }
        SetPropValue(
          Self,
          string(attr.ObjProperty),
          string(col.pAdsvalues^.__MIDL____MIDL_itf_ads_0000_00000000.CaseIgnoreString)
        );
      end;
    end;

    ASearchRes.FreeColumn(col);
  end;

  { Заполняем свойства для плавающего окна }
  hRes := ASearchRes.GetColumn(ASearchHandle, PWideChar('displayName'), col);
  if Succeeded(hRes) then SetPropValue(
    Self,
    'displayName',
    string(col.pAdsvalues^.__MIDL____MIDL_itf_ads_0000_00000000.CaseIgnoreString)
  );
  ASearchRes.FreeColumn(col);

  hRes := ASearchRes.GetColumn(ASearchHandle, PWideChar('title'), col);
  if Succeeded(hRes) then SetPropValue(
    Self,
    'title',
    string(col.pAdsvalues^.__MIDL____MIDL_itf_ads_0000_00000000.CaseIgnoreString)
  );
  ASearchRes.FreeColumn(col);

  hRes := ASearchRes.GetColumn(ASearchHandle, PWideChar('physicalDeliveryOfficeName'), col);
  if Succeeded(hRes) then
  SetPropValue(
    Self,
    'physicalDeliveryOfficeName',
    string(col.pAdsvalues^.__MIDL____MIDL_itf_ads_0000_00000000.CaseIgnoreString)
  );
  ASearchRes.FreeColumn(col);
end;

procedure TADObjectHelper.WriteProperties(ALDAP: PLDAP; AEntry: PLDAPMessage;
  AAttrCat: TAttrCatalog; ADomainHostName: string; AMaxPwdAge: Int64);
var
  ldapValues: PPAnsiChar;
  ldapBinValues: PPLDAPBerVal;
  attr: TADAttribute;
  i: Integer;
  dn: PAnsiChar;
  memStream: TMemoryStream;
  strStream: TStringStream;
  d: TDateTime;
begin
  Self.Clear;
  Self.DomainHostName := ADomainHostName;

  for i := 0 to AAttrCat.Count - 1 do
  begin
    attr := AAttrCat[i]^;
    if attr.ObjProperty = 'nearestEvent' then
    begin
      ldapBinValues := ldap_get_values_len(ALDAP, AEntry, PAnsiChar(AnsiString(attr.Name)));
      if (ldapBinValues <> nil) and (ldapBinValues^.bv_len > 0) then
      begin
        strStream := TStringStream.Create;
        try
          strStream.Write(
            ldapBinValues^.bv_val^,
            ldapBinValues^.bv_len
          );
          strStream.Seek(0, soFromBeginning);
          FillEventList(strStream);
        except

        end;
        strStream.Free;
      end;
      ldap_value_free_len(ldapBinValues);
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
        ldapBinValues := ldap_get_values_len(ALDAP, AEntry, PAnsiChar(AnsiString(attr.Name)));
        if (ldapBinValues <> nil) and (ldapBinValues^.bv_len > 0)
          then SetFloatProp(Self, string(attr.ObjProperty), TimestampToDateTime(ldapBinValues^.bv_val));
        ldap_value_free_len(ldapBinValues);
      end;

      1: begin                   { pwdLastSet }
        ldapBinValues := ldap_get_values_len(ALDAP, AEntry, PAnsiChar(AnsiString(attr.Name)));
        if (ldapBinValues <> nil) and (ldapBinValues^.bv_len > 0) then
        begin
          d := Self.TimestampToDateTime(ldapBinValues^.bv_val);
          if d > 0
            then SetFloatProp(Self, string(attr.ObjProperty), IncSecond(d, AMaxPwdAge))
            else SetFloatProp(Self, string(attr.ObjProperty), 0)
        end;
        ldap_value_free_len(ldapBinValues);
      end;

      2..4: begin                { badPwdCount, groupType, userAccountControl }
        ldapBinValues := ldap_get_values_len(ALDAP, AEntry, PAnsiChar(AnsiString(attr.Name)));
        if (ldapBinValues <> nil) and (ldapBinValues^.bv_len > 0)
          then SetPropValue(Self, string(attr.ObjProperty), StrToIntDef(ldapBinValues^.bv_val, 0));
        ldap_value_free_len(ldapBinValues);
      end;

      5: begin                   { objectSid }
        ldapBinValues := ldap_get_values_len(ALDAP, AEntry, PAnsiChar(AnsiString(attr.Name)));
        if (ldapBinValues <> nil) and (ldapBinValues^.bv_len > 0)
          then SetPropValue(Self, string(attr.ObjProperty), SIDToString(ldapBinValues^.bv_val));
        ldap_value_free_len(ldapBinValues);
      end;

      6: begin                   { thumbnailPhoto }
        ldapBinValues := ldap_get_values_len(ALDAP, AEntry, PAnsiChar(AnsiString(attr.Name)));
        if (ldapBinValues <> nil) and (ldapBinValues^.bv_len > 0) then
        begin
          memStream := TMemoryStream.Create;
          try
            memStream.Write(
              ldapBinValues^.bv_val^,
              ldapBinValues^.bv_len
            );
            memStream.Seek(0, soFromBeginning);
            Self.thumbnailPhoto.LoadFromStream(memStream);
          except

          end;
          memStream.Free;
        end;
        ldap_value_free_len(ldapBinValues);
      end;

      7: begin                   { distinguishedName }
        dn := ldap_get_dn(ALDAP, AEntry);
        if dn <> nil then SetPropValue(Self, string(attr.ObjProperty), string(dn));
        ldap_memfree(dn);
      end;

      8: begin                  { primaryGroupToken }
        ldapBinValues := ldap_get_values_len(ALDAP, AEntry, PAnsiChar(AnsiString(attr.Name)));
        if (ldapBinValues <> nil) and (ldapBinValues^.bv_len > 0)
          then SetPropValue(Self, string(attr.ObjProperty), StrToIntDef(ldapBinValues^.bv_val, 0));
        ldap_value_free_len(ldapBinValues);
      end;

      else begin                 { Все текстовые атрибуты }
        ldapValues := ldap_get_values(ALDAP, AEntry, PAnsiChar(AnsiString(attr.Name)));
        if ldap_count_values(ldapValues) > 0
          then SetPropValue(Self, string(attr.ObjProperty), string(AnsiString(ldapValues^)));
        ldap_value_free(ldapValues);
      end;
    end;
  end;

  { Заполняем свойства для плавающего окна }
  ldapValues := ldap_get_values(ALDAP, AEntry, PAnsiChar('displayName'));
  if ldap_count_values(ldapValues) > 0
    then SetPropValue(Self, 'displayName', string(AnsiString(ldapValues^)));
  ldap_value_free(ldapValues);

  ldapValues := ldap_get_values(ALDAP, AEntry, PAnsiChar('title'));
  if ldap_count_values(ldapValues) > 0
    then SetPropValue(Self, 'title', string(AnsiString(ldapValues^)));
  ldap_value_free(ldapValues);

  ldapValues := ldap_get_values(ALDAP, AEntry, PAnsiChar('physicalDeliveryOfficeName'));
  if ldap_count_values(ldapValues) > 0
    then SetPropValue(Self, 'physicalDeliveryOfficeName', string(AnsiString(ldapValues^)));
  ldap_value_free(ldapValues);
end;

end.
