object Form_ResetPassword: TForm_ResetPassword
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu]
  BorderStyle = bsSingle
  Caption = #1057#1084#1077#1085#1072' '#1087#1072#1088#1086#1083#1103
  ClientHeight = 254
  ClientWidth = 361
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
  DesignSize = (
    361
    254)
  PixelsPerInch = 96
  TextHeight = 13
  object Label15: TLabel
    Left = 16
    Top = 46
    Width = 87
    Height = 13
    Caption = #1055#1086#1076#1090#1074#1077#1088#1078#1076#1077#1085#1080#1077':'
  end
  object Label14: TLabel
    Left = 16
    Top = 19
    Width = 76
    Height = 13
    Caption = #1053#1086#1074#1099#1081' '#1087#1072#1088#1086#1083#1100':'
  end
  object Label1: TLabel
    Left = 32
    Top = 100
    Width = 315
    Height = 28
    AutoSize = False
    Caption = 
      #1053#1077#1086#1073#1093#1086#1076#1080#1084#1086' '#1074#1099#1081#1090#1080' '#1080#1079' '#1089#1080#1089#1090#1077#1084#1099' '#1080' '#1074#1086#1081#1090#1080' '#1074' '#1089#1080#1089#1090#1077#1084#1091' '#1079#1072#1085#1086#1074#1086', '#1095#1090#1086#1073#1099' '#1080#1079#1084#1077 +
      #1085#1077#1085#1080#1103' '#1074#1089#1090#1091#1087#1080#1083#1080' '#1074' '#1089#1080#1083#1091'.'
    WordWrap = True
  end
  object Label2: TLabel
    Left = 16
    Top = 144
    Width = 331
    Height = 25
    AutoSize = False
    Caption = 
      #1057#1086#1089#1090#1086#1103#1085#1080#1077' '#1073#1083#1086#1082#1080#1088#1086#1074#1082#1080' '#1091#1095#1077#1090#1085#1086#1081' '#1079#1072#1087#1080#1089#1080' '#1085#1072' '#1076#1072#1085#1085#1086#1084' '#1082#1086#1085#1090#1088#1086#1083#1083#1077#1088#1077' '#1076#1086#1084#1077#1085#1072 +
      ':'
    WordWrap = True
  end
  object Bevel1: TBevel
    Left = 0
    Top = 211
    Width = 361
    Height = 43
    Align = alBottom
    Shape = bsTopLine
    ExplicitTop = 214
  end
  object Edit_Password1: TEdit
    Left = 126
    Top = 16
    Width = 221
    Height = 21
    MaxLength = 128
    PasswordChar = #8226
    TabOrder = 0
  end
  object CheckBox_ChangeOnLogon: TCheckBox
    Left = 16
    Top = 80
    Width = 331
    Height = 17
    Caption = #1058#1088#1077#1073#1086#1074#1072#1090#1100' '#1089#1084#1077#1085#1099' '#1087#1072#1088#1086#1083#1103' '#1087#1088#1080' '#1089#1083#1077#1076#1091#1102#1097#1077#1084' '#1074#1093#1086#1076#1077' '#1074' '#1089#1080#1089#1090#1077#1084#1091
    TabOrder = 2
    OnClick = CheckBox_ChangeOnLogonClick
  end
  object Edit_Password2: TEdit
    Left = 126
    Top = 43
    Width = 221
    Height = 21
    MaxLength = 128
    PasswordChar = #8226
    TabOrder = 1
  end
  object Button_Cancel: TButton
    Left = 263
    Top = 221
    Width = 90
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = #1054#1090#1084#1077#1085#1072
    TabOrder = 4
    OnClick = Button_CancelClick
  end
  object Button_OK: TButton
    Left = 167
    Top = 221
    Width = 90
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = #1054#1050
    TabOrder = 5
    OnClick = Button_OKClick
  end
  object CheckBox_Unblock: TCheckBox
    Left = 32
    Top = 175
    Width = 315
    Height = 17
    Caption = #1056#1072#1079#1073#1083#1086#1082#1080#1088#1086#1074#1072#1090#1100' '#1091#1095#1077#1090#1085#1091#1102' '#1079#1072#1087#1080#1089#1100
    TabOrder = 3
  end
end
