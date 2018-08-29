  !define APP_NAME "AD Commander"
  
  !define WND_CLASS "TADCmd_MainForm"
  !define PROG_ID "ADCommander.UCMA"
  !define CLASS_ID "{FB2CFC10-C1B2-30D5-A52B-48AC9B5E48E2}"
  !define TIMEOUT 3000
  !define SYNC_TERM 0x00100001
  
  !define MUI_ICON "AppIcon.ico"
  !define MUI_UNICON "AppIcon_uninstall.ico"
  !define MUI_WELCOMEFINISHPAGE_BITMAP "welcome_page.bmp"

;--------------------------------
;Include Modern UI

  !include "x64.nsh"
  !include "MUI2.nsh"
  !include "UAC.nsh"
  !include "WinVer.nsh"
  !include "FileFunc.nsh"
  !include "WinMessages.nsh"
  
;--------------------------------
;General
  Var StartMenuFolder
  
  !addplugindir ".\plugins\x86-ansi"
  BrandingText '© 2018, ОАО "Мозырский НПЗ"'
  
  ;Name and file
  Name "${APP_NAME}"
  
  !getdllversion "..\Win32\Release\adcmd.exe" v
  OutFile "adcommander_${v1}.${v2}.${v3}_32bit-64bit.exe"
  
  ;Default installation folder
  InstallDir "$PROGRAMFILES\${APP_NAME}"
  
  ;Get installation folder from registry if available
  InstallDirRegKey HKLM "Software\${APP_NAME}" "InstallPath"
  
  ShowInstDetails show

  ;Request application privileges for Windows Vista
  RequestExecutionLevel user
  
  !macro Init
    UAC_TryAgain:
    !insertmacro UAC_RunElevated
    ${Switch} $0
    ${Case} 0
        ${IfThen} $1 = 1 ${|} Quit ${|} ;we are the outer process, the inner process has done its work, we are done
        ${IfThen} $3 <> 0 ${|} ${Break} ${|} ;we are admin, let the show go on
        ${If} $1 = 3 ;RunAs completed successfully, but with a non-admin user
            MessageBox MB_YESNO|MB_ICONEXCLAMATION|MB_TOPMOST|MB_SETFOREGROUND "Для установки ${APP_NAME} необходимы права администратора. Попробуйте еще раз." /SD IDNO IDYES UAC_TryAgain IDNO 0
        ${EndIf}
        ;fall-through and die
    ${Case} 1223
    #    MessageBox MB_ICONSTOP|MB_TOPMOST|MB_SETFOREGROUND "Необходимы права администратора."
        Quit
    ${Case} 1062
        MessageBox MB_ICONSTOP|MB_TOPMOST|MB_SETFOREGROUND "Служба входа в систему не запущена. Операция отменена."
        Quit
    ${Default}
    #    MessageBox MB_ICONSTOP|MB_TOPMOST|MB_SETFOREGROUND "Невозможно повысить привилегии. Ошибка: $0"
        Quit
    ${EndSwitch}

    SetShellVarContext all
  !macroend
  
  !macro TerminateApp
    Push $0 ; window handle
    Push $1
    Push $2 ; process handle
    
    FindWindow $0 '${WND_CLASS}' ''
    IntCmp $0 0 FinishUp
    DetailPrint "Остановка приложения ${APP_NAME}"
    
    ${While} $0 <> 0
      System::Call 'user32.dll::GetWindowThreadProcessId(i r0, *i .r1) i .r2'
      System::Call 'kernel32.dll::OpenProcess(i ${SYNC_TERM}, i 0, i r1) i .r2'
      SendMessage $0 ${WM_CLOSE} 0 0 /TIMEOUT=${TIMEOUT}
      System::Call 'kernel32.dll::WaitForSingleObject(i r2, i ${TIMEOUT}) i .r1'
      IntCmp $1 0 close
      MessageBox MB_YESNOCANCEL|MB_ICONEXCLAMATION|MB_TOPMOST|MB_SETFOREGROUND "Программе установки не удалось закрыть приложение ${APP_NAME}.$\r$\nЗавершить процесс принудительно?" /SD IDYES IDYES terminate IDNO close
      System::Call 'kernel32.dll::CloseHandle(i r2) i .r1'
      Quit
      terminate:
        System::Call 'kernel32.dll::TerminateProcess(i r2, i 0) i .r1'
      close:
        System::Call 'kernel32.dll::CloseHandle(i r2) i .r1'
      
      FindWindow $0 '${WND_CLASS}' ''
    ${EndWhile}
    
    FinishUp:
      Pop $2
      Pop $1
      Pop $0
  !macroend
  
  Function .onInit
    ${IfNot} ${AtLeastWinVista}
      MessageBox MB_OK|MB_ICONEXCLAMATION "Для установки приложения необходима операционная система Windows версии 6.0 и выше."
      Quit
    ${EndIf}
    
    !insertmacro Init
    #Call CheckIfAlreadyInstalled
    ${If} ${RunningX64}
      ; change install dir
      ReadRegStr $INSTDIR HKLM "Software\${APP_NAME}" "InstallPath"
      ${If} $INSTDIR == ""
        StrCpy $INSTDIR "$PROGRAMFILES64\${APP_NAME}"
      ${EndIf} 
    ${EndIf}
  FunctionEnd
  
  Function un.onInit
    !insertmacro Init
  FunctionEnd
  
  Function CreateDesktopShortCut
    CreateShortCut "$DESKTOP\${APP_NAME}.lnk" "$INSTDIR\adcmd.exe"
    ${If} ${RunningX64}
       CreateShortCut "$DESKTOP\${APP_NAME} (64-bit).lnk" "$INSTDIR\adcmd64.exe"
    ${EndIf}
  FunctionEnd
  
  Function LaunchApp
    ${If} ${RunningX64}
       #ExecShell "" "$INSTDIR\adcmd64.exe"
       !insertmacro UAC_AsUser_ExecShell "" "$INSTDIR\adcmd64.exe" "" "" ""
    ${Else}
       #ExecShell "" "$INSTDIR\adcmd.exe"
       !insertmacro UAC_AsUser_ExecShell "" "$INSTDIR\adcmd.exe" "" "" ""
    ${EndIf}
  FunctionEnd
  
  Function CheckIfAlreadyInstalled
    ReadRegStr $R0 HKLM "SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\${APP_NAME}" "UninstallString"
    IfFileExists $R0 +1 NotInstalled
    MessageBox MB_YESNO|MB_ICONQUESTION|MB_TOPMOST|MB_SETFOREGROUND|MB_DEFBUTTON2 "Приложение ${APP_NAME} уже установлено на вашем компьютере.$\r$\nУдалить приложение?" /SD IDNO IDYES UninstallApp IDNO QuitInstallation
    
    UninstallApp:
      Exec $R0
      Quit
    
    QuitInstallation:
      Quit
    
    NotInstalled:
    
  FunctionEnd
  
  Function CheckDotNETInstallation
    Var /GLOBAL RequiredVersion
    Var /GLOBAL DotNETVersion
    Var /GLOBAL DotNETInstallPath
	Var /GLOBAL EXIT_CODE
    
    StrCpy $RequiredVersion "3.5"
    
    ReadRegStr $DotNETVersion HKLM "SOFTWARE\Microsoft\NET Framework Setup\NDP\v$RequiredVersion" "Version"
    ReadRegStr $DotNETInstallPath HKLM "SOFTWARE\Microsoft\NET Framework Setup\NDP\v$RequiredVersion" "InstallPath"
    StrCmp $DotNETInstallPath "" 0 AlreadyInstalled 
    IfFileExists "$EXEDIR\dotnetfx35.exe" DoLocalInstallation DoNetworkInstallation
    
    AlreadyInstalled:
      #DetailPrint "В системе установлен пакет Microsoft .NET Framework v$DotNETVersion"
      Goto Completed
      
    DoLocalInstallation:
      # .NET Framework found on the local disk. Use this copy
      DetailPrint "Установка Microsoft .NET Framework v$RequiredVersion..."
      ExecWait '"$EXEDIR\dotnetfx35.exe"' $EXIT_CODE
      Goto CheckRebootRequest
 
    DoNetworkInstallation:
      # Now, let's Download the .NET Framework
      DetailPrint "Загрузка Microsoft .NET Framework v$RequiredVersion..."
      NSISdl::download "https://download.microsoft.com/download/2/0/E/20E90413-712F-438C-988E-FDAA79A8AC3D/dotnetfx35.exe" "$TEMP\dotnetfx35.exe"
      Pop $R0 ;Get the return value
      StrCmp $R0 "success" Success 0
      StrCmp $R0 "cancel" Cancel Fail
      Success:
        DetailPrint "Установка Microsoft .NET Framework v$RequiredVersion..."
        ExecWait '"$TEMP\dotnetfx35.exe"' $EXIT_CODE
        Goto CheckRebootRequest
      Cancel:
        DetailPrint "Загрузка Microsoft .NET Framework v$RequiredVersion отменена пользователем"
        DetailPrint "Интеграция Skype for Business в приложение ${APP_NAME} будет недоступна"
        Goto Completed
      Fail:
        DetailPrint "Невозможно загрузить Microsoft .NET Framework v$RequiredVersion"
        DetailPrint "Ошибка загрузки: $R0"
        DetailPrint "Интеграция Skype for Business в приложение ${APP_NAME} будет недоступна"
        Goto Completed
 
    CheckRebootRequest:
      # $EXIT_CODE contains the return codes. 1641 and 3010 means a Reboot has been requested
      ${If} $EXIT_CODE = 1641
        ${OrIf} $EXIT_CODE = 3010
          SetRebootFlag true
      ${EndIf}
    
    Completed:
    
  FunctionEnd

