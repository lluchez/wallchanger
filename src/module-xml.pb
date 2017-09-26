
#ENC_TYPE = #PB_UTF8

Macro WriteString_(string, tab = 0)
  WriteStringN(hFile,RSet("", tab, Chr(9))+ReplaceString(string, "'", Chr(34)), #ENC_TYPE)
EndMacro


Macro WriteStringGroup(Name, url, tab = 0)
  WriteStringN(hFile,RSet("", tab, Chr(9))+"<group name="+Chr(34)+Name+Chr(34)+" url="+Chr(34)+url+Chr(34)+">", #ENC_TYPE)
EndMacro



Procedure XMLNodeFromPathSafe(*NodeXML, Path$, Exit=#True)
  Protected *NewNode
  *NewNode = XMLNodeFromPath(*NodeXML, Path$)
  If *NewNode = #Null And Exit
    Alert("This node doesn't exist : '"+Path$+"'")
    End
  EndIf
  ProcedureReturn *NewNode
EndProcedure



Procedure.s GetRelativeXMLNodeText_Safe(*node, Path$)
  *node = XMLNodeFromPathSafe(*node, Path$)
  ProcedureReturn GetXMLNodeText(*node)
EndProcedure




Procedure LoadConfXML()
  Protected hXML.l, *mainNode, *confNode, *groupsNode, *groupNode
  Protected *colorsNode;, *colorNode, black.Color
  
  Conf\Delay = #PrefDelay
  hXML = LoadXML(#PB_Any, #XML_FILE)
  If hXML
    *mainNode = MainXMLNode(hXML)
    If *mainNode
      *confNode = XMLNodeFromPathSafe(*mainNode, "configuration/")
      If *confNode
        Conf\Delay         = Val(GetRelativeXMLNodeText(*confNode, "delay/"))
        Conf\AutoStart     = Val(GetRelativeXMLNodeText(*confNode, "startup/"))
        Conf\DisplayMode   = Val(GetRelativeXMLNodeText(*confNode, "display/"))
        If Conf\DisplayMode = #Null 
          Conf\DisplayMode = #WP_Format_Maximize
        EndIf
        Conf\CurrentGroup = Val(GetRelativeXMLNodeText(*confNode, "current-group/"))
        Conf\CurrentColor = Val(GetRelativeXMLNodeText(*confNode, "current-color/"))
        
        *groupsNode = XMLNodeFromPathSafe(*confNode, "groups/")
        *groupNode = XMLNodeFromPath(*groupsNode, "group")
        If *groupNode
          While *groupNode And GetXMLNodeName(*groupNode) = "group"
            Vector_AddElement(Conf\Groups, *groupNode)
            *groupNode = NextXMLNode(*groupNode)
          Wend
        EndIf
      EndIf
    Else
      Warning("Invalid configuration file !")
    EndIf
    FreeXML(hXML)
  ElseIf FileSize(#XML_FILE) > 0
    Warning("Couldn't load configuration file !")
  Else
    Warning("The configuration file was not found !"+#CRLF$+"An empty file will be created.")
  EndIf
EndProcedure



Procedure SaveConfXML()
  Protected hFile.l, *Group.Group, *Color.Color, *Ban.String
  
  hFile = CreateFile(#PB_Any, #XML_FILE)
  If hFile
    WriteString_("<?xml version='1.0' encoding='"+#XML_Encodage+"' standalone='yes'?>")
    WriteString_("<parameters version='"+#VERSION+"'>")
    WriteString_("<configuration>", 1)
    WriteString_("<delay>"+Str(Conf\Delay)+"</delay>", 2)
    WriteString_("<startup>"+Str(Conf\AutoStart)+"</startup>", 2)
    WriteString_("<display>"+Str(Conf\DisplayMode)+"</display>", 2)
    WriteString_("<current-group>"+Str(Conf\CurrentGroup)+"</current-group>", 2)
    WriteString_("<current-color>"+Str(Conf\CurrentColor)+"</current-color>", 2)
    
    ; ---------------- groups ----------------
    WriteString_("", 2)
    WriteString_("<groups>", 2)
    Vector_Reset(Conf\Groups)
    While Vector_NextElement(Conf\Groups)
      *Group = Vector_GetElement(Conf\Groups)
      ;Debug *Group\Path
      WriteStringGroup(*Group\Name, *Group\Path, 3)
      Vector_Reset(*Group\Ban)
      While Vector_NextElement(*Group\Ban)
        *Ban = Vector_GetElement(*Group\Ban)
        WriteString_("<ban>"+*Ban\s+"</ban>", 4)
      Wend
      WriteString_("</group>", 3)
    Wend
    WriteString_("</groups>", 2)
    
    WriteString_("</configuration>", 1)
    WriteString_("</parameters>")
    CloseFile(hFile)
  Else
    Alert("Can't save configuration !", #False)
  EndIf
EndProcedure




; IDE Options = PureBasic 4.30 (Windows - x86)
; CursorPosition = 113
; FirstLine = 77
; Folding = --