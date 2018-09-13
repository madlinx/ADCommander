unit ADC.Attributes;

interface

uses
  System.SysUtils, System.Classes, System.Variants, ActiveDs_TLB, Winapi.ActiveX,
  Vcl.Controls, Vcl.StdCtrls, Vcl.Samples.Spin, Winapi.Windows, System.StrUtils,
  Vcl.ComCtrls, Vcl.Graphics, Winapi.UxTheme, Winapi.Messages, JwaDSGetDc, JwaLmApiBuf,
  System.Math, Vcl.Imaging.PNGImage, ADC.Types;

type
  TAttrCheckBox = class(Vcl.StdCtrls.TCheckBox)
//    procedure WMNCPaint(var Msg: TMessage); message WM_NCPAINT;
  end;

  TAttrEdit = class(Vcl.StdCtrls.TEdit)
    procedure WMNCPaint(var Msg: TMessage); message WM_NCPAINT;
  end;

  TAttrComboBox = class(Vcl.StdCtrls.TComboBox)
  private
    procedure CNDrawItem(var Message : TWMDrawItem); message CN_DRAWITEM;
    procedure WMPaint(var Msg: TMessage); message WM_PAINT;
    procedure WMNCPaint(var Msg: TMessage); message WM_NCPAINT;
  end;

  TAttrSpinEdit = class(Vcl.Samples.Spin.TSpinEdit)
  protected
    procedure Change; override;
  private
    procedure WMNCPaint(var Msg: TMessage); message WM_NCPAINT;
  end;

type
  TAttrCatalog = class(TList)
  private
    FOwnsObjects: Boolean;
    FOnSave: TNotifyEvent;
    function Get(Index: Integer): PADAttribute;
  protected
    destructor Destroy; override;
  public
    constructor Create(AOwnsObjects: Boolean = True); reintroduce;
    function Add(Value: PADAttribute): Integer;
    function GetObjPropertyByAttrubute(AAttr: string): string;
    function GetAttrubuteByObjProperty(AProperty: string): string;
    function ItemByID(ID: Integer): PADAttribute;
    function ItemByProperty(APropertyName: string): PADAttribute;
    function VisibleCount: Integer;
    function AsIStream: IStream;
    procedure Clear; override;
    procedure LoadDefaults;
    procedure LoadFromFile(AFileName: TFileName);
    procedure SaveToFile(AFileName: TFileName; ARaiseEvent: Boolean = False);
    procedure LoadFromStream(AStream: TStream);
    procedure SaveToStream(AStream: TStream);
    property Items[Index: Integer]: PADAttribute read Get; default;
    property OnSave: TNotifyEvent read FOnSave write FOnSave;
    property OwnsObjects: Boolean read FOwnsObjects write FOwnsObjects;
  end;

type
  TAttrCatalogControl = class(TObject)
  strict private
    const
      pngHex_AlignLeft = (
        '0954506E67496D61676589504E470D0A1A0A0000000D49484452000000100000' +
        '001008060000001FF3FF610000002F4944415478DA6364A010300E0E038A8A8A' +
        'FE93A3B9AFAF8F71887901E464DAB8806E5EC0E6A521E685411C0B9400000847' +
        '1011C32CEAC90000000049454E44AE426082'
      );

      pngHex_AlignCenter = (
        '0954506E67496D61676589504E470D0A1A0A0000000D49484452000000100000' +
        '001008060000001FF3FF61000000304944415478DA6364A010300E0E038A8A8A' +
        'FE93A3B9AFAF8F719078010688F50AC8E9B47101D9068CC6C260F202390000C8' +
        '3810115E77CB9F0000000049454E44AE426082'
      );

      pngHex_AlignRight = (
        '0954506E67496D61676589504E470D0A1A0A0000000D49484452000000100000' +
        '001008060000001FF3FF610000002C4944415478DA6364A010300E0E038A8A8A' +
        'FE93A3B9AFAF8F719078011D10EBA541E485D158188C5E2005000088381011B6' +
        '989E460000000049454E44AE426082'
      );
  private
    FParent: TWinControl;
    FAttr: PADAttribute;
    FEnabled: Boolean;
    FVisible: Boolean;
    FReadOnly: Boolean;
    FIcon_AlignLeft: TPngImage;
    FIcon_AlignCenter: TPngImage;
    FIcon_AlignRight: TPngImage;
    FCheckBox: TAttrCheckBox;
    FEdit: TAttrEdit;
    FComboBox_Attribute: TAttrComboBox;
    FSpinEdit: TAttrSpinEdit;
    FComboBox_Alignment: TAttrComboBox;
    FOnFocus: TNotifyEvent;
    FOnChange: TNotifyEvent;
    FComboBoxWndProc_Attribute: TWndMethod;
    FComboBoxWndProc_Alignment: TWndMethod;
    procedure HexStringToPNGImage(AHexString: string; out AImage: TPngImage);
    procedure OnComboBoxDrawItem_Alignment(Control: TWinControl; Index: Integer;
      Rect:TRect; State: TOwnerDrawState);
    procedure OnControlFocus(Sender: TObject);
    procedure OnControlChange(Sender: TObject);
    procedure OnComboBoxDropDown_Attribute(Sender: TObject);
    procedure OnComboBoxDropDown_Alignment(Sender: TObject);
    procedure OnComboBoxResize(Sender: TObject);
    procedure ComboBoxWndProc_Alignment(var Message: TMessage);
    procedure ComboBoxWndProc_Attribute(var Message: TMessage);
    procedure SetComboBoxDropDownWidth(AComboBox: TComboBox; AIncrease: Integer = 0);
    procedure SetVisible(AVisible: Boolean);
    procedure SetReadOnly(AReadOnly: Boolean);
    procedure SetEnabled(AEnabled: Boolean);
    procedure SetParent(AParent: TWinControl);
    function IsFocused: Boolean;
  protected
    destructor Destroy; override;
    procedure DoOnFocus; dynamic;
    procedure DoOnChange; dynamic;
  public
    constructor Create(AParent: TWinControl; AAttribute: PADAttribute); reintroduce; overload;
    constructor Create(AParent: TWinControl; AAttribute: PADAttribute;
      AAttrList: TStrings); reintroduce; overload;
    procedure Show;
    procedure SetFocus;
    procedure Hide;
    procedure WriteToCatalog;
    property Attribute: PADAttribute read FAttr;
    property OnChange: TNotifyEvent read FOnChange write FOnChange;
    property OnFocus: TNotifyEvent read FOnFocus write FOnFocus;
  published
    property Parent: TWinControl read FParent write SetParent;
    property Visible: Boolean read FVisible write SetVisible;
    property ReadOnly: Boolean read FReadOnly write SetReadOnly;
    property Enabled: Boolean read FEnabled write SetEnabled;
    property Focused: Boolean read IsFocused;
    property NormalEdit: TAttrEdit read FEdit;
    property ComboBox_Attribute: TAttrComboBox read FComboBox_Attribute;
    property CheckBox: TAttrCheckBox read FCheckBox;
    property SpinEdit: TAttrSpinEdit read FSpinEdit;
    property ComboBox_Alignment: TAttrComboBox read FComboBox_Alignment;
  end;

