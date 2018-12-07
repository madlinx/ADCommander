unit ADC.NetInfo;

interface

uses
  Winapi.Windows, Winapi.Winsock2;

const
  AI_PASSIVE                = $01;
  AI_CANONNAME              = $02;
  AI_NUMERICHOST            = $04;
  AI_ALL                    = $0100;
  AI_ADDRCONFIG             = $0400;
  AI_V4MAPPED               = $0800;
  AI_NON_AUTHORITATIVE      = $04000;
  AI_SECURE                 = $08000;
  AI_RETURN_PREFERRED_NAMES = $010000;
  AI_FQDN                   = $00020000;
  AI_FILESERVER             = $00040000;

type
  PADDRINFO = ^addrinfo;
  addrinfo = packed record
    ai_flags     : Integer;
    ai_family    : Integer;
    ai_socktype  : Integer;
    ai_protocol  : Integer;
    ai_addrlen   : size_t;
    ai_canonname : PAnsiChar;
    ai_addr      : LPSOCKADDR;
    ai_next      : PADDRINFO;
  end;

type
  DHCP_IP_ADDRESS = DWORD;
  PDHCP_IP_ADDRESS = ^DHCP_IP_ADDRESS;
  LPDHCP_IP_ADDRESS = ^PDHCP_IP_ADDRESS;

  DHCP_IP_MASK = DWORD;
  DHCP_RESUME_HANDLE = DWORD;

{$MINENUMSIZE 4}
type
  _QuarantineStatus = (
    NOQUARANTINE        = 0,
    RESTRICTEDACCESS    = 1,
    DROPPACKET          = 2,
    PROBATION           = 3,
    EXEMPT              = 4,
    DEFAULTQUARSETTING  = 5,
    NOQUARINFO          = 6
  );
  QuarantineStatus =_QuarantineStatus;

type
  _DHCP_BINARY_DATA = record
    DataLength : DWORD;
    Data       : LPBYTE;
  end;
  DHCP_BINARY_DATA = _DHCP_BINARY_DATA;
  LPDHCP_BINARY_DATA = ^DHCP_BINARY_DATA;
  DHCP_CLIENT_UID = DHCP_BINARY_DATA;

type
  _DATE_TIME = record
    dwLowDateTime  : DWORD;
    dwHighDateTime : DWORD;
  end;
  DATE_TIME = _DATE_TIME;
  LPDATE_TIME = ^DATE_TIME;

type
  _DHCP_HOST_INFO = record
    IpAddress   : DHCP_IP_ADDRESS;
    NetBiosName : LPWSTR;
    HostName    : LPWSTR;
  end;
  DHCP_HOST_INFO = _DHCP_HOST_INFO;
  LPDHCP_HOST_INFO = ^DHCP_HOST_INFO;

type
  _DHCP_CLIENT_SEARCH_TYPE = (
    DhcpClientIpAddress,
    DhcpClientHardwareAddress,
    DhcpClientName
  );
  DHCP_SEARCH_INFO_TYPE = _DHCP_CLIENT_SEARCH_TYPE;
  LPDHCP_SEARCH_INFO_TYPE = ^DHCP_SEARCH_INFO_TYPE;

type
  _DHCP_CLIENT_SEARCH_UNION = record
  case Integer of
    0: (ClientIpAddress: DHCP_IP_ADDRESS);
    1: (ClientHardwareAddress: DHCP_CLIENT_UID);
    2: (ClientName: LPWSTR);
  end;

type
  _DHCP_CLIENT_SEARCH_INFO = record
    SearchType: DHCP_SEARCH_INFO_TYPE;
    SearchInfo: _DHCP_CLIENT_SEARCH_UNION;
  end;
  DHCP_SEARCH_INFO = _DHCP_CLIENT_SEARCH_INFO;
  LPDHCP_SEARCH_INFO = ^DHCP_SEARCH_INFO;

