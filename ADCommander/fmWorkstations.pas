unit fmWorkstations;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls,
  ADC.Types;

type
  TForm_Workstations = class(TForm)
    Label_Hint: TLabel;
    Label_Choice: TLabel;
    GroupBox_Workstation: TGroupBox;
    Label_ComputerName: TLabel;
    Edit_Workstation: TEdit;
    Button_Add: TButton;
    Button_Change: TButton;
    ListBox_Workstations: TListBox;
    Button_Delete: TButton;
    RadioButton_All: TRadioButton;
    RadioButton_Listed: TRadioButton;
    Button_Cancel: TButton;
    Button_OK: TButton;
    procedure Button_CancelClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure Button_ChangeClick(Sender: TObject);
    procedure ListBox_WorkstationsClick(Sender: TObject);
    procedure Edit_WorkstationKeyPress(Sender: TObject; var Key: Char);
    procedure Button_AddClick(Sender: TObject);
    procedure Edit_WorkstationChange(Sender: TObject);
    procedure RadioButton_AllClick(Sender: TObject);
    procedure RadioButton_ListedClick(Sender: TObject);
    procedure Button_DeleteClick(Sender: TObject);
    procedure Button_OKClick(Sender: TObject);
  private
    FCallingForm: TForm;
    FInPlaceEdit: TEdit;
    FOnApply: TApplyWorkstationsProc;
    procedure SetCallingForm(const Value: TForm);
    procedure SetWorkstations(const Value: string);
    procedure OnInPlaceEditKeyPress(Sender: TObject; var Key: Char);
    procedure OnInPlaceEditExit(Sender: TObject);
  public
    property CallingForm: TForm write SetCallingForm;
    property Workstations: string write SetWorkstations;
    property OnApply: TApplyWorkstationsProc read FOnApply write FOnApply;
  end;

var
  Form_Workstations: TForm_Workstations;

implementation

{$R *.dfm}

{ TForm_Workstations }

procedure TForm_Workstations.Button_AddClick(Sender: TObject);
begin
if (Edit_Workstation.Text <> '') and (ListBox_Workstations.Items.IndexOf(Edit_Workstation.Text) = -1)
    then ListBox_Workstations.Items.Add(Edit_Workstation.Text);
  Edit_Workstation.Text := '';
  Edit_Workstation.SetFocus;
end;

procedure TForm_Workstations.Button_CancelClick(Sender: TObject);
begin
  Close;
end;

procedure TForm_Workstations.Button_ChangeClick(Sender: TObject);
var
  LRect: TRect;
begin
  LRect := ListBox_Workstations.ItemRect(ListBox_Workstations.ItemIndex);
  {Set the size of the TEdit}
  FInPlaceEdit.Top := LRect.Top;
  FInPlaceEdit.Left := LRect.Left + 1;
  FInPlaceEdit.Width := 150; //ListBox1.Canvas.TextWidth(ListBox1.Items.Strings[ListBox1.ItemIndex]) + 6;
  FInPlaceEdit.Height := (LRect.Bottom - LRect.Top);

  FInPlaceEdit.Text := ListBox_Workstations.Items.Strings[ListBox_Workstations.ItemIndex];
  FInPlaceEdit.Visible := True;
  FInPlaceEdit.SelectAll;
  FInPlaceEdit.SetFocus;
end;

procedure TForm_Workstations.Button_DeleteClick(Sender: TObject);
var
  i: Integer;
begin
  i := ListBox_Workstations.ItemIndex;
  ListBox_Workstations.DeleteSelected;

  if ListBox_Workstations.Items.Count - 1 >= i
    then ListBox_Workstations.ItemIndex := i
    else if ListBox_Workstations.Items.Count > 0
      then ListBox_Workstations.ItemIndex := i - 1;

  Button_Change.Enabled := ListBox_Workstations.ItemIndex > -1;
  Button_Delete.Enabled := ListBox_Workstations.ItemIndex > -1;
