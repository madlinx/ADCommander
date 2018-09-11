unit ADCommander_TLB;

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
// File generated on 11.09.2018 16:30:43 from Type Library described below.

// ************************************************************************  //
// Type Lib: D:\Projects\ADCommander\ElevationMoniker\ADCmdUAC (1)
// LIBID: {90228991-EF3C-4C19-A4F2-C58AE05C677A}
// LCID: 0
// Helpfile:
// HelpString: AD Commander ActiveX Library
// DepndLst:
//   (1) v2.0 stdole, (C:\Windows\SysWOW64\stdole2.tlb)
// SYS_KIND: SYS_WIN32
// ************************************************************************ //
{$TYPEDADDRESS OFF} // Unit must be compiled without type-checked pointers.
{$WARN SYMBOL_PLATFORM OFF}
{$WRITEABLECONST ON}
{$VARPROPSETTER ON}
{$ALIGN 4}

interface

uses Winapi.Windows, System.Classes, System.Variants, System.Win.StdVCL, Vcl.Graphics, Vcl.OleServer, Winapi.ActiveX;


// *********************************************************************//
// GUIDS declared in the TypeLibrary. Following prefixes are used:
//   Type Libraries     : LIBID_xxxx
//   CoClasses          : CLASS_xxxx
//   DISPInterfaces     : DIID_xxxx
//   Non-DISP interfaces: IID_xxxx
// *********************************************************************//
const
  // TypeLibrary Major and minor versions
  ADCommanderMajorVersion = 1;
  ADCommanderMinorVersion = 0;

  LIBID_ADCommander: TGUID = '{90228991-EF3C-4C19-A4F2-C58AE05C677A}';

  IID_IElevationMoniker: TGUID = '{44B30677-801B-406F-9925-6CB4A2E9B12D}';
  CLASS_ElevationMoniker: TGUID = '{B8A05C5C-72B1-4E0F-AE1E-CAE0249B3D89}';
type

// *********************************************************************//
// Forward declaration of types defined in TypeLibrary
// *********************************************************************//
  IElevationMoniker = interface;
  IElevationMonikerDisp = dispinterface;

// *********************************************************************//
// Declaration of CoClasses defined in Type Library
// (NOTE: Here we map each CoClass to its Default Interface)
// *********************************************************************//
  ElevationMoniker = IElevationMoniker;


// *********************************************************************//
// Interface: IElevationMoniker
// Flags:     (320) Dual OleAutomation
// GUID:      {44B30677-801B-406F-9925-6CB4A2E9B12D}
// *********************************************************************//
  IElevationMoniker = interface(IUnknown)
    ['{44B30677-801B-406F-9925-6CB4A2E9B12D}']
    procedure RegisterUCMAComponents(AClassID: PWideChar); safecall;
    procedure UnregisterUCMAComponents(AClassID: PWideChar); safecall;
    procedure SaveControlEventsList(AFileName: PWideChar; const AXMLStream: IUnknown); safecall;
    procedure DeleteControlEventsList(AFileName: PWideChar); safecall;
    function CreateAccessDatabase(AConnectionString: PWideChar; const AFieldCatalog: IUnknown): IUnknown; safecall;
  end;

// *********************************************************************//
// DispIntf:  IElevationMonikerDisp
// Flags:     (320) Dual OleAutomation
// GUID:      {44B30677-801B-406F-9925-6CB4A2E9B12D}
// *********************************************************************//
  IElevationMonikerDisp = dispinterface
    ['{44B30677-801B-406F-9925-6CB4A2E9B12D}']
    procedure RegisterUCMAComponents(AClassID: {NOT_OLEAUTO(PWideChar)}OleVariant); dispid 101;
    procedure UnregisterUCMAComponents(AClassID: {NOT_OLEAUTO(PWideChar)}OleVariant); dispid 102;
    procedure SaveControlEventsList(AFileName: {NOT_OLEAUTO(PWideChar)}OleVariant;
                                    const AXMLStream: IUnknown); dispid 103;
    procedure DeleteControlEventsList(AFileName: {NOT_OLEAUTO(PWideChar)}OleVariant); dispid 104;
    function CreateAccessDatabase(AConnectionString: {NOT_OLEAUTO(PWideChar)}OleVariant;
                                  const AFieldCatalog: IUnknown): IUnknown; dispid 105;
  end;

// *********************************************************************//
// The Class CoElevationMoniker provides a Create and CreateRemote method to
// create instances of the default interface IElevationMoniker exposed by
// the CoClass ElevationMoniker. The functions are intended to be used by
// clients wishing to automate the CoClass objects exposed by the
// server of this typelibrary.
// *********************************************************************//
  CoElevationMoniker = class
    class function Create: IElevationMoniker;
    class function CreateRemote(const MachineName: string): IElevationMoniker;
  end;

implementation

uses System.Win.ComObj;

class function CoElevationMoniker.Create: IElevationMoniker;
begin
  Result := CreateComObject(CLASS_ElevationMoniker) as IElevationMoniker;
end;

class function CoElevationMoniker.CreateRemote(const MachineName: string): IElevationMoniker;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_ElevationMoniker) as IElevationMoniker;
end;

end.

