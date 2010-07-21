  IncludeFile "RNet.pb"
  RNet_Init()
  InitNetwork()
  
  Debug "===================================================1"
  
  RNet_Create(1, #RNet_Type_NNTP)
  Debug RNet_NNTP_Connect(1, "news.free.fr", 119, "progi1984", "oneill")
  Listing.s     = ">"+RNet_NNTP_ExamineGroup(1, "alt.comp.lang*")
  PartDebug.s   = ""
  For Inc = 0 To CountString(Listing, #RNet_Const_Tab)
    If Inc = 0 
      Debug "HEADER : " + StringField(Listing, Inc + 1, #RNet_Const_Tab)
    Else
      If PartDebug <> ""
        Debug PartDebug +">"+StringField(Listing, Inc + 1, #RNet_Const_Tab)
        PartDebug = ""
      Else
        PartDebug = StringField(Listing, Inc + 1, #RNet_Const_Tab)
      EndIf
    EndIf
  Next
  Debug RNet_NNTP_SetGroup(1, "proxad.free.services.pagesperso")
  Debug RNet_NNTP_CountMessages(1)
  Debug RNet_NNTP_GetFirstArticle(1)
  Debug RNet_NNTP_GetLastArticle(1)
  Debug RNet_NNTP_RetrieveArticle(1, 60000)
  Debug RNet_NNTP_ExamineMessage(1)
  Debug RNet_NNTP_GetNextArticle(1)

  RNet_NNTP_Disconnect(1)
  RNet_Free(1)
 
; IDE Options = PureBasic 4.10 (Windows - x86)
; CursorPosition = 26
; Folding = -