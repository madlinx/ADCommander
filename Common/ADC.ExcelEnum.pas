unit ADC.ExcelEnum;

interface

uses
  System.SysUtils, System.RegularExpressions;

type
  TADCExportFormat = (
    efNone,
    efAccess,
    efAccess2007,
    efExcel,
    efExcel2007,
    efCommaSeparated
  );

  { -------------------------------------------------------------------------------------- }
  { КОНСТАНТЫ ИСПОЛЬЗУЕМЫЕ ПРИ ЭКСПОРТЕ В EXCEL                                            }
  { -------------------------------------------------------------------------------------- }
  { https://msdn.microsoft.com/en-us/library/microsoft.office.interop.excel.constants.aspx }
  { https://msdn.microsoft.com/en-us/library/bb259481(v=office.12).aspx                    }
  { -------------------------------------------------------------------------------------- }

const
  { Сохранить как: Формат документа }
  xlWorkbookDefault          = 51;     { Workbook default                          }
  xlExcel8                   = 56;     { Excel8 (Excel 97-2003)                    }
  xlCSVWindows               = 23;     { Windows CSV                               }

  { Добавить книгу... }
  xlWBATChart                = -4109;  { Chart                                     }
  xlWBATExcel4IntlMacroSheet = 4;      { Excel version 4 macro                     }
  xlWBATExcel4MacroSheet     = 3;      { Excel version 4 international macro       }
  xlWBATWorksheet            = -4167;  { Worksheet                                 }

  { Добавит в книгу... }
  xlChart                    = -4109;  { Chart                                     }
  xlDialogSheet              = -4116;  { Dialog sheet                              }
  xlExcel4IntlMacroSheet     = 4;      { Excel version 4 international macro sheet }
  xlExcel4MacroSheet         = 3;      { Excel version 4 macro sheet               }
  xlWorksheet                = -4167;  { Worksheet                                 }

  { Пересчет/обновления значений в ячейках с формулами }
  xlCalculationAutomatic     = -4105;  { Excel controls recalculation                               }
  xlCalculationManual        = -4135;  { Calculation is done when the user requests it              }
  xlCalculationSemiautomatic = 2;      { Excel controls recalculation but ignores changes in tables }

  { Смещение курсора }
  xlDown                     = -4121;
  xlToLeft                   = -4159;
  xlToRight                  = -4161;
  xlUp                       = -4162;

  { Выравнивание в ячейке }
  xlBottom                   = -4107;
  xlLeft                  	 = -4131;
  xlRight	                   = -4152;
  xlTop                   	 = -4160;
 	xlCenter                   = -4108;

  { Application.International Property                       }
  { Returns information about the current country/region and }
  { international settings. Read-only Variant.               }
  { https://docs.microsoft.com/en-us/office/vba/api/excel.xlapplicationinternational }
  xlDecimalSeparator         = 3;
  xlThousandsSeparator       = 4;
  xlCurrencyDigits           = 27;
  xlDateSeparator            = 17;
  xlDayCode                  = 21;
  xlMonthCode                = 20;
  xlYearCode                 = 19;
  xlTimeSeparator            = 18;
  xlHourCode                 = 22;
  xlMinuteCode               = 23;
  xlSecondCode               = 24;

  function xlGetNumberFormat(XLApp: Variant; ADecPlaces: SmallInt = -1): string;
  function xlGetDateFormat(XLApp: Variant; AFormat: string = 'dd.mm.yyyy'): string;
  function xlGetDateTimeFormat(XLApp: Variant; AFormat: string = 'dd.mm.yyyy hh:nn:ss'): string;

implementation

function xlGetNumberFormat(XLApp: VAriant; ADecPlaces: SmallInt = -1): string;
var
  dp: Byte;
begin
  if ADecPlaces < 0
    then dp := Byte(XLApp.International[xlCurrencyDigits])
    else dp := ADecPlaces;

  case dp of
    0: begin
      Result := Format('#%s##0', [
          XLApp.International[xlThousandsSeparator]
        ]
      );
    end;

    else begin
      Result := Format('#%s##0%s%s', [
          XLApp.International[xlThousandsSeparator],
          XLApp.International[xlDecimalSeparator],
          StringOfChar('0', dp)
        ]
      );
    end;
  end;
end;

function xlGetDateFormat(XLApp: Variant; AFormat: string = 'dd.mm.yyyy'): string;
var
  regEx: TRegEx;
  s: string;
begin
  s := AFormat;

  regEx := TRegEx.Create('[^dmy\-\/\.]', [roIgnoreCase]);
  s := regEx.Replace(s, '');

  regEx := TRegEx.Create('\.', [roIgnoreCase]);
  s := regEx.Replace(s, XLApp.International[xlDateSeparator]);

  regEx := TRegEx.Create('d', [roIgnoreCase]);
  s := regEx.Replace(s, XLApp.International[xlDayCode]);

  regEx := TRegEx.Create('m', [roIgnoreCase]);
  s := regEx.Replace(s, XLApp.International[xlMonthCode]);

  regEx := TRegEx.Create('y', [roIgnoreCase]);
  s := regEx.Replace(s, XLApp.International[xlYearCode]);

  Result := s;
end;

function xlGetDateTimeFormat(XLApp: Variant; AFormat: string = 'dd.mm.yyyy hh:nn:ss'): string;
var
  regEx: TRegEx;
  s: string;
begin
  s := AFormat;

  regEx := TRegEx.Create('[^dmyhns\s:\-\.\/]', [roIgnoreCase]);
  s := regEx.Replace(s, '');

  regEx := TRegEx.Create('[\.\/-]', [roIgnoreCase]);
  s := regEx.Replace(s, XLApp.International[xlDateSeparator]);

  regEx := TRegEx.Create('d', [roIgnoreCase]);
  s := regEx.Replace(s, XLApp.International[xlDayCode]);

  regEx := TRegEx.Create('m', [roIgnoreCase]);
  s := regEx.Replace(s, XLApp.International[xlMonthCode]);

  regEx := TRegEx.Create('y', [roIgnoreCase]);
  s := regEx.Replace(s, XLApp.International[xlYearCode]);

  regEx := TRegEx.Create(':', [roIgnoreCase]);
  s := regEx.Replace(s, XLApp.International[xlTimeSeparator]);

  regEx := TRegEx.Create('h', [roIgnoreCase]);
  s := regEx.Replace(s, XLApp.International[xlHourCode]);

  regEx := TRegEx.Create('n', [roIgnoreCase]);
  s := regEx.Replace(s, XLApp.International[xlMinuteCode]);

  regEx := TRegEx.Create('s', [roIgnoreCase]);
  s := regEx.Replace(s, XLApp.International[xlSecondCode]);

  Result := s;
end;

end.
