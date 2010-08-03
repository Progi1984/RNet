InitNetwork()
XIncludeFile "../src/RNet_Res.pb"
XIncludeFile "../src/RNet.pb"
RNet_Init()

  Global sProxyIP.s = ""
  Global lProxyPort.l = 0
  Global sProxyUsername.s = ""
  Global sProxyPassword.s = ""
  Global bUseProxy.b = #False
  
  Debug "===================================================1"
  ; A very simple download
  RNet_CreateClient(1, #RNet_Type_HTTP)
  If bUseProxy = #True
    RNet_HTTP_SetProxy(1, sProxyIP, lProxyPort, sProxyUsername, sProxyPassword)
  EndIf
  RNet_HTTP_SetTimeout(1, 1000)
  RNet_HTTP_Allocate(1, "http://www.rootslabs.net", #RNet_HTTP_Request_GET)
  Repeat
  Until RNet_HTTP_GetState(1) = #RNet_State_Done
  RNet_HTTP_SaveToFile(1, "results/HTTP_Index_00.htm", #True)
  RNet_Free(1)
  Debug "===================================================2"
  ; Get informations about page
  RNet_CreateClient(2, #RNet_Type_HTTP)
  If bUseProxy = #True
    RNet_HTTP_SetProxy(2, sProxyIP, lProxyPort, sProxyUsername, sProxyPassword)
  EndIf
  RNet_HTTP_Allocate(2, "http://www.rootslabs.net", #RNet_HTTP_Request_GET)
  Repeat
  Until RNet_HTTP_GetState(2) = #RNet_State_Done
  RNet_HTTP_Examine(2)
    Debug "Size > " + Str(Val(RNet_HTTP_GetAttribute(2, #RNet_HTTP_Attribute_Size)))
    Debug "LastModified > " + RNet_HTTP_GetAttribute(2, #RNet_HTTP_Attribute_LastModified)
  RNet_Free(2)
  
  Debug "===================================================3"
  ; Define informations  
  RNet_CreateClient(3, #RNet_Type_HTTP)
  If bUseProxy = #True
    RNet_HTTP_SetProxy(3, sProxyIP, lProxyPort, sProxyUsername, sProxyPassword)
  EndIf
  RNet_HTTP_SetAttribute(3, #RNet_HTTP_Attribute_UserAgent, "RNet for PureBasic")
  RNet_HTTP_SetAttribute(3, #RNet_HTTP_Attribute_Range, "50")
  RNet_HTTP_SetAttribute(3, #RNet_HTTP_Attribute_CacheControl, "only-if-cached")
  RNet_HTTP_SetAttribute(3, #RNet_HTTP_Attribute_Referer, "http://www.purebasic.com/")
  RNet_HTTP_SetAttribute(3, #RNet_HTTP_Attribute_HTTPVersion, "HTTP/1.1")
  
  RNet_HTTP_Allocate(3, "http://www.rootslabs.net", #RNet_HTTP_Request_GET)
  Repeat
  Until RNet_HTTP_GetState(3) = #RNet_State_Done
  RNet_HTTP_Examine(3)
  RNet_HTTP_ResetAllocation(3)
  
  Debug "----"
  RNet_HTTP_Allocate(3, "http://www.google.fr", #RNet_HTTP_Request_GET)
  Repeat
  Until RNet_HTTP_GetState(3) = #RNet_State_Done
  RNet_HTTP_Examine(3)
  RNet_HTTP_ResetAllocation(3)
  
  Debug "----"
  RNet_HTTP_Allocate(3, "http://www.rootslabs.net", #RNet_HTTP_Request_GET)
  Repeat
  Until RNet_HTTP_GetState(3) = #RNet_State_Done
  RNet_HTTP_Examine(3)
  RNet_HTTP_ResetAllocation(3)
  
  Debug "----"
  RNet_HTTP_Allocate(3, "http://www.google.fr", #RNet_HTTP_Request_GET)
  Repeat
  Until RNet_HTTP_GetState(3) = #RNet_State_Done
  RNet_HTTP_Examine(3)
  RNet_HTTP_SaveToFile(3, "results/HTTP_Index_01.htm", #True)
  RNet_Free(3)
  
  Debug "===================================================4"
  ; Get informations about page
  RNet_CreateClient(4, #RNet_Type_HTTP)
  If bUseProxy = #True
    RNet_HTTP_SetProxy(4, sProxyIP, lProxyPort, sProxyUsername, sProxyPassword)
  EndIf

  RNet_HTTP_Allocate(4, "http://www.rootslabs.net", #RNet_HTTP_Request_GET)
  Repeat
  Until RNet_HTTP_GetState(4) = #RNet_State_Done
  *Buffer = AllocateMemory(Size)
  RNet_HTTP_SaveToMemory(4, *Buffer)
  Debug PeekS(*Buffer)
  RNet_Free(4)

  Debug "===================================================5"
  ; A very simple download (with bad proxy login & pass)
  RNet_CreateClient(5, #RNet_Type_HTTP)
  If bUseProxy = #True
    RNet_HTTP_SetProxy(5, sProxyIP, lProxyPort, sProxyUsername, "badpassword")
  EndIf

  RNet_HTTP_Allocate(5, "http://www.and51.de/index.html", #RNet_HTTP_Request_GET)
  Repeat
  Until RNet_HTTP_GetState(5) = #RNet_State_Done
  RNet_HTTP_SaveToFile(5, "results/HTTP_Index_02.htm", #True)
  RNet_Free(5)
  
  Debug "===================================================6"
  ; A very simple download (with bad URL)
  RNet_CreateClient(6, #RNet_Type_HTTP)
  If bUseProxy = #True
    RNet_HTTP_SetProxy(6, sProxyIP, lProxyPort, sProxyUsername, sProxyPassword)
  EndIf
  RNet_HTTP_SetTimeout(6, 10)
  RNet_HTTP_Allocate(6, "http://www.index.rieb", #RNet_HTTP_Request_GET)
  Repeat
  Until RNet_HTTP_GetState(6) = #RNet_State_Done
  Debug RNet_GetLastError(6)
  If RNet_GetLastError(6) = #RNet_Error_TimeOut
    Debug "Error TimeOut"
  EndIf
  RNet_Free(6)
  