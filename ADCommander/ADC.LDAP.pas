unit ADC.LDAP;

interface

uses
  Winapi.Windows;

type
  PPCharA = ^PAnsiChar;
  PPCharW = ^PWideChar;
  PPChar = PPCharA;

  PPPCharA = ^PPCharA;
  PPPCharW = ^PPCharW;
  PPPChar = PPPCharA;

const
  LDAP_PORT               = 389;
  LDAP_SSL_PORT           = 636;
  LDAP_GC_PORT            = 3268;
  LDAP_SSL_GC_PORT        = 3269;

  LDAP_VERSION1          = 1;
  LDAP_VERSION2          = 2;
  LDAP_VERSION3          = 3;
  LDAP_VERSION           = LDAP_VERSION2;

  LDAP_BIND_CMD          = $60;
  LDAP_UNBIND_CMD        = $42;
  LDAP_SEARCH_CMD        = $63;
  LDAP_MODIFY_CMD        = $66;
  LDAP_ADD_CMD           = $68;
  LDAP_DELETE_CMD        = $4a;
  LDAP_MODRDN_CMD        = $6c;
  LDAP_COMPARE_CMD       = $6e;
  LDAP_ABANDON_CMD       = $50;
  LDAP_SESSION_CMD       = $71;
  LDAP_EXTENDED_CMD      = $77;


  LDAP_RES_BIND           = $61;
  LDAP_RES_SEARCH_ENTRY   = $64;
  LDAP_RES_SEARCH_RESULT  = $65;
  LDAP_RES_MODIFY         = $67;
  LDAP_RES_ADD            = $69;
  LDAP_RES_DELETE         = $6b;
  LDAP_RES_MODRDN         = $6d;
  LDAP_RES_COMPARE        = $6f;
  LDAP_RES_SESSION        = $72;
  LDAP_RES_REFERRAL       = $73;
  LDAP_RES_EXTENDED       = $78;
  LDAP_RES_ANY            = -1;

  LDAP_INVALID_CMD        = $FF;
  LDAP_INVALID_RES        = $FF;

type
  LDAP_RETCODE = ULONG;

const
  LDAP_SUCCESS                    = $00;
  LDAP_OPERATIONS_ERROR           = $01;
  LDAP_PROTOCOL_ERROR             = $02;
  LDAP_TIMELIMIT_EXCEEDED         = $03;
  LDAP_SIZELIMIT_EXCEEDED         = $04;
  LDAP_COMPARE_FALSE              = $05;
  LDAP_COMPARE_TRUE               = $06;
  LDAP_AUTH_METHOD_NOT_SUPPORTED  = $07;
  LDAP_STRONG_AUTH_REQUIRED       = $08;
  LDAP_REFERRAL_V2                = $09;
  LDAP_PARTIAL_RESULTS            = $09;
  LDAP_REFERRAL                   = $0a;
  LDAP_ADMIN_LIMIT_EXCEEDED       = $0b;
  LDAP_UNAVAILABLE_CRIT_EXTENSION = $0c;
  LDAP_CONFIDENTIALITY_REQUIRED   = $0d;
  LDAP_SASL_BIND_IN_PROGRESS      = $0e;
  LDAP_NO_SUCH_ATTRIBUTE          = $10;
  LDAP_UNDEFINED_TYPE             = $11;
  LDAP_INAPPROPRIATE_MATCHING     = $12;
  LDAP_CONSTRAINT_VIOLATION       = $13;
  LDAP_ATTRIBUTE_OR_VALUE_EXISTS  = $14;
  LDAP_INVALID_SYNTAX             = $15;
  LDAP_NO_SUCH_OBJECT             = $20;
  LDAP_ALIAS_PROBLEM              = $21;
  LDAP_INVALID_DN_SYNTAX          = $22;
  LDAP_IS_LEAF                    = $23;
  LDAP_ALIAS_DEREF_PROBLEM        = $24;
  LDAP_INAPPROPRIATE_AUTH         = $30;
  LDAP_INVALID_CREDENTIALS        = $31;
  LDAP_INSUFFICIENT_RIGHTS        = $32;
  LDAP_BUSY                       = $33;
  LDAP_UNAVAILABLE                = $34;
  LDAP_UNWILLING_TO_PERFORM       = $35;
  LDAP_LOOP_DETECT                = $36;
  LDAP_NAMING_VIOLATION           = $40;
  LDAP_OBJECT_CLASS_VIOLATION     = $41;
  LDAP_NOT_ALLOWED_ON_NONLEAF     = $42;
  LDAP_NOT_ALLOWED_ON_RDN         = $43;
  LDAP_ALREADY_EXISTS             = $44;
  LDAP_NO_OBJECT_CLASS_MODS       = $45;
  LDAP_RESULTS_TOO_LARGE          = $46;
  LDAP_AFFECTS_MULTIPLE_DSAS      = $47;
  LDAP_OTHER                      = $50;
  LDAP_SERVER_DOWN                = $51;
  LDAP_LOCAL_ERROR                = $52;
  LDAP_ENCODING_ERROR             = $53;
  LDAP_DECODING_ERROR             = $54;
  LDAP_TIMEOUT                    = $55;
  LDAP_AUTH_UNKNOWN               = $56;
  LDAP_FILTER_ERROR               = $57;
  LDAP_USER_CANCELLED             = $58;
  LDAP_PARAM_ERROR                = $59;
  LDAP_NO_MEMORY                  = $5a;
  LDAP_CONNECT_ERROR              = $5b;
  LDAP_NOT_SUPPORTED              = $5c;
  LDAP_NO_RESULTS_RETURNED        = $5e;
  LDAP_CONTROL_NOT_FOUND          = $5d;
  LDAP_MORE_RESULTS_TO_RETURN     = $5f;
  LDAP_CLIENT_LOOP                = $60;
  LDAP_REFERRAL_LIMIT_EXCEEDED    = $61;

  LDAP_AUTH_SIMPLE                = $80;
  LDAP_AUTH_SASL                  = $83;
  LDAP_AUTH_OTHERKIND             = $86;
  LDAP_AUTH_SICILY                = LDAP_AUTH_OTHERKIND or $0200;
  LDAP_AUTH_MSN                   = LDAP_AUTH_OTHERKIND or $0800;
  LDAP_AUTH_NTLM                  = LDAP_AUTH_OTHERKIND or $1000;
  LDAP_AUTH_DPA                   = LDAP_AUTH_OTHERKIND or $2000;
  LDAP_AUTH_NEGOTIATE             = LDAP_AUTH_OTHERKIND or $0400;
  LDAP_AUTH_SSPI                  = LDAP_AUTH_NEGOTIATE;

  LDAP_FILTER_AND         = $a0;
  LDAP_FILTER_OR          = $a1;
  LDAP_FILTER_NOT         = $a2;
  LDAP_FILTER_EQUALITY    = $a3;
  LDAP_FILTER_SUBSTRINGS  = $a4;
  LDAP_FILTER_GE          = $a5;
  LDAP_FILTER_LE          = $a6;
  LDAP_FILTER_PRESENT     = $87;
  LDAP_FILTER_APPROX      = $a8;
  LDAP_FILTER_EXTENSIBLE  = $a9;

  LDAP_SUBSTRING_INITIAL  = $80;
  LDAP_SUBSTRING_ANY      = $81;
  LDAP_SUBSTRING_FINAL    = $82;

  LDAP_DEREF_NEVER        = 0;
  LDAP_DEREF_SEARCHING    = 1;
  LDAP_DEREF_FINDING      = 2;
  LDAP_DEREF_ALWAYS       = 3;

  LDAP_NO_LIMIT       = 0;


  LDAP_OPT_DNS                = $00000001;
  LDAP_OPT_CHASE_REFERRALS    = $00000002;
  LDAP_OPT_RETURN_REFS        = $00000004;

{$ALIGN ON}

type
  PLDAP = ^LDAP;
  LDAP = record

    ld_sb: record
      sb_sd: ULONG;
      Reserved1: array [0..10*SizeOf(ULONG)] of Byte;
      sb_naddr: ULONG;   // notzero implies CLDAP available
      Reserved2: array [0..6*SizeOf(ULONG)-1] of Byte;
    end;

    ld_host: PAnsiChar;
    ld_version: ULONG;
    ld_lberoptions: Byte;
    ld_deref: ULONG;
    ld_timelimit: ULONG;
    ld_sizelimit: ULONG;
    ld_errno: ULONG;
    ld_matched: PAnsiChar;
    ld_error: PAnsiChar;
    ld_msgid: ULONG;
    Reserved3: array  [0..6*SizeOf(ULONG)] of Byte;
    ld_cldaptries: ULONG;
    ld_cldaptimeout: ULONG;
    ld_refhoplimit: ULONG;
    ld_options: ULONG;
  end;

  PLDAPTimeVal = ^TLDAPTimeVal;
  l_timeval = packed record
    tv_sec: Longint;
    tv_usec: Longint;
  end;
  LDAP_TIMEVAL = l_timeval;
  PLDAP_TIMEVAL = ^LDAP_TIMEVAL;
  TLDAPTimeVal = l_timeval;

  PLDAPBerVal = ^TLDAPBerVal;
  PPLDAPBerVal = ^PLDAPBerVal;
  PLDAP_BERVAL = ^berval;
  PBERVAL = ^berval;
  berval = record
    bv_len: ULONG;
    bv_val: PAnsiChar;
  end;
  LDAP_BERVAL = berval;
  TLDAPBerVal = berval;

  PPLDAPMessage = ^PLDAPMessage;
  PLDAPMessage = ^LDAPMessage;
  ldapmsg = record
    lm_msgid: ULONG;
    lm_msgtype: ULONG;
    lm_ber: Pointer;
    lm_chain: PLDAPMessage;
    lm_next: PLDAPMessage;
    lm_time: ULONG;
    Connection: PLDAP;
    Request: Pointer;
    lm_returncode: ULONG;
    lm_referral: Word;
    lm_chased: ByteBool;
    lm_eom: ByteBool;
    ConnectionReferenced: ByteBool;
  end;
  LDAPMessage = ldapmsg;

  PPPLDAPControlA = ^PPLDAPControlA;
  PPPLDAPControlW = ^PPLDAPControlW;
  PPPLDAPControl = PPPLDAPControlA;
  PPLDAPControlA = ^PLDAPControlA;
  PPLDAPControlW = ^PLDAPControlW;
  PPLDAPControl = PPLDAPControlA;
  PLDAPControlA = ^LDAPControlA;
  PLDAPControlW = ^LDAPControlW;
  PLDAPControl = PLDAPControlA;

  LDAPControlA = record
    ldctl_oid: PAnsiChar;
    ldctl_value: TLDAPBerVal;
    ldctl_iscritical: ByteBool;
  end;

  LDAPControlW = record
    ldctl_oid: PWideChar;
    ldctl_value: TLDAPBerVal;
    ldctl_iscritical: ByteBool;
  end;
  LDAPControl = LDAPControlA;

  TLDAPControlA = LDAPControlA;
  TLDAPControlW = LDAPControlW;
  TLDAPControl = TLDAPControlA;