end;

procedure TForm_Workstations.Button_OKClick(Sender: TObject);
begin
  if Assigned(FOnApply) then
    if RadioButton_All.Checked
      then FOnApply(Self, '')
      else FOnApply(Self, ListBox_Workstations.Items.CommaText);

  Close;
end;

procedure TForm_Workstations.Edit_WorkstationChange(Sender: TObject);
begin
  Button_Add.Enabled := Edit_Workstation.Text <> '';
end;

procedure TForm_Workstations.Edit_WorkstationKeyPress(Sender: TObject;
  var Key: Char);
begin
  if (Edit_Workstation.Text <> '') and (Key = #13) then
  begin
    Button_AddClick(Self);
    Key := #0;
  end;
end;

procedure TForm_Workstations.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  RadioButton_All.Checked := True;
  Edit_Workstation.Clear;
  ListBox_Workstations.Clear;
  ListBox_WorkstationsClick(Self);
  FOnApply := nil;
  if FCallingForm <> nil then
  begin
    FCallingForm.Enabled := True;
    FCallingForm.Show;
    FCallingForm := nil;
  end;
end;

procedure TForm_Workstations.FormCreate(Sender: TObject);
begin
  RadioButton_All.Checked := True;
  FInPlaceEdit := TEdit.Create(nil);
  with FInPlaceEdit do
  begin
    Parent := ListBox_Workstations;
    Ctl3D := False;
    Visible := False;
    OnKeyPress := OnInPlaceEditKeyPress;
    OnExit := OnInPlaceEditExit;
  end;
end;

procedure TForm_Workstations.FormDestroy(Sender: TObject);
begin
  FInPlaceEdit.Free;
end;

procedure TForm_Workstations.ListBox_WorkstationsClick(Sender: TObject);
begin
  Button_Change.Enabled := ListBox_Workstations.ItemIndex > -1;
  Button_Delete.Enabled := ListBox_Workstations.ItemIndex > -1;
end;

procedure TForm_Workstations.OnInPlaceEditExit(Sender: TObject);
var
  Key: Char;
begin
  Key := #13;
  OnInPlaceEditKeyPress(Self, Key);
end;

procedure TForm_Workstations.OnInPlaceEditKeyPress(Sender: TObject;
  var Key: Char);
begin
  if Key = #13 then
  begin
    ListBox_Workstations.Items[ListBox_Workstations.ItemIndex] := FInPlaceEdit.Text;
    FInPlaceEdit.Hide;
    Key := #0;
  end;
end;

procedure TForm_Workstations.RadioButton_AllClick(Sender: TObject);
var
  i: Integer;
begin
  for i := 0 to GroupBox_Workstation.ControlCount - 1 do
    GroupBox_Workstation.Controls[i].Enabled := False;
  Edit_Workstation.Color := clBtnFace;
  ListBox_Workstations.Color := clBtnFace;
end;

procedure TForm_Workstations.RadioButton_ListedClick(Sender: TObject);
var
  i: Integer;
begin
  for i := 0 to GroupBox_Workstation.ControlCount - 1 do
    GroupBox_Workstation.Controls[i].Enabled := True;
  Edit_Workstation.Color := clWindow;
  ListBox_Workstations.Color := clWindow;
  Edit_WorkstationChange(Self);
  ListBox_WorkstationsClick(Self);
end;

procedure TForm_Workstations.SetCallingForm(const Value: TForm);
begin
  FCallingForm := Value;

  if FCallingForm <> nil
    then FCallingForm.Enabled := False;
end;

procedure TForm_Workstations.SetWorkstations(const Value: string);
begin
  ListBox_Workstations.Clear;
  ListBox_Workstations.Items.CommaText := Value;

  if ListBox_Workstations.Items.Count = 0
    then RadioButton_All.Checked := True
    else RadioButton_Listed.Checked := True
end;

end.
