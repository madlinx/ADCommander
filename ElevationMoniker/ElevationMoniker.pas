unit ElevationMoniker;

{$WARN SYMBOL_PLATFORM OFF}

interface

uses
  Winapi.Windows, Winapi.ActiveX, System.Classes, System.Win.ComObj, ADCommander_TLB,
  System.SysUtils, System.Win.Registry, System.Win.ComServ, ElevationMonikerFactory,
  MSXML2_TLB;

type
  TADCElevationMoniker = class(TTypedComObject, IElevationMoniker)
  private
    const KEY_WOW64: array [0..1] of DWORD = (KEY_WOW64_32KEY, KEY_WOW64_64KEY);
  protected
    procedure RegisterUCMAComponents(AClassID: PWideChar); safecall;
    procedure UnregisterUCMAComponents(AClassID: PWideChar); safecall;
    procedure SaveControlEventsList(AFileName: PWideChar; const AXMLStream: IUnknown); safecall;
    procedure DeleteControlEventsList(AFileName: PWideChar); safecall;
  end;

implementation

{ TADCElevationMoniker }

procedure TADCElevationMoniker.DeleteControlEventsList(AFileName: PWideChar);
begin
  DeleteFileW(AFileName);
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
