unit fmSettings;

interface

uses
  Winapi.Windows, Winapi.Messages, Winapi.CommCtrl, System.SysUtils, System.Variants,
  System.Classes, Vcl.Forms, Vcl.Controls, Vcl.StdCtrls, Vcl.Graphics, Vcl.ComCtrls,
  System.Rtti, ADC.Types, ADC.Attributes, ADC.Common, ADC.GlobalVar, Vcl.Samples.Spin,
  Vcl.ImgList, Vcl.Grids, Winapi.UxTheme, System.Math, Vcl.ExtCtrls, Winapi.ShellAPI,
  Winapi.ShlObj, Winapi.ActiveX, Vcl.Imaging.pngimage, ADC.DC, JvExControls, JvGradient,
  ADCmdUCMA_TLB, System.StrUtils, System.Win.Registry, System.Types, Vcl.Dialogs,
  System.RegularExpressions, Vcl.ToolWin, ADC.ScriptBtn, ADC.Elevation;

const
  SETTINGS_MENU_GENERAL         = 0;
  SETTINGS_MENU_ATTRIBUTES      = 1;
  SETTINGS_MENU_EVENTS          = 2;
  SETTINGS_MENU_EDITOR          = 3;
  SETTINGS_MENU_FLOATING_WINDOW = 4;
  SETTINGS_MENU_MOUSE_BUTTONS   = 5;
  SETTINGS_MENU_SCRIPT_BUTTONS  = 6;
  {-------------------------    = 7 }
  SETTINGS_MENU_DAMEWARE        = 8;
  SETTINGS_MENU_QUICK_MESSAGES  = 9;

type
  TComboBox = class(Vcl.StdCtrls.TComboBox)
  private
    procedure CN_DrawItem(var Message : TWMDrawItem); message CN_DRAWITEM;
  end;

