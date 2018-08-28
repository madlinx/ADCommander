object Form_ScriptButton: TForm_ScriptButton
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu]
  Caption = #1057#1082#1088#1080#1087#1090
  ClientHeight = 341
  ClientWidth = 497
  Color = clBtnFace
  Constraints.MinHeight = 380
  Constraints.MinWidth = 513
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnClose = FormClose
  OnCreate = FormCreate
  DesignSize = (
    497
    341)
  PixelsPerInch = 96
  TextHeight = 13
  object Label_Title: TLabel
    Left = 24
    Top = 27
    Width = 52
    Height = 13
    Caption = #1053#1072#1079#1074#1072#1085#1080#1077':'
  end
  object Label1: TLabel
    Left = 24
    Top = 54
    Width = 53
    Height = 13
    Caption = #1054#1087#1080#1089#1072#1085#1080#1077':'
  end
  object Label2: TLabel
    Left = 24
    Top = 81
    Width = 58
    Height = 13
    Caption = #1048#1084#1103' '#1092#1072#1081#1083#1072':'
  end
  object Label_Parameters: TLabel
    Left = 24
    Top = 108
    Width = 61
    Height = 13
    Caption = #1055#1072#1088#1072#1084#1077#1090#1088#1099':'
  end
  object Label_dn: TLabel
    Left = 105
    Top = 170
    Width = 16
    Height = 13
    Caption = '-dn'
  end
  object Label_h: TLabel
    Left = 106
    Top = 132
    Width = 16
    Height = 13
    Caption = '-hn'
  end
  object Label_a: TLabel
    Left = 106
    Top = 151
    Width = 16
    Height = 13
    Caption = '-an'
  end
  object Label_h_Hint: TLabel
    Left = 130
    Top = 132
    Width = 144
    Height = 13
    Caption = #8212'  '#1048#1084#1103' '#1082#1086#1085#1090#1088#1086#1083#1083#1077#1088#1072' '#1076#1086#1084#1077#1085#1072
  end
  object Label_a_Hint: TLabel
    Left = 130
    Top = 151
    Width = 198
    Height = 13
    Caption = #8212'  '#1047#1085#1072#1095#1077#1085#1080#1077' '#1072#1090#1088#1080#1073#1090#1072' sAMAccountName'
  end
  object Label3: TLabel
    Left = 130
    Top = 170
    Width = 201
    Height = 13
    Caption = #8212'  '#1047#1085#1072#1095#1077#1085#1080#1077' '#1072#1090#1088#1080#1073#1090#1072' distinguishedName'
  end
  object Bevel1: TBevel
    Left = 0
    Top = 298
    Width = 497
    Height = 43
    Align = alBottom
    Shape = bsTopLine
    ExplicitTop = 225
    ExplicitWidth = 457
  end
  object Edit_Title: TEdit
    Left = 104
    Top = 24
    Width = 369
    Height = 21
    Anchors = [akLeft, akTop, akRight]
    TabOrder = 0
    ExplicitWidth = 321
  end
  object Edit_Description: TEdit
    Left = 104
    Top = 51
    Width = 369
    Height = 21
    Anchors = [akLeft, akTop, akRight]
    TabOrder = 1
    ExplicitWidth = 321
  end
  object Edit_Path: TEdit
    Left = 104
    Top = 78
    Width = 338
    Height = 21
    Anchors = [akLeft, akTop, akRight]
    TabOrder = 2
  end
  object Button_Cancel: TButton
    Left = 414
    Top = 308
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = #1054#1090#1084#1077#1085#1072
    TabOrder = 5
    OnClick = Button_CancelClick
    ExplicitLeft = 366
    ExplicitTop = 227
  end
  object Button_OK: TButton
    Left = 333
    Top = 308
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = 'OK'
    TabOrder = 6
    OnClick = Button_OKClick
    ExplicitLeft = 285
    ExplicitTop = 227
  end
  object Edit_Parameters: TEdit
    Left = 104
    Top = 105
    Width = 369
    Height = 21
    Anchors = [akLeft, akTop, akRight]
    TabOrder = 4
    ExplicitWidth = 321
  end
  object Button_Browse: TButton
    Left = 448
    Top = 76
    Width = 25
    Height = 25
    Anchors = [akTop, akRight]
    Caption = '...'
    TabOrder = 3
    OnClick = Button_BrowseClick
  end
end
