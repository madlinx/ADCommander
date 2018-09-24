unit fmGroupMemeberSelection;

interface

uses
  Winapi.Windows, Winapi.Messages, Winapi.CommCtrl, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls,
  Vcl.ComCtrls, Vcl.ToolWin, Vcl.ExtCtrls, System.ImageList, Vcl.ImgList,
  Winapi.UxTheme, System.StrUtils, ADC.Types, ADC.ADObject, ADC.ADObjectList,
  ADC.ImgProcessor, ADC.Common, Vcl.Imaging.pngimage, ADC.GlobalVar;

type
  TForm_GroupMemberSelection = class(TForm)
    ListView_Objects: TListView;
    ImageList_ToolBar: TImageList;
    Edit_Search: TButtonedEdit;
    ToolBar: TToolBar;
    ToolButton_SelectNone: TToolButton;
    ToolButton_SelectAll: TToolButton;
    Button_OK: TButton;
    Button_Cancel: TButton;
    Label_Search: TLabel;
    Label_Description: TLabel;
    Edit_GroupName: TEdit;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure Edit_SearchChange(Sender: TObject);
    procedure Edit_SearchRightButtonClick(Sender: TObject);
    procedure ToolButton_SelectNoneClick(Sender: TObject);
    procedure ToolButton_SelectAllClick(Sender: TObject);
    procedure ListView_ObjectsData(Sender: TObject; Item: TListItem);
    procedure ListView_ObjectsDrawItem(Sender: TCustomListView; Item: TListItem;
      Rect: TRect; State: TOwnerDrawState);
    procedure ListView_ObjectsResize(Sender: TObject);
    procedure ListView_ObjectsKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure ListView_ObjectsMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure ListView_ObjectsClick(Sender: TObject);
    procedure Button_CancelClick(Sender: TObject);
    procedure Button_OKClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    FGroup: TADObject;
    FCallingForm: TForm;
    FObjects: TADGroupMemberList;
    FObjectList: TADGroupMemberList;
    FStateImages: TImageList;
    FListViewWndProc: TWndMethod;
    FOnAddMembers: TSelectGroupMemberProc;
    procedure ListViewWndProc(var Msg: TMessage);
    procedure SetCallingForm(const Value: TForm);
    procedure ClearFields;
  public
    procedure Initialize(AGroup: TADObject; AObjects: TADObjectList<TADObject>);
    property CallingForm: TForm write SetCallingForm;
    property OnAddMembers: TSelectGroupMemberProc read FOnAddMembers write FOnAddMembers;
  end;

var
  Form_GroupMemberSelection: TForm_GroupMemberSelection;

implementation

{$R *.dfm}

uses dmDataModule;

{ TForm_GroupMemberSelection }

function SortObjectsByName(Item1, Item2: Pointer): Integer;
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

procedure TForm_GroupMemberSelection.Button_CancelClick(Sender: TObject);
begin
  Close;
end;

procedure TForm_GroupMemberSelection.Button_OKClick(Sender: TObject);
var
  i: Integer;
  ResultList: TADGroupMemberList;
  m: PADGroupMember;
  MsgBoxParam: TMsgBoxParams;
begin
  ResultList := TADGroupMemberList.Create;

  for i := FObjectList.Count - 1 downto 0 do
  begin
    m := FObjectList[i];

    if m^.Selected then
    try
      case apAPI of
        ADC_API_LDAP: FGroup.AddGroupMember(LDAPBinding, m^.distinguishedName);
        ADC_API_ADSI: FGroup.AddGroupMember(m^.distinguishedName);
      end;
      FObjects.Remove(m);
      ResultList.Add(FObjectList.Extract(m));
      ListView_Objects.Items.Count := FObjects.Count
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
        ResultList.Free;
        ListView_Objects.Invalidate;
        Exit;
      end;
    end;
  end;

  if (ResultList.Count > 0) and (Assigned(FOnAddMembers))
    then FOnAddMembers(Self, ResultList);

  ResultList.Free;
  Close;
end;

procedure TForm_GroupMemberSelection.ClearFields;
begin
  Edit_GroupName.Text := '';
  ListView_Objects.Clear;
  FObjects.Clear;
  FObjectList.Clear;
  Edit_Search.Clear;
  FOnAddMembers := nil;
end;

procedure TForm_GroupMemberSelection.Edit_SearchChange(Sender: TObject);
var
  m: PADGroupMember;