type
  TForm_Settings = class(TForm)
    PageControl_Settings: TPageControl;
    TabSheet_General: TTabSheet;
    TabSheet_Attributes: TTabSheet;
    LeftMenu: TStringGrid;
    ListView_AttrCatalog: TListView;
    Panel_Bottom: TPanel;
    Button_Cancel: TButton;
    Button_Apply: TButton;
    Button_OK: TButton;
    Button_AttrCatReset: TButton;
    CheckBox_MinimizeToTray: TCheckBox;
    CheckBox_MinimizeAtClose: TCheckBox;
    Panel_Instances: TPanel;
    RadioButton_Instance: TRadioButton;
    RadioButton_AskForAction: TRadioButton;
    CheckBox_AppInstances: TCheckBox;
    Panel_Caption1: TPanel;
    Label1: TLabel;
    Panel_Left: TPanel;
    Panel_Client: TPanel;
    Panel2: TPanel;
    Label2: TLabel;
    Label_AttrCat_Hint1: TLabel;
    TabSheet_Events: TTabSheet;
    Panel1: TPanel;
    Label4: TLabel;
    TabSheet_Editor: TTabSheet;
    Panel3: TPanel;
    Label5: TLabel;
    TabSheet_FloatingWindow: TTabSheet;
    Panel4: TPanel;
    Label6: TLabel;
    TabSheet_Mouse: TTabSheet;
    Panel5: TPanel;
    Label7: TLabel;
    TabSheet_Scripts: TTabSheet;
    Panel6: TPanel;
    Label8: TLabel;
    TabSheet_DameWare: TTabSheet;
    Panel7: TPanel;
    Label9: TLabel;
    TabSheet1: TTabSheet;
    Panel9: TPanel;
    Label11: TLabel;
    TabSheet_Dummy1: TTabSheet;
    Panel10: TPanel;
    Label12: TLabel;
    Label61: TLabel;
    Panel_LMB1: TPanel;
    RadioButton_LMB1: TRadioButton;
    RadioButton_LMB2: TRadioButton;
    Label62: TLabel;
    Image12: TImage;
    Panel_LMB2: TPanel;
    RadioButton_CtrlLMB2: TRadioButton;
    RadioButton_CtrlLMB1: TRadioButton;
    Label66: TLabel;
    Label67: TLabel;
    Image11: TImage;
    Panel13: TPanel;
    Label13: TLabel;
    Image13: TImage;
    Panel14: TPanel;
    Label14: TLabel;
    Image14: TImage;
    Label54: TLabel;
    CheckBox_UseDefPwd: TCheckBox;
    Label56: TLabel;
    Label55: TLabel;
    Edit_Password2: TEdit;
    Edit_Password1: TEdit;
    Label71: TLabel;
    Button_BrowseStorage: TButton;
    Edit_Storage: TEdit;
    Panel11: TPanel;
    RadioButton_StorageDisk: TRadioButton;
    RadioButton_StorageAD: TRadioButton;
    Label72: TLabel;
    Panel12: TPanel;
    Label15: TLabel;
    ComboBox_API: TComboBox;
    Label_API: TLabel;
    Edit_DMRC_dom: TEdit;
    Button_DMRC1: TButton;
    Edit_DMRC_exe: TEdit;
    Label_DMRC_Version: TLabel;
    Label_DMRC1: TLabel;
    Edit_DMRC_pass: TEdit;
    Edit_DMRC_user: TEdit;
    ComboBox_DMRC: TComboBox;
    Label_DMRC_Authorization: TLabel;
    Label_DMRC_Username: TLabel;
    Label_DMRC_Password: TLabel;
    Label_DMRC_Domain: TLabel;
    CheckBox_DMRC_Driver: TCheckBox;
    CheckBox_DMRC_Auto: TCheckBox;
    Panel15: TPanel;
    Label16: TLabel;
    RadioButton_DMRC_Viewer: TRadioButton;
    RadioButton_DMRC_RDP: TRadioButton;
    Edit_PsE_Password: TEdit;
    Label_PsE_Hint2: TLabel;
    Label_PsE_Hint1: TLabel;
    Label_PsE_Password: TLabel;
    Label_PsE_User: TLabel;
    Edit_PsE_User: TEdit;
    CheckBox_PsE_RunAs: TCheckBox;
    CheckBox_PsE_Output: TCheckBox;
    Label_PsE4: TLabel;
    UpDown_PsE_DisplayTime: TUpDown;
    Edit_PsE_DisplayTime: TEdit;
    Label_PsE3: TLabel;
    UpDown_PsE_WaitingTime: TUpDown;
    Edit_PsE_WaitingTime: TEdit;
    Label_PsE2: TLabel;
    Label_PsE_Version: TLabel;
    Label_PsE1: TLabel;
    Button_PsE1: TButton;
    Edit_PsE_exe: TEdit;
    Panel16: TPanel;
    Label18: TLabel;
    Label_PsE9: TLabel;
    Label_PsE10: TLabel;
    Label_PsE11: TLabel;
    Panel17: TPanel;
    Label17: TLabel;
    ComboBox_AttrCat_UserLogonPC: TComboBox;
    Label_AttrCat_Hint2: TLabel;
    ListView_ScriptButtons: TListView;
    Label48: TLabel;
    ToolBar_ScriptButtons: TToolBar;
    ToolButton_ScriptButton_Create: TToolButton;
    Edit_ScriptButtons_Search: TButtonedEdit;
    Label_ScriptButtons_Search: TLabel;
    ToolButton_ScriptButtons_Refresh: TToolButton;
    ToolButton2: TToolButton;
    Button_FWND_UCMA_UnReg: TButton;
    Button_FWND_UCMA_Reg: TButton;
    Label_FWND_Activity_Hint: TLabel;
    CheckBox_FWND_Activity: TCheckBox;
    Label_FWND_Duration_Unit: TLabel;
    UpDown_FWND_Duration: TUpDown;
    Edit_FWND_Duration: TEdit;
    Label_FWND_Duration: TLabel;
    Label_FWND_Delay_Unit: TLabel;
    UpDown_FWND_Delay: TUpDown;
    Edit_FWND_Delay: TEdit;
    Label_FWND_Delay: TLabel;
    CheckBox_FWND_Display: TCheckBox;
    Label3: TLabel;
    ComboBox_FWND_Style: TComboBox;
    CheckBox_Autorun: TCheckBox;
    CheckBox_MinimizeAtAutorun: TCheckBox;
    procedure FormCreate(Sender: TObject);
    procedure LeftMenuDrawCell(Sender: TObject; ACol, ARow: Integer;
      Rect: TRect; State: TGridDrawState);
    procedure LeftMenuSelectCell(Sender: TObject; ACol, ARow: Integer;
      var CanSelect: Boolean);
    procedure FormResize(Sender: TObject);
    procedure LeftMenuMouseWheelDown(Sender: TObject; Shift: TShiftState;
      MousePos: TPoint; var Handled: Boolean);
    procedure LeftMenuMouseWheelUp(Sender: TObject; Shift: TShiftState;
      MousePos: TPoint; var Handled: Boolean);
    procedure LeftMenuKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure FormDestroy(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure Button_ApplyClick(Sender: TObject);
    procedure Button_AttrCatResetClick(Sender: TObject);
    procedure CheckBox_AppInstancesClick(Sender: TObject);
    procedure Button_CancelClick(Sender: TObject);
    procedure Button_OKClick(Sender: TObject);
    procedure ListView_AttrCatalogDeletion(Sender: TObject; Item: TListItem);
    procedure TabSheet_AttributesShow(Sender: TObject);
    procedure ListView_AttrCatalogResize(Sender: TObject);
    procedure ListView_AttrCatalogDrawItem(Sender: TCustomListView;
      Item: TListItem; Rect: TRect; State: TOwnerDrawState);
    procedure RadioButton_LMB1Click(Sender: TObject);
    procedure RadioButton_LMB2Click(Sender: TObject);
    procedure RadioButton_CtrlLMB1Click(Sender: TObject);
    procedure RadioButton_CtrlLMB2Click(Sender: TObject);
    procedure RadioButton_StorageDiskClick(Sender: TObject);
    procedure RadioButton_StorageADClick(Sender: TObject);
    procedure Button_BrowseStorageClick(Sender: TObject);
    procedure CheckBox_UseDefPwdClick(Sender: TObject);
    procedure ComboBox_APIDrawItem(Control: TWinControl; Index: Integer;
      Rect: TRect; State: TOwnerDrawState);
    procedure Button_DMRC1Click(Sender: TObject);
    procedure Edit_DMRC_exeChange(Sender: TObject);
    procedure ComboBox_DMRCSelect(Sender: TObject);
    procedure RadioButton_DMRC_ViewerClick(Sender: TObject);
    procedure RadioButton_DMRC_RDPClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure ComboBox_AttrCat_UserLogonPCDrawItem(Control: TWinControl;
      Index: Integer; Rect: TRect; State: TOwnerDrawState);
    procedure Button_PsE1Click(Sender: TObject);
    procedure Edit_PsE_exeChange(Sender: TObject);
    procedure Edit_PsE_WaitingTimeChange(Sender: TObject);
    procedure Edit_PsE_DisplayTimeChange(Sender: TObject);
    procedure CheckBox_PsE_RunAsClick(Sender: TObject);
    procedure ListView_ScriptButtonsDrawItem(Sender: TCustomListView;
      Item: TListItem; Rect: TRect; State: TOwnerDrawState);
    procedure ListView_ScriptButtonsResize(Sender: TObject);
    procedure Edit_ScriptButtons_SearchChange(Sender: TObject);
    procedure Edit_ScriptButtons_SearchRightButtonClick(Sender: TObject);
    procedure ToolButton_ScriptButtons_RefreshClick(Sender: TObject);
    procedure ListView_ScriptButtonsClick(Sender: TObject);
    procedure ListView_ScriptButtonsKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure ToolButton_ScriptButton_CreateClick(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure ListView_ScriptButtonsCustomDraw(Sender: TCustomListView;
      const ARect: TRect; var DefaultDraw: Boolean);
    procedure ListView_ScriptButtonsDblClick(Sender: TObject);
    procedure ListView_ScriptButtonsMouseMove(Sender: TObject;
      Shift: TShiftState; X, Y: Integer);
    procedure CheckBox_FWND_DisplayClick(Sender: TObject);
    procedure Button_FWND_UCMA_RegClick(Sender: TObject);
    procedure Button_FWND_UCMA_UnRegClick(Sender: TObject);
    procedure CheckBox_AutorunClick(Sender: TObject);
  private
    FDMRC_PrevAuth: SmallInt;
    FListViewWndProc_Attributes: TWndMethod;
    FImgList_AttrCatalog: TImageList;
    FCallingForm: TForm;
    FOnSettingsApply: TNotifyEvent;
    FImgList_ScriptButtons: TImageList;
    FScriptButtonList: TADScriptButtonList;
    FScriptButtons: TADScriptButtonList;
    FListViewWndProc_ScriptButtons: TWndMethod;
    procedure ListViewWndProc_ScriptButtons(var Msg: TMessage);
    procedure FillAttrDropDownList;
    procedure RefreshPage_General;
    procedure RefreshPage_DameWare;
    procedure RefreshPage_FloatingWindow;
    procedure BuildAttrCatalogImageList;
    procedure BuildScriptButtonsImageList;
    procedure ScriptButtonListRefresh;
    procedure AlignAttrCatalogColumns;
    procedure AlignAttrCatalogControls;
    procedure ListViewWndProc_Attributes(var Message: TMessage);
    procedure SaveAttributeCatalog;
    procedure OnAttrControlFocus(Sender: TObject);
    procedure OnAttrControlChange(Sender: TObject);
    procedure OnComboBoxDrawItem(Control: TWinControl;
      Index: Integer; Rect: TRect; State: TOwnerDrawState);
    procedure UpdateParameterControls;
    procedure SelectEventsStorage(AOutput: TEdit); overload;
    procedure SelectEventsStorage(AOutput: TEdit; AAttributeType: string); overload;
    procedure SetCallingForm(const Value: TForm);
    procedure OnScriptButtonCreate(Sender: TObject; AButton: TADScriptButton);
    procedure OnScriptButtonChange(Sender: TObject; AButton: PADScriptButton);
    procedure RegisterUCMA(ARegister: Boolean = True);
    procedure RegisterUCMAEx(AElevate: Boolean; ARegister: Boolean = True);
    procedure SetAutorun(AValue: Boolean);
    function GetAutorun: Boolean;
    function IsUCMARegistered: Boolean;
    function GetScriptBtnIconRect_Edit(AListView: TCustomListView; AItemIndex: Integer): TRect;
    function GetScriptBtnIconRect_Delete(AListView: TCustomListView; AItemIndex: Integer): TRect;
  public
    procedure BuildAttributeCatalog(ADC: TDCInfo);
    procedure BuildLeftMenu;
    procedure OpenSettingsMenu(AMenu: Byte);
    property CallingForm: TForm write SetCallingForm;
    property OnSettingsApply: TNotifyEvent read FOnSettingsApply write FOnSettingsApply;
  end;

var
  Form_Settings: TForm_Settings;

implementation

{$R *.dfm}

uses fmMainForm, fmAttrSelection, dmDataModule, fmScriptButton;

function BrowseCallbackProc(hwnd, uMsg, lParam, lpData: Cardinal): Cardinal; stdcall;
var
  Malloc: IMalloc;
  pDesktopFolder: IShellFolder ;
  pidlInitialFolder: PItemIDList;
  CharsDone: ULONG;
  Attr: ULONG;
  szPath: array [0..MAX_PATH] of Char;
begin
  case uMsg of
    BFFM_INITIALIZED: begin
      // Получаем ItemID текущего каталога
      pidlInitialFolder := nil;
      if Succeeded(SHGetDesktopFolder(pDesktopFolder)) then
      pDesktopFolder.ParseDisplayName(
        0,
        nil,
        PWideChar(Form_Settings.Edit_Storage.Text),
        CharsDone,
        pidlInitialFolder,
        Attr
      );

      if pidlInitialFolder <> nil
        then SendMessage(hwnd, BFFM_SETSELECTION, Integer(False), Integer(pidlInitialFolder));

      SHGetMalloc(Malloc);
      Malloc.Free( pidlInitialFolder );
    end;

    BFFM_SELCHANGED: begin
      // Выключаем кнопку "ок" для папок, которые не относятся к файловой системе
      if SHGetPathFromIDList(PItemIDList(lParam), @szPath)
        then SendMessage(hwnd, BFFM_ENABLEOK, 0, 1)
        else SendMessage(hwnd, BFFM_ENABLEOK, 0, 0);
    end;
  end;
  Result := 0;
end;

procedure TForm_Settings.AlignAttrCatalogColumns;
var
  lv: TListView;
  _width: Integer;
begin
  lv := ListView_AttrCatalog;
  lv.Columns[0].Width := lv.Columns[0].MinWidth;
  lv.Columns[3].Width := lv.Columns[3].MinWidth;
  lv.Columns[4].Width := lv.Columns[4].MinWidth;

  _width := lv.Width - (
     lv.Columns[0].Width +
     lv.Columns[3].Width +
     lv.Columns[4].Width
  );

  if lv.BorderStyle = bsSingle
    then _width := _width - GetSystemMetrics(SM_CXEDGE) * 2;

  { Проверяем отображается ли вертикальная полоса прокрутки }
//  if GetWindowLong(ListView_AttrCatalog.Handle, GWL_STYLE) and WS_VSCROLL <> 0
//    then _width := _width - GetSystemMetrics(SM_CYVSCROLL);

  _width := _width - GetSystemMetrics(SM_CYVSCROLL);

  lv.Columns[1].Width := _width div 2;
  lv.Columns[2].Width := _width div 2;

  lv := nil;
end;

procedure TForm_Settings.AlignAttrCatalogControls;
var
  li: TListItem;
  hHeader: HWND;
  rHeader: TRect;
  ctrl: TAttrCatalogControl;
  r: TRect;
begin
  hHeader := SendMessage(ListView_AttrCatalog.Handle, LVM_GETHEADER, 0, 0);
//  hHeader := ListView_GetHeader(ListView_AttrCatalog.Handle);
  GetWindowRect(hHeader, rHeader);

  for li in ListView_AttrCatalog.Items do
  begin
    ctrl := TAttrCatalogControl(li.Data);

    { Рисуем CheckBox }
    ListView_GetItemRect(
      ListView_AttrCatalog.Handle,
      li.Index,
      r,
      LVIR_ICON
    );

    ctrl.Visible := r.Top >= rHeader.Height;
//    ctrl.Visible := r.Top >= ListView_AttrCatalog.ClientRect.Top;

    if not ctrl.Visible then Continue;


    InflateRect(
      r,
      -(r.Width - ctrl.CheckBox.Width) div 2,
      -(r.Height - ctrl.CheckBox.Height) div 2
    );

    ctrl.CheckBox.BoundsRect := r;

    { Рисуем NormalEdit }
    ListView_GetSubItemRect(
      ListView_AttrCatalog.Handle,
      li.Index,
      1,
      LVIR_LABEL,
      @r
    );

    InflateRect(
      r,
      -1,
      -(r.Height - ctrl.NormalEdit.Height) div 2
    );

    ctrl.NormalEdit.BoundsRect := r;

    { Рисуем ComboBox_Alignment }
    ListView_GetSubItemRect(
      ListView_AttrCatalog.Handle,
      li.Index,
      2,
      LVIR_LABEL,
      @r
    );

    InflateRect(
      r,
      -3,
      -(r.Height - ctrl.ComboBox_Attribute.Height) div 2
    );

    ctrl.ComboBox_Attribute.BoundsRect := r;

    { Рисуем SpinEdit }
    ListView_GetSubItemRect(
      ListView_AttrCatalog.Handle,
      li.Index,
      3,
      LVIR_LABEL,
      @r
    );

    InflateRect(
      r,
      -3,
      -(r.Height - ctrl.SpinEdit.Height) div 2
    );

    ctrl.SpinEdit.BoundsRect := r;

    { Рисуем ComboBox_Alignment }
    ListView_GetSubItemRect(
      ListView_AttrCatalog.Handle,
      li.Index,
      4,
      LVIR_LABEL,
      @r
    );

    InflateRect(
      r,
      -3,
      -(r.Height - ctrl.ComboBox_Alignment.Height) div 2
    );

    ctrl.ComboBox_Alignment.BoundsRect := r;
  end;

  ctrl := nil;
end;

procedure TForm_Settings.ListViewWndProc_Attributes(var Message: TMessage);
type
  LPNMLVSCROLL = ^NMLVSCROLL;
  NMLVSCROLL = record
    hdr: NMHDR;
    dx: Integer;
    dy: Integer;
  end;

var
  msgNotify: TWMNotify absolute Message;
  colWidth: Integer;
begin
  FListViewWndProc_Attributes(Message);

  case msgNotify.Msg of
    WM_KEYDOWN: begin
      AlignAttrCatalogControls;
    end;

    WM_VSCROLL: begin
      if TWMVScroll(Message).ScrollCode = SB_ENDSCROLL then
      begin
//        AlignAttrCatalogControls;
      end;
    end;

    CN_NOTIFY: begin
      case msgNotify.NMHdr^.code of
        LVN_BEGINSCROLL: begin
          // use LPNMLVSCROLL(Message.LParam) if needed...
        end;

        LVN_ENDSCROLL: begin
          AlignAttrCatalogControls;
          // use LPNMLVSCROLL(Message.LParam) if needed...
        end;
      end;
    end;

    WM_NOTIFY: begin
      case PHDNotify(msgNotify.NMHdr)^.Hdr.Code of
        HDN_BEGINTRACK, HDN_BEGINTRACKA: begin
//          DoColumnBeginResize(PHDNotify(AMsg.NMHdr)^.Item);
        end;

        HDN_ENDTRACK, HDN_ENDTRACKA: begin
//          DoColumnResized(PHDNotify(AMsg.NMHdr)^.Item);
        end;

        HDN_ITEMCHANGED, HDN_ITEMCHANGEDA: begin
          AlignAttrCatalogControls;
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
  end;
end;

procedure TForm_Settings.ListViewWndProc_ScriptButtons(var Msg: TMessage);
begin
  ShowScrollBar(ListView_ScriptButtons.Handle, SB_HORZ, False);
//  ShowScrollBar(ListView_ScriptButtons.Handle, SB_VERT, True);
  FListViewWndProc_ScriptButtons(Msg);
end;

procedure TForm_Settings.BuildAttributeCatalog(ADC: TDCInfo);
var
  i: Integer;
  ctx: TRttiContext;
  fCount: Integer;
  attr: PADAttribute;
  li: TListItem;
  attrList: TStrings;
  attrItem: string;
begin
  attrList := TStringList.Create;

  if ADC <> nil then
  begin
    for i := 0 to ADC.UserAttributes.Count - 1 do
    if CompareText(ADC.UserAttributes.ValueFromIndex[i], ATTR_TYPE_DIRECTORY_STRING) = 0
      then attrList.Add(ADC.UserAttributes.Names[i]);
  end;

  ctx := TRttiContext.Create;
  try
    fCount := Length(ctx.GetType(TypeInfo(TADAttribute)).GetFields);
  finally
    ctx.Free;
  end;

  ListView_AttrCatalog.Items.BeginUpdate;
  try
    ListView_AttrCatalog.Items.Clear;

    for attr in List_Attributes do
    begin
      li := ListView_AttrCatalog.Items.Add;
      while li.SubItems.Count < fCount do li.SubItems.Add('');
      li.ImageIndex := -1;
      li.Data := TAttrCatalogControl.Create(ListView_AttrCatalog, attr, attrList);
      TAttrCatalogControl(li.Data).OnFocus := OnAttrControlFocus;
      TAttrCatalogControl(li.Data).OnChange := OnAttrControlChange;
    end;
  finally
    ListView_AttrCatalog.Items.EndUpdate;
  end;

  attrList.Free;
end;

procedure TForm_Settings.BuildLeftMenu;
var
  i: Integer;
  miCaption: string;
begin
  LeftMenu.RowCount := 10;
  for i := 0 to LeftMenu.RowCount - 1 do
  begin
    case i of
       SETTINGS_MENU_GENERAL         : miCaption := 'Общие';
       SETTINGS_MENU_ATTRIBUTES      : miCaption := 'Поля и атрибуты';
       SETTINGS_MENU_EVENTS          : miCaption := 'Контроль событий пользователя';
       SETTINGS_MENU_EDITOR          : miCaption := 'Редактор учетных записей';
       SETTINGS_MENU_FLOATING_WINDOW : miCaption := 'Плавающее окно';
       SETTINGS_MENU_MOUSE_BUTTONS   : miCaption := 'Мышь';
       SETTINGS_MENU_SCRIPT_BUTTONS  : miCaption := 'Кнопки выполнения скриптов';
       SETTINGS_MENU_DAMEWARE        : miCaption := 'DameWare';
       SETTINGS_MENU_QUICK_MESSAGES  : miCaption := 'Быстрые сообщения';
       else miCaption := '-';
    end;
    LeftMenu.Cells[0, i] := miCaption;
  end;

  if GetWindowLong(LeftMenu.Handle, GWL_STYLE) and WS_VSCROLL <> 0
    then LeftMenu.ColWidths[0] := LeftMenu.Width - GetSystemMetrics(SM_CYVSCROLL)
    else LeftMenu.ColWidths[0] := LeftMenu.Width;
end;

procedure TForm_Settings.BuildScriptButtonsImageList;
const
  AC_IMAGE_SIZE = 81;
begin
  FImgList_ScriptButtons := TImageList.Create(Self);
  FImgList_ScriptButtons.SetSize(AC_IMAGE_SIZE, AC_IMAGE_SIZE);
  FImgList_ScriptButtons.ColorDepth := cd32bit;
  ListView_ScriptButtons.SmallImages := FImgList_ScriptButtons;
end;

procedure TForm_Settings.Button_PsE1Click(Sender: TObject);
var
  MajorVersion, MinorVersion, BuildNumber, RevisionNumber: Cardinal;
begin
  with DM1.OpenDialog do
  begin
    FileName := '';
    Filter := 'Sysinternals PsExec|psexec.exe|Приложения (*.exe)|*.exe|Все файлы (*.*)|*.*';
    FilterIndex := 1;
    Options := Options - [ofAllowMultiSelect];
    if Execute then
    begin
      Edit_PsE_exe.Text := FileName;
    end;
  end;
end;

procedure TForm_Settings.Button_ApplyClick(Sender: TObject);
var
  i: Integer;
  MsgBoxParam: TMsgBoxParams;
  hr: HRESULT;
  tmpBoolean: Boolean;
begin
  with MsgBoxParam do
  begin
    cbSize := SizeOf(MsgBoxParam);
    hwndOwner := Self.Handle;
    hInstance := 0;
    lpszCaption := PChar(APP_TITLE);
    lpszIcon := MAKEINTRESOURCE(32516);
    dwStyle := MB_OK or MB_ICONINFORMATION;
    dwContextHelpId := 0;
    lpfnMsgBoxCallback := nil;
    dwLanguageId := LANG_NEUTRAL;
  end;

  if not string(Edit_Password1.Text).Equals(Edit_Password2.Text) then
  begin
    OpenSettingsMenu(SETTINGS_MENU_EDITOR);
    Edit_Password2.SetFocus;
    MsgBoxParam.lpszText := PChar('Пароли не совпадают.');
    MessageBoxIndirect(MsgBoxParam);
    Exit;
  end;

  { Общие параметры }
  SetAutorun(CheckBox_Autorun.Checked);
  apMinimizeAtAutorun := CheckBox_MinimizeAtAutorun.Checked;
  apMinimizeToTray := CheckBox_MinimizeToTray.Checked;
  apMinimizeAtClose := CheckBox_MinimizeAtClose.Checked;
  apRunSingleInstance := not CheckBox_AppInstances.Checked;
  if RadioButton_Instance.Checked
    then apRunOption := EXEC_NEW_INSTANCE
    else apRunOption := EXEC_PROMPT_ACTION;

  apAPI := ComboBox_API.ItemIndex;


  { Поля и атрибуты }
  SaveAttributeCatalog;

  if ComboBox_AttrCat_UserLogonPC.ItemIndex > 0
    then apAttrCat_LogonPCFieldID := PADAttribute(ComboBox_AttrCat_UserLogonPC.Items.Objects[ComboBox_AttrCat_UserLogonPC.ItemIndex])^.ID
    else apAttrCat_LogonPCFieldID := -1;

  { Контроль событий пользователя }
  if RadioButton_StorageDisk.Checked then
  begin
    apEventsStorage := CTRL_EVENT_STORAGE_DISK;
    apEventsDir := Edit_Storage.Text;
    List_Attributes.ItemByProperty('nearestEvent')^.Name := '';
  end else
  begin
    apEventsStorage := CTRL_EVENT_STORAGE_AD;
    apEventsAttr := Edit_Storage.Text;
    List_Attributes.ItemByProperty('nearestEvent')^.Name := apEventsAttr;
  end;

  { Редактор }
  apUseDefaultPassword := CheckBox_UseDefPwd.Checked;
  apDefaultPassword := Edit_Password1.Text;

  { Плавающее окно }
  apFWND_Display := CheckBox_FWND_Display.Checked;
  apFWND_DisplayDelay := UpDown_FWND_Delay.Position;
  apFWND_DisplayDuration := UpDown_FWND_Duration.Position * 1000;
  apFWND_DisplayActivity := CheckBox_FWND_Activity.Checked;
  if ComboBox_FWND_Style.ItemIndex < 0
    then apFWND_DisplayStyle := TFloatingWindowStyle(0)
    else apFWND_DisplayStyle := TFloatingWindowStyle(ComboBox_FWND_Style.ItemIndex);

  { Мышь }
  if RadioButton_LMB1.Checked
    then apMouseLMBOption := MOUSE_LMB_OPTION1
    else apMouseLMBOption := MOUSE_LMB_OPTION2;

  { Кнопки выполнения скриптов }
  FScriptButtonList.SaveToFile(FileName_ScriptButtons);
  List_ScriptButtons.LoadFromFile(FileName_ScriptButtons);

  { DameWare }
  apDMRC_Executable := Edit_DMRC_exe.Text;
  apDMRC_Authorization := ComboBox_DMRC.ItemIndex;
  if ComboBox_DMRC.ItemIndex = DMRC_AUTH_CURRENTUSER then
  begin
    apDMRC_User := '';
    apDMRC_Password := '';
    apDMRC_Domain := '';
  end else
  begin
    apDMRC_User := Edit_DMRC_user.Text;
    apDMRC_Password := Edit_DMRC_pass.Text;
    apDMRC_Domain := Edit_DMRC_dom.Text;
  end;

  if RadioButton_DMRC_Viewer.Checked
    then apDMRC_Connection := DMRC_CONNECTION_MRC
      else if RadioButton_DMRC_RDP.Checked
        then apDMRC_Connection := DMRC_CONNECTION_RDP;

  apDMRC_Driver := CheckBox_DMRC_Driver.Checked;
  apDMRC_AutoConnect := CheckBox_DMRC_Auto.Checked;

  { PsExec }
  apPsE_Executable := Edit_PsE_exe.Text;
  apPsE_WaitingTime := StrToIntDef(Edit_PsE_WaitingTime.Text, 1);
  apPsE_DisplayTime := StrToIntDef(Edit_PsE_DisplayTime.Text, 0);
  apPsE_ShowOutput := CheckBox_PsE_Output.Checked;
  apPsE_RunAs := CheckBox_PsE_RunAs.Checked;
  case CheckBox_PsE_RunAs.Checked of
    True: begin
      apPsE_User := Edit_PsE_User.Text;
      apPsE_Password := Edit_PsE_Password.Text;
    end;

    False: begin
      apPsE_User := '';
      apPsE_Password := '';
    end;
  end;

  WriteSettings(FileName_Ini);

  FillAttrDropDownList;

  if Assigned(FOnSettingsApply)
    then FOnSettingsApply(Self);
end;

procedure TForm_Settings.Button_AttrCatResetClick(Sender: TObject);
begin
  List_Attributes.LoadDefaults;
  if apEventsStorage = CTRL_EVENT_STORAGE_AD
    then List_Attributes.ItemByProperty('nearestEvent')^.Name := apEventsAttr;
  BuildAttributeCatalog(SelectedDC);
  AlignAttrCatalogControls;
end;

procedure TForm_Settings.Button_BrowseStorageClick(Sender: TObject);
begin
  if RadioButton_StorageDisk.Checked then
  begin
    SelectEventsStorage(Edit_Storage);
  end else
  if RadioButton_StorageAD.Checked then
  begin
    SelectEventsStorage(Edit_Storage, ATTR_TYPE_OCTET_STRING);
  end;
end;

procedure TForm_Settings.Button_CancelClick(Sender: TObject);
begin
  List_Attributes.LoadFromFile(FileName_AttrCat);
  Close;
end;

procedure TForm_Settings.Button_DMRC1Click(Sender: TObject);
var
  MajorVersion, MinorVersion, BuildNumber, RevisionNumber: Cardinal;
begin
  with DM1.OpenDialog do
  begin
    FileName := '';
    Filter := 'DameWare Mini Remote Control|dwrcc.exe|Приложения (*.exe)|*.exe|Все файлы (*.*)|*.*';
    FilterIndex := 1;
    Options := Options - [ofAllowMultiSelect];
    if Execute then
    begin
      Edit_DMRC_exe.Text := FileName;
    end;
  end;
end;

procedure TForm_Settings.Button_FWND_UCMA_RegClick(Sender: TObject);
begin
//  RegisterUCMA;
  RegisterUCMAEx(True, True);
end;

procedure TForm_Settings.Button_FWND_UCMA_UnRegClick(Sender: TObject);
begin
//  RegisterUCMA(False);
  RegisterUCMAEx(True, False);
end;

procedure TForm_Settings.Button_OKClick(Sender: TObject);
begin
  Button_ApplyClick(Self);
  Close;
end;

procedure TForm_Settings.CheckBox_UseDefPwdClick(Sender: TObject);
begin
  Label55.Enabled := CheckBox_UseDefPwd.Checked;
  Label56.Enabled := CheckBox_UseDefPwd.Checked;
  Edit_Password1.Enabled := CheckBox_UseDefPwd.Checked;
  Edit_Password2.Enabled := CheckBox_UseDefPwd.Checked;
  if not CheckBox_UseDefPwd.Checked then
  begin
    Edit_Password1.Clear;
    Edit_Password2.Clear;
  end;
end;

procedure TForm_Settings.ComboBox_DMRCSelect(Sender: TObject);
begin
  RefreshPage_DameWare;
end;

procedure TForm_Settings.ComboBox_AttrCat_UserLogonPCDrawItem(Control: TWinControl;
  Index: Integer; Rect: TRect; State: TOwnerDrawState);
const
  _margin: Integer = 6;
var
  C: TCanvas;
  R: TRect;
  DeviderPos: Integer;
  TextWidth: Integer;
  attr: TADAttribute;
  S: string;
begin
  attr.Title := '';
  attr.Name := '';

  if PADAttribute(ComboBox_AttrCat_UserLogonPC.Items.Objects[Index]) <> nil
    then attr := PADAttribute(ComboBox_AttrCat_UserLogonPC.Items.Objects[Index])^;

  C := ComboBox_AttrCat_UserLogonPC.Canvas;
  DeviderPos := 0;

  { Вычисляем положение отрисовки разделителя }
  if odComboBoxEdit in State
    then DeviderPos := GetTextWidthInPixels(attr.Title, ComboBox_AttrCat_UserLogonPC.Font) + 6
    else DeviderPos := Round(C.ClipRect.Width / 2);

  DeviderPos := DeviderPos + _margin * 2;

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
  if attr.Name <> '' then
  begin
    C.Pen.Width := 1;
    C.MoveTo(DeviderPos, Rect.Top);
    C.LineTo(DeviderPos, Rect.Bottom);
  end;

  { Выводим имя заголовок колонки }
  R := Rect;
  OffsetRect(R, _margin, 1);
  if DeviderPos - _margin < Rect.Right
    then R.Right := DeviderPos - _margin
    else R.Right := Rect.Right;
  with C.Font do
  begin
    Style := C.Font.Style + [fsBold];
    if ( odSelected in State ) or ( odFocused in State )
      then Color := clHighlightText
      else Color := clWindowText;
  end;
  S := attr.Title;
  C.TextRect(R, S, [tfLeft, tfEndEllipsis]);

  { Выводим описание API }
  R := Rect;
  OffsetRect(R, DeviderPos + _margin, 1);
  R.Right := Rect.Right;
  with C.Font do
  begin
    Style := C.Font.Style - [fsBold];
    if ( odSelected in State ) or ( odFocused in State )
      then Color := clHighlightText
      else Color := COLOR_GRAY_TEXT;
  end;
  S := attr.Name;
  C.TextRect(R, S, [tfEndEllipsis]);
end;

procedure TForm_Settings.Edit_DMRC_exeChange(Sender: TObject);
var
  MajorVersion, MinorVersion, BuildNumber, RevisionNumber: Cardinal;
begin
  if GetFileVersionNumber(Edit_DMRC_exe.Text, MajorVersion, MinorVersion, BuildNumber, RevisionNumber)
    then Label_DMRC_Version.Caption := IntToStr(MajorVersion) + '.'
      + IntToStr(MinorVersion) + '.' + IntToStr(BuildNumber) + '.' + IntToStr(RevisionNumber)
    else Label_DMRC_Version.Caption := TEXT_NO_DATA;
end;

procedure TForm_Settings.Edit_PsE_DisplayTimeChange(Sender: TObject);
begin
  if StrToIntDef(Edit_PsE_DisplayTime.Text, 0) > UpDown_PsE_DisplayTime.Max then
  begin
    Edit_PsE_DisplayTime.Text := IntToStr(UpDown_PsE_DisplayTime.Max);
    Edit_PsE_DisplayTime.SelectAll;
  end;
end;

procedure TForm_Settings.Edit_PsE_exeChange(Sender: TObject);
var
  MajorVersion, MinorVersion, BuildNumber, RevisionNumber: Cardinal;
begin
  if GetFileVersionNumber(Edit_PsE_exe.Text, MajorVersion, MinorVersion, BuildNumber, RevisionNumber)
    then Label_PsE_Version.Caption := IntToStr(MajorVersion) + '.'
      + IntToStr(MinorVersion) + '.' + IntToStr(BuildNumber) + '.' + IntToStr(RevisionNumber)
    else Label_PsE_Version.Caption := TEXT_NO_DATA;
end;

procedure TForm_Settings.Edit_PsE_WaitingTimeChange(Sender: TObject);
begin
  if StrToIntDef(Edit_PsE_WaitingTime.Text, 0) > UpDown_PsE_WaitingTime.Max then
  begin
    Edit_PsE_WaitingTime.Text := IntToStr(UpDown_PsE_WaitingTime.Max);
    Edit_PsE_WaitingTime.SelectAll;
  end;
end;

procedure TForm_Settings.Edit_ScriptButtons_SearchChange(Sender: TObject);
var
  sb: PADScriptButton;
begin
  Edit_ScriptButtons_Search.RightButton.Visible := Edit_ScriptButtons_Search.Text <> '';

  ListView_ScriptButtons.Clear;
  FScriptButtons.Clear;
  if Edit_ScriptButtons_Search.Text = '' then
  begin
    for sb in FScriptButtonList do
      FScriptButtons.Add(sb);
  end else
  for sb in FScriptButtonList do
  begin
    if ContainsText(sb^.Title, Edit_ScriptButtons_Search.Text)
    or ContainsText(sb^.Description, Edit_ScriptButtons_Search.Text)
    or ContainsText(sb^.Path, Edit_ScriptButtons_Search.Text)
      then FScriptButtons.Add(sb);
  end;

  ListView_ScriptButtons.Items.Count := FScriptButtons.Count;
  ListView_ScriptButtons.Invalidate;
end;

procedure TForm_Settings.Edit_ScriptButtons_SearchRightButtonClick(
  Sender: TObject);
begin
  Edit_ScriptButtons_Search.Clear;
end;

procedure TForm_Settings.ComboBox_APIDrawItem(Control: TWinControl; Index: Integer;
  Rect: TRect; State: TOwnerDrawState);
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
    Columns := SplitString(ComboBox_API.Items[Index], '|');
    DeviderPos := GetTextWidthInPixels(Columns[0], ComboBox_API.Font) + 6;
  end
  else for ItemText in ComboBox_API.Items do
  begin
    Columns := SplitString(ItemText, '|');
    if Length(Columns) > 0 then
    begin
      TextWidth := GetTextWidthInPixels(Columns[0], ComboBox_API.Font);
      if DeviderPos < TextWidth
        then DeviderPos := TextWidth;
    end;
  end;
  DeviderPos := DeviderPos + _margin * 2;

  ItemText := ComboBox_API.Items[Index];
  Columns := SplitString(ItemText, '|');
  ColCount := Length(Columns);
//  DC := ComboBox_DC.Canvas.Handle;
  C := ComboBox_API.Canvas;
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

  { Выводим имя API }
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

  { Выводим описание API }
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

procedure TForm_Settings.CheckBox_AppInstancesClick(Sender: TObject);
var
  i: Integer;
begin
  for i := 0 to Panel_Instances.ControlCount - 1 do
  begin
    if Panel_Instances.Controls[i] is TRadioButton
      then Panel_Instances.Controls[i].Enabled := (Sender as TCheckBox).Checked
  end;
end;

procedure TForm_Settings.CheckBox_AutorunClick(Sender: TObject);
begin
  RefreshPage_General;
end;

procedure TForm_Settings.CheckBox_FWND_DisplayClick(Sender: TObject);
begin
  RefreshPage_FloatingWindow;
end;

procedure TForm_Settings.CheckBox_PsE_RunAsClick(Sender: TObject);
begin
  Label_PsE_User.Enabled := CheckBox_PsE_RunAs.Checked;
  Label_PsE_Password.Enabled := CheckBox_PsE_RunAs.Checked;
  Label_PsE_Hint1.Enabled := CheckBox_PsE_RunAs.Checked;
  Label_PsE_Hint2.Enabled := CheckBox_PsE_RunAs.Checked;
  Edit_PsE_User.Enabled := CheckBox_PsE_RunAs.Checked;
  Edit_PsE_Password.Enabled := CheckBox_PsE_RunAs.Checked;
end;

procedure TForm_Settings.BuildAttrCatalogImageList;
const
  AC_IMAGE_SIZE = 25;
begin
  FImgList_AttrCatalog := TImageList.Create(Self);
  FImgList_AttrCatalog.SetSize(AC_IMAGE_SIZE, AC_IMAGE_SIZE);
  FImgList_AttrCatalog.ColorDepth := cd32bit;
  ListView_AttrCatalog.SmallImages := FImgList_AttrCatalog;
end;

procedure TForm_Settings.FillAttrDropDownList;
var
  i: Integer;
  idx: Integer;
  attr: TADAttribute;
begin
  ComboBox_AttrCat_UserLogonPC.Items.Clear;
  ComboBox_AttrCat_UserLogonPC.Items.AddObject(IntToStr(-1), nil);
  ComboBox_AttrCat_UserLogonPC.ItemIndex := 0;

  for i := 0 to List_Attributes.Count - 1 do
  begin
    attr := List_Attributes[i]^;
    if (not attr.ReadOnly) and (not string(attr.Name).IsEmpty) and (attr.Visible) then
    begin
      idx := ComboBox_AttrCat_UserLogonPC.Items.AddObject(
        IntToStr(attr.ID),
        TObject(List_Attributes[i])
      );

      if attr.ID = apAttrCat_LogonPCFieldID
        then ComboBox_AttrCat_UserLogonPC.ItemIndex := idx;
    end;
  end;
end;

procedure TForm_Settings.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  if FCallingForm <> nil then
  begin
    FCallingForm.Enabled := True;
    FCallingForm.Show;
  end;
  FCallingForm := nil;
  FOnSettingsApply := nil;
end;

procedure TForm_Settings.FormCreate(Sender: TObject);
begin
  FScriptButtonList := TADScriptButtonList.Create;
  FScriptButtons := TADScriptButtonList.Create(False);
  BuildAttrCatalogImageList;
  BuildScriptButtonsImageList;
  FListViewWndProc_Attributes := ListView_AttrCatalog.WindowProc;
  ListView_AttrCatalog.WindowProc := ListViewWndProc_Attributes;
  FListViewWndProc_ScriptButtons := ListView_ScriptButtons.WindowProc;
  ListView_ScriptButtons.WindowProc := ListViewWndProc_ScriptButtons;
  ComboBox_FWND_Style.OnDrawItem := OnComboBoxDrawItem;
  ComboBox_DMRC.OnDrawItem := OnComboBoxDrawItem;
end;

procedure TForm_Settings.FormDestroy(Sender: TObject);
begin
  FImgList_AttrCatalog.Free;
  FScriptButtons.Free;
  FScriptButtonList.Free;
  FImgList_ScriptButtons.Free;
end;

procedure TForm_Settings.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  case PageControl_Settings.ActivePageIndex of
    SETTINGS_MENU_SCRIPT_BUTTONS: begin
      ListView_ScriptButtonsKeyDown(Self, Key, Shift);
    end;
  end;
end;

procedure TForm_Settings.FormResize(Sender: TObject);
begin
  BuildLeftMenu;
end;

procedure TForm_Settings.FormShow(Sender: TObject);
begin
  UpdateParameterControls;
//  SendMessage(ListView_AttrCatalog.Handle, LVM_SETCALLBACKMASK, LVIS_FOCUSED, 0);
end;

function TForm_Settings.GetAutorun: Boolean;
var
  Reg: TRegistry;
  Res: Boolean;
  s: string;
  regEx: TRegEx;
begin
  Reg := TRegistry.Create(KEY_ALL_ACCESS);
  Reg.RootKey := HKEY_CURRENT_USER;
  Res := Reg.OpenKey('Software\Microsoft\Windows\CurrentVersion\Run', False);
  if not Res then Result := False else
  begin
    Res := Reg.ValueExists('AD Commander');
    if not Res then Result := False else
    begin
      s := Reg.ReadString('AD Commander');
      regEx := TRegEx.Create('(?:[A-z]\:|\\)(\\[\w\-\s\.]+)+\.\w+');
      Result := CompareText(regEx.Match(s).Value, Application.ExeName) = 0;
    end;
  end;
  Reg.CloseKey;
  Reg.Free;
end;

function TForm_Settings.GetScriptBtnIconRect_Delete(AListView: TCustomListView;
  AItemIndex: Integer): TRect;
var
  R: TRect;
  h: Integer;
begin
  ListView_GetSubItemRect(AListView.Handle, AItemIndex, 2, LVIR_LABEL, @R);
  R.Inflate((16 - R.Width) div 2, (16 - R.Height) div 2);
  R.Offset(-10, 0);

//  ListView_GetSubItemRect(AListView.Handle, AItemIndex, 2, LVIR_LABEL, @R);
//  h := (R.Height - 32) div 3;
//  R.Inflate((16 - R.Width) div 2, -h);
//  R.Height := 16;
//  R.Offset(-8, 0);

  Result := R;
end;

function TForm_Settings.GetScriptBtnIconRect_Edit(AListView: TCustomListView;
  AItemIndex: Integer): TRect;
var
  R: TRect;
  h: Integer;
begin
  ListView_GetSubItemRect(AListView.Handle, AItemIndex, 1, LVIR_LABEL, @R);
  R.Inflate((16 - R.Width) div 2, (16 - R.Height) div 2);
  R.Offset(-8, 0);

//  ListView_GetSubItemRect(AListView.Handle, AItemIndex, 2, LVIR_LABEL, @R);
//  h := (R.Height - 32) div 3;
//  R.Inflate((16 - R.Width) div 2, -(h * 2 + 16));
//  R.Height := 16;
//  R.Offset(-8, 0);

  Result := R;
end;

function TForm_Settings.IsUCMARegistered: Boolean;
var
  ClassID: TGUID;
  hRes: Integer;
begin
  ClassID := TGUID.Empty;
  hRes := CLSIDFromProgID(PChar('ADCommander.UCMA'), ClassID);
  Result := hRes = 0;
end;

procedure TForm_Settings.LeftMenuDrawCell(Sender: TObject; ACol, ARow: Integer;
  Rect: TRect; State: TGridDrawState);
const
  DEF_ITEM_HEIGHT = 32;
var
  sg: TStringGrid;
  C: TCanvas;
  R: TRect;
  S: string;
begin
  sg := (Sender as TStringGrid);
  C := sg.Canvas;
  if sg.Cells[0, ARow] = '-' then
  begin
    sg.RowHeights[ARow] := 1;
    R := Rect;
    C.FillRect(R);
    InflateRect(
      R,
      -8,
      0
    );
    C.Brush.Color := clSilver;
    C.FillRect(R);
  end else
  begin
    sg.RowHeights[ARow] := DEF_ITEM_HEIGHT;
    R := Rect;

    if gdSelected in State then
    begin
      C.Font.Color := clBlack;
      C.Brush.Color := clSilver;
    end else
    begin
      C.Font.Color := $00333333;
      C.Brush.Color := sg.Color;
    end;
    C.FillRect(R);

    R := Rect;
    S := sg.Cells[ACol, ARow];
    InflateRect(
      R,
      -(R.Height - C.TextHeight(S)) div 2,
      -(R.Height - C.TextHeight(S)) div 2
    );
    C.TextRect(R, S, [tfEndEllipsis]);

//    if gdFocused in State then
//    begin
//      C.Brush.Color := clGray;
//      C.FrameRect(Rect);
//    end;
  end;
  sg := nil;
end;

procedure TForm_Settings.LeftMenuKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
var
  sg: TStringGrid;
  iRow: Integer;
begin
  sg := (Sender as TStringGrid);
  case Key of
    VK_PRIOR, VK_NEXT, VK_UP, VK_DOWN: begin
      case Key of
        VK_PRIOR, VK_UP: begin
          if (sg.Row > 0) and ( sg.Cells[0, sg.Row - 1] = '-')
            then iRow := sg.Row - 2
            else iRow := sg.Row - 1;
        end;

        VK_NEXT, VK_DOWN: begin
          if sg.Cells[0, sg.Row + 1] = '-'
            then iRow := sg.Row + 2
            else iRow := sg.Row + 1;
        end;
      end;
      if iRow in [0..sg.RowCount - 1] then sg.Row := iRow;
      Key := 0;
    end;
  end;
  sg := nil;
end;

procedure TForm_Settings.LeftMenuMouseWheelDown(Sender: TObject;
  Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
begin
  (Sender as TStringGrid).Perform(WM_VSCROLL, SB_LINEDOWN, 0);
  Handled := True;
end;

procedure TForm_Settings.LeftMenuMouseWheelUp(Sender: TObject;
  Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
begin
  (Sender as TStringGrid).Perform(WM_VSCROLL, SB_LINEUP, 0);
  Handled := True;
end;

procedure TForm_Settings.LeftMenuSelectCell(Sender: TObject; ACol,
  ARow: Integer; var CanSelect: Boolean);
begin
  if (Sender as TStringGrid).Cells[0, ARow] = '-' then
  begin
    CanSelect := False;
  end;

  PageControl_Settings.ActivePageIndex := ARow;
end;

procedure TForm_Settings.ListView_AttrCatalogDeletion(Sender: TObject;
  Item: TListItem);
begin
  if Item.Data <> nil
    then TAttrCatalogControl(Item.Data).Free;
  Item.Data := nil;
end;

procedure TForm_Settings.ListView_AttrCatalogDrawItem(Sender: TCustomListView;
  Item: TListItem; Rect: TRect; State: TOwnerDrawState);
var
  C: TCanvas;
  R: TRect;
begin
  C := Sender.Canvas;
  R := Rect;

  R.Width := R.Width - 2;
  R.Height := R.Height - 1;

  case Item.Selected of
    True : C.Pen.Color := COLOR_SELBORDER;
    False: C.Pen.Color := clWindow;
  end;

  C.Brush.Color := clWindow;
  C.Pen.Width := 1;
  C.Polygon(
    [
      R.TopLeft,
      Point(R.BottomRight.X, R.TopLeft.Y),
      R.BottomRight,
      Point(R.TopLeft.X, R.BottomRight.Y)
    ]
  );
end;

procedure TForm_Settings.ListView_AttrCatalogResize(Sender: TObject);
begin
  AlignAttrCatalogColumns;
end;

procedure TForm_Settings.ListView_ScriptButtonsClick(Sender: TObject);
var
  hts : THitTests;
  lvCursosPos : TPoint;
  li : TListItem;
  R1: TRect;
  R2: TRect;
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
      { Положение значка "Измнить" }
      R1 := GetScriptBtnIconRect_Edit(li.ListView, li.Index);

      { Положение значка "Удалить" }
      R2 := GetScriptBtnIconRect_Delete(li.ListView, li.Index);

      if PtInRect(R1, lvCursosPos) then
      begin
        Key := VK_RETURN;
        ListView_ScriptButtonsKeyDown(ListView_ScriptButtons, Key, [])
      end else if PtInRect(R2, lvCursosPos) then
      begin
        Key := VK_DELETE;
        ListView_ScriptButtonsKeyDown(ListView_ScriptButtons, Key, [ssCtrl]);
      end;
    end;
  end;
end;

procedure TForm_Settings.ListView_ScriptButtonsCustomDraw(
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
  S := 'Кнопки выполнения скриптов еще не созданы';
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
  S := 'Для создания нажмите кнопку "Создать", либо комбинацию клавиш Alt + Insert';
  DrawText(
    C.Handle,
    S,
    Length(S),
    R,
    DT_CENTER or DT_SINGLELINE or DT_VCENTER
  );
end;

procedure TForm_Settings.ListView_ScriptButtonsDblClick(Sender: TObject);
var
  hts : THitTests;
  lvCursosPos : TPoint;
  li : TListItem;
  R1: TRect;
  R2: TRect;
  Key: Word;
  Shift: TShiftState;
begin
  inherited;
  lvCursosPos := ListView_ScriptButtons.ScreenToClient(Mouse.CursorPos) ;
  hts := ListView_ScriptButtons.GetHitTestInfoAt(lvCursosPos.X, lvCursosPos.Y);
  if htOnItem in hts then
  begin
    li := ListView_ScriptButtons.GetItemAt(lvCursosPos.X, lvCursosPos.Y);
    if li <> nil then
    begin
      { Положение значка "Измнить" }
      R1 := GetScriptBtnIconRect_Edit(li.ListView, li.Index);

      { Положение значка "Удалить" }
      R2 := GetScriptBtnIconRect_Delete(li.ListView, li.Index);

      if PtInRect(R2, lvCursosPos) then
      begin
        Key := VK_DELETE;
        Shift := [ssCtrl];
      end else
      begin
        Key := VK_RETURN;
        Shift := [];
      end;

      ListView_ScriptButtonsKeyDown(Self, Key, Shift);
    end;
  end;
end;

procedure TForm_Settings.ListView_ScriptButtonsDrawItem(Sender: TCustomListView;
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

  { Выводим "Файл не найден" }
  if not FileExists(FScriptButtons[Item.Index]^.Path) then
  begin
    C.Font.Color := clGrayText;
    C.Font.Size := 8;
    C.Refresh;
    S := TEXT_FILE_NOT_FOUND;
    DrawText(
      C.Handle,
      S,
      Length(S),
      R,
      DT_RIGHT
    );

    R.Width := R.Width - C.TextWidth(TEXT_FILE_NOT_FOUND) - 12;
  end;

  { Выводим заголовок }
  R.Height := 16;
  C.Font.Color := clWindowText;
  C.Font.Size := 10;
  C.Refresh;
  S := FScriptButtons[Item.Index]^.Title;
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

  if FScriptButtons[Item.Index]^.Description.IsEmpty
    then S := FScriptButtons[Item.Index]^.Title
    else S := FScriptButtons[Item.Index]^.Description;

  DrawText(
    C.Handle,
    S,
    Length(S),
    R,
    DT_LEFT or DT_SINGLELINE or DT_END_ELLIPSIS
  );

  { Выводим путь }
  R.Offset(0, R.Height + 9);
  S := FScriptButtons[Item.Index]^.Path;
  DrawText(
    C.Handle,
    S,
    Length(S),
    R,
    DT_LEFT or DT_VCENTER or DT_SINGLELINE or DT_PATH_ELLIPSIS
  );

//  { Закрашиваем фон иконок }
//  ListView_GetSubItemRect(Sender.Handle, Item.Index, 1, LVIR_LABEL, @R);
//  R.Inflate(0, -3);
//  R.Offset(-3, 0);
//  C.Brush.Color := IncreaseBrightness(clSilver, 80);
//  C.FillRect(R);
//
//  ListView_GetSubItemRect(Sender.Handle, Item.Index, 2, LVIR_LABEL, @R);
//  R.Inflate(0, -3);
//  R.Offset(-3, 0);
//  C.Brush.Color := IncreaseBrightness(clSilver, 80);
//  C.FillRect(R);

//  { Выводим вертикальный разделитель }
//  R := Rect;
//  R.Width := Sender.Column[0].Width - R.Left;
//  R.Inflate(-3, -11);
//  C.Pen.Color := IncreaseBrightness(clSilver, 0);
//  C.Polyline([R.BottomRight, Point(R.BottomRight.X, R.TopLeft.y)]);

  { Выводим иконку "Изменить" }
  R := GetScriptBtnIconRect_Edit(Sender, Item.Index);
  C.Refresh;
  DM1.ImageList_16x16.Draw(
    C,
    R.TopLeft.X,
    R.TopLeft.Y,
    3
  );

  { Выводим иконку "Удалить" }
  R := GetScriptBtnIconRect_Delete(Sender, Item.Index);
  C.Refresh;
  DM1.ImageList_16x16.Draw(
    C,
    R.TopLeft.X,
    R.TopLeft.Y,
    9
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

procedure TForm_Settings.ListView_ScriptButtonsKeyDown(Sender: TObject;
  var Key: Word; Shift: TShiftState);
var
  i: Integer;
  li: TListItem;
  sb: PADScriptButton;
begin
  li := ListView_ScriptButtons.Selected;

  case Key of
    VK_F5: begin
      ToolButton_ScriptButtons_RefreshClick(Self);
    end;

    VK_RETURN: begin
      if li <> nil then
      with Form_ScriptButton do
      begin
        CallingForm := Self;
        Mode := ADC_EDIT_MODE_CHANGE;
        ScriptButton := FScriptButtons[li.Index];
        OnScriptButtonChange := Self.OnScriptButtonChange;
        Position := poMainFormCenter;
        Show;
      end;
    end;

    VK_INSERT: begin
      if ssAlt in Shift
        then ToolButton_ScriptButton_CreateClick(Self);
    end;

    VK_DELETE: begin
      if ssCtrl in Shift then
      begin
        if li <> nil then
        begin
          i := li.Index;
          ListView_ScriptButtons.Clear;
          sb := FScriptButtons[i];
          FScriptButtons.Extract(sb);
          FScriptButtonList.Delete(FScriptButtonList.IndexOf(sb));
          ListView_ScriptButtons.Items.Count := FScriptButtons.Count;

          if ListView_ScriptButtons.Items.Count > 0 then
          begin
            if i in [0..ListView_ScriptButtons.Items.Count - 1]
              then ListView_ScriptButtons.Items[i].Selected := True
              else ListView_ScriptButtons.Items[ListView_ScriptButtons.Items.Count - 1].Selected := True;

            i := ListView_ScriptButtons.Selected.Index;
            ListView_ScriptButtons.Selected.MakeVisible(False);
          end;

//          if ListView_ScriptButtons.Items.Count > 0 then
//          begin
//            if not i in [0..ListView_ScriptButtons.Items.Count - 1]
//              then i := ListView_ScriptButtons.Items.Count - 1;
//
//            ListView_ScriptButtons.Items[i].MakeVisible(False);
//          end;

          ListView_ScriptButtons.Invalidate;
        end;
      end;
    end;
  end;
end;

procedure TForm_Settings.ListView_ScriptButtonsMouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Integer);
var
  P: TPoint;
  R1: TRect;
  R2: TRect;
  li : TLIstItem;
  lvHitInfo: TLVHitTestInfo;
  S: string;
begin
  P := ListView_ScriptButtons.ScreenToClient(Mouse.CursorPos);
  li := ListView_ScriptButtons.GetItemAt(P.X, P.Y);

  if li <> nil then
  begin
    { Положение значка "Измнить" }
    R1 := GetScriptBtnIconRect_Edit(li.ListView, li.Index);

    { Положение значка "Удалить" }
    R2 := GetScriptBtnIconRect_Delete(li.ListView, li.Index);

    if PtInRect(R1, P)
      then S := 'Изменить'
      else if PtInRect(R2, P)
        then S := 'Удалить';

    ListView_ScriptButtons.Hint := S;
  end;

  ListView_ScriptButtons.Hint := S;
  Application.ActivateHint(Mouse.CursorPos);
end;

procedure TForm_Settings.ListView_ScriptButtonsResize(Sender: TObject);
var
  w: Integer;
begin
  w := ListView_ScriptButtons.ClientWidth;
//  if GetWindowLong(ListView_ScriptButtons.Handle, GWL_STYLE) and WS_VSCROLL <> 0
//    then w := w - GetSystemMetrics(SM_CXVSCROLL);
  ListView_ScriptButtons.Columns[1].Width := 32;
  ListView_ScriptButtons.Columns[2].Width := 32;

  ListView_ScriptButtons.Columns[0].Width := w - (
    ListView_ScriptButtons.Columns[1].Width +
    ListView_ScriptButtons.Columns[2].Width
  );
end;

procedure TForm_Settings.OnAttrControlChange(Sender: TObject);
begin

end;

procedure TForm_Settings.OnAttrControlFocus(Sender: TObject);
var
  li: TListItem;
begin
  li := ListView_AttrCatalog.FindData(0, Sender, True, True);
  if li <> nil then
  begin
    li.Selected := True;
    li.MakeVisible(False);
    AlignAttrCatalogControls;
  end;
end;

procedure TForm_Settings.OnComboBoxDrawItem(Control: TWinControl;
  Index: Integer; Rect: TRect; State: TOwnerDrawState);
const
  _margin: Integer = 6;
var
  cb: TComboBox absolute Control;
  Columns: TStringDynArray;
  ColCount: Integer;
  ItemText: string;
  C: TCanvas;
  DrawRect: TRect;
begin
  if Control is TComboBox
    then cb := TComboBox(Control)
    else Exit;


  C := cb.Canvas;
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

  { Выводим текст }
  ItemText := cb.Items[Index];
  begin
    DrawRect := Rect;
    DrawRect.Offset(_margin, 0);
    DrawRect.Top := DrawRect.Top + 1;
    with C.Font do
    begin
      if ( odSelected in State ) or ( odFocused in State )
        then Color := clHighlightText;
//        else Color := clWindowText;
    end;
    C.TextRect(DrawRect, ItemText, [tfVerticalCenter, tfLeft, tfEndEllipsis]);
  end;
end;

procedure TForm_Settings.OnScriptButtonChange(Sender: TObject;
  AButton: PADScriptButton);
var
  idx: Integer;
begin
  Edit_ScriptButtons_SearchChange(Self);

  idx := FScriptButtons.IndexOf(AButton);
  if idx > -1 then
  begin
    ListView_ScriptButtons.Items[idx].Selected := True;
    ListView_ScriptButtons.Selected.MakeVisible(False);
  end;
end;

procedure TForm_Settings.OnScriptButtonCreate(Sender: TObject;
  AButton: TADScriptButton);
var
  sb: PADScriptButton;
  idx: Integer;
begin
  New(sb);
  sb^ := AButton;
  FScriptButtonList.Add(sb);
  Edit_ScriptButtons_SearchChange(Self);

  idx := FScriptButtons.IndexOf(sb);
  if idx > -1 then
  begin
    ListView_ScriptButtons.Items[idx].Selected := True;
    ListView_ScriptButtons.Selected.MakeVisible(False);
  end;
end;

procedure TForm_Settings.OpenSettingsMenu(AMenu: Byte);
var
  CanSelect: Boolean;
begin
  if LeftMenu.Cells[0, AMenu].Equals('-') then Exit;
  CanSelect := True;
  LeftMenu.Col := 0;
  LeftMenu.Row := AMenu;
  LeftMenuSelectCell(LeftMenu, 0, AMenu, CanSelect);
//  LeftMenu.SetFocus;
end;

procedure TForm_Settings.RadioButton_LMB1Click(Sender: TObject);
begin
  RadioButton_CtrlLMB1.Checked := True;
end;

procedure TForm_Settings.RadioButton_LMB2Click(Sender: TObject);
begin
  RadioButton_CtrlLMB2.Checked := True;
end;

procedure TForm_Settings.RadioButton_StorageADClick(Sender: TObject);
begin
  Edit_Storage.Text := apEventsAttr;
end;

procedure TForm_Settings.RadioButton_StorageDiskClick(Sender: TObject);
begin
  Edit_Storage.Text := apEventsDir;
end;

procedure TForm_Settings.RefreshPage_DameWare;
begin
  case FDMRC_PrevAuth of
    DMRC_AUTH_PROPRIETARY: begin
      Edit_DMRC_dom.Text := apDMRC_Domain;
    end;

    DMRC_AUTH_SMARTCARD: begin
      Edit_DMRC_user.Text := apDMRC_User;
      Edit_DMRC_dom.Text := apDMRC_Domain;
    end;

    -1, DMRC_AUTH_CURRENTUSER: begin
      Edit_DMRC_user.Text := apDMRC_User;
      Edit_DMRC_pass.Text := apDMRC_Password;
      Edit_DMRC_dom.Text := apDMRC_Domain;
    end;
  end;

  case ComboBox_DMRC.ItemIndex of
    -1: begin
      Edit_DMRC_user.Text := '';
      Edit_DMRC_pass.Text := '';
      Edit_DMRC_dom.Text := '';
    end;

    DMRC_AUTH_PROPRIETARY: begin
      Edit_DMRC_dom.Text := '';
    end;

    DMRC_AUTH_SMARTCARD: begin
      Edit_DMRC_user.Text := '';
      Edit_DMRC_dom.Text := '';
    end;

    DMRC_AUTH_CURRENTUSER: begin
      Edit_DMRC_user.Text := gvUserName;
      Edit_DMRC_pass.Text := '********';
      Edit_DMRC_dom.Text := gvDomainName;
    end;
  end;

  case ComboBox_DMRC.ItemIndex of
    -1: begin
      ComboBox_DMRC.Enabled := False;
      ComboBox_DMRC.Color := clBtnFace;
      Label_DMRC_Password.Caption := 'Пароль:';
      Edit_DMRC_user.Enabled := False;
      Edit_DMRC_user.Color := clBtnFace;
      Edit_DMRC_pass.Enabled := False;
      Edit_DMRC_pass.Color := clBtnFace;
      Edit_DMRC_dom.Enabled := False;
      Edit_DMRC_dom.Color := clBtnFace;
    end;

    DMRC_AUTH_PROPRIETARY: begin
      ComboBox_DMRC.Enabled := True;
      ComboBox_DMRC.Color := clWindow;
      Label_DMRC_Password.Caption := 'Пароль:';
      Edit_DMRC_user.Enabled := True;
      Edit_DMRC_user.Color := clWindow;
      Edit_DMRC_pass.Enabled := True;
      Edit_DMRC_pass.Color := clWindow;
      Edit_DMRC_dom.Enabled := False;
      Edit_DMRC_dom.Color := clBtnFace;
    end;

    DMRC_AUTH_SMARTCARD: begin
      ComboBox_DMRC.Enabled := True;
      ComboBox_DMRC.Color := clWindow;
      Label_DMRC_Password.Caption := 'PIN-код:';
      Edit_DMRC_user.Enabled := False;
      Edit_DMRC_user.Color := clBtnFace;
      Edit_DMRC_pass.Enabled := True;
      Edit_DMRC_pass.Color := clWindow;
      Edit_DMRC_dom.Enabled := False;
      Edit_DMRC_dom.Color := clBtnFace;
    end;

    DMRC_AUTH_CURRENTUSER: begin
      ComboBox_DMRC.Enabled := True;
      ComboBox_DMRC.Color := clWindow;
      Label_DMRC_Password.Caption := 'Пароль:';
      Edit_DMRC_user.Enabled := False;
      Edit_DMRC_user.Color := clBtnFace;
      Edit_DMRC_pass.Enabled := False;
      Edit_DMRC_pass.Color := clBtnFace;
      Edit_DMRC_dom.Enabled := False;
      Edit_DMRC_dom.Color := clBtnFace;
    end;

    else begin
      ComboBox_DMRC.Enabled := True;
      ComboBox_DMRC.Color := clWindow;
      Label_DMRC_Password.Caption := 'Пароль:';
      Edit_DMRC_user.Enabled := True;
      Edit_DMRC_user.Color := clWindow;
      Edit_DMRC_pass.Enabled := True;
      Edit_DMRC_pass.Color := clWindow;
      Edit_DMRC_dom.Enabled := True;
      Edit_DMRC_dom.Color := clWindow;
    end;
  end;

  FDMRC_PrevAuth := ComboBox_DMRC.ItemIndex;

  if RadioButton_DMRC_RDP.Checked
    then CheckBox_DMRC_Driver.Checked := False;

  CheckBox_DMRC_Driver.Enabled := RadioButton_DMRC_Viewer.Checked;
end;

procedure TForm_Settings.RefreshPage_FloatingWindow;
var
  c: TControl;
  i: Integer;
begin
  for i := 0 to TabSheet_FloatingWindow.ControlCount - 1 do
  begin
    c := TabSheet_FloatingWindow.Controls[i];
    if c.Tag = 1
      then c.Enabled := CheckBox_FWND_Display.Checked;
  end;

  if IsUCMARegistered then
  begin
    Button_FWND_UCMA_Reg.Caption := 'Переустановить';
    Button_FWND_UCMA_UnReg.Enabled := CheckBox_FWND_Display.Checked;
  end else
  begin
    Button_FWND_UCMA_Reg.Caption := 'Установить';
    Button_FWND_UCMA_UnReg.Enabled := False;
  end;
end;

procedure TForm_Settings.RefreshPage_General;
begin
  CheckBox_MinimizeAtAutorun.Enabled := CheckBox_Autorun.Checked;
  if not CheckBox_Autorun.Checked
    then CheckBox_MinimizeAtAutorun.Checked := False;
end;

procedure TForm_Settings.RegisterUCMA(ARegister: Boolean);
const
  ProgID = 'ADCommander.UCMA';
  ClassName = 'ADCommander.UCMA.UCMAContact';
var
  Reg: TRegistry;
  Res: Boolean;
  ClassID: string;
begin
  ClassID := CLASS_UCMAContact.ToString;
  Reg := TRegistry.Create(KEY_WRITE);
  Reg.RootKey := HKEY_CLASSES_ROOT;
  if ARegister then
  begin
    { [HKEY_CLASSES_ROOT\ADCommander.UCMA] }
    Res := Reg.OpenKey(ProgID, True);
    if Res then
    begin
      Reg.WriteString('', ClassName);
    end;
    Reg.CloseKey;

    { [HKEY_CLASSES_ROOT\ADCommander.UCMA\CLSID] }
    Res := Reg.OpenKey(ProgID + '\CLSID', True);
    if Res then
    begin
      Reg.WriteString('', ClassID);
    end;
    Reg.CloseKey;

    { [HKEY_CLASSES_ROOT\CLSID\%ClassID%] }
    Res := Reg.OpenKey('CLSID\' + ClassID, True);
    if Res then
    begin
      Reg.WriteString('', ClassName);
    end;
    Reg.CloseKey;

    { [HKEY_CLASSES_ROOT\CLSID\%ClassID%\InprocServer32] }
    Res := Reg.OpenKey('CLSID\' + ClassID + '\InprocServer32', True);
    if Res then
    begin
      Reg.WriteString('', 'mscoree.dll');
      Reg.WriteString('ThreadingModel', 'Both');
      Reg.WriteString('Class', ClassName);
      Reg.WriteString('Assembly', 'adcmd.ucma, Version=1.0.0.0, Culture=neutral, PublicKeyToken=null');
      Reg.WriteString('RuntimeVersion', 'v2.0.50727');
    end;
    Reg.CloseKey;

    { [HKEY_CLASSES_ROOT\CLSID\%ClassID%\InprocServer32\1.0.0.0] }
    Res := Reg.OpenKey('CLSID\' + ClassID + '\InprocServer32\1.2.0.0', True);
    if Res then
    begin
      Reg.WriteString('Class', ClassName);
      Reg.WriteString('Assembly', 'adcmd.ucma, Version=1.0.0.0, Culture=neutral, PublicKeyToken=null');
      Reg.WriteString('RuntimeVersion', 'v2.0.50727');
    end;
    Reg.CloseKey;

    { [HKEY_CLASSES_ROOT\CLSID\%ClassID%\ProgId] }
    Res := Reg.OpenKey('CLSID\' + ClassID + '\ProgId', True);
    if Res then
    begin
      Reg.WriteString('', ProgId);
    end;
    Reg.CloseKey;

    Res := Reg.OpenKey('CLSID\' + ClassID + '\Implemented Categories\{62C8FE65-4EBB-45E7-B440-6E39B2CDBF29}', True);
    Reg.CloseKey;
  end else
  begin
    Reg.DeleteKey(ProgID + '\CLSID');
    Reg.DeleteKey(ProgID);
    Reg.DeleteKey('CLSID\' + ClassID + '\Implemented Categories\{62C8FE65-4EBB-45E7-B440-6E39B2CDBF29}');
    Reg.DeleteKey('CLSID\' + ClassID + '\Implemented Categories');
    Reg.DeleteKey('CLSID\' + ClassID + '\ProgId');
    Reg.DeleteKey('CLSID\' + ClassID + '\InprocServer32\1.2.0.0');
    Reg.DeleteKey('CLSID\' + ClassID + '\InprocServer32');
    Reg.DeleteKey('CLSID\' + ClassID);
  end;
  Reg.CloseKey;
  Reg.Free;

  RefreshPage_FloatingWindow;
end;

procedure TForm_Settings.RegisterUCMAEx(AElevate: Boolean; ARegister: Boolean);
var
  res: HRESULT;
  MsgBoxParam: TMsgBoxParams;
begin
  if (not IsProcessElevated) and (not AElevate) then
  begin
    with MsgBoxParam do
    begin
      cbSize := SizeOf(MsgBoxParam);
      hwndOwner := Self.Handle;
      hInstance := 0;
      lpszCaption := PChar(APP_TITLE);
      lpszIcon := MAKEINTRESOURCE(32515);
      dwStyle := MB_OK or MB_ICONEXCLAMATION;
      dwContextHelpId := 0;
      lpfnMsgBoxCallback := nil;
      dwLanguageId := LANG_NEUTRAL;
      lpszText := PChar('Hеобходимы права администратора для установки или настройки программы.');
    end;

    MessageBoxIndirect(MsgBoxParam);
    Exit;
  end;

  case ARegister of
    True:
      res := RegisterUCMAComponents(
        Self.Handle,
        PChar(CLASS_UCMAContact.ToString),
        AElevate
      );

    False:
      res := UnregisterUCMAComponents(
        Self.Handle,
        PChar(CLASS_UCMAContact.ToString),
        AElevate
      );
  end;

  if res = S_OK
    then RefreshPage_FloatingWindow;
end;

procedure TForm_Settings.RadioButton_CtrlLMB2Click(Sender: TObject);
begin
  RadioButton_LMB2.Checked := True;
end;

procedure TForm_Settings.RadioButton_DMRC_RDPClick(Sender: TObject);
begin
  ComboBox_DMRC.ItemIndex := -1;
  RefreshPage_DameWare;
end;

procedure TForm_Settings.RadioButton_DMRC_ViewerClick(Sender: TObject);
begin
  ComboBox_DMRC.ItemIndex := DMRC_AUTH_WINLOGON;
  RefreshPage_DameWare;
end;

procedure TForm_Settings.RadioButton_CtrlLMB1Click(Sender: TObject);
begin
  RadioButton_LMB1.Checked := True;
end;

procedure TForm_Settings.SaveAttributeCatalog;
var
  li: TListItem;
begin
  for li in ListView_AttrCatalog.Items do
  begin
    TAttrCatalogControl(li.Data).WriteToCatalog;
  end;

  List_Attributes.SaveToFile(FileName_AttrCat, True);
end;

procedure TForm_Settings.ScriptButtonListRefresh;
var
  i: Integer;
  src: PADScriptButton;
  dst: PADScriptButton;
begin
  ListView_ScriptButtons.Clear;
  FScriptButtons.Clear;
  FScriptButtonList.Clear;

  for src in List_ScriptButtons do
  begin
    New(dst);
    dst^ := src^;
    FScriptButtonList.Add(dst);
  end;

  ListView_ScriptButtonsResize(ListView_ScriptButtons);
  Edit_ScriptButtons_Search.Clear;
//  Edit_ScriptButtons_SearchChange(Self);
end;

procedure TForm_Settings.SelectEventsStorage(AOutput: TEdit);
var
  DestFileName: TFileName;
  pszPath: LPWSTR;
  lpbi: TBrowseInfo;
  pidl, pidlRoot: PItemIDList;
  pcfgaoOut: DWORD;
  i, iImage: Integer;
  pszDisplayName: PWideChar;
begin
  ZeroMemory(@lpbi, SizeOf(lpbi));
  GetMem(pszDisplayName, MAX_PATH);
//  SHParseDisplayName(LPCWSTR('D:\'), nil, pidlRoot, 0, pcfgaoOut);
//  lpbi.pidlRoot := pidlRoot;
  lpbi.hwndOwner := Handle;
  lpbi.pszDisplayName := pszDisplayName;
  lpbi.lpszTitle := LPCWSTR('Выберите каталог');
  lpbi.ulFlags := BIF_RETURNONLYFSDIRS or BIF_NEWDIALOGSTYLE or BIF_NONEWFOLDERBUTTON;
  lpbi.iImage := iImage;
  lpbi.lpfn := @BrowseCallbackProc;

  pidl := SHBrowseForFolder(lpbi);
  if pidl <> nil then
  try
    GetMem(pszPath, MAX_PATH + 1);
    try
      if SHGetPathFromIDList(pidl, pszPath) then
      begin
        AOutput.Text := IncludeTrailingBackslash(pszPath);
        end;
    finally
      FreeMem(pszPath);
    end;
  finally
    CoTaskMemFree(pidl);
  end;
  FreeMem(pszDisplayName);
end;

procedure TForm_Settings.SelectEventsStorage(AOutput: TEdit; AAttributeType: string);
var
  lii: TListItem;
begin
  with Form_AttrSelect do
  begin
    ComboBox_DC.Items.Assign(ADCmd_MainForm.ComboBox_DC.Items);
    ComboBox_DC.ItemIndex := ADCmd_MainForm.ComboBox_DC.ItemIndex;
    OutputField := AOutput;
    AttributeType := AAttributeType;
    CallingForm := Self;
    Position := poMainFormCenter;
    Show;
  end;
  Self.Enabled := False;
end;

procedure TForm_Settings.SetAutorun(AValue: Boolean);
var
  Reg: TRegistry;
  Res: Boolean;
begin
  Reg := TRegistry.Create(KEY_WRITE);
  Reg.RootKey := HKEY_CURRENT_USER;
  Res := Reg.OpenKey('Software\Microsoft\Windows\CurrentVersion\Run', False);
  if Res then
  case AValue of
    True : Reg.WriteString('AD Commander', '"' + Application.ExeName +'" -autorun');
    False: Reg.DeleteValue('AD Commander');
  end;
  Reg.CloseKey;
  Reg.Free;
end;

procedure TForm_Settings.SetCallingForm(const Value: TForm);
begin
  FCallingForm := Value;
  if FCallingForm <> nil
    then FCallingForm.Enabled := False;
end;

procedure TForm_Settings.TabSheet_AttributesShow(Sender: TObject);
begin
  if ListView_AttrCatalog.Items.Count > 0
    then ListView_AttrCatalog.Items[0].MakeVisible(True);

  AlignAttrCatalogControls;
end;

procedure TForm_Settings.ToolButton_ScriptButtons_RefreshClick(Sender: TObject);
begin
  ScriptButtonListRefresh;
end;

procedure TForm_Settings.ToolButton_ScriptButton_CreateClick(Sender: TObject);
begin
  with Form_ScriptButton do
  begin
    CallingForm := Self;
    Mode := ADC_EDIT_MODE_CREATE;
    OnScriptButtonCreate := Self.OnScriptButtonCreate;
    Position := poMainFormCenter;
    Show;
  end;
end;

procedure TForm_Settings.UpdateParameterControls;
var
  i: Integer;
begin
  { Общие параметры }
  for i := 0 to PageControl_Settings.Pages[0].ControlCount - 1 do
    if PageControl_Settings.Pages[0].Controls[i].Tag = -1
      then PageControl_Settings.Pages[0].Controls[i].Hide;

  CheckBox_Autorun.Checked := GetAutorun;
  CheckBox_MinimizeAtAutorun.Checked := apMinimizeAtAutorun;
  CheckBox_MinimizeToTray.Checked := apMinimizeToTray;
  CheckBox_MinimizeAtClose.Checked := apMinimizeAtClose;
  CheckBox_AppInstances.Checked := not apRunSingleInstance;
  case apRunOption of
    EXEC_NEW_INSTANCE : RadioButton_Instance.Checked := True;
    EXEC_PROMPT_ACTION: RadioButton_AskForAction.Checked := True;
  end;
  ComboBox_API.ItemIndex := apAPI;

  RefreshPage_General;

  { Поля и атрибуты }
  AlignAttrCatalogColumns;
  AlignAttrCatalogControls;

  FillAttrDropDownList;

  { Контроль событий пользователя }
  case apEventsStorage of
    CTRL_EVENT_STORAGE_DISK: RadioButton_StorageDisk.Checked := True;
    CTRL_EVENT_STORAGE_AD: RadioButton_StorageAD.Checked := True;
  end;

  { Редактор }
  CheckBox_UseDefPwd.Checked := apUseDefaultPassword;
  CheckBox_UseDefPwdClick(CheckBox_UseDefPwd);
  Edit_Password1.Text := apDefaultPassword;
  Edit_Password2.Text := apDefaultPassword;

  { Плавающее окно }
  CheckBox_FWND_Display.Checked := apFWND_Display;
  UpDown_FWND_Delay.Position := apFWND_DisplayDelay;
  UpDown_FWND_Duration.Position := apFWND_DisplayDuration div 1000;
  CheckBox_FWND_Activity.Checked := apFWND_DisplayActivity;

  if Integer(apFWND_DisplayStyle) in [0..ComboBox_FWND_Style.Items.Count - 1]
    then ComboBox_FWND_Style.ItemIndex := Integer(apFWND_DisplayStyle)
    else ComboBox_FWND_Style.ItemIndex := Integer(TFloatingWindowStyle(0));

  RefreshPage_FloatingWindow;

  { Мышь }
  case apMouseLMBOption of
    MOUSE_LMB_OPTION1: RadioButton_LMB1.Checked := True;
    MOUSE_LMB_OPTION2: RadioButton_LMB2.Checked := True;
  end;

  { Кнопки выполнения скриптов }
  ScriptButtonListRefresh;

  { DameWare }
  Edit_DMRC_exe.Text := apDMRC_Executable;
  ComboBox_DMRC.ItemIndex := apDMRC_Authorization;
  Edit_DMRC_pass.Text := apDMRC_Password;
  Edit_DMRC_user.Text := apDMRC_User;
  Edit_DMRC_dom.Text := apDMRC_Domain;
  CheckBox_DMRC_Driver.Checked := apDMRC_Driver;
  CheckBox_DMRC_Auto.Checked := apDMRC_AutoConnect;
  case apDMRC_Connection of
    DMRC_CONNECTION_MRC: RadioButton_DMRC_Viewer.Checked := True;
    DMRC_CONNECTION_RDP: RadioButton_DMRC_RDP.Checked := True;
  end;
  FDMRC_PrevAuth := apDMRC_Authorization;
  RefreshPage_DameWare;

  { PsExec }
  Edit_PsE_exe.Text := apPsE_Executable;
  UpDown_PsE_WaitingTime.Position := apPsE_WaitingTime;
  UpDown_PsE_DisplayTime.Position := apPsE_DisplayTime;
  CheckBox_PsE_Output.Checked := apPsE_ShowOutput;
  CheckBox_PsE_RunAs.Checked := apPsE_RunAs;
  Edit_PsE_User.Text := apPsE_User;
  Edit_PsE_Password.Text := apPsE_Password;
end;

{ TComboBox }

procedure TComboBox.CN_DrawItem(var Message: TWMDrawItem);
begin
  with Message do
    DrawItemStruct.itemState := DrawItemStruct.itemState and not ODS_FOCUS;

  inherited;
end;

end.
