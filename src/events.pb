

Procedure Swap_Groups(Way.l)
  Protected Index.l

  Index = GetGadgetState(#Listview_Groups)
  Vector_Swap(SaveConf\Groups, Index, Index+Way)
  FillGroupList()
  SetGadgetState(#Listview_Groups, Index+Way)
EndProcedure



Procedure Click_AddGroup()
  Protected Index.l, g.Group, *g.Group
  
  g\Name = SafeString(InputRequester(#PROG_NAME, "New name :", ""))
  If g\Name
    If Vector_Search(SaveConf\Groups, g)
      Warning("This goup already exists !")
    Else
      Vector_AddAtEnd(SaveConf\Groups, g)
      FillGroupList()
      SetGadgetState(#Listview_Groups, CountGadgetItems(#Listview_Groups)-1)
      ;Change_UrlString()
      ListGroups_Change()
      SetActiveGadget(#String_Url)
      NoModifications = #False
    EndIf
  EndIf
EndProcedure



Procedure Click_DropGroup()
  Protected Index.l, *g.Group

  If YesNo("Are you sure to delete this group ?") = #PB_MessageRequester_Yes
    Index = GetGadgetState(#Listview_Groups)
    *g = Vector_GetElement(SaveConf\Groups, Index)
    If *g
      If GetGadgetText(#Listview_Groups) = CurrentGroupName
        ; // Stop the Thread
        KillTimer()
      EndIf
      Vector_DeleteElement(SaveConf\Groups)
      FillGroupList()
      NoModifications = #False
    Else
      Alert("This group don't exist anymore !", #True)
    EndIf
  EndIf
EndProcedure



Procedure Click_EditGroup()
  Protected Name$, Index.l, *g.Group, g.Group
  
  Index = GetGadgetState(#Listview_Groups)
  *g = Vector_GetElement(SaveConf\Groups, Index)
  If *g
    Name$ = SafeString(InputRequester(#PROG_NAME, "New name :", *g\Name))
    If Name$
      If *g\Name <> Name$
        g\Name = Name$
        If Vector_Search(SaveConf\Groups, g)
          Warning("This goup already exists !")
        Else
          If *g\Name = CurrentGroupName
            CurrentGroupName = Name$
          EndIf
          *g\Name = Name$
          SetGadgetItemText(#Listview_Groups, Index, Name$)
          SetGadgetState(#Listview_Groups, Index)
          NoModifications = #False
        EndIf
      EndIf
    EndIf
  Else
    Alert("This group don't exist anymore !", #True)
  EndIf
EndProcedure





Procedure Click_BrowseFile()
  Protected File$
  
  File$ = OpenFileRequester(#PROG_NAME, "Choice a list file", "All files|*.*", 0)
  If File$
    SetGadgetText(#String_Url, File$)
    Change_UrlString()
    NoModifications = #False
  EndIf
EndProcedure

Procedure Click_BrowseFolder()
  Protected Folder$
  Static Defaut$ = ""
  
  Folder$ = PathRequester(#PROG_NAME, Defaut$)
  If Folder$
    Defaut$ = Folder$
    SetGadgetText(#String_Url, NormalizeFolder(Folder$))
    Change_UrlString()
    NoModifications = #False
  EndIf
EndProcedure



Procedure CancelSettingsModifications()
  If NoModifications
    Hide_Setting_Window(#Setting_Action_Cancel)
    ProcedureReturn
  EndIf
  Select Confirm("Do you wan to save the settings before closing this window ?")
    Case #PB_MessageRequester_Yes
      Hide_Setting_Window(#Setting_Action_Save)
    Case #PB_MessageRequester_No
      Hide_Setting_Window(#Setting_Action_Cancel)
    Default
  EndSelect
EndProcedure

; jaPBe Version=3.7.11.672
; FoldLines=00020009000D001E0022003400380052005800610063006E
; Build=0
; FirstLine=11
; CursorPosition=119
; ExecutableFormat=Windows
; DontSaveDeclare
; EOF