;--------------------------------
;Interface Settings

  !define MUI_ABORTWARNING
  !define MUI_UNABORTWARNING

;--------------------------------
;Pages

  #!insertmacro MUI_PAGE_WELCOME
  !insertmacro MUI_PAGE_DIRECTORY
  !insertmacro MUI_PAGE_STARTMENU "Application" $StartMenuFolder
  !insertmacro MUI_PAGE_INSTFILES
    # These indented statements modify settings for MUI_PAGE_FINISH
    !define MUI_FINISHPAGE_NOAUTOCLOSE
    
    !define MUI_FINISHPAGE_SHOWREADME ""
    !define MUI_FINISHPAGE_SHOWREADME_NOTCHECKED
    !define MUI_FINISHPAGE_SHOWREADME_TEXT "Запустить ${APP_NAME}"
    !define MUI_FINISHPAGE_SHOWREADME_FUNCTION LaunchApp 
    
    !define MUI_FINISHPAGE_RUN
    !define MUI_FINISHPAGE_RUN_NOTCHECKED
    !define MUI_FINISHPAGE_RUN_TEXT "Создать ярлык на рабочем столе"
    !define MUI_FINISHPAGE_RUN_FUNCTION CreateDesktopShortCut
  !insertmacro MUI_PAGE_FINISH
  !insertmacro MUI_UNPAGE_CONFIRM
  !insertmacro MUI_UNPAGE_INSTFILES
  
