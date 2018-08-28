unit ADCmdUCMA_TLB;

// ************************************************************************ //
// WARNING                                                                    
// -------                                                                    
// The types declared in this file were generated from data read from a       
// Type Library. If this type library is explicitly or indirectly (via        
// another type library referring to this type library) re-imported, or the   
// 'Refresh' command of the Type Library Editor activated while editing the   
// Type Library, the contents of this file will be regenerated and all        
// manual modifications will be lost.                                         
// ************************************************************************ //

// $Rev: 52393 $
// File generated on 14.03.2018 10:20:38 from Type Library described below.

// ************************************************************************  //
// Type Lib: D:\Projects\ADCommander\UCMA.Source\adcmd.ucma_vs2008\adcmd.ucma\bin\Release\adcmd.ucma.tlb (1)
// LIBID: {5DF323CE-FD37-4B3B-AC00-7FF9D6AF7C76}
// LCID: 0
// Helpfile: 
// HelpString: Unified Communications Managed API for AD Commander
// DepndLst: 
//   (1) v2.0 stdole, (C:\Windows\SysWOW64\stdole2.tlb)
//   (2) v2.0 mscorlib, (C:\Windows\Microsoft.NET\Framework\v2.0.50727\mscorlib.tlb)
//   (3) v2.0 System_EnterpriseServices, (C:\Windows\Microsoft.NET\Framework\v2.0.50727\System.EnterpriseServices.tlb)
//   (4) v2.0 mscoree, (C:\Windows\Microsoft.NET\Framework\v2.0.50727\mscoree.tlb)
// SYS_KIND: SYS_WIN32
// ************************************************************************ //
{$TYPEDADDRESS OFF} // Unit must be compiled without type-checked pointers. 
{$WARN SYMBOL_PLATFORM OFF}
{$WRITEABLECONST ON}
{$VARPROPSETTER ON}
{$ALIGN 4}

interface

uses Winapi.Windows, mscoree_TLB, mscorlib_TLB, System.Classes, System.Variants, System.Win.StdVCL, System_EnterpriseServices_TLB, Vcl.Graphics, 
Vcl.OleServer, Winapi.ActiveX;
  

// *********************************************************************//
// GUIDS declared in the TypeLibrary. Following prefixes are used:        
//   Type Libraries     : LIBID_xxxx                                      
//   CoClasses          : CLASS_xxxx                                      
//   DISPInterfaces     : DIID_xxxx                                       
//   Non-DISP interfaces: IID_xxxx                                        
// *********************************************************************//
const
  // TypeLibrary Major and minor versions
  adcmd_ucmaMajorVersion = 1;
  adcmd_ucmaMinorVersion = 0;

  LIBID_adcmd_ucma: TGUID = '{5DF323CE-FD37-4B3B-AC00-7FF9D6AF7C76}';

  DIID_IUCMAContactEvents: TGUID = '{7F0A6F02-8FA2-46DB-A444-6962635218D5}';
  IID_IUCMAContact: TGUID = '{2DB3341F-909A-44EB-A36A-BD313980B269}';
  CLASS_UCMAContact: TGUID = '{FB2CFC10-C1B2-30D5-A52B-48AC9B5E48E2}';
  IID__OnClientDisconnectedDelegate: TGUID = '{94D76060-DA17-384D-8FF4-8AF8DBFC196B}';
  IID__OnClientSignInDelegate: TGUID = '{22AC3EEE-C2D8-3B4C-847A-4516E7452BE7}';
  IID__OnClientSignOutDelegate: TGUID = '{42B13728-985B-35C4-A433-9A880DC31DED}';
  IID__OnContactInformationChangedDelegate: TGUID = '{D93545A5-B7C6-3D3F-BE9A-E9855774CF5A}';
  IID__OnSettingChangedDelegate: TGUID = '{921D5324-1973-3ECF-BE94-07129DCC9099}';
  IID__OnUriChangedDelegate: TGUID = '{0C87546E-F0E2-32A3-BC62-BBC6B253F8FC}';
  CLASS_OnClientDisconnectedDelegate: TGUID = '{60AC650D-608F-3642-BA25-788FC2543912}';
  CLASS_OnClientSignInDelegate: TGUID = '{9150EA1A-2FC3-33C9-A1C2-933253CE9EF8}';
  CLASS_OnClientSignOutDelegate: TGUID = '{32C92684-0726-3E98-85F6-B96A5288BEB3}';
  CLASS_OnContactInformationChangedDelegate: TGUID = '{BB257817-42D8-31CC-A83A-A9EB689CC103}';
  CLASS_OnSettingChangedDelegate: TGUID = '{7682B662-BAD7-3BDD-A9F7-508C1237157F}';
  CLASS_OnUriChangedDelegate: TGUID = '{44C4BE1C-FF5F-3E4C-9808-A2DDF478F831}';
