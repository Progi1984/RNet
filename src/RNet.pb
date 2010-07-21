CompilerIf #PB_Compiler_Thread ;>
  #ObjectManager = "compilers/objectmanagerthread.a"
CompilerElse ;=
  #ObjectManager = "compilers/objectmanager.a"
CompilerEndIf;<

ImportC #PB_Compiler_Home + #ObjectManager
  Object_GetOrAllocateID   (Objects, Object.l) As "PB_Object_GetOrAllocateID"
  Object_GetObject       (Objects, Object.l) As "PB_Object_GetObject"
  Object_IsObject        (Objects, Object.l) As "PB_Object_IsObject"
  Object_EnumerateAll    (Objects, ObjectEnumerateAllCallback, *VoidData) As "PB_Object_EnumerateAll"
  Object_EnumerateStart  (Objects) As "PB_Object_EnumerateStart"
  Object_EnumerateNext   (Objects, *object.Long) As "PB_Object_EnumerateNext"
  Object_EnumerateAbort  (Objects) As "PB_Object_EnumerateAbort"
  Object_FreeID            (Objects, Object.l) As "PB_Object_FreeID"
  Object_Init            (StructureSize.l, IncrementStep.l, ObjectFreeFunction) As "PB_Object_Init"
  Object_GetThreadMemory (MemoryID.l) As "PB_Object_GetThreadMemory"
  Object_InitThreadMemory(Size.l, InitFunction, EndFunction) As "PB_Object_InitThreadMemory"
EndImport 
; Import "Compilers/ObjectManager.a"
;   Object_GetOrAllocateID  (Objects, Object.l) As "_PB_Object_GetOrAllocateID@8"
;   Object_GetObject        (Objects, Object.l) As "_PB_Object_GetObject@8"
;   Object_IsObject         (Objects, Object.l) As "_PB_Object_IsObject@8"
;   Object_EnumerateAll     (Objects, ObjectEnumerateAllCallback, *VoidData) As "_PB_Object_EnumerateAll@12"
;   Object_EnumerateStart   (Objects) As "_PB_Object_EnumerateStart@4"
;   Object_EnumerateNext    (Objects, *object.Long) As "_PB_Object_EnumerateNext@8"
;   Object_EnumerateAbort   (Objects) As "_PB_Object_EnumerateAbort@4"
;   Object_FreeID           (Objects, Object.l) As "_PB_Object_FreeID@8"
;   Object_Init             (StructureSize.l, IncrementStep.l, ObjectFreeFunction) As "_PB_Object_Init@12"
;   Object_GetThreadMemory  (MemoryID.l) As "_PB_Object_GetThreadMemory@4"
;   Object_InitThreadMemory (Size.l, InitFunction, EndFunction) As "_PB_Object_InitThreadMemory@12"
; EndImport

  ;IncludePath "Inc"
   XIncludeFile "Inc/RNet_Res.pb"
  Declare RNet_Free(ID.l)
  ; FTP
  Declare RNet_FTP_Disconnect(ID.l)
    
    
  ProcedureDLL RNet_Init()
    Global RNetObjects 
    RNetObjects = RNET_INITIALIZE(@RNet_Free())
  EndProcedure
  ProcedureDLL RNet_Create(ID.l, Type.l)
    Protected *RObject.S_RNet = RNET_NEW(ID)
    With *RObject
      \ID   = *RObject
      \type = Type
      Select \type
        Case #RNet_Type_HTTP
          \HTTP\Has_Proxy         = #False
          \HTTP\State             = #RNet_State_Idle
          \HTTP\Infos_HTTPVersion = "HTTP/1.1"
        Case #RNet_Type_POP
          \POP\Mail = AllocateMemory(SizeOf(S_RNet_Mail))
        Case #RNet_Type_NNTP
          \NNTP\Mail = AllocateMemory(SizeOf(S_RNet_Mail))
        Case #RNet_Type_IMAP
          \IMAP\Mail = AllocateMemory(SizeOf(S_RNet_Mail))
        Case #RNet_Type_SMTP
          \SMTP\Mail = AllocateMemory(SizeOf(S_RNet_Mail))
      EndSelect
    EndWith
    ProcedureReturn *RObject
  EndProcedure
  ProcedureDLL RNet_Is(ID.l)
    ProcedureReturn RNet_IsID(ID)
  EndProcedure
  ProcedureDLL RNet_Free(ID.l)
    Protected *RObject.S_RNet
  	If *RObject
  	  Select *RObject\type
  	    Case #RNet_Type_FTP
  	    ;{
  	      If *RObject\FTP\Connexion <> 0
  	        RNet_FTP_Disconnect(ID)
  	      EndIf
  	    ;}
  	  EndSelect
      RNet_FreeID(Id)
    EndIf
    ProcedureReturn #True
  EndProcedure
  ProcedureDLL RNet_GetLastError(Id.l)
    Protected *RObject.S_RNet = RNET_ID(Id)
    With *RObject
      ProcedureReturn \LastError
    EndWith
  EndProcedure

;   ProcedureDLL.l RNet_(Id.l)
;     Protected *RObject.S_RNet = RNET_ID(Id)
;     Debug Id
;     Debug *RObject
;     With *RObject
;       Debug *RObject\HTTP\Has_Proxy
;     EndWith
;   EndProcedure
  
  XIncludeFile "RNet_CDDB.pb"
  IncludePath "IncLib"
  XIncludeFile "RNet_Mail.pb"
  XIncludeFile "RNet_HTTP.pb"
  XIncludeFile "RNet_FTP.pb"
  XIncludeFile "RNet_POP.pb"
  XIncludeFile "RNet_SMTP.pb"
  XIncludeFile "RNet_Torrent.pb"
  XIncludeFile "RNet_IMAP.pb"
  XIncludeFile "RNet_NNTP.pb"
  

  