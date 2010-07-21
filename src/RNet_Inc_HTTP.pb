;- Private
  Procedure RNet_HTTP_RequestGET_Thread(ID.l)
    Protected *RObject.S_RNet = RNET_ID(ID)
    Protected CRLF.s          = Chr(13) + Chr(10)
    Protected Connexion.l
    Protected RequestGet.s, LoginLen.l, EncodingProxyAuth.s, Login.s
    Protected EndTime.l
    With *RObject\HTTP
      \State     = #RNet_State_Running
      EndTime   = Date()  + \TimeOut
      If \Has_Proxy = #True
        Connexion = OpenNetworkConnection(\Proxy_IP, \Proxy_Port)
      Else
        Connexion = OpenNetworkConnection(\Host, \Port)
      EndIf
      RequestGet =  "GET " + \URL +" "+\Infos_HTTPVersion + CRLF
      RequestGet + "Host: " + \Host + CRLF
      If \Infos_UserAgent <> ""     : RequestGet + "User-Agent: "+\Infos_UserAgent + CRLF:EndIf
      ;If \Infos_Range <> ""         : RequestGet + "User-Agent: "+\Infos_Range + CRLF:Endif
      If \Infos_CacheControl <> ""  : RequestGet + "Cache-Control: "+\Infos_CacheControl + CRLF:EndIf
      If \Infos_Referer <> ""       : RequestGet + "Referer: "+\Infos_Range + CRLF:EndIf
      If \Has_Proxy = #True ; Partie relative au proxy
        Login             = \Proxy_Login+":"+\Proxy_Pass
        LoginLen          = Len(Login) + Len(Login)*50/100
        EncodingProxyAuth = Space(LoginLen) 
        Base64Encoder(@Login, Len(Login), @EncodingProxyAuth, LoginLen)
        RequestGet        + "Proxy-Connection: Keep-Alive" + CRLF
        RequestGet        + "Proxy-Authorization: Basic "  + EncodingProxyAuth + CRLF + CRLF
      Else
        RequestGet        + "Connection: keep-alive"+CRLF+CRLF
      EndIf
      SendNetworkString(Connexion, RequestGet)
      \ContentReturned = ""
      \ContentBody = ""
      Repeat
        If NetworkClientEvent(Connexion) = #PB_NetworkEvent_Data
          *Buffer = AllocateMemory(1024)
          ReturnData = ReceiveNetworkData(Connexion, *Buffer, 1024)
          \ContentReturned + PeekS(*Buffer)
          If ReturnData < 1024
            Main = #True
            \State = #RNet_State_Done
            *RObject\LastError = #RNet_Error_OK
          EndIf
        Else
          If Date() > EndTime And \TimeOut > 0
            Main = #True
            \State = #RNet_State_Done
            *RObject\LastError = #RNet_Error_TimeOut
          EndIf
        EndIf
      Until Main = #True
      ;Debug \ContentReturned
      \Infos_HTTPVersion  = StringField(StringField(\ContentReturned, 1, CRLF), 1, " ")
      \Infos_HTTPCode     = StringField(StringField(\ContentReturned, 1, CRLF), 2, " ")
      CloseNetworkConnection(Connexion): Connexion = 0
      
    EndWith
    ProcedureReturn #True
  EndProcedure
  Procedure RNet_HTTP_RequestPOST_Thread(ID.l)
    Protected *RObject.S_RNet = RNET_ID(ID)
    Protected CRLF.s          = Chr(13) + Chr(10)
    Protected Connexion.l
    Protected RequestGet.s, LoginLen.l, EncodingProxyAuth.s, Login.s, IsThere.l, Header.s
    With *RObject\HTTP
      \State     = #RNet_State_Running
      If \Has_Proxy = #True
        Connexion = OpenNetworkConnection(\Proxy_IP, \Proxy_Port)
      Else
        Connexion = OpenNetworkConnection(\Host, \Port)
      EndIf
      RequestGet =  "POST " + \URL +" "+\Infos_HTTPVersion + CRLF
      RequestGet + "Host: " + \Host + CRLF
      If \Infos_UserAgent <> ""     : RequestGet + "User-Agent: "+\Infos_UserAgent + CRLF:EndIf
      ;If \Infos_Range <> ""         : RequestGet + "User-Agent: "+\Infos_Range + CRLF:Endif
      If \Infos_CacheControl <> ""  : RequestGet + "Cache-Control: "+\Infos_CacheControl + CRLF:EndIf
      If \Infos_Referer <> ""       : RequestGet + "Referer: "+\Infos_Referer + CRLF:EndIf
      If \Infos_ContentType <> ""   : RequestGet + "Content-Type: "+\Infos_ContentType + CRLF:EndIf
      RequestGet + "Content-Length:"+Str(MemorySize(\Post_Data))+ CRLF
      If \Has_Proxy = #True ; Partie relative au proxy
        Login             = \Proxy_Login+":"+\Proxy_Pass
        LoginLen          = Len(Login) + Len(Login)*50/100
        EncodingProxyAuth = Space(LoginLen) 
        Base64Encoder(@Login, Len(Login), @EncodingProxyAuth, LoginLen)
        RequestGet        + "Proxy-Connection: keep-alive" + CRLF
        RequestGet        + "Proxy-Authorization: Basic "  + EncodingProxyAuth + CRLF + CRLF
      Else
        RequestGet        + "Connection: keep-alive"+CRLF+CRLF
      EndIf
      RequestGetMem = AllocateMemory(Len(RequestGet) + \Post_Data_Len);+4)
      PokeS(RequestGetMem, RequestGet, Len(RequestGet), #PB_Ascii)
      CopyMemory(\Post_Data , RequestGetMem+ Len(RequestGet), \Post_Data_Len)
      SendNetworkData(Connexion, RequestGetMem, Len(RequestGet) + \Post_Data_Len)
      \ContentReturned    = ""
      \ContentBody        = ""
      Repeat
        If NetworkClientEvent(Connexion) = #PB_NetworkEvent_Data
          *Buffer = AllocateMemory(512)
          ReturnData = ReceiveNetworkData(Connexion, *Buffer, 512)
          \ContentReturned + PeekS(*Buffer, ReturnData)
          IsThere = FindString(PeekS(*Buffer), CRLF+CRLF, 0)
          ; on quitte le thread que quand le texte récupéré est de la taille de l'attribut content-length ou quand le timeout a explosé :p
          If IsThere > 0 ; HEADER IN
            Header = Left(PeekS(*Buffer), IsThere)
            IsThere = FindString(LCase(Header), "content-length",0)
            If IsThere > 0
              Header = Trim(Mid(Header, IsThere, FindString(Header, CRLF, IsThere)-IsThere))
              \Infos_ContentLength = Trim(Mid(Header, FindString(Header, ":", 0)+1, Len(Header) - FindString(Header, ":", 0)))
            EndIf
          Else ; HEADER OUT
            If  \Infos_ContentLength <> "" And Val(\Infos_ContentLength) > 0
              IsThere = FindString(\ContentReturned, CRLF+CRLF, 0)
              If Len(\ContentReturned) - IsThere >= Val(\Infos_ContentLength)
                Main = #True
                \State = #RNet_State_Done
                *RObject\LastError = #RNet_Error_OK
              EndIf
            EndIf
          EndIf
        Else
          If Date() > EndTime And \TimeOut > 0
            Main = #True
            \State = #RNet_State_Done
            *RObject\LastError = #RNet_Error_TimeOut
          EndIf
        EndIf
      Until Main = #True
      \Infos_HTTPVersion  = StringField(StringField(\ContentReturned, 1, CRLF), 1, " ")
      \Infos_HTTPCode     = StringField(StringField(\ContentReturned, 1, CRLF), 2, " ")
      CloseNetworkConnection(Connexion): Connexion = 0
      \State = #RNet_State_Done
    EndWith
    ProcedureReturn #True
  EndProcedure
  Procedure RNet_HTTP_RequestHEAD_Thread(ID.l)
    Protected *RObject.S_RNet = RNET_ID(ID)
    Protected CRLF.s          = Chr(13) + Chr(10)
    Protected Connexion.l
    Protected RequestGet.s, LoginLen.l, EncodingProxyAuth.s, Login.s
    With *RObject\HTTP
      \State     = #RNet_State_Running
      Debug "Running"
      If \Has_Proxy = #True
        Connexion = OpenNetworkConnection(\Proxy_IP, \Proxy_Port)
      Else
        Connexion = OpenNetworkConnection(\Host, \Port)
      EndIf
      RequestGet =  "HEAD " + \URL +" "+\Infos_HTTPVersion + CRLF
      RequestGet + "Host: " + \Host + CRLF
      If \Infos_UserAgent <> ""     : RequestGet + "User-Agent: "+\Infos_UserAgent + CRLF:EndIf
      ;If \Infos_Range <> ""         : RequestGet + "User-Agent: "+\Infos_Range + CRLF:Endif
      If \Infos_CacheControl <> ""  : RequestGet + "Cache-Control: "+\Infos_CacheControl + CRLF:EndIf
      If \Infos_Referer <> ""       : RequestGet + "Referer: "+\Infos_Referer + CRLF:EndIf
      If \Infos_ContentType <> ""   : RequestGet + "Content-Type: "+\Infos_ContentType + CRLF:EndIf
      RequestGet + "Content-Length:"+Str(MemorySize(\Post_Data))+ CRLF
      If \Has_Proxy = #True ; Partie relative au proxy
        Login             = \Proxy_Login+":"+\Proxy_Pass
        LoginLen          = Len(Login) + Len(Login)*50/100
        EncodingProxyAuth = Space(LoginLen) 
        Base64Encoder(@Login, Len(Login), @EncodingProxyAuth, LoginLen)
        RequestGet        + "Proxy-Connection: keep-alive" + CRLF
        RequestGet        + "Proxy-Authorization: Basic "  + EncodingProxyAuth + CRLF + CRLF
      Else
        RequestGet        + "Connection: keep-alive"+CRLF+CRLF
      EndIf
      RequestGetMem = AllocateMemory(Len(RequestGet) + \Post_Data_Len);+4)
      PokeS(RequestGetMem, RequestGet, Len(RequestGet), #PB_Ascii)
      CopyMemory(\Post_Data , RequestGetMem+ Len(RequestGet)                  , \Post_Data_Len)
      SendNetworkData(Connexion, RequestGetMem, Len(RequestGet) + \Post_Data_Len)
      \ContentReturned    = ""
      \ContentBody        = ""
      Repeat
        If NetworkClientEvent(Connexion) = #PB_NetworkEvent_Data
          *Buffer = AllocateMemory(1024)
          ReturnData = ReceiveNetworkData(Connexion, *Buffer, 1024)
          \ContentReturned + PeekS(*Buffer)
          If ReturnData < 1024
            Main = #True
            \State = #RNet_State_Done
            *RObject\LastError = #RNet_Error_OK
          EndIf
        Else
          If Date() > EndTime And \TimeOut > 0
            Main = #True
            \State = #RNet_State_Done
            *RObject\LastError = #RNet_Error_TimeOut
          EndIf
        EndIf
      Until Main = #True
      \Infos_HTTPVersion  = StringField(StringField(\ContentReturned, 1, CRLF), 1, " ")
      \Infos_HTTPCode     = StringField(StringField(\ContentReturned, 1, CRLF), 2, " ")
      CloseNetworkConnection(Connexion): Connexion = 0
      \State = #RNet_State_Done
    EndWith
    ProcedureReturn #True
  EndProcedure
;- Public
  ProcedureDLL RNet_HTTP_SetProxy(ID.l, Proxy.s = "", Port.l = 80, Login.s = "", Password.s = "")
    Protected *RObject.S_RNet = RNET_ID(ID)
    If *RObject <>  #Null
      With *RObject
        If Proxy.s = "" And Port.l = 80 And Login.s = "" And Password.s = ""
          \HTTP\Has_Proxy  = #False
          \HTTP\Proxy_IP   = ""
          \HTTP\Proxy_Port = 80
          \HTTP\Proxy_Login= ""
          \HTTP\Proxy_Pass = ""
        Else
          \HTTP\Has_Proxy  = #True
          \HTTP\Proxy_IP   = Proxy
          \HTTP\Proxy_Port = Port
          \HTTP\Proxy_Login= Login
          \HTTP\Proxy_Pass = Password
        EndIf
      EndWith
    Else
      ProcedureReturn -1
    EndIf
  EndProcedure
  ProcedureDLL RNet_HTTP_Allocate(ID.l, URL.s, Request.l = #RNet_HTTP_Request_Get)
    Protected *RObject.S_RNet = RNET_ID(ID)
    If *RObject <>  #Null
      Protected Host.s
      Protected Path.s
      Protected Port.l = 80 ; Port number
      With *RObject\HTTP
        \URL = URL
        If FindString(\URL, "http://", 1) = 1 : URL = Right(\URL, Len(\URL)-7) : EndIf
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
        \Host = Host
        \Port = Port
        \Path = Path
      EndWith
      Select Request
        Case #RNet_HTTP_Request_Get
          CreateThread(@RNet_HTTP_RequestGET_Thread(), ID)
        Case #RNet_HTTP_Request_Post
          CreateThread(@RNet_HTTP_RequestPOST_Thread(), ID)
        Case #RNet_HTTP_Request_Head
          CreateThread(@RNet_HTTP_RequestHEAD_Thread(), ID)
        Default
          CreateThread(@RNet_HTTP_RequestGET_Thread(), ID)
      EndSelect 
    Else
      ProcedureReturn -1
    EndIf
  EndProcedure
  ProcedureDLL RNet_HTTP_GetState(ID.l)
    Protected *RObject.S_RNet = RNET_ID(ID)
    If *RObject <>  #Null
      With *RObject\HTTP
        ProcedureReturn \State
      EndWith
    Else
      ProcedureReturn -1
    EndIf
  EndProcedure
  ProcedureDLL RNet_HTTP_ResetAllocation(ID.l)
    Protected *RObject.S_RNet = RNET_ID(ID)
    If *RObject <>  #Null
      With *RObject\HTTP
        \ContentReturned  = ""
        \State            = #RNet_State_Idle    
      EndWith
      ProcedureReturn #True
    Else
      ProcedureReturn -1
    EndIf
  EndProcedure

  ProcedureDLL RNet_HTTP_SaveToFile(ID.l, Filename.s)
    Protected *RObject.S_RNet = RNET_ID(ID)
    If *RObject <>  #Null
      Protected Output.l
      With *RObject\HTTP
        Output = OpenFile(#PB_Any, FileName)
        If Output
          Debug \ContentReturned
          WriteString(Output, \ContentReturned)
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
      With *RObject\HTTP
        If MemorySize(Buffer) >= Len(\ContentBody)
          PokeS(Buffer, \ContentBody, Len(\ContentBody), #PB_Ascii)
          ProcedureReturn #True
        Else
          ProcedureReturn #False
        EndIf
      EndWith
    Else
      ProcedureReturn -1
    EndIf
  EndProcedure

  ProcedureDLL RNet_HTTP_Examine(ID.l)
    Protected *RObject.S_RNet = RNET_ID(ID)
    If *RObject <>  #Null
      Protected CRLF.s          = Chr(13) + Chr(10)
      Protected Line.s
      Protected GoToBody.l =#False
      With *RObject\HTTP
        For Inc = 1 To CountString(\ContentReturned, CRLF)+1
          If GoToBody = #False
            Line = StringField(\ContentReturned, Inc, CRLF)
            Line = RemoveString(Line, Chr(10))
            Select Trim(LCase(StringField(Line, 1, ":")))
              Case "accept-ranges"
                \Infos_AcceptRanges     = Trim(StringField(Line, 2, ":"))
              Case "date"
                \Infos_Date             = Trim(StringField(Line, 2, ":"))
              Case "content-length"
                \Infos_ContentLength    = Trim(StringField(Line, 2, ":"))
              Case "content-type"
                \Infos_ContentType      = Trim(StringField(Line, 2, ":"))
              Case "server"
                \Infos_Server           = Trim(StringField(Line, 2, ":"))
              Case "last-modified"
                \Infos_LastModified     = Trim(StringField(Line, 2, ":"))
              Case "etag"
                \Infos_Etag             = Trim(StringField(Line, 2, ":"))
              Case "via"
                \Infos_Via              = Trim(StringField(Line, 2, ":"))
              Case "age"
                \Infos_Age              = Trim(StringField(Line, 2, ":"))
              Case "transfer-encoding"
                \Infos_TransferEncoding = Trim(StringField(Line, 2, ":"))
              Case "cache-control"
                \Infos_CacheControl = Trim(StringField(Line, 2, ":"))
              Case "set-cookie"
                \Infos_SetCookie = Trim(StringField(Line, 2, ":"))
              Case ""
                GoToBody = #True
              Default
                Select Trim(LCase(Left(Line, 4)))
                  Case "http"
                    \Infos_HTTPVersion  = Trim(StringField(Line, 1, " "))
                    \Infos_HTTPCode     = Trim(Right(Line, Len(Line) - Len(\Infos_HTTPVersion) -1))
                  Default
                EndSelect
            EndSelect
          Else
            \ContentBody + StringField(\ContentReturned, Inc, CRLF)
          EndIf
        Next
      EndWith
    Else
      ProcedureReturn -1
    EndIf
  EndProcedure
  ProcedureDLL.s RNet_HTTP_GetAttribute(ID.l, AttributeType.l)
    Protected *RObject.S_RNet = RNET_ID(ID)
    If *RObject <>  #Null
      With *RObject\HTTP
        Select AttributeType
          Case #RNet_HTTP_Attribute_FileSize
            ProcedureReturn Str(Len(\ContentBody))
          Case #RNet_HTTP_Attribute_Size
            ProcedureReturn Str(Len(\ContentReturned))
          Case #RNet_HTTP_Attribute_ContentBody
            ProcedureReturn \ContentBody
          Case #RNet_HTTP_Attribute_ContentAll
            ProcedureReturn \ContentReturned
          Case #RNet_HTTP_Attribute_ContentHeader
            ProcedureReturn Left(\ContentReturned, Len(\ContentReturned)-Len(\ContentBody))
          Case #RNet_HTTP_Attribute_AcceptRanges
            ProcedureReturn \Infos_AcceptRanges
          Case #RNet_HTTP_Attribute_Date
            ProcedureReturn \Infos_Date
          Case #RNet_HTTP_Attribute_ContentLength
            ProcedureReturn \Infos_ContentLength
          Case #RNet_HTTP_Attribute_ContentType
            ProcedureReturn \Infos_ContentType
          Case #RNet_HTTP_Attribute_Server
            ProcedureReturn \Infos_Server
          Case #RNet_HTTP_Attribute_LastModified
            ProcedureReturn \Infos_LastModified
          Case #RNet_HTTP_Attribute_Etag
            ProcedureReturn \Infos_Etag
          Case #RNet_HTTP_Attribute_Via
            ProcedureReturn \Infos_Via
          Case #RNet_HTTP_Attribute_Age
            ProcedureReturn \Infos_Age
          Case #RNet_HTTP_Attribute_HTTPVersion
            ProcedureReturn \Infos_HTTPVersion
          Case #RNet_HTTP_Attribute_HTTPCode
            ProcedureReturn \Infos_HTTPCode
          Case #RNet_HTTP_Attribute_TransferEncoding
            ProcedureReturn \Infos_TransferEncoding
          Case #RNet_HTTP_Attribute_SetCookie
            ProcedureReturn \Infos_SetCookie
        EndSelect
      EndWith
    Else
      ProcedureReturn ""
    EndIf
  EndProcedure
  ProcedureDLL RNet_HTTP_SetAttribute(ID.l, AttributeType.l, AttributContent.s)
    Protected *RObject.S_RNet = RNET_ID(ID)
    If *RObject <>  #Null
      With *RObject\HTTP
        Select AttributeType
          Case #RNet_HTTP_Attribute_UserAgent
            \Infos_UserAgent    = AttributContent
          Case #RNet_HTTP_Attribute_Range
            \Infos_Range        = AttributContent
          Case #RNet_HTTP_Attribute_CacheControl
            \Infos_CacheControl = AttributContent
          Case #RNet_HTTP_Attribute_Referer
            \Infos_Referer      = AttributContent
          Case #RNet_HTTP_Attribute_HTTPVersion
            \Infos_HTTPVersion  = AttributContent
          Case #RNet_HTTP_Attribute_ContentType
            \Infos_ContentType  = AttributContent
          ;Case #RNet_HTTP_Attribute_
        EndSelect
      EndWith
      ProcedureReturn #True
    Else
      ProcedureReturn -1
    EndIf
  EndProcedure
  ProcedureDLL RNet_HTTP_ResetAttribute(ID.l)
    Protected *RObject.S_RNet = RNET_ID(ID)
    If *RObject <>  #Null
      With *RObject\HTTP
        \ContentReturned    = ""
        \Infos_HTTPVersion  = ""
        \Infos_HTTPCode     = ""
        \Infos_AcceptRanges = ""
        \Infos_Date         = ""
        \Infos_ContentLength= ""
        \Infos_ContentType  = ""
        \Infos_Server       = ""
        \Infos_LastModified = ""
        \Infos_Etag         = ""
        \Infos_Via          = ""
        \Infos_Age          = ""
        \ContentBody        = ""
      EndWith
      ProcedureReturn #True
    Else
      ProcedureReturn -1
    EndIf
  EndProcedure
  ProcedureDLL RNet_HTTP_SetPostData(ID.l, Buffer.l, Length.l)
    Protected *RObject.S_RNet = RNET_ID(ID)
    If *RObject <>  #Null
      With *RObject\HTTP
        \Post_Data      = AllocateMemory(Length)
        CopyMemory(Buffer, \Post_Data, Length)
        \Post_Data_Len  = Length
      EndWith
      ProcedureReturn #True
    Else
      ProcedureReturn -1
    EndIf
  EndProcedure
  ProcedureDLL RNet_HTTP_SetTimeout(ID.l, Timeout.l)
    Protected *RObject.S_RNet = RNET_ID(ID)
    If *RObject <>  #Null
      With *RObject\HTTP
        \Timeout  = Timeout
      EndWith
      ProcedureReturn #True
    Else
      ProcedureReturn -1
    EndIf
  EndProcedure
  
  ProcedureDLL RNet_HTTP_(ID.l)
    Protected *RObject.S_RNet = RNET_ID(ID)
    If *RObject <>  #Null
      With *RObject\HTTP
  
      EndWith
      ProcedureReturn #True
    Else
      ProcedureReturn -1
    EndIf
  EndProcedure

; IDE Options = PureBasic 4.20 (Linux - x86)
; CursorPosition = 506
; Folding = CAMAAAAAAc4PAAA-
; UseMainFile = RNet_Ex_HTTP_00.pb