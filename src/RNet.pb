; Macros for double quotes
Macro DQuote
  "
EndMacro
; Define the ImportLib
CompilerSelect #PB_Compiler_Thread
  CompilerCase #False ;{ THREADSAFE : OFF
    CompilerSelect #PB_Compiler_OS
      CompilerCase #PB_OS_Linux         : #Power_ObjectManagerLib = #PB_Compiler_Home + "compilers/objectmanager.a"
      CompilerCase #PB_OS_Windows   : #Power_ObjectManagerLib = #PB_Compiler_Home + "compilers\ObjectManager.lib"
    CompilerEndSelect
  ;}
  CompilerCase #True ;{ THREADSAFE : ON
    CompilerSelect #PB_Compiler_OS
      CompilerCase #PB_OS_Linux         : #Power_ObjectManagerLib = #PB_Compiler_Home + "compilers/objectmanagerthread.a"
      CompilerCase #PB_OS_Windows   : #Power_ObjectManagerLib = #PB_Compiler_Home + "compilers\ObjectManagerThread.lib"
    CompilerEndSelect
  ;}
CompilerEndSelect
; Macro ImportFunction
Macro ImportFunction(Name, Param)
  CompilerSelect #PB_Compiler_OS
    CompilerCase #PB_OS_Linux ;{
        DQuote#Name#DQuote
    ;}
    CompilerCase #PB_OS_Windows ;{
        DQuote _#Name@Param#DQuote
    ;}
  CompilerEndSelect
EndMacro
; Import the ObjectManager library
CompilerSelect #PB_Compiler_OS
  CompilerCase #PB_OS_Linux : ImportC #Power_ObjectManagerLib
  CompilerCase #PB_OS_Windows : Import #Power_ObjectManagerLib
CompilerEndSelect
  Object_GetOrAllocateID(Objects, Object.l) As ImportFunction(PB_Object_GetOrAllocateID, 8)
  Object_GetObject(Objects, Object.l) As ImportFunction(PB_Object_GetObject, 8)
  Object_IsObject(Objects, Object.l) As ImportFunction(PB_Object_IsObject, 8)
  Object_EnumerateAll(Objects, ObjectEnumerateAllCallback, *VoidData) As ImportFunction(PB_Object_EnumerateAll, 12)
  Object_EnumerateStart(Objects) As ImportFunction(PB_Object_EnumerateStart, 4)
  Object_EnumerateNext(Objects, *object.Long) As ImportFunction(PB_Object_EnumerateNext, 8)
  Object_EnumerateAbort(Objects) As ImportFunction(PB_Object_EnumerateAbort, 4)
  Object_FreeID(Objects, Object.l) As ImportFunction(PB_Object_FreeID, 8)
  Object_Init(StructureSize.l, IncrementStep.l, ObjectFreeFunction) As ImportFunction(PB_Object_Init, 12)
  Object_GetThreadMemory(MemoryID.l) As ImportFunction(PB_Object_GetThreadMemory, 4)
  Object_InitThreadMemory(Size.l, InitFunction, EndFunction) As ImportFunction(PB_Object_InitThreadMemory, 12)
EndImport

  IncludePath #PB_Compiler_FilePath
  XIncludeFile "RNet_Inc_HTTP.pb"
  
  ProcedureDLL RNet_Free(ID.l)
    Protected *RObject.S_RNet
  	If *RObject
;   	  Select *RObject\lType
;   	    Case #RNet_Type_FTP
;   	    ;{
;   	      If *RObject\FTP\Connexion <> 0
;   	        RNet_FTP_Disconnect(ID)
;   	      EndIf
;   	    ;}
;   	  EndSelect
  	  RNet_Free(Id)
  	  ProcedureReturn #True
  	Else
      ProcedureReturn #False
    EndIf
  EndProcedure
  ProcedureDLL RNet_Init()
    Global RNetObjects 
    RNetObjects = RNET_INITIALIZE(@RNet_Free())
  EndProcedure
  ProcedureDLL RNet_CreateClient(ID.l, Type.l)
    Protected *RObject.S_RNet = RNET_NEW(ID)
    If *RObject
      With *RObject
        \lType = Type
        Select \lType
          Case #RNet_Type_HTTP
            \HTTP\Has_Proxy         = #False
            \HTTP\State             = #RNet_State_Idle
            \HTTP\Infos_HTTPVersion = "HTTP/1.1"
  ;         Case #RNet_Type_POP
  ;           \POP\Mail = AllocateMemory(SizeOf(S_RNet_Mail))
  ;         Case #RNet_Type_NNTP
  ;           \NNTP\Mail = AllocateMemory(SizeOf(S_RNet_Mail))
  ;         Case #RNet_Type_IMAP
  ;           \IMAP\Mail = AllocateMemory(SizeOf(S_RNet_Mail))
  ;         Case #RNet_Type_SMTP
  ;           \SMTP\Mail = AllocateMemory(SizeOf(S_RNet_Mail))
        EndSelect
      EndWith
      ProcedureReturn *RObject
    Else
      ProcedureReturn #False
    EndIf
  EndProcedure
  ProcedureDLL RNet_IsClient(ID.l)
    ProcedureReturn RNet_IS(ID)
  EndProcedure
  ProcedureDLL RNet_GetLastError(Id.l)
    Protected *RObject.S_RNet = RNET_ID(Id)
    If *RObject
      With *RObject
        ProcedureReturn \lLastError
      EndWith
    Else
      ProcedureReturn #False
    EndIf
  EndProcedure

