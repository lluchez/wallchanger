
Procedure Vector_Debug(*vector.Vector, spacer$ = #Null$, number.b = #Null)
  Protected String$, i.l
  String$ = Vector_Parse(*vector, spacer$, number)
  For i = 1 To CountString(String$, #Vector_NewLine)
    Debug StringField(String$, i, #Vector_NewLine)
  Next i
EndProcedure



; ----------------- Constants ----------------

#XML_FILE       = "prefs.xml"
#PICTURES_EXT   = ";jpg;bmp;png;gif;"
#TEMP_BMP_FILE  = "my_wallpaper.bmp"
#MaxDelay       = $FFFF
#PrefDelay      = 20
#Size_ColorBox  = 18
#XML_Encodage   = "UTF-8"


; ------------ Globals Declaration -----------


Global Conf.Configuration, SaveConf.Configuration
Global CurrentGroupName.s, SaveCurrentGroupName.s, CurrentGroupPath.s
Global *Colors.Vector, hImageColor.l
Global *Pictures.Vector, *RndPictures.Vector
Global TimerID.l, FullScreen.l, FullScreen_old.l
Global CurrentWP.s
Global NoModifications.l




; ----------- Globals Initialisation ----------

Conf\Groups       = Vector_CreateFromComplexStructure(@Group_ConstructorFromXML(), @Group_Destructor(), @Group_Comparator())
SaveConf\Groups   = Vector_CreateFromComplexStructure(@Group_Constructor(), @Group_Destructor(), @Group_Comparator())

*Colors           = Vector_CreateFromComplexStructure(@Color_Constructor(), @Color_Destructor(), @Color_Comparator())

CurrentGroupName  = #Null$

*Pictures         = Vector_Create(#String)
*RndPictures      = Vector_Create(#String)

FullScreen        = #False




; ----------------- Constants ----------------

;{ Window Constants
Enumeration
  #Window_Conf
  #Systray
  #Popup

  #Frame3D_0
  #Listview_Groups
  #Btn_Up
  #Btn_Add
  #Btn_Edit
  #Btn_Drop
  #Btn_Down
  
  #Frame3D_1
  #Text_0
  #Spin_Delay
  #Text_Delay
  
  #Text_1
  #Img_Color
  #Label_Color
  #Btn_EditColor
  
  #Combo_Display
  #Text_Display
  
  #Check_Startup

  #Text_2
  #String_Url
  #Btn_Browse_File
  #Btn_Browse_Folder

  #Btn_Cancel
  #Btn_Reload
  #Btn_Apply
  
  #TimerID
  #TimerFullScreen
  
  #PU_Settings
  #PU_Exit
  #PU_Pause
  #PU_Resume
  #PU_Ban
  #PU_Next
  #PU_Groups  = 100
EndEnumeration
;}


;{ Settings Actions
Enumeration
  #Setting_Action_Save
  #Setting_Action_Reload
  #Setting_Action_Cancel
EndEnumeration
;}


;{ WP display format
#WP_Format_Offset = 1
Enumeration #WP_Format_Offset 
  #WP_Format_Maximize
  #WP_Format_Stretch
  #WP_Format_Mozaic
  #WP_Format_Centered
  #WP_Format_Automatique
  
  ; Private Mode
  #WP_Format_ZoomedOnce ; Sizes multiplied by 2
EndEnumeration
;}


 
; jaPBe Version=3.8.3.696
; Build=0
; FirstLine=94
; CursorPosition=131
; ExecutableFormat=Windows
; DontSaveDeclare
; EOF