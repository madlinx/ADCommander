object Frame_Search: TFrame_Search
  Left = 0
  Top = 0
  Width = 250
  Height = 22
  TabOrder = 0
  OnResize = FrameResize
  DesignSize = (
    250
    22)
  object Panel_Search: TPanel
    Left = 0
    Top = 0
    Width = 250
    Height = 22
    Anchors = [akLeft, akRight]
    BevelOuter = bvNone
    Caption = 'Panel_Search'
    Color = clWindow
    Constraints.MaxHeight = 22
    Constraints.MinHeight = 22
    Ctl3D = True
    ParentBackground = False
    ParentCtl3D = False
    ShowCaption = False
    TabOrder = 0
    object Button_ClearPattern: TBitBtn
      Left = 162
      Top = 0
      Width = 18
      Height = 22
      Align = alRight
      Glyph.Data = {
        F6000000424DF600000000000000360000002800000008000000080000000100
        180000000000C0000000120B0000120B00000000000000000000FEFEFEB1B1B1
        FFFFFFFFFFFFFFFFFFFFFFFFB1B1B1FEFEFEB1B1B1707070A3A3A3FFFFFFFFFF
        FFA3A3A3707070B1B1B1FFFFFFA3A3A3707070A3A3A3A3A3A3707070A3A3A3FF
        FFFFFFFFFFFFFFFFA3A3A3707070707070A3A3A3FFFFFFFFFFFFFFFFFFFFFFFF
        A3A3A3707070707070A3A3A3FFFFFFFFFFFFFFFFFFA3A3A3707070A3A3A3A3A3
        A3707070A3A3A3FFFFFFB1B1B1707070A3A3A3FFFFFFFFFFFFA3A3A3707070B1
        B1B1FEFEFEB1B1B1FFFFFFFFFFFFFFFFFFFFFFFFB4B4B4FEFEFE}
      TabOrder = 1
      StyleElements = [seFont]
      OnClick = Button_ClearPatternClick
    end
    object ComboBox_SearchOption: TComboBox
      Left = 180
      Top = 0
      Width = 70
      Height = 22
      Align = alRight
      BevelKind = bkFlat
      Style = csOwnerDrawFixed
      Ctl3D = False
      ItemIndex = 0
      ParentCtl3D = False
      TabOrder = 2
      Text = #1042#1089#1077' '#1087#1086#1083#1103
      StyleElements = [seFont]
      OnDrawItem = ComboBox_SearchOptionDrawItem
      OnDropDown = ComboBox_SearchOptionDropDown
      OnSelect = ComboBox_SearchOptionSelect
      Items.Strings = (
        #1042#1089#1077' '#1087#1086#1083#1103
        #1048#1084#1103)
    end
    object Edit_SearchPattern: TEdit
      AlignWithMargins = True
      Left = 3
      Top = 4
      Width = 159
      Height = 15
      Margins.Top = 4
      Margins.Right = 0
      Align = alClient
      BorderStyle = bsNone
      Ctl3D = False
      ParentCtl3D = False
      TabOrder = 0
      TextHint = ' '#1055#1086#1080#1089#1082
      StyleElements = [seFont]
      OnChange = Edit_SearchPatternChange
    end
  end
end
