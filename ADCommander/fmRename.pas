unit fmRename;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls,
  ADC.ADObject, ADC.Types, ADC.Common, ADC.AD, ADC.LDAP, ADC.GlobalVar;

type
  TForm_Rename = class(TForm)
    Label_Name: TLabel;
    Edit_Name: TEdit;
    Button_Close: TButton;
    Button_Apply: TButton;
    Button_OK: TButton;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure Button_CloseClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure Button_ApplyClick(Sender: TObject);
    procedure Button_OKClick(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
  private
    FCallingForm: TForm;
    FObj: TADObject;
    FCanClose: Boolean;
    procedure SetCallingForm(const Value: TForm);
    procedure SetObject(const Value: TADObject);
  public
    property CallingForm: TForm write SetCallingForm;
    property ADObject: TADObject read FObj write SetObject;
  end;

var
  Form_Rename: TForm_Rename;

implementation

{$R *.dfm}

{ TForm_Rename }

procedure TForm_Rename.Button_CloseClick(Sender: TObject);
begin
  Close;
end;

procedure TForm_Rename.Button_OKClick(Sender: TObject);
begin
  Button_ApplyClick(Self);
  if FCanClose then Close;
end;

procedure TForm_Rename.Button_ApplyClick(Sender: TObject);
var
  MsgBoxParam: TMsgBoxParams;
begin
  try
    case apAPI of
      ADC_API_LDAP: begin
        FCanClose := FObj.Rename(LDAPBinding, Edit_Name.Text);
        FObj.Refresh(LDAPBinding, List_Attributes);
      end;

      ADC_API_ADSI: begin
        FCanClose := FObj.Rename(Edit_Name.Text);
        FObj.Refresh(ADSIBinding, List_Attributes);
      end;
    end;
  except
    on E: Exception do
    begin
      with MsgBoxParam do
      begin
        cbSize := SizeOf(MsgBoxParam);
        hwndOwner := Handle;
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

procedure TForm_Rename.FormClose(Sender: TObject; var Action: TCloseAction);
var
  i: Integer;
begin
  for i := 0 to Self.ControlCount - 1 do
    if Self.Controls[i] is TEdit
      then TEdit(Self.Controls[i]).Clear;

  FCanClose := False;

  if FCallingForm <> nil then
  begin
    FCallingForm.Enabled := True;
    FCallingForm.Show;
    FCallingForm := nil;
    FObj := nil;
  end;
end;

procedure TForm_Rename.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  case Key of
    VK_ESCAPE: begin
      Close;
    end;
  end;
end;

procedure TForm_Rename.FormShow(Sender: TObject);
begin
  Edit_Name.SetFocus;
  Edit_Name.SelectAll;
end;

procedure TForm_Rename.SetCallingForm(const Value: TForm);
begin
  FCallingForm := Value;
  if FCallingForm <> nil
    then FCallingForm.Enabled := False;
end;

procedure TForm_Rename.SetObject(const Value: TADObject);
begin
  FObj := Value;
  if FObj <> nil then
  begin
    Edit_Name.Text := FObj.name;
  end;
end;

end.
