  IncludeFile "RNet.pb"
  RNet_Init()
  InitNetwork()
  
  Debug "===================================================1"
  
  RNet_Create(1, #RNet_Type_CDDB)
  RNet_CDDB_Connect(1, "freedb.freedb.org", 8880)
  
  Debug RNet_CDDB_CalculateDiskID(1, "E:\")
; IDE Options = PureBasic 4.10 (Windows - x86)
; CursorPosition = 7
; Folding = -