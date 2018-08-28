unit fmFloatingWindow;

interface

uses
  System.Classes, Vcl.Forms, Winapi.Windows, System.SysUtils, Winapi.Messages,
  Vcl.Graphics, Vcl.StdCtrls, Vcl.Controls, Vcl.ExtCtrls, Vcl.Dialogs, System.DateUtils,
  Variants, Vcl.ComCtrls, Vcl.Imaging.jpeg, System.ImageList, Vcl.ImgList, ActiveDs_TLB,
  Winapi.CommCtrl, Winapi.ActiveX, ADCmdUCMA_TLB, ADC.UCMAEvents, System.Win.ComObj,
  System.StrUtils, ADC.ADObject, ADC.Common, ADC.ImgProcessor, ADC.UserEdit, ADC.GlobalVar,
  ADC.Types, ADC.AD;

const
  WM_FWND_THREAD = WM_USER + 1;

  STATUS_TEXT_UNKNOWN         = 'Состояние присутствия неизвестно';
  STATUS_TEXT_UPDATING        = 'Идет обновление...';

  STATUS_IMAGE_UNKNOWN        = 0;
  STATUS_IMAGE_ONLINE         = 1;
  STATUS_IMAGE_IDLE           = 2;
  STATUS_IMAGE_BUSY           = 3;
  STATUS_IMAGE_DO_NOT_DISTURB = 4;

type
  PContactActivity = ^TContactActivity;
  TContactActivity = record
    _Handle: THandle;
    _Contact: IUCMAContact;
  end;

type
  PContactInfo = ^TContactInfo;
  TContactInfo = record
    _Handle: THandle;
    _DistingushedName: string;
    DisplayName: string;
    Info1: string;
    Info2: string;
    Image: TImgByteArray;
  end;

type
  TForm_FloatingWindow = class(TForm)
    PaintBox_Background: TPaintBox;
    Image_Status: TImage;
    Image_Contact: TImage;
    Label_Name: TLabel;
    Label_Info1: TLabel;
    Label_Info2: TLabel;
    ImageList_Status_Classic: TImageList;
    ImageList_Status_Modern: TImageList;
    ImageList_Contact: TImageList;
    Timer_Display: TTimer;
    Timer_StatusRefresh: TTimer;
    procedure PaintBox_BackgroundPaint(Sender: TObject);
    procedure Timer_DisplayTimer(Sender: TObject);
    procedure Timer_StatusRefreshTimer(Sender: TObject);
  strict private
    const FFormPadding = 9;
    const TIMER_MODE_DISPLAY_DELAY    = 0;
    const TIMER_MODE_DISPLAY_DURATION = 1;
  protected
    procedure WndProc(var Message: TMessage); override;
    procedure VisibleChanging; override;
  private
    FOwner: TForm;
    FDisplayStyle: TFloatingWindowStyle;
    FListView: TListView;
    FObj: TADObject;
    FContact: IUCMAContact;
    FEventSink: TUCMAEventSink;
    FClientSignedIn: Boolean;
    FDisplayActivity: Boolean;
    FDisplayDelay: Integer;
    FDisplayDuration: Integer;
    FJPEG_Default: TJPEGImage;
    FDefaultHeight: Integer;
    FSA: SECURITY_ATTRIBUTES;
    FThreads: array of THandle;
    procedure AlignControls;
    procedure SetPosition;
    procedure SetDisplayDelay(const Value: Integer);
    procedure CreateUCMAClient;
    procedure DestroyUCMAClient;
    procedure SignInUCMAClient;
    procedure SetStatusImage(AImageIndex: Integer);
    procedure SetContactImage(AObject: TADObject); overload;
    procedure SetContactImage(AImage: PSafeArray); overload;
    procedure SetContactImage(AImage: TImgByteArray); overload;
    function ContactIdleTimeToString(AIdleStartTime: TDateTime): string;
    function ContactActivityTextEx(AContact: IUCMAContact): string;
    procedure OnClientSignIn(Sender: TObject);
    procedure OnClientSignOut(Sender: TObject);
    procedure OnClientDisconnected(Sender: TObject);
    procedure OnSettingChanged(Sender: TObject);
    procedure OnContactInformationChanged(Sender: TObject);
    procedure OnUriChanged(Sender: TObject; oldURI, newURI: WideString);
    procedure SetDisplayActivity(const Value: Boolean);
    procedure SetDisplayStyle(const Value: TFloatingWindowStyle);
  public
    { Public declarations }
    constructor Create(AOwner: TComponent; ListView: TListView = nil); overload;
    destructor Destroy;
    procedure Show(AUser: TADObject); overload;
    procedure Hide(Clear: Boolean); overload;
    procedure Reset;
    property DisplayStyle: TFloatingWindowStyle read FDisplayStyle write SetDisplayStyle;
    property DisplayDelay: Integer read FDisplayDelay write SetDisplayDelay;
    property DisplayDuration: Integer read FDisplayDuration write FDisplayDuration;
    property DisplayActivity: Boolean read FDisplayActivity write SetDisplayActivity;
  end;

