unit fmCreateGroup;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls;

type
  TForm_CreateGroup = class(TForm)
    Edit_DomainNetBIOSName: TEdit;
    Label_sAMAccountName: TLabel;
    Edit_AccountName: TEdit;
    Label_AccountName: TLabel;
    Button_SelectContainer: TButton;
    Edit_Container: TEdit;
    Label_Container: TLabel;
    GroupBox1: TGroupBox;
    GroupBox2: TGroupBox;
    RadioButton1: TRadioButton;
    RadioButton2: TRadioButton;
    RadioButton3: TRadioButton;
    RadioButton4: TRadioButton;
    RadioButton5: TRadioButton;
    Button_OK: TButton;
    Button_Cancel: TButton;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form_CreateGroup: TForm_CreateGroup;

implementation

{$R *.dfm}

end.
