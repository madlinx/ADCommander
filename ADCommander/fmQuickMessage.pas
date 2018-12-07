unit fmQuickMessage;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  System.RegularExpressions, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ComCtrls,
  System.StrUtils, Winapi.ActiveX, ADC.Types, ADC.Common, ADC.GlobalVar, ADC.NetInfo, ADC.ADObject,
  ADC.AD, ActiveDS_TLB, ADC.LDAP, Vcl.ExtCtrls, tdMessageSend;

type
  TForm_QuickMessage = class(TForm)
    Memo_ProcessOutput: TMemo;
    ComboBox_Computer: TComboBox;
    Button_Send: TButton;
    Button_Cancel: TButton;
    Edit_Recipient: TEdit;
    Label_Computer: TLabel;
    Label_Recipient: TLabel;
    Button_GetIP: TButton;
    Memo_MessageText: TMemo;
    Label_MessageText: TLabel;
    Label_SymbolCount: TLabel;
    Label_Output: TLabel;
    procedure Button_GetIPClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure Memo_MessageTextChange(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure Button_CancelClick(Sender: TObject);
    procedure Button_SendClick(Sender: TObject);
  private
    FCallingForm: TForm;
    FObj: TADObject;
    FMsgSend: TMessageSendThread;
    procedure SetADObject(const Value: TADObject);
    procedure SetCallingForm(const Value: TForm);
    procedure ClearTextFields;
    procedure OnMessageSendOutput(ASender: TThread; AOutput: string);
    procedure OnMessageSendException(ASender: TThread; AMessage: string);
    procedure OnMessageSendTerminate(Sender: TObject);
    function GetUserWorkstations(ARootDSE: IADs; ADN: string): string; overload;
    function GetUserWorkstations(ALDAP: PLDAP; ADN: string): string; overload;
  public
    procedure AddHostName(AValue: string);
    property CallingForm: TForm write SetCallingForm;
    property ADObject: TADObject write SetADObject;
  end;

var
  Form_QuickMessage: TForm_QuickMessage;

implementation

{$R *.dfm}

procedure TForm_QuickMessage.AddHostName(AValue: string);
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
    end;
    ComboBox_Computer.ItemIndex := i;
  end;
end;

procedure TForm_QuickMessage.Button_CancelClick(Sender: TObject);
begin
  Close;
end;

procedure TForm_QuickMessage.Button_GetIPClick(Sender: TObject);
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

procedure TForm_QuickMessage.Button_SendClick(Sender: TObject);
var
  msgParam: TMessageSendParam;
  msgText: string;
begin
  { «амен€ем все переводы строк на пробелы }
//  msgText := Memo_MessageText.Lines.Text;
//  msgText := TRegEx.Replace(msgText, '[\r\n]', ' ');
//  msgText := TRegEx.Replace(msgText, '\s{2,}', ' ');
//  msgText := Trim(msgText);

  with msgParam do
  begin
    ExeName            := apPsE_Executable;
    Process_ShowWindow := apPsE_ShowOutput;
    Process_Timeout    := apPsE_WaitingTime;
    UseCredentials     := apPsE_RunAs;
    User               := apPsE_User;
    Password           := apPsE_Password;
    Message_Text       := Memo_MessageText.Text;
    Message_Recipient  := ComboBox_Computer.Text;
    Message_Timeout    := apPsE_DisplayTime;
  end;

  FMsgSend := TMessageSendThread.Create(msgParam, csQuickMessage);
  FMsgSend.Priority := tpNormal;
  FMsgSend.OnTerminate := OnMessageSendTerminate;
  FMsgSend.OnException := OnMessageSendException;
  FMsgSend.OnProcessOutput := OnMessageSendOutput;
  FMsgSend.Start;
end;

procedure TForm_QuickMessage.ClearTextFields;
begin
  Edit_Recipient.Clear;
  ComboBox_Computer.Clear;
  Memo_MessageText.Clear;
  Label_SymbolCount.Caption := Format('(%d/%d)', [0, Memo_MessageText.MaxLength]);
  Memo_ProcessOutput.Clear;
end;

procedure TForm_QuickMessage.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  if FMsgSend <> nil then
  begin
    if FMsgSend.hProcess <> 0
      then TerminateProcess(FMsgSend.hProcess, 0);
    FreeThreadManually(FMsgSend);
  end;

  ClearTextFields;
  FObj := nil;
  if FCallingForm <> nil then
  begin
    FCallingForm.Enabled := True;
    FCallingForm.Show;
    FCallingForm := nil;
  end;
end;

procedure TForm_QuickMessage.FormCreate(Sender: TObject);
begin
  ClearTextFields;
end;

function TForm_QuickMessage.GetUserWorkstations(ARootDSE: IADs;
  ADN: string): string;
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

function TForm_QuickMessage.GetUserWorkstations(ALDAP: PLDAP;
  ADN: string): string;
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

procedure TForm_QuickMessage.Memo_MessageTextChange(Sender: TObject);
begin
  Label_SymbolCount.Caption := Format('(%d/%d)', [Length(Memo_MessageText.Text), Memo_MessageText.MaxLength]);
end;

procedure TForm_QuickMessage.OnMessageSendException(ASender: TThread;
  AMessage: string);
var
  MsgBoxParam: TMsgBoxParams;
begin
  with MsgBoxParam do
  begin
    cbSize := SizeOf(MsgBoxParam);
    hwndOwner := Self.Handle;
    hInstance := 0;
    lpszCaption := PChar(APP_TITLE);
    lpszIcon := MAKEINTRESOURCE(32513);
    dwStyle := MB_OK or MB_ICONERROR;
    dwContextHelpId := 0;
    lpfnMsgBoxCallback := nil;
    dwLanguageId := LANG_NEUTRAL;
    MsgBoxParam.lpszText := PChar(AMessage);
  end;

  MessageBoxIndirect(MsgBoxParam);
end;

procedure TForm_QuickMessage.OnMessageSendOutput(ASender: TThread;
  AOutput: string);
begin
  Memo_ProcessOutput.Lines.Text := AOutput;
end;

procedure TForm_QuickMessage.OnMessageSendTerminate(Sender: TObject);
begin

end;

procedure TForm_QuickMessage.SetADObject(const Value: TADObject);
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

procedure TForm_QuickMessage.SetCallingForm(const Value: TForm);
begin
  FCallingForm := Value;
  if FCallingForm <> nil
    then FCallingForm.Enabled := False;
end;

end.
