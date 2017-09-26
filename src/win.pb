; PureBasic Visual Designer v3.95 build 1485 (PB4Code)

#WrongPath    = $FFFF00
#CorrectPath  = $FFFFFF


Global Image0, Image1, Image2, Image3, Image4, Image5, Image6, Image7, ImageSystray
Global SysPause, SysResume, SysNext, SysBan, SysConf, SysQuit, SysGroups


;{ Catch Images
Image0        = CatchImage(0, ?Image0)
Image1        = CatchImage(1, ?Image1)
Image2        = CatchImage(2, ?Image2)
Image3        = CatchImage(3, ?Image3)
Image4        = CatchImage(4, ?Image4)
Image5        = CatchImage(5, ?Image5)
Image6        = CatchImage(6, ?Image6)
Image7        = CatchImage(15, ?Image7)
ImageSystray  = CatchImage(7, ?ImageSystray)
SysPause      = CatchImage(8, ?SysPause)
SysResume     = CatchImage(9, ?SysResume)
SysNext       = CatchImage(10, ?SysNext)
SysBan        = CatchImage(11, ?SysBan)
SysConf       = CatchImage(12, ?SysConf)
SysQuit       = CatchImage(13, ?SysQuit)
SysGroups     = CatchImage(14, ?SysGroups)
;}




