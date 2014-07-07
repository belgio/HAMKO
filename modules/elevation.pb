#MODULE_ACCESS = 1

XIncludeFile("../include/framework.pbi")


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

If IsUserAdmin();
	send_fdb("<span style='color:green'><b>We are elevated!</b></span>")
Else
	send_fdb("<span style='color:red'><b>We are not elevated</b></span>")
EndIf
; IDE Options = PureBasic 5.00 (Windows - x86)
; EnableXP