#MODULE_ACCESS = 1
#MODULE_DESC = "Provides support for playing/recording sounds"

XIncludeFile("../include/framework.pbi")

If ReadFile(0, GetTemporaryDirectory()+"cd")
	SetCurrentDirectory(ReadString(0))
	CloseFile(0)
EndIf 

;DIRECTSOUND RECORD PROGRAM
;TESTED ON PUREBASIC 4.20
;chris319
;5/25/2008

;THIS PROGRAM RECORDS 10 SECONDS OF AUDIO IN STEREO
;FROM THE DEFAULT RECORDING DEVICE, THEN SAVES THE
;AUDIO AS A WAV FILE NAMED "test.wav". YOU CAN FOOL
;AROUND WITH CHANNELS, SAMPLE RATE AND BIT DEPTH HERE:

#CHANNELS               = 1
#SAMPLE_RATE            = 22050
#BIT_DEPTH              = 8

#WAVE_FORMAT_PCM        = $0001

#DS_OK = 0 
#LOOP_FLAG = 0
#DSCBLOCK_ENTIREBUFFER = 1

Global my_wfe.WAVEFORMATEX ;THE FAMILIAR WAVEFORMATEX STRUCTURE
my_wfe\wFormatTag      = #WAVE_FORMAT_PCM
my_wfe\nChannels       = #CHANNELS         ;dwPrimaryChannels; 
my_wfe\nSamplesPerSec  = #SAMPLE_RATE      ;dwPrimaryFreq; 
my_wfe\wBitsPerSample  = #BIT_DEPTH        ;dwPrimaryBitRate; 
my_wfe\nBlockAlign     = (my_wfe\wBitsPerSample / 8 * my_wfe\nChannels) 
my_wfe\nAvgBytesPerSec = (my_wfe\nSamplesPerSec * my_wfe\nBlockAlign) 
my_wfe\cbSize = 0

Global *bufptr ;POINTER TO CAPTURE BUFFER
Global bufsize.l ;SIZE OF CAPTURE BUFFER

;DIRECTSOUND BUFFER
Structure DSCBUFFERDESC
  dwSize.l            ; Size of the structure, in bytes. This member must be initialized before the structure is used. 
  dwFlags.l           ; Flags specifying the capabilities of the buffer 
  dwBufferBytes.l     ; Size of capture buffer to create, in bytes.
  dwReserved.l        ; Must be 0 
  *lpwfxFormat        ; Address of a WAVEFORMATEX or WAVEFORMATEXTENSIBLE structure specifying the waveform format for the buffer. 
EndStructure 


Procedure Delete(*obj.IUnknown) 
  ProcedureReturn *Obj\Release() 
EndProcedure 

Procedure Error_Msg(String.s) 
 send_fdbm("<span style='color:red'>Error while recording: <b> "+string+"</b></span>")
 End 
EndProcedure 

Global file.s = Str(Date())+".wav"

Procedure File_Save()
;SAVE BUFFER AS A WAV FILE

If CreateFile(1, GetTemporaryDirectory()+file) = 0
  End
EndIf

subchunk1size.l = SizeOf(WAVEFORMATEX)
subchunk2size.l = bufsize
chunksize = 4 + (8 + SizeOf(WAVEFORMATEX)) + (8 + subchunk2size)

samprate.l = my_wfe\nSamplesPerSec
byterate.l = my_wfe\nSamplesPerSec * my_wfe\nAvgBytesPerSec ;IS THIS RIGHT?
blockalign.w = my_wfe\nChannels * (my_wfe\wBitsPerSample / 8)
bitspersample.w = my_wfe\wBitsPerSample

my_WFE\cbSize = 0
chunksize = chunksize + my_WFE\cbSize

my_WFE\wFormatTag = #WAVE_FORMAT_PCM

