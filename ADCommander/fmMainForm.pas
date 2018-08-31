unit fmMainForm;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  System.Types, System.StrUtils, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  Vcl.ExtCtrls, Vcl.ComCtrls, Vcl.StdCtrls, Vcl.ToolWin, Winapi.CommCtrl, Winapi.ActiveX,
  System.Generics.Collections, System.TypInfo, System.Actions, Vcl.ActnMan, Vcl.ActnCtrls,
  Vcl.Menus, Vcl.ActnList, Vcl.PlatformDefaultStyleActnCtrls, Vcl.StdStyleActnCtrls,
  Vcl.XPStyleActnCtrls, Vcl.CustomizeDlg, Vcl.ActnMenus, Winapi.UxTheme, System.UITypes,
  System.AnsiStrings, frSearch, tdLDAPEnum, tdADSIEnum, ActiveDs_TLB, JvCipher, ADC.LDAP,
  ADC.Types, ADC.DC, ADC.Attributes, ADC.Common, ADC.GlobalVar, ADC.ADObject,
  ADC.ADObjectList, ADC.ScriptBtn, System.IniFiles, System.RegularExpressions, Vcl.Themes,
  Winapi.ShlObj, System.SyncObjs, System.Win.ComObj, tdDataExport, fmFloatingWindow;

const
  { Контекстное меню   }
  MENU_REFRESH             = 0;
  {----------------        = 1}
  MENU_DAMEWARE            = 2;
  MENU_SEND_MESSAGE        = 3;
  MENU_PING                = 4;
  MENU_COMPUTER_INFO       = 5;
  MENU_COMPUTER_MANAGEMENT = 6;
  {----------------        = 7}
  MENU_RENAME              = 8;
  MENU_DISABLE_ACC         = 9;
  MENU_CHANGE_PWD          = 10;
  MENU_REMOVE_ACC          = 11;
  MENU_DELETE_ACC          = 12;
  {----------------        = 13}
  MENU_PROPERTIES          = 14;

type
  TInPlaceEdit = class(Vcl.StdCtrls.TEdit)
  private
    FItemIndex: Integer;
    FSubItemIndex: Integer;
    procedure WMNCPaint(var Msg: TMessage); message WM_NCPAINT;
  protected
    procedure KeyDown(var Key: Word; Shift: TShiftState); override;
  public
    procedure Clear; override;
    property ItemIndex: Integer read FItemIndex write FItemIndex;
    property SubItemIndex: Integer read FSubItemIndex write FSubItemIndex;
  end;

type
  TMenuItemEx = class(TMenuItem)
  private
     FData: Pointer;
  public
    property Data: Pointer read FData write FData;
  end;

type
  TSplitter = class(Vcl.ExtCtrls.TSplitter)
    protected
      procedure WndProc(var Message: TMessage); override;
  end;

type
  TStatusBar = class(Vcl.ComCtrls.TStatusBar)
    protected
      procedure CreateParams(var Params: TCreateParams); override;
  end;

type
  TComboBox = class(Vcl.StdCtrls.TComboBox)
  private
    procedure CN_DrawItem(var Message : TWMDrawItem); message CN_DRAWITEM;
  end;