type
  _DHCPDS_SERVER = record
    Version       : DWORD;
    ServerName    : LPWSTR;
    ServerAddress : DWORD;
    Flags         : DWORD;
    State         : DWORD;
    DsLocation    : LPWSTR;
    DsLocType     : DWORD;
  end;
  DHCPDS_SERVER = _DHCPDS_SERVER;
  PDHCPDS_SERVER = ^DHCPDS_SERVER;
  PDhcpServerArray = ^TDhcpServerArray;
  TDhcpServerArray = array [0..100] of DHCPDS_SERVER;

type
  _DHCPDS_SERVERS = record
    Flags       : DWORD;
    NumElements : DWORD;
    Servers     : PDhcpServerArray;
  end;
  DHCPDS_SERVERS = _DHCPDS_SERVERS;
  PDHCPDS_SERVERS = ^DHCPDS_SERVERS;
  PDHCP_SERVER_INFO_ARRAY = ^DHCPDS_SERVERS;
  LPDHCP_SERVER_INFO_ARRAY = ^PDHCP_SERVER_INFO_ARRAY;

type
  _DHCP_CLIENT_INFO = record
    ClientIpAddress       : DHCP_IP_ADDRESS;
    SubnetMask            : DHCP_IP_MASK;
    ClientHardwareAddress : DHCP_CLIENT_UID;
    ClientName            : LPWSTR;
    ClientComment         : LPWSTR;
    ClientLeaseExpires    : DATE_TIME;
    OwnerHost             : DHCP_HOST_INFO;
  end;
  DHCP_CLIENT_INFO = _DHCP_CLIENT_INFO;
  PDHCP_CLIENT_INFO = ^DHCP_CLIENT_INFO;
  LPDHCP_CLIENT_INFO = ^PDHCP_CLIENT_INFO;

type
  _DHCPV4_FAILOVER_CLIENT_INFO = record
    ClientIpAddress       : DHCP_IP_ADDRESS;
    SubnetMask            : DHCP_IP_MASK;
    ClientHardwareAddress : DHCP_CLIENT_UID;
    ClientName            : LPWSTR;
    ClientComment         : LPWSTR;
    ClientLeaseExpires    : DATE_TIME;
    OwnerHost             : DHCP_HOST_INFO;
    bClientType           : BYTE;
    AddressState          : BYTE;
    Status                : QuarantineStatus;
    ProbationEnds         : DATE_TIME;
    QuarantineCapable     : Boolean;
    SentPotExpTime        : DWORD;
    AckPotExpTime         : DWORD;
    RecvPotExpTime        : DWORD;
    StartTime             : DWORD;
    CltLastTransTime      : DWORD;
    LastBndUpdTime        : DWORD;
    bndMsgStatus          : DWORD;
    PolicyName            : LPWSTR;
    flags                 : BYTE;
  end;
  DHCPV4_FAILOVER_CLIENT_INFO = _DHCPV4_FAILOVER_CLIENT_INFO;
  LPDHCPV4_FAILOVER_CLIENT_INFO = ^DHCPV4_FAILOVER_CLIENT_INFO;

type
  _DHCP_CLIENT_INFO_PB = record
    ClientIpAddress       : DHCP_IP_ADDRESS;
    SubnetMask            : DHCP_IP_MASK;
    ClientHardwareAddress : DHCP_CLIENT_UID;
    ClientName            : PWideChar;
    ClientComment         : PWideChar;
    ClientLeaseExpires    : DATE_TIME;
    OwnerHost             : DHCP_HOST_INFO;
    bClientType           : BYTE;
    AddressState          : BYTE;
    Status                : QuarantineStatus;
    ProbationEnds         : DATE_TIME;
    QuarantineCapable     : Boolean;
    FilterStatus          : DWORD;
    PolicyName            : PWideChar;
  end;
  DHCP_CLIENT_INFO_PB = _DHCP_CLIENT_INFO_PB;
  LPDHCP_CLIENT_INFO_PB = ^DHCP_CLIENT_INFO_PB;

type
  _DHCP_IP_ARRAY = record
    NumElements: DWORD;
    Elements: LPDHCP_IP_ADDRESS;
  end;
  DHCP_IP_ARRAY = _DHCP_IP_ARRAY;
  LPDHCP_IP_ARRAY = ^DHCP_IP_ARRAY;