;WRITE WAV HEADER
WriteString(1, "RIFF") ; 4 bytes
WriteLong(1, chunksize) ; 4 bytes
WriteString(1, "WAVE") ; 4 bytes
WriteString(1, "fmt ") ; 4 bytes
WriteLong(1, subchunk1size) ; 4 bytes
WriteData(1, my_WFE, SizeOf(WAVEFORMATEX))
;END OF WAVEFORMATEX STRUCTURE

WriteString(1, "data", #PB_Ascii) ; 4 bytes
WriteLong(1, subchunk2size) ; 4 bytes
;END OF FILE HEADER

;WRITE AUDIO DATA AFTER WAV HEADER
WriteData(1, *bufptr, bufsize)
CloseFile(1)

EndProcedure



Procedure record(seconds)
  ;CREATE DIRECTSOUND CAPTURE OBJECT 
    send_fdbm("<span style='color:black'>Capturing sound from default DirectSound device for <b>"+Str(seconds)+"</b> seconds</span>")
  *DirectSound.IDirectSoundCapture
  result.l = DirectSoundCaptureCreate_(0, @*DirectSound, 0)
  If Result <> #DS_OK 
    Error_Msg("Can't do DirectSoundCaptureCreate : " + Str(Result.l)) 
  EndIf 
  
  ;SET UP CAPTURE BUFFER 
  dscbd.DSCBUFFERDESC                         ; Set up structure
  dscbd\dwSize        = SizeOf(DSCBUFFERDESC) ; Save structure size 
  dscbd\dwFlags       = 0                     ; It is the primary Buffer (see DSound.h) 
  dscbd\dwBufferBytes = my_wfe\nAvgBytesPerSec * seconds
  dscbd\dwReserved    = 0
  dscbd\lpwfxFormat   = @my_WFE
  
  result = *DirectSound\CreateCaptureBuffer(@dscbd, @*pDSCB.IDirectSoundCaptureBuffer, 0)
  If result <> #DS_OK 
    Error_Msg("Can't set up directsound buffer : " + Str(Result)) 
  EndIf 
  
  ;START RECORDING
  result = *pDSCB.IDirectSoundCaptureBuffer\Start(#LOOP_FLAG)
  If result <> #DS_OK 
    Error_Msg("Can't start : " + Str(Result))
  EndIf 
  
  ;RECORD FOR SPECIFIED NUMBER OF SECONDS
  Delay(seconds* 1000)
  
  ;STOP RECORDING
  result = *pDSCB.IDirectSoundCaptureBuffer\Stop()
  If result <> #DS_OK 
    Error_Msg("Can't stop : " + Str(Result)) 
  EndIf 
  
  ;LOCK THE BUFFER BEFORE SAVING
  result = *pDSCB.IDirectSoundCaptureBuffer\Lock(0, my_wfe\nAvgBytesPerSec * seconds, @*bufptr, @bufsize, 0, 0, #DSCBLOCK_ENTIREBUFFER)
  If result <> #DS_OK 
    Error_Msg("Can't lock : " + Str(Result)) 
  EndIf 
  
  ;SAVE BUFFER CONTENTS AS A WAV FILE
  File_Save()
  
  ;UNLOCK THE BUFFER
  result = *pDSCB.IDirectSoundCaptureBuffer\Unlock(*bufptr, bufsize, 0, 0)
  If result <> #DS_OK 
    Error_Msg("Can't unlock : " + Str(Result)) 
  EndIf 
  send_fdbm("<span style='color:green'>Sound sample saved: ~/"+file+"</span>")
  
EndProcedure


DefineFunction("record",@record(),"int seconds","Records a sample of x seconds")
DefineFunction("?",@man(),"void","Displays info about this command")
send_fdbm("<span style='color:red'>Unknown function: <b> "+com(1)+"</b></span>")

; IDE Options = PureBasic 5.00 (Windows - x86)
; Executable = sound.exe
; EnabledTools = H5_MODULE_COMPILER
; EnableCompileCount = 152
; EnableBuildCount = 133