type
  TADCmd_MainForm = class(TForm)
    StatusBar: TStatusBar;
    Panel_DC: Vcl.ExtCtrls.TPanel;
    Splitter: TSplitter;
    Panel_Accounts: Vcl.ExtCtrls.TPanel;
    Panel_DCTop: Vcl.ExtCtrls.TPanel;
    TreeView_AD: TTreeView;
    ComboBox_DC: TComboBox;
    Panel_AccountsTop: Vcl.ExtCtrls.TPanel;
    ListView_Accounts: TListView;
    Panel_AccountsBottom: Vcl.ExtCtrls.TPanel;
    Label_ADPath: TLabel;
    Panel_DCBottom: Vcl.ExtCtrls.TPanel;
    PopupMenu_TreeAD: TPopupMenu;
    N1: TMenuItem;
    ActionManager_Main: TActionManager;
    Action_DCList_Refresh: TAction;
    Action_DCList_Expand_All: TAction;
    Action_DCList_Collapse_All: TAction;
    Action_AccList_Refresh: TAction;
    PopupMenu_ListAcc: TPopupMenu;
    ActionToolBar_DC: TActionToolBar;
    ActionToolBar_Acc: TActionToolBar;
    Frame_Search: TFrame_Search;
    Action_Settings: TAction;
    Action_Properties: TAction;
    Object_PwdReset: TMenuItem;
    ObjListRefresh: TMenuItem;
    N6: TMenuItem;
    DameWare: TMenuItem;
    QuickMessage: TMenuItem;
    Ping: TMenuItem;
    N10: TMenuItem;
    Object_Rename: TMenuItem;
    Object_Disable: TMenuItem;
    Object_Move: TMenuItem;
    Object_Delete: TMenuItem;
    N15: TMenuItem;
    Object_Properties: TMenuItem;
    DMRC_Control: TMenuItem;
    DMRC_View: TMenuItem;
    N17: TMenuItem;
    DMRC_Custom: TMenuItem;
    Action_ShowUsers: TAction;
    Action_ShowGroups: TAction;
    Action_ShowWorkstations: TAction;
    Action_ShowDC: TAction;
    Action_CreateUser: TAction;
    ComputerManagement: TMenuItem;
    N2: TMenuItem;
    Action_Export_Access: TAction;
    Action_Export_Excel: TAction;
    N3: TMenuItem;
    N4: TMenuItem;
    Action_CreateOU: TAction;
    procedure ComboBox_DCSelect(Sender: TObject);
    procedure SplitterPaint(Sender: TObject);
    procedure ComboBox_DCDrawItem(Control: TWinControl; Index: Integer;
      Rect: TRect; State: TOwnerDrawState);
    procedure TreeView_ADCollapsing(Sender: TObject; Node: TTreeNode;
      var AllowCollapse: Boolean);
    procedure FormCreate(Sender: TObject);
    procedure Action_DCList_RefreshExecute(Sender: TObject);
    procedure Action_DCList_Expand_AllExecute(Sender: TObject);
    procedure Action_DCList_Collapse_AllExecute(Sender: TObject);
    procedure TreeView_ADKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure TreeView_ADChange(Sender: TObject; Node: TTreeNode);
    procedure TreeView_ADMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure FormDestroy(Sender: TObject);
    procedure Action_AccList_RefreshExecute(Sender: TObject);
    procedure ListView_AccountsData(Sender: TObject; Item: TListItem);
    procedure FormShow(Sender: TObject);
    procedure Action_SettingsExecute(Sender: TObject);
    procedure Action_PropertiesExecute(Sender: TObject);
    procedure TreeView_ADDeletion(Sender: TObject; Node: TTreeNode);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure ListView_AccountsColumnDragged(Sender: TObject);
    procedure ListView_AccountsDrawItem(Sender: TCustomListView;
      Item: TListItem; Rect: TRect; State: TOwnerDrawState);
    procedure ListView_AccountsColumnClick(Sender: TObject;
      Column: TListColumn);
    procedure Panel_DCBottomClick(Sender: TObject);
    procedure Frame_SearchEdit_SearchPatternChange(Sender: TObject);
    procedure Frame_SearchComboBox_SearchOptionSelect(Sender: TObject);
    procedure ListView_AccountsMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure ListView_AccountsCustomDraw(Sender: TCustomListView;
      const [Ref] ARect: TRect; var DefaultDraw: Boolean);
    procedure ListView_AccountsKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure PopupMenu_ListAccPopup(Sender: TObject);
    procedure Object_PwdResetClick(Sender: TObject);
    procedure PingClick(Sender: TObject);
    procedure DMRC_ControlClick(Sender: TObject);
    procedure DMRC_ViewClick(Sender: TObject);
    procedure DMRC_CustomClick(Sender: TObject);
    procedure Action_ShowUsersExecute(Sender: TObject);
    procedure Action_ShowGroupsExecute(Sender: TObject);
    procedure Action_ShowWorkstationsExecute(Sender: TObject);
    procedure Action_ShowDCExecute(Sender: TObject);
    procedure Object_DisableClick(Sender: TObject);
    procedure Object_RenameClick(Sender: TObject);
    procedure Object_MoveClick(Sender: TObject);
    procedure Object_DeleteClick(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure Action_CreateUserExecute(Sender: TObject);
    procedure QuickMessageClick(Sender: TObject);
    procedure StatusBarDrawPanel(StatusBar: TStatusBar; Panel: TStatusPanel;
      const Rect: TRect);
    procedure FormResize(Sender: TObject);
    procedure ListView_AccountsChange(Sender: TObject; Item: TListItem;
      Change: TItemChange);
    procedure ComputerManagementClick(Sender: TObject);
    procedure N2Click(Sender: TObject);
    procedure Action_Export_AccessExecute(Sender: TObject);
    procedure Action_Export_ExcelExecute(Sender: TObject);
    procedure Action_CreateOUExecute(Sender: TObject);
  protected
    FAccountListWndProc: TWndMethod;
    procedure WndProc(var Message: TMessage); override;
    procedure WndProc_ListView_Accounts(var Message: TMessage);
  private
    FInPlaceEdit: TInPlaceEdit;
    FProgressBar: TProgressBar;
    FFloatingWindow: TForm_FloatingWindow;
    function GetJokeAppTitle: string;
    function GetCurrentUserName: string;
    function GetHostDomainName: string;
    function CheckDameWareConfig: Boolean;
    function CheckPsExecConfig: Boolean;
    procedure ClearList_Accounts;
    procedure ClearStatusBar;
    procedure LoadLastFormState(AIniFile: TFileName);
    procedure SaveLastFormState(AIniFile: TFileName);
    procedure EnumerateObjects;
    procedure ArrangeColumns(AAttrCat: TAttrCatalog);
    procedure SetInfoColumnWidth;
    procedure AllignStatusBarPanels;
    procedure SetComboBoxDropDownWidth(AComboBox: TComboBox; AMargin: Word = 0);
    procedure ExecuteDataExport(AFormat: TADExportFormat; AFileName: TFileName);
    procedure OnInPlaceEditExit(Sender: TObject);
    procedure OnEnumerationProgress(AItem: TObject; AProgress: Integer);
    procedure OnEnumerationException(AMsg: string; ACode: ULONG);
    procedure OnEnumerationComplete(Sender: TObject);
    procedure OnAttrCatalogSave(Sender: TObject);
    procedure OnObjListNotify(Sender: TObject; const Item: TADObject; Action: TCollectionNotification);
    procedure OnObjListSort(Sender: TObject);
    procedure OnObjListFilter(Sender: TObject);
    procedure OnADObjectRefresh(Sender: TObject);
    procedure OnSettingsApply(Sender: TObject);
    procedure OnTargetContainerSelect(Sender: TObject; ACont: TADContainer);
    procedure OnMenuItem_CreateUser(Sender: TObject);
    procedure OnMenuItem_CreateContainer(Sender: TObject);
    procedure OnMenuItem_DeleteContainer(Sender: TObject);
    procedure OnUserCreate(Sender: TObject; AOpenEditor: Boolean);
    procedure OnUserChange(Sender: TObject);
    procedure OnComputerChange(Sender: TObject);
    procedure OnPasswordChange(Sender: TObject; AChangeOnLogon: Boolean);
    procedure OnOrganizationalUnitCreate(ANewDN: string);
  public
    { Public declarations }
    procedure UpdateDCList;
    procedure DrawSortedColumnHeader;
  end;

var
  ADCmd_MainForm: TADCmd_MainForm;

implementation

uses dmDataModule, fmSettings, fmPasswordReset, fmDameWare, fmComputerInfo,
  fmGroupInfo, fmRename, fmContainerSelection, fmCreateUser, fmUserInfo,
  fmQuickMessage, fmWorkstationInfo, fmCreateContainer;

{$R *.dfm}

{ TSplitter }

procedure TSplitter.WndProc(var Message: TMessage);
var
  i: Integer;
  MinWidth: Integer;
  Node: TTreeNode;
begin
  inherited;
  case Message.Msg of
    WM_LBUTTONDBLCLK: begin
      MinWidth := 0;
      for i := 0 to ADCmd_MainForm.TreeView_AD.Items.Count - 1 do
      begin
        Node := ADCmd_MainForm.TreeView_AD.Items[i];
        if (Node.IsVisible) and (Node.DisplayRect(True).Right > MinWidth)
          then MinWidth := Node.DisplayRect(True).Right;
      end;
      MinWidth := MinWidth + GetSystemMetrics(SM_CXEDGE);
      { Проверяем отображается ли вертикальная полоса прокрутки }
      if GetWindowLong(ADCmd_MainForm.TreeView_AD.Handle, GWL_STYLE) and WS_VSCROLL <> 0
        then MinWidth := MinWidth + GetSystemMetrics(SM_CYVSCROLL);

      if MinWidth < Self.MinSize
        then MinWidth := Self.MinSize;
      ADCmd_MainForm.Panel_DC.Width := MinWidth;
    end;
  end;
end;

{ TStatusBar }

procedure TStatusBar.CreateParams(var Params: TCreateParams);
begin
  inherited;

end;

procedure TADCmd_MainForm.WndProc_ListView_Accounts(var Message: TMessage);
var
  msgNotify: TWMNotify absolute Message;
  msgDrawItem: TWMDrawItem absolute Message;
  msgNotifyHC: TWMNotifyHC absolute Message;
  colID: Integer;
  attrID: Integer;
  lpdis: PDrawItemStruct;
  colHDC: HDC;
  R: TRect;
  P: TPoint;
  li : TLIstItem;
  o: TADObject;
begin
  FAccountListWndProc(Message);

  case Message.Msg of
    WM_DRAWITEM: begin
      lpdis := msgDrawItem.DrawItemStruct;

      colHDC := lpdis^.hDC;
      R      := lpdis^.rcItem;

      { Вытягиваем DC_BRUSH и DC_PEN }
      SelectObject(colHDC, GetStockObject(DC_BRUSH));
      SelectObject(colHDC, GetStockObject(DC_PEN));

      if lpdis^.itemID = 0 then
      begin
        { Закрашиваем фон }
        SetDCBrushColor(colHDC, ColorToRGB(clBtnFace));
        SetDCPenColor(colHDC, ColorToRGB(clBtnFace));
        Rectangle(colHDC, R.TopLeft.X, R.TopLeft.Y, R.BottomRight.X, R.BottomRight.Y);

        { Отрисовываем полосу сверху }
        SetDCPenColor(colHDC, ColorToRGB(ListView_Accounts.Color));
        MoveToEx(colHDC, 0, 0, nil);
        LineTo(colHDC, R.Width, 0);

        msgDrawItem.Result := CDRF_SKIPDEFAULT;
      end else
      begin
//        { Закрашиваем фон }
//        SetDCBrushColor(colHDC, ColorToRGB(IncreaseBrightness(COLOR_SELBORDER, 90)));
//        SetDCPenColor(colHDC, ColorToRGB(clBtnFace));
//        Rectangle(colHDC, R.TopLeft.X, R.TopLeft.Y, R.BottomRight.X, R.BottomRight.Y);
//
//        msgDrawItem.Result := CDRF_SKIPDEFAULT;
      end;
    end;

    WM_NOTIFY: begin
      case PHDNotify(msgNotify.NMHdr)^.Hdr.Code of
        HDN_BEGINDRAG: begin

        end;

        HDN_ENDDRAG: begin
          colID := PHDNotify(msgNotify.NMHdr)^.Item;
          if colID = 0
            then msgNotifyHC.HDNotify^.PItem^.iOrder := 0
            else if msgNotifyHC.HDNotify^.PItem^.iOrder = 0
              then msgNotifyHC.HDNotify^.PItem^.iOrder := 1
        end;

        HDN_BEGINTRACK, HDN_BEGINTRACKA: begin
          FInPlaceEdit.Hide;
        end;

        HDN_ENDTRACK, HDN_ENDTRACKA: begin
          colID := PHDNotify(msgNotify.NMHdr)^.Item;

          if colID > 0 then
          begin
            attrID := ListView_Accounts.Columns[colID].Tag;
            List_Attributes.ItemByID(attrID)^.Width := PHDNotify(msgNotify.NMHdr)^.PItem^.cxy;
            List_Attributes.SaveToFile(FileName_AttrCat);
          end;

          DrawSortedColumnHeader;
        end;

        HDN_ITEMCHANGED, HDN_ITEMCHANGEDA: begin

        end;

        HDN_TRACK, HDN_TRACKA, HDN_ITEMCHANGING, HDN_ITEMCHANGINGA: begin
//          colWidth := -1;
//          if (PHDNotify(msgNotify.NMHdr)^.PItem <> nil)
//          and (PHDNotify(msgNotify.NMHdr)^.PItem^.Mask and HDI_WIDTH <> 0)
//            then colWidth := PHDNotify(msgNotify.NMHdr)^.PItem^.cxy;
//          DoColumnResizing(PHDNotify(msgNotify.NMHdr)^.Item, vColWidth);
        end;
      end;

    end;

    WM_MOUSEMOVE: begin
      if apFWND_Display then
      try
        P := ListView_Accounts.ScreenToClient(Mouse.CursorPos);
        li := ListView_Accounts.GetItemAt(P.X, P.Y);

        if li = nil
          then raise Exception.Create('No items found');

        o := List_Obj[li.Index];

        if not o.IsUser
          then raise Exception.Create('Object is not a user');

        if Self.Active
          then FFloatingWindow.Show(o);
      except
        FFloatingWindow.Hide(True);
      end;
    end;

    WM_MOUSEWHEEL: begin
      FFloatingWindow.Hide(True);
    end;

    WM_MOUSELEAVE: begin
      FFloatingWindow.Hide(True);
    end;

    WM_VSCROLLCLIPBOARD: begin
      FFloatingWindow.Hide(True);
    end;

    WM_KEYDOWN: begin
      if Message.WParam in [VK_UP, VK_DOWN, VK_PRIOR, VK_NEXT, VK_END, VK_HOME]
        then FFloatingWindow.Hide(True);
    end;
  end;
end;

procedure TADCmd_MainForm.Action_SettingsExecute(Sender: TObject);
begin
  with Form_Settings do
  begin
    OnSettingsApply := Self.OnSettingsApply;
    BuildAttributeCatalog(SelectedDC);
    Position := poMainFormCenter;
    Show;
    OpenSettingsMenu(SETTINGS_MENU_GENERAL);
    CallingForm := Self;
  end;
end;

procedure TADCmd_MainForm.Action_ShowWorkstationsExecute(Sender: TObject);
begin
  if Action_ShowWorkstations.Checked
    then apFilterObjects := apFilterObjects or FILTER_OBJECT_WORKSTATION
    else apFilterObjects := apFilterObjects xor FILTER_OBJECT_WORKSTATION;

  List_ObjFull.Filter.Objects := apFilterObjects;
end;

procedure TADCmd_MainForm.Action_ShowDCExecute(Sender: TObject);
begin
  if Action_ShowDC.Checked
    then apFilterObjects := apFilterObjects or FILTER_OBJECT_DC
    else apFilterObjects := apFilterObjects xor FILTER_OBJECT_DC;

  List_ObjFull.Filter.Objects := apFilterObjects;
end;

procedure TADCmd_MainForm.Action_ShowGroupsExecute(Sender: TObject);
begin
  if Action_ShowGroups.Checked
    then apFilterObjects := apFilterObjects or FILTER_OBJECT_GROUP
    else apFilterObjects := apFilterObjects xor FILTER_OBJECT_GROUP;

  List_ObjFull.Filter.Objects := apFilterObjects;
end;

procedure TADCmd_MainForm.Action_ShowUsersExecute(Sender: TObject);
begin
  if Action_ShowUsers.Checked
    then apFilterObjects := apFilterObjects or FILTER_OBJECT_USER
    else apFilterObjects := apFilterObjects xor FILTER_OBJECT_USER;

  List_ObjFull.Filter.Objects := apFilterObjects;
end;

procedure TADCmd_MainForm.Action_PropertiesExecute(Sender: TObject);
var
  obj: TADObject;
begin
  if ListView_Accounts.Selected = nil
    then Exit;

  obj := List_Obj[ListView_Accounts.Selected.Index];
  case obj.ObjectType of
    otWorkstation, otDomainController, otRODomainController: begin
      with Form_ComputerInfo do
      begin
        ComputerObject := obj;
        OnComputerChange := Self.OnComputerChange;
        Position := poMainFormCenter;
        Show;
        CallingForm := Self;
      end;
    end;

    otUser: begin
      with Form_UserInfo do
      begin
        UserObject := obj;
        OnUserChange := Self.OnUserChange;
        Position := poMainFormCenter;
        Show;
        CallingForm := Self;
      end;
    end;

    otGroup: begin
      with Form_GroupInfo do
      begin
        GroupObject := obj;
        Position := poMainFormCenter;
        Show;
        CallingForm := Self;
      end;
    end;
  end;
end;

procedure TADCmd_MainForm.Action_AccList_RefreshExecute(Sender: TObject);
var
  res: DWORD;
  h: PHANDLE;
  MsgBoxParam: TMsgBoxParams;
begin
  try
    if SelectedDC = nil
      then raise Exception.Create('Не указан контроллер домена.');

    { Проверяем доступность контроллера домена }
    res := DsBind(PChar(SelectedDC.Name), nil, h);
    DsUnBind(h);

    { Если контроллер домена недоступен, то выходим }
    if res <> ERROR_SUCCESS
      then raise Exception.Create(SysErrorMessage(res));

    { Если контроллер домена доступен, то ищем объекты }
    EnumerateObjects;
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
        dwStyle := MB_OK or MB_ICONERROR;
        dwContextHelpId := 0;
        lpfnMsgBoxCallback := nil;
        dwLanguageId := LANG_NEUTRAL;
        MsgBoxParam.lpszText := PChar(E.Message);
      end;

      MessageBoxIndirect(MsgBoxParam);
    end;
  end;
end;

procedure TADCmd_MainForm.Action_CreateOUExecute(Sender: TObject);
begin
  OnMenuItem_CreateContainer(Self);
end;

procedure TADCmd_MainForm.Action_CreateUserExecute(Sender: TObject);
begin
  Form_CreateUser.CallingForm := Self;
  Form_CreateUser.DomainController := SelectedDC;
  if Sender is TMenuItemEx
    then if Assigned(TMenuItemEx(Sender).Data)
      then Form_CreateUser.Container := PADContainer(TMenuItemEx(Sender).Data)^;
  Form_CreateUser.OnUserCreate := Self.OnUserCreate;
  Form_CreateUser.Position := poMainFormCenter;
  Form_CreateUser.Show;
  Self.Enabled := False;
end;

procedure TADCmd_MainForm.Action_DCList_Collapse_AllExecute(Sender: TObject);
begin
  with TreeView_AD do
  begin
    FullCollapse;
    if Items.Count > 0 then TopItem.Expand(False);
  end;
end;

procedure TADCmd_MainForm.Action_DCList_Expand_AllExecute(Sender: TObject);
begin
  with TreeView_AD do
  begin
    Items.BeginUpdate;
    FullExpand;
    if Selected <> nil then
    begin
      Selected.MakeVisible;
      Selected.Focused := True;
    end else
    begin
      if Items.GetFirstNode <> nil
        then Items.GetFirstNode.MakeVisible;
    end;
    Items.EndUpdate;
  end;
end;

procedure TADCmd_MainForm.Action_DCList_RefreshExecute(Sender: TObject);
begin
  TreeView_AD.Items.Clear;
  ClearList_Accounts;
  List_ObjFull.Clear;
  Application.ProcessMessages;
  UpdateDCList;
end;

procedure TADCmd_MainForm.Action_Export_AccessExecute(Sender: TObject);
var
  lstProviders: TStrings;
  fExt: string;
  fName: TFileName;
  msgBox: TMsgBoxParams;
  eFormat: TADExportFormat;
begin
  lstProviders := TStringList.Create;

  try
    if List_Obj.Count = 0
      then raise Exception.Create('Нет данных для экспорта.');

    with DM1.SaveDialog do
    begin
      FileName := Format('adcmd_%s', [FormatDateTime('yyyymmddhhnnss', Now)]);
      if DBProviderExists(DB_PROVIDER_ACE120) then
      begin
        lstProviders.Add(DB_PROVIDER_ACE120);
        Filter := 'Базы данных Microsoft Access 2007 (*.accdb)|*.accdb';
      end;

//      {$IFDEF WIN32}
      if DBProviderExists(DB_PROVIDER_JET) then
      begin
        lstProviders.Add(DB_PROVIDER_JET);
        if not Filter.IsEmpty then Filter := Filter + '|';
        Filter := Filter + 'Базы данных Microsoft Access (*.mdb)|*.mdb';
      end;
//      {$ENDIF}

      if Filter.IsEmpty
        then raise Exception.Create('Провайдер баз данных Microsoft Access в вашей системе не установлен.');

      FilterIndex := 1;
    end;

    if DM1.SaveDialog.Execute(Self.Handle) then
    begin
      if lstProviders[DM1.SaveDialog.FilterIndex - 1] = DB_PROVIDER_ACE120 then
      begin
        eFormat := efAccess2007;
        fExt := '.accdb'
      end
      else if lstProviders[DM1.SaveDialog.FilterIndex - 1] = DB_PROVIDER_JET then
      begin
        eFormat := efAccess;
        fExt := '.mdb';
      end;

      fName := DM1.SaveDialog.FileName;
      if ExtractFileExt(fName) = ''
        then fName := fName + fExt;

//      raise Exception.Create('Функция экспорта в Microsoft Access находится в разработке.');

      ExecuteDataExport(eFormat, fName);
    end
  except
    on E: Exception do
    begin
      with msgBox do
      begin
        cbSize := SizeOf(msgBox);
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

      MessageBoxIndirect(msgBox);
    end;

  end;

  lstProviders.Free;
end;

procedure TADCmd_MainForm.Action_Export_ExcelExecute(Sender: TObject);
var
  v: Variant;
  excelApp: Variant;
  excelVer: Integer;
  fExt: string;
  fName: TFileName;
  msgBox: TMsgBoxParams;
  eFormat: TADExportFormat;
begin
  try
    if List_Obj.Count = 0
      then raise Exception.Create('Нет данных для экспорта.');

    if not DBProviderExists('Excel.Application')
      then raise Exception.Create('Для использования этой функции в вашей системе необходимо установить Microsoft Excel.');

    excelApp := CreateOleObject('Excel.Application');
    v := ExcelApp.Version;
    if not VarIsNull(v)
      then excelVer := StrToIntDef(Copy(VarToStr(v), 1, Pos('.', VarToStr(v)) - 1), 0);
    excelApp.Quit;
    excelApp := Null;

    with DM1.SaveDialog do
    begin
      FileName := Format('adcmd_%s', [FormatDateTime('yyyymmddhhnnss', Now)]);

      if excelVer < 12 then
      begin
        Filter := 'Книга Excel 97-2003 (*.xls)|*.xls';
      end else
      begin
        Filter := 'Книга Excel (*.xlsx)|*.xlsx|Книга Excel 97-2003 (*.xls)|*.xls';
      end;

      FilterIndex := 1;
    end;

    if DM1.SaveDialog.Execute(Self.Handle) then
    begin
      if excelVer < 12 then fExt := '.xls' else
      case DM1.SaveDialog.FilterIndex of
        1: begin
          fExt := '.xlsx';
          eFormat := efExcel2007
        end;

        2: begin
          fExt := '.xls';
          eFormat := efExcel;
        end;
      end;

      fName := DM1.SaveDialog.FileName;
      if ExtractFileExt(fName) = ''
        then fName := fName + fExt;

//      raise Exception.Create('Функция экспорта в Microsoft Excel находится в разработке.');

      ExecuteDataExport(eFormat, fName);
    end;
  except
    on E: Exception do
    begin
      with msgBox do
      begin
        cbSize := SizeOf(msgBox);
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

      MessageBoxIndirect(msgBox);
    end;
  end;
end;

procedure TADCmd_MainForm.ArrangeColumns(AAttrCat: TAttrCatalog);
var
  i: Integer;
  c: TListColumn;
begin
  ListView_Accounts.Items.BeginUpdate;
  try
    ListView_Accounts.Columns.Clear;
    c := ListView_Accounts.Columns.Add;

    for i := 0 to AAttrCat.Count - 1 do
    begin
      if not AAttrCat[i]^.Visible
        then Continue;

      c := ListView_Accounts.Columns.Add;
      { В Tag записываем ID столбца в каталоге атрибутов }
      c.Tag := AAttrCat[i]^.ID;
      c.Caption := string(AAttrCat[i]^.Title);
      c.MinWidth := 50;
      c.Width := AAttrCat[i]^.Width;
      c.Alignment := AAttrCat[i]^.Alignment;
    end;
  finally
    ListView_Accounts.Items.EndUpdate;
    SetInfoColumnWidth;
    DrawSortedColumnHeader;
  end;
end;

procedure TADCmd_MainForm.AllignStatusBarPanels;
const
  idx = 1;
var
  Borders: array[0..2] of Integer;
  i, DeltaWidth, PanelWidth, MaxWidth: Integer;
begin
  DeltaWidth := 0;
  SendMessage(StatusBar.Handle, SB_GETBORDERS, 0, LPARAM(@Borders));

  for i := 0 to StatusBar.Panels.Count - 1 do
    if i <> idx then DeltaWidth := DeltaWidth + StatusBar.Panels[i].Width;

  StatusBar.Canvas.Font := StatusBar.Font;
  PanelWidth := StatusBar.Canvas.TextWidth(StatusBar.Panels[idx].Text) + 2 * Borders[2] + 12;
  MaxWidth := StatusBar.Width - (
                                   DeltaWidth +
                                   2 * Borders[1] +
                                   (StatusBar.Panels.Count - 1) * Borders[2]
                                 );
  if PanelWidth > MaxWidth then
  begin
    SendMessage(StatusBar.Handle, SB_SETTIPTEXT, 0,
    NativeInt(PChar(StatusBar.Panels[idx].Text)));
  end else
    SendMessage(StatusBar.Handle, SB_SETTIPTEXT, 0, 0);

  PanelWidth := MaxWidth;
  StatusBar.Panels[idx].Width := PanelWidth;
end;

function TADCmd_MainForm.CheckDameWareConfig: Boolean;
var
  MsgText: string;
  MsgBoxParam: TMsgBoxParams;
begin
  Result := FileExists(apDMRC_Executable);
  if not Result then
  begin
    MsgText := 'Для использования этой функции необходимо настроить' + #13#10
      + 'DameWare Mini Remote Control.'+ #13#10#13#10
      + 'Желаете произвести настройку сейчас?';

    with MsgBoxParam do
    begin
      cbSize := SizeOf(MsgBoxParam);
      hwndOwner := Self.Handle;
      hInstance := 0;
      lpszCaption := PChar(APP_TITLE);
      lpszIcon := MAKEINTRESOURCE(32513);
      dwStyle := MB_YESNO or MB_ICONASTERISK;
      dwContextHelpId := 0;
      lpfnMsgBoxCallback := nil;
      dwLanguageId := LANG_NEUTRAL;
      MsgBoxParam.lpszText := PChar(MsgText);
    end;

    if MessageBoxIndirect(MsgBoxParam) = mrYes then
    with Form_Settings do
    begin
      BuildAttributeCatalog(SelectedDC);
      Position := poMainFormCenter;
      Show;
      OpenSettingsMenu(SETTINGS_MENU_DAMEWARE);
      CallingForm := Self;
    end;
  end;
end;

function TADCmd_MainForm.CheckPsExecConfig: Boolean;
var
  MsgText: string;
  MsgBoxParam: TMsgBoxParams;
begin
  Result := FileExists(apPsE_Executable);
  if not Result then
  begin
    MsgText := 'Для использования этой функции необходимо настроить' + #13#10
      + 'Sysinternals PsExec.'+ #13#10#13#10
      + 'Желаете произвести настройку сейчас?';

    with MsgBoxParam do
    begin
      cbSize := SizeOf(MsgBoxParam);
      hwndOwner := Self.Handle;
      hInstance := 0;
      lpszCaption := PChar(APP_TITLE);
      lpszIcon := MAKEINTRESOURCE(32513);
      dwStyle := MB_YESNO or MB_ICONASTERISK;
      dwContextHelpId := 0;
      lpfnMsgBoxCallback := nil;
      dwLanguageId := LANG_NEUTRAL;
      MsgBoxParam.lpszText := PChar(MsgText);
    end;

    if MessageBoxIndirect(MsgBoxParam) = mrYes then
    with Form_Settings do
    begin
      BuildAttributeCatalog(SelectedDC);
      Position := poMainFormCenter;
      Show;
      OpenSettingsMenu(SETTINGS_MENU_QUICK_MESSAGES);
      CallingForm := Self;
    end;
  end;

end;

procedure TADCmd_MainForm.ClearList_Accounts;
begin
  if ListView_Accounts.Items.Count > 0
    then ListView_Accounts.Items.Clear;

  List_Obj.Clear;
end;

procedure TADCmd_MainForm.ClearStatusBar;
begin
  StatusBar.Panels[1].Text := '';
  StatusBar.Panels[2].Text := '';
  StatusBar.Panels[3].Text := '';
  StatusBar.Repaint;
end;

procedure TADCmd_MainForm.ComboBox_DCDrawItem(Control: TWinControl;
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

  { Выводим имя контроллера домена }
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

procedure TADCmd_MainForm.ComboBox_DCSelect(Sender: TObject);
var
  i: Integer;
begin
  i := ComboBox_DC.ItemIndex;
  if i > -1 then
  try
    SelectedDC := TDCInfo(ComboBox_DC.Items.Objects[i]);
    SelectedDC.BuildTree(TreeView_AD);

    if SelectedDC.Address.IsEmpty and SelectedDC.IPAddress.IsEmpty
      then SelectedDC.RefreshData;

    case apAPI of
      ADC_API_LDAP: ServerBinding(
        SelectedDC.Name,
        LDAPBinding,
        OnEnumerationException
      );

      ADC_API_ADSI: ServerBinding(
        SelectedDC.Name,
        @ADSIBinding,
        OnEnumerationException
      );
    end;
  except
    SelectedDC := nil;
  end;

  if TreeView_AD.Items.Count > 0
    then TreeView_AD.Items[0].Selected := True;

  ClearList_Accounts;
end;

procedure TADCmd_MainForm.ComputerManagementClick(Sender: TObject);
var
  obj: TADObject;
  pcName: string;
  StartInfo: TStartupInfo;
  ProcInfo: TProcessInformation;
  SA: SECURITY_ATTRIBUTES;
  pingCmdLine: string;
  MsgBoxParam: TMsgBoxParams;
  fSuccess: Boolean;
begin
  obj := List_Obj[ListView_Accounts.Selected.Index];

  case obj.ObjectType of
    otUser: pcName := GetUserLogonPCName(obj, List_Attributes, apAttrCat_LogonPCFieldID);
    otWorkstation, otDomainController, otRODomainController: pcName := obj.name;
  end;

  pingCmdLine := 'cmd /c compmgmt.msc –a /computer=' + pcName;
  with SA do
  begin
    nLength := SizeOf(SECURITY_ATTRIBUTES);
    bInheritHandle := True;
    lpSecurityDescriptor := nil;
  end;
  FillChar(StartInfo, SizeOf(StartInfo), #0);
  FillChar(ProcInfo, SizeOf(StartInfo), #0);
  with StartInfo do
  begin
    cb := SizeOf(StartInfo);
    dwFlags := STARTF_USESHOWWINDOW;
    wShowWindow := SW_HIDE;
  end;

  fSuccess := CreateProcess(nil,
    PChar(pingCmdLine),
    @SA,
    @SA,
    False,
    0,
    nil,
    nil,
    StartInfo,
    ProcInfo
  );

  if fSuccess then
  begin
////    WaitForSingleObject(ProcInfo.hProcess, INFINITE);
//    case WaitForSingleObject(ProcInfo.hProcess, 30000) of
//      WAIT_TIMEOUT : ;
//      WAIT_FAILED  : ;
//      else ;
//    end;
    CloseHandle(ProcInfo.hProcess);
    CloseHandle(ProcInfo.hThread);
  end else
  begin
    with MsgBoxParam do
    begin
      cbSize := SizeOf(MsgBoxParam);
      hwndOwner := Self.Handle;
      hInstance := 0;
      lpszText := PChar(SysErrorMessage(GetLastError));
      lpszIcon := MAKEINTRESOURCE(32513);
      dwStyle := MB_OK or MB_ICONHAND;
      dwContextHelpId := 0;
      lpfnMsgBoxCallback := nil;
      dwLanguageId := LANG_NEUTRAL;
    end;
    MessageBoxIndirect(MsgBoxParam);
  end;
end;

procedure TADCmd_MainForm.DMRC_ControlClick(Sender: TObject);
var
  obj: TADObject;
  pcName: string;
begin
  if CheckDameWareConfig then
  begin
    obj := List_Obj[ListView_Accounts.Selected.Index];

    case obj.ObjectType of
      otUser: pcName := GetUserLogonPCName(obj, List_Attributes, apAttrCat_LogonPCFieldID);
      otWorkstation, otDomainController, otRODomainController: pcName := obj.name;
    end;

    DameWareMRC_Connect(
      apDMRC_Executable,
      pcName,
      apDMRC_Authorization,
      apDMRC_User,
      apDMRC_Password,
      apDMRC_Domain,
      apDMRC_Driver,
      apDMRC_Connection = DMRC_CONNECTION_RDP,
      apDMRC_AutoConnect,
      False
    );
  end;
end;

procedure TADCmd_MainForm.DMRC_CustomClick(Sender: TObject);
begin
  if CheckDameWareConfig then
  with Form_DameWare do
  begin
    ComboBox_DMRC.ItemIndex := apDMRC_Authorization;
    Edit_DMRC_user.Text := apDMRC_User;
    Edit_DMRC_pass.Text := apDMRC_Password;
    Edit_DMRC_dom.Text := apDMRC_Domain;
    case apDMRC_Connection of
      DMRC_CONNECTION_MRC: RadioButton_DMRC_Viewer.Checked := True;
      DMRC_CONNECTION_RDP: RadioButton_DMRC_RDP.Checked := True;
    end;
    CheckBox_DMRC_Driver.Checked := apDMRC_Driver;
    CheckBox_DMRC_Auto.Checked := apDMRC_AutoConnect;
    Position := poMainFormCenter;
    CallingForm := Self;
    ADObject := List_Obj[ListView_Accounts.Selected.Index];
    if List_Obj[ListView_Accounts.Selected.Index].IsUser
      then AddHostName(GetUserLogonPCName(List_Obj[ListView_Accounts.Selected.Index], List_Attributes, apAttrCat_LogonPCFieldID));
    Show;
    ComboBox_Computer.SetFocus;
  end;
end;

procedure TADCmd_MainForm.DMRC_ViewClick(Sender: TObject);
var
  obj: TADObject;
  pcName: string;
begin
  if CheckDameWareConfig then
  begin
    obj := List_Obj[ListView_Accounts.Selected.Index];

    case obj.ObjectType of
      otUser: pcName := GetUserLogonPCName(obj, List_Attributes, apAttrCat_LogonPCFieldID);
      otWorkstation, otDomainController, otRODomainController: pcName := obj.name;
    end;

    DameWareMRC_Connect(
      apDMRC_Executable,
      pcName,
      apDMRC_Authorization,
      apDMRC_User,
      apDMRC_Password,
      apDMRC_Domain,
      apDMRC_Driver,
      apDMRC_Connection = DMRC_CONNECTION_RDP,
      apDMRC_AutoConnect,
      True
    );
  end;
end;

procedure TADCmd_MainForm.DrawSortedColumnHeader;
var
  o: PADAttribute;
  i: Integer;
  idx: Integer;
  c: TListColumn;
  h: THandle;
  hItem: THDItem;
begin
  h := ListView_GetHeader(ListView_Accounts.Handle);

  for i := 1 to ListView_Accounts.Columns.Count - 1 do
  begin
    c := ListView_Accounts.Columns.Items[i];

    idx := Header_OrderToIndex(h, c.Index);

    ZeroMemory(@hItem, SizeOf(THDItem));
    hItem.Mask := HDI_FORMAT;

    Header_GetItem(h, idx, hItem);

    hItem.Mask := HDI_FORMAT;
    hItem.fmt := (hItem.fmt or HDF_OWNERDRAW) and not (HDF_SORTUP or HDF_SORTDOWN);

    try
      o := List_Attributes.ItemByProperty(List_ObjFull.SortedProperty);
      if Assigned(o) then
      if c.Tag = o^.ID then
      case List_ObjFull.SortOrder of
        osoAscending  : hItem.fmt := hItem.fmt or HDF_SORTUP;
        osoDescending : hItem.fmt := hItem.fmt or HDF_SORTDOWN;
      end;
    except

    end;

    Header_SetItem(h, idx, hItem);
  end;
end;

procedure TADCmd_MainForm.EnumerateObjects;
begin
  ClearList_Accounts;

  case apAPI of
    ADC_API_LDAP: begin
      ObjEnum_LDAP := TLDAPEnum.Create(
          LDAPBinding,
          List_Attributes,
          List_ObjFull,
          csEnumaration,
          OnEnumerationProgress,
          OnEnumerationException,
          True
      );
      ObjEnum_LDAP.OnTerminate := OnEnumerationComplete;
      ObjEnum_LDAP.Priority := tpNormal;
      ObjEnum_LDAP.Start;
    end;

    ADC_API_ADSI: begin
      ObjEnum_ADSI := TADSIEnum.Create(
          ADSIBinding,
          List_Attributes,
          List_ObjFull,
          csEnumaration,
          OnEnumerationProgress,
          OnEnumerationException,
          True
      );
      ObjEnum_ADSI.OnTerminate := OnEnumerationComplete;
      ObjEnum_ADSI.Priority := tpNormal;
      ObjEnum_ADSI.Start;
    end;
  end;
end;

procedure TADCmd_MainForm.ExecuteDataExport(AFormat: TADExportFormat;
  AFileName: TFileName);
begin
  case apAPI of
    ADC_API_LDAP: ObjExport := TADExporter.Create(
      LDAPBinding,
      List_Obj,
      List_Attributes,
      AFormat,
      AFileName,
      csExport,
      nil,
      nil,
      True
    );

    ADC_API_ADSI: ObjExport := TADExporter.Create(
      ADSIBinding,
      List_Obj,
      List_Attributes,
      AFormat,
      AFileName,
      csExport,
      nil,
      nil,
      True
    );
  end;

  ObjExport.FreeOnTerminate := True;
  ObjExport.Priority := tpNormal;
  ObjExport.Start;
end;

procedure TADCmd_MainForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  if (apMinimizeAtClose) and (Action <> caFree) then
  begin
    Action := caNone;
    Application.Minimize;
  end else Application.Terminate;
end;

procedure TADCmd_MainForm.FormCreate(Sender: TObject);
var
  pbStyle: Integer;
begin
  Caption := GetJokeAppTitle;
  {$IFDEF WIN32}
    Caption := Caption + ' - ' + GetFileInfo(Application.ExeName, 'ProductVersion');
  {$ENDIF}
  {$IFDEF WIN64}
    Caption := Caption + ' (x64) - ' + GetFileInfo(Application.ExeName, 'ProductVersion');
  {$ENDIF}

  if ContainsText(Caption, APP_TITLE_JOKE)
    then Caption := Caption + ' - Kalashnikoff''s Edition';

  gvDomainName := GetHostDomainName;
  gvUserName := GetCurrentUserName;

  FAccountListWndProc := ListView_Accounts.WindowProc;
  ListView_Accounts.WindowProc := WndProc_ListView_Accounts;
  Cipher := TJvVigenereCipher.Create(Self);
  Frame_Search.InitControls;

  { Загружаем настройки программы }
  FileName_Ini := GetSpecialFolderPath(CSIDL_APPDATA) + '\settings.ini';
  if FileExists(FileName_Ini) then
  begin
    LoadLastFormState(FileName_Ini);
    ReadSettings(FileName_Ini);
  end else
  begin
    { Для поддержки старых версий, которые хранили настройки в каталоге программы }
    FileName_Ini := ChangeFileExt(Application.ExeName, '.ini');
    LoadLastFormState(FileName_Ini);
    ReadSettings(FileName_Ini);
    DeleteFile(FileName_Ini);
    FileName_Ini := GetSpecialFolderPath(CSIDL_APPDATA) + '\settings.ini';
    WriteSettings(FileName_Ini);
  end;

  FProgressBar := TProgressBar.Create(Self);
  with FProgressBar do
  begin
    Parent := ListView_Accounts;
    Visible := False;
    Width := 300;
    Height := 13;
    Style := pbstMarquee;
  end;
  pbStyle := GetWindowLong(FProgressBar.Handle, GWL_EXSTYLE);
  if pbStyle and WS_EX_STATICEDGE <> 0
    then pbStyle := pbStyle xor WS_EX_STATICEDGE;
  SetWindowLong(FProgressBar.Handle, GWL_EXSTYLE, pbStyle);


  FFloatingWindow := TForm_FloatingWindow.Create(Self, ListView_Accounts);
  with FFloatingWindow do
  begin
    DisplayStyle := apFWND_DisplayStyle;
    DisplayDelay := apFWND_DisplayDelay;
    DisplayDuration := apFWND_DisplayDuration;
    DisplayActivity := apFWND_DisplayActivity;
  end;

  FInPlaceEdit := TInPlaceEdit.Create(Self);
  with FInPlaceEdit do
  begin
    Parent := ListView_Accounts;
    Visible := False;
    ReadOnly := True;
    OnExit := OnInPlaceEditExit;
  end;
  SendMessage(
    FInPlaceEdit.Handle,
    EM_SETMARGINS,
    EC_LEFTMARGIN or EC_RIGHTMARGIN,
    MakeLong(3, 3)
  );

  { Загружаем список атрибутов Active Directory }
  List_Attributes := TAttrCatalog.Create;
  List_Attributes.OnSave := OnAttrCatalogSave;
  FileName_AttrCat := GetSpecialFolderPath(CSIDL_APPDATA) + '\attrcat.dat';
  if FileExists(FileName_AttrCat) then
  begin
    List_Attributes.LoadFromFile(FileName_AttrCat);
  end else
  begin
    { Для поддержки старых версий, которые хранили настройки в каталоге программы }
    FileName_AttrCat := ExtractFilePath(Application.ExeName) + 'attrcat.dat';
    List_Attributes.LoadFromFile(FileName_AttrCat);
    DeleteFile(FileName_AttrCat);
    FileName_AttrCat := GetSpecialFolderPath(CSIDL_APPDATA) + '\attrcat.dat';
    List_Attributes.SaveToFile(FileName_AttrCat, False);
  end;
  ArrangeColumns(List_Attributes);

  { Загружаем список кнопок выполнения скриптов }
  List_ScriptButtons := TADScriptButtonList.Create;
  FileName_ScriptButtons := GetSpecialFolderPath(CSIDL_APPDATA) + '\scriptbtn.xml';
  if FileExists(FileName_ScriptButtons) then
  begin
    List_ScriptButtons.LoadFromFile(FileName_ScriptButtons);
  end else
  begin
    { Для поддержки старых версий, которые хранили настройки в каталоге программы }
    FileName_ScriptButtons := ExtractFilePath(Application.ExeName) + 'scriptbtn.xml';
    List_ScriptButtons.LoadFromFile(FileName_ScriptButtons);
    DeleteFile(FileName_ScriptButtons);
    FileName_ScriptButtons := GetSpecialFolderPath(CSIDL_APPDATA) + '\scriptbtn.xml';
    List_ScriptButtons.SaveToFile(FileName_ScriptButtons);
  end;

  List_Obj := TADObjectList<TADObject>.Create(False);
  List_Obj.OnSort := OnObjListSort;
  List_ObjFull := TADObjectList<TADObject>.Create(True);
  with List_ObjFull.Filter do
  begin
    IncludeDisabled := True;
    NameOnly := Frame_Search.FilterOption = FILTER_BY_NAME;
    ApplyOnChange := True;
    AttrCatalog := List_Attributes;
    Objects := apFilterObjects;
    ResultList := List_Obj;
    Enabled := True;
  end;
  List_ObjFull.OnFilter := OnObjListFilter;
  List_ObjFull.OnNotify := OnObjListNotify;

  ListView_SetExtendedListViewStyle(
    ListView_Accounts.Handle,
    ListView_GetExtendedListViewStyle(ListView_Accounts.Handle) xor LVS_EX_INFOTIP
  );

  csEnumaration := TCriticalSection.Create;
  csQuickMessage := TCriticalSection.Create;
  csExport := TCriticalSection.Create;
end;

procedure TADCmd_MainForm.FormDestroy(Sender: TObject);
begin
  SaveLastFormState(FileName_Ini);
  FInPlaceEdit.Free;
  FFloatingWindow.Free;
  FProgressBar.Free;
  ldap_unbind(LDAPBinding);
  List_Attributes.Free;
  List_ScriptButtons.Free;
  List_Obj.Free;
  List_ObjFull.Free;
  Cipher.Free;
  csEnumaration.Free;
  csQuickMessage.Free;
  csExport.Free;
end;

procedure TADCmd_MainForm.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  case Key of
    Ord('F'): begin
      if ssCtrl in Shift
        then Frame_Search.Edit_SearchPattern.SetFocus;
    end;
  end;
end;

procedure TADCmd_MainForm.FormResize(Sender: TObject);
begin
  AllignStatusBarPanels;
end;

procedure TADCmd_MainForm.FormShow(Sender: TObject);
begin
//  SendMessage(
//    ListView_Accounts.Handle,
//    LVM_SETEXTENDEDLISTVIEWSTYLE,
//    0,
//    LVS_EX_DOUBLEBUFFER or LVS_EX_FULLROWSELECT or LVS_EX_HEADERDRAGDROP or
//    LVS_EX_LABELTIP or LVS_EX_SUBITEMIMAGES or LVS_OWNERDATA
//  );

  { Отключаем рамку на выделенной строке }
//  SendMessage(
//    ListView_Accounts.Handle,
//    LVM_SETCALLBACKMASK,
//    LVIS_FOCUSED,
//    0
//  );

//  with Panel1 do
//  begin
//    Top := Panel5.Top + Round((Panel5.Height - Height) / 2) + ListView1.Top;
//    Left := Panel5.Left + Round((Panel5.Width - Width) / 2);
//  end;
  ActionToolBar_Acc.RecreateControls;
  Frame_Search.Edit_SearchPattern.SetFocus;
end;

procedure TADCmd_MainForm.Frame_SearchComboBox_SearchOptionSelect(
  Sender: TObject);
begin
  Frame_Search.ComboBox_SearchOptionSelect(Sender);
  List_ObjFull.Filter.NameOnly := Frame_Search.FilterOption <> FILTER_BY_ANY;
end;

procedure TADCmd_MainForm.Frame_SearchEdit_SearchPatternChange(
  Sender: TObject);
begin
  Frame_Search.Edit_SearchPatternChange(Sender);
  List_ObjFull.Filter.Condition := Frame_Search.Edit_SearchPattern.Text;
end;

function TADCmd_MainForm.GetJokeAppTitle: string;
const
  UNLEN = 256;
var
  BuffSize: Cardinal;
  n: PWideChar;
begin
  BuffSize := UNLEN + 1;
  GetMem(n, BuffSize);
  GetUserName(n, BuffSize);
  if CompareText(string(n), 'klever') = 0
    then Result := APP_TITLE_JOKE
    else Result := APP_TITLE;
  FreeMem(n);
end;

function TADCmd_MainForm.GetCurrentUserName: string;
const
  NameSamCompatible = 2;
  UNLEN = 256;
var
  BuffSize: Cardinal;
  Buff: PWideChar;
begin
  BuffSize := UNLEN + 1;
  GetMem(Buff, BuffSize);
//  if GetUserNameEx(NameSamCompatible, Buff, BuffSize)
  if GetUserName(Buff, BuffSize)
    then Result := string(Buff);
  FreeMem(Buff);
end;

function TADCmd_MainForm.GetHostDomainName: string;
var
  Buff: PChar;
  BuffSize: Cardinal;
begin
  BuffSize := 4096;
  GetMem(Buff, BuffSize);

  if GetComputerNameEx(_COMPUTER_NAME_FORMAT.ComputerNameDnsDomain, Buff, BuffSize)
    then Result := Buff;

  FreeMem(Buff);

//HRESULT hr     = S_OK;
//   BSTR   domainName;
//   DWORD dwSize  = 0;
//   wchar_t* pBuf = new wchar_t[BUF_SIZE];
//   if(pBuf == NULL)
//      _com_issue_error(E_OUTOFMEMORY);
//
//   if(!GetComputerNameEx((COMPUTER_NAME_FORMAT)ComputerNameDnsDomain,
//                     pBuf,
//                     &dwSize)) {
//      if(GetLastError() == ERROR_MORE_DATA) {
//         delete [] pBuf;
//         pBuf = new wchar_t[dwSize+1];
//         if(pBuf == NULL)
//            _com_issue_error(E_OUTOFMEMORY);
//
//         if(!GetComputerNameEx((COMPUTER_NAME_FORMAT)ComputerNameDnsDomain, pBuf, &dwSize) ) {
//            hr =   HRESULT_FROM_WIN32(GetLastError());
//            delete [] pBuf;
//            pBuf    = NULL;
//            _com_issue_error(hr);
//         }
//      }
//      else
//         _com_issue_error(HRESULT_FROM_WIN32(GetLastError()));
//   }
//
//   domainName = SysAllocString(pBuf);
//   delete [] pBuf;
//
//   return bstr_t(domainName, false);
end;

procedure TADCmd_MainForm.ListView_AccountsChange(Sender: TObject;
  Item: TListItem; Change: TItemChange);
var
  obj: TADObject;
begin
  case Change of
    ctText: ;

    ctImage: ;

    ctState: begin
      if (Item = nil) or (Item.Index > List_Obj.Count - 1) then
      begin
        StatusBar.Panels[0].Text := IntToStr(List_Obj.Count);
        StatusBar.Panels[1].Text := '';
        StatusBar.Panels[2].Text := '';
        StatusBar.Panels[3].Text := '';
      end else
      if Item.Selected then
      begin
        obj := List_Obj[Item.Index];
        StatusBar.Panels[1].Text := obj.CanonicalName;
        case obj.passwordExpiration > 0 of
          True : if obj.UserAccountControl and ADS_UF_DONT_EXPIRE_PASSWD = 0
            then StatusBar.Panels[2].Text := FormatDateTime('dd/mm/yyyy hh:nn:ss', obj.passwordExpiration)
            else StatusBar.Panels[2].Text := 'НЕ ОГРАНИЧЕН';

          False: StatusBar.Panels[2].Text := '<НЕТ>';
        end;
        StatusBar.Panels[3].Text := IntToStr(obj.BadPwdCount);
      end else ClearStatusBar;
      StatusBar.Repaint;
    end;
  end;
end;

procedure TADCmd_MainForm.ListView_AccountsColumnClick(Sender: TObject;
  Column: TListColumn);
var
  i: Integer;
  idx: Integer;
  c: TListColumn;
  h: THandle;
  hItem: THDItem;
begin
  if Column.Index > 0 then
  begin
    List_ObjFull.SortObjects(string(List_Attributes.ItemByID(Column.Tag)^.ObjProperty));
    List_Obj.SortObjects(string(List_Attributes.ItemByID(Column.Tag)^.ObjProperty));
  end;

  DrawSortedColumnHeader;
end;

procedure TADCmd_MainForm.ListView_AccountsColumnDragged(Sender: TObject);
var
  col: TListColumn;
  i: Integer;
begin
  for i := 1 to ListView_Accounts.Columns.Count - 1 do
  begin
    col := ListView_Accounts.Columns.Items[i];
    List_Attributes.Move(
      List_Attributes.IndexOf(List_Attributes.ItemByID(col.Tag)),
      col.Index - 1
    );
  end;
  List_Attributes.SaveToFile(FileName_AttrCat);
end;

procedure TADCmd_MainForm.ListView_AccountsCustomDraw(Sender: TCustomListView;
  const [Ref] ARect: TRect; var DefaultDraw: Boolean);
var
  R: TRect;
begin
  if FInPlaceEdit.Visible then
  begin
    if FInPlaceEdit.SubItemIndex > - 1 then
    begin
      ListView_GetSubItemRect(
        ListView_Accounts.Handle,
        FInPlaceEdit.ItemIndex,
        FInPlaceEdit.SubItemIndex + 1,
        LVIR_BOUNDS,
        @R
      );
      FInPlaceEdit.SetBounds(R.Left, R.Top, R.Right - R.Left, R.Bottom - R.Top);
    end else if FInPlaceEdit.ItemIndex > - 1 then
    begin
      ListView_GetItemRect(
        ListView_Accounts.Handle,
        FInPlaceEdit.ItemIndex,
        R,
        LVIR_LABEL
      );
      FInPlaceEdit.SetBounds(R.Left, R.Top, R.Right - R.Left, R.Bottom - R.Top);
    end;
  end;
end;

procedure TADCmd_MainForm.ListView_AccountsData(Sender: TObject;
  Item: TListItem);
var
  i: Integer;
  attr: TADAttribute;
  val: string;
  ColOrder: array of Integer;
  SubIndex: Integer;
begin
  SetLength(ColOrder, (Sender as TListView).Columns.Count);
  ListView_GetColumnOrderArray(
    (Sender as TListView).Handle,
    (Sender as TListView).Columns.Count,
    PInteger(ColOrder)
  );
  while Item.SubItems.Count < List_Attributes.VisibleCount do Item.SubItems.Add('');
  Item.Caption := FormatFloat('#,##0', Item.Index + 1);

  case List_Obj[Item.Index].ObjectType of
    otUser: case List_Obj[Item.Index].IsDisabled of
      False: Item.ImageIndex := 0;
      True : Item.ImageIndex := 1;
    end;

    otWorkstation: case List_Obj[Item.Index].IsDisabled of
      False: Item.ImageIndex := 2;
      True : Item.ImageIndex := 3;
    end;

    otDomainController: case List_Obj[Item.Index].IsDisabled of
      False: Item.ImageIndex := 4;
      True : Item.ImageIndex := 5;
    end;

    otRODomainController: case List_Obj[Item.Index].IsDisabled of
      False: Item.ImageIndex := 4;
      True : Item.ImageIndex := 5;
    end;

    otGroup: Item.ImageIndex := 6;
    else Item.ImageIndex := -1;
  end;

  for i := 0 to (Sender as TListView).Columns.Count - 1 do
  begin
    attr := List_Attributes.ItemByID( (Sender as TListView).Columns[i].Tag )^;
    val := '';
    case IndexText(attr.Name,
      [
        'lastLogon',
        'pwdLastSet',
        'userAccountControl',
        'thumbnailPhoto',
        'groupType'
      ]
    ) of
      0: val := List_Obj[Item.Index].lastLogon.AsString('<нет>');
      1: val := List_Obj[Item.Index].passwordExpiration.AsString(List_Obj[Item.Index].userAccountControl);
      2: val := List_Obj[Item.Index].userAccountControl.AsString;
      3: val := List_Obj[Item.Index].thumbnailFileSize.AsString;
      4: val := List_Obj[Item.Index].groupType.AsString;
      else if IsPublishedProp(List_Obj[Item.Index], attr.ObjProperty) then
      begin
        if CompareText(attr.ObjProperty, 'nearestEvent') = 0
          then val := List_Obj[Item.Index].nearestEvent.AsDateString
          else val := GetPropValue(List_Obj[Item.Index], attr.ObjProperty);
      end;
    end;

    SubIndex := ColOrder[i];
    if SubIndex > 0 then
    begin
      Dec(SubIndex);
      Item.SubItems[SubIndex] := val;
    end;
  end;
end;

procedure TADCmd_MainForm.ListView_AccountsDrawItem(Sender: TCustomListView;
  Item: TListItem; Rect: TRect; State: TOwnerDrawState);
var
  C: TCanvas;
  tmpRect: TRect;
  S: string;
  ColOrder: array of Integer;
  SubIndex: Integer;
  txtAlign: UINT;
  i: Integer;
  attr: TADAttribute;
begin
  C := Sender.Canvas;

  { Закрашиваем первый столбец }
  tmpRect := Rect;
  tmpRect.Right := tmpRect.Left + Sender.Column[0].Width;
  if odSelected in State
    then C.Brush.Color := COLOR_SELBORDER
    else C.Brush.Color := clBtnFace;
  C.FillRect(tmpRect);

  { Выводим индикатор сигнализации }
  if List_Obj[Item.Index].nearestEvent > 0 then
  begin
    tmpRect := Rect;
    tmpRect.Width := 8;
    tmpRect.Inflate(-3, -3);
    C.Brush.Color := GetUserEventColor(List_Obj[Item.Index].nearestEvent, C.Brush.Color);
    C.FillRect(tmpRect);
//    C.Brush.Color := clWhite;
//    C.FrameRect(tmpRect);
  end;

  { Формируем Rect для вывода индикатора, порядкового номера, }
  { вертикального разделителя и значка                        }
  tmpRect := Rect;
  tmpRect.Right := tmpRect.Left + Sender.Column[0].Width;
  tmpRect.Width := tmpRect.Width - 16 - 12 - 6;
//  tmpRect.Height := tmpRect.Height - 1;
//  tmpRect.Offset(0, 1);

  { Выводим порядковый номер записи }
  if odSelected in State
    then C.Brush.Color := COLOR_SELBORDER
    else C.Brush.Color := clBtnFace;
  C.Font.Size := 6;
  if odSelected in State then
  begin
    C.Font.Color := clWhite;
    C.Font.Style := [fsBold];
  end;
  C.Refresh;
  S := Item.Caption;
  DrawText(
    C.Handle,
    S,
    Length(S),
    tmpRect,
    DT_RIGHT or DT_VCENTER or DT_SINGLELINE
  );

  { Выводим вертикальный разделитель номера записи и значка }
  C.Pen.Color := clSilver;
  C.Pen.Width := 1;
  C.Refresh;
  C.MoveTo(tmpRect.BottomRight.X + 6, tmpRect.TopLeft.Y + 4);
  C.LineTo(tmpRect.BottomRight.X + 6, tmpRect.BottomRight.Y - 4);

  { Выводим значек объекта AD }
  if Item.ImageIndex > -1 then
  begin
    tmpRect.Width := Sender.Column[0].Width - tmpRect.Width;
    OffsetRect(tmpRect, Sender.Column[0].Width - tmpRect.Width + 12, 1);
    DM1.ImageList_Accounts.Draw(c, tmpRect.TopLeft.X, tmpRect.TopLeft.Y, Item.ImageIndex);
  end;

  { Выводим текстовую информацию }
  SetLength(ColOrder, (Sender as TListView).Columns.Count);
  ListView_GetColumnOrderArray(
    (Sender as TListView).Handle,
    (Sender as TListView).Columns.Count,
    PInteger(ColOrder)
  );

  C.Font.Size := 8;
  C.Font.Style := [];
  C.Refresh;

  for i := Low(ColOrder) to High(ColOrder) do
  begin
    SubIndex := ColOrder[i];
    if SubIndex > 0 then
    begin
      attr := List_Attributes.ItemByID(Sender.Column[i].Tag)^;

      { Определяем положение текста SubItem }
      case attr.Alignment of
        taLeftJustify : txtAlign := DT_LEFT;
        taCenter      : txtAlign := DT_CENTER;
        taRightJustify: txtAlign := DT_RIGHT;
        else txtAlign := DT_LEFT;
      end;

      { Определяем цвет текста SubItem и цвет его фона }
//      if attr^.ReadOnly then
//      begin
//        C.Font.Color := clGrayText;
//        C.Brush.Color := clBtnFace;
//      end else
//      begin
//        case List_Obj[Item.Index].userAccountControl and ADS_UF_ACCOUNTDISABLE = ADS_UF_ACCOUNTDISABLE of
//          True : C.Font.Color := clGrayText;
//          False: C.Font.Color := clWindowText;
//        end;
//
//        if odSelected in State
//          then C.Brush.Color := IncreaseBrightness(COLOR_SELBORDER, 95)
//          else C.Brush.Color := clWindow;
//      end;

      case List_Obj[Item.Index].IsDisabled of
        True : C.Font.Color := clGrayText;
        False: C.Font.Color := attr.FontColor;
      end;

      if odSelected in State
        then C.Brush.Color := IncreaseBrightness(COLOR_SELBORDER, 95)
        else C.Brush.Color := attr.BgColor;

      { Выводим текст SubItem }
      ListView_GetSubItemRect(Sender.Handle, Item.Index, SubIndex, LVIR_BOUNDS, @tmpRect);
      C.FillRect(tmpRect);
      tmpRect.Inflate(-6, -3);
      C.Refresh;
      S := Item.SubItems[SubIndex - 1];
      DrawText(
        C.Handle,
        S,
        Length(S),
        tmpRect,
        txtAlign or DT_VCENTER or DT_END_ELLIPSIS or DT_SINGLELINE or DT_NOPREFIX
      );
    end;
  end;

  { Отрисовываем рамку вокруг записи }
  tmpRect := Rect;
  tmpRect.Height := tmpRect.Height - 1;
  if odSelected in State then
  begin
    tmpRect.Width := tmpRect.Width - 1;
    C.Pen.Color := COLOR_SELBORDER;
    C.Pen.Width := 1;
    C.Refresh;
    C.Polyline(
      [
         tmpRect.TopLeft,
         Point(tmpRect.BottomRight.X, tmpRect.TopLeft.Y),
         tmpRect.BottomRight,
         Point(tmpRect.TopLeft.X, tmpRect.BottomRight.Y),
         tmpRect.TopLeft
      ]
    );
  end else
  begin
    tmpRect.Width := tmpRect.Width - Sender.Column[0].Width;
    tmpRect.Offset(Sender.Column[0].Width, 0);
    C.Pen.Color := IncreaseBrightness(clBtnFace, 35);
    C.Pen.Width := 1;
    C.Refresh;
    C.Polyline(
      [
         Point(tmpRect.TopLeft.X, tmpRect.BottomRight.Y),
         tmpRect.BottomRight
      ]
    )
  end;

  SetLength(ColOrder, 0);
end;

procedure TADCmd_MainForm.ListView_AccountsKeyDown(Sender: TObject;
  var Key: Word; Shift: TShiftState);
var
  R: TRect;
  P: TPoint;
  hHeader: NativeInt;
begin
  if Key = VK_APPS then
  begin
    P := Panel_Accounts.ClientToScreen(ListView_Accounts.BoundsRect.TopLeft);
    hHeader := SendMessage(ListView_Accounts.Handle, LVM_GETHEADER, 0, 0);
    if GetWindowRect(hHeader, R) then P.Offset(3, R.Height + 3) else P.Offset(3, 3);
    if ListView_Accounts.Selected <> nil then
    begin
      R := ListView_Accounts.Selected.DisplayRect(drLabel);
      if SendMessage(ListView_Accounts.Handle, LVM_ISITEMVISIBLE, ListView_Accounts.Selected.Index, 0) <> 0 then
      begin
        P.X := 100; //R.TopLeft.X;
        P.Y := R.TopLeft.Y + Round(R.Height / 2);
        P := ListView_Accounts.ClientToScreen(P);
      end;
    end;
    PopupMenu_ListAcc.Popup(P.X, P.Y);
  end;
end;

procedure TADCmd_MainForm.ListView_AccountsMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
const
  LMB_RES_PROPERTIES   = 1;
  LMB_RES_SELECT_FIELD = 2;
var
  HitPoint: TPoint;
  HitInfo: TLVHitTestInfo;
  R: TRect;
  MsgRes: Integer;
  LMB_Result: Integer;
begin
  if (ssLeft in Shift) and (ssDouble in Shift) then
  begin
    case ssCtrl in Shift of
      False: case apMouseLMBOption of
               MOUSE_LMB_OPTION1: LMB_Result := LMB_RES_PROPERTIES;
               MOUSE_LMB_OPTION2: LMB_Result := LMB_RES_SELECT_FIELD;
             end;

      True: case apMouseLMBOption of
              MOUSE_LMB_OPTION1: LMB_Result := LMB_RES_SELECT_FIELD;
              MOUSE_LMB_OPTION2: LMB_Result := LMB_RES_PROPERTIES;
            end;
    end;

    case LMB_Result of
      LMB_RES_PROPERTIES:
      begin
        Action_PropertiesExecute(Self);
      end;

      LMB_RES_SELECT_FIELD: begin
        FInPlaceEdit.Clear;
        HitPoint := ListView_Accounts.ScreenToClient(Mouse.Cursorpos);
        FillChar(HitInfo, SizeOf(TLVHitTestInfo), 0);
        HitInfo.pt := HitPoint;
        MsgRes := ListView_Accounts.Perform(LVM_SUBITEMHITTEST, 0, lparam(@HitInfo));
        if MsgRes <> -1 then
        begin
          if HitInfo.iSubItem > 0 then
          begin
            ListView_GetSubItemRect(
              ListView_Accounts.Handle,
              HitInfo.iItem,
              HitInfo.iSubItem,
              LVIR_LABEL,
              @R
            );
            FInPlaceEdit.SetBounds(R.Left, R.Top, R.Right - R.Left, R.Bottom - R.Top);
            Dec(HitInfo.iSubItem);
            FInPlaceEdit.Text := ListView_Accounts.Items[HitInfo.iItem].Subitems[HitInfo.iSubItem];
            FInPlaceEdit.ItemIndex := HitInfo.iItem;
            FInPlaceEdit.SubItemIndex := HitInfo.iSubItem;
          end else
          begin
            { Код ниже закомментирован для того, чтобы при двойном клике }
            { на порядковом номере записи не появлялся FInPlaceEdit      }
//            ListView_GetItemRect(ListView_Accounts.Handle, HitInfo.iItem, R, LVIR_LABEL);
//            FInPlaceEdit.SetBounds(R.Left, R.Top, R.Right - R.Left, R.Bottom - R.Top);
//            FInPlaceEdit.Text := ListView_Accounts.Items[HitInfo.iItem].Caption;
//            FInPlaceEdit.ItemIndex := HitInfo.iItem;

            ListView_GetItemRect(ListView_Accounts.Handle, HitInfo.iItem, R, LVIR_LABEL);
            ShowMessage(IntToStr(List_Obj[HitInfo.iItem].systemFlags));
          end;
          if not string(FInPlaceEdit.Text).IsEmpty then
          begin
            FInPlaceEdit.Visible:=True;
            FInPlaceEdit.SetFocus;
          end;
        end;
      end;
    end;
  end;
end;

procedure TADCmd_MainForm.LoadLastFormState(AIniFile: TFileName);
var
  Ini: TIniFile;
  posTop: Integer;
  posLeft: Integer;
begin
  Ini := TIniFile.Create(AIniFile);
  try
    Frame_Search.FilterOption := Ini.ReadInteger(INI_SECTION_STATE, 'FilterOption', FILTER_BY_ANY);
    apFilterObjects := Ini.ReadInteger(
      INI_SECTION_STATE,
      'FilterObjects',
      FILTER_OBJECT_USER or FILTER_OBJECT_GROUP or FILTER_OBJECT_WORKSTATION or FILTER_OBJECT_DC
    );
    Action_ShowUsers.Checked := apFilterObjects and FILTER_OBJECT_USER <> 0;
    Action_ShowGroups.Checked := apFilterObjects and FILTER_OBJECT_GROUP <> 0;
    Action_ShowWorkstations.Checked := apFilterObjects and FILTER_OBJECT_WORKSTATION <> 0;
    Action_ShowDC.Checked := apFilterObjects and FILTER_OBJECT_DC <> 0;

    Self.Position := poDesigned;
    Self.Height := Ini.ReadInteger(INI_SECTION_STATE, 'Height', Self.Constraints.MinHeight);
    Self.Width := Ini.ReadInteger(INI_SECTION_STATE, 'Width', Self.Constraints.MinWidth);

    posTop := (Screen.PrimaryMonitor.Height - Self.Height) div 2;
    posLeft := (Screen.PrimaryMonitor.Width - Self.Width) div 2;

    if TWindowState(Ini.ReadInteger(INI_SECTION_STATE, 'State', 0)) = wsMaximized then
    begin
      Self.WindowState := wsMaximized;
      Self.Top := posTop;
      Self.Left := posLeft;
    end else
    begin
      Self.Top := Ini.ReadInteger(INI_SECTION_STATE, 'Top', posTop);
      Self.Left := Ini.ReadInteger(INI_SECTION_STATE, 'Left', posLeft);
      if (Self.Left > Screen.PrimaryMonitor.Width - Self.Width)
      or (Self.Top > Screen.PrimaryMonitor.Height - Self.Height) then
      begin
        Self.Top := posTop;
        Self.Left := posLeft;
      end;
    end;

    Panel_DC.Width := Ini.ReadInteger(INI_SECTION_STATE, 'DCTreeWidth', Splitter.MinSize);
  finally
    Ini.Free;
  end;
end;

procedure TADCmd_MainForm.N2Click(Sender: TObject);
begin
  with Form_WorkstationInfo do
  begin
    Position := poMainFormCenter;
    CallingForm := Self;
    UserObject := List_Obj[ListView_Accounts.Selected.Index];
    AddHostName(
      GetUserLogonPCName(
        List_Obj[ListView_Accounts.Selected.Index],
        List_Attributes,
        apAttrCat_LogonPCFieldID
      )
    );
    Show;
    ComboBox_Name.SetFocus;
  end;
end;

procedure TADCmd_MainForm.OnMenuItem_CreateContainer(Sender: TObject);
begin
  Form_CreateContainer.CallingForm := Self;
  Form_CreateContainer.DomainController := SelectedDC;
  Form_CreateContainer.OnOrganizationalUnitCreate := OnOrganizationalUnitCreate;
  if Sender is TMenuItemEx
    then if Assigned(TMenuItemEx(Sender).Data)
      then Form_CreateContainer.Container := PADContainer(TMenuItemEx(Sender).Data)^;
  Form_CreateContainer.Position := poMainFormCenter;
  Form_CreateContainer.Show;
  Self.Enabled := False;
end;

procedure TADCmd_MainForm.OnMenuItem_CreateUser(Sender: TObject);
begin

  Action_CreateUserExecute(Sender);
end;

procedure TADCmd_MainForm.OnMenuItem_DeleteContainer(Sender: TObject);
const
  msgTemplate = 'Вы действительно хотите удалить %s %s?';
var
  obj: TADObject;
  MsgBoxParam: TMsgBoxParams;
  msgText: string;
  eventFileName: string;
  i: Integer;
  n: TTreeNode;
begin
  if Sender is TMenuItemEx then if Assigned(TMenuItemEx(Sender).Data) then
  begin
    msgText := Format(msgTemplate, [
        'подразделение',
        PADContainer(TMenuItemEx(Sender).Data)^.name
    ]);

    with MsgBoxParam do
    begin
      cbSize := SizeOf(MsgBoxParam);
      hwndOwner := Self.Handle;
      hInstance := 0;
      case apAPI of
        ADC_API_LDAP: lpszCaption := PChar('LDAP Confirmation');
        ADC_API_ADSI: lpszCaption := PChar('ADSI Confirmation');
      end;
      lpszIcon := MAKEINTRESOURCE(32515);
      dwStyle := MB_YESNO or MB_ICONEXCLAMATION or MB_DEFBUTTON2;
      dwContextHelpId := 0;
      lpfnMsgBoxCallback := nil;
      dwLanguageId := LANG_NEUTRAL;
      lpszText := PChar(msgText);
    end;

    if MessageBoxIndirect(MsgBoxParam) = mrYes then
    try
      case apAPI of
        ADC_API_LDAP: begin
          ADDeleteObject(
            LDAPBinding,
            PADContainer(TMenuItemEx(Sender).Data)^.DistinguishedName
          );
        end;

        ADC_API_ADSI: begin
          ADDeleteObjectDS(
            ADSIBinding,
            PADContainer(TMenuItemEx(Sender).Data)^.DistinguishedName
          );
        end;
      end;

      for n in TreeView_AD.Items do
      begin
        if n.Data <> nil then
          if CompareText(
            PADContainer(TMenuItemEx(Sender).Data)^.DistinguishedName,
            PADContainer(n.Data)^.DistinguishedName
          ) = 0 then
          begin
            n.DeleteChildren;
            n.Delete;
            Break;
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
end;

procedure TADCmd_MainForm.Object_DeleteClick(Sender: TObject);
const
  msgTemplate = 'Вы действительно хотите удалить %s %s?';
var
  obj: TADObject;
  MsgBoxParam: TMsgBoxParams;
  msgText: string;
  eventFileName: string;
begin
  if ListView_Accounts.Selected = nil
    then Exit;

  obj := List_Obj[ListView_Accounts.Selected.Index];
  case obj.ObjectType of
    otUser: msgText := Format(msgTemplate, ['пользователя', obj.name]);
    otWorkstation: msgText := Format(msgTemplate, ['компьютер', obj.name]);
    else msgText := Format(msgTemplate, ['объект', obj.name]);
  end;

  with MsgBoxParam do
  begin
    cbSize := SizeOf(MsgBoxParam);
    hwndOwner := Self.Handle;
    hInstance := 0;
    case apAPI of
      ADC_API_LDAP: lpszCaption := PChar('LDAP Confirmation');
      ADC_API_ADSI: lpszCaption := PChar('ADSI Confirmation');
    end;
    lpszIcon := MAKEINTRESOURCE(32515);
    dwStyle := MB_YESNO or MB_ICONEXCLAMATION or MB_DEFBUTTON2;
    dwContextHelpId := 0;
    lpfnMsgBoxCallback := nil;
    dwLanguageId := LANG_NEUTRAL;
    lpszText := PChar(msgText);
  end;

  if MessageBoxIndirect(MsgBoxParam) = mrNo
    then Exit;

  try
    case apAPI of
      ADC_API_LDAP: begin
        obj.Delete(LDAPBinding);
      end;

      ADC_API_ADSI: begin
        obj.Delete;
      end;
    end;

    eventFileName := apEventsDir + '\' + obj.objectSid + '.xml';
    if FileExists(eventFileName)
      then DeleteFile(eventFileName);

    ListView_Accounts.Items.Count := ListView_Accounts.Items.Count - 1;
    List_Obj.Remove(obj);
    List_ObjFull.Remove(obj);
    ListView_Accounts.Invalidate;
    ClearStatusBar;
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
        dwStyle := MB_YESNO or MB_ICONHAND;
        dwContextHelpId := 0;
        lpfnMsgBoxCallback := nil;
        dwLanguageId := LANG_NEUTRAL;
        lpszText := PChar(E.Message + #13#10#13#10 + 'Удалить запись из списка?');
      end;

      if MessageBoxIndirect(MsgBoxParam) = mrYes then
      begin
        ListView_Accounts.Items.Count := ListView_Accounts.Items.Count - 1;
        List_Obj.Remove(obj);
        List_ObjFull.Remove(obj);
        ListView_Accounts.Invalidate;
      end;
    end;
  end;
end;

procedure TADCmd_MainForm.Object_DisableClick(Sender: TObject);
var
  obj: TADObject;
  MsgBoxParam: TMsgBoxParams;
begin
  if ListView_Accounts.Selected = nil
    then Exit;

  obj := List_Obj[ListView_Accounts.Selected.Index];

  try
    case apAPI of
      ADC_API_LDAP: begin
        obj.ChangeDisabledState(LDAPBinding);
        obj.Refresh(LDAPBinding, List_Attributes);
      end;

      ADC_API_ADSI: begin
        obj.ChangeDisabledState;
        obj.Refresh(ADSIBinding, List_Attributes);
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

procedure TADCmd_MainForm.Object_MoveClick(Sender: TObject);
const
  msgTemplate = 'Выберите контейнер Active Directory в который будет перемещен %s %s.';
var
  obj: TADObject;
begin
  if ListView_Accounts.Selected <> nil then
  begin
    obj := List_Obj[ListView_Accounts.Selected.Index];
    Form_Container.CallingForm := Self;
    case obj.ObjectType of
      otUser: Form_Container.Description := Format(msgTemplate, ['пользователь', obj.name]);
      otWorkstation: Form_Container.Description := Format(msgTemplate, ['компьютер', obj.name]);
      else Form_Container.Description := Format(msgTemplate, ['объект', obj.name]);
    end;
    Form_Container.DomainController := SelectedDC;
    Form_Container.DefaultPath := obj.ParentCanonicalName;
    Form_Container.OnContainerSelect := OnTargetContainerSelect;
    Form_Container.Position := poMainFormCenter;
    Form_Container.Show;
    Self.Enabled := False;
  end;
end;

procedure TADCmd_MainForm.Object_PwdResetClick(Sender: TObject);
begin
  if ListView_Accounts.Selected <> nil then
  begin
    Form_ResetPassword.CallingForm := Self;
    Form_ResetPassword.UserObject := List_Obj[ListView_Accounts.Selected.Index];
    if apUseDefaultPassword
      then Form_ResetPassword.DefaultPassword := apDefaultPassword;
    Form_ResetPassword.OnPasswordChange := Self.OnPasswordChange;
    Form_ResetPassword.Position := poMainFormCenter;
    Form_ResetPassword.Show;
    Self.Enabled := False;
  end;
end;

procedure TADCmd_MainForm.Object_RenameClick(Sender: TObject);
begin
  if ListView_Accounts.Selected <> nil then
  begin
    Form_Rename.CallingForm := Self;
    Form_Rename.ADObject := List_Obj[ListView_Accounts.Selected.Index];
    Form_Rename.Position := poMainFormCenter;
    Form_Rename.Show;
    Self.Enabled := False;
  end;
end;

procedure TADCmd_MainForm.OnObjListFilter(Sender: TObject);
begin
  if not (Sender is TADObjectList<TADObject>)
    then Exit;

  ListView_Accounts.Items.Count := List_Obj.Count;
  ListView_Accounts.Invalidate;
  SetInfoColumnWidth;

  StatusBar.Repaint;
end;

procedure TADCmd_MainForm.OnObjListNotify(Sender: TObject;
  const Item: TADObject; Action: TCollectionNotification);
begin
  case Action of
    cnAdded: begin
      Item.OnRefresh := OnADObjectRefresh;
    end;

    cnRemoved: begin
      Item.OnRefresh := nil;
    end;

    cnExtracted: begin
      Item.OnRefresh := nil;
    end;
  end;
end;

procedure TADCmd_MainForm.OnObjListSort(Sender: TObject);
begin
  ListView_Accounts.Invalidate;
end;

procedure TADCmd_MainForm.OnOrganizationalUnitCreate(ANewDN: string);
var
  n: TTreeNode;
begin
  SelectedDC.BuildTree(TreeView_AD);
  for n in TreeView_AD.Items do
  begin
    if n.Data <> nil then
      if CompareText(ANewDN, PADContainer(n.Data)^.DistinguishedName) = 0 then
      begin
        TreeView_AD.Selected := n;
        Break;
      end;
  end;
end;

procedure TADCmd_MainForm.OnPasswordChange(Sender: TObject;
  AChangeOnLogon: Boolean);
begin
  if Sender is TADObject then
  case apAPI of
    ADC_API_LDAP: TADObject(Sender).Refresh(LDAPBinding, List_Attributes);
    ADC_API_ADSI: TADObject(Sender).Refresh(ADSIBinding, List_Attributes);
  end;
end;

procedure TADCmd_MainForm.OnSettingsApply(Sender: TObject);
var
  i: Integer;
begin
  for i := 0 to ComboBox_DC.Items.Count - 1 do
    TDCInfo(ComboBox_DC.Items.Objects[i]).AdsApi := apAPI;

  if SelectedDC <> nil then
  case apAPI of
    ADC_API_LDAP: ServerBinding(
      SelectedDC.Name,
      LDAPBinding,
      OnEnumerationException
    );

    ADC_API_ADSI: ServerBinding(
      SelectedDC.Name,
      @ADSIBinding,
      OnEnumerationException
    );
  end;

  FFloatingWindow.DisplayDelay := apFWND_DisplayDelay;
  FFloatingWindow.DisplayDuration := apFWND_DisplayDuration;
  FFloatingWindow.DisplayActivity := apFWND_DisplayActivity;
  FFloatingWindow.DisplayStyle := apFWND_DisplayStyle;

  StatusBar.Repaint;
end;

procedure TADCmd_MainForm.OnTargetContainerSelect(Sender: TObject; ACont: TADContainer);
var
  obj: TADObject;
  MsgBoxParam: TMsgBoxParams;
begin
  if ListView_Accounts.Selected = nil
    then Exit;

  obj := List_Obj[ListView_Accounts.Selected.Index];

  try
    case apAPI of
      ADC_API_LDAP: begin
        obj.Move(LDAPBinding, ACont.DistinguishedName);
        obj.Refresh(LDAPBinding, List_Attributes);
      end;

      ADC_API_ADSI: begin
        obj.Move(ACont.DistinguishedName);
        obj.Refresh(ADSIBinding, List_Attributes);
      end;
    end;

    if Sender <> nil
      then if Sender is TForm
        then TForm(Sender).Close;
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

procedure TADCmd_MainForm.OnADObjectRefresh(Sender: TObject);
begin
  if Sender is TADObject
    then if apEventsStorage = CTRL_EVENT_STORAGE_DISK
      then TADObject(Sender).LoadEventsFromFile(apEventsDir);

  List_ObjFull.Filter.Apply;
  List_Obj.SortObjects;

  if List_Obj.Contains(TADObject(Sender))
    then ListView_Accounts.Selected := ListView_Accounts.Items[List_Obj.IndexOf(TADObject(Sender))];

  if (Sender is TADObject) then
  try
    ListView_AccountsChange(
      Self,
      ListView_Accounts.Items[List_Obj.IndexOf(TADObject(Sender))],
      ctState
    );
  except
    ListView_AccountsChange(
      Self,
      nil,
      ctState
    );
  end;
end;

procedure TADCmd_MainForm.OnAttrCatalogSave(Sender: TObject);
begin
  ArrangeColumns(TAttrCatalog(Sender));
end;

procedure TADCmd_MainForm.OnComputerChange(Sender: TObject);
begin
  if Sender is TADObject then
  begin
    case apAPI of
      ADC_API_LDAP: TADObject(Sender).Refresh(LDAPBinding, List_Attributes);
      ADC_API_ADSI: TADObject(Sender).Refresh(ADSIBinding, List_Attributes);
    end;
  end;
end;

procedure TADCmd_MainForm.OnUserChange(Sender: TObject);
begin
  if Sender is TADObject then
  begin
    case apAPI of
      ADC_API_LDAP: TADObject(Sender).Refresh(LDAPBinding, List_Attributes);
      ADC_API_ADSI: TADObject(Sender).Refresh(ADSIBinding, List_Attributes);
    end;
  end;
end;

procedure TADCmd_MainForm.OnUserCreate(Sender: TObject; AOpenEditor: Boolean);
var
  i: Integer;
begin
  if Sender is TADObject then
  begin
    i := List_ObjFull.Add(TADObject(Sender));

    case apAPI of
      ADC_API_LDAP: List_ObjFull[i].Refresh(LDAPBinding, List_Attributes);
      ADC_API_ADSI: List_ObjFull[i].Refresh(ADSIBinding, List_Attributes);
    end;

    if AOpenEditor then
    begin
      with Form_UserInfo do
      begin
        UserObject := TADObject(Sender);
        OnUserChange := Self.OnUserChange;
        Position := poMainFormCenter;
        Show;
        CallingForm := Self;
      end;

      { Удаляем из окна создания пользователя Form_CreateUser вызывающую форму. }
      { Если этого не сделать, то MainForm останется активной не смотря на то,  }
      { что она должна быть блоктрована формой Form_UserInfo                    }
      Form_CreateUser.CallingForm := nil;
    end;
  end;
end;

procedure TADCmd_MainForm.OnEnumerationComplete(Sender: TObject);
begin
  FProgressBar.Visible := False;
  List_ObjFull.SortObjects;
  List_ObjFull.Filter.Apply;
  ListView_Accounts.Items.Count := List_Obj.Count;
  DrawSortedColumnHeader;
end;

procedure TADCmd_MainForm.OnEnumerationException(AMsg: string; ACode: ULONG);
var
  MsgBoxParam: TMsgBoxParams;
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

    if ACode <> 0
      then lpszText := PChar(AMsg + ' Return code is: ' + IntToStr(ACode))
      else lpszText := PChar(AMsg);
  end;

  MessageBoxIndirect(MsgBoxParam);
end;

procedure TADCmd_MainForm.SaveLastFormState(AIniFile: TFileName);
var
  Ini: TIniFile;
begin
  Ini := TIniFile.Create(AIniFile);

  try
    Ini.WriteInteger(INI_SECTION_STATE, 'FilterOption', Frame_Search.FilterOption);
    Ini.WriteInteger(INI_SECTION_STATE, 'FilterObjects', apFilterObjects);
    if Self.WindowState = wsNormal then
    begin
      Ini.WriteInteger(INI_SECTION_STATE, 'Width', Self.Width);
      Ini.WriteInteger(INI_SECTION_STATE, 'Height', Self.Height);
    end;
    Ini.WriteInteger(INI_SECTION_STATE, 'Top', Self.Top);
    Ini.WriteInteger(INI_SECTION_STATE, 'Left', Self.Left);
    Ini.WriteInteger(INI_SECTION_STATE, 'State', Integer(Self.WindowState));
    Ini.WriteInteger(INI_SECTION_STATE, 'DCTreeWidth', Panel_DC.Width);
  finally
    Ini.Free;
  end;
end;

procedure TADCmd_MainForm.SetComboBoxDropDownWidth(AComboBox: TComboBox;
  AMargin: Word);
var
  Columns: TStringDynArray;
  ItemText: string;
  F: TFont;
  TextWidth: Integer;
  MaxWidth: Integer;
begin
  F := TFont.Create;
  try
    F.Assign(AComboBox.Font);
    MaxWidth := 0;
    for ItemText in AComboBox.Items do
    begin
      F.Style := F.Style + [fsBold];
      Columns := SplitString(ItemText, '|');
      TextWidth := GetTextWidthInPixels(Columns[0], F) + AMargin * 2;
      if Length(Columns) > 1 then
      begin
        F.Style := F.Style - [fsBold];
        TextWidth := TextWidth + 1 + GetTextWidthInPixels(Columns[1], F);
        TextWidth := TextWidth + AMargin * 2;
      end;
      if MaxWidth < TextWidth then MaxWidth := TextWidth;
    end;
  finally
    F.Free;
  end;

  if (MaxWidth > AComboBox.Width) then
  begin
    if AComboBox.DropDownCount < AComboBox.Items.Count
      then MaxWidth := MaxWidth + GetSystemMetrics(SM_CXVSCROLL);
    SendMessage(AComboBox.Handle, CB_SETDROPPEDWIDTH, MaxWidth, 0);
  end;
end;

procedure TADCmd_MainForm.SetInfoColumnWidth;
var
  objCount: Integer;
  C: TCanvas;
  F: TFont;
  w: Integer;
  h: THandle;
  hItem: THDItem;
begin
  try
    objCount := List_Obj.Count;
  except
    objCount := 0;
  end;

  if objCount = 0 then w := 1 else
  begin
    C := ListView_Accounts.Canvas;

    F := TFont.Create;
    try
      F.Assign(ListView_Accounts.Font);
      F.Size := 6;
      F.Style := [fsBold];

      w := GetTextWidthInPixels(
        FormatFloat('#,##0', objCount),
        F
      );
    finally
      F.Free;
    end;

    w := w + 43;
  end;

  ZeroMemory(@hItem, SizeOf(THDItem));
  hItem.Mask := HDI_FORMAT;
  h := ListView_GetHeader(ListView_Accounts.Handle);
  if Header_GetItem(h, 0, hItem) then
  begin
    hItem.Mask := HDI_FORMAT or HDI_WIDTH;
    hItem.fmt := hItem.fmt or HDF_OWNERDRAW or HDF_FIXEDWIDTH;
    hItem.cxy := w;
    Header_SetItem(h, 0, hItem);
  end;
end;

procedure TADCmd_MainForm.SplitterPaint(Sender: TObject);
var
  R: TRect;
  hTop: Integer;
  hBottom: Integer;
begin
  with Sender as TSplitter do
  begin
    { Верхняя часть }
    case Panel_DCTop.AlignWithMargins of
      True : hTop := Panel_DCTop.Height + Panel_DCTop.Margins.Top + Panel_DCTop.Margins.Bottom;
      False: hTop := Panel_DCTop.Height;
    end;
    R := Canvas.ClipRect;
    R.Width := 1;
    OffsetRect(R, Round(Width / 2), 0);
    R.Height := hTop;
    Canvas.Brush.Color := clWhite;
    Canvas.FillRect(R);

    { Нижняя часть }
    if Panel_DCBottom.Visible and Panel_AccountsBottom.Visible then
    case Panel_DCBottom.AlignWithMargins of
      True : hBottom := Panel_DCBottom.Height + Panel_DCBottom.Margins.Top + Panel_DCBottom.Margins.Bottom;
      False: hBottom := Panel_DCBottom.Height;
    end else
    begin
      hBottom := 0;
    end;

    R := Canvas.ClipRect;
    R.Width := 1;
    OffsetRect(R, Round(Width / 2), Height - hBottom);
    Canvas.Brush.Color := clWhite;
    Canvas.FillRect(R);

    { Основная часть }
    R := Canvas.ClipRect;
    R.Height := Height - (hTop + hBottom);
    OffsetRect(R, 0, hTop);
    Canvas.Brush.Color := clWhite;
    Canvas.FillRect(R);
    R.Width := 1;
    OffsetRect(R, Round(Width / 2), 0);
    Canvas.Brush.Color := Color;
    Canvas.FillRect(R);
  end;
end;

procedure TADCmd_MainForm.StatusBarDrawPanel(StatusBar: TStatusBar;
  Panel: TStatusPanel; const Rect: TRect);
var
  offset: Integer;
  panelIcon: Integer;
  panelText: string;
  txtRect: TRect;
begin
  offset := 6;
  txtRect := TRect.Create(Rect.Left + offset, Rect.Top, Rect.Right - offset, Rect.Bottom);
  with StatusBar.Canvas do
  begin
    Brush.Color := TStyleManager.ActiveStyle.GetStyleColor(scWindow);
    FillRect(Rect);
    Font.Size := 8;
    Font.Color := clWindowText;
    Font.Style := [];
    case Panel.Index of
      0: begin
        panelText := FormatFloat('#,##0', List_Obj.Count);
        case (Frame_Search.Edit_SearchPattern.Text = '') of
          True: begin
//            txtRect.Offset(-offset * 2, 0);
            DrawText(Handle, PWideChar(panelText), -1, txtRect, DT_RIGHT or DT_SINGLELINE);
          end;

          False: begin
            panelIcon := 1;
            txtRect.Offset(-(offset + DM1.ImageList_16x16.Width), 0);
            DrawText(Handle, PWideChar(panelText), -1, txtRect, DT_RIGHT or DT_SINGLELINE);

            DM1.ImageList_16x16.Draw(
              StatusBar.Canvas,
              Rect.Right - (offset + DM1.ImageList_16x16.Width),
              Rect.Top - 1,
              panelIcon
            );
          end;
        end;
        txtRect := TRect.Create(Rect.Left + offset, Rect.Top, Rect.Right - offset, Rect.Bottom);
        DrawText(Handle, PWideChar('ЧИСЛО ЗАПИСЕЙ:'), -1, txtRect, DT_LEFT or DT_SINGLELINE);
      end;

      1: begin
        panelText := Panel.Text;
        DrawText(Handle, PWideChar(panelText), -1, txtRect, DT_LEFT or DT_WORD_ELLIPSIS or DT_SINGLELINE);
      end;

      2: begin
        DrawText(Handle, PWideChar(Panel.Text), -1, txtRect, DT_RIGHT or DT_SINGLELINE);
        DrawText(Handle, PWideChar('ПАРОЛЬ ИСТЕКАЕТ:'), -1, txtRect, DT_LEFT or DT_SINGLELINE);
      end;

      3: begin
        DrawText(Handle, PWideChar(Panel.Text), -1, txtRect, DT_RIGHT);
        DrawText(Handle, PWideChar('ОШИБКИ ВВОДА ПАРОЛЯ:'), -1, txtRect, DT_LEFT);
      end;

      4: begin
        case apAPI of
          ADC_API_LDAP: panelText := 'LDAP';
          ADC_API_ADSI: panelText := 'ADSI';
        end;
        Font.Style := Font.Style + [fsBold];
        DrawText(Handle, PWideChar(panelText), -1, txtRect, DT_CENTER or DT_SINGLELINE);
      end;
    end;
  end;
end;

procedure TADCmd_MainForm.TreeView_ADChange(Sender: TObject; Node: TTreeNode);
begin
  if Node <> nil then
  begin
    Label_ADPath.Caption := PADContainer(Node.Data)^.Path;
    List_ObjFull.Filter.ADPath := PADContainer(Node.Data)^.Path;
  end;
end;

procedure TADCmd_MainForm.TreeView_ADCollapsing(Sender: TObject;
  Node: TTreeNode; var AllowCollapse: Boolean);
begin
  if Node.Parent = nil then AllowCollapse := False;
end;

procedure TADCmd_MainForm.TreeView_ADDeletion(Sender: TObject;
  Node: TTreeNode);
begin
  { В узлах дерева хранятся данные типа PADContainerData. Поэтому, }
  { прежде чем очистить дерево/удалить узел, необходимо освободить }
  { память занимаемую этими данными                                }
  if Assigned(Node.Data)
    then Dispose(Node.Data);
  Node.Data := nil;
end;

procedure TADCmd_MainForm.TreeView_ADKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
var
  R: TRect;
  P: TPoint;
begin
  case Key of
    VK_RETURN: begin

    end;

    VK_APPS: begin
      if TreeView_AD.Selected <> nil then
      begin
        TreeView_GetItemRect(TreeView_AD.Handle, TreeView_AD.Selected.ItemId, R, True);
        P := TreeView_AD.ClientToScreen(Point(R.Left, R.Top + R.Height + 1));
        PopupMenu_TreeAD.Popup(P.X, P.Y);
      end;
    end;
  end;
end;

procedure TADCmd_MainForm.TreeView_ADMouseUp(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  Node: TTreeNode;
  P: TPoint;
  mi: TMenuItemEx;
begin
  Node := TreeView_AD.GetNodeAt(X, Y);

  if Node <> nil then
  case Button of
    TMouseButton.mbLeft: begin

    end;

    TMouseButton.mbRight: begin
      PopupMenu_TreeAD.Items.Clear;

      mi := TMenuItemEx.Create(PopupMenu_TreeAD);
      mi.Caption := 'Создать';
      PopupMenu_TreeAD.Items.Add(mi);

      mi := TMenuItemEx.Create(PopupMenu_TreeAD);
      mi.Caption := 'Учетная запись';
      mi.Data := PADContainer(Node.Data);
      mi.OnClick := OnMenuItem_CreateUser;
      mi.Enabled := (Node.IsFirstNode) or (PADContainer(Node.Data)^.CanContainClass('user'));
      PopupMenu_TreeAD.Items[0].Add(mi);

      mi := TMenuItemEx.Create(PopupMenu_TreeAD);
      mi.Caption := 'Подразделение';
      mi.Data := PADContainer(Node.Data);
      mi.OnClick := OnMenuItem_CreateContainer;
      mi.Enabled := (Node.IsFirstNode) or (PADContainer(Node.Data)^.CanContainClass('organizationalUnit'));
      PopupMenu_TreeAD.Items[0].Add(mi);

      mi := TMenuItemEx.Create(PopupMenu_TreeAD);
      mi.Caption := '-';
      PopupMenu_TreeAD.Items.Add(mi);

      mi := TMenuItemEx.Create(PopupMenu_TreeAD);
      mi.Caption := 'Удалить';
      mi.Data := PADContainer(Node.Data);
      mi.OnClick := OnMenuItem_DeleteContainer;
      mi.Enabled := (not Node.IsFirstNode) and (PADContainer(Node.Data)^.CanBeDeleted);
      PopupMenu_TreeAD.Items.Add(mi);

      P := TreeView_AD.ClientToScreen(Point(X, Y));
      PopupMenu_TreeAD.Popup(P.X, P.Y);
    end;

    TMouseButton.mbMiddle: begin

    end;
  end;
end;

procedure TADCmd_MainForm.UpdateDCList;
var
  i: Integer;
  dcStr: string;
begin
  SelectedDC := nil;
  Label_ADPath.Caption := '';
  if ComboBox_DC.ItemIndex > -1
    then dcStr := TDCInfo(ComboBox_DC.Items.Objects[ComboBox_DC.ItemIndex]).DomainDnsName;

  TDCInfo.EnumDomainControllers(ComboBox_DC.Items, apAPI);

  SetComboBoxDropDownWidth(ComboBox_DC, 6);
  if ComboBox_DC.ItemCount > 0
    then ComboBox_DC.ItemIndex := 0;

  if not dcStr.IsEmpty then
  for i := 0 to ComboBox_DC.Items.Count - 1 do
  begin
    if CompareText(dcStr, TDCInfo(ComboBox_DC.Items.Objects[i]).DomainDnsName) = 0 then
    begin
      ComboBox_DC.ItemIndex := i;
      Break;
    end;
  end;

  ComboBox_DCSelect(Self);
end;

procedure TADCmd_MainForm.OnEnumerationProgress(AItem: TObject; AProgress: Integer);
var
  C: TCanvas;
  R: TRect;
  S: string;
begin
  if AItem <> nil
    then if AItem is TADObject then
    begin
      if apEventsStorage = CTRL_EVENT_STORAGE_DISK
        then TADObject(AItem).LoadEventsFromFile(apEventsDir);
    end;

  if AProgress = 0 then
     FProgressBar.Visible := True;

  C := ListView_Accounts.Canvas;
  R := ListView_Accounts.ClientRect;

  FProgressBar.Left := Round((R.Width - FProgressBar.Width) / 2);
  FProgressBar.Top := Round((R.Height - FProgressBar.Height) / 2);

  R.Inflate(
    Round((FProgressBar.Width - R.Width) / 2),
    Round((FProgressBar.Height - R.Height) / 2)
  );
  R.Top := FProgressBar.Top - R.Height * 2 - 10;


  C.Font.Color := clWindowText;
  C.Font.Size := 8;

  S := 'Поиск учетных записей...';
  C.Refresh;
  DrawText(
    C.Handle,
    S,
    Length(S),
    R,
    DT_SINGLELINE or DT_VCENTER or DT_LEFT
  );

  S := FormatFloat('#,##0', AProgress);
  C.Refresh;
  DrawText(
    C.Handle,
    S,
    Length(S),
    R,
    DT_SINGLELINE or DT_VCENTER or DT_RIGHT
  );
end;

procedure TADCmd_MainForm.OnInPlaceEditExit(Sender: TObject);
begin
  with FInPlaceEdit do
  begin
    Hide;
    Clear;
  end;
end;

procedure TADCmd_MainForm.Panel_DCBottomClick(Sender: TObject);
begin
  ListView_Accounts.Items.Count := List_Obj.Count;
end;

procedure TADCmd_MainForm.PingClick(Sender: TObject);
var
  obj: TADObject;
  pcName: string;
  StartInfo: TStartupInfo;
  ProcInfo: TProcessInformation;
  SA: SECURITY_ATTRIBUTES;
  pingCmdLine: string;
  MsgBoxParam: TMsgBoxParams;
  fSuccess: Boolean;
begin
  obj := List_Obj[ListView_Accounts.Selected.Index];

  case obj.ObjectType of
    otUser: pcName := GetUserLogonPCName(obj, List_Attributes, apAttrCat_LogonPCFieldID);
    otWorkstation, otDomainController, otRODomainController: pcName := obj.name;
  end;

  pingCmdLine := 'cmd /k ping -t ' + pcName;
  with SA do
  begin
    nLength := SizeOf(SECURITY_ATTRIBUTES);
    bInheritHandle := True;
    lpSecurityDescriptor := nil;
  end;
  FillChar(StartInfo, SizeOf(StartInfo), #0);
  FillChar(ProcInfo, SizeOf(StartInfo), #0);
  with StartInfo do
  begin
    cb := SizeOf(StartInfo);
    dwFlags := STARTF_USESHOWWINDOW;
    wShowWindow := SW_SHOWNORMAL;
  end;

  fSuccess := CreateProcess(nil,
    PChar(pingCmdLine),
    @SA,
    @SA,
    False,
    0,
    nil,
    nil,
    StartInfo,
    ProcInfo
  );

  if fSuccess then
  begin
////    WaitForSingleObject(ProcInfo.hProcess, INFINITE);
//    case WaitForSingleObject(ProcInfo.hProcess, 15000) of
//      WAIT_TIMEOUT : ;
//      WAIT_FAILED  : ;
//      else ;
//    end;
    CloseHandle(ProcInfo.hProcess);
    CloseHandle(ProcInfo.hThread);
  end else
  begin
    with MsgBoxParam do
    begin
      cbSize := SizeOf(MsgBoxParam);
      hwndOwner := Self.Handle;
      hInstance := 0;
      lpszText := PChar(SysErrorMessage(GetLastError));
      lpszIcon := MAKEINTRESOURCE(32513);
      dwStyle := MB_OK or MB_ICONHAND;
      dwContextHelpId := 0;
      lpfnMsgBoxCallback := nil;
      dwLanguageId := LANG_NEUTRAL;
    end;
    MessageBoxIndirect(MsgBoxParam);
  end;
end;

procedure TADCmd_MainForm.PopupMenu_ListAccPopup(Sender: TObject);
var
  mi: TMenuItem;
  i: Integer;
begin
  for mi in PopupMenu_ListAcc.Items do mi.Enabled := False;
  PopupMenu_ListAcc.Items[MENU_REFRESH].Enabled := True;
  if ListView_Accounts.Selected <> nil then
  begin
    PopupMenu_ListAcc.Items[MENU_PROPERTIES].Enabled := True;

    i := ListView_Accounts.Selected.Index;

    PopupMenu_ListAcc.Items[MENU_DAMEWARE].Enabled :=
      (List_Obj[i].ObjectType in [otWorkstation, otDomainController, otRODomainController])
      or (List_Obj[i].IsUser and (apAttrCat_LogonPCFieldID > -1));

    PopupMenu_ListAcc.Items[MENU_SEND_MESSAGE].Enabled := PopupMenu_ListAcc.Items[MENU_DAMEWARE].Enabled;

    PopupMenu_ListAcc.Items[MENU_PING].Enabled := PopupMenu_ListAcc.Items[MENU_DAMEWARE].Enabled;

    PopupMenu_ListAcc.Items[MENU_COMPUTER_INFO].Enabled := (List_Obj[i].IsUser) and (apAttrCat_LogonPCFieldID > -1);
    PopupMenu_ListAcc.Items[MENU_COMPUTER_INFO].Visible := List_Obj[i].IsUser;

    PopupMenu_ListAcc.Items[MENU_COMPUTER_MANAGEMENT].Enabled := PopupMenu_ListAcc.Items[MENU_DAMEWARE].Enabled;

    PopupMenu_ListAcc.Items[MENU_RENAME].Enabled := True;

    PopupMenu_ListAcc.Items[MENU_DISABLE_ACC].Enabled :=
      List_Obj[i].ObjectType in [otUser, otWorkstation, otDomainController, otRODomainController];
    case List_Obj[i].IsDisabled of
      True: PopupMenu_ListAcc.Items[MENU_DISABLE_ACC].Caption := 'Включить учетную запись';
      False: PopupMenu_ListAcc.Items[MENU_DISABLE_ACC].Caption := 'Отключить учетную запись';
    end;

    PopupMenu_ListAcc.Items[MENU_CHANGE_PWD].Enabled := List_Obj[i].IsUser;

    PopupMenu_ListAcc.Items[MENU_REMOVE_ACC].Enabled := True;

    PopupMenu_ListAcc.Items[MENU_DELETE_ACC].Enabled :=
      List_Obj[i].ObjectType in [otUser, otWorkstation];
  end;
end;

procedure TADCmd_MainForm.QuickMessageClick(Sender: TObject);
var
  obj: TADObject;
  pcName: string;
begin
  if CheckPsExecConfig then
  begin
    obj := List_Obj[ListView_Accounts.Selected.Index];

    with Form_QuickMessage do
    begin
      Edit_Recipient.Text := obj.name;
      ADObject := List_Obj[ListView_Accounts.Selected.Index];

      if List_Obj[ListView_Accounts.Selected.Index].IsUser
        then AddHostName(GetUserLogonPCName(obj, List_Attributes, apAttrCat_LogonPCFieldID));

      CallingForm := Self;
      Position := poMainFormCenter;
      Show;
      ComboBox_Computer.SetFocus;
    end;
  end;
end;

procedure TADCmd_MainForm.WndProc(var Message: TMessage);
var
  DrawItem: TDrawItemStruct;
  CopyData: TCopyDataStruct;
  ResultInfo: array [0..MAX_PATH] of char;
  CloseAction: TCloseAction;
  StartupInfo: TStartupInfo;
begin
  case Message.Msg of
    {
      Обрабатываем WM_DRAWITEM, т.к. есть проблема - меню программы "Инструменты"
      отрисовывает названия своих разделов в статусбаре (известная проблема) если
      панели статусбара имею стиль psOwnerDraw и отрисовываются в ручную в OnDrawPanel
    }
    WM_DRAWITEM: begin
      DrawItem := PDrawItemStruct(Message.LParam)^;
      if DrawItem.hwndItem = StatusBar.Handle then
      begin
        StatusBar.Dispatch(Message);
        { Важно выйти в этом месте, иначе меню все равно отрисуется в статустбаре после inherited }
        Exit;
      end;
    end;

    WM_COPYDATA: begin
      CopyData := PCopyDataStruct(Message.LParam)^;
      StrLCopy(ResultInfo, CopyData.lpData, CopyData.cbData);

      case IndexText(ResultInfo,
        [
          'AUTORUN',
          'SHOW_WINDOW',
          'EXIT_PROGRAMM'
        ]
      ) of
        0: begin
          if apMinimizeAtAutorun then
          begin
            Application.Minimize;
            Application.MainForm.Visible := not apMinimizeToTray;
          end;

          Message.Result := 1;
          { Важно выйти в этом месте, иначе Message.Result примет значение 0 после inherited }
          Exit;
        end;

        1: begin
          DM1.TrayIconMouseDown(Self, mbLeft, [], 0, 0);
//          Application.Restore;
          Message.Result := 1;
          { Важно выйти в этом месте, иначе Message.Result примет значение 0 после inherited }
          Exit;
        end;

        2: begin
          CloseAction := caFree;
          FormClose(Self, CloseAction);
//          Application.Terminate;
          Message.Result := 1;
          { Важно выйти в этом месте, иначе Message.Result примет значение 0 после inherited }
          Exit;
        end;
      end;
    end;
  end;

  inherited;
end;

{ TComboBox }

procedure TComboBox.CN_DrawItem(var Message: TWMDrawItem);
begin
  with Message do
    DrawItemStruct.itemState := DrawItemStruct.itemState and not ODS_FOCUS;

  inherited;
end;

{ TInPlaceEdit }

procedure TInPlaceEdit.Clear;
begin
  inherited;
  FItemIndex := -1;
  FSubItemIndex := -1;
end;

procedure TInPlaceEdit.KeyDown(var Key: Word; Shift: TShiftState);
begin
  inherited;

  if Key = VK_ESCAPE then
  try
    Self.Hide;
    Self.Parent.SetFocus;
  except

  end;
end;

procedure TInPlaceEdit.WMNCPaint(var Msg: TMessage);
var
  hC: HDC;
  C: TCanvas;
  R: TRect;
begin
  hC := GetWindowDC(Handle);
  SaveDC(hC);
  try
    C:= TCanvas.Create;
    try
      C.Handle := hC;
      C.Lock;
      R := Rect(0, 0, Width, Height);
      C.Brush.Color := COLOR_SELBORDER;
      C.Brush.Style := bsSolid;
      C.FrameRect(R);
      InflateRect(R, -1, -1);
      C.Brush.Color := IncreaseBrightness(COLOR_SELBORDER, 85);
      C.FrameRect(R);
    finally
      C.Unlock;
      C.free;
    end;
  finally
    RestoreDC(hC, -1);
    ReleaseDC(Handle, hC);
  end;
end;

end.