var
  Form_FloatingWindow: TForm_FloatingWindow;

  FContactInfo: TContactInfo;
  FContactActivity: TContactActivity;

  FThreadID_GetContactActiveDirectoryInfo: DWORD;
  FThreadID_GetContactActivity: DWORD;

implementation

{$R *.dfm}

{ В отдельном потоке вытягиваем информацию пользователя из Active Directory }
procedure GetContactActiveDirectoryInfo(lpParam: LPVOID); stdcall;
var
  c: PContactInfo absolute lpParam;
  u: TUserEdit;
begin
  try
    case apAPI of
      ADC_API_LDAP: u.GetInfo(LDAPBinding, c^._DistingushedName);
      ADC_API_ADSI: u.GetInfoDS(ADSIBinding, c^._DistingushedName);
    end;
  except

  end;

  if GetCurrentThreadID = FThreadID_GetContactActiveDirectoryInfo then
  begin
    c^.DisplayName := u.displayName;
    c^.Info1 := u.title;
    c^.Info2 := u.physicalDeliveryOfficeName;
    c^.Image := u.thumbnailPhoto;

    PostMessage(c^._Handle, WM_FWND_THREAD, 0, GetCurrentThreadID);
  end;
end;

{ В отдельном потоке вытягиваем информацию пользователя из Active Directory }
procedure GetContactActivity(lpParam: LPVOID); stdcall;
var
  c: PContactActivity absolute lpParam;
  res: Integer;
begin
  try
    case c^._Contact.Availability of
      0            : res := STATUS_IMAGE_UNKNOWN;           { None              }
      1..4999      : res := STATUS_IMAGE_ONLINE;            { Free              }
      5000..6499   : res := STATUS_IMAGE_IDLE;              { FreeIdle          }
      6500..7499   : res := STATUS_IMAGE_BUSY;              { Busy              }
      7500..9499   : res := STATUS_IMAGE_BUSY;              { BusyIdle          }
      9500..12499  : res := STATUS_IMAGE_DO_NOT_DISTURB;    { DoNotDisturb      }
      12500..15499 : res := STATUS_IMAGE_IDLE;              { TemporarilyAway   }
      15500..18499 : res := STATUS_IMAGE_IDLE;              { Away              }
      else raise Exception.Create('Availability unknown');  { >= 18500: Offline }
    end;
  except
    res := STATUS_IMAGE_UNKNOWN;
  end;

  if GetCurrentThreadID = FThreadID_GetContactActivity then
  begin
    PostMessage(c^._Handle, WM_FWND_THREAD, res, GetCurrentThreadID);
  end;
end;

{ TForm_FloatingWindow }

function TForm_FloatingWindow.ContactActivityTextEx(
  AContact: IUCMAContact): string;
var
  a: Integer;
  s: string;
  t: TDateTime;
begin
  try
    a := AContact.Availability;
    s := AContact.Activity;
    t := AContact.IdleStartTime;
    
    if not s.IsEmpty then
    begin
      if (a >= 5000) and (a < 6500) or (a >= 12500)
        then Result := s + ' ' + ContactIdleTimeToString(t)
        else Result := s;
    end else raise Exception.Create('Presence unknown');
  except
    Result := STATUS_TEXT_UNKNOWN;
  end;
end;

function TForm_FloatingWindow.ContactIdleTimeToString(
  AIdleStartTime: TDateTime): string;
