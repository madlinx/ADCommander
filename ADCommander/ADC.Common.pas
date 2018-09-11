unit ADC.Common;

interface

uses
  System.SysUtils, Winapi.Windows, System.Classes, Vcl.Dialogs, System.Variants,
  System.IniFiles, Vcl.Graphics, System.StrUtils, System.RegularExpressions,
  Winapi.Messages, Winapi.TlHelp32, Winapi.PsAPI, Vcl.Forms, Winapi.ActiveX,
  Vcl.ComCtrls, ActiveDs_TLB, JwaLmAccess, JwaLmApiBuf, JwaDSGetDc, JwaActiveDS,
  ADC.NetInfo, Winapi.Winsock2, ADC.Types, System.DateUtils, System.Types, System.TypInfo,
  Winapi.ShlObj, System.AnsiStrings, ADC.LDAP, JwaRpcDce, ADC.AD, ADC.Attributes;

function ReduceBrightness(AColor: TColor; Percent: Byte): TColor;
function IncreaseBrightness(AColor: TColor; Percent: Byte): TColor;
function GetUserEventColor(EventDate: TDate; DefaultColor: TColor = clBtnFace): TColor;

function TempDirPath: string;
function GetSpecialFolderPath(AFolderID: DWORD): string;
function IsCreateFileElevationRequired(APath: string): Boolean;
function DBProviderExists(Provider: string): Boolean;
procedure FreeThreadManually(AThread: TThread);
function TranslitCyrillicToLatin(const AInput: string): string;
function GetUserLogonPCName(AObj: TObject; AAttrList: TAttrCatalog; AAttrID: Integer): string;
function AppInstanceExists(AClassName: string): Boolean; overload;
function AppInstanceExists(AClassName: string; AIniFile: TFileName): Boolean; overload;
function SendMessageToWindow(AClassName, AMessage: string): DWORD;
function GetTreeNodePath(ANode: TTreeNode; var ARootPath: string;
  ASeparator: string = '/'): string;
function GetTextWidthInPixels(const AText: string; ATextFont: TFont): Integer;
function GetTextHeightInPixels(const AText: string; ATextFont: TFont): Integer;
function GetFileInfo(const FileName: TFileName; Information: string): string;
function GetFileVersionNumber(const FileName: TFileName;
  var MajorVersion, MinorVersion, BuildNumber, RevisionNumber: DWORD): Boolean;
function ADSIErrorToString: string;
function SortEvents(Item1, Item2: Pointer): Integer;
function SIDToString(objSID: PSID): string; overload;
function SIDToString(objSID: OleVariant): string; overload;
function ADEscapeReservedCharacters(AValue: string): string;
function DateTimeToADDate(ADate: TDateTime): ActiveDs_TLB._LARGE_INTEGER;
function ADDateToDateTime(ADDate: DATE_TIME): System.TDateTime; overload;
function ADDateToDateTime(ADDate: ActiveDs_TLB._LARGE_INTEGER): System.TDateTime; overload;
function ADDateToDateTime(ADDate: OleVariant): System.TDateTime; overload;
function CalcPasswordExpiration(const PwdLastSet: ActiveDs_TLB._LARGE_INTEGER;
  MaxPwdAge: Integer): System.TDateTime;
function ADCheckPasswordComplexity(ADomainName, APassword: string): Boolean;
procedure ADEnumDomainControllers(const outDCList: TStrings);
procedure ADEnumContainers(ARootDSE: IADs; const outList: TStrings); overload;
procedure ADEnumContainers(ALDAP: PLDAP; const outList: TStrings); overload;
function DameWareMRC_Connect(const Executable, MachineName: string; key_a: Integer;
  key_u, key_p, key_d: string; key_md, key_r, AutoConnect, ViewOnly: Boolean): Boolean;
function EncodeIP(AIP: string): Cardinal;
function DecodeIP(AIP: Cardinal): string;
procedure GetIPAddress(AClient: string; out AInfo: PIPAddr);
procedure GetDHCPInfo(AClient: string; out AInfo: PDHCPInfo);
procedure GetDHCPInfoV4(AClient: string; out AInfo: PDHCPInfo);
procedure FreeDHCPClientInfoMemory(pClientInfo: LPDHCP_CLIENT_INFO); overload;
procedure FreeDHCPClientInfoMemory(pClientInfo: LPDHCP_CLIENT_INFO_PB); overload;
procedure ServerBinding(ADcDnsName: string; out ALDAP: PLDAP;
  AOnException: TExceptionProc); overload;
procedure ServerBinding(ADcName: string; ARootDSE: Pointer;
  AOnException: TExceptionProc); overload;
function ADCreateOU(ALDAP: PLDAP; AContainer: string; ANewOU: string): string; overload;
function ADCreateOU(ARootDSE: IADS; AContainer: string; ANewOU: string): string; overload;
function ADCreateOUDS(ARootDSE: IADS; AContainer: string; ANewOU: string): string;
function ADDeleteObject(ALDAP: PLDAP; ADN: string): Boolean; overload;
function ADDeleteObject(ARootDSE: IADS; ADN: string): Boolean; overload;
function ADDeleteObjectDS(ARootDSE: IADS; ADN: string): Boolean; overload;



implementation

function ReduceBrightness(AColor: TColor; Percent: Byte): TColor;
var
  R, G, B: Byte;
  Cl: Integer;
begin
  Cl := ColorToRGB(AColor);
  R := GetRValue(Cl);
  G := GetGValue(Cl);
  B := GetBValue(Cl);
  R := R - MulDiv(R, Percent, 100);
  G := G - MulDiv(G, Percent, 100);
  B := B - MulDiv(B, Percent, 100);
  Result := RGB(R, G, B);
end;

function IncreaseBrightness(AColor: TColor; Percent: Byte): TColor;
var
  R, G, B: Byte;
  Cl: Integer;
begin
  Cl := ColorToRGB(AColor);
  R := GetRValue(Cl);
  G := GetGValue(Cl);
  B := GetBValue(Cl);
  R := R + MulDiv(255 - R, Percent, 100);
  G := G + MulDiv(255 - G, Percent, 100);
  B := B + MulDiv(255 - B, Percent, 100);
  Result := RGB(R, G, B);
end;

function GetUserEventColor(EventDate: TDate; DefaultColor: TColor = clBtnFace): TColor;
begin
  Result := DefaultColor;
  if EventDate > 0 then
  begin
    if DateOf(EventDate) < DateOf(Now) then
    begin
      Result := clRed;
    end else
    if DateOf(EventDate) = DateOf(Now) then
    begin
      Result := clYellow;
    end else
    begin
//    if DaysBetween(DateOf(Now), ctrlDate) <= 1 then Sender.Canvas.Brush.Color := $00E1E1FF else
//    if DaysBetween(DateOf(Now), ctrlDate) <= 3 then Sender.Canvas.Brush.Color := $00CEFFFF;
    end;
  end;
end;

function TempDirPath: string;
var
  Buf: string;
  Len: Cardinal;
begin
  SetLength(Buf, 1024);
  Len := GetTempPath(1023, PChar(Buf));
  SetLength(Buf, Len);
  Result := IncludeTrailingBackslash(Buf);
end;

function GetSpecialFolderPath(AFolderID: DWORD): string;
var
  DirPath: PChar;
begin
  Result := '';
  begin
    DirPath := StrAlloc(MAX_PATH);
    if SHGetSpecialFolderPath(0, DirPath, AFolderID, True) then
    begin
      Result := Format('%s%s', [IncludeTrailingBackslash(string(DirPath)), 'AD Commander']);
      if not DirectoryExists(Result) then
        if not ForceDirectories(Result) then Result := '';
    end;
    StrDispose(DirPath);
  end;
end;

function IsCreateFileElevationRequired(APath: string): Boolean;
var
  fName: string;
  hFile: THandle;
begin
  Result := False;
  fName := IncludeTrailingBackslash(APath) + 'adcmd_test.tmp';

  hFile := CreateFile(
    PChar(fName),
    GENERIC_WRITE,
    0,
    nil,
    CREATE_ALWAYS,
    FILE_ATTRIBUTE_NORMAL or FILE_FLAG_DELETE_ON_CLOSE,
    0
  );

  if hFile = INVALID_HANDLE_VALUE then
  begin
    if GetLastError = ERROR_ACCESS_DENIED
      then Result := True;
  end else CloseHandle(hFile);
end;

function DBProviderExists(Provider: string): Boolean;
var
  CLSID: TGUID;
  hRes: Integer;
begin
  CLSID := TGUID.Empty;
  hRes := CLSIDFromProgID(PChar(Provider), CLSID);
  Result := hRes = 0;
end;

procedure FreeThreadManually(AThread: TThread);
begin
  try
    AThread.Terminate;
    AThread.WaitFor;
    AThread.Free;
    FreeAndNil(AThread);
  except
    AThread := nil;
  end;
end;

