;- Constantes
#RNet_Const_CRLF  = Chr(13)+Chr(10)
#RNet_Const_Quote = Chr(34)
#RNet_Const_Tab   = Chr(9)
;- Enumerations
;{
  Enumeration 1 ; RNet_Type
    #RNet_Type_HTTP
    #RNet_Type_FTP
    #RNet_Type_Torrent
    #RNet_Type_POP
    #RNet_Type_SMTP
    #RNet_Type_IMAP
    #RNet_Type_NNTP
    #RNet_Type_CDDB
    
    #RNet_Type_NTP
    #RNet_Type_Games
    #RNet_Type_SOAP
    #RNet_Type_LDAP
    #RNet_Type_WhoIs
    #RNet_Type_IRC   
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
  
  Enumeration 1 ; RNet_HTTP_Attribute_FileSize 
    #RNet_HTTP_Attribute_FileSize
    #RNet_HTTP_Attribute_AcceptRanges
    #RNet_HTTP_Attribute_Date
    #RNet_HTTP_Attribute_ContentLength
    #RNet_HTTP_Attribute_ContentType
    #RNet_HTTP_Attribute_Server
    #RNet_HTTP_Attribute_LastModified
    #RNet_HTTP_Attribute_Etag
    #RNet_HTTP_Attribute_Via
    #RNet_HTTP_Attribute_Age
    #RNet_HTTP_Attribute_HTTPVersion
    #RNet_HTTP_Attribute_HTTPCode
    #RNet_HTTP_Attribute_UserAgent
    #RNet_HTTP_Attribute_Range
    #RNet_HTTP_Attribute_CacheControl
    #RNet_HTTP_Attribute_Referer
    #RNet_HTTP_Attribute_Size
    #RNet_HTTP_Attribute_ContentBody
    #RNet_HTTP_Attribute_ContentAll
    #RNet_HTTP_Attribute_ContentHeader
    #RNet_HTTP_Attribute_TransferEncoding
    #RNet_HTTP_Attribute_SetCookie
  EndEnumeration
  Enumeration 1 ; RNet_HTTP_Request_Get
    #RNet_HTTP_Request_Get
    #RNet_HTTP_Request_Post
    #RNet_HTTP_Request_Head
  EndEnumeration
  
  Enumeration 1 ; RNet_FTP_Mode
    #RNet_FTP_Mode_Ascii
    #RNet_FTP_Mode_Binary
  EndEnumeration
  
  Enumeration 0 ; RNet_Torrent
    #RNet_Torrent_bDicoStart
    #RNet_Torrent_bDicoEnd
    #RNet_Torrent_bInteger
    #RNet_Torrent_bList
    #RNet_Torrent_bString
  EndEnumeration
  
  Enumeration 1 ; RNet_Mail_Attribute
    #RNet_Mail_Attribute_ReturnPath
    #RNet_Mail_Attribute_DeliveredTo
    #RNet_Mail_Attribute_Received
    #RNet_Mail_Attribute_XSender
    #RNet_Mail_Attribute_XMailer
    #RNet_Mail_Attribute_XUser
    #RNet_Mail_Attribute_XScript
    #RNet_Mail_Attribute_Date
    #RNet_Mail_Attribute_From
    #RNet_Mail_Attribute_BCC
    #RNet_Mail_Attribute_Subject
    #RNet_Mail_Attribute_XProxadSc
    #RNet_Mail_Attribute_XSpamCheckerVersion
    #RNet_Mail_Attribute_XSpamLevel
    #RNet_Mail_Attribute_XSpamStatus
    #RNet_Mail_Attribute_To
    #RNet_Mail_Attribute_ReplyTo
    #RNet_Mail_Attribute_XAuthSmtpUser
    #RNet_Mail_Attribute_XAbuseContact
    #RNet_Mail_Attribute_MimeVersion
    #RNet_Mail_Attribute_ContentType
    #RNet_Mail_Attribute_MessageId
    #RNet_Mail_Attribute_DomainkeySignature
    #RNet_Mail_Attribute_Organization
    #RNet_Mail_Attribute_XPriority
    #RNet_Mail_Attribute_UserAgent
    #RNet_Mail_Attribute_ThreadTopic
    #RNet_Mail_Attribute_ThreadIndex
    #RNet_Mail_Attribute_XEmvCampagneid
    #RNet_Mail_Attribute_XEmvMemberid
  EndEnumeration
;}
;- Globales
;{
  ;Global RNetIDs.l
;}
;- Structures
;{
  Structure S_RNet_Mail
    Infos_to.s
    Infos_cc.s
    Infos_bcc.s
    Infos_from.s
    Infos_date.s
    Infos_subject.s
    Infos_reply_to.s
    Infos_return_path.s
    Infos_delivered_to.s
    Infos_received.s
    Infos_mime_version.s
    Infos_content_type.s
    Infos_message_id.s
    Infos_domainkey_signature.s
    Infos_organization.s
    Infos_user_agent.s
    Infos_thread_topic.s
    Infos_thread_index.s
    Infos_x_sender.s
    Infos_x_mailer.s
    Infos_x_user.s
    Infos_x_script.s
    Infos_x_proxad_sc.s
    Infos_x_spam_checker_version.s
    Infos_x_spam_level.s
    Infos_x_spam_status.s
    Infos_x_auth_smtp_user.s
    Infos_x_abuse_contact.s
    Infos_x_priority.s
    Infos_x_emv_campagneid.s
    Infos_x_emv_memberid.s
    Infos_path.s
    Infos_newsgroups.s
    Infos_references.s
    Infos_content_transfer_encoding.s
    Infos_lines.s
    Infos_nntp_posting_date.s
    Infos_nntp_posting_host.s
    Infos_x_trace.s
    Infos_x_complaints_to.s
    Infos_xref.s
    Infos_Body.s
  EndStructure

  Structure S_RNet_CDDB_Toc
    min.l
    sec.l
    frame.l
  EndStructure
  Structure S_RNet_CDDB
    Connexion.l
    Server.s
    Port.l
    Login.s
    Password.s
    CmdLastAnswer.s
    
    DiscID.s
  EndStructure
  Structure S_RNet_NNTP
    Connexion.l
    Server.s
    Port.l
    Login.s
    Password.s
    CmdLastAnswer.s
    
    CmdListAnswer.s
    
    CmdGroup_NbMessages.l
    CmdGroup_FirstMessage.l
    CmdGroup_LastMessage.l
    
    CmdArticle_Answer.s
    CmdArticle_MessageID.s
    CmdArticle_Identifier.s
        
    *Mail.S_RNet_Mail
  EndStructure
  Structure S_RNet_IMAP
    Connexion.l
    Server.s
    Port.l
    Login.s
    Password.s
    CmdLastAnswer.s
    CmdId.l
    
    DirInfos.s
    Dir_MessagesAll.l
    Dir_MessagesRecent.l
    Dir_MessagesUnseen.l
    Dir_UIDValidity.l
    Dir_UIDNext.l
    Dir_Flags.s
    Dir_PermanentFlags.s

    Msg.s
    MsgSize.l
    *Mail.S_RNet_Mail
  EndStructure
  Structure S_RNet_SMTP
    Connexion.l
    Server.s
    Port.l
    Login.s
    Password.s
    CmdLastAnswer.s
    
    *Mail.S_RNet_Mail
  EndStructure
  Structure S_RNet_Torrent_File_Info
    Files.s
    Lengths.s
  EndStructure
  Structure S_RNet_Torrent
    TypeMime.s
    announce.s
    announce_list.s
    creation_date.l
    creation_by.s
    encoding.s
    private.l
    comment.s
    info.S_RNet_Torrent_File_Info
  EndStructure
  Structure S_RNet_POP
    Connexion.l
    Server.s
    Port.l
    Login.s
    Password.s
    
    CmdList.s
    CmdLastAnswer.s
    
    Msg.s
    *Mail.S_RNet_Mail

  EndStructure
  Structure S_RNet_NTP
  EndStructure
  Structure S_RNet_FTP
    Connexion.l
    Server.s
    Port.l
    Login.s
    Password.s
    
    Connexion_PASV.l
    ListingDir.s
    ListingEntry.l
    
    DataMem.l
    DataLen.l
  EndStructure
  Structure S_RNet_HTTP
    State.l
    Timeout.l
    
    ; Proxy
    Has_Proxy.l
    Proxy_IP.s
    Proxy_Port.l
    Proxy_Login.s
    Proxy_Pass.s
    
    ; Page
    URL.s
    Host.s
    Port.l
    Path.s
    
    ContentReturned.s
    ContentBody.s
    
    Post_Data.l
    Post_Data_Len.l
    
    Infos_HTTPVersion.s
    Infos_HTTPCode.s
    Infos_AcceptRanges.s
    Infos_Date.s
    Infos_ContentLength.s
    Infos_ContentType.s
    Infos_Server.s
    Infos_LastModified.s
    Infos_Etag.s
    Infos_Via.s
    Infos_Age.s
    Infos_UserAgent.s
    Infos_Range.s
    Infos_CacheControl.s
    Infos_Referer.s
    Infos_TransferEncoding.s
    Infos_SetCookie.s
  EndStructure
  Structure S_RNet
    ID.l
    type.l
    LastError.l
    StructureUnion
      HTTP.S_RNet_HTTP
      IMAP.S_RNet_IMAP
      FTP.S_RNet_FTP
      NNTP.S_RNet_NNTP
      NTP.S_RNet_NTP
      POP.S_RNet_POP
      SMTP.S_RNet_SMTP
      Torrent.S_RNet_Torrent
      CDDB.S_RNet_CDDB
    EndStructureUnion
  EndStructure
;}
;- Macros
;{
  Macro RNET_ID(object)
    Object_GetObject(RNetObjects, object)
  EndMacro
  Macro RNET_ISID(object)
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
    *RObject\LastError = Error
  EndMacro
;}



; IDE Options = PureBasic 4.20 (Windows - x86)
; Folding = AYQAA-