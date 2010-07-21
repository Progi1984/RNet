  ; Doc
  ;   http://fr.wikipedia.org/wiki/Simple_Mail_Transfer_Protocol
  ;   http://www.commentcamarche.net/internet/smtp.php3
  ;   http://christian.caleca.free.fr/smtp/
  ;   http://bobpeers.com/technical/telnet_smtp
  
  ProcedureDLL RNet_SMTP_Connect(ID.l, Server.s, Port.l = 25, Login.s = "", Password.s = "")
    Protected *RObject.S_RNet = RNET_ID(ID)
    If *RObject <>  #Null
      Protected StepAuth = 0, Inc.l
      Protected Content.s
      With *RObject\SMTP
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
                Case "220"
                  If StepAuth = 0
                    StepAuth = 1
                    SendNetworkString(\Connexion, "EHLO localhost"+#RNet_Const_CRLF)
                  EndIf
                Case "250"
                  ;Code pour différencier les différentes authentifications
                  ;For Inc = 0 To CountString(\CmdLastAnswer, #RNet_Const_CRLF)
                  ;  Content = StringField(\CmdLastAnswer, Inc+1,#RNet_Const_CRLF)
                  ;  Content = RemoveString(Content, Chr(13))
                  ;  Content = RemoveString(Content, Chr(10))
                  ;Next
                  If StepAuth = 1
                     StepAuth = 2
                    SendNetworkString(\Connexion, "AUTH PLAIN"+#RNet_Const_CRLF)
                  EndIf
                Case "334"
                  If StepAuth = 2
                    StepAuth = 3
                    MemLen    = Len(Login) + Len(Password)+ 2
                    MemLogin  = AllocateMemory(MemLen)
                    PokeB(MemLogin              , 0)
                    PokeS(MemLogin+1            , Login)
                    PokeB(MemLogin+1+Len(Login) , 0)
                    PokeS(MemLogin+2+Len(Login) , Password)
                    Mem64Login = AllocateMemory(Int(MemLen*1.5)+2)
                    Base64Encoder(MemLogin, MemLen, Mem64Login, MemorySize(Mem64Login))
                    PokeS(Mem64Login + MemorySize(Mem64Login) - 2, #RNet_Const_CRLF)
                    SendNetworkData(\Connexion, Mem64Login, MemorySize(Mem64Login))
                  EndIf
                Case "235"
                  If StepAuth = 3
                    MainOut = #True
                    RNet_SetLastError(#RNet_Error_OK)
                  EndIf
                Default: Debug "StepAuth="+Str(StepAuth)+">"+\CmdLastAnswer
              EndSelect
            EndIf
          EndIf
          FreeMemory(*Buffer)
        Until MainOut = #True
      EndWith
      ProcedureReturn #True
    Else
      ProcedureReturn #False
    EndIf
  EndProcedure
  ProcedureDLL RNet_SMTP_Disconnect(ID.l)
    Protected *RObject.S_RNet = RNET_ID(ID)
    If *RObject <>  #Null
      Protected StepAuth = 0, Inc.l
      Protected Content.s
      With *RObject\SMTP
        SendNetworkString(\Connexion, "QUIT"+#RNet_Const_CRLF)
        Repeat
          *Buffer   = AllocateMemory(1024)
          If NetworkClientEvent(\Connexion) = #PB_NetworkEvent_Data
            ReturnData      = ReceiveNetworkData(\Connexion, *Buffer, 1024)
            If Trim(PeekS(*Buffer)) <> ""
              \CmdLastAnswer  = PeekS(*Buffer)
              Select Left(\CmdLastAnswer, 3)
                Case "221"
                  MainOut = #True
                Default: Debug "RNet_SMTP_Disconnect>"+\CmdLastAnswer
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
  ProcedureDLL RNet_SMTP_SetAttribute(ID.l, Attribute.l, Content.s)
    Protected *RObject.S_RNet = RNET_ID(ID)
    If *RObject <>  #Null
      RNet_Mail_SetAttribute(*RObject\SMTP\Mail, Attribute, Content)
      ProcedureReturn #True
    Else
      ProcedureReturn #False
    EndIf
  EndProcedure
  ProcedureDLL.s RNet_SMTP_GetAttribute(ID.l, Attribute.l)
    Protected *RObject.S_RNet = RNET_ID(ID)
    If *RObject <>  #Null
      With *RObject\SMTP
        ProcedureReturn RNet_Mail_GetAttribute(*RObject\SMTP\Mail, Attribute)
      EndWith
    Else
      ProcedureReturn ""
    EndIf
  EndProcedure
  ProcedureDLL RNet_SMTP_ResetAttribute(ID.l)
    Protected *RObject.S_RNet = RNET_ID(ID)
    If *RObject <>  #Null
      With *RObject\SMTP
        RNet_Mail_ResetAttribute(\Mail)
      EndWith
      ProcedureReturn #True
    Else
      ProcedureReturn -1
    EndIf
  EndProcedure
  ProcedureDLL RNet_SMTP_SendMail(ID.l)
    Protected *RObject.S_RNet = RNET_ID(ID)
    If *RObject <>  #Null
      Protected StepSend.l = 0, MailMsg.s
      With *RObject\SMTP
        If \Mail\Infos_From = ""
          RNet_SetLastError(#RNet_Error_NoSender)
          ProcedureReturn #False
        ElseIf \Mail\Infos_To = ""
          RNet_SetLastError(#RNet_Error_NoRecipient)
          ProcedureReturn #False
        ElseIf \Mail\Infos_Body = ""
          RNet_SetLastError(#RNet_Error_NoContent)
          ProcedureReturn #False
        Else
          SendNetworkString(\Connexion, "MAIL FROM: <"+\Mail\Infos_From+">"+#RNet_Const_CRLF)
          Repeat
            *Buffer   = AllocateMemory(1024)
            If NetworkClientEvent(\Connexion) = #PB_NetworkEvent_Data
              ReturnData      = ReceiveNetworkData(\Connexion, *Buffer, 1024)
              If Trim(PeekS(*Buffer)) <> ""
                \CmdLastAnswer  = PeekS(*Buffer)
                Select Left(\CmdLastAnswer, 3)
                  Case "250"
                    ;{
                      Select StepSend 
                        Case 0 ; From OK
                          StepSend = 1
                          SendNetworkString(\Connexion, "RCPT TO: <"+\Mail\Infos_To+">"+#RNet_Const_CRLF)
                        Case 1 ; To OK 
                          StepSend = 2
                          SendNetworkString(\Connexion, "DATA"+#RNet_Const_CRLF)
                        Case 3
                          MainOut = #True
                        Default : Debug "RNet_SMTP_SendMail="+Str(StepSend)+">"+\CmdLastAnswer
                      EndSelect
                    ;}
                  Case "354"
                    If StepSend = 2
                      StepSend = 3
                      MailMsg = "From: "+\Mail\Infos_From+#RNet_Const_CRLF
                      MailMsg + "To:"   +\Mail\Infos_To  +#RNet_Const_CRLF
                      If \Mail\Infos_Cc <> ""          : MailMsg + "Bcc: "         + \Mail\Infos_Cc          + #RNet_Const_CRLF : EndIf
                      If \Mail\Infos_Bcc <> ""         : MailMsg + "Cc: "          + \Mail\Infos_Bcc         + #RNet_Const_CRLF : EndIf
                      If \Mail\Infos_Reply_To <> ""    : MailMsg + "Reply-To: "    + \Mail\Infos_Reply_To    + #RNet_Const_CRLF : EndIf
                      If \Mail\Infos_Content_Type <> "": MailMsg + "Content-Type: "+ \Mail\Infos_Content_Type+ #RNet_Const_CRLF : EndIf
                      If \Mail\Infos_Mime_Version <> "": MailMsg + "MIME-Version: "+ \Mail\Infos_Mime_Version+ #RNet_Const_CRLF : EndIf
                      If \Mail\Infos_Subject <> ""     : MailMsg + "Subject: "     + \Mail\Infos_Subject     + #RNet_Const_CRLF : EndIf
                      If \Mail\Infos_X_Mailer <> ""    : MailMsg + "X-Mailer: "    + \Mail\Infos_X_Mailer    + #RNet_Const_CRLF : EndIf
                      If \Mail\Infos_Date <> ""        : MailMsg + "Date: "        + \Mail\Infos_Date        + #RNet_Const_CRLF : EndIf
                      MailMsg +#RNet_Const_CRLF+\Mail\Infos_Body                                                         
                      SendNetworkString(\Connexion, MailMsg + #RNet_Const_CRLF+"."+#RNet_Const_CRLF)
                    EndIf
                  Default: Debug "RNet_SMTP_SendMail="+Str(StepSend)+">"+\CmdLastAnswer
                EndSelect
              EndIf
            EndIf
            FreeMemory(*Buffer)
          Until MainOut = #True
        EndIf
      EndWith
      ProcedureReturn #True
    Else
      ProcedureReturn #False
    EndIf
  EndProcedure

  ProcedureDLL RNet_SMTP_(ID.l)
    Protected *RObject.S_RNet = RNET_ID(ID)
    If *RObject <>  #Null
      With *RObject\SMTP
  
      EndWith
      ProcedureReturn #True
    Else
      ProcedureReturn #False
    EndIf
  EndProcedure

; IDE Options = PureBasic 4.20 (Windows - x86)
; CursorPosition = 179
; FirstLine = 58
; Folding = CAo5--6--
; UseMainFile = RNet_Ex_SMTP_00.pb