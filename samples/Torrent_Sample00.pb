  IncludeFile "RNet.pb"
  RNet_Init()
  InitNetwork()
  
  Debug "===================================================Torrent"
  
  RNet_Create(1, #RNet_Type_Torrent)
  Debug RNet_Torrent_ExamineFile(1, "C:\ZPerso\RNet\Samples\Sample0.torrent")
    Debug "Mime : "+ RNet_Torrent_GetTypeMime(1)
    Debug "Announce : "+ RNet_Torrent_GetAnnounce(1)
    Debug "AnnounceList : "+ RNet_Torrent_GetAnnounceList(1)
    Debug "Creator : "+ RNet_Torrent_GetCreator(1)
    Debug "Encoding : "+ RNet_Torrent_GetEncoding(1)
    Debug "Comment : "+ RNet_Torrent_GetComment(1)
    Debug "Private : "+ Str(RNet_Torrent_GetPrivate(1))
    Debug "Date Creation : " + FormatDate("%dd/%mm/%yyyy %hh:%ii:%ss", RNet_Torrent_GetCreationDate(1))
    For i = 0 To RNet_Torrent_CountFiles(1) - 1
      Debug "# "+Str(i)
      Debug "Filename :"+RNet_Torrent_GetFilename(1, i)
      Debug "Filesize :"+Str(RNet_Torrent_GetFilesize(1, i))
    Next
  Debug "======================"  
  Debug RNet_Torrent_ExamineFile(1, "C:\ZPerso\RNet\Samples\Sample1.torrent")
    Debug "Mime : "+ RNet_Torrent_GetTypeMime(1)
    Debug "Announce : "+ RNet_Torrent_GetAnnounce(1)
    Debug "AnnounceList : "+ RNet_Torrent_GetAnnounceList(1)
    Debug "Creator : "+ RNet_Torrent_GetCreator(1)
    Debug "Encoding : "+ RNet_Torrent_GetEncoding(1)
    Debug "Comment : "+ RNet_Torrent_GetComment(1)
    Debug "Private : "+ Str(RNet_Torrent_GetPrivate(1))
    Debug "Announce : "+ RNet_Torrent_GetAnnounce(1)
    Debug "Date Creation : " + FormatDate("%dd/%mm/%yyyy %hh:%ii:%ss", RNet_Torrent_GetCreationDate(1))
    For i = 0 To RNet_Torrent_CountFiles(1) - 1
      Debug "# "+Str(i)
      Debug "Filename :"+RNet_Torrent_GetFilename(1, i)
      Debug "Filesize :"+Str(RNet_Torrent_GetFilesize(1, i))
    Next
  RNet_Free(1)

; IDE Options = PureBasic 4.10 (Windows - x86)
; CursorPosition = 14
; Folding = -