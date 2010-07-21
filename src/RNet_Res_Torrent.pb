  Enumeration 0 ; RNet_Torrent
    #RNet_Torrent_bDicoStart
    #RNet_Torrent_bDicoEnd
    #RNet_Torrent_bInteger
    #RNet_Torrent_bList
    #RNet_Torrent_bString
  EndEnumeration
  
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
