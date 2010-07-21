  IncludeFile "RNet.pb"
  RNet_Init()
  InitNetwork()
  
  Debug "===================================================1"
  
  RNet_Create(1, #RNet_Type_SMTP)
  Debug RNet_SMTP_Connect(1, "smtp.laposte.net", 25, "francky.lefevre", "timbre")
  
  RNet_SMTP_SetAttribute(1, #RNet_SMTP_Attribute_From, "francky.lefevre@laposte.net")
  RNet_SMTP_SetAttribute(1, #RNet_SMTP_Attribute_To, "progi1984@gmail.com")
  RNet_SMTP_SetAttribute(1, #RNet_SMTP_Attribute_Subject, "Test 16:07")
  RNet_SMTP_SetAttribute(1, #RNet_SMTP_Attribute_Body, "Test Body 16:07")
  
  RNet_SMTP_SendMail(1)
  RNet_SMTP_Disconnect(1)
  RNet_Free(1)
 
; IDE Options = PureBasic 4.10 (Windows - x86)
; CursorPosition = 14
; Folding = -
; EnableThread