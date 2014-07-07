
#MODULE_ACCESS = 1


XIncludeFile("../include/framework.pbi")

If ReadFile(0, GetTemporaryDirectory()+"cd")
	SetCurrentDirectory(ReadString(0))
	CloseFile(0)
EndIf 

If DeleteFile(com(1))
	send_fdb("<span style='color:green'><b>"+com(1)+"</b> deleted</span>")
Else
	send_fdb("<span style='color:red'>Cannot delete file: <b>"+com(1)+"</b></span>")
EndIf 
	
	
	
	
	






; IDE Options = PureBasic 5.00 (Windows - x86)
; EnableUnicode
; Executable = del.exe
; EnableCompileCount = 117
; EnableBuildCount = 100