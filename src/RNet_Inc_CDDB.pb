; Doc 
  ;http://ftp.freedb.org/pub/freedb/latest/DBFORMAT
  ;http://ftp.freedb.org/pub/freedb/latest/CDDBPROTO
  ;http://en.wikipedia.org/wiki/CDDB
  Procedure RNet_CDDB_Sum(VarN.l)
    Protected VarRet.l = 0
    While VarN > 0
      VarRet = VarRet + (VarN % 10)
      VarN = VarN / 10
    Wend
    ProcedureReturn VarRet
  EndProcedure
  ProcedureDLL.l RNet_CDDB_CalculateDiskID(ID.l, CDDrive.s)
    Protected *RObject.S_RNet = RNET_ID(ID)
    If *RObject <>  #Null
      With *RObject\CDDB
        Protected CDAList_Size.l = 99
        Protected TrackCount.l = 0, TrackNum.l = 0, FileCDA.l
        Protected TrackName.s
        Protected TrackStart_Frame.s, TrackStart_Seconds.s, TrackStart_Minutes.s
        Protected TrackEnd_Frame.l, TrackEnd_Seconds.l, TrackEnd_Minutes.l
        Protected sTrackEnd_Frame.s, sTrackEnd_Seconds.s, sTrackEnd_Minutes.s
        Protected TrackLength_Frame.s, TrackLength_Seconds.s, TrackLength_Minutes.s
        Protected Var_T.l = 0, Var_N.l = 0, Var_I.l = 0
        Protected Dim CDAList.s(CDAList_Size)
        Protected Dim CDToc.S_RNet_CDDB_Toc(CDAList_Size+1)
        ; Count CDTracks
        If ExamineDirectory(0, CDDrive, "*.cda")  
          While NextDirectoryEntry(0)
            CDAList(TrackCount) = CDDrive+DirectoryEntryName(0)
            TrackCount   + 1
          Wend
          FinishDirectory(0)
        EndIf
        If TrackCount > 0
          ; Sort the file names in ascending order
          SortArray(CDAList(), 0)
          ; Our file names are at the end of our array
          ; with null filenames being first after sorting
          ; do the math to get the first .cda file (Track01.cda)
          For Inc = (CDAList_Size+1) - TrackCount To CDAList_Size
            ; Open file for reading
            FileCDA             = ReadFile(#PB_Any, CDAList(Inc))
            ; Seek to track byte
            FileSeek(FileCDA, 22)
            TrackName           = RSet(Str(ReadByte(FileCDA)&$FF), 2, "0")
            ; Seek to track start info
            FileSeek(FileCDA, 36)
            ; Add leading zeros to track start info
            TrackStart_Frame    = RSet(Str(ReadByte(FileCDA)&$FF), 2, "0")
            TrackStart_Seconds  = RSet(Str(ReadByte(FileCDA)&$FF), 2, "0")
            TrackStart_Minutes  = RSet(Str(ReadByte(FileCDA)&$FF), 2, "0")
            ; Seek to track length info
            FileSeek(FileCDA, 40)
            ; Add leading zeros to track length info
            TrackLength_Frame   = RSet(Str(ReadByte(FileCDA)&$FF), 2, "0")
            TrackLength_Seconds = RSet(Str(ReadByte(FileCDA)&$FF), 2, "0")
            TrackLength_Minutes = RSet(Str(ReadByte(FileCDA)&$FF), 2, "0")
            ; Close file
            CloseFile(FileCDA)
            
            ; Do math to get track end info
            TrackEnd_Minutes = Val(TrackStart_Minutes) + Val(TrackLength_Minutes)
            If TrackEnd_Minutes >= 60 : TrackEnd_Minutes - 60 : EndIf
            
            ; 60 seconds = 1 minute so make adjustments as needed
            TrackEnd_Seconds = Val(TrackStart_Seconds) + Val(TrackLength_Seconds)
            If TrackEnd_Seconds >= 60 : TrackEnd_Seconds - 60 : TrackEnd_Seconds + 1  :EndIf
            
            ; 75 frames = 1 second so make adjustments as needed
            TrackEnd_Frame = Val(TrackStart_Frame) + Val(TrackLength_Frame)
            If TrackEnd_Frame >= 75   : TrackEnd_Frame - 75   : TrackEnd_Seconds + 1  :EndIf

            ; Fill track end info with 0's
            sTrackEnd_Frame    = RSet(Str(TrackEnd_Frame), 2, "0")
            sTrackEnd_Seconds  = RSet(Str(TrackEnd_Seconds), 2, "0")
            sTrackEnd_Minutes  = RSet(Str(TrackEnd_Minutes), 2, "0")

            ; Fill in the cdtoc for returning DiscID
            CDToc(TrackNum)\min    = Val(TrackStart_Minutes)
            CDToc(TrackNum)\sec    = Val(TrackStart_Seconds)
            CDToc(TrackNum)\frame  = Val(TrackStart_Frame)
            TrackNum+1
          Next Inc
          CDToc(trackNum)\min   = Val(sTrackEnd_Minutes)
          CDToc(trackNum)\sec   = Val(sTrackEnd_Seconds)
          CDToc(trackNum)\frame = Val(sTrackEnd_Frame)
          
          While Var_I < TrackCount
            Var_N + RNet_CDDB_Sum((CDToc(Var_I)\min * 60) + CDToc(Var_I)\sec)
            Var_I + 1
          Wend
          Var_T = ((CDToc(TrackCount)\min * 60) + CDToc(TrackCount)\sec) - ((CDToc(0)\min * 60) + CDToc(0)\sec)
          \DiscID = Hex(Var_N % $FF << 24 | Var_T << 8 | TrackCount)
        EndIf
        ProcedureReturn #True
      EndWith
    Else
      ProcedureReturn #False
    EndIf
  EndProcedure
  ProcedureDLL RNet_CDDB_Connect(ID.l, Server.s, Port.l = 119, Login.s = "", Password.s = "")
    Protected *RObject.S_RNet = RNET_ID(ID)
    If *RObject <>  #Null
      With *RObject\CDDB
        \Server   = Server
        \Port     = Port
        \Connexion= OpenNetworkConnection(\Server, \Port, #PB_Network_TCP)
        Repeat
          *Buffer   = AllocateMemory(1024)
          If NetworkClientEvent(\Connexion) = #PB_NetworkEvent_Data
            ReturnData      = ReceiveNetworkData(\Connexion, *Buffer, 1024)
            If Trim(PeekS(*Buffer)) <> ""
              \CmdLastAnswer  = PeekS(*Buffer)
              Debug \CmdLastAnswer
              Select Left(\CmdLastAnswer, 3)
                Case ""
                Default: Debug "RNet_CDDB_Connect > "+\CmdLastAnswer
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

  
  ProcedureDLL RNet_CDDB_(ID.l)
    Protected *RObject.S_RNet = RNET_ID(ID)
    If *RObject <>  #Null
      With *RObject\CDDB
  
      EndWith
      ProcedureReturn #True
    Else
      ProcedureReturn -1
    EndIf
  EndProcedure

; IDE Options = PureBasic 4.10 (Windows - x86)
; CursorPosition = 104
; Folding = y-+-
; UseMainFile = RNet_Ex_CDDB_00.pb