; German forum: http://robsite.de/php/pureboard/viewtopic.php?t=1378&highlight=
; Author: Manne
; Date: 16. June 2003 (updated on 26. July 2003)
; Modified By: lionel_om, alias b!g b@$s

Structure Reg
  TopKey.l
  KeyName.s
  KeyValue.s
EndStructure


;Global Reg_ListVal.s

; -------------------------
;-   Gestion des TopKey
; -------------------------

ProcedureDLL TopKeyToLong(s.s)
  s = UCase(s)
  Select s
    Case "HKEY_CLASSES_ROOT"
      ProcedureReturn #HKEY_CLASSES_ROOT
    Case "HKEY_CURRENT_USER"
      ProcedureReturn #HKEY_CURRENT_USER
    Case "HKEY_LOCAL_MACHINE"
      ProcedureReturn #HKEY_LOCAL_MACHINE
    Case "HKEY_USERS"
      ProcedureReturn #HKEY_USERS
    Case "HKEY_CURRENT_CONFIG"
      ProcedureReturn #HKEY_CURRENT_CONFIG
    Default
      ProcedureReturn 0
  EndSelect
EndProcedure



ProcedureDLL.s TopKeyToStr(s.l)
  Select s
    Case #HKEY_CLASSES_ROOT
      ProcedureReturn "HKEY_CLASSES_ROOT"
    Case #HKEY_CURRENT_USER
      ProcedureReturn "HKEY_CURRENT_USER"
    Case #HKEY_LOCAL_MACHINE
      ProcedureReturn "HKEY_LOCAL_MACHINE"
    Case #HKEY_USERS
      ProcedureReturn "HKEY_USERS"
    Case #HKEY_CURRENT_CONFIG
      ProcedureReturn "HKEY_CURRENT_CONFIG"
    Default
      ProcedureReturn ""
  EndSelect
EndProcedure



; -----------------------------
;-     Test si le type est bon
; -----------------------------
;Renvoi 'Vrai' si la valeur passée est bien un type de KeyValue

ProcedureDLL.l IsKeyValueType(type.l)

  Select type
    Case #REG_SZ
    Case #REG_DWORD
    Case #REG_BINARY
    Case #REG_MULTI_SZ
    Case #REG_EXPAND_SZ
    Default
      ProcedureReturn #False
  EndSelect
  ProcedureReturn #True

EndProcedure



; -------------------------
;-     Ini d une Key
; -------------------------

ProcedureDLL IniRegKey(*reg.Reg)
  If *reg
    *reg\TopKey   = 0
    *reg\KeyName  = ""
    *reg\KeyValue = ""
  EndIf
EndProcedure




; -------------------------
;- Convertion Str <--> Reg
; -------------------------


