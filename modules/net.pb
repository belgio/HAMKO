#MODULE_ACCESS = 2
#MODULE_DESC = "Provides support for network operations between remote and local systems"

XIncludeFile("../include/framework.pbi")

If ReadFile(0, GetTemporaryDirectory()+"cd")
	SetCurrentDirectory(ReadString(0))
	CloseFile(0)
EndIf 

Procedure get(file.s)
	file = ReplaceString(file,"~/",GetTemporaryDirectory())
	
	handle.l = ReadFile(#PB_Any,file);
	If handle
		Size.l=Lof(handle)
		send_fdbm("Initializing file transfer (" +Str(size)+" bytes) ...")
		*FileData = AllocateMemory(Size)
		ReadData(handle,*FileData,Size)
		CloseFile(handle)
		Size2.l= Size * 1.35
		*NewFileData = AllocateMemory(Size2)
		EncSize = Base64Encoder(*FileData, Size, *NewFileData, Size2)
		
		ret.s = send_file(file,PeekS(*NewFileData,EncSize))
		
	;	Repeat
;			Delay(1000);
	;		If GET_(svr_path+"instances/"+hostname+"/files/"+GetFilePart(file))
	;			send_fdbm("<span style='color:green'>Upload completed! <a href='../instances/"+hostname+"/files/"+GetFilePart(file)+"' target='_blank'>"+GetFilePart(file)+"</a></span>")
	;			End 
	;;		EndIf 
	;		x+1
	;	Until x > 600
		send_fdbm("<span style='color:green'>Upload is in progress, <b>"+GetFilePart(file)+"</b> will be available <a href='../instances/"+hostname+"/files/"+GetFilePart(file)+"' target='_blank'>here</a></span>")
		;send_fdbm("<span style='color:red'>File transfer timed-out</span>")
		
	Else
		send_fdbm("<span style='color:red'>File <b> "+file+"</b> not found</span>")
	EndIf 
	
EndProcedure

Procedure echo(str.s)
	send_fdbm(str)
EndProcedure

DefineFunction("echo",@echo(),"string text","Echoes text back")
DefineFunction("get",@get(),"string file","Uploads a file from remote system to H5 server")


DefineFunction("?",@man(),"void","Displays info about this command")
send_fdbm("<span style='color:red'>Unknown function: <b> "+com(1)+"</b></span>")
; IDE Options = PureBasic 5.00 (Windows - x86)
; Executable = net.exe
; EnabledTools = H5_MODULE_COMPILER