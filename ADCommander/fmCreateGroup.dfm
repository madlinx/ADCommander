object Form_CreateGroup: TForm_CreateGroup
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu]
  BorderStyle = bsSingle
  Caption = #1053#1086#1074#1099#1081' '#1086#1073#1098#1077#1082#1090' - '#1043#1088#1091#1087#1087#1072
  ClientHeight = 305
  ClientWidth = 492
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  DesignSize = (
    492
    305)
  PixelsPerInch = 96
  TextHeight = 13
  object Label_sAMAccountName: TLabel
    Left = 20
    Top = 95
    Width = 113
    Height = 26
    AutoSize = False
    Caption = #1048#1084#1103' '#1075#1088#1091#1087#1087#1099': ('#1087#1088#1077#1076'-Windows 2000)'
    WordWrap = True
  end
  object Label_AccountName: TLabel
    Left = 20
    Top = 75
    Width = 63
    Height = 13
    Caption = #1048#1084#1103' '#1075#1088#1091#1087#1087#1099':'
  end
  object Label_Container: TLabel
    Left = 20
    Top = 23
    Width = 56
    Height = 13
    Caption = #1057#1086#1079#1076#1072#1090#1100' '#1074':'
  end
  object Edit_DomainNetBIOSName: TEdit
    Left = 139
    Top = 99
    Width = 335
    Height = 21
    TabStop = False
    TabOrder = 0
  end
  object Edit_AccountName: TEdit
    Left = 139
    Top = 72
    Width = 335
    Height = 21
    MaxLength = 64
    TabOrder = 1
  end
  object Button_SelectContainer: TButton
    Left = 447
    Top = 18
    Width = 27
    Height = 25
    Caption = '...'
    TabOrder = 2
  end
  object Edit_Container: TEdit
    Left = 139
    Top = 20
    Width = 302
    Height = 21
    TabStop = False
    Color = clBtnFace
    ReadOnly = True
    TabOrder = 3
  end
  object GroupBox1: TGroupBox
    Left = 20
    Top = 144
    Width = 218
    Height = 105
    Caption = ' '#1054#1073#1083#1072#1089#1090#1100' '#1076#1077#1081#1089#1090#1074#1080#1103' '#1075#1088#1091#1087#1087#1099' '
    TabOrder = 4
    object RadioButton1: TRadioButton
      Left = 16
      Top = 24
      Width = 189
      Height = 17
      Caption = #1051#1086#1082#1072#1083#1100#1085#1072#1103' '#1074' '#1076#1086#1084#1077#1085#1077
      TabOrder = 0
    end
    object RadioButton2: TRadioButton
      Left = 16
      Top = 47
      Width = 189
      Height = 17
      Caption = #1043#1083#1086#1073#1072#1083#1100#1085#1072#1103
      TabOrder = 1
    end
    object RadioButton3: TRadioButton
      Left = 16
      Top = 70
      Width = 189
      Height = 17
      Caption = #1059#1085#1080#1074#1077#1088#1089#1072#1083#1100#1085#1072#1103
      TabOrder = 2
    end
  end
  object GroupBox2: TGroupBox
    Left = 256
    Top = 144
    Width = 218
    Height = 105
    Caption = ' '#1058#1080#1087' '#1075#1088#1091#1087#1087#1099' '
    TabOrder = 5
    object RadioButton4: TRadioButton
      Left = 16
      Top = 24
      Width = 188
      Height = 17
      Caption = #1043#1088#1091#1087#1087#1072' '#1073#1077#1079#1086#1087#1072#1089#1085#1086#1089#1090#1080
      TabOrder = 0
    end
    object RadioButton5: TRadioButton
      Left = 16
      Top = 47
      Width = 188
      Height = 17
      Caption = #1043#1088#1091#1087#1087#1072' '#1088#1072#1089#1087#1088#1086#1089#1090#1088#1072#1085#1077#1085#1080#1103
      TabOrder = 1
    end
  end
  object Button_OK: TButton
    Left = 288
    Top = 265
    Width = 90
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = #1054#1050
    TabOrder = 6
  end
  object Button_Cancel: TButton
    Left = 384
    Top = 265
    Width = 90
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = #1054#1090#1084#1077#1085#1072
    TabOrder = 7
  end
end
