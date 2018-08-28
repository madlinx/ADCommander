SETLOCAL
SET regasm="c:\Windows\Microsoft.NET\Framework\v2.0.50727\RegAsm.exe"
SET dll="d:\Projects\ADCommander\UCMA.Source\adcmd.ucma_vs2008\adcmd.ucma\bin\Release\adcmd.ucma.dll"

%regasm% %dll%
%regasm% %dll% /regfile: "%~dp0%adcmd.ucma.reg"
%regasm% %dll% /tlb: "%~dp0%adcmd.ucma.tlb"