type

// *********************************************************************//
// Forward declaration of types defined in TypeLibrary                    
// *********************************************************************//
  IUCMAContactEvents = dispinterface;
  IUCMAContact = interface;
  IUCMAContactDisp = dispinterface;
  _OnClientDisconnectedDelegate = interface;
  _OnClientDisconnectedDelegateDisp = dispinterface;
  _OnClientSignInDelegate = interface;
  _OnClientSignInDelegateDisp = dispinterface;
  _OnClientSignOutDelegate = interface;
  _OnClientSignOutDelegateDisp = dispinterface;
  _OnContactInformationChangedDelegate = interface;
  _OnContactInformationChangedDelegateDisp = dispinterface;
  _OnSettingChangedDelegate = interface;
  _OnSettingChangedDelegateDisp = dispinterface;
  _OnUriChangedDelegate = interface;
  _OnUriChangedDelegateDisp = dispinterface;

// *********************************************************************//
// Declaration of CoClasses defined in Type Library                       
// (NOTE: Here we map each CoClass to its Default Interface)              
// *********************************************************************//
  UCMAContact = IUCMAContact;
  OnClientDisconnectedDelegate = _OnClientDisconnectedDelegate;
  OnClientSignInDelegate = _OnClientSignInDelegate;
  OnClientSignOutDelegate = _OnClientSignOutDelegate;
  OnContactInformationChangedDelegate = _OnContactInformationChangedDelegate;
  OnSettingChangedDelegate = _OnSettingChangedDelegate;
  OnUriChangedDelegate = _OnUriChangedDelegate;


// *********************************************************************//
// DispIntf:  IUCMAContactEvents
// Flags:     (4096) Dispatchable
// GUID:      {7F0A6F02-8FA2-46DB-A444-6962635218D5}
// *********************************************************************//
  IUCMAContactEvents = dispinterface
    ['{7F0A6F02-8FA2-46DB-A444-6962635218D5}']
    procedure OnClientSignIn; dispid 1000;
    procedure OnClientSignOut; dispid 1001;
    procedure OnClientDisconnected; dispid 1002;
    procedure OnSettingChanged; dispid 1003;
    procedure OnContactInformationChanged; dispid 1004;
    procedure OnUriChanged(const oldURI: WideString; const newURI: WideString); dispid 1005;
  end;

// *********************************************************************//
// Interface: IUCMAContact
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {2DB3341F-909A-44EB-A36A-BD313980B269}
// *********************************************************************//
  IUCMAContact = interface(IDispatch)
    ['{2DB3341F-909A-44EB-A36A-BD313980B269}']
    function ClientSignIn: WordBool; safecall;
    procedure SetContact(const ContactURIorDN: WideString); safecall;
    procedure FreeContact; safecall;
    function Get_DisplayName: WideString; safecall;
    function Get_Title: WideString; safecall;
    function Get_PersonalNote: WideString; safecall;
    function Get_Activity: WideString; safecall;
    function Get_ActivityID: WideString; safecall;
    function Get_IdleStartTime: TDateTime; safecall;
    function Get_Availability: Integer; safecall;
    function Get_Photo: PSafeArray; safecall;
    function Get_IconStream: PSafeArray; safecall;
    function Get_PhotoHex: WideString; safecall;
    function Get_IconStreamHex: WideString; safecall;
    property DisplayName: WideString read Get_DisplayName;
    property Title: WideString read Get_Title;
    property PersonalNote: WideString read Get_PersonalNote;
    property Activity: WideString read Get_Activity;
    property ActivityID: WideString read Get_ActivityID;
    property IdleStartTime: TDateTime read Get_IdleStartTime;
    property Availability: Integer read Get_Availability;
    property Photo: PSafeArray read Get_Photo;
    property IconStream: PSafeArray read Get_IconStream;
    property PhotoHex: WideString read Get_PhotoHex;
    property IconStreamHex: WideString read Get_IconStreamHex;
  end;

