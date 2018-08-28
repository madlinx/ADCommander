object Form_ComputerInfo: TForm_ComputerInfo
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu]
  BorderStyle = bsSingle
  Caption = #1057#1074#1086#1081#1089#1090#1074#1072' '#1082#1086#1084#1087#1100#1102#1090#1077#1088#1072
  ClientHeight = 242
  ClientWidth = 409
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
    409
    242)
  PixelsPerInch = 96
  TextHeight = 13
  object Label_Name: TLabel
    Left = 24
    Top = 24
    Width = 89
    Height = 13
    Caption = #1048#1084#1103' '#1082#1086#1084#1087#1100#1102#1090#1077#1088#1072':'
  end
  object Label_IPAddress: TLabel
    Left = 24
    Top = 51
    Width = 60
    Height = 13
    Caption = 'IPv4-'#1072#1076#1088#1077#1089':'
  end
  object Label_MACAddress: TLabel
    Left = 24
    Top = 78
    Width = 97
    Height = 13
    Caption = #1060#1080#1079#1080#1095#1077#1089#1082#1080#1081' '#1072#1076#1088#1077#1089':'
  end
  object Label_DHCP_Server: TLabel
    Left = 24
    Top = 105
    Width = 71
    Height = 13
    Caption = 'DHCP '#1057#1077#1088#1074#1077#1088':'
  end
  object Bevel1: TBevel
    Left = 0
    Top = 199
    Width = 409
    Height = 43
    Align = alBottom
    Shape = bsTopLine
    ExplicitTop = 143
    ExplicitWidth = 337
  end
  object Label_InvNumber: TLabel
    Left = 24
    Top = 159
    Width = 106
    Height = 13
    Caption = #1048#1085#1074#1077#1085#1090#1072#1088#1085#1099#1081' '#1085#1086#1084#1077#1088':'
  end
  object Label_OS: TLabel
    Left = 24
    Top = 132
    Width = 121
    Height = 13
    Caption = #1054#1087#1077#1088#1072#1094#1080#1086#1085#1085#1072#1103' '#1089#1080#1089#1090#1077#1084#1072':'
  end
  object Edit_Name: TEdit
    Left = 157
    Top = 21
    Width = 228
    Height = 21
    Anchors = [akLeft, akTop, akRight]
    AutoSelect = False
    Color = clBtnFace
    ReadOnly = True
    TabOrder = 3
  end
  object Edit_IPv4_Address: TEdit
    Left = 157
    Top = 48
    Width = 228
    Height = 21
    Anchors = [akLeft, akTop, akRight]
    AutoSelect = False
    Color = clBtnFace
    ReadOnly = True
    TabOrder = 4
  end
  object Edit_MAC_Address: TEdit
    Left = 157
    Top = 75
    Width = 228
    Height = 21
    Anchors = [akLeft, akTop, akRight]
    AutoSelect = False
    Color = clBtnFace
    ReadOnly = True
    TabOrder = 5
  end
  object Edit_DHCP_Server: TEdit
    Left = 157
    Top = 102
    Width = 228
    Height = 21
    Anchors = [akLeft, akTop, akRight]
    AutoSelect = False
    Color = clBtnFace
    ReadOnly = True
    TabOrder = 6
  end
  object Button_Close: TButton
    Left = 326
    Top = 209
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = #1047#1072#1082#1088#1099#1090#1100
    TabOrder = 0
    OnClick = Button_CloseClick
  end
  object Edit_InvNumber: TEdit
    Left = 157
    Top = 156
    Width = 228
    Height = 21
    Anchors = [akLeft, akTop, akRight]
    AutoSelect = False
    MaxLength = 16
    TabOrder = 8
  end
  object Button_Apply: TButton
    Left = 245
    Top = 209
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = #1055#1088#1080#1084#1077#1085#1080#1090#1100
    TabOrder = 1
    OnClick = Button_ApplyClick
  end
  object Button_OK: TButton
    Left = 164
    Top = 209
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = 'OK'
    TabOrder = 2
    OnClick = Button_OKClick
  end
  object Edit_OS: TEdit
    Left = 157
    Top = 129
    Width = 228
    Height = 21
    Anchors = [akLeft, akTop, akRight]
    AutoSelect = False
    Color = clBtnFace
    ReadOnly = True
    TabOrder = 7
  end
end
