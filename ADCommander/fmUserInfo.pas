unit fmUserInfo;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ComCtrls, Vcl.StdCtrls,
  Vcl.Imaging.jpeg, Vcl.ExtCtrls, Vcl.Imaging.pngimage, Vcl.Menus, System.StrUtils,
  System.Types, System.DateUtils, Winapi.CommCtrl, Vcl.ImgList, ActiveDS_TLB,
  ADC.GlobalVar, ADC.Types, ADC.ImgProcessor, ADC.ADObject, ADC.UserEdit, ADC.Common,
  ADC.ScriptBtn;

type
  TForm_UserInfo = class(TForm)
    Panel_Title: TPanel;
    Label_Title_Title: TLabel;
    Label_Title_DisplayName: TLabel;
    Bevel_Top: TBevel;
    PageControl: TPageControl;
    TabSheet_General: TTabSheet;
    Label_DisplayName: TLabel;
    Label_LastName: TLabel;
    Label_FirstName: TLabel;
    Label_TelephoneNumber: TLabel;
    Label_OfficeName: TLabel;
    Label_Position: TLabel;
    Label_Department: TLabel;
    Label_EmployeeID: TLabel;
    Label_Description: TLabel;
    Label_Initials: TLabel;
    Image: TImage;
    Label_ObjectSID: TLabel;
    Edit_DisplayName: TEdit;
    Edit_LastName: TEdit;
    Edit_Initials: TEdit;
    Edit_FirstName: TEdit;
    Edit_TelephoneNumber: TEdit;
    Edit_OfficeName: TEdit;
    Edit_Title: TEdit;
    Edit_Department: TEdit;
    Edit_EmployeeID: TEdit;
    Edit_Description: TEdit;
    Button_Image: TButton;
    Edit_ObjectSID: TEdit;
    TabSheet_Account: TTabSheet;
    Label_sAMAccountName: TLabel;
    Label_AccountName: TLabel;
    Edit_sAMAccountName: TEdit;
    Edit_DomainNetBIOSName: TEdit;
    Edit_DomainDNSName: TEdit;
    Edit_AccountName: TEdit;
    CheckBox_DisableAccount: TCheckBox;
    CheckBox_PwdNotExpire: TCheckBox;
    CheckBox_PwdChangeOnLogon: TCheckBox;
    Button_Workstations: TButton;
    Edit_Workstations: TEdit;
    Button_PwdChange: TButton;
    CheckBox_UnlockAccount: TCheckBox;
    TabSheet_MemberOf: TTabSheet;
    Bevel_MemberOf: TBevel;
    Label_PrimaryGroup: TLabel;
    Label_PrimaryGroupName: TLabel;
    Label_PrimaryGroupHint: TLabel;
    ListView_Groups: TListView;
    Button_AddToGroup: TButton;
    Button_RemoveFromGroup: TButton;
    Button_SetGroupAsPrimary: TButton;
    TabSheet_Profile: TTabSheet;
    Label_LogonScript: TLabel;
    Edit_LogonScript: TEdit;
    TabSheet_Events: TTabSheet;
    Bevel_Events: TBevel;
    Label_EventsStorage: TLabel;
    Label_EventsStorageName: TLabel;
    Label_EventsStorageHint: TLabel;
    ListView_Events: TListView;
    Button_EventDelete: TButton;
    Button_EventAdd: TButton;
    Button_EventChange: TButton;
    Button_EventsSave: TButton;
    TabSheet_Advanced: TTabSheet;
    Button_Close: TButton;
    Button_Apply: TButton;
    Button_OK: TButton;
    PopupMenu_Image: TPopupMenu;
    LoadImage: TMenuItem;
    SaveImage: TMenuItem;
    MenuItem2: TMenuItem;
    DeleteImage: TMenuItem;
    Label_Title_Description: TLabel;
    ListView_ScriptButtons: TListView;
    procedure PageControlResize(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure Button_CloseClick(Sender: TObject);
    procedure LoadImageClick(Sender: TObject);
    procedure SaveImageClick(Sender: TObject);
    procedure DeleteImageClick(Sender: TObject);
    procedure PopupMenu_ImagePopup(Sender: TObject);
    procedure Button_ImageClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure Button_WorkstationsClick(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure Button_PwdChangeClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure Button_ApplyClick(Sender: TObject);
    procedure CheckBox_PwdChangeOnLogonClick(Sender: TObject);
    procedure CheckBox_PwdNotExpireClick(Sender: TObject);
    procedure Button_OKClick(Sender: TObject);
    procedure ListView_GroupsChange(Sender: TObject; Item: TListItem;
      Change: TItemChange);
    procedure ListView_EventsChange(Sender: TObject; Item: TListItem;
      Change: TItemChange);
    procedure ListView_GroupsData(Sender: TObject; Item: TListItem);
    procedure ListView_GroupsDrawItem(Sender: TCustomListView;
      Item: TListItem; Rect: TRect; State: TOwnerDrawState);
    procedure ListView_GroupsResize(Sender: TObject);
    procedure ListView_EventsResize(Sender: TObject);
    procedure Button_SetGroupAsPrimaryClick(Sender: TObject);
    procedure Button_RemoveFromGroupClick(Sender: TObject);
    procedure Button_AddToGroupClick(Sender: TObject);
    procedure ListView_EventsData(Sender: TObject; Item: TListItem);
    procedure ListView_EventsDrawItem(Sender: TCustomListView; Item: TListItem;
      Rect: TRect; State: TOwnerDrawState);
    procedure Button_EventAddClick(Sender: TObject);
    procedure Button_EventChangeClick(Sender: TObject);
    procedure Button_EventDeleteClick(Sender: TObject);
    procedure ListView_EventsMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure ListView_EventsKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure Button_EventsSaveClick(Sender: TObject);
    procedure ListView_ScriptButtonsCustomDraw(Sender: TCustomListView;
      const ARect: TRect; var DefaultDraw: Boolean);
    procedure ListView_ScriptButtonsChange(Sender: TObject; Item: TListItem;
      Change: TItemChange);
    procedure ListView_ScriptButtonsDrawItem(Sender: TCustomListView;
      Item: TListItem; Rect: TRect; State: TOwnerDrawState);
    procedure ListView_ScriptButtonsResize(Sender: TObject);
    procedure ListView_ScriptButtonsClick(Sender: TObject);
    procedure ListView_ScriptButtonsKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure ListView_ScriptButtonsDblClick(Sender: TObject);
  private
    const
      _TEXT_WORKSTATIONS_ALL = 'Все компьютеры';
  private
    FCallingForm: TForm;
    FObj: TADObject;
    FObjEdit: TUserEdit;
    FGroupList: TADGroupList;
    FGroups: TADGroupList;
    FEvents: TADEventList;
    FOnUserChange: TChangeUserProc;
    FCanClose: Boolean;
    FListViewWndProc_Groups: TWndMethod;
    FListViewWndProc_Events: TWndMethod;
    FListViewWndProc_ScriptButtons: TWndMethod;
    FImgList_ScriptButtons: TImageList;
    procedure BuildScriptButtonsImageList;
    procedure ListViewWndProc_Groups(var Msg: TMessage);
    procedure ListViewWndProc_Events(var Msg: TMessage);
    procedure ListViewWndProc_ScriptButtons(var Msg: TMessage);
    procedure SetCallingForm(const Value: TForm);
    procedure SetObject(const Value: TADObject);
    procedure ClearTextFields;
    procedure ClearImage;
    procedure CheckPasswordParameters;
    procedure RefreshInfo;
    procedure UpdateGroupList;
    function SaveUserInfo: Boolean;
    procedure OnWorkstationsApply(Sender: TObject; AWorkstations: string);
    procedure OnGroupsApply(Sender: TObject; AGroupList: TADGroupList);
    procedure OnPasswordChange(Sender: TObject; AChangeOnLogon: Boolean);
    procedure OnEventChange(Sender: TObject; AMode: Byte; AEvent: TADEvent);
    function GetScriptBtnIconRect_Execute(AListView: TCustomListView; AItemIndex: Integer): TRect;
  public
    property CallingForm: TForm write SetCallingForm;
    property UserObject: TADObject read FObj write SetObject;
    property OnUserChange: TChangeUserProc read FOnUserChange write FOnUserChange;
  end;

var
  Form_UserInfo: TForm_UserInfo;

implementation

{$R *.dfm}

uses dmDataModule, fmWorkstations, fmPasswordReset, fmGroupSelection,
  fmEventEditor;

{ TForm_UserInfo }

function SortGropListByName(Item1, Item2: Pointer): Integer;
var
  m1, m2: TADGroup;
begin
  m1 := PADGroup(Item1)^;
  m2 := PADGroup(Item2)^;
  Result := AnsiCompareText(m1.name, m2.name);
end;

procedure TForm_UserInfo.BuildScriptButtonsImageList;
const
  AC_IMAGE_SIZE = 58;
begin
  FImgList_ScriptButtons := TImageList.Create(Self);
  FImgList_ScriptButtons.SetSize(AC_IMAGE_SIZE, AC_IMAGE_SIZE);
  FImgList_ScriptButtons.ColorDepth := cd32bit;
  ListView_ScriptButtons.SmallImages := FImgList_ScriptButtons;
end;

procedure TForm_UserInfo.Button_AddToGroupClick(Sender: TObject);
begin
  with Form_GroupSelect do
  begin
    { В SetSelectedGroups указываем именно полный список групп         }
    { FGroupList, а не FGroups, который отображается в ListView_Groups }
    SetBaseGroupList(FGroupList);
    CallingForm := Self;
    OnGroupsApply := Self.OnGroupsApply;
    Position := poMainFormCenter;
    Show;
    Self.Enabled := False;
  end;
end;

procedure TForm_UserInfo.Button_ApplyClick(Sender: TObject);
var
  MsgBoxParam: TMsgBoxParams;
begin
  try
    FCanClose := SaveUserInfo;
    RefreshInfo;
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

procedure TForm_UserInfo.Button_CloseClick(Sender: TObject);
begin
  Close;
end;

procedure TForm_UserInfo.Button_EventAddClick(Sender: TObject);
begin
  with Form_EventEditor do
  begin
    CallingForm := Self;
    OnEventChange := Self.OnEventChange;
    Mode := ADC_EDIT_MODE_CREATE;
    Position := poMainFormCenter;
    Show;
  end;

  Self.Enabled := False;
end;

procedure TForm_UserInfo.Button_EventChangeClick(Sender: TObject);
var
  e: TADEvent;
begin
  if ListView_Events.Selected = nil
    then Exit;

  with Form_EventEditor do
  begin
    CallingForm := Self;
    OnEventChange := Self.OnEventChange;
    Mode := ADC_EDIT_MODE_CHANGE;
    ControlEvent := FEvents[ListView_Events.Selected.Index]^;
    Position := poMainFormCenter;
    Show;
  end;

  Self.Enabled := False;
end;

procedure TForm_UserInfo.Button_EventDeleteClick(Sender: TObject);
var
  i: Integer;
  e: PADEvent;
begin
  if ListView_Events.Selected = nil
    then Exit;

  i := ListView_Events.Selected.Index;
  e := FEvents.Extract(FEvents[i]);
  Dispose(e);
  ListView_Events.Items.Count := FEvents.Count;
  ListView_EventsChange(Self, nil, ctState);
  ListView_Events.Invalidate;
end;

procedure TForm_UserInfo.Button_EventsSaveClick(Sender: TObject);
begin
//  FObjEdit.SetEventList(apEventsDir, FObj.objectSid, FEvents);
  FObjEdit.SetEventList(Self.Handle, apEventsDir, FObj.objectSid, FEvents);

  if Assigned(FOnUserChange)
    then FOnUserChange(FObj);
end;

procedure TForm_UserInfo.Button_ImageClick(Sender: TObject);
var
  P: TPoint;
begin
  P := Button_Image.ClientToScreen(Point(0, Button_Image.Height));
  PopupMenu_Image.Popup(P.X, P.Y);
end;

procedure TForm_UserInfo.Button_OKClick(Sender: TObject);
begin
  Button_ApplyClick(Self);
  if FCanClose then Close;
end;

procedure TForm_UserInfo.Button_PwdChangeClick(Sender: TObject);
begin
  with Form_ResetPassword do
  begin
    CallingForm := Self;
    UserObject := FObj;
    if apUseDefaultPassword
      then DefaultPassword := apDefaultPassword;
    OnPasswordChange := Self.OnPasswordChange;
    Position := poMainFormCenter;
    Show;
  end;

  Self.Enabled := False;
end;

procedure TForm_UserInfo.Button_RemoveFromGroupClick(Sender: TObject);
var
  MsgBoxParam: TMsgBoxParams;
  i: Integer;
  R: TRect;
begin
  if ListView_Groups.Selected = nil
    then Exit;

  if FGroups[ListView_Groups.Selected.Index].IsPrimary then
  begin
    with MsgBoxParam do
    begin
      cbSize := SizeOf(MsgBoxParam);
      hwndOwner := Self.Handle;
      hInstance := 0;
      lpszCaption := PChar('AD Commander');
      lpszIcon := MAKEINTRESOURCE(32515);
      dwStyle := MB_OK or MB_ICONEXCLAMATION;
      dwContextHelpId := 0;
      lpfnMsgBoxCallback := nil;
      dwLanguageId := LANG_NEUTRAL;
      lpszText := PChar(
        'Основная группа не может быть удалена.' + #13#10
        + 'Определите другую группу в качестве основной прежде, чем удалить эту.'
      );
    end;

    MessageBoxIndirect(MsgBoxParam);
  end else
  begin
    i := ListView_Groups.Selected.Index;
    FGroups[i].Selected := False;
    UpdateGroupList;

    if ListView_Groups.Items.Count > 0 then
    begin
      if i in [0..ListView_Groups.Items.Count - 1]
        then ListView_Groups.Items[i].Selected := True
        else ListView_Groups.Items[ListView_Groups.Items.Count - 1].Selected := True;

      i := ListView_Groups.Selected.Index;
      ListView_Groups.Selected.MakeVisible(False);
    end;

    ListView_GroupsChange(Self, nil, ctState);
  end;
end;

procedure TForm_UserInfo.Button_SetGroupAsPrimaryClick(Sender: TObject);
var
  g: PADGroup;
begin
  if ListView_Groups.Selected = nil
    then Exit;

  FGroups.SetGroupAsPrimary(FGroups[ListView_Groups.Selected.Index].primaryGroupToken);

  ListView_GroupsChange(
    Self,
    ListView_Groups.Items[FGroups.PrimaryGroupIndex],
    ctState
  );

  ListView_Groups.Invalidate;
  ListView_Groups.SetFocus;
end;

procedure TForm_UserInfo.Button_WorkstationsClick(Sender: TObject);
begin
  with Form_Workstations do
  begin
    if CompareText(_TEXT_WORKSTATIONS_ALL, Self.Edit_Workstations.Text) <> 0
      then Workstations := Edit_Workstations.Text;
    OnApply := OnWorkstationsApply;
    Position := poMainFormCenter;
    Show;
    CallingForm := Self;
  end;
end;

procedure TForm_UserInfo.CheckBox_PwdChangeOnLogonClick(Sender: TObject);
begin
  CheckPasswordParameters;
end;

procedure TForm_UserInfo.CheckBox_PwdNotExpireClick(Sender: TObject);
begin
  CheckPasswordParameters;
end;

procedure TForm_UserInfo.CheckPasswordParameters;
var
  MsgBoxParam: TMsgBoxParams;
begin
  if (CheckBox_PwdChangeOnLogon.Checked) and (CheckBox_PwdNotExpire.Checked) then
  begin
    with MsgBoxParam do
    begin
      cbSize := SizeOf(MsgBoxParam);
      hwndOwner := Self.Handle;
      hInstance := 0;
      lpszText := PChar(
        'Установлен параметр "Срок действия пароля не ограничен".'+ #13#10 +
        'От пользователя не требуется изменять пароль при следующем входе в систему.'
      );
      lpszCaption := PChar('AD Commander');
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

procedure TForm_UserInfo.ClearImage;
begin
  Image.Picture := nil;
  Image.Tag := USER_IMAGE_EMPTY;
  DM1.ImageList_AccountDefault.GetBitmap(0, Image.Picture.Bitmap);
end;

procedure TForm_UserInfo.ClearTextFields;
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
      if Ctrl is TListView then
      begin
        TListView(Ctrl).Items.Count := 0;
        TListView(Ctrl).Clear;
        TListView(Ctrl).OnChange(Ctrl, nil, ctState);
      end;
    end;
  end;
  Button_OK.Enabled := False;
  Button_Apply.Enabled := False;
end;

procedure TForm_UserInfo.DeleteImageClick(Sender: TObject);
begin
  ClearImage;
end;

procedure TForm_UserInfo.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  ClearImage;
  ClearTextFields;
  FObj := nil;
  FCanClose := False;
  FGroups.Clear;
  FGroupList.Clear;
  FEvents.Clear;
  FOnUserChange := nil;

  if FCallingForm <> nil then
  begin
    FCallingForm.Enabled := True;
    FCallingForm.Show;
    FCallingForm := nil;
    FObj := nil;
  end;
end;

procedure TForm_UserInfo.FormCreate(Sender: TObject);
begin
  BuildScriptButtonsImageList;
  FGroupList := TADGroupList.Create;
  FGroups := TADGroupList.Create(False);
  FEvents := TADEventList.Create;
  ClearImage;
  ClearTextFields;
  PageControl.ActivePageIndex := 0;

  FListViewWndProc_Groups := ListView_Groups.WindowProc;
  ListView_Groups.WindowProc := ListViewWndProc_Groups;
  ListView_SetExtendedListViewStyle(
    ListView_Groups.Handle,
    ListView_GetExtendedListViewStyle(ListView_Groups.Handle) xor LVS_EX_INFOTIP
  );

  FListViewWndProc_Events := ListView_Events.WindowProc;
  ListView_Events.WindowProc := ListViewWndProc_Events;
  ListView_SetExtendedListViewStyle(
    ListView_Events.Handle,
    ListView_GetExtendedListViewStyle(ListView_Events.Handle) xor LVS_EX_INFOTIP
  );

  FListViewWndProc_ScriptButtons := ListView_ScriptButtons.WindowProc;
  ListView_ScriptButtons.WindowProc := ListViewWndProc_ScriptButtons;
end;

procedure TForm_UserInfo.FormDestroy(Sender: TObject);
begin
  FGroups.Free;
  FGroupList.Free;
  FImgList_ScriptButtons.Free;
end;

procedure TForm_UserInfo.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  case Key of
    VK_F5: begin
      RefreshInfo;
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
        if ActiveControl.ClassNameIs(TPageControl.ClassName)
          then SelectNext(ActiveControl, True, True);
      end;
    end;

    VK_ESCAPE: begin
      Close;
    end;
  end;
end;

function TForm_UserInfo.GetScriptBtnIconRect_Execute(AListView: TCustomListView;
  AItemIndex: Integer): TRect;
var
  R: TRect;
begin
  ListView_GetSubItemRect(AListView.Handle, AItemIndex, 1, LVIR_LABEL, @R);
  R.Inflate((16 - R.Width) div 2, (16 - R.Height) div 2);
//  R.Offset(-3, 0);

  Result := R;
end;

procedure TForm_UserInfo.ListViewWndProc_Events(var Msg: TMessage);
begin
  ShowScrollBar(ListView_Events.Handle, SB_HORZ, False);
//  ShowScrollBar(ListView_MemberOf.Handle, SB_VERT, True);
  FListViewWndProc_Events(Msg);
end;

procedure TForm_UserInfo.ListViewWndProc_Groups(var Msg: TMessage);
begin
  ShowScrollBar(ListView_Groups.Handle, SB_HORZ, False);
//  ShowScrollBar(ListView_MemberOf.Handle, SB_VERT, True);
  FListViewWndProc_Groups(Msg);
end;

procedure TForm_UserInfo.ListViewWndProc_ScriptButtons(var Msg: TMessage);
begin
  ShowScrollBar(ListView_ScriptButtons.Handle, SB_HORZ, False);
//  ShowScrollBar(ListView_ScriptButtons.Handle, SB_VERT, True);
  FListViewWndProc_ScriptButtons(Msg);
end;

procedure TForm_UserInfo.ListView_EventsChange(Sender: TObject; Item: TListItem;
  Change: TItemChange);
begin
  case Change of
    ctText: ;

    ctImage: ;

    ctState: begin
      Button_EventChange.Enabled := ListView_Events.SelCount > 0;
      Button_EventDelete.Enabled := ListView_Events.SelCount > 0;
    end;
  end;

end;

procedure TForm_UserInfo.ListView_EventsData(Sender: TObject; Item: TListItem);
begin
  while Item.SubItems.Count < ListView_Events.Columns.Count - 1 do
    Item.SubItems.Add('');

  Item.Caption := DateToStr(FEvents[Item.Index]^.Date);
  Item.SubItems[0] := ReplaceStr(FEvents[Item.Index]^.Description, #13#10, ' ');
end;

procedure TForm_UserInfo.ListView_EventsDrawItem(Sender: TCustomListView;
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

  { Выводим дату }
  R := Rect;
  R.Left := R.Left + 5;
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

  { Выводим описание }
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

  { Выводим индикатор сигнализации }
  if FEvents[Item.Index]^.Date > 0 then
  begin
    R := Rect;
    R.Width := 8;
    R.Inflate(-3, -3);
    C.Brush.Color := GetUserEventColor(FEvents[Item.Index]^.Date, C.Brush.Color);
    C.FillRect(R);
//    C.Brush.Color := clWhite;
//    C.FrameRect(tmpRect);
  end;

  { Отрисовываем рамку вокруг записи }
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

procedure TForm_UserInfo.ListView_EventsKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  case Key of
    VK_RETURN: begin
      Button_EventChangeClick(Self);
    end;
  end;
end;

procedure TForm_UserInfo.ListView_EventsMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  k: Word;
  li: TListItem;
  HitPoint: TPoint;
  HitInfo: TLVHitTestInfo;
  MsgRes: Integer;
begin
  if (Button = mbLeft) and (ssDouble in Shift) then
  begin
    HitPoint := ListView_Events.ScreenToClient(Mouse.Cursorpos);
    FillChar(HitInfo, SizeOf(TLVHitTestInfo), 0);
    HitInfo.pt := HitPoint;
    MsgRes := ListView_Events.Perform(LVM_SUBITEMHITTEST, 0, LPARAM(@HitInfo));
    if MsgRes <> -1 then
    begin
      ListView_Events.Selected := ListView_Events.Items[HitInfo.iItem];
      k := VK_RETURN;
      ListView_EventsKeyDown(Sender, k, []);
    end;
  end;
end;

procedure TForm_UserInfo.ListView_EventsResize(Sender: TObject);
var
  w: Integer;
begin
  w := ListView_Events.ClientWidth;
  ListView_Events.Columns[0].Width := 75;
  ListView_Events.Columns[1].Width := w - ListView_Events.Columns[0].Width;
end;

procedure TForm_UserInfo.ListView_GroupsChange(Sender: TObject;
  Item: TListItem; Change: TItemChange);
begin
  case Change of
    ctText: ;

    ctImage: ;

    ctState: begin
      Button_RemoveFromGroup.Enabled := ListView_Groups.SelCount > 0;
      Button_SetGroupAsPrimary.Enabled := (ListView_Groups.SelCount > 0)
        and (not FGroups[ListView_Groups.Selected.Index]^.IsPrimary)
        and (FGroups[ListView_Groups.Selected.Index]^.groupType
          in [ADS_GROUP_TYPE_GLOBAL_GROUP, ADS_GROUP_TYPE_UNIVERSAL_GROUP]
        );
    end;
  end;

end;

procedure TForm_UserInfo.ListView_GroupsData(Sender: TObject;
  Item: TListItem);
begin
  while Item.SubItems.Count < ListView_Groups.Columns.Count - 1 do
    Item.SubItems.Add('');

  Item.ImageIndex := FGroups[Item.Index]^.ImageIndex;
  Item.Caption := FGroups[Item.Index]^.name;
  Item.SubItems[0] := FGroups[Item.Index]^.description;
end;

procedure TForm_UserInfo.ListView_GroupsDrawItem(Sender: TCustomListView;
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

  { Выводим значек объекта AD }
  R := Rect;
  R.Left := R.Left + 6;
  R.Width := 16;
  if Item.ImageIndex > -1
    then DM1.ImageList_Accounts.Draw(c, R.TopLeft.X, R.TopLeft.Y + 1, Item.ImageIndex);

  { Выводим name }
  R := Rect;
  R.Left := R.Left + 22;
  R.Right := R.Left + (Sender.Column[0].Width - R.Left);
  R.Inflate(-6, 0);
  if FGroups[Item.Index].IsPrimary
    then C.Font.Style := C.Font.Style + [fsBold]
    else C.Font.Style := C.Font.Style - [fsBold];
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

procedure TForm_UserInfo.ListView_GroupsResize(Sender: TObject);
var
  w: Integer;
begin
  w := ListView_Groups.ClientWidth;
  ListView_Groups.Columns[0].Width := Round(w * 40 / 100);
  ListView_Groups.Columns[1].Width := w - ListView_Groups.Columns[0].Width;
end;

procedure TForm_UserInfo.ListView_ScriptButtonsChange(Sender: TObject;
  Item: TListItem; Change: TItemChange);
begin
  {}
end;

procedure TForm_UserInfo.ListView_ScriptButtonsClick(Sender: TObject);
var
  hts : THitTests;
  lvCursosPos : TPoint;
  li : TListItem;
  R: TRect;
  Key: Word;
begin
  inherited;

  //position of the mouse cursor related to ListView
  lvCursosPos := ListView_ScriptButtons.ScreenToClient(Mouse.CursorPos) ;
  //click where?
  hts := ListView_ScriptButtons.GetHitTestInfoAt(lvCursosPos.X, lvCursosPos.Y);
  //locate the state-clicked item
  if htOnItem in hts then
  begin
    li := ListView_ScriptButtons.GetItemAt(lvCursosPos.X, lvCursosPos.Y);
    if li <> nil then
    begin
      { Положение значка "Выполнить" }
      R := GetScriptBtnIconRect_Execute(li.ListView, li.Index);

      if PtInRect(R, lvCursosPos) then
      begin
        Key := VK_RETURN;
        ListView_ScriptButtonsKeyDown(ListView_ScriptButtons, Key, [])
      end
    end;
  end;
end;

procedure TForm_UserInfo.ListView_ScriptButtonsCustomDraw(
  Sender: TCustomListView; const ARect: TRect; var DefaultDraw: Boolean);
var
  C: TCanvas;
  R: TRect;
  S: string;
begin
  if Sender.Items.Count > 0
    then Exit;

  C := Sender.Canvas;

  R := C.ClipRect;
  R.Inflate(0, (16 - Sender.ClientHeight) div 2);
  R.Offset(0, -19);
  C.Font.Size := 10;
  C.Font.Color := clWindowText;
  C.Refresh;
  S := 'Нет доступных дополнительных функций';
  DrawText(
    C.Handle,
    S,
    Length(S),
    R,
    DT_CENTER or DT_SINGLELINE or DT_VCENTER
  );

  R := C.ClipRect;
  R.Inflate(0, (13 - Sender.ClientHeight) div 2);
  C.Font.Size := 8;
  C.Font.Color := clGrayText;
  C.Refresh;
  S := 'Для добавления дополнительных функций перейдите в настройки программы';
  DrawText(
    C.Handle,
    S,
    Length(S),
    R,
    DT_CENTER or DT_SINGLELINE or DT_VCENTER
  );

  R.Offset(0, 13);
  C.Font.Size := 8;
  C.Font.Color := clGrayText;
  C.Refresh;
  S := 'в раздел "Кнопки выполнения скриптов"';
  DrawText(
    C.Handle,
    S,
    Length(S),
    R,
    DT_CENTER or DT_SINGLELINE or DT_VCENTER
  );
end;

procedure TForm_UserInfo.ListView_ScriptButtonsDblClick(Sender: TObject);
var
  Key: Word;
begin
  Key := VK_RETURN;
  ListView_ScriptButtonsKeyDown(Self, Key, []);
end;

procedure TForm_UserInfo.ListView_ScriptButtonsDrawItem(Sender: TCustomListView;
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

  R := Rect;
  R.Inflate(-3, -3);
  C.FillRect(R);

  R := Rect;
  R.Width := Sender.Column[0].Width - R.Left;
  R.Inflate(-15, -13);

  { Выводим заголовок }
  R.Height := 16;
  C.Font.Color := clWindowText;
  C.Font.Size := 10;
  C.Refresh;
  S := List_ScriptButtons[Item.Index]^.Title;
  DrawText(
    C.Handle,
    S,
    Length(S),
    R,
    DT_LEFT or DT_SINGLELINE or DT_END_ELLIPSIS
  );

  { Выводим описание }
  R := Rect;
  R.Width := Sender.Column[0].Width - R.Left;
  R.Inflate(-15, -3);
  R.Height := 13;
  R.Offset(0, 28);
  C.Font.Color := clGrayText;
  C.Font.Size := 8;
  C.Refresh;

  if List_ScriptButtons[Item.Index]^.Description.IsEmpty
    then S := List_ScriptButtons[Item.Index]^.Title
    else S := List_ScriptButtons[Item.Index]^.Description;

  DrawText(
    C.Handle,
    S,
    Length(S),
    R,
    DT_LEFT or DT_SINGLELINE or DT_END_ELLIPSIS
  );

//  { Закрашиваем фон иконки "Выполнить" }
//  ListView_GetSubItemRect(Sender.Handle, Item.Index, 1, LVIR_LABEL, @R);
//  R.Inflate(-3, -3);
//  C.Brush.Color := IncreaseBrightness(clSilver, 80);
//  C.FillRect(R);

//  { Выводим вертикальный разделитель }
//  R := Rect;
//  R.Width := Sender.Column[0].Width - R.Left;
//  R.Inflate(0, -11);
//  C.Pen.Color := IncreaseBrightness(clSilver, 0);
//  C.Polyline([R.BottomRight, Point(R.BottomRight.X, R.TopLeft.y)]);

  { Выводим иконку "Выполнить" }
  R := GetScriptBtnIconRect_Execute(Sender, Item.Index);
  C.Refresh;
  DM1.ImageList_16x16.Draw(
    C,
    R.TopLeft.X,
    R.TopLeft.Y,
    8
  );

  { Отрисовываем рамку вокруг записи }
  R := Rect;
  R.Inflate(-3, -3);

  if odSelected in State
    then C.Pen.Color := COLOR_SELBORDER
    else C.Pen.Color := IncreaseBrightness(clSilver, 0);

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
end;

procedure TForm_UserInfo.ListView_ScriptButtonsKeyDown(Sender: TObject;
  var Key: Word; Shift: TShiftState);
var
  li: TListItem;
  MsgBoxParam: TMsgBoxParams;
begin
  li := ListView_ScriptButtons.Selected;

  case Key of
    VK_RETURN: begin
      if li <> nil then
      try
        List_ScriptButtons[li.Index]^.Execute(FObj);
      except
        on E: Exception do
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
            lpszText := PChar(E.Message);
          end;

          MessageBoxIndirect(MsgBoxParam);
        end;
      end;
    end;
  end;
end;

procedure TForm_UserInfo.ListView_ScriptButtonsResize(Sender: TObject);
var
  w: Integer;
begin
  w := ListView_ScriptButtons.ClientWidth;
//  if GetWindowLong(ListView_ScriptButtons.Handle, GWL_STYLE) and WS_VSCROLL <> 0
//    then w := w - GetSystemMetrics(SM_CXVSCROLL);
  ListView_ScriptButtons.Columns[1].Width := 38;

  ListView_ScriptButtons.Columns[0].Width := w - (
    ListView_ScriptButtons.Columns[1].Width
  );
end;

procedure TForm_UserInfo.LoadImageClick(Sender: TObject);
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
        Button_Image.SetFocus;
      end;
    end;
  end;
end;

procedure TForm_UserInfo.OnEventChange(Sender: TObject; AMode: Byte; AEvent: TADEvent);
var
  e: PADEvent;
begin
  case AMode of
    ADC_EDIT_MODE_CREATE: begin
      New(e);
      e^ := AEvent;
      FEvents.Add(e);
    end;

    ADC_EDIT_MODE_CHANGE: begin
      e := FEvents.GetEventByID(AEvent.ID);
      if Assigned(e) then
      begin
        e^.Date := AEvent.Date;
        e^.Description := AEvent.Description;
      end;
    end;

    ADC_EDIT_MODE_DELETE: begin
      e := FEvents.GetEventByID(AEvent.ID);
      if Assigned(e) then
      begin
        FEvents.Delete(FEvents.IndexOf(e));
      end;
    end;
  end;

  FEvents.SortList(SortEvents);
  ListView_Events.Items.Count := FEvents.Count;
  ListView_Events.Invalidate;

  if Assigned(e) then
  begin
    ListView_Events.Selected := ListView_Events.Items[FEvents.IndexOf(e)];
    ListView_Events.Selected.MakeVisible(False);
  end;
end;

procedure TForm_UserInfo.OnGroupsApply(Sender: TObject; AGroupList: TADGroupList);
var
  src: PADGroup;
  dst: PADGroup;
begin
  ListView_Groups.Clear;
  FGroups.Clear;
  FGroupList.Clear;
  for src in AGroupList do
  begin
    New(dst);
    dst^ := src^;
    FGroupList.Add(dst);
  end;
  FGroupList.Sort(SortGropListByName);
  UpdateGroupList;
end;

procedure TForm_UserInfo.OnPasswordChange(Sender: TObject;
  AChangeOnLogon: Boolean);
begin
  if Sender is TADObject then
  case apAPI of
    ADC_API_LDAP: TADObject(Sender).Refresh(LDAPBinding, List_Attributes);
    ADC_API_ADSI: TADObject(Sender).Refresh(ADSIBinding, List_Attributes);
  end;

  CheckBox_PwdChangeOnLogon.Checked := AChangeOnLogon;
end;

procedure TForm_UserInfo.OnWorkstationsApply(Sender: TObject;
  AWorkstations: string);
begin
  if AWorkstations.IsEmpty
    then Edit_Workstations.Text := _TEXT_WORKSTATIONS_ALL
    else Edit_Workstations.Text := AWorkstations;
end;

procedure TForm_UserInfo.PageControlResize(Sender: TObject);
const
  s = 6;
var
  l: Integer;
  w: Integer;
begin
  l := TabSheet_Account.ClientWidth - Label_AccountName.Left - Edit_AccountName.Left - s;
  w := Round(l / 2);
  Edit_AccountName.Width := w;
  Edit_DomainDNSName.Left := Edit_AccountName.Left + s + w;
  Edit_DomainDNSName.Width := l - w;
  Edit_DomainNetBIOSName.Width := w;
  Edit_sAMAccountName.Left := Edit_DomainNetBIOSName.Left + s + w;
  Edit_sAMAccountName.Width := l - w;
end;

procedure TForm_UserInfo.PopupMenu_ImagePopup(Sender: TObject);
begin
  PopupMenu_Image.Items[1].Enabled := Image.Tag = USER_IMAGE_ASSIGNED;
end;

procedure TForm_UserInfo.RefreshInfo;
var
  strArr: TStringDynArray;
  gSrc: PADEvent;
  gDst: PADEvent;
begin
  FGroups.Clear;
  FGroupList.Clear;
  FEvents.Clear;
  ClearImage;
  ClearTextFields;
  try
    case apAPI of
      ADC_API_LDAP: begin
        FObj.Refresh(LDAPBinding, List_Attributes, False);
        FObjEdit.GetInfo(LDAPBinding, FObj.distinguishedName);
        FObjEdit.GetGroupList(LDAPBinding, FObj.distinguishedName, FGroupList);
      end;

      ADC_API_ADSI: begin
        FObj.Refresh(ADSIBinding, List_Attributes, False);
        FObjEdit.GetInfoDS(ADSIBinding, FObj.distinguishedName);
        FObjEdit.GetGroupList(ADSIBinding, FObj.distinguishedName, FGroupList);
      end;
    end;

    if apEventsStorage = CTRL_EVENT_STORAGE_DISK
      then FObj.LoadEventsFromFile(apEventsDir);

    for gSrc in FObj.events do
    begin
      New(gDst);
      gDst^ := gSrc^;
      FEvents.Add(gDst);
    end;

    Button_OK.Enabled := True;
    Button_Apply.Enabled := True;
  except
    Button_OK.Enabled := False;
    Button_Apply.Enabled := False;
  end;

  { Заголовок }
  Label_Title_DisplayName.Caption := FObjEdit.displayName;
  Label_Title_Title.Caption := FObjEdit.title;
  Label_Title_Description.Caption := FObjEdit.department;

  { Общие }
  Edit_FirstName.Text := FObjEdit.givenName;
  Edit_Initials.Text := FObjEdit.initials;
  Edit_LastName.Text := FObjEdit.sn;
  Edit_DisplayName.Text := FObjEdit.displayName;
  Edit_Description.Text := FObjEdit.description;
  Edit_EmployeeID.Text := FObjEdit.employeeID;
  Edit_Department.Text := FObjEdit.department;
  Edit_Title.Text := FObjEdit.title;
  Edit_OfficeName.Text := FObjEdit.physicalDeliveryOfficeName;
  Edit_TelephoneNumber.Text := FObjEdit.telephoneNumber;
  Edit_ObjectSID.Text := FObj.objectSid;
  if TImgProcessor.ByteArrayToImage(FObjEdit.thumbnailPhoto, Image.Picture.Bitmap)
    then Image.Tag := USER_IMAGE_ASSIGNED
    else Image.Tag := USER_IMAGE_EMPTY;

  { Учетная запись }
  strArr := SplitString(FObjEdit.userPrincipalName, '@');
  if Length(strArr) > 0 then
  begin
    Edit_AccountName.Text := strArr[0];
    if Length(strArr) > 1
      then Edit_DomainDNSName.Text := '@' + strArr[1]
      else Edit_DomainDNSName.Text := '@' + SelectedDC.DomainDnsName;
  end;
  Edit_DomainNetBIOSName.Text := SelectedDC.DomainNetbiosName + '\';
  Edit_sAMAccountName.Text := FObjEdit.sAMAccountName;
  if FObjEdit.userWorkstations.IsEmpty
    then Edit_Workstations.Text := _TEXT_WORKSTATIONS_ALL
    else Edit_Workstations.Text := FObjEdit.userWorkstations;
  CheckBox_PwdChangeOnLogon.Checked := FObjEdit.ChangePwdAtLogon
    and (FObjEdit.userAccountControl and ADS_UF_DONT_EXPIRE_PASSWD = 0);
  CheckBox_PwdNotExpire.Checked := FObjEdit.userAccountControl and ADS_UF_DONT_EXPIRE_PASSWD <> 0;
  CheckBox_DisableAccount.Checked := FObjEdit.userAccountControl and ADS_UF_ACCOUNTDISABLE <> 0;
  CheckBox_UnlockAccount.Checked := False;
  case FObjEdit.AccountIsLocked of
    True: CheckBox_UnlockAccount.Caption := 'Разблокировать учетную запись. Учетная запись в данный момент заблокирована.';
    False: CheckBox_UnlockAccount.Caption := 'Разблокировать учетную запись';
  end;

  { Член групп }
  FGroupList.SortList(SortGropListByName);
  UpdateGroupList;
  Label_PrimaryGroupName.Caption := FGroupList.PrimaryGroupName;
  ListView_GroupsResize(Self);

  { Профиль }
  Edit_LogonScript.Text := FObjEdit.scriptPath;

  { События }
  FEvents.SortList(SortEvents);
  ListView_Events.Items.Count := FEvents.Count;
  Button_EventsSave.Visible := apEventsStorage = CTRL_EVENT_STORAGE_DISK;
  case apEventsStorage of
    CTRL_EVENT_STORAGE_DISK: Label_EventsStorageName.Caption := ExcludeTrailingBackslash(apEventsDir);
    CTRL_EVENT_STORAGE_AD: Label_EventsStorageName.Caption := 'Active Directory, атрибут ' + apEventsAttr;
  end;
  if Label_EventsStorageName.Caption = ''
    then Label_EventsStorageName.Caption := TEXT_NO_DATA;
  ListView_EventsResize(Self);

  { Дополнительно }
  ListView_ScriptButtonsResize(Self);
  ListView_ScriptButtons.Clear;
  ListView_ScriptButtons.Items.Count := List_ScriptButtons.Count;
end;

procedure TForm_UserInfo.SaveImageClick(Sender: TObject);
var
  flExt: string;
  flName: string;
  jpegImg: TJPEGImage;
begin
  with DM1.SaveDialog do
  begin
    FileName := FObj.sAMAccountName;
    Filter := 'Изображения в формате JPEG|*.jpg;*.jpeg';
    FilterIndex := 1;
    if Execute(Self.Handle) then
    begin
      flExt := '.jpg';

      flName := FileName;
      if ExtractFileExt(flName) = ''
        then flName := flName + flExt;

      jpegImg := TJPEGImage.Create;
      try
        with jpegImg do
        begin
          CompressionQuality := 100;
          Smoothing := True;
          Assign(Image.Picture.Bitmap);
          jpegImg.SaveToFile(flName);
        end;
      finally
        jpegImg.Free;
      end;
    end;
  end;
end;

function TForm_UserInfo.SaveUserInfo: Boolean;
begin
  Result := False;
  with FObjEdit do
  begin
    Clear;

    userAccountControl := FObj.userAccountControl;

    case CheckBox_PwdNotExpire.Checked of
      True: if userAccountControl and ADS_UF_DONT_EXPIRE_PASSWD = 0
        then userAccountControl := userAccountControl or ADS_UF_DONT_EXPIRE_PASSWD;

      False: if userAccountControl and ADS_UF_DONT_EXPIRE_PASSWD <> 0
        then userAccountControl := userAccountControl xor ADS_UF_DONT_EXPIRE_PASSWD;
    end;

    case CheckBox_DisableAccount.Checked of
      True: if userAccountControl and ADS_UF_ACCOUNTDISABLE = 0
        then userAccountControl := userAccountControl or ADS_UF_ACCOUNTDISABLE;

      False: if userAccountControl and ADS_UF_ACCOUNTDISABLE <> 0
        then userAccountControl := userAccountControl xor ADS_UF_ACCOUNTDISABLE;
    end;

    cn := Edit_DisplayName.Text;
    givenName := Edit_FirstName.Text;
    initials := Edit_Initials.Text;
    sn := Edit_LastName.Text;
    displayName := Edit_DisplayName.Text;
    userPrincipalName := Edit_AccountName.Text + Edit_DomainDNSName.Text;
    sAMAccountName := Edit_sAMAccountName.Text;
    if CompareText(Edit_Workstations.Text, _TEXT_WORKSTATIONS_ALL) <> 0
      then userWorkstations := Edit_Workstations.Text;
    description := Edit_Description.Text;
    employeeID := Edit_EmployeeID.Text;
    department := Edit_Department.Text;
    title := Edit_Title.Text;
    telephoneNumber := Edit_TelephoneNumber.Text;
    physicalDeliveryOfficeName := Edit_OfficeName.Text;
    ChangePwdAtLogon := CheckBox_PwdChangeOnLogon.Checked;
    AccountIsLocked := CheckBox_UnlockAccount.Checked;
    scriptPath := Edit_LogonScript.Text;
    if Image.Tag = USER_IMAGE_ASSIGNED
      then TImgProcessor.ImageToByteArray(Image.Picture.Bitmap, @thumbnailPhoto);
  end;

  try
    case apAPI of
      ADC_API_LDAP: begin
        FObjEdit.SetInfo(LDAPBinding, FObj.distinguishedName);
        FObjEdit.SetGroupList(LDAPBinding, FObj.distinguishedName, FGroupList);
        if apEventsStorage = CTRL_EVENT_STORAGE_AD
          then FObjEdit.SetEventList(LDAPBinding, FObj.distinguishedName, apEventsAttr, FEvents);
      end;

      ADC_API_ADSI: begin
//        FObjEdit.SetInfo(ADSIBinding, FObj.distinguishedName);
//        FObjEdit.SetGroupList(ADSIBinding, FObj.distinguishedName, FGroupList);
//        if apEventsStorage = CTRL_EVENT_STORAGE_AD
//          then FObjEdit.SetEventList(ADSIBinding, FObj.distinguishedName, apEventsAttr, FEvents);
        FObjEdit.SetInfoDS(ADSIBinding, FObj.distinguishedName);
        FObjEdit.SetGroupListDS(ADSIBinding, FObj.distinguishedName, FGroupList);
        if apEventsStorage = CTRL_EVENT_STORAGE_AD
          then FObjEdit.SetEventListDS(ADSIBinding, FObj.distinguishedName, apEventsAttr, FEvents);
      end;
    end;

    if apEventsStorage = CTRL_EVENT_STORAGE_DISK
      then Button_EventsSaveClick(Self);

    Result := True;

    if Assigned(FOnUserChange)
      then FOnUserChange(FObj);
  finally

  end;
end;

procedure TForm_UserInfo.SetCallingForm(const Value: TForm);
begin
  FCallingForm := Value;

  if FCallingForm <> nil
    then FCallingForm.Enabled := False;
end;

procedure TForm_UserInfo.SetObject(const Value: TADObject);
begin
  PageControl.ActivePageIndex := 0;
  FObj := Value;
  if FObj <> nil then
  begin
    RefreshInfo;
  end;
end;

procedure TForm_UserInfo.UpdateGroupList;
var
  g: PADGroup;
begin
  ListView_Groups.Clear;
  FGroups.Clear;

  for g in FGroupList do
    if g^.Selected
      then FGroups.Add(g);

  ListView_Groups.Items.Count := FGroups.Count;

  ListView_Groups.Invalidate;
end;

end.