var
  m: Int64;
  h: Int64;
  d: Int64;
  f: string;
begin
  m := MinutesBetween(AIdleStartTime, Now);

  if m = 0 then
  begin
//    Result := 'меньше минуты';
    Exit;
  end;

  d := m div 60 div 24;
  if d > 0 
    then m := m - d * 24 * 60;
  
  h := m div 60;
  if h > 0 
    then m := m - h * 60;

  if d > 0
    then f := '%0:d дн.'
    else if h > 0
      then f := '%1:d час. %2:d мин.' 
      else f := '%2:d мин.'; 

  Result := Format(f, [d, h, m]);
end;

constructor TForm_FloatingWindow.Create(AOwner: TComponent; ListView: TListView);
begin
  if not (AOwner is TForm) then
    raise Exception.Create('Owner should be TForm');

  inherited Create(AOwner);

  FOwner := TForm(AOwner);
  FListView := ListView;
  FJPEG_Default := TJPEGImage.Create;

  FormStyle := fsStayOnTop;
  BorderStyle := bsNone;
  TransparentColorValue := clPurple;
  Color := TransparentColorValue;
  TransparentColor := True;
  Position := poDesigned;
  Width := 320;
  Height := 69;

  SetLength(FThreads, 2);
  SetDisplayStyle(fwsSkype);
  SetDisplayActivity(False);
  SetDisplayDelay(500);
  FDisplayDuration := 3000;

  FContact := nil;
  FEventSink := nil;

  with FSA do
  begin
    nLength := SizeOf(SECURITY_ATTRIBUTES);
    bInheritHandle := True;
    lpSecurityDescriptor := nil;
  end;

  AlignControls;

  FDefaultHeight := Image_Contact.Top * 2 + Image_Contact.Height;
  Height := FDefaultHeight;
  Reset;
end;

procedure TForm_FloatingWindow.CreateUCMAClient;
begin
  if FEventSink <> nil then
  try
    FEventSink.Disconnect;
    FEventSink.Free;
  except

  end;
  FEventSink := nil;

  if FContact <> nil then
  try
    FContact.FreeContact;
  except

  end;
  FContact := nil;

  try
    FContact := CreateComObject(CLASS_UCMAContact) as IUCMAContact;
    FClientSignedIn := FContact.ClientSignIn;
  except
    FContact := nil;
  end;

  FEventSink := TUCMAEventSink.Create;
  try
    FEventSink.Connect(FContact);
    FEventSink.OnClientSignIn := OnClientSignIn;
    FEventSink.OnClientSignOut := OnClientSignOut;
    FEventSink.OnClientDisconnected := OnClientDisconnected;
    FEventSink.OnContactInformationChanged := OnContactInformationChanged;
    FEventSink.OnSettingChanged := OnSettingChanged;
    FEventSink.OnUriChanged := OnUriChanged;
  except

  end;
end;

destructor TForm_FloatingWindow.Destroy;
var
  i: Integer;
begin
  FJPEG_Default.Free;
  DestroyUCMAClient;

  inherited Destroy;
end;

procedure TForm_FloatingWindow.DestroyUCMAClient;
begin
  try
    FEventSink.Disconnect;
    FEventSink.Free;
  except

  end;

  FEventSink := nil;

  try
    FContact.FreeContact;
  except

  end;

 FContact := nil;
end;

procedure TForm_FloatingWindow.PaintBox_BackgroundPaint(Sender: TObject);
var
  ImgRect: TRect;
  i: Integer;
  RoundValue: Integer;
begin
  case FDisplayStyle of
    fwsLync : RoundValue := 3;
    fwsSkype  : RoundValue := 0;
  end;

  with Sender as TPaintBox do
  begin
    Canvas.Brush.Color := TransparentColorValue;
    Canvas.FillRect(BoundsRect);

    Canvas.Pen.Color := clSilver;
    Canvas.Brush.Color := clWindow;

    Canvas.RoundRect(
      ClientRect.TopLeft.X,
      ClientRect.TopLeft.Y,
      ClientRect.BottomRight.X,
      ClientRect.BottomRight.Y,
      RoundValue,
      RoundValue
    );

    case FDisplayStyle of
      fwsLync: begin
        Canvas.Pen.Color := clGray;
        ImgRect := Image_Contact.ClientRect;
        ImgRect.Offset(Image_Contact.Left, Image_Contact.Top);

        Canvas.Rectangle(
          ImgRect.TopLeft.X - 1,
          ImgRect.TopLeft.Y - 1,
          ImgRect.BottomRight.X + 1,
          ImgRect.BottomRight.Y + 1
        );
      end;

      fwsSkype: begin

      end;
    end;
  end;

  AlignControls;
