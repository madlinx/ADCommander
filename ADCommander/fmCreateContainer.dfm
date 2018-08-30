object Form_CreateContainer: TForm_CreateContainer
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu]
  BorderStyle = bsSingle
  Caption = #1057#1086#1079#1076#1072#1090#1100' '#1082#1086#1085#1090#1077#1081#1085#1077#1088
  ClientHeight = 119
  ClientWidth = 429
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnClose = FormClose
  DesignSize = (
    429
    119)
  PixelsPerInch = 96
  TextHeight = 13
  object Label_Container: TLabel
    Left = 20
    Top = 23
    Width = 56
    Height = 13
    Caption = #1057#1086#1079#1076#1072#1090#1100' '#1074':'
  end
  object Label_Name: TLabel
    Left = 20
    Top = 50
    Width = 23
    Height = 13
    Caption = #1048#1084#1103':'
  end
  object Button_SelectContainer: TButton
    Left = 8
    Top = 88
    Width = 27
    Height = 25
    Caption = '...'
    TabOrder = 0
    Visible = False
    OnClick = Button_SelectContainerClick
  end
  object Edit_Container: TEdit
    Left = 88
    Top = 20
    Width = 321
    Height = 21
    TabStop = False
    Color = clBtnFace
    ReadOnly = True
    TabOrder = 1
  end
  object Edit_Name: TEdit
    Left = 88
    Top = 47
    Width = 321
    Height = 21
    MaxLength = 64
    TabOrder = 2
  end
  object Button_Cancel: TButton
    Left = 319
    Top = 82
    Width = 90
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = #1054#1090#1084#1077#1085#1072
    TabOrder = 3
    OnClick = Button_CancelClick
  end
  object Button_OK: TButton
    Left = 223
    Top = 82
    Width = 90
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = #1054#1050
    TabOrder = 4
    OnClick = Button_OKClick
  end
end
