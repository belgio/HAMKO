#MODULE_ACCESS = 1

XIncludeFile("../include/framework.pbi")

UseJPEGImageEncoder()

ScreenX = GetSystemMetrics_(#SM_CXSCREEN)
ScreenY = GetSystemMetrics_(#SM_CYSCREEN)

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

ScreenCaptureAddress = CaptureScreen(0, 0, ScreenX,ScreenY)

CreateImage(0, ScreenX, ScreenY)
StartDrawing(ImageOutput(0))
    DrawImage(ScreenCaptureAddress, 0, 0)
StopDrawing()


img.s = Str(Date())+".jpg"

SaveImage(0, GetTemporaryDirectory()+img ,#PB_ImagePlugin_JPEG,Val(com(1)))


send_fdb("<span style='color:green'>Screenshot captured: ~/"+img.s+"</span>")


; IDE Options = PureBasic 5.00 (Windows - x86)
; Executable = screenshot.exe