
#MODULE_ACCESS = 1


XIncludeFile("../include/framework.pbi")

If ReadFile(0, GetTemporaryDirectory()+"cd")
	SetCurrentDirectory(ReadString(0))
	CloseFile(0)
EndIf 

status.l=ShellExecute_(GetForegroundWindow_(), #Null, com(1), com(2), #Null, #SW_SHOWNORMAL)
If status = 42
	send_fdb("<span style='color:green'>Successfully created process <b>"+com(1)+"</b></span>")
Else
	send_fdb("<span style='color:red'>Failed with status <b>"+Str(status)+"</b> (for more info see <a href='http://msdn.microsoft.com/en-us/library/windows/desktop/bb762153(v=vs.85).aspx' target='_blank'>here</a>)</span>")
EndIf 
	
	
	
	
	






; IDE Options = PureBasic 5.00 (Windows - x86)
; EnableUnicode
; Executable = exec.exe
; EnableCompileCount = 115
; EnableBuildCount = 98