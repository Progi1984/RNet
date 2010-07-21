  ; Doc
    ; http://www-igm.univ-mlv.fr/~dr/XPOSE2004/bitorrent/index.html
    ; http://www.run.montefiore.ulg.ac.be/~martin/resources/BitTorrentTutoriel.html
    ; http://www-igm.univ-mlv.fr/~dr/XPOSE2004/bitorrent/structure.html
  ProcedureDLL RNet_Torrent_(ID.l)
    Protected *RObject.S_RNet = RNET_ID(ID)
    If *RObject <>  #Null
      With *RObject\Torrent
  
      EndWith
      ProcedureReturn #True
    Else
      ProcedureReturn -1
    EndIf
  EndProcedure

  Procedure.b RNet_Torrent_bType(Byte.b)
    Select Byte
      Case 48 To 57
        ProcedureReturn #RNet_Torrent_bString
      Case $69;'i'
        ProcedureReturn #RNet_Torrent_bInteger
      Case $6C;'l'
        ProcedureReturn #RNet_Torrent_bList
      Case $64;'d'
        ProcedureReturn #RNet_Torrent_bDicoStart
      Case $65;'e'
        ProcedureReturn #RNet_Torrent_bDicoEnd
    EndSelect
  EndProcedure
  Procedure.s RNet_Torrent_bReadString(ByteR.l, FileID.l)
    Protected ByteRead.b
    Protected Dim ByteDim.l(0)
    Protected SizeByteDim.l = 0
    Protected LenStr.l
    Protected Str.s
    ByteDim.l(0) = ByteR
    Repeat
      ByteRead = ReadByte(FileID)
      If ByteRead >= '0' And ByteRead <= '9'
        SizeByteDim + 1
        ReDim ByteDim.l(SizeByteDim)
        ByteDim(SizeByteDim) = Val(Chr(ByteRead))
      EndIf
    Until ByteRead = ':'
    For i = 0 To SizeByteDim
      LenStr + ByteDim(i) * Pow(10,SizeByteDim-i)
    Next
    For i = 0 To LenStr - 1
      Str + Chr(ReadByte(FileID))
    Next
    ProcedureReturn Str
  EndProcedure
  Procedure.l RNet_Torrent_bReadInteger(FileID.l)
    Protected Dim Integer.l(0)
    Protected SizeInteger.l
    Protected ByteRead.b
    Repeat
      ByteRead = ReadByte(FileID)
      If ByteRead >= 48 And ByteRead <= 57
        SizeInteger + 1
        ReDim Integer(SizeInteger)
        Integer(SizeInteger-1) = Val(Chr(ByteRead))
      EndIf
    Until ByteRead = 'e'
    Protected Val.l
    For i = 0 To SizeInteger-1
      Val + Integer(i) * Pow(10,SizeInteger-1-i)
    Next
    ProcedureReturn Val
  EndProcedure
  Procedure.l RNet_Torrent_bSaveInfo(ID.l, Param.s, Integer.l, String.s)
    Protected *RObject.S_RNet = RNET_ID(ID)
    If *RObject <>  #Null
      With *RObject\Torrent
        Select Param
          Case "announce"
            \announce = String
          Case "announce-list"
            \announce_list = String
          Case "creation date"
            \creation_date = Integer
          Case "created by"
            \creation_by = String
          Case "encoding"
            \encoding = String
          Case "comment"
            \comment = String
          Case "private"
            \private = Integer
          Case "info"
          Case "path", "name"
            \info\Files + ";"+String
          Case "length", "piece length"
            \info\Lengths + ";"+Str(Integer)
          Case "pieces"
            ProcedureReturn #False
          Default
            Debug "RNet_Torrent_bSaveInfo > Param > "+ Param
        EndSelect
      EndWith
      ProcedureReturn #True
    Else
      ProcedureReturn #False
    EndIf
  EndProcedure

  ProcedureDLL RNet_Torrent_ExamineFile(ID.l, Filename.s)
    Protected *RObject.S_RNet = RNET_ID(ID)
    If *RObject <>  #Null
      Protected InfoTitle.b = #False, DicoOnline.b = #False
      Protected Param.s, FileID.l
      With *RObject\Torrent
        \TypeMime       = "application/x-bittorrent"
        \announce       = ""
        \creation_date  = 0
        \info\Files     = ""
        \info\Lengths   = ""
        FileID = OpenFile(#PB_Any, Filename)
        If FileID 
          If ReadByte(FileID) = 'd'
            Repeat
              Byte.b = ReadByte(FileID)
              Select RNet_Torrent_bType(Byte)
                Case #RNet_Torrent_bString
                ;{
                  String.s = RNet_Torrent_bReadString(Val(Chr(Byte)), FileID)
                  If InfoTitle = #True
                    If RNet_Torrent_bSaveInfo(ID, Param, 0, String) = -1 : Break :EndIf
                    InfoTitle = #False
                    Param     = ""
                  Else
                    Param     = String
                    InfoTitle = #True
                  EndIf
                ;}
                Case #RNet_Torrent_bInteger
                ;{
                  Integer.l = RNet_Torrent_bReadInteger(FileID)
                  If InfoTitle = #True
                    If RNet_Torrent_bSaveInfo(ID, Param, Integer, "") = -1 : Break :EndIf
                    InfoTitle = #False
                    Param = ""
                  EndIf
                ;}
                Case #RNet_Torrent_bDicoStart
                ;{
                  DicoOnline = #True
                ;}
                Case #RNet_Torrent_bDicoEnd
                ;{
                  DicoOnline = #False
                ;}
                Case #RNet_Torrent_bList
                ;{
                  
                ;}
              EndSelect
            Until Loc(FileID) >= Lof(FileID)
            ProcedureReturn #True
          Else
            ProcedureReturn #False
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
  ProcedureDLL.s RNet_Torrent_GetTypeMime(ID.l)
    Protected *RObject.S_RNet = RNET_ID(ID)
    If *RObject <>  #Null
      With *RObject\Torrent
        ProcedureReturn \TypeMime
      EndWith
    Else
      ProcedureReturn ""
    EndIf
  EndProcedure
  ProcedureDLL.s RNet_Torrent_GetAnnounceList(ID.l)
    Protected *RObject.S_RNet = RNET_ID(ID)
    If *RObject <>  #Null
      With *RObject\Torrent
        ProcedureReturn \announce_list
      EndWith
    Else
      ProcedureReturn ""
    EndIf
  EndProcedure
  ProcedureDLL.s RNet_Torrent_GetCreator(ID.l)
    Protected *RObject.S_RNet = RNET_ID(ID)
    If *RObject <>  #Null
      With *RObject\Torrent
        ProcedureReturn \creation_by
      EndWith
    Else
      ProcedureReturn ""
    EndIf
  EndProcedure
  ProcedureDLL.s RNet_Torrent_GetEncoding(ID.l)
    Protected *RObject.S_RNet = RNET_ID(ID)
    If *RObject <>  #Null
      With *RObject\Torrent
        ProcedureReturn \encoding
      EndWith
    Else
      ProcedureReturn ""
    EndIf
  EndProcedure
  ProcedureDLL.s RNet_Torrent_GetComment(ID.l)
    Protected *RObject.S_RNet = RNET_ID(ID)
    If *RObject <>  #Null
      With *RObject\Torrent
        ProcedureReturn \comment
      EndWith
    Else
      ProcedureReturn ""
    EndIf
  EndProcedure
  ProcedureDLL.l RNet_Torrent_GetPrivate(ID.l)
    Protected *RObject.S_RNet = RNET_ID(ID)
    If *RObject <>  #Null
      With *RObject\Torrent
        ProcedureReturn \private
      EndWith
    Else
      ProcedureReturn -1
    EndIf
  EndProcedure
  ProcedureDLL.s RNet_Torrent_GetAnnounce(ID.l)
    Protected *RObject.S_RNet = RNET_ID(ID)
    If *RObject <>  #Null
      With *RObject\Torrent
        ProcedureReturn \announce
      EndWith
    Else
      ProcedureReturn ""
    EndIf
  EndProcedure
  ProcedureDLL.l RNet_Torrent_GetCreationDate(ID.l)
    Protected *RObject.S_RNet = RNET_ID(ID)
    If *RObject <>  #Null
      With *RObject\Torrent
        ProcedureReturn \creation_date
      EndWith
    Else
      ProcedureReturn -1
    EndIf
  EndProcedure
  ProcedureDLL.l RNet_Torrent_CountFiles(ID.l)
    Protected *RObject.S_RNet = RNET_ID(ID)
    If *RObject <>  #Null
      With *RObject\Torrent
        ProcedureReturn CountString(\info\Files, ";")
      EndWith
    Else
      ProcedureReturn -1
    EndIf
  EndProcedure
  ProcedureDLL.s RNet_Torrent_GetFilename(ID.l, Item.l)
    Protected *RObject.S_RNet = RNET_ID(ID)
    If *RObject <>  #Null
      With *RObject\Torrent
        If Item<0                             : Item = 0                              : EndIf
        If Item>RNet_Torrent_CountFiles(ID)-1 : Item = RNet_Torrent_CountFiles(ID) - 1  : EndIf
        ProcedureReturn StringField(\info\Files, Item + 2, ";")
      EndWith
    Else
      ProcedureReturn ""
    EndIf
  EndProcedure
  ProcedureDLL.l RNet_Torrent_GetFilesize(ID.l, Item.l)
    Protected *RObject.S_RNet = RNET_ID(ID)
    If *RObject <>  #Null
      With *RObject\Torrent
        If Item<0                             : Item = 0                              : EndIf
        If Item>RNet_Torrent_CountFiles(ID)-1 : Item = RNet_Torrent_CountFiles(ID) - 1  : EndIf
        ProcedureReturn Val(StringField(\info\Lengths, Item + 2, ";"))
      EndWith
      ProcedureReturn #True
    Else
      ProcedureReturn -1
    EndIf
  EndProcedure

; IDE Options = PureBasic 4.10 (Windows - x86)
; CursorPosition = 287
; Folding = AAAAAAAAA-