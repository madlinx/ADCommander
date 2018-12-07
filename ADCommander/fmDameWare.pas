unit fmDameWare;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, ADC.GlobalVar,
  ADC.ADObject, ADC.Common, ADC.Types, Vcl.ExtCtrls, System.StrUtils, ADC.LDAP,
  ADC.AD, Winapi.ActiveX, ActiveDs_TLB, System.RegularExpressions;

type
  TForm_DameWare = class(TForm)
    ComboBox_DMRC: TComboBox;
    CheckBox_DMRC_Auto: TCheckBox;
    CheckBox_DMRC_Driver: TCheckBox;
    RadioButton_DMRC_Viewer: TRadioButton;
    RadioButton_DMRC_RDP: TRadioButton;
    Edit_DMRC_dom: TEdit;
    Label_DMRC_Domain: TLabel;
    Edit_DMRC_pass: TEdit;
    Label_DMRC_Password: TLabel;
    Edit_DMRC_user: TEdit;
    Label_DMRC_Username: TLabel;
    Label_DMRC_Authorization: TLabel;
    ComboBox_Computer: TComboBox;
    Label_DMRC_ComputerName: TLabel;
    Button_Control: TButton;
    Button_View: TButton;
    Button_Cancel: TButton;
    Bevel1: TBevel;
    Button_GetIP: TButton;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure ComboBox_DMRCSelect(Sender: TObject);
    procedure RadioButton_DMRC_RDPClick(Sender: TObject);
    procedure RadioButton_DMRC_ViewerClick(Sender: TObject);
    procedure Button_CancelClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure Button_ControlClick(Sender: TObject);
    procedure Button_ViewClick(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure Button_GetIPClick(Sender: TObject);
  private
    FDMRC_PrevAuth: SmallInt;
    FCallingForm: TForm;
    FObj: TADObject;
    procedure RefreshFields;
    procedure SetCallingForm(const Value: TForm);
    procedure SetADObject(const Value: TADObject);
    function GetUserWorkstations(ARootDSE: IADs; ADN: string): string; overload;
    function GetUserWorkstations(ALDAP: PLDAP; ADN: string): string; overload;
  public
    procedure AddHostName(AValue: string);
    property CallingForm: TForm write SetCallingForm;
    property ADObject: TADObject write SetADObject;
  end;

var
  Form_DameWare: TForm_DameWare;

implementation

{$R *.dfm}

uses
  dmDataModule;

{ TForm_DameWare }

procedure TForm_DameWare.AddHostName(AValue: string);
var
  i: Integer;
  infoIP: PIPAddr;
  infoDHCP: PDHCPInfo;
  fqdn: string;
begin
  if not AValue.IsEmpty then
  begin
    i := ComboBox_Computer.Items.IndexOf(AValue);
    if i < 0 then
    begin
      i := ComboBox_Computer.Items.Add(AValue);
//      New(infoIP);
//      New(infoDHCP);
//      GetIPAddress(AValue, infoIP);
//      if Pos('.', infoIP^.FQDN) > 0
//        then fqdn := infoIP^.FQDN
//        else fqdn := AValue;
////      GetDHCPInfo(LowerCase(fqdn), infoDHCP);
//      GetDHCPInfoEx(LowerCase(fqdn), infoDHCP);
//      if not (infoIP^.v4.IsEmpty and infoDHCP.IPAddress.v4.IsEmpty) then
//      begin
//        ComboBox_Computer.Items.Insert(
//          0,
//          IfThen(infoIP^.v4.IsEmpty, infoDHCP.IPAddress.v4, infoIP^.v4)
//        );
//        i := 0;
//      end;
//      Dispose(infoIP);
//      Dispose(infoDHCP);
    end;
    ComboBox_Computer.ItemIndex := i;
  end;
end;

procedure TForm_DameWare.Button_CancelClick(Sender: TObject);
begin
  Close;
end;

procedure TForm_DameWare.Button_ControlClick(Sender: TObject);
begin
  DameWareMRC_Connect(
    apDMRC_Executable,
    ComboBox_Computer.Text,
    ComboBox_DMRC.ItemIndex,
    Edit_DMRC_user.Text,
    Edit_DMRC_pass.Text,
    Edit_DMRC_dom.Text,
    CheckBox_DMRC_Driver.Checked,
    RadioButton_DMRC_RDP.Checked,
    CheckBox_DMRC_Auto.Checked,
    False
  );
end;

procedure TForm_DameWare.Button_GetIPClick(Sender: TObject);
var
  regEx: TRegEx;
  pcName: string;
  infoIP: PIPAddr;
  infoDHCP: PDHCPInfo;
begin
  if ComboBox_Computer.Text = ''
    then Exit;

  regEx := TRegEx.Create('\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}', [roNone]);
  if regEx.IsMatch(ComboBox_Computer.Text)
    then pcName := ComboBox_Computer.Text
    else pcName := LowerCase(ComboBox_Computer.Text + '.' + SelectedDC.DomainDnsName);

  New(infoIP);
  New(infoDHCP);
  GetIPAddress(pcName, infoIP);
//  GetDHCPInfo(pcName, infoDHCP);
  GetDHCPInfoEx(pcName, infoDHCP);

  ComboBox_Computer.Text := IfThen(
    infoIP^.v4.IsEmpty,
    infoDHCP^.IPAddress.v4,
    infoIP^.v4
  );

  Dispose(infoIP);
  Dispose(infoDHCP);
end;

procedure TForm_DameWare.Button_ViewClick(Sender: TObject);
begin
  DameWareMRC_Connect(
    apDMRC_Executable,
    ComboBox_Computer.Text,
    ComboBox_DMRC.ItemIndex,
    Edit_DMRC_user.Text,
    Edit_DMRC_pass.Text,
    Edit_DMRC_dom.Text,
    CheckBox_DMRC_Driver.Checked,
    RadioButton_DMRC_RDP.Checked,
    CheckBox_DMRC_Auto.Checked,
    True
  );
end;

procedure TForm_DameWare.ComboBox_DMRCSelect(Sender: TObject);
begin
  RefreshFields;
end;

procedure TForm_DameWare.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  if FCallingForm <> nil then
  begin
    FCallingForm.Enabled := True;
    FCallingForm.Show;
    FCallingForm := nil;
  end;
  FObj := nil;
end;

procedure TForm_DameWare.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  case Key of
    VK_ESCAPE: begin
      Close;
    end;
  end;
end;

procedure TForm_DameWare.FormShow(Sender: TObject);
begin
  RefreshFields;
end;

function TForm_DameWare.GetUserWorkstations(ARootDSE: IADs; ADN: string): string;
var
  hRes: HRESULT;
  pObj: IADs;
  v: OleVariant;
  DomainHostName: string;
begin
  Result := '';

  v := ARootDSE.Get('dnsHostName');
  DomainHostName := VariantToStringWithDefault(v, '');
  VariantClear(v);

  hRes := ADsOpenObject(
    PChar('LDAP://' + DomainHostName + '/' + ADN),
    nil,
    nil,
    ADS_SECURE_AUTHENTICATION or ADS_SERVER_BIND,
    IID_IADs,
    @pObj
  );

  if Succeeded(hRes) then
  try
    v := pObj.Get('userWorkstations');
    Result := VarToStr(v);
    VariantClear(v);
  except

  end;

  pObj := nil;
end;

function TForm_DameWare.GetUserWorkstations(ALDAP: PLDAP; ADN: string): string;
var
  ldapBase: AnsiString;
  attrArray: array of PAnsiChar;
  returnCode: ULONG;
  searchResult: PLDAPMessage;
  ldapEntry: PLDAPMessage;
  ldapValue: PPAnsiChar;
begin
  SetLength(attrArray, 2);
  attrArray[0] := PAnsiChar('userWorkstations');
  attrArray[1] := nil;

  ldapBase := ADN;

  returnCode := ldap_search_ext_s(
    ALDAP,
    PAnsiChar(ldapBase),
    LDAP_SCOPE_BASE,
    nil,
    PAnsiChar(@attrArray[0]),
    0,
    nil,
    nil,
    nil,
    0,
    searchResult
  );

  if (returnCode = LDAP_SUCCESS) and (ldap_count_entries(ALDAP, searchResult) > 0 ) then
  begin
    ldapEntry := ldap_first_entry(ALDAP, searchResult);
    ldapValue := ldap_get_values(ALDAP, ldapEntry, attrArray[0]);
    if ldapValue <> nil
      then Result := ldapValue^
      else Result := '';
    ldap_value_free(ldapValue);
  end;

  if searchResult <> nil
    then ldap_msgfree(searchResult);
end;

procedure TForm_DameWare.RadioButton_DMRC_RDPClick(Sender: TObject);
begin
  ComboBox_DMRC.ItemIndex := -1;
  RefreshFields;
end;

procedure TForm_DameWare.RadioButton_DMRC_ViewerClick(Sender: TObject);
begin
  ComboBox_DMRC.ItemIndex := DMRC_AUTH_WINLOGON;
  RefreshFields;
end;

procedure TForm_DameWare.RefreshFields;
begin
  case FDMRC_PrevAuth of
    DMRC_AUTH_PROPRIETARY: begin
      Edit_DMRC_dom.Text := apDMRC_Domain;
    end;

    DMRC_AUTH_SMARTCARD: begin
      Edit_DMRC_user.Text := apDMRC_User;
      Edit_DMRC_dom.Text := apDMRC_Domain;
    end;

    -1, DMRC_AUTH_CURRENTUSER: begin
      Edit_DMRC_user.Text := apDMRC_User;
      Edit_DMRC_pass.Text := apDMRC_Password;
      Edit_DMRC_dom.Text := apDMRC_Domain;
    end;
  end;

  case ComboBox_DMRC.ItemIndex of
    -1: begin
      Edit_DMRC_user.Text := '';
      Edit_DMRC_pass.Text := '';
      Edit_DMRC_dom.Text := '';
    end;

    DMRC_AUTH_PROPRIETARY: begin
      Edit_DMRC_dom.Text := '';
    end;

    DMRC_AUTH_SMARTCARD: begin
      Edit_DMRC_user.Text := '';
      Edit_DMRC_dom.Text := '';
    end;

    DMRC_AUTH_CURRENTUSER: begin
      Edit_DMRC_user.Text := gvUserName;
      Edit_DMRC_pass.Text := '********';
      Edit_DMRC_dom.Text := gvDomainName;
    end;
  end;

  case ComboBox_DMRC.ItemIndex of
    -1: begin
      ComboBox_DMRC.Enabled := False;
      ComboBox_DMRC.Color := clBtnFace;
      Label_DMRC_Password.Caption := 'Пароль:';
      Edit_DMRC_user.Enabled := False;
      Edit_DMRC_user.Color := clBtnFace;
      Edit_DMRC_pass.Enabled := False;
      Edit_DMRC_pass.Color := clBtnFace;
      Edit_DMRC_dom.Enabled := False;
      Edit_DMRC_dom.Color := clBtnFace;
    end;

    DMRC_AUTH_PROPRIETARY: begin
      ComboBox_DMRC.Enabled := True;
      ComboBox_DMRC.Color := clWindow;
      Label_DMRC_Password.Caption := 'Пароль:';
      Edit_DMRC_user.Enabled := True;
      Edit_DMRC_user.Color := clWindow;
      Edit_DMRC_pass.Enabled := True;
      Edit_DMRC_pass.Color := clWindow;
      Edit_DMRC_dom.Enabled := False;
      Edit_DMRC_dom.Color := clBtnFace;
    end;

    DMRC_AUTH_SMARTCARD: begin
      ComboBox_DMRC.Enabled := True;
      ComboBox_DMRC.Color := clWindow;
      Label_DMRC_Password.Caption := 'PIN-код:';
      Edit_DMRC_user.Enabled := False;
      Edit_DMRC_user.Color := clBtnFace;
      Edit_DMRC_pass.Enabled := True;
      Edit_DMRC_pass.Color := clWindow;
      Edit_DMRC_dom.Enabled := False;
      Edit_DMRC_dom.Color := clBtnFace;
    end;

    DMRC_AUTH_CURRENTUSER: begin
      ComboBox_DMRC.Enabled := True;
      ComboBox_DMRC.Color := clWindow;
      Label_DMRC_Password.Caption := 'Пароль:';
      Edit_DMRC_user.Enabled := False;
      Edit_DMRC_user.Color := clBtnFace;
      Edit_DMRC_pass.Enabled := False;
      Edit_DMRC_pass.Color := clBtnFace;
      Edit_DMRC_dom.Enabled := False;
      Edit_DMRC_dom.Color := clBtnFace;
    end;

    else begin
      ComboBox_DMRC.Enabled := True;
      ComboBox_DMRC.Color := clWindow;
      Label_DMRC_Password.Caption := 'Пароль:';
      Edit_DMRC_user.Enabled := True;
      Edit_DMRC_user.Color := clWindow;
      Edit_DMRC_pass.Enabled := True;
      Edit_DMRC_pass.Color := clWindow;
      Edit_DMRC_dom.Enabled := True;
      Edit_DMRC_dom.Color := clWindow;
    end;
  end;

  FDMRC_PrevAuth := ComboBox_DMRC.ItemIndex;

  if RadioButton_DMRC_RDP.Checked
    then CheckBox_DMRC_Driver.Checked := False;

  CheckBox_DMRC_Driver.Enabled := RadioButton_DMRC_Viewer.Checked;
end;

procedure TForm_DameWare.SetADObject(const Value: TADObject);
var
  infoIP: PIPAddr;
  infoDHCP: PDHCPInfo;
begin
  ComboBox_Computer.Items.Clear;
  FObj := Value;
  if FObj <> nil then
  begin
    case FObj.ObjectType of
      otWorkstation, otDomainController, otRODomainController: begin
        New(infoIP);
        New(infoDHCP);
        GetIPAddress(FObj.dNSHostName, infoIP);
//        GetDHCPInfo(FObj.dNSHostName, infoDHCP);
        GetDHCPInfoEx(FObj.dNSHostName, infoDHCP);

        if not infoIP^.v4.IsEmpty
          then ComboBox_Computer.Items.Add(infoIP^.v4)
          else if not infoDHCP^.IPAddress.v4.IsEmpty
            then ComboBox_Computer.Items.Add(infoDHCP^.IPAddress.v4);

        ComboBox_Computer.Items.Add(FObj.name);

        Dispose(infoIP);
        Dispose(infoDHCP);
      end;

      otUser: begin
        case apAPI of
          ADC_API_LDAP: begin
            ComboBox_Computer.Items.DelimitedText := GetUserWorkstations(LDAPBinding, FObj.distinguishedName);
          end;

          ADC_API_ADSI: begin
            ComboBox_Computer.Items.DelimitedText := GetUserWorkstations(ADSIBinding, FObj.distinguishedName);
          end;
        end;
      end;
    end;

    if ComboBox_Computer.Items.Count > 0
      then ComboBox_Computer.ItemIndex := 0;
  end;
end;

procedure TForm_DameWare.SetCallingForm(const Value: TForm);
begin
  FCallingForm := Value;
  if FCallingForm <> nil
    then FCallingForm.Enabled := False;
end;

end.