ProcedureDLL SplitRegKey(key$, *reg.Reg)
  Protected tmp$
  IniRegKey(*reg)
  
  key$ = Trim(key$)
  If Right(key$, 1) = "@"
    key$ = Left(key$, Len(key$)-1)
  EndIf
  
  tmp$ = StringField(key$, 1, "\")
  *reg\TopKey = TopKeyToLong(tmp$)
  
  If *reg\TopKey
    tmp$ = ReplaceString(key$, tmp$ +"\", "")
    *reg\KeyValue = StringField(tmp$, CountString(tmp$, "\")+1, "\")
    If Len(*reg\KeyValue)
      tmp$ = ReplaceString(tmp$, *reg\KeyValue, "")
    EndIf
    If Right(tmp$,1)="\"
      tmp$ = Left(tmp$, Len(tmp$)-1)
    EndIf
    *reg\KeyName = tmp$
  EndIf
EndProcedure



ProcedureDLL.s GlueRegKey(*reg.Reg)
  Protected key$

  If *reg
    key$ = TopKeyToStr(*reg\TopKey)
    If key$
      key$ + "\" + *reg\KeyName + *reg\KeyValue
      ProcedureReturn key$
    EndIf
  EndIf
  
  ProcedureReturn ""
EndProcedure




; -------------------------
;- Les GET pour un obj Reg
; -------------------------

ProcedureDLL.l GetTopKey(*reg.Reg)
  If *reg
    ProcedureReturn *reg\TopKey
  EndIf
EndProcedure


ProcedureDLL.s GetKeyName(*reg.Reg)
  If *reg
    ProcedureReturn *reg\KeyName
  EndIf
EndProcedure


ProcedureDLL.s GetKeyValue(*reg.Reg)
  If *reg
    ProcedureReturn *reg\KeyValue
  EndIf
EndProcedure


ProcedureDLL DebugRegKey(*reg.Reg)
  If *reg
    Debug *reg\TopKey
    Debug *reg\KeyName
    Debug *reg\KeyValue
  Else
    Debug "Adresse incorrecte"
  EndIf
EndProcedure



; -------------------------------------
;- Initialise le GetHandle et le hKey
; -------------------------------------

ProcedureDLL.l IniForQueryToRegKey(*reg.Reg, ComputerName.l, hKey.l, lhRemoteRegistry.l)
  Protected lReturnCode.l
  
  If Left(*reg\KeyName, 1) = "\" 
    *reg\KeyName = Right(*reg\KeyName, Len(*reg\KeyName) - 1) 
  EndIf

  If PeekS(ComputerName) = "" 
    ProcedureReturn RegOpenKeyEx_(*reg\TopKey, *reg\KeyName, 0, #KEY_ALL_ACCESS, hKey) 
  Else 
    lReturnCode = RegConnectRegistry_(PeekS(ComputerName), *reg\TopKey, lhRemoteRegistry) 
    ProcedureReturn RegOpenKeyEx_(PeekL(lhRemoteRegistry), *reg\KeyName, 0, #KEY_ALL_ACCESS, hKey) 
  EndIf
EndProcedure





; -------------------------------------
;- Recuperation de la valeur d une cle
; -------------------------------------


ProcedureDLL.s GetRegKeyStrValue(regKey.s, ComputerName.s = "")
  Protected reg.Reg
  Protected GetHandle.l, hKey.l, lpData.s, lpcbData.l
  Protected lType.l, lReturnCode.l, lhRemoteRegistry.l, GetValue.s 
  
  SplitRegKey(regKey, reg.Reg)
  GetHandle = IniForQueryToRegKey(reg, @ComputerName, @hKey, @lhRemoteRegistry)
  GetValue = ""
  
  If GetHandle = #ERROR_SUCCESS 
    lpcbData = 255
    lpData = Space(255)
      
    GetHandle = RegQueryValueEx_(hKey, reg\KeyValue, 0, @lType, @lpData, @lpcbData)
    Select lType 
      ; <-- String -->
      Case #REG_SZ 

        If GetHandle = 0 
          GetValue = Left(lpData, lpcbData - 1) 
        EndIf
      
      ; <-- Long -->
      Case #REG_DWORD 
        ;Debug "ok"
        If GetHandle = 0
          GetValue = lpData
        EndIf
          
    EndSelect 
  EndIf 
  RegCloseKey_(hKey)
  ;Debug "> " + GetValue
  ProcedureReturn GetValue
EndProcedure




ProcedureDLL.l GetRegKeyIntValue(regKey.s, ComputerName.s = "")
  ProcedureReturn Val(GetRegKeyStrValue(regKey, ComputerName))
EndProcedure






; -----------------------------------
;- Changement de la valeur d'une clé
; -----------------------------------


; Crée une valeur si la clé n'existe pas
; Renvoi #True en cas de succès,
;   faux si la clé spécifiée est incorrecte ou que le "dossier" n'existe pas
ProcedureDLL.l SetRegKeyValue(regKey.s, vValue.s, ComputerName.s = "")
  Protected reg.Reg
  Protected GetHandle.l, hKey.l, lpcbData.l, lType.l, lValue.l
  Protected lpData.s, lReturnCode.l, lhRemoteRegistry.l 
  
  SplitRegKey(regKey, reg.Reg)
  GetHandle = IniForQueryToRegKey(reg, @ComputerName, @hKey, @lhRemoteRegistry)
 
  If GetHandle = #ERROR_SUCCESS
    lpcbData = 255
    lpData = Space(255)

    GetHandle = RegQueryValueEx_(hKey, reg\KeyValue, 0, @lType, @lpData, @lpcbData)
    ;lpcbData = 255: lpData = Space(255) ; <-- Ci Bug enlever ce commentaire
    
    If IsKeyValueType(lType) = #False ; La clé n'existe pas
      If Str(Val(vValue)) = Trim(vValue)
        lType = #REG_DWORD
      Else
        lType = #REG_SZ
      EndIf
    EndIf
    
    Select lType
      ; <-- Long -->
      Case #REG_DWORD
        lValue = Val(vValue)
        RegSetValueEx_(hKey, reg\KeyValue, 0, #REG_DWORD, @lValue, 4)
      ; <-- String -->
      Case #REG_SZ
        RegSetValueEx_(hKey, reg\KeyValue, 0, #REG_SZ, @vValue, StringByteLength(vValue) + 1)
    EndSelect
      
    RegCloseKey_(hKey) 
    ProcedureReturn #True
  Else 
    RegCloseKey_(hKey) 
    ProcedureReturn #False
  EndIf
EndProcedure 





; ----------------------------------------
;- Renvoi la sous-cle a l indice specifie
; ----------------------------------------
; Les indices commences à 0

ProcedureDLL.s ListRegSubKey(regKey.s, Index.l, ComputerName.s = "") 
  Protected GetHandle.l, hKey.l, lpName.s, lpcbName.l, ListSubKey.s
  Protected lpftLastWriteTime.FILETIME, lReturnCode.l, lhRemoteRegistry.l
  Protected reg.Reg
  
  PathAddBackslash_(regKey)
  SplitRegKey(regKey, reg.Reg)
  GetHandle = IniForQueryToRegKey(reg, @ComputerName, @hKey, @lhRemoteRegistry)
  ListSubKey = ""
          
  If GetHandle = #ERROR_SUCCESS
    lpcbName = 255
    lpName = Space(255)
                
    GetHandle = RegEnumKeyEx_(hKey, Index, @lpName, @lpcbName, 0, 0, 0, @lpftLastWriteTime)
    If GetHandle = #ERROR_SUCCESS
      ListSubKey = Left(lpName, lpcbName)
    EndIf
  EndIf
  RegCloseKey_(hKey)
  ;Reg_ListVal = ListSubKey
  ProcedureReturn ListSubKey
EndProcedure




ProcedureDLL.l CountRegSubKey(regKey.s, ComputerName.s = "") 
  Protected i.l, s$
  i = 0
  s$ = ListRegSubKey(regKey, i, ComputerName)
  While s$ <> ""
    i + 1
    s$ = ListRegSubKey(regKey, i, ComputerName)
  Wend
  ProcedureReturn i
EndProcedure




; ------------------
;- Supprime une cle
; ------------------


ProcedureDLL.l DeleteRegKeyValue(regKey.s, ComputerName.s = "") 
  Protected GetHandle.l, hKey.l, lReturnCode.l, lhRemoteRegistry.l, DeleteValue.l
  Protected reg.Reg
  
  SplitRegKey(regKey, reg.Reg)
  GetHandle = IniForQueryToRegKey(reg, @ComputerName, @hKey, @lhRemoteRegistry) 

  If GetHandle = #ERROR_SUCCESS
    GetHandle = RegDeleteValue_(hKey, @reg\KeyValue)
    If GetHandle = #ERROR_SUCCESS
      DeleteValue = #True
    Else
      DeleteValue = #False
    EndIf
  EndIf
  RegCloseKey_(hKey)
  ProcedureReturn DeleteValue
EndProcedure 




; --------------------
;- Creation d une cle
; --------------------

ProcedureDLL.l CreateRegKey(regKey.s, ComputerName.s = "") 
  Protected hNewKey.l, lpSecurityAttributes.SECURITY_ATTRIBUTES 
  Protected GetHandle.l, lReturnCode.l, lhRemoteRegistry.l, CreateKey.l
  Protected reg.Reg
  
  PathAddBackslash_(regKey)
  SplitRegKey(regKey, reg.Reg)
  
  If Left(reg\KeyName, 1) = "\" 
    reg\KeyName = Right(reg\KeyName, Len(reg\KeyName) - 1) 
  EndIf 
  
  If ComputerName = "" 
    GetHandle = RegCreateKeyEx_(reg\TopKey, reg\KeyName, 0, 0, #REG_OPTION_NON_VOLATILE, #KEY_ALL_ACCESS, @lpSecurityAttributes, @hNewKey, @GetHandle) 
  Else 
    lReturnCode = RegConnectRegistry_(ComputerName, reg\TopKey, @lhRemoteRegistry) 
    GetHandle = RegCreateKeyEx_(lhRemoteRegistry, reg\KeyName, 0, 0, #REG_OPTION_NON_VOLATILE, #KEY_ALL_ACCESS, @lpSecurityAttributes, @hNewKey, @GetHandle) 
  EndIf 

  If GetHandle = #ERROR_SUCCESS 
    GetHandle = RegCloseKey_(hNewKey)
    CreateKey = #True
  Else 
    CreateKey = #False
  EndIf 
  ProcedureReturn CreateKey 
EndProcedure 




; ------------------
;- Supprime une cle
; ------------------


ProcedureDLL.l DeleteRegKey(regKey.s, ComputerName.s = "") 
  Protected GetHandle.l, lReturnCode.l, lhRemoteRegistry.l, DeleteKey.l
  Protected reg.Reg
  
  PathAddBackslash_(regKey)
  SplitRegKey(regKey, reg.Reg)
  
  If Left(reg\KeyName, 1) = "\" 
    reg\KeyName = Right(reg\KeyName, Len(reg\KeyName) - 1) 
  EndIf 
    
  If ComputerName = ""
    GetHandle = RegDeleteKey_(reg\TopKey, reg\KeyName) 
  Else 
    lReturnCode = RegConnectRegistry_(ComputerName, reg\TopKey, @lhRemoteRegistry) 
    GetHandle = RegDeleteKey_(lhRemoteRegistry, reg\KeyName) 
  EndIf 

  If GetHandle = #ERROR_SUCCESS 
    DeleteKey = #True 
  Else 
    DeleteKey = #False 
  EndIf 
  ProcedureReturn DeleteKey 
EndProcedure 








; -------------------------------------------------
;- Renvoi les valeurs des cles a l indice specifie
; -------------------------------------------------
; Les indices commences à 0

ProcedureDLL.s ListRegSubValue(regKey.s, Index.l, ComputerName.s = "") 
  Protected GetHandle.l, hKey.l, dwIndex.l, lpName.s, lpcbName.l, ListSubValue.s
  Protected lhRemoteRegistry.l, lReturnCode.l, lpftLastWriteTime.FILETIME 
  Protected reg.Reg
  
  PathAddBackslash_(regKey)
  SplitRegKey(regKey, reg.Reg)
  GetHandle = IniForQueryToRegKey(reg, @ComputerName, @hKey, @lhRemoteRegistry)

  If GetHandle = #ERROR_SUCCESS
    lpcbName = 255
    lpName = Space(255)
    
    GetHandle = RegEnumValue_(hKey, Index, @lpName, @lpcbName, 0, 0, 0, 0)

    If GetHandle = #ERROR_SUCCESS
      ListSubValue = Left(lpName, lpcbName)
    Else
      ListSubValue = ""
    EndIf
    RegCloseKey_(hKey)
  EndIf
  ;Reg_ListVal = ListSubValue
  ProcedureReturn ListSubValue
EndProcedure



ProcedureDLL.l CountRegSubValue(regKey.s, ComputerName.s = "") 
  Protected i.l, s$
  i = 0
  s$ = ListRegSubValue(regKey, i, ComputerName)
  While s$ <> ""
    i + 1
    s$ = ListRegSubValue(regKey, i, ComputerName)
  Wend
  ProcedureReturn i
EndProcedure






; --------------------------------------------
;- Test l existance d une cle ou d une valeur
; --------------------------------------------


ProcedureDLL.l IsRegKey(regKey.s, ComputerName.s = "") 
  Protected hKey.l, lhRemoteRegistry.l, lReturnCode.l, KeyExists.b
  Protected reg.Reg
  
  PathAddBackslash_(regKey)
  SplitRegKey(regKey, reg.Reg)
    
  If IniForQueryToRegKey(reg, @ComputerName, @hKey, @lhRemoteRegistry) = #ERROR_SUCCESS
    KeyExists = #True
  Else
    KeyExists = #False
  EndIf
  
  RegCloseKey_(hKey)
  ProcedureReturn KeyExists
EndProcedure





ProcedureDLL.l IsSubValue(regKey.s, ComputerName.s = "") 
  Protected hKey.l, lhRemoteRegistry.l, lReturnCode.l, KeyExists.b
  Protected GetHandle.l, lpcbData.l, lpData.s, lType.l
  Protected reg.Reg
  
  SplitRegKey(regKey, reg.Reg)
  
  GetHandle = IniForQueryToRegKey(reg, @ComputerName, @hKey, @lhRemoteRegistry)
  
  If GetHandle = #ERROR_SUCCESS 
    lpcbData = 255
    lpData = Space(255)
      
    GetHandle = RegQueryValueEx_(hKey, reg\KeyValue, 0, @lType, @lpData, @lpcbData)
    If IsKeyValueType(lType) = #False
      lType = #False
    EndIf
  Else
    lType = #False
  EndIf
  
  RegCloseKey_(hKey)
  ProcedureReturn lType
EndProcedure



; IDE Options = PureBasic 4.10 Beta 4 (Windows - x86)
; CursorPosition = 71
; FirstLine = 45

; jaPBe Version=3.7.11.672
; Build=0
; FirstLine=523
; CursorPosition=532
; ExecutableFormat=Windows
; DontSaveDeclare
; EOF

; IDE Options = PureBasic 4.30 (Windows - x86)
; CursorPosition = 247
; FirstLine = 220
; Folding = ----