end;

procedure TForm_FloatingWindow.Hide(Clear: Boolean);
begin
  if Clear then
  begin
    Self.FObj := nil;
  end;

  inherited Hide;
  Reset;
end;

procedure TForm_FloatingWindow.OnClientDisconnected(Sender: TObject);
begin
  FClientSignedIn := False;
end;

procedure TForm_FloatingWindow.OnClientSignIn(Sender: TObject);
begin
  FClientSignedIn := True;
end;

procedure TForm_FloatingWindow.OnClientSignOut(Sender: TObject);
begin
  FClientSignedIn := False;
end;

procedure TForm_FloatingWindow.OnContactInformationChanged(Sender: TObject);
var
  s: string;
begin
  Timer_StatusRefreshTimer(Timer_StatusRefresh);
//  s := FContact.DisplayName;
//  if not s.IsEmpty
//    then Label_Name.Caption := s;
//
//  s := FContact.Title;
//  if not s.IsEmpty
//    then Label_Info1.Caption := s;
//
//  Label_Info2.Caption := ContactActivityTextEx(FContact);
//
//  try
//    case FContact.Availability of
//      1..4999      : SetStatusImage(STATUS_IMAGE_ONLINE);
//      5000..6499   : SetStatusImage(STATUS_IMAGE_IDLE);
//      6500..7499   : SetStatusImage(STATUS_IMAGE_BUSY);
//      7500..9499   : SetStatusImage(STATUS_IMAGE_BUSY);
//      9500..12499  : SetStatusImage(STATUS_IMAGE_DO_NOT_DISTURB);
//      12500..15499 : SetStatusImage(STATUS_IMAGE_IDLE);
//      15500..18499 : SetStatusImage(STATUS_IMAGE_IDLE);
//      else raise Exception.Create('Availability unknown');
//    end;
//  except
//    SetStatusImage(STATUS_IMAGE_UNKNOWN);
//  end;
//
//  SetContactImage(FContact.Photo);
end;

procedure TForm_FloatingWindow.OnSettingChanged(Sender: TObject);
begin

end;

procedure TForm_FloatingWindow.OnUriChanged(Sender: TObject; oldURI,
  newURI: WideString);
begin

end;

procedure TForm_FloatingWindow.Reset;
var
  i: Integer;
begin
  for i := Low(FThreads) to High(FThreads) do
  if FThreads[i] <> 0 then
  begin
//    TerminateThread(FThreads[i], 0);
    CloseHandle(FThreads[i]);
    FThreads[i] := 0;
  end;

  Timer_Display.Enabled := False;
  Timer_Display.Tag := TIMER_MODE_DISPLAY_DELAY;
  Timer_Display.Interval := FDisplayDelay;
  Timer_StatusRefresh.Enabled := False;
  try FContact.FreeContact; except end;
  SetStatusImage(STATUS_IMAGE_UNKNOWN);
  Label_Name.Caption := '';
  Label_Info1.Caption := '';

  if DisplayActivity
    then Label_Info2.Caption := STATUS_TEXT_UPDATING
    else Label_Info2.Caption := '';
end;

procedure TForm_FloatingWindow.SetPosition;
var
  Rightmost, Bottommost: Integer;
  R: TRect;
  P: TPoint;
  li : TLIstItem;
  lvHitInfo: TLVHitTestInfo;
begin
  if (FOwner.WindowState = wsMaximized) and (FListView <> nil) then
  begin
    Rightmost := FListView.ClientToScreen(Point(FListView.ClientWidth, 0)).X;
    Bottommost := FListView.ClientToScreen(Point(0, FListView.ClientHeight)).Y;
  end else
  begin
    Rightmost := Screen.DesktopWidth;
    Bottommost := Screen.WorkAreaHeight;
  end;

  if Mouse.CursorPos.X > Rightmost - Width - 16
    then Left := Rightmost - Width
    else Left := Mouse.CursorPos.X + 16;

  if Mouse.CursorPos.Y > Bottommost - Height - 18
    then Top := Mouse.CursorPos.Y - Height - 9
    else Top := Mouse.CursorPos.Y + 18;
