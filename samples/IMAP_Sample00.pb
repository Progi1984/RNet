  IncludeFile "RNet.pb"
  RNet_Init()
  InitNetwork()
  
  Debug "===================================================1"
  
  RNet_Create(1, #RNet_Type_IMAP)
  Debug RNet_IMAP_Connect(1, "imap.laposte.net", 143, "francky.lefevre", "timbre")
  
  Debug "=====================ListFolders in *"
  List.s = RNet_IMAP_ListFolders(1, "*")
  If List > ""
    For Inc = 0 To CountString(List, #RNet_Const_Tab)
      Debug "[DIR] "+StringField(List, Inc + 1, #RNet_Const_Tab)
      Debug RNet_IMAP_SetDirectory(1, StringField(List, Inc + 1, #RNet_Const_Tab))
      Debug RNet_IMAP_ExamineDirectory(1)
      Debug "Num Messages : "+Str(RNet_IMAP_CountMessagesAll(1))
      If RNet_IMAP_CountMessagesUnseen(1) > 0
        Debug "== Unseen : "+Str(RNet_IMAP_CountMessagesUnseen(1))
      EndIf
      If RNet_IMAP_CountMessagesRecent(1) > 0
        Debug "== New : "+Str(RNet_IMAP_CountMessagesRecent(1))
      EndIf
      Debug "--------------------"
    Next
  Else
    Debug "No Folders"
  EndIf

  Debug RNet_IMAP_CreateDirectory(1, "INBOX.PersoTest")
  Debug RNet_IMAP_RenameDirectory(1, "INBOX.PersoTest", "INBOX.PersoTestNew")
  Debug RNet_IMAP_DeleteDirectory(1, "INBOX.PersoTest")
;   
  
  Debug RNet_IMAP_SetDirectory(1,"INBOX")
  Debug RNet_IMAP_RetrieveMessage(1, 1)
  Debug RNet_IMAP_ExamineMessage(1)
  Debug RNet_IMAP_GetAttribute(1, #RNet_Mail_Attribute_To)
  ;debug RNet_IMAP_DeleteMessage(1,1)
  RNet_IMAP_Disconnect(1)
  RNet_Free(1)
 
; IDE Options = PureBasic 4.10 (Windows - x86)
; CursorPosition = 37
; Folding = -
; EnableThread