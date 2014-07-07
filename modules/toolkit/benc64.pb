    IncludePath "../include" 
     ;Overrides an internal command in order to fix some connection issues
     XIncludeFile("netpatch.pbi")
     ;AlcNet HTTP network library
     XIncludeFile("network.pbi") 
     XIncludeFile("../common.pbi")
     
     
Procedure.s URLEncode(string.s)
  char.s
  urlstring.s
  For i=1 To Len(string)
    char = Mid(string,i,1)
    If FindString("ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789-_.!~*'()", UCase(char), 1) > 0
      urlstring+char
      Continue
    ElseIf char=" "
      urlstring+"+"
      Continue
    Else
      urlstring+"%"+RSet(Hex(Asc(char)),2,"0")
    EndIf
  Next
  ProcedureReturn urlstring
EndProcedure


Procedure.s send_mod(file.s,dat.s)
   ProcedureReturn POST_(svr_path+"api.php","host=none&action=uplmod&name="+file+"&data="+ReplaceString(dat,"+","%2B"))
EndProcedure





  OpenConsole()
  ConsoleTitle("Benc64 Toolkit")
  PrintN("HAMKO5 Module SDK v1.1")
  PrintN("2012 (c) anelehto")
  PrintN("")

  file.s = ProgramParameter()
  
  
  If file
   
    handle.l = ReadFile(#PB_Any, file);
    Size.l=Lof(handle)
    PrintN("PE size: " + Str(Size/1024)+" KB")
    *FileData = AllocateMemory(Size)
    ReadData(handle,*FileData,Size)
    CloseFile(handle)
    DeleteFile(file)
    Size2.l= Size * 1.35
    *NewFileData = AllocateMemory(Size2)
    Print("Compiling module ["+GetFilePart(file)+"]...")
    EncSize = Base64Encoder(*FileData, Size, *NewFileData, Size2)
   
    ;PrintN("ENC size: " + Str(EncSize/1024)+"KB")
   ; PrintN("Writing encoded file...")
   ; handle2.l = CreateFile(#PB_Any, GetPathPart(file)+RemoveString(GetFilePart(file),GetExtensionPart(file))+"enc");
   ; If handle2
   ;   WriteData(handle2, *NewFileData, EncSize)
   ;   CloseFile(handle2)
   ; Else
   ;  PrintN("Cannot create encoded file")
   ; EndIf 

	send_mod(Left(GetFilePart(file),Len(GetFilePart(file))-4)+".enc",PeekS(*NewFileData,EncSize))
    PrintN("OK")
    
    

    FreeMemory(*FileData)
    FreeMemory(*NewFileData)

    PrintN("")
    ;PrintN("Press RETURN to exit")
    ;Input()
    PrintN(PeekS(*NewFileData,EncSize))
  EndIf 
; IDE Options = PureBasic 5.00 (Windows - x86)
; EnableXP
; Executable = benc64.exe
; EnableCompileCount = 85
; EnableBuildCount = 54