#MODULE_ACCESS = 1
#MODULE_DESC = "Provides support for accessing the windows interface"

XIncludeFile("../include/framework.pbi")

Procedure.l CaptureScreen(Left.l, Top.l, Width.l, Height.l)
    dm.DEVMODE
    BMPHandle.l
    srcDC = CreateDC_("DISPLAY", "", "", dm)
    trgDC = CreateCompatibleDC_(srcDC)
    BMPHandle = CreateCompatibleBitmap_(srcDC, Width, Height)
    SelectObject_( trgDC, BMPHandle)
    BitBlt_( trgDC, 0, 0, Width, Height, srcDC, Left, Top, #SRCCOPY)
    DeleteDC_( trgDC)
    ReleaseDC_( BMPHandle, srcDC)
    ProcedureReturn BMPHandle
EndProcedure

Procedure ScreenShot(quality)
	UseJPEGImageEncoder()
	ScreenX = GetSystemMetrics_(#SM_CXSCREEN)
	ScreenY = GetSystemMetrics_(#SM_CYSCREEN)
	ScreenCaptureAddress = CaptureScreen(0, 0, ScreenX,ScreenY)
	
	CreateImage(0, ScreenX, ScreenY)
	StartDrawing(ImageOutput(0))
	DrawImage(ScreenCaptureAddress, 0, 0)
	StopDrawing()
	
	img.s = Str(Date())+".jpg"
	
	SaveImage(0, GetTemporaryDirectory()+img ,#PB_ImagePlugin_JPEG,quality)
	send_fdbm("<span style='color:green'>Screenshot captured: ~/"+img.s+"</span>")
EndProcedure

Procedure msgbox(title.s,body.s,flags.l)
	send_fdbm("Displaying messagebox...")
	res = MessageRequester(title,body,flags)
	send_fdbm("User closed messagebox ["+Str(res)+"]")
EndProcedure


DefineFunction("msgbox",@msgbox(),"string title,string body,int flags","Displays a message box dialog")
DefineFunction("screenshot",@screenshot(),"int quality","Captures a screenshot with a quality scale between 1-10")

DefineFunction("?",@man(),"void","Displays info about this command")
send_fdbm("<span style='color:red'>Unknown function: <b> "+com(1)+"</b></span>")
; IDE Options = PureBasic 5.00 (Windows - x86)
; EnableUnicode
; EnableXP
; Executable = interface.exe
; EnabledTools = H5_MODULE_COMPILER
; EnableCompileCount = 66
; EnableBuildCount = 52