implementation

function CompareVisibility(Item1, Item2: Pointer): Integer;
begin
  if PADAttribute(Item1)^.Visible and not PADAttribute(Item2)^.Visible
    then Result := -1
  else if not PADAttribute(Item1)^.Visible and PADAttribute(Item2)^.Visible
    then Result := 1
  else Result := CompareText(PADAttribute(Item1)^.Title, PADAttribute(Item2)^.Title);
end;

{ TADAttributeList }

function TAttrCatalog.Add(Value: PADAttribute): Integer;
begin
  Result := inherited Add(Value);
end;

function TAttrCatalog.AsIStream: IStream;
var
  CatatalogStream: TStream;
  AdapterStream: TStreamAdapter;
  StreamPos: LargeUInt;
begin
  CatatalogStream := TMemoryStream.Create;

  try
    Self.SaveToStream(CatatalogStream);
    AdapterStream := TStreamAdapter.Create(CatatalogStream, soOwned);
    AdapterStream.Seek(0, 0, StreamPos);
    Result := AdapterStream as IStream;
  finally

  end;
end;

procedure TAttrCatalog.Clear;
var
  i: Integer;
begin
  if FOwnsObjects
    then for i := Self.Count - 1 downto 0 do
      Dispose(Self.Items[i]);

  inherited Clear;
end;

constructor TAttrCatalog.Create(AOwnsObjects: Boolean);
begin
  inherited Create;

  FOwnsObjects := AOwnsObjects;
end;

destructor TAttrCatalog.Destroy;
begin
  Self.Clear;

  inherited;
end;

function TAttrCatalog.Get(Index: Integer): PADAttribute;
begin
  Result := PADAttribute(inherited Get(Index));
end;

function TAttrCatalog.GetAttrubuteByObjProperty(AProperty: string): string;
var
  i: Integer;
begin
  for i := 0 to Count - 1 do
  if CompareText(AProperty, Self.Items[i]^.ObjProperty) = 0 then
  begin
    Result := Self.Items[i]^.Name;
    Break;
  end;
end;

function TAttrCatalog.ItemByID(ID: Integer): PADAttribute;
var
  i: Integer;
begin
  for i := 0 to Self.Count - 1 do
  if Self.Items[i]^.ID = ID then
  begin
    Result := Self.Items[i];
    Break;
  end;
end;

function TAttrCatalog.ItemByProperty(APropertyName: string): PADAttribute;
var
  i: Integer;
begin
  for i := 0 to Self.Count - 1 do
  if AnsiCompareText(Self.Items[i]^.ObjProperty, APropertyName) = 0 then
  begin
    Result := Self.Items[i];
    Break;
  end;
end;

function TAttrCatalog.GetObjPropertyByAttrubute(AAttr: string): string;
var
  i: Integer;
begin
  for i := 0 to Self.Count - 1 do
  if CompareText(AAttr, Self.Items[i]^.Name) = 0 then
  begin
    Result := Self.Items[i]^.ObjProperty;
    Break;
  end;
end;

procedure TAttrCatalog.LoadDefaults;
var
  attr: PADAttribute;
