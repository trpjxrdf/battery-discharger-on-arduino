object Form1: TForm1
  Left = 248
  Top = 192
  Width = 928
  Height = 480
  Caption = 'Discharger'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -13
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 120
  TextHeight = 16
  object mmo1: TMemo
    Left = 0
    Top = 41
    Width = 920
    Height = 407
    Align = alClient
    ReadOnly = True
    ScrollBars = ssVertical
    TabOrder = 0
  end
  object pnl1: TPanel
    Left = 0
    Top = 0
    Width = 920
    Height = 41
    Align = alTop
    TabOrder = 1
    object cmld1: TComLed
      Left = 8
      Top = 8
      Width = 25
      Height = 25
      ComPort = cmprt1
      LedSignal = lsConn
      Kind = lkRedLight
    end
    object cbb1: TComComboBox
      Left = 40
      Top = 8
      Width = 145
      Height = 24
      ComPort = cmprt1
      ComProperty = cpPort
      AutoApply = True
      Text = 'COM11'
      Style = csDropDownList
      ItemHeight = 16
      ItemIndex = 0
      TabOrder = 0
    end
    object edt1: TEdit
      Left = 248
      Top = 8
      Width = 49
      Height = 24
      TabOrder = 1
      Text = '200'
      OnKeyPress = edt1KeyPress
    end
    object btn1: TButton
      Left = 296
      Top = 8
      Width = 75
      Height = 25
      Caption = #1055#1086#1089#1083#1072#1090#1100
      TabOrder = 2
      OnClick = btn1Click
    end
  end
  object cmprt1: TComPort
    BaudRate = br115200
    Port = 'COM11'
    Parity.Bits = prNone
    StopBits = sbOneStopBit
    DataBits = dbEight
    EventChar = #13
    Events = [evRxChar, evTxEmpty, evRxFlag, evRing, evBreak, evCTS, evDSR, evError, evRLSD, evRx80Full]
    FlowControl.OutCTSFlow = False
    FlowControl.OutDSRFlow = False
    FlowControl.ControlDTR = dtrEnable
    FlowControl.ControlRTS = rtsDisable
    FlowControl.XonXoffOut = False
    FlowControl.XonXoffIn = False
    OnAfterOpen = cmprt1AfterOpen
    OnRxChar = cmprt1RxChar
    Left = 40
    Top = 64
  end
  object tmr1: TTimer
    OnTimer = tmr1Timer
    Left = 80
    Top = 144
  end
end
