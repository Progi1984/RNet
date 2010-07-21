  ;- Public
  ProcedureDLL RNet_FTP_(ID.l)
    Protected *RObject.S_RNet = RNET_ID(ID)
    If *RObject <>  #Null
      With *RObject\FTP
  
      EndWith
      ProcedureReturn #True
    Else
      ProcedureReturn -1
    EndIf
  EndProcedure

  ProcedureDLL RNet_FTP_Connect(ID.l, Server.s, Port.l = 21, Login.s = "", Password.s = "")
    Protected *RObject.S_RNet = RNET_ID(ID)
    If *RObject <>  #Null
      Protected Rep.s, Buf.l
      With *RObject\FTP
        \Server     = Server
        \Port       = Port
        \Login      = Login
        \Password   = Password
        \Connexion  = OpenNetworkConnection(Server, Port)
        If \Connexion
          Repeat
            If NetworkClientEvent(\Connexion) = #PB_NetworkEvent_Data
              Buf   = AllocateMemory(1024)
              Res   = ReceiveNetworkData(\Connexion, Buf,1024)
              Rep   = Trim(PeekS(Buf))
              Select Left(Rep, 3)
                Case "220"
                  SendNetworkString(\Connexion, "USER " + \Login    +#RNet_Const_CRLF)
                Case "230"
                  RNet_SetLastError(#RNet_Error_OK)
                  Main  = #True  
                Case "331"
                  SendNetworkString(\Connexion, "PASS " + \Password +#RNet_Const_CRLF)
                Case "530"
                  RNet_SetLastError(#RNet_Error_BadPassword)
                  Main  = #True
                Default
                  Debug "RNet_FTP_Connect >"+Rep
              EndSelect
              FreeMemory(Buf)
            EndIf
          Until Main = #True
        Else
          RNet_SetLastError(#RNet_Error_NoConnection)
          ProcedureReturn -1
        EndIf
      EndWith
      ProcedureReturn #True
    Else
      ProcedureReturn -1
    EndIf
  EndProcedure
  ProcedureDLL RNet_FTP_Disconnect(ID.l)
    Protected *RObject.S_RNet = RNET_ID(ID)
    If *RObject <>  #Null
      Protected Rep.s, Buf.l
      With *RObject\FTP
        If \Connexion
          SendNetworkString(\Connexion, "QUIT"+#RNet_Const_CRLF)
          Repeat
            If NetworkClientEvent(\Connexion) = #PB_NetworkEvent_Data
              Buf   = AllocateMemory(1024)
              Res   = ReceiveNetworkData(\Connexion, Buf,1024)
              Rep   = Trim(PeekS(Buf))
              Select Left(Rep, 3)
                Case "221"
                  *RObject\LastError  = #RNet_Error_OK
                  Main                = #True  
                Case "500"
                  *RObject\LastError  = #RNet_Error_SyntaxError
                  Main                = #True  
                Default
                  Debug "RNet_FTP_Disconnect >"+Rep
              EndSelect
              FreeMemory(Buf)
            EndIf
          Until Main = #True
          CloseNetworkConnection(\Connexion)
          \Connexion  = 0
        Else
          ProcedureReturn -1
        EndIf
      EndWith
      ProcedureReturn #True
    Else
      ProcedureReturn -1
    EndIf
  EndProcedure
  ProcedureDLL RNet_FTP_CreateDirectory(ID.l, DirectoryName.s)
    Protected *RObject.S_RNet = RNET_ID(ID)
    If *RObject <>  #Null
      Protected Rep.s, Buf.l
      With *RObject\FTP
        If \Connexion
          SendNetworkString(\Connexion, "MKD " + DirectoryName    +#RNet_Const_CRLF)
          Repeat
            If NetworkClientEvent(\Connexion) = #PB_NetworkEvent_Data
              Buf   = AllocateMemory(1024)
              Res   = ReceiveNetworkData(\Connexion, Buf,1024)
              Rep   = Trim(PeekS(Buf))
              Select Left(Rep, 3)
                Case "257"
                  *RObject\LastError  = #RNet_Error_OK
                  Main                = #True  
                Case "550"
                  *RObject\LastError  = #RNet_Error_EverExisting
                  Main                = #True  
                Default
                  Debug "RNet_FTP_CreateDirectory >"+Rep
              EndSelect
              FreeMemory(Buf)
            EndIf
          Until Main = #True
        Else
          ProcedureReturn -1
        EndIf
      EndWith
      ProcedureReturn #True
    Else
      ProcedureReturn -1
    EndIf
  EndProcedure
  ProcedureDLL RNet_FTP_DeleteDirectory(ID.l, Path.s)
    Protected *RObject.S_RNet = RNET_ID(ID)
    If *RObject <>  #Null
      Protected Rep.s, Buf.l
      With *RObject\FTP
        If \Connexion
          SendNetworkString(\Connexion, "RMD " + Path    +#RNet_Const_CRLF)
          Repeat
            If NetworkClientEvent(\Connexion) = #PB_NetworkEvent_Data
              Buf   = AllocateMemory(1024)
              Res   = ReceiveNetworkData(\Connexion, Buf,1024)
              Rep   = Trim(PeekS(Buf))
              Select Left(Rep, 3)
                Case "250"
                  *RObject\LastError  = #RNet_Error_OK
                  Main                = #True  
                Case "550"
                  *RObject\LastError  = #RNet_Error_EverExisting
                  Main                = #True  
                Default
                  Debug "RNet_FTP_DeleteDirectory >"+Rep
              EndSelect
              FreeMemory(Buf)
            EndIf
          Until Main = #True
        Else
          ProcedureReturn -1
        EndIf
      EndWith
      ProcedureReturn #True
    Else
      ProcedureReturn -1
    EndIf
  EndProcedure
  ProcedureDLL RNet_FTP_DeleteFile(ID.l, Filename.s)
    Protected *RObject.S_RNet = RNET_ID(ID)
    If *RObject <>  #Null
      Protected Rep.s, Buf.l
      With *RObject\FTP
        If \Connexion
          SendNetworkString(\Connexion, "DELE " + Filename    +#RNet_Const_CRLF)
          Repeat
            If NetworkClientEvent(\Connexion) = #PB_NetworkEvent_Data
              Buf   = AllocateMemory(1024)
              Res   = ReceiveNetworkData(\Connexion, Buf,1024)
              Rep   = Trim(PeekS(Buf))
              Select Left(Rep, 3)
                Case "250"
                  *RObject\LastError  = #RNet_Error_OK
                  Main                = #True  
                Case "550"
                  *RObject\LastError  = #RNet_Error_EverExisting
                  Main                = #True  
                Default
                  Debug "RNet_FTP_DeleteDirectory >"+Rep
              EndSelect
              FreeMemory(Buf)
            EndIf
          Until Main = #True
        Else
          ProcedureReturn -1
        EndIf
      EndWith
      ProcedureReturn #True
    Else
      ProcedureReturn -1
    EndIf
  EndProcedure
  ProcedureDLL.s RNet_FTP_GetCurrentDirectory(ID.l)
    Protected *RObject.S_RNet = RNET_ID(ID)
    If *RObject <>  #Null
      Protected Rep.s, Buf.l, Path.s
      With *RObject\FTP
        If \Connexion
          SendNetworkString(\Connexion, "PWD"+#RNet_Const_CRLF)
          Repeat
            If NetworkClientEvent(\Connexion) = #PB_NetworkEvent_Data
              Buf   = AllocateMemory(1024)
              Res   = ReceiveNetworkData(\Connexion, Buf,1024)
              Rep   = Trim(PeekS(Buf))
              Select Left(Rep, 3)
                Case "257"
                  *RObject\LastError  = #RNet_Error_OK
                  Main                = #True  
                  Path                = StringField(Rep, 2, Chr(34))
                Case "550"
                  *RObject\LastError  = #RNet_Error_EverExisting
                  Main                = #True  
                Default
                  Debug "RNet_FTP_GetCurrentDirectory >"+Rep
              EndSelect
              FreeMemory(Buf)
            EndIf
          Until Main = #True
          ProcedureReturn Path
        Else
          ProcedureReturn ""
        EndIf
      EndWith
    Else
      ProcedureReturn ""
    EndIf
  EndProcedure
  ProcedureDLL RNet_FTP_SetCurrentDirectory(ID.l, Path.s)
    Protected *RObject.S_RNet = RNET_ID(ID)
    If *RObject <>  #Null
      Protected Rep.s, Buf.l
      With *RObject\FTP
        If \Connexion
          SendNetworkString(\Connexion, "CWD " + Path    +#RNet_Const_CRLF)
          Repeat
            If NetworkClientEvent(\Connexion) = #PB_NetworkEvent_Data
              Buf   = AllocateMemory(1024)
              Res   = ReceiveNetworkData(\Connexion, Buf,1024)
              Rep   = Trim(PeekS(Buf))
              Select Left(Rep, 3)
                Case "250"
                  *RObject\LastError  = #RNet_Error_OK
                  Main                = #True  
                Case "550"
                  *RObject\LastError  = #RNet_Error_EverExisting
                  Main                = #True  
                Default
                  Debug "RNet_FTP_SetCurrentDirectory >"+Rep
              EndSelect
              FreeMemory(Buf)
            EndIf
          Until Main = #True
        Else
          ProcedureReturn -1
        EndIf
      EndWith
      ProcedureReturn #True
    Else
      ProcedureReturn -1
    EndIf
  EndProcedure
  ProcedureDLL RNet_FTP_RenameFile(ID.l, OldFilename.s, NewFilename.s)
    Protected *RObject.S_RNet = RNET_ID(ID)
    If *RObject <>  #Null
      Protected Rep.s, Buf.l
      With *RObject\FTP
        If \Connexion
          SendNetworkString(\Connexion, "RNFR " + OldFilename    +#RNet_Const_CRLF)
          SendNetworkString(\Connexion, "RNTO " + NewFilename    +#RNet_Const_CRLF)
          Repeat
            If NetworkClientEvent(\Connexion) = #PB_NetworkEvent_Data
              Buf   = AllocateMemory(1024)
              Res   = ReceiveNetworkData(\Connexion, Buf,1024)
              Rep   = Trim(PeekS(Buf))
              Select Left(Rep, 3)
                Case "350"; Service fichier en attente d'information.
                Case "250"; Service fichier terminé
                  *RObject\LastError  = #RNet_Error_OK
                  Main                = #True  
                Case "550"
                  *RObject\LastError  = #RNet_Error_EverExisting
                  Main                = #True
                Default
                  Debug "RNet_FTP_RenameFile >"+Rep
              EndSelect
              FreeMemory(Buf)
            EndIf
          Until Main = #True
          If *RObject\LastError > #RNet_Error_OK
            ProcedureReturn #False
          Else
            ProcedureReturn #True
          EndIf
        Else
          ProcedureReturn #False
        EndIf
      EndWith
      ProcedureReturn #True
    Else
      ProcedureReturn #False
    EndIf
  EndProcedure
  
  ProcedureDLL RNet_FTP_ExamineDirectory(ID.l)
    Protected *RObject.S_RNet = RNET_ID(ID)
    If *RObject <>  #Null
      Protected Rep.s, Buf.l
      Protected IPStart.l, IPEnd.l, IPPort.l
      Protected IPContent.s, IPAdress.s
      With *RObject\FTP
        If \Connexion
          SendNetworkString(\Connexion, "TYPE I"+#RNet_Const_CRLF)
          Repeat
            If NetworkClientEvent(\Connexion) = #PB_NetworkEvent_Data 
              Buf   = AllocateMemory(1024)
              Res   = ReceiveNetworkData(\Connexion, Buf,1024)
              Rep   = Trim(PeekS(Buf))
              Select Left(Rep, 3)
                Case "200"
                  Main = #True
                Default
                  Debug "RNet_FTP_ExamineDirectory >1>"+Rep
              EndSelect
            EndIf
          Until Main = #True
          If Main = #True
            Main = #False
            SendNetworkString(\Connexion, "PASV"  +#RNet_Const_CRLF)
            Repeat
              If NetworkClientEvent(\Connexion) = #PB_NetworkEvent_Data 
                Buf   = AllocateMemory(1024)
                Res   = ReceiveNetworkData(\Connexion, Buf,1024)
                Rep   = Trim(PeekS(Buf))
                Select Left(Rep, 3)
                  Case "227"
                    Main            = #True
                    IPStart         = FindString(Rep, "(", 1)+1
                    IPEnd           = FindString(Rep, ")", 1)
                    IPContent       = Mid(Rep, IPStart, IPEnd-IPStart)
                    IPAdress        = StringField(IPContent, 1, ",")+"."+StringField(IPContent, 2, ",")+"."+StringField(IPContent, 3, ",")+"."+StringField(IPContent, 4, ",")
                    IPPort          = Val(StringField(IPContent, 5, ","))*256+Val(StringField(IPContent, 6, ","))
                    \Connexion_PASV = OpenNetworkConnection(IPAdress, IPPort)
                  Default
                    Debug "RNet_FTP_ExamineDirectory >2>"+Rep
                EndSelect
              EndIf
            Until Main = #True
            If Main = #True
              Main = #False
              SendNetworkString(\Connexion, "LIST"  +#RNet_Const_CRLF)
              Repeat
                If NetworkClientEvent(\Connexion_PASV) = #PB_NetworkEvent_Data 
                  Buf   = AllocateMemory(1024)
                  Res   = ReceiveNetworkData(\Connexion_PASV, Buf,1024)
                  Rep   = Trim(PeekS(Buf))
                  \ListingDir + Rep
                EndIf
                If NetworkClientEvent(\Connexion) = #PB_NetworkEvent_Data 
                  Buf   = AllocateMemory(1024)
                  Res   = ReceiveNetworkData(\Connexion, Buf,1024)
                  Rep   = Trim(PeekS(Buf))
                  Select Left(Rep, 3)
                    Case "150" ; Statut de fichier vérifié; ouverture de canal de données en cours
                    Case "226"  ; Fermeture du canal de données. Service terminé
                      CloseNetworkConnection(\Connexion_PASV)
                      \Connexion_PASV     = 0
                      *RObject\LastError  = #RNet_Error_OK
                      Main                = #True  
                    Default
                      Debug "RNet_FTP_ExamineDirectory >3>"+Rep
                  EndSelect
                EndIf
              Until Main = #True
              Debug \ListingDir
              ProcedureReturn #True
            Else
              ProcedureReturn #False
            EndIf
          Else
            ProcedureReturn #False
          EndIf
          CloseNetworkConnection(\Connexion)
          \Connexion  = 0
        Else
          ProcedureReturn #False
        EndIf
      EndWith
      ProcedureReturn #True
    Else
      ProcedureReturn #False
    EndIf
  EndProcedure
  ProcedureDLL RNet_FTP_NextDirectoryEntry(ID.l)
    Protected *RObject.S_RNet = RNET_ID(ID)
    If *RObject <>  #Null
      With *RObject\FTP
        If CountString(\ListingDir, #RNet_Const_CRLF) > \ListingEntry + 1
          \ListingEntry + 1
          ProcedureReturn #True
        Else
          \ListingEntry
          ProcedureReturn #False
        EndIf
      EndWith
    Else
      ProcedureReturn #False
    EndIf
  EndProcedure
  ProcedureDLL.s RNet_FTP_DirectoryEntryName(ID.l)
    Protected *RObject.S_RNet = RNET_ID(ID)
    If *RObject <>  #Null
      Protected Content.s
      With *RObject\FTP
        Content = StringField(\ListingDir, \ListingEntry+1, #RNet_Const_CRLF)
        Content = RemoveString(Content, Chr(13))
        Content = RemoveString(Content, Chr(10))
        ProcedureReturn StringField(Content, CountString(Content, " ")+1, " ")
      EndWith
    Else
      ProcedureReturn ""
    EndIf
  EndProcedure
  ProcedureDLL RNet_FTP_DirectoryEntryType(ID.l)
    Protected *RObject.S_RNet = RNET_ID(ID)
    If *RObject <>  #Null
      Protected Content.s
      With *RObject\FTP
        Content = StringField(\ListingDir, \ListingEntry+1, #RNet_Const_CRLF)
        Content = RemoveString(Content, Chr(13))
        Content = RemoveString(Content, Chr(10))
        If LCase(Left(StringField(Content, 1, " "), 1)) = "d"
          ProcedureReturn #PB_DirectoryEntry_Directory
        Else
          ProcedureReturn #PB_DirectoryEntry_File
        EndIf
      EndWith
    Else
      ProcedureReturn #False
    EndIf
  EndProcedure
  ProcedureDLL RNet_FTP_DirectoryEntryDate(ID.l)
    Protected *RObject.S_RNet = RNET_ID(ID)
    If *RObject <>  #Null
      With *RObject\FTP
        If RNet_FTP_DirectoryEntryName(ID) = "." Or RNet_FTP_DirectoryEntryName(ID) = ".."
          ProcedureReturn #False
        Else
          Protected Content.s, Find.l, Date.s
          Content = StringField(\ListingDir, \ListingEntry+1, #RNet_Const_CRLF)
          Content = RemoveString(Content, Chr(13))
          Content = RemoveString(Content, Chr(10))
          Find = FindString(LCase(Content), "jan", 1)
          If Find = 0
            Find = FindString(LCase(Content), "feb", 1)
            If Find = 0
              Find = FindString(LCase(Content), "mar", 1)
              If Find = 0
                Find = FindString(LCase(Content), "apr", 1)
                If Find = 0
                  Find = FindString(LCase(Content), "may", 1)
                  If Find = 0
                    Find = FindString(LCase(Content), "jun", 1)
                    If Find = 0
                      Find = FindString(LCase(Content), "jul", 1)
                      If Find = 0
                        Find = FindString(LCase(Content), "sep", 1)
                        If Find = 0
                          Find = FindString(LCase(Content), "oct", 1)
                          If Find = 0
                            Find = FindString(LCase(Content), "nov", 1)
                            If Find = 0
                              Find = FindString(LCase(Content), "dec", 1)
                              If Find = 0
                                ProcedureReturn #False
                              EndIf
                            EndIf
                          EndIf
                        EndIf
                      EndIf
                    EndIf
                  EndIf
                EndIf
              EndIf
            EndIf
          EndIf
          Date = Trim(Mid(Content, Find, Len(Content) - Find+1 - Len(RNet_FTP_DirectoryEntryName(ID))))
          For Inc = 1 To CountString(Date, " ") +1
            Elem.s = Trim(StringField(Date, Inc, " "))
            If Elem <> ""
              Select LCase(Elem)
                Case "jan"  : Date_Month  = 1
                Case "feb"  : Date_Month  = 2
                Case "mar"  : Date_Month  = 3
                Case "apr"  : Date_Month  = 4
                Case "may"  : Date_Month  = 5
                Case "jun"  : Date_Month  = 6
                Case "jul"  : Date_Month  = 7
                Case "aug"  : Date_Month  = 8
                Case "sep"  : Date_Month  = 9
                Case "oct"  : Date_Month  = 10
                Case "nov"  : Date_Month  = 11
                Case "dec"  : Date_Month  = 12
                Default
                  If Date_Month > 0 And Date_Day = 0
                    Date_Day = Val(Elem)
                  Else
                    If FindString(Elem, ":", 1) > 0
                      Date_Hour   = Val(StringField(Elem, 1, ":"))
                      Date_Minute = Val(StringField(Elem, 2, ":"))
                    Else
                      Date_Year   = Val(Elem)
                    EndIf
                  EndIf
              EndSelect
            EndIf
          Next
          If Date_Year = 0 : Date_Year = Year(Date()) : EndIf
          ProcedureReturn Date(Date_Year, Date_Month, Date_Day, Date_Hour, Date_Minute,0)
        EndIf
      EndWith
    Else
      ProcedureReturn #False
    EndIf
  EndProcedure
  ProcedureDLL RNet_FTP_DirectoryEntrySize(ID.l)
    Protected *RObject.S_RNet = RNET_ID(ID)
    If *RObject <>  #Null
      Protected Content.s
      With *RObject\FTP
        Content = StringField(\ListingDir, \ListingEntry+1, #RNet_Const_CRLF)
        Content = RemoveString(Content, Chr(13))
        Content = RemoveString(Content, Chr(10))
        Find = FindString(LCase(Content), "jan", 1)
        If Find = 0
          Find = FindString(LCase(Content), "feb", 1)
          If Find = 0
            Find = FindString(LCase(Content), "mar", 1)
            If Find = 0
              Find = FindString(LCase(Content), "apr", 1)
              If Find = 0
                Find = FindString(LCase(Content), "may", 1)
                If Find = 0
                  Find = FindString(LCase(Content), "jun", 1)
                  If Find = 0
                    Find = FindString(LCase(Content), "jul", 1)
                    If Find = 0
                      Find = FindString(LCase(Content), "sep", 1)
                      If Find = 0
                        Find = FindString(LCase(Content), "oct", 1)
                        If Find = 0
                          Find = FindString(LCase(Content), "nov", 1)
                          If Find = 0
                            Find = FindString(LCase(Content), "dec", 1)
                            If Find = 0
                              ProcedureReturn #False
                            EndIf
                          EndIf
                        EndIf
                      EndIf
                    EndIf
                  EndIf
                EndIf
              EndIf
            EndIf
          EndIf
        EndIf
        Content = Trim(Left(Content, Find-1))
        If Left(Content, 1) = "d"
          ProcedureReturn #False
        Else
          ProcedureReturn Val(StringField(Content, CountString(Content, " ")+1, " "))
        EndIf
      EndWith
    Else
      ProcedureReturn #False
    EndIf
  EndProcedure
  ProcedureDLL RNet_FTP_FinishDirectory(ID.l)
    Protected *RObject.S_RNet = RNET_ID(ID)
    If *RObject <>  #Null
      With *RObject\FTP
        \ListingDir   = "" 
        \ListingEntry = 0
        ProcedureReturn #True
      EndWith
    Else
      ProcedureReturn #False
    EndIf
  EndProcedure

  ProcedureDLL RNet_FTP_Download(ID.l, FTPFile.s, LocalFile.s, Mode.l = #RNet_FTP_Mode_Binary)
    Protected *RObject.S_RNet = RNET_ID(ID)
    If *RObject <>  #Null
      Protected Rep.s, Buf.l
      Protected IPStart.l, IPEnd.l, IPPort.l
      Protected IPContent.s, IPAdress.s
      With *RObject\FTP
        If \Connexion
          If Mode = #RNet_FTP_Mode_Binary
            SendNetworkString(\Connexion, "TYPE I"+#RNet_Const_CRLF)
          ElseIf Mode = #RNet_FTP_Mode_Ascii
            SendNetworkString(\Connexion, "TYPE A"+#RNet_Const_CRLF)
          EndIf
          Repeat
            If NetworkClientEvent(\Connexion) = #PB_NetworkEvent_Data
              Buf   = AllocateMemory(1024)
              Res   = ReceiveNetworkData(\Connexion, Buf,1024)
              Rep   = Trim(PeekS(Buf))
              Select Left(Rep, 3)
                Case "200" ; OK
                  Main  = #True  
                Default
                  Debug "RNet_FTP_Download > 1 >"+Rep
              EndSelect
              FreeMemory(Buf)
            EndIf
          Until Main = #True
          If Main = #True
            Main = #False
            SendNetworkString(\Connexion, "PASV"+#RNet_Const_CRLF)
            Repeat
              If NetworkClientEvent(\Connexion) = #PB_NetworkEvent_Data 
                Buf   = AllocateMemory(1024)
                Res   = ReceiveNetworkData(\Connexion, Buf,1024)
                Rep   = Trim(PeekS(Buf))
                Select Left(Rep, 3)
                  Case "227"
                    Main            = #True
                    IPStart         = FindString(Rep, "(", 1)+1
                    IPEnd           = FindString(Rep, ")", 1)
                    IPContent       = Mid(Rep, IPStart, IPEnd-IPStart)
                    IPAdress        = StringField(IPContent, 1, ",")+"."+StringField(IPContent, 2, ",")+"."+StringField(IPContent, 3, ",")+"."+StringField(IPContent, 4, ",")
                    IPPort          = Val(StringField(IPContent, 5, ","))*256+Val(StringField(IPContent, 6, ","))
                    \Connexion_PASV = OpenNetworkConnection(IPAdress, IPPort)
                  Default
                    Debug "RNet_FTP_Download > 2 >"+Rep
                EndSelect
              EndIf
            Until Main = #True
            If Main = #True
              Main = #False
              SendNetworkString(\Connexion, "RETR "+FTPFile+#RNet_Const_CRLF)
              Repeat
                If NetworkClientEvent(\Connexion_PASV) = #PB_NetworkEvent_Data 
                  Buf = AllocateMemory(1024)
                  Res = ReceiveNetworkData(\Connexion_PASV, Buf, 1024)
                  If \DataLen > 0
                    TmpMem = AllocateMemory(\DataLen)
                    CopyMemory(\DataMem, TmpMem, \DataLen)
                    FreeMemory(\DataMem)
                  EndIf
                  \DataLen + Res
                  \DataMem = AllocateMemory(\DataLen)
                  If TmpMem
                    CopyMemory(TmpMem, \DataMem, \DataLen - Res)
                    FreeMemory(TmpMem)
                    CopyMemory(Buf, \DataMem + \DataLen - Res, Res)
                  Else
                    CopyMemory(Buf, \DataMem , Res)
                  EndIf
                EndIf
                If NetworkClientEvent(\Connexion) = #PB_NetworkEvent_Data 
                  Buf   = AllocateMemory(1024)
                  Res   = ReceiveNetworkData(\Connexion, Buf,1024)
                  
                  Rep   = Trim(PeekS(Buf))
                  Select Left(Rep, 3)
                    Case "150" ; Statut de fichier vérifié; ouverture de canal de données en cours
                    Case "226"  ; Fermeture du canal de données. Service terminé
                      CloseNetworkConnection(\Connexion_PASV)
                      \Connexion_PASV     = 0
                      Main                = #True  
                    Default
                      Debug "RNet_FTP_ExamineDirectory >3>"+Rep
                  EndSelect
                EndIf
              Until Main = #True
              FileWrite = OpenFile(#PB_Any, LocalFile)
              WriteData(FileWrite, \DataMem, \DataLen)
              CloseFile(FileWrite)
              \DataLen = 0
              FreeMemory(\DataMem)
              ProcedureReturn #True
            EndIf
          EndIf
        Else
          ProcedureReturn #False
        EndIf
      EndWith
      ProcedureReturn #True
    Else
      ProcedureReturn #False
    EndIf
  EndProcedure
  ProcedureDLL RNet_FTP_Upload(ID.l, FTPPath.s, LocalFile.s, Mode.l = #RNet_FTP_Mode_Binary)
    Protected *RObject.S_RNet = RNET_ID(ID)
    If *RObject <>  #Null
      Protected Rep.s, Buf.l
      Protected IPStart.l, IPEnd.l, IPPort.l
      Protected IPContent.s, IPAdress.s
      With *RObject\FTP
        If \Connexion
          If Mode = #RNet_FTP_Mode_Binary
            SendNetworkString(\Connexion, "TYPE I"+#RNet_Const_CRLF)
          ElseIf Mode = #RNet_FTP_Mode_Ascii
            SendNetworkString(\Connexion, "TYPE A"+#RNet_Const_CRLF)
          EndIf
          Repeat
            If NetworkClientEvent(\Connexion) = #PB_NetworkEvent_Data
              Buf   = AllocateMemory(1024)
              Res   = ReceiveNetworkData(\Connexion, Buf,1024)
              Rep   = Trim(PeekS(Buf))
              Select Left(Rep, 3)
                Case "200" ; OK
                  Main  = #True  
                Default
                  Debug "RNet_FTP_Upload > 1 >"+Rep
              EndSelect
              FreeMemory(Buf)
            EndIf
          Until Main = #True
          If Main = #True
            Main = #False
            SendNetworkString(\Connexion, "PASV"+#RNet_Const_CRLF)
            Repeat
              If NetworkClientEvent(\Connexion) = #PB_NetworkEvent_Data 
                Buf   = AllocateMemory(1024)
                Res   = ReceiveNetworkData(\Connexion, Buf,1024)
                Rep   = Trim(PeekS(Buf))
                Select Left(Rep, 3)
                  Case "227"
                    Main            = #True
                    IPStart         = FindString(Rep, "(", 1)+1
                    IPEnd           = FindString(Rep, ")", 1)
                    IPContent       = Mid(Rep, IPStart, IPEnd-IPStart)
                    IPAdress        = StringField(IPContent, 1, ",")+"."+StringField(IPContent, 2, ",")+"."+StringField(IPContent, 3, ",")+"."+StringField(IPContent, 4, ",")
                    IPPort          = Val(StringField(IPContent, 5, ","))*256+Val(StringField(IPContent, 6, ","))
                    \Connexion_PASV = OpenNetworkConnection(IPAdress, IPPort)
                  Default
                    Debug "RNet_FTP_Upload > 2 >"+Rep
                EndSelect
              EndIf
            Until Main = #True
            If Main = #True
              Main = #False
              SendNetworkString(\Connexion, "STOR "+FTPPath+GetFilePart(LocalFile)+#RNet_Const_CRLF)
              ;{ Load In Memory le fichier
              \DataLen = FileSize(LocalFile)
              \DataMem = AllocateMemory(\DataLen)
              TmpFile = OpenFile(#PB_Any, LocalFile)
                ReadData(TmpFile, \DataMem, \DataLen)
              CloseFile(TmpFile)
              ;}
              ;{ Upload le fichier par paquet de 1024o
              For Inc = 0 To Int(\DataLen/1024)
                Start = 1024 * Inc
                If \DataLen - Start > 1024 
                  SendNetworkData(\Connexion_PASV, \DataMem + Start, 1024)
                Else
                  SendNetworkData(\Connexion_PASV, \DataMem + Start, \DataLen - Start)
                EndIf
              Next
              ;}
              ; Ferme la connexion pour que le serv puisse écrire le fichier
              CloseNetworkConnection(\Connexion_PASV)
              Repeat
                If NetworkClientEvent(\Connexion) = #PB_NetworkEvent_Data 
                  Buf   = AllocateMemory(1024)
                  Res   = ReceiveNetworkData(\Connexion, Buf,1024)
                  Rep   = Trim(PeekS(Buf))
                  Select Left(Rep, 3)
                    Case "150" ; Statut de fichier vérifié; ouverture de canal de données en cours
                    Case "226"  ; Fermeture du canal de données. Service terminé
                      \Connexion_PASV     = 0
                      Main                = #True  
                    Default
                      Debug "RNet_FTP_Upload >3>"+Rep
                  EndSelect
                EndIf
              Until Main = #True
              \DataLen = 0
              FreeMemory(\DataMem)
              ProcedureReturn #True
            EndIf
          EndIf
        Else
          ProcedureReturn #False
        EndIf
      EndWith
      ProcedureReturn #True
    Else
      ProcedureReturn #False
    EndIf
  EndProcedure
  
  ProcedureDLL.s RNet_FTP_GetSystem(ID.l)
    Protected *RObject.S_RNet = RNET_ID(ID)
    If *RObject <>  #Null
      Protected Rep.s, Buf.l, System.s
      With *RObject\FTP
        If \Connexion
          SendNetworkString(\Connexion, "SYST"+#RNet_Const_CRLF)
          Repeat
            If NetworkClientEvent(\Connexion) = #PB_NetworkEvent_Data
              Buf   = AllocateMemory(1024)
              Res   = ReceiveNetworkData(\Connexion, Buf,1024)
              Rep   = Trim(PeekS(Buf))
              Select Left(Rep, 3)
                Case "215"
                  *RObject\LastError  = #RNet_Error_OK
                  Main                = #True
                  Rep                 = RemoveString(Rep, Chr(13))
                  Rep                 = RemoveString(Rep, Chr(10))
                  System              = Trim(Right(Rep, Len(Rep)-3))
                Default
                  Debug "RNet_FTP_GetSystem >"+Rep
              EndSelect
              FreeMemory(Buf)
            EndIf
          Until Main = #True
          ProcedureReturn System
        Else
          ProcedureReturn ""
        EndIf
      EndWith
    Else
      ProcedureReturn ""
    EndIf
  EndProcedure
  ProcedureDLL.l RNet_FTP_GetStatus(ID.l)
    Protected *RObject.S_RNet = RNET_ID(ID)
    If *RObject <>  #Null
      Protected Rep.s, Buf.l, Path.s
      With *RObject\FTP
        If \Connexion
          SendNetworkString(\Connexion, "STAT"+#RNet_Const_CRLF)
          Repeat
            If NetworkClientEvent(\Connexion) = #PB_NetworkEvent_Data
              Buf   = AllocateMemory(1024)
              Res   = ReceiveNetworkData(\Connexion, Buf,1024)
              Rep   = Trim(PeekS(Buf))
              Select Left(Rep, 3)
                Case ""
                  *RObject\LastError  = #RNet_Error_OK
                Case "500"
                  *RObject\LastError  = #RNet_Error_CommandUnrecognized
                  Main                = #True
                Default
                  Debug "RNet_FTP_GetStatus >"+Rep
              EndSelect
              FreeMemory(Buf)
            EndIf
          Until Main = #True
          If *RObject\LastError = #RNet_Error_OK
            ProcedureReturn #True
          Else
            ProcedureReturn #False
          EndIf
        Else
          ProcedureReturn #False
        EndIf
      EndWith
    Else
      ProcedureReturn #False
    EndIf
  EndProcedure
  ProcedureDLL.s RNet_FTP_GetHelp(ID.l)
    Protected *RObject.S_RNet = RNET_ID(ID)
    If *RObject <>  #Null
      Protected Rep.s, Buf.l, Help.s
      With *RObject\FTP
        If \Connexion
          SendNetworkString(\Connexion, "HELP"+#RNet_Const_CRLF)
          Repeat
            If NetworkClientEvent(\Connexion) = #PB_NetworkEvent_Data
              Buf   = AllocateMemory(1024)
              Res   = ReceiveNetworkData(\Connexion, Buf,1024)
              Rep   = Trim(PeekS(Buf))
              Select Left(Rep, 3)
                Case ""
                  *RObject\LastError  = #RNet_Error_OK
                Case "500"
                  *RObject\LastError  = #RNet_Error_CommandUnrecognized
                  Main                = #True
                Default
                  Debug "RNet_FTP_GetHelp >"+Rep
              EndSelect
              FreeMemory(Buf)
            EndIf
          Until Main = #True
          ProcedureReturn Help
        Else
          ProcedureReturn ""
        EndIf
      EndWith
    Else
      ProcedureReturn ""
    EndIf
  EndProcedure
  ProcedureDLL.l RNet_FTP_NoOperation(ID.l)
    Protected *RObject.S_RNet = RNET_ID(ID)
    If *RObject <>  #Null
      Protected Rep.s, Buf.l, Path.s
      With *RObject\FTP
        If \Connexion
          SendNetworkString(\Connexion, "NOOP"+#RNet_Const_CRLF)
          Repeat
            If NetworkClientEvent(\Connexion) = #PB_NetworkEvent_Data
              Buf   = AllocateMemory(1024)
              Res   = ReceiveNetworkData(\Connexion, Buf,1024)
              Rep   = Trim(PeekS(Buf))
              Select Left(Rep, 3)
                Case "200"
                  *RObject\LastError  = #RNet_Error_OK
                  Main                = #True
                Default
                  Debug "RNet_FTP_NoOperation >"+Rep
              EndSelect
              FreeMemory(Buf)
            EndIf
          Until Main = #True
          ProcedureReturn #True
        Else
          ProcedureReturn #False
        EndIf
      EndWith
    Else
      ProcedureReturn #False
    EndIf
  EndProcedure
  

; IDE Options = PureBasic 4.20 (Windows - x86)
; CursorPosition = 76
; Folding = AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA9
; UseMainFile = RNet_Ex_FTP_00.pb