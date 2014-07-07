
#MODULE_ACCESS = 2

XIncludeFile("../include/framework.pbi")

If ReadFile(0, GetTemporaryDirectory()+"cd")
	SetCurrentDirectory(ReadString(0))
	CloseFile(0)
EndIf 



output.s = "Displaying the contents of <b> "+com(1)+"</b><br>"

output + "<table cellspacing='0' cellpadding = '5' border='1' style='width:100%'><tr><td>"


If ReadFile(2,com(1))
	While Eof(2) = 0
	output+ReadString(2)+"<br>"
	Wend 
	
	If Len(output) > 10000
		output = Left(output,10000)
    EndIf 
	output+ "</td></tr></table>"
	
    send_fdbm(output)
Else
	send_fdbm("<span style='color:red'>Cannot stat file <b>"+com(1)+"</b></span>")
EndIf 
	
	
	
	






; IDE Options = PureBasic 5.00 (Windows - x86)
; EnableUnicode
; Executable = cat.exe
; EnableCompileCount = 135
; EnableBuildCount = 117