Option Explicit
Dim objShell, objArgs 
Dim ADsPath_LDAP, objUser_LDAP 
Dim ADsPath_WinNT, objUser_WinNT 
Dim UserAttr

On Error Resume Next

Set objArgs = WScript.Arguments
If objArgs.Count = 0 Then
  MsgBox "Не указан объект Active Directory (передан пустой параметр).", _
    vbCritical, "Active Directory Domain Services"
  WScript.Quit
End If

Set objShell = WScript.CreateObject("WScript.Shell")

ADsPath_LDAP = "LDAP://" & objArgs(0)
ADsPath_WinNT = ADsPath_LDAP2WinNT(ADsPath_LDAP)

Err.Number = 0
Set objUser_LDAP = GetObject(ADsPath_LDAP)
If Err.Number <> 0 Then
  MsgBox "Объект Active Directory не найден:" _
    & Chr(13) & Chr(10) & objArgs(0), vbCritical, "Active Directory Domain Services"
  WScript.Quit
End If

Set objUser_WinNT = GetObject(ADsPath_WinNt)

Err.Number = 0
UserAttr = objUser_LDAP.Get("msRTCSIP-PrimaryUserAddress")
If Err.Number <> 0 Then
  UserAttr =""
End If

If UserAttr <> "" Then
  MsgBox "Пользователь " & objUser_LDAP.CN & " уже зарегистрирован в Microsoft Lync.", _
    vbExclamation, "Active Directory Domain Services"
  WScript.Quit
End If

objShell.Run("powershell.exe Start-Transcript; Import-module 'C:\Program Files\Common Files\Microsoft Lync Server 2013\Modules\Lync\Lync.psd1'; Enable-csuser -Identity '" & objUser_LDAP.distinguishedName & "' -RegistrarPool 'lync01.npz.com' -SipAddressType Samaccountname -SipDomain 'npz.com'; Stop-Transcript")

Set objArgs = Nothing
Set objUser_LDAP = Nothing
Set objShell = Nothing

Function ADsPath_LDAP2WinNT(ByVal LDAPADsPath)
  Dim objUser
  Dim ResultStr

  On Error Resume Next

  Set objUser = GetObject(LDAPADsPath)
  If Err.Number <> 0 Then
    Exit Function
  End If

  ResultStr = Right(LDAPADsPath, Len(LDAPADsPath) - InStr(1, LDAPADsPath, "DC=", 1) + 1)
  ResultStr = Replace(ResultStr, ",", "", 1, -1, 1)
  ResultStr = Replace(ResultStr, "DC=", "", 1, 1, 1) 
  ResultStr = Replace(ResultStr, "DC=", ".", 1, -1, 1)  

  ADsPath_LDAP2WinNT = "WinNT://" & ResultStr & "/" & objUser.sAMAccountName
  Set objUser = Nothing
End Function