function TranslitCyrillicToLatin(const AInput: string): string;
const
  CHAR_LOWER_CASE = 1;
  CHAR_UPPER_CASE = 2;
  AlphabetLC = 'абвгдеёжзийклмнопрстуфхцчшщьыъэюя';
  AlphabetUC = 'АБВГДЕЁЖЗИЙКЛМНОПРСТУФХЦЧШЩЬЫЪЭЮЯ';
  AlphabetLength = Length(AlphabetUC);
  arr: array[CHAR_LOWER_CASE..CHAR_UPPER_CASE, 1..AlphabetLength] of string = (
    (
       'a', 'b', 'v', 'g', 'd', 'e', 'yo', 'zh', 'z', 'i', 'y',
       'k', 'l', 'm', 'n', 'o', 'p', 'r', 's', 't', 'u', 'f',
       'kh', 'ts', 'ch', 'sh', 'shch', '''', 'y', '''', 'e', 'yu', 'ya'
    ),
    (
       'A', 'B', 'V', 'G', 'D', 'E', 'Yo', 'Zh', 'Z', 'I', 'Y',
       'K', 'L', 'M', 'N', 'O', 'P', 'R', 'S', 'T', 'U', 'F',
       'Kh', 'Ts', 'Ch', 'Sh', 'Shch', '''', 'Y', '''', 'E', 'Yu', 'Ya'
    )
  );
var
  i: Integer;
  l: Integer;
  p: Integer;
  d: Byte;
begin
  Result := '';
  l := Length(AInput);
  for i := 1 to l do
  begin
    d := CHAR_LOWER_CASE;
    p := pos(AInput[i], AlphabetLC);
    if p = 0 then
    begin
      p := pos(AInput[i], AlphabetUC);
      d := CHAR_UPPER_CASE;
    end;
    if p <> 0 then
      result := result + arr[d, p]
    else
      result := result + AInput[i]; //если не русская буква, то берем исходную
  end;
end;

function GetUserLogonPCName(AObj: TObject; AAttrList: TAttrCatalog; AAttrID: Integer): string;
var
  attr: TADAttribute;
  val: string;
  RegEx: TRegEx;
begin
  if AAttrList.ItemByID(AAttrID) <> nil then
  try
    attr := AAttrList.ItemByID(AAttrID)^;
    if IsPublishedProp(AObj, attr.ObjProperty)
      then val := GetPropValue(AObj, attr.ObjProperty, True);
    RegEx := TRegEx.Create('(%clientname%)|(,.*$)', [roIgnoreCase]);
    Result := RegEx.Replace(val, '');
  except
    Result := ''
  end;
end;

function AppInstanceExists(AClassName: string): Boolean;
begin
  Result := AppInstanceExists(AClassName, '');
end;

function AppInstanceExists(AClassName: string; AIniFile: TFileName): Boolean;
const
  PROCESS_NAME_NATIVE = $00000001;
  PROCESS_QUERY_LIMITED_INFORMATION = $1000;
var
  hW: THandle;
  hP: THandle;
  ProcessID: Integer;
  Buf: PChar;
  BufSize: DWORD;
  ExeName: string;
  QueryFullProcessImageName: TQueryFullProcessImageName;
  SingleInstance: Boolean;
  ExecParam: Byte;
  CopyDataStruct : TCopyDataStruct;
  Res: NativeInt;
  MsgBoxParam: TMsgBoxParams;
  fIni: TIniFile;
