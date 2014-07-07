
Procedure Base64_Decode(file.s)
handle = ReadFile(#PB_Any, file)
If handle
  Size = Lof(handle)
  *FileData = AllocateMemory(Size)
  If *FileData
    If ReadData(handle, *FileData, Size) = Size
      *Decoded = AllocateMemory(Size)
      If *Decoded      
        Bytes = Base64Decoder(*FileData, Size, *Decoded, Size)
        handle2 = CreateFile(#PB_Any,GetPathPart(file)+RemoveString(GetFilePart(file),GetExtensionPart(file))+"exe")
        If handle2
          WriteData(handle2, *Decoded, Bytes)
          CloseFile(handle2)
        EndIf
        FreeMemory(*Decoded)
      EndIf
    EndIf
    FreeMemory(*FileData)
  EndIf
  CloseFile(handle)
EndIf
EndProcedure
; IDE Options = PureBasic 5.00 (Windows - x86)
; CursorPosition = 23
; Folding = -
; EnableXP
; Executable = decoder.exe
; EnableCompileCount = 3
; EnableBuildCount = 3