begin
  Self.Clear;

  New(attr);
  attr^.ID          := 1;
  attr^.Title       := 'Имя';
  attr^.Name        := 'name';
  attr^.Comment     := 'name';
  attr^.ObjProperty := 'name';
  attr^.Visible     := True;
  attr^.Width       := 150;
  attr^.Alignment   := taLeftJustify;
  attr^.BgColor     := clWindow;
  attr^.FontColor   := clWindowText;
  attr^.ReadOnly    := True;
  Self.Add(attr);

  New(attr);
  attr^.ID          := 2;
  attr^.Title       := 'Псевдоним';
  attr^.Name        := 'sAMAccountName';
  attr^.Comment     := '';
  attr^.ObjProperty := 'Attribute01';
  attr^.Visible     := True;
  attr^.Width       := 100;
  attr^.Alignment   := taLeftJustify;
  attr^.BgColor     := clWindow;
  attr^.FontColor   := clWindowText;
  attr^.ReadOnly    := False;
  Self.Add(attr);

  New(attr);
  attr^.ID          := 3;
  attr^.Title       := 'Табельный номер';
  attr^.Name        := 'employeeID';
  attr^.Comment     := '';
  attr^.ObjProperty := 'Attribute02';
  attr^.Visible     := True;
  attr^.Width       := 100;
  attr^.Alignment   := taLeftJustify;
  attr^.BgColor     := clWindow;
  attr^.FontColor   := clWindowText;
  attr^.ReadOnly    := False;
  Self.Add(attr);

  New(attr);
  attr^.ID          := 4;
  attr^.Title       := 'Должность';
  attr^.Name        := 'title';
  attr^.Comment     := '';
  attr^.ObjProperty := 'Attribute03';
  attr^.Visible     := True;
  attr^.Width       := 150;
  attr^.Alignment   := taLeftJustify;
  attr^.BgColor     := clWindow;
  attr^.FontColor   := clWindowText;
  attr^.ReadOnly    := False;
  Self.Add(attr);

  New(attr);
  attr^.ID          := 5;
  attr^.Title       := 'Служебный телефон';
  attr^.Name        := 'telephoneNumber';
  attr^.Comment     := '';
  attr^.ObjProperty := 'Attribute04';
  attr^.Visible     := True;
  attr^.Width       := 120;
  attr^.Alignment   := taLeftJustify;
  attr^.BgColor     := clWindow;
  attr^.FontColor   := clWindowText;
  attr^.ReadOnly    := False;
  Self.Add(attr);

  New(attr);
  attr^.ID          := 6;
  attr^.Title       := 'Компьютер';
  attr^.Name        := 'labelComputer';
  attr^.Comment     := '';
  attr^.ObjProperty := 'Attribute05';
  attr^.Visible     := True;
  attr^.Width       := 100;
  attr^.Alignment   := taLeftJustify;
  attr^.BgColor     := clWindow;
  attr^.FontColor   := clWindowText;
  attr^.ReadOnly    := False;
  Self.Add(attr);

  New(attr);
  attr^.ID          := 7;
  attr^.Title       := 'Описание';
  attr^.Name        := 'description';
  attr^.Comment     := '';
  attr^.ObjProperty := 'Attribute06';
  attr^.Visible     := True;
  attr^.Width       := 150;
  attr^.Alignment   := taLeftJustify;
  attr^.BgColor     := clWindow;
  attr^.FontColor   := clWindowText;
  attr^.ReadOnly    := False;
  Self.Add(attr);

  New(attr);
  attr^.ID          := 8;
  attr^.Title       := 'Вход на рабочие станции';
  attr^.Name        := 'userWorkstations';
  attr^.Comment     := '';
  attr^.ObjProperty := 'Attribute07';
  attr^.Visible     := True;
  attr^.Width       := 150;
  attr^.Alignment   := taLeftJustify;
  attr^.BgColor     := clWindow;
  attr^.FontColor   := clWindowText;
  attr^.ReadOnly    := False;
  Self.Add(attr);

  New(attr);
  attr^.ID          := 9;
  attr^.Title       := 'Размещение';
  attr^.Name        := 'physicalDeliveryOfficeName';
  attr^.Comment     := '';
  attr^.ObjProperty := 'Attribute08';
  attr^.Visible     := True;
  attr^.Width       := 150;
  attr^.Alignment   := taLeftJustify;
  attr^.BgColor     := clWindow;
  attr^.FontColor   := clWindowText;
  attr^.ReadOnly    := False;
  Self.Add(attr);

  New(attr);
  attr^.ID          := 10;
  attr^.Title       := 'Отдел';
  attr^.Name        := 'department';
  attr^.Comment     := '';
  attr^.ObjProperty := 'Attribute09';
  attr^.Visible     := True;
  attr^.Width       := 150;
  attr^.Alignment   := taLeftJustify;
  attr^.BgColor     := clWindow;
  attr^.FontColor   := clWindowText;
  attr^.ReadOnly    := False;
  Self.Add(attr);

  New(attr);
  attr^.ID          := 11;
  attr^.Title       := 'Адрес электронной почты';
  attr^.Name        := 'mail';
  attr^.Comment     := '';
  attr^.ObjProperty := 'Attribute10';
  attr^.Visible     := True;
  attr^.Width       := 150;
  attr^.Alignment   := taLeftJustify;
  attr^.BgColor     := clWindow;
  attr^.FontColor   := clWindowText;
  attr^.ReadOnly    := False;
  Self.Add(attr);

  New(attr);
  attr^.ID          := 12;
  attr^.Title       := 'Событие';
  attr^.Name        := '';
  attr^.Comment     := 'См. "Контроль событий пользователя"';
  attr^.ObjProperty := 'nearestEvent';
  attr^.Visible     := True;
  attr^.Width       := 72;
  attr^.Alignment   := taCenter;
  attr^.BgColor     := clWindow;
  attr^.FontColor   := clWindowText;
  attr^.ReadOnly    := True;
  Self.Add(attr);

  New(attr);
  attr^.ID          := 13;
  attr^.Title       := 'Полный путь AD';
  attr^.Name        := 'canonicalName';
  attr^.Comment     := 'canonicalName';
  attr^.ObjProperty := 'canonicalName';
  attr^.Visible     := True;
  attr^.Width       := 200;
  attr^.Alignment   := taLeftJustify;
  attr^.BgColor     := clBtnFace;
  attr^.FontColor   := clGrayText;
  attr^.ReadOnly    := True;
  Self.Add(attr);

  New(attr);
  attr^.ID          := 14;
  attr^.Title       := 'Последний вход';
  attr^.Name        := 'lastLogon';
  attr^.Comment     := 'lastLogon';
  attr^.ObjProperty := 'lastLogon';
  attr^.Visible     := True;
  attr^.Width       := 120;
  attr^.Alignment   := taCenter;
  attr^.BgColor     := clBtnFace;
  attr^.FontColor   := clGrayText;
  attr^.ReadOnly    := True;
  Self.Add(attr);

  New(attr);
  attr^.ID          := 15;
  attr^.Title       := 'Ошибки ввода пароля';
  attr^.Name        := 'badPwdCount';
  attr^.Comment     := 'badPwdCount';
  attr^.ObjProperty := 'badPwdCount';
  attr^.Visible     := True;
  attr^.Width       := 40;
  attr^.Alignment   := taRightJustify;
  attr^.BgColor     := clBtnFace;
  attr^.FontColor   := clGrayText;
  attr^.ReadOnly    := True;
  Self.Add(attr);

  New(attr);
  attr^.ID          := 16;
  attr^.Title       := 'Срок действия пароля';
  attr^.Name        := 'pwdLastSet';
  attr^.Comment     := 'pwdLastSet + maxPwdAge';
  attr^.ObjProperty := 'passwordExpiration';
  attr^.Visible     := True;
  attr^.Width       := 120;
  attr^.Alignment   := taCenter;
  attr^.BgColor     := clBtnFace;
  attr^.FontColor   := clGrayText;
  attr^.ReadOnly    := True;
  Self.Add(attr);

  New(attr);
  attr^.ID          := 17;
  attr^.Title       := 'Тип группы';
  attr^.Name        := 'groupType';
  attr^.Comment     := 'groupType';
  attr^.ObjProperty := 'groupType';
  attr^.Visible     := False;
  attr^.Width       := 150;
  attr^.Alignment   := taLeftJustify;
  attr^.BgColor     := clBtnFace;
  attr^.FontColor   := clGrayText;
  attr^.ReadOnly    := True;
  Self.Add(attr);

  New(attr);
  attr^.ID          := 18;
  attr^.Title       := 'primaryGroupToken';
  attr^.Name        := 'primaryGroupToken';
  attr^.Comment     := 'primaryGroupToken';
  attr^.ObjProperty := 'primaryGroupToken';
  attr^.Visible     := False;
  attr^.Width       := 50;
  attr^.Alignment   := taRightJustify;
  attr^.BgColor     := clBtnFace;
  attr^.FontColor   := clGrayText;
  attr^.ReadOnly    := True;
  Self.Add(attr);

  New(attr);
  attr^.ID          := 19;
  attr^.Title       := 'Статус';
  attr^.Name        := 'userAccountControl';
  attr^.Comment     := 'userAccountControl';
  attr^.ObjProperty := 'userAccountControl';
  attr^.Visible     := True;
  attr^.Width       := 150;
  attr^.Alignment   := taLeftJustify;
  attr^.BgColor     := clBtnFace;
  attr^.FontColor   := clGrayText;
  attr^.ReadOnly    := True;
  Self.Add(attr);

  New(attr);
  attr^.ID          := 20;
  attr^.Title       := 'SID';
  attr^.Name        := 'objectSid';
  attr^.Comment     := 'objectSid';
  attr^.ObjProperty := 'objectSid';
  attr^.Visible     := False;
  attr^.Width       := 280;
  attr^.Alignment   := taLeftJustify;
  attr^.BgColor     := clBtnFace;
  attr^.FontColor   := clGrayText;
  attr^.ReadOnly    := True;
  Self.Add(attr);

  New(attr);
  attr^.ID          := 21;
  attr^.Title       := 'Изображение';
  attr^.Name        := 'thumbnailPhoto';
  attr^.Comment     := 'thumbnailPhoto (размер файла)';
  attr^.ObjProperty := 'thumbnailPhoto';
  attr^.Visible     := False;
  attr^.Width       := 60;
  attr^.Alignment   := taRightJustify;
  attr^.BgColor     := clBtnFace;
  attr^.FontColor   := clGrayText;
  attr^.ReadOnly    := True;
  Self.Add(attr);

  New(attr);
  attr^.ID          := 22;
  attr^.Title       := 'sAMAccountName';
  attr^.Name        := 'sAMAccountName';
  attr^.Comment     := 'sAMAccountName';
  attr^.ObjProperty := 'sAMAccountName';
  attr^.Visible     := False;
  attr^.Width       := 150;
  attr^.Alignment   := taLeftJustify;
  attr^.BgColor     := clBtnFace;
  attr^.FontColor   := clGrayText;
  attr^.ReadOnly    := True;
  Self.Add(attr);

  New(attr);
  attr^.ID          := 23;
  attr^.Title       := 'DistinguishedName';
  attr^.Name        := 'distinguishedName';
  attr^.Comment     := 'distinguishedName';
  attr^.ObjProperty := 'distinguishedName';
  attr^.Visible     := False;
  attr^.Width       := 200;
  attr^.Alignment   := taLeftJustify;
  attr^.BgColor     := clBtnFace;
  attr^.FontColor   := clGrayText;
  attr^.ReadOnly    := True;
  Self.Add(attr);

  New(attr);
  attr^.ID          := 24;
  attr^.Title       := 'DNS Hostname';
  attr^.Name        := 'dNSHostName';
  attr^.Comment     := 'dNSHostName';
  attr^.ObjProperty := 'dNSHostName';
  attr^.Visible     := False;
  attr^.Width       := 150;
  attr^.Alignment   := taLeftJustify;
  attr^.BgColor     := clBtnFace;
  attr^.FontColor   := clGrayText;
  attr^.ReadOnly    := True;
  Self.Add(attr);

  New(attr);
  attr^.ID          := 25;
  attr^.Title       := 'msRTCSIP-PrimaryUserAddress';
  attr^.Name        := 'msRTCSIP-PrimaryUserAddress';
  attr^.Comment     := 'msRTCSIP-PrimaryUserAddress';
  attr^.ObjProperty := 'msRTCSIP_PrimaryUserAddress';
  attr^.Visible     := False;
  attr^.Width       := 150;
  attr^.Alignment   := taLeftJustify;
  attr^.BgColor     := clBtnFace;
  attr^.FontColor   := clGrayText;
  attr^.ReadOnly    := True;
  Self.Add(attr);

  New(attr);
  attr^.ID          := 26;
  attr^.Title       := 'Атрибут';
  attr^.Name        := '';
  attr^.Comment     := 'Атрибут';
  attr^.ObjProperty := 'Attribute11';
  attr^.Visible     := False;
  attr^.Width       := 150;
  attr^.Alignment   := taLeftJustify;
  attr^.BgColor     := clWindow;
  attr^.FontColor   := clWindowText;
  attr^.ReadOnly    := False;
  Self.Add(attr);

  New(attr);
  attr^.ID          := 27;
  attr^.Title       := 'Атрибут';
  attr^.Name        := '';
  attr^.Comment     := 'Атрибут';
  attr^.ObjProperty := 'Attribute12';
  attr^.Visible     := False;
  attr^.Width       := 150;
  attr^.Alignment   := taLeftJustify;
  attr^.BgColor     := clWindow;
  attr^.FontColor   := clWindowText;
  attr^.ReadOnly    := False;
  Self.Add(attr);

  New(attr);
  attr^.ID          := 28;
  attr^.Title       := 'Атрибут';
  attr^.Name        := '';
  attr^.Comment     := 'Атрибут';
  attr^.ObjProperty := 'Attribute13';
  attr^.Visible     := False;
  attr^.Width       := 150;
  attr^.Alignment   := taLeftJustify;
  attr^.BgColor     := clWindow;
  attr^.FontColor   := clWindowText;
  attr^.ReadOnly    := False;
  Self.Add(attr);

  New(attr);
  attr^.ID          := 29;
  attr^.Title       := 'Атрибут';
  attr^.Name        := '';
  attr^.Comment     := 'Атрибут';
  attr^.ObjProperty := 'Attribute14';
  attr^.Visible     := False;
  attr^.Width       := 150;
  attr^.Alignment   := taLeftJustify;
  attr^.BgColor     := clWindow;
  attr^.FontColor   := clWindowText;
  attr^.ReadOnly    := False;
  Self.Add(attr);

  New(attr);
  attr^.ID          := 30;
  attr^.Title       := 'Атрибут';
  attr^.Name        := '';
  attr^.Comment     := 'Атрибут';
  attr^.ObjProperty := 'Attribute15';
  attr^.Visible     := False;
  attr^.Width       := 150;
  attr^.Alignment   := taLeftJustify;
  attr^.BgColor     := clWindow;
  attr^.FontColor   := clWindowText;
  attr^.ReadOnly    := False;
  Self.Add(attr);
