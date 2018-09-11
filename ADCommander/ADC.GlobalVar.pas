unit ADC.GlobalVar;

interface

uses
  System.IniFiles, System.SysUtils, Winapi.Windows, System.Generics.Collections,
  tdLDAPEnum, ActiveDs_TLB, ADC.Types, ADC.ADObject, ADC.ADObjectList, ADC.Attributes,
  JvCipher, ADC.LDAP, tdADSIEnum, JwaRpcdce, ADC.DC, ADC.ScriptBtn, System.SyncObjs,
  tdDataExport;

var
  Cipher: TJvVigenereCipher;
  FileName_AttrCat: TFileName;
  FileName_ScriptButtons: TFileName;
  FileName_Ini: TFileName;
  List_Attributes: TAttrCatalog;
  List_ScriptButtons: TADScriptButtonList;
  List_ObjFull: TADObjectList<TADObject>;
  List_Obj: TADObjectList<TADObject>;
  SelectedDC: TDCInfo;

  ADSIBinding: IADs;
  LDAPBinding: PLDAP;
  ObjEnum_LDAP: TLDAPEnum;
  ObjEnum_ADSI: TADSIEnum;
  ObjExport: TADCExporter;

  csEnumaration: TCriticalSection;
  csQuickMessage: TCriticalSection;
  csExport: TCriticalSection;

  apAPI: Byte;
  apEventsDir,
  apEventsAttr,
  apDefaultPassword: string;
  apMinimizeAtAutorun,
  apMinimizeToTray,
  apMinimizeAtClose,
  apRunSingleInstance,
  apUseDefaultPassword: Boolean;
  apRunOption,
  apEventsStorage,
  apMouseLMBOption: Byte;
  apFilterObjects: Word;

  apAttrCat_LogonPCFieldID: ShortInt;

  apFWND_Display: Boolean;
  apFWND_DisplayDelay: Integer;
  apFWND_DisplayDuration: Integer;
  apFWND_DisplayActivity: Boolean;
  apFWND_DisplayStyle: TFloatingWindowStyle;

  apDMRC_Executable,
  apDMRC_User,
  apDMRC_Password,
  apDMRC_Domain: string;
  apDMRC_Authorization: SmallInt;
  apDMRC_Connection: Byte;
  apDMRC_Driver,
  apDMRC_AutoConnect: Boolean;

  apPsE_Executable,
  apPsE_User,
  apPsE_Password: string;
  apPsE_WaitingTime,
  apPsE_DisplayTime: Integer;
  apPsE_ShowOutput,
  apPsE_RunAs: Boolean;

  gvUserName: string;
  gvDomainName: string;

  procedure WriteSettings(AIniFile: TFileName);
  procedure ReadSettings(AIniFile: TFileName);

implementation

procedure WriteSettings(AIniFile: TFileName);
var
  Ini: TIniFile;
