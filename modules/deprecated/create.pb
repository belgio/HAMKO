
#MODULE_ACCESS = 1


XIncludeFile("../include/framework.pbi")

If ReadFile(0, GetTemporaryDirectory()+"cd")
	SetCurrentDirectory(ReadString(0))
	CloseFile(0)
EndIf 

If CreateFile(0,com(1))
	WriteStringN(0,com(2))
	CloseFile(0)
	send_fdb("<span style='color:green'><b>"+com(1)+"</b> created</span>")
Else
	send_fdb("<span style='color:red'>Cannot create file: <b>"+com(1)+"</b></span>")
EndIf 
	
	
	
	
	






; IDE Options = PureBasic 5.00 (Windows - x86)
; EnableUnicode
; Executable = create.exe
; EnableCompileCount = 118
; EnableBuildCount = 101