;--------------------------------
;Languages
 
  !insertmacro MUI_LANGUAGE "Russian"
  !insertmacro MUI_LANGUAGE "English"
  
;--------------------------------
;Version Information
  !getdllversion "..\Win32\Release\adcmd.exe" v
  
  VIProductVersion "${v1}.${v2}.${v3}.${v4}"
  VIAddVersionKey /LANG=${LANG_ENGLISH} "ProductVersion" "${v1}.${v2}.${v3}.${v4}"
  VIAddVersionKey /LANG=${LANG_ENGLISH} "FileVersion" "${v1}.${v2}.${v3}.${v4}"
  
  VIAddVersionKey /LANG=${LANG_ENGLISH} "ProductName" "${APP_NAME}"
  VIAddVersionKey /LANG=${LANG_ENGLISH} "Comments" "Compiled by Alexander Zhigadlo"
  VIAddVersionKey /LANG=${LANG_ENGLISH} "CompanyName" "JSC Mozyr Oil Refinery"
  VIAddVersionKey /LANG=${LANG_ENGLISH} "LegalTrademarks" "Madlinx™"
  VIAddVersionKey /LANG=${LANG_ENGLISH} "LegalCopyright" "Copyright © 2018, JSC Mozyr Oil Refinery"
  VIAddVersionKey /LANG=${LANG_ENGLISH} "FileDescription" "${APP_NAME}"

;--------------------------------
;Installer Sections

