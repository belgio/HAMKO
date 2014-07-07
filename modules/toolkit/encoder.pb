  OpenConsole()
  ConsoleTitle("Benc64")
  PrintN("Base64 Encoder v1.1")
  PrintN("2007 (c) Dimitris Tsiktsiris")
  PrintN("")

file.s = ProgramParameter()

If file
  

PrintN("Encoding "+file+" ...")
handle.l = ReadFile(#PB_Any, file);
Size.l=Lof(handle)
*FileData = AllocateMemory(Size)
ReadData(handle,*FileData,Size)
CloseFile(handle)

Size2.l= Size * 1.35
*NewFileData = AllocateMemory(Size2)

EncSize = Base64Encoder(*FileData, Size, *NewFileData, Size2)

PrintN("Writing encoded file...")
handle2.l = CreateFile(#PB_Any, GetPathPart(file)+RemoveString(GetFilePart(file),GetExtensionPart(file))+"enc");
If handle2
WriteData(handle2, *NewFileData, EncSize)
CloseFile(handle2)
Else
  PrintN("Cannot create encoded file")
EndIf 

FreeMemory(*FileData)
FreeMemory(*NewFileData)

PrintN("Finished!")
PrintN("Press RETURN to exit")
Input()
EndIf 
; IDE Options = PureBasic 5.00 (Windows - x86)
; CursorPosition = 24
; EnableXP
; Executable = encoder.exe
; EnableCompileCount = 13
; EnableBuildCount = 13