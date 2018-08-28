object Form_Workstations: TForm_Workstations
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu]
  BorderStyle = bsSingle
  Caption = #1056#1072#1073#1086#1095#1080#1077' '#1089#1090#1072#1085#1094#1080#1080' '#1076#1083#1103' '#1074#1093#1086#1076#1072' '#1074' '#1089#1080#1089#1090#1077#1084#1091
  ClientHeight = 376
  ClientWidth = 377
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnClose = FormClose
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  DesignSize = (
    377
    376)
  PixelsPerInch = 96
  TextHeight = 13
  object Label_Hint: TLabel
    Left = 16
    Top = 16
    Width = 338
    Height = 26
    Caption = 
      #1042' '#1087#1086#1083#1077' "'#1048#1084#1103' '#1082#1086#1084#1087#1100#1102#1090#1077#1088#1072'" '#1074#1074#1077#1076#1080#1090#1077' NetBIOS-'#1080#1084#1103' '#1080#1083#1080' '#1076#1086#1084#1077#1085#1085#1086#1077' '#1080#1084#1103' (DN' +
      'S-'#1080#1084#1103') '#1082#1086#1084#1087#1100#1102#1090#1077#1088#1072'. '
    WordWrap = True
  end
  object Label_Choice: TLabel
    Left = 16
    Top = 58
    Width = 225
    Height = 13
    Caption = #1069#1090#1086#1090' '#1087#1086#1083#1100#1079#1086#1074#1072#1090#1077#1083#1100' '#1084#1086#1078#1077#1090' '#1074#1099#1087#1086#1083#1085#1103#1090#1100' '#1074#1093#1086#1076':'
  end
  object GroupBox_Workstation: TGroupBox
    Left = 16
    Top = 105
    Width = 345
    Height = 229
    Caption = 
      '                                                                ' +
      '    '
    TabOrder = 0
    object Label_ComputerName: TLabel
      Left = 12
      Top = 21
      Width = 89
      Height = 13
      Caption = #1048#1084#1103' '#1082#1086#1084#1087#1100#1102#1090#1077#1088#1072':'
    end
    object Edit_Workstation: TEdit
      Left = 12
      Top = 40
      Width = 236
      Height = 21
      TabOrder = 0
      OnChange = Edit_WorkstationChange
      OnKeyPress = Edit_WorkstationKeyPress
    end
    object Button_Add: TButton
      Left = 258
      Top = 38
      Width = 75
      Height = 25
      Caption = #1044#1086#1073#1072#1074#1080#1090#1100
      Enabled = False
      TabOrder = 1
      OnClick = Button_AddClick
    end
    object Button_Change: TButton
      Left = 258
      Top = 69
      Width = 75
      Height = 25
      Caption = #1048#1079#1084#1077#1085#1080#1090#1100
      Enabled = False
      TabOrder = 3
      OnClick = Button_ChangeClick
    end
    object ListBox_Workstations: TListBox
      Left = 12
      Top = 69
      Width = 236
      Height = 147
      Style = lbOwnerDrawFixed
      DoubleBuffered = True
      ItemHeight = 18
      ParentDoubleBuffered = False
      TabOrder = 2
      OnClick = ListBox_WorkstationsClick
    end
    object Button_Delete: TButton
      Left = 258
      Top = 100
      Width = 75
      Height = 25
      Caption = #1059#1076#1072#1083#1080#1090#1100
      Enabled = False
      TabOrder = 4
      OnClick = Button_DeleteClick
    end
  end
  object RadioButton_All: TRadioButton
    Left = 28
    Top = 80
    Width = 197
    Height = 17
    Caption = #1085#1072' '#1074#1089#1077' '#1082#1086#1084#1087#1100#1102#1090#1077#1088#1099
    TabOrder = 1
    OnClick = RadioButton_AllClick
  end
  object RadioButton_Listed: TRadioButton
    Left = 28
    Top = 103
    Width = 197
    Height = 17
    Caption = #1090#1086#1083#1100#1082#1086' '#1085#1072' '#1091#1082#1072#1079#1072#1085#1085#1099#1077' '#1082#1086#1084#1087#1100#1102#1090#1077#1088#1099
    TabOrder = 2
    OnClick = RadioButton_ListedClick
  end
  object Button_Cancel: TButton
    Left = 294
    Top = 343
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = #1054#1090#1084#1077#1085#1072
    TabOrder = 3
    OnClick = Button_CancelClick
  end
  object Button_OK: TButton
    Left = 213
    Top = 343
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = 'OK'
    TabOrder = 4
    OnClick = Button_OKClick
  end
end