begin
  Ini := TIniFile.Create(AIniFile);

  { Общие параметры }
  Ini.WriteBool(INI_SECTION_GENERAL, 'MinimizeAtAutorun', apMinimizeAtAutorun);
  Ini.WriteBool(INI_SECTION_GENERAL, 'MinimizeToTray', apMinimizeToTray);
  Ini.WriteBool(INI_SECTION_GENERAL, 'MinimizeAtClose', apMinimizeAtClose);
  Ini.WriteBool(INI_SECTION_GENERAL, 'RunSingleInstance', apRunSingleInstance);
  Ini.WriteInteger(INI_SECTION_GENERAL, 'ExecParam', apRunOption);
  Ini.WriteInteger(INI_SECTION_GENERAL, 'API', apAPI);


  { Поля и аттрибуты }
  Ini.WriteInteger(INI_SECTION_ATTRIBUTES, 'LogonPCFieldID', apAttrCat_LogonPCFieldID);

  { Контроль событий пользователя }
  Ini.WriteInteger(INI_SECTION_EVENTS, 'Storage', apEventsStorage);
  Ini.WriteString(INI_SECTION_EVENTS, 'Attribute', apEventsAttr);
  Ini.WriteString(INI_SECTION_EVENTS, 'Directory', apEventsDir);

  { Редактор }
  Ini.WriteBool(INI_SECTION_EDITOR, 'UseDefaultPassword', apUseDefaultPassword);
  Ini.WriteString(INI_SECTION_EDITOR, 'DefaultPassword',
    Cipher.EncodeString('Aa123852', apDefaultPassword)
  );

  { Плавающее окно }
  Ini.WriteBool(INI_SECTION_FLOATING, 'Display', apFWND_Display);
  Ini.WriteInteger(INI_SECTION_FLOATING, 'DisplayDelay', apFWND_DisplayDelay);
  Ini.WriteInteger(INI_SECTION_FLOATING, 'DisplayDuration', apFWND_DisplayDuration);
  Ini.WriteBool(INI_SECTION_FLOATING, 'DisplayActivity', apFWND_DisplayActivity);
  Ini.WriteInteger(INI_SECTION_FLOATING, 'Style', Integer(apFWND_DisplayStyle));

  { Мышь }
  Ini.WriteInteger(INI_SECTION_MOUSE, 'LeftButtonOption', apMouseLMBOption);

  { DameWare MRC}
  Ini.WriteString(INI_SECTION_DMRC, 'Executable', apDMRC_Executable);
  Ini.WriteInteger(INI_SECTION_DMRC, 'Authorization', apDMRC_Authorization);
  Ini.WriteString(INI_SECTION_DMRC, 'Username',
    Cipher.EncodeString('Aa123852', apDMRC_User)
  );
  Ini.WriteString(INI_SECTION_DMRC, 'Password',
    Cipher.EncodeString('Aa123852', apDMRC_Password)
  );
  Ini.WriteString(INI_SECTION_DMRC, 'Domain', apDMRC_Domain);
  Ini.WriteInteger(INI_SECTION_DMRC, 'Connection', apDMRC_Connection);
  Ini.WriteBool(INI_SECTION_DMRC, 'MirrorDriver', apDMRC_Driver);
  Ini.WriteBool(INI_SECTION_DMRC, 'AutoConnect', apDMRC_AutoConnect);

  { PsExec }
  Ini.WriteString(INI_SECTION_PSEXEC, 'Executable', apPsE_Executable);
  Ini.WriteInteger(INI_SECTION_PSEXEC, 'WaitingTime', apPsE_WaitingTime);
  Ini.WriteInteger(INI_SECTION_PSEXEC, 'DisplayTime', apPsE_DisplayTime);
  Ini.WriteBool(INI_SECTION_PSEXEC, 'ShowOutput', apPsE_ShowOutput);
  Ini.WriteBool(INI_SECTION_PSEXEC, 'RunAs', apPsE_RunAs);
  Ini.WriteString(INI_SECTION_PSEXEC, 'Username',
    Cipher.EncodeString('Aa123852', apPsE_User)
  );
  Ini.WriteString(INI_SECTION_PSEXEC, 'Password',
    Cipher.EncodeString('Aa123852', apPsE_Password)
  );

  Ini.Free;
end;

procedure ReadSettings(AIniFile: TFileName);
var
  Ini: TIniFile;
  S: string;
