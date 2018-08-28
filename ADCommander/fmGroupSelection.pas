unit fmGroupSelection;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ComCtrls, Winapi.ActiveX,
  Winapi.CommCtrl, Winapi.UxTheme, Vcl.StdCtrls, Vcl.ImgList, ActiveDS_TLB, ADC.Types,
  ADC.GlobalVar, ADC.Common, ADC.AD, ADC.LDAP, ADC.ImgProcessor, Vcl.ToolWin,
  System.ImageList, System.StrUtils, Vcl.ExtCtrls;

type
  TForm_GroupSelect = class(TForm)
    ListView_Groups: TListView;
    Label_Search: TLabel;
    Button_Cancel: TButton;
    Button_OK: TButton;
    ToolBar: TToolBar;
    ToolButton_Refresh: TToolButton;
    ToolButton_Separator1: TToolButton;
    ToolButton_SelectAll: TToolButton;
    ImageList_ToolBar: TImageList;
    ToolButton_SelectNone: TToolButton;
    Edit_Search: TButtonedEdit;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure ListView_GroupsData(Sender: TObject; Item: TListItem);
    procedure ListView_GroupsDrawItem(Sender: TCustomListView; Item: TListItem;
      Rect: TRect; State: TOwnerDrawState);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure ListView_GroupsResize(Sender: TObject);
    procedure Button_CancelClick(Sender: TObject);
    procedure ListView_GroupsClick(Sender: TObject);
    procedure ListView_GroupsKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure ListView_GroupsMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure ToolButton_RefreshClick(Sender: TObject);
    procedure ToolButton_SelectAllClick(Sender: TObject);
    procedure ToolButton_SelectNoneClick(Sender: TObject);
    procedure Edit_SearchChange(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure Button_OKClick(Sender: TObject);
    procedure Edit_SearchRightButtonClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    FCallingForm: TForm;
    FGroups: TADGroupList;
    FGroupList: TADGroupList;
    FBaseList: TADGroupList;
    FStateImages: TImageList;
    FListViewWndProc: TWndMethod;
    FOnGroupsApply: TSelectGroupProc;
    procedure ListViewWndProc(var Msg: TMessage);
    procedure ClearFields;
    procedure GetGroupList(ALDAP: PLDAP; AList: TADGroupList); overload;
    procedure GetGroupList(ARootDSE: IAds; AList: TADGroupList); overload;
    procedure SetCallingForm(const Value: TForm);
    function _GroupType(AValue: Integer): Integer;
  public
    procedure SetBaseGroupList(const AGroupList: TADGroupList);
    procedure RefreshGroupList;
    property CallingForm: TForm write SetCallingForm;
    property OnGroupsApply: TSelectGroupProc read FOnGroupsApply write FOnGroupsApply;
  end;

var
  Form_GroupSelect: TForm_GroupSelect;

implementation

{$R *.dfm}

uses dmDataModule;

function SortGropListByName(Item1, Item2: Pointer): Integer;
var
  m1, m2: TADGroup;
begin
  m1 := PADGroup(Item1)^;
  m2 := PADGroup(Item2)^;
  Result := AnsiCompareText(m1.name, m2.name);
end;

procedure TForm_GroupSelect.Button_CancelClick(Sender: TObject);
begin
  Close;
end;

procedure TForm_GroupSelect.Button_OKClick(Sender: TObject);
var
  i: Integer;
  idx: Integer;
begin
  { Если группа присутсвует в базовом списке групп, то изменяем значения ее }
  { полей. Если же группа в базовом списке не присутствовала и она выбрана  }
  { для добавления, то добавляем ее в базовый список. Возвращаем измененный }
  { базовый список в событии OnGroupsApply                                  }
  for i := FGroupList.Count - 1 downto 0 do
  begin
    idx := FBaseList.IndexOf(FGroupList[i]^.primaryGroupToken);
    if idx > -1 then
    begin
      FBaseList[idx]^ := FGroupList[i]^;
    end else if FGroupList[i]^.Selected then
    begin
      ListView_Groups.Items.Count := ListView_Groups.Items.Count - 1;
      FBaseList.Add(FGroupList.Extract(FGroupList[i]));
    end;
  end;

  if Assigned(FOnGroupsApply)
    then FOnGroupsApply(Self, FBaseList);

  Close;
end;

procedure TForm_GroupSelect.ClearFields;
begin
  ListView_Groups.Clear;
  FBaseList.Clear;
  FGroups.Clear;
  FGroupList.Clear;
  Edit_Search.Clear;
  FOnGroupsApply := nil;
end;

procedure TForm_GroupSelect.Edit_SearchChange(Sender: TObject);
var
  g: PADGroup;
begin
  Edit_Search.RightButton.Visible := Edit_Search.Text <> '';

  ListView_Groups.Clear;
  FGroups.Clear;
  if Edit_Search.Text = '' then
  begin
    for g in FGroupList do
      FGroups.Add(g);
  end else
  for g in FGroupList do
  begin
    if ContainsText(g^.name, Edit_Search.Text)
    or ContainsText(g^.description, Edit_Search.Text)
      then FGroups.Add(g);
  end;
  ListView_Groups.Items.Count := FGroups.Count;
end;

procedure TForm_GroupSelect.Edit_SearchRightButtonClick(Sender: TObject);
begin
  Edit_Search.Clear;
end;

procedure TForm_GroupSelect.FormClose(Sender: TObject;
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

procedure TForm_GroupSelect.FormCreate(Sender: TObject);
begin
  FGroups := TADGroupList.Create(False);
  FGroupList := TADGroupList.Create;
  FBaseList := TADGroupList.Create;

  FStateImages := TImageList.Create(Self);
  FStateImages.ColorDepth := cd32Bit;

  TImgProcessor.GetThemeButtons(
    Self.Handle,
    ListView_Groups.Canvas.Handle,
    BP_CHECKBOX,
    ListView_Groups.Color,
    FStateImages
  );

  ListView_Groups.StateImages := FStateImages;
  FListViewWndProc := ListView_Groups.WindowProc;
  ListView_Groups.WindowProc := ListViewWndProc;
end;

procedure TForm_GroupSelect.FormDestroy(Sender: TObject);
begin
  FGroups.Free;
  FGroupList.Free;
  FBaseList.Free;
end;

procedure TForm_GroupSelect.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  case Key of
    VK_F5: begin
      ToolButton_RefreshClick(Self);
    end;

    Ord('F'): begin
      if ssCtrl in Shift
        then Edit_Search.SetFocus;
    end;

    VK_ESCAPE: begin
      Close;
    end;
  end;
end;

procedure TForm_GroupSelect.FormShow(Sender: TObject);
begin
  Edit_Search.SetFocus;
end;

procedure TForm_GroupSelect.GetGroupList(ALDAP: PLDAP; AList: TADGroupList);
var
  ldapBase: AnsiString;
  ldapFilter: AnsiString;
  ldapCookie: PLDAPBerVal;
  ldapPage: PLDAPControl;
  ldapControls: array[0..1] of PLDAPControl;
  ldapServerControls: PPLDAPControl;
  ldapEntry: PLDAPMessage;
  ldapValue: PPAnsiChar;
  ldapCount: ULONG;
  searchResult: PLDAPMessage;
  attrArray: array of PAnsiChar;
  errorCode: ULONG;
  returnCode: ULONG;
  morePages: Boolean;
  dn: PAnsiChar;
  g: PADGroup;
begin
  AList.Clear;

  SetLength(attrArray, 2);
  attrArray[0] := PAnsiChar('defaultNamingContext');
  attrArray[1] := nil;

  returnCode := ldap_search_ext_s(
    ALDAP,
    nil,
    LDAP_SCOPE_BASE,
    PAnsiChar('(objectclass=*)'),
    PAnsiChar(@attrArray[0]),
    0,
    nil,
    nil,
    nil,
    0,
    searchResult
  );

  if (returnCode = LDAP_SUCCESS) and (ldap_count_entries(ALDAP, searchResult) > 0 ) then
  begin
    ldapEntry := ldap_first_entry(ALDAP, searchResult);
    ldapValue := ldap_get_values(ALDAP, ldapEntry, attrArray[0]);
    if ldapValue <> nil
      then ldapBase := ldapValue^;
    ldap_value_free(ldapValue);
  end;

  if searchResult <> nil
    then ldap_msgfree(searchResult);

  SetLength(attrArray, 5);
  attrArray[0] := PAnsiChar('primaryGroupToken');
  attrArray[1] := PAnsiChar('name');
  attrArray[2] := PAnsiChar('description');
  attrArray[3] := PAnsiChar('groupType');
  attrArray[4] := nil;

  try
    { Формируем фильтр объектов AD }
    ldapFilter := '(objectclass=group)';

    ldapCookie := nil;

    { Постраничный поиск объектов AD }
    repeat
      returnCode := ldap_create_page_control(
        ALDAP,
        ADC_SEARCH_PAGESIZE,
        ldapCookie,
        1,
        ldapPage
      );

      if returnCode <> LDAP_SUCCESS
        then raise Exception.Create('Failure during ldap_create_page_control: ' + ldap_err2string(returnCode));

      ldapControls[0] := ldapPage;
      ldapControls[1] := nil;

      returnCode := ldap_search_ext_s(
        ALDAP,
        PAnsiChar(ldapBase),
        LDAP_SCOPE_SUBTREE,
        PAnsiChar(ldapFilter),
        PAnsiChar(@attrArray[0]),
        0,
        @ldapControls,
        nil,
        nil,
        0,
        SearchResult
      );

      if not (returnCode in [LDAP_SUCCESS, LDAP_PARTIAL_RESULTS])
        then raise Exception.Create('Failure during ldap_search_ext_s: ' + ldap_err2string(returnCode));

      returnCode := ldap_parse_result(
        ALDAP^,
        SearchResult,
        @errorCode,
        nil,
        nil,
        nil,
        ldapServerControls,
        False
      );

      if ldapCookie <> nil then
      begin
        ber_bvfree(ldapCookie);
        ldapCookie := nil;
      end;

      returnCode := ldap_parse_page_control(
        ALDAP,
        ldapServerControls,
        ldapCount,
        ldapCookie
      );

      if (ldapCookie <> nil) and (ldapCookie^.bv_val <> nil) and (System.SysUtils.StrLen(ldapCookie^.bv_val) > 0)
        then morePages := True
        else morePages := False;

      if ldapServerControls <> nil then
      begin
         ldap_controls_free(ldapServerControls);
         ldapServerControls := nil;
      end;

      ldapControls[0]:= nil;
      ldap_control_free(ldapPage);
      ldapPage := nil;

      ldapEntry := ldap_first_entry(ALDAP, searchResult);
      while ldapEntry <> nil do
      begin
        New(g);

        g^.Selected   := False;
        g^.IsMember   := False;
        g^.IsPrimary  := False;
        g^.ImageIndex := 6;

        ldapValue := ldap_get_values(ALDAP, ldapEntry, attrArray[0]);
        if ldapValue <> nil
          then g^.primaryGroupToken := StrToIntDef(ldapValue^, 0);
        ldap_value_free(ldapValue);

        dn := ldap_get_dn(ALDAP, ldapEntry);
        if dn <> nil
         then g^.distinguishedName := dn;
        ldap_memfree(dn);

        ldapValue := ldap_get_values(ALDAP, ldapEntry, attrArray[1]);
        if ldapValue <> nil
          then g^.name := ldapValue^;
        ldap_value_free(ldapValue);

        ldapValue := ldap_get_values(ALDAP, ldapEntry, attrArray[2]);
        if ldapValue <> nil
          then g^.description := ldapValue^;
        ldap_value_free(ldapValue);

        ldapValue := ldap_get_values(ALDAP, ldapEntry, attrArray[3]);
        if ldapValue <> nil
          then g^.groupType := _GroupType(StrToIntDef(ldapValue^, 0));
        ldap_value_free(ldapValue);

        AList.Add(g);

        ldapEntry := ldap_next_entry(ALDAP, ldapEntry);
      end;

      ldap_msgfree(SearchResult);
      SearchResult := nil;
    until (morePages = False);

    ber_bvfree(ldapCookie);
    ldapCookie := nil;
  finally
    if searchResult <> nil
      then ldap_msgfree(searchResult);
  end;
end;

procedure TForm_GroupSelect.GetGroupList(ARootDSE: IAds; AList: TADGroupList);
const
  S_ADS_NOMORE_ROWS = HRESULT($00005012);
var
  hostName: string;
  hr: HRESULT;
  objFilter: string;
  hRes: HRESULT;
  SearchBase: string;
  SearchPrefs: array of ADS_SEARCHPREF_INFO;
  SearchResult: IDirectorySearch;
  SearchHandle: PHandle;
  col: ADS_SEARCH_COLUMN;
  attrArray: array of WideString;
  v: OleVariant;
  g: PADGroup;
begin
  AList.Clear;

  CoInitialize(nil);

  try
    v := ARootDSE.Get('defaultNamingContext');
    if not VarIsNull(v)
      then SearchBase := VariantToStringWithDefault(v, '');
    VariantClear(v);

    v := ARootDSE.Get('dnsHostName');
    if not VarIsNull(v)
      then hostName := VariantToStringWithDefault(v, '');
    VariantClear(v);

    { Получаем список групп в которых состоит пользователь }
    SetLength(attrArray, 5);
    attrArray[0] := PAnsiChar('primaryGroupToken');
    attrArray[1] := PAnsiChar('distinguishedName');
    attrArray[2] := PAnsiChar('name');
    attrArray[3] := PAnsiChar('description');
    attrArray[4] := PAnsiChar('groupType');

    hRes := ADsOpenObject(
      PChar('LDAP://' + hostName + '/' + SearchBase),
      nil,
      nil,
      ADS_SECURE_AUTHENTICATION or ADS_SERVER_BIND,
      IID_IDirectorySearch,
      @SearchResult
    );

    if Succeeded(hRes) then
    begin
      SetLength(SearchPrefs, 3);
      with SearchPrefs[0] do
      begin
        dwSearchPref  := ADS_SEARCHPREF_PAGESIZE;
        vValue.dwType := ADSTYPE_INTEGER;
        vValue.__MIDL____MIDL_itf_ads_0000_00000000.Integer := ADC_SEARCH_PAGESIZE;
      end;
      with SearchPrefs[1] do
      begin
        dwSearchPref  := ADS_SEARCHPREF_PAGED_TIME_LIMIT;
        vValue.dwType := ADSTYPE_INTEGER;
        vValue.__MIDL____MIDL_itf_ads_0000_00000000.Integer := 60;
      end;
      with SearchPrefs[2] do
      begin
        dwSearchPref  := ADS_SEARCHPREF_SEARCH_SCOPE;
        vValue.dwType := ADSTYPE_INTEGER;
        vValue.__MIDL____MIDL_itf_ads_0000_00000000.Integer := ADS_SCOPE_SUBTREE;
      end;

      hRes := SearchResult.SetSearchPreference(SearchPrefs[0], Length(SearchPrefs));

      if not Succeeded(hRes)
        then raise Exception.Create(ADSIErrorToString);

      objFilter := '(objectclass=group)';

      hRes := SearchResult.ExecuteSearch(
        PWideChar(objFilter),
        PWideChar(@attrArray[0]),
        Length(attrArray),
        Pointer(SearchHandle)
      );

      if not Succeeded(hRes)
        then raise Exception.Create(ADSIErrorToString);

      hRes := SearchResult.GetNextRow(SearchHandle);
      while (hRes <> S_ADS_NOMORE_ROWS) do
      begin
        New(g);

        g^.Selected   := False;
        g^.IsMember   := False;
        g^.IsPrimary  := False;
        g^.ImageIndex := 6;

        hRes := SearchResult.GetColumn(SearchHandle, PWideChar(attrArray[0]), col);
        if Succeeded(hRes)
          then g^.primaryGroupToken := col.pAdsvalues^.__MIDL____MIDL_itf_ads_0000_00000000.Integer;
        SearchResult.FreeColumn(col);

        hRes := SearchResult.GetColumn(SearchHandle, PWideChar(attrArray[1]), col);
        if Succeeded(hRes)
          then g^.distinguishedName := col.pAdsvalues^.__MIDL____MIDL_itf_ads_0000_00000000.DNString;
        SearchResult.FreeColumn(col);

        hRes := SearchResult.GetColumn(SearchHandle, PWideChar(attrArray[2]), col);
        if Succeeded(hRes)
          then g^.name := col.pAdsvalues^.__MIDL____MIDL_itf_ads_0000_00000000.CaseIgnoreString;
        SearchResult.FreeColumn(col);

        hRes := SearchResult.GetColumn(SearchHandle, PWideChar(attrArray[3]), col);
        if Succeeded(hRes)
          then g^.description := col.pAdsvalues^.__MIDL____MIDL_itf_ads_0000_00000000.CaseIgnoreString;
        SearchResult.FreeColumn(col);

        hRes := SearchResult.GetColumn(SearchHandle, PWideChar(attrArray[4]), col);
        if Succeeded(hRes)
          then g^.groupType := _GroupType(col.pAdsvalues^.__MIDL____MIDL_itf_ads_0000_00000000.Integer);
        SearchResult.FreeColumn(col);

        AList.Add(g);

        hRes := SearchResult.GetNextRow(Pointer(SearchHandle));
      end;
    end else raise Exception.Create(ADSIErrorToString);
  finally
    SearchResult.CloseSearchHandle(Pointer(SearchHandle));
  end;
end;

procedure TForm_GroupSelect.ListViewWndProc(var Msg: TMessage);
begin
  ShowScrollBar(ListView_Groups.Handle, SB_HORZ, False);
//  ShowScrollBar(ListView_MemberOf.Handle, SB_VERT, True);
  FListViewWndProc(Msg);
end;

procedure TForm_GroupSelect.ListView_GroupsClick(Sender: TObject);
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
  lvCursosPos := ListView_Groups.ScreenToClient(Mouse.CursorPos) ;
  //click where?
  hts := ListView_Groups.GetHitTestInfoAt(lvCursosPos.X, lvCursosPos.Y);
  //locate the state-clicked item
  if htOnItem in hts then
  begin
    li := ListView_Groups.GetItemAt(lvCursosPos.X, lvCursosPos.Y);
    if li <> nil then
    begin
      ListView_GetItemRect(ListView_Groups.Handle, li.Index, R, LVIR_BOUNDS);
      { Величины R.Width и R.Offset см. в отрисовке значка состояния атрибута }
      { в процедуре ListView_AttributesDrawItem                               }
      R.Width := 16;
      R.Offset(6, 0);
      if PtInRect(R, lvCursosPos)
        then ListView_GroupsKeyDown(ListView_Groups, Key, []);
    end;
  end;
end;

procedure TForm_GroupSelect.ListView_GroupsData(Sender: TObject;
  Item: TListItem);
begin
  while Item.SubItems.Count < ListView_Groups.Columns.Count - 1 do
    Item.SubItems.Add('');

  if FGroups[Item.Index]^.Selected
    then Item.StateIndex := 1
    else Item.StateIndex := 0;

  if FGroupList[Item.Index]^.IsPrimary
    then Item.StateIndex := 3;

  Item.ImageIndex := FGroups[Item.Index]^.ImageIndex;
  Item.Caption := FGroups[Item.Index]^.name;
  Item.SubItems[0] := FGroups[Item.Index]^.description;
end;

procedure TForm_GroupSelect.ListView_GroupsDrawItem(Sender: TCustomListView;
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

  if (odSelected in State) or (FGroups[Item.Index].Selected)
    then C.Brush.Color := IncreaseBrightness(COLOR_SELBORDER, 95);
  C.FillRect(Rect);

  { Выводим CheckBox }
  R := Rect;
  R.Width := 16;
  R.Offset(5, 0);
  ListView_Groups.StateImages.Draw(c, R.TopLeft.X, R.TopLeft.Y, Item.StateIndex);

  { Выводим значек объекта AD }
  R.Offset(R.Width + 6, 0);
  if Item.ImageIndex > -1
    then DM1.ImageList_Accounts.Draw(c, R.TopLeft.X, R.TopLeft.Y + 1, Item.ImageIndex);

  { Выводим name }
  R.Offset(R.Width + 6, 0);
  R.Right := R.Left + (Sender.Column[0].Width - R.Left - 6);
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

procedure TForm_GroupSelect.ListView_GroupsKeyDown(Sender: TObject;
  var Key: Word; Shift: TShiftState);
var
  li: TListItem;
  HitPoint: TPoint;
  HitInfo: TLVHitTestInfo;
  MsgRes: Integer;
begin
  case Key of
    VK_SPACE: begin
      li :=  ListView_Groups.Selected;
      if li <> nil then
      begin
        if not FGroups[li.Index]^.IsPrimary
          then FGroups.SetSelected(li.Index, not FGroups[li.Index].Selected);
        ListView_Groups.Invalidate
      end;
    end;
  end;
end;

procedure TForm_GroupSelect.ListView_GroupsMouseDown(Sender: TObject;
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
    HitPoint := ListView_Groups.ScreenToClient(Mouse.Cursorpos);
    FillChar(HitInfo, SizeOf(TLVHitTestInfo), 0);
    HitInfo.pt := HitPoint;
    MsgRes := ListView_Groups.Perform(LVM_SUBITEMHITTEST, 0, LPARAM(@HitInfo));
    if MsgRes <> -1 then
    begin
      ListView_Groups.Selected := ListView_Groups.Items[HitInfo.iItem];
      k := VK_SPACE;
      ListView_GroupsKeyDown(Sender, k, []);
    end;
  end;
end;

procedure TForm_GroupSelect.ListView_GroupsResize(Sender: TObject);
var
  w: Integer;
begin
  w := ListView_Groups.ClientWidth;
  ListView_Groups.Columns[0].Width := Round(w * 55 / 100);
  ListView_Groups.Columns[1].Width := w - ListView_Groups.Columns[0].Width;
end;

procedure TForm_GroupSelect.RefreshGroupList;
var
  g: PADGroup;
  i: Integer;
begin
  ListView_Groups.Items.Clear;
  FGroups.Clear;
  try
    case apAPI of
      ADC_API_LDAP: GetGroupList(LDAPBinding, FGroupList);
      ADC_API_ADSI: GetGroupList(ADSIBinding, FGroupList);
    end;

    for g in FGroupList do
    begin
      i := FBaseList.IndexOf(g^.primaryGroupToken);
      if i > -1 then
      begin
        g^.Selected := FBaseList[i]^.Selected;
        g^.IsMember := FBaseList[i]^.IsMember;
        g^.IsPrimary := FBaseList[i]^.IsPrimary;
      end;
    end;

    FGroupList.Sort(SortGropListByName);
    Edit_SearchChange(Self);
  except

  end;
end;

procedure TForm_GroupSelect.SetCallingForm(const Value: TForm);
begin
  FCallingForm := Value;
end;

procedure TForm_GroupSelect.SetBaseGroupList(const AGroupList: TADGroupList);
var
  src: PADGroup;
  dst: PADGroup;
begin
  FBaseList.Clear;

  for src in AGroupList do
  begin
    New(dst);
    dst^ := src^;
    FBaseList.Add(dst);
  end;

  RefreshGroupList;
end;

procedure TForm_GroupSelect.ToolButton_RefreshClick(Sender: TObject);
begin
  RefreshGroupList;
end;

procedure TForm_GroupSelect.ToolButton_SelectAllClick(Sender: TObject);
var
  g: PADGroup;
begin
  for g in FGroups do
    g^.Selected := True;

  ListView_Groups.Invalidate;
end;

procedure TForm_GroupSelect.ToolButton_SelectNoneClick(Sender: TObject);
var
  g: PADGroup;
begin
  for g in FGroups do
    if not g^.IsPrimary then g^.Selected := False;

  ListView_Groups.Invalidate;
end;

function TForm_GroupSelect._GroupType(AValue: Integer): Integer;
begin
  if AValue = -2147483640
    then Result := 8
      else if AValue = -2147483646
        then Result := 2
          else Result := AValue;
end;

end.