// *********************************************************************//
// DispIntf:  IUCMAContactDisp
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {2DB3341F-909A-44EB-A36A-BD313980B269}
// *********************************************************************//
  IUCMAContactDisp = dispinterface
    ['{2DB3341F-909A-44EB-A36A-BD313980B269}']
    function ClientSignIn: WordBool; dispid 1610743808;
    procedure SetContact(const ContactURIorDN: WideString); dispid 1610743809;
    procedure FreeContact; dispid 1610743810;
    property DisplayName: WideString readonly dispid 1610743811;
    property Title: WideString readonly dispid 1610743812;
    property PersonalNote: WideString readonly dispid 1610743813;
    property Activity: WideString readonly dispid 1610743814;
    property ActivityID: WideString readonly dispid 1610743815;
    property IdleStartTime: TDateTime readonly dispid 1610743816;
    property Availability: Integer readonly dispid 1610743817;
    property Photo: {NOT_OLEAUTO(PSafeArray)}OleVariant readonly dispid 1610743818;
    property IconStream: {NOT_OLEAUTO(PSafeArray)}OleVariant readonly dispid 1610743819;
    property PhotoHex: WideString readonly dispid 1610743820;
    property IconStreamHex: WideString readonly dispid 1610743821;
  end;

// *********************************************************************//
// Interface: _OnClientDisconnectedDelegate
// Flags:     (4432) Hidden Dual OleAutomation Dispatchable
// GUID:      {94D76060-DA17-384D-8FF4-8AF8DBFC196B}
// *********************************************************************//
  _OnClientDisconnectedDelegate = interface(IDispatch)
    ['{94D76060-DA17-384D-8FF4-8AF8DBFC196B}']
  end;

// *********************************************************************//
// DispIntf:  _OnClientDisconnectedDelegateDisp
// Flags:     (4432) Hidden Dual OleAutomation Dispatchable
// GUID:      {94D76060-DA17-384D-8FF4-8AF8DBFC196B}
// *********************************************************************//
  _OnClientDisconnectedDelegateDisp = dispinterface
    ['{94D76060-DA17-384D-8FF4-8AF8DBFC196B}']
  end;

// *********************************************************************//
// Interface: _OnClientSignInDelegate
// Flags:     (4432) Hidden Dual OleAutomation Dispatchable
// GUID:      {22AC3EEE-C2D8-3B4C-847A-4516E7452BE7}
// *********************************************************************//
  _OnClientSignInDelegate = interface(IDispatch)
    ['{22AC3EEE-C2D8-3B4C-847A-4516E7452BE7}']
  end;

// *********************************************************************//
// DispIntf:  _OnClientSignInDelegateDisp
// Flags:     (4432) Hidden Dual OleAutomation Dispatchable
// GUID:      {22AC3EEE-C2D8-3B4C-847A-4516E7452BE7}
// *********************************************************************//
  _OnClientSignInDelegateDisp = dispinterface
    ['{22AC3EEE-C2D8-3B4C-847A-4516E7452BE7}']
  end;

// *********************************************************************//
// Interface: _OnClientSignOutDelegate
// Flags:     (4432) Hidden Dual OleAutomation Dispatchable
// GUID:      {42B13728-985B-35C4-A433-9A880DC31DED}
// *********************************************************************//
  _OnClientSignOutDelegate = interface(IDispatch)
    ['{42B13728-985B-35C4-A433-9A880DC31DED}']
  end;

// *********************************************************************//
// DispIntf:  _OnClientSignOutDelegateDisp
// Flags:     (4432) Hidden Dual OleAutomation Dispatchable
// GUID:      {42B13728-985B-35C4-A433-9A880DC31DED}
// *********************************************************************//
  _OnClientSignOutDelegateDisp = dispinterface
    ['{42B13728-985B-35C4-A433-9A880DC31DED}']
  end;

