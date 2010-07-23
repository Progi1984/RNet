IncludePath #PB_Compiler_FilePath
XIncludeFile "RNet_Res_HTTP.pb"

;- Constantes
#RNet_Const_CRLF  = Chr(13)+Chr(10)
#RNet_Const_Quote = Chr(34)
#RNet_Const_Tab   = Chr(9)

;- Enumerations
Enumeration 1 ; RNet_Type
  #RNet_Type_CDDB
  #RNet_Type_FTP
  #RNet_Type_Games
  #RNet_Type_HTTP
  #RNet_Type_IMAP
  #RNet_Type_IRC   
  #RNet_Type_LDAP
  #RNet_Type_NNTP
  #RNet_Type_NTP
  #RNet_Type_POP
  #RNet_Type_SMTP
  #RNet_Type_SOAP
  #RNet_Type_Torrent
  #RNet_Type_WhoIs
EndEnumeration
Enumeration 1 ; RNet_State
  #RNet_State_Idle
  #RNet_State_Running
  #RNet_State_Done
EndEnumeration
Enumeration 1 ; RNet_Error
  #RNet_Error_OK
  #RNet_Error_BadLogin
  #RNet_Error_BadPassword
  #RNet_Error_CommandUnrecognized
  #RNet_Error_EverExisting
  #RNet_Error_MemorySmall
  #RNet_Error_NoConnection
  #RNet_Error_NoContent
  #RNet_Error_NoRecipient
  #RNet_Error_NoSender
  #RNet_Error_ServerTooBusy
  #RNet_Error_SyntaxError
  #RNet_Error_TimeOut
  #RNet_Error_WritingInFile
EndEnumeration

;- Structures
Structure S_RNet
  sObject.s
  lType.l
  lLastError.l
  StructureUnion
    S_HTTP.S_RNet_HTTP
;     S_IMAP.S_RNet_IMAP
;     S_FTP.S_RNet_FTP
;     S_NNTP.S_RNet_NNTP
;     S_NTP.S_RNet_NTP
;     S_POP.S_RNet_POP
;     S_SMTP.S_RNet_SMTP
;     S_Torrent.S_RNet_Torrent
;     S_CDDB.S_RNet_CDDB
  EndStructureUnion
EndStructure

;- Macros
Macro RNET_ID(object)
  Object_GetObject(RNetObjects, object)
EndMacro
Macro RNET_IS(object)
  Object_IsObject(RNetObjects, object) 
EndMacro
Macro RNET_NEW(object)
  Object_GetOrAllocateID(RNetObjects, object)
EndMacro
Macro RNET_FREEID(object)
  If object <> #PB_Any And RNET_IS(object) = #True
    Object_FreeID(RNetObjects, object)
  EndIf
EndMacro
Macro RNET_INITIALIZE(hCloseFunction)
  Object_Init(SizeOf(S_RNet), 1, hCloseFunction)
EndMacro
Macro RNet_SetLastError(Error)
  *RObject\lLastError = Error
EndMacro