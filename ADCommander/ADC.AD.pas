unit ADC.AD;

interface

uses
  Winapi.Windows;

const
  ADS_ATTR_CLEAR  = 1;  // Causes all attribute values to be removed from an object.
  ADS_ATTR_UPDATE = 2;  // Causes the specified attribute values to be updated.
  ADS_ATTR_APPEND = 3;  // Causes the specified attribute values to be appended to the existing attribute values.
  ADS_ATTR_DELETE = 4;  // Causes the specified attribute values to be removed from an object.

type
  PBERVAL = ^berval;
  berval = record
    bv_len: ULONG;
    bv_val: PAnsiChar;
  end;

type
  PBerElement = ^BerElement;
  BerElement = record
    opaque: PAnsiChar;
  end;

  function ADsGetObject(lpszPathName: LPCWSTR; const riid: TGUID; ppObject: Pointer): HRESULT; stdcall;
  function ADsOpenObject(lpszPathName, lpszUserName, lpszPassword: LPCWSTR;
    dwReserved: DWORD; const riid: TGUID; ppObject: Pointer): HRESULT; stdcall;
  function ADsGetLastError(var lpError: DWORD; lpErrorBuf: LPWSTR;
    dwErrorBufLen: DWORD; lpNameBuf: LPWSTR; dwNameBufLen: DWORD): DWORD; stdcall;
  function FreeADsMem(pMem: Pointer): BOOL; stdcall;

function ber_alloc_t(options: Integer): PBerElement; cdecl;
function ber_printf(BerElement: PBerElement; fmt: PAnsiChar): Integer; cdecl; varargs;
function ber_flatten(pBerElement: PBerElement; var pBerVal: PBerVal): Integer; cdecl;
procedure ber_free(pBerElement: PBerElement; fbuf: Integer); cdecl;

implementation

function ADsGetObject; external 'activeds.dll' name 'ADsGetObject';
function ADsOpenObject; external 'activeds.dll' name 'ADsOpenObject';
function ADsGetLastError; external 'activeds.dll' name 'ADsGetLastError';
function FreeADsMem; external 'activeds.dll' name 'FreeADsMem';

function ber_alloc_t; external 'Wldap32.dll' name 'ber_alloc_t';
function ber_printf; external 'Wldap32.dll' name 'ber_printf';
procedure ber_free; external 'Wldap32.dll' name 'ber_free';
function ber_flatten; external 'Wldap32.dll' name 'ber_flatten';

end.
