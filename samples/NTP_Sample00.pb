  IncludeFile "RNet.pb"
  RNet_Init()
  InitNetwork()
  
  Debug "===================================================NTP"
  
  RNet_Create(1, #RNet_Type_NTP)
    Test = OpenNetworkConnection("ntp2.cines.fr", 123)
    Repeat
      If NetworkClientEvent(Test) = #PB_NetworkEvent_Data 
        Buf   = AllocateMemory(1024)
        Res   = ReceiveNetworkData(Test, Buf,1024)
        Debug Trim(PeekS(Buf))
      EndIf
    Until Main = #True
    
    
    CloseNetworkConnection(Test)
  RNet_Free(1)
  
  
  ;/ Récupération Heure depuis Serveur NTP
; Droopy 15/01/06 22H28 et 22secondes  Heure NTP :)
; PureBasic 3.94

InitNetwork()
CnxionId= OpenNetworkConnection("time.nist.gov",37) ; time.nist.gov / ntp1.fau.de
Debug CnxionId
If CnxionId
  Debug ""
  ;/ Attends que le serveur envoie des data
  While NetworkClientEvent(CnxionId)=0
    Delay(1)
  Wend
 Debug ""
  ;/ Réception des 4 octets
  Buffer.s=Space(4)
  ReceiveNetworkData(CnxionId,@Buffer,4)
  CloseNetworkConnection(CnxionId)
 
  ;/ Calcule l'heure
  NTPTime=Asc(Left(Buffer,1))*255*255*255 + Asc(Mid(Buffer,2,1))*255*255 + Asc(Mid(Buffer,3,1))*255 + Asc(Right(Buffer,1)) + 2125010696
   
  ;/ Affiche l'heure
  MessageRequester("NTP",FormatDate(" %dd/%mm/%yy %hh:%ii:%ss",NTPTime))
EndIf
; IDE Options = PureBasic 4.10 (Windows - x86)
; CursorPosition = 45
; FirstLine = 2
; Folding = -