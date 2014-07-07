
#MODULE_ACCESS = 1


XIncludeFile("../include/framework.pbi")

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


Procedure.b GetNamePID(ProcessName.s,*ptrPID.l)
  Protected HSnap.l,Prec.processentry32,result.l=#False
  HSnap=CreateToolhelp32Snapshot_(#TH32CS_SNAPPROCESS,0)
  If HSnap=#INVALID_HANDLE_VALUE 
    ProcedureReturn result
  EndIf
  Prec\dwSize=SizeOf(prec)
  If Not Process32First_(HSnap,Prec)
    ProcedureReturn result
  EndIf
  Repeat
    If LCase(GetFilePart(PeekS(@Prec\szexefile)))=LCase(ProcessName)
      PokeL(*ptrPID,Prec\th32ProcessID)
      result=#True
      Break
    EndIf
  Until Not Process32Next_(HSnap,Prec)
  CloseHandle_(HSnap)
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

If Val(com(1)) <> 0 
	If KillProcess(Val(com(1)))
		send_fdb("<span style='color:green'>Killed process with PID <b>"+com(1)+"</b></span>")
	Else
		send_fdb("<span style='color:red'>The process with PID <b>"+com(1)+"</b> does not exist in target OS</span>")
	EndIf 
Else
	pid = GetPidByName(com(1))
	
	If KillProcess(pid)
		send_fdb("<span style='color:green'>Killed process <b>"+com(1)+"</b> with PID <b>"+Str(pid)+"</b></span>")
	Else
		send_fdb("<span style='color:red'>The process <b>"+com(1)+"</b> does not exist in target OS</span>")
	EndIf 
	
EndIf 
End 
; IDE Options = PureBasic 5.00 (Windows - x86)
; Executable = kill.exe