object Form_Settings: TForm_Settings
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu]
  Caption = #1055#1072#1088#1072#1084#1077#1090#1088#1099
  ClientHeight = 543
  ClientWidth = 754
  Color = clBtnFace
  Constraints.MinHeight = 582
  Constraints.MinWidth = 770
  DoubleBuffered = True
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poMainFormCenter
  OnClose = FormClose
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnKeyDown = FormKeyDown
  OnResize = FormResize
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object Panel_Bottom: TPanel
    Left = 0
    Top = 503
    Width = 754
    Height = 40
    Align = alBottom
    BevelOuter = bvNone
    Caption = 'Panel_Bottom'
    Ctl3D = True
    ParentBackground = False
    ParentCtl3D = False
    ShowCaption = False
    TabOrder = 0
    DesignSize = (
      754
      40)
    object Button_Cancel: TButton
      Left = 673
      Top = 8
      Width = 75
      Height = 25
      Anchors = [akTop, akRight]
      Caption = #1054#1090#1084#1077#1085#1072
      TabOrder = 0
      OnClick = Button_CancelClick
    end
    object Button_Apply: TButton
      Left = 592
      Top = 8
      Width = 75
      Height = 25
      Anchors = [akTop, akRight]
      Caption = #1055#1088#1080#1084#1077#1085#1080#1090#1100
      TabOrder = 1
      OnClick = Button_ApplyClick
    end
    object Button_OK: TButton
      Left = 511
      Top = 8
      Width = 75
      Height = 25
      Anchors = [akTop, akRight]
      Caption = 'OK'
      TabOrder = 2
      OnClick = Button_OKClick
    end
  end
  object Panel_Left: TPanel
    AlignWithMargins = True
    Left = 6
    Top = 6
    Width = 200
    Height = 497
    Margins.Left = 6
    Margins.Top = 6
    Margins.Bottom = 0
    Align = alLeft
    BevelKind = bkFlat
    BevelOuter = bvNone
    Caption = 'Panel_Left'
    Color = clWindow
    Ctl3D = True
    ParentBackground = False
    ParentCtl3D = False
    ShowCaption = False
    TabOrder = 1
    object LeftMenu: TStringGrid
      Left = 0
      Top = 0
      Width = 196
      Height = 493
      Align = alClient
      BorderStyle = bsNone
      ColCount = 1
      DefaultColWidth = 195
      DefaultRowHeight = 32
      DefaultDrawing = False
      FixedCols = 0
      FixedRows = 0
      Options = [goFixedVertLine, goFixedHorzLine]
      TabOrder = 0
      OnDrawCell = LeftMenuDrawCell
      OnKeyDown = LeftMenuKeyDown
      OnMouseWheelDown = LeftMenuMouseWheelDown
      OnMouseWheelUp = LeftMenuMouseWheelUp
      OnSelectCell = LeftMenuSelectCell
      ColWidths = (
        195)
      RowHeights = (
        32
        32
        32
        32
        32)
    end
  end
  object Panel_Client: TPanel
    AlignWithMargins = True
    Left = 212
    Top = 6
    Width = 536
    Height = 497
    Margins.Top = 6
    Margins.Right = 6
    Margins.Bottom = 0
    Align = alClient
    BevelKind = bkFlat
    BevelOuter = bvNone
    Caption = 'Panel_Client'
    Color = clWhite
    Ctl3D = True
    ParentBackground = False
    ParentCtl3D = False
    ShowCaption = False
    TabOrder = 2
    object PageControl_Settings: TPageControl
      Left = 0
      Top = 0
      Width = 532
      Height = 493
      ActivePage = TabSheet_FloatingWindow
      Align = alClient
      Style = tsButtons
      TabOrder = 0
      TabStop = False
      object TabSheet_General: TTabSheet
        Caption = 'TabSheet_General'
        TabVisible = False
        DesignSize = (
          524
          483)
        object Label_API: TLabel
          Left = 11
          Top = 248
          Width = 97
          Height = 13
          Caption = #1048#1089#1087#1086#1083#1100#1079#1091#1077#1084#1099#1081' API:'
        end
        object CheckBox_MinimizeToTray: TCheckBox
          Left = 11
          Top = 84
          Width = 502
          Height = 17
          Anchors = [akLeft, akTop, akRight]
          Caption = #1057#1074#1086#1088#1072#1095#1080#1074#1072#1090#1100' '#1086#1082#1085#1086' '#1087#1088#1086#1075#1088#1072#1084#1084#1099' '#1074' '#1089#1080#1089#1090#1077#1084#1085#1099#1081' '#1090#1088#1077#1081
          TabOrder = 2
        end
        object CheckBox_MinimizeAtClose: TCheckBox
          Left = 11
          Top = 107
          Width = 502
          Height = 17
          Anchors = [akLeft, akTop, akRight]
          Caption = #1057#1074#1086#1088#1072#1095#1080#1074#1072#1090#1100' '#1086#1082#1085#1086' '#1087#1088#1080' '#1079#1072#1082#1088#1099#1090#1080#1080' '#1087#1088#1086#1075#1088#1072#1084#1084#1099
          TabOrder = 3
        end
        object Panel_Instances: TPanel
          Left = 11
          Top = 130
          Width = 502
          Height = 63
          Anchors = [akLeft, akTop, akRight]
          BevelOuter = bvNone
          Ctl3D = False
          ParentBackground = False
          ParentColor = True
          ParentCtl3D = False
          TabOrder = 4
          DesignSize = (
            502
            63)
          object RadioButton_Instance: TRadioButton
            Left = 15
            Top = 23
            Width = 487
            Height = 17
            Anchors = [akLeft, akTop, akRight]
            Caption = #1047#1072#1087#1091#1089#1090#1080#1090#1100' '#1077#1097#1077' '#1086#1076#1085#1091' '#1082#1086#1087#1080#1102' '#1087#1088#1086#1075#1088#1072#1084#1084#1099
            Enabled = False
            TabOrder = 1
          end
          object RadioButton_AskForAction: TRadioButton
            Left = 15
            Top = 46
            Width = 487
            Height = 17
            Anchors = [akLeft, akTop, akRight]
            Caption = #1047#1072#1087#1088#1086#1089#1080#1090#1100' '#1076#1077#1081#1089#1090#1074#1080#1077' '#1091' '#1087#1086#1083#1100#1079#1086#1074#1072#1090#1077#1083#1103
            Enabled = False
            TabOrder = 2
          end
          object CheckBox_AppInstances: TCheckBox
            Left = 0
            Top = 0
            Width = 502
            Height = 17
            Anchors = [akLeft, akTop, akRight]
            Caption = #1056#1072#1079#1088#1077#1096#1080#1090#1100' '#1079#1072#1087#1091#1089#1082' '#1085#1077#1089#1082#1086#1083#1100#1082#1080#1093' '#1082#1086#1087#1080#1081' '#1087#1088#1086#1075#1088#1072#1084#1084#1099
            TabOrder = 0
            OnClick = CheckBox_AppInstancesClick
          end
        end
        object Panel_Caption1: TPanel
          Left = 3
          Top = 3
          Width = 518
          Height = 24
          Alignment = taLeftJustify
          Anchors = [akLeft, akTop, akRight]
          BevelOuter = bvNone
          Caption = 'Panel_Caption1'
          ParentBackground = False
          ShowCaption = False
          TabOrder = 6
          object Label1: TLabel
            Left = 8
            Top = 5
            Width = 108
            Height = 13
            Caption = #1054#1073#1097#1080#1077' '#1087#1072#1088#1072#1084#1077#1090#1088#1099
            Font.Charset = DEFAULT_CHARSET
            Font.Color = 3355443
            Font.Height = -11
            Font.Name = 'Tahoma'
            Font.Style = [fsBold]
            ParentFont = False
          end
        end
        object Panel12: TPanel
          Left = 3
          Top = 209
          Width = 518
          Height = 24
          Alignment = taLeftJustify
          Anchors = [akLeft, akTop, akRight]
          BevelOuter = bvNone
          Caption = 'Panel_Caption1'
          ParentBackground = False
          ShowCaption = False
          TabOrder = 7
          object Label15: TLabel
            Left = 8
            Top = 5
            Width = 206
            Height = 13
            Caption = #1057#1083#1091#1078#1073#1072' '#1082#1072#1090#1072#1083#1086#1075#1086#1074' Active Directory'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = 3355443
            Font.Height = -11
            Font.Name = 'Tahoma'
            Font.Style = [fsBold]
            ParentFont = False
          end
        end
        object ComboBox_API: TComboBox
          Left = 119
          Top = 244
          Width = 302
          Height = 22
          Style = csOwnerDrawFixed
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentFont = False
          TabOrder = 5
          OnDrawItem = ComboBox_APIDrawItem
          Items.Strings = (
            'LDAP | Lightweight Directory Access Protocol'
            'ADSI | Active Directory Service Interfaces')
        end
        object CheckBox_Autorun: TCheckBox
          Left = 11
          Top = 38
          Width = 502
          Height = 17
          Anchors = [akLeft, akTop, akRight]
          Caption = #1047#1072#1087#1091#1089#1082#1072#1090#1100' '#1072#1074#1090#1086#1084#1072#1090#1080#1095#1077#1089#1082#1080' '#1087#1088#1080' '#1074#1093#1086#1076#1077' '#1074' '#1089#1080#1089#1090#1077#1084#1091
          TabOrder = 0
          OnClick = CheckBox_AutorunClick
        end
        object CheckBox_MinimizeAtAutorun: TCheckBox
          Left = 26
          Top = 61
          Width = 487
          Height = 17
          Anchors = [akLeft, akTop, akRight]
          Caption = #1057#1074#1077#1088#1085#1091#1090#1100' '#1087#1088#1080' '#1079#1072#1087#1091#1089#1082#1077
          TabOrder = 1
        end
      end
      object TabSheet_Attributes: TTabSheet
        Caption = 'TabSheet_Attributes'
        ImageIndex = 1
        TabVisible = False
        OnShow = TabSheet_AttributesShow
        DesignSize = (
          524
          483)
        object Label_AttrCat_Hint1: TLabel
          Left = 11
          Top = 38
          Width = 381
          Height = 26
          Anchors = [akLeft, akTop, akRight]
          AutoSize = False
          Caption = 
            #1059#1082#1072#1078#1080#1090#1077' '#1080#1084#1077#1085#1072' '#1087#1086#1083#1077#1081' '#1080' '#1089#1086#1086#1090#1074#1077#1090#1089#1090#1074#1091#1102#1097#1080#1077' '#1080#1084' '#1072#1090#1088#1080#1073#1091#1090#1099' Active Directo' +
            'ry, '#1072' '#1090#1072#1082' '#1078#1077' '#1087#1072#1088#1072#1084#1077#1090#1088#1099' '#1086#1090#1086#1073#1088#1072#1078#1077#1085#1080#1103' '#1080#1093' '#1079#1085#1072#1095#1077#1085#1080#1081' '#1074' '#1090#1072#1073#1083#1080#1094#1077
          Layout = tlCenter
          WordWrap = True
          ExplicitWidth = 371
        end
        object Label_AttrCat_Hint2: TLabel
          Left = 11
          Top = 385
          Width = 502
          Height = 52
          Anchors = [akLeft, akRight, akBottom]
          AutoSize = False
          Caption = 
            #1059#1082#1072#1078#1080#1090#1077' '#1087#1086#1083#1077' '#1089#1086#1076#1077#1088#1078#1072#1097#1077#1077' '#1080#1084#1103' '#1082#1086#1084#1087#1100#1102#1090#1077#1088#1072', '#1085#1072' '#1082#1086#1090#1086#1088#1099#1081' '#1087#1086#1083#1100#1079#1086#1074#1072#1090#1077#1083#1100' ' +
            #1086#1089#1091#1097#1077#1089#1090#1074#1080#1083' '#1074#1093#1086#1076' '#1074' '#1087#1086#1089#1083#1077#1076#1085#1080#1081' '#1088#1072#1079'. '#1069#1090#1086' '#1087#1086#1079#1074#1086#1083#1080#1090' '#1087#1086' '#1080#1084#1077#1085#1080' '#1087#1086#1083#1100#1079#1086#1074#1072#1090 +
            #1077#1083#1103' '#1087#1086#1076#1082#1083#1102#1095#1072#1090#1100#1089#1103' '#1082' '#1082#1086#1084#1087#1100#1102#1090#1077#1088#1091' '#1080' '#1086#1089#1091#1097#1077#1089#1090#1074#1083#1103#1090#1100' '#1077#1075#1086' ping. '#1058#1072#1082#1086#1081' '#1072#1090#1088 +
            #1080#1073#1091#1090' '#1086#1090#1089#1091#1090#1089#1090#1074#1091#1077#1090' '#1074' '#1089#1090#1072#1085#1076#1072#1088#1090#1085#1086#1081' '#1089#1093#1077#1084#1077' Active Direcory, '#1086#1085', '#1082#1072#1082' '#1080' ' +
            #1089#1082#1088#1080#1087#1090' '#1079#1072#1087#1080#1089#1080' '#1080#1084#1077#1085#1080' '#1082#1086#1084#1087#1100#1102#1090#1077#1088#1072' '#1074' '#1085#1077#1075#1086', '#1089#1086#1079#1076#1072#1077#1090#1089#1103' '#1080' '#1085#1072#1089#1090#1088#1072#1080#1074#1072#1077#1090#1089#1103 +
            ' '#1072#1076#1084#1080#1085#1080#1089#1090#1088#1072#1090#1086#1088#1086#1084'.'
          WordWrap = True
          ExplicitTop = 376
          ExplicitWidth = 492
        end
        object ListView_AttrCatalog: TListView
          AlignWithMargins = True
          Left = 11
          Top = 71
          Width = 502
          Height = 260
          Margins.Left = 11
          Margins.Right = 11
          Margins.Bottom = 11
          Anchors = [akLeft, akTop, akRight, akBottom]
          BevelInner = bvLowered
          BevelOuter = bvNone
          BevelKind = bkFlat
          BorderStyle = bsNone
          Columns = <
            item
              MaxWidth = 33
              MinWidth = 33
              Width = 33
            end
            item
              Caption = #1048#1084#1103' '#1087#1086#1083#1103
              MinWidth = 150
              Width = 150
            end
            item
              Caption = #1040#1090#1088#1080#1073#1091#1090' AD'
              MinWidth = 150
              Width = 150
            end
            item
              Alignment = taCenter
              Caption = #1064#1080#1088#1080#1085#1072
              MinWidth = 55
              Width = 55
            end
            item
              Alignment = taCenter
              Caption = #1042#1099#1088#1072#1074#1085#1080#1074#1072#1085#1080#1077
              MaxWidth = 50
              MinWidth = 50
            end>
          ColumnClick = False
          OwnerDraw = True
          ReadOnly = True
          RowSelect = True
          TabOrder = 0
          ViewStyle = vsReport
          OnDeletion = ListView_AttrCatalogDeletion
          OnDrawItem = ListView_AttrCatalogDrawItem
          OnResize = ListView_AttrCatalogResize
        end
        object Button_AttrCatReset: TButton
          Left = 423
          Top = 39
          Width = 90
          Height = 25
          Anchors = [akTop, akRight]
          Caption = #1055#1086' '#1091#1084#1086#1083#1095#1072#1085#1080#1102
          TabOrder = 2
          OnClick = Button_AttrCatResetClick
        end
        object Panel2: TPanel
          Left = 3
          Top = 3
          Width = 518
          Height = 24
          Alignment = taLeftJustify
          Anchors = [akLeft, akTop, akRight]
          BevelOuter = bvNone
          Caption = 'Panel_Caption1'
          ParentBackground = False
          ShowCaption = False
          TabOrder = 3
          object Label2: TLabel
            Left = 8
            Top = 5
            Width = 208
            Height = 13
            Caption = #1050#1072#1090#1072#1083#1086#1075' '#1072#1090#1088#1080#1073#1091#1090#1086#1074' Active Directory'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = 3355443
            Font.Height = -11
            Font.Name = 'Tahoma'
            Font.Style = [fsBold]
            ParentFont = False
          end
        end
        object Panel17: TPanel
          Left = 3
          Top = 350
          Width = 518
          Height = 24
          Alignment = taLeftJustify
          Anchors = [akLeft, akRight, akBottom]
          BevelOuter = bvNone
          Caption = 'Panel_Caption1'
          ParentBackground = False
          ShowCaption = False
          TabOrder = 4
          object Label17: TLabel
            Left = 8
            Top = 5
            Width = 93
            Height = 13
            Caption = #1044#1086#1087#1086#1083#1085#1080#1090#1077#1083#1100#1085#1086
            Font.Charset = DEFAULT_CHARSET
            Font.Color = 3355443
            Font.Height = -11
            Font.Name = 'Tahoma'
            Font.Style = [fsBold]
            ParentFont = False
          end
        end
        object ComboBox_AttrCat_UserLogonPC: TComboBox
          Left = 11
          Top = 448
          Width = 502
          Height = 22
          Style = csOwnerDrawFixed
          Anchors = [akLeft, akRight, akBottom]
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentFont = False
          TabOrder = 1
          OnDrawItem = ComboBox_AttrCat_UserLogonPCDrawItem
        end
      end
      object TabSheet_Events: TTabSheet
        Caption = 'TabSheet_Events'
        ImageIndex = 2
        TabVisible = False
        DesignSize = (
          524
          483)
        object Label71: TLabel
          Tag = 1
          Left = 11
          Top = 51
          Width = 502
          Height = 27
          Anchors = [akLeft, akTop, akRight]
          AutoSize = False
          Caption = 
            #1045#1089#1083#1080' '#1091#1082#1072#1079#1072#1085' '#1085#1077#1089#1091#1097#1077#1089#1090#1074#1091#1102#1097#1080#1081' '#1085#1072' '#1076#1080#1089#1082#1077' '#1082#1072#1090#1072#1083#1086#1075', '#1080#1083#1080' '#1085#1077#1089#1091#1097#1077#1089#1090#1074#1091#1102#1097#1080#1081' ' +
            #1072#1090#1088#1080#1073#1091#1090' Active Directory, '#1090#1086' '#1092#1091#1085#1082#1094#1080#1086#1085#1072#1083' '#1082#1086#1085#1090#1088#1086#1083#1103' '#1089#1086#1073#1099#1090#1080#1081' '#1087#1086#1083#1100#1079#1086#1074 +
            #1072#1090#1077#1083#1077#1081' '#1073#1091#1076#1077#1090' '#1085#1077#1076#1086#1089#1090#1091#1087#1077#1085'.'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = []
          ParentFont = False
          Transparent = True
          WordWrap = True
        end
        object Label72: TLabel
          Tag = 1
          Left = 11
          Top = 38
          Width = 502
          Height = 14
          Anchors = [akLeft, akTop, akRight]
          AutoSize = False
          Caption = #1057#1087#1080#1089#1082#1080' '#1089#1086#1073#1099#1090#1080#1081' '#1087#1086#1083#1100#1079#1086#1074#1072#1090#1077#1083#1077#1081' '#1093#1088#1072#1085#1103#1090#1089#1103' '#1074' '#1092#1072#1081#1083#1072#1093' '#1092#1086#1088#1084#1072#1090#1072' *.xml'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = []
          ParentFont = False
          Transparent = True
          WordWrap = True
        end
        object Panel1: TPanel
          Left = 3
          Top = 3
          Width = 518
          Height = 24
          Alignment = taLeftJustify
          Anchors = [akLeft, akTop, akRight]
          BevelOuter = bvNone
          Caption = 'Panel_Caption1'
          ParentBackground = False
          ShowCaption = False
          TabOrder = 3
          object Label4: TLabel
            Left = 8
            Top = 5
            Width = 196
            Height = 13
            Caption = #1052#1077#1089#1090#1086' '#1093#1088#1072#1085#1077#1085#1080#1103' '#1089#1087#1080#1089#1082#1086#1074' '#1089#1086#1073#1099#1090#1080#1081
            Font.Charset = DEFAULT_CHARSET
            Font.Color = 3355443
            Font.Height = -11
            Font.Name = 'Tahoma'
            Font.Style = [fsBold]
            ParentFont = False
          end
        end
        object Button_BrowseStorage: TButton
          Left = 438
          Top = 130
          Width = 75
          Height = 25
          Anchors = [akTop, akRight]
          Caption = #1054#1073#1079#1086#1088'...'
          TabOrder = 2
          OnClick = Button_BrowseStorageClick
        end
        object Edit_Storage: TEdit
          Left = 26
          Top = 132
          Width = 406
          Height = 21
          Anchors = [akLeft, akTop, akRight]
          TabOrder = 1
        end
        object Panel11: TPanel
          Left = 11
          Top = 89
          Width = 490
          Height = 37
          Anchors = [akLeft, akTop, akRight]
          BevelOuter = bvNone
          Ctl3D = True
          ParentCtl3D = False
          TabOrder = 0
          DesignSize = (
            490
            37)
          object RadioButton_StorageDisk: TRadioButton
            Left = 0
            Top = 0
            Width = 490
            Height = 17
            Anchors = [akLeft, akTop, akRight]
            Caption = #1050#1072#1090#1072#1083#1086#1075' '#1085#1072' '#1083#1086#1082#1072#1083#1100#1085#1086#1084' '#1080#1083#1080' '#1089#1077#1090#1077#1074#1086#1084' '#1076#1080#1089#1082#1077
            TabOrder = 0
            OnClick = RadioButton_StorageDiskClick
          end
          object RadioButton_StorageAD: TRadioButton
            Left = 0
            Top = 20
            Width = 490
            Height = 17
            Anchors = [akLeft, akTop, akRight]
            Caption = #1040#1090#1088#1080#1073#1091#1090' Active Directory'
            TabOrder = 1
            OnClick = RadioButton_StorageADClick
          end
        end
      end
      object TabSheet_Editor: TTabSheet
        Caption = 'TabSheet_Editor'
        ImageIndex = 3
        TabVisible = False
        DesignSize = (
          524
          483)
        object Label54: TLabel
          Left = 11
          Top = 38
          Width = 505
          Height = 26
          Anchors = [akLeft, akTop, akRight]
          AutoSize = False
          Caption = 
            #1055#1072#1088#1086#1083#1100' '#1087#1086' '#1091#1084#1086#1083#1095#1072#1085#1080#1102' '#1073#1091#1076#1077#1090' '#1080#1089#1087#1086#1083#1100#1079#1086#1074#1072#1085' '#1076#1083#1103' '#1072#1074#1090#1086#1084#1072#1090#1080#1095#1077#1089#1082#1086#1075#1086' '#1079#1072#1087#1086#1083#1085 +
            #1077#1085#1080#1103' '#1087#1086#1083#1103' "'#1055#1072#1088#1086#1083#1100'" '#1087#1088#1080' '#1089#1086#1079#1076#1072#1085#1080#1080' '#1085#1086#1074#1086#1081' '#1091#1095#1077#1090#1085#1086#1081' '#1079#1072#1087#1080#1089#1080' '#1087#1086#1083#1100#1079#1086#1074#1072#1090#1077#1083 +
            #1103' '#1080#1083#1080' '#1087#1088#1080' '#1089#1084#1077#1085#1077' '#1087#1072#1088#1086#1083#1103' '#1087#1086#1083#1100#1079#1086#1074#1072#1090#1077#1083#1103'.'
          WordWrap = True
          ExplicitWidth = 495
        end
        object Label56: TLabel
          Left = 38
          Top = 101
          Width = 41
          Height = 13
          Caption = #1055#1072#1088#1086#1083#1100':'
          Enabled = False
        end
        object Label55: TLabel
          Left = 38
          Top = 128
          Width = 87
          Height = 13
          Caption = #1055#1086#1076#1090#1074#1077#1088#1078#1076#1077#1085#1080#1077':'
          Enabled = False
        end
        object Panel3: TPanel
          Left = 3
          Top = 3
          Width = 518
          Height = 24
          Alignment = taLeftJustify
          Anchors = [akLeft, akTop, akRight]
          BevelOuter = bvNone
          Caption = 'Panel_Caption1'
          ParentBackground = False
          ShowCaption = False
          TabOrder = 3
          object Label5: TLabel
            Left = 8
            Top = 5
            Width = 130
            Height = 13
            Caption = #1055#1072#1088#1086#1083#1100' '#1087#1086' '#1091#1084#1086#1083#1095#1072#1085#1080#1102
            Font.Charset = DEFAULT_CHARSET
            Font.Color = 3355443
            Font.Height = -11
            Font.Name = 'Tahoma'
            Font.Style = [fsBold]
            ParentFont = False
          end
        end
        object CheckBox_UseDefPwd: TCheckBox
          Left = 11
          Top = 75
          Width = 505
          Height = 17
          Anchors = [akLeft, akTop, akRight]
          Caption = #1048#1089#1087#1086#1083#1100#1079#1086#1074#1072#1090#1100' '#1087#1072#1088#1086#1083#1100' '#1087#1086' '#1091#1084#1086#1083#1095#1072#1085#1080#1102
          TabOrder = 0
          OnClick = CheckBox_UseDefPwdClick
        end
        object Edit_Password2: TEdit
          Left = 148
          Top = 125
          Width = 221
          Height = 21
          Enabled = False
          HideSelection = False
          MaxLength = 128
          PasswordChar = #8226
          TabOrder = 2
        end
        object Edit_Password1: TEdit
          Left = 148
          Top = 98
          Width = 221
          Height = 21
          Enabled = False
          MaxLength = 128
          PasswordChar = #8226
          TabOrder = 1
        end
      end
      object TabSheet_FloatingWindow: TTabSheet
        Caption = 'TabSheet_FloatingWindow'
        ImageIndex = 4
        TabVisible = False
        DesignSize = (
          524
          483)
        object Label_FWND_Activity_Hint: TLabel
          Tag = 1
          Left = 28
          Top = 170
          Width = 485
          Height = 56
          Anchors = [akLeft, akTop, akRight]
          AutoSize = False
          Caption = 
            #1044#1083#1103' '#1086#1090#1086#1073#1088#1072#1078#1077#1085#1080#1103' '#1089#1086#1089#1090#1086#1103#1085#1080#1103' '#1087#1088#1080#1089#1091#1090#1089#1090#1074#1080#1103' '#1087#1086#1083#1100#1079#1086#1074#1072#1090#1077#1083#1103' '#1074' '#1089#1077#1090#1080' '#1074' '#1089#1080#1089#1090 +
            #1077#1084#1077' '#1076#1086#1083#1078#1085#1099' '#1073#1099#1090#1100' '#1091#1089#1090#1072#1085#1086#1074#1083#1077#1085#1099' '#1080' '#1079#1072#1087#1091#1097#1077#1085#1099' Skype for Business '#1080#1083#1080' Mi' +
            'crosoft Lync 2010, '#1072' '#1090#1072#1082#1078#1077' '#1079#1072#1088#1077#1075#1080#1089#1090#1088#1080#1088#1086#1074#1072#1085#1099' '#1076#1086#1087#1086#1083#1085#1080#1090#1077#1083#1100#1085#1099#1077' '#1082#1086#1084#1087#1086 +
            #1085#1077#1085#1090#1099' AD Commander. '#1063#1090#1086#1073#1099' '#1079#1072#1088#1077#1075#1080#1089#1090#1088#1080#1088#1086#1074#1072#1090#1100' '#1080#1083#1080' '#1091#1076#1072#1083#1080#1090#1100' '#1082#1086#1084#1087#1086#1085#1077#1085#1090 +
            #1099' AD Commander, '#1074#1086#1089#1087#1086#1083#1100#1079#1091#1081#1090#1077#1089#1100' '#1089#1086#1086#1090#1074#1077#1090#1089#1090#1074#1091#1102#1097#1080#1084#1080' '#1082#1085#1086#1087#1082#1072#1084#1080' '#1088#1072#1089#1087#1086#1083#1086 +
            #1078#1077#1085#1085#1099#1084#1080' '#1085#1080#1078#1077'.'
          Transparent = True
          WordWrap = True
        end
        object Label_FWND_Duration_Unit: TLabel
          Tag = 1
          Left = 227
          Top = 91
          Width = 126
          Height = 13
          Caption = #1089'  (0 - '#1085#1077' '#1089#1082#1088#1099#1074#1072#1090#1100' '#1086#1082#1085#1086')'
          Enabled = False
        end
        object Label_FWND_Duration: TLabel
          Tag = 1
          Left = 28
          Top = 91
          Width = 105
          Height = 13
          Caption = #1042#1088#1077#1084#1103' '#1086#1090#1086#1073#1088#1072#1078#1077#1085#1080#1103':'
          Enabled = False
        end
        object Label_FWND_Delay_Unit: TLabel
          Tag = 1
          Left = 227
          Top = 64
          Width = 11
          Height = 13
          Caption = #1084#1089
          Enabled = False
        end
        object Label_FWND_Delay: TLabel
          Tag = 1
          Left = 28
          Top = 64
          Width = 126
          Height = 13
          Caption = #1047#1072#1076#1077#1088#1078#1082#1072' '#1086#1090#1086#1073#1088#1072#1078#1077#1085#1080#1103':'
          Enabled = False
        end
        object Label3: TLabel
          Tag = 1
          Left = 28
          Top = 118
          Width = 106
          Height = 13
          Caption = #1057#1090#1080#1083#1100' '#1086#1090#1086#1073#1088#1072#1078#1077#1085#1080#1103':'
          Enabled = False
        end
        object Panel4: TPanel
          Left = 3
          Top = 3
          Width = 518
          Height = 24
          Alignment = taLeftJustify
          Anchors = [akLeft, akTop, akRight]
          BevelOuter = bvNone
          Caption = 'Panel_Caption1'
          ParentBackground = False
          ShowCaption = False
          TabOrder = 8
          object Label6: TLabel
            Left = 8
            Top = 5
            Width = 102
            Height = 13
            Caption = #1055#1083#1072#1074#1072#1102#1097#1077#1077' '#1086#1082#1085#1086
            Font.Charset = DEFAULT_CHARSET
            Font.Color = 3355443
            Font.Height = -11
            Font.Name = 'Tahoma'
            Font.Style = [fsBold]
            ParentFont = False
          end
        end
        object Button_FWND_UCMA_UnReg: TButton
          Left = 154
          Top = 232
          Width = 120
          Height = 25
          Caption = #1059#1076#1072#1083#1080#1090#1100
          ElevationRequired = True
          TabOrder = 7
          OnClick = Button_FWND_UCMA_UnRegClick
        end
        object Button_FWND_UCMA_Reg: TButton
          Tag = 1
          Left = 28
          Top = 232
          Width = 120
          Height = 25
          Caption = #1055#1077#1088#1077#1091#1089#1090#1072#1085#1086#1074#1080#1090#1100
          ElevationRequired = True
          TabOrder = 6
          OnClick = Button_FWND_UCMA_RegClick
        end
        object CheckBox_FWND_Activity: TCheckBox
          Tag = 1
          Left = 11
          Top = 147
          Width = 502
          Height = 17
          Anchors = [akLeft, akTop, akRight]
          Caption = #1055#1086#1082#1072#1079#1099#1074#1072#1090#1100' c'#1086#1089#1090#1086#1103#1085#1080#1077' '#1087#1088#1080#1089#1091#1090#1089#1090#1074#1080#1103' '#1087#1086#1083#1100#1079#1086#1074#1072#1090#1077#1083#1103' '#1074' '#1089#1077#1090#1080
          TabOrder = 5
        end
        object UpDown_FWND_Duration: TUpDown
          Tag = 1
          Left = 205
          Top = 88
          Width = 16
          Height = 21
          Associate = Edit_FWND_Duration
          Enabled = False
          TabOrder = 4
        end
        object Edit_FWND_Duration: TEdit
          Tag = 1
          Left = 165
          Top = 88
          Width = 40
          Height = 21
          Alignment = taCenter
          Enabled = False
          NumbersOnly = True
          ReadOnly = True
          TabOrder = 3
          Text = '0'
        end
        object UpDown_FWND_Delay: TUpDown
          Tag = 1
          Left = 205
          Top = 61
          Width = 16
          Height = 21
          Associate = Edit_FWND_Delay
          Enabled = False
          Max = 9000
          Increment = 50
          TabOrder = 2
        end
        object Edit_FWND_Delay: TEdit
          Tag = 1
          Left = 165
          Top = 61
          Width = 40
          Height = 21
          Alignment = taCenter
          Enabled = False
          NumbersOnly = True
          ReadOnly = True
          TabOrder = 1
          Text = '0'
        end
        object CheckBox_FWND_Display: TCheckBox
          Left = 11
          Top = 38
          Width = 502
          Height = 17
          Anchors = [akLeft, akTop, akRight]
          Caption = #1055#1086#1082#1072#1079#1099#1074#1072#1090#1100' '#1087#1083#1072#1074#1072#1102#1097#1077#1077' '#1086#1082#1085#1086' '#1089' '#1082#1088#1072#1090#1082#1086#1081' '#1080#1085#1092#1086#1088#1084#1072#1094#1080#1077#1081' '#1086' '#1087#1086#1083#1100#1079#1086#1074#1072#1090#1077#1083#1077
          TabOrder = 0
          OnClick = CheckBox_FWND_DisplayClick
        end
        object ComboBox_FWND_Style: TComboBox
          Tag = 1
          Left = 165
          Top = 115
          Width = 188
          Height = 22
          Style = csOwnerDrawFixed
          Enabled = False
          ItemIndex = 1
          TabOrder = 9
          Text = 'Skype for Business'
          Items.Strings = (
            'Microsoft Lync'
            'Skype for Business')
        end
      end
      object TabSheet_Mouse: TTabSheet
        Caption = 'TabSheet_Mouse'
        ImageIndex = 5
        TabVisible = False
        DesignSize = (
          524
          483)
        object Label61: TLabel
          Left = 11
          Top = 38
          Width = 127
          Height = 13
          Caption = #1044#1074#1086#1081#1085#1086#1081' '#1082#1083#1080#1082' '#1085#1072' '#1079#1072#1087#1080#1089#1080':'
        end
        object Label62: TLabel
          Left = 35
          Top = 110
          Width = 141
          Height = 13
          Caption = ' + '#1044#1074#1086#1081#1085#1086#1081' '#1082#1083#1080#1082' '#1085#1072' '#1079#1072#1087#1080#1089#1080':'
        end
        object Image12: TImage
          Left = 11
          Top = 110
          Width = 24
          Height = 15
          AutoSize = True
          Picture.Data = {
            0954506E67496D61676589504E470D0A1A0A0000000D49484452000000180000
            000F080200000071C6988C0000000774494D4507DE0A080C19275CF402A60000
            02244944415478DA63FCF7EF5F574F3B0365203FB788B1A7AFD3D4D4849B9B97
            9181913C537EFFF97DE0C07EC6EEDE0E7B07FB1F3F7E08F20B926AC47F86FFEF
            3FBC6767673FB0FF00636F7FA7B5B58D8C94CCF75F3F88D5FFFF3FC810060646
            46066E0E9E5B776F9D387E82B17F62B7A5A595ACB4CCD79FDF6EDEB87560DFA1
            FFFFFE090A09DA3BDA2E59B8BCA02497858505A2FFC5F31710112626A67F20F0
            1768221F0FFFE3C78F8E1C390A35484E46EEC3E70F53264EF7F6F5D4D0547F70
            FFE18DEB372F5EB8C4C7C76B6B6FB375F37619596909498933A7CE1697153031
            31FE051B0404FCBC828F1E3D4018A420A7F0E0F1C379B3171495E603FD0CB4FF
            F9B3E70BE62D2EAD287AFDEA351A83918911620C90E0E71578F8F0FEE1C33083
            941494DE7F7A3FA1777240901FD0450F1F3C626367039A0BD4F6E6CDDBF97316
            965795BC7AF51AC2606404BAE82FD824908B1E3CB877F8F011A8412ACAAADF7E
            7CBB72F9EADEDDFB800129222212121E0C34E8CF9FDF8ECE8E1BD66DACA82E03
            1A346FF67C2003E42290B7FE000D12E015BA77FF0EC220551535A04144C61AC4
            397FFEFE019282FC4277EEDE4618A4A1A6F5E3D777A20DFA030E9FBF7FFFFF15
            E217B97CF5C2B1A3C7A10601FDC2C3CD4B743A84244610F5F5EBD767CF9F1C3B
            0636C8C1C1919999F9C5CBE764E40F2E2E6E6096D8BC65332330C7AAAAAAC9CA
            4A7FFF41ACD7900123239390A0F0A64D1B192F5E3CBF67DF6EA08BC830050284
            84842DCD2D012EB53E3E920E60440000000049454E44AE426082}
        end
        object Label66: TLabel
          Left = 19
          Top = 217
          Width = 96
          Height = 13
          Caption = #1050#1086#1085#1090#1077#1082#1089#1090#1085#1086#1077' '#1084#1077#1085#1102
        end
        object Label67: TLabel
          Left = 19
          Top = 281
          Width = 224
          Height = 13
          Caption = #1055#1088#1086#1082#1088#1091#1090#1082#1072' '#1089#1087#1080#1089#1082#1072' '#1086#1073#1098#1077#1082#1090#1086#1074' Active Directory'
        end
        object Panel5: TPanel
          Left = 3
          Top = 3
          Width = 518
          Height = 24
          Alignment = taLeftJustify
          Anchors = [akLeft, akTop, akRight]
          BevelOuter = bvNone
          Caption = 'Panel_Caption1'
          ParentBackground = False
          ShowCaption = False
          TabOrder = 0
          object Label7: TLabel
            Left = 32
            Top = 5
            Width = 125
            Height = 13
            Caption = #1051#1077#1074#1072#1103' '#1082#1083#1072#1074#1080#1096#1072' '#1084#1099#1096#1080
            Font.Charset = DEFAULT_CHARSET
            Font.Color = 3355443
            Font.Height = -11
            Font.Name = 'Tahoma'
            Font.Style = [fsBold]
            ParentFont = False
          end
          object Image11: TImage
            Left = 8
            Top = 4
            Width = 16
            Height = 16
            AutoSize = True
            Picture.Data = {
              0954506E67496D61676589504E470D0A1A0A0000000D49484452000000100000
              001008060000001FF3FF61000002B04944415478DA7D937B48537114C7BFF7CE
              CD998944B5E64C1798D043CCA68B521223247351A885CD5032CA9041A68235C5
              CA0C0A61388AA2FAA384FEB00714BE86D163D97C44F38FB09181ACB4749A66CD
              E7DCE3EEF6BB77448F6BFDB887DFE53C3EBF737EBF73289665C12D8AA2F85D53
              D57C5E44F9ABA364CBD03FEC44BE8A819BA140D3746D9176DF19CEE7670C1FF7
              3B20FD54F3685A42A47CEB460542A562945F7B81CEFA1C303E1FDA9EF7C0F1E5
              EB58714176C4A280DD55AD25096B65C65455347C8C1FE220116A6F59D065DCCF
              DB7D04D2F2B41363139325C5F9399705008DFED1DB9C8CC4B860090D8AA660B1
              7E84EDC3046AB2E4484BDE42A00C6CEF0760E9B5394A8EE4460A007B2A9BD82C
              8D1A5E1FC3D58B7B4DAF6138AA425BFB639CD615C24B004EA7138D2D66941ED3
              52024081C1CC6E4E5A0786A44F930C4C262BCA340A7474587041AFE3F5DFBF11
              40AB19654579424046652BEBF1FA78474EE36769E4A9588844145C6E0FA69D53
              989D9D877CD50A0238240418AF37B0B999A9080F0F27C104E22717C752E43FE0
              C8953535358DFBA697A8D015080197AEDC66B37725432A0D214F4A932C883EF0
              F14FCCFAFD5870BBF0B0BD1BFA138542408DE1C6E87675BC5C215B0EB144FC67
              B31080D7E385637C92BC4EDFD8D9F2E3110240C5B9BAC6C44D710763950A2C09
              0D4540CD9F0FAE49E7E7E63038328E57BD6FEED6D554688597B8F7C0B61DE999
              DD3B53E2B98A210D96065227F605978BF3C4B3EE3E989F9892DB9B1FF42CD6CA
              127DADD116BF3E265619B9926F1CCEC49D1E2412616864027DFDF6818BD527E3
              488C67D159885E1393945F546ADD10B31ACAD532FE744E3F343C8E77F661DCB9
              59AFFE3468EFFDE73071B92BA29429DAC33A834412AC0E5B1A829959173C1EB7
              B5B1E16AB9E3F35017DF22FF01704B44248648187EAD19227622CCDFE3FC0384
              6A56F02E38F6190000000049454E44AE426082}
          end
        end
        object Panel_LMB1: TPanel
          Left = 19
          Top = 57
          Width = 490
          Height = 37
          Anchors = [akLeft, akTop, akRight]
          BevelOuter = bvNone
          Ctl3D = True
          ParentCtl3D = False
          TabOrder = 1
          DesignSize = (
            490
            37)
          object RadioButton_LMB1: TRadioButton
            Left = 0
            Top = 0
            Width = 490
            Height = 17
            Anchors = [akLeft, akTop, akRight]
            Caption = #1054#1090#1082#1088#1099#1090#1100' '#1089#1074#1086#1081#1089#1090#1074#1072' '#1086#1073#1098#1077#1082#1090#1072
            TabOrder = 0
            OnClick = RadioButton_LMB1Click
          end
          object RadioButton_LMB2: TRadioButton
            Left = 0
            Top = 20
            Width = 490
            Height = 17
            Anchors = [akLeft, akTop, akRight]
            Caption = #1042#1099#1076#1077#1083#1080#1090#1100' '#1090#1077#1082#1089#1090' '#1089#1086#1076#1077#1088#1078#1072#1097#1080#1081#1089#1103' '#1074' '#1087#1086#1083#1077' '#1087#1086#1076' '#1082#1091#1088#1089#1086#1088#1086#1084
            TabOrder = 1
            OnClick = RadioButton_LMB2Click
          end
        end
        object Panel_LMB2: TPanel
          Left = 19
          Top = 129
          Width = 490
          Height = 37
          Anchors = [akLeft, akTop, akRight]
          BevelOuter = bvNone
          Ctl3D = True
          ParentCtl3D = False
          TabOrder = 2
          DesignSize = (
            490
            37)
          object RadioButton_CtrlLMB2: TRadioButton
            Left = 0
            Top = 20
            Width = 490
            Height = 17
            Anchors = [akLeft, akTop, akRight]
            Caption = #1054#1090#1082#1088#1099#1090#1100' '#1089#1074#1086#1081#1089#1090#1074#1072' '#1086#1073#1098#1077#1082#1090#1072
            TabOrder = 0
            OnClick = RadioButton_CtrlLMB2Click
          end
          object RadioButton_CtrlLMB1: TRadioButton
            Left = 0
            Top = 0
            Width = 490
            Height = 17
            Anchors = [akLeft, akTop, akRight]
            Caption = #1042#1099#1076#1077#1083#1080#1090#1100' '#1090#1077#1082#1089#1090' '#1089#1086#1076#1077#1088#1078#1072#1097#1080#1081#1089#1103' '#1074' '#1087#1086#1083#1077' '#1087#1086#1076' '#1082#1091#1088#1089#1086#1088#1086#1084
            TabOrder = 1
            OnClick = RadioButton_CtrlLMB1Click
          end
        end
        object Panel13: TPanel
          Left = 3
          Top = 182
          Width = 518
          Height = 24
          Alignment = taLeftJustify
          Anchors = [akLeft, akTop, akRight]
          BevelOuter = bvNone
          Caption = 'Panel_Caption1'
          ParentBackground = False
          ShowCaption = False
          TabOrder = 3
          object Label13: TLabel
            Left = 32
            Top = 5
            Width = 132
            Height = 13
            Caption = #1055#1088#1072#1074#1072#1103' '#1082#1083#1072#1074#1080#1096#1072' '#1084#1099#1096#1080
            Font.Charset = DEFAULT_CHARSET
            Font.Color = 3355443
            Font.Height = -11
            Font.Name = 'Tahoma'
            Font.Style = [fsBold]
            ParentFont = False
          end
          object Image13: TImage
            Left = 8
            Top = 4
            Width = 16
            Height = 16
            AutoSize = True
            Picture.Data = {
              0954506E67496D61676589504E470D0A1A0A0000000D49484452000000100000
              001008060000001FF3FF61000002B64944415478DA7D937B48D35114C7BFBFDF
              7E9B3A5F1B3E98D3521895864AC1045D5BA558044EA3FE08250AF38F8AA49808
              529059898A529895480B2A5C3625660F9F29D20B7B30652462868C5AEA141F84
              A86DCDF6FB757F93E8F1B3CEE570E1DC733EF7DC7BCEA1388E032F1445F976A3
              F9D1458E654BC534D064A3111F23C3F8CC177839BABCA322E71CEFF333C617F7
              3BA0A1B1754AA90857E8D3D340333474450F71E9C40E2CBB57F066C48967B6C9
              E9DEEA9CA835010D26CB294544585D76A6160CC3F86C5A8305670BB4F8EEF542
              44D3E879FB11A38E79435785BE4E00A8BBD532A953272A93E237807FCDF5E63E
              B4DADC50844991B533016291086E8F1796AEC1E18EAA7D490240ED4D3397979D
              0E994C0686DC66B2B461F7AE0C1CAE7E8E0C6D3CC2E54124331A0FDAAD68AFDC
              4B0901C67B5C2E01C8E532D034856BC62668B66B517A771469A99B209307133B
              0DDBC0281A8BD38580EAFA466E766E0E52A99464114AF600CC2EB1E8F9404144
              71E0DD44221A123183EE4ABD1050536FE20E64E9101A12029665F96291401244
              CA491222FF42636161012D9D2F60389E2F04545DBDCDEDDFA381BF5F0028922A
              6FF779F1C164711C0BB7DB85D627AF70FAE41121E0C2E51B53BA94648532320C
              6289F8CF66216559F1ACC039338F97D6A1E9B2E26351024049598D3955BD2537
              2E3A12D2C040AC9A395F0A7C59BF2E2F63CCE1C4E0BBE1E69AF3257902C0C182
              427DD256755BA626995869F2147FDFCDFCB9DBE5221FC1A1AF7F084F7B3B35DD
              8FEFBF5EAB95A567CAAFD89213541B63A3237CDDC71FF1B733A4891C93B3187A
              6F1FAB2A35249218CF9AB3B03E4EA53E74B4C8BA591583D898C8D58F2476C7C4
              0C46EC1330196B533E7FB20FFC739888D0CA75B1DBF2F20B2F4B247E29C14101
              585C72C1E3F96635DFA92F768E3BFA890FFB3F002F22A22AA2C1F8258B44ED44
              BD7F8FF30F69EC33F032EEEBA40000000049454E44AE426082}
          end
        end
        object Panel14: TPanel
          Left = 3
          Top = 246
          Width = 518
          Height = 24
          Alignment = taLeftJustify
          Anchors = [akLeft, akTop, akRight]
          BevelOuter = bvNone
          Caption = 'Panel_Caption1'
          ParentBackground = False
          ShowCaption = False
          TabOrder = 4
          object Label14: TLabel
            Left = 32
            Top = 5
            Width = 106
            Height = 13
            Caption = #1050#1086#1083#1077#1089#1086' '#1087#1088#1086#1082#1088#1091#1090#1082#1080
            Font.Charset = DEFAULT_CHARSET
            Font.Color = 3355443
            Font.Height = -11
            Font.Name = 'Tahoma'
            Font.Style = [fsBold]
            ParentFont = False
          end
          object Image14: TImage
            Left = 8
            Top = 4
            Width = 16
            Height = 16
            AutoSize = True
            Picture.Data = {
              0954506E67496D61676589504E470D0A1A0A0000000D49484452000000100000
              001008060000001FF3FF61000002B14944415478DA7D930B4814511486FFD99D
              7D98A9A0A6EB6A6DB05824664859F84832894AD4C0085D457B40960899294B42
              66666089A608A25950B9C84AA1908609150B6A1A28152A3D900D355D4D537CAF
              EECEEC746724B2C6BA709873CFBDE73B7339E7A7388E03BF288A12BEB5C66737
              59D691CFFB52A9142CCB62CD9714A5EB4E5CE7FD5F3942DE7A40755DD3B8DADB
              531513150A5A46A3B4A61EB91753C0D819B49ABA61F9FE6322232DC1674340B5
              A1314BE5E55111171D019AA685D8D5C252DC2EC8157C8661D0F2AA131353D359
              19A9272B4580F2070DFD87F6EF0E0CD8A185424EE396F13DBE8CCE63A7AF2BAE
              2507C3CE38D0FF79101DBD0396AC7389BE62C07D23171B7D001AB51A721985D0
              EC66946446415F654277793C6C760E33B3B330B698907D5E478900776BEB395D
              EC61B8BBBB41410091B92F703A29028F1B3AD15E7A1CAB3C60660EC6E7265C49
              4F16036A0C8D9CF9EB083CBD3CE0EAEC04C33B29680979BB03480966304D9217
              1797A1F2F624801431E04E551D97181309373757D2271652724542CC418E598E
              225D9260766E1E4F5ADBA1CF4C13038A2B1F720947C3A0543A819248F86EE3F7
              A2C0391C5859B5A2A9AD0B7997CE8A018565F7C60F8604A9D4E40932B9ECCF61
              213362B7D961999C46474FDF4441CE051F11407FA3C4B8774F6092BF468D4DCE
              CE580B7342757E4897979630343689B7BD1F1A4A0AF53A11E058FCA9D0A82331
              5DD1E14164278152A1142AF3E72B562B7F13AFBBFA607AD91AD6D6FCB47BA351
              96E715550C04EDD2FA6B7CB780211AE08FF8EA34D1C4F0D814FA3E99078BF32F
              07921CDB865AD8B65DBB2F353DBB2740EB078D9F97509D8F0F8F4EE2A3791486
              DAF290912173EF3FC5C4FFBB7AAB265C7726B34C2E5784B86C76C2C2A21536DB
              6A8FF151558EE5DBF01BF09DFD0F40502E312D3197757D5C206626C6FE2DE79F
              B3E641F0E367DEC30000000049454E44AE426082}
          end
        end
      end
      object TabSheet_Scripts: TTabSheet
        Caption = 'TabSheet_Scripts'
        ImageIndex = 6
        TabVisible = False
        DesignSize = (
          524
          483)
        object Label48: TLabel
          Left = 11
          Top = 38
          Width = 502
          Height = 39
          Anchors = [akLeft, akTop, akRight]
          AutoSize = False
          Caption = 
            #1047#1076#1077#1089#1100' '#1074#1099' '#1084#1086#1078#1077#1090#1077' '#1089#1086#1079#1076#1072#1090#1100' '#1082#1085#1086#1087#1082#1080', '#1082#1086#1090#1086#1088#1099#1077' '#1073#1091#1076#1091#1090' '#1074#1099#1087#1086#1083#1085#1103#1090#1100' '#1087#1088#1080#1089#1074#1086#1077#1085 +
            #1085#1099#1077' '#1080#1084' '#1089#1082#1088#1080#1087#1090#1099'. '#1057#1086#1079#1076#1072#1085#1085#1099#1077' '#1082#1085#1086#1087#1082#1080' '#1073#1091#1076#1091#1090' '#1088#1072#1089#1087#1086#1083#1086#1078#1077#1085#1099' '#1074' '#1088#1077#1076#1072#1082#1090#1086#1088#1077' '#1089 +
            #1074#1086#1081#1089#1090#1074' '#1091#1095#1077#1090#1085#1086#1081' '#1079#1072#1087#1080#1089#1080' '#1087#1086#1083#1100#1079#1086#1074#1072#1090#1077#1083#1103' '#1085#1072' '#1079#1072#1082#1083#1072#1076#1082#1077' "'#1044#1086#1087#1086#1083#1085#1080#1090#1077#1083#1100#1085#1086'".'
          Transparent = True
          WordWrap = True
        end
        object Label_ScriptButtons_Search: TLabel
          Left = 273
          Top = 91
          Width = 34
          Height = 13
          Anchors = [akTop, akRight]
          Caption = #1055#1086#1080#1089#1082':'
        end
        object Panel6: TPanel
          Left = 3
          Top = 3
          Width = 518
          Height = 24
          Alignment = taLeftJustify
          Anchors = [akLeft, akTop, akRight]
          BevelOuter = bvNone
          Caption = 'Panel_Caption1'
          ParentBackground = False
          ShowCaption = False
          TabOrder = 0
          object Label8: TLabel
            Left = 8
            Top = 5
            Width = 173
            Height = 13
            Caption = #1050#1085#1086#1087#1082#1080' '#1074#1099#1087#1086#1083#1085#1077#1085#1080#1103' '#1089#1082#1088#1080#1087#1090#1086#1074
            Font.Charset = DEFAULT_CHARSET
            Font.Color = 3355443
            Font.Height = -11
            Font.Name = 'Tahoma'
            Font.Style = [fsBold]
            ParentFont = False
          end
        end
        object ListView_ScriptButtons: TListView
          AlignWithMargins = True
          Left = 11
          Top = 115
          Width = 502
          Height = 357
          Margins.Left = 11
          Margins.Right = 11
          Margins.Bottom = 11
          Anchors = [akLeft, akTop, akRight, akBottom]
          BorderStyle = bsNone
          Columns = <
            item
              Width = 250
            end
            item
              Width = 32
            end
            item
              Width = 32
            end>
          ColumnClick = False
          OwnerData = True
          OwnerDraw = True
          ReadOnly = True
          ParentColor = True
          ParentShowHint = False
          ShowColumnHeaders = False
          ShowHint = True
          TabOrder = 1
          ViewStyle = vsReport
          OnClick = ListView_ScriptButtonsClick
          OnCustomDraw = ListView_ScriptButtonsCustomDraw
          OnDblClick = ListView_ScriptButtonsDblClick
          OnDrawItem = ListView_ScriptButtonsDrawItem
          OnKeyDown = ListView_ScriptButtonsKeyDown
          OnMouseMove = ListView_ScriptButtonsMouseMove
          OnResize = ListView_ScriptButtonsResize
        end
        object ToolBar_ScriptButtons: TToolBar
          Left = 11
          Top = 88
          Width = 118
          Height = 22
          Align = alCustom
          ButtonWidth = 70
          Caption = 'ToolBar_ScriptButtons'
          Images = DM1.ImageList_16x16
          List = True
          AllowTextButtons = True
          TabOrder = 2
          Wrapable = False
          object ToolButton_ScriptButtons_Refresh: TToolButton
            Left = 0
            Top = 0
            Caption = 'ToolButton_ScriptButtons_Refresh'
            ImageIndex = 7
            OnClick = ToolButton_ScriptButtons_RefreshClick
          end
          object ToolButton2: TToolButton
            Left = 24
            Top = 0
            Width = 8
            Caption = 'ToolButton2'
            ImageIndex = 6
            Style = tbsSeparator
          end
          object ToolButton_ScriptButton_Create: TToolButton
            Left = 32
            Top = 0
            Caption = #1057#1086#1079#1076#1072#1090#1100
            ImageIndex = 5
            Style = tbsTextButton
            OnClick = ToolButton_ScriptButton_CreateClick
          end
        end
        object Edit_ScriptButtons_Search: TButtonedEdit
          Left = 313
          Top = 88
          Width = 200
          Height = 21
          Anchors = [akTop, akRight]
          Images = DM1.ImageList_16x16
          RightButton.ImageIndex = 6
          TabOrder = 3
          OnChange = Edit_ScriptButtons_SearchChange
          OnRightButtonClick = Edit_ScriptButtons_SearchRightButtonClick
        end
      end
      object TabSheet_Dummy1: TTabSheet
        Caption = 'TabSheet_Dummy1'
        ImageIndex = 10
        TabVisible = False
        DesignSize = (
          524
          483)
        object Panel10: TPanel
          Left = 3
          Top = 3
          Width = 518
          Height = 24
          Alignment = taLeftJustify
          Anchors = [akLeft, akTop, akRight]
          BevelOuter = bvNone
          Caption = 'Panel_Caption1'
          ParentBackground = False
          ShowCaption = False
          TabOrder = 0
          object Label12: TLabel
            Left = 8
            Top = 5
            Width = 15
            Height = 13
            Caption = '---'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = 3355443
            Font.Height = -11
            Font.Name = 'Tahoma'
            Font.Style = [fsBold]
            ParentFont = False
          end
        end
      end
      object TabSheet_DameWare: TTabSheet
        Caption = 'TabSheet_DameWare'
        ImageIndex = 7
        TabVisible = False
        DesignSize = (
          524
          483)
        object Label_DMRC_Version: TLabel
          Left = 56
          Top = 70
          Width = 76
          Height = 13
          Caption = '<'#1085#1077#1090' '#1076#1072#1085#1085#1099#1093'>'
        end
        object Label_DMRC1: TLabel
          Left = 11
          Top = 70
          Width = 39
          Height = 13
          Caption = #1042#1077#1088#1089#1080#1103':'
        end
        object Label_DMRC_Authorization: TLabel
          Left = 11
          Top = 138
          Width = 126
          Height = 13
          Caption = #1052#1077#1090#1086#1076' '#1072#1091#1090#1077#1085#1090#1080#1092#1080#1082#1072#1094#1080#1080':'
        end
        object Label_DMRC_Username: TLabel
          Left = 11
          Top = 165
          Width = 97
          Height = 13
          Caption = #1048#1084#1103' '#1087#1086#1083#1100#1079#1086#1074#1072#1090#1077#1083#1103':'
        end
        object Label_DMRC_Password: TLabel
          Left = 11
          Top = 192
          Width = 41
          Height = 13
          Caption = #1055#1072#1088#1086#1083#1100':'
        end
        object Label_DMRC_Domain: TLabel
          Left = 11
          Top = 219
          Width = 36
          Height = 13
          Caption = #1044#1086#1084#1077#1085':'
        end
        object Panel7: TPanel
          Left = 3
          Top = 3
          Width = 518
          Height = 24
          Alignment = taLeftJustify
          Anchors = [akLeft, akTop, akRight]
          BevelOuter = bvNone
          Caption = 'Panel_Caption1'
          ParentBackground = False
          ShowCaption = False
          TabOrder = 0
          object Label9: TLabel
            Left = 8
            Top = 5
            Width = 181
            Height = 13
            Caption = 'DameWare Mini Remote Control'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = 3355443
            Font.Height = -11
            Font.Name = 'Tahoma'
            Font.Style = [fsBold]
            ParentFont = False
          end
        end
        object Edit_DMRC_dom: TEdit
          Left = 148
          Top = 216
          Width = 198
          Height = 21
          AutoSelect = False
          TabOrder = 1
        end
        object Button_DMRC1: TButton
          Left = 438
          Top = 36
          Width = 75
          Height = 25
          Anchors = [akTop, akRight]
          Caption = #1054#1073#1079#1086#1088'...'
          TabOrder = 2
          OnClick = Button_DMRC1Click
        end
        object Edit_DMRC_exe: TEdit
          Left = 11
          Top = 38
          Width = 421
          Height = 21
          Anchors = [akLeft, akTop, akRight]
          AutoSelect = False
          TabOrder = 3
          OnChange = Edit_DMRC_exeChange
        end
        object Edit_DMRC_pass: TEdit
          Left = 148
          Top = 189
          Width = 198
          Height = 21
          AutoSelect = False
          PasswordChar = #8226
          TabOrder = 4
        end
        object Edit_DMRC_user: TEdit
          Left = 148
          Top = 162
          Width = 198
          Height = 21
          AutoSelect = False
          TabOrder = 5
        end
        object ComboBox_DMRC: TComboBox
          Left = 148
          Top = 134
          Width = 198
          Height = 22
          Style = csOwnerDrawFixed
          ItemIndex = 2
          TabOrder = 6
          Text = 'Encrypted Windows Logon'
          OnSelect = ComboBox_DMRCSelect
          Items.Strings = (
            'Proprietary Challenge/Response'
            'Windows NT Challenge/Response'
            'Encrypted Windows Logon'
            'Smart Card Logon'
            'Current Logon Credentials')
        end
        object CheckBox_DMRC_Driver: TCheckBox
          Left = 11
          Top = 299
          Width = 502
          Height = 17
          Anchors = [akLeft, akTop, akRight]
          Caption = #1048#1089#1087#1086#1083#1100#1079#1086#1074#1072#1090#1100' DameWare Mirror Driver ('#1077#1089#1083#1080' '#1091#1089#1090#1072#1085#1086#1074#1083#1077#1085')'
          TabOrder = 7
        end
        object CheckBox_DMRC_Auto: TCheckBox
          Left = 11
          Top = 322
          Width = 502
          Height = 17
          Anchors = [akLeft, akTop, akRight]
          Caption = #1055#1086#1076#1082#1083#1102#1095#1072#1090#1100#1089#1103' '#1072#1074#1090#1086#1084#1072#1090#1080#1095#1077#1089#1082#1080
          Checked = True
          State = cbChecked
          TabOrder = 8
        end
        object Panel15: TPanel
          Left = 3
          Top = 99
          Width = 518
          Height = 24
          Alignment = taLeftJustify
          Anchors = [akLeft, akTop, akRight]
          BevelOuter = bvNone
          Caption = 'Panel_Caption1'
          ParentBackground = False
          ShowCaption = False
          TabOrder = 9
          object Label16: TLabel
            Left = 8
            Top = 5
            Width = 153
            Height = 13
            Caption = #1055#1072#1088#1072#1084#1077#1090#1088#1099' '#1087#1086#1076#1082#1083#1102#1095#1077#1085#1080#1103
            Font.Charset = DEFAULT_CHARSET
            Font.Color = 3355443
            Font.Height = -11
            Font.Name = 'Tahoma'
            Font.Style = [fsBold]
            ParentFont = False
          end
        end
        object RadioButton_DMRC_Viewer: TRadioButton
          Left = 11
          Top = 276
          Width = 492
          Height = 17
          Caption = #1048#1089#1087#1086#1083#1100#1079#1086#1074#1072#1090#1100' MRC Viewer'
          Checked = True
          TabOrder = 10
          TabStop = True
          OnClick = RadioButton_DMRC_ViewerClick
        end
        object RadioButton_DMRC_RDP: TRadioButton
          Left = 11
          Top = 253
          Width = 492
          Height = 17
          Caption = #1048#1089#1087#1086#1083#1100#1079#1086#1074#1072#1090#1100' Remote Desktop Protocol (RDP)'
          TabOrder = 11
          OnClick = RadioButton_DMRC_RDPClick
        end
      end
      object TabSheet1: TTabSheet
        Caption = 'TabSheet_PsExec'
        ImageIndex = 9
        TabVisible = False
        DesignSize = (
          524
          483)
        object Label_PsE_Hint2: TLabel
          Left = 38
          Top = 309
          Width = 459
          Height = 13
          Caption = 
            #1042' '#1087#1072#1088#1086#1083#1077' '#1085#1077#1083#1100#1079#1103' '#1080#1089#1087#1086#1083#1100#1079#1086#1074#1072#1090#1100' '#1089#1087#1077#1094#1080#1072#1083#1100#1085#1099#1077' '#1089#1080#1084#1074#1086#1083#1099'. '#1053#1072#1087#1088#1080#1084#1077#1088': " & ' +
            '^ ['#1087#1088#1086#1073#1077#1083'] '#1080' '#1076#1088#1091#1075#1080#1077'.'
          Enabled = False
          ShowAccelChar = False
        end
        object Label_PsE_Hint1: TLabel
          Left = 38
          Top = 293
          Width = 438
          Height = 13
          Caption = 
            #1060#1086#1088#1084#1072#1090' '#1074#1074#1086#1076#1072' '#1080#1084#1077#1085#1080' '#1087#1086#1083#1100#1079#1086#1074#1072#1090#1077#1083#1103': DOMAIN\Username '#1080#1083#1080' COMPUTERNAM' +
            'E\Username'
          Enabled = False
        end
        object Label_PsE_Password: TLabel
          Left = 38
          Top = 264
          Width = 41
          Height = 13
          Caption = #1055#1072#1088#1086#1083#1100':'
          Enabled = False
        end
        object Label_PsE_User: TLabel
          Left = 38
          Top = 237
          Width = 97
          Height = 13
          Caption = #1048#1084#1103' '#1087#1086#1083#1100#1079#1086#1074#1072#1090#1077#1083#1103':'
          Enabled = False
        end
        object Label_PsE4: TLabel
          Left = 267
          Top = 164
          Width = 21
          Height = 13
          Caption = #1089#1077#1082'.'
        end
        object Label_PsE3: TLabel
          Left = 11
          Top = 164
          Width = 164
          Height = 13
          Caption = #1042#1088#1077#1084#1103' '#1086#1090#1086#1073#1088#1072#1078#1077#1085#1080#1103' '#1089#1086#1086#1073#1097#1077#1085#1080#1103':'
        end
        object Label_PsE2: TLabel
          Left = 11
          Top = 137
          Width = 201
          Height = 13
          Caption = #1042#1088#1077#1084#1103' '#1086#1078#1080#1076#1072#1085#1080#1103' '#1079#1072#1074#1077#1088#1096#1077#1085#1080#1103' '#1087#1088#1086#1094#1077#1089#1089#1072':'
        end
        object Label_PsE_Version: TLabel
          Left = 56
          Top = 70
          Width = 76
          Height = 13
          Caption = '<'#1085#1077#1090' '#1076#1072#1085#1085#1099#1093'>'
        end
        object Label_PsE1: TLabel
          Left = 11
          Top = 70
          Width = 39
          Height = 13
          Caption = #1042#1077#1088#1089#1080#1103':'
        end
        object Label_PsE9: TLabel
          Left = 267
          Top = 137
          Width = 22
          Height = 13
          Caption = #1084#1080#1085'.'
        end
        object Label_PsE10: TLabel
          Left = 300
          Top = 137
          Width = 131
          Height = 13
          Caption = '(0 - '#1086#1078#1080#1076#1072#1090#1100' '#1073#1077#1089#1082#1086#1085#1077#1095#1085#1086')'
        end
        object Label_PsE11: TLabel
          Left = 300
          Top = 164
          Width = 203
          Height = 13
          Caption = '(0 - '#1087#1086#1082#1072' '#1085#1077' '#1073#1091#1076#1077#1090' '#1085#1072#1078#1072#1090#1072' '#1082#1085#1086#1087#1082#1072' "'#1054#1050'")'
        end
        object Panel9: TPanel
          Left = 3
          Top = 3
          Width = 518
          Height = 24
          Alignment = taLeftJustify
          Anchors = [akLeft, akTop, akRight]
          BevelOuter = bvNone
          Caption = 'Panel_Caption1'
          ParentBackground = False
          ShowCaption = False
          TabOrder = 10
          object Label11: TLabel
            Left = 8
            Top = 5
            Width = 112
            Height = 13
            Caption = 'Sysinternals PsExec'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = 3355443
            Font.Height = -11
            Font.Name = 'Tahoma'
            Font.Style = [fsBold]
            ParentFont = False
          end
        end
        object Edit_PsE_Password: TEdit
          Left = 147
          Top = 261
          Width = 185
          Height = 21
          Enabled = False
          PasswordChar = #8226
          TabOrder = 9
        end
        object Edit_PsE_User: TEdit
          Left = 147
          Top = 234
          Width = 185
          Height = 21
          Enabled = False
          TabOrder = 8
        end
        object CheckBox_PsE_RunAs: TCheckBox
          Left = 11
          Top = 211
          Width = 505
          Height = 17
          Anchors = [akLeft, akTop, akRight]
          Caption = 
            #1047#1072#1087#1091#1089#1082#1072#1090#1100' PsExec '#1085#1072' '#1091#1076#1072#1083#1077#1085#1085#1086#1084' '#1082#1086#1084#1087#1100#1102#1090#1077#1088#1077' '#1086#1090' '#1080#1084#1077#1085#1080' '#1076#1088#1091#1075#1086#1075#1086' '#1087#1086#1083#1100#1079#1086 +
            #1074#1072#1090#1077#1083#1103
          TabOrder = 7
          OnClick = CheckBox_PsE_RunAsClick
        end
        object CheckBox_PsE_Output: TCheckBox
          Left = 11
          Top = 188
          Width = 502
          Height = 17
          Anchors = [akLeft, akTop, akRight]
          Caption = #1054#1090#1086#1073#1088#1072#1078#1072#1090#1100' '#1086#1082#1085#1086' '#1074#1099#1087#1086#1083#1085#1077#1085#1080#1103' '#1087#1088#1086#1094#1077#1089#1089#1072' PsExec ('#1085#1077' '#1088#1077#1082#1086#1084#1077#1085#1076#1091#1077#1090#1089#1103')'
          TabOrder = 6
        end
        object UpDown_PsE_DisplayTime: TUpDown
          Left = 247
          Top = 161
          Width = 16
          Height = 21
          Associate = Edit_PsE_DisplayTime
          Max = 600
          Position = 10
          TabOrder = 5
        end
        object Edit_PsE_DisplayTime: TEdit
          Left = 218
          Top = 161
          Width = 29
          Height = 21
          Alignment = taCenter
          NumbersOnly = True
          TabOrder = 4
          Text = '10'
          OnChange = Edit_PsE_DisplayTimeChange
        end
        object UpDown_PsE_WaitingTime: TUpDown
          Left = 247
          Top = 134
          Width = 16
          Height = 21
          Associate = Edit_PsE_WaitingTime
          Position = 10
          TabOrder = 3
        end
        object Edit_PsE_WaitingTime: TEdit
          Left = 218
          Top = 134
          Width = 29
          Height = 21
          Alignment = taCenter
          NumbersOnly = True
          TabOrder = 2
          Text = '10'
          OnChange = Edit_PsE_WaitingTimeChange
        end
        object Button_PsE1: TButton
          Left = 438
          Top = 36
          Width = 75
          Height = 25
          Anchors = [akTop, akRight]
          Caption = #1054#1073#1079#1086#1088'...'
          TabOrder = 1
          OnClick = Button_PsE1Click
        end
        object Edit_PsE_exe: TEdit
          Left = 11
          Top = 38
          Width = 421
          Height = 21
          Anchors = [akLeft, akTop, akRight]
          AutoSelect = False
          TabOrder = 0
          OnChange = Edit_PsE_exeChange
        end
        object Panel16: TPanel
          Left = 3
          Top = 99
          Width = 518
          Height = 24
          Alignment = taLeftJustify
          Anchors = [akLeft, akTop, akRight]
          BevelOuter = bvNone
          Caption = 'Panel_Caption1'
          ParentBackground = False
          ShowCaption = False
          TabOrder = 11
          object Label18: TLabel
            Left = 8
            Top = 5
            Width = 68
            Height = 13
            Caption = #1055#1072#1088#1072#1084#1077#1090#1088#1099
            Font.Charset = DEFAULT_CHARSET
            Font.Color = 3355443
            Font.Height = -11
            Font.Name = 'Tahoma'
            Font.Style = [fsBold]
            ParentFont = False
          end
        end
      end
    end
  end
end
