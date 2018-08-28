unit fmGroupInfo;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, ADC.ADObject, Vcl.ComCtrls,
  Winapi.ActiveX, Vcl.StdCtrls, Winapi.CommCtrl, System.StrUtils, ActiveDs_TLB,
  ADC.Types, ADC.Common, ADC.GlobalVar, ADC.AD, ADC.LDAP, Vcl.ToolWin,
  Vcl.ExtCtrls, System.ImageList, Vcl.ImgList;

type
  TForm_GroupInfo = class(TForm)
    Edit_Name: TEdit;
    ListView_Members: TListView;
    Label_Name: TLabel;
    Label_Description: TLabel;
    Edit_Description: TEdit;
    Button_Close: TButton;
    Button_Apply: TButton;
    Button_OK: TButton;
    Edit_Search: TButtonedEdit;
    ToolBar: TToolBar;
    ToolButton_Refresh: TToolButton;
    ToolButton_Separator1: TToolButton;
    ToolButton_SelectNone: TToolButton;
    ToolButton_SelectAll: TToolButton;
    Label_Search: TLabel;
    ImageList_ToolBar: TImageList;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure ListView_MembersData(Sender: TObject; Item: TListItem);
    procedure ListView_MembersDrawItem(Sender: TCustomListView; Item: TListItem;
      Rect: TRect; State: TOwnerDrawState);
    procedure Button_CloseClick(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure Button_OKClick(Sender: TObject);
    procedure Button_ApplyClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure Edit_SearchChange(Sender: TObject);
    procedure ToolButton_RefreshClick(Sender: TObject);
    procedure Edit_SearchRightButtonClick(Sender: TObject);
  private
    FCallingForm: TForm;
    FObj: TADObject;
    FCanClose: Boolean;
    FMembers: TADGroupMemberList;
    FMemberList: TADGroupMemberList;
    FListViewWndProc: TWndMethod;
    procedure ListViewWndProc(var Msg: TMessage);
    procedure SetCallingForm(const Value: TForm);
    procedure SetObject(const Value: TADObject);
  public
    property CallingForm: TForm write SetCallingForm;
    property GroupObject: TADObject read FObj write SetObject;
  end;

var
  Form_GroupInfo: TForm_GroupInfo;

implementation

{$R *.dfm}

uses dmDataModule;

{ TForm_GroupInfo }

function SortMembersByName(Item1, Item2: Pointer): Integer;
var
  m1, m2: TADGroupMember;
begin
  m1 := PADGroupMember(Item1)^;
  m2 := PADGroupMember(Item2)^;
  if m1.SortKey > m2.SortKey
    then Result := 1
    else if m1.SortKey < m2.SortKey
      then Result := -1
      else Result := AnsiCompareText(m1.name, m2.name);
end;

procedure TForm_GroupInfo.Button_ApplyClick(Sender: TObject);
var
  MsgBoxParam: TMsgBoxParams;
begin
  try
    case apAPI of
      ADC_API_LDAP: begin
        FCanClose := FObj.SetGroupDescription(LDAPBinding, Edit_Description.Text);
        FObj.Refresh(LDAPBinding, List_Attributes);
      end;

      ADC_API_ADSI: begin
        FCanClose := FObj.SetGroupDescription(Edit_Description.Text);
        FObj.Refresh(ADSIBinding, List_Attributes);
      end;
    end;
  except
    on E: Exception do
    begin
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
end;

procedure TForm_GroupInfo.Button_CloseClick(Sender: TObject);
begin
  Close;
end;

procedure TForm_GroupInfo.Button_OKClick(Sender: TObject);
begin
  Button_ApplyClick(Self);
  if FCanClose then Close;
end;

procedure TForm_GroupInfo.Edit_SearchChange(Sender: TObject);
var
  m: PADGroupMember;
begin
  Edit_Search.RightButton.Visible := Edit_Search.Text <> '';

  ListView_Members.Clear;
  FMembers.Clear;
  if Edit_Search.Text = '' then
  begin
    for m in FMemberList do
      FMembers.Add(m);
  end else
  for m in FMemberList do
  begin
    if ContainsText(m^.name, Edit_Search.Text)
    or ContainsText(m^.sAMAccountName, Edit_Search.Text)
      then FMembers.Add(m);
  end;
  ListView_Members.Items.Count := FMembers.Count;
end;

procedure TForm_GroupInfo.Edit_SearchRightButtonClick(Sender: TObject);
begin
  Edit_Search.Clear;
end;

procedure TForm_GroupInfo.FormClose(Sender: TObject; var Action: TCloseAction);
var
  i: Integer;
begin
  for i := 0 to Self.ControlCount - 1 do
    if Self.Controls[i] is TEdit
      then TEdit(Self.Controls[i]).Clear;

  Edit_Search.Clear;

  FCanClose := False;

  ListView_Members.Items.Count := 0;
  if FCallingForm <> nil then
  begin
    FCallingForm.Enabled := True;
    FCallingForm.Show;
    FCallingForm := nil;
    FObj := nil;
  end;
end;

procedure TForm_GroupInfo.FormCreate(Sender: TObject);
begin
  FMembers := TADGroupMemberList.Create(False);
  FMemberList := TADGroupMemberList.Create;

  FListViewWndProc := ListView_Members.WindowProc;
  ListView_Members.WindowProc := ListViewWndProc;
end;

procedure TForm_GroupInfo.FormDestroy(Sender: TObject);
begin
  FMembers.Free;
  FMemberList.Free;
end;

procedure TForm_GroupInfo.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  case Key of
    VK_F5: begin
      SetObject(FObj);
    end;

    VK_UP: begin
      if ActiveControl <> nil then
      begin
        if ActiveControl.ClassNameIs(TEdit.ClassName)
          then SelectNext(ActiveControl, False, True);
      end;
    end;

    VK_DOWN: begin
      if ActiveControl <> nil then
      begin
        if ActiveControl.ClassNameIs(TEdit.ClassName)
          then SelectNext(ActiveControl, True, True);
      end;
    end;

    VK_ESCAPE: begin
      Close;
    end;
  end;
end;

procedure TForm_GroupInfo.FormResize(Sender: TObject);
var
  w: Integer;
begin
  w := ListView_Members.ClientWidth;
  ListView_Members.Columns[0].Width := Round(w * 50 / 100);
  ListView_Members.Columns[1].Width := w - ListView_Members.Columns[0].Width;
end;

procedure TForm_GroupInfo.FormShow(Sender: TObject);
begin
  Button_Close.SetFocus;
end;

procedure TForm_GroupInfo.ListViewWndProc(var Msg: TMessage);
begin
  ShowScrollBar(ListView_Members.Handle, SB_HORZ, False);
//  ShowScrollBar(ListView_MemberOf.Handle, SB_VERT, True);
  FListViewWndProc(Msg);
end;

procedure TForm_GroupInfo.ListView_MembersData(Sender: TObject; Item: TListItem);
begin
  while Item.SubItems.Count < 2 do Item.SubItems.Add('');

  Item.Caption := FMembers[Item.Index]^.name;
  case FMembers[Item.Index]^.SortKey of
    1: begin
      Item.ImageIndex := 6;
    end;

    2: begin
      Item.ImageIndex := 0;
      Item.SubItems[0] := FMembers[Item.Index]^.sAMAccountName;
    end;
  end;
end;

procedure TForm_GroupInfo.ListView_MembersDrawItem(Sender: TCustomListView;
  Item: TListItem; Rect: TRect; State: TOwnerDrawState);
var
 C: TCanvas;
 R: TRect;
 S: string;
 ColOrder: array of Integer;
 SubIndex: Integer;
 txtAlign: UINT;
 i: Integer;
 attr: PADAttribute;
begin
  C := Sender.Canvas;

  if odSelected in State
    then C.Brush.Color := IncreaseBrightness(COLOR_SELBORDER, 95);
  C.FillRect(Rect);

  { ������� ������ ������� AD }
  R := Rect;
  R.Left := 6;
  R.Width := 16;
  if Item.ImageIndex > -1
    then DM1.ImageList_Accounts.Draw(c, R.TopLeft.X, R.TopLeft.Y + 1, Item.ImageIndex);

  { ������� name }
  R := Rect;
  R.Left := 22;
  R.Right := R.Left + (Sender.Column[0].Width - R.Left);
  R.Inflate(-6, 0);
  C.Refresh;
  S := Item.Caption;
  DrawText(
    C.Handle,
    S,
    Length(S),
    R,
    DT_LEFT or DT_VCENTER or DT_SINGLELINE or DT_END_ELLIPSIS
  );

  { ������� sAMAccountName }
  ListView_GetSubItemRect(Sender.Handle, Item.Index, 1, 0, @R);
  R.Inflate(-6, 0);
  C.Refresh;
  S := Item.SubItems[0];
  DrawText(
    C.Handle,
    S,
    Length(S),
    R,
    DT_LEFT or DT_VCENTER or DT_SINGLELINE or DT_END_ELLIPSIS
  );

  { ������������ ����� ������ ������ }
  R := Rect;
  R.Height := R.Height - 1;
  R.Width := R.Width - 1;
  if odSelected in State then
  begin
    C.Pen.Color := COLOR_SELBORDER;
    C.Pen.Width := 1;
    C.Refresh;
    C.Polyline(
      [
         R.TopLeft,
         Point(R.BottomRight.X, R.TopLeft.Y),
         R.BottomRight,
         Point(R.TopLeft.X, R.BottomRight.Y),
         R.TopLeft
      ]
    );
  end else
  begin
    C.Pen.Color := IncreaseBrightness(clBtnFace, 35);
    C.Pen.Width := 1;
    C.Refresh;
    C.Polyline(
      [
         Point(R.TopLeft.X, R.BottomRight.Y),
         R.BottomRight
      ]
    )
  end;
end;

procedure TForm_GroupInfo.SetCallingForm(const Value: TForm);
begin
  FCallingForm := Value;
  if FCallingForm <> nil
    then FCallingForm.Enabled := False;
end;

procedure TForm_GroupInfo.SetObject(const Value: TADObject);
begin
  FObj := Value;
  if FObj <> nil then
  begin
    Edit_Name.Text := FObj.name;

    case apAPI of
      ADC_API_LDAP: begin
        Edit_Description.Text := FObj.GetGroupDescription(LDAPBinding);
        FObj.GetGroupMembers(LDAPBinding, FMemberList);
      end;

      ADC_API_ADSI: begin
        Edit_Description.Text := FObj.GetGroupDescription;
        FObj.GetGroupMembers(FMemberList);
      end;
    end;

    FMemberList.SortList(SortMembersByName);
    Edit_SearchChange(Self);
  end;
end;

procedure TForm_GroupInfo.ToolButton_RefreshClick(Sender: TObject);
begin
  ListView_Members.Items.Clear;
  FMembers.Clear;
  SetObject(FObj);
end;

end.
