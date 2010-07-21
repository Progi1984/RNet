  ; http://www.purebasic.fr/english/viewtopic.php?t=6668&highlight=pop3+checker
  ; http://www.iprelax.fr/pop/pop_descr1.php
  ; http://www.iprelax.fr/pop/pop_session.php
  ; http://freenet-homepage.de/gnozal/PurePOP3_.htm
  ; http://www.purebasic.fr/english/viewtopic.php?t=17032
  ; http://bobpeers.com/technical/telnet_pop.php
  ;-Private
  Procedure RNet_POP_RefreshList(ID.l)
    Protected *RObject.S_RNet = RNET_ID(ID)
    If *RObject <>  #Null
      With *RObject\POP
        SendNetworkString(\Connexion, "LIST"+ #RNet_Const_CRLF)
        \CmdList = ""
        Repeat
          If NetworkClientEvent(\Connexion) = #PB_NetworkEvent_Data
            *Buffer     = AllocateMemory(1024)
            ReturnData  = ReceiveNetworkData(\Connexion, *Buffer, 1024)
            If Trim(PeekS(*Buffer)) > ""
              \CmdLastAnswer  = PeekS(*Buffer)
              If Left(Trim(PeekS(*Buffer)), 3) = "+OK" Or Left(Trim(PeekS(*Buffer)), 4) = "-ERR" Or \CmdList <> ""
                \CmdList + Trim(PeekS(*Buffer))
                If Right(Trim(PeekS(*Buffer)), 3) = "."+#RNet_Const_CRLF
                  MainOut = #True
                EndIf
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

  ;-Public
  ProcedureDLL RNet_POP_Connect(ID.l, Server.s, Port.l = 110, Login.s = "", Password.s = "")
    Protected *RObject.S_RNet = RNET_ID(ID)
    If *RObject <>  #Null
      Protected ValidCommand = -1, StepAuth = 0
      With *RObject\POP
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
              If Left(PeekS(*Buffer), 3) = "+OK"
                ValidCommand = #True
              ElseIf Left(PeekS(*Buffer), 4) = "-ERR"
                ValidCommand = #False
              EndIf
            EndIf
            If ValidCommand = #True
              Select StepAuth
                Case 0 : SendNetworkString(\Connexion, "USER "+ \Login    + #RNet_Const_CRLF) : StepAuth + 1 : ValidCommand = -1
                Case 1 : SendNetworkString(\Connexion, "PASS "+ \Password + #RNet_Const_CRLF) : StepAuth + 1 : ValidCommand = -1
                Case 2 : MainOut = #True
              EndSelect
            ElseIf ValidCommand = #False
              Debug StepAuth
              Select StepAuth
                Case 1 : 
                Case 2 : MainOut = #True : RNet_SetLastError(#RNet_Error_BadLogin)
                Case 3 : MainOut = #True : RNet_SetLastError(#RNet_Error_BadPassword)
              EndSelect
              MainOut = #True
            EndIf
            FreeMemory(*Buffer)
          EndIf
        Until MainOut = #True
      EndWith
      ProcedureReturn ValidCommand
    Else
      ProcedureReturn -1
    EndIf
  EndProcedure
  ProcedureDLL RNet_POP_Disconnect(ID.l)
    Protected *RObject.S_RNet = RNET_ID(ID)
    If *RObject <>  #Null
      With *RObject\POP
        SendNetworkString(\Connexion, "QUIT"+#RNet_Const_CRLF)
        Repeat
          *Buffer   = AllocateMemory(1024)
          If NetworkClientEvent(\Connexion) = #PB_NetworkEvent_Data
            ReturnData      = ReceiveNetworkData(\Connexion, *Buffer, 1024)
            If Trim(PeekS(*Buffer)) <> ""
              \CmdLastAnswer  = PeekS(*Buffer)
              If Left(Trim(PeekS(*Buffer)), 3) = "+OK" 
                MainOut = #True
              EndIf
            EndIf
          EndIf
          FreeMemory(*Buffer)
        Until MainOut = #True
        CloseNetworkConnection(\Connexion)
        \Connexion = 0
      EndWith
      ProcedureReturn #True
    Else
      ProcedureReturn #False
    EndIf
  EndProcedure
  ProcedureDLL RNet_POP_CountMessages(ID.l)
    Protected *RObject.S_RNet = RNET_ID(ID)
    If *RObject <>  #Null
      With *RObject\POP
        RNet_POP_RefreshList(ID)
        ProcedureReturn CountString(\CmdList, #RNet_Const_CRLF)-2
      EndWith
    Else
      ProcedureReturn #False
    EndIf
  EndProcedure
  ProcedureDLL RNet_POP_GetMessageSize(ID.l, Item.l)
    Protected *RObject.S_RNet = RNET_ID(ID)
    If *RObject <>  #Null
      With *RObject\POP
        ProcedureReturn Val(StringField(StringField(\CmdList, Item+2, #RNet_Const_CRLF), 2, " "))
      EndWith
    Else
      ProcedureReturn #False
    EndIf
  EndProcedure
  ProcedureDLL RNet_POP_RetrieveMessage(ID.l, Item.l)
    Protected *RObject.S_RNet = RNET_ID(ID)
    If *RObject <>  #Null
      Protected MsgID.l 
      With *RObject\POP
        \Msg      = ""
        MsgID     = Val(StringField(RemoveString(StringField(\CmdList, Item+2, #RNet_Const_CRLF), Chr(10)), 1, " "))
        SendNetworkString(\Connexion, "RETR "+Str(MsgID)+ #RNet_Const_CRLF)
        Repeat
          *Buffer   = AllocateMemory(1024)
          If NetworkClientEvent(\Connexion) = #PB_NetworkEvent_Data
            ReturnData      = ReceiveNetworkData(\Connexion, *Buffer, 1024)
            If Trim(PeekS(*Buffer)) <> ""
              \CmdLastAnswer  = PeekS(*Buffer)
              If Left(Trim(PeekS(*Buffer)), 3) <> "+OK"
                \Msg + Trim(PeekS(*Buffer))
                If ReturnData <1024
                  MainOut = #True
                EndIf
              EndIf
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
  ProcedureDLL RNet_POP_ExamineMessage(ID.l)
    Protected *RObject.S_RNet = RNET_ID(ID)
    If *RObject <>  #Null
      With *RObject\POP
        RNet_Mail_ExamineMessage(*RObject\POP\Mail, #RNet_Type_Pop, \Msg)
      EndWith
      ProcedureReturn #True
    Else
      ProcedureReturn #False
    EndIf
  EndProcedure
  ProcedureDLL.s RNet_POP_GetAttribute(ID.l, Attribute.l)
    Protected *RObject.S_RNet = RNET_ID(ID)
    If *RObject <>  #Null
      ProcedureReturn RNet_Mail_GetAttribute(*RObject\POP\Mail, Attribute)
    Else
      ProcedureReturn ""
    EndIf
  EndProcedure
  ProcedureDLL.s RNet_POP_GetBody(ID.l)
    Protected *RObject.S_RNet = RNET_ID(ID)
    If *RObject <>  #Null
      With *RObject\POP\Mail
        ProcedureReturn RNet_Mail_GetBody(*RObject\POP\Mail)
      EndWith
    Else
      ProcedureReturn ""
    EndIf
  EndProcedure
  ProcedureDLL.s RNet_POP_GetLastServerMessage(ID.l)
    Protected *RObject.S_RNet = RNET_ID(ID)
    If *RObject <>  #Null
      With *RObject\POP
        ProcedureReturn \CmdLastAnswer
      EndWith
    Else
      ProcedureReturn ""
    EndIf
  EndProcedure
  ProcedureDLL RNet_POP_GetMessagesTotalSize(ID.l)
    Protected *RObject.S_RNet = RNET_ID(ID)
    If *RObject <>  #Null
      Protected Number
      With *RObject\POP
        SendNetworkString(\Connexion, "STAT"+#RNet_Const_CRLF)
        Repeat
          *Buffer   = AllocateMemory(1024)
          If NetworkClientEvent(\Connexion) = #PB_NetworkEvent_Data
            ReturnData      = ReceiveNetworkData(\Connexion, *Buffer, 1024)
            If Trim(PeekS(*Buffer)) <> ""
              \CmdLastAnswer  = PeekS(*Buffer)
              If Left(Trim(PeekS(*Buffer)), 3) = "+OK"
                MainOut = #True
                Number = Val(StringField(PeekS(*Buffer), 3, " "))
              EndIf
            EndIf
          EndIf
          FreeMemory(*Buffer)
        Until MainOut = #True
      EndWith
      ProcedureReturn Number
    Else
      ProcedureReturn #False
    EndIf
  EndProcedure
  ProcedureDLL RNet_POP_DeleteMessage(ID.l, Item.l)
    Protected *RObject.S_RNet = RNET_ID(ID)
    If *RObject <>  #Null
      Protected MsgID.l 
      With *RObject\POP
        MsgID     = Val(StringField(RemoveString(StringField(\CmdList, Item+2, #RNet_Const_CRLF), Chr(10)), 1, " "))
        SendNetworkString(\Connexion, "DELE "+Str(MsgID)+ #RNet_Const_CRLF)
        Repeat
          *Buffer   = AllocateMemory(1024)
          If NetworkClientEvent(\Connexion) = #PB_NetworkEvent_Data
            ReturnData      = ReceiveNetworkData(\Connexion, *Buffer, 1024)
            If Trim(PeekS(*Buffer)) <> ""
              \CmdLastAnswer  = PeekS(*Buffer)
              If Left(Trim(PeekS(*Buffer)), 3) = "+OK"
                MainOut = 1
              EndIf
              If Left(Trim(PeekS(*Buffer)), 4) = "-ERR"
                MainOut = 2
              EndIf
            EndIf
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
  ProcedureDLL RNet_POP_NoOperation(ID.l)
    Protected *RObject.S_RNet = RNET_ID(ID)
    If *RObject <>  #Null
      Protected MsgID.l 
      With *RObject\POP
        SendNetworkString(\Connexion, "NOOP "+ #RNet_Const_CRLF)
        Repeat
          *Buffer   = AllocateMemory(1024)
          If NetworkClientEvent(\Connexion) = #PB_NetworkEvent_Data
            ReturnData      = ReceiveNetworkData(\Connexion, *Buffer, 1024)
            If Trim(PeekS(*Buffer)) <> ""
              \CmdLastAnswer  = PeekS(*Buffer)
              If Left(Trim(PeekS(*Buffer)), 3) = "+OK"
                MainOut = 1
              EndIf
              If Left(Trim(PeekS(*Buffer)), 4) = "-ERR"
                MainOut = 2
              EndIf
            EndIf
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
  ProcedureDLL RNet_POP_Reset(ID.l)
    Protected *RObject.S_RNet = RNET_ID(ID)
    If *RObject <>  #Null
      Protected MsgID.l 
      With *RObject\POP
        SendNetworkString(\Connexion, "RSET "+ #RNet_Const_CRLF)
        Repeat
          *Buffer   = AllocateMemory(1024)
          If NetworkClientEvent(\Connexion) = #PB_NetworkEvent_Data
            ReturnData      = ReceiveNetworkData(\Connexion, *Buffer, 1024)
            If Trim(PeekS(*Buffer)) <> ""
              \CmdLastAnswer  = PeekS(*Buffer)
              If Left(Trim(PeekS(*Buffer)), 3) = "+OK"
                MainOut = 1
              EndIf
              If Left(Trim(PeekS(*Buffer)), 4) = "-ERR"
                MainOut = 2
              EndIf
            EndIf
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

  ProcedureDLL RNet_POP_SaveToFile(ID.l, Filename.s)
    Protected *RObject.S_RNet = RNET_ID(ID)
    If *RObject <>  #Null
      Protected FileID.l
      With *RObject\POP
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
  ProcedureDLL RNet_POP_SaveToMemory(ID.l, Buffer.l)
    Protected *RObject.S_RNet = RNET_ID(ID)
    If *RObject <>  #Null
      With *RObject\POP
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
  
  ProcedureDLL RNet_POP_(ID.l)
    Protected *RObject.S_RNet = RNET_ID(ID)
    If *RObject <>  #Null
      With *RObject\POP
  
      EndWith
      ProcedureReturn #True
    Else
      ProcedureReturn #False
    EndIf
  EndProcedure

; IDE Options = PureBasic 4.10 (Windows - x86)
; CursorPosition = 370
; Folding = ++8VfVd+0843
; UseMainFile = RNet_Ex_POP_00.pb