Section "Install" SecInstall
  !insertmacro TerminateApp
  
  SetOutPath "$INSTDIR"
  
  ;ADD YOUR OWN FILES HERE...
  ${If} ${RunningX64}
    File "/oname=adcmd64.exe" "..\Win64\Release\adcmd.exe"
  ${EndIf}
  File "..\Win32\Release\adcmd.exe"
  File "..\Win32\Release\adcmd.uac.dll"
  File "..\Win32\Release\adcmd.ucma.dll"
  File "..\Win32\Release\Microsoft.Lync.Model.dll"
  File "..\Win32\Release\Microsoft.Office.Uc.dll"
 
  RegDLL "$INSTDIR\adcmd.uac.dll"
  
  ;Store installation folder
  WriteRegStr HKLM "Software\${APP_NAME}" "InstallPath" $INSTDIR
  
  ;Write the uninstall keys for Windows
  ${If} ${RunningX64}
    WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\AD Commander" "DisplayIcon" "$INSTDIR\adcmd64.exe"
    WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\AD Commander" "DisplayName" "${APP_NAME} (64-bit)"
  ${Else}
    WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\AD Commander" "DisplayIcon" "$INSTDIR\adcmd.exe"
    WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\AD Commander" "DisplayName" "${APP_NAME}"
  ${EndIf}
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\AD Commander" "InstallLocation" "$INSTDIR" 
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\AD Commander" "Publisher" "JSC Mozyr Oil Refinery"
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\AD Commander" "UninstallString" "$INSTDIR\Uninstall.exe"
  WriteRegDWORD HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\AD Commander" "NoModify" 1
  WriteRegDWORD HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\AD Commander" "NoRepair" 1
  
  ;Write the DisplayVersion
  !getdllversion "..\Win32\Release\adcmd.exe" v
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\AD Commander" "DisplayVersion" "${v1}.${v2}.${v3}.${v4}"
  
  ;Write the EstimatedSize
  ${GetSize} "$INSTDIR" "/S=0K" $0 $1 $2
  IntFmt $0 "0x%08X" $0
  WriteRegDWORD HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\AD Commander" "EstimatedSize" $0
  
  ;Create uninstaller
  WriteUninstaller "$INSTDIR\Uninstall.exe"

  ;Create shortcuts in Start Menu
  !insertmacro MUI_STARTMENU_WRITE_BEGIN "Application"
    CreateDirectory "$SMPROGRAMS\$StartMenuFolder"
    CreateShortCut "$SMPROGRAMS\$StartMenuFolder\${APP_NAME}.lnk" "$INSTDIR\adcmd.exe"
    ${If} ${RunningX64}
      CreateShortCut "$SMPROGRAMS\$StartMenuFolder\${APP_NAME} (64-bit).lnk" "$INSTDIR\adcmd64.exe"
    ${EndIf}
    CreateShortCut "$SMPROGRAMS\$StartMenuFolder\Uninstall.lnk" "$INSTDIR\Uninstall.exe"
  !insertmacro MUI_STARTMENU_WRITE_END
  
  Call CheckDotNETInstallation
SectionEnd

;--------------------------------
;Uninstaller Section

Section "Uninstall"
  !insertmacro MUI_STARTMENU_GETFOLDER "Application" $StartMenuFolder
  !insertmacro TerminateApp

  UnRegDLL "$INSTDIR\adcmd.uac.dll"  

  Delete "$DESKTOP\${APP_NAME}.lnk"
  Delete "$DESKTOP\${APP_NAME} (64-bit).lnk"
  Delete "$SMPROGRAMS\$StartMenuFolder\*.*"
  RMDir "$SMPROGRAMS\$StartMenuFolder"
  
  ;ADD YOUR OWN FILES HERE...
  Delete "$INSTDIR\adcmd*.*"
  Delete "$INSTDIR\Microsoft.Lync.Model.dll"
  Delete "$INSTDIR\Microsoft.Office.Uc.dll"
  Delete "$INSTDIR\Uninstall.exe"
  RMDir "$INSTDIR"

  ; Remove registry keys
  SetRegView 64
  DeleteRegKey HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\AD Commander"
  DeleteRegKey HKLM "Software\${APP_NAME}"
  DeleteRegKey HKCR "${PROG_ID}"
  DeleteRegKey HKCR "CLSID\${CLASS_ID}"
  
  SetRegView 32
  DeleteRegKey HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\AD Commander"
  DeleteRegKey HKLM "Software\${APP_NAME}"
  DeleteRegKey HKCR "${PROG_ID}"
  DeleteRegKey HKCR "CLSID\${CLASS_ID}"
SectionEnd