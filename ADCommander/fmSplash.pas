unit fmSplash;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls,
  ADC.Types, ADC.Common, ADC.GlobalVar, ADC.ADObject, Vcl.Imaging.pngimage;

type
  TForm_Splash = class(TForm)
    Label_AppVersion: TLabel;
    Label_AppName: TLabel;
    Label_Copyright: TLabel;
    Label_Department: TLabel;
    Image_Splash: TImage;
    Label_Info: TLabel;
    Label_API: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
    const
      csProgressInfo = 'Поиск объектов в домене %s...   %s';
      csJoker = 'klever';
  private
    FBitMap: TBitMap;
    FRect: TRect;
    function GetJokeAppTitle: string;
    function GetJokeAppVersion: string;
    function GetCurrentUserName: string;
  public
    procedure OnEnumProgress(AItem: TObject; AProgress: Integer);
    procedure OnEnumException(AMsg: string; ACode: ULONG);
    procedure OnEnumComplete(Sender: TObject);
    procedure DrawInfoText(AText: string);
  end;

var
  Form_Splash: TForm_Splash;

implementation

{$R *.dfm}

procedure TForm_Splash.DrawInfoText(AText: string);
var
  c: TCanvas;
  r: TRect;
begin
  try
    c := Label_Info.Canvas;
    c.Brush.Style := bsClear;
    c.Font.Color := clWhite;
    r := c.ClipRect;
    c.CopyRect(r, FBitMap.Canvas, FRect);
    c.TextOut(0, 0, AText);
//    c.TextRect(r, AText, [tfEndEllipsis, tfSingleLine, tfVerticalCenter]);
  except

  end;

  Label_Info.Update;
end;

procedure TForm_Splash.FormCreate(Sender: TObject);
const
  CopyrightStr: string = 'Copyright © 2017-%d, JSC Mozyr Oil Refinery';
begin
  Label_API.Caption := '';
  Label_AppName.Caption := GetJokeAppTitle;
  Label_AppVersion.Caption := GetJokeAppVersion;
  Label_Info.Caption := '';
  Label_Copyright.Caption := Format(CopyrightStr, [CurrentYear]);
  Position := poDesigned;
  Top := (Screen.PrimaryMonitor.Height - Height) div 2;
  Left := (Screen.PrimaryMonitor.Width - Width) div 2;

  FBitMap := TBitmap.Create;
  try
    FBitMap.Assign(Image_Splash.Picture);
    FRect.TopLeft := Point(Label_Info.Left, Label_Info.Top);
    FRect.Width := Label_Info.Width;
    FRect.Height := Label_Info.Height;
  except

  end;
end;

procedure TForm_Splash.FormDestroy(Sender: TObject);
begin
  if FBitMap <> nil
    then FBitMap.Free;
end;

function TForm_Splash.GetCurrentUserName: string;
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

function TForm_Splash.GetJokeAppTitle: string;
const
  UNLEN = 256;
var
  BuffSize: Cardinal;
  n: PWideChar;
begin
  BuffSize := UNLEN + 1;
  GetMem(n, BuffSize);
  GetUserName(n, BuffSize);
  if CompareText(string(n), csJoker) = 0
    then Result := APP_TITLE_JOKE
    else Result := APP_TITLE;
  FreeMem(n);
end;

function TForm_Splash.GetJokeAppVersion: string;
const
  UNLEN = 256;
var
  BuffSize: Cardinal;
  n: PWideChar;
begin
  Result := 'Версия: ' + GetFileInfo(Application.ExeName, 'ProductVersion');
  {$IFDEF WIN64}
    Result := Result + ' (x64)';
  {$ENDIF}
  BuffSize := UNLEN + 1;
  GetMem(n, BuffSize);
  GetUserName(n, BuffSize);
  if CompareText(string(n), csJoker) = 0
    then Result := Result + ' - Kalashnikoff''s Edition';
  FreeMem(n);
end;

procedure TForm_Splash.OnEnumComplete(Sender: TObject);
begin
  DrawInfoText(Format(csProgressInfo, [SelectedDC.DomainDnsName, FormatFloat('#,##0', List_ObjFull.Count)]));
  Sleep(50);
  List_ObjFull.SortObjects;
  List_ObjFull.Filter.Apply;
end;

procedure TForm_Splash.OnEnumException(AMsg: string; ACode: ULONG);
var
  s: string;
begin
  if ACode = 0
    then s := AMsg
    else s := AMsg + Format(' Error code: ', [ACode]);

  DrawInfoText(s);
end;

procedure TForm_Splash.OnEnumProgress(AItem: TObject; AProgress: Integer);
var
  s: string;
begin
  if AItem <> nil
    then if AItem is TADObject then
    begin
      if apEventsStorage = CTRL_EVENT_STORAGE_DISK
        then TADObject(AItem).LoadEventsFromFile(apEventsDir);
    end;

  if AProgress mod 25 = 0 then
  begin
    if AProgress = 0
      then s := Format(csProgressInfo, [SelectedDC.DomainDnsName, ''])
      else s := Format(csProgressInfo, [SelectedDC.DomainDnsName, FormatFloat('#,##0', AProgress)]);

    DrawInfoText(s);
  end;
end;

end.
