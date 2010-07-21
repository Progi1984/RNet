Enumeration 1 ; RNet_HTTP_Attribute_FileSize 
  #RNet_HTTP_Attribute_FileSize
  #RNet_HTTP_Attribute_AcceptRanges
  #RNet_HTTP_Attribute_Date
  #RNet_HTTP_Attribute_ContentLength
  #RNet_HTTP_Attribute_ContentType
  #RNet_HTTP_Attribute_Server
  #RNet_HTTP_Attribute_LastModified
  #RNet_HTTP_Attribute_Etag
  #RNet_HTTP_Attribute_Via
  #RNet_HTTP_Attribute_Age
  #RNet_HTTP_Attribute_HTTPVersion
  #RNet_HTTP_Attribute_HTTPCode
  #RNet_HTTP_Attribute_UserAgent
  #RNet_HTTP_Attribute_Range
  #RNet_HTTP_Attribute_CacheControl
  #RNet_HTTP_Attribute_Referer
  #RNet_HTTP_Attribute_Size
  #RNet_HTTP_Attribute_ContentBody
  #RNet_HTTP_Attribute_ContentAll
  #RNet_HTTP_Attribute_ContentHeader
  #RNet_HTTP_Attribute_TransferEncoding
  #RNet_HTTP_Attribute_SetCookie
EndEnumeration
Enumeration 1 ; RNet_HTTP_Request_Get
  #RNet_HTTP_Request_Get
  #RNet_HTTP_Request_Post
  #RNet_HTTP_Request_Head
EndEnumeration

Structure S_RNet_HTTP
  State.l
  Timeout.l
  
  ; Proxy
  Has_Proxy.l
  Proxy_IP.s
  Proxy_Port.l
  Proxy_Login.s
  Proxy_Pass.s
  
  ; Page
  URL.s
  Host.s
  Port.l
  Path.s
  
  ContentReturned.s
  ContentBody.s
  
  Post_Data.l
  Post_Data_Len.l
  
  Infos_HTTPVersion.s
  Infos_HTTPCode.s
  Infos_AcceptRanges.s
  Infos_Date.s
  Infos_ContentLength.s
  Infos_ContentType.s
  Infos_Server.s
  Infos_LastModified.s
  Infos_Etag.s
  Infos_Via.s
  Infos_Age.s
  Infos_UserAgent.s
  Infos_Range.s
  Infos_CacheControl.s
  Infos_Referer.s
  Infos_TransferEncoding.s
  Infos_SetCookie.s
EndStructure
