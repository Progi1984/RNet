;- Private
  Procedure RNet_HTTP_RequestGET_Thread(ID.l)
    Protected *RObject.S_RNet = RNET_ID(ID)
    Protected psCRLF.s, psReceivedData.s
    Protected plConnexion.l
    Protected RequestGet.s, LoginLen.l, EncodingProxyAuth.s, Login.s
    Protected plEndTime.l, plNetEvent.l
    
    psCRLF  = Chr(13) + Chr(10)
    With *RObject
      \S_HTTP\State     = #RNet_State_Running
      plEndTime   = Date()  + \S_HTTP\TimeOut
      If \S_HTTP\bIsProxy = #True
        plConnexion = OpenNetworkConnection(\S_HTTP\sProxy_IP, \S_HTTP\lProxy_Port)
      Else
        plConnexion = OpenNetworkConnection(\S_HTTP\sPageHost, \S_HTTP\lPagePort)
      EndIf
      RequestGet = "GET " + \S_HTTP\sPageURL + " " + \S_HTTP\sInfosHTTPVersion
      RequestGet + psCRLF
      RequestGet + "Host: " + \S_HTTP\sPageHost
      RequestGet + psCRLF
      If \S_HTTP\sInfosUserAgent <> ""
        RequestGet + "User-Agent: "
        RequestGet + \S_HTTP\sInfosUserAgent
        RequestGet + psCRLF
      EndIf
      ;If \S_HTTP\sInfosRange <> ""
      ;  RequestGet + "User-Agent: "
      ;  RequestGet + \S_HTTP\sInfosRange
      ;  RequestGet + psCRLF
      ;EndIf
      If \S_HTTP\sInfosCacheControl <> ""
        RequestGet + "Cache-Control: "
        RequestGet + \S_HTTP\sInfosCacheControl
        RequestGet + psCRLF
      EndIf
      If \S_HTTP\sInfosReferer <> ""
        RequestGet + "Referer: "
        RequestGet + \S_HTTP\sInfosRange
        RequestGet + psCRLF
      EndIf
      If \S_HTTP\bIsProxy = #True ; Partie relative au proxy
        Login             = \S_HTTP\sProxy_Login + ":" + \S_HTTP\sProxy_Pass
        LoginLen          = Len(Login) + Len(Login) * 50 / 100
        EncodingProxyAuth = Space(LoginLen) 
        Base64Encoder(@Login, Len(Login), @EncodingProxyAuth, LoginLen)
        RequestGet + "Proxy-Connection: Keep-Alive"
        RequestGet + psCRLF
        RequestGet + "Proxy-Authorization: Basic "
        RequestGet + EncodingProxyAuth
      Else
        RequestGet + "Connection: keep-alive"
      EndIf
      RequestGet + psCRLF
      RequestGet + psCRLF
      
      SendNetworkString(plConnexion, RequestGet)
      
      \S_HTTP\sContentReturned  = ""
      \S_HTTP\sContentBody      = ""
      Repeat
        plNetEvent = NetworkClientEvent(plConnexion)
        If plNetEvent = #PB_NetworkEvent_Data
          *Buffer           = AllocateMemory(1024)
          ReturnData        = ReceiveNetworkData(plConnexion, *Buffer, 1024)
          psReceivedData    = PeekS(*Buffer)
          \S_HTTP\sContentReturned + psReceivedData
          FreeMemory(*Buffer)
          If FindString(LCase(\S_HTTP\sContentReturned), "chunked", 0) = 0
            If ReturnData < 1024  
              Main = #True
              \S_HTTP\State = #RNet_State_Done
              \lLastError = #RNet_Error_OK
            EndIf
          Else
            If Right(LCase(\S_HTTP\sContentReturned), 5) = "0" + #RNet_Const_CRLF + #RNet_Const_CRLF
              Main = #True
              \S_HTTP\State = #RNet_State_Done
              \lLastError   = #RNet_Error_OK
            EndIf
          EndIf
        ElseIf plNetEvent = 0
          If Date() > plEndTime And \S_HTTP\TimeOut <> 0
            Main = #True
            \S_HTTP\State = #RNet_State_Done
            \lLastError   = #RNet_Error_TimeOut
          EndIf
        EndIf
      Until Main = #True
      \S_HTTP\sInfosHTTPVersion  = StringField(StringField(\S_HTTP\sContentReturned, 1, psCRLF), 1, " ")
      \S_HTTP\sInfosHTTPCode     = StringField(StringField(\S_HTTP\sContentReturned, 1, psCRLF), 2, " ")
      CloseNetworkConnection(plConnexion)
      plConnexion = 0
      
      ; Cleans the chunked size
      ;@url : http://personnel.univ-reunion.fr/jclain/cours/http/chunked11.html
      If FindString(LCase(\S_HTTP\sContentReturned), "chunked", 0) > 0
        Protected plPosStart.l, plPosEnd.l, plSizeChunk.l
        Protected psSizeChunk.s
        Protected psContent.s
        plPosStart  = FindString(\S_HTTP\sContentReturned, #RNet_Const_CRLF + #RNet_Const_CRLF, 0)
        plPosStart  + 2
        plPosEnd    = FindString(\S_HTTP\sContentReturned, #RNet_Const_CRLF, plPosStart + 1)
        psSizeChunk = Mid(\S_HTTP\sContentReturned, plPosStart, plPosEnd - plPosStart)
        psContent   = Left(\S_HTTP\sContentReturned, plPosStart)
        psContent   + Right(\S_HTTP\sContentReturned, Len(\S_HTTP\sContentReturned) - plPosEnd)
        \S_HTTP\sContentReturned = psContent
        Repeat
          plPosEnd    + Val("$"+psSizeChunk)
          plPosStart  = FindString(\S_HTTP\sContentReturned, #RNet_Const_CRLF, plPosEnd)
          If plPosStart > 0
            plPosEnd    = FindString(\S_HTTP\sContentReturned, #RNet_Const_CRLF, plPosStart + 1)
            psSizeChunk = Mid(\S_HTTP\sContentReturned, plPosStart, plPosEnd - plPosStart)
            psContent   = Left(\S_HTTP\sContentReturned, plPosStart)
            psContent   + Right(\S_HTTP\sContentReturned, Len(\S_HTTP\sContentReturned) - plPosEnd)
            \S_HTTP\sContentReturned = psContent
          EndIf
        Until plPosStart = 0
      EndIf
    EndWith
    ProcedureReturn #True
  EndProcedure
  Procedure RNet_HTTP_RequestPOST_Thread(ID.l)
    Protected *RObject.S_RNet = RNET_ID(ID)
    Protected psCRLF.s          = Chr(13) + Chr(10)
    Protected Connexion.l
    Protected RequestGet.s, LoginLen.l, EncodingProxyAuth.s, Login.s, IsThere.l, Header.s
    With *RObject\S_HTTP
      \State     = #RNet_State_Running
      If \bIsProxy = #True
        Connexion = OpenNetworkConnection(\sProxy_IP, \lProxy_Port)
      Else
        Connexion = OpenNetworkConnection(\sPageHost, \lPagePort)
      EndIf
      RequestGet =  "POST " + \sPageURL +" "+\sInfosHTTPVersion + psCRLF
      RequestGet + "Host: " + \sPageHost + psCRLF
      If \sInfosUserAgent <> ""     : RequestGet + "User-Agent: "+\sInfosUserAgent + psCRLF:EndIf
      ;If \sInfosRange <> ""         : RequestGet + "User-Agent: "+\sInfosRange + psCRLF:Endif
      If \sInfosCacheControl <> ""  : RequestGet + "Cache-Control: "+\sInfosCacheControl + psCRLF:EndIf
      If \sInfosReferer <> ""       : RequestGet + "Referer: "+\sInfosReferer + psCRLF:EndIf
      If \sInfosContentType <> ""   : RequestGet + "Content-Type: "+\sInfosContentType + psCRLF:EndIf
      RequestGet + "Content-Length:"+Str(MemorySize(\lPostData))+ psCRLF
      If \bIsProxy = #True ; Partie relative au proxy
        Login             = \sProxy_Login+":"+\sProxy_Pass
        LoginLen          = Len(Login) + Len(Login)*50/100
        EncodingProxyAuth = Space(LoginLen) 
        Base64Encoder(@Login, Len(Login), @EncodingProxyAuth, LoginLen)
        RequestGet        + "Proxy-Connection: keep-alive" + psCRLF
        RequestGet        + "Proxy-Authorization: Basic "  + EncodingProxyAuth + psCRLF + psCRLF
      Else
        RequestGet        + "Connection: keep-alive"+psCRLF+psCRLF
      EndIf
      RequestGetMem = AllocateMemory(Len(RequestGet) + \lPostData_Len);+4)
      PokeS(RequestGetMem, RequestGet, Len(RequestGet), #PB_Ascii)
      CopyMemory(\lPostData , RequestGetMem+ Len(RequestGet), \lPostData_Len)
      SendNetworkData(Connexion, RequestGetMem, Len(RequestGet) + \lPostData_Len)
      \sContentReturned    = ""
      \sContentBody        = ""
      Repeat
        If NetworkClientEvent(Connexion) = #PB_NetworkEvent_Data
          *Buffer = AllocateMemory(512)
          ReturnData = ReceiveNetworkData(Connexion, *Buffer, 512)
          \sContentReturned + PeekS(*Buffer, ReturnData)
          IsThere = FindString(PeekS(*Buffer), psCRLF+psCRLF, 0)
          ; on quitte le thread que quand le texte récupéré est de la taille de l'attribut content-length ou quand le timeout a explosé :p
          If IsThere > 0 ; HEADER IN
            Header = Left(PeekS(*Buffer), IsThere)
            IsThere = FindString(LCase(Header), "content-length",0)
            If IsThere > 0
              Header = Trim(Mid(Header, IsThere, FindString(Header, psCRLF, IsThere)-IsThere))
              \sInfosContentLength = Trim(Mid(Header, FindString(Header, ":", 0)+1, Len(Header) - FindString(Header, ":", 0)))
            EndIf
          Else ; HEADER OUT
            If  \sInfosContentLength <> "" And Val(\sInfosContentLength) > 0
              IsThere = FindString(\sContentReturned, psCRLF+psCRLF, 0)
              If Len(\sContentReturned) - IsThere >= Val(\sInfosContentLength)
                Main = #True
                \State = #RNet_State_Done
                *RObject\lLastError = #RNet_Error_OK
              EndIf
            EndIf
          EndIf
        Else
          If Date() > EndTime And \TimeOut > 0
            Main = #True
            \State = #RNet_State_Done
            *RObject\lLastError = #RNet_Error_TimeOut
          EndIf
        EndIf
      Until Main = #True
      \sInfosHTTPVersion  = StringField(StringField(\sContentReturned, 1, psCRLF), 1, " ")
      \sInfosHTTPCode     = StringField(StringField(\sContentReturned, 1, psCRLF), 2, " ")
      CloseNetworkConnection(Connexion): Connexion = 0
      \State = #RNet_State_Done
    EndWith
    ProcedureReturn #True
  EndProcedure
  Procedure RNet_HTTP_RequestHEAD_Thread(ID.l)
    Protected *RObject.S_RNet = RNET_ID(ID)
    Protected psCRLF.s          = Chr(13) + Chr(10)
    Protected Connexion.l
    Protected RequestGet.s, LoginLen.l, EncodingProxyAuth.s, Login.s
    With *RObject\S_HTTP
      \State     = #RNet_State_Running
      Debug "Running"
      If \bIsProxy = #True
        Connexion = OpenNetworkConnection(\sProxy_IP, \lProxy_Port)
      Else
        Connexion = OpenNetworkConnection(\sPageHost, \lPagePort)
      EndIf
      RequestGet =  "HEAD " + \sPageURL +" "+\sInfosHTTPVersion + psCRLF
      RequestGet + "Host: " + \sPageHost + psCRLF
      If \sInfosUserAgent <> ""     : RequestGet + "User-Agent: "+\sInfosUserAgent + psCRLF:EndIf
      ;If \sInfosRange <> ""         : RequestGet + "User-Agent: "+\sInfosRange + psCRLF:Endif
      If \sInfosCacheControl <> ""  : RequestGet + "Cache-Control: "+\sInfosCacheControl + psCRLF:EndIf
      If \sInfosReferer <> ""       : RequestGet + "Referer: "+\sInfosReferer + psCRLF:EndIf
      If \sInfosContentType <> ""   : RequestGet + "Content-Type: "+\sInfosContentType + psCRLF:EndIf
      RequestGet + "Content-Length:"+Str(MemorySize(\lPostData))+ psCRLF
      If \bIsProxy = #True ; Partie relative au proxy
        Login             = \sProxy_Login+":"+\sProxy_Pass
        LoginLen          = Len(Login) + Len(Login)*50/100
        EncodingProxyAuth = Space(LoginLen) 
        Base64Encoder(@Login, Len(Login), @EncodingProxyAuth, LoginLen)
        RequestGet        + "Proxy-Connection: keep-alive" + psCRLF
        RequestGet        + "Proxy-Authorization: Basic "  + EncodingProxyAuth + psCRLF + psCRLF
      Else
        RequestGet        + "Connection: keep-alive"+psCRLF+psCRLF
      EndIf
      RequestGetMem = AllocateMemory(Len(RequestGet) + \lPostData_Len);+4)
      PokeS(RequestGetMem, RequestGet, Len(RequestGet), #PB_Ascii)
      CopyMemory(\lPostData , RequestGetMem+ Len(RequestGet)                  , \lPostData_Len)
      SendNetworkData(Connexion, RequestGetMem, Len(RequestGet) + \lPostData_Len)
      \sContentReturned    = ""
      \sContentBody        = ""
      Repeat
        If NetworkClientEvent(Connexion) = #PB_NetworkEvent_Data
          *Buffer = AllocateMemory(1024)
          ReturnData = ReceiveNetworkData(Connexion, *Buffer, 1024)
          \sContentReturned + PeekS(*Buffer)
          If ReturnData < 1024
            Main = #True
            \State = #RNet_State_Done
            *RObject\lLastError = #RNet_Error_OK
          EndIf
        Else
          If Date() > EndTime And \TimeOut > 0
            Main = #True
            \State = #RNet_State_Done
            *RObject\lLastError = #RNet_Error_TimeOut
          EndIf
        EndIf
      Until Main = #True
      \sInfosHTTPVersion  = StringField(StringField(\sContentReturned, 1, psCRLF), 1, " ")
      \sInfosHTTPCode     = StringField(StringField(\sContentReturned, 1, psCRLF), 2, " ")
      CloseNetworkConnection(Connexion): Connexion = 0
      \State = #RNet_State_Done
    EndWith
    ProcedureReturn #True
  EndProcedure

;- Public
  DeclareDLL.l RNet_HTTP_Examine(ID.l)
  ;@todo : Moebius 1.5 : Proxy.s = "", Port.l = 80, Login.s = "", Password.s = ""
  ProcedureDLL.l RNet_HTTP_SetProxy(ID.l, sProxy.s, lPort.l, sLogin.s, sPassword.s)
    Protected *RObject.S_RNet = RNET_ID(ID)
    If *RObject
      With *RObject
        If sProxy.s = "" And lPort.l = 80 And sLogin.s = "" And sPassword.s = ""
          \S_HTTP\bIsProxy    = #False
          \S_HTTP\sProxy_IP   = ""
          \S_HTTP\lProxy_Port = 80
          \S_HTTP\sProxy_Login= ""
          \S_HTTP\sProxy_Pass = ""
        Else
          \S_HTTP\bIsProxy    = #True
          \S_HTTP\sProxy_IP   = sProxy
          \S_HTTP\lProxy_Port = lPort
          \S_HTTP\sProxy_Login= sLogin
          \S_HTTP\sProxy_Pass = sPassword
        EndIf
      EndWith
      ProcedureReturn #True
    Else
      ProcedureReturn #False
    EndIf
  EndProcedure
  ;@todo : Moebius 1.5 : Request.l = #RNet_HTTP_Request_GET
  ProcedureDLL.l RNet_HTTP_Allocate(ID.l, URL.s, Request.l)
    Protected *RObject.S_RNet = RNET_ID(ID)
    If *RObject <>  #Null
      Protected Host.s
      Protected Path.s
      Protected Port.l = 80 ; Port number
      With *RObject\S_HTTP
        \sPageURL = URL
        If FindString(\sPageURL, "http://", 1) = 1 : URL = Right(\sPageURL, Len(\sPageURL)-7) : EndIf
        Pos = FindString(URL, "/", 1)
        If Pos = 0
          Host = URL
          Path = "/"
        Else
          Host = Left(URL, Pos-1)
          Path = Right(URL, Len(URL)-Pos+1)
        EndIf
        Pos = FindString(Host, ":", 1)
        If Pos > 0
          Port = Val(Right(Host, Len(Host)-Pos))
          Host = Left(Host, Pos-1)
        EndIf
        \sPageHost = Host
        \lPagePort = Port
        \sPagePath = Path
      EndWith
      Select Request
        Case #RNet_HTTP_Request_GET
          CreateThread(@RNet_HTTP_RequestGET_Thread(), ID)
        Case #RNet_HTTP_Request_POST
          CreateThread(@RNet_HTTP_RequestPOST_Thread(), ID)
        Case #RNet_HTTP_Request_HEAD
          CreateThread(@RNet_HTTP_RequestHEAD_Thread(), ID)
        Default
          CreateThread(@RNet_HTTP_RequestGET_Thread(), ID)
      EndSelect 
    Else
      ProcedureReturn #False
    EndIf
  EndProcedure
  ProcedureDLL.l RNet_HTTP_GetState(ID.l)
    Protected *RObject.S_RNet = RNET_ID(ID)
    If *RObject <>  #Null
      With *RObject\S_HTTP
        ProcedureReturn \State
      EndWith
    Else
      ProcedureReturn #False
    EndIf
  EndProcedure
  ProcedureDLL.l RNet_HTTP_ResetAllocation(ID.l)
    Protected *RObject.S_RNet = RNET_ID(ID)
    If *RObject <>  #Null
      With *RObject\S_HTTP
        \sContentReturned = ""
        \sContentBody     = ""
        \State            = #RNet_State_Idle    
      EndWith
      ProcedureReturn #True
    Else
      ProcedureReturn #False
    EndIf
  EndProcedure
  ;@todo : Moebius 1.5 : bJustBody.b = #True
  ProcedureDLL RNet_HTTP_SaveToFile(ID.l, Filename.s, bJustBody.b)
    Protected *RObject.S_RNet = RNET_ID(ID)
    If *RObject <>  #Null
      Protected Output.l
      With *RObject\S_HTTP
        Output = OpenFile(#PB_Any, FileName)
        If Output
          If bJustBody = #False
            WriteString(Output, \sContentReturned)
          Else
            If \sContentBody = ""
              RNet_HTTP_Examine(ID)
            EndIf
            WriteString(Output, \sContentBody)
          EndIf
          CloseFile(Output)
          ProcedureReturn #True
        Else
          ProcedureReturn #False
        EndIf
        ProcedureReturn \State
      EndWith
    Else
      ProcedureReturn -1
    EndIf
  EndProcedure
  ProcedureDLL RNet_HTTP_SaveToMemory(ID.l, Buffer.l)
    Protected *RObject.S_RNet = RNET_ID(ID)
    If *RObject <>  #Null
      Protected Output.l
      With *RObject\S_HTTP
        If MemorySize(Buffer) >= Len(\sContentBody)
          PokeS(Buffer, \sContentBody, Len(\sContentBody), #PB_Ascii)
          ProcedureReturn #True
        Else
          ProcedureReturn #False
        EndIf
      EndWith
    Else
      ProcedureReturn -1
    EndIf
  EndProcedure

  ProcedureDLL.l RNet_HTTP_Examine(ID.l)
    Protected *RObject.S_RNet = RNET_ID(ID)
    If *RObject
      Protected psCRLF.s    = Chr(13) + Chr(10)
      Protected psLine.s
      Protected GoToBody.l  = #False
      With *RObject\S_HTTP
        For Inc = 1 To CountString(\sContentReturned, psCRLF) + 1
          If GoToBody = #False
            psLine = StringField(\sContentReturned, Inc, psCRLF)
            psLine = RemoveString(psLine, Chr(10))
            Select Trim(LCase(StringField(psLine, 1, ":")))
              Case "accept-ranges"
                \sInfosAcceptRanges     = Trim(StringField(psLine, 2, ":"))
              Case "date"
                \sInfosDate             = Trim(StringField(psLine, 2, ":"))
              Case "content-length"
                \sInfosContentLength    = Trim(StringField(psLine, 2, ":"))
              Case "content-type"
                \sInfosContentType      = Trim(StringField(psLine, 2, ":"))
              Case "server"
                \sInfosServer           = Trim(StringField(psLine, 2, ":"))
              Case "last-modified"
                \sInfosLastModified     = Trim(StringField(psLine, 2, ":"))
              Case "etag"
                \sInfosEtag             = Trim(StringField(psLine, 2, ":"))
              Case "via"
                \sInfosVia              = Trim(StringField(psLine, 2, ":"))
              Case "age"
                \sInfosAge              = Trim(StringField(psLine, 2, ":"))
              Case "transfer-encoding"
                \sInfosTransferEncoding = Trim(StringField(psLine, 2, ":"))
              Case "cache-control"
                \sInfosCacheControl     = Trim(StringField(psLine, 2, ":"))
              Case "set-cookie"
                \sInfosSetCookie        = Trim(StringField(psLine, 2, ":"))
              Case ""
                GoToBody = #True
              Default
                Select Trim(LCase(Left(psLine, 4)))
                  Case "http"
                    \sInfosHTTPVersion  = Trim(StringField(psLine, 1, " "))
                    \sInfosHTTPCode     = Trim(Right(psLine, Len(psLine) - Len(\sInfosHTTPVersion) -1))
                  Default
                EndSelect
            EndSelect
          Else
            \sContentBody + StringField(\sContentReturned, Inc, psCRLF)
          EndIf
          If Left(\sContentBody, 1) = Chr(13)
            \sContentBody = Right(\sContentBody, Len(\sContentBody) - 1)
          EndIf
          If Left(\sContentBody, 1) = Chr(10)
            \sContentBody = Right(\sContentBody, Len(\sContentBody) - 1)
          EndIf
          \sContentBody = ReplaceString(\sContentBody, Chr(174), "")
          \sContentBody = ReplaceString(\sContentBody, Chr(1), "")
          \sContentBody = ReplaceString(\sContentBody, Chr(129), "")
        Next
        ProcedureReturn #True
      EndWith
    Else
      ProcedureReturn #False
    EndIf
  EndProcedure
  ProcedureDLL.s RNet_HTTP_GetAttribute(ID.l, lAttributeType.l)
    Protected *RObject.S_RNet = RNET_ID(ID)
    If *RObject
      With *RObject\S_HTTP
        Select lAttributeType
          Case #RNet_HTTP_Attribute_FileSize
            ProcedureReturn Str(Len(\sContentBody))
          Case #RNet_HTTP_Attribute_Size
            ProcedureReturn Str(Len(\sContentReturned))
          Case #RNet_HTTP_Attribute_ContentBody
            ProcedureReturn \sContentBody
          Case #RNet_HTTP_Attribute_ContentAll
            ProcedureReturn \sContentReturned
          Case #RNet_HTTP_Attribute_ContentHeader
            ProcedureReturn Left(\sContentReturned, Len(\sContentReturned)-Len(\sContentBody))
          Case #RNet_HTTP_Attribute_AcceptRanges
            ProcedureReturn \sInfosAcceptRanges
          Case #RNet_HTTP_Attribute_Date
            ProcedureReturn \sInfosDate
          Case #RNet_HTTP_Attribute_ContentLength
            ProcedureReturn \sInfosContentLength
          Case #RNet_HTTP_Attribute_ContentType
            ProcedureReturn \sInfosContentType
          Case #RNet_HTTP_Attribute_Server
            ProcedureReturn \sInfosServer
          Case #RNet_HTTP_Attribute_LastModified
            ProcedureReturn \sInfosLastModified
          Case #RNet_HTTP_Attribute_Etag
            ProcedureReturn \sInfosEtag
          Case #RNet_HTTP_Attribute_Via
            ProcedureReturn \sInfosVia
          Case #RNet_HTTP_Attribute_Age
            ProcedureReturn \sInfosAge
          Case #RNet_HTTP_Attribute_HTTPVersion
            ProcedureReturn \sInfosHTTPVersion
          Case #RNet_HTTP_Attribute_HTTPCode
            ProcedureReturn \sInfosHTTPCode
          Case #RNet_HTTP_Attribute_TransferEncoding
            ProcedureReturn \sInfosTransferEncoding
          Case #RNet_HTTP_Attribute_SetCookie
            ProcedureReturn \sInfosSetCookie
        EndSelect
      EndWith
    Else
      ProcedureReturn ""
    EndIf
  EndProcedure
  ProcedureDLL.l RNet_HTTP_SetAttribute(ID.l, lAttributeType.l, sAttributContent.s)
    Protected *RObject.S_RNet = RNET_ID(ID)
    If *RObject
      With *RObject\S_HTTP
        Select lAttributeType
          Case #RNet_HTTP_Attribute_UserAgent
            \sInfosUserAgent    = sAttributContent
          Case #RNet_HTTP_Attribute_Range
            \sInfosRange        = sAttributContent
          Case #RNet_HTTP_Attribute_CacheControl
            \sInfosCacheControl = sAttributContent
          Case #RNet_HTTP_Attribute_Referer
            \sInfosReferer      = sAttributContent
          Case #RNet_HTTP_Attribute_HTTPVersion
            \sInfosHTTPVersion  = sAttributContent
          Case #RNet_HTTP_Attribute_ContentType
            \sInfosContentType  = sAttributContent
          ;Case #RNet_HTTP_Attribute_
        EndSelect
      EndWith
      ProcedureReturn #True
    Else
      ProcedureReturn #False
    EndIf
  EndProcedure
  ProcedureDLL.l RNet_HTTP_ResetAttribute(ID.l)
    Protected *RObject.S_RNet = RNET_ID(ID)
    If *RObject <>  #Null
      With *RObject\S_HTTP
        \sContentBody       = ""
        \sContentReturned   = ""
        \sInfosHTTPVersion  = ""
        \sInfosHTTPCode     = ""
        \sInfosAcceptRanges = ""
        \sInfosDate         = ""
        \sInfosContentLength= ""
        \sInfosContentType  = ""
        \sInfosServer       = ""
        \sInfosLastModified = ""
        \sInfosEtag         = ""
        \sInfosVia          = ""
        \sInfosAge          = ""
      EndWith
      ProcedureReturn #True
    Else
      ProcedureReturn #False
    EndIf
  EndProcedure
  ProcedureDLL.l RNet_HTTP_SetPostData(ID.l, Buffer.l, Length.l)
    Protected *RObject.S_RNet = RNET_ID(ID)
    If *RObject <>  #Null
      With *RObject\S_HTTP
        \lPostData      = AllocateMemory(Length)
        CopyMemory(Buffer, \lPostData, Length)
        \lPostData_Len  = Length
      EndWith
      ProcedureReturn #True
    Else
      ProcedureReturn #False
    EndIf
  EndProcedure
  ProcedureDLL.l RNet_HTTP_SetTimeout(ID.l, Timeout.l)
    Protected *RObject.S_RNet = RNET_ID(ID)
    If *RObject <>  #Null
      With *RObject\S_HTTP
        \Timeout  = Timeout
      EndWith
      ProcedureReturn #True
    Else
      ProcedureReturn #False
    EndIf
  EndProcedure
  
  ProcedureDLL.s RNet_HTTP_Get(ID.l)
    Protected *RObject.S_RNet = RNET_ID(ID)
    If *RObject <>  #Null
      ProcedureReturn *RObject\S_HTTP\sContentReturned
    Else
      ProcedureReturn ""
    EndIf
  EndProcedure
