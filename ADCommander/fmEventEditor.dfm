object Form_EventEditor: TForm_EventEditor
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu]
  BorderStyle = bsSingle
  Caption = #1057#1086#1073#1099#1090#1080#1077
  ClientHeight = 195
  ClientWidth = 377
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  KeyPreview = True
  OldCreateOrder = False
  OnClose = FormClose
  OnKeyDown = FormKeyDown
  PixelsPerInch = 96
  TextHeight = 13
  object DateTimePicker: TDateTimePicker
    Left = 16
    Top = 16
    Width = 97
    Height = 21
    Date = 0.000011574074074074
    Time = 0.000011574074074074
    DoubleBuffered = True
    ParentDoubleBuffered = False
    TabOrder = 0
  end
  object Memo_Description: TMemo
    Left = 16
    Top = 43
    Width = 345
    Height = 110
    ScrollBars = ssVertical
    TabOrder = 1
  end
  object Button_Cancel: TButton
    Left = 286
    Top = 162
    Width = 75
    Height = 25
    Caption = #1054#1090#1084#1077#1085#1072
    TabOrder = 2
    OnClick = Button_CancelClick
  end
  object Button_OK: TButton
    Left = 205
    Top = 162
    Width = 75
    Height = 25
    Caption = 'OK'
    TabOrder = 3
    OnClick = Button_OKClick
  end
end