begin
  Edit_Search.RightButton.Visible := Edit_Search.Text <> '';

  ListView_Objects.Clear;
  FObjects.Clear;
  if Edit_Search.Text = '' then
  begin
    for m in FObjectList do
      FObjects.Add(m);
  end else
  for m in FObjectList do
  begin
    if ContainsText(m^.name, Edit_Search.Text)
    or ContainsText(m^.sAMAccountName, Edit_Search.Text)
      then FObjects.Add(m);
  end;
  ListView_Objects.Items.Count := FObjects.Count;
end;

procedure TForm_GroupMemberSelection.Edit_SearchRightButtonClick(
  Sender: TObject);
begin
  Edit_Search.Clear;
end;

procedure TForm_GroupMemberSelection.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  ClearFields;

  if FCallingForm <> nil then
  begin
    FCallingForm.Enabled := True;
    FCallingForm.Show;
    FCallingForm := nil;
  end;
end;

procedure TForm_GroupMemberSelection.FormCreate(Sender: TObject);
begin
  FObjects := TADGroupMemberList.Create(False);
  FObjectList := TADGroupMemberList.Create;

  FStateImages := TImageList.Create(Self);
  FStateImages.ColorDepth := cd32Bit;

  TImgProcessor.GetThemeButtons(
    Self.Handle,
    ListView_Objects.Canvas.Handle,
    BP_CHECKBOX,
    ListView_Objects.Color,
    FStateImages
  );

  ListView_Objects.StateImages := FStateImages;
  FListViewWndProc := ListView_Objects.WindowProc;
  ListView_Objects.WindowProc := ListViewWndProc;
end;

procedure TForm_GroupMemberSelection.FormDestroy(Sender: TObject);
begin
  FObjects.Free;
  FObjectList.Free;
end;

procedure TForm_GroupMemberSelection.FormShow(Sender: TObject);
begin
  Edit_Search.SetFocus;
end;

procedure TForm_GroupMemberSelection.Initialize(AGroup: TADObject;
  AObjects: TADObjectList<TADObject>);
var
  l: TADGroupMemberList;
  o: TADObject;
  m: PADGroupMember;
begin
  l := TADGroupMemberList.Create;
  FGroup := AGroup;
  case apAPI of
    ADC_API_LDAP: FGroup.GetGroupMembers(LDAPBinding, l, False);
    ADC_API_ADSI: FGroup.GetGroupMembers(l, False);
  end;

  Edit_GroupName.Text := FGroup.name;

  for o in AObjects do
  if o.IsUser and not l.ContainsMember(o.distinguishedName) then
  begin
    New(m);
    m^.Selected := False;
    if o.IsGroup then m^.SortKey := 1 else m^.SortKey := 2;
    m^.name := o.name;
    m^.sAMAccountName := o.sAMAccountName;
    m^.distinguishedName := o.distinguishedName;
    FObjectList.Add(m);
  end;

  FObjectList.SortList(SortObjectsByName);
  Edit_SearchChange(Self);
end;

procedure TForm_GroupMemberSelection.ListViewWndProc(var Msg: TMessage);
begin
  ShowScrollBar(ListView_Objects.Handle, SB_HORZ, False);
//  ShowScrollBar(ListView_MemberOf.Handle, SB_VERT, True);
  FListViewWndProc(Msg);
end;

procedure TForm_GroupMemberSelection.ListView_ObjectsClick(Sender: TObject);
var
  hts : THitTests;
  lvCursosPos : TPoint;
  li : TListItem;
  R: TRect;
  Key: Word;
begin
  inherited;
  Key := VK_SPACE;
  //position of the mouse cursor related to ListView
  lvCursosPos := ListView_Objects.ScreenToClient(Mouse.CursorPos) ;
  //click where?
  hts := ListView_Objects.GetHitTestInfoAt(lvCursosPos.X, lvCursosPos.Y);
  //locate the state-clicked item
  if htOnItem in hts then
  begin
    li := ListView_Objects.GetItemAt(lvCursosPos.X, lvCursosPos.Y);
    if li <> nil then
    begin
      ListView_GetItemRect(ListView_Objects.Handle, li.Index, R, LVIR_BOUNDS);
      { Величины R.Width и R.Offset см. в отрисовке значка состояния атрибута }
      { в процедуре ListView_AttributesDrawItem                               }
      R.Width := 16;
      R.Offset(6, 0);
      if PtInRect(R, lvCursosPos)
        then ListView_ObjectsKeyDown(ListView_Objects, Key, []);
    end;
  end;
end;

procedure TForm_GroupMemberSelection.ListView_ObjectsData(Sender: TObject;
  Item: TListItem);
