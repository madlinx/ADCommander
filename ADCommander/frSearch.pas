unit frSearch;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.Themes,
  ADC.Types, ADC.Common, Vcl.Buttons, Vcl.ExtCtrls;

type
  TPanel = class(Vcl.ExtCtrls.TPanel)
    private
      procedure WMPaint(var Msg: TMessage); message WM_PAINT;
end;

type
  TBitBtn = class(Vcl.Buttons.TBitBtn)
    private
      procedure WMPaint(var Msg: TMessage); message WM_PAINT;
      procedure WMSetFocus(var Message: TWMSetFocus); message WM_SETFOCUS;
  end;

type
  TComboBox = class(Vcl.StdCtrls.TComboBox)
  private
    procedure CN_DrawItem(var Message : TWMDrawItem); message CN_DRAWITEM;
    procedure WMPaint(var Msg: TMessage); message WM_PAINT;
    procedure WMNCPaint(var Msg: TMessage); message WM_NCPAINT;
  end;

type
  TFrame_Search = class(TFrame)
    Edit_SearchPattern: TEdit;
    ComboBox_SearchOption: TComboBox;
    Button_ClearPattern: TBitBtn;
    Panel_Search: TPanel;
    procedure ComboBox_SearchOptionDropDown(Sender: TObject);
    procedure ComboBox_SearchOptionDrawItem(Control: TWinControl;
      Index: Integer; Rect: TRect; State: TOwnerDrawState);
    procedure ComboBox_SearchOptionSelect(Sender: TObject);
    procedure FrameResize(Sender: TObject);
    procedure Button_ClearPatternClick(Sender: TObject);
    procedure Edit_SearchPatternChange(Sender: TObject);
  private
    { Private declarations }
    FComboBoxMargin: Byte;
    FComboBoxWndProc: TWndMethod;
    procedure ComboBoxWndProc(var Message: TMessage);
    procedure SetComboBoxWidth;
    procedure SetComboBoxDropDownWidth;
    procedure SetFilterOption(Value: Byte);
    function GetFilterOption: Byte;
  public
    { Public declarations }
    procedure InitControls;
    property FilterOption: Byte read GetFilterOption write SetFilterOption;
  end;

implementation

{$R *.dfm}

{ TComboBox }

procedure TComboBox.CN_DrawItem(var Message: TWMDrawItem);
begin
  with Message do
    DrawItemStruct.itemState := DrawItemStruct.itemState and not ODS_FOCUS;

  inherited;
end;

procedure TComboBox.WMNCPaint(var Msg: TMessage);
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

procedure TComboBox.WMPaint(var Msg: TMessage);
var
  C: TControlCanvas;
  R: TRect;
begin
  inherited;

  C := TControlCanvas.Create;
  try
    C.Control := Self;
    with C do
    begin
      { Рисуем новую рамку }
      Brush.Color := StyleServices.GetStyleColor(scBorder);
      R := ClientRect;
      FrameRect(R);
      { Левую сторону перерисовываем как разделитель }
      Pen.Color := clWindow;
      MoveTo(0, 1);
      LineTo(0, R.Height - 1);
      Pen.Color := clSilver;
      MoveTo(0, 3);
      LineTo(0, R.Height - 3);
    end;
  finally
    C.Free;
  end;
end;

procedure TFrame_Search.Button_ClearPatternClick(Sender: TObject);
begin
  Edit_SearchPattern.Clear;
  Edit_SearchPattern.SetFocus;
end;

procedure TFrame_Search.ComboBoxWndProc(var Message: TMessage);
var
  cbR: TRect;
  lbR: TRect;
begin
  if Message.Msg = WM_CTLCOLORLISTBOX then
  begin
    GetWindowRect(ComboBox_SearchOption.Handle, cbR);
    GetWindowRect(Message.LParam, lbR);
    if cbR.Right <> lbR.Right then MoveWindow(
      Message.LParam,
      lbR.Left - (lbR.Right - cbR.Right),
      lbR.Top,
      lbR.Right - lbR.Left,
      lbR.Bottom - lbR.Top,
      True
    );
  end
  else FComboBoxWndProc(Message);