begin
  hW := 0;
  hP := 0;
  ProcessID := 0;
  BufSize := MAX_PATH;
  GetMem(Buf, BufSize);
  Result := False;
  hW := FindWindow(PChar(AClassName), nil);
  if hW > 0 then
  begin
    { По классу основного окна приложения ищем ProcessID и, далее, }
    { по ProcessID получаем имя *.exe файла процесса (приложения)  }
    GetWindowThreadProcessID(hW, @ProcessID);
    if ProcessID > 0 then
    begin
      if (Win32MajorVersion in [4, 5]) and (Win32Platform = VER_PLATFORM_WIN32_NT) then
      begin
        hP := OpenProcess(PROCESS_QUERY_INFORMATION or PROCESS_VM_READ, False, ProcessID);
        if hP > 0
          then if GetModuleFileNameEx(hP, 0, Buf, BufSize) > 0
            then ExeName := StringReplace(Buf, '\??\', '', [rfReplaceAll, rfIgnoreCase]);
      end else
      begin
        @QueryFullProcessImageName := GetProcAddress(
          GetModuleHandle(PChar('kernel32.dll')),
          PChar('QueryFullProcessImageNameW')
        );

        if Assigned(QueryFullProcessImageName) then
        begin
          hP := OpenProcess(PROCESS_QUERY_LIMITED_INFORMATION, False, ProcessID);
          if hP > 0
            then if QueryFullProcessImageName(hP, 0, Buf, @BufSize) > 0
              then ExeName := Buf;
        end;
      end;
      CloseHandle(hP);

      { Если файл приложения существует, то читаем из *.ini файла   }
      { параметры запуска нескольких копий приложения, иначе просто }
      { сообщаем что других экземпляров приложения не обнаружено    }
      if FileExists(AIniFile)
        then fIni := TIniFile.Create(AIniFile)
        else if FileExists(ExeName)
          then fIni := TIniFile.Create(ChangeFileExt(ExeName, '.ini'));

      try
        SingleInstance := fIni.ReadBool(INI_SECTION_GENERAL, 'RunSingleInstance', False);
        ExecParam := fIni.ReadInteger(INI_SECTION_GENERAL, 'ExecParam', EXEC_PROMPT_ACTION);

        if SingleInstance then Res := IDNO else
        case ExecParam of
          EXEC_NEW_INSTANCE : Res := IDYES;
          EXEC_PROMPT_ACTION: begin
            with MsgBoxParam do
            begin
              cbSize             := SizeOf(MsgBoxParam);
              hwndOwner          := 0;
              hInstance          := 0;
              lpszCaption        := PChar('Подтверждение');
              lpszIcon           := MAKEINTRESOURCE(32514);
              dwStyle            := MB_YESNO or MB_ICONQUESTION;
              dwContextHelpId    := 0;
              lpfnMsgBoxCallback := nil;
              dwLanguageId       := LANG_NEUTRAL;
            end;
            MsgBoxParam.lpszText := PChar(
              'Программа "' + APP_TITLE +'" уже запущена.' + #13#10 +
              'Запустить еще один экземпляр программы?'
            );
            MessageBeep(MB_ICONQUESTION);
            Res := MessageBoxIndirect(MsgBoxParam);
          end;
        end;

        case Res of
          IDNO: begin
            with CopyDataStruct do
            begin
              dwData := 0;
              cbData := MAX_PATH;
              lpData := PChar('SHOW_WINDOW');
            end;
            Res := SendMessage(hW, WM_COPYDATA, Integer(0), Integer(@CopyDataStruct)) ;
            if Res = 0 then
            begin
              MessageBeep(MB_ICONASTERISK);
              MessageDlg(
              'Программа "' + APP_TITLE +'" уже запущена.',
              mtInformation,
              [mbOk],
              0
            );
            end else
            begin
              SetForegroundWindow(hW);
              //ShowWindow(MainWindow, SW_SHOW);
              //SetWindowPos(MainWindow,HWND_TOP,0,0,0,0,SWP_NOMOVE or SWP_NOSIZE or SWP_SHOWWINDOW);
            end;
            Result := True;
          end;

          IDYES: begin
            Result := False;
          end;
        end;
      except
        Result := False;
      end;
      fIni.Free;
    end;
  end;
  FreeMem(Buf);
end;

function SendMessageToWindow(AClassName, AMessage: string): DWORD;
var
  hW: THandle;
  CopyDataStruct : TCopyDataStruct;
begin
  hW := 0;
  Result := 0;
  hW := FindWindow(PChar(AClassName), nil);
  if hW > 0 then
  begin
    with CopyDataStruct do
    begin
      dwData := 0;
      cbData := MAX_PATH;
      lpData := PChar(AMessage);
    end;
    Result := SendMessage(hW, WM_COPYDATA, Integer(0), Integer(@CopyDataStruct));
  end;
end;

function GetTreeNodePath(ANode: TTreeNode; var ARootPath: string;
  ASeparator: string): string;
begin
  ARootPath := Format('%s%s%s', [ANode.Text, ASeparator, ARootPath]);
  if ANode.Level = 0
    then Result := ARootPath
    else Result := GetTreeNodePath(ANode.Parent, ARootPath);

  if (Length(Result) > 0) and (Result[Length(Result)] = ASeparator)
    then Delete(Result, Length(Result), 1);
end;

function GetTextWidthInPixels(const AText: string; ATextFont: TFont): Integer;
var
  c: TBitmap;
begin
  Result := 0;
  c := TBitmap.Create;
  try
    c.Canvas.Font.Assign(ATextFont);
    Result := c.Canvas.TextWidth(AText);
  finally
    c.Free;
  end;
end;

function GetTextHeightInPixels(const AText: string; ATextFont: TFont): Integer;
var
  c: TBitmap;
begin
  Result := 0;
  c := TBitmap.Create;
  try
    c.Canvas.Font.Assign(ATextFont);
    Result := c.Canvas.TextHeight(AText);
  finally
    c.Free;
  end;
end;

function GetFileInfo(const FileName: TFileName; Information: string): string;
type
  PDWORD = ^DWORD;
  PLangAndCodePage = ^TLangAndCodePage;
  TLangAndCodePage = packed record
    wLanguage: WORD;
    wCodePage: WORD;
  end;
  PLangAndCodePageArray = ^TLangAndCodePageArray;
  TLangAndCodePageArray = array[0..0] of TLangAndCodePage;
var
  loc_InfoBufSize: DWORD;
  loc_InfoBuf: PChar;
  loc_VerBufSize: DWORD;
  loc_VerBuf: PChar;
  cbTranslate: DWORD;
  lpTranslate: PDWORD;
  i: DWORD;
begin
  Result := '';
  if (Length(FileName) = 0) or (not FileExists(FileName)) then Exit;
  loc_InfoBufSize := GetFileVersionInfoSize(PChar(FileName), loc_InfoBufSize);
  if loc_InfoBufSize > 0 then
  begin
    loc_VerBuf := nil;
    loc_InfoBuf := AllocMem(loc_InfoBufSize);
    try
      if not GetFileVersionInfo(PChar(FileName), 0, loc_InfoBufSize, loc_InfoBuf)
        then
        exit;
      if not VerQueryValue(loc_InfoBuf, '\\VarFileInfo\\Translation',
        LPVOID(lpTranslate), DWORD(cbTranslate)) then Exit;
      for i := 0 to (cbTranslate div SizeOf(TLangAndCodePage)) - 1 do
      begin
        if VerQueryValue(
          loc_InfoBuf,
          PChar(Format(
            'StringFileInfo\0%x0%x\%s', [
            PLangAndCodePageArray(lpTranslate)[i].wLanguage,
            PLangAndCodePageArray(lpTranslate)[i].wCodePage,
            Information])),
            Pointer(loc_VerBuf),
          DWORD(loc_VerBufSize)
          ) then
        begin
          Result := loc_VerBuf;
          Break;
        end;
      end;
    finally
      FreeMem(loc_InfoBuf, loc_InfoBufSize);
    end;
  end;
end;

function GetFileVersionNumber(const FileName: TFileName;
  var MajorVersion, MinorVersion, BuildNumber, RevisionNumber: DWORD): Boolean;
var
  InfoBufSize: DWORD;
  InfoBuf: PChar;
  BufLen: UINT;
  lpFileInfo: ^VS_FIXEDFILEINFO;
begin
  Result := False;
  if (Length(FileName) = 0) or (not FileExists(FileName)) then Exit;
  InfoBufSize := GetFileVersionInfoSize(PChar(FileName), InfoBufSize);
  if InfoBufSize > 0 then
  begin
    InfoBuf := AllocMem(InfoBufSize);
    try
      if GetFileVersionInfo(PChar(FileName), 0, InfoBufSize, InfoBuf) then
        if VerQueryValue(InfoBuf, '\\', LPVOID(lpFileInfo), BufLen) then
        begin
          MajorVersion   := HIWORD(lpFileInfo.dwFileVersionMS);
          MinorVersion   := LOWORD(lpFileInfo.dwFileVersionMS);
          BuildNumber    := HIWORD(lpFileInfo.dwFileVersionLS);
          RevisionNumber := LOWORD(lpFileInfo.dwFileVersionLS);
          Result := True;
        end;
    finally
      FreeMem(InfoBuf, InfoBufSize);
    end;
  end;
end;

function ADSIErrorToString: string;
var
  hr: HRESULT;
  adsiError: DWORD;
  adsiErrorBuf: PChar;
  adsiNameBuf: PChar;
begin
  Result := '';
  adsiErrorBuf := AllocMem(MAX_PATH);
  adsiNameBuf := AllocMem(MAX_PATH);

  hr := ADsGetLastError(
    adsiError,
    adsiErrorBuf,
    MAX_PATH,
    adsiNameBuf,
    MAX_PATH
  );

  if Succeeded(hr)
    { Подробное описаниие ошибки }
//    then Result := Format(
//      'Error Code: %d'#13#10'Error Text: %s'#13#10'Provider: %s',
//      [adsiError, adsiErrorBuf, adsiNameBuf]
//    );
    { Краткое описаниие ошибки }
    then Result := SysErrorMessage(adsiError);

  FreeMem(adsiErrorBuf);
  FreeMem(adsiNameBuf);
end;

function SortEvents(Item1, Item2: Pointer): Integer;
var
  e1, e2: TADEvent;
begin
  e1 := PADEvent(Item1)^;
  e2 := PADEvent(Item2)^;
  Result := CompareDate(e1.Date, e2.Date);
end;

function SIDToString(objSID: PSID): string;
const
  SID_REVISION = 1;
var
  psia: PSIDIdentifierAuthority;
  dwSubAuthorities: DWORD;
  dwSidRev: DWORD;
  dwCounter: DWORD;
  res: PChar;
begin
  Result := '';
  dwSidRev := SID_REVISION;

  if objSID = nil then Exit;

  if not IsValidSid(objSID)
    then Exit;

  if ConvertSidToStringSid(objSID, res)
    then Result := string(res);

//  psia := GetSidIdentifierAuthority(objSID);
//  dwSubAuthorities := GetSidSubAuthorityCount(objSID)^;
//
//  result := Format('S-%u-', [dwSidRev]);
//
//  if (psia^.Value[0] <> 0) or (psia^.Value[1] <> 0) then
//    result := result + format('0x%02x%02x%02x%02x%02x%02x', [
//      psia^.Value[0],
//        psia^.Value[1],
//        psia^.Value[2],
//        psia^.Value[3],
//        psia^.Value[4],
//        psia^.Value[5]])
//  else
//    result := result + format('%u', [
//        DWORD(psia^.Value[5]) +
//        DWORD(psia^.Value[4] shl 8) +
//        DWORD(psia^.Value[3] shl 16) +
//        DWORD(psia^.Value[2] shl 24)
//    ]);
//
//  for dwCounter := 0 to dwSubAuthorities - 1 do
//    result := result + Format('-%u', [GetSidSubAuthority(objSID, dwCounter)^])
end;

function SIDToString(objSID: OleVariant): string;
var
  pSID: Pointer;
begin
  pSID := VarArrayLock(objSID);
  try
    Result := SIDToString(pSID);
  finally
    VarArrayUnlock(objSID);
  end;
end;

function ADEscapeReservedCharacters(AValue: string): string;
var
  res: string;
begin
  res := AValue;

  if AValue.IsEmpty then Exit;

  { Важно сначала заменить символ "\" }
  res := ReplaceStr(res, '\', '\5C');
  res := ReplaceStr(res, ',', '\2C');
  res := ReplaceStr(res, '+', '\2B');
  res := ReplaceStr(res, '"', '\22');
  res := ReplaceStr(res, '<', '\3C');
  res := ReplaceStr(res, '>', '\3E');
  res := ReplaceStr(res, ';', '\3B');
  res := ReplaceStr(res, '=', '\3D');
  res := ReplaceStr(res, '/', '\2F');
  res := ReplaceStr(res, '#', '\#');
  res := ReplaceStr(res, #10{LF}, '\0A');
  res := ReplaceStr(res, #13{CR}, '\0D');

  if res[Length(res)] = ' '
    then Insert('\20', res, Length(res));

  if res[1] = ' '
    then Insert('\20', res, 1);

  Result := res;
end;

function DateTimeToADDate(ADate: TDateTime): ActiveDs_TLB._LARGE_INTEGER;
var
  LocalTime: Winapi.Windows.TFileTime;
  SystemTime: TSystemTime;
  FileTime : Winapi.Windows.TFileTime;
  ULargeInt: ULARGE_INTEGER;
begin
  DateTimeToSystemTime(ADate, SystemTime);
  if SystemTimeToFileTime(SystemTime, LocalTime) then
    if LocalFileTimeToFileTime(LocalTime, FileTime) then
    begin
      ULargeInt.HighPart := FileTime.dwHighDateTime;
      ULargeInt.LowPart := FileTime.dwLowDateTime;
      Result.QuadPart := ULargeInt.QuadPart;
    end;
end;

function ADDateToDateTime(ADDate: DATE_TIME): System.TDateTime;
var
  int64Value: Int64;
  LocalTime: TFileTime;
  SystemTime: TSystemTime;
  FileTime : TFileTime;
begin
  try
    int64Value := ADDate.dwHighDateTime;
    int64Value := int64Value shl 32;
    int64Value := int64Value + ADDate.dwLowDateTime;
    Result := EncodeDate(1601,1,1);
    FileTime := TFileTime(int64Value);
    if FileTimeToLocalFileTime(FileTime, LocalTime) then
      if FileTimeToSystemTime(LocalTime, SystemTime) then
        Result := SystemTimeToDateTime(SystemTime);
  except
    Result := 0;
  end;
end;

function ADDateToDateTime(ADDate: ActiveDs_TLB._LARGE_INTEGER): System.TDateTime;
var
  int64Value: Int64;
  LocalTime: TFileTime;
  SystemTime: TSystemTime;
  FileTime : TFileTime;
begin
//  Result := EncodeDate(1601,1,1);
  Result := 0;
  if ADDate.QuadPart = 0 then Result := 0 else
  try
    {int64Value := LastLogon.HighPart;
    int64Value := int64Value shl 32;
    int64Value := int64Value + LastLogon.LowPart;}
    int64Value := ADDate.QuadPart;
    FileTime := TFileTime(int64Value);
    if FileTimeToLocalFileTime(FileTime, LocalTime) then
      if FileTimeToSystemTime(LocalTime, SystemTime) then
        Result := SystemTimeToDateTime(SystemTime);
  except

  end;
end;

function ADDateToDateTime(ADDate: OleVAriant): System.TDateTime;
var
  d: LARGE_INTEGER;
  val: ActiveDS_TLB._LARGE_INTEGER;
begin
  d.HighPart := (IDispatch(ADDate) as IADsLargeInteger).HighPart;
  d.LowPart := (IDispatch(ADDate) as IADsLargeInteger).LowPart;
  if d.LowPart > 0 then
  begin
    d.QuadPart := d.HighPart;
    d.QuadPart := d.QuadPart shl 32;
    d.QuadPart := d.QuadPart + d.LowPart;
    val.QuadPart := d.QuadPart;
    Result := ADDateToDateTime(val)
  end;

//  val.QuadPart :=
//    (UInt64(IADsLargeInteger(IDispatch(ADDate)).HighPart) shl 32)
//    + UInt64(IADsLargeInteger(IDispatch(ADDate)).LowPart );
//  Result := ADDateToDateTime(val);
end;

function CalcPasswordExpiration(const PwdLastSet: ActiveDs_TLB._LARGE_INTEGER;
  MaxPwdAge: Integer): System.TDateTime;
var
  d: System.TDateTime;
begin
  d := ADDateToDateTime(PwdLastSet);
  if d > 0
    then Result := IncSecond(d, MaxPwdAge)
    else Result := 0;
end;

function ADCheckPasswordComplexity(ADomainName, APassword: string): Boolean;
const
  NERR_Success = 0;
var
  InputArg: TNetValidatePasswordChangeInputArg;
  pInputArg: PNetValidatePasswordChangeInputArg;
  pOutputArg: PNetValidateOutputArg;
  Res: DWORD;
begin
  Result := False;
  FillChar(InputArg, sizeof(InputArg), 0);
  InputArg.ClearPassword := LPWSTR(APassword);
  InputArg.PasswordMatch := True;
  PInputArg := @InputArg;
  Res := NetValidatePasswordPolicy(
    LPWSTR('\\' + ADomainName),
    nil,
    NetValidatePasswordChange,
    LPVOID(pInputArg),
    LPVOID(pOutputArg)
  );

  if Res = NERR_Success then
  begin
    if (pOutputArg <> nil) and (pOutputArg^.ValidationStatus = 0)
      then Result := True;
  end else Result := True;
  NetValidatePasswordPolicyFree(LPVOID(pOutputArg));
end;

procedure ADEnumDomainControllers(const outDCList: TStrings);
type
  PDomainsArray = ^TDomainsArray;
  TDomainsArray = array [1..100] of DS_DOMAIN_TRUSTS;
var
  i: Integer;
  dwRet: DWORD;
  ulSocketCount: UINT;
  Domains: PDomainsArray;
begin
  for i := 0 to outDCList.Count - 1 do
    if outDCList.Objects[i] <> nil then outDCList.Objects[i].Free;
  outDCList.Clear;

  dwRet := DsEnumerateDomainTrusts(
    nil,
    DS_DOMAIN_PRIMARY {or DS_DOMAIN_IN_FOREST or DS_DOMAIN_DIRECT_OUTBOUND},
    PDS_DOMAIN_TRUSTS(Domains),
    ulSocketCount
  );

  if dwRet = ERROR_SUCCESS then
  for i := 1 to ulSocketCount do
  begin
    outDCList.Add(Domains[i].DnsDomainName);
  end;

  NetApiBufferFree(Domains);
end;

procedure ADEnumContainers(ARootDSE: IADs; const outList: TStrings);
var
  v: OleVariant;
  DomainHostName: string;
  DomainDN: string;
  dcPathName: string;
  hr: HRESULT ;
  SearchRes: IDirectorySearch;
  SearchPrefs: array of ADS_SEARCHPREF_INFO;
  hSearch: THandle;
  Attributes: array of WideString;
  col: ADS_SEARCH_COLUMN;
  i, j: Integer;
  outStr: string;
  contData: PADContainer;
  AdValue: PAdsValueArray;
begin
  for i := 0 to outList.Count - 1 do
    if outList.Objects[i] <> nil
      then Dispose(PADContainer(outList.Objects[i]));

  outList.Clear;
  CoInitialize(nil);

  try
    v := ARootDSE.Get('dnsHostName');
    DomainHostName := VariantToStringWithDefault(v, '');
    VariantClear(v);

    v := ARootDSE.Get('defaultNamingContext');
    DomainDN := VariantToStringWithDefault(v, '');
    VariantClear(v);

    New(contData);
    with contData^ do
    begin
      Category := 0;
      DistinguishedName := DomainDN;
      CanonicalName := ReplaceText(
        ReplaceText(
          DomainDN,
          ',DC=',
          '.'
        ),
        'DC=',
        ''
      );
    end;

    outList.AddObject(contData^.CanonicalName, TObject(contData));

    hr := ADsOpenObject(
      PChar('LDAP://' + DomainHostName + '/' + DomainDN),
      nil,
      nil,
      ADS_SECURE_AUTHENTICATION or ADS_SERVER_BIND,
      IID_IDirectorySearch,
      @SearchRes
    );

    if SUCCEEDED(hr) then
    begin
      SetLength(SearchPrefs, 3);
      with SearchPrefs[0] do
      begin
        dwSearchPref := ADS_SEARCHPREF_PAGESIZE;
        vValue.dwType := ADSTYPE_INTEGER;
        vValue.__MIDL____MIDL_itf_ads_0000_00000000.Integer := 1000;
      end;
      with SearchPrefs[1] do
      begin
        dwSearchPref := ADS_SEARCHPREF_PAGED_TIME_LIMIT;
        vValue.dwType := ADSTYPE_INTEGER;
        vValue.__MIDL____MIDL_itf_ads_0000_00000000.Integer := 60;
      end;
      with SearchPrefs[2] do
      begin
        dwSearchPref := ADS_SEARCHPREF_SEARCH_SCOPE;
        vValue.dwType := ADSTYPE_INTEGER;
        vValue.__MIDL____MIDL_itf_ads_0000_00000000.Integer := ADS_SCOPE_SUBTREE;
      end;
      hr := SearchRes.SetSearchPreference(SearchPrefs[0], Length(SearchPrefs));

      SetLength(Attributes, 6);
      Attributes := [
          'name',
          'distinguishedName',
          'canonicalName',
          'objectCategory',
          'systemFlags',
          'allowedChildClasses'
      ];

      SearchRes.ExecuteSearch(
        PChar(
          '(|' +
            '(&(ObjectCategory=organizationalUnit)(ou=*))' +
            '(objectCategory=container)' +
            '(objectCategory=builtinDomain)' +
            '(objectClass=msExchSystemObjectsContainer)' +
          ')'
        ),
        PWideChar(@Attributes[0]),
        Length(Attributes),
        LPVOID(hSearch)
      );
      hr := SearchRes.GetNextRow(LPVOID(hSearch));
      while (hr <> S_ADS_NOMORE_ROWS) do
      begin
        New(contData);
        for i := Low(Attributes) to High(Attributes) do
        begin
          j := 0;
          hr := SearchRes.GetColumn(LPVOID(hSearch), PWideChar(Attributes[i]), col);
          if Succeeded(hr)then
          case i of
            0: begin
              contData^.name := col.pAdsvalues^.__MIDL____MIDL_itf_ads_0000_00000000.CaseIgnoreString;
            end;

            1: begin
              contData^.DistinguishedName := col.pAdsvalues^.__MIDL____MIDL_itf_ads_0000_00000000.CaseIgnoreString;
            end;

            2: begin
              outStr := col.pAdsvalues^.__MIDL____MIDL_itf_ads_0000_00000000.CaseIgnoreString;
              contData^.CanonicalName := col.pAdsvalues^.__MIDL____MIDL_itf_ads_0000_00000000.CaseIgnoreString;
            end;

            3: begin
              if ContainsText(col.pAdsvalues^.__MIDL____MIDL_itf_ads_0000_00000000.CaseIgnoreString, 'Organizational-Unit')
                then contData^.Category := AD_CONTCAT_ORGUNIT
                else contData^.Category := AD_CONTCAT_CONTAINER
            end;

            4: begin
              contData^.systemFlags := col.pAdsvalues^.__MIDL____MIDL_itf_ads_0000_00000000.Integer;
            end;

            5: begin
              AdValue := PAdsValueArray(col.pADsValues);
              for j := 0 to col.dwNumValues - 1 do
              begin
                if j > 0 then contData^.allowedChildClasses := contData^.allowedChildClasses + ',';
                contData^.allowedChildClasses := contData^.allowedChildClasses
                  + string(AdValue^[j].__MIDL____MIDL_itf_ads_0000_00000000.CaseIgnoreString);
              end;
            end;
          end;
          SearchRes.FreeColumn(col);
        end;
        outList.AddObject(outStr, TObject(contData));
        hr := SearchRes.GetNextRow(LPVOID(hSearch));
      end;
      SearchRes.CloseSearchHandle(LPVOID(hSearch));
    end;
  except
    on e:Exception do
    begin
      OutputDebugString(PChar(e.Message));
    end;
  end;
  CoUninitialize;
end;

procedure ADEnumContainers(ALDAP: PLDAP; const outList: TStrings);
const
  AttrArray: array of AnsiString = [
      'name',
      'distinguishedName',
      'canonicalName',
      'objectCategory',
      'systemFlags',
      'allowedChildClasses'
  ];

var
  returnCode: ULONG;
  errorCode: ULONG;
  morePages: Boolean;
  ldapBase: AnsiString;
  ldapFilter: AnsiString;
  ldapCookie: PLDAPBerVal;
  ldapPage: PLDAPControl;
  ldapControls: array[0..1] of PLDAPControl;
  ldapServerControls: PPLDAPControl;
  ldapCount: ULONG;
  ldapSearchResult: PLDAPMessage;
  ldapAttributes: array of PAnsiChar;
  ldapEntry: PLDAPMessage;
  ldapValues: PPAnsiChar;
  ldapBinValues: PPLDAPBerVal;
  i: Integer;
  ldapClass: string;
  attr: AnsiString;
  outStr: string;
  contData: PADContainer;
begin
  for i := 0 to outList.Count - 1 do
    if outList.Objects[i] <> nil
      then Dispose(PADContainer(outList.Objects[i]));

  outList.Clear;

  if not Assigned(ALDAP) then Exit;

  ldapCookie := nil;
  ldapSearchResult := nil;

  // Получаем имя домена
  returnCode := ldap_search_ext_s(
    ALDAP,
    nil,
    LDAP_SCOPE_BASE,
    PAnsiChar('(objectclass=*)'),
    nil,
    0,
    nil,
    nil,
    nil,
    0,
    ldapSearchResult
  );

  if (returnCode = LDAP_SUCCESS) and (ldap_count_entries(ALDAP, ldapSearchResult) > 0 ) then
  begin
    ldapEntry := ldap_first_entry(ALDAP, ldapSearchResult);
    ldapValues := ldap_get_values(ALDAP, ldapEntry, PAnsiChar('defaultNamingContext'));
    if ldapValues <> nil then
    begin
      ldapBase := ldapValues^;
      New(contData);
      with contData^ do
      begin
        Category := 0;
        DistinguishedName := ldapBase;
        CanonicalName := ReplaceText(
          ReplaceText(
            ldapBase,
            ',DC=',
            '.'
          ),
          'DC=',
          ''
        );
      end;
      outList.AddObject(contData^.CanonicalName, TObject(contData));
    end;
    ldap_value_free(ldapValues);
  end;

  if ldapSearchResult <> nil
    then ldap_msgfree(ldapSearchResult);

  { Формируем набор атрибутов }
  SetLength(ldapAttributes, Length(AttrArray) + 1);
  for i := Low(AttrArray) to High(AttrArray) do
    ldapAttributes[i] := PAnsiChar(AttrArray[i]);

  try
    { Формируем фильтр объектов AD }
    ldapFilter := '(|' +
        '(&(ObjectCategory=organizationalUnit)(ou=*))' +
        '(objectCategory=container)' +
        '(objectCategory=builtinDomain)' +
        '(objectClass=msExchSystemObjectsContainer)' +
    ')';

    { Постраничный поиск объектов AD }
    repeat
      returnCode := ldap_create_page_control(
          ALDAP,
          1000,
          ldapCookie,
          1,
          ldapPage
      );

      if returnCode <> LDAP_SUCCESS
        then raise Exception.Create('Failure during ldap_create_page_control.');

      ldapControls[0] := ldapPage;
      ldapControls[1] := nil;

      returnCode := ldap_search_ext_s(
          ALDAP,
          PAnsiChar(ldapBase),
          LDAP_SCOPE_SUBTREE,
          PAnsiChar(ldapFilter),
          PAnsiChar(@ldapAttributes[0]),
          0,
          @ldapControls,
          nil,
          nil,
          0,
          ldapSearchResult
      );

      if not (returnCode in [LDAP_SUCCESS, LDAP_PARTIAL_RESULTS])
        then raise Exception.Create('Failure during ldap_search_ext_s.');

      returnCode := ldap_parse_result(
          ALDAP^,
          ldapSearchResult,
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

      if (ldapCookie <> nil) and (ldapCookie.bv_val <> nil) and (System.SysUtils.StrLen(ldapCookie.bv_val) > 0)
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

      { Обработка результатов }
      ldapEntry := ldap_first_entry(ALDAP, ldapSearchResult);
      while ldapEntry <> nil do
      begin
        New(contData);
        for attr in AttrArray do
        begin
          i := 0;
          if Assigned(ldapValues) then
          case IndexText(attr, ['name', 'distinguishedName', 'canonicalName', 'objectCategory', 'systemFlags', 'allowedChildClasses']) of
            0: begin
              ldapValues := ldap_get_values(ALDAP, ldapEntry, PAnsiChar(attr));
              if ldapValues <> nil
                then contData^.name := ldapValues^;
              ldap_value_free(ldapValues);
            end;

            1: begin
              ldapValues := ldap_get_values(ALDAP, ldapEntry, PAnsiChar(attr));
              if ldapValues <> nil
                then contData^.DistinguishedName := ldapValues^;
              ldap_value_free(ldapValues);
            end;

            2: begin
              ldapValues := ldap_get_values(ALDAP, ldapEntry, PAnsiChar(attr));
              if ldapValues <> nil then
              begin
                outStr := ldapValues^;
                contData^.CanonicalName := ldapValues^;
              end;
              ldap_value_free(ldapValues);
            end;

            3: begin
              ldapValues := ldap_get_values(ALDAP, ldapEntry, PAnsiChar(attr));
              if ldapValues <> nil then
              if ContainsText(ldapValues^, 'Organizational-Unit')
                then contData^.Category := AD_CONTCAT_ORGUNIT
                else contData^.Category := AD_CONTCAT_CONTAINER;
              ldap_value_free(ldapValues);
            end;

            4: begin
              ldapBinValues := ldap_get_values_len(ALDAP, ldapEntry, PAnsiChar(attr));
              if (ldapBinValues <> nil) and (ldapBinValues^.bv_len > 0)
                then contData^.systemFlags := StrToIntDef(ldapBinValues^.bv_val, 0);
              ldap_value_free_len(ldapBinValues);
            end;

            5: begin
              ldapValues := ldap_get_values(ALDAP, ldapEntry, PAnsiChar(attr));
              if ldapValues <> nil then
              while ldapValues^ <> nil do
              begin
                if i > 0 then contData^.allowedChildClasses := contData^.allowedChildClasses + ',';
                contData^.allowedChildClasses := contData^.allowedChildClasses + ldapValues^;
                Inc(ldapValues);
                Inc(i);
              end;
              Dec(ldapValues, i);
              ldap_value_free(ldapValues);
            end;
          end;
        end;

        outList.AddObject(outStr, TObject(contData));
        ldapEntry := ldap_next_entry(ALDAP, ldapEntry);
      end;

      ldap_msgfree(ldapSearchResult);
      ldapSearchResult := nil;
    until (morePages = False);

    ber_bvfree(ldapCookie);
    ldapCookie := nil;
  except
    on e:Exception do
    begin
      OutputDebugString(PChar(e.Message));
    end;
  end;

  if ldapSearchResult <> nil
    then ldap_msgfree(ldapSearchResult);
end;

function DameWareMRC_Connect(const Executable, MachineName: string; key_a: Integer;
  key_u, key_p, key_d: string; key_md, key_r, AutoConnect, ViewOnly: Boolean): Boolean;
var
  CmdLine: string;
  StartInfo: TStartupInfo;
  ProcInfo: TProcessInformation;
begin
  Result := False;
  CmdLine := '"' + Executable + '"';
  if AutoConnect then CmdLine := CmdLine + ' -c:';
  CmdLine := CmdLine + ' -m:' + MachineName;
  if key_r then
  begin
    CmdLine := CmdLine + ' -u:' + key_u;
    CmdLine := CmdLine + ' -p:' + key_p;
    CmdLine := CmdLine + ' -d:' + key_d;
    CmdLine := CmdLine + ' -r:';
  end else
  begin
    case key_a of
      0: begin
        CmdLine := CmdLine + ' -a:' + IntToStr(key_a);
        CmdLine := CmdLine + ' -u:' + key_u;
        CmdLine := CmdLine + ' -p:' + key_p;
      end;

      1..2: begin
        CmdLine := CmdLine + ' -a:' + IntToStr(key_a);
        CmdLine := CmdLine + ' -u:' + key_u;
        CmdLine := CmdLine + ' -p:' + key_p;
        CmdLine := CmdLine + ' -d:' + key_d;
      end;

      3: begin
        CmdLine := CmdLine + ' -a:' + IntToStr(key_a);
        CmdLine := CmdLine + ' -p:' + key_p;
      end;

      4: begin
        CmdLine := CmdLine + ' -a:' + IntToStr(1);
      end;
    end;
  end;
  if key_md then CmdLine := CmdLine + ' -md:';
  if ViewOnly then CmdLine := CmdLine + ' -v:';
  CmdLine := CmdLine + ' -x:';

  FillChar(StartInfo, SizeOf(StartInfo), #0);
  FillChar(ProcInfo, SizeOf(StartInfo), #0);
  with StartInfo do
  begin
    cb := SizeOf(StartInfo);
    dwFlags := STARTF_USESHOWWINDOW;
    wShowWindow := SW_SHOWDEFAULT;
  end;
  if CreateProcess(nil, PChar(CmdLine), nil, nil, False,
    CREATE_NEW_CONSOLE or NORMAL_PRIORITY_CLASS, nil,
    PChar(ExtractFileDir(Executable)), StartInfo, ProcInfo) then
    begin
      //WaitForSingleObject(ProcInfo.hProcess, INFINITE);
      {case WaitForSingleObject(ProcInfo.hProcess, 30000) of
        WAIT_TIMEOUT : begin
          TerminateProcess(ProcInfo.hProcess, 0);
        end;
        WAIT_FAILED  : begin
          TerminateProcess(ProcInfo.hProcess, 0);
        end;
      end;}
      CloseHandle(ProcInfo.hProcess);
      CloseHandle(ProcInfo.hThread);
      Result := True;
    end;
end;

function EncodeIP(AIP: string): Cardinal;
type
  TIP4Address = packed record
    a: Byte;
    b: Byte;
    c: Byte;
    d: Byte;
  end;
var
  _Result: TIP4Address absolute Result;
  strArr: TStringDynArray;
begin
  Result := 0;
  strArr := SplitString(AIP, '.');

  _Result.a := StrToInt(strArr[0]);
  _Result.b := StrToInt(strArr[1]);
  _Result.c := StrToInt(strArr[2]);
  _Result.d := StrToInt(strArr[3]);
end;

{ Альтернативная реализация EncodeIP }
//function EncodeIP(AIP: string): Cardinal;
//var
//  strArr: TStringDynArray;
//begin
//  Result := 0;
//  strArr := SplitString(AIP, '.');
//  Result := (StrToInt(strArr[0]) shl 24) + (StrToInt(strArr[1]) shl 16) + (StrToInt(strArr[2]) shl 8) + StrToInt(strArr[3]);
//end;

function DecodeIP(AIP: Cardinal): string;
begin
  Result := Format(
    '%d.%d.%d.%d',
    [
      (AIP shr 24),
      (AIP shr 16) and $FF,
      (AIP shr 8) and $FF,
      AIP and $FF
    ]
  );
end;

procedure GetIPAddress(AClient: string; out AInfo: PIPAddr);
var
  wsa: WSAData;
  iRes: Integer;
  aiRes: PAddrInfo;
  aiPtr: PAddrInfo;
  hints: PAddrInfo;
  sockaddr_ipv4: PSOCKADDR_IN;
  nodeName: AnsiString;
begin
  nodeName := AClient;
  ZeroMemory(AInfo, SizeOf(TIPAddr));
  try
    iRes := WSAStartup(MAKEWORD(2, 2), wsa);
    if iRes <> 0
      then raise Exception.Create(Format('WSAStartup failed. Error: %d', [iRes]));

    hints := nil;
    New(hints);
    ZeroMemory(hints, SizeOf(addrinfo));
    hints^.ai_flags := AI_FQDN;
    hints^.ai_family := AF_INET;
    hints^.ai_socktype := SOCK_STREAM;
    hints^.ai_protocol := IPPROTO_TCP;

    aiRes := nil;

    iRes := getaddrinfo(
      PAnsiChar(nodeName),
      nil,
      hints,
      aiRes
    );

    if iRes <> 0
      then raise Exception.Create(Format('getaddrinfo failed. Error: %d', [iRes]));

    aiPtr := aiRes;
    while aiPtr <> nil do
    begin
      case aiPtr.ai_family of
        AF_UNSPEC: ;

        AF_INET: begin
          AInfo^.FQDN := aiPtr.ai_canonname;
          sockaddr_ipv4 := PSOCKADDR_IN(aiPtr.ai_addr);
          AInfo^.v4 := inet_ntoa(sockaddr_ipv4.sin_addr);
          { Получаем IP только из первого интерфейса }
          Break;
        end;

        AF_NETBIOS: ;
        AF_INET6: ;
        AF_IRDA: ;
        AF_BTH: ;
      end;

      aiPtr := aiPtr.ai_next;
    end;
  except
    on e: Exception do
    begin

    end;
  end;

  WSACleanup;
  sockaddr_ipv4 := nil;
  aiPtr := nil;

  if hints <> nil then
  begin
    Dispose(hints);
    hints := nil;
  end;

  if aiRes <> nil then
  begin
    freeaddrinfo(aiRes);
    aiRes := nil;
  end;
end;

procedure GetDHCPInfo(AClient: string; out AInfo: PDHCPInfo);
var
  DhcpGetClientInfo: TDhcpGetClientInfo;
  i: integer;
  returnCode: DWORD;
  srvArr: PDHCPDS_SERVERS;
  psInfo: LPDHCP_SEARCH_INFO;
  pcInfo: LPDHCP_CLIENT_INFO;
  clientName: string;
begin
  @DhcpGetClientInfo := GetProcAddress(
    GetModuleHandle(PChar('dhcpsapi.dll')),
    PChar('DhcpGetClientInfo')
  );

  if Assigned(DhcpGetClientInfo) then
  begin
    clientName := LowerCase(AClient);
    srvArr := nil;
    ZeroMemory(AInfo, SizeOf(TDHCPInfo));
    returnCode := DhcpEnumServers(
      0,
      nil,
      @srvArr,
      nil,
      nil
    );

    if (returnCode = ERROR_SUCCESS) then
    begin
      psInfo := HeapAlloc(GetProcessHeap, HEAP_ZERO_MEMORY, SizeOf(DHCP_SEARCH_INFO));
      pcInfo := nil;

      for i := 0 to srvArr.NumElements - 1 do
      begin
        psInfo^.SearchType := _DHCP_CLIENT_SEARCH_TYPE.DhcpClientName;
        psInfo^.searchInfo.ClientName := PWideChar(clientName);

        returnCode := DhcpGetClientInfo(
          PChar(DecodeIP(srvArr^.Servers[i].ServerAddress)),
          psInfo,
          @pcInfo
        );

        if (returnCode = ERROR_SUCCESS) then
        begin
          AInfo^.ServerName := string(pcInfo^.OwnerHost.HostName);
          AInfo^.ServerNetBIOSName := string(pcInfo^.OwnerHost.NetBiosName);
          AInfo^.ServerAddress := DecodeIP(pcInfo^.OwnerHost.IpAddress{srvArr.Servers[i].ServerAddress});
          AInfo^.HardwareAddress := Format(
            '%.2x-%.2x-%.2x-%.2x-%.2x-%.2x',
            [
               pcInfo^.ClientHardwareAddress.Data[0],
               pcInfo^.ClientHardwareAddress.Data[1],
               pcInfo^.ClientHardwareAddress.Data[2],
               pcInfo^.ClientHardwareAddress.Data[3],
               pcInfo^.ClientHardwareAddress.Data[4],
               pcInfo^.ClientHardwareAddress.Data[5]
            ]
          );

          AInfo^.IPAddress.FQDN := string(pcInfo^.ClientName);
          AInfo^.IPAddress.v4 := DecodeIP(pcInfo^.ClientIpAddress);
          AInfo^.SubnetMask := DecodeIP(pcInfo^.SubnetMask);
          AInfo^.LeaseExpires := ADDateToDateTime(pcInfo^.ClientLeaseExpires);
          Break;
        end;
        FreeDHCPClientInfoMemory(pcInfo);
      end;
      HeapFree(GetProcessHeap, HEAP_ZERO_MEMORY, psInfo);
      psInfo := nil;
    end;
  end;
end;

procedure GetDHCPInfoV4(AClient: string; out AInfo: PDHCPInfo);
var
  DhcpV4GetClientInfo: TDhcpV4GetClientInfo;
  i: integer;
  returnCode: DWORD;
  srvArr: PDHCPDS_SERVERS;
  psInfo: LPDHCP_SEARCH_INFO;
  pcInfo: LPDHCP_CLIENT_INFO_PB;
  clientName: string;
begin
  @DhcpV4GetClientInfo := GetProcAddress(
    GetModuleHandle(PChar('dhcpsapi.dll')),
    PChar('DhcpV4GetClientInfo')
  );

  if Assigned(DhcpV4GetClientInfo) then
  begin
    clientName := LowerCase(AClient);
    srvArr := nil;
    ZeroMemory(AInfo, SizeOf(TDHCPInfo));
    returnCode := DhcpEnumServers(
      0,
      nil,
      @srvArr,
      nil,
      nil
    );

    if (returnCode = ERROR_SUCCESS) then
    begin
      psInfo := HeapAlloc(GetProcessHeap, HEAP_ZERO_MEMORY, SizeOf(DHCP_SEARCH_INFO));
      pcInfo := nil;

      for i := 0 to srvArr.NumElements - 1 do
      begin
        psInfo^.SearchType := _DHCP_CLIENT_SEARCH_TYPE.DhcpClientName;
        psInfo^.searchInfo.ClientName := PWideChar(clientName);

        returnCode := DhcpV4GetClientInfo(
          PChar(DecodeIP(srvArr^.Servers[i].ServerAddress)),
          psInfo,
          @pcInfo
        );

        if (returnCode = ERROR_SUCCESS) then
        begin
          AInfo^.ServerName := string(pcInfo^.OwnerHost.HostName);
          AInfo^.ServerNetBIOSName := string(pcInfo^.OwnerHost.NetBiosName);
          AInfo^.ServerAddress := DecodeIP(pcInfo^.OwnerHost.IpAddress{srvArr.Servers[i].ServerAddress});
          AInfo^.HardwareAddress := Format(
            '%.2x-%.2x-%.2x-%.2x-%.2x-%.2x',
            [
               pcInfo^.ClientHardwareAddress.Data[0],
               pcInfo^.ClientHardwareAddress.Data[1],
               pcInfo^.ClientHardwareAddress.Data[2],
               pcInfo^.ClientHardwareAddress.Data[3],
               pcInfo^.ClientHardwareAddress.Data[4],
               pcInfo^.ClientHardwareAddress.Data[5]
            ]
          );

          AInfo^.IPAddress.FQDN := string(pcInfo^.ClientName);
          AInfo^.IPAddress.v4 := DecodeIP(pcInfo^.ClientIpAddress);
          AInfo^.SubnetMask := DecodeIP(pcInfo^.SubnetMask);
          AInfo^.LeaseExpires := ADDateToDateTime(pcInfo^.ClientLeaseExpires);
          Break;
        end;
        FreeDHCPClientInfoMemory(pcInfo);
        pcInfo := nil;
      end;
      HeapFree(GetProcessHeap, HEAP_ZERO_MEMORY, psInfo);
      psInfo := nil;
    end;
  end;
end;

procedure FreeDHCPClientInfoMemory(pClientInfo: LPDHCP_CLIENT_INFO);
begin
  if Assigned(pClientInfo) then
  begin
    { Frees client name }
    if Assigned(pClientInfo^.ClientName)
      then DhcpRpcFreeMemory(pClientInfo^.ClientName);

    { Frees client comments }
    if Assigned(pClientInfo^.ClientComment)
      then DhcpRpcFreeMemory(pClientInfo^.ClientComment);

    { Frees the ClientHardwareAddress }
    if Assigned(pClientInfo^.ClientHardwareAddress.Data) and (pClientInfo^.ClientHardwareAddress.DataLength > 0)
      then DhcpRpcFreeMemory(pClientInfo^.ClientHardwareAddress.Data);

    { Frees the HostName }
    if Assigned(pClientInfo^.OwnerHost.HostName)
      then DhcpRpcFreeMemory(pClientInfo^.OwnerHost.HostName);

    { Frees the NetBiosName }
    if Assigned(pClientInfo^.OwnerHost.NetBiosName)
      then DhcpRpcFreeMemory(pClientInfo^.OwnerHost.NetBiosName);

    { Frees the clientInfo }
    DhcpRpcFreeMemory(pClientInfo);
  end;
end;

procedure FreeDHCPClientInfoMemory(pClientInfo: LPDHCP_CLIENT_INFO_PB);
begin
  if Assigned(pClientInfo) then
  begin
    { Frees client name }
    if Assigned(pClientInfo^.ClientName)
      then DhcpRpcFreeMemory(pClientInfo^.ClientName);

    { Frees policy name }
    if Assigned(pClientInfo^.PolicyName)
      then DhcpRpcFreeMemory(pClientInfo^.PolicyName);

    { Frees client comments }
    if Assigned(pClientInfo^.ClientComment)
      then DhcpRpcFreeMemory(pClientInfo^.ClientComment);

    { Frees the ClientHardwareAddress }
    if Assigned(pClientInfo^.ClientHardwareAddress.Data) and (pClientInfo^.ClientHardwareAddress.DataLength > 0)
      then DhcpRpcFreeMemory(pClientInfo^.ClientHardwareAddress.Data);

    { Frees the HostName }
    if Assigned(pClientInfo^.OwnerHost.HostName)
      then DhcpRpcFreeMemory(pClientInfo^.OwnerHost.HostName);

    { Frees the NetBiosName }
    if Assigned(pClientInfo^.OwnerHost.NetBiosName)
      then DhcpRpcFreeMemory(pClientInfo^.OwnerHost.NetBiosName);

    { Frees the clientInfo }
    DhcpRpcFreeMemory(pClientInfo);
  end;
end;

procedure ServerBinding(ADcDnsName: string; out ALDAP: PLDAP;
  AOnException: TExceptionProc);
var
  returnCode: ULONG;
  optValue: ULONG;
  secIdent: SEC_WINNT_AUTH_IDENTITY;
  hostName: AnsiString;
  pDN: AnsiString;
  pUserName: AnsiString;
  pPassword: AnsiString;
begin
  ldap_unbind(ALDAP);

  hostName := ADcDnsName;
  ALDAP := nil;
//  ALDAP := ldap_sslinit(PAnsiChar(hostName), LDAP_SSL_PORT, 1);
  ALDAP := ldap_init(PAnsiChar(hostName), LDAP_PORT);
  returnCode := GetLastError;
  try
    if ALDAP = nil
      then raise Exception.Create(
        Format(
          'Init of server %s at port %d failed. %s',
          [hostName, LDAP_PORT, ldap_err2string(returnCode)]
        )
      );

    optValue := LDAP_VERSION3;
    returnCode := ldap_set_option(
      ALDAP,
      LDAP_OPT_PROTOCOL_VERSION,
      @optValue
    );

    optValue := LDAP_NO_LIMIT;
    returnCode := ldap_set_option(
      ALDAP,
      LDAP_OPT_SIZELIMIT,
      @optValue
    );

    returnCode := ldap_set_option(
      ALDAP,
      LDAP_OPT_AUTO_RECONNECT,
      LDAP_OPT_ON
    );

//    returnCode := ldap_set_option(
//      ALDAP,
//      LDAP_OPT_ENCRYPT,
//      LDAP_OPT_ON
//    );

    returnCode := ldap_set_option(
      ALDAP,
      LDAP_OPT_AREC_EXCLUSIVE,
      LDAP_OPT_ON
    );

    { Отключаем опцию LDAP_OPT_REFERRALS, т.к. с ней не работает постарничный поиск }
    returnCode := ldap_set_option(
      ALDAP,
      LDAP_OPT_REFERRALS,
      LDAP_OPT_OFF
    );

//    if (returnCode <> LDAP_SUCCESS)
//      then raise Exception.Create(
//        Format(
//          'Failure during ldap_set_option. %s',
//          [ldap_err2string(returnCode)]
//        )
//      );

    returnCode := ldap_connect(ALDAP, nil);

    if returnCode <> LDAP_SUCCESS
      then raise Exception.Create(
        Format(
          'Failure during ldap_connect. %s',
          [ldap_err2string(returnCode)]
        )
      );

    { https://msdn.microsoft.com/en-us/library/aa366156(v=vs.85).aspx         }
    { To log in as the current user, set the dn and cred parameters to NULL.  }
    { To log in as another user, set the dn parameter to NULL and the cred    }
    { parameter to a pointer to a SEC_WINNT_AUTH_IDENTITY or                  }
    { SEC_WINNT_AUTH_IDENTITY_EX structure with the appropriate user name,    }
    { domain name, and password.                                              }

    pDN := System.AnsiStrings.ReplaceText('DC=' + hostName, '.', ',DC=');
    secIdent.User := PChar(pUserName);
    secIdent.UserLength := Length(pUserName);
    secIdent.Password := PChar(pPassword);
    secIdent.PasswordLength := Length(pPassword);
    secIdent.Domain := PChar(hostName);
    secIdent.DomainLength := Length(hostName);
    secIdent.Flags := SEC_WINNT_AUTH_IDENTITY_ANSI;

    returnCode := ldap_bind_s(
      ALDAP,
      nil, //PAnsiChar(pDN),
      nil, //@secIdent,
      LDAP_AUTH_NEGOTIATE
    );

    if returnCode <> LDAP_SUCCESS
      then raise Exception.Create(
        Format(
          'Unable to Bind to the LDAP server. %s',
          [ldap_err2string(returnCode)]
        )
      );
  except
    on E: Exception do
    begin
      ALDAP := nil;
      if Assigned(AOnException)
        then AOnException(E.Message, returnCode);
    end;
  end;
end;

procedure ServerBinding(ADcName: string;
  ARootDSE: Pointer; AOnException: TExceptionProc);
var
  hr: HRESULT;
  addr: string;
begin
  IADs(ARootDSE^) := nil;

  CoInitialize(nil);

  addr := ADcName;

  hr := ADsOpenObject(
    PChar('LDAP://' + addr + '/RootDSE'),
    nil,
    nil,
    ADS_SECURE_AUTHENTICATION or ADS_SERVER_BIND,
    IID_IADs,
    ARootDSE
  );

  if not Succeeded(hr) then
  begin
    IADs(ARootDSE^) := nil;
    if Assigned(AOnException)
      then AOnException('Can not bind to server ' + addr, hr);
  end;

  CoUninitialize;
end;

function ADCreateOU(ALDAP: PLDAP; AContainer: string; ANewOU: string): string;
var
  ldapDN: AnsiString;
  attrArray: array of PLDAPMod;
  valClass: array of PAnsiChar;
  valOU: array of PAnsiChar;
  valSAMAccountName: array of PAnsiChar;
  returnCode: ULONG;
  i: Integer;
begin
  Result := '';

  if AContainer.IsEmpty or ANewOU.IsEmpty
    then Exit;

  ldapDN := Format('OU=%s,%s', [ADEscapeReservedCharacters(ANewOU), AContainer]);

  SetLength(valClass, 3);
  valClass[0] := PAnsiChar('top');
  valClass[1] := PAnsiChar('organizationalUnit');

  SetLength(valOU, 2);
  valOU[0] := PAnsiChar(AnsiString(ANewOU));

  SetLength(attrArray, 3);

  New(attrArray[0]);
  with attrArray[0]^ do
  begin
    mod_op       := 0;
    mod_type     := PAnsiChar('objectClass');
    modv_strvals := @valClass[0];
  end;

  New(attrArray[1]);
  with attrArray[1]^ do
  begin
    mod_op       := 0;
    mod_type     := PAnsiChar('ou');
    modv_strvals := @valOU[0];
  end;

  try
    returnCode := ldap_add_ext_s(
      ALDAP,
      PAnsiChar(ldapDN),
      @attrArray[0],
      nil,
      nil
    );

    if returnCode <> LDAP_SUCCESS
      then raise Exception.Create(ldap_err2string(returnCode));

    Result := ldapDN;
  finally
    for i := Low(attrArray) to High(attrArray) do
      if Assigned(attrArray[i])
        then Dispose(attrArray[i]);
  end;
end;

function ADCreateOU(ARootDSE: IADS; AContainer: string; ANewOU: string): string;
var
  v: OleVariant;
  hostName: string;
  hr: HRESULT;
  ICont: IADsContainer;
  INewCont: IADs;
begin
  Result := '';
  ICont := nil;
  INewCont := nil;

  if AContainer.IsEmpty or ANewOU.IsEmpty
    then Exit;

  CoInitialize(nil);

  try
    v := ARootDSE.Get('dnsHostName');
    hostName := VariantToStringWithDefault(v, '');
    VariantClear(v);

    hr := ADsOpenObject(
      PChar(Format('LDAP://%s/%s', [hostName, AContainer])),
      nil,
      nil,
      ADS_SECURE_AUTHENTICATION or ADS_SERVER_BIND,
      IID_IADsContainer,
      @ICont
    );

    if Succeeded(hr) then
    begin
      INewCont := ICont.Create(
        'organizationalUnit',
        'OU=' + ADEscapeReservedCharacters(ANewOU)
      ) as IADs;

      if INewCont <> nil then
      begin
        INewCont.SetInfo;
        v := INewCont.Get('distinguishedName');
        Result := VariantToStringWithDefault(v, '');
        VariantClear(v);
      end else raise Exception.Create(ADSIErrorToString);
    end else raise Exception.Create(ADSIErrorToString);
  finally
    CoUninitialize;
  end;
end;

function ADCreateOUDS(ARootDSE: IADS; AContainer: string; ANewOU: string): string;
var
  v: OleVariant;
  hostName: string;
  hr: HRESULT;
  attrArray: array of ADS_ATTR_INFO;
  valClass: ADSVALUE;
  IDir: IDirectoryObject;
  IDisp: IDispatch;
  INewCont: IADs;
begin
  Result := '';
  IDir := nil;
  INewCont := nil;

  if AContainer.IsEmpty or ANewOU.IsEmpty
    then Exit;

  CoInitialize(nil);

  try
    v := ARootDSE.Get('dnsHostName');
    hostName := VariantToStringWithDefault(v, '');
    VariantClear(v);

    SetLength(attrArray, 1);

    with attrArray[0] do
    begin
      pszAttrName   := 'objectClass';
      dwControlCode := ADS_ATTR_UPDATE;
      dwADsType     := ADSTYPE_CASE_IGNORE_STRING;
      pADsValues    := @valClass;
      dwNumValues   := 1;
    end;

    valClass.dwType := ADSTYPE_CASE_IGNORE_STRING;
    valClass.__MIDL____MIDL_itf_ads_0000_00000000.CaseIgnoreString := PChar('organizationalUnit');

    hr := ADsOpenObject(
      PChar(Format('LDAP://%s/%s', [hostName, AContainer])),
      nil,
      nil,
      ADS_SECURE_AUTHENTICATION or ADS_SERVER_BIND,
      IID_IDirectoryObject,
      @IDir
    );

    if Succeeded(hr) then
    begin
      hr := IDir.CreateDSObject(
        PChar('OU=' + ADEscapeReservedCharacters(ANewOU)),
        @attrArray[0],
        Length(attrArray),
        IDisp
      );

      if Succeeded(hr) then
      begin
        hr := IDisp.QueryInterface(IID_IADsContainer, INewCont);
        if not Succeeded(hr)
          then raise Exception.Create(ADSIErrorToString);
        v := INewCont.Get('distinguishedName');
        Result := VariantToStringWithDefault(v, '');
        VariantClear(v);
      end else raise Exception.Create(ADSIErrorToString);
    end else raise Exception.Create(ADSIErrorToString);
  finally
    CoUninitialize;
  end;
end;

function ADDeleteObject(ALDAP: PLDAP; ADN: string): Boolean;
var
  ldapDN: AnsiString;
  returnCode: ULONG;
begin
  Result := False;

  ldapDN := AnsiString(ADN);

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

function ADDeleteObject(ARootDSE: IADS; ADN: string): Boolean;
var
  Obj: IADs;
  objClass: string;
  objRelativeName: string;
  objCont: IADsContainer;
  hr: HRESULT;
  dn: string;
  ADSIPath_LDAP: string;
  v: OleVariant;
  hostName: string;
begin
  CoInitialize(nil);

  try
    v := ARootDSE.Get('dnsHostName');
    hostName := VariantToStringWithDefault(v, '');
    VariantClear(v);
  except

  end;

  { ADSI requires that the forward slash character "/" also be escaped }
  { in distinguished names in most scripts where distinguished names   }
  { are used to bind to objects in Active Directory:                   }
  { https://social.technet.microsoft.com/wiki/contents/articles/5312.active-directory-characters-to-escape.aspx }

  dn := ReplaceStr(ADN, '/', '\/');

  if hostName.IsEmpty
    then ADSIPath_LDAP := Format('LDAP://%s', [dn])
    else ADSIPath_LDAP := Format('LDAP://%s/%s', [hostName, dn]);

  Result := False;

  try
    hr := ADsOpenObject(
      PChar(ADSIPath_LDAP),
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

function ADDeleteObjectDS(ARootDSE: IADS; ADN: string): Boolean;
var
  Obj: IADs;
  objRelativeName: string;
  objCont: IDirectoryObject;
  hr: HRESULT;
  dn: string;
  ADSIPath_LDAP: string;
  v: OleVariant;
  hostName: string;
begin
  CoInitialize(nil);

  try
    v := ARootDSE.Get('dnsHostName');
    hostName := VariantToStringWithDefault(v, '');
    VariantClear(v);
  except

  end;

  { ADSI requires that the forward slash character "/" also be escaped }
  { in distinguished names in most scripts where distinguished names   }
  { are used to bind to objects in Active Directory:                   }
  { https://social.technet.microsoft.com/wiki/contents/articles/5312.active-directory-characters-to-escape.aspx }

  dn := ReplaceStr(ADN, '/', '\/');

  if hostName.IsEmpty
    then ADSIPath_LDAP := Format('LDAP://%s', [dn])
    else ADSIPath_LDAP := Format('LDAP://%s/%s', [hostName, dn]);

  Result := False;

  try
    hr := ADsOpenObject(
      PChar(ADSIPath_LDAP),
      nil,
      nil,
      ADS_SECURE_AUTHENTICATION or ADS_SERVER_BIND,
      IID_IADs,
      @Obj
    );

    if Succeeded(hr) then
    begin
      objRelativeName := Obj.Name;

      hr := ADsOpenObject(
        PChar(Obj.Parent),
        nil,
        nil,
        ADS_SECURE_AUTHENTICATION or ADS_SERVER_BIND,
        IID_IDirectoryObject,
        @objCont
      );

      if Succeeded(hr) then
      begin
        hr := objCont.DeleteDSObject(PChar(objRelativeName));
        if not Succeeded(hr)
          then raise Exception.Create(ADSIErrorToString);
      end else raise Exception.Create(ADSIErrorToString);
    end else raise Exception.Create(ADSIErrorToString);

    Result := True;
  finally
    CoUninitialize;
  end;
end;

end.