// *********************************************************************//
// Interface: _OnContactInformationChangedDelegate
// Flags:     (4432) Hidden Dual OleAutomation Dispatchable
// GUID:      {D93545A5-B7C6-3D3F-BE9A-E9855774CF5A}
// *********************************************************************//
  _OnContactInformationChangedDelegate = interface(IDispatch)
    ['{D93545A5-B7C6-3D3F-BE9A-E9855774CF5A}']
  end;

// *********************************************************************//
// DispIntf:  _OnContactInformationChangedDelegateDisp
// Flags:     (4432) Hidden Dual OleAutomation Dispatchable
// GUID:      {D93545A5-B7C6-3D3F-BE9A-E9855774CF5A}
// *********************************************************************//
  _OnContactInformationChangedDelegateDisp = dispinterface
    ['{D93545A5-B7C6-3D3F-BE9A-E9855774CF5A}']
  end;

// *********************************************************************//
// Interface: _OnSettingChangedDelegate
// Flags:     (4432) Hidden Dual OleAutomation Dispatchable
// GUID:      {921D5324-1973-3ECF-BE94-07129DCC9099}
// *********************************************************************//
  _OnSettingChangedDelegate = interface(IDispatch)
    ['{921D5324-1973-3ECF-BE94-07129DCC9099}']
  end;

// *********************************************************************//
// DispIntf:  _OnSettingChangedDelegateDisp
// Flags:     (4432) Hidden Dual OleAutomation Dispatchable
// GUID:      {921D5324-1973-3ECF-BE94-07129DCC9099}
// *********************************************************************//
  _OnSettingChangedDelegateDisp = dispinterface
    ['{921D5324-1973-3ECF-BE94-07129DCC9099}']
  end;

// *********************************************************************//
// Interface: _OnUriChangedDelegate
// Flags:     (4432) Hidden Dual OleAutomation Dispatchable
// GUID:      {0C87546E-F0E2-32A3-BC62-BBC6B253F8FC}
// *********************************************************************//
  _OnUriChangedDelegate = interface(IDispatch)
    ['{0C87546E-F0E2-32A3-BC62-BBC6B253F8FC}']
  end;

// *********************************************************************//
// DispIntf:  _OnUriChangedDelegateDisp
// Flags:     (4432) Hidden Dual OleAutomation Dispatchable
// GUID:      {0C87546E-F0E2-32A3-BC62-BBC6B253F8FC}
// *********************************************************************//
  _OnUriChangedDelegateDisp = dispinterface
    ['{0C87546E-F0E2-32A3-BC62-BBC6B253F8FC}']
  end;

// *********************************************************************//
// The Class CoUCMAContact provides a Create and CreateRemote method to          
// create instances of the default interface IUCMAContact exposed by              
// the CoClass UCMAContact. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  CoUCMAContact = class
    class function Create: IUCMAContact;
    class function CreateRemote(const MachineName: string): IUCMAContact;
  end;

// *********************************************************************//
// The Class CoOnClientDisconnectedDelegate provides a Create and CreateRemote method to          
// create instances of the default interface _OnClientDisconnectedDelegate exposed by              
// the CoClass OnClientDisconnectedDelegate. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  CoOnClientDisconnectedDelegate = class
    class function Create: _OnClientDisconnectedDelegate;
    class function CreateRemote(const MachineName: string): _OnClientDisconnectedDelegate;
  end;

// *********************************************************************//
// The Class CoOnClientSignInDelegate provides a Create and CreateRemote method to          
// create instances of the default interface _OnClientSignInDelegate exposed by              
// the CoClass OnClientSignInDelegate. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  CoOnClientSignInDelegate = class
    class function Create: _OnClientSignInDelegate;
    class function CreateRemote(const MachineName: string): _OnClientSignInDelegate;
  end;

// *********************************************************************//
// The Class CoOnClientSignOutDelegate provides a Create and CreateRemote method to          
// create instances of the default interface _OnClientSignOutDelegate exposed by              
// the CoClass OnClientSignOutDelegate. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  CoOnClientSignOutDelegate = class
    class function Create: _OnClientSignOutDelegate;
    class function CreateRemote(const MachineName: string): _OnClientSignOutDelegate;
  end;

