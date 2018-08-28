object Form_QuickMessage: TForm_QuickMessage
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu]
  BorderStyle = bsSingle
  Caption = #1041#1099#1089#1090#1088#1086#1077' '#1089#1086#1086#1073#1097#1077#1085#1080#1077
  ClientHeight = 489
  ClientWidth = 545
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnClose = FormClose
  OnCreate = FormCreate
  DesignSize = (
    545
    489)
  PixelsPerInch = 96
  TextHeight = 13
  object Label_Computer: TLabel
    Left = 16
    Top = 46
    Width = 89
    Height = 13
    Caption = #1048#1084#1103' '#1082#1086#1084#1087#1100#1102#1090#1077#1088#1072':'
  end
  object Label_Recipient: TLabel
    Left = 16
    Top = 19
    Width = 65
    Height = 13
    Caption = #1055#1086#1083#1091#1095#1072#1090#1077#1083#1100':'
  end
  object Label_MessageText: TLabel
    Left = 16
    Top = 80
    Width = 88
    Height = 13
    Caption = #1058#1077#1082#1089#1090' '#1089#1086#1086#1073#1097#1077#1085#1080#1103
  end
  object Label_SymbolCount: TLabel
    Left = 110
    Top = 80
    Width = 36
    Height = 13
    Caption = '(0/250)'
  end
  object Label_Output: TLabel
    Left = 16
    Top = 220
    Width = 95
    Height = 13
    Caption = #1046#1091#1088#1085#1072#1083' '#1086#1090#1087#1088#1072#1074#1082#1080':'
  end
  object Memo_ProcessOutput: TMemo
    Left = 16
    Top = 239
    Width = 513
    Height = 202
    Color = clBlack
    Font.Charset = DEFAULT_CHARSET
    Font.Color = 13882323
    Font.Height = -11
    Font.Name = 'Consolas'
    Font.Style = []
    ParentFont = False
    ReadOnly = True
    ScrollBars = ssVertical
    TabOrder = 4
  end
  object ComboBox_Computer: TComboBox
    Left = 120
    Top = 43
    Width = 378
    Height = 21
    Anchors = [akLeft, akTop, akRight]
    Sorted = True
    TabOrder = 1
  end
  object Button_Send: TButton
    Left = 372
    Top = 453
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = #1054#1090#1087#1088#1072#1074#1080#1090#1100
    TabOrder = 5
    OnClick = Button_SendClick
  end
  object Button_Cancel: TButton
    Left = 453
    Top = 453
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = #1047#1072#1082#1088#1099#1090#1100
    TabOrder = 6
    OnClick = Button_CancelClick
  end
  object Edit_Recipient: TEdit
    Left = 120
    Top = 16
    Width = 409
    Height = 21
    Anchors = [akLeft, akTop, akRight]
    AutoSelect = False
    Color = clBtnFace
    ReadOnly = True
    TabOrder = 0
  end
  object Button_GetIP: TButton
    Left = 504
    Top = 41
    Width = 25
    Height = 25
    Anchors = [akTop, akRight]
    ImageIndex = 2
    ImageMargins.Left = 2
    ImageMargins.Top = 1
    Images = DM1.ImageList_16x16
    TabOrder = 2
    OnClick = Button_GetIPClick
  end
  object Memo_MessageText: TMemo
    Left = 16
    Top = 99
    Width = 512
    Height = 110
    Anchors = [akLeft, akTop, akRight]
    MaxLength = 250
    ScrollBars = ssVertical
    TabOrder = 3
    OnChange = Memo_MessageTextChange
  end
end
