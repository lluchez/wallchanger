; You need to download these libs:
; Lib Vector2
;   http://basicunivers.free.fr/index.php?page=sources.php&file=248
; Lib Common:
;   http://basicunivers.free.fr/index.php?page=sources.php&file=252

#PROG_NAME  = "WallChanger"
#VERSION    = "1.3"

EnableExplicit
IncludePath "src\"
  ;IncludeFile "Registre.pb"
  IncludeFile "basics.pb"
  IncludeFile "class.pb"
  IncludeFile "res.pb"
  IncludeFile "module-xml.pb"
  IncludeFile "fcts.pb"
  IncludeFile "timer.pb"
  IncludeFile "win.pb"
  IncludeFile "events.pb"
  IncludeFile "callbacks.pb"
IncludePath "."



;{ Decoder Plugins
  UsePNGImageDecoder()
  UseJPEGImageDecoder()
  UseTGAImageDecoder()
  UseTIFFImageDecoder()
;}


Define Quit.c

RunOnlyOneInstance()
SetCurrentDirectory(GetPathPart(GetModuleFileName()))
;SetCurrentDirectory("E:\Programmation\PureBasic\Projets\Petits Projets\Images\WallChanger\")

LoadConfXML()
Create_Settings_Window()
FillColorVector(*Colors)
RandomSeed(Date())
WP_Launch()


SetTimer_(MainWnd, #TimerFullScreen, 300, #Null)

;{ Main Loop
;  ----------------------- {
    Quit = #False
    Repeat

      Select WaitWindowEvent()
      
        Case #PB_Event_CloseWindow
          CallBack_Close_Window()
          
        Case #PB_Event_SysTray
          CallBack_SysTray()
        
        Case #PB_Event_Menu
          CallBack_Menu(@Quit)
        
        Case #PB_Event_Gadget
          CallBack_Gadget()
        
        Case #WM_TIMER
          CallBack_Timer()
    
      EndSelect
      
    Until Quit
;} ------------------------}


SaveConfXML()



RemoveSysTrayIcon(#Systray)

Vector_FreeGarbageCollector()






;{- Data : Images
DataSection
  IncludePath "images"
  Image0:
    IncludeBinary "up.ico"
  Image1:
    IncludeBinary "add.ico"
  Image2:
    IncludeBinary "edit.ico"
  Image3:
    IncludeBinary "drop.ico"
  Image4:
    IncludeBinary "down.ico"
  Image5:
    IncludeBinary "file_icon.ico"
  Image6:
    IncludeBinary "folder_icon.ico"
  Image7:
    IncludeBinary "color.bmp"
  
  IncludePath "images\systray"
  SysPause:
    IncludeBinary "pause.bmp"
  SysResume:
    IncludeBinary "resume.bmp"
  SysNext:
    IncludeBinary "next.bmp"
  SysBan:
    IncludeBinary "ban.bmp"
  SysConf:
    IncludeBinary "settings.bmp"
  SysQuit:
    IncludeBinary "exit.bmp"
  SysGroups:
    IncludeBinary "groups.bmp"
  
  IncludePath ""
  ImageSystray:
    IncludeBinary "icon.ico"
EndDataSection
;}

 
; jaPBe Version=3.8.3.696
; Build=9
; Language=0x0000 Language Neutral
; FirstLine=91
; CursorPosition=99
; EnableThread
; EnableUnicode
; UseIcon=icon.ico
; ExecutableFormat=Windows
; Executable=E:\Programmation\PureBasic\Projets\Petits Projets\Images\WallChanger\WallChanger.exe
; DontSaveDeclare
; EOF