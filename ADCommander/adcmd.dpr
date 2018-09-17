program adcmd;

uses
  Vcl.Forms,
  Vcl.Graphics,
  System.StrUtils,
  Winapi.Windows,
  fmMainForm in 'fmMainForm.pas' {ADCmd_MainForm},
  dmDataModule in 'dmDataModule.pas' {DM1: TDataModule},
  ADC.Common in 'ADC.Common.pas',
  ADC.Attributes in 'ADC.Attributes.pas',
  ADC.GlobalVar in 'ADC.GlobalVar.pas',
  fmSplash in 'fmSplash.pas' {Form_Splash},
  frSearch in 'frSearch.pas' {Frame_Search: TFrame},
  ADC.ADObject in 'ADC.ADObject.pas',
  fmSettings in 'fmSettings.pas' {Form_Settings},
  System.SysUtils,
  Vcl.Themes,
  Vcl.Styles,
  ADC.DC in 'ADC.DC.pas',
  ADC.ADObjectList in 'ADC.ADObjectList.pas',
  fmAttrSelection in 'fmAttrSelection.pas' {Form_AttrSelect},
  fmPasswordReset in 'fmPasswordReset.pas' {Form_ResetPassword},
  tdLDAPEnum in 'tdLDAPEnum.pas',
  tdADSIEnum in 'tdADSIEnum.pas',
  fmDameWare in 'fmDameWare.pas' {Form_DameWare},
  ADC.NetInfo in 'ADC.NetInfo.pas',
  fmComputerInfo in 'fmComputerInfo.pas' {Form_ComputerInfo},
  ADC.AD in 'ADC.AD.pas',
  fmGroupInfo in 'fmGroupInfo.pas' {Form_GroupInfo},
  ADC.LDAP in 'ADC.LDAP.pas',
  fmRename in 'fmRename.pas' {Form_Rename},
  fmContainerSelection in 'fmContainerSelection.pas' {Form_Container},
  fmCreateUser in 'fmCreateUser.pas' {Form_CreateUser},
  ADC.ImgProcessor in 'ADC.ImgProcessor.pas',
  fmUserInfo in 'fmUserInfo.pas' {Form_UserInfo},
  ADC.UserEdit in 'ADC.UserEdit.pas',
  fmWorkstations in 'fmWorkstations.pas' {Form_Workstations},
  fmGroupSelection in 'fmGroupSelection.pas' {Form_GroupSelect},
  ADC.ComputerEdit in 'ADC.ComputerEdit.pas',
  fmEventEditor in 'fmEventEditor.pas' {Form_EventEditor},
  fmScriptButton in 'fmScriptButton.pas' {Form_ScriptButton},
  ADC.ScriptBtn in 'ADC.ScriptBtn.pas',
  fmQuickMessage in 'fmQuickMessage.pas' {Form_QuickMessage},
  tdMessageSend in 'tdMessageSend.pas',
  fmWorkstationInfo in 'fmWorkstationInfo.pas' {Form_WorkstationInfo},
  tdDataExport in 'tdDataExport.pas',
  ADCmdUCMA_TLB in 'ADCmdUCMA_TLB.pas',
  fmFloatingWindow in 'fmFloatingWindow.pas' {Form_FloatingWindow},
  ADC.UCMAEvents in 'ADC.UCMAEvents.pas',
  ADC.Elevation in 'ADC.Elevation.pas',
  fmCreateContainer in 'fmCreateContainer.pas' {Form_CreateContainer},
  MSXML2_TLB in '..\Common\MSXML2_TLB.pas',
  ADCommander_TLB in '..\ElevationMoniker\ADCommander_TLB.pas',
  ADOX_TLB in '..\Common\ADOX_TLB.pas',
  ActiveDs_TLB in '..\Common\ActiveDs_TLB.pas',
  ADC.Types in '..\Common\ADC.Types.pas',
  ADC.ExcelEnum in '..\Common\ADC.ExcelEnum.pas',
  fmExportProgress in 'fmExportProgress.pas' {Form_ExportProgress};

{$R *.res}

