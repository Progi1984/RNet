  IncludeFile "RNet.pb"
  RNet_Init()
  InitNetwork()
  
  Debug "===================================================1"
  ; A very simple download (with bad proxy login & pass)
  RNet_Create(1, #RNet_Type_HTTP)
  RNet_HTTP_SetProxy(1, "213.56.30.99", 8080, "e-malherbe@sasmalt2.fr.fto", "eamlh200")
  
  RNet_HTTP_Allocate(1, "http://www.and51.de/index.html")
  Repeat
  Until RNet_HTTP_GetState(1) = #RNet_State_Done
  RNet_HTTP_SaveToFile(1, "C:\ZPerso\RNet\Samples\HTTP_Index_00.htm")
  RNet_Free(1)
  
  Debug "===================================================2"
  ; Get informations about page
  RNet_Create(2, #RNet_Type_HTTP)
  RNet_HTTP_SetProxy(2, "213.56.30.99", 8080, "e-malherbe@sasmalt2.fr.fto", "eamlh200")
  *greetings=AllocateMemory(100)
  PokeS(*greetings, "Hello from PureBasic!")

  RNet_HTTP_Allocate(2, "http://www.and51.de/index.html")
  Repeat
  Until RNet_HTTP_GetState(2) = #RNet_State_Done
  RNet_HTTP_Examine(2)
    Size = Val(RNet_HTTP_GetAttribute(2, #RNet_HTTP_Attribute_Size))
    Debug Size
    Debug RNet_HTTP_GetAttribute(2, #RNet_HTTP_Attribute_LastModified)
  RNet_Free(2)
  
  Debug "===================================================3"
  ; Define informations  
  RNet_Create(3, #RNet_Type_HTTP)
  RNet_HTTP_SetProxy(3, "213.56.30.99", 8080, "e-malherbe@sasmalt2.fr.fto", "eamlh200")
  RNet_HTTP_SetAttribute(3, #RNet_HTTP_Attribute_UserAgent, "RNet for PureBasic")
  RNet_HTTP_SetAttribute(3, #RNet_HTTP_Attribute_Range, "50")
  RNet_HTTP_SetAttribute(3, #RNet_HTTP_Attribute_CacheControl, "only-if-chaced")
  RNet_HTTP_SetAttribute(3, #RNet_HTTP_Attribute_Referer, "http://www.purebasic.com/")
  RNet_HTTP_SetAttribute(3, #RNet_HTTP_Attribute_HTTPVersion, "HTTP/1.1")
  
  RNet_HTTP_Allocate(3, "http://www.and51.de/index.html")
  Repeat
  Until RNet_HTTP_GetState(3) = #RNet_State_Done
  RNet_HTTP_Examine(3)
  RNet_HTTP_ResetAllocation(3)
  
  Debug "----"
  RNet_HTTP_Allocate(3, "http://www.google.fr")
  Repeat
  Until RNet_HTTP_GetState(3) = #RNet_State_Done
  RNet_HTTP_Examine(3)
  RNet_HTTP_ResetAllocation(3)
  
  Debug "----"
  RNet_HTTP_Allocate(3, "http://www.and51.de/index.html")
  Repeat
  Until RNet_HTTP_GetState(3) = #RNet_State_Done
  RNet_HTTP_Examine(3)
  RNet_HTTP_ResetAllocation(3)
  
  Debug "----"
  RNet_HTTP_Allocate(3, "http://www.google.fr")
  Repeat
  Until RNet_HTTP_GetState(3) = #RNet_State_Done
  RNet_HTTP_Examine(3)
  RNet_HTTP_SaveToFile(3, "C:\ZPerso\RNet\Samples\HTTP_Index_01.htm")
  RNet_Free(3)
  
  Debug "===================================================4"
  ; Get informations about page
  RNet_Create(4, #RNet_Type_HTTP)
  RNet_HTTP_SetProxy(4, "213.56.30.99", 8080, "e-malherbe@sasmalt2.fr.fto", "eamlh200")
  *greetings=AllocateMemory(100)
  PokeS(*greetings, "Hello from PureBasic!")

  RNet_HTTP_Allocate(4, "http://www.and51.de/index.html")
  Repeat
  Until RNet_HTTP_GetState(4) = #RNet_State_Done
  *Buffer = AllocateMemory(Size)
  RNet_HTTP_SaveToMemory(4, *Buffer)
  Debug PeekS(*Buffer)
  RNet_Free(4)

  Debug "===================================================5"
  ; A very simple download (with bad proxy login & pass)
  RNet_Create(5, #RNet_Type_HTTP)
  RNet_HTTP_SetProxy(5, "213.56.30.99", 8080, "e-malherb@ssmalt2.fr.fto", "emlh200")
  
  RNet_HTTP_Allocate(5, "http://www.and51.de/index.html")
  Repeat
  Until RNet_HTTP_GetState(5) = #RNet_State_Done
  RNet_HTTP_SaveToFile(5, "C:\ZPerso\RNet\Samples\HTTP_Index_02.htm")
  RNet_Free(5)
  
  Debug "===================================================6"
  ; A very simple download (with bad URL)
  RNet_Create(6, #RNet_Type_HTTP)
  RNet_HTTP_SetProxy(6, "213.66.30.99", 8080, "e-malherbe@sesmalt2.fr.fto", "emlh200")
  RNet_HTTP_SetTimeout(6, 10)
  RNet_HTTP_Allocate(6, "http://www.and51.de/index.rieb")
  Repeat
  Until RNet_HTTP_GetState(6) = #RNet_State_Done
  If RNet_GetLastError(6) = #RNet_Error_TimeOut
    Debug "Error TimeOut"
  EndIf
  RNet_Free(6)
  
; IDE Options = PureBasic 4.10 (Windows - x86)
; CursorPosition = 41
; FirstLine = 27
; Folding = -
; EnableThread