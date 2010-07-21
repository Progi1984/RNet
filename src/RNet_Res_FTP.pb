  Enumeration 1 ; RNet_FTP_Mode
    #RNet_FTP_Mode_Ascii
    #RNet_FTP_Mode_Binary
  EndEnumeration
  Structure S_RNet_FTP
    Connexion.l
    Server.s
    Port.l
    Login.s
    Password.s
    
    Connexion_PASV.l
    ListingDir.s
    ListingEntry.l
    
    DataMem.l
    DataLen.l
  EndStructure
