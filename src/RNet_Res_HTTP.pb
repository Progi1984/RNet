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
  #RNet_HTTP_Request_GET
  #RNet_HTTP_Request_POST
  #RNet_HTTP_Request_HEAD
EndEnumeration

Structure S_RNet_HTTP
  State.l
  Timeout.l
  
  ; Proxy
  bIsProxy.b
  sProxy_IP.s
  lProxy_Port.l
  sProxy_Login.s
  sProxy_Pass.s
  
  ; Page
  sPageURL.s
  sPageHost.s
  lPagePort.l
  sPagePath.s
  
  sContentReturned.s
  sContentBody.s
  
  lPostData.l
  lPostData_Len.l
  
  sInfosHTTPVersion.s
  sInfosHTTPCode.s
  sInfosAcceptRanges.s
  sInfosDate.s
  sInfosContentLength.s
  sInfosContentType.s
  sInfosServer.s
  sInfosLastModified.s
  sInfosEtag.s
  sInfosVia.s
  sInfosAge.s
  sInfosUserAgent.s
  sInfosRange.s
  sInfosCacheControl.s
  sInfosReferer.s
  sInfosTransferEncoding.s
  sInfosSetCookie.s
EndStructure