const
  sLineBreak = {$IFDEF LINUX} AnsiChar(#10) {$ENDIF}
               {$IFDEF MSWINDOWS} AnsiString(#13#10) {$ENDIF};

var
  MsgText: string;
  MsgBoxParam: TMsgBoxParams;
  IsAutorun: Boolean;
  CopyDataStruct: TCopyDataStruct;

begin
//  ReportMemoryLeaksOnShutdown := True;
  if Win32MajorVersion < 6 then
  begin
    MsgText := 'Для запуска приложения необходима операционная '
      + sLineBreak + 'система Windows версии 6.0 и выше.';
    with MsgBoxParam do
    begin
      cbSize := SizeOf(MsgBoxParam);
      hwndOwner := 0;
      hInstance := 0;
      lpszCaption := PChar(APP_TITLE);
      lpszIcon := MAKEINTRESOURCE(32513);
      dwStyle := MB_OK or MB_ICONASTERISK;
      dwContextHelpId := 0;
      lpfnMsgBoxCallback := nil;
      dwLanguageId := LANG_NEUTRAL;
      MsgBoxParam.lpszText := PChar(MsgText);
    end;
    MessageBoxIndirect(MsgBoxParam);
    Exit;
  end;

  if AppInstanceExists('TADCmd_MainForm')
    then Exit;

  IsAutorun := FindCmdLineSwitch('autorun');

  Application.Initialize;
  Application.MainFormOnTaskbar := True;

  with TForm_Splash.Create(nil) do
  try
    if not IsAutorun then Show;
    Update;
    DrawInfoText('Поиск контроллеров домена...');
    Application.CreateForm(TADCmd_MainForm, ADCmd_MainForm);
  Application.CreateForm(TForm_Settings, Form_Settings);
  Application.CreateForm(TForm_AttrSelect, Form_AttrSelect);
  Application.CreateForm(TForm_ResetPassword, Form_ResetPassword);
  Application.CreateForm(TForm_DameWare, Form_DameWare);
  Application.CreateForm(TForm_ComputerInfo, Form_ComputerInfo);
  Application.CreateForm(TDM1, DM1);
  Application.CreateForm(TForm_GroupInfo, Form_GroupInfo);
  Application.CreateForm(TForm_Rename, Form_Rename);
  Application.CreateForm(TForm_Container, Form_Container);
  Application.CreateForm(TForm_CreateUser, Form_CreateUser);
  Application.CreateForm(TForm_UserInfo, Form_UserInfo);
  Application.CreateForm(TForm_Workstations, Form_Workstations);
  Application.CreateForm(TForm_GroupSelect, Form_GroupSelect);
  Application.CreateForm(TForm_EventEditor, Form_EventEditor);
  Application.CreateForm(TForm_ScriptButton, Form_ScriptButton);
  Application.CreateForm(TForm_QuickMessage, Form_QuickMessage);
  Application.CreateForm(TForm_WorkstationInfo, Form_WorkstationInfo);
  Application.CreateForm(TForm_CreateContainer, Form_CreateContainer);
  Application.CreateForm(TForm_ExportProgress, Form_ExportProgress);
  { Поиск контроллеров домена и их объектов при запуске программы }
    case apAPI of
      ADC_API_LDAP: Label_API.Caption := 'Lightweight Directory Access Protocol';
      ADC_API_ADSI: Label_API.Caption := 'Active Directory Service Interfaces';
    end;

    Update;

    ADCmd_MainForm.UpdateDCList;
    try
      case apAPI of
        ADC_API_LDAP: begin
          ServerBinding(
              SelectedDC.Name,
              LDAPBinding,
              OnEnumException
          );

          ObjEnum_LDAP := TLDAPEnum.Create(
              LDAPBinding,
              List_Attributes,
              List_ObjFull,
              nil,
              OnEnumProgress,
              OnEnumException,
              True
          );
          ObjEnum_LDAP.OnTerminate := OnEnumComplete;
          ObjEnum_LDAP.FreeOnTerminate := False;
          ObjEnum_LDAP.Start;
          ObjEnum_LDAP.WaitFor;
          FreeAndNil(ObjEnum_LDAP);
        end;

        ADC_API_ADSI: begin
          ServerBinding(
            SelectedDC.Name,
            @ADSIBinding,
            OnEnumException
          );

          ObjEnum_ADSI := TADSIEnum.Create(
              ADSIBinding,
              List_Attributes,
              List_ObjFull,
              nil,
              OnEnumProgress,
              OnEnumException,
              True
          );
          ObjEnum_ADSI.OnTerminate := OnEnumComplete;
          ObjEnum_ADSI.FreeOnTerminate := False;
          ObjEnum_ADSI.Start;
          ObjEnum_ADSI.WaitFor;
          FreeAndNil(ObjEnum_ADSI);
        end;
      end;

      ADCmd_MainForm.DrawSortedColumnHeader;

      if IsAutorun
        then SendMessageToWindow('TADCmd_MainForm', 'AUTORUN');
    except

    end;
  finally
    Free;
  end;

  Application.Run;
end.
