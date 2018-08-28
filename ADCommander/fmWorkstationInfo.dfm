object Form_WorkstationInfo: TForm_WorkstationInfo
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu]
  BorderStyle = bsSingle
  Caption = #1050#1086#1084#1087#1100#1102#1090#1077#1088' '#1087#1086#1083#1100#1079#1086#1074#1072#1090#1077#1083#1103
  ClientHeight = 284
  ClientWidth = 433
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
  DesignSize = (
    433
    284)
  PixelsPerInch = 96
  TextHeight = 13
  object Label_OS: TLabel
    Left = 24
    Top = 175
    Width = 121
    Height = 13
    Caption = #1054#1087#1077#1088#1072#1094#1080#1086#1085#1085#1072#1103' '#1089#1080#1089#1090#1077#1084#1072':'
  end
  object Label_InvNumber: TLabel
    Left = 24
    Top = 202
    Width = 106
    Height = 13
    Caption = #1048#1085#1074#1077#1085#1090#1072#1088#1085#1099#1081' '#1085#1086#1084#1077#1088':'
  end
  object Label_DHCP_Server: TLabel
    Left = 24
    Top = 148
    Width = 71
    Height = 13
    Caption = 'DHCP '#1057#1077#1088#1074#1077#1088':'
  end
  object Label_MACAddress: TLabel
    Left = 24
    Top = 121
    Width = 97
    Height = 13
    Caption = #1060#1080#1079#1080#1095#1077#1089#1082#1080#1081' '#1072#1076#1088#1077#1089':'
  end
  object Label_IPAddress: TLabel
    Left = 24
    Top = 94
    Width = 60
    Height = 13
    Caption = 'IPv4-'#1072#1076#1088#1077#1089':'
  end
  object Label_Name: TLabel
    Left = 24
    Top = 67
    Width = 89
    Height = 13
    Caption = #1048#1084#1103' '#1082#1086#1084#1087#1100#1102#1090#1077#1088#1072':'
  end
  object Bevel1: TBevel
    Left = 0
    Top = 241
    Width = 433
    Height = 43
    Align = alBottom
    Shape = bsTopLine
    ExplicitTop = 143
    ExplicitWidth = 337
  end
  object Label1: TLabel
    Left = 24
    Top = 24
    Width = 97
    Height = 13
    Caption = #1048#1084#1103' '#1087#1086#1083#1100#1079#1086#1074#1072#1090#1077#1083#1103':'
  end
  object Edit_OS: TEdit
    Left = 157
    Top = 172
    Width = 251
    Height = 21
    Anchors = [akLeft, akTop, akRight]
    AutoSelect = False
    Color = clBtnFace
    ReadOnly = True
    TabOrder = 5
  end
  object Edit_InvNumber: TEdit
    Left = 157
    Top = 199
    Width = 251
    Height = 21
    Anchors = [akLeft, akTop, akRight]
    AutoSelect = False
    Color = clBtnFace
    MaxLength = 16
    ReadOnly = True
    TabOrder = 6
  end
  object Edit_DHCP_Server: TEdit
    Left = 157
    Top = 145
    Width = 251
    Height = 21
    Anchors = [akLeft, akTop, akRight]
    AutoSelect = False
    Color = clBtnFace
    ReadOnly = True
    TabOrder = 4
  end
  object Edit_MAC_Address: TEdit
    Left = 157
    Top = 118
    Width = 251
    Height = 21
    Anchors = [akLeft, akTop, akRight]
    AutoSelect = False
    Color = clBtnFace
    ReadOnly = True
    TabOrder = 3
  end
  object Edit_IPv4_Address: TEdit
    Left = 157
    Top = 91
    Width = 251
    Height = 21
    Anchors = [akLeft, akTop, akRight]
    AutoSelect = False
    Color = clBtnFace
    ReadOnly = True
    TabOrder = 2
  end
  object ComboBox_Name: TComboBox
    Left = 157
    Top = 64
    Width = 251
    Height = 21
    Style = csDropDownList
    Anchors = [akLeft, akTop, akRight]
    TabOrder = 1
    OnSelect = ComboBox_NameSelect
  end
  object Button_Close: TButton
    Left = 350
    Top = 251
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = #1047#1072#1082#1088#1099#1090#1100
    TabOrder = 7
    OnClick = Button_CloseClick
  end
  object Edit_UserName: TEdit
    Left = 157
    Top = 21
    Width = 251
    Height = 21
    Anchors = [akLeft, akTop, akRight]
    Color = clBtnFace
    ReadOnly = True
    TabOrder = 0
  end
end
