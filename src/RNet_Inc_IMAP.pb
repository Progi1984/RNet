  ; Doc
  ;   http://bobpeers.com/technical/telnet_imap
  ;   http://www.iprelax.fr/imap/imap_session.php
  ;   http://blogpmenier.dynalias.net/?2005/05/10/64-connexion-telnet-sur-un-serveur-imap
  ;   http://www.toutestfacile.com/php/cours/printables/PHPFacile.com-imap.php
  ;   http://www.journaldunet.com/developpeur/tutoriel/php/050503-php-email-imap-lecteur-1a.shtml
  ;   http://christian.caleca.free.fr/imap/
  ;   http://dadmin.over-blog.com/article-12245804.html
  ;   http://www.nicolasjean.com/article_pop.pdf
  ;   http://cri.univ-lyon2.fr/doc/ImapMaisCEstTresSimple.html#SELECT
  ;   http://getpopfile.org/docs/imapservers
  
  ProcedureDLL RNet_IMAP_Connect(ID.l, Server.s, Port.l = 143, Login.s = "", Password.s = "")
    Protected *RObject.S_RNet = RNET_ID(ID)
    If *RObject <>  #Null
      Protected ValidCommand = -1, StepAuth = 0
      With *RObject\IMAP
        \Server   = Server
        \Port     = Port
        \Login    = Login
        \Password = Password
        \Connexion= OpenNetworkConnection(\Server, \Port)
        Repeat
          If NetworkClientEvent(\Connexion) = #PB_NetworkEvent_Data
            *Buffer     = AllocateMemory(1024)
            ReturnData  = ReceiveNetworkData(\Connexion, *Buffer, 1024)
            If Trim(PeekS(*Buffer)) > ""
              \CmdLastAnswer = Trim(PeekS(*Buffer))
              If Left(PeekS(*Buffer), 4) = "* OK" Or Left(PeekS(*Buffer), Len("A"+Str(\CmdId)+" OK")) = "A"+Str(\CmdId)+" OK"
                ValidCommand = #True
              Else
                ValidCommand = #False
              EndIf
            EndIf
            If ValidCommand = #True
              Select StepAuth
                Case 0 : \CmdId+1 : SendNetworkString(\Connexion, "A"+Str(\CmdId)+" login "+ \Login + " "+\Password+#RNet_Const_CRLF) : StepAuth + 1 : ValidCommand = -1
                Case 1 : MainOut = #True
              EndSelect
            ElseIf ValidCommand = #False
              Select StepAuth
                Case 1 : MainOut = #True : RNet_SetLastError(#RNet_Error_BadLogin)
              EndSelect
              MainOut = #True
            EndIf
            FreeMemory(*Buffer)
          EndIf
        Until MainOut = #True
      EndWith
      ProcedureReturn ValidCommand
    Else
      ProcedureReturn #False
    EndIf
  EndProcedure
  ProcedureDLL RNet_IMAP_Disconnect(ID.l)
    Protected *RObject.S_RNet = RNET_ID(ID)
    If *RObject <>  #Null
      With *RObject\IMAP
        SendNetworkString(\Connexion, "A"+Str(\CmdId)+" LOGOUT"+#RNet_Const_CRLF)
        \CmdId+1
        Repeat
          If NetworkClientEvent(\Connexion) = #PB_NetworkEvent_Data
            *Buffer     = AllocateMemory(1024)
            ReturnData  = ReceiveNetworkData(\Connexion, *Buffer, 1024)
            If Trim(PeekS(*Buffer)) > ""
              \CmdLastAnswer = Trim(PeekS(*Buffer))
              If Left(PeekS(*Buffer), 4) = "* BYE"
                ValidCommand = #True  : MainOut = #True
              Else
                ValidCommand = #False : MainOut = #True
              EndIf
            EndIf
            FreeMemory(*Buffer)
          EndIf
        Until MainOut = #True
        CloseNetworkConnection(\Connexion)
        \Connexion  = 0
      EndWith
      ProcedureReturn #True
    Else
      ProcedureReturn #False
    EndIf
  EndProcedure
  ProcedureDLL.s RNet_IMAP_ListFolders(ID.l, Pattern.s)
    Protected *RObject.S_RNet = RNET_ID(ID)
    If *RObject <>  #Null
      Protected Inc.l
      Protected Content.s, ReturnValue.s
      With *RObject\IMAP
        SendNetworkString(\Connexion, "A"+Str(\CmdId)+" LIST "+#RNet_Const_Quote+#RNet_Const_Quote+" "+#RNet_Const_Quote+Pattern+#RNet_Const_Quote+#RNet_Const_CRLF)
        \CmdId+1
        Repeat
          If NetworkClientEvent(\Connexion) = #PB_NetworkEvent_Data
            *Buffer     = AllocateMemory(1024)
            ReturnData  = ReceiveNetworkData(\Connexion, *Buffer, 1024)
            If Trim(PeekS(*Buffer)) > ""
              \CmdLastAnswer = Trim(PeekS(*Buffer))
              If Left(PeekS(*Buffer), Len("A"+Str(\CmdId-1)+" OK")) = "A"+Str(\CmdId-1)+" OK"
                MainOut = #True
              Else
                For Inc = 1 To CountString(\CmdLastAnswer, Chr(13))
                  Content = StringField(\CmdLastAnswer, Inc,Chr(13))
                  Content = RemoveString(Content, Chr(13))
                  Content = RemoveString(Content, Chr(10))
                  Content = Trim(Content)
                  Content = StringField(Content, CountString(Content, #RNet_Const_Quote), #RNet_Const_Quote)
                  If ReturnValue = ""
                    ReturnValue = Content
                  Else
                    ReturnValue + #RNet_Const_Tab + Content
                  EndIf
                Next
              EndIf
            EndIf
            FreeMemory(*Buffer)
          EndIf
        Until MainOut = #True
      EndWith
      ProcedureReturn ReturnValue
    Else
      ProcedureReturn ""
    EndIf
  EndProcedure

  ProcedureDLL RNet_IMAP_CreateDirectory(ID.l, Name.s)
    Protected *RObject.S_RNet = RNET_ID(ID)
    If *RObject <>  #Null
      Protected ReturnValue.l, Content.s
      With *RObject\IMAP
        SendNetworkString(\Connexion, "A"+Str(\CmdId)+" CREATE "+Name+#RNet_Const_CRLF)
        \CmdId+1
        Repeat
          If NetworkClientEvent(\Connexion) = #PB_NetworkEvent_Data
            *Buffer     = AllocateMemory(1024)
            ReturnData  = ReceiveNetworkData(\Connexion, *Buffer, 1024)
            If Trim(PeekS(*Buffer)) > ""
              \CmdLastAnswer = Trim(PeekS(*Buffer))
              If Left(PeekS(*Buffer), Len("A"+Str(\CmdId-1)+" OK")) = "A"+Str(\CmdId-1)+" OK"
                MainOut     = #True
                ReturnValue = #True
              ElseIf Left(PeekS(*Buffer), Len("A"+Str(\CmdId-1)+" NO")) = "A"+Str(\CmdId-1)+" NO"
                Content = RemoveString(\CmdLastAnswer, Chr(13))
                Content = RemoveString(Content, Chr(10))
                If FindString(LCase(Content), "file exists", 1) > 0
                  MainOut     = #True
                  ReturnValue = #False
                  RNet_SetLastError(#RNet_Error_EverExisting)
                ElseIf FindString(LCase(Content), "mailbox already exists", 1) > 0
                  MainOut     = #True
                  ReturnValue = #False
                  RNet_SetLastError(#RNet_Error_EverExisting)
                ElseIf FindString(LCase(Content), "invalid mailbox name", 1) > 0
                  MainOut     = #True
                  ReturnValue = #False
                  RNet_SetLastError(#RNet_Error_SyntaxError)
                Else
                  Debug "RNet_IMAP_CreateDirectory>"+\CmdLastAnswer
                EndIf
              EndIf
            EndIf
            FreeMemory(*Buffer)
          EndIf
        Until MainOut = #True
      EndWith
      ProcedureReturn ReturnValue
    Else
      ProcedureReturn #False
    EndIf
  EndProcedure
  ProcedureDLL RNet_IMAP_DeleteDirectory(ID.l, Name.s)
    Protected *RObject.S_RNet = RNET_ID(ID)
    If *RObject <>  #Null
      Protected ReturnValue.l, Content.s
      With *RObject\IMAP
        SendNetworkString(\Connexion, "A"+Str(\CmdId)+" DELETE "+Name+#RNet_Const_CRLF)
        \CmdId+1
        Repeat
          If NetworkClientEvent(\Connexion) = #PB_NetworkEvent_Data
            *Buffer     = AllocateMemory(1024)
            ReturnData  = ReceiveNetworkData(\Connexion, *Buffer, 1024)
            If Trim(PeekS(*Buffer)) > ""
              \CmdLastAnswer = Trim(PeekS(*Buffer))
              If Left(PeekS(*Buffer), Len("A"+Str(\CmdId-1)+" OK")) = "A"+Str(\CmdId-1)+" OK"
                MainOut     = #True
                ReturnValue = #True
              ElseIf Left(PeekS(*Buffer), Len("A"+Str(\CmdId-1)+" NO")) = "A"+Str(\CmdId-1)+" NO"
                Content = RemoveString(\CmdLastAnswer, Chr(13))
                Content = RemoveString(Content, Chr(10))
              Else
                Debug "RNet_IMAP_DeleteDirectory>"+\CmdLastAnswer
              EndIf
            EndIf
            FreeMemory(*Buffer)
          EndIf
        Until MainOut = #True
      EndWith
      ProcedureReturn ReturnValue
    Else
      ProcedureReturn #False
    EndIf
  EndProcedure
  ProcedureDLL RNet_IMAP_RenameDirectory(ID.l, OldName.s, NewName.s)
    Protected *RObject.S_RNet = RNET_ID(ID)
    If *RObject <>  #Null
      Protected ReturnValue.l, Content.s
      With *RObject\IMAP
        SendNetworkString(\Connexion, "A"+Str(\CmdId)+" RENAME "+OldName+" "+NewName+#RNet_Const_CRLF)
        \CmdId+1
        Repeat
          If NetworkClientEvent(\Connexion) = #PB_NetworkEvent_Data
            *Buffer     = AllocateMemory(1024)
            ReturnData  = ReceiveNetworkData(\Connexion, *Buffer, 1024)
            If Trim(PeekS(*Buffer)) > ""
              \CmdLastAnswer = Trim(PeekS(*Buffer))
              If Left(PeekS(*Buffer), Len("A"+Str(\CmdId-1)+" OK")) = "A"+Str(\CmdId-1)+" OK"
                MainOut     = #True
                ReturnValue = #True
              ElseIf Left(PeekS(*Buffer), Len("A"+Str(\CmdId-1)+" NO")) = "A"+Str(\CmdId-1)+" NO"
                Content = RemoveString(\CmdLastAnswer, Chr(13))
                Content = RemoveString(Content, Chr(10))
                If FindString(LCase(Content), "mailbox already exists",0) > 0
                  MainOut     = #True
                  ReturnValue = #False
                  RNet_SetLastError(#RNet_Error_EverExisting)
                EndIf
              Else
                Debug "RNet_IMAP_RenameDirectory>"+\CmdLastAnswer
              EndIf
            EndIf
            FreeMemory(*Buffer)
          EndIf
        Until MainOut = #True
      EndWith
      ProcedureReturn ReturnValue
    Else
      ProcedureReturn #False
    EndIf
  EndProcedure
  ProcedureDLL RNet_IMAP_SetDirectory(ID.l, Name.s)
    Protected *RObject.S_RNet = RNET_ID(ID)
    If *RObject <>  #Null
      Protected Inc.l, Content.s
      With *RObject\IMAP
        SendNetworkString(\Connexion, "A"+Str(\CmdId)+" SELECT "+#RNet_Const_Quote+Name+#RNet_Const_Quote+#RNet_Const_CRLF)
        \CmdId    + 1
        \DirInfos = ""
        Repeat
          If NetworkClientEvent(\Connexion) = #PB_NetworkEvent_Data
            *Buffer     = AllocateMemory(1024)
            ReturnData  = ReceiveNetworkData(\Connexion, *Buffer, 1024)
            If Trim(PeekS(*Buffer)) > ""
              \CmdLastAnswer = Trim(PeekS(*Buffer))
              For Inc = 0 To CountString(PeekS(*Buffer), Chr(13))
                Content = StringField(PeekS(*Buffer), Inc+1, Chr(13))
                Content = RemoveString(Content, Chr(13))
                Content = RemoveString(Content, Chr(10))
                Content = Trim(content)
                If Content <> ""
                  If Left(Content, Len("A"+Str(\CmdId-1)+" OK")) = "A"+Str(\CmdId-1)+" OK"
                    MainOut     = #True
                    ReturnValue = #True
                  Else
                    \DirInfos + Content + #RNet_Const_CRLF
                  EndIf                
                EndIf
              Next
            EndIf
            FreeMemory(*Buffer)
          EndIf
        Until MainOut = #True
      EndWith
      ProcedureReturn ReturnValue
    Else
      ProcedureReturn #False
    EndIf
  EndProcedure
  ProcedureDLL RNet_IMAP_ExamineDirectory(ID.l)
    Protected *RObject.S_RNet = RNET_ID(ID)
    If *RObject <>  #Null
      Protected Inc.l, Content.s
      With *RObject\IMAP
        \Dir_MessagesAll    = 0
        \Dir_MessagesRecent = 0
        \Dir_MessagesUnseen = 0
        \Dir_UIDNext        = 0
        \Dir_UIDValidity    = 0
        \Dir_Flags          = ""
        \Dir_PermanentFlags = ""
        For Inc = 0 To CountString(\DirInfos, #RNet_Const_CRLF) - 1
          Content = StringField(\DirInfos, Inc + 1, #RNet_Const_CRLF)
          Content = RemoveString(Content, Chr(13))
          Content = RemoveString(Content, Chr(10))
          If Asc(Content) = '*'       : Content = Trim(Right(Content, Len(Content) - 1)):EndIf
          If Left(Content, 2) = "OK"  : Content = Trim(Right(Content, Len(Content) - 2)):EndIf
          Select StringField(Content, 1, " ")
            Case "FLAGS"
            ;{
              Content             = RemoveString(Content, "FLAGS")
              Content             = RemoveString(Content, "[")
              Content             = RemoveString(Content, "]")
              Content             = RemoveString(Content, "(")
              Content             = RemoveString(Content, ")")
              Content             = Trim(Content)
              \Dir_Flags          = Content
            ;}
            Case "[PERMANENTFLAGS"
            ;{
              Content             = RemoveString(Content, "PERMANENTFLAGS")
              Content             = RemoveString(Content, "[")
              Content             = RemoveString(Content, "]")
              Content             = RemoveString(Content, "(")
              Content             = RemoveString(Content, ")")
              Content             = Trim(Content)
              \Dir_PermanentFlags = Content
            ;}
            Case "[UNSEEN"
            ;{
              Content             = RemoveString(Content, "]")
              Content             = RemoveString(Content, "[")
              \Dir_MessagesUnseen = Val(StringField(Content, CountString(Content, " ")+1, " "))
            ;}
            Case "[UIDVALIDITY"
            ;{
              Content = RemoveString(Content, "]")
              Content = RemoveString(Content, "[")
              \Dir_UIDValidity = Val(StringField(Content, CountString(Content, " ")+1, " "))
            ;}
            Case "[UIDNEXT"
            ;{
              Content = RemoveString(Content, "]")
              Content = RemoveString(Content, "[")
              \Dir_UIDNext = Val(StringField(Content, CountString(Content, " ")+1, " "))
            ;}
            Default
              Select StringField(Content, CountString(Content, " ")+1, " ")
                Case "EXISTS"
                  \Dir_MessagesAll = Val(StringField(Content, 1, " "))
                Case "RECENT"
                  \Dir_MessagesRecent = Val(StringField(Content, 1, " "))
                Default
                  Debug "RNet_IMAP_ExamineDirectory > "+StringField(Content, CountString(Content, " ")+1, " ")
              EndSelect
          EndSelect
          
        Next
      EndWith
      ProcedureReturn #True
    Else
      ProcedureReturn #False
    EndIf
  EndProcedure
  ProcedureDLL.s RNet_IMAP_GetFlags(ID.l, Permanent.l = #False)
    Protected *RObject.S_RNet = RNET_ID(ID)
    If *RObject <>  #Null
      With *RObject\IMAP
        If Permanent = #False
          ProcedureReturn \Dir_Flags
        Else
          ProcedureReturn \Dir_PermanentFlags
        EndIf
      EndWith
    Else
      ProcedureReturn ""
    EndIf
  EndProcedure
  ProcedureDLL RNet_IMAP_GetUIDNext(ID.l)
    Protected *RObject.S_RNet = RNET_ID(ID)
    If *RObject <>  #Null
      With *RObject\IMAP
        ProcedureReturn \Dir_UIDNext
      EndWith
    Else
      ProcedureReturn #False
    EndIf
  EndProcedure
  ProcedureDLL RNet_IMAP_GetUIDValidity(ID.l)
    Protected *RObject.S_RNet = RNET_ID(ID)
    If *RObject <>  #Null
      With *RObject\IMAP
        ProcedureReturn \Dir_UIDValidity
      EndWith
    Else
      ProcedureReturn #False
    EndIf
  EndProcedure
  ProcedureDLL RNet_IMAP_CountMessagesAll(ID.l)
    Protected *RObject.S_RNet = RNET_ID(ID)
    If *RObject <>  #Null
      With *RObject\IMAP
        ProcedureReturn \Dir_MessagesAll
      EndWith
    Else
      ProcedureReturn #False
    EndIf
  EndProcedure
  ProcedureDLL RNet_IMAP_CountMessagesUnseen(ID.l)
    Protected *RObject.S_RNet = RNET_ID(ID)
    If *RObject <>  #Null
      With *RObject\IMAP
        ProcedureReturn \Dir_MessagesUnseen
      EndWith
    Else
      ProcedureReturn #False
    EndIf
  EndProcedure
  ProcedureDLL RNet_IMAP_CountMessagesRecent(ID.l)
    Protected *RObject.S_RNet = RNET_ID(ID)
    If *RObject <>  #Null
      With *RObject\IMAP
        ProcedureReturn \Dir_MessagesRecent
      EndWith
    Else
      ProcedureReturn #False
    EndIf
  EndProcedure

  ProcedureDLL RNet_IMAP_RetrieveMessage(ID.l, Item.l)
    Protected *RObject.S_RNet = RNET_ID(ID)
    If *RObject <>  #Null
      With *RObject\IMAP
        SendNetworkString(\Connexion, "A"+Str(\CmdId)+" FETCH "+Str(Item)+" RFC822.HEADER"+#RNet_Const_CRLF)
        \CmdId    + 1
        \Msg      = ""
        Repeat
          If NetworkClientEvent(\Connexion) = #PB_NetworkEvent_Data
            *Buffer     = AllocateMemory(1024)
            ReturnData  = ReceiveNetworkData(\Connexion, *Buffer, 1024)
            If Trim(PeekS(*Buffer)) > ""
              \CmdLastAnswer = Trim(PeekS(*Buffer))
              \Msg + \CmdLastAnswer
              If FindString(\CmdLastAnswer, "A"+Str(\CmdId-1)+" OK", 0) > 0
                MainOut     = #True
              EndIf
            EndIf
            FreeMemory(*Buffer)
          EndIf
        Until MainOut = #True
        SendNetworkString(\Connexion, "A"+Str(\CmdId)+" FETCH "+Str(Item)+" RFC822.TEXT"+#RNet_Const_CRLF)
        \CmdId    + 1
        MainOut   = #False
        Repeat
          If NetworkClientEvent(\Connexion) = #PB_NetworkEvent_Data
            *Buffer     = AllocateMemory(1024)
            ReturnData  = ReceiveNetworkData(\Connexion, *Buffer, 1024)
            If Trim(PeekS(*Buffer)) > ""
              \CmdLastAnswer = Trim(PeekS(*Buffer))
              \Msg + \CmdLastAnswer
              If FindString(\CmdLastAnswer, "A"+Str(\CmdId-1)+" OK", 0) > 0
                MainOut     = #True
              EndIf
            EndIf
            FreeMemory(*Buffer)
          EndIf
        Until MainOut = #True
      EndWith
      ProcedureReturn #True
    Else
      ProcedureReturn #False
    EndIf
  EndProcedure
  ProcedureDLL RNet_IMAP_ExamineMessage(ID.l)
    Protected *RObject.S_RNet = RNET_ID(ID)
    If *RObject <>  #Null
      With *RObject\IMAP
        If FindString(\Msg, "FETCH(RFC822.HEADER",0)>0
          Ret     = FindString(\Msg, "FETCH(RFC822.HEADER",0)
          RetFin  = FindString(\Msg, "}",Ret+1)
          \MsgSize  = Val(RemoveString(StringField(\Msg, 2,"{"), "}"))
          \Msg    = Right(\Msg, Len(\Msg) -  RetFin)
          If Asc(\Msg) = 13 : \Msg = Trim(Right(\Msg, Len(\Msg) - 1)): EndIf
          If Asc(\Msg) = 10 : \Msg = Trim(Right(\Msg, Len(\Msg) - 1)): EndIf
        EndIf
        
        RNet_Mail_ExamineMessage(\Mail, #RNet_Type_IMAP, \Msg)
        
        If FindString(\Mail\Infos_Body, "FETCH(RFC822.TEXT",0)>0 Or FindString(\Mail\Infos_Body, "FETCH (RFC822.TEXT",0)>0
          Res = FindString(\Mail\Infos_Body, "FETCH(RFC822.TEXT",0)
          If Res = 0
            Res = FindString(\Mail\Infos_Body, "FETCH (RFC822.TEXT",0)
          EndIf
          \Mail\Infos_Body = Right(\Mail\Infos_Body, Len(\Mail\Infos_Body) - FindString(\Mail\Infos_Body, "}", Res+1))
        EndIf
        While Left(\Mail\Infos_Body,1) = Chr(13) Or Left(\Mail\Infos_Body,1) = Chr(10) 
          \Mail\Infos_Body = Right(\Mail\Infos_Body, Len(\Mail\Infos_Body)-1)
        Wend
        While Right(\Mail\Infos_Body,1) = Chr(13) Or Left(\Mail\Infos_Body,1) = Chr(10) 
          \Mail\Infos_Body = Left(\Mail\Infos_Body, Len(\Mail\Infos_Body)-1)
        Wend
      EndWith
      ProcedureReturn #True
    Else
      ProcedureReturn #False
    EndIf
  EndProcedure
  ProcedureDLL RNet_IMAP_GetMessageSize(ID.l)
    Protected *RObject.S_RNet = RNET_ID(ID)
    If *RObject <>  #Null
      With *RObject\IMAP
        ProcedureReturn \MsgSize
      EndWith
    Else
      ProcedureReturn #False
    EndIf
  EndProcedure
  ProcedureDLL.s RNet_IMAP_GetAttribute(ID.l, Attribute.l)
    Protected *RObject.S_RNet = RNET_ID(ID)
    If *RObject <>  #Null
      ProcedureReturn RNet_Mail_GetAttribute(*RObject\IMAP\Mail, Attribute)
    Else
      ProcedureReturn ""
    EndIf
  EndProcedure
  ProcedureDLL.s RNet_IMAP_GetBody(ID.l)
    Protected *RObject.S_RNet = RNET_ID(ID)
    If *RObject <>  #Null
      With *RObject\IMAP
        ProcedureReturn RNet_Mail_GetBody(\Mail)
      EndWith
    Else
      ProcedureReturn ""
    EndIf
  EndProcedure
  ProcedureDLL RNet_IMAP_SaveToFile(ID.l, Filename.s)
    Protected *RObject.S_RNet = RNET_ID(ID)
    If *RObject <>  #Null
      Protected FileID.l
      With *RObject\IMAP
        FileID = OpenFile(#PB_Any, Filename)
        If FileID
          WriteString(FileID, \Mail\Infos_Body, #PB_Ascii)
          CloseFile(FileID)
          ProcedureReturn #True
        Else
          RNet_SetLastError(#RNet_Error_WritingInFile)
          ProcedureReturn #False
        EndIf
      EndWith
    Else
      ProcedureReturn #False
    EndIf
  EndProcedure
  ProcedureDLL RNet_IMAP_SaveToMemory(ID.l, Buffer.l)
    Protected *RObject.S_RNet = RNET_ID(ID)
    If *RObject <>  #Null
      With *RObject\IMAP
        If MemorySize(Buffer) >= Len(\Mail\Infos_Body)
          PokeS(Buffer, \Mail\Infos_Body, Len(\Mail\Infos_Body), #PB_Ascii)
          ProcedureReturn #True
        Else
          RNet_SetLastError(#RNet_Error_MemorySmall)
          ProcedureReturn #False
        EndIf
      EndWith
      ProcedureReturn #True
    Else
      ProcedureReturn #False
    EndIf
  EndProcedure
  ProcedureDLL RNet_IMAP_DeleteMessage(ID.l, Item.l)
    Protected *RObject.S_RNet = RNET_ID(ID)
    If *RObject <>  #Null
      With *RObject\IMAP
        SendNetworkString(\Connexion, "A"+Str(\CmdId)+" STORE "+Str(Item)+" FLAGS \DELETED"+#RNet_Const_CRLF)
        \CmdId    + 1
        Repeat
          If NetworkClientEvent(\Connexion) = #PB_NetworkEvent_Data
            *Buffer     = AllocateMemory(1024)
            ReturnData  = ReceiveNetworkData(\Connexion, *Buffer, 1024)
            If Trim(PeekS(*Buffer)) > ""
              \CmdLastAnswer = Trim(PeekS(*Buffer))
              If FindString(\CmdLastAnswer, "A"+Str(\CmdId-1)+" OK", 0) > 0
                MainOut     = #True
              EndIf
            EndIf
            FreeMemory(*Buffer)
          EndIf
        Until MainOut = #True
        SendNetworkString(\Connexion, "A"+Str(\CmdId)+" EXPUNGE"+#RNet_Const_CRLF)
        \CmdId    + 1
        MainOut   = #False
        Repeat
          If NetworkClientEvent(\Connexion) = #PB_NetworkEvent_Data
            *Buffer     = AllocateMemory(1024)
            ReturnData  = ReceiveNetworkData(\Connexion, *Buffer, 1024)
            If Trim(PeekS(*Buffer)) > ""
              \CmdLastAnswer = Trim(PeekS(*Buffer))
              If FindString(\CmdLastAnswer, "A"+Str(\CmdId-1)+" OK", 0) > 0
                MainOut     = #True
              EndIf
            EndIf
            FreeMemory(*Buffer)
          EndIf
        Until MainOut = #True

      EndWith
      ProcedureReturn #True
    Else
      ProcedureReturn #False
    EndIf
  EndProcedure
  ProcedureDLL RNet_IMAP_NoOperation(ID.l)
    Protected *RObject.S_RNet = RNET_ID(ID)
    If *RObject <>  #Null
      Protected MsgID.l 
      With *RObject\IMAP
        SendNetworkString(\Connexion, "A"+Str(\CmdId)+"NOOP "+ #RNet_Const_CRLF)
        Repeat
          *Buffer   = AllocateMemory(1024)
          If NetworkClientEvent(\Connexion) = #PB_NetworkEvent_Data
            *Buffer     = AllocateMemory(1024)
            ReturnData  = ReceiveNetworkData(\Connexion, *Buffer, 1024)
            If Trim(PeekS(*Buffer)) > ""
              \CmdLastAnswer = Trim(PeekS(*Buffer))
              If FindString(\CmdLastAnswer, "A"+Str(\CmdId-1)+" OK", 0) > 0
                MainOut     = #True
              EndIf
            EndIf
            FreeMemory(*Buffer)
          EndIf
          FreeMemory(*Buffer)
        Until MainOut >= 1
      EndWith
      If MainOut = 1
        ProcedureReturn #True
      Else
        ProcedureReturn #False
      EndIf
    Else
      ProcedureReturn #False
    EndIf
  EndProcedure


  ProcedureDLL RNet_IMAP_(ID.l)
    Protected *RObject.S_RNet = RNET_ID(ID)
    If *RObject <>  #Null
      With *RObject\IMAP
  
      EndWith
      ProcedureReturn #True
    Else
      ProcedureReturn #False
    EndIf
  EndProcedure

; IDE Options = PureBasic 4.20 (Windows - x86)
; CursorPosition = 467
; FirstLine = 37
; Folding = AAAAAAAAAAAwBtgarnP------
; UseMainFile = ..\RNet_Ex_IMAP_00.pb