end;

procedure TForm_FloatingWindow.SetStatusImage(AImageIndex: Integer);
var
  imgList: TImageList;
begin
  case FDisplayStyle of
    fwsLync : imgList := ImageList_Status_Classic;
    fwsSkype  : imgList := ImageList_Status_Modern;
  end;

  if (imgList = nil) or (AImageIndex < 0) or (AImageIndex > imgList.Count - 1) then
  begin
    Image_Status.Picture := nil
  end else
  begin
    imgList.GetBitmap(AImageIndex, Image_Status.Picture.Bitmap);
  end;

  imgList := nil;

  Image_Status.Refresh;
end;

procedure TForm_FloatingWindow.SetContactImage(AImage: TImgByteArray);
var
  srcB: TBitmap;
  resB: TBitmap;
  R: TRect;
begin
  srcB := TBitmap.Create;
  try
    try
      if Length(AImage) = 0
        then raise Exception.Create('No contact image');

      TImgProcessor.ByteArrayToImage(AImage, srcB);
    except;
      srcB.Assign(FJPEG_Default);
    end;

    if (srcB.Width > Image_Contact.Width) or (srcB.Height > Image_Contact.Height) then
    begin
      resB := TBitmap.Create;
      try
        { Вписывание изображения по ширине/высоте }
        if srcB.Height > srcB.Width then
        begin
          resB.Width := Image_Contact.ClientWidth;
          resB.Height := (resB.Width * srcB.Height) div srcB.Width;
          R := resB.Canvas.ClipRect;
          R.Inflate(0, -Abs(resB.Height - resB.Width) div 2);
          R.Offset(0, -Abs(resB.Height - resB.Width) div 4);
        end else
        begin
          resB.Height := Image_Contact.ClientHeight;
          resB.Width := (resB.Height * srcB.Width) div srcB.Height;
          R := resB.Canvas.ClipRect;
          R.Inflate(-Abs(resB.Width - resB.Height) div 2, 0);
        end;

        TImgProcessor.SmoothResize(srcB, resB);
        Image_Contact.Canvas.CopyMode := cmSrcCopy;
        Image_Contact.Canvas.CopyRect(
           Image_Contact.Canvas.ClipRect,
           resB.Canvas,
           R
        );

        { Изменение размера с сохранением пропорций }
//        if srcB.Width > srcB.Height then
//        begin
//          resB.Width := Image_Contact.ClientWidth;
//          resB.Height := (resB.Width * srcB.Height) div srcB.Width;
//        end else
//        begin
//          resB.Height := Image_Contact.ClientHeight;
//          resB.Width := (resB.Height * srcB.Width) div srcB.Height;
//        end;
//        TImgProcessor.SmoothResize(srcB, resB);
//        Image_Contact.Picture.Bitmap.Assign(resB);
      finally
        resB.Free;
      end;
    end else Image_Contact.Picture.Bitmap.Assign(srcB);
  finally
    srcB.Free;
  end;

  Image_Contact.Refresh;
end;

procedure TForm_FloatingWindow.SetContactImage(AObject: TADObject);
var
  ms: TMemoryStream;
  imgBytes: TImgByteArray;
begin
  if (AObject <> nil) and (AObject.thumbnailFileSize > 0) then
  begin
    ms := TMemoryStream.Create;
    try
      AObject.thumbnailPhoto.SaveToStream(ms);
      SetLength(imgBytes, ms.Size);
      ms.Position := 0;
      ms.ReadBuffer(imgBytes[0], Length(imgBytes));
    finally
      ms.Free;
    end;
  end;

  SetContactImage(imgBytes);

  SetLength(imgBytes, 0);
end;

procedure TForm_FloatingWindow.SetContactImage(AImage: PSafeArray);
var
  LBound: Integer;
  HBound: Integer;
  ImgBytes: TImgByteArray;
  i: Integer;
  ib: Byte;
