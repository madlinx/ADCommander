unit fmEventEditor;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ComCtrls,
  System.RegularExpressions, System.DateUtils, ADC.Types;

type
  TForm_EventEditor = class(TForm)
    DateTimePicker: TDateTimePicker;
    Memo_Description: TMemo;
    Button_Cancel: TButton;
    Button_OK: TButton;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure Button_OKClick(Sender: TObject);
    procedure Button_CancelClick(Sender: TObject);
  private
    FCallingForm: TForm;
    FEvent: TADEvent;
    FMode: Byte;
    FOnEventChange: TChangeEventProc;
    procedure SetCallingForm(const Value: TForm);
    procedure ClearTextFields;
    procedure SetMode(const Value: Byte);
    procedure SetViewMode;
    procedure SetEvent(const Value: TADEvent);
  public
    property CallingForm: TForm write SetCallingForm;
    property OnEventChange: TChangeEventProc read FOnEventChange write FOnEventChange;
    property Mode: Byte read FMode write SetMode;
    property ControlEvent: TADEvent read FEvent write SetEvent;
  end;

var
  Form_EventEditor: TForm_EventEditor;

implementation

{$R *.dfm}

{ TForm_EventEditor }

procedure TForm_EventEditor.Button_CancelClick(Sender: TObject);
begin
  Close;
end;

procedure TForm_EventEditor.Button_OKClick(Sender: TObject);
var
  s: string;
begin
  s := Memo_Description.Text;

  s := TRegEx.Replace(s, '[\r\n]', ' ');
  s := TRegEx.Replace(s, '\s{2,}', ' ');
  s := Trim(s);

  FEvent.Date := DateTimePicker.Date;
  FEvent.Description := s;

  if Assigned(Self.FOnEventChange)
    then Self.FOnEventChange(Self, FMode, FEvent);

  Close;
end;

procedure TForm_EventEditor.ClearTextFields;
begin
  DateTimePicker.DateTime := DateOf(Now);
  Memo_Description.Clear;
end;

procedure TForm_EventEditor.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  SetMode(ADC_EDIT_MODE_CREATE);
  FEvent.Clear;

  if FCallingForm <> nil then
  begin
    FCallingForm.Enabled := True;
    FCallingForm.Show;
    FCallingForm := nil;
  end;
end;

procedure TForm_EventEditor.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  case Key of
    VK_ESCAPE: begin
      Close;
    end;
  end;
end;

procedure TForm_EventEditor.SetCallingForm(const Value: TForm);
begin
  FCallingForm := Value;
end;

procedure TForm_EventEditor.SetEvent(const Value: TADEvent);
begin
  FEvent := Value;
  SetMode(FMode);
end;

procedure TForm_EventEditor.SetMode(const Value: Byte);
begin
  FMode := Value;
  if FMode = ADC_EDIT_MODE_CREATE then ClearTextFields
  else begin
    DateTimePicker.DateTime := DateOf(FEvent.Date);
    Memo_Description.Text := FEvent.Description;
  end;

  SetViewMode;
end;

procedure TForm_EventEditor.SetViewMode;
var
  i: Integer;
  ctrl: TControl;
  aEdit: Boolean;
begin
  aEdit := FMode in[ADC_EDIT_MODE_CREATE, ADC_EDIT_MODE_CHANGE];

  for i := 0 to Self.ControlCount - 1 do
  begin
    ctrl := Self.Controls[i];
    if ctrl is TDateTimePicker then
    begin
      TDateTimePicker(ctrl).Enabled := AEdit;
    end;

    if ctrl is TEdit then
    begin
      TEdit(ctrl).ReadOnly := not AEdit;
      if AEdit
        then TEdit(ctrl).Color := clWindow
        else TEdit(ctrl).Color := clBtnFace;
    end;

    if ctrl is TMemo then
    begin
      TMemo(ctrl).ReadOnly := not AEdit;
      if AEdit
        then TMemo(ctrl).Color := clWindow
        else TMemo(ctrl).Color := clBtnFace;
    end;
  end;

  case FMode of
    ADC_EDIT_MODE_CREATE: Button_OK.Caption := 'Сохранить';
    ADC_EDIT_MODE_CHANGE: Button_OK.Caption := 'Сохранить';
    ADC_EDIT_MODE_DELETE: Button_OK.Caption := 'Удалить';
  end;
end;

end.