const
  LDAP_CONTROL_REFERRALS_W = '1.2.840.113556.1.4.616';
  LDAP_CONTROL_REFERRALS   = '1.2.840.113556.1.4.616';

const
  LDAP_MOD_ADD            = $00;
  LDAP_MOD_DELETE         = $01;
  LDAP_MOD_REPLACE        = $02;
  LDAP_MOD_BVALUES        = $80;

type
  PLDAPModA = ^LDAPModA;
  PLDAPModW = ^LDAPModW;
  PLDAPMod = PLDAPModA;
  PPLDAPMod = ^PLDAPMod;
  LDAPModA = record
    mod_op: ULONG;
    mod_type: PAnsiChar;
    case integer of
      0:(modv_strvals: ^PAnsiChar);
      1:(modv_bvals: ^PLDAPBerVal);
  end;

  LDAPModW = record
    mod_op: ULONG;
    mod_type: PWideChar;
    case integer of
      0:(modv_strvals: ^PWideChar);
      1:(modv_bvals: ^PLDAPBerVal);
  end;

  LDAPMod = LDAPModA;
  TLDAPModA = LDAPModA;
  TLDAPModW = LDAPModW;
  TLDAPMod = TLDAPModA;

function LDAP_IS_CLDAP(ld: PLDAP): Boolean;
function NAME_ERROR(n: Integer): Boolean;

function ldap_openA(HostName: PAnsiChar; PortNumber: ULONG): PLDAP; cdecl;
function ldap_openW(HostName: PWideChar; PortNumber: ULONG): PLDAP; cdecl;
function ldap_open(HostName: PAnsiChar; PortNumber: ULONG): PLDAP; cdecl;
function ldap_initA(HostName: PAnsiChar; PortNumber: ULONG): PLDAP; cdecl;
function ldap_initW(HostName: PWideChar; PortNumber: ULONG): PLDAP; cdecl;
function ldap_init(HostName: PAnsiChar; PortNumber: ULONG): PLDAP; cdecl;
function ldap_sslinitA(HostName: PAnsiChar; PortNumber: ULONG; secure: integer): PLDAP; cdecl;
function ldap_sslinitW(HostName: PWideChar; PortNumber: ULONG; secure: integer): PLDAP; cdecl;
function ldap_sslinit(HostName: PAnsiChar; PortNumber: ULONG; secure: integer): PLDAP; cdecl;
function ldap_connect(ld: PLDAP; timeout: PLDAPTimeval): ULONG; cdecl;
function cldap_openA(HostName: PAnsiChar; PortNumber: ULONG): PLDAP; cdecl;
function cldap_openW(HostName: PWideChar; PortNumber: ULONG): PLDAP; cdecl;
function cldap_open(HostName: PAnsiChar; PortNumber: ULONG): PLDAP; cdecl;
function ldap_unbind(ld: PLDAP): ULONG; cdecl;
function ldap_unbind_s(ld: PLDAP): ULONG; cdecl;
function ldap_get_option(ld: PLDAP; option: integer; outvalue: pointer): ULONG; cdecl;
function ldap_get_optionW(ld: PLDAP; option: integer; outvalue: pointer): ULONG; cdecl;
function ldap_set_option(ld: PLDAP; option: integer; invalue: pointer): ULONG; cdecl;
function ldap_set_optionW(ld: PLDAP; option: integer; invalue: pointer): ULONG; cdecl;

const
  LDAP_OPT_DESC               = $01;
  LDAP_OPT_DEREF              = $02;
  LDAP_OPT_SIZELIMIT          = $03;
  LDAP_OPT_TIMELIMIT          = $04;
  LDAP_OPT_THREAD_FN_PTRS     = $05;
  LDAP_OPT_REBIND_FN          = $06;
  LDAP_OPT_REBIND_ARG         = $07;
  LDAP_OPT_REFERRALS          = $08;
  LDAP_OPT_RESTART            = $09;
  LDAP_OPT_SSL                = $0a;
  LDAP_OPT_IO_FN_PTRS         = $0b;
  LDAP_OPT_CACHE_FN_PTRS      = $0d;
  LDAP_OPT_CACHE_STRATEGY     = $0e;
  LDAP_OPT_CACHE_ENABLE       = $0f;
  LDAP_OPT_REFERRAL_HOP_LIMIT = $10;
  LDAP_OPT_PROTOCOL_VERSION   = $11;
  LDAP_OPT_VERSION            = $11;
  LDAP_OPT_SORTKEYS           = $11;
  LDAP_OPT_HOST_NAME          = $30;
  LDAP_OPT_ERROR_NUMBER       = $31;
  LDAP_OPT_ERROR_STRING       = $32;
  LDAP_OPT_SERVER_ERROR       = $33;
  LDAP_OPT_SERVER_EXT_ERROR   = $34;
  LDAP_OPT_HOST_REACHABLE     = $3E;
  LDAP_OPT_PING_KEEP_ALIVE    = $36;
  LDAP_OPT_PING_WAIT_TIME     = $37;
  LDAP_OPT_PING_LIMIT         = $38;
  LDAP_OPT_DNSDOMAIN_NAME     = $3B;
  LDAP_OPT_GETDSNAME_FLAGS    = $3D;
  LDAP_OPT_PROMPT_CREDENTIALS = $3F;
  LDAP_OPT_AUTO_RECONNECT     = $91;
  LDAP_OPT_SSPI_FLAGS         = $92;
  LDAP_OPT_SSL_INFO           = $93;
  LDAP_OPT_SIGN               = $95;
  LDAP_OPT_ENCRYPT            = $96;
  LDAP_OPT_SASL_METHOD        = $97;
  LDAP_OPT_AREC_EXCLUSIVE     = $98;
  LDAP_OPT_SECURITY_CONTEXT   = $99;

  LDAP_OPT_ON                 = Pointer(1);
  LDAP_OPT_OFF                = Pointer(0);

  LDAP_CHASE_SUBORDINATE_REFERRALS    = $00000020;
  LDAP_CHASE_EXTERNAL_REFERRALS       = $00000040;

function ldap_simple_bindA(ld: PLDAP; dn, passwd: PAnsiChar): ULONG; cdecl;
function ldap_simple_bindW(ld: PLDAP; dn, passwd: PWideChar): ULONG; cdecl;
function ldap_simple_bind(ld: PLDAP; dn, passwd: PAnsiChar): ULONG; cdecl;
function ldap_simple_bind_sA(ld: PLDAP; dn, passwd: PAnsiChar): ULONG; cdecl;
function ldap_simple_bind_sW(ld: PLDAP; dn, passwd: PWideChar): ULONG; cdecl;
function ldap_simple_bind_s(ld: PLDAP; dn, passwd: PAnsiChar): ULONG; cdecl;
function ldap_bindA(ld: PLDAP; dn, cred: PAnsiChar; method: ULONG): ULONG; cdecl;
function ldap_bindW(ld: PLDAP; dn, cred: PWideChar; method: ULONG): ULONG; cdecl;
function ldap_bind(ld: PLDAP; dn, cred: PAnsiChar; method: ULONG): ULONG; cdecl;
function ldap_bind_sA(ld: PLDAP; dn, cred: PAnsiChar; method: ULONG): ULONG; cdecl;
function ldap_bind_sW(ld: PLDAP; dn, cred: PWideChar; method: ULONG): ULONG; cdecl;
function ldap_bind_s(ld: PLDAP; dn, cred: PAnsiChar; method: ULONG): ULONG; cdecl;
function ldap_sasl_bindA(ExternalHandle: PLDAP; DistName: PAnsiChar;
  AuthMechanism: PAnsiChar; cred: PBERVAL;
  var ServerCtrls, ClientCtrls: PLDAPControlA;
  var MessageNumber: Integer): Integer; cdecl;
function ldap_sasl_bindW(ExternalHandle: PLDAP; DistName: PWideChar;
  AuthMechanism: PWideChar; cred: PBERVAL;
  var ServerCtrls, ClientCtrls: PLDAPControlW;
  var MessageNumber: Integer): Integer; cdecl;
function ldap_sasl_bind(ExternalHandle: PLDAP; DistName: PAnsiChar;
  AuthMechanism: PAnsiChar; cred: PBERVAL;
  var ServerCtrls, ClientCtrls: PLDAPControl;
  var MessageNumber: Integer): Integer; cdecl;