// *********************************************************************//
// The Class CoOnContactInformationChangedDelegate provides a Create and CreateRemote method to          
// create instances of the default interface _OnContactInformationChangedDelegate exposed by              
// the CoClass OnContactInformationChangedDelegate. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  CoOnContactInformationChangedDelegate = class
    class function Create: _OnContactInformationChangedDelegate;
    class function CreateRemote(const MachineName: string): _OnContactInformationChangedDelegate;
  end;

// *********************************************************************//
// The Class CoOnSettingChangedDelegate provides a Create and CreateRemote method to          
// create instances of the default interface _OnSettingChangedDelegate exposed by              
// the CoClass OnSettingChangedDelegate. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  CoOnSettingChangedDelegate = class
    class function Create: _OnSettingChangedDelegate;
    class function CreateRemote(const MachineName: string): _OnSettingChangedDelegate;
  end;

// *********************************************************************//
// The Class CoOnUriChangedDelegate provides a Create and CreateRemote method to          
// create instances of the default interface _OnUriChangedDelegate exposed by              
// the CoClass OnUriChangedDelegate. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  CoOnUriChangedDelegate = class
    class function Create: _OnUriChangedDelegate;
    class function CreateRemote(const MachineName: string): _OnUriChangedDelegate;
  end;

implementation

uses System.Win.ComObj;

class function CoUCMAContact.Create: IUCMAContact;
begin
  Result := CreateComObject(CLASS_UCMAContact) as IUCMAContact;
end;

class function CoUCMAContact.CreateRemote(const MachineName: string): IUCMAContact;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_UCMAContact) as IUCMAContact;
end;

class function CoOnClientDisconnectedDelegate.Create: _OnClientDisconnectedDelegate;
begin
  Result := CreateComObject(CLASS_OnClientDisconnectedDelegate) as _OnClientDisconnectedDelegate;
end;

class function CoOnClientDisconnectedDelegate.CreateRemote(const MachineName: string): _OnClientDisconnectedDelegate;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_OnClientDisconnectedDelegate) as _OnClientDisconnectedDelegate;
end;

class function CoOnClientSignInDelegate.Create: _OnClientSignInDelegate;
begin
  Result := CreateComObject(CLASS_OnClientSignInDelegate) as _OnClientSignInDelegate;
end;

class function CoOnClientSignInDelegate.CreateRemote(const MachineName: string): _OnClientSignInDelegate;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_OnClientSignInDelegate) as _OnClientSignInDelegate;
end;

class function CoOnClientSignOutDelegate.Create: _OnClientSignOutDelegate;
begin
  Result := CreateComObject(CLASS_OnClientSignOutDelegate) as _OnClientSignOutDelegate;
end;

class function CoOnClientSignOutDelegate.CreateRemote(const MachineName: string): _OnClientSignOutDelegate;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_OnClientSignOutDelegate) as _OnClientSignOutDelegate;
end;

class function CoOnContactInformationChangedDelegate.Create: _OnContactInformationChangedDelegate;
begin
  Result := CreateComObject(CLASS_OnContactInformationChangedDelegate) as _OnContactInformationChangedDelegate;
end;

class function CoOnContactInformationChangedDelegate.CreateRemote(const MachineName: string): _OnContactInformationChangedDelegate;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_OnContactInformationChangedDelegate) as _OnContactInformationChangedDelegate;
end;

class function CoOnSettingChangedDelegate.Create: _OnSettingChangedDelegate;
begin
  Result := CreateComObject(CLASS_OnSettingChangedDelegate) as _OnSettingChangedDelegate;
end;

class function CoOnSettingChangedDelegate.CreateRemote(const MachineName: string): _OnSettingChangedDelegate;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_OnSettingChangedDelegate) as _OnSettingChangedDelegate;
end;

class function CoOnUriChangedDelegate.Create: _OnUriChangedDelegate;
begin
  Result := CreateComObject(CLASS_OnUriChangedDelegate) as _OnUriChangedDelegate;
end;

class function CoOnUriChangedDelegate.CreateRemote(const MachineName: string): _OnUriChangedDelegate;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_OnUriChangedDelegate) as _OnUriChangedDelegate;
end;

end.
