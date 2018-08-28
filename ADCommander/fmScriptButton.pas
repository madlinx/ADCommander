unit fmScriptButton;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls,
  ADC.Types, ADC.ScriptBtn, Vcl.ExtCtrls;

type
  TForm_ScriptButton = class(TForm)
    Label_Title: TLabel;
    Label1: TLabel;
    Label2: TLabel;
    Edit_Title: TEdit;
    Edit_Description: TEdit;
    Edit_Path: TEdit;
    Button_Cancel: TButton;
    Button_OK: TButton;
    Label_Parameters: TLabel;
    Edit_Parameters: TEdit;
    Label_dn: TLabel;
    Label_h: TLabel;
    Label_a: TLabel;
    Label_h_Hint: TLabel;
    Label_a_Hint: TLabel;
    Label3: TLabel;
    Bevel1: TBevel;
    Button_Browse: TButton;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure Button_CancelClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure Button_OKClick(Sender: TObject);
    procedure Button_BrowseClick(Sender: TObject);
  private
    FCallingForm: TForm;
    FObj: PADScriptButton;
    FMode: Byte;
    FOnScriptButtonCreate: TCreateScriptButtonProc;
    FOnScriptButtonChange: TChangeScriptButtonProc;
    procedure SetCallingForm(const Value: TForm);
    procedure SetObject(const Value: PADScriptButton);
    procedure SetMode(const Value: Byte);
    procedure ClearTextFields;
  public
    property CallingForm: TForm write SetCallingForm;
    property Mode: Byte read FMode write SetMode;
    property ScriptButton: PADScriptButton read FObj write SetObject;
    property OnScriptButtonCreate: TCreateScriptButtonProc read FOnScriptButtonCreate write FOnScriptButtonCreate;
    property OnScriptButtonChange: TChangeScriptButtonProc read FOnScriptButtonChange write FOnScriptButtonChange;
  end;

var
  Form_ScriptButton: TForm_ScriptButton;

implementation

{$R *.dfm}

uses dmDataModule;

{ TForm_ScriptButton }

procedure TForm_ScriptButton.Button_BrowseClick(Sender: TObject);
begin
  with DM1.OpenDialog do
  begin
    FileName := '';
    Filter := 'Файлы сценария VBScript (*.vbs)|*.vbs'
      + '|Файлы сценария JavaScript (*.js)|*.js'
      + '|Все файлы (*.*)|*.*';
    FilterIndex := 1;
    Options := Options - [ofAllowMultiSelect];
    if Execute then
    begin
      Edit_Path.Text := FileName;
    end;
  end;
end;

procedure TForm_ScriptButton.Button_CancelClick(Sender: TObject);
begin
  Close;
end;

procedure TForm_ScriptButton.Button_OKClick(Sender: TObject);
var
  sb: TADScriptButton;
begin
  case FMode of
    ADC_EDIT_MODE_CREATE: begin
      with sb do
      begin
        Title := Edit_Title.Text;
        Description := Edit_Description.Text;
        Path := Edit_Path.Text;
        Parameters := Edit_Parameters.Text;
      end;

      if Assigned(FOnScriptButtonCreate)
        then FOnScriptButtonCreate(Self, sb);
    end;

    ADC_EDIT_MODE_CHANGE: begin
      if Assigned(FObj) then with FObj^ do
      begin
        Title := Edit_Title.Text;
        Description := Edit_Description.Text;
        Path := Edit_Path.Text;
        Parameters := Edit_Parameters.Text;
      end;

      if Assigned(FOnScriptButtonChange)
        then FOnScriptButtonChange(Self, FObj);
    end;
  end;

  Close;
end;

procedure TForm_ScriptButton.ClearTextFields;
var
  i: Integer;
begin
  for i := 0 to Self.ControlCount - 1 do
    if Self.Controls[i] is TEdit
      then TEdit(Self.Controls[i]).Clear;

  Edit_Parameters.Text := '-dn'
end;

procedure TForm_ScriptButton.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  ClearTextFields;

  FMode := ADC_EDIT_MODE_CREATE;
  FObj := nil;
  FOnScriptButtonCreate := nil;
  FOnScriptButtonChange := nil;

  if FCallingForm <> nil then
  begin
    FCallingForm.Enabled := True;
    FCallingForm.Show;
    FCallingForm := nil;
  end;
end;

procedure TForm_ScriptButton.FormCreate(Sender: TObject);
begin
  ClearTextFields;
end;

procedure TForm_ScriptButton.SetCallingForm(const Value: TForm);
begin
  FCallingForm := Value;
  if FCallingForm <> nil
    then FCallingForm.Enabled := False;
end;

procedure TForm_ScriptButton.SetMode(const Value: Byte);
begin
  FMode := Value;

  SetObject(FObj);
end;

procedure TForm_ScriptButton.SetObject(const Value: PADScriptButton);
begin
  FObj := Value;

  if FMode = ADC_EDIT_MODE_CREATE then ClearTextFields
  else begin
    if Assigned(FObj) then
    begin
      Edit_Title.Text := FObj^.Title;
      Edit_Description.Text := FObj^.Description;
      Edit_Path.Text := FObj^.Path;
      Edit_Parameters.Text := FObj^.Parameters;
    end;
  end;
end;

end.
