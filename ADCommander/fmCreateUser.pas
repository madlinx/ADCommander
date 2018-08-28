unit fmCreateUser;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.Imaging.pngimage,
  System.RegularExpressions, Vcl.ComCtrls, Vcl.Menus, System.ImageList, Vcl.ImgList,
  Vcl.Imaging.jpeg, ActiveDs_TLB,
  ADC.Types, ADC.GlobalVar, ADC.Common, ADC.DC, ADC.ImgProcessor, ADC.UserEdit,
  ADC.ADObject;

type
  TForm_CreateUser = class(TForm)
    Button_Cancel: TButton;
    Button_Next: TButton;
    Button_Back: TButton;
    Panel_Title: TPanel;
    Label_PageTitle: TLabel;
    Label_PageHint: TLabel;
    Bevel_Top: TBevel;
    Bevel_Bottom: TBevel;
    Image_PageTitle: TImage;
    PageControl: TPageControl;
    TabSheet_Account: TTabSheet;
    TabSheet_Security: TTabSheet;
    TabSheet_PersonalInfo: TTabSheet;
    TabSheet_Confirmation: TTabSheet;
    Edit_Container: TEdit;
    Edit_Initials: TEdit;
    Label_Initials: TLabel;
    Edit_DomainDNSName: TEdit;
    Edit_sAMAccountName: TEdit;
    Edit_DomainNetBIOSName: TEdit;
    Edit_AccountName: TEdit;
    Edit_DisplayName: TEdit;
    Edit_LastName: TEdit;
    Edit_FirstName: TEdit;
    Label_sAMAccountName: TLabel;
    Label_AccountName: TLabel;
    Label_DisplayName: TLabel;
    Label_LastName: TLabel;
    Label_FirstName: TLabel;
    Button_SelectContainer: TButton;
    Label_Container: TLabel;
    CheckBox_DisableAccount: TCheckBox;
    CheckBox_PwdNotExpire: TCheckBox;
    CheckBox_PwdChangeOnLogon: TCheckBox;
    Edit_PwdConfirmation: TEdit;
    Label_PasswordConfirmation: TLabel;
    Edit_Pwd: TEdit;
    Label_Password: TLabel;
    Image: TImage;
    Button_Image: TButton;
    Edit_Description: TEdit;
    Edit_EmployeeID: TEdit;
    Edit_Department: TEdit;
    Edit_Title: TEdit;
    Edit_OfficeName: TEdit;
    Edit_TelephoneNumber: TEdit;
    Label_TelephoneNumber: TLabel;
    Label_OfficeName: TLabel;
    Label_Position: TLabel;
    Label_Department: TLabel;
    Label_EmployeeID: TLabel;
    Label_Description: TLabel;
    CheckBox_GoToProperties: TCheckBox;
    Memo_TotalInfo: TMemo;
    Label_FinishHint: TLabel;
    PopupMenu_Image: TPopupMenu;
    LoadImage: TMenuItem;
    N9: TMenuItem;
    DeleteImage: TMenuItem;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure Button_CancelClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure Button_BackClick(Sender: TObject);
    procedure Button_NextClick(Sender: TObject);
    procedure Button_SelectContainerClick(Sender: TObject);
    procedure GenerateAccountName(Sender: TObject);
    procedure OnSecurityParamChange(Sender: TObject);
    procedure Edit_AccountNameChange(Sender: TObject);
    procedure Button_ImageClick(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure DeleteImageClick(Sender: TObject);
    procedure LoadImageClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    FCallingForm: TForm;
    FDomainController: TDCInfo;
    FContainer: TOrganizationalUnit;
    FUser: TUserEdit;
    FOnUserCreate: TCreateUserProc;
    procedure SetCallingForm(const Value: TForm);
    procedure OnPageSelect(Sender: TObject);
    procedure OnTargetContainerSelect(Sender: TObject; ACont: TOrganizationalUnit);
    procedure SetDomainController(const Value: TDCInfo);
    procedure CheckAccountData;
    procedure CheckSecurityData;
    procedure ClearTextFields;
    procedure ClearImage;
    procedure SetContainer(const Value: TOrganizationalUnit);
    function CreateUser: Boolean;
  public
    property CallingForm: TForm write SetCallingForm;
    property DomainController: TDCInfo read FDomainController write SetDomainController;
    property Container: TOrganizationalUnit read FContainer write SetContainer;
    property OnUserCreate: TCreateUserProc read FOnUserCreate write FOnUserCreate;
  end;

var
  Form_CreateUser: TForm_CreateUser;

implementation

{$R *.dfm}

uses fmContainerSelection, dmDataModule;

{ TForm_CreateUser }

procedure TForm_CreateUser.Button_ImageClick(Sender: TObject);
var
  P: TPoint;
begin
  P := Button_Image.ClientToScreen(Point(0, Button_Image.Height));
  PopupMenu_Image.Popup(P.X, P.Y);
end;

procedure TForm_CreateUser.Button_BackClick(Sender: TObject);
begin
  PageControl.SelectNextPage(False, False);
end;

procedure TForm_CreateUser.Button_CancelClick(Sender: TObject);
begin
  Close;
end;

procedure TForm_CreateUser.Button_NextClick(Sender: TObject);
var
  MsgBoxParam: TMsgBoxParams;
begin
  try
    case PageControl.ActivePageIndex of
      0: CheckAccountData;
      1: CheckSecurityData;
      2: ;

      3: if CreateUser then
      begin
        Close;
      end;
    end;

    if PageControl.ActivePageIndex <> PageControl.PageCount - 1
      then PageControl.SelectNextPage(True, False);
  except
    on e: Exception do
    begin
      with MsgBoxParam do
      begin
        cbSize := SizeOf(MsgBoxParam);
        hwndOwner := Handle;
        hInstance := 0;
        lpszCaption := PChar(APP_TITLE);
        lpszIcon := MAKEINTRESOURCE(32515);
        dwStyle := MB_OK or MB_ICONEXCLAMATION;
        dwContextHelpId := 0;
        lpfnMsgBoxCallback := nil;
        dwLanguageId := LANG_NEUTRAL;
        lpszText := PChar(E.Message);
      end;

      MessageBoxIndirect(MsgBoxParam);
    end;
  end;
end;

procedure TForm_CreateUser.Button_SelectContainerClick(Sender: TObject);
const
  msgTemplate = 'Выберите контейнер Active Directory в котором будет %s.';
begin
  Form_Container.CallingForm := Self;
  Form_Container.Description := Format(msgTemplate, ['создана учетная запись пользователя']);
  Form_Container.DomainController := FDomainController;
  Form_Container.DefaultPath := Edit_Container.Text;
  Form_Container.OnContainerSelect := OnTargetContainerSelect;
  Form_Container.Position := poMainFormCenter;
  Form_Container.Show;
  Self.Enabled := False;
end;

procedure TForm_CreateUser.CheckAccountData;
begin
  if (Edit_Container.Text = '')
  or (Edit_DisplayName.Text = '')
  or (Edit_AccountName.Text = '')
  or (Edit_sAMAccountName.Text = '')
    then raise Exception.Create(
      'Заполнены не все обязательные поля.' + #13#10 +
      'Поля "Создать в", "Полное имя" и "Имя входа" должны быть заполнены.'
    );
end;

procedure TForm_CreateUser.CheckSecurityData;
begin
  if Edit_Pwd.Text = ''
    then raise Exception.Create('Установите пароль пользователя.');

  if CompareStr(Edit_Pwd.Text, Edit_PwdConfirmation.Text) <> 0
    then raise Exception.Create('Пароли не совпадают.');

  if not ADCheckPasswordComplexity(SelectedDC.DomainDnsName, Edit_Pwd.Text)
    then raise Exception.Create(
      'Пароль не отвечает требованиям политики безопасности.' + #13#10 +
      'Проверьте минимальную длинну пароля, его сложность, отличие от ранее использованных паролей.'
    );
end;

procedure TForm_CreateUser.Edit_AccountNameChange(Sender: TObject);
begin
  if Length(Edit_AccountName.Text) <= Edit_sAMAccountName.MaxLength
    then Edit_sAMAccountName.Text := Edit_AccountName.Text
    else Edit_sAMAccountName.Text := Copy(Edit_AccountName.Text, 1, Edit_sAMAccountName.MaxLength);
end;

procedure TForm_CreateUser.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  ClearTextFields;
  ClearImage;
  FDomainController := nil;
  FContainer.Clear;
  FOnUserCreate := nil;

  if FCallingForm <> nil then
  begin
    FCallingForm.Enabled := True;
    FCallingForm.Show;
    FCallingForm := nil;
  end;
end;

procedure TForm_CreateUser.FormCreate(Sender: TObject);
begin
  PageControl.OnChange := OnPageSelect;
  ClearTextFields;
  ClearImage;
end;

procedure TForm_CreateUser.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
//  case Key of
//    VK_UP: begin
//      if ActiveControl <> nil then
//      begin
//        if ActiveControl is TEdit
//          then SelectNext(ActiveControl, False, True);
//        if ActiveControl is TPageControl
//          then SelectNext(ActiveControl, False, True);
//      end;
//    end;
//
//    VK_DOWN: begin
//      if ActiveControl <> nil then
//      begin
//        if ActiveControl is TEdit
//          then SelectNext(ActiveControl, True, True);
//        if ActiveControl is TPageControl
//          then SelectNext(ActiveControl, True, True);
//      end;
//    end;
//  end;
end;

procedure TForm_CreateUser.FormShow(Sender: TObject);
begin
  try
    Edit_FirstName.SetFocus;
  except

  end;
end;

procedure TForm_CreateUser.GenerateAccountName(Sender: TObject);
var
  FullName: string;
  AccountName: string;
  RegEx: TRegEx;
begin
  if Edit_LastName.Text <> '' then
  begin
    FullName := Edit_LastName.Text;
    AccountName := Edit_LastName.Text;
  end;

  if Edit_FirstName.Text <> '' then
  begin
    if FullName <> ''
      then FullName := FullName + ' ';

    FullName := FullName + Edit_FirstName.Text;
    AccountName := Edit_FirstName.Text[1] + AccountName;
  end;

  if Edit_Initials.Text <> '' then
  begin
    if FullName <> ''
      then FullName := FullName + ' ';

    FullName := FullName + Edit_Initials.Text + '.';
  end;

  RegEx := TRegEx.Create('\.{2,}', [roIgnoreCase]);
  FullName := RegEx.Replace(FullName, '.');

  if Length(FullName) <= Edit_DisplayName.MaxLength
    then Edit_DisplayName.Text := FullName
    else Edit_DisplayName.Text := Copy(FullName, 1, Edit_DisplayName.MaxLength);

  RegEx := TRegEx.Create('[^A-Za-z]', [roIgnoreCase]);
  Edit_AccountName.Text := AnsiLowerCase(
    RegEx.Replace(TranslitCyrillicToLatin(AccountName), '')
  );
end;

procedure TForm_CreateUser.DeleteImageClick(Sender: TObject);
begin
  ClearImage;
end;

procedure TForm_CreateUser.LoadImageClick(Sender: TObject);
var
  SourceImg: TBitmap;
  ResizedImg: TBitmap;
  ThumbRect: TRect;
  JPEGImage: TJPEGImage;
begin
  with DM1.OpenDialog do
  begin
    Filter := 'Изображения в формате JPEG|*.jpg;*.jpeg';
    FilterIndex := 1;
    Options := Options - [ofAllowMultiSelect];
    if Execute then
    begin
      JPEGImage := TJPEGImage.Create;
      try
        TImgProcessor.OpenImage_JPEG(FileName, JPEGImage);
        Image.Picture := nil;
        Image.Tag := USER_IMAGE_EMPTY;
        Image.Picture.Bitmap.Assign(JPEGImage);
        Image.Tag := USER_IMAGE_ASSIGNED;
      finally
        JPEGImage.Free;
      end;
    end;
  end;
end;

procedure TForm_CreateUser.ClearTextFields;
var
  i, j: Integer;
  Ctrl: TControl;
begin
  for i := 0 to PageControl.PageCount - 1 do
  begin
    for j := 0 to PageControl.Pages[i].ControlCount - 1 do
    begin
      Ctrl := PageControl.Pages[i].Controls[j];
      if Ctrl is TEdit then TEdit(Ctrl).Clear else
      if Ctrl is TCheckBox then TCheckBox(Ctrl).Checked := False else
      if Ctrl is TMemo then TMemo(Ctrl).Clear else
      if Ctrl is TListView then
      begin
        TListView(Ctrl).Items.Count := 0;
        TListView(Ctrl).Clear;
//        TListView(Ctrl).OnChange(Ctrl, nil, ctState);
      end;
    end;
  end;

  if apUseDefaultPassword then
  begin
    Edit_Pwd.Text := apDefaultPassword;
    Edit_PwdConfirmation.Text := apDefaultPassword;
  end;

  CheckBox_PwdChangeOnLogon.Checked := True;
  CheckBox_GoToProperties.Checked := True;
end;

function TForm_CreateUser.CreateUser: Boolean;
var
  dn: string;
  objUser: TADObject;
begin
  { При создании учетной записи пользователя важен порядок: }
  { 1. Создаем учетную запись                               }
  { 2. Устанавливаем пароль для новой учетной записи        }
  { 3. Устанавливаем значения всех остальных атрибутов      }
  { Т.к., если после создания учетки не устанавливая пароль }
  { сразу установить флажок "Требовать смены пароля при     }
  { следующем входе", сервер вернет ошибку.                 }

  Result := False;

  with FUser do
  begin
    Clear;

    userAccountControl := ADS_UF_NORMAL_ACCOUNT;
    ChangePwdAtLogon := CheckBox_PwdChangeOnLogon.Checked;
    if CheckBox_PwdNotExpire.Checked
      then userAccountControl := userAccountControl or ADS_UF_DONT_EXPIRE_PASSWD;
    if CheckBox_DisableAccount.Checked
      then userAccountControl := userAccountControl or ADS_UF_ACCOUNTDISABLE;

    cn := Edit_DisplayName.Text;
    givenName := Edit_FirstName.Text;
    initials := Edit_Initials.Text;
    sn := Edit_LastName.Text;
    displayName := Edit_DisplayName.Text;
    userPrincipalName := Edit_AccountName.Text + Edit_DomainDNSName.Text;
    sAMAccountName := Edit_sAMAccountName.Text;
    description := Edit_Description.Text;
    employeeID := Edit_EmployeeID.Text;
    department := Edit_Department.Text;
    title := Edit_Title.Text;
    telephoneNumber := Edit_TelephoneNumber.Text;
    physicalDeliveryOfficeName := Edit_OfficeName.Text;
    if Image.Tag = USER_IMAGE_ASSIGNED
      then TImgProcessor.ImageToByteArray(Image.Picture.Bitmap, @thumbnailPhoto);
  end;

  { 1. Создаем учетную запись и в переменну dn возвращаем distinguishedName }
  {    новой учетной записи пользователя                                    }
  case apAPI of
    ADC_API_LDAP: dn := FUser.CreateUser(LDAPBinding, FContainer.DistinguishedName);
//    ADC_API_ADSI: dn := FUser.CreateUser(ADSIBinding, FContainer.DistinguishedName);
    ADC_API_ADSI: dn := FUser.CreateUserDS(ADSIBinding, FContainer.DistinguishedName);
  end;

  objUser := TADObject.Create;
  try
    objUser.distinguishedName := dn;

    case apAPI of
      ADC_API_LDAP: objUser.Refresh(LDAPBinding, List_Attributes, False);
      ADC_API_ADSI: objUser.Refresh(ADSIBinding, List_Attributes, False);
    end;

    { 2. Устанавливаем пароль для новой учетной записи }
    objUser.SetUserPassword(
      Edit_Pwd.Text,
      CheckBox_PwdChangeOnLogon.Checked,
      False
    );

    { 3. Устанавливаем значения всех остальных атрибутов }
    case apAPI of
      ADC_API_LDAP: FUser.SetInfo(LDAPBinding, objUser.distinguishedName);
//      ADC_API_ADSI: FUser.SetInfo(ADSIBinding, objUser.distinguishedName);
      ADC_API_ADSI: FUser.SetInfoDS(ADSIBinding, objUser.distinguishedName);
    end;

    { Можно сразу обновить значения всех атрибутов объекта, но мы это сделаем  }
    { не здесь, а в обработчитке события OnUserCreate в ADCmd_MainForm         }
//    case apAPI of
//      ADC_API_LDAP: objUser.Refresh(LDAPBinding, List_Attributes, False);
//      ADC_API_ADSI: objUser.Refresh(ADSIBinding, List_Attributes, False);
//    end;
  except
    on e: Exception do
    begin
      objUser.Free;
      objUser := nil;
      raise Exception.Create(e.Message);
    end;
  end;

  if Assigned(Self.FOnUserCreate)
    then Self.OnUserCreate(objUser, CheckBox_GoToProperties.Checked)
    else objUser.Free;

  Result := True;
end;

procedure TForm_CreateUser.ClearImage;
begin
  Image.Picture := nil;
  Image.Tag := USER_IMAGE_EMPTY;
  DM1.ImageList_AccountDefault.GetBitmap(0, Image.Picture.Bitmap);
end;

procedure TForm_CreateUser.OnPageSelect(Sender: TObject);
begin
  case PageControl.ActivePageIndex of
    0: begin
      Label_PageTitle.Caption := 'Учетная запись';
      Label_PageHint.Caption := 'Поля "Создать в", "Полное имя" и "Имя входа" должны быть заполнены';
    end;

    1: begin
      Label_PageTitle.Caption := 'Параметры безопасности';
      Label_PageHint.Caption := 'Установите пароль пользователя и параметры безопасности';
    end;

    2: begin
      Label_PageTitle.Caption := 'Персональные данные';
      Label_PageHint.Caption := 'Укажите справочную информацию и личные данные пользователя';
    end;

    3: begin
      Label_PageTitle.Caption := 'Подтверждение';
      Label_PageHint.Caption := 'Проверьте данные и подтвердите создание учетной записи пользователя';

      with Memo_TotalInfo do
      begin
        Clear;
        Lines.Add('Создать в:  ' + Edit_Container.Text);
        Lines.Add('');
        Lines.Add('Полное имя:  ' + Edit_DisplayName.Text);
        Lines.Add('');
        Lines.Add('Имя входа в систему:  ' + Edit_AccountName.Text + Edit_DomainDNSName.Text);
        Lines.Add('');
        if CheckBox_PwdChangeOnLogon.Checked
          then Lines.Add('Пользователь должен сменить пароль при следующем входе в систему.');
        if CheckBox_PwdNotExpire.Checked
          then Lines.Add('Срок действия пароля не ограничен.');
        if CheckBox_DisableAccount.Checked
          then Lines.Add('Учетная запись отключена.');
      end;
    end;
  end;

  Button_Back.Enabled := PageControl.ActivePageIndex <> 0;

  if PageControl.ActivePageIndex = PageControl.PageCount - 1
    then Button_Next.Caption := 'Сохранить'
    else Button_Next.Caption := 'Далее >';
end;

procedure TForm_CreateUser.OnSecurityParamChange(Sender: TObject);
var
  MsgBoxParam: TMsgBoxParams;
begin
  if (CheckBox_PwdChangeOnLogon.Checked) and (CheckBox_PwdNotExpire.Checked) then
  begin
    with MsgBoxParam do
    begin
      cbSize := SizeOf(MsgBoxParam);
      hwndOwner := Handle;
      hInstance := 0;
      lpszText := PChar(
        'Установлен параметр "Срок действия пароля не ограничен".'+ #13#10 +
        'От пользователя не требуется изменять пароль при следующем входе в систему.'
      );
      lpszCaption := PChar(APP_TITLE);
      lpszIcon := MAKEINTRESOURCE(32516);
      dwStyle := MB_OK or MB_ICONASTERISK;
      dwContextHelpId := 0;
      lpfnMsgBoxCallback := nil;
      dwLanguageId := LANG_NEUTRAL;
    end;
    MessageBoxIndirect(MsgBoxParam);
    CheckBox_PwdChangeOnLogon.Checked := False;
  end;
end;

procedure TForm_CreateUser.OnTargetContainerSelect(Sender: TObject; ACont: TOrganizationalUnit);
begin
  SetContainer(ACont);

  if Sender <> nil
    then if Sender is TForm
      then TForm(Sender).Close;
end;

procedure TForm_CreateUser.SetCallingForm(const Value: TForm);
begin
  FCallingForm := Value;
  PageControl.ActivePage := TabSheet_Account;
  OnPageSelect(Self);
end;

procedure TForm_CreateUser.SetContainer(const Value: TOrganizationalUnit);
begin
  FContainer := Value;
  Edit_Container.Text := FContainer.Path;
end;

procedure TForm_CreateUser.SetDomainController(const Value: TDCInfo);
begin
  FDomainController := Value;

  if FDomainController <> nil then
  begin
    Edit_DomainDNSName.Text := '@' + FDomainController.DomainDnsName;
    Edit_DomainNetBIOSName.Text := FDomainController.DomainNetbiosName + '\';
  end;
end;

end.
