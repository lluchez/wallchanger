

; ---------------- Structures ---------------


Structure Color
  Name.s
  Value.l
EndStructure


Structure Configuration
  Delay.l
  AutoStart.l
  DisplayMode.l
  CurrentGroup.l
  CurrentColor.l
  *Groups.Vector
EndStructure


Structure Group
  Name.s
  Path.s
  *Ban.Vector
EndStructure





; --------------  Vector Color  --------------


Procedure Color_Constructor(*src.Color)
  Protected *dst.Color
  
  *dst = Vector__Allocate(SizeOf(Color))
  If *src
    *dst\Name = *src\Name
    *dst\Value = *src\Value
  EndIf
  ProcedureReturn *dst
EndProcedure 

Procedure Color_Destructor(*Color.Color)
EndProcedure

Procedure Color_Comparator(*obj1.Color, Color.l)
  If *obj1\Value = Color
    ProcedureReturn #Vector_Compare_Equal
  ElseIf *obj1\Value < Color
    ProcedureReturn #Vector_Compare_Less
  Else
    ProcedureReturn #Vector_Compare_More
  EndIf
EndProcedure


Procedure FillColorVector(*vector)
  Protected Color.Color
  Restore Colors
  Repeat
    Read.l Color\Value
    If Color\Value = $FFFFFFFF
      Break
    Else
      Read.s Color\Name
      Vector_AddElement(*vector, Color)
    EndIf
  ForEver
EndProcedure



; --------------  Vector Group  --------------


