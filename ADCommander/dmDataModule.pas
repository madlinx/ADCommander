unit dmDataModule;

interface

uses
  System.SysUtils, System.Classes, System.ImageList, Vcl.ImgList, Vcl.Dialogs,
  Vcl.Forms, Vcl.Controls, Vcl.AppEvnts, Vcl.ExtCtrls, Vcl.Menus, Winapi.Windows,
  Winapi.CommCtrl, Vcl.ComCtrls, ADC.GlobalVar, ADC.Types;

type
  TDM1 = class(TDataModule)
    ImageList_Main: TImageList;
    AppEvents: TApplicationEvents;
    TrayIcon: TTrayIcon;
    ImageList_Accounts: TImageList;
    ImageList_AccCtxMenu: TImageList;
    PopupMenu_TrayIcon: TPopupMenu;
    N1: TMenuItem;
    N2: TMenuItem;
    N3: TMenuItem;
    OpenDialog: TOpenDialog;
    ImageList_AccountDefault: TImageList;
    SaveDialog: TSaveDialog;
    ImageList_16x16: TImageList;
    procedure AppEventsMinimize(Sender: TObject);
    procedure DataModuleCreate(Sender: TObject);
    procedure TrayIconMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure AppEventsRestore(Sender: TObject);
    procedure AppEventsShowHint(var HintStr: string; var CanShow: Boolean;
      var HintInfo: THintInfo);
    procedure N3Click(Sender: TObject);
    procedure N1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  DM1: TDM1;

implementation

uses
  fmMainForm, fmSettings;

{%CLASSGROUP 'Vcl.Controls.TControl'}

{$R *.dfm}

procedure TDM1.AppEventsMinimize(Sender: TObject);
begin
  if apMinimizeToTray then
  begin
    ADCmd_MainForm.Hide;
    DM1.TrayIcon.Visible := True;
  end;
end;

procedure TDM1.AppEventsRestore(Sender: TObject);
begin
  ADCmd_MainForm.Frame_Search.Edit_SearchPattern.SetFocus;
end;

procedure TDM1.AppEventsShowHint(var HintStr: string; var CanShow: Boolean;
  var HintInfo: THintInfo);
var
  StatusBar: TStatusBar;
  R: TRect;
  idx: integer;
  TextWidth: integer;
begin
  StatusBar := ADCmd_MainForm.StatusBar;

  if (HintInfo.HintControl = StatusBar) and (not StatusBar.SimplePanel) then
  begin
    for idx := 0 to StatusBar.Panels.Count - 1 do
    begin
      SendMessage(statusBar.Handle, SB_GETRECT, idx, Longint(@R));
      if PtInRect(R, HintInfo.CursorPos) then
      begin
        case idx of
          0: begin
            HintStr := 'Число записей';
            if ADCmd_MainForm.Frame_Search.Edit_SearchPattern.Text <> ''
              then HintStr := HintStr + #13#10 + 'Фильтр включен';
          end;

          1: begin
            HintStr := 'Полное имя учетной записи';
            statusBar.Canvas.Font := statusBar.Font;
            textWidth := statusBar.Canvas.TextWidth(statusBar.Panels[1].Text);
            if textWidth > statusBar.Panels[idx].Width
              then HintStr := HintStr + #13#10 + statusBar.Panels[idx].Text;
          end;

          2: begin
            HintStr := 'Срок действия пароля';
          end;

          3: begin
            HintStr := 'Количество ошибок ввода пароля';
          end;

          4: begin
            HintStr := 'Используемый API';
          end;
        end;
        InflateRect(R, 3, 3);
        { Устанавливаем CursorRect говоря системе проверить новые
        строки с подсказками, когда курсор покинет этот прямоугольник. }
        HintInfo.CursorRect := R;
        Break;
      end;
    end;
  end;
end;

procedure TDM1.DataModuleCreate(Sender: TObject);
begin
  TrayIcon.Icon := Application.Icon;
  TrayIcon.Hint := APP_TITLE;
end;

procedure TDM1.N1Click(Sender: TObject);
begin
  TrayIconMouseDown(Sender, mbLeft, [], 0, 0);
end;

procedure TDM1.N3Click(Sender: TObject);
var
  CloseAction: TCloseAction;
begin
  CloseAction := caFree;
  ADCmd_MainForm.FormClose(Sender, CloseAction);
end;

procedure TDM1.TrayIconMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  case Button of
    mbLeft: begin
      case ADCmd_MainForm.WindowState of
        wsMinimized: begin
          ADCmd_MainForm.Visible := True;
          ShowWindow(ADCmd_MainForm.Handle, SW_RESTORE) ;
////          ADUI_MainForm.WindowState := wsNormal;
          Application.BringToFront();
//          TrayIcon1.Visible := False;
          ADCmd_MainForm.Frame_Search.Edit_SearchPattern.SetFocus;
        end;
        else Application.BringToFront;
      end;
    end;

    mbMiddle: ;

    mbRight: ;
  end;
end;

end.
