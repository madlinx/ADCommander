unit fmCreateGroup;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls,
  ADC.Types, ADC.DC, ADC.GlobalVar, ADC.Common, ActiveDs_TLB;

type
  TForm_CreateGroup = class(TForm)
    Edit_GroupNamePre2k: TEdit;
    Label_GroupNamePre2k: TLabel;
    Edit_GroupName: TEdit;
    Label_GroupName: TLabel;
    Button_SelectContainer: TButton;
    Edit_Container: TEdit;
    Label_Container: TLabel;
    GroupBox1: TGroupBox;
    GroupBox2: TGroupBox;
    RadioButton_Local: TRadioButton;
    RadioButton_Global: TRadioButton;
    RadioButton_Universal: TRadioButton;
    RadioButton_Security: TRadioButton;
    RadioButton_Distribution: TRadioButton;
    Button_OK: TButton;
    Button_Cancel: TButton;
    procedure Button_SelectContainerClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure Button_CancelClick(Sender: TObject);
    procedure Button_OKClick(Sender: TObject);
    procedure Edit_GroupNameChange(Sender: TObject);
  private
    FDomainController: TDCInfo;
    FContainer: TADContainer;
    FCallingForm: TForm;
    FOnGroupCreate: TCreateGroupProc;
    procedure ClearTextFields;
    procedure OnTargetContainerSelect(Sender: TObject; ACont: TADContainer);
    procedure SetContainer(const Value: TADContainer);
    procedure SetDomainController(const Value: TDCInfo);
    procedure SetCallingForm(const Value: TForm);
  public
    property CallingForm: TForm write SetCallingForm;
    property DomainController: TDCInfo read FDomainController write SetDomainController;
    property Container: TADContainer read FContainer write SetContainer;
    property OnGroupCreate: TCreateGroupProc read FOnGroupCreate write FOnGroupCreate;
  end;

var
  Form_CreateGroup: TForm_CreateGroup;

implementation

{$R *.dfm}

uses fmContainerSelection;

procedure TForm_CreateGroup.Button_CancelClick(Sender: TObject);
begin
  Close;
end;

procedure TForm_CreateGroup.Button_OKClick(Sender: TObject);
var
  groupType: DWORD;
  res: string;
  MsgBoxParam: TMsgBoxParams;
begin
  groupType := 0;

  if RadioButton_Local.Checked
    then groupType := ADS_GROUP_TYPE_LOCAL_GROUP
    else if RadioButton_Global.Checked
      then groupType := ADS_GROUP_TYPE_GLOBAL_GROUP
      else if RadioButton_Universal.Checked
        then groupType := ADS_GROUP_TYPE_UNIVERSAL_GROUP;

  if RadioButton_Security.Checked
    then groupType := groupType or ADS_GROUP_TYPE_SECURITY_ENABLED;

  try
    if (Edit_Container.Text = '')
    or (Edit_GroupName.Text = '')
    or (Edit_GroupNamePre2k.Text = '')
    then raise Exception.Create(
      'Заполнены не все обязательные поля.' + #13#10 +
      'Поля "Создать в", "Имя группы" и "Имя группы: (пред-Windows 2000)" должны быть заполнены.'
    );

    case apAPI of
      ADC_API_LDAP: begin
        res := ADCreateGroup(LDAPBinding, FContainer.DistinguishedName,
          Edit_GroupName.Text, Edit_GroupNamePre2k.Text, groupType);
      end;

      ADC_API_ADSI: begin
        res := ADCreateGroup(ADSIBinding, FContainer.DistinguishedName,
          Edit_GroupName.Text, Edit_GroupNamePre2k.Text, groupType);
      end;
    end;
  except
    on E: Exception do
    begin
      res := '';
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

  if (not res.IsEmpty) and Assigned(FOnGroupCreate) then
  begin
    FOnGroupCreate(res);
    Close;
  end;
end;

procedure TForm_CreateGroup.Button_SelectContainerClick(Sender: TObject);
const
  msgTemplate = 'Выберите контейнер Active Directory в котором будет %s.';
begin
  Form_Container.CallingForm := Self;
  Form_Container.ContainedClass := 'group';
  Form_Container.Description := Format(msgTemplate, ['создана группа']);
  Form_Container.DomainController := FDomainController;
  Form_Container.DefaultPath := Edit_Container.Text;
  Form_Container.OnContainerSelect := OnTargetContainerSelect;
  Form_Container.Position := poMainFormCenter;
  Form_Container.Show;
  Self.Enabled := False;
end;

procedure TForm_CreateGroup.ClearTextFields;
var
  i: Integer;
  Ctrl: TControl;
begin
  for i := 0 to Self.ControlCount - 1 do
  begin
    Ctrl := Self.Controls[i];
    if Ctrl is TEdit then TEdit(Ctrl).Clear else
    if Ctrl is TCheckBox then TCheckBox(Ctrl).Checked := False else
    if Ctrl is TMemo then TMemo(Ctrl).Clear
  end;

  RadioButton_Global.Checked := True;
  RadioButton_Security.Checked := True;
end;

procedure TForm_CreateGroup.Edit_GroupNameChange(Sender: TObject);
begin
  if Length(Edit_GroupName.Text) <= Edit_GroupNamePre2k.MaxLength
    then Edit_GroupNamePre2k.Text := Edit_GroupName.Text
    else Edit_GroupNamePre2k.Text := Copy(Edit_GroupName.Text, 1, Edit_GroupNamePre2k.MaxLength);
end;

procedure TForm_CreateGroup.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  ClearTextFields;
  FDomainController := nil;
  FContainer.Clear;
  FOnGroupCreate := nil;

  if FCallingForm <> nil then
  begin
    FCallingForm.Enabled := True;
    FCallingForm.Show;
    FCallingForm := nil;
  end;
end;

procedure TForm_CreateGroup.OnTargetContainerSelect(Sender: TObject;
  ACont: TADContainer);
begin
  SetContainer(ACont);

  if Sender <> nil
    then if Sender is TForm
      then TForm(Sender).Close;
end;

procedure TForm_CreateGroup.SetCallingForm(const Value: TForm);
begin
  FCallingForm := Value;
end;

procedure TForm_CreateGroup.SetContainer(const Value: TADContainer);
begin
  FContainer := Value;
  Edit_Container.Text := FContainer.Path;
end;

procedure TForm_CreateGroup.SetDomainController(const Value: TDCInfo);
begin
  FDomainController := Value;

  if FDomainController <> nil then
  begin
//    Edit_DomainDNSName.Text := '@' + FDomainController.DomainDnsName;
//    Edit_DomainNetBIOSName.Text := FDomainController.DomainNetbiosName + '\';
  end;
end;

end.
