  InitNetwork()

  ; A very simple request POST
  RNet_CreateClient(1, #RNet_Type_HTTP)
  ;RNet_HTTP_SetProxy(1, "213.56.30.99", 8080, "e-malherbe@sasmalt2.fr.fto", "eamlh200")
  
  RNet_HTTP_SetAttribute(1, #RNet_HTTP_Attribute_ContentType, "application/x-www-form-urlencoded")
  RNet_HTTP_SetPostData(1, @"saisie2=test", Len("saisie2=test"))
;   RNet_HTTP_Allocate(1, "http://rootslabs.free.fr/useful/RW_LibCurl_Post.php", #RNet_HTTP_Request_POST)
;   Repeat
;   Until RNet_HTTP_GetState(1) = #RNet_State_Done
;   RNet_HTTP_SaveToFile(1, "C:\ZPerso\RNet\Samples\HTTP_Index_10.htm")
  RNet_Free(1)

  