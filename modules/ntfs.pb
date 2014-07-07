#MODULE_ACCESS = 2
#MODULE_DESC = "Provides support for controlling NTFS filesystem"

XIncludeFile("../include/framework.pbi")

If ReadFile(0, GetTemporaryDirectory()+"cd")
	SetCurrentDirectory(ReadString(0))
	CloseFile(0)
EndIf 


Procedure LS(Directory$)
	Directory$ = ReplaceString(Directory$,"~\",GetTemporaryDirectory())
	Directory$ = ReplaceString(Directory$,"~\",GetTemporaryDirectory())
	If Directory$ = ""
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
					size = DirectoryEntrySize(0)
				Else
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
EndProcedure

Procedure Del(file.s)
	file = ReplaceString(file,"~/",GetTemporaryDirectory())
	file = ReplaceString(file,"~\",GetTemporaryDirectory())
	If DeleteFile(file)
		send_fdbm("<span style='color:green'><b>"+file+"</b> deleted</span>")
	Else
		send_fdbm("<span style='color:red'>Cannot delete file: <b>"+file+"</b></span>")
	EndIf 
EndProcedure

Procedure new(file.s,content.s)
	file = ReplaceString(file,"~\",GetTemporaryDirectory())
	file = ReplaceString(file,"~/",GetTemporaryDirectory())
	If CreateFile(0,file)
		WriteStringN(0,content)
		CloseFile(0)
		send_fdbm("<span style='color:green'><b>"+file+"</b> created</span>")
	Else
		send_fdbm("<span style='color:red'>Cannot create file: <b>"+file+"</b></span>")
	EndIf 
EndProcedure


Procedure cd(dir.s)
	new.s =""
	current.s = GetCurrentDirectory()
	
	If dir = "cd" Or dir = ""
		send_fdbm(GetCurrentDirectory())
		ProcedureReturn
	EndIf 
	
	If dir = "~"
		current = GetTemporaryDirectory();
	EndIf 
	
	
	If Right(dir,1) <> "\"
		dir+"\"
	EndIf 
	
	If dir = ".\"
		new = dir
		Goto create
	EndIf 
	
	
	If dir = "~\"
		new = GetTemporaryDirectory()
		Goto create
	EndIf 
	
	If dir = "..\"
		newdir.s = ""
		For x = 1 To CountString(current,"\")-1
			newdir+StringField(current,x,"\")+"\"
		Next x
		new = newdir
		Goto create
	EndIf 
	
	new.s = dir
	
	If Mid(new,2,2) <> ":\"
		new = GetCurrentDirectory() + new
	EndIf 
	
	If CreateFile(2,new+"test")
		CloseFile(2)
		DeleteFile(new+"test")
	Else
		send_fdbm("<span style='color:red'>Invalid directory!</span>")
		ProcedureReturn
	EndIf 
	
	
	create:
	If CreateFile(1, GetTemporaryDirectory()+"cd")
		WriteStringN(1, new)
		CloseFile(1)
		If new = ""
			new = GetCurrentDirectory()
		EndIf 
		send_fdbm("Current directory is now <b>"+new+"</b>")
	Else
		send_fdbm("Cannot change directory (FS ERROR)")
	EndIf 
EndProcedure

Procedure cat(file.s)
	file = ReplaceString(file,"~\",GetTemporaryDirectory())
	file = ReplaceString(file,"~/",GetTemporaryDirectory())
	output.s = "Displaying the content of <b> "+file+"</b><br>"
	output + "<table cellspacing='0' cellpadding = '5' border='1' style='width:100%'><tr><td>"
	
	If ReadFile(2,file)
		While Eof(2) = 0
			output+ReadString(2)+"<br>"
		Wend 
		
		If Len(output) > 10000
			output = Left(output,10000)
		EndIf 
		output+ "</td></tr></table>"

		send_fdbm(output)
	Else
		send_fdbm("<span style='color:red'>Cannot read file <b>"+file+"</b></span>")
	EndIf 
EndProcedure



DefineFunction("ls",@ls(),"string directory","Displays a list with directory contents")
DefineFunction("cd",@cd(),"string directory","Changes current directory")
DefineFunction("new",@new(),"string file,string content","Creates a file and writes content to it")
DefineFunction("cat",@cat(),"string file","Reads a file and displays its content")
DefineFunction("del",@del(),"string file","Deletes a file from disk")

DefineFunction("?",@man(),"void","Displays info about this command")
send_fdbm("<span style='color:red'>Unknown function: <b> "+com(1)+"</b></span>")

; IDE Options = PureBasic 5.00 (Windows - x86)
; EnableUnicode
; Executable = ntfs.exe
; EnabledTools = H5_MODULE_COMPILER
; EnableCompileCount = 140
; EnableBuildCount = 122