function ldap_sasl_bind_sA(ExternalHandle: PLDAP; DistName: PAnsiChar;
  AuthMechanism: PAnsiChar; cred: PBERVAL;
  var ServerCtrls, ClientCtrls: PLDAPControlA;
  var ServerData: PBERVAL): Integer; cdecl;
function ldap_sasl_bind_sW(ExternalHandle: PLDAP; DistName: PWideChar;
  AuthMechanism: PWideChar; cred: PBERVAL;
  var ServerCtrls, ClientCtrls: PLDAPControlW;
  var ServerData: PBERVAL): Integer; cdecl;
function ldap_sasl_bind_s(ExternalHandle: PLDAP; DistName: PAnsiChar;
  AuthMechanism: PAnsiChar; cred: PBERVAL;
  var ServerCtrls, ClientCtrls: PLDAPControl;
  var ServerData: PBERVAL): Integer; cdecl;

const
  LDAP_SCOPE_BASE         = $00;
  LDAP_SCOPE_ONELEVEL     = $01;
  LDAP_SCOPE_SUBTREE      = $02;

function ldap_searchA(
  ld: PLDAP;
  base: PAnsiChar;        // distinguished name or ''
  scope: ULONG;           // LDAP_SCOPE_xxxx
  filter: PAnsiChar;
  attrs: PAnsiChar;       // pointer to an array of PAnsiChar attribute names
  attrsonly: ULONG        // boolean on whether to only return attr names
): ULONG; cdecl;

function ldap_searchW(
  ld: PLDAP;
  base: PWideChar;        // distinguished name or ''
  scope: ULONG;           // LDAP_SCOPE_xxxx
  filter: PWideChar;
  attrs: PWideChar;       // pointer to an array of PAnsiChar attribute names
  attrsonly: ULONG        // boolean on whether to only return attr names
): ULONG; cdecl;

function ldap_search(
  ld: PLDAP;
  base: PAnsiChar;        // distinguished name or ''
  scope: ULONG;           // LDAP_SCOPE_xxxx
  filter: PAnsiChar;
  attrs: PAnsiChar;       // pointer to an array of PAnsiChar attribute names
  attrsonly: ULONG        // boolean on whether to only return attr names
): ULONG; cdecl;


function ldap_search_sA(ld: PLDAP; base: PAnsiChar; scope: ULONG;
  filter, attrs: PAnsiChar; attrsonly: ULONG;
  var res: PLDAPMessage): ULONG; cdecl;

function ldap_search_sW(ld: PLDAP; base: PWideChar; scope: ULONG;
  filter, attrs: PWideChar; attrsonly: ULONG;
  var res: PLDAPMessage): ULONG; cdecl;

function ldap_search_s(ld: PLDAP; base: PAnsiChar; scope: ULONG;
  filter, attrs: PAnsiChar; attrsonly: ULONG;
  var res: PLDAPMessage): ULONG; cdecl;

function ldap_search_stA(ld: PLDAP; base: PAnsiChar; scope: ULONG;
  filter, attrs: PAnsiChar; attrsonly:  ULONG; var timeout: TLDAPTimeVal;
  var res: PLDAPMessage): ULONG; cdecl;

function ldap_search_stW(ld: PLDAP; base: PWideChar; scope: ULONG;
  filter, attrs: PWideChar; attrsonly:  ULONG; var timeout: TLDAPTimeVal;
  var res: PLDAPMessage): ULONG; cdecl;

function ldap_search_st(ld: PLDAP; base: PAnsiChar; scope: ULONG;
  filter, attrs: PAnsiChar; attrsonly:  ULONG; var timeout: TLDAPTimeVal;
  var res: PLDAPMessage): ULONG; cdecl;

function ldap_search_extA(ld: PLDAP; base: PAnsiChar; scope: ULONG;
  filter, attrs: PAnsiChar; attrsonly: ULONG;
  var ServerControls, ClientControls: PLDAPControlA;
  TimeLimit, SizeLimit: ULONG; var MessageNumber: ULONG): ULONG; cdecl;

function ldap_search_extW(ld: PLDAP; base: PWideChar; scope: ULONG;
  filter, attrs: PWideChar; attrsonly: ULONG;
  var ServerControls, ClientControls: PLDAPControlW;
  TimeLimit, SizeLimit: ULONG; var MessageNumber: ULONG): ULONG; cdecl;

function ldap_search_ext(ld: PLDAP; base: PAnsiChar; scope: ULONG;
  filter, attrs: PAnsiChar; attrsonly: ULONG;
  ServerControls, ClientControls: PPLDAPControl;
  TimeLimit, SizeLimit: ULONG; var MessageNumber: ULONG): ULONG; cdecl;

function ldap_search_ext_sA(ld: PLDAP; base: PAnsiChar; scope: ULONG;
  filter, attrs: PAnsiChar; attrsonly: ULONG;
  var ServerControls, ClientControls: PLDAPControlA;
  var timeout: TLDAPTimeVal; SizeLimit: ULONG;
  var res: PLDAPMessage): ULONG; cdecl;

function ldap_search_ext_sW(ld: PLDAP; base: PWideChar; scope: ULONG;
  filter, attrs: PWideChar; attrsonly: ULONG;
  var ServerControls, ClientControls: PLDAPControlW;
  var timeout: TLDAPTimeVal; SizeLimit: ULONG;
  var res: PLDAPMessage): ULONG; cdecl;

function ldap_search_ext_s(ld: PLDAP; base: PAnsiChar; scope: ULONG;
  filter, attrs: PAnsiChar; attrsonly: ULONG;
  ServerControls, ClientControls: PPLDAPControl;
  timeout: PLDAPTimeVal; SizeLimit: ULONG;
  var res: PLDAPMessage): ULONG; cdecl;

function ldap_check_filterA(ld: PLDAP; SearchFilter: PAnsiChar): ULONG; cdecl;
function ldap_check_filterW(ld: PLDAP; SearchFilter: PWideChar): ULONG; cdecl;
function ldap_check_filter(ld: PLDAP; SearchFilter: PAnsiChar): ULONG; cdecl;
function ldap_modifyA(ld: PLDAP; dn: PAnsiChar; var mods: PLDAPModA): ULONG; cdecl;
function ldap_modifyW(ld: PLDAP; dn: PWideChar; var mods: PLDAPModW): ULONG; cdecl;
function ldap_modify(ld: PLDAP; dn: PAnsiChar; var mods: PLDAPMod): ULONG; cdecl;
function ldap_modify_sA(ld: PLDAP; dn: PAnsiChar; var mods: PLDAPModA): ULONG; cdecl;
function ldap_modify_sW(ld: PLDAP; dn: PWideChar; var mods: PLDAPModW): ULONG; cdecl;
function ldap_modify_s(ld: PLDAP; dn: PAnsiChar; mods: PLDAPMod): ULONG; cdecl;
function ldap_modify_extA(ld: PLDAP; dn: PAnsiChar; var mods: PLDAPModA;
  var ServerControls, ClientControls: PLDAPControlA;
  var MessageNumber: ULONG): ULONG; cdecl;

function ldap_modify_extW(ld: PLDAP; dn: PWideChar; var mods: PLDAPModW;
  var ServerControls, ClientControls: PLDAPControlW;
  var MessageNumber: ULONG): ULONG; cdecl;

function ldap_modify_ext(ld: PLDAP; dn: PAnsiChar; var mods: PLDAPMod;
  var ServerControls, ClientControls: PLDAPControl;
  var MessageNumber: ULONG): ULONG; cdecl;

function ldap_modify_ext_sA(ld: PLDAP; dn: PAnsiChar; var mods: PLDAPModA;
  var ServerControls, ClientControls: PLDAPControlA): ULONG; cdecl;

function ldap_modify_ext_sW(ld: PLDAP; dn: PWideChar; var mods: PLDAPModW;
  var ServerControls, ClientControls: PLDAPControlW): ULONG; cdecl;

function ldap_modify_ext_s(ld: PLDAP; dn: PAnsiChar; mods: PPLDAPMod;
  ServerControls, ClientControls: PPLDAPControl): ULONG; cdecl;

function ldap_modrdn2A(var ExternalHandle: LDAP;
  DistinguishedName, NewDistinguishedName: PAnsiChar;
  DeleteOldRdn: Integer): ULONG; cdecl;

function ldap_modrdn2W(var ExternalHandle: LDAP;
  DistinguishedName, NewDistinguishedName: PWideChar;
  DeleteOldRdn: Integer): ULONG; cdecl;

function ldap_modrdn2(var ExternalHandle: LDAP;
  DistinguishedName, NewDistinguishedName: PAnsiChar;
  DeleteOldRdn: Integer): ULONG; cdecl;

function ldap_modrdnA(var ExternalHandle: LDAP;
  DistinguishedName, NewDistinguishedName: PAnsiChar): ULONG; cdecl;

function ldap_modrdnW(var ExternalHandle: LDAP;
  DistinguishedName, NewDistinguishedName: PWideChar): ULONG; cdecl;

function ldap_modrdn(var ExternalHandle: LDAP;
  DistinguishedName, NewDistinguishedName: PAnsiChar): ULONG; cdecl;

function ldap_modrdn2_sA(var ExternalHandle: LDAP;
  DistinguishedName, NewDistinguishedName: PAnsiChar;
  DeleteOldRdn: Integer): ULONG; cdecl;

function ldap_modrdn2_sW(var ExternalHandle: LDAP;
  DistinguishedName, NewDistinguishedName: PWideChar;
  DeleteOldRdn: Integer): ULONG; cdecl;

