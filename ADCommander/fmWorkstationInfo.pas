unit fmWorkstationInfo;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls, ActiveDs_TLB,
  Winapi.ActiveX, ADC.GlobalVar, ADC.Types, ADC.ADObject, ADC.ComputerEdit, ADC.AD,
  ADC.LDAP;

type
  TForm_WorkstationInfo = class(TForm)
    Edit_OS: TEdit;
    Edit_InvNumber: TEdit;
    Edit_DHCP_Server: TEdit;
    Edit_MAC_Address: TEdit;
    Edit_IPv4_Address: TEdit;
    Label_OS: TLabel;
    Label_InvNumber: TLabel;
    Label_DHCP_Server: TLabel;
    Label_MACAddress: TLabel;
    Label_IPAddress: TLabel;
    Label_Name: TLabel;
    ComboBox_Name: TComboBox;
    Button_Close: TButton;
    Bevel1: TBevel;
    Label1: TLabel;
    Edit_UserName: TEdit;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure ComboBox_NameSelect(Sender: TObject);
    procedure Button_CloseClick(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
  private
    FCallingForm: TForm;
    FObj: TADObject;
    FWorkstationInfo: TComputerEdit;
    procedure ClearTextFields;
    function GetUserWorkstations(ARootDSE: IADs; ADN: string): string; overload;
    function GetUserWorkstations(ALDAP: PLDAP; ADN: string): string; overload;
  public
    procedure SetCallingForm(const Value: TForm);
    procedure SetObject(const Value: TADObject);
    procedure AddHostName(AValue: string);
    property CallingForm: TForm write SetCallingForm;
    property UserObject: TADObject read FObj write SetObject;
  end;

var
  Form_WorkstationInfo: TForm_WorkstationInfo;

implementation

{$R *.dfm}

{ TForm_WorkstationInfo }

procedure TForm_WorkstationInfo.AddHostName(AValue: string);
var
  i: Integer;
begin
  if not AValue.IsEmpty then
  begin
    i := ComboBox_Name.Items.IndexOf(AValue);

    if i < 0
      then i := ComboBox_Name.Items.Add(AValue);

    ComboBox_Name.ItemIndex := i;
  end;

  ComboBox_NameSelect(Self);
end;

procedure TForm_WorkstationInfo.Button_CloseClick(Sender: TObject);
begin
  Close;
end;

procedure TForm_WorkstationInfo.ClearTextFields;
var
  i: Integer;
begin
  for i := 0 to Self.ControlCount - 1 do
    if Self.Controls[i] is TEdit
      then TEdit(Self.Controls[i]).Clear;
end;

procedure TForm_WorkstationInfo.ComboBox_NameSelect(Sender: TObject);
begin
  ClearTextFields;

  if FObj <> nil
    then Edit_UserName.Text := FObj.name;

  case apAPI of
    ADC_API_LDAP: FWorkstationInfo.GetInfoByName(LDAPBinding, ComboBox_Name.Text);
    ADC_API_ADSI: FWorkstationInfo.GetInfoByNameDS(ADSIBinding, ComboBox_Name.Text);
  end;

  FWorkstationInfo.GetExtendedInfo;

  Edit_IPv4_Address.Text := FWorkstationInfo.IPv4;
//  Edit_MAC_Address.Text := FWorkstationInfo.MAC_Address;

  if Length(FWorkstationInfo.MAC_Address) > 0
    then Edit_MAC_Address.Text := Format(
      '%s   |   %s', [
        FWorkstationInfo.MAC_Address.Format(gfSixOfTwo, gsColon, True),
        FWorkstationInfo.MAC_Address.Format(gfThreeOfFour, gsDot)
      ]
    );

  Edit_DHCP_Server.Text := FWorkstationInfo.DHCP_Server;
  Edit_OS.Text := FWorkstationInfo.operatingSystem;
  Edit_InvNumber.Text := FWorkstationInfo.employeeID;
end;

procedure TForm_WorkstationInfo.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  ComboBox_Name.Clear;
  ClearTextFields;

  FObj := nil;

  if FCallingForm <> nil then
  begin
    FCallingForm.Enabled := True;
    FCallingForm.Show;
    FCallingForm := nil;
  end;
end;

procedure TForm_WorkstationInfo.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  case Key of
    VK_ESCAPE: begin
      Close;
    end;
  end;
end;

function TForm_WorkstationInfo.GetUserWorkstations(ARootDSE: IADs;
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
end;

function TForm_WorkstationInfo.GetUserWorkstations(ALDAP: PLDAP;
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

procedure TForm_WorkstationInfo.SetCallingForm(const Value: TForm);
begin
  FCallingForm := Value;

  if FCallingForm <> nil
    then FCallingForm.Enabled := False;
end;

procedure TForm_WorkstationInfo.SetObject(const Value: TADObject);
var
  infoIP: PIPAddr;
  infoDHCP: PDHCPInfo;
begin
  ComboBox_Name.Items.Clear;
  FObj := Value;
  if FObj <> nil then
  begin
    Edit_UserName.Text := FObj.name;

    case apAPI of
      ADC_API_LDAP: begin
        ComboBox_Name.Items.DelimitedText := GetUserWorkstations(LDAPBinding, FObj.distinguishedName);
      end;

      ADC_API_ADSI: begin
        ComboBox_Name.Items.DelimitedText := GetUserWorkstations(ADSIBinding, FObj.distinguishedName);
      end;
    end;
  end;

  if ComboBox_Name.Items.Count > 0
    then ComboBox_Name.ItemIndex := 0;

  ComboBox_NameSelect(Self);
end;

end.
