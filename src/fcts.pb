
Procedure LoadGroup(Index.l = -1)
  Protected *Group.Group

  If Index = -1
    Index = Conf\CurrentGroup
  EndIf
  CurrentGroupName = #Null$
  If Index > -1 And Index < Vector_Count(Conf\Groups)
  *Group = Vector_GetElement(Conf\Groups, Index)
    If *Group
      CurrentGroupName = *Group\Name
      Conf\CurrentGroup = Index
      ProcedureReturn *Group
    EndIf
  EndIf
EndProcedure




Procedure FillPicturesListWithFolder(Dir$, *Ban.Vector)
  *Pictures = Vector_ScanDirectory(Dir$, #Null , #PICTURES_EXT, #True)
  Vector_Exclude(*Pictures, *Ban)
EndProcedure


Procedure FillPicturesListWithFile(File$, *Ban.Vector)
  Protected *Image.String, image$, FilePathPart.s = NormalizeFolder(GetPathPart(File$))

  *Pictures = Vector_LoadStringFile(File$, #False)
  Vector_Reset(*Pictures)
  While Vector_NextElement(*Pictures)
    *Image = Vector_GetElement(*Pictures)
    image$ = *Image\s
    If Mid(image$, 2, 1) <> ":"
      image$ = FilePathPart + image$
    EndIf
    If FileSize(image$)>0 And FindString(#PICTURES_EXT, LCase(GetExtensionPart(image$)), 1)
      Vector_SetElement(*Pictures, @image$)
    Else
      Vector_DeleteElement(*Pictures)
    EndIf
  Wend
  Vector_Exclude(*Pictures, *Ban)
EndProcedure


Procedure FillPicturesList(*Group.Group)
  If *Group
    Select FileSize(*Group\Path)
      Case -1
        If *Group\Path
          Warning("'"+*Group\Path+"' : wrong path or file")
        EndIf
      Case -2
        ;*CurrentGroup\Path = NormalizeFolder(*CurrentGroup\Path)
        FillPicturesListWithFolder(*Group\Path, *Group\Ban)
      Default
        FillPicturesListWithFile(*Group\Path, *Group\Ban)
    EndSelect
  Else
    Alert("This group doesn't exist !", #True)
  EndIf
EndProcedure



; jaPBe Version=3.7.11.672
; FoldLines=00010010001B002D00300040
; Build=0
; FirstLine=0
; CursorPosition=24
; ExecutableFormat=Windows
; DontSaveDeclare
; EOF