begin
  SafeArrayGetLBound(AImage, 1, LBound);
  SafeArrayGetUBound(AImage, 1, HBound);
  SetLength(ImgBytes, HBound + 1);
  for i := LBound to HBound do
  begin
    SafeArrayGetElement(AImage, i, ib);
    ImgBytes[i] := ib;
  end;
  SafeArrayDestroy(AImage);

  SetContactImage(ImgBytes);
end;

procedure TForm_FloatingWindow.SetDisplayActivity(const Value: Boolean);
begin
  Timer_StatusRefresh.Enabled := Value;
  FDisplayActivity := Value;

  if FDisplayActivity then
  begin
    CreateUCMAClient;
    SignInUCMAClient;
  end else DestroyUCMAClient;
end;

procedure TForm_FloatingWindow.SetDisplayDelay(const Value: Integer);
var
  TimerState: Boolean;
begin
  if Value < 1
    then FDisplayDelay := 1
    else FDisplayDelay := Value;

  TimerState := Timer_Display.Enabled;
  Timer_Display.Enabled := False;
  Timer_Display.Interval := FDisplayDelay;
  Timer_Display.Enabled := TimerState;
end;

procedure TForm_FloatingWindow.SetDisplayStyle(const Value: TFloatingWindowStyle);
var
  TmpBMP: TBitmap;
begin
  case Value of
    fwsLync..fwsSkype: FDisplayStyle := Value;
    else FDisplayStyle := fwsSkype;
  end;

  with FJPEG_Default do
  try
    CompressionQuality := 100;
    Smoothing := True;
    TmpBMP := TBitmap.Create;
    try
      case FDisplayStyle of
        fwsLync: ImageList_Contact.GetBitmap(0, TmpBMP);
        fwsSkype: ImageList_Contact.GetBitmap(1, TmpBMP);
        else ImageList_Contact.GetBitmap(1, TmpBMP);
      end;
      Assign(TmpBMP);
    finally
      TmpBMP.Free;
    end;
  except

  end;

  AlignControls;
  PaintBox_Background.Repaint;
end;

procedure TForm_FloatingWindow.Show(AUser: TADObject);
begin
  SetPosition;

  if AUser = nil then
  begin
    Self.Hide(True);
    Exit;
  end;

  SetPosition;

  if FObj <> AUser then
  begin
    { Если задержка отображения небольшая, то скрывать окно нет смысла. }
    { Поэтому просто сбрасываем его состояние.                          }
    if FDisplayDelay > 99 then Hide(False) else Reset;

    FObj := AUser;

    SetContactImage(FObj);
    Label_Name.Caption := IfThen(
      FObj.displayName.IsEmpty,
      FObj.name,
      FObj.displayName
    );
    Label_Info1.Caption := FObj.title;
    if not FDisplayActivity
     then Label_Info2.Caption := FObj.physicalDeliveryOfficeName;

    { Закомментированный код ниже обновляет информацию о пользователе }
    { напрямую из Active Directory, чем нагружает сеть и ОЗУ          }
//    ZeroMemory(@FContactInfo, SizeOf(TContactInfo));
//    with FContactInfo do
//    begin
//      _Handle := Self.Handle;
//      _DistingushedName := FObj.distinguishedName;
//    end;
//
//    FThreads[0] := CreateThread(
//      @FSA,
//      0,
//      @GetContactActiveDirectoryInfo,
//      @FContactInfo,
//      0,
//      FThreadID_GetContactActiveDirectoryInfo
//    );

    if FDisplayActivity then
    try
      if FContact = nil then CreateUCMAClient;
      if not FClientSignedIn then SignInUCMAClient;
      FContact.SetContact(FObj.msRTCSIP_PrimaryUserAddress);
//      FContact.SetContact(FObj.distinguishedName);
//      Self.OnContactInformationChanged(FEventSink);
      Timer_StatusRefreshTimer(Timer_StatusRefresh);
      Timer_StatusRefresh.Enabled := True;
    except
      Label_Info2.Caption := STATUS_TEXT_UNKNOWN;
    end;

    Timer_Display.Tag := TIMER_MODE_DISPLAY_DELAY;
    Timer_Display.Enabled := True;
  end;
end;

procedure TForm_FloatingWindow.SignInUCMAClient;
begin
  if FContact <> nil then
  try
    FClientSignedIn := FContact.ClientSignIn;
  except
    FClientSignedIn := False;
  end;
