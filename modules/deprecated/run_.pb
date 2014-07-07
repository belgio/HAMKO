#MODULE_ACCESS = 1

XIncludeFile("../include/framework.pbi")

If ReadFile(0, GetTemporaryDirectory()+"cd")
	SetCurrentDirectory(ReadString(0))
	CloseFile(0)
EndIf 





hWnd = GetForegroundWindow_()
app$ = GetCurrentDirectory()+com(1) ; Full path needed!
ThreadID = RunProgram(app$, "", GetPathPart(app$), #PB_Program_Open) ;,#SW_NORMAL)
timeout  = 500
Repeat
  Delay(200): timeout-1
  hWnd1 = GetForegroundWindow_()
  If hWnd<>hWnd1
     GetWindowThreadProcessId_(hWnd1,@programid) 
  EndIf
Until (hWnd1<>hWnd And programid=ProgramID(ThreadID)) Or timeout<1
If (hWnd1<>hWnd And programid = ProgramID(ThreadID)) And timeout>1
   hWnd = hWnd1
   ShowWindow_(hWnd, #SW_SHOW) ;HIDE) 
EndIf
; IDE Options = PureBasic 5.00 (Windows - x86)
; EnableXP
; Executable = run_.exe