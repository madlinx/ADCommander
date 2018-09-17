object Form_ExportProgress: TForm_ExportProgress
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu]
  BorderStyle = bsSingle
  Caption = #1055#1088#1086#1075#1088#1077#1089#1089' '#1074#1099#1087#1086#1083#1085#1077#1085#1080#1103
  ClientHeight = 105
  ClientWidth = 425
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnClose = FormClose
  OnCloseQuery = FormCloseQuery
  DesignSize = (
    425
    105)
  PixelsPerInch = 96
  TextHeight = 13
  object Label_Desription: TLabel
    Left = 16
    Top = 21
    Width = 96
    Height = 13
    Caption = #1069#1082#1089#1087#1086#1088#1090' '#1076#1072#1085#1085#1099#1093'...'
  end
  object Label_Percentage: TLabel
    Left = 392
    Top = 21
    Width = 17
    Height = 13
    Alignment = taRightJustify
    Anchors = [akTop, akRight]
    Caption = '0%'
    ExplicitLeft = 440
  end
  object ProgressBar: TProgressBar
    Left = 16
    Top = 40
    Width = 393
    Height = 12
    Anchors = [akLeft, akTop, akRight]
    TabOrder = 0
    ExplicitWidth = 441
  end
  object Button_Cancel: TButton
    Left = 334
    Top = 67
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = #1054#1090#1084#1077#1085#1072
    TabOrder = 1
    OnClick = Button_CancelClick
  end
end
