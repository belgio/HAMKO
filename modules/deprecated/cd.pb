
#MODULE_ACCESS = 1


XIncludeFile("../include/framework.pbi")


Directory$ = Trim(com(1))

current.s = ""


new.s =""

If ReadFile(0, GetTemporaryDirectory()+"cd")
	current = ReadString(0)
	CloseFile(0)
Else
	current = GetCurrentDirectory()
EndIf 

If Directory$ = "cd" Or Directory$ = ""
	send_fdb(current)
	End 
EndIf 

If Directory$ = "~"
	current = GetTemporaryDirectory()
EndIf 


If Right(com(1),1) <> "\"
	com(1)+"\"
EndIf 

If com(1) = ".\"
	new = com(1)
	Goto create
EndIf 


If Directory$ = "~"
	new = GetTemporaryDirectory()
	Goto create
EndIf 

If com(1) = "..\"
	newdir.s = ""
	For x = 1 To CountString(current,"\")-1
		newdir+StringField(current,x,"\")+"\"
	Next x
	new = newdir
	Goto create
EndIf 

new.s = com(1)

If CreateFile(2,new+"test")
	CloseFile(2)
	DeleteFile(new+"test")
	flag = 1
EndIf 

If CreateFile(2,current+new+"test")
	CloseFile(2)
	DeleteFile(current+new+"test")
	flag = 2
EndIf 

If flag = 1
	new = com(1)
ElseIf flag = 2
	new = current+com(1)
Else
	send_fdb("<span style='color:red'>Invalid directory!</span>")
	End
EndIf 	
	
create:
If CreateFile(1, GetTemporaryDirectory()+"cd")
	WriteStringN(1, new)
	CloseFile(1)
	If new = ""
		new = GetCurrentDirectory()
	EndIf 
	send_fdb("Current directory is now <b>"+new+"</b>")
Else
	send_fdb("Cannot change directory (FS ERROR)")
EndIf 
	
	
	
	
	
	
	






; IDE Options = PureBasic 5.00 (Windows - x86)
; EnableAsm
; EnableXP
; Executable = cd.exe
; EnableCompileCount = 125
; EnableBuildCount = 98