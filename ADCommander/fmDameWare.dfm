object Form_DameWare: TForm_DameWare
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu]
  BorderStyle = bsSingle
  Caption = 'DameWare MRC - '#1055#1086#1076#1082#1083#1102#1095#1077#1085#1080#1077
  ClientHeight = 309
  ClientWidth = 366
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
  object Label_DMRC_Domain: TLabel
    Left = 16
    Top = 128
    Width = 36
    Height = 13
    Caption = #1044#1086#1084#1077#1085':'
  end
  object Label_DMRC_Password: TLabel
    Left = 16
    Top = 101
    Width = 41
    Height = 13
    Caption = #1055#1072#1088#1086#1083#1100':'
  end
  object Label_DMRC_Username: TLabel
    Left = 16
    Top = 74
    Width = 97
    Height = 13
    Caption = #1048#1084#1103' '#1087#1086#1083#1100#1079#1086#1074#1072#1090#1077#1083#1103':'
  end
  object Label_DMRC_Authorization: TLabel
    Left = 16
    Top = 47
    Width = 126
    Height = 13
    Caption = #1052#1077#1090#1086#1076' '#1072#1091#1090#1077#1085#1090#1080#1092#1080#1082#1072#1094#1080#1080':'
  end
  object Label_DMRC_ComputerName: TLabel
    Left = 16
    Top = 19
    Width = 89
    Height = 13
    Caption = #1048#1084#1103' '#1082#1086#1084#1087#1100#1102#1090#1077#1088#1072':'
  end
  object Bevel1: TBevel
    Left = 0
    Top = 264
    Width = 366
    Height = 45
    Align = alBottom
    Shape = bsTopLine
  end
  object ComboBox_DMRC: TComboBox
    Left = 153
    Top = 43
    Width = 198
    Height = 22
    Style = csOwnerDrawFixed
    ItemIndex = 2
    TabOrder = 2
    Text = 'Encrypted Windows Logon'
    OnSelect = ComboBox_DMRCSelect
    Items.Strings = (
      'Proprietary Challenge/Response'
      'Windows NT Challenge/Response'
      'Encrypted Windows Logon'
      'Smart Card Logon'
      'Current Logon Credentials')
  end
  object CheckBox_DMRC_Auto: TCheckBox
    Left = 16
    Top = 231
    Width = 335
    Height = 17
    Caption = #1055#1086#1076#1082#1083#1102#1095#1072#1090#1100#1089#1103' '#1072#1074#1090#1086#1084#1072#1090#1080#1095#1077#1089#1082#1080
    Checked = True
    State = cbChecked
    TabOrder = 9
  end
  object CheckBox_DMRC_Driver: TCheckBox
    Left = 16
    Top = 208
    Width = 335
    Height = 17
    Caption = #1048#1089#1087#1086#1083#1100#1079#1086#1074#1072#1090#1100' DameWare Mirror Driver ('#1077#1089#1083#1080' '#1091#1089#1090#1072#1085#1086#1074#1083#1077#1085')'
    TabOrder = 8
  end
  object RadioButton_DMRC_Viewer: TRadioButton
    Left = 16
    Top = 185
    Width = 335
    Height = 17
    Caption = #1048#1089#1087#1086#1083#1100#1079#1086#1074#1072#1090#1100' MRC Viewer'
    Checked = True
    TabOrder = 7
    TabStop = True
    OnClick = RadioButton_DMRC_ViewerClick
  end
  object RadioButton_DMRC_RDP: TRadioButton
    Left = 16
    Top = 162
    Width = 335
    Height = 17
    Caption = #1048#1089#1087#1086#1083#1100#1079#1086#1074#1072#1090#1100' Remote Desktop Protocol (RDP)'
    TabOrder = 6
    OnClick = RadioButton_DMRC_RDPClick
  end
  object Edit_DMRC_dom: TEdit
    Left = 153
    Top = 125
    Width = 198
    Height = 21
    AutoSelect = False
    TabOrder = 5
  end
  object Edit_DMRC_pass: TEdit
    Left = 153
    Top = 98
    Width = 198
    Height = 21
    AutoSelect = False
    PasswordChar = #8226
    TabOrder = 4
  end
  object Edit_DMRC_user: TEdit
    Left = 153
    Top = 71
    Width = 198
    Height = 21
    AutoSelect = False
    TabOrder = 3
  end
  object ComboBox_Computer: TComboBox
    Left = 153
    Top = 16
    Width = 170
    Height = 21
    TabOrder = 0
  end
  object Button_Control: TButton
    Left = 112
    Top = 275
    Width = 84
    Height = 25
    Caption = #1059#1087#1088#1072#1074#1083#1077#1085#1080#1077
    TabOrder = 12
    OnClick = Button_ControlClick
  end
  object Button_View: TButton
    Left = 202
    Top = 275
    Width = 75
    Height = 25
    Caption = #1055#1088#1086#1089#1084#1086#1090#1088
    TabOrder = 11
    OnClick = Button_ViewClick
  end
  object Button_Cancel: TButton
    Left = 283
    Top = 275
    Width = 75
    Height = 25
    Caption = #1054#1090#1084#1077#1085#1072
    TabOrder = 10
    OnClick = Button_CancelClick
  end
  object Button_GetIP: TButton
    Left = 326
    Top = 14
    Width = 25
    Height = 25
    ImageIndex = 2
    ImageMargins.Left = 2
    ImageMargins.Top = 1
    Images = DM1.ImageList_16x16
    TabOrder = 1
    OnClick = Button_GetIPClick
  end
end
