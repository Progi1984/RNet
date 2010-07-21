  IncludeFile "RNet.pb"
  RNet_Init()
  InitNetwork()
  
  Debug "===================================================1"
  
  RNet_Create(1, #RNet_Type_POP)
  Debug RNet_POP_Connect(1, "pop.free.fr", 110, "progi1984", "oneill")
  ;Debug RNet_POP_Connect(1, "192.168.14.10", 110, "f.lefevre@malherbe.fr", "mt87lf")
  Number  = RNet_POP_CountMessages(1)
  Debug "Total Number : "+Str(Number)
  Debug "Total Size : "+Str(RNet_POP_GetMessagesTotalSize(1))
  For Inc = 0 To Number -1
    Debug "ID : "+Str(Inc)
    Debug "Size = "+Str(RNet_POP_GetMessageSize(1, Inc))
    RNet_POP_RetrieveMessage(1, Inc)
    Debug RNet_POP_ExamineMessage(1)
    Debug "From : "+RNet_Pop_GetAttribute(1, #RNet_Mail_Attribute_From)
    Debug "Content-Type : "+RNet_Pop_GetAttribute(1, #RNet_Mail_Attribute_ContentType)
    Debug RNet_POP_SaveToFile(1, "Samples\POP_Mail_"+Str(Inc)+".txt")
    Debug "--------------------------------"
  Next
  
  Debug RNet_POP_NoOperation(1)
  Debug "After RNet_POP_NoOperation >" +RNet_POP_GetLastServerMessage(1) 
  
  Debug RNet_POP_Reset(1)
  Debug "After RNet_POP_Reset >" +RNet_POP_GetLastServerMessage(1) 
  
  RNet_POP_Disconnect(1)
  RNet_Free(1)
 
; IDE Options = PureBasic 4.10 (Windows - x86)
; CursorPosition = 18
; Folding = -
; EnableThread