end;

procedure TAttrCatalog.LoadFromFile(AFileName: TFileName);
var
  f: file of TADAttribute;
  a: PADAttribute;
begin
  Self.Clear;
  {$i-}
  AssignFile(f, AFileName);
  Reset(f);
  try
    if IOResult <> 0
      then raise Exception.Create('I/O error while opening attribute catalog.');

    while not Eof(f) do
    begin
      New(a);
      Read(f, a^);
      Self.Add(a);
      if IOResult <> 0
        then raise Exception.Create('I/O error while reading attribute catalog.');
    end;
  except
    LoadDefaults;
  end;

  CloseFile(f);
  {$i+}

  if Self.Count = 0
    then LoadDefaults;
end;

procedure TAttrCatalog.LoadFromStream(AStream: TStream);
var
  a: PADAttribute;
begin
  Self.Clear;

  try
    AStream.Position := 0;
    while AStream.Position < AStream.Size do
    begin
      New(a);
      AStream.Read(a^, SizeOf(TADAttribute));
      Self.Add(a);
    end;
  except

  end;
end;

procedure TAttrCatalog.SaveToFile(AFileName: TFileName; ARaiseEvent: Boolean);
var
  i: Integer;
  f: file of TADAttribute;
begin
//  Self.Sort(@CompareVisibility);
  {$i-}
  AssignFile(f, AFileName);
  Rewrite(f);
  try
    if IOResult <> 0
      then raise Exception.Create('I/O error while opening attribute catalog.');

    for i := 0 to Self.Count - 1 do
    begin
      Write(f, Self[i]^);
      if IOResult <> 0
        then raise Exception.Create('I/O error while saving attribute catalog.');
    end;

    if ARaiseEvent and Assigned(FOnSave) then FOnSave(Self);
  except

  end;

  CloseFile(f);
  {$i+}
