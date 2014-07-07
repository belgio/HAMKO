
#MODULE_ACCESS = 2


XIncludeFile("../include/framework.pbi")

Procedure.f DirectorySize(ID.l, Directory.s)
  Protected Size.f
  If ExamineDirectory(ID, Directory, "*.*")
    Repeat
      Entry.l = NextDirectoryEntry(ID)
      If Entry = 1
        Size + DirectoryEntrySize(ID)
      ElseIf Entry = 2
        Name.s = DirectoryEntryName(ID)
        If Name <> ".." And Name <> "."
          Size + DirectorySize(ID+1, Directory+Name+"\")
          ;UseDirectory(ID)
        EndIf
      EndIf
    Until Entry = 0
  EndIf
  ProcedureReturn Size
EndProcedure


Directory$ = Trim(com(1))

If Directory$ = "ls"
	If ReadFile(0, GetTemporaryDirectory()+"cd")
		Directory$ = ReadString(0)
		CloseFile(0)
	Else
		Directory$ = GetCurrentDirectory()
	EndIf 
EndIf 

output.s = "Listing directory <b>"+Directory$+"</b><br>"
If ExamineDirectory(0, Directory$, "*.*")  
	While NextDirectoryEntry(0)
		If DirectoryEntryName(0) <> "." And DirectoryEntryName(0) <> ".."
			entryname.s =  DirectoryEntryName(0)
		If DirectoryEntryType(0) = #PB_DirectoryEntry_File
			;Type$ = " [FILE] "
			size = DirectoryEntrySize(0)
		Else
			;Type$ = " [DIR] "
			;size = DirectorySize(5, Directory$+DirectoryEntryName(0))
			size = 0
			entryname + "\"
			entryname = "<span style='color:purple'>"+entryname+"</span>"
		EndIf
		
			
      If size> 1024*1024
      	output+"%26nbsp%3B%26nbsp%3B"+ Type$+"<b>"+ entryname  + "</b>%26nbsp%3B<i>" + StrF(size/1024/1024,2) +" MB</i><br>"
      ElseIf  size >1024
      	output+"%26nbsp%3B%26nbsp%3B"+ Type$+"<b>"+ entryname  + "</b>%26nbsp%3B<i>" + StrF(size/1024,2) +" KB</i><br>"
      ElseIf size >0
      	output+"%26nbsp%3B%26nbsp%3B"+ Type$+"<b>"+ entryname  + "</b>%26nbsp%3B<i>" + Str(size) +" bytes </i><br>"
      Else
      	output+"%26nbsp%3B%26nbsp%3B"+ Type$+"<b>"+ entryname  + "</b><br>"
      EndIf 
  EndIf 
	Wend
	
	FinishDirectory(0)
	send_fdbm(output)
Else
	send_fdbm("<span style='color:red'>Not a valid directory: "+Directory$+"</span>")
EndIf


; IDE Options = PureBasic 5.00 (Windows - x86)
; EnableUnicode
; Executable = ls.exe
; EnableCompileCount = 117
; EnableBuildCount = 99