function ldap_modrdn2_s(var ExternalHandle: LDAP;
  DistinguishedName, NewDistinguishedName: PAnsiChar;
  DeleteOldRdn: Integer): ULONG; cdecl;

function ldap_modrdn_sA(var ExternalHandle: LDAP;
  DistinguishedName, NewDistinguishedName: PAnsiChar): ULONG; cdecl;

function ldap_modrdn_sW(var ExternalHandle: LDAP;
  DistinguishedName, NewDistinguishedName: PWideChar): ULONG; cdecl;

function ldap_modrdn_s(var ExternalHandle: LDAP;
  DistinguishedName, NewDistinguishedName: PAnsiChar): ULONG; cdecl;

function ldap_rename_extA(ld: PLDAP; dn, NewRDN, NewParent: PAnsiChar;
  DeleteOldRdn: Integer; var ServerControls, ClientControls: PLDAPControlA;
  var MessageNumber: ULONG): ULONG; cdecl;

function ldap_rename_extW(ld: PLDAP; dn, NewRDN, NewParent: PWideChar;
  DeleteOldRdn: Integer; var ServerControls, ClientControls: PLDAPControlW;
  var MessageNumber: ULONG): ULONG; cdecl;

function ldap_rename_ext(ld: PLDAP; dn, NewRDN, NewParent: PAnsiChar;
  DeleteOldRdn: Integer; var ServerControls, ClientControls: PLDAPControl;
  var MessageNumber: ULONG): ULONG; cdecl;

function ldap_rename_ext_sA(ld: PLDAP;
  dn, NewRDN, NewParent: PAnsiChar; DeleteOldRdn: Integer;
  var ServerControls, ClientControls: PLDAPControlA): ULONG; cdecl;

function ldap_rename_ext_sW(ld: PLDAP;
  dn, NewRDN, NewParent: PWideChar; DeleteOldRdn: Integer;
  var ServerControls, ClientControls: PLDAPControlW): ULONG; cdecl;

function ldap_rename_ext_s(ld: PLDAP;
  dn, NewRDN, NewParent: PAnsiChar; DeleteOldRdn: Integer;
  ServerControls, ClientControls: PPLDAPControl): ULONG; cdecl;

function ldap_addA(ld: PLDAP; dn: PAnsiChar; var attrs: PLDAPModA): ULONG; cdecl;
function ldap_addW(ld: PLDAP; dn: PWideChar; var attrs: PLDAPModW): ULONG; cdecl;
function ldap_add(ld: PLDAP; dn: PAnsiChar; var attrs: PLDAPMod): ULONG; cdecl;
function ldap_add_sA(ld: PLDAP; dn: PAnsiChar; var attrs: PLDAPModA): ULONG; cdecl;
function ldap_add_sW(ld: PLDAP; dn: PWideChar; var attrs: PLDAPModW): ULONG; cdecl;
function ldap_add_s(ld: PLDAP; dn: PAnsiChar; var attrs: PLDAPMod): ULONG; cdecl;
function ldap_add_extA(ld: PLDAP; dn: PAnsiChar; var attrs: PLDAPModA;
  var ServerControls, ClientControls: PLDAPControlA;
  var MessageNumber: ULONG): ULONG; cdecl;

function ldap_add_extW(ld: PLDAP; dn: PWideChar; var attrs: PLDAPModW;
  var ServerControls, ClientControls: PLDAPControlW;
  var MessageNumber: ULONG): ULONG; cdecl;

function ldap_add_ext(ld: PLDAP; dn: PAnsiChar; var attrs: PLDAPMod;
  var ServerControls, ClientControls: PLDAPControl;
  var MessageNumber: ULONG): ULONG; cdecl;

function ldap_add_ext_sA(ld: PLDAP; dn: PAnsiChar; var attrs: PLDAPModA;
  var ServerControls, ClientControls: PLDAPControlA): ULONG; cdecl;
function ldap_add_ext_sW(ld: PLDAP; dn: PWideChar; var attrs: PLDAPModW;
  var ServerControls, ClientControls: PLDAPControlW): ULONG; cdecl;
function ldap_add_ext_s(ld: PLDAP; dn: PAnsiChar; attrs: PPLDAPMod;
  ServerControls, ClientControls: PPLDAPControl): ULONG; cdecl;

function ldap_compareA(ld: PLDAP; dn, attr, value: PAnsiChar): ULONG; cdecl;
function ldap_compareW(ld: PLDAP; dn, attr, value: PWideChar): ULONG; cdecl;
function ldap_compare(ld: PLDAP; dn, attr, value: PAnsiChar): ULONG; cdecl;
function ldap_compare_sA(ld: PLDAP; dn, attr, value: PAnsiChar): ULONG; cdecl;
function ldap_compare_sW(ld: PLDAP; dn, attr, value: PWideChar): ULONG; cdecl;
function ldap_compare_s(ld: PLDAP; dn, attr, value: PAnsiChar): ULONG; cdecl;

function ldap_compare_extA(ld: PLDAP; dn, Attr, Value: PAnsiChar;
  Data: PLDAPBerVal; var ServerControls, ClientControls: PLDAPControlA;
  var MessageNumber: ULONG): ULONG; cdecl;

function ldap_compare_extW(ld: PLDAP; dn, Attr, Value: PWideChar;
  Data: PLDAPBerVal; var ServerControls, ClientControls: PLDAPControlW;
  var MessageNumber: ULONG): ULONG; cdecl;

function ldap_compare_ext(ld: PLDAP; dn, Attr, Value: PAnsiChar;
  Data: PLDAPBerVal; var ServerControls, ClientControls: PLDAPControl;
  var MessageNumber: ULONG): ULONG; cdecl;

function ldap_compare_ext_sA(ld: PLDAP;
  dn, Attr, Value: PAnsiChar; Data: PLDAPBerVal;
  var ServerControls, ClientControls: PLDAPControlA): ULONG; cdecl;

function ldap_compare_ext_sW(ld: PLDAP;
  dn, Attr, Value: PWideChar; Data: PLDAPBerVal;
  var ServerControls, ClientControls: PLDAPControlW): ULONG; cdecl;

function ldap_compare_ext_s(ld: PLDAP;
  dn, Attr, Value: PAnsiChar; Data: PLDAPBerVal;
  var ServerControls, ClientControls: PLDAPControl): ULONG; cdecl;

function ldap_deleteA(ld: PLDAP; dn: PAnsiChar): ULONG; cdecl;
function ldap_deleteW(ld: PLDAP; dn: PWideChar): ULONG; cdecl;
function ldap_delete(ld: PLDAP; dn: PAnsiChar): ULONG; cdecl;
function ldap_delete_sA(ld: PLDAP; dn: PAnsiChar): ULONG; cdecl;
function ldap_delete_sW(ld: PLDAP; dn: PWideChar): ULONG; cdecl;
function ldap_delete_s(ld: PLDAP; dn: PAnsiChar): ULONG; cdecl;
function ldap_delete_extA(ld: PLDAP; dn: PAnsiChar;
  var ServerControls, ClientControls: PLDAPControlA;
  var MessageNumber: ULONG): ULONG; cdecl;

function ldap_delete_extW(ld: PLDAP; dn: PWideChar;
  var ServerControls, ClientControls: PLDAPControlW;
  var MessageNumber: ULONG): ULONG; cdecl;

function ldap_delete_ext(ld: PLDAP; dn: PAnsiChar;
  var ServerControls, ClientControls: PLDAPControl;
  var MessageNumber: ULONG): ULONG; cdecl;

function ldap_delete_ext_sA(ld: PLDAP; dn: PAnsiChar;
  var ServerControls, ClientControls: PLDAPControlA): ULONG; cdecl;

function ldap_delete_ext_sW(ld: PLDAP; dn: PWideChar;
  var ServerControls, ClientControls: PLDAPControlW): ULONG; cdecl;

function ldap_delete_ext_s(ld: PLDAP; dn: PAnsiChar;
  ServerControls, ClientControls: PLDAPControl): ULONG; cdecl;

function ldap_abandon(ld: PLDAP; msgid: ULONG): ULONG; cdecl;

const
  LDAP_MSG_ONE       = 0;
  LDAP_MSG_ALL       = 1;
  LDAP_MSG_RECEIVED  = 2;

function ldap_result(ld: PLDAP; msgid, all: ULONG;
  timeout: PLDAP_TIMEVAL; var res: PLDAPMessage): ULONG; cdecl;

function ldap_msgfree(res: PLDAPMessage): ULONG; cdecl;
function ldap_result2error(ld: PLDAP; res: PLDAPMessage;
  freeit: ULONG): ULONG; cdecl;

function ldap_parse_resultA (
        var Connection: LDAP;
        ResultMessage: PLDAPMessage;
        ReturnCode: PULONG;                     // returned by server
        MatchedDNs: PPCharA;                    // free with ldap_memfree
        ErrorMessage: PPCharA;                  // free with ldap_memfree
        Referrals: PPPCharA;                    // free with ldap_value_freeW
        var ServerControls: PPLDAPControlA;     // free with ldap_free_controlsW
        Freeit: BOOL): ULONG; cdecl;

function ldap_parse_resultW (
        var Connection: LDAP;
        ResultMessage: PLDAPMessage;
        ReturnCode: PULONG;                     // returned by server
        MatchedDNs: PPCharW;                    // free with ldap_memfree
        ErrorMessage: PPCharW;                  // free with ldap_memfree
        Referrals: PPPCharW;                    // free with ldap_value_freeW
        var ServerControls: PPLDAPControlW;     // free with ldap_free_controlsW
        Freeit: BOOL): ULONG; cdecl;