end;

procedure TAttrCatalog.SaveToStream(AStream: TStream);
var
  i: Integer;
  l: TAttrCatalog;
begin
  try
    for i := 0 to Self.Count - 1 do
    begin
      AStream.WriteBuffer(Self[i]^, SizeOf(TADAttribute));
    end;
  except

  end;
end;

function TAttrCatalog.VisibleCount: Integer;
var
  item: PADAttribute;
  c: Integer;
begin
  c := 0;
  for item in Self do
    if item^.Visible then c := c + 1;
  Result := c;
end;

{ TAttrCatalogControl }

procedure TAttrCatalogControl.ComboBoxWndProc_Alignment(var Message: TMessage);
var
  cbR: TRect;
  lbR: TRect;
begin
  case Message.Msg of
    WM_CTLCOLORLISTBOX: begin
      GetWindowRect(ComboBox_Alignment.Handle, cbR);
      GetWindowRect(Message.LParam, lbR);
      if cbR.Right <> lbR.Right then MoveWindow(
        Message.LParam,
        lbR.Left - (lbR.Right - cbR.Right),
        lbR.Top,
        lbR.Right - lbR.Left,
        lbR.Bottom - lbR.Top,
        True
      );
    end;

    WM_MOUSEWHEEL: begin

    end;

    else FComboBoxWndProc_Alignment(Message);
  end;
