  Structure S_RNet_IMAP
    Connexion.l
    Server.s
    Port.l
    Login.s
    Password.s
    CmdLastAnswer.s
    CmdId.l
    
    DirInfos.s
    Dir_MessagesAll.l
    Dir_MessagesRecent.l
    Dir_MessagesUnseen.l
    Dir_UIDValidity.l
    Dir_UIDNext.l
    Dir_Flags.s
    Dir_PermanentFlags.s

    Msg.s
    MsgSize.l
    *Mail.S_RNet_Mail
  EndStructure