function ldap_parse_result (
        var Connection: LDAP;
        ResultMessage: PLDAPMessage;
        ReturnCode: PULONG;                     // returned by server
        MatchedDNs: PPAnsiChar;                    // free with ldap_memfree
        ErrorMessage: PPAnsiChar;                  // free with ldap_memfree
        Referrals: PPPChar;                    // free with ldap_value_freeW
        var ServerControls: PPLDAPControl;     // free with ldap_free_controlsW
        Freeit: BOOL): ULONG; cdecl;

function ldap_controls_freeA(Controls: PPLDAPControlA): ULONG; cdecl;
function ldap_controls_freeW(Controls: PPLDAPControlW): ULONG; cdecl;
function ldap_controls_free(Controls: PPLDAPControl): ULONG; cdecl;

function ldap_parse_extended_resultA(
  Connection: PLDAP;
  ResultMessage: PLDAPMessage;          // returned by server
  var ResultOID: PAnsiChar;             // free with ldap_memfree
  var ResultData: PBERVAL;              // free with ldap_memfree
  Freeit: ByteBool                      // Don't need the message anymore
): ULONG; cdecl;

function ldap_parse_extended_resultW(
  Connection: PLDAP;
  ResultMessage: PLDAPMessage;          // returned by server
  var ResultOID: PWideChar;             // free with ldap_memfree
  var ResultData: PBERVAL;              // free with ldap_memfree
  Freeit: ByteBool                      // Don't need the message anymore
): ULONG; cdecl;

function ldap_parse_extended_result(
  Connection: PLDAP;
  ResultMessage: PLDAPMessage;          // returned by server
  var ResultOID: PAnsiChar;             // free with ldap_memfree
  var ResultData: PBERVAL;              // free with ldap_memfree
  Freeit: ByteBool                      // Don't need the message anymore
): ULONG; cdecl;

function ldap_control_freeA(Control: PLDAPControlA): ULONG; cdecl;
function ldap_control_freeW(Control: PLDAPControlW): ULONG; cdecl;
function ldap_control_free(Control: PLDAPControl): ULONG; cdecl;
function ldap_free_controlsA(var Controls: PLDAPControlA): ULONG; cdecl;
function ldap_free_controlsW(var Controls: PLDAPControlW): ULONG; cdecl;
function ldap_free_controls(var Controls: PLDAPControl): ULONG; cdecl;
function ldap_err2stringA(err: ULONG): PAnsiChar; cdecl;
function ldap_err2stringW(err: ULONG): PWideChar; cdecl;
function ldap_err2string(err: ULONG): PAnsiChar; cdecl;
procedure ldap_perror(ld: PLDAP; msg: PAnsiChar); cdecl;
function ldap_first_entry(ld: PLDAP; res: PLDAPMessage): PLDAPMessage; cdecl;
function ldap_next_entry(ld: PLDAP; entry: PLDAPMessage): PLDAPMessage; cdecl;
function ldap_count_entries(ld: PLDAP; res: PLDAPMessage): ULONG; cdecl;

type
  PBerElement = ^BerElement;
  BerElement = record
    opaque: PAnsiChar;
  end;

const
  NULLBER = PBerElement(nil);

function ldap_first_attributeA(ld: PLDAP; entry: PLDAPMessage;
  var ptr: PBerElement): PAnsiChar; cdecl;
function ldap_first_attributeW(ld: PLDAP; entry: PLDAPMessage;
  var ptr: PBerElement): PWideChar; cdecl;
function ldap_first_attribute(ld: PLDAP; entry: PLDAPMessage;
  var ptr: PBerElement): PAnsiChar; cdecl;

function ldap_next_attributeA(ld: PLDAP; entry: PLDAPMessage;
  ptr: PBerElement): PAnsiChar; cdecl;

function ldap_next_attributeW(ld: PLDAP; entry: PLDAPMessage;
  ptr: PBerElement): PWideChar; cdecl;

function ldap_next_attribute(ld: PLDAP; entry: PLDAPMessage;
  ptr: PBerElement): PAnsiChar; cdecl;

function ldap_get_valuesA(ld: PLDAP; entry: PLDAPMessage;
  attr: PAnsiChar): PPCharA; cdecl;

function ldap_get_valuesW(ld: PLDAP; entry: PLDAPMessage;
  attr: PWideChar): PPCharW; cdecl;

function ldap_get_values(ld: PLDAP; entry: PLDAPMessage;
  attr: PAnsiChar): PPAnsiChar; cdecl;

function ldap_get_values_lenA(ExternalHandle: PLDAP; Message: PLDAPMessage;
 attr: PAnsiChar): PPLDAPBerVal; cdecl;

function ldap_get_values_lenW(ExternalHandle: PLDAP; Message: PLDAPMessage;
 attr: PWideChar): PPLDAPBerVal; cdecl;

function ldap_get_values_len(ExternalHandle: PLDAP; Message: PLDAPMessage;
 attr: PAnsiChar): PPLDAPBerVal; cdecl;

function ldap_count_valuesA(vals: PPCharA): ULONG; cdecl;
function ldap_count_valuesW(vals: PPCharW): ULONG; cdecl;
function ldap_count_values(vals: PPAnsiChar): ULONG; cdecl;
function ldap_count_values_len(vals: PPLDAPBerVal): ULONG; cdecl;
function ldap_value_freeA(vals: PPCharA): ULONG; cdecl;
function ldap_value_freeW(vals: PPCharW): ULONG; cdecl;
function ldap_value_free(vals: PPAnsiChar): ULONG; cdecl;
function ldap_value_free_len(vals: PPLDAPBerVal): ULONG; cdecl;
function ldap_get_dnA(ld: PLDAP; entry: PLDAPMessage): PAnsiChar; cdecl;
function ldap_get_dnW(ld: PLDAP; entry: PLDAPMessage): PWideChar; cdecl;
function ldap_get_dn(ld: PLDAP; entry: PLDAPMessage): PAnsiChar; cdecl;
function ldap_explode_dnA(dn: PAnsiChar; notypes: ULONG): PPCharA; cdecl;
function ldap_explode_dnW(dn: PWideChar; notypes: ULONG): PPCharW; cdecl;
function ldap_explode_dn(dn: PAnsiChar; notypes: ULONG): PPAnsiChar; cdecl;
function ldap_dn2ufnA(dn: PAnsiChar): PAnsiChar; cdecl;
function ldap_dn2ufnW(dn: PWideChar): PWideChar; cdecl;
function ldap_dn2ufn(dn: PAnsiChar): PAnsiChar; cdecl;
procedure ldap_memfreeA(Block: PAnsiChar); cdecl;
procedure ldap_memfreeW(Block: PWideChar); cdecl;
procedure ldap_memfree(Block: PAnsiChar); cdecl;
procedure ber_bvfree(bv: PLDAPBerVal); cdecl;
function ldap_ufn2dnA(ufn: PAnsiChar; var pDn: PAnsiChar): ULONG; cdecl;
function ldap_ufn2dnW(ufn: PWideChar; var pDn: PWideChar): ULONG; cdecl;
function ldap_ufn2dn(ufn: PAnsiChar; var pDn: PAnsiChar): ULONG; cdecl;

const
  LBER_USE_DER            = $01;
  LBER_USE_INDEFINITE_LEN = $02;
  LBER_TRANSLATE_STRINGS  = $04;

  LAPI_MAJOR_VER1     = 1;
  LAPI_MINOR_VER1     = 1;

type
  PLDAPVersionInfo = ^TLDAPVersionInfo;
  PLDAP_VERSION_INFO = ^LDAP_VERSION_INFO;
  LDAP_VERSION_INFO = record
     lv_size: ULONG;
     lv_major: ULONG;
     lv_minor: ULONG;
  end;
  TLDAPVersionInfo = LDAP_VERSION_INFO;

function ldap_startup(var version: TLDAPVersionInfo): ULONG; cdecl;
function ldap_cleanup(hInstance: THandle): ULONG; cdecl;
function ldap_escape_filter_elementA(
  sourceFilterElement: PAnsiChar; sourceLength: ULONG;
  destFilterElement: PAnsiChar; destLength: ULONG): ULONG; cdecl;

function ldap_escape_filter_elementW(
  sourceFilterElement: PAnsiChar; sourceLength: ULONG;
  destFilterElement: PWideChar; destLength: ULONG): ULONG; cdecl;

function ldap_escape_filter_element(
  sourceFilterElement: PAnsiChar; sourceLength: ULONG;
  destFilterElement: PAnsiChar; destLength: ULONG): ULONG; cdecl;

function ldap_set_dbg_flags(NewFlags: ULONG): ULONG; cdecl;

type
  DBGPRINT = function(Format: PAnsiChar {; ...} ): ULONG cdecl;
  TDbgPrint = DBGPRINT;

procedure ldap_set_dbg_routine(DebugPrintRoutine: TDbgPrint); cdecl;
function LdapUTF8ToUnicode(lpSrcStr: LPCSTR; cchSrc: Integer;
  lpDestStr: LPWSTR; cchDest: Integer): Integer; cdecl;

function LdapUnicodeToUTF8(lpSrcStr: LPCWSTR; cchSrc: Integer;
  lpDestStr: LPSTR; cchDest: Integer): Integer; cdecl;

const
  LDAP_SERVER_SORT_OID        = '1.2.840.113556.1.4.473';
  LDAP_SERVER_SORT_OID_W      = '1.2.840.113556.1.4.473';
  LDAP_SERVER_RESP_SORT_OID   = '1.2.840.113556.1.4.474';
  LDAP_SERVER_RESP_SORT_OID_W = '1.2.840.113556.1.4.474';

