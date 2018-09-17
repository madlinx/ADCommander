unit fmExportProgress;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, ADC.ExcelEnum, ADC.Types, ADC.GlobalVar,
  ADC.Common, ADC.ADObject, ADC.ADObjectList, tdDataExport, Vcl.StdCtrls, Vcl.ComCtrls;

type
  TForm_ExportProgress = class(TForm)
    ProgressBar: TProgressBar;
    Label_Desription: TLabel;
    Label_Percentage: TLabel;
    Button_Cancel: TButton;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure Button_CancelClick(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
  private
    FCallingForm: TForm;
    function ConfirmCancellation: Boolean;
    procedure OnDataExportProgress(AItem: TObject; AProgress: Integer);
    procedure OnDataExportException(AMsg: string; ACode: ULONG);
    procedure OnDataExportComplete(Sender: TObject);
    procedure SetCallingForm(const Value: TForm);
  public
    procedure Execute(AFileName: TFileName; AFormat: TADCExportFormat);
    property CallingForm: TForm write SetCallingForm;
  end;

var
  Form_ExportProgress: TForm_ExportProgress;

implementation

{$R *.dfm}

{ TForm_ExportProgress }

procedure TForm_ExportProgress.Button_CancelClick(Sender: TObject);
begin
  Close;
end;

function TForm_ExportProgress.ConfirmCancellation: Boolean;
var
  MsgBoxParam: TMsgBoxParams;
begin
  if not csExport.TryEnter then
  begin
    ObjExport.Paused := True;

    with MsgBoxParam do
    begin
      cbSize := SizeOf(MsgBoxParam);
      hwndOwner := Self.Handle;
      hInstance := 0;
      lpszCaption := PChar(APP_TITLE);
      lpszIcon := MAKEINTRESOURCE(32514);
      dwStyle := MB_YESNO or MB_ICONQUESTION;
      dwContextHelpId := 0;
      lpfnMsgBoxCallback := nil;
      dwLanguageId := LANG_NEUTRAL;
      MsgBoxParam.lpszText := PChar('Отменить экспорт данных?');
    end;

    Result := MessageBoxIndirect(MsgBoxParam) = mrYes;

    if Result
      then ObjExport.Terminate;

    ObjExport.Paused := False;
  end else
  begin
    csExport.Leave;
    Result := True;
  end;
end;

procedure TForm_ExportProgress.Execute(AFileName: TFileName; AFormat: TADCExportFormat);
begin
  case apAPI of
    ADC_API_LDAP: ObjExport := TADCExporter.Create(
      Self.Handle,
      LDAPBinding,
      List_Obj,
      List_Attributes,
      AFormat,
      AFileName,
      csExport,
      OnDataExportProgress,
      OnDataExportException,
      True
    );

    ADC_API_ADSI: ObjExport := TADCExporter.Create(
      Self.Handle,
      ADSIBinding,
      List_Obj,
      List_Attributes,
      AFormat,
      AFileName,
      csExport,
      OnDataExportProgress,
      OnDataExportException,
      True
    );
  end;

  ObjExport.OnTerminate := OnDataExportComplete;
  ObjExport.FreeOnTerminate := True;
  ObjExport.Priority := tpNormal;
  ObjExport.Start;
end;

procedure TForm_ExportProgress.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  Label_Percentage.Caption := '0%';
  ProgressBar.Position := 0;
  if FCallingForm <> nil then
  begin
    FCallingForm.Enabled := True;
    FCallingForm.Show;
    FCallingForm := nil;
  end;
end;

procedure TForm_ExportProgress.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
begin
  CanClose := ConfirmCancellation;
end;

procedure TForm_ExportProgress.OnDataExportComplete(Sender: TObject);
begin
  Self.Close;
end;

procedure TForm_ExportProgress.OnDataExportException(AMsg: string;
  ACode: ULONG);
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
    dwStyle := MB_OK or MB_ICONHAND;
    dwContextHelpId := 0;
    lpfnMsgBoxCallback := nil;
    dwLanguageId := LANG_NEUTRAL;
    MsgBoxParam.lpszText := PChar(AMsg);
  end;

  MessageBoxIndirect(MsgBoxParam);
end;

procedure TForm_ExportProgress.OnDataExportProgress(AItem: TObject;
  AProgress: Integer);
begin
  Label_Percentage.Caption := Format('%d%%', [AProgress]);
  ProgressBar.Position := AProgress;
end;

procedure TForm_ExportProgress.SetCallingForm(const Value: TForm);
begin
  FCallingForm := Value;
  if FCallingForm <> nil
    then FCallingForm.Enabled := False;
end;

end.