end;

procedure TFrame_Search.ComboBox_SearchOptionDrawItem(Control: TWinControl;
  Index: Integer; Rect: TRect; State: TOwnerDrawState);
var
  ItemText: string;
  C: TCanvas;
  DC: HDC;
  DrawRect: TRect;
  TextWidth: Integer;
begin
  ItemText := ComboBox_SearchOption.Items[Index];
  DC := ComboBox_SearchOption.Canvas.Handle;
  C := ComboBox_SearchOption.Canvas;
  C.Font.Color := clGray;
  C.FillRect(Rect);
  if odSelected in State then
  begin
    if odComboBoxEdit in State then
    begin
      C.Brush.Color := StyleServices.GetStyleColor(scComboBox);
      C.FillRect(Rect);
      { ВАЖНО: Вызываем C.DrawFocusRect(Rect) дважды с разным   }
      { цветом кисти. Иначе цвет FocusRect всегда темный черный }
      C.Brush.Color := clBlack;
      C.DrawFocusRect(Rect);
      C.Brush.Color := StyleServices.GetStyleColor(scComboBox);
      C.DrawFocusRect(Rect);
    end else
    begin
      C.Brush.Color := clSilver;
      C.Font.Color := clWhite;
      C.FillRect(Rect);
    end;
  end;

  { Выводим текст }
  DrawRect := Rect;
  OffsetRect(DrawRect, FComboBoxMargin, 1);
  DrawRect.Right := Rect.Right - FComboBoxMargin;
  C.TextRect(DrawRect, ItemText, [tfLeft, tfEndEllipsis]);
end;

procedure TFrame_Search.ComboBox_SearchOptionDropDown(Sender: TObject);
begin
  SetComboBoxDropDownWidth;
end;

procedure TFrame_Search.ComboBox_SearchOptionSelect(Sender: TObject);
begin
  SetComboBoxWidth;
  Edit_SearchPattern.SetFocus;
end;

procedure TFrame_Search.Edit_SearchPatternChange(Sender: TObject);
begin
  Button_ClearPattern.Visible := Edit_SearchPattern.Text <> '';
end;

procedure TFrame_Search.FrameResize(Sender: TObject);
begin
  Panel_Search.Top := Round((Self.ClientHeight - Panel_Search.Height) / 2);
end;

function TFrame_Search.GetFilterOption: Byte;
begin
  Result := ComboBox_SearchOption.ItemIndex;
end;

procedure TFrame_Search.InitControls;
var
  i: Integer;
begin
  Button_ClearPattern.Hide;
  FComboBoxMargin := 3;

  SendMessage(
    Edit_SearchPattern.Handle,
    EM_SETMARGINS,
    EC_LEFTMARGIN or EC_RIGHTMARGIN,
    MakeLong(FComboBoxMargin, 0)
  );

  FComboBoxWndProc := ComboBox_SearchOption.WindowProc;
  ComboBox_SearchOption.WindowProc := ComboBoxWndProc;

  SetComboBoxWidth;
  SetFilterOption(0);

  for i := 0 to Self.ControlCount - 1 do
    Self.Controls[i].Repaint;
end;

procedure TFrame_Search.SetComboBoxDropDownWidth;
var
  ItemText: string;
  TextWidth: Integer;
  MaxWidth: Integer;
begin
  MaxWidth := 0;
  for ItemText in ComboBox_SearchOption.Items do
  begin
    TextWidth := GetTextWidthInPixels(ItemText, ComboBox_SearchOption.Font);
    if MaxWidth < TextWidth then MaxWidth := TextWidth;
  end;

  MaxWidth := MaxWidth + FComboBoxMargin * 2 + 2;

  if (MaxWidth > ComboBox_SearchOption.Width) then
  begin
    if ComboBox_SearchOption.DropDownCount < ComboBox_SearchOption.Items.Count
      then MaxWidth := MaxWidth + GetSystemMetrics(SM_CXVSCROLL);
    SendMessage(ComboBox_SearchOption.Handle, CB_SETDROPPEDWIDTH, MaxWidth, 0);
  end;