type
  PLDAPSearch = ^LDAPSearch;
  LDAPSearch = record end;
  PLDAPSortKeyA = ^LDAPSortKeyA;
  PLDAPSortKeyW = ^LDAPSortKeyW;
  PLDAPSortKey = PLDAPSortKeyA;

  LDAPSortKeyA = packed record
    sk_attrtype: PAnsiChar;
    sk_matchruleoid: PAnsiChar;
    sk_reverseorder: ByteBool;
  end;

  LDAPSortKeyW = packed record
    sk_attrtype: PWideChar;
    sk_matchruleoid: PWideChar;
    sk_reverseorder: ByteBool;
  end;

  LDAPSortKey = LDAPSortKeyA;

function ldap_create_sort_controlA(ExternalHandle: PLDAP;
  var SortKeys: PLDAPSortKeyA; IsCritical: UCHAR;
  var Control: PLDAPControlA): ULONG; cdecl;

function ldap_create_sort_controlW(ExternalHandle: PLDAP;
  var SortKeys: PLDAPSortKeyW; IsCritical: UCHAR;
  var Control: PLDAPControlW): ULONG; cdecl;

function ldap_create_sort_control(ExternalHandle: PLDAP;
  var SortKeys: PLDAPSortKey; IsCritical: UCHAR;
  var Control: PLDAPControl): ULONG; cdecl;

function ldap_parse_sort_controlA(ExternalHandle: PLDAP;
  var Control: PLDAPControlA; var Result: ULONG;
  var Attribute: PAnsiChar): ULONG; cdecl;

function ldap_parse_sort_controlW(ExternalHandle: PLDAP;
  var Control: PLDAPControlW; var Result: ULONG;
  var Attribute: PWideChar): ULONG; cdecl;

function ldap_parse_sort_control(ExternalHandle: PLDAP;
  var Control: PLDAPControl; var Result: ULONG;
  var Attribute: PAnsiChar): ULONG; cdecl;

function ldap_encode_sort_controlA(ExternalHandle: PLDAP;
  var SortKeys: PLDAPSortKeyA; Control: PLDAPControlA;
  Criticality: ByteBool): ULONG; cdecl;

function ldap_encode_sort_controlW(ExternalHandle: PLDAP;
  var SortKeys: PLDAPSortKeyW; Control: PLDAPControlW;
  Criticality: ByteBool): ULONG; cdecl;

function ldap_encode_sort_control(ExternalHandle: PLDAP;
  var SortKeys: PLDAPSortKey; Control: PLDAPControl;
  Criticality: ByteBool): ULONG; cdecl;

function ldap_create_page_controlA(ExternalHandle: PLDAP;
  PageSize: ULONG; var Cookie: TLDAPBerVal; IsCritical: UCHAR;
  var Control: PLDAPControlA): ULONG; cdecl;

function ldap_create_page_controlW(ExternalHandle: PLDAP;
  PageSize: ULONG; var Cookie: TLDAPBerVal; IsCritical: UCHAR;
  var Control: PLDAPControlW): ULONG; cdecl;

//function ldap_create_page_control(ExternalHandle: PLDAP;
//  PageSize: ULONG; var Cookie: TLDAPBerVal; IsCritical: UCHAR;
//  var Control: PLDAPControl): ULONG; cdecl; overload;

function ldap_create_page_control(ExternalHandle: PLDAP;
  PageSize: ULONG; Cookie: PLDAPBerVal; IsCritical: UCHAR;
  var Control: PLDAPControl): ULONG; cdecl;

function ldap_parse_page_controlA(ExternalHandle: PLDAP;
  ServerControls: PPLDAPControlA; var TotalCount: ULONG;
  var Cookie: PLDAPBerVal): ULONG; cdecl;

function ldap_parse_page_controlW(ExternalHandle: PLDAP;
  ServerControls: PPLDAPControlW; var TotalCount: ULONG;
  var Cookie: PLDAPBerVal): ULONG; cdecl;

function ldap_parse_page_control(ExternalHandle: PLDAP;
  ServerControls: PPLDAPControl; var TotalCount: ULONG;
  var Cookie: PLDAPBerVal): ULONG; cdecl;

const
  LDAP_PAGED_RESULT_OID_STRING   = '1.2.840.113556.1.4.319';
  LDAP_PAGED_RESULT_OID_STRING_W = '1.2.840.113556.1.4.319';

function ldap_search_init_pageA(ExternalHandle: PLDAP;
  DistinguishedName: PAnsiChar; ScopeOfSearch: ULONG; SearchFilter: PAnsiChar;
  AttributeList: PPCharA; AttributesOnly: ULONG;
  var ServerControls, ClientControls: PLDAPControlA;
  PageTimeLimit, TotalSizeLimit: ULONG;
  var SortKeys: PLDAPSortKeyA): PLDAPSearch; cdecl;

function ldap_search_init_pageW(ExternalHandle: PLDAP;
  DistinguishedName: PWideChar; ScopeOfSearch: ULONG; SearchFilter: PWideChar;
  AttributeList: PPCharW; AttributesOnly: ULONG;
  var ServerControls, ClientControls: PLDAPControlW;
  PageTimeLimit, TotalSizeLimit: ULONG;
  var SortKeys: PLDAPSortKeyW): PLDAPSearch; cdecl;

function ldap_search_init_page(ExternalHandle: PLDAP;
  DistinguishedName: PAnsiChar; ScopeOfSearch: ULONG; SearchFilter: PAnsiChar;
  AttributeList: PPAnsiChar; AttributesOnly: ULONG;
  var ServerControls, ClientControls: PLDAPControl;
  PageTimeLimit, TotalSizeLimit: ULONG;
  var SortKeys: PLDAPSortKey): PLDAPSearch; cdecl;

function ldap_get_next_page(ExternalHandle: PLDAP; SearchHandle: PLDAPSearch;
  PageSize: ULONG; var MessageNumber: ULONG): ULONG; cdecl;

function ldap_get_next_page_s(ExternalHandle: PLDAP; SearchHandle: PLDAPSearch;
  var timeout: TLDAPTimeVal; PageSize: ULONG; var TotalCount: ULONG;
  var Results: PLDAPMessage): ULONG; cdecl;

function ldap_get_paged_count(ExternalHandle: PLDAP; SearchBlock: PLDAPSearch;
  var TotalCount: ULONG; Results: PLDAPMessage): ULONG; cdecl;

function ldap_search_abandon_page(ExternalHandle: PLDAP;
  SearchBlock: PLDAPSearch): ULONG; cdecl;

function ldap_first_reference(ld: PLDAP; res: PLDAPMessage): PLDAPMessage;
function ldap_next_reference(ld: PLDAP; entry: PLDAPMessage): PLDAPMessage;
function ldap_count_references(ld: PLDAP; res: PLDAPMessage): ULONG; cdecl;
function ldap_parse_referenceA(Connection: PLDAP; ResultMessage: PLDAPMessage;
  var Referrals: PPCharA): ULONG; cdecl;

function ldap_parse_referenceW(Connection: PLDAP; ResultMessage: PLDAPMessage;
  var Referrals: PPCharW): ULONG; cdecl;

function ldap_parse_reference(Connection: PLDAP; ResultMessage: PLDAPMessage;
  var Referrals: PPAnsiChar): ULONG; cdecl;

function ldap_extended_operationA(ld: PLDAP; Oid: PAnsiChar;
  var Data: TLDAPBerVal; var ServerControls, ClientControls: PLDAPControlA;
  var MessageNumber: ULONG): ULONG; cdecl;

function ldap_extended_operationW(ld: PLDAP; Oid: PWideChar;
  var Data: TLDAPBerVal; var ServerControls, ClientControls: PLDAPControlW;
  var MessageNumber: ULONG): ULONG; cdecl;

function ldap_extended_operation(ld: PLDAP; Oid: PAnsiChar;
  var Data: TLDAPBerVal; var ServerControls, ClientControls: PLDAPControl;
  var MessageNumber: ULONG): ULONG; cdecl;

function ldap_close_extended_op(ld: PLDAP; MessageNumber: ULONG): ULONG; cdecl;

const
  LDAP_OPT_REFERRAL_CALLBACK = $70;

type
  QUERYFORCONNECTION = function(
    PrimaryConnection: PLDAP;
    ReferralFromConnection: PLDAP;
    NewDN: PWideChar;
    HostName: PAnsiChar;
    PortNumber: ULONG;
    SecAuthIdentity: Pointer;
    CurrentUserToken: Pointer;
    var ConnectionToUse: PLDAP):ULONG cdecl;
  TQueryForConnection = QUERYFORCONNECTION;

  NOTIFYOFNEWCONNECTION = function(
    PrimaryConnection: PLDAP;
    ReferralFromConnection: PLDAP;
    NewDN: PWideChar;
    HostName: PAnsiChar;
    NewConnection: PLDAP;
    PortNumber: ULONG;
    SecAuthIdentity: Pointer;
    CurrentUser: Pointer;
    ErrorCodeFromBind: ULONG): ByteBool cdecl;
  TNotifyOfNewConnection = NOTIFYOFNEWCONNECTION;

 DEREFERENCECONNECTION = function(PrimaryConnection: PLDAP;
   ConnectionToDereference: PLDAP): ULONG cdecl;
 TDereferenceConnection = DEREFERENCECONNECTION;

  PLDAPReferralCallback = ^TLDAPReferralCallback;
  LdapReferralCallback = packed record
    SizeOfCallbacks: ULONG;
    QueryForConnection: QUERYFORCONNECTION;
    NotifyRoutine: NOTIFYOFNEWCONNECTION;
    DereferenceRoutine: DEREFERENCECONNECTION;
  end;
  LDAP_REFERRAL_CALLBACK = LdapReferralCallback;
  PLDAP_REFERRAL_CALLBACK = ^LdapReferralCallback;
  TLDAPReferralCallback = LdapReferralCallback;