begin
  while Item.SubItems.Count < 2 do Item.SubItems.Add('');

  if FObjects[Item.Index]^.Selected
    then Item.StateIndex := 1
    else Item.StateIndex := 0;

  Item.Caption := FObjects[Item.Index]^.name;
  case FObjects[Item.Index]^.SortKey of
    1: begin
      Item.ImageIndex := 6;
    end;

    2: begin
      Item.ImageIndex := 0;
      Item.SubItems[0] := FObjects[Item.Index]^.sAMAccountName;
    end;
  end;
end;

procedure TForm_GroupMemberSelection.ListView_ObjectsDrawItem(
  Sender: TCustomListView; Item: TListItem; Rect: TRect;
  State: TOwnerDrawState);
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

  if (odSelected in State) or (FObjects[Item.Index].Selected)
    then C.Brush.Color := IncreaseBrightness(COLOR_SELBORDER, 95);
  C.FillRect(Rect);

  { Выводим CheckBox }
  R := Rect;
  R.Width := 16;
  R.Offset(5, 0);
  ListView_Objects.StateImages.Draw(c, R.TopLeft.X, R.TopLeft.Y, Item.StateIndex);

  { Выводим значек объекта AD }
  R.Offset(R.Width + 6, 0);
  if Item.ImageIndex > -1
    then DM1.ImageList_Accounts.Draw(c, R.TopLeft.X, R.TopLeft.Y + 1, Item.ImageIndex);

  { Выводим name }
  R.Offset(R.Width + 6, 0);
  R.Right := R.Left + (Sender.Column[0].Width - R.Left - 6);
  C.Font.Style := C.Font.Style - [fsBold];
  C.Refresh;
  S := Item.Caption;
  DrawText(
    C.Handle,
    S,
    Length(S),
    R,
    DT_LEFT or DT_VCENTER or DT_SINGLELINE or DT_END_ELLIPSIS
  );

  { Выводим description }
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

  { Отрисовываем рамку вокруг записи }
  R := Rect;
  R.Height := R.Height - 1;
  R.Width := R.Width - 1;
  if odFocused in State then
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

procedure TForm_GroupMemberSelection.ListView_ObjectsKeyDown(Sender: TObject;
  var Key: Word; Shift: TShiftState);
var
  li: TListItem;
begin
  case Key of
    VK_SPACE: begin
      li :=  ListView_Objects.Selected;
      if li <> nil then
      begin
        FObjects.SetSelected(li.Index, not FObjects[li.Index].Selected);
        ListView_Objects.Invalidate
      end;
    end;
  end;
end;

procedure TForm_GroupMemberSelection.ListView_ObjectsMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  k: Word;
  li: TListItem;
  HitPoint: TPoint;
  HitInfo: TLVHitTestInfo;
  MsgRes: Integer;
begin
  if (Button = mbLeft) and (ssDouble in Shift)
  or (Button = mbLeft) and (ssCtrl in Shift) then
  begin
    HitPoint := ListView_Objects.ScreenToClient(Mouse.Cursorpos);
    FillChar(HitInfo, SizeOf(TLVHitTestInfo), 0);
    HitInfo.pt := HitPoint;
    MsgRes := ListView_Objects.Perform(LVM_SUBITEMHITTEST, 0, LPARAM(@HitInfo));
    if MsgRes <> -1 then
    begin
      ListView_Objects.Selected := ListView_Objects.Items[HitInfo.iItem];
      k := VK_SPACE;
      ListView_ObjectsKeyDown(Sender, k, []);
    end;
  end;
end;

procedure TForm_GroupMemberSelection.ListView_ObjectsResize(Sender: TObject);
var
  w: Integer;
begin
  w := ListView_Objects.ClientWidth;
  ListView_Objects.Columns[0].Width := Round(w * 55 / 100);
  ListView_Objects.Columns[1].Width := w - ListView_Objects.Columns[0].Width;
end;

procedure TForm_GroupMemberSelection.SetCallingForm(const Value: TForm);
begin
  FCallingForm := Value;
end;

procedure TForm_GroupMemberSelection.ToolButton_SelectAllClick(Sender: TObject);
var
  m: PADGroupMember;
begin
  for m in FObjects do
    m^.Selected := True;

  ListView_Objects.Invalidate;
end;

procedure TForm_GroupMemberSelection.ToolButton_SelectNoneClick(
  Sender: TObject);
var
  m: PADGroupMember;
begin
  for m in FObjects do
    m^.Selected := False;

  ListView_Objects.Invalidate;
end;

end.
