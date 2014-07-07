#MODULE_ACCESS = 1
#MODULE_DESC = "Provides support for controlling a cursor"

XIncludeFile("../include/framework.pbi")

Procedure Lock()
	GetCursorPos_(info.Point)
	rc.RECT\left = info\x-1
	rc\top = info\y-1
	rc\right = info\x
	rc\bottom = info\y
	ClipCursor_(rc)
	send_fdbm("<span style='color:black'>Cursor is now locked</span>")
EndProcedure

Procedure Unlock()
	x = GetSystemMetrics_(#SM_CXSCREEN)
	y = GetSystemMetrics_(#SM_CYSCREEN)
	GetCursorPos_(info.Point)
	
	rc.RECT\left = 0
	rc\top = 0
	rc\right = x
	rc\bottom = y
	ClipCursor_(rc)
	send_fdbm("<span style='color:black'>Cursor is unlocked</span>")	
EndProcedure

Procedure Hide()
	x = GetSystemMetrics_(#SM_CXSCREEN)
	y = GetSystemMetrics_(#SM_CYSCREEN)
	
	rc.RECT\left = x - 1
	rc\top = y - 1
	rc\right = x
	rc\bottom = y
	ClipCursor_(rc)
	send_fdbm("<span style='color:black'>Cursor is now hidden</span>")
EndProcedure

Procedure Unhide()
	Unlock()
	SetCursorPos_(500,500)
	send_fdbm("<span style='color:black'>Cursor is visible</span>")
EndProcedure

Procedure Move(x,y)
	send_fdbm("<span style='color:black'>Moving cursor to <b>"+Str(x)+","+Str(y)+"</b></span>")	
	SetCursorPos_(x,y)
EndProcedure

Procedure AnimateMove(x,y,duration)
	send_fdbm("<span style='color:black'>Moving cursor to <b>"+Str(x)+","+Str(y)+"</b> in "+Str(duration)+" ms</span>")		
	GetCursorPos_(info.Point)
	startX = info\x
	startY = info\y
	
	deltaX.f = x-startX
	deltaY.f = y-startY
	
	starttime = ElapsedMilliseconds()
	
	timefraction.f = 0
	
	While timeFraction < 1.0
		timefraction = (ElapsedMilliseconds() - starttime) / duration
		SetCursorPos_(startX + deltaX* timefraction, startY + deltaY*timefraction)
		Delay(10)
	Wend 
EndProcedure


Procedure RandomMove(steps)
	send_fdbm("<span style='color:black'>Random moving cursor ("+Str(steps)+" steps)</span>")		
	x = GetSystemMetrics_(#SM_CXSCREEN)
	y = GetSystemMetrics_(#SM_CYSCREEN)
	
	For i = 1 To steps
		randx = Random(x)
		randy = Random(y)
		AnimateMove(randx,randy,Random(200)+50)
	Next i 
EndProcedure


Procedure RandomMoveLoop(delay)
	send_fdbm("<span style='color:black'>Random moving cursor with "+Str(delay)+" sec delay (function needs kill in order to stop)</span>")	
	x = GetSystemMetrics_(#SM_CXSCREEN)
	y = GetSystemMetrics_(#SM_CYSCREEN)
	
	Repeat
		randx = Random(x)
		randy = Random(y)
		AnimateMove(randx,randy,Random(200)+50)
		Delay(Random(delay*1000-5000)+5000)
	ForEver 
EndProcedure


DefineFunction("lock",@lock(),"void","Locks the mouse cursor")
DefineFunction("unlock",@unlock(),"void","Unlocks the mouse cursor")
DefineFunction("hide",@hide(),"void","Hides the mouse cursor")
DefineFunction("unhide",@unhide(),"void","Unhides the mouse cursor")
DefineFunction("move",@move(),"int x,int y","Moves the cursor to specified coordinates")
DefineFunction("linmove",@AnimateMove(),"int x,int y,int duration","Moves the cursor to specified coordinates with linear transition")
DefineFunction("randmove",@RandomMove(),"int steps","Moves the cursor at random steps")
DefineFunction("randmoveloop",@RandomMoveLoop(),"int delay","Moves the cursor at random directions with delay")


DefineFunction("?",@man(),"void","Displays info about this command")
send_fdbm("<span style='color:red'>Unknown function: <b> "+com(1)+"</b></span>")

	
	
	






; IDE Options = PureBasic 5.00 (Windows - x86)
; Executable = cursor.exe
; EnabledTools = H5_MODULE_COMPILER
; EnableCompileCount = 283
; EnableBuildCount = 134