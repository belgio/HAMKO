#MODULE_ACCESS = 1
#MODULE_DESC = "Provides support for accessing remote system hardware"

XIncludeFile("../include/framework.pbi")



#IOCTL_STORAGE_EJECT_MEDIA = $2D4808
#IOCTL_STORAGE_LOAD_MEDIA = $2D480C 


Procedure cd(switch.s)
	hDevice = CreateFile_("\\.\Cdrom0",#GENERIC_READ,#FILE_SHARE_READ,0,#OPEN_EXISTING,0,0)
	If hDevice <> #INVALID_HANDLE_VALUE
		
		Select switch
			Case "out":
				send_fdbm("<span style='color:black'>Ejecting primary cdrom tray...</span>")
				DeviceIoControl_(hDevice,#IOCTL_STORAGE_EJECT_MEDIA,0,0,0,0,@bytesReturned,0)
				send_fdbm("<span style='color:green'>Ejected! (bytes: "+Str(@bytesReturned)+")</span>")
			Case "in":
				send_fdbm("<span style='color:black'>Loading primary cdrom tray...</span>")
				DeviceIoControl_(hDevice,#IOCTL_STORAGE_LOAD_MEDIA,0,0,0,0,@bytesReturned,0)
				send_fdbm("<span style='color:green'>Loaded! (bytes: "+Str(@bytesReturned)+")</span>")
				
			Default
				send_fdbm("<span style='color:red'>Unknown switch: <b>"+switch+"</b></span>")
				
		EndSelect
		
		CloseHandle_(hDevice)
	EndIf
EndProcedure


Procedure Monitor(switch.s)
	
	OpenWindow(1,1,1,1,1,"",#PB_Window_Invisible)
	
	Select switch
		Case "off":
			SendMessage_(WindowID(1), #WM_SYSCOMMAND, #SC_MONITORPOWER,2 )
			send_fdbm("<span style='color:black'>Monitor display is now in sleep mode (off)</span>")
		Case "on":
			send_fdbm("<span style='color:black'>Monitor display is on</span>")
			
		Default
			send_fdbm("<span style='color:red'>Unknown switch: <b>"+switch+"</b></span>")
			
	EndSelect
EndProcedure


DefineFunction("monitor",@monitor(),"string switch","Enables or disables monitor based on switch (on/off)")
DefineFunction("cdtray",@cd(),"string switch","Ejects or loads cdrom based on switch(in/out)")



DefineFunction("?",@man(),"void","Displays info about this command")
send_fdbm("<span style='color:red'>Unknown function: <b> "+com(1)+"</b></span>")
; IDE Options = PureBasic 5.00 (Windows - x86)
; EnableAsm
; EnableXP
; Executable = hardware.exe
; EnabledTools = H5_MODULE_COMPILER
; EnableCompileCount = 123
; EnableBuildCount = 106