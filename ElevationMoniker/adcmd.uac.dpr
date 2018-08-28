library adcmd.uac;

{$RTTI EXPLICIT METHODS([]) PROPERTIES([]) FIELDS([])}
{$WEAKLINKRTTI ON}

{$R 'ElevationMoniker.res' 'ElevationMoniker.rc'}

uses
  ComServ,
  ADCommander_TLB in 'ADCommander_TLB.pas',
  ElevationMoniker in 'ElevationMoniker.pas' {ADCElevationMoniker: CoClass},
  ElevationMonikerFactory in 'ElevationMonikerFactory.pas',
  MSXML2_TLB in '..\ADCommander\MSXML2_TLB.pas';

exports
  DllGetClassObject,
  DllCanUnloadNow,
  DllRegisterServer,
  DllUnregisterServer,
  DllInstall;

{$R *.TLB}

{$R *.RES}

begin
end.
