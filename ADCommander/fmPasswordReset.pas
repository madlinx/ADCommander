unit fmPasswordReset;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls,
  ActiveDs_TLB, ADC.GlobalVar, ADC.Types, ADC.Common, ADC.DC, ADC.ADObject;

const
  LockoutStatus: string = 'Состояние блокировки учетной записи на данном контроллере домена:   %s';

type
  TForm_ResetPassword = class(TForm)
    Edit_Password1: TEdit;
    CheckBox_ChangeOnLogon: TCheckBox;
    Edit_Password2: TEdit;
    Label15: TLabel;
    Label14: TLabel;
    Button_Cancel: TButton;
    Button_OK: TButton;
    CheckBox_Unblock: TCheckBox;
    Label1: TLabel;
    Label2: TLabel;
    Bevel1: TBevel;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure Button_CancelClick(Sender: TObject);
    procedure Button_OKClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure CheckBox_ChangeOnLogonClick(Sender: TObject);
  private
    { Private declarations }
    FObj: TADObject;
    FCallingForm: TForm;
    FOnPwdChange: TPwdChangeProc;
    procedure SetObject(const Value: TADObject);
    procedure SetDefaultPassword(const Value: string);
  public
    { Public declarations }
    property CallingForm: TForm read FCallingForm write FCallingForm;
    property UserObject: TADObject read FObj write SetObject;
    property DefaultPassword: string write SetDefaultPassword;
    property OnPasswordChange: TPwdChangeProc read FOnPwdChange write FOnPwdChange;
  end;

var
  Form_ResetPassword: TForm_ResetPassword;

implementation

{$R *.dfm}

uses fmMainForm;

procedure TForm_ResetPassword.Button_CancelClick(Sender: TObject);
begin
  Close;
end;

procedure TForm_ResetPassword.Button_OKClick(Sender: TObject);
var
  MsgBoxParam: TMsgBoxParams;
  hr: HRESULT;
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
  end;

  if Edit_Password1.Text = '' then
  begin
    MsgBoxParam.lpszText := PChar('Установите пароль пользователя.');
    MessageBoxIndirect(MsgBoxParam);
    Edit_Password1.SetFocus;
    Exit;
  end;

  if not string(Edit_Password1.Text).Equals(Edit_Password2.Text) then
  begin
    MsgBoxParam.lpszText := PChar('Пароли не совпадают.');
    MessageBoxIndirect(MsgBoxParam);
    Edit_Password2.SetFocus;
    Exit;
  end;

  if not ADCheckPasswordComplexity(SelectedDC.DomainDnsName, Edit_Password1.Text) then
  begin
    MsgBoxParam.lpszText := PChar('Пароль не отвечает требованиям политики.' + #13#10
      + 'Проверьте минимальную длинну пароля, его сложность, отличие от ранее использованных паролей.');
    MessageBoxIndirect(MsgBoxParam);
    Edit_Password1.SetFocus;
    Exit;
  end;

  try
    case apAPI of
      ADC_API_LDAP: begin
//        FObj.SetUserPassword(
//          LDAPBinding,
//          Edit_Password1.Text,
//          CheckBox_ChangeOnLogon.Checked,
//          CheckBox_Unblock.Checked
//        );

        FObj.SetUserPassword(
          Edit_Password1.Text,
          CheckBox_ChangeOnLogon.Checked,
          CheckBox_Unblock.Checked
        );
      end;

      ADC_API_ADSI: begin
        FObj.SetUserPassword(
          Edit_Password1.Text,
          CheckBox_ChangeOnLogon.Checked,
          CheckBox_Unblock.Checked
        );
      end;
    end;

    if Assigned(FOnPwdChange)
      then FOnPwdChange(FObj, CheckBox_ChangeOnLogon.Checked);

    Close;
  except
    on e: Exception do
    begin
      MsgBoxParam.lpszText := PChar(e.Message);
      MessageBoxIndirect(MsgBoxParam);
    end;
  end;
end;

procedure TForm_ResetPassword.CheckBox_ChangeOnLogonClick(Sender: TObject);
var
  MsgBoxParam: TMsgBoxParams;
begin
  if ((FObj.userAccountControl and ADS_UF_DONT_EXPIRE_PASSWD) <> 0)
  and (CheckBox_ChangeOnLogon.Checked) then
  begin
    with MsgBoxParam do
    begin
      cbSize := SizeOf(MsgBoxParam);
      hwndOwner := Self.Handle;
      hInstance := 0;
      lpszText := PChar(
        'Установлен параметр "Срок действия пароля не ограничен".'+ #13#10 +
        'От пользователя не требуется изменять пароль при следующем входе в систему.'
      );
      lpszCaption := PChar('AD Commander');
      lpszIcon := MAKEINTRESOURCE(32516);
      dwStyle := MB_OK or MB_ICONASTERISK;
      dwContextHelpId := 0;
      lpfnMsgBoxCallback := nil;
      dwLanguageId := LANG_NEUTRAL;
    end;
    MessageBoxIndirect(MsgBoxParam);
    CheckBox_ChangeOnLogon.Checked := False;
  end;
end;

procedure TForm_ResetPassword.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Edit_Password1.Clear;
  Edit_Password2.Clear;
  CheckBox_ChangeOnLogon.Checked := False;
  CheckBox_Unblock.Checked := False;
  FObj := nil;
  FOnPwdChange := nil;

  if FCallingForm <> nil then
  begin
    FCallingForm.Enabled := True;
    FCallingForm.Show;
    FCallingForm := nil;
  end;
end;

procedure TForm_ResetPassword.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  case Key of
    VK_ESCAPE: begin
      Close;
    end;
  end;
end;

procedure TForm_ResetPassword.FormShow(Sender: TObject);
begin
  Edit_Password1.SetFocus;
end;

procedure TForm_ResetPassword.SetDefaultPassword(const Value: string);
begin
  Edit_Password1.Text := Value;
  Edit_Password2.Text := Value;
end;

procedure TForm_ResetPassword.SetObject(const Value: TADObject);
begin
  FObj := Value;

  CheckBox_ChangeOnLogon.Checked := FObj.userAccountControl and ADS_UF_DONT_EXPIRE_PASSWD = 0;

  case FObj.IsAccountLocked of
    True  : Label2.Caption := Format(LockoutStatus, ['Заблокирована']);
    False : Label2.Caption := Format(LockoutStatus, ['Разблокирована']);
  end;
end;

end.