Procedure Create_Settings_Window()
  If OpenWindow(#Window_Conf, 216, 0, 503, 261, #PROG_NAME + " - Settings", #PB_Window_ScreenCentered | #PB_Window_Invisible | #PB_Window_SystemMenu | #PB_Window_TitleBar )
    ;If CreateGadgetList(WindowID(#Window_Conf))
      Frame3DGadget(#Frame3D_0, 10, 10, 260, 170, "Groups")
      ListViewGadget(#Listview_Groups, 20, 30, 200, 140)
      ButtonImageGadget(#Btn_Up, 230, 30, 23, 23, Image0)
        GadgetToolTip(#Btn_Up, "Move up")
      ButtonImageGadget(#Btn_Add, 230, 60, 23, 23, Image1)
        GadgetToolTip(#Btn_Add, "Add a new group")
      ButtonImageGadget(#Btn_Edit, 230, 90, 23, 23, Image2)
        GadgetToolTip(#Btn_Edit, "Edit the name of this group")
      ButtonImageGadget(#Btn_Drop, 230, 120, 23, 23, Image3)
        GadgetToolTip(#Btn_Drop, "Delete this group")
      ButtonImageGadget(#Btn_Down, 230, 150, 23, 23, Image4)
        GadgetToolTip(#Btn_Down, "Move down")
      
      Frame3DGadget(#Frame3D_1, 280, 10, 210, 170, "Generals settings")
      TextGadget(#Text_0, 290, 30, 190, 20, "Roll time (in seconds), zero to freeze it :")
      StringGadget(#Spin_Delay, 300, 50, 70, 20, "", #PB_String_Numeric)
      TextGadget(#Text_Delay, 390, 55, 90, 20, "")
      TextGadget(#Text_1, 290, 80, 190, 20, "Background color (for portait pictures) :")
      ImageGadget(#Img_Color, 300, 100, #Size_ColorBox, #Size_ColorBox, #Null, #PB_Image_Border)
      ButtonImageGadget(#Btn_EditColor, 330, 101, 22, #Size_ColorBox, Image7)
      TextGadget(#Label_Color, 370, 104, 70, 20, "")
        GadgetToolTip(#Btn_EditColor, "Edit color list")
      TextGadget(#Text_Display, 290, 130, 50, 20, "Display :")
      ComboBoxGadget(#Combo_Display, 350, 130, 120, 20)
        AddGadgetItem(#Combo_Display, 0, "Maximized")
        AddGadgetItem(#Combo_Display, 1, "Stretched")
        AddGadgetItem(#Combo_Display, 2, "Mozaic")
        AddGadgetItem(#Combo_Display, 3, "Centered")
        AddGadgetItem(#Combo_Display, 4, "Auto")
      CheckBoxGadget(#Check_Startup, 290, 150, 190, 20, "Launch on startup")

      TextGadget(#Text_2, 10, 194, 60, 20, "Path / File :")
      StringGadget(#String_Url, 80, 190, 355, 20, "")
        GadgetToolTip(#String_Url, "Always keep the last good file/folder")
      ButtonImageGadget(#Btn_Browse_File, 445, 190, 20, 20, Image5)
        GadgetToolTip(#Btn_Browse_File, "Browse file")
      ButtonImageGadget(#Btn_Browse_Folder, 470, 190, 20, 20, Image6)
        GadgetToolTip(#Btn_Browse_Folder, "Browse folder")

      ButtonGadget(#Btn_Cancel, 390, 220, 100, 30, "Cancel")
        GadgetToolTip(#Btn_Cancel, "Cancel and close this window")
      ButtonGadget(#Btn_Reload, 280, 220, 100, 30, "Reload")
        GadgetToolTip(#Btn_Reload, "Reload this window")
      ButtonGadget(#Btn_Apply, 170, 220, 100, 30, "Apply")
        GadgetToolTip(#Btn_Reload, "Save changes and close this window")
    ;EndIf
    AddSysTrayIcon(#Systray, WindowID(#Window_Conf), ImageSystray)
    SysTrayIconToolTip(#Systray, #PROG_NAME)
  EndIf
EndProcedure



Procedure Create_Systray_PopupMenu()
  Protected *g.Group, PopUpMenu.l, Sub.l
  
  If IsMenu(#Popup)
    FreeMenu(#Popup)
  EndIf
  PopUpMenu = CreatePopupMenu(#Popup)
  If PopUpMenu
    
    If CurrentGroupName And Vector_Count(*Pictures)
      If TimerID
        MenuItem(#PU_Pause, "Pause")
        SetMenuItemBitmaps_(PopUpMenu, #PU_Pause, #MF_BYCOMMAND, SysPause, SysPause)
        MenuItem(#PU_Next, "Next picture")
        SetMenuItemBitmaps_(PopUpMenu, #PU_Next, #MF_BYCOMMAND, SysNext, SysNext)
      Else
        MenuItem(#PU_Resume, "Resume")
        SetMenuItemBitmaps_(PopUpMenu, #PU_Resume, #MF_BYCOMMAND, SysResume, SysResume)
      EndIf
      If CurrentWP
        MenuItem(#PU_Ban, "Ban this picture")
        SetMenuItemBitmaps_(PopUpMenu, #PU_Ban, #MF_BYCOMMAND, SysBan, SysBan)
      EndIf
      MenuBar()
    EndIf
    
    If Vector_Count(Conf\Groups)
      OpenSubMenu("Groups")
      Vector_Reset(Conf\Groups)
      While Vector_NextElement(Conf\Groups)
        *g = Vector_GetElement(Conf\Groups)
        MenuItem(#PU_Groups + Vector_GetIndex(Conf\Groups), *g\Name)
        If *g\Name = CurrentGroupName
          SetMenuItemState(#Popup, #PU_Groups + Vector_GetIndex(Conf\Groups), #True)
        EndIf
      Wend
      CloseSubMenu()
      MenuBar()
    EndIf
    
    MenuItem(#PU_Settings, "Settings")
    SetMenuItemBitmaps_(PopUpMenu, #PU_Settings, #MF_BYCOMMAND, SysConf, SysConf)
    MenuBar()
    MenuItem(#PU_Exit, "Exit "+#PROG_NAME)
    SetMenuItemBitmaps_(PopUpMenu, #PU_Exit, #MF_BYCOMMAND, SysQuit, SysQuit)
  EndIf 
EndProcedure



Procedure DisableGadgets(state, Index, Count)
  DisableGadget(#Btn_Browse_File, state)
  DisableGadget(#Btn_Browse_Folder, state)
  DisableGadget(#Btn_Edit, state)
  DisableGadget(#Btn_Drop, state)
  If Index < 1
    DisableGadget(#Btn_Up, #True)
  Else
    DisableGadget(#Btn_Up, #False)
  EndIf
  If Index = Count - 1 Or state
    DisableGadget(#Btn_Down, #True)
  Else
    DisableGadget(#Btn_Down, #False)
  EndIf
EndProcedure





; ----------------- StringGadget : URL Change ------------------

Procedure Set_UrlString_BackgroundColor()
  Protected Color.l
  If FileSize(GetGadgetText(#String_Url)) = -1 And GetGadgetState(#Listview_Groups) <> -1
    Color = #WrongPath
  Else
    Color = #CorrectPath
  EndIf
  SetGadgetColor(#String_Url, #PB_Gadget_BackColor, Color)
EndProcedure


Procedure Change_UrlString()
  Protected Index.l, *g.Group, Color.l, Size.l, debut.l, fin.l
  
  Color = #WrongPath
  Index = GetGadgetState(#Listview_Groups)
  If Index <> -1
    Size = FileSize(GetGadgetText(#String_Url))
    *g = Vector_GetElement(SaveConf\Groups, Index)
    If Size <> -1 And *g
      If Size >= 0
        *g\Path = GetGadgetText(#String_Url)
      Else
        *g\Path = NormalizeFolder(GetGadgetText(#String_Url))
        If GetGadgetText(#String_Url) <> *g\Path
          SendMessage_(GadgetID(#String_Url), #EM_GETSEL, @debut, @fin)
          SetGadgetText(#String_Url, *g\Path)
          SendMessage_(GadgetID(#String_Url), #EM_SETSEL, debut, fin)
        EndIf
      EndIf
      Color = #CorrectPath
      If *g\Name = CurrentGroupName And CurrentGroupPath <> *g\Path
        Vector_Clear(*g\Ban)
        KillTimer()
      EndIf
    EndIf
  Else
    Color = #CorrectPath
  EndIf
  SetGadgetColor(#String_Url, #PB_Gadget_BackColor, Color)
  NoModifications = #False
EndProcedure





; ---------------- ListViewGadget : Groups ------------------


Procedure ListGroups_Change()
  Protected Index.l, Count.l, *grp.Group
  
  Index = GetGadgetState(#Listview_Groups)
  Count  = CountGadgetItems(#Listview_Groups)
  If Index > -1 And Index < Count
    *grp = Vector_GetElement(SaveConf\Groups, Index)
    SetGadgetText(#String_Url, *grp\Path)
    DisableGadgets(#False, Index, Count)
  Else
    SetGadgetText(#String_Url, "")
    DisableGadgets(#True, Index, Count)
  EndIf
EndProcedure



Procedure FillGroupList()
  Protected *grp.Group
  
  ClearGadgetItems(#Listview_Groups)
  
  Vector_Reset(SaveConf\Groups)
  While Vector_NextElement(SaveConf\Groups)
    *grp = Vector_GetElement(SaveConf\Groups)
    AddGadgetItem(#Listview_Groups, -1, *grp\Name)
  Wend
  ListGroups_Change()
EndProcedure



; ------------------ ComboGadget : Colors --------------------

Procedure SetNewColor()
  Protected Index.l, *Color.Color
  
  If hImageColor
    FreeImage(hImageColor)
  EndIf
  hImageColor = CreateImage(#PB_Any, #Size_ColorBox, #Size_ColorBox)
  If hImageColor
    If StartDrawing(ImageOutput(hImageColor))
      Box(0,0, #Size_ColorBox,#Size_ColorBox, SaveConf\CurrentColor)
      StopDrawing()
    EndIf
    SetGadgetState(#Img_Color, ImageID(hImageColor))
  EndIf
  
  SetGadgetText(#Label_Color, "")
  If Vector_Search(*Colors, SaveConf\CurrentColor, @Index)
    *Color = Vector_GetElement(*Colors, Index)
    If *Color
      SetGadgetText(#Label_Color, *Color\Name)
    EndIf
  EndIf
EndProcedure


Procedure Color_Change()
  Protected Color.l
  
  Color = ColorRequester(SaveConf\CurrentColor)
  If Color <> -1
    SaveConf\CurrentColor = Color
    SetNewColor()
    NoModifications = #False
  EndIf
EndProcedure



; -------------------- SpinGadget : Delay ----------------------


Procedure Delay_Change()
  SaveConf\Delay = Val(GetGadgetText(#Spin_Delay))
  If SaveConf\Delay > #MaxDelay
    SaveConf\Delay = #MaxDelay
    SetGadgetText(#Spin_Delay, Str(SaveConf\Delay))
  EndIf
  SetGadgetText(#Text_Delay, "Either : " + TimeInMinute(SaveConf\Delay))
  NoModifications = #False
EndProcedure



; ---------------- Settings Window : Show/Hide ------------------


Procedure Show_Setting_Window()
  Groups_Save(Conf, SaveConf)
  SaveCurrentGroupName = CurrentGroupName
  FillGroupList()
  SetNewColor()
  SetGadgetState(#Combo_Display, Conf\DisplayMode - #WP_Format_Offset)
  
  SetSpinGadget(#Spin_Delay, SaveConf\Delay)
  Delay_Change()
  SetGadgetState(#Check_Startup, SaveConf\AutoStart)
  Set_UrlString_BackgroundColor()
  HideWindow(#Window_Conf, #False)
  RemoveSysTrayIcon(#Systray)
  NoModifications = #True
EndProcedure


Procedure Hide_Setting_Window(action.l)
  AddSysTrayIcon(#Systray, WindowID(#Window_Conf), ImageSystray)
  HideWindow(#Window_Conf, #True)
  Select action
    Case #Setting_Action_Save
      SaveConf\Delay = Val(GetGadgetText(#Spin_Delay))
      SaveConf\DisplayMode = GetGadgetState(#Combo_Display) + #WP_Format_Offset
      Groups_Restore(SaveConf, Conf)
      SaveConfXML()
      LaunchAtStartUp(Conf\AutoStart)
    
    Case #Setting_Action_Cancel
      CurrentGroupName = SaveCurrentGroupName
    
    Case #Setting_Action_Reload
      Show_Setting_Window()
  EndSelect
EndProcedure










; IDE Options = PureBasic 4.30 (Windows - x86)
; CursorPosition = 63
; FirstLine = 39 
; jaPBe Version=3.8.3.696
; Build=0
; FirstLine=302
; CursorPosition=327
; ExecutableFormat=Windows
; DontSaveDeclare
; EOF