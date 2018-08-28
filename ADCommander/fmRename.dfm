object Form_Rename: TForm_Rename
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu]
  BorderStyle = bsSingle
  Caption = #1055#1077#1088#1077#1080#1084#1077#1085#1086#1074#1072#1090#1100' '#1086#1073#1098#1077#1082#1090
  ClientHeight = 97
  ClientWidth = 393
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
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object Label_Name: TLabel
    Left = 16
    Top = 16
    Width = 98
    Height = 13
    Caption = #1053#1086#1074#1086#1077' '#1080#1084#1103' '#1086#1073#1098#1077#1082#1090#1072
  end
  object Edit_Name: TEdit
    Left = 16
    Top = 35
    Width = 361
    Height = 21
    MaxLength = 255
    TabOrder = 0
  end
  object Button_Close: TButton
    Left = 302
    Top = 64
    Width = 75
    Height = 25
    Caption = #1047#1072#1082#1088#1099#1090#1100
    TabOrder = 1
    OnClick = Button_CloseClick
  end
  object Button_Apply: TButton
    Left = 221
    Top = 64
    Width = 75
    Height = 25
    Caption = #1055#1088#1080#1084#1077#1085#1080#1090#1100
    TabOrder = 2
    OnClick = Button_ApplyClick
  end
  object Button_OK: TButton
    Left = 140
    Top = 64
    Width = 75
    Height = 25
    Caption = 'OK'
    TabOrder = 3
    OnClick = Button_OKClick
  end
end