Procedure Group_Constructor(*src.Group)
  Protected *dst.Group
  
  *dst = Vector__Allocate(SizeOf(Group))
  If *src
    *dst\Name = *src\Name
    *dst\Path = *src\Path
    If *src\Ban
      *dst\Ban = Vector_Copy(*src\Ban)
    Else
      *dst\Ban = Vector_Create(#String)
    EndIf
  Else
    *dst\Ban = Vector_Create(#String)
  EndIf
  ProcedureReturn *dst
EndProcedure

Procedure Group_ConstructorFromXML(*NodeXML.l)
  Protected *Group.Group, *BanNode, ban$
  
  *Group = Vector__Allocate(SizeOf(Group))
  *Group\Ban = Vector_Create(#String)
  If *NodeXML
    *Group\Name = GetXMLAttribute(*NodeXML, "name")
    *Group\Path = GetXMLAttribute(*NodeXML, "url")
    If (Not(IsAbsolutePath(*Group\Path))) And *Group\Path
      *Group\Path = GetCurrentDirectory() + *Group\Path
    EndIf
    If FileSize(*Group\Path) = -2
      *Group\Path = NormalizeFolder(*Group\Path)
    EndIf
    *BanNode   = XMLNodeFromPath(*NodeXML, "ban/")
    While *BanNode And GetXMLNodeName(*BanNode) = "ban"
      ban$ = GetXMLNodeText(*BanNode)
      ;Debug ">> " + ban$
      If Not(IsAbsolutePath(ban$))
        If GetExtensionPart(*Group\Path)
          ban$ = GetPathPart(*Group\Path) + ban$
        Else
          ban$ = NormalizeFolder(*Group\Path) + ban$
        EndIf
      EndIf
      ;Debug ">> " + ban$
      Vector_AddElement(*Group\Ban, @ban$)
      *BanNode = NextXMLNode(*BanNode)
    Wend
  EndIf
  ProcedureReturn *Group
EndProcedure

Procedure Group_Destructor(*Group.Group)
  Vector_Free(*Group\Ban)
EndProcedure

Procedure Group_Comparator(*obj1.Group, *obj2.Group)
  If *obj1\Name = *obj2\Name
    ProcedureReturn #Vector_Compare_Equal
  ElseIf *obj1\Name < *obj2\Name
    ProcedureReturn #Vector_Compare_Less
  Else
    ProcedureReturn #Vector_Compare_More
  EndIf
EndProcedure

Procedure Group_Search(*Groups.Vector, Name.s)
  Protected Group.Group, Index.l
  
  Group\Name = Name
  If Vector_Search(*Groups, Group, @Index)
    ProcedureReturn Vector_GetElement(*Groups, Index)
  EndIf
EndProcedure



; --------------  Vector Groups  --------------


Procedure Groups_Save(*src.Configuration, *Dest.Configuration)
  *Dest\Delay        = *src\Delay
  *Dest\DisplayMode  = *src\DisplayMode
  *Dest\CurrentGroup = *src\CurrentGroup
  *Dest\CurrentColor = *src\CurrentColor
  *Dest\AutoStart    = *src\AutoStart
  
  If *Dest\Groups
    Vector_Clear(*Dest\Groups)
  EndIf
  Vector_Reset(*src\Groups)
  While Vector_Next(*src\Groups)
    Vector_Add(*Dest\Groups, Vector_GetElement(*src\Groups))
  Wend
EndProcedure

Procedure Groups_Restore(*src.Configuration, *Dest.Configuration)
  Protected *cstGrp;, *cstCol
  
    *cstGrp = Vector_GetConstructorFunction(*Dest\Groups)
    Vector_SetConstructorFunction(*Dest\Groups, Vector_GetConstructorFunction(*src\Groups))
    Groups_Save(*src, *Dest)
    Vector_SetConstructorFunction(*Dest\Groups, *cstGrp)
EndProcedure




;{ - Data Colors -
DataSection
Colors:
  ;Data.l $FFFFFFFF
  Data.l $FFF8F0: Data.s "AliceBlue"
  Data.l $D7EBFA: Data.s "AntiqueWhite"
  Data.l $FFFF00: Data.s "Aqua"
  Data.l $D4FF7F: Data.s "Aquamarine"
  Data.l $FFFFF0: Data.s "Azure"
  Data.l $DCF5F5: Data.s "Beige"
  Data.l $C4E4FF: Data.s "Bisque"
  Data.l $000000: Data.s "Black"
  Data.l $CDEBFF: Data.s "BlanchedAlmond"
  Data.l $FF0000: Data.s "Blue"
  Data.l $E22B8A: Data.s "BlueViolet"
  Data.l $2A2AA5: Data.s "Brown"
  Data.l $87B8DE: Data.s "BurlyWood"
  Data.l $A09E5F: Data.s "CadetBlue"
  Data.l $00FF7F: Data.s "Chartreuse"
  Data.l $1E69D2: Data.s "Chocolate"
  Data.l $507FFF: Data.s "Coral"
  Data.l $ED9564: Data.s "CornflowerBlue"
  Data.l $DCF8FF: Data.s "Cornsilk"
  Data.l $3C14DC: Data.s "Crimson"
  Data.l $FFFF00: Data.s "Cyan"
  Data.l $8B0000: Data.s "DarkBlue"
  Data.l $8B8B00: Data.s "DarkCyan"
  Data.l $0B86B8: Data.s "DarkGoldenRod"
  Data.l $A9A9A9: Data.s "DarkGray"
  Data.l $A9A9A9: Data.s "DarkGrey"
  Data.l $006400: Data.s "DarkGreen"
  Data.l $6BB7BD: Data.s "DarkKhaki"
  Data.l $8B008B: Data.s "DarkMagenta"
  Data.l $2F6B55: Data.s "DarkOliveGreen"
  Data.l $008CFF: Data.s "Darkorange"
  Data.l $CC3299: Data.s "DarkOrchid"
  Data.l $00008B: Data.s "DarkRed"
  Data.l $7A96E9: Data.s "DarkSalmon"
  Data.l $8FBC8F: Data.s "DarkSeaGreen"
  Data.l $8B3D48: Data.s "DarkSlateBlue"
  Data.l $4F4F2F: Data.s "DarkSlateGray"
  Data.l $4F4F2F: Data.s "DarkSlateGrey"
  Data.l $D1CE00: Data.s "DarkTurquoise"
  Data.l $D30094: Data.s "DarkViolet"
  Data.l $9314FF: Data.s "DeepPink"
  Data.l $FFBF00: Data.s "DeepSkyBlue"
  Data.l $696969: Data.s "DimGray"
  Data.l $696969: Data.s "DimGrey"
  Data.l $FF901E: Data.s "DodgerBlue"
  Data.l $2222B2: Data.s "FireBrick"
  Data.l $F0FAFF: Data.s "FloralWhite"
  Data.l $228B22: Data.s "ForestGreen"
  Data.l $FF00FF: Data.s "Fuchsia"
  Data.l $DCDCDC: Data.s "Gainsboro"
  Data.l $FFF8F8: Data.s "GhostWhite"
  Data.l $00D7FF: Data.s "Gold"
  Data.l $20A5DA: Data.s "GoldenRod"
  Data.l $808080: Data.s "Gray"
  Data.l $808080: Data.s "Grey"
  Data.l $008000: Data.s "Green"
  Data.l $2FFFAD: Data.s "GreenYellow"
  Data.l $F0FFF0: Data.s "HoneyDew"
  Data.l $B469FF: Data.s "HotPink"
  Data.l $5C5CCD: Data.s "IndianRed"
  Data.l $82004B: Data.s "Indigo"
  Data.l $F0FFFF: Data.s "Ivory"
  Data.l $8CE6F0: Data.s "Khaki"
  Data.l $FAE6E6: Data.s "Lavender"
  Data.l $F5F0FF: Data.s "LavenderBlush"
  Data.l $00FC7C: Data.s "LawnGreen"
  Data.l $CDFAFF: Data.s "LemonChiffon"
  Data.l $E6D8AD: Data.s "LightBlue"
  Data.l $8080F0: Data.s "LightCoral"
  Data.l $FFFFE0: Data.s "LightCyan"
  Data.l $D2FAFA: Data.s "LightGoldenRodYellow"
  Data.l $D3D3D3: Data.s "LightGray"
  Data.l $D3D3D3: Data.s "LightGrey"
  Data.l $90EE90: Data.s "LightGreen"
  Data.l $C1B6FF: Data.s "LightPink"
  Data.l $7AA0FF: Data.s "LightSalmon"
  Data.l $AAB220: Data.s "LightSeaGreen"
  Data.l $FACE87: Data.s "LightSkyBlue"
  Data.l $998877: Data.s "LightSlateGray"
  Data.l $998877: Data.s "LightSlateGrey"
  Data.l $DEC4B0: Data.s "LightSteelBlue"
  Data.l $E0FFFF: Data.s "LightYellow"
  Data.l $00FF00: Data.s "Lime"
  Data.l $32CD32: Data.s "LimeGreen"
  Data.l $E6F0FA: Data.s "Linen"
  Data.l $FF00FF: Data.s "Magenta"
  Data.l $000080: Data.s "Maroon"
  Data.l $AACD66: Data.s "MediumAquaMarine"
  Data.l $CD0000: Data.s "MediumBlue"
  Data.l $D355BA: Data.s "MediumOrchid"
  Data.l $D87093: Data.s "MediumPurple"
  Data.l $71B33C: Data.s "MediumSeaGreen"
  Data.l $EE687B: Data.s "MediumSlateBlue"
  Data.l $9AFA00: Data.s "MediumSpringGreen"
  Data.l $CCD148: Data.s "MediumTurquoise"
  Data.l $8515C7: Data.s "MediumVioletRed"
  Data.l $701919: Data.s "MidnightBlue"
  Data.l $FAFFF5: Data.s "MintCream"
  Data.l $E1E4FF: Data.s "MistyRose"
  Data.l $B5E4FF: Data.s "Moccasin"
  Data.l $ADDEFF: Data.s "NavajoWhite"
  Data.l $800000: Data.s "Navy"
  Data.l $E6F5FD: Data.s "OldLace"
  Data.l $008080: Data.s "Olive"
  Data.l $238E6B: Data.s "OliveDrab"
  Data.l $00A5FF: Data.s "Orange"
  Data.l $0045FF: Data.s "OrangeRed"
  Data.l $D670DA: Data.s "Orchid"
  Data.l $AAE8EE: Data.s "PaleGoldenRod"
  Data.l $98FB98: Data.s "PaleGreen"
  Data.l $EEEEAF: Data.s "PaleTurquoise"
  Data.l $9370D8: Data.s "PaleVioletRed"
  Data.l $D5EFFF: Data.s "PapayaWhip"
  Data.l $B9DAFF: Data.s "PeachPuff"
  Data.l $3F85CD: Data.s "Peru"
  Data.l $CBC0FF: Data.s "Pink"
  Data.l $DDA0DD: Data.s "Plum"
  Data.l $E6E0B0: Data.s "PowderBlue"
  Data.l $800080: Data.s "Purple"
  Data.l $0000FF: Data.s "Red"
  Data.l $8F8FBC: Data.s "RosyBrown"
  Data.l $E16941: Data.s "RoyalBlue"
  Data.l $13458B: Data.s "SaddleBrown"
  Data.l $7280FA: Data.s "Salmon"
  Data.l $60A4F4: Data.s "SandyBrown"
  Data.l $578B2E: Data.s "SeaGreen"
  Data.l $EEF5FF: Data.s "SeaShell"
  Data.l $2D52A0: Data.s "Sienna"
  Data.l $C0C0C0: Data.s "Silver"
  Data.l $EBCE87: Data.s "SkyBlue"
  Data.l $CD5A6A: Data.s "SlateBlue"
  Data.l $908070: Data.s "SlateGray"
  Data.l $908070: Data.s "SlateGrey"
  Data.l $FAFAFF: Data.s "Snow"
  Data.l $7FFF00: Data.s "SpringGreen"
  Data.l $B48246: Data.s "SteelBlue"
  Data.l $8CB4D2: Data.s "Tan"
  Data.l $808000: Data.s "Teal"
  Data.l $D8BFD8: Data.s "Thistle"
  Data.l $4763FF: Data.s "Tomato"
  Data.l $D0E040: Data.s "Turquoise"
  Data.l $EE82EE: Data.s "Violet"
  Data.l $B3DEF5: Data.s "Wheat"
  Data.l $FFFFFF: Data.s "White"
  Data.l $F5F5F5: Data.s "WhiteSmoke"
  Data.l $00FFFF: Data.s "Yellow"
  Data.l $32CD9A: Data.s "YellowGreen"
  Data.l $FFFFFFFF

EndDataSection
;}



 
; jaPBe Version=3.8.3.696
; FoldLines=00050008001500190022002B002D002E00300038004E005E0060007F00810083
; FoldLines=0085008D008F0096009D00AB00AD00B4
; Build=0
; FirstLine=20
; CursorPosition=66
; ExecutableFormat=Windows
; DontSaveDeclare
; EOF