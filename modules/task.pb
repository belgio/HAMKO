#MODULE_ACCESS = 1
#MODULE_DESC = "Provides support for managing system processes"

XIncludeFile("../include/framework.pbi")

If ReadFile(0, GetTemporaryDirectory()+"cd")
	SetCurrentDirectory(ReadString(0))
	CloseFile(0)
EndIf 

#PROCESS_TERMINATE = $1
#PROCESS_CREATE_THREAD = $2
#PROCESS_VM_OPERATION = $8
#PROCESS_VM_READ = $10
#PROCESS_VM_WRITE = $20
#PROCESS_DUP_HANDLE = $40
#PROCESS_CREATE_PROCESS = $80
#PROCESS_SET_QUOTA = $100
#PROCESS_SET_INFORMATION = $200
#PROCESS_QUERY_INFORMATION = $400
#PROCESS_ALL_ACCESS = #STANDARD_RIGHTS_REQUIRED | #SYNCHRONIZE | $FFF

Procedure KillProcess (pid)
    phandle = OpenProcess_ (#PROCESS_TERMINATE, #False, pid)
    If phandle <> #Null
        If TerminateProcess_ (phandle, 1)
            result = #True
        EndIf
        CloseHandle_ (phandle)
    EndIf
    ProcedureReturn result
EndProcedure

#PROCESS_ALL_ACCESS_VISTA_WIN7 = $1FFFFF

Prototype.i PFNCreateToolhelp32Snapshot(dwFlags.i, th32ProcessID.i) ;
Prototype.b PFNProcess32First(hSnapshot.i, *lppe.PROCESSENTRY32) ;
Prototype.b PFNProcess32Next(hSnapshot.i, *lppe.PROCESSENTRY32) ;

Procedure GetPidByName(p_name$) 
    Protected hDLL.i, process_name$ 
    Protected PEntry.PROCESSENTRY32, hTool32.i 
    Protected pCreateToolhelp32Snapshot.PFNCreateToolhelp32Snapshot 
    Protected pProcess32First.PFNProcess32First 
    Protected pProcess32Next.PFNProcess32Next 
    Protected pid.i 
    
    hDLL = OpenLibrary(#PB_Any,"kernel32.dll") 
    
    If hDLL 
        pCreateToolhelp32Snapshot = GetFunction(hDLL,"CreateToolhelp32Snapshot") 
        pProcess32First = GetFunction(hDLL,"Process32First") 
        pProcess32Next = GetFunction(hDLL,"Process32Next") 
    Else 
        ProcedureReturn 0 
    EndIf 
    
    PEntry\dwSize = SizeOf(PROCESSENTRY32) 
    hTool32 = pCreateToolhelp32Snapshot(#TH32CS_SNAPPROCESS, 0) 
    pProcess32First(hTool32, @PEntry) 
    process_name$ = Space(#MAX_PATH) 
    CopyMemory(@PEntry\szExeFile,@process_name$,#MAX_PATH) 
    
    If  UCase(process_name$) = UCase(p_name$) 
        ProcedureReturn PEntry\th32ProcessID 
    EndIf 
    
    While pProcess32Next(hTool32, @PEntry) > 0 
        process_name$ = Space(#MAX_PATH) 
        CopyMemory(@PEntry\szExeFile,@process_name$,#MAX_PATH) 
        
        If  UCase(process_name$) = UCase(p_name$) 
            ProcedureReturn PEntry\th32ProcessID 
        EndIf 
    
    Wend 
    
    CloseLibrary(hDLL) 
    
    ProcedureReturn 0 
EndProcedure


Procedure tasklist()
	outbuffer.s = "Listing running processes:<br>"
	outbuffer.s + "<table cellspacing='0' border = '1' style='width:500px'>"
	
	#TH32CS_SNAPHEAPLIST = $1
	#TH32CS_SNAPPROCESS = $2
	#TH32CS_SNAPTHREAD = $4
	#TH32CS_SNAPMODULE = $8
	#TH32CS_SNAPALL = #TH32CS_SNAPHEAPLIST | #TH32CS_SNAPPROCESS | #TH32CS_SNAPTHREAD | #TH32CS_SNAPMODULE
	#TH32CS_INHERIT = $80000000
	#INVALID_HANDLE_VALUE = -1
	#PROCESS32LIB = 9999
	
	NewList Process32.PROCESSENTRY32 ()
	
	If OpenLibrary (#PROCESS32LIB, "kernel32.dll")
		snap = CallFunction (#PROCESS32LIB, "CreateToolhelp32Snapshot", #TH32CS_SNAPPROCESS, 0)
		If snap
			Define.PROCESSENTRY32 Proc32
			Proc32\dwSize = SizeOf (PROCESSENTRY32)
			
			If CallFunction (#PROCESS32LIB, "Process32First", snap, @Proc32)
				
				AddElement (Process32 ())
				CopyMemory (@Proc32, @Process32 (), SizeOf (PROCESSENTRY32))
				
				While CallFunction (#PROCESS32LIB, "Process32Next", snap, @Proc32)
					AddElement (Process32 ())
					CopyMemory (@Proc32, @Process32 (), SizeOf (PROCESSENTRY32))
				Wend
			EndIf    
			CloseHandle_ (snap)
		EndIf
		CloseLibrary (#PROCESS32LIB)
	EndIf
	
	ResetList (Process32 ())
	
	outbuffer + "<tr><th><center>PID</center></th><th><center>Name</center></th><th><center>Status</center></th></tr>"
	
	While NextElement (Process32 ())
		If  PeekS (@Process32 ()\szExeFile) <> "[System Process]"
			pid=GetPidByName(PeekS (@Process32 ()\szExeFile))
			outbuffer+ "<tr><td align='middle'>"+Str(pid)+"</td><td align='middle'>"+ PeekS (@Process32 ()\szExeFile)+"</td><td align='middle'>Running</td></tr>"
		EndIf 
	Wend
	
	outbuffer+"</table>"
	send_fdbm(outbuffer)
EndProcedure

Procedure exec(task.s,args.s)
	status.l=ShellExecute_(GetForegroundWindow_(), #Null, task,args, #Null, #SW_SHOWNORMAL)
	If status = 42
		send_fdbm("<span style='color:green'>Successfully created process <b>"+task+"</b></span>")
	Else
		send_fdbm("<span style='color:red'>Failed with status <b>"+Str(status)+"</b> (for more info see <a href='http://msdn.microsoft.com/en-us/library/windows/desktop/bb762153(v=vs.85).aspx' target='_blank'>here</a>)</span>")
	EndIf 
EndProcedure

Procedure killpid(pid)
	If KillProcess(pid)
		send_fdbm("<span style='color:green'>Killed process with PID <b>"+Str(pid)+"</b></span>")
	Else
		send_fdbm("<span style='color:red'>The process with PID <b>"+Str(pid)+"</b> does not exist!</span>")
	EndIf 
EndProcedure

Procedure killname(name.s)
	pid = GetPidByName(name)
	
	If KillProcess(pid)
		send_fdbm("<span style='color:green'>Killed process <b>"+name+"</b> with PID <b>"+Str(pid)+"</b></span>")
	Else
		send_fdbm("<span style='color:red'>The process <b>"+name+"</b> does not exist!</span>")
	EndIf 
EndProcedure

Procedure.l EnumWindowsProc(hWnd.l, lParam.l)
	Shared RunProgram_WindowID.l
	If GetWindowThreadProcessId_(hWnd, 0) = lParam
		RunProgram_WindowID = hWnd
		ProcedureReturn #False
	Else
		ProcedureReturn #True
	EndIf
EndProcedure

Procedure.l RunProgram2(Filename.s, Parameter.s)
	Directory.s = GetCurrentDirectory()
	Shared RunProgram_WindowID.l
	Info.STARTUPINFO
	Info\cb = SizeOf(STARTUPINFO)
	ret = CreateProcess_(@Filename, @Parameter, 0, 0, 0, 0, 0, @Directory, @Info, @ProcessInfo.PROCESS_INFORMATION)
	If ret
		send_fdbm("<span style='color:green'>Successfully created process <b>"+Filename.s+"</b></span>")
	Else
		send_fdbm("<span style='color:red'>Failed with status <b>"+Str(GetLastError_())+"</b> (for more info see <a href='http://msdn.microsoft.com/en-us/library/windows/desktop/ms681381%28v=vs.85%29.aspx' target='_blank'>here</a>)</span>")
	EndIf 
	RunProgram_WindowID = 0
	EnumWindows_(@EnumWindowsProc(), ProcessInfo\dwThreadId)
	SetForegroundWindow_(RunProgram_WindowID)
	ProcedureReturn RunProgram_WindowID
EndProcedure

Procedure GetAV()
	
	If GetPidByName("AvastSvc.exe") <> 0
		send_fdbm("<span style='color:orange'>Detected <b>AVAST</b> antivirus (version 2014.9.0.2018)</span>")
	Else
		send_fdbm("<span style='color:black'>Cannot detect antivirus</span>")
	EndIf 
	
EndProcedure


DefineFunction("list",@tasklist(),"void","Displays a list with running processes")
DefineFunction("new",@exec(),"string task,string args","Creates a new process")
DefineFunction("create",@RunProgram2(),"string task,string args","Creates a new process in foreground (alternative to 'new')")
DefineFunction("killpid",@killpid(),"int pid","Terminates a process with the provided id")
DefineFunction("killname",@killname(),"string name","Terminates a process with the provided name")
DefineFunction("getav",@getAv(),"void","Tries to detect the antivirus (if exist)")



DefineFunction("?",@man(),"void","Displays info about this command")
send_fdbm("<span style='color:red'>Unknown function: <b> "+com(1)+"</b></span>")

; IDE Options = PureBasic 5.00 (Windows - x86)
; Executable = task.exe
; EnabledTools = H5_MODULE_COMPILER
; EnableCompileCount = 146
; EnableBuildCount = 128