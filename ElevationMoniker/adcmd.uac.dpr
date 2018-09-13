library adcmd.uac;

{$RTTI EXPLICIT METHODS([]) PROPERTIES([]) FIELDS([])}
{$WEAKLINKRTTI ON}

{$R 'ElevationMoniker.res' 'ElevationMoniker.rc'}

uses
  ComServ,
  ADCommander_TLB in 'ADCommander_TLB.pas',
  ElevationMoniker in 'ElevationMoniker.pas' {ADCElevationMoniker: CoClass},
  ElevationMonikerFactory in 'ElevationMonikerFactory.pas',
  MSXML2_TLB in '..\Common\MSXML2_TLB.pas',
  ADC.Attributes in '..\ADCommander\ADC.Attributes.pas',
  ActiveDs_TLB in '..\Common\ActiveDs_TLB.pas',
  ADC.Types in '..\Common\ADC.Types.pas',
  ADOX_TLB in '..\Common\ADOX_TLB.pas',
  ADC.ExcelEnum in '..\Common\ADC.ExcelEnum.pas';

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
