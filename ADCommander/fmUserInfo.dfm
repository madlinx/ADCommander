object Form_UserInfo: TForm_UserInfo
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu]
  Caption = #1057#1074#1086#1081#1089#1090#1074#1072' '#1087#1086#1083#1100#1079#1086#1074#1072#1090#1077#1083#1103
  ClientHeight = 456
  ClientWidth = 634
  Color = clBtnFace
  Constraints.MinHeight = 495
  Constraints.MinWidth = 650
  DoubleBuffered = True
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  KeyPreview = True
  OldCreateOrder = False
  OnClose = FormClose
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnKeyDown = FormKeyDown
  DesignSize = (
    634
    456)
  PixelsPerInch = 96
  TextHeight = 13
  object Bevel_Top: TBevel
    Left = 0
    Top = 60
    Width = 634
    Height = 3
    Align = alTop
    Shape = bsTopLine
    ExplicitTop = 81
    ExplicitWidth = 573
  end
  object Panel_Title: TPanel
    Left = 0
    Top = 0
    Width = 634
    Height = 60
    Align = alTop
    BevelOuter = bvNone
    Color = clWindow
    Ctl3D = True
    ParentBackground = False
    ParentCtl3D = False
    TabOrder = 0
    DesignSize = (
      634
      60)
    object Label_Title_Title: TLabel
      Left = 16
      Top = 24
      Width = 411
      Height = 13
      Anchors = [akLeft, akTop, akRight]
      AutoSize = False
      Caption = 'Label_Title_Title'
      EllipsisPosition = epEndEllipsis
      Font.Charset = DEFAULT_CHARSET
      Font.Color = 3355443
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
      ExplicitWidth = 378
    end
    object Label_Title_DisplayName: TLabel
      Left = 16
      Top = 5
      Width = 411
      Height = 13
      Anchors = [akLeft, akTop, akRight]
      AutoSize = False
      Caption = 'Label_Title_DisplayName'
      EllipsisPosition = epEndEllipsis
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
      ExplicitWidth = 378
    end
    object Label_Title_Description: TLabel
      Left = 16
      Top = 39
      Width = 110
      Height = 13
      Caption = 'Label_Title_Description'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = 3355443
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
    end
  end
  object PageControl: TPageControl
    Left = 8
    Top = 71
    Width = 618
    Height = 346
    ActivePage = TabSheet_Events
    Anchors = [akLeft, akTop, akRight, akBottom]
    TabOrder = 1
    OnResize = PageControlResize
    object TabSheet_General: TTabSheet
      Caption = #1054#1073#1097#1080#1077
      ImageIndex = 1
      DesignSize = (
        610
        318)
      object Label_DisplayName: TLabel
        Left = 16
        Top = 73
        Width = 82
        Height = 13
        Caption = #1042#1099#1074#1086#1076#1080#1084#1086#1077' '#1080#1084#1103':'
      end
      object Label_LastName: TLabel
        Left = 16
        Top = 46
        Width = 48
        Height = 13
        Caption = #1060#1072#1084#1080#1083#1080#1103':'
      end
      object Label_FirstName: TLabel
        Left = 16
        Top = 19
        Width = 23
        Height = 13
        Caption = #1048#1084#1103':'
      end
      object Label_TelephoneNumber: TLabel
        Left = 16
        Top = 235
        Width = 88
        Height = 13
        Caption = #1053#1086#1084#1077#1088' '#1090#1077#1083#1077#1092#1086#1085#1072':'
      end
      object Label_OfficeName: TLabel
        Left = 16
        Top = 208
        Width = 47
        Height = 13
        Caption = #1050#1086#1084#1085#1072#1090#1072':'
      end
      object Label_Position: TLabel
        Left = 16
        Top = 181
        Width = 61
        Height = 13
        Caption = #1044#1086#1083#1078#1085#1086#1089#1090#1100':'
      end
      object Label_Department: TLabel
        Left = 16
        Top = 154
        Width = 37
        Height = 13
        Caption = #1054#1090#1076#1077#1083':'
      end
      object Label_EmployeeID: TLabel
        Left = 16
        Top = 127
        Width = 93
        Height = 13
        Caption = #1058#1072#1073#1077#1083#1100#1085#1099#1081' '#1085#1086#1084#1077#1088':'
      end
      object Label_Description: TLabel
        Left = 16
        Top = 100
        Width = 53
        Height = 13
        Caption = #1054#1087#1080#1089#1072#1085#1080#1077':'
      end
      object Label_Initials: TLabel
        Left = 360
        Top = 19
        Width = 55
        Height = 13
        Anchors = [akTop, akRight]
        Caption = #1048#1085#1080#1094#1080#1072#1083#1099':'
        ExplicitLeft = 299
      end
      object Image: TImage
        Left = 495
        Top = 16
        Width = 100
        Height = 100
        Anchors = [akTop, akRight]
        Center = True
        Proportional = True
        ExplicitLeft = 434
      end
      object Label_ObjectSID: TLabel
        Left = 16
        Top = 262
        Width = 56
        Height = 13
        Caption = 'Object SID:'
      end
      object Edit_DisplayName: TEdit
        Left = 139
        Top = 70
        Width = 339
        Height = 21
        Anchors = [akLeft, akTop, akRight]
        MaxLength = 256
        TabOrder = 3
      end
      object Edit_LastName: TEdit
        Left = 139
        Top = 43
        Width = 339
        Height = 21
        Anchors = [akLeft, akTop, akRight]
        MaxLength = 64
        TabOrder = 2
      end
      object Edit_Initials: TEdit
        Left = 421
        Top = 16
        Width = 57
        Height = 21
        Anchors = [akTop, akRight]
        MaxLength = 6
        TabOrder = 1
      end
      object Edit_FirstName: TEdit
        Left = 139
        Top = 16
        Width = 207
        Height = 21
        Anchors = [akLeft, akTop, akRight]
        MaxLength = 64
        TabOrder = 0
      end
      object Edit_TelephoneNumber: TEdit
        Left = 139
        Top = 232
        Width = 339
        Height = 21
        Anchors = [akLeft, akTop, akRight]
        MaxLength = 64
        TabOrder = 9
      end
      object Edit_OfficeName: TEdit
        Left = 139
        Top = 205
        Width = 339
        Height = 21
        Anchors = [akLeft, akTop, akRight]
        TabOrder = 8
      end
      object Edit_Title: TEdit
        Left = 139
        Top = 178
        Width = 339
        Height = 21
        Anchors = [akLeft, akTop, akRight]
        MaxLength = 64
        TabOrder = 7
      end
      object Edit_Department: TEdit
        Left = 139
        Top = 151
        Width = 339
        Height = 21
        Anchors = [akLeft, akTop, akRight]
        MaxLength = 64
        TabOrder = 6
      end
      object Edit_EmployeeID: TEdit
        Left = 139
        Top = 124
        Width = 339
        Height = 21
        Anchors = [akLeft, akTop, akRight]
        MaxLength = 16
        TabOrder = 5
      end
      object Edit_Description: TEdit
        Left = 139
        Top = 97
        Width = 339
        Height = 21
        Anchors = [akLeft, akTop, akRight]
        MaxLength = 1024
        TabOrder = 4
      end
      object Button_Image: TButton
        Left = 495
        Top = 122
        Width = 100
        Height = 25
        Anchors = [akTop, akRight]
        Caption = #1060#1086#1090#1086#1075#1088#1072#1092#1080#1103
        ImageAlignment = iaRight
        ImageIndex = 0
        ImageMargins.Top = 1
        Images = DM1.ImageList_16x16
        TabOrder = 11
        OnClick = Button_ImageClick
      end
      object Edit_ObjectSID: TEdit
        Left = 139
        Top = 259
        Width = 339
        Height = 21
        Anchors = [akLeft, akTop, akRight]
        Color = clBtnFace
        MaxLength = 64
        ReadOnly = True
        TabOrder = 10
      end
    end
    object TabSheet_Account: TTabSheet
      Caption = #1059#1095#1077#1090#1085#1072#1103' '#1079#1072#1087#1080#1089#1100
      ImageIndex = 2
      DesignSize = (
        610
        318)
      object Label_sAMAccountName: TLabel
        Left = 16
        Top = 40
        Width = 113
        Height = 26
        AutoSize = False
        Caption = #1048#1084#1103' '#1074#1093#1086#1076#1072': ('#1087#1088#1077#1076'-Windows 2000)'
        WordWrap = True
      end
      object Label_AccountName: TLabel
        Left = 16
        Top = 19
        Width = 57
        Height = 13
        Caption = #1048#1084#1103' '#1074#1093#1086#1076#1072':'
      end
      object Edit_sAMAccountName: TEdit
        Left = 339
        Top = 43
        Width = 194
        Height = 21
        MaxLength = 20
        TabOrder = 3
      end
      object Edit_DomainNetBIOSName: TEdit
        Left = 139
        Top = 43
        Width = 194
        Height = 21
        TabStop = False
        Color = clBtnFace
        ReadOnly = True
        TabOrder = 2
      end
      object Edit_DomainDNSName: TEdit
        Left = 339
        Top = 16
        Width = 194
        Height = 21
        TabStop = False
        Color = clBtnFace
        ReadOnly = True
        TabOrder = 1
      end
      object Edit_AccountName: TEdit
        Left = 139
        Top = 16
        Width = 194
        Height = 21
        MaxLength = 256
        TabOrder = 0
      end
      object CheckBox_DisableAccount: TCheckBox
        Left = 16
        Top = 170
        Width = 578
        Height = 17
        Anchors = [akLeft, akTop, akRight]
        Caption = #1059#1095#1077#1090#1085#1072#1103' '#1079#1072#1087#1080#1089#1100' '#1086#1090#1082#1083#1102#1095#1077#1085#1072
        TabOrder = 8
      end
      object CheckBox_PwdNotExpire: TCheckBox
        Left = 16
        Top = 147
        Width = 578
        Height = 17
        Anchors = [akLeft, akTop, akRight]
        Caption = #1057#1088#1086#1082' '#1076#1077#1081#1089#1090#1074#1080#1103' '#1087#1072#1088#1086#1083#1103' '#1085#1077' '#1086#1075#1088#1072#1085#1080#1095#1077#1085
        TabOrder = 7
        OnClick = CheckBox_PwdNotExpireClick
      end
      object CheckBox_PwdChangeOnLogon: TCheckBox
        Left = 16
        Top = 124
        Width = 578
        Height = 17
        Anchors = [akLeft, akTop, akRight]
        Caption = #1058#1088#1077#1073#1086#1074#1072#1090#1100' '#1089#1084#1077#1085#1099' '#1087#1072#1088#1086#1083#1103' '#1087#1088#1080' '#1089#1083#1077#1076#1091#1102#1097#1077#1084' '#1074#1093#1086#1076#1077' '#1074' '#1089#1080#1089#1090#1077#1084#1091
        TabOrder = 6
        OnClick = CheckBox_PwdChangeOnLogonClick
      end
      object Button_Workstations: TButton
        Left = 16
        Top = 83
        Width = 117
        Height = 25
        Caption = #1056#1072#1079#1088#1077#1096#1077#1085' '#1074#1093#1086#1076' '#1085#1072
        TabOrder = 4
        OnClick = Button_WorkstationsClick
      end
      object Edit_Workstations: TEdit
        Left = 139
        Top = 85
        Width = 455
        Height = 21
        TabStop = False
        Anchors = [akLeft, akTop, akRight]
        AutoSelect = False
        Color = clBtnFace
        ReadOnly = True
        TabOrder = 5
      end
      object Button_PwdChange: TButton
        Left = 16
        Top = 226
        Width = 117
        Height = 25
        Caption = #1057#1084#1077#1085#1072' '#1087#1072#1088#1086#1083#1103'...'
        TabOrder = 10
        OnClick = Button_PwdChangeClick
      end
      object CheckBox_UnlockAccount: TCheckBox
        Left = 16
        Top = 193
        Width = 578
        Height = 17
        Anchors = [akLeft, akTop, akRight]
        Caption = 
          #1056#1072#1079#1073#1083#1086#1082#1080#1088#1086#1074#1072#1090#1100' '#1091#1095#1077#1090#1085#1091#1102' '#1079#1072#1087#1080#1089#1100'. '#1059#1095#1077#1090#1085#1072#1103' '#1079#1072#1087#1080#1089#1100' '#1074' '#1076#1072#1085#1085#1099#1081' '#1084#1086#1084#1077#1085#1090' '#1079#1072 +
          #1073#1083#1086#1082#1080#1088#1086#1074#1072#1085#1072'.'
        TabOrder = 9
        WordWrap = True
      end
    end
    object TabSheet_MemberOf: TTabSheet
      Caption = #1063#1083#1077#1085' '#1075#1088#1091#1087#1087
      DesignSize = (
        610
        318)
      object Bevel_MemberOf: TBevel
        Left = 16
        Top = 245
        Width = 578
        Height = 3
        Anchors = [akLeft, akRight, akBottom]
        Shape = bsTopLine
        ExplicitTop = 221
        ExplicitWidth = 517
      end
      object Label_PrimaryGroup: TLabel
        Left = 16
        Top = 254
        Width = 137
        Height = 13
        Anchors = [akLeft, akBottom]
        Caption = #1058#1077#1082#1091#1097#1072#1103' '#1086#1089#1085#1086#1074#1085#1072#1103' '#1075#1088#1091#1087#1087#1072':'
        ExplicitTop = 230
      end
      object Label_PrimaryGroupName: TLabel
        Left = 165
        Top = 254
        Width = 429
        Height = 13
        Anchors = [akLeft, akRight, akBottom]
        AutoSize = False
        Caption = 'Label_PrimaryGroupName'
        EllipsisPosition = epEndEllipsis
        ExplicitTop = 230
        ExplicitWidth = 368
      end
      object Label_PrimaryGroupHint: TLabel
        Left = 16
        Top = 277
        Width = 578
        Height = 27
        Anchors = [akLeft, akRight, akBottom]
        AutoSize = False
        Caption = 
          #1053#1077#1090' '#1085#1077#1086#1073#1093#1086#1076#1080#1084#1086#1089#1090#1080' '#1080#1079#1084#1077#1085#1103#1090#1100' '#1086#1089#1085#1086#1074#1085#1091#1102' '#1075#1088#1091#1087#1087#1091', '#1077#1089#1083#1080' '#1090#1086#1083#1100#1082#1086' '#1085#1077' '#1080#1089#1087#1086#1083 +
          #1100#1079#1091#1102#1090#1089#1103' '#1082#1083#1080#1077#1085#1090#1099' Macintosh '#1080#1083#1080' POSIX-'#1089#1086#1074#1084#1077#1089#1090#1080#1084#1099#1077' '#1087#1088#1080#1083#1086#1078#1077#1085#1080#1103'.'
        WordWrap = True
        ExplicitTop = 253
        ExplicitWidth = 517
      end
      object ListView_Groups: TListView
        Left = 16
        Top = 16
        Width = 578
        Height = 184
        Anchors = [akLeft, akTop, akRight, akBottom]
        Columns = <
          item
            Caption = #1048#1084#1103' '#1075#1088#1091#1087#1087#1099
          end
          item
            Caption = #1054#1087#1080#1089#1072#1085#1080#1077' '#1075#1088#1091#1087#1087#1099
          end>
        ColumnClick = False
        HideSelection = False
        OwnerData = True
        OwnerDraw = True
        ReadOnly = True
        RowSelect = True
        ShowColumnHeaders = False
        TabOrder = 0
        ViewStyle = vsReport
        OnChange = ListView_GroupsChange
        OnData = ListView_GroupsData
        OnDrawItem = ListView_GroupsDrawItem
        OnResize = ListView_GroupsResize
      end
      object Button_AddToGroup: TButton
        Left = 16
        Top = 208
        Width = 90
        Height = 25
        Anchors = [akLeft, akBottom]
        Caption = #1048#1079#1084#1077#1085#1080#1090#1100'...'
        TabOrder = 1
        OnClick = Button_AddToGroupClick
      end
      object Button_RemoveFromGroup: TButton
        Left = 112
        Top = 208
        Width = 90
        Height = 25
        Anchors = [akLeft, akBottom]
        Caption = #1059#1076#1072#1083#1080#1090#1100
        Enabled = False
        TabOrder = 2
        OnClick = Button_RemoveFromGroupClick
      end
      object Button_SetGroupAsPrimary: TButton
        Left = 436
        Top = 208
        Width = 158
        Height = 25
        Anchors = [akRight, akBottom]
        Caption = #1047#1072#1076#1072#1090#1100' '#1086#1089#1085#1086#1074#1085#1091#1102' '#1075#1088#1091#1087#1087#1091
        TabOrder = 3
        OnClick = Button_SetGroupAsPrimaryClick
      end
    end
    object TabSheet_Profile: TTabSheet
      Caption = #1055#1088#1086#1092#1080#1083#1100
      ImageIndex = 3
      DesignSize = (
        610
        318)
      object Label_LogonScript: TLabel
        Left = 16
        Top = 19
        Width = 87
        Height = 13
        Caption = #1057#1094#1077#1085#1072#1088#1080#1081' '#1074#1093#1086#1076#1072':'
      end
      object Edit_LogonScript: TEdit
        Left = 139
        Top = 16
        Width = 455
        Height = 21
        Anchors = [akLeft, akTop, akRight]
        TabOrder = 0
      end
    end
    object TabSheet_Events: TTabSheet
      Caption = #1050#1086#1085#1090#1088#1086#1083#1100' '#1089#1086#1073#1099#1090#1080#1081
      ImageIndex = 5
      DesignSize = (
        610
        318)
      object Bevel_Events: TBevel
        Left = 16
        Top = 245
        Width = 578
        Height = 3
        Anchors = [akLeft, akRight, akBottom]
        Shape = bsTopLine
        ExplicitTop = 221
        ExplicitWidth = 517
      end
      object Label_EventsStorage: TLabel
        Left = 16
        Top = 254
        Width = 169
        Height = 13
        Anchors = [akLeft, akBottom]
        Caption = #1052#1077#1089#1090#1086' '#1093#1088#1072#1085#1077#1085#1080#1103' '#1089#1087#1080#1089#1082#1072' '#1089#1086#1073#1099#1090#1080#1081':'
        ExplicitTop = 230
      end
      object Label_EventsStorageName: TLabel
        Left = 197
        Top = 254
        Width = 397
        Height = 13
        Anchors = [akLeft, akRight, akBottom]
        AutoSize = False
        Caption = 'Label_EventsStorageName'
        EllipsisPosition = epPathEllipsis
        ExplicitTop = 230
        ExplicitWidth = 336
      end
      object Label_EventsStorageHint: TLabel
        Left = 16
        Top = 277
        Width = 578
        Height = 27
        Anchors = [akLeft, akRight, akBottom]
        AutoSize = False
        Caption = 
          #1048#1079#1084#1077#1085#1080#1090#1100' '#1084#1077#1089#1090#1086' '#1093#1088#1072#1085#1077#1085#1080#1103' '#1089#1087#1080#1089#1082#1086#1074' '#1089#1086#1073#1099#1090#1080#1081' '#1087#1086#1083#1100#1079#1086#1074#1072#1090#1077#1083#1077#1081' '#1084#1086#1078#1085#1086' '#1074' '#1085#1072 +
          #1089#1090#1088#1086#1081#1082#1072#1093' '#1087#1088#1086#1075#1088#1072#1084#1084#1099' '#1074' '#1088#1072#1079#1076#1077#1083#1077' "'#1050#1086#1085#1090#1088#1086#1083#1100' '#1089#1086#1073#1099#1090#1080#1081' '#1087#1086#1083#1100#1079#1086#1074#1072#1090#1077#1083#1103'"'
        WordWrap = True
        ExplicitTop = 253
        ExplicitWidth = 517
      end
      object ListView_Events: TListView
        Left = 16
        Top = 16
        Width = 578
        Height = 184
        Anchors = [akLeft, akTop, akRight, akBottom]
        Columns = <
          item
            Caption = #1044#1072#1090#1072
            Width = 75
          end
          item
            Caption = #1054#1087#1080#1089#1072#1085#1080#1077
            Width = 420
          end>
        ColumnClick = False
        HideSelection = False
        OwnerData = True
        OwnerDraw = True
        ReadOnly = True
        RowSelect = True
        ShowColumnHeaders = False
        TabOrder = 0
        ViewStyle = vsReport
        OnChange = ListView_EventsChange
        OnData = ListView_EventsData
        OnDrawItem = ListView_EventsDrawItem
        OnKeyDown = ListView_EventsKeyDown
        OnMouseDown = ListView_EventsMouseDown
        OnResize = ListView_EventsResize
      end
      object Button_EventDelete: TButton
        Left = 208
        Top = 208
        Width = 90
        Height = 25
        Anchors = [akLeft, akBottom]
        Caption = #1059#1076#1072#1083#1080#1090#1100'...'
        Enabled = False
        TabOrder = 3
        OnClick = Button_EventDeleteClick
      end
      object Button_EventAdd: TButton
        Left = 16
        Top = 208
        Width = 90
        Height = 25
        Anchors = [akLeft, akBottom]
        Caption = #1044#1086#1073#1072#1074#1080#1090#1100'...'
        TabOrder = 1
        OnClick = Button_EventAddClick
      end
      object Button_EventChange: TButton
        Left = 112
        Top = 208
        Width = 90
        Height = 25
        Anchors = [akLeft, akBottom]
        Caption = #1048#1079#1084#1077#1085#1080#1090#1100'...'
        Enabled = False
        TabOrder = 2
        OnClick = Button_EventChangeClick
      end
      object Button_EventsSave: TButton
        Left = 461
        Top = 208
        Width = 133
        Height = 25
        Anchors = [akRight, akBottom]
        Caption = #1057#1086#1093#1088#1072#1085#1080#1090#1100' '#1089#1086#1073#1099#1090#1080#1103
        TabOrder = 4
        OnClick = Button_EventsSaveClick
      end
    end
    object TabSheet_Advanced: TTabSheet
      Caption = #1044#1086#1087#1086#1083#1085#1080#1090#1077#1083#1100#1085#1086
      ImageIndex = 4
      object ListView_ScriptButtons: TListView
        AlignWithMargins = True
        Left = 11
        Top = 11
        Width = 588
        Height = 296
        Margins.Left = 11
        Margins.Top = 11
        Margins.Right = 11
        Margins.Bottom = 11
        Align = alClient
        BorderStyle = bsNone
        Columns = <
          item
            Width = 200
          end
          item
            Width = 24
          end>
        ColumnClick = False
        OwnerData = True
        OwnerDraw = True
        ReadOnly = True
        ShowColumnHeaders = False
        TabOrder = 0
        ViewStyle = vsReport
        OnChange = ListView_ScriptButtonsChange
        OnClick = ListView_ScriptButtonsClick
        OnCustomDraw = ListView_ScriptButtonsCustomDraw
        OnDblClick = ListView_ScriptButtonsDblClick
        OnDrawItem = ListView_ScriptButtonsDrawItem
        OnKeyDown = ListView_ScriptButtonsKeyDown
        OnResize = ListView_ScriptButtonsResize
      end
    end
  end
  object Button_Close: TButton
    Left = 551
    Top = 423
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = #1047#1072#1082#1088#1099#1090#1100
    TabOrder = 2
    OnClick = Button_CloseClick
  end
  object Button_Apply: TButton
    Left = 470
    Top = 423
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = #1055#1088#1080#1084#1077#1085#1080#1090#1100
    Enabled = False
    TabOrder = 3
    OnClick = Button_ApplyClick
  end
  object Button_OK: TButton
    Left = 389
    Top = 423
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = 'OK'
    Enabled = False
    TabOrder = 4
    OnClick = Button_OKClick
  end
  object PopupMenu_Image: TPopupMenu
    OnPopup = PopupMenu_ImagePopup
    Left = 8
    Top = 400
    object LoadImage: TMenuItem
      Caption = #1047#1072#1075#1088#1091#1079#1080#1090#1100'...'
      OnClick = LoadImageClick
    end
    object SaveImage: TMenuItem
      Caption = #1057#1086#1093#1088#1072#1085#1080#1090#1100' '#1082#1072#1082'...'
      OnClick = SaveImageClick
    end
    object MenuItem2: TMenuItem
      Caption = '-'
    end
    object DeleteImage: TMenuItem
      Caption = #1059#1076#1072#1083#1080#1090#1100
      OnClick = DeleteImageClick
    end
  end
end
