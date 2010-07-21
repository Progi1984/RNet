  IncludeFile "RNet.pb"
  RNet_Init()
  InitNetwork()
  
  Debug "===================================================1"
  
  RNet_Create(1, #RNet_Type_FTP)
  RNet_FTP_Connect(1, "ftpperso.free.fr", 21, "progi1984", "oneill")
  ;RNet_FTP_Connect(1, "192.168.14.23", 21, "root", "asfpmo")
    Debug "---Misc"
    Debug RNet_FTP_GetCurrentDirectory(1)
    Debug RNet_FTP_SetCurrentDirectory(1, "/")
    Debug RNet_FTP_GetCurrentDirectory(1)
    Debug "---File System"
    Debug RNet_FTP_ExamineDirectory(1)
    Repeat
      Name.s = RNet_FTP_DirectoryEntryName(1)
      Date.s = FormatDate("%dd/%mm/%yyyy %hh:%mm:%ss", RNet_FTP_DirectoryEntryDate(1))
      Size.s = Str(RNet_FTP_DirectoryEntrySize(1))
      If RNet_FTP_DirectoryEntryType(1) = #PB_DirectoryEntry_File
        Debug "[FILE]"+Space(9)+ Name + Space(30-Len(Name)) + Date + Space(30-Len(Date)) + Size+" bytes"
      Else
        Debug "[DIR] "+Space(9)+ Name + Space(30-Len(Name)) + Date + Space(30-Len(Date))
      EndIf
    Until RNet_FTP_NextDirectoryEntry(1) = 0
    Debug "---Directory"
    Debug RNet_FTP_CreateDirectory(1, "TestRNet")
    Debug RNet_FTP_SetCurrentDirectory(1, "/TestRNet")
    Debug RNet_FTP_GetCurrentDirectory(1)
    Debug RNet_FTP_DeleteDirectory(1, "TestRNet")
    Debug RNet_FTP_DeleteDirectory(1, "TestRNet2")
    Debug RNet_FTP_CreateDirectory(1, "TestRNet")
    Debug "---Download File"
    Debug RNet_FTP_Download(1, "/403_fr.php", "E:\Mes projets\PB_Userlibs\RNet\SRC\Samples\403_fr.php")
    Debug RNet_FTP_Download(1, "/images/app_html.png", "E:\Mes projets\PB_Userlibs\RNet\SRC\Samples\app_html.png")
    Debug "---Upload File"
    Debug RNet_FTP_Upload(1, "/TestRNet/", "E:\Mes projets\PB_Userlibs\RNet\SRC\Samples\403_fr.php")
    Debug RNet_FTP_SetCurrentDirectory(1, "/")
    Debug "---Rename File"
    Debug RNet_FTP_RenameFile(1, "/TestRNet/403_fr.php", "/TestRNet/file.php")
    Debug "---Rename Dir"
    Debug RNet_FTP_RenameFile(1, "TestRNet", "TestRNet2")
  
    Debug RNet_FTP_GetSystem(1)
    Debug RNet_FTP_GetStatus(1)
    Debug RNet_FTP_GetHelp(1)
    Debug RNet_FTP_NoOperation(1)
  RNet_FTP_Disconnect(1)
  RNet_Free(1)
 
; IDE Options = PureBasic 4.20 (Windows - x86)
; CursorPosition = 34
; FirstLine = 5
; Folding = -