function LdapGetLastError: ULONG; cdecl;
function LdapMapErrorToWin32(LdapError: ULONG): ULONG; cdecl;

const
  LDAP_OPT_CLIENT_CERTIFICATE    = $80;

type
  QUERYCLIENTCERT = function(
    Connection: PLDAP;
    trusted_CAs: Pointer;
    hCertStore: LongWord;
    var pcCreds: DWORD
  ): ByteBool cdecl;

const
  LDAP_OPT_SERVER_CERTIFICATE    = $81;

type
  VERIFYSERVERCERT = function(
    Connection: PLDAP;
    pServerCert: Pointer
  ): ByteBool cdecl;

function ldap_conn_from_msg(PrimaryConn: PLDAP; res: PLDAPMessage): PLDAP; cdecl;

const
  LDAP_OPT_REF_DEREF_CONN_PER_MSG = $94;


implementation
const
  wldap32 = 'wldap32.dll';

function ldap_openA; external wldap32 name 'ldap_openA';
function ldap_openW; external wldap32 name 'ldap_openW';
function ldap_open; external wldap32 name 'ldap_openA';
function ldap_initA; external wldap32 name 'ldap_initA';
function ldap_initW; external wldap32 name 'ldap_initW';
function ldap_init; external wldap32 name 'ldap_initA';
function ldap_sslinitA; external wldap32 name 'ldap_sslinitA';
function ldap_sslinitW; external wldap32 name 'ldap_sslinitW';
function ldap_sslinit; external wldap32 name 'ldap_sslinitA';
function cldap_openA; external wldap32 name 'cldap_openA';
function cldap_openW; external wldap32 name 'cldap_openW';
function cldap_open; external wldap32 name 'cldap_openA';
function ldap_simple_bindA; external wldap32 name 'ldap_simple_bindA';
function ldap_simple_bindW; external wldap32 name 'ldap_simple_bindW';
function ldap_simple_bind; external wldap32 name 'ldap_simple_bindA';
function ldap_simple_bind_sA; external wldap32 name 'ldap_simple_bind_sA';
function ldap_simple_bind_sW; external wldap32 name 'ldap_simple_bind_sW';
function ldap_simple_bind_s; external wldap32 name 'ldap_simple_bind_sA';
function ldap_bindA; external wldap32 name 'ldap_bindA';
function ldap_bindW; external wldap32 name 'ldap_bindW';
function ldap_bind; external wldap32 name 'ldap_bindA';
function ldap_bind_sA; external wldap32 name 'ldap_bind_sA';
function ldap_bind_sW; external wldap32 name 'ldap_bind_sW';
function ldap_bind_s; external wldap32 name 'ldap_bind_sA';
function ldap_sasl_bindA; external wldap32 name 'ldap_sasl_bindA';
function ldap_sasl_bindW; external wldap32 name 'ldap_sasl_bindW';
function ldap_sasl_bind; external wldap32 name 'ldap_sasl_bindA';
function ldap_sasl_bind_sA; external wldap32 name 'ldap_sasl_bind_sA';
function ldap_sasl_bind_sW; external wldap32 name 'ldap_sasl_bind_sW';
function ldap_sasl_bind_s; external wldap32 name 'ldap_sasl_bind_sA';
function ldap_searchA; external wldap32 name 'ldap_searchA';
function ldap_searchW; external wldap32 name 'ldap_searchW';
function ldap_search; external wldap32 name 'ldap_searchA';
function ldap_search_sA; external wldap32 name 'ldap_search_sA';
function ldap_search_sW; external wldap32 name 'ldap_search_sW';
function ldap_search_s; external wldap32 name 'ldap_search_sA';
function ldap_search_stA; external wldap32 name 'ldap_search_stA';
function ldap_search_stW; external wldap32 name 'ldap_search_stW';
function ldap_search_st; external wldap32 name 'ldap_search_stA';
function ldap_modifyA; external wldap32 name 'ldap_modifyA';
function ldap_modifyW; external wldap32 name 'ldap_modifyW';
function ldap_modify; external wldap32 name 'ldap_modifyA';
function ldap_modify_sA; external wldap32 name 'ldap_modify_sA';
function ldap_modify_sW; external wldap32 name 'ldap_modify_sW';
function ldap_modify_s; external wldap32 name 'ldap_modify_sA';
function ldap_modrdn2A; external wldap32 name 'ldap_modrdn2A';
function ldap_modrdn2W; external wldap32 name 'ldap_modrdn2W';
function ldap_modrdn2; external wldap32 name 'ldap_modrdn2A';
function ldap_modrdnA; external wldap32 name 'ldap_modrdnA';
function ldap_modrdnW; external wldap32 name 'ldap_modrdnW';
function ldap_modrdn; external wldap32 name 'ldap_modrdnA';
function ldap_modrdn2_sA; external wldap32 name 'ldap_modrdn2_sA';
function ldap_modrdn2_sW; external wldap32 name 'ldap_modrdn2_sW';
function ldap_modrdn2_s; external wldap32 name 'ldap_modrdn2_sA';
function ldap_modrdn_sA; external wldap32 name 'ldap_modrdn_sA';
function ldap_modrdn_sW; external wldap32 name 'ldap_modrdn_sW';
function ldap_modrdn_s; external wldap32 name 'ldap_modrdn_sA';
function ldap_addA; external wldap32 name 'ldap_addA';
function ldap_addW; external wldap32 name 'ldap_addW';
function ldap_add; external wldap32 name 'ldap_addA';
function ldap_add_sA; external wldap32 name 'ldap_add_sA';
function ldap_add_sW; external wldap32 name 'ldap_add_sW';
function ldap_add_s; external wldap32 name 'ldap_add_sA';
function ldap_compareA; external wldap32 name 'ldap_compareA';
function ldap_compareW; external wldap32 name 'ldap_compareW';
function ldap_compare; external wldap32 name 'ldap_compareA';
function ldap_compare_sA; external wldap32 name 'ldap_compare_sA';
function ldap_compare_sW; external wldap32 name 'ldap_compare_sW';
function ldap_compare_s; external wldap32 name 'ldap_compare_sA';
function ldap_deleteA; external wldap32 name 'ldap_deleteA';
function ldap_deleteW; external wldap32 name 'ldap_deleteW';
function ldap_delete; external wldap32 name 'ldap_deleteA';
function ldap_delete_sA; external wldap32 name 'ldap_delete_sA';
function ldap_delete_sW; external wldap32 name 'ldap_delete_sW';
function ldap_delete_s; external wldap32 name 'ldap_delete_sA';
function ldap_err2stringA; external wldap32 name 'ldap_err2stringA';
function ldap_err2stringW; external wldap32 name 'ldap_err2stringW';
function ldap_err2string; external wldap32 name 'ldap_err2stringA';
function ldap_first_attributeA; external wldap32 name 'ldap_first_attributeA';
function ldap_first_attributeW; external wldap32 name 'ldap_first_attributeW';
function ldap_first_attribute; external wldap32 name 'ldap_first_attributeA';
function ldap_next_attributeA; external wldap32 name 'ldap_next_attributeA';
function ldap_next_attributeW; external wldap32 name 'ldap_next_attributeW';
function ldap_next_attribute; external wldap32 name 'ldap_next_attributeA';
function ldap_get_valuesA; external wldap32 name 'ldap_get_valuesA';
function ldap_get_valuesW; external wldap32 name 'ldap_get_valuesW';
function ldap_get_values; external wldap32 name 'ldap_get_valuesA';
function ldap_get_values_lenA; external wldap32 name 'ldap_get_values_lenA';
function ldap_get_values_lenW; external wldap32 name 'ldap_get_values_lenW';
function ldap_get_values_len; external wldap32 name 'ldap_get_values_lenA';
function ldap_count_valuesA; external wldap32 name 'ldap_count_valuesA';
function ldap_count_valuesW; external wldap32 name 'ldap_count_valuesW';
function ldap_count_values; external wldap32 name 'ldap_count_valuesA';
function ldap_value_freeA; external wldap32 name 'ldap_value_freeA';
function ldap_value_freeW; external wldap32 name 'ldap_value_freeW';
function ldap_value_free; external wldap32 name 'ldap_value_freeA';
function ldap_get_dnA; external wldap32 name 'ldap_get_dnA';
function ldap_get_dnW; external wldap32 name 'ldap_get_dnW';
function ldap_get_dn; external wldap32 name 'ldap_get_dnA';
function ldap_explode_dnA; external wldap32 name 'ldap_explode_dnA';
function ldap_explode_dnW; external wldap32 name 'ldap_explode_dnW';
function ldap_explode_dn; external wldap32 name 'ldap_explode_dnA';
function ldap_dn2ufnA; external wldap32 name 'ldap_dn2ufnA';
function ldap_dn2ufnW; external wldap32 name 'ldap_dn2ufnW';
function ldap_dn2ufn; external wldap32 name 'ldap_dn2ufnA';
procedure ldap_memfreeA; external wldap32 name 'ldap_memfreeA';
procedure ldap_memfreeW; external wldap32 name 'ldap_memfreeW';
procedure ldap_memfree; external wldap32 name 'ldap_memfreeA';
function ldap_ufn2dnA; external wldap32 name 'ldap_ufn2dnA';
function ldap_ufn2dnW; external wldap32 name 'ldap_ufn2dnW';
function ldap_ufn2dn; external wldap32 name 'ldap_ufn2dnA';
function ldap_escape_filter_elementA; external wldap32 name 'ldap_escape_filter_elementA';
function ldap_escape_filter_elementW; external wldap32 name 'ldap_escape_filter_elementW';
function ldap_escape_filter_element; external wldap32 name 'ldap_escape_filter_elementA';
function ldap_search_extA; external wldap32 name 'ldap_search_extA';
function ldap_search_extW; external wldap32 name 'ldap_search_extW';
function ldap_search_ext; external wldap32 name 'ldap_search_extA';
function ldap_search_ext_sA; external wldap32 name 'ldap_search_ext_sA';
function ldap_search_ext_sW; external wldap32 name 'ldap_search_ext_sW';
function ldap_search_ext_s; external wldap32 name 'ldap_search_ext_sA';
function ldap_check_filterA; EXTERNAL wldap32 name 'ldap_check_filterA';
function ldap_check_filterW; EXTERNAL wldap32 name 'ldap_check_filterW';
function ldap_check_filter; EXTERNAL wldap32 name 'ldap_check_filterA';
function ldap_modify_extA; external wldap32 name 'ldap_modify_extA';
function ldap_modify_extW; external wldap32 name 'ldap_modify_extW';
function ldap_modify_ext; external wldap32 name 'ldap_modify_extA';
function ldap_modify_ext_sA; external wldap32 name 'ldap_modify_ext_sA';
function ldap_modify_ext_sW; external wldap32 name 'ldap_modify_ext_sW';
function ldap_modify_ext_s; external wldap32 name 'ldap_modify_ext_sA';
function ldap_rename_extA; external wldap32 name 'ldap_rename_extA';
function ldap_rename_extW; external wldap32 name 'ldap_rename_extW';
function ldap_rename_ext; external wldap32 name 'ldap_rename_extA';
function ldap_rename_ext_sA; external wldap32 name 'ldap_rename_ext_sA';
function ldap_rename_ext_sW; external wldap32 name 'ldap_rename_ext_sW';
function ldap_rename_ext_s; external wldap32 name 'ldap_rename_ext_sA';
function ldap_add_extA; external wldap32 name 'ldap_add_extA';
function ldap_add_extW; external wldap32 name 'ldap_add_extW';
function ldap_add_ext; external wldap32 name 'ldap_add_extA';
function ldap_add_ext_sA; external wldap32 name 'ldap_add_ext_sA';
function ldap_add_ext_sW; external wldap32 name 'ldap_add_ext_sW';
function ldap_add_ext_s; external wldap32 name 'ldap_add_ext_sA';
function ldap_compare_extA; external wldap32 name 'ldap_compare_extA';
function ldap_compare_extW; external wldap32 name 'ldap_compare_extW';
function ldap_compare_ext; external wldap32 name 'ldap_compare_extA';
function ldap_compare_ext_sA; external wldap32 name 'ldap_compare_ext_sA';
function ldap_compare_ext_sW; external wldap32 name 'ldap_compare_ext_sW';
function ldap_compare_ext_s; external wldap32 name 'ldap_compare_ext_sA';
function ldap_delete_extA; external wldap32 name 'ldap_delete_extA';
function ldap_delete_extW; external wldap32 name 'ldap_delete_extW';
function ldap_delete_ext; external wldap32 name 'ldap_delete_extA';
function ldap_delete_ext_sA; external wldap32 name 'ldap_delete_ext_sA';
function ldap_delete_ext_sW; external wldap32 name 'ldap_delete_ext_sW';
function ldap_delete_ext_s; external wldap32 name 'ldap_delete_ext_sA';
function ldap_parse_resultA; external wldap32 name 'ldap_parse_resultA';
function ldap_parse_resultW; external wldap32 name 'ldap_parse_resultW';
function ldap_parse_result; external wldap32 name 'ldap_parse_resultA';
function ldap_controls_freeA; external wldap32 name 'ldap_controls_freeA';
function ldap_controls_freeW; external wldap32 name 'ldap_controls_freeW';
function ldap_controls_free; external wldap32 name 'ldap_controls_freeA';
function ldap_parse_extended_resultA; external wldap32 name 'ldap_parse_extended_resultA';
function ldap_parse_extended_resultW; external wldap32 name 'ldap_parse_extended_resultW';
function ldap_parse_extended_result; external wldap32 name 'ldap_parse_extended_resultA';
function ldap_control_freeA; external wldap32 name 'ldap_control_freeA';
function ldap_control_freeW; external wldap32 name 'ldap_control_freeW';
function ldap_control_free; external wldap32 name 'ldap_control_freeA';
function ldap_free_controlsA; external wldap32 name 'ldap_free_controlsA';
function ldap_free_controlsW; external wldap32 name 'ldap_free_controlsW';
function ldap_free_controls; external wldap32 name 'ldap_free_controlsA';
function ldap_create_sort_controlA; external wldap32 name 'ldap_create_sort_controlA';
function ldap_create_sort_controlW; external wldap32 name 'ldap_create_sort_controlW';
function ldap_create_sort_control; external wldap32 name 'ldap_create_sort_controlA';
function ldap_parse_sort_controlA; external wldap32 name 'ldap_parse_sort_controlA';
function ldap_parse_sort_controlW; external wldap32 name 'ldap_parse_sort_controlW';
function ldap_parse_sort_control; external wldap32 name 'ldap_parse_sort_controlA';
function ldap_encode_sort_controlA; external wldap32 name 'ldap_encode_sort_controlA';
function ldap_encode_sort_controlW; external wldap32 name 'ldap_encode_sort_controlW';
function ldap_encode_sort_control; external wldap32 name 'ldap_encode_sort_controlA';
function ldap_create_page_controlA; external wldap32 name 'ldap_create_page_controlA';
function ldap_create_page_controlW; external wldap32 name 'ldap_create_page_controlW';
function ldap_create_page_control; external wldap32 name 'ldap_create_page_controlA';
function ldap_parse_page_controlA; external wldap32 name 'ldap_parse_page_controlA';
function ldap_parse_page_controlW; external wldap32 name 'ldap_parse_page_controlW';
function ldap_parse_page_control; external wldap32 name 'ldap_parse_page_controlA';
function ldap_search_init_pageA; external wldap32 name 'ldap_search_init_pageA';
function ldap_search_init_pageW; external wldap32 name 'ldap_search_init_pageW';
function ldap_search_init_page; external wldap32 name 'ldap_search_init_pageA';
function ldap_parse_referenceA; external wldap32 name 'ldap_parse_referenceA';
function ldap_parse_referenceW; external wldap32 name 'ldap_parse_referenceW';
function ldap_parse_reference; external wldap32 name 'ldap_parse_referenceA';
function ldap_extended_operationA; external wldap32 name 'ldap_extended_operationA';
function ldap_extended_operationW; external wldap32 name 'ldap_extended_operationW';
function ldap_extended_operation; external wldap32 name 'ldap_extended_operationA';
function ldap_unbind; external wldap32 name 'ldap_unbind';
function ldap_unbind_s; external wldap32 name 'ldap_unbind_s';
function ldap_get_option; external wldap32 name 'ldap_get_option';
function ldap_set_option; external wldap32 name 'ldap_set_option';
function ldap_get_optionW; external wldap32 name 'ldap_get_optionW';
function ldap_set_optionW; external wldap32 name 'ldap_set_optionW';
function ldap_abandon; external wldap32 name 'ldap_abandon';
function ldap_result; external wldap32 name 'ldap_result';
function ldap_msgfree; external wldap32 name 'ldap_msgfree';
function ldap_result2error; external wldap32 name 'ldap_result2error';
procedure ldap_perror; external wldap32 name 'ldap_perror';
function ldap_first_entry; external wldap32 name 'ldap_first_entry';
function ldap_next_entry; external wldap32 name 'ldap_next_entry';
function ldap_count_entries; external wldap32 name 'ldap_count_entries';
function ldap_count_values_len; external wldap32 name 'ldap_count_values_len';
function ldap_value_free_len; external wldap32 name 'ldap_value_free_len';
function ldap_startup; external wldap32 name 'ldap_startup';
function ldap_cleanup; external wldap32 name 'ldap_cleanup';
function ldap_set_dbg_flags; external wldap32 name 'ldap_set_dbg_flags';
function ldap_connect; external wldap32 name 'ldap_connect';
procedure ber_bvfree; external wldap32 name 'ber_bvfree';
procedure ldap_set_dbg_routine; external wldap32 name 'ldap_set_dbg_routine';
function LdapUTF8ToUnicode; external wldap32 name 'LdapUTF8ToUnicode';
function LdapUnicodeToUTF8; external wldap32 name 'LdapUnicodeToUTF8';
function ldap_get_next_page; external wldap32 name 'ldap_get_next_page';
function ldap_get_next_page_s; external wldap32 name 'ldap_get_next_page_s';
function ldap_get_paged_count; external wldap32 name 'ldap_get_paged_count';
function ldap_search_abandon_page; external wldap32 name 'ldap_search_abandon_page';
function ldap_first_reference; external wldap32 name 'ldap_first_reference';
function ldap_next_reference; external wldap32 name 'ldap_next_reference';
function ldap_count_references; external wldap32 name 'ldap_count_references';
function ldap_close_extended_op; external wldap32 name 'ldap_close_extended_op';
function LdapGetLastError; external wldap32 name 'LdapGetLastError';
function LdapMapErrorToWin32; external wldap32 name 'LdapMapErrorToWin32';
function ldap_conn_from_msg; external wldap32 name 'ldap_conn_from_msg';

// Macros.
function LDAP_IS_CLDAP(ld: PLDAP): boolean;
begin
  Result :=(ld^.ld_sb.sb_naddr > 0);
end;

function NAME_ERROR(n: integer): boolean;
begin
  Result := (n and $F0) = $20;
end;

end.