end;

constructor TAttrCatalogControl.Create(AParent: TWinControl; AAttribute: PADAttribute);
const
  DEF_TOP = -30;
var
  h: HTHEME;
  c: HDC;
  s: TSize;
begin
  FParent := AParent;
  FEnabled := True;
  FVisible := True;
  FReadOnly := False;
  FAttr := AAttribute;

  FIcon_AlignLeft := TPngImage.Create;
  FIcon_AlignCenter := TPngImage.Create;
  FIcon_AlignRight := TPngImage.Create;

  HexStringToPNGImage(pngHex_AlignLeft, FIcon_AlignLeft);
  HexStringToPNGImage(pngHex_AlignCenter, FIcon_AlignCenter);
  HexStringToPNGImage(pngHex_AlignRight, FIcon_AlignRight);

  { При создании контролов выставляем их значения Top отрицательными, }
  { делая их невидимыми, иначе при создании они будут мерцать на      }
  { канве парента.                                                    }

  FCheckBox := TAttrCheckBox.Create(nil);
  with FCheckBox do
  begin
    Parent := AParent;
    ParentCtl3D := False;
    Ctl3D := True;
    Top := DEF_TOP;
    Checked := FAttr^.Visible;
    OnEnter := OnControlFocus;
    OnClick := OnControlChange;

    if Parent.HandleAllocated then
    begin
//      raise Exception.Create('The control''s window handle has not been allocated');
      c := GetWindowDC(Parent.Handle);
      h := OpenThemeData(Parent.Handle, 'BUTTON');
      GetThemePartSize(
        h,
        c,
        BP_CHECKBOX,
        CBS_CHECKEDNORMAL,
        nil,
        TS_DRAW,
        s
      );
      Height := s.Height;
      Width := s.Width;
      ReleaseDC(Parent.Handle, c);
      CloseThemeData(h);
    end;
  end;

  FEdit := TAttrEdit.Create(nil);
  with FEdit do
  begin
    Parent := AParent;
    ParentCtl3D := False;
    Ctl3D := True;
    Top := DEF_TOP;
    Text := FAttr^.Title;
    OnEnter := OnControlFocus;
    OnChange := OnControlChange;

    SendMessage(
      Handle,
      EM_SETMARGINS,
      EC_LEFTMARGIN or EC_RIGHTMARGIN,
      MakeLong(3, 0)
    );
  end;

  FComboBox_Attribute := TAttrComboBox.Create(nil);
  with FComboBox_Attribute do
  begin
    Parent := AParent;
    ParentCtl3D := False;
    Ctl3D := True;
    Top := DEF_TOP;
    Style := csDropDown;
    Sorted := True;
    case FAttr.ReadOnly of
      True : Text := FAttr^.Comment;
      False: Text := FAttr^.Name;
    end;
    OnDropDown := OnComboBoxDropDown_Attribute;
    OnResize := OnComboBoxResize;
    OnEnter := OnControlFocus;
    OnChange := OnControlChange;
    OnSelect := OnControlChange;

    FComboBoxWndProc_Attribute := WindowProc;
    WindowProc := ComboBoxWndProc_Attribute;
  end;

  FSpinEdit := TAttrSpinEdit.Create(nil);
  with FSpinEdit do
  begin
    Parent := AParent;
    ParentCtl3D := False;
    Ctl3D := True;
    Top := DEF_TOP;
    Alignment := taCenter;
    Value := FAttr^.Width;
    OnEnter := OnControlFocus;
  end;

  FComboBox_Alignment := TAttrComboBox.Create(nil);
  with FComboBox_Alignment do
  begin
    Parent := AParent;
    ParentCtl3D := False;
    Ctl3D := True;
    Top := DEF_TOP;
    Style := csOwnerDrawFixed;
    Top := -Height;
    OnDrawItem := OnComboBoxDrawItem_Alignment;
    OnDropDown := OnComboBoxDropDown_Alignment;
    OnResize := OnComboBoxResize;
    OnEnter := OnControlFocus;
    FComboBoxWndProc_Alignment := WindowProc;
    WindowProc := ComboBoxWndProc_Alignment;

    Items.Add('По левому краю');
    Items.Add('По правому краю');
    Items.Add('По центру');
    ItemIndex := Byte(FAttr^.Alignment);
  end;

  Self.ReadOnly := FAttr.ReadOnly;
