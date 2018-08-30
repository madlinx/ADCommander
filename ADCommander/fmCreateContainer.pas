unit fmCreateContainer;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, ADC.Types, ADC.DC, ADC.GlobalVar,
  ADC.Common, Vcl.ExtCtrls;

type
  TForm_CreateContainer = class(TForm)
    Button_SelectContainer: TButton;
    Edit_Container: TEdit;
    Label_Container: TLabel;
    Edit_Name: TEdit;
    Label_Name: TLabel;
    Button_Cancel: TButton;
    Button_OK: TButton;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure Button_SelectContainerClick(Sender: TObject);
    procedure Button_CancelClick(Sender: TObject);
    procedure Button_OKClick(Sender: TObject);
  private
    FOnOrganizationalUnitCreate: TCreateOrganizationalUnitProc;
    FCallingForm: TForm;
    FDomainController: TDCInfo;
    FContainer: TOrganizationalUnit;
    procedure ClearTextFields;
    procedure SetCallingForm(const Value: TForm);
    procedure SetContainer(const Value: TOrganizationalUnit);
    procedure SetDomainController(const Value: TDCInfo);
    procedure OnTargetContainerSelect(Sender: TObject; ACont: TOrganizationalUnit);
  public
    property CallingForm: TForm write SetCallingForm;
    property DomainController: TDCInfo read FDomainController write SetDomainController;
    property Container: TOrganizationalUnit read FContainer write SetContainer;
    property OnOrganizationalUnitCreate: TCreateOrganizationalUnitProc read FOnOrganizationalUnitCreate write FOnOrganizationalUnitCreate;
  end;

var
  Form_CreateContainer: TForm_CreateContainer;

implementation

{$R *.dfm}

uses fmContainerSelection, fmMainForm;

{ TForm_CreateContainer }

procedure TForm_CreateContainer.Button_CancelClick(Sender: TObject);
begin
  Close;
end;

procedure TForm_CreateContainer.Button_OKClick(Sender: TObject);
var
  res: string;
begin

  case apAPI of
    ADC_API_LDAP: begin
      res := ADCreateUO(LDAPBinding, FContainer.DistinguishedName, Edit_Name.Text);
    end;

    ADC_API_ADSI: begin
      res := ADCreateUO(ADSIBinding, FContainer.DistinguishedName, Edit_Name.Text);
    end;
  end;

  if (not res.IsEmpty) and Assigned(FOnOrganizationalUnitCreate) then
  begin
    FOnOrganizationalUnitCreate(res);
    Close;
  end;
end;

procedure TForm_CreateContainer.Button_SelectContainerClick(Sender: TObject);
const
  msgTemplate = '�������� ��������� Active Directory � ������� ����� %s.';
begin
  Form_Container.CallingForm := Self;
  Form_Container.Description := Format(msgTemplate, ['������� ������� ������ ������������']);
  Form_Container.DomainController := FDomainController;
  Form_Container.DefaultPath := Edit_Container.Text;
  Form_Container.OnContainerSelect := OnTargetContainerSelect;
  Form_Container.Position := poMainFormCenter;
  Form_Container.Show;
  Self.Enabled := False;
end;

procedure TForm_CreateContainer.ClearTextFields;
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
end;

procedure TForm_CreateContainer.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  ClearTextFields;
  FDomainController := nil;
  FContainer.Clear;
  FOnOrganizationalUnitCreate := nil;

  if FCallingForm <> nil then
  begin
    FCallingForm.Enabled := True;
    FCallingForm.Show;
    FCallingForm := nil;
  end;
end;

procedure TForm_CreateContainer.OnTargetContainerSelect(Sender: TObject;
  ACont: TOrganizationalUnit);
begin
  SetContainer(ACont);

  if Sender <> nil
    then if Sender is TForm
      then TForm(Sender).Close;
end;

procedure TForm_CreateContainer.SetCallingForm(const Value: TForm);
begin
  FCallingForm := Value;
end;

procedure TForm_CreateContainer.SetContainer(const Value: TOrganizationalUnit);
begin
  FContainer := Value;
  Edit_Container.Text := FContainer.Path;
end;

procedure TForm_CreateContainer.SetDomainController(const Value: TDCInfo);
begin
  FDomainController := Value;
end;

end.
