object Form_Container: TForm_Container
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu]
  Caption = #1050#1086#1085#1090#1077#1081#1085#1077#1088' Active Directory'
  ClientHeight = 431
  ClientWidth = 384
  Color = clBtnFace
  Constraints.MinHeight = 470
  Constraints.MinWidth = 400
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
    384
    431)
  PixelsPerInch = 96
  TextHeight = 13
  object Label_Description: TLabel
    Left = 16
    Top = 14
    Width = 352
    Height = 25
    Anchors = [akLeft, akTop, akRight]
    AutoSize = False
    Caption = #1042#1099#1073#1077#1088#1080#1090#1077' '#1082#1086#1085#1090#1077#1081#1085#1077#1088' Active Directory.'
    WordWrap = True
    ExplicitWidth = 353
  end
  object TreeView_Containers: TTreeView
    Left = 16
    Top = 56
    Width = 352
    Height = 327
    Anchors = [akLeft, akTop, akRight, akBottom]
    HideSelection = False
    Images = DM1.ImageList_Main
    Indent = 19
    ReadOnly = True
    RowSelect = True
    TabOrder = 0
    OnChange = TreeView_ContainersChange
    OnDeletion = TreeView_ContainersDeletion
  end
  object Button_Cancel: TButton
    Left = 293
    Top = 395
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = #1054#1090#1084#1077#1085#1072
    TabOrder = 1
    OnClick = Button_CancelClick
  end
  object Button_OK: TButton
    Left = 212
    Top = 395
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = 'OK'
    Enabled = False
    TabOrder = 2
    OnClick = Button_OKClick
  end
end
