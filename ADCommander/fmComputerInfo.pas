unit fmComputerInfo;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  System.StrUtils, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls,
  Winapi.ActiveX, ActiveDs_TLB, ADC.ADObject, ADC.Types, ADC.Common, ADC.AD, ADC.LDAP,
  ADC.GlobalVar, ADC.ComputerEdit;

type
  TForm_ComputerInfo = class(TForm)
    Label_Name: TLabel;
    Label_IPAddress: TLabel;
    Edit_Name: TEdit;
    Edit_IPv4_Address: TEdit;
    Label_MACAddress: TLabel;
    Edit_MAC_Address: TEdit;
    Label_DHCP_Server: TLabel;
    Edit_DHCP_Server: TEdit;
    Button_Close: TButton;
    Bevel1: TBevel;
    Label_InvNumber: TLabel;
    Edit_InvNumber: TEdit;
    Button_Apply: TButton;
    Button_OK: TButton;
    Label_OS: TLabel;
    Edit_OS: TEdit;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure Button_CloseClick(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormShow(Sender: TObject);
    procedure Button_OKClick(Sender: TObject);
    procedure Button_ApplyClick(Sender: TObject);
  private
    FCallingForm: TForm;
    FObj: TADObject;
    FCanClose: Boolean;
    FObjEdit: TComputerEdit;
    FOnComputerChange: TChangeComputerProc;
    procedure SetCallingForm(const Value: TForm);
    procedure SetObject(const Value: TADObject);
    function SaveComputerInfo: Boolean;
  public
    property CallingForm: TForm write SetCallingForm;
    property ComputerObject: TADObject read FObj write SetObject;
    property OnComputerChange: TChangeComputerProc read FOnComputerChange write FOnComputerChange;
  end;

var
  Form_ComputerInfo: TForm_ComputerInfo;

implementation

{$R *.dfm}

{ TForm_ComputerInfo }

procedure TForm_ComputerInfo.Button_ApplyClick(Sender: TObject);
var
  MsgBoxParam: TMsgBoxParams;
begin
  with FObjEdit do
  begin
    employeeID := Edit_InvNumber.Text;
  end;

  try
    FCanClose := SaveComputerInfo;
  except
    on E: Exception do
    begin
      with MsgBoxParam do
      begin
        cbSize := SizeOf(MsgBoxParam);
        hwndOwner := Self.Handle;
        hInstance := 0;
        case apAPI of
          ADC_API_LDAP: lpszCaption := PChar('LDAP Exception');
          ADC_API_ADSI: lpszCaption := PChar('ADSI Exception');
        end;
        lpszIcon := MAKEINTRESOURCE(32513);
        dwStyle := MB_OK or MB_ICONHAND;
        dwContextHelpId := 0;
        lpfnMsgBoxCallback := nil;
        dwLanguageId := LANG_NEUTRAL;
        lpszText := PChar(E.Message);
      end;

      MessageBoxIndirect(MsgBoxParam);
    end;
  end;
end;

procedure TForm_ComputerInfo.Button_CloseClick(Sender: TObject);
begin
  Close;
end;

procedure TForm_ComputerInfo.Button_OKClick(Sender: TObject);
begin
  Button_ApplyClick(Self);
  if FCanClose then Close;
end;

procedure TForm_ComputerInfo.FormClose(Sender: TObject;
  var Action: TCloseAction);
var
  i: Integer;
begin
  for i := 0 to Self.ControlCount - 1 do
    if Self.Controls[i] is TEdit
      then TEdit(Self.Controls[i]).Clear;

  FObj := nil;
  FCanClose := False;

  if FCallingForm <> nil then
  begin
    FCallingForm.Enabled := True;
    FCallingForm.Show;
    FCallingForm := nil;
  end;
end;

procedure TForm_ComputerInfo.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  case Key of
    VK_F5: begin
      SetObject(FObj);
    end;

    VK_UP: begin
      if ActiveControl <> nil then
      begin
        if ActiveControl.ClassNameIs(TEdit.ClassName)
          then SelectNext(ActiveControl, False, True);
      end;
    end;

    VK_DOWN: begin
      if ActiveControl <> nil then
      begin
        if ActiveControl.ClassNameIs(TEdit.ClassName)
          then SelectNext(ActiveControl, True, True);
      end;
    end;

    VK_ESCAPE: begin
      Close;
    end;
  end;
end;

procedure TForm_ComputerInfo.FormShow(Sender: TObject);
begin
  Button_Close.SetFocus;
end;

function TForm_ComputerInfo.SaveComputerInfo: Boolean;
begin
  Result := False;

  with FObjEdit do
  begin
    Clear;
    employeeID := Edit_InvNumber.Text;
  end;

  try
    case apAPI of
      ADC_API_LDAP: FObjEdit.SetInfo(LDAPBinding, FObj.distinguishedName);
//      ADC_API_ADSI: FObjEdit.SetInfo(ADSIBinding, FObj.distinguishedName);
      ADC_API_ADSI: FObjEdit.SetInfoDS(ADSIBinding, FObj.distinguishedName);
    end;

    Result := True;

    if Assigned(FOnComputerChange)
      then FOnComputerChange(FObj);
  finally

  end;
end;

procedure TForm_ComputerInfo.SetCallingForm(const Value: TForm);
begin
  FCallingForm := Value;
  if FCallingForm <> nil
    then FCallingForm.Enabled := False;
end;

procedure TForm_ComputerInfo.SetObject(const Value: TADObject);
var
  infoIP: PIPAddr;
  infoDHCP: PDHCPInfo;
  sFormat: string;
  sSrvName: string;
begin
  FObj := Value;
  if FObj <> nil then
  begin
    case apAPI of
      ADC_API_LDAP: FObjEdit.GetInfo(LDAPBinding, FObj.distinguishedName);
      ADC_API_ADSI: FObjEdit.GetInfo(ADSIBinding, FObj.distinguishedName);
    end;

    FObjEdit.GetExtendedInfo;

    Edit_Name.Text := FObjEdit.dNSHostName;
    Edit_IPv4_Address.Text := FObjEdit.IPv4;
    if Length(FObjEdit.MAC_Address) > 0
      then Edit_MAC_Address.Text := Format(
        '%s   |   %s', [
          FObjEdit.MAC_Address.Format(gfSixOfTwo, gsColon, True),
          FObjEdit.MAC_Address.Format(gfThreeOfFour, gsDot)
        ]
      );
    Edit_DHCP_Server.Text := FObjEdit.DHCP_Server;
    Edit_OS.Text := FObjEdit.operatingSystem + ' ' + FObjEdit.operatingSystemServicePack;
    Edit_InvNumber.Text := FObjEdit.employeeID;
  end;
end;

end.
