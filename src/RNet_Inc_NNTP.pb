  ; Doc
  ;   http://www.iprelax.fr/nntp/nntp_rfc4.php
  ;   http://www.hobbesworld.com/telnet/nntp.php
  ;   http://www.iprelax.fr/nntp/nntp_session.php
  ;   http://www.liafa.jussieu.fr/~yunes/internet/nntp/
  
  ProcedureDLL RNet_NNTP_Connect(ID.l, Server.s, Port.l = 119, Login.s = "", Password.s = "")
    Protected *RObject.S_RNet = RNET_ID(ID)
    If *RObject <>  #Null
      Protected StepAuth = 0, Inc.l
      Protected Content.s
      With *RObject\NNTP
        \Server   = Server
        \Port     = Port
        \Login    = Login
        \Password = Password
        \Connexion= OpenNetworkConnection(\Server, \Port, #PB_Network_TCP)
        Repeat
          *Buffer   = AllocateMemory(1024)
          If NetworkClientEvent(\Connexion) = #PB_NetworkEvent_Data
            ReturnData      = ReceiveNetworkData(\Connexion, *Buffer, 1024)
            If Trim(PeekS(*Buffer)) <> ""
              \CmdLastAnswer  = PeekS(*Buffer)
              Select Left(\CmdLastAnswer, 3)
                Case "200" ; STEPAuth 1
                  StepAuth+1
                  SendNetworkString(\Connexion, "AUTHINFO USER "+\Login+#RNet_Const_CRLF)
                Case "281" ; STEPAuth 3
                  MainOut     = #True
                  ReturnValue = #True
                Case "381" ; STEPAuth 2
                  StepAuth+1
                  If FindString(LCase(\CmdLastAnswer), "381 pass required",0) > 0
                    SendNetworkString(\Connexion, "AUTHINFO PASS "+\Password+#RNet_Const_CRLF)
                  EndIf
                Case "400"
                  MainOut     = #True
                  ReturnValue = #False
                  RNet_SetLastError(#RNet_Error_ServerTooBusy)
                Default: Debug "RNet_NNTP_Connect > StepAuth="+Str(StepAuth)+">"+\CmdLastAnswer
              EndSelect
            EndIf
          EndIf
          FreeMemory(*Buffer)
        Until MainOut = #True
      EndWith
      ProcedureReturn ReturnValue
    Else
      ProcedureReturn #False
    EndIf
  EndProcedure
  ProcedureDLL RNet_NNTP_Disconnect(ID.l)
    Protected *RObject.S_RNet = RNET_ID(ID)
    If *RObject <>  #Null
      Protected StepAuth = 0, Inc.l
      Protected Content.s
      With *RObject\NNTP
        SendNetworkString(\Connexion, "QUIT"+#RNet_Const_CRLF)
        Repeat
          *Buffer   = AllocateMemory(1024)
          If NetworkClientEvent(\Connexion) = #PB_NetworkEvent_Data
            ReturnData      = ReceiveNetworkData(\Connexion, *Buffer, 1024)
            If Trim(PeekS(*Buffer)) <> ""
              \CmdLastAnswer  = PeekS(*Buffer)
              Select Left(\CmdLastAnswer, 3)
                Case "205"
                  MainOut = #True
                Default: Debug "RNet_NNTP_Disconnect>"+\CmdLastAnswer
              EndSelect
            EndIf
          EndIf
          FreeMemory(*Buffer)
        Until MainOut = #True
        CloseNetworkConnection(\Connexion)
        \Connexion = 0
      EndWith
      ProcedureReturn #True
    Else
      ProcedureReturn -1
    EndIf
  EndProcedure
  ProcedureDLL.s RNet_NNTP_ExamineGroup(ID.l, Group.s = "")
    Protected *RObject.S_RNet = RNET_ID(ID)
    If *RObject <>  #Null
      With *RObject\NNTP
        Protected Inc.l, Content.s, ResStart.l, ResEnd.l, ResNbSpaces.l, bNewLine.l = #True
        If Group = ""
          SendNetworkString(\Connexion, "LIST"+#RNet_Const_CRLF)
        Else
          SendNetworkString(\Connexion, "LIST NEWSGROUPS "+Group+#RNet_Const_CRLF)
        EndIf
        Repeat
          *Buffer   = AllocateMemory(1024)
          If NetworkClientEvent(\Connexion) = #PB_NetworkEvent_Data
            ReturnData      = ReceiveNetworkData(\Connexion, *Buffer, 1024)
            If Trim(PeekS(*Buffer)) <> ""
              \CmdLastAnswer  = PeekS(*Buffer)
              For Inc = 0 To CountString(\CmdLastAnswer, #RNet_Const_CRLF)
                Content = StringField(\CmdLastAnswer, Inc + 1, #RNet_Const_CRLF)
                Content = RemoveString(Content, Chr($AE))
                Content = RemoveString(Content, Chr($01))
                Content = RemoveString(Content, Chr($81))
                Content = Trim(Content)
                If Left(Content, 4) = "215"
                  ResStart        = FindString(Content, #RNet_Const_Quote, 0)+1
                  ResEnd          = FindString(Content, #RNet_Const_Quote, ResStart)
                  ResNbSpaces     = CountString(Content, " ")
                  \CmdListAnswer  = Mid(Content, ResStart, ResEnd-ResStart)+ #RNet_Const_Tab
                ElseIf Content = Chr(10)+"."
                  MainOut = #True
                Else
                  If Content <> ""
                    If Asc(Content) = 10:bNewLine = #True:Else:bNewLine = #False:EndIf
                    Content = RemoveString(Content, Chr(10))
                    If bNewLine= #True
                      \CmdListAnswer + #RNet_Const_Tab+ Content
                    Else
                      \CmdListAnswer + Content
                    EndIf
                  EndIf
                EndIf
              Next
            EndIf
          EndIf
          FreeMemory(*Buffer)
        Until MainOut = #True
        ProcedureReturn \CmdListAnswer
      EndWith
    Else
      ProcedureReturn ""
    EndIf
  EndProcedure
  ProcedureDLL RNet_NNTP_SetGroup(ID.l, Group.s)
    Protected *RObject.S_RNet = RNET_ID(ID)
    If *RObject <>  #Null
      With *RObject\NNTP
        Protected Content.s
        SendNetworkString(\Connexion, "GROUP "+Group+#RNet_Const_CRLF)
        Repeat
          *Buffer   = AllocateMemory(1024)
          If NetworkClientEvent(\Connexion) = #PB_NetworkEvent_Data
            ReturnData      = ReceiveNetworkData(\Connexion, *Buffer, 1024)
            If Trim(PeekS(*Buffer)) <> ""
              \CmdLastAnswer  = PeekS(*Buffer)
              If Left(\CmdLastAnswer, 3) = "211"
                Content                 = \CmdLastAnswer
                Content                 = RemoveString(Content, Chr(13))
                Content                 = RemoveString(Content, Chr(10))
                \CmdGroup_NbMessages    = Val(StringField(Content, 2, " "))
                \CmdGroup_FirstMessage  = Val(StringField(Content, 3, " "))
                \CmdGroup_LastMessage   = Val(StringField(Content, 4, " "))
                MainOut                 = #True
              EndIf
            EndIf
          EndIf
          FreeMemory(*Buffer)
        Until MainOut = #True
        ProcedureReturn #True
      EndWith
    Else
      ProcedureReturn #False
    EndIf
  EndProcedure
  ProcedureDLL RNet_NNTP_CountMessages(ID.l)
    Protected *RObject.S_RNet = RNET_ID(ID)
    If *RObject <>  #Null
      With *RObject\NNTP
        ProcedureReturn \CmdGroup_NbMessages
      EndWith
    Else
      ProcedureReturn #False
    EndIf
  EndProcedure
  ProcedureDLL RNet_NNTP_GetFirstArticle(ID.l)
    Protected *RObject.S_RNet = RNET_ID(ID)
    If *RObject <>  #Null
      With *RObject\NNTP
        ProcedureReturn \CmdGroup_FirstMessage
      EndWith
    Else
      ProcedureReturn #False
    EndIf
  EndProcedure
  ProcedureDLL RNet_NNTP_GetLastArticle(ID.l)
    Protected *RObject.S_RNet = RNET_ID(ID)
    If *RObject <>  #Null
      With *RObject\NNTP
        ProcedureReturn \CmdGroup_LastMessage
      EndWith
    Else
      ProcedureReturn #False
    EndIf
  EndProcedure
  ProcedureDLL RNet_NNTP_RetrieveArticle(ID.l, Item.l)
    Protected *RObject.S_RNet = RNET_ID(ID)
    If *RObject <>  #Null
      With *RObject\NNTP
        Protected Content.s
        SendNetworkString(\Connexion, "ARTICLE "+Str(Item)+#RNet_Const_CRLF)
        Repeat
          *Buffer   = AllocateMemory(1024)
          If NetworkClientEvent(\Connexion) = #PB_NetworkEvent_Data
            ReturnData      = ReceiveNetworkData(\Connexion, *Buffer, 1024)
            If Trim(PeekS(*Buffer)) <> ""
              \CmdLastAnswer  = PeekS(*Buffer)
              \CmdArticle_Answer + \CmdLastAnswer

              Content = StringField(\CmdArticle_Answer, CountString(\CmdArticle_Answer, #RNet_Const_CRLF), #RNet_Const_CRLF)
              Content = RemoveString(Content, Chr(13))
              Content = RemoveString(Content, Chr(10))
              Content = Trim(Content)
              If Content = "."
                MainOut = #True
              EndIf
            EndIf
          EndIf
          FreeMemory(*Buffer)
        Until MainOut = #True
      EndWith
      ProcedureReturn #True
    Else
      ProcedureReturn -1
    EndIf
  EndProcedure
  ProcedureDLL RNet_NNTP_ExamineMessage(ID.l)
    Protected *RObject.S_RNet = RNET_ID(ID)
    If *RObject <>  #Null
      With *RObject\NNTP
        Protected Content.s, LastPart_1.s, Part_1.s, Part_2.s, Inc.l, IncBis.l, InHeader.l = #False
        Content = StringField(\CmdArticle_Answer, 1, Chr(13)+Chr(10))
        Content = RemoveString(Content, Chr(10))
        If Left(Content, 3) = "220"
          \CmdArticle_MessageID   = StringField(Content, 2, " ")
          \CmdArticle_Identifier  = StringField(Content, 3, " ")
        EndIf
        \CmdArticle_Answer = Trim(Right(\CmdArticle_Answer, Len(\CmdArticle_Answer) - Len(Content)))
        If Asc(\CmdArticle_Answer) = 13 : \CmdArticle_Answer = Trim(Right(\CmdArticle_Answer, Len(\CmdArticle_Answer) - 1)): EndIf
        If Asc(\CmdArticle_Answer) = 10 : \CmdArticle_Answer = Trim(Right(\CmdArticle_Answer, Len(\CmdArticle_Answer) - 1)): EndIf
        RNet_Mail_ExamineMessage(\Mail, #RNet_Type_NNTP, \CmdArticle_Answer)
      EndWith
      ProcedureReturn #True
    Else
      ProcedureReturn #False
    EndIf
  EndProcedure
  ProcedureDLL RNet_NNTP_GetNextArticle(ID.l)
    Protected *RObject.S_RNet = RNET_ID(ID)
    If *RObject <>  #Null
      With *RObject\NNTP
        Protected Content.s
        SendNetworkString(\Connexion, "NEXT "+#RNet_Const_CRLF)
        Repeat
          *Buffer   = AllocateMemory(1024)
          If NetworkClientEvent(\Connexion) = #PB_NetworkEvent_Data
            ReturnData      = ReceiveNetworkData(\Connexion, *Buffer, 1024)
            If Trim(PeekS(*Buffer)) <> ""
              \CmdLastAnswer  = PeekS(*Buffer)
              If Left(\CmdLastAnswer, 3) = "223"
                ReturnValue             = Val(StringField(\CmdLastAnswer, 2, " "))
                MainOut                 = #True
              EndIf
            EndIf
          EndIf
          FreeMemory(*Buffer)
        Until MainOut = #True
        ProcedureReturn ReturnValue
      EndWith
    Else
      ProcedureReturn #False
    EndIf
  EndProcedure
  ProcedureDLL.s RNet_NNTP_GetAttribute(ID.l, Attribute.l)
    Protected *RObject.S_RNet = RNET_ID(ID)
    If *RObject <>  #Null
      ProcedureReturn RNet_Mail_GetAttribute(*RObject\NNTP\Mail, Attribute)
    Else
      ProcedureReturn ""
    EndIf
  EndProcedure
  ProcedureDLL.s RNet_NNTP_GetBody(ID.l)
    Protected *RObject.S_RNet = RNET_ID(ID)
    If *RObject <>  #Null
      With *RObject\NNTP
        ProcedureReturn RNet_Mail_GetBody(\Mail)
      EndWith
    Else
      ProcedureReturn ""
    EndIf
  EndProcedure

  ProcedureDLL RNet_NNTP_(ID.l)
    Protected *RObject.S_RNet = RNET_ID(ID)
    If *RObject <>  #Null
      With *RObject\NNTP
  
      EndWith
      ProcedureReturn #True
    Else
      ProcedureReturn -1
    EndIf
  EndProcedure
  
; IDE Options = PureBasic 4.10 (Windows - x86)
; CursorPosition = 290
; Folding = AAAAAAEAg
; UseMainFile = RNet_Ex_NNTP_00.pb