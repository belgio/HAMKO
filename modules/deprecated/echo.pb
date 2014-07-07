#MODULE_ACCESS = 1
#MODULE_DESC = "Echoes a string back to server"

XIncludeFile("../include/framework.pbi")


Procedure echo(str.s)
	send_fdbm(str)
EndProcedure


DefineFunction("help",@man(),"void","Displays info about this command")

echo(com(1))




	
	
	
	
	






; IDE Options = PureBasic 5.00 (Windows - x86)
; EnableUnicode
; Executable = echo.exe
; EnableCompileCount = 137
; EnableBuildCount = 119