end;

procedure TAttrCatalogControl.ComboBoxWndProc_Attribute(var Message: TMessage);
var
  cbR: TRect;
  lbR: TRect;
begin
  case Message.Msg of
    WM_MOUSEWHEEL: begin

    end;

    else FComboBoxWndProc_Attribute(Message);
  end;
end;

constructor TAttrCatalogControl.Create(AParent: TWinControl;
  AAttribute: PADAttribute; AAttrList: TStrings);
begin
  Create(AParent, AAttribute);
  FComboBox_Attribute.Items.Assign(AAttrList);
end;

destructor TAttrCatalogControl.Destroy;
begin
  FAttr := nil;
  FIcon_AlignLeft.Free;
  FIcon_AlignCenter.Free;
  FIcon_AlignRight.Free;
  FEdit.Free;
  FComboBox_Attribute.Free;
  FCheckBox.Free;
  FSpinEdit.Free;
  FComboBox_Alignment.Free;

  inherited;
end;

procedure TAttrCatalogControl.DoOnChange;
begin
  if Assigned(FOnChange)
    then FOnChange(Self)
end;

procedure TAttrCatalogControl.DoOnFocus;
begin
  if Assigned(FOnFocus)
    then FOnFocus(Self);
end;

procedure TAttrCatalogControl.HexStringToPNGImage(AHexString: string;
  out AImage: TPngImage);
var
  hexStr: string absolute AHexString;
  bufSize: Integer;
  Buffer: Pointer;
  memStream: TMemoryStream;
begin
  Delete(HexStr, 1, 20);
  BufSize := Length(HexStr) div 2;
  Buffer := AllocMem(BufSize);
  try
    HexToBin(PWideChar(HexStr), Buffer, BufSize);
    memStream := TMemoryStream.Create;
    try
      memStream.Write(Buffer^, BufSize);
      memStream.Position := 0;
      AImage.LoadFromStream(memStream);
    finally
      memStream.Free;
    end;
  finally
    FreeMem(Buffer);
  end;
end;

procedure TAttrCatalogControl.Hide;
begin
  SetVisible(False);
end;

function TAttrCatalogControl.IsFocused: Boolean;
begin
  Result := FCheckBox.Focused or FEdit.Focused or FComboBox_Attribute.Focused
    or FSpinEdit.Focused or ComboBox_Alignment.Focused;
end;

procedure TAttrCatalogControl.OnComboBoxDrawItem_Alignment(Control: TWinControl;
  Index: Integer; Rect:TRect; State: TOwnerDrawState);
const
  _margin: Byte = 3;
var
  pngImg: TPngImage;
  ItemText: string;
  C: TCanvas;
  R: TRect;
begin
  C := ComboBox_Alignment.Canvas;
  R := Rect;
  C.Brush.Color := clWindow;
  C.FillRect(Rect);

  if ( odSelected in State ) or ( odFocused in State ) then
  begin
    C.Brush.Color := clHighlight;
    C.Pen.Color := clHighlightText;
  end else
  begin
    C.Brush.Color := clWhite;
    C.Pen.Color := clSilver;
  end;

  case Index of
    0: pngImg := FIcon_AlignLeft;
    1: pngImg := FIcon_AlignRight;
    2: pngImg := FIcon_AlignCenter;
  end;

  if odComboBoxEdit in State then
  begin
    InflateRect(
      R,
      -(R.Width - pngImg.Width) div 2,
      -(R.Height - pngImg.Height) div 2
    );

    if ( odSelected in State ) or ( odFocused in State ) then
    begin
      { ВАЖНО: Вызываем C.DrawFocusRect(Rect) дважды с разным   }
      { цветом кисти. Иначе цвет FocusRect всегда темный черный }
      C.Brush.Color := clWindow;
      C.DrawFocusRect(Rect);
      C.Brush.Color := clBlack;
      C.DrawFocusRect(Rect);
    end;
  end else
  begin
    InflateRect(
      R,
      0,
      -(R.Height - pngImg.Height) div 2
    );

    OffsetRect(R, _margin, 0);
  end;

  C.Draw(R.TopLeft.X, R.TopLeft.Y, pngImg);

  if not (odComboBoxEdit in State)  then
  begin
    R := Rect;
    OffsetRect(R, pngImg.Width + _margin * 2, 0);
    C.FillRect(R);
    OffsetRect(R, _margin, 1);
    ItemText := (Control as TComboBox).Items[Index];
    C.TextRect(R, ItemText, [tfLeft, tfEndEllipsis, tfVerticalCenter]);
  end;
end;

procedure TAttrCatalogControl.OnComboBoxDropDown_Alignment(Sender: TObject);
begin
  SetComboBoxDropDownWidth(Sender as TComboBox, FIcon_AlignCenter.Width + 15);
end;

