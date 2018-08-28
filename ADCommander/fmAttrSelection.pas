unit fmAttrSelection;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  System.StrUtils, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls,
  Vcl.ComCtrls, ADC.Common, ADC.Types, ADC.GlobalVar, ADC.DC, System.ImageList,
  Vcl.ImgList, System.Types, Winapi.CommCtrl, Winapi.UxTheme, ADC.ImgProcessor,
  Vcl.ToolWin, Vcl.ExtCtrls;

type
  TComboBox = class(Vcl.StdCtrls.TComboBox)
  private
    procedure CN_DrawItem(var Message : TWMDrawItem); message CN_DRAWITEM;
  end;

type
  TForm_AttrSelect = class(TForm)
    ListView_Attributes: TListView;
    Button_Cancel: TButton;
    Button_OK: TButton;
    ComboBox_DC: TComboBox;
    ToolBar: TToolBar;
    ToolButton_Refresh: TToolButton;
    ToolButton2: TToolButton;
    ToolButton_ShowAll: TToolButton;
    ImageList_ToolBar: TImageList;
    ToolButton_ShowSuitable: TToolButton;
    Label_Search: TLabel;
    Edit_Search: TButtonedEdit;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure ListView_AttributesClick(Sender: TObject);
    procedure ListView_AttributesKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure Button_CancelClick(Sender: TObject);
    procedure Button_OKClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure ComboBox_DCSelect(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure ListView_AttributesData(Sender: TObject; Item: TListItem);
    procedure ListView_AttributesDrawItem(Sender: TCustomListView; Item: TListItem;
      Rect: TRect; State: TOwnerDrawState);
    procedure ComboBox_DCDrawItem(Control: TWinControl; Index: Integer;
      Rect: TRect; State: TOwnerDrawState);
    procedure ListView_AttributesResize(Sender: TObject);
    procedure ListView_AttributesMouseDown(Sender: TObject;
      Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure ToolButton_RefreshClick(Sender: TObject);
    procedure ToolButton_ShowAllClick(Sender: TObject);
    procedure ToolButton_ShowSuitableClick(Sender: TObject);
    procedure Edit_SearchChange(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure Edit_SearchRightButtonClick(Sender: TObject);
  private
    type
      PAttrItem = ^TAttrItem;
      TAttrItem = packed record
        Selected: Boolean;
        AttrName: string[255];
        AttrType: string[255];
        function IsType(const AType: string): Boolean;
      end;

    type
      TAttrItems = class(TList)
      private
        FOwnsObjects: Boolean;
        function Get(Index: Integer): PAttrItem;
      protected
        function Add(Value: PAttrItem): Integer;
        procedure Clear; override;
        property Items[Index: Integer]: PAttrItem read Get; default;
      public
        constructor Create(AOwnsObjects: Boolean = True); reintroduce;
        destructor Destroy; override;
        procedure SelectItem(AIndex: Integer);
        function SelectedIndex: Integer;
        property OwnsObjects: Boolean read FOwnsObjects write FOwnsObjects;
      end;

    const
      ATTR_ITEM_NOT_SELECTED          = 0;
      ATTR_ITEM_SELECTED              = 1;
      ATTR_ITEM_DISABLED_NOT_SELECTED = 2;
      ATTR_ITEM_DISABLED_SELECTED     = 3;
  private
    { Private declarations }
    FCallingForm: TForm;
    FSelectedAttr: string;
    FAttributes: TAttrItems;
    FAttributeList: TAttrItems;
    FOutputField: TEdit;
    FAttrType: string;
    FStateImages: TImageList;
    FListViewWndProc: TWndMethod;
    procedure ListViewWndProc(var Msg: TMessage);
    procedure FillAttributeList(AShowAll: Boolean);
    procedure SetOutputField(Fld: TEdit);
    procedure SetAttributeType(AAttrType: string);
    procedure SetCallingForm(const Value: TForm);
    procedure ClearFields;
  public
    { Public declarations }
    property OutputField: TEdit read FOutputField write SetOutputField;
    property AttributeType: string read FAttrType write SetAttributeType;
    property CallingForm: TForm write SetCallingForm;
  end;

var
  Form_AttrSelect: TForm_AttrSelect;

implementation

{$R *.dfm}

procedure TForm_AttrSelect.Button_CancelClick(Sender: TObject);
begin
  Close;
end;

procedure TForm_AttrSelect.Button_OKClick(Sender: TObject);
begin
  FOutputField.Text := FSelectedAttr;
  Close;
end;

procedure TForm_AttrSelect.ClearFields;
begin
  FAttrType := ATTR_TYPE_ANY;
  FSelectedAttr := '';
  ComboBox_DC.Clear;
  ListView_Attributes.Clear;
  FAttributes.Clear;
  FAttributeList.Clear;
  Edit_Search.Clear;
end;

procedure TForm_AttrSelect.ComboBox_DCDrawItem(Control: TWinControl;
  Index: Integer; Rect: TRect; State: TOwnerDrawState);
const
  _margin: Integer = 6;
var
  Columns: TStringDynArray;
  ColCount: Integer;
  ItemText: string;
  C: TCanvas;
//  DC: HDC;
  DrawRect: TRect;
  DeviderPos: Integer;
  TextWidth: Integer;
begin
  DeviderPos := 0;
  { Вычисляем положение отрисовки разделителя }
  if odComboBoxEdit in State then
  begin
    Columns := SplitString(ComboBox_DC.Items[Index], '|');
    DeviderPos := GetTextWidthInPixels(Columns[0], ComboBox_DC.Font) + 6;
  end
  else for ItemText in ComboBox_DC.Items do
  begin
    Columns := SplitString(ItemText, '|');
    if Length(Columns) > 0 then
    begin
      TextWidth := GetTextWidthInPixels(Columns[0], ComboBox_DC.Font);
      if DeviderPos < TextWidth
        then DeviderPos := TextWidth;
    end;
  end;
  DeviderPos := DeviderPos + _margin * 2;

  ItemText := ComboBox_DC.Items[Index];
  Columns := SplitString(ItemText, '|');
  ColCount := Length(Columns);
//  DC := ComboBox_DC.Canvas.Handle;
  C := ComboBox_DC.Canvas;
  if ( odSelected in State ) or ( odFocused in State ) then
  begin
     C.Brush.Color := clHighlight;
     C.Pen.Color := clHighlightText;
  end else
  begin
    C.Brush.Color := clWhite;
    C.Pen.Color := clSilver;
  end;
  C.FillRect(Rect);

  { Рисуем разделитель }
  C.Pen.Width := 1;
  C.MoveTo(DeviderPos, Rect.Top);
  C.LineTo(DeviderPos, Rect.Bottom);

  { Выводим имя домена в фромате DNS }
  if ColCount > 0 then begin
    DrawRect := Rect;
    OffsetRect(DrawRect, _margin, 1);
    if DeviderPos - _margin < Rect.Right
      then DrawRect.Right := DeviderPos - _margin
      else DrawRect.Right := Rect.Right;
    with C.Font do
    begin
      Style := C.Font.Style + [fsBold];
      if ( odSelected in State ) or ( odFocused in State )
        then Color := clHighlightText
        else Color := clWindowText;
    end;
    C.TextRect(DrawRect, Columns[0], [tfLeft, tfEndEllipsis]);
  end;

  { Выводим имя домена контроллера домена }
  if ColCount > 1 then begin
    DrawRect := Rect;
    OffsetRect(DrawRect, DeviderPos + _margin, 1);
    DrawRect.Right := Rect.Right;
    with C.Font do
    begin
      Style := C.Font.Style - [fsBold];
      if ( odSelected in State ) or ( odFocused in State )
        then Color := clHighlightText
        else Color := COLOR_GRAY_TEXT;
    end;
    C.TextRect(DrawRect, Columns[1], [tfEndEllipsis]);
  end;
end;

procedure TForm_AttrSelect.ComboBox_DCSelect(Sender: TObject);
begin
  ToolButton_RefreshClick(Self);
end;

procedure TForm_AttrSelect.Edit_SearchChange(Sender: TObject);
var
  a: PAttrItem;
begin
  Edit_Search.RightButton.Visible := Edit_Search.Text <> '';

  ListView_Attributes.Clear;
  FAttributes.Clear;
  if Edit_Search.Text = '' then
  begin
    for a in FAttributeList do
      FAttributes.Add(a);
  end else
  for a in FAttributeList do
  begin
    if ContainsText(a^.AttrName, Edit_Search.Text)
      then FAttributes.Add(a);
  end;

  ListView_Attributes.Items.Count := FAttributes.Count;
end;

procedure TForm_AttrSelect.Edit_SearchRightButtonClick(Sender: TObject);
begin
  Edit_Search.Clear;
end;

procedure TForm_AttrSelect.FillAttributeList(AShowAll: Boolean);
var
  src: TStringList;
  i: Integer;
  s: string;
  attr: PAttrItem;
begin
  ListView_Attributes.Items.Clear;
  FSelectedAttr := FOutputField.Text;
  FAttributes.Clear;
  FAttributeList.Clear;

  try
    src := TDCInfo(ComboBox_DC.Items.Objects[ComboBox_DC.ItemIndex]).UserAttributes;
  except
    Exit;
  end;

  for i := 0 to src.Count - 1 do
  begin
    if (AShowAll) or (AnsiLowerCase(src[i]).Contains(AnsiLowerCase(FAttrType))) then
    begin
//      GetMem(attr, SizeOf(TAttrItem));
      New(attr);
      attr^.Selected := CompareText(src.Names[i], FSelectedAttr) = 0;
      attr^.AttrName := src.Names[i];
      attr^.AttrType := src.ValueFromIndex[i];
      FAttributeList.Add(attr);
    end;
    Application.ProcessMessages;
  end;

  Edit_SearchChange(Self);
end;

procedure TForm_AttrSelect.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  ClearFields;

  if FCallingForm <> nil then
  begin
    FCallingForm.Enabled := True;
    FCallingForm.Show;
    FCallingForm := nil;
  end;
end;

procedure TForm_AttrSelect.FormCreate(Sender: TObject);
begin
  FStateImages := TImageList.Create(Self);
  FStateImages.ColorDepth := cd32Bit;

  TImgProcessor.GetThemeButtons(
    Self.Handle,
    ListView_Attributes.Canvas.Handle,
    BP_RADIOBUTTON,
    ListView_Attributes.Color,
    FStateImages
  );

  ListView_Attributes.StateImages := FStateImages;
  FListViewWndProc := ListView_Attributes.WindowProc;
  ListView_Attributes.WindowProc := ListViewWndProc;

  FAttributeList := TAttrItems.Create;
  FAttributes := TAttrItems.Create(False);
end;

procedure TForm_AttrSelect.FormDestroy(Sender: TObject);
begin
  FAttributes.Free;
  FAttributeList.Free;
  FStateImages.Free;
end;

procedure TForm_AttrSelect.FormKeyDown(Sender: TObject; var Key: Word;
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

procedure TForm_AttrSelect.FormShow(Sender: TObject);
var
  R: TRect;
begin
  if FAttributes.SelectedIndex = -1 then Exit;

  if ListView_IsItemVisible(ListView_Attributes.Handle, FAttributes.SelectedIndex) = 0 then
  begin
    R := ListView_Attributes.Items[FAttributes.SelectedIndex].DisplayRect(drBounds);
    ListView_Attributes.Scroll(0, R.Top - ListView_Attributes.ClientHeight div 2);
  end;
end;

procedure TForm_AttrSelect.ListViewWndProc(var Msg: TMessage);
begin
  ShowScrollBar(ListView_Attributes.Handle, SB_HORZ, False);
  FListViewWndProc(Msg);
end;

procedure TForm_AttrSelect.ListView_AttributesClick(Sender: TObject);
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
  lvCursosPos := ListView_Attributes.ScreenToClient(Mouse.CursorPos) ;
  //click where?
  hts := ListView_Attributes.GetHitTestInfoAt(lvCursosPos.X, lvCursosPos.Y);
  //locate the state-clicked item
  if htOnItem in hts then
  begin
    li := ListView_Attributes.GetItemAt(lvCursosPos.X, lvCursosPos.Y);
    if li <> nil then
    begin
      ListView_GetItemRect(ListView_Attributes.Handle, li.Index, R, LVIR_BOUNDS);
      { Величины R.Width и R.Offset см. в отрисовке значка состояния атрибута }
      { в процедуре ListView_AttributesDrawItem                               }
      R.Width := 16;
      R.Offset(6, 0);
      if PtInRect(R, lvCursosPos)
        then ListView_AttributesKeyDown(ListView_Attributes, Key, []);
    end;
  end;
end;

procedure TForm_AttrSelect.ListView_AttributesData(Sender: TObject; Item: TListItem);
var
  attr: TAttrItem;
begin
  attr := FAttributes[Item.Index]^;
  Item.Caption := attr.AttrName;
  Item.SubItems.Add(attr.AttrType);
  if attr.IsType(FAttrType) then
  begin
    if attr.Selected
      then Item.StateIndex := ATTR_ITEM_SELECTED
      else Item.StateIndex := ATTR_ITEM_NOT_SELECTED
  end
  else Item.StateIndex := ATTR_ITEM_DISABLED_NOT_SELECTED
end;

procedure TForm_AttrSelect.ListView_AttributesDrawItem(Sender: TCustomListView;
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

  if (odSelected in State) or (FAttributes[Item.Index].Selected)
    then C.Brush.Color := IncreaseBrightness(COLOR_SELBORDER, 95);
  C.FillRect(Rect);

  { Выводим значек состояния атрибута }
  R := Rect;
  R.Width := 16;
  R.Offset(5, 0);
  ListView_Attributes.StateImages.Draw(c, R.TopLeft.X, R.TopLeft.Y, Item.StateIndex);

  { Выводим имя атрибута }
  if not FAttributes[Item.Index].IsType(FAttrType)
    then C.Font.Color := clGrayText;

  R := Rect;
  R.Right := R.Left + Sender.Column[0].Width;
  R.Inflate(-6, 0);
  if FAttributes[Item.Index]^.Selected then
  begin
    C.Font.Style := [fsBold];
  end;
  C.Refresh;
  R.Width := R.Width - 22;
  R.Offset(22, 0);
  S := Item.Caption;
  DrawText(
    C.Handle,
    S,
    Length(S),
    R,
    DT_LEFT or DT_VCENTER or DT_SINGLELINE or DT_END_ELLIPSIS
  );

  { Выводим тип данных атрибуда }
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

procedure TForm_AttrSelect.ListView_AttributesKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
var
  li: TListItem;
begin
  case Key of
    VK_SPACE: begin
      li := ListView_Attributes.Selected;
      if (li <> nil)
        then if FAttributes[li.Index].IsType(FAttrType)
          then FAttributes.SelectItem(li.Index);

      FSelectedAttr := FAttributes[FAttributes.SelectedIndex].AttrName;
      ListView_Attributes.Invalidate;
    end;
  end;
end;

procedure TForm_AttrSelect.ListView_AttributesMouseDown(Sender: TObject;
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
    HitPoint := ListView_Attributes.ScreenToClient(Mouse.Cursorpos);
    FillChar(HitInfo, SizeOf(TLVHitTestInfo), 0);
    HitInfo.pt := HitPoint;
    MsgRes := ListView_Attributes.Perform(LVM_SUBITEMHITTEST, 0, LPARAM(@HitInfo));
    if MsgRes <> -1 then
    begin
      ListView_Attributes.Selected := ListView_Attributes.Items[HitInfo.iItem];
      k := VK_SPACE;
      ListView_AttributesKeyDown(Sender, k, []);
    end;
  end;
end;

procedure TForm_AttrSelect.ListView_AttributesResize(Sender: TObject);
var
  w: Integer;
begin
  w := ListView_Attributes.ClientWidth;
  ListView_Attributes.Columns[0].Width := Round(w * 65 / 100);
  ListView_Attributes.Columns[1].Width := w - ListView_Attributes.Columns[0].Width;
end;

procedure TForm_AttrSelect.SetAttributeType(AAttrType: string);
begin
  ToolButton_ShowSuitable.Down := AAttrType <> ATTR_TYPE_ANY;
  with ToolButton_ShowAll do
  begin
    Enabled := not (AAttrType = ATTR_TYPE_ANY);
    Down := AAttrType = ATTR_TYPE_ANY;
  end;
  ToolButton_ShowSuitable.Enabled := ToolButton_ShowAll.Enabled;
  FAttrType := AAttrType;
  FillAttributeList((FAttrType = ATTR_TYPE_ANY) or (ToolButton_ShowAll.Down));
end;

procedure TForm_AttrSelect.SetCallingForm(const Value: TForm);
begin
  FCallingForm := Value;
end;

procedure TForm_AttrSelect.SetOutputField(Fld: TEdit);
begin
  FOutputField := Fld;
  FSelectedAttr := Fld.Text;
end;

procedure TForm_AttrSelect.ToolButton_RefreshClick(Sender: TObject);
begin
//  TDCInfo(ComboBox_DC.Items.Objects[ComboBox_DC.ItemIndex]).RefreshData;
  FillAttributeList((FAttrType = ATTR_TYPE_ANY) or (ToolButton_ShowAll.Down));
  OnShow(Self);
end;

procedure TForm_AttrSelect.ToolButton_ShowAllClick(Sender: TObject);
begin
  ToolButton_RefreshClick(Self);
end;

procedure TForm_AttrSelect.ToolButton_ShowSuitableClick(Sender: TObject);
begin
  ToolButton_RefreshClick(Self);
end;

{ TForm_AttrSelect.TAttrItems }

function TForm_AttrSelect.TAttrItems.Add(Value: PAttrItem): Integer;
begin
 Result := inherited Add(Value);
end;

procedure TForm_AttrSelect.TAttrItems.Clear;
var
  i: Integer;
begin
  if FOwnsObjects
    then for i := Self.Count - 1 downto 0 do
      Dispose(Self.Items[i]);

  inherited;
end;


constructor TForm_AttrSelect.TAttrItems.Create(AOwnsObjects: Boolean);
begin
  inherited Create;

  FOwnsObjects := AOwnsObjects;
end;

destructor TForm_AttrSelect.TAttrItems.Destroy;
begin

  inherited;
end;

function TForm_AttrSelect.TAttrItems.Get(Index: Integer): PAttrItem;
begin
  Result := PAttrItem(inherited Get(Index));
end;

function TForm_AttrSelect.TAttrItems.SelectedIndex: Integer;
var
  i: Integer;
begin
  Result := -1;

  for i := 0 to Self.Count - 1 do
    if Self[i]^.Selected then
    begin
      Result := i;
      Break;
    end;
end;

procedure TForm_AttrSelect.TAttrItems.SelectItem(AIndex: Integer);
var
  i: Integer;
begin
  if not Self[AIndex]^.Selected then
  for i:= 0 to Self.Count - 1 do
    Self.Items[i]^.Selected := i = AIndex;
end;

{ TForm_AttrSelect.TAttrItem }

function TForm_AttrSelect.TAttrItem.IsType(const AType: string): Boolean;
begin
  Result := (CompareText(AttrType, AType) = 0) or (CompareText(AType, ATTR_TYPE_ANY) = 0)
end;

{ TComboBox }

procedure TComboBox.CN_DrawItem(var Message: TWMDrawItem);
begin
  with Message do
    DrawItemStruct.itemState := DrawItemStruct.itemState and not ODS_FOCUS;

  inherited;
end;

end.