end;

procedure TForm_FloatingWindow.Timer_DisplayTimer(Sender: TObject);
var
  t: TTimer absolute Sender;
  i: Integer;
begin
  if Sender is TTimer then
  case t.Tag of
    TIMER_MODE_DISPLAY_DELAY: begin
      PaintBox_BackgroundPaint(PaintBox_Background);

      for i := 0 to Self.ControlCount - 1 do
        Self.Controls[i].Refresh;

      ShowWindow(Self.Handle, SW_SHOWNOACTIVATE);
      { Выставляем Visible := True, т.к. если не выставить, то не будет работать метод Hide }
      Self.Visible := True;
      t.Enabled := False;
      t.Tag := TIMER_MODE_DISPLAY_DURATION;
      t.Interval := FDisplayDuration;
      t.Enabled := FDisplayDuration > 0;
    end;

    TIMER_MODE_DISPLAY_DURATION: begin
      Self.Hide(False);
    end;
  end;
end;

procedure TForm_FloatingWindow.Timer_StatusRefreshTimer(Sender: TObject);
begin
  if not Self.Visible
    then Exit;

  ZeroMemory(@FContactActivity, SizeOf(TContactActivity));

  with FContactActivity do
  begin
    _Handle := Self.Handle;
    _Contact := Self.FContact;
  end;

  FThreads[1] := CreateThread(
    @FSA,
    0,
    @GetContactActivity,
    @FContactActivity,
    0,
    FThreadID_GetContactActivity
  );
end;

procedure TForm_FloatingWindow.VisibleChanging;
begin
  inherited;
  case Visible of
    True: begin
      { Если окно отображается и будет скрыто }

    end;

    False: begin
      { Если окно скрыто и будет отображено   }

    end;
  end;

end;

procedure TForm_FloatingWindow.WndProc(var Message: TMessage);
var
  s: string;
begin
  inherited;

  case Message.Msg of
    WM_FWND_THREAD: begin
      if Message.LParam = FThreadID_GetContactActiveDirectoryInfo then
      begin
        if FContactInfo.DisplayName.IsEmpty
          then try FContactInfo.DisplayName := FObj.name; except end;

        Label_Name.Caption := FContactInfo.DisplayName;
        Label_Info1.Caption := FContactInfo.Info1;
        if not FDisplayActivity
          then Label_Info2.Caption := FContactInfo.Info2;

        if Length(FContactInfo.Image) > 0
          then SetContactImage(FContactInfo.Image)
          else SetContactImage(FObj);
      end else

      if Message.LParam = FThreadID_GetContactActivity then
      begin
        SetStatusImage(Message.WParam);
//        SetContactImage(FContact.Photo);
        Label_Info2.Caption := ContactActivityTextEx(FContact);
      end;
    end;
  end;
end;

procedure TForm_FloatingWindow.AlignControls;
var
 dy: Integer;
begin
  Image_Status.Top := FFormPadding;
  Image_Status.Visible := FDisplayActivity{ and (FDrawStyle = fwsClassic)};

  if FDisplayActivity then
  begin
    case FDisplayStyle of
      fwsLync: begin
        Image_Status.Left := FFormPadding;
        Image_Status.Width := 10;
      end;

      fwsSkype: begin
        Image_Status.Left := 1;
        Image_Status.Width := 8;
      end;
    end;

    Image_Contact.Left := Image_Status.Left + Image_Status.Width;
  end else Image_Contact.Left := FFormPadding + 1;

  Image_Contact.Top := Image_Status.Top + 1;

  Label_Name.Left := Image_Contact.Left + Image_Contact.Width + 10;
  Label_Name.Top := Image_Contact.Top - 1;
  Label_Name.Width := ClientWidth - Label_Name.Left - FFormPadding;

  Label_Info1.Left := Label_Name.Left;
  Label_Info1.Top := Label_Name.Top + Label_Name.Height + 4;
  Label_Info1.Width := Label_Name.Width;

  Label_Info2.Left := Label_Name.Left;
  Label_Info2.Top := Label_Info1.Top + Label_Info1.Height + 4;
  Label_Info2.Width := Label_Name.Width;
end;

end.