procedure TAttrCatalogControl.OnComboBoxDropDown_Attribute(Sender: TObject);
begin
  SetComboBoxDropDownWidth(Sender as TComboBox, 5);
end;

procedure TAttrCatalogControl.OnComboBoxResize(Sender: TObject);
begin
  (Sender as TComboBox).SelLength := 0;
end;

procedure TAttrCatalogControl.OnControlChange(Sender: TObject);
begin
  DoOnChange;
end;

procedure TAttrCatalogControl.OnControlFocus(Sender: TObject);
begin
  DoOnFocus;
end;

procedure TAttrCatalogControl.SetComboBoxDropDownWidth(AComboBox: TComboBox;
  AIncrease: Integer);
var
  C: TCanvas;
  ItemText: string;
  TextWidth: Integer;
  MaxWidth: Integer;
begin
  C := AComboBox.Canvas;
  MaxWidth := 0;
  for ItemText in AComboBox.Items do
  begin
    TextWidth := C.TextWidth(ItemText) + AIncrease;
    if MaxWidth < TextWidth then MaxWidth := TextWidth;
  end;

  if (MaxWidth > AComboBox.Width) then
  begin
    if AComboBox.DropDownCount < AComboBox.Items.Count
      then MaxWidth := MaxWidth + GetSystemMetrics(SM_CXVSCROLL);
    SendMessage(AComboBox.Handle, CB_SETDROPPEDWIDTH, MaxWidth, 0);
  end;
end;

procedure TAttrCatalogControl.SetEnabled(AEnabled: Boolean);
begin
  FCheckBox.Enabled := AEnabled;
  case AEnabled of
    True: begin
      FEdit.Enabled := FReadOnly;
      FComboBox_Attribute.Enabled := FReadOnly;
    end;

    False: begin
      FEdit.Enabled := AEnabled;
      FComboBox_Attribute.Enabled := AEnabled;
    end;
  end;
  FSpinEdit.Enabled := AEnabled;
  FComboBox_Alignment.Enabled := AEnabled;

  FEnabled := AEnabled;
end;

procedure TAttrCatalogControl.SetFocus;
begin
  FEdit.SetFocus;
end;

procedure TAttrCatalogControl.SetParent(AParent: TWinControl);
begin
  FEdit.Parent := AParent;
  FComboBox_Attribute.Parent := AParent;
  FCheckBox.Parent := AParent;
  FSpinEdit.Parent := AParent;
  FComboBox_Alignment.Parent := AParent;

  FParent := AParent;
end;

procedure TAttrCatalogControl.SetReadOnly(AReadOnly: Boolean);
begin
  case AReadOnly of
    True: begin
      FEdit.Enabled := not AReadOnly;
      FComboBox_Attribute.Enabled := not AReadOnly;
    end;

    False: begin
      FEdit.Enabled := FEnabled;
      FComboBox_Attribute.Enabled := FEnabled;
    end;
  end;

  FReadOnly := AReadOnly;
end;

procedure TAttrCatalogControl.SetVisible(AVisible: Boolean);
begin
  FEdit.Visible := AVisible;
  FComboBox_Attribute.Visible := AVisible;
  FCheckBox.Visible := AVisible;
  FSpinEdit.Visible := AVisible;
  FComboBox_Alignment.Visible := AVisible;

  FVisible := AVisible;
end;

procedure TAttrCatalogControl.Show;
begin
  SetVisible(True);
end;

procedure TAttrCatalogControl.WriteToCatalog;
begin
  with FAttr^ do
  begin
    Visible := FCheckBox.Checked;
    if not ReadOnly then
    begin
      Title := FEdit.Text;
      Name := FComboBox_Attribute.Text;
    end;
    Width := FSpinEdit.Value;
    Alignment := TAlignment(FComboBox_Alignment.ItemIndex);
  end;
end;

{ TAttrComboBox }

procedure TAttrComboBox.CNDrawItem(var Message: TWMDrawItem);
const
  ODS_NOFOCUSRECT = $0200;
begin
  with Message do
    DrawItemStruct.itemState := DrawItemStruct.itemState and not (ODS_FOCUS);

  inherited;
end;

procedure TAttrComboBox.WMNCPaint(var Msg: TMessage);
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
      with C.Brush do
      begin
        Color := Self.Color;
        Style := bsSolid;
      end;
      C.FrameRect(R);
      InflateRect(R, -1, -1);
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

procedure TAttrComboBox.WMPaint(var Msg: TMessage);
var
  C: TCanvas;
  R: TRect;
begin
  inherited;

  C := Self.Canvas;
  with C do
  begin
    { Рисуем новую рамку }
    Brush.Color := Self.Color;
    R := ClientRect;
    FrameRect(R);
    InflateRect(R, -1, -1);
    FrameRect(R);
  end;
end;

{ TAttrEdit }

procedure TAttrEdit.WMNCPaint(var Msg: TMessage);
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
      with C.Brush do
      begin
        Color := Self.Color;
        Style := bsSolid;
      end;
      C.FrameRect(R);
      InflateRect(R, -1, -1);
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

{ TAttrSpinEdit }

procedure TAttrSpinEdit.Change;
begin
  inherited;

  if Value < 50 then
  begin
    Value := 50;
  end;
end;

procedure TAttrSpinEdit.WMNCPaint(var Msg: TMessage);
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
      with C.Brush do
      begin
        Color := Self.Color;
        Style := bsSolid;
      end;
      C.FrameRect(R);
      InflateRect(R, -1, -1);
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
