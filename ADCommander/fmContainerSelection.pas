unit fmContainerSelection;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ComCtrls,
  ADC.Types, ADC.DC;

type
  TForm_Container = class(TForm)
    TreeView_Containers: TTreeView;
    Button_Cancel: TButton;
    Button_OK: TButton;
    Label_Description: TLabel;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure Button_CancelClick(Sender: TObject);
    procedure TreeView_ContainersChange(Sender: TObject; Node: TTreeNode);
    procedure TreeView_ContainersDeletion(Sender: TObject; Node: TTreeNode);
    procedure Button_OKClick(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
  private
    FCallingForm: TForm;
    FDC: TDCInfo;
    FDefaultPath: string;
    FDescription: string;
    FSelectedContainer: TOrganizationalUnit;
    FOnContainerSelect: TSelectContainerProc;
    procedure SetCallingForm(const Value: TForm);
    procedure SetDomainController(const Value: TDCInfo);
    procedure OpenContainer(APath: string);
    procedure SetDefaulPath(const Value: string);
    procedure SetDescription(const Value: string);
  public
    property CallingForm: TForm write SetCallingForm;
    property DomainController: TDCInfo read FDC write SetDomainController;
    property DefaultPath: string write SetDefaulPath;
    property Description: string read FDescription write SetDescription;
    property OnContainerSelect: TSelectContainerProc read FOnContainerSelect write FOnContainerSelect;
  end;

var
  Form_Container: TForm_Container;

implementation

uses dmDataModule;

{$R *.dfm}

{ TForm_Container }

procedure TForm_Container.Button_CancelClick(Sender: TObject);
begin
  Close;
end;

procedure TForm_Container.Button_OKClick(Sender: TObject);
begin
  if Assigned(FOnContainerSelect)
    then Self.OnContainerSelect(Self, FSelectedContainer)
    else Close;
end;

procedure TForm_Container.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  SetDescription('');
  FDefaultPath := '';
  FOnContainerSelect := nil;
  TreeView_Containers.Items.Clear;
  Button_OK.Enabled := False;
  if FCallingForm <> nil then
  begin
    FCallingForm.Enabled := True;
    FCallingForm.Show;
    FCallingForm := nil;
  end;
end;

procedure TForm_Container.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  case Key of
    VK_ESCAPE: begin
      Close;
    end;
  end;
end;

procedure TForm_Container.OpenContainer(APath: string);
function GetNode(ParentNode: TTreeNode; NodeName: string): TTreeNode;
var
  TmpNode: TTreeNode;
begin
  if ParentNode = nil
    then TmpNode := TreeView_Containers.Items.GetFirstNode
    else TmpNode := ParentNode.GetFirstChild;

  while (TmpNode <> nil) and (CompareText(TmpNode.Text, NodeName) <> 0) do
    TmpNode := TmpNode.GetNextSibling;

  Result := TmpNode;
end;
var
  NodeNames: TStringList;
  pn: TTreeNode;
  n: TTreeNode;
  i: Integer;
begin
  NodeNames := TStringList.Create;
  NodeNames.StrictDelimiter := True;
  NodeNames.Delimiter := '/';
  NodeNames.DelimitedText := APath;
  pn := nil;
  n := nil;
  for i := 0 to NodeNames.Count - 1 do
  begin
    n := GetNode(pn, NodeNames[i]);
    if n = nil
      then Break
      else pn := n;
  end;
  NodeNames.Free;

  if n <> nil
    then TreeView_Containers.Selected := n;
end;

procedure TForm_Container.SetCallingForm(const Value: TForm);
begin
  FCallingForm := Value;
end;

procedure TForm_Container.SetDefaulPath(const Value: string);
begin
  FDefaultPath := Value;
  OpenContainer(Value);
end;

procedure TForm_Container.SetDescription(const Value: string);
begin
  FDescription := Value;
  if FDescription.IsEmpty
    then Label_Description.Caption := 'Укажите контейнер Active Directory.'
    else Label_Description.Caption := Value;
end;

procedure TForm_Container.SetDomainController(const Value: TDCInfo);
begin
  FDC := Value;
  if FDC <> nil
    then FDC.BuildTree(TreeView_Containers);
  if not FDefaultPath.IsEmpty
    then OpenContainer(FDefaultPath);
end;

procedure TForm_Container.TreeView_ContainersChange(Sender: TObject;
  Node: TTreeNode);
begin
  FSelectedContainer.Clear;
  Button_OK.Enabled := Node <> nil;
  if Node <> nil then
  begin
    FSelectedContainer := POrganizationalUnit(Node.Data)^;
  end;
end;

procedure TForm_Container.TreeView_ContainersDeletion(Sender: TObject;
  Node: TTreeNode);
begin
  { В узлах дерева хранятся данные типа PADContainerData. Поэтому, }
  { прежде чем очистить дерево/удалить узел, необходимо освободить }
  { память занимаемую этими данными                                }
  if Node.Data <> nil
    then Dispose(Node.Data);
  Node.Data := nil;
end;

end.