end;

procedure TFrame_Search.SetComboBoxWidth;
begin
  ComboBox_SearchOption.Width := GetSystemMetrics(SM_CXHTHUMB)
    + GetSystemMetrics(SM_CYFIXEDFRAME) * 2
    + GetTextWidthInPixels(ComboBox_SearchOption.Text, ComboBox_SearchOption.Font)
    + FComboBoxMargin * 2;
end;

procedure TFrame_Search.SetFilterOption(Value: Byte);
begin
  if (Value > ComboBox_SearchOption.Items.Count - 1)
    then ComboBox_SearchOption.ItemIndex := FILTER_BY_ANY
    else ComboBox_SearchOption.ItemIndex := Value;

  SetComboBoxWidth;
end;

{ TBitBtn }

procedure TBitBtn.WMPaint(var Msg: TMessage);
var
  C: TControlCanvas;
  R: TRect;
begin
  inherited;

  C := TControlCanvas.Create;
  try
    C.Control := Self;
    with C do
    begin
      { Закрашиваем стандартную рамку }
      Brush.Color := clWindow;
      R := ClientRect;
      FrameRect(R);
      FillRect(R);
      InflateRect(R, -1, -1);
      FrameRect(R);

      { Рисуем новую рамку }
      Brush.Color := StyleServices.GetStyleColor(scBorder);
      R := ClientRect;
      FrameRect(R);
      Brush.Color := clWindow;
      InflateRect(R, 0, -1);
      FillRect(R);
      Draw(
        Round((ClipRect.Width - Self.Glyph.Width) / 2),
        Round((ClipRect.Height - Self.Glyph.Height) / 2),
        Self.Glyph
      );
//      Pen.Color := StyleServices.GetStyleColor(scBorder);
//      MoveTo(0, 0);
//      LineTo(ClipRect.Width, 0);
//      Pen.Color := StyleServices.GetStyleColor(scBorder);
//      MoveTo(0, ClipRect.Height);
//      LineTo(ClipRect.Width, ClipRect.Height);
    end;
  finally
    C.Free;
  end;
end;

procedure TBitBtn.WMSetFocus(var Message: TWMSetFocus);
var
  C: TControlCanvas;
  R: TRect;
begin
  inherited;

  C := TControlCanvas.Create;
  try
    C.Control := Self;
    with C do
    begin
      { Закрашиваем стандартную рамку }
      Brush.Color := clWindow;
      R := ClientRect;
      FrameRect(R);
      FillRect(R);
      InflateRect(R, -1, -1);
      FrameRect(R);

      { Рисуем новую рамку }
      Brush.Color := StyleServices.GetStyleColor(scBorder);
      R := ClientRect;
      FrameRect(R);
      Brush.Color := clWindow;
      InflateRect(R, 0, -1);
      FillRect(R);
      InflateRect(R, -2, -2);
      DrawFocusRect(R);
      Draw(
        Round((ClipRect.Width - Self.Glyph.Width) / 2),
        Round((ClipRect.Height - Self.Glyph.Height) / 2),
        Self.Glyph
      );
    end;
  finally
    C.Free;
  end;
end;

{ TPanel }

procedure TPanel.WMPaint(var Msg: TMessage);
var
  C: TControlCanvas;
  R: TRect;
begin
  inherited;

  C := TControlCanvas.Create;
  try
    C.Control := Self;
    with C do
    begin
      { Заливаем фон }
      Brush.Color := clWindow;
      R := ClientRect;
      FillRect(R);

      { Рисуем рамку }
      Brush.Color := StyleServices.GetStyleColor(scBorder);
      R := ClientRect;
      FrameRect(R);
    end;
  finally
    C.Free;
  end;
end;

end.