begin
  Ini := TIniFile.Create(AIniFile);

  { Общие параметры }
  apMinimizeAtAutorun := Ini.ReadBool(INI_SECTION_GENERAL, 'MinimizeAtAutorun', False);
  apMinimizeToTray := Ini.ReadBool(INI_SECTION_GENERAL, 'MinimizeToTray', False);
  apMinimizeAtClose := Ini.ReadBool(INI_SECTION_GENERAL, 'MinimizeAtClose', False);
  apRunSingleInstance := Ini.ReadBool(INI_SECTION_GENERAL, 'RunSingleInstance', True);
  apRunOption := Ini.ReadInteger(INI_SECTION_GENERAL, 'ExecParam', EXEC_NEW_INSTANCE);
  apAPI := Ini.ReadInteger(INI_SECTION_GENERAL, 'API', ADC_API_LDAP);

  { Поля и аттрибуты }
  apAttrCat_LogonPCFieldID := Ini.ReadInteger(INI_SECTION_ATTRIBUTES, 'LogonPCFieldID', -1);

  { Контроль событий пользователя }
  apEventsStorage := Ini.ReadInteger(INI_SECTION_EVENTS, 'Storage', CTRL_EVENT_STORAGE_DISK);
  apEventsAttr := Ini.ReadString(INI_SECTION_EVENTS, 'Attribute', '');
  apEventsDir := Ini.ReadString(INI_SECTION_EVENTS, 'Directory', '');

  { Редактор }
  apUseDefaultPassword := Ini.ReadBool(INI_SECTION_EDITOR, 'UseDefaultPassword', False);
  S := Ini.ReadString(INI_SECTION_EDITOR, 'DefaultPassword', '');
  if S.IsEmpty
    then apDefaultPassword := ''
    else apDefaultPassword := Cipher.DecodeString('Aa123852', S);

  { Плавающее окно }
  apFWND_Display := Ini.ReadBool(INI_SECTION_FLOATING, 'Display', False);
  apFWND_DisplayDelay := Ini.ReadInteger(INI_SECTION_FLOATING, 'DisplayDelay', 500);
  apFWND_DisplayDuration := Ini.ReadInteger(INI_SECTION_FLOATING, 'DisplayDuration', 3000);
  apFWND_DisplayActivity := Ini.ReadBool(INI_SECTION_FLOATING, 'DisplayActivity', False);
  apFWND_DisplayStyle := TFloatingWindowStyle(Ini.ReadInteger(INI_SECTION_FLOATING, 'Style', Integer(fwsSkype)));

  { Мышь }
  apMouseLMBOption := Ini.ReadInteger(INI_SECTION_MOUSE, 'LeftButtonOption', MOUSE_LMB_OPTION1);

  { DameWare MRC}
  apDMRC_Executable := Ini.ReadString(INI_SECTION_DMRC, 'Executable', '');
  apDMRC_Authorization := Ini.ReadInteger(INI_SECTION_DMRC, 'Authorization', DMRC_AUTH_WINLOGON);
  S := Ini.ReadString(INI_SECTION_DMRC, 'Username', '');
  if S.IsEmpty
    then apDMRC_User := ''
    else apDMRC_User := Cipher.DecodeString('Aa123852', S);
  S := Ini.ReadString(INI_SECTION_DMRC, 'Password', '');
  if S.IsEmpty
    then apDMRC_Password := ''
    else apDMRC_Password := Cipher.DecodeString('Aa123852', S);
  apDMRC_Domain := Ini.ReadString(INI_SECTION_DMRC, 'Domain', '');
  apDMRC_Connection := Ini.ReadInteger(INI_SECTION_DMRC, 'Connection', DMRC_CONNECTION_MRC);
  apDMRC_Driver := Ini.ReadBool(INI_SECTION_DMRC, 'MirrorDriver', False);
  apDMRC_AutoConnect := Ini.ReadBool(INI_SECTION_DMRC, 'AutoConnect', False);

  { PsExec }
  apPsE_Executable := Ini.ReadString(INI_SECTION_PSEXEC, 'Executable', '');
  apPsE_WaitingTime := Ini.ReadInteger(INI_SECTION_PSEXEC, 'WaitingTime', 1);
  apPsE_DisplayTime := Ini.ReadInteger(INI_SECTION_PSEXEC, 'DisplayTime', 0);
  apPsE_ShowOutput := Ini.ReadBool(INI_SECTION_PSEXEC, 'ShowOutput', False);
  apPsE_RunAs := Ini.ReadBool(INI_SECTION_PSEXEC, 'RunAs', False);
  S := Ini.ReadString(INI_SECTION_PSEXEC, 'Username', '');
  if S.IsEmpty
    then apPsE_User := ''
    else apPsE_User := Cipher.DecodeString('Aa123852', S);
  S := Ini.ReadString(INI_SECTION_PSEXEC, 'Password', '');
  if S.IsEmpty
    then apPsE_Password := ''
    else apPsE_Password := Cipher.DecodeString('Aa123852', S);

  Ini.Free;
end;

end.
