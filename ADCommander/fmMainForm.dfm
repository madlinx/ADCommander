object ADCmd_MainForm: TADCmd_MainForm
  Left = 0
  Top = 0
  Caption = 'ADCmd_MainForm'
  ClientHeight = 561
  ClientWidth = 784
  Color = clBtnFace
  Constraints.MinHeight = 600
  Constraints.MinWidth = 800
  DoubleBuffered = True
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  KeyPreview = True
  OldCreateOrder = False
  Position = poScreenCenter
  OnClose = FormClose
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnKeyDown = FormKeyDown
  OnResize = FormResize
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object Splitter: TSplitter
    Left = 250
    Top = 0
    Width = 5
    Height = 542
    AutoSnap = False
    MinSize = 250
    ResizeStyle = rsUpdate
    OnPaint = SplitterPaint
  end
  object StatusBar: TStatusBar
    Left = 0
    Top = 542
    Width = 784
    Height = 19
    Panels = <
      item
        Style = psOwnerDraw
        Width = 170
      end
      item
        Style = psOwnerDraw
        Width = 130
      end
      item
        Style = psOwnerDraw
        Width = 222
      end
      item
        Style = psOwnerDraw
        Width = 180
      end
      item
        Style = psOwnerDraw
        Width = 50
      end
      item
        Width = 5
      end>
    ParentShowHint = False
    ShowHint = True
    OnDrawPanel = StatusBarDrawPanel
  end
  object Panel_DC: TPanel
    Left = 0
    Top = 0
    Width = 250
    Height = 542
    Margins.Left = 0
    Margins.Top = 0
    Margins.Right = 0
    Margins.Bottom = 0
    Align = alLeft
    BevelOuter = bvNone
    TabOrder = 1
    object Panel_DCTop: TPanel
      AlignWithMargins = True
      Left = 3
      Top = 3
      Width = 244
      Height = 28
      Align = alTop
      BevelOuter = bvNone
      ShowCaption = False
      TabOrder = 0
      DesignSize = (
        244
        28)
      object ComboBox_DC: TComboBox
        Left = 3
        Top = 3
        Width = 147
        Height = 22
        Align = alCustom
        Style = csOwnerDrawFixed
        Anchors = [akLeft, akTop, akRight]
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Tahoma'
        Font.Style = [fsBold]
        ParentFont = False
        Sorted = True
        TabOrder = 0
        OnDrawItem = ComboBox_DCDrawItem
        OnSelect = ComboBox_DCSelect
      end
      object ActionToolBar_DC: TActionToolBar
        Left = 155
        Top = 0
        Width = 93
        Height = 28
        ActionManager = ActionManager_Main
        Align = alNone
        Anchors = [akTop, akRight]
        Caption = 'ActionToolBar_DC'
        Color = clMenuBar
        ColorMap.DisabledFontColor = 7171437
        ColorMap.HighlightColor = clWhite
        ColorMap.BtnSelectedFont = clBlack
        ColorMap.UnusedColor = clWhite
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clBlack
        Font.Height = -11
        Font.Name = 'Tahoma'
        Font.Style = []
        ParentFont = False
        ParentShowHint = False
        ShowHint = True
        Spacing = 0
        VertMargin = 2
      end
    end
    object TreeView_AD: TTreeView
      Left = 0
      Top = 34
      Width = 250
      Height = 480
      Align = alClient
      BorderStyle = bsNone
      Ctl3D = True
      HideSelection = False
      Images = DM1.ImageList_Main
      Indent = 19
      ParentCtl3D = False
      ReadOnly = True
      ShowRoot = False
      TabOrder = 1
      OnChange = TreeView_ADChange
      OnCollapsing = TreeView_ADCollapsing
      OnDeletion = TreeView_ADDeletion
      OnKeyDown = TreeView_ADKeyDown
      OnMouseUp = TreeView_ADMouseUp
    end
    object Panel_DCBottom: TPanel
      Left = 0
      Top = 514
      Width = 250
      Height = 28
      Align = alBottom
      BevelOuter = bvNone
      TabOrder = 2
      Visible = False
      OnClick = Panel_DCBottomClick
    end
  end
  object Panel_Accounts: TPanel
    Left = 255
    Top = 0
    Width = 529
    Height = 542
    Margins.Left = 0
    Margins.Top = 0
    Margins.Right = 0
    Margins.Bottom = 0
    Align = alClient
    BevelOuter = bvNone
    TabOrder = 2
    object Panel_AccountsTop: TPanel
      AlignWithMargins = True
      Left = 3
      Top = 3
      Width = 523
      Height = 28
      Align = alTop
      BevelOuter = bvNone
      TabOrder = 0
      object ActionToolBar_Acc: TActionToolBar
        AlignWithMargins = True
        Left = 0
        Top = 0
        Width = 267
        Height = 28
        Margins.Left = 0
        Margins.Top = 0
        Margins.Right = 6
        Margins.Bottom = 0
        ActionManager = ActionManager_Main
        Align = alClient
        Caption = 'ActionToolBar_Acc'
        Color = clMenuBar
        ColorMap.DisabledFontColor = 7171437
        ColorMap.HighlightColor = clWhite
        ColorMap.BtnSelectedFont = clBlack
        ColorMap.UnusedColor = clWhite
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clBlack
        Font.Height = -11
        Font.Name = 'Tahoma'
        Font.Style = []
        ParentFont = False
        ParentShowHint = False
        ShowHint = True
        Spacing = 0
        VertMargin = 2
      end
      inline Frame_Search: TFrame_Search
        Left = 273
        Top = 0
        Width = 250
        Height = 28
        Align = alRight
        TabOrder = 1
        ExplicitLeft = 273
        ExplicitHeight = 28
        inherited Panel_Search: TPanel
          Top = 2
          ExplicitTop = 2
          inherited Button_ClearPattern: TBitBtn
            Visible = False
          end
          inherited ComboBox_SearchOption: TComboBox
            OnSelect = Frame_SearchComboBox_SearchOptionSelect
          end
          inherited Edit_SearchPattern: TEdit
            OnChange = Frame_SearchEdit_SearchPatternChange
          end
        end
      end
    end
    object ListView_Accounts: TListView
      Left = 0
      Top = 34
      Width = 529
      Height = 480
      Align = alClient
      BorderStyle = bsNone
      Columns = <>
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = []
      FullDrag = True
      OwnerData = True
      OwnerDraw = True
      ReadOnly = True
      RowSelect = True
      ParentFont = False
      PopupMenu = PopupMenu_ListAcc
      TabOrder = 1
      ViewStyle = vsReport
      OnChange = ListView_AccountsChange
      OnColumnClick = ListView_AccountsColumnClick
      OnColumnDragged = ListView_AccountsColumnDragged
      OnCustomDraw = ListView_AccountsCustomDraw
      OnData = ListView_AccountsData
      OnDrawItem = ListView_AccountsDrawItem
      OnKeyDown = ListView_AccountsKeyDown
      OnMouseDown = ListView_AccountsMouseDown
    end
    object Panel_AccountsBottom: TPanel
      Left = 0
      Top = 514
      Width = 529
      Height = 28
      Align = alBottom
      BevelOuter = bvNone
      Color = clWhite
      TabOrder = 2
      Visible = False
      object Label_ADPath: TLabel
        AlignWithMargins = True
        Left = 6
        Top = 3
        Width = 520
        Height = 22
        Margins.Left = 6
        Align = alClient
        AutoSize = False
        Caption = 'Label_ADPath'
        EllipsisPosition = epPathEllipsis
        Layout = tlCenter
        ExplicitLeft = 120
        ExplicitTop = 8
        ExplicitWidth = 31
        ExplicitHeight = 13
      end
    end
  end
  object PopupMenu_TreeAD: TPopupMenu
    AutoPopup = False
    Left = 16
    Top = 464
    object N1: TMenuItem
      Caption = #1057#1086#1079#1076#1072#1090#1100
    end
  end
  object ActionManager_Main: TActionManager
    ActionBars = <
      item
        Items.CaptionOptions = coNone
        Items = <
          item
            Caption = '-'
          end
          item
            Action = Action_DCList_Refresh
            ImageIndex = 8
            ShortCut = 32850
          end
          item
            Action = Action_DCList_Expand_All
            ImageIndex = 4
            ShortCut = 32837
          end
          item
            Action = Action_DCList_Collapse_All
            ImageIndex = 5
            ShortCut = 32835
          end>
        ActionBar = ActionToolBar_DC
      end
      item
        ChangesAllowed = []
        Items = <
          item
            ChangesAllowed = []
            Action = Action_AccList_Refresh
            ImageIndex = 3
            ShowCaption = False
            ShortCut = 116
          end
          item
            ChangesAllowed = []
            Caption = '-'
          end
          item
            ChangesAllowed = []
            Action = Action_CreateUser
            ImageIndex = 12
            ShowCaption = False
            ShortCut = 32813
          end
          item
            ChangesAllowed = []
            Caption = '-'
          end
          item
            ChangesAllowed = []
            Action = Action_ShowUsers
            ImageIndex = 9
            ShowCaption = False
          end
          item
            ChangesAllowed = []
            Action = Action_ShowGroups
            ImageIndex = 10
            ShowCaption = False
          end
          item
            ChangesAllowed = []
            Action = Action_ShowDC
            ImageIndex = 0
            ShowCaption = False
          end
          item
            ChangesAllowed = []
            Action = Action_ShowWorkstations
            ImageIndex = 11
            ShowCaption = False
          end
          item
            ChangesAllowed = []
            Caption = '-'
          end
          item
            ChangesAllowed = []
            Action = Action_Properties
            ImageIndex = 7
            ShowCaption = False
            ShortCut = 13
          end
          item
            ChangesAllowed = []
            Caption = '-'
          end
          item
            ChangesAllowed = []
            Items = <
              item
                ChangesAllowed = []
                Action = Action_Export_Access
                Caption = #1041#1072#1079#1072' '#1076#1072#1085#1085#1099#1093' &Microsoft Access'
                Default = True
              end
              item
                ChangesAllowed = []
                Action = Action_Export_Excel
                Caption = #1050#1085#1080#1075#1072' M&icrosoft Excel'
              end>
            Action = Action_Export_Access
            Caption = #1069#1082#1089#1087#1086#1088#1090
            ImageIndex = 13
            ShowCaption = False
          end
          item
            ChangesAllowed = []
            Action = Action_Settings
            ImageIndex = 6
            ShowCaption = False
          end>
        ActionBar = ActionToolBar_Acc
        AutoSize = False
      end>
    Images = DM1.ImageList_Main
    Left = 264
    Top = 464
    StyleName = 'Platform Default'
    object Action_DCList_Refresh: TAction
      Category = 'List_DC'
      Caption = #1054#1073#1085#1086#1074#1080#1090#1100
      Hint = #1054#1073#1085#1086#1074#1080#1090#1100' '#1089#1087#1080#1089#1086#1082' '#1082#1086#1085#1090#1088#1086#1083#1083#1077#1088#1086#1074' '#1076#1086#1084#1077#1085#1072
      ImageIndex = 8
      ShortCut = 32850
      OnExecute = Action_DCList_RefreshExecute
    end
    object Action_DCList_Expand_All: TAction
      Category = 'List_DC'
      Caption = #1056#1072#1079#1074#1077#1088#1085#1091#1090#1100' '#1074#1089#1077
      Hint = #1056#1072#1079#1074#1077#1088#1085#1091#1090#1100' '#1074#1089#1077' '#1082#1086#1085#1090#1077#1081#1085#1077#1088#1099
      ImageIndex = 4
      ShortCut = 32837
      OnExecute = Action_DCList_Expand_AllExecute
    end
    object Action_DCList_Collapse_All: TAction
      Category = 'List_DC'
      Caption = #1057#1074#1077#1088#1085#1091#1090#1100' '#1074#1089#1077
      Hint = #1057#1074#1077#1088#1085#1091#1090#1100' '#1074#1089#1077' '#1082#1086#1085#1090#1077#1081#1085#1077#1088#1099
      ImageIndex = 5
      ShortCut = 32835
      OnExecute = Action_DCList_Collapse_AllExecute
    end
    object Action_AccList_Refresh: TAction
      Category = 'List_Accounts'
      Caption = #1054#1073#1085#1086#1074#1080#1090#1100
      Hint = #1054#1073#1085#1086#1074#1080#1090#1100' '#1089#1087#1080#1089#1086#1082' '#1086#1073#1098#1077#1082#1090#1086#1074
      ImageIndex = 3
      ShortCut = 116
      OnExecute = Action_AccList_RefreshExecute
    end
    object Action_CreateUser: TAction
      Category = 'List_Accounts'
      Caption = #1057#1086#1079#1076#1072#1090#1100'...'
      Hint = #1057#1086#1079#1076#1072#1090#1100' '#1091#1095#1077#1090#1085#1091#1102' '#1079#1072#1087#1080#1089#1100' '#1087#1086#1083#1100#1079#1086#1074#1072#1090#1077#1083#1103
      ImageIndex = 12
      ShortCut = 32813
      OnExecute = Action_CreateUserExecute
    end
    object Action_ShowUsers: TAction
      Category = 'List_Accounts'
      AutoCheck = True
      Caption = #1055#1086#1083#1100#1079#1086#1074#1072#1090#1077#1083#1080
      Hint = #1055#1086#1082#1072#1079#1099#1074#1072#1090#1100' '#1087#1086#1083#1100#1079#1086#1074#1072#1090#1077#1083#1077#1081
      ImageIndex = 9
      OnExecute = Action_ShowUsersExecute
    end
    object Action_ShowGroups: TAction
      Category = 'List_Accounts'
      AutoCheck = True
      Caption = #1043#1088#1091#1087#1087#1099
      Hint = #1055#1086#1082#1072#1079#1099#1074#1072#1090#1100' '#1075#1088#1091#1087#1087#1099
      ImageIndex = 10
      OnExecute = Action_ShowGroupsExecute
    end
    object Action_ShowDC: TAction
      Category = 'List_Accounts'
      AutoCheck = True
      Caption = #1050#1086#1085#1090#1088#1086#1083#1083#1077#1088#1099' '#1076#1086#1084#1077#1085#1072
      Hint = #1055#1086#1082#1072#1079#1099#1074#1072#1090#1100' '#1082#1086#1085#1090#1088#1086#1083#1083#1077#1088#1099' '#1076#1086#1084#1077#1085#1072
      ImageIndex = 0
      OnExecute = Action_ShowDCExecute
    end
    object Action_ShowWorkstations: TAction
      Category = 'List_Accounts'
      AutoCheck = True
      Caption = #1056#1072#1073#1086#1095#1080#1077' '#1089#1090#1072#1085#1094#1080#1080
      Hint = #1055#1086#1082#1072#1079#1099#1074#1072#1090#1100' '#1088#1072#1073#1086#1095#1080#1077' '#1089#1090#1072#1085#1094#1080#1080
      ImageIndex = 11
      OnExecute = Action_ShowWorkstationsExecute
    end
    object Action_Properties: TAction
      Category = 'List_Accounts'
      Caption = #1057#1074#1086#1081#1089#1090#1074#1072
      Hint = #1057#1074#1086#1081#1089#1090#1074#1072
      ImageIndex = 7
      ShortCut = 13
      OnExecute = Action_PropertiesExecute
    end
    object Action_Export_Access: TAction
      Category = 'List_Accounts'
      Caption = #1041#1072#1079#1072' '#1076#1072#1085#1085#1099#1093' Microsoft Access'
      Hint = #1069#1082#1089#1087#1086#1088#1090
      ImageIndex = 14
      OnExecute = Action_Export_AccessExecute
    end
    object Action_Export_Excel: TAction
      Category = 'List_Accounts'
      Caption = #1050#1085#1080#1075#1072' Microsoft Excel'
      ImageIndex = 15
      OnExecute = Action_Export_ExcelExecute
    end
    object Action_Settings: TAction
      Category = 'List_Accounts'
      Caption = #1053#1072#1089#1090#1088#1086#1081#1082#1080
      Hint = #1053#1072#1089#1090#1088#1086#1081#1082#1080
      ImageIndex = 6
      OnExecute = Action_SettingsExecute
    end
  end
  object PopupMenu_ListAcc: TPopupMenu
    Images = DM1.ImageList_AccCtxMenu
    OnPopup = PopupMenu_ListAccPopup
    Left = 301
    Top = 464
    object ObjListRefresh: TMenuItem
      Action = Action_AccList_Refresh
    end
    object N6: TMenuItem
      Caption = '-'
    end
    object DameWare: TMenuItem
      Caption = 'DameWare'
      ImageIndex = 0
      object DMRC_Control: TMenuItem
        Caption = #1059#1087#1088#1072#1074#1083#1077#1085#1080#1077
        OnClick = DMRC_ControlClick
      end
      object DMRC_View: TMenuItem
        Caption = #1055#1088#1086#1089#1084#1086#1090#1088
        OnClick = DMRC_ViewClick
      end
      object N17: TMenuItem
        Caption = '-'
      end
      object DMRC_Custom: TMenuItem
        Caption = #1042#1099#1073#1086#1088#1086#1095#1085#1086'...'
        OnClick = DMRC_CustomClick
      end
    end
    object QuickMessage: TMenuItem
      Caption = #1041#1099#1089#1090#1088#1086#1077' '#1089#1086#1086#1073#1097#1077#1085#1080#1077'...'
      ImageIndex = 1
      OnClick = QuickMessageClick
    end
    object Ping: TMenuItem
      Caption = 'Ping'
      OnClick = PingClick
    end
    object N2: TMenuItem
      Caption = #1057#1074#1086#1081#1089#1090#1074#1072' '#1082#1086#1084#1087#1100#1102#1090#1077#1088#1072
      OnClick = N2Click
    end
    object ComputerManagement: TMenuItem
      Caption = #1059#1087#1088#1072#1074#1083#1077#1085#1080#1077' '#1082#1086#1084#1087#1100#1102#1090#1077#1088#1086#1084
      OnClick = ComputerManagementClick
    end
    object N10: TMenuItem
      Caption = '-'
    end
    object Object_Rename: TMenuItem
      Caption = #1055#1077#1088#1077#1080#1084#1077#1085#1086#1074#1072#1090#1100'...'
      OnClick = Object_RenameClick
    end
    object Object_Disable: TMenuItem
      Caption = #1054#1090#1082#1083#1102#1095#1080#1090#1100' '#1091#1095#1077#1090#1085#1091#1102' '#1079#1072#1087#1080#1089#1100
      OnClick = Object_DisableClick
    end
    object Object_PwdReset: TMenuItem
      Caption = #1057#1084#1077#1085#1072' '#1087#1072#1088#1086#1083#1103'...'
      OnClick = Object_PwdResetClick
    end
    object Object_Move: TMenuItem
      Caption = #1055#1077#1088#1077#1084#1077#1089#1090#1080#1090#1100'...'
      OnClick = Object_MoveClick
    end
    object Object_Delete: TMenuItem
      Caption = #1059#1076#1072#1083#1080#1090#1100
      ShortCut = 16430
      OnClick = Object_DeleteClick
    end
    object N15: TMenuItem
      Caption = '-'
    end
    object Object_Properties: TMenuItem
      Action = Action_Properties
      Default = True
    end
  end
end
