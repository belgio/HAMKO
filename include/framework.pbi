; H5 module framework SDK
; authored by anelehto
; 
; This include provides a standard communication layer between the module and the main executable
; Therefore it should be included in all modules to ensure the correct functionality of H5

Enumeration
	#ACCESS_NONE  		; No communication with server 
	#ACCESS_BASIC 		; Basic communication using H5 layer
	#ACCESS_DIRECT 	; Direct communication
EndEnumeration

; NOTE: 
; for normal communication (e.g return a string < 1000 bytes), use basic mode. 
; the string is passed as a parameter to a new instance which sends the string 
; to server and then exits
;
; use direct communication only if the module relies on heavy network usage
; it adds a small overhead (~ 4 KB) and may trigger the defensive routines of 
; some antivirus software

IncludePath "../include" 

Global NewList arg.s()

args.s = ProgramParameter(1)

For idx = 1 To CountString(args,"#") +1
  AddElement(arg())
  arg() = StringField(args,idx,"#")
Next idx 


Global Dim com.s(ListSize(arg()))

ForEach arg()
	com(x) = arg()
	x+1
Next 

FreeList(arg())

com(0) = ProgramParameter(0)  

If com(0) = Space(0)
	End
EndIf 

CompilerSelect #MODULE_ACCESS
		
	CompilerCase #ACCESS_NONE
		
	CompilerCase #ACCESS_BASIC
		
		Procedure send_fdbm(msg.s)
			RunProgram(ProgramParameter(0),Chr(34)+"FDB"+Chr(34)+" " + Chr(34)+msg + Chr(34)+" " + Chr(34) + RemoveString(GetFilePart(ProgramFilename()),"."+GetExtensionPart(ProgramFilename())) + Chr(34),GetCurrentDirectory())
		EndProcedure
		
		
	CompilerCase #ACCESS_DIRECT
		XIncludeFile("./common.pbi")
		
		Procedure send_fdbm(msg.s)
			send_fdb("<span style='color:#A0A0A0'><b>#"+ RemoveString(GetFilePart(ProgramFilename()),"."+GetExtensionPart(ProgramFilename()))+" > </b></span>"+msg+"")
		EndProcedure
		
CompilerEndSelect



Macro DefineVar(name,value,type)
	name#.type = value
EndMacro

Procedure.i _call(hFunc,Array args.l(1))
  Protected size.l=ArraySize(args()), res.i
   If hFunc
      !PUSH ebp
      !MOV ebx,dword[p.v_size+4]
      !MOV ebp, esp
      !MOV eax,dword[p.v_hFunc+4]
      !OR  ebx,ebx
      !JZ .noargs
      !MOV edi,dword[p.a_args+4]
      !MOV edi,dword[edi]
      !@@:PUSH dword[edi+ebx*4]
      !DEC ebx
      !JNZ @r
      !.noargs:
      !CALL eax
      !MOV esp, ebp
      !POP ebp
      !MOV dword[p.v_res],eax
   EndIf
  ProcedureReturn res
EndProcedure


Procedure.l IsInt(str.s)
	Shared is_nn.s
	Shared nnptr.l

	is_nn = str
	nnptr = 0
	! CLD
	! MOV ESI, [v_is_nn] 
	inloop:
	! lodsb
	! TEST al, al
	! JZ  l_innull                  
	! CMP al, $39                            
	! JA l_nnfound                  
	! CMP  al, $30                               
	! JB l_nnfound                
	! JMP l_inloop                     
	nnfound:                          
	!SUB ESI, [v_is_nn]  
	!MOV [v_nnptr], ESI                  
	innull:                           
	
	ProcedureReturn nnptr
EndProcedure


Global NewList com_name.s()
Global NewList com_args.s()
Global NewList com_desc.s()

Procedure DefineFunction(cmd.s,proc.l,args.s,desc.s)
	AddElement(com_name()): com_name() = cmd
	AddElement(com_args()): com_args() = args
	AddElement(com_desc()): com_desc() = desc
	
	If com(1) <> cmd
		ProcedureReturn 0
	EndIf 
	
	totalargs = CountString(args,",") +1
	
	If totalargs <> 1 And ArraySize(com()) -2 <> 0
		If totalargs <> ArraySize(com()) -2
			send_fdbm("<span style='color:red'>Incorrect arguments, function expects <b>"+Str(totalargs)+"</b> and you provided <b>"+Str(ArraySize(com()) -2)+"</b></span>")
			End 
		EndIf 
	EndIf 
	
	Protected Dim amap.l(totalargs)
		
	For idx = 2 To totalargs +1
		argtype.s = StringField(StringField(args,idx-1,","),1,Space(1))
		argdesc.s = StringField(StringField(args,idx-1,","),2,Space(1))
		
		Select argtype
			Case "void"
				
			Case "int"
				If isInt(com(idx)) 
					send_fdbm("<span style='color:red'>Incorrect argument type, function expects <b>int</b></span>")
					End 
				EndIf 
				amap(idx-1) = Val(com(idx))

			Case "string"
				amap(idx-1) = @com(idx)
		EndSelect
	Next idx 
	
	_call(proc,amap())
	End 
EndProcedure

Procedure man()
	outbuffer.s = #MODULE_DESC
	
	If ListSize(com_name()) = 1 
		send_fdbm(outbuffer)
		End
	EndIf 
	
	outbuffer.s + "<br><table cellspacing='0' border = '1' style='width:800px'>"
	outbuffer + "<tr><th><center>Function</center></th><th><center>Arguments</center></th><th><center>Description</center></th></tr>"
	
	ResetList(com_name())
	ResetList(com_args())
	ResetList(com_desc())
	
	For i = 1 To ListSize(com_name())
		NextElement(com_name())
		NextElement(com_args())
		NextElement(com_desc())
		If com_name() <> "help" And  com_name() <> "?" And  com_name() <> "man"
			outbuffer+ "<tr><td align='middle'>"+com_name()+"</td><td align='middle'>"+com_args()+"</td><td align='middle'>"+com_desc()+"</td></tr>"
		EndIf
	Next i
	
	outbuffer+"</table>"
	send_fdbm(outbuffer)
	End 
EndProcedure


; IDE Options = PureBasic 5.00 (Windows - x86)
; EnableXP
; EnableCompileCount = 0
; EnableBuildCount = 0