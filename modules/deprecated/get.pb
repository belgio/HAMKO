#MODULE_ACCESS = 2

XIncludeFile("../include/framework.pbi")

If ReadFile(0, GetTemporaryDirectory()+"cd")
	SetCurrentDirectory(ReadString(0))
	CloseFile(0)
EndIf 


com(1) = ReplaceString(com(1),"~/",GetTemporaryDirectory())
;com(1)="fystiki.dll"

handle.l = ReadFile(#PB_Any,com(1));
If handle
    Size.l=Lof(handle)
    send_fdbm("Initializing file transfer (" +Str(size)+" bytes) ...")
    *FileData = AllocateMemory(Size)
    ReadData(handle,*FileData,Size)
    CloseFile(handle)
    Size2.l= Size * 1.35
    *NewFileData = AllocateMemory(Size2)
    EncSize = Base64Encoder(*FileData, Size, *NewFileData, Size2)
    
    ret.s = send_file(com(1),PeekS(*NewFileData,EncSize))
 
    ;send_fdbm("Upload returned: "+ret)
    ;If Trim(ret) <> "?1" Or Trim(ret) <> ""
   ; 	send_fdbm("<span style='color:red'>File transfer interrupted with code </span>"+ret)
   ; 	End
   ; EndIf 
    Repeat
    	Delay(1000)
    	If GET_(svr_path+"instances/"+hostname+"/files/"+GetFilePart(com(1)))
   		send_fdbm("<span style='color:green'>Upload completed! <a href='../instances/"+hostname+"/files/"+GetFilePart(com(1))+"' target='_blank'>"+GetFilePart(com(1))+"</a></span>")
    		End 
    	EndIf 
    	x+1
    Until x > 600
    	
    send_fdbm("<span style='color:red'>File transfer timed-out</span>")

Else
	send_fdbm("<span style='color:red'>File <b> "+com(1)+"</b> not found</span>")
EndIf 



; IDE Options = PureBasic 5.00 (Windows - x86)
; Executable = get.exe