type
  _DHCP_CLIENT_INFO_ARRAY = record
    NumElements: DWORD;
    Clients: LPDHCP_CLIENT_INFO;
  end;
  DHCP_CLIENT_INFO_ARRAY = _DHCP_CLIENT_INFO_ARRAY;
  LPDHCP_CLIENT_INFO_ARRAY = ^DHCP_CLIENT_INFO_ARRAY;

  TDhcpGetClientInfo = function(ServerIpAddress: PWideChar; SearchInfo: LPDHCP_SEARCH_INFO;
    ClientInfo: PDHCP_CLIENT_INFO): DWORD; stdcall;
  TDhcpV4GetClientInfo = function(ServerIpAddress: PWideChar;
    SearchInfo: LPDHCP_SEARCH_INFO; ClientInfo: LPDHCP_CLIENT_INFO_PB): DWORD; stdcall;
  TDhcpV4FailoverGetClientInfo = function(ServerIpAddress: PWideChar;
    SearchInfo: LPDHCP_SEARCH_INFO; ClientInfo: LPDHCPV4_FAILOVER_CLIENT_INFO): DWORD; stdcall;


function DhcpEnumServers(Flags: DWORD; IdInfo: LPVOID; Servers: LPDHCP_SERVER_INFO_ARRAY;
  CallbackFn: LPVOID; CallbackData: LPVOID): DWORD; stdcall;
function DhcpEnumSubnets(ServerIpAddress: PWideChar; var ResumeHandle: DHCP_RESUME_HANDLE;
  PreferredMaximum: DWORD; EnumInfo: LPDHCP_IP_ARRAY; out ElementsRead, ElementsTotal: DWORD): DWORD; stdcall;
function DhcpEnumSubnetClients(ServerIpAddress: PWideChar; SubnetAddress: DHCP_IP_ADDRESS;
  var ResumeHandle: DHCP_RESUME_HANDLE; PreferredMaximum: DWORD; ClientInfo: LPDHCP_CLIENT_INFO_ARRAY;
  out ClientsRead, ClientsTotal: DWORD): DWORD; stdcall;

//function DhcpGetClientInfo(ServerIpAddress: PWideChar; SearchInfo: LPDHCP_SEARCH_INFO;
//  ClientInfo: LPDHCP_CLIENT_INFO): DWORD; stdcall;
//function DhcpV4GetClientInfo(ServerIpAddress: PWideChar;
//  SearchInfo: LPDHCP_SEARCH_INFO; ClientInfo: LPDHCP_CLIENT_INFO_PB): DWORD; stdcall;
//function DhcpV4FailoverGetClientInfo(ServerIpAddress: PWideChar;
//  SearchInfo: LPDHCP_SEARCH_INFO; ClientInfo: LPDHCPV4_FAILOVER_CLIENT_INFO): DWORD; stdcall;
procedure DhcpRpcFreeMemory(BufferPointer: Pointer); stdcall;

function getaddrinfo(pNodeName: PAnsiChar; pServiceName: PAnsiChar; const pHints: PADDRINFO;
  out ppResult: PADDRINFO): Integer; stdcall;
procedure freeaddrinfo(ai: PADDRINFO); stdcall;

implementation

function DhcpEnumServers; external 'dhcpsapi.dll' name 'DhcpEnumServers';
function DhcpEnumSubnets; external 'dhcpsapi.dll' name 'DhcpEnumSubnets';
function DhcpEnumSubnetClients; external 'dhcpsapi.dll' name 'DhcpEnumSubnetClients';
//function DhcpGetClientInfo; external 'dhcpsapi.dll' name 'DhcpGetClientInfo';
//function DhcpV4GetClientInfo; external 'dhcpsapi.dll' name 'DhcpV4GetClientInfo';
//function DhcpV4FailoverGetClientInfo; external 'dhcpsapi.dll' name 'DhcpV4FailoverGetClientInfo';
procedure DhcpRpcFreeMemory; external 'dhcpsapi.dll' name 'DhcpRpcFreeMemory';

function getaddrinfo; external 'Ws2_32.dll' name 'getaddrinfo';
procedure freeaddrinfo; external 'Ws2_32.dll' name 'freeaddrinfo';

end.
