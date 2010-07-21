
  Procedure.l RNet_Mail_ExamineMessage(*Mail.S_RNet_Mail, Type.l, Msg.s)
    With *Mail
      Protected Content.s, LastPart_1.s, Part_1.s, Part_2.s, Inc.l, IncBis.l, InHeader.l = #True
      ;{ Init
      \Infos_return_path  = ""
      \Infos_delivered_to = ""
      \Infos_received     = ""
      \Infos_x_sender     = ""
      \Infos_x_mailer     = ""
      \Infos_x_user       = ""
      \Infos_x_script     = ""
      \Infos_date         = ""
      \Infos_from         = ""
      \Infos_bcc          = ""
      \Infos_subject      = ""
      \Infos_x_proxad_sc  = ""
      \Infos_x_spam_checker_version = ""
      \Infos_x_spam_level = ""
      \Infos_x_spam_status= ""
      \Infos_to           = ""
      \Infos_reply_to     = ""
      \Infos_x_auth_smtp_user = ""
      \Infos_x_abuse_contact = ""
      \Infos_mime_version = ""
      \Infos_content_type = ""
      \Infos_message_id   = ""
      \Infos_domainkey_signature = ""
      \Infos_organization = ""
      \Infos_x_priority   = ""
      \Infos_user_agent   = ""
      \Infos_thread_topic = ""
      \Infos_thread_index = ""
      \Infos_x_emv_campagneid = ""
      \Infos_x_emv_memberid = ""
      \Infos_path = ""                    
      \Infos_newsgroups = ""              
      \Infos_references = ""              
      \Infos_content_transfer_encoding = ""
      \Infos_lines = ""                   
      \Infos_nntp_posting_date = ""       
      \Infos_nntp_posting_host = ""       
      \Infos_x_trace = ""                 
      \Infos_x_complaints_to            = ""         
      \Infos_xref                       = ""                    
      \Infos_Body                       = ""
      ;}
      For Inc = 0 To CountString(Msg, Chr(13)+Chr(10))-1
        Content = StringField(Msg, Inc +1, Chr(13)+Chr(10))
        Content = RemoveString(Content, Chr(10))
        If InHeader = #True
          Part_1  = LCase(Trim(StringField(Content, 1, ":")))
          Part_2  = Trim(Right(Content, Len(Content)-Len(Part_1)-1))
          If Part_1 <> "return-path" And Part_1 <> "delivered-to" And Part_1 <> "received" And Part_1 <> "x-sender" And Part_1 <> "x-mailer" 
            If Part_1 <> "x-user" And Part_1 <> "x-script" And Part_1 <> "date" And Part_1 <> "from" And Part_1 <> "bcc" And Part_1 <> "subject" 
              If Part_1 <> "x-proxad-sc" And Part_1 <> "x-spam-checker-version" And Part_1 <> "x-spam-level" And Part_1 <> "x-spam-status"
                If Part_1 <> "to" And Part_1 <> "reply-to" And Part_1 <> "x-auth-smtp-user" And Part_1 <> "x-abuse-contact" And Part_1 <> "mime-version"
                  If Part_1 <> "content-type" And Part_1 <> "message-id" And Part_1 <> "domainkey-signature" And Part_1 <> "organization"
                    If Part_1 <> "x-priority" And Part_1 <> "user-agent" And Part_1 <> "thread-topic" And Part_1 <> "thread-index" And Part_1 <> "x-emv-campagneid"
                      If Part_1 <> "x-emv-memberid" And Part_1 <> "path" And Part_1 <> "newsgroups" And Part_1 <> "references" And Part_1 <> "content-transfer-encoding"
                        If Part_1 <> "lines" And Part_1 <> "nntp-posting-date" And Part_1 <> "nntp-posting-host" And Part_1 <> "x-trace" And Part_1 <> "x-complaints-to"
                          If Part_1 <> "xref" And Part_1 <> ""
                            Debug "RNet_Mail_ExamineMessage >" +Part_1
                            Part_1 = LastPart_1
                            Part_2 = Content
                          EndIf
                        EndIf
                      EndIf
                    EndIf
                  EndIf
                EndIf
              EndIf
            EndIf
          EndIf
          Select Part_1
            Case "return-path"              :If \Infos_return_path = ""             : \Infos_return_path = Part_2             :Else: \Infos_return_path + Part_2             :EndIf
            Case "delivered-to"             :If \Infos_delivered_to = ""            : \Infos_delivered_to = Part_2            :Else: \Infos_delivered_to + Part_2            :EndIf
            Case "received"                 :If \Infos_received = ""                : \Infos_received = Part_2                :Else: \Infos_received + Part_2                :EndIf
            Case "x-sender"                 :If \Infos_x_sender = ""                : \Infos_x_sender = Part_2                :Else: \Infos_x_sender + Part_2                :EndIf
            Case "x-mailer"                 :If \Infos_x_mailer = ""                : \Infos_x_mailer = Part_2                :Else: \Infos_x_mailer + Part_2                :EndIf
            Case "x-user"                   :If \Infos_x_user = ""                  : \Infos_x_user = Part_2                  :Else: \Infos_x_user + Part_2                  :EndIf
            Case "x-script"                 :If \Infos_x_script = ""                : \Infos_x_script = Part_2                :Else: \Infos_x_script + Part_2                :EndIf
            Case "date"                     :If \Infos_date = ""                    : \Infos_date = Part_2                    :Else: \Infos_date + Part_2                    :EndIf
            Case "from"                     :If \Infos_from = ""                    : \Infos_from = Part_2                    :Else: \Infos_from + Part_2                    :EndIf
            Case "bcc"                      :If \Infos_bcc = ""                     : \Infos_bcc = Part_2                     :Else: \Infos_bcc + Part_2                     :EndIf
            Case "subject"                  :If \Infos_subject = ""                 : \Infos_subject = Part_2                 :Else: \Infos_subject + Part_2                 :EndIf
            Case "x-proxad-sc"              :If \Infos_x_proxad_sc = ""             : \Infos_x_proxad_sc = Part_2             :Else: \Infos_x_proxad_sc + Part_2             :EndIf
            Case "x-spam-checker-version"   :If \Infos_x_spam_checker_version = ""  : \Infos_x_spam_checker_version = Part_2  :Else: \Infos_x_spam_checker_version + Part_2  :EndIf
            Case "x-spam-level"             :If \Infos_x_spam_level = ""            : \Infos_x_spam_level = Part_2            :Else: \Infos_x_spam_level + Part_2            :EndIf
            Case "x-spam-status"            :If \Infos_x_spam_status = ""           : \Infos_x_spam_status = Part_2           :Else: \Infos_x_spam_status + Part_2           :EndIf
            Case "to"                       :If \Infos_to = ""                      : \Infos_to = Part_2                      :Else: \Infos_to + Part_2                      :EndIf
            Case "reply-to"                 :If \Infos_reply_to = ""                : \Infos_reply_to = Part_2                :Else: \Infos_reply_to + Part_2                :EndIf
            Case "x-auth-smtp-user"         :If \Infos_x_auth_smtp_user = ""        : \Infos_x_auth_smtp_user = Part_2        :Else: \Infos_x_auth_smtp_user + Part_2        :EndIf
            Case "x-abuse-contact"          :If \Infos_x_abuse_contact = ""         : \Infos_x_abuse_contact = Part_2         :Else: \Infos_x_abuse_contact + Part_2         :EndIf
            Case "mime-version"             :If \Infos_mime_version = ""            : \Infos_mime_version = Part_2            :Else: \Infos_mime_version + Part_2            :EndIf
            Case "content-type"             :If \Infos_content_type = ""            : \Infos_content_type = Part_2            :Else: \Infos_content_type + Part_2            :EndIf
            Case "message-id"               :If \Infos_message_id = ""              : \Infos_message_id = Part_2              :Else: \Infos_message_id + Part_2              :EndIf
            Case "domainkey-signature"      :If \Infos_domainkey_signature = ""     : \Infos_domainkey_signature = Part_2     :Else: \Infos_domainkey_signature + Part_2     :EndIf
            Case "organization"             :If \Infos_organization = ""            : \Infos_organization = Part_2            :Else: \Infos_organization + Part_2            :EndIf
            Case "x-priority"               :If \Infos_x_priority = ""              : \Infos_x_priority = Part_2              :Else: \Infos_x_priority + Part_2              :EndIf
            Case "user-agent"               :If \Infos_user_agent = ""              : \Infos_user_agent = Part_2              :Else: \Infos_user_agent + Part_2              :EndIf
            Case "thread-topic"             :If \Infos_thread_topic = ""            : \Infos_thread_topic = Part_2            :Else: \Infos_thread_topic + Part_2            :EndIf
            Case "thread-index"             :If \Infos_thread_index = ""            : \Infos_thread_index = Part_2            :Else: \Infos_thread_index + Part_2            :EndIf
            Case "x-emv-campagneid"         :If \Infos_x_emv_campagneid = ""        : \Infos_x_emv_campagneid = Part_2        :Else: \Infos_x_emv_campagneid + Part_2        :EndIf
            Case "x-emv-memberid"           :If \Infos_x_emv_memberid = ""          : \Infos_x_emv_memberid = Part_2          :Else: \Infos_x_emv_memberid + Part_2          :EndIf
            Case "path"                     :If \Infos_path = ""                    : \Infos_path = Part_2                    :Else: \Infos_path + Part_2                    :EndIf
            Case "newsgroups"               :If \Infos_newsgroups = ""              : \Infos_newsgroups = Part_2              :Else: \Infos_newsgroups + Part_2              :EndIf
            Case "references"               :If \Infos_references = ""              : \Infos_references = Part_2              :Else: \Infos_references + Part_2              :EndIf
            Case "content-transfer-encoding":If \Infos_content_transfer_encoding = "": \Infos_content_transfer_encoding = Part_2:Else: \Infos_content_transfer_encoding + Part_2:EndIf
            Case "lines"                    :If \Infos_lines = ""                   : \Infos_lines = Part_2                   :Else: \Infos_lines + Part_2                   :EndIf
            Case "nntp-posting-date"        :If \Infos_nntp_posting_date = ""       : \Infos_nntp_posting_date = Part_2       :Else: \Infos_nntp_posting_date + Part_2       :EndIf
            Case "nntp-posting-host"        :If \Infos_nntp_posting_host = ""       : \Infos_nntp_posting_host = Part_2       :Else: \Infos_nntp_posting_host + Part_2       :EndIf
            Case "x-trace"                  :If \Infos_x_trace = ""                 : \Infos_x_trace = Part_2                 :Else: \Infos_x_trace + Part_2                 :EndIf
            Case "x-complaints-to"          :If \Infos_x_complaints_to = ""         : \Infos_x_complaints_to = Part_2         :Else: \Infos_x_complaints_to + Part_2         :EndIf
            Case "xref"                     :If \Infos_xref = ""                    : \Infos_xref = Part_2                    :Else: \Infos_xref + Part_2                    :EndIf
            Case ""                         :Stop = Inc : InHeader = #False                                                      
            Default
              Debug "RNet_Mail_ExamineMessage >>"+Part_1
          EndSelect
          LastPart_1 = Part_1
        EndIf
      Next
      For Inc = 0 To Stop-1
        Content = StringField(Msg, Inc+1, Chr(13))
        Part + Len(Content)+1
      Next
      \Infos_Body = Right(Msg, Len(Msg)-Part)
      While Left(\Infos_Body,1) = Chr(13) Or Left(\Infos_Body,1) = Chr(10) 
        \Infos_Body = Right(\Infos_Body, Len(\Infos_Body)-1)
      Wend
    EndWith
    ProcedureReturn #True
  EndProcedure
  Procedure.s RNet_Mail_GetAttribute(*Mail.S_RNet_Mail, Attribute.l)
    With *Mail
      Select Attribute
        Case #RNet_Mail_Attribute_ReturnPath         : ProcedureReturn \Infos_return_path
        Case #RNet_Mail_Attribute_Deliveredto        : ProcedureReturn \Infos_delivered_to
        Case #RNet_Mail_Attribute_Received           : ProcedureReturn \Infos_received
        Case #RNet_Mail_Attribute_XSender            : ProcedureReturn \Infos_x_sender
        Case #RNet_Mail_Attribute_XMailer            : ProcedureReturn \Infos_x_mailer
        Case #RNet_Mail_Attribute_XUser              : ProcedureReturn \Infos_x_user
        Case #RNet_Mail_Attribute_XScript            : ProcedureReturn \Infos_x_script
        Case #RNet_Mail_Attribute_Date               : ProcedureReturn \Infos_date
        Case #RNet_Mail_Attribute_From               : ProcedureReturn \Infos_from
        Case #RNet_Mail_Attribute_BCC                : ProcedureReturn \Infos_bcc
        Case #RNet_Mail_Attribute_Subject            : ProcedureReturn \Infos_subject
        Case #RNet_Mail_Attribute_XProxadSc          : ProcedureReturn \Infos_x_proxad_sc
        Case #RNet_Mail_Attribute_XSpamCheckerVersion: ProcedureReturn \Infos_x_spam_checker_version
        Case #RNet_Mail_Attribute_XSpamLevel         : ProcedureReturn \Infos_x_spam_level    
        Case #RNet_Mail_Attribute_XSpamStatus        : ProcedureReturn \Infos_x_spam_status   
        Case #RNet_Mail_Attribute_To                 : ProcedureReturn \Infos_to              
        Case #RNet_Mail_Attribute_ReplyTo            : ProcedureReturn \Infos_reply_to        
        Case #RNet_Mail_Attribute_XAuthSmtpUser      : ProcedureReturn \Infos_x_auth_smtp_user
        Case #RNet_Mail_Attribute_XAbuseContact      : ProcedureReturn \Infos_x_abuse_contact 
        Case #RNet_Mail_Attribute_MimeVersion        : ProcedureReturn \Infos_mime_version    
        Case #RNet_Mail_Attribute_ContentType        : ProcedureReturn \Infos_content_type    
        Case #RNet_Mail_Attribute_MessageId          : ProcedureReturn \Infos_message_id      
        Case #RNet_Mail_Attribute_DomainkeySignature : ProcedureReturn \Infos_domainkey_signature
        Case #RNet_Mail_Attribute_Organization       : ProcedureReturn \Infos_organization    
        Case #RNet_Mail_Attribute_XPriority          : ProcedureReturn \Infos_x_priority    
        Case #RNet_Mail_Attribute_UserAgent          : ProcedureReturn \Infos_user_agent    
        Case #RNet_Mail_Attribute_ThreadTopic        : ProcedureReturn \Infos_thread_topic  
        Case #RNet_Mail_Attribute_ThreadIndex        : ProcedureReturn \Infos_thread_index  
        Case #RNet_Mail_Attribute_XEmvCampagneid     : ProcedureReturn \Infos_x_emv_campagneid
        Case #RNet_Mail_Attribute_XEmvMemberid       : ProcedureReturn \Infos_x_emv_memberid
        Default : ProcedureReturn ""                         
      EndSelect
    EndWith
    ProcedureReturn ""
  EndProcedure
  Procedure.s RNet_Mail_GetBody(*Mail.S_RNet_Mail)
    With *Mail
      ProcedureReturn \Infos_Body
    EndWith
    ProcedureReturn ""
  EndProcedure
  Procedure.l RNet_Mail_SetAttribute(*Mail.S_RNet_Mail, Attribute.l, Content.s)
    With *Mail
      Select Attribute
        Case #RNet_Mail_Attribute_ReturnPath         : \Infos_return_path = Content
        Case #RNet_Mail_Attribute_Deliveredto        : \Infos_delivered_to = Content
        Case #RNet_Mail_Attribute_Received           : \Infos_received = Content
        Case #RNet_Mail_Attribute_XSender            : \Infos_x_sender = Content
        Case #RNet_Mail_Attribute_XMailer            : \Infos_x_mailer = Content
        Case #RNet_Mail_Attribute_XUser              : \Infos_x_user = Content
        Case #RNet_Mail_Attribute_XScript            : \Infos_x_script = Content
        Case #RNet_Mail_Attribute_Date               : \Infos_date = Content
        Case #RNet_Mail_Attribute_From               : \Infos_from = Content
        Case #RNet_Mail_Attribute_BCC                : \Infos_bcc = Content
        Case #RNet_Mail_Attribute_Subject            : \Infos_subject = Content
        Case #RNet_Mail_Attribute_XProxadSc          : \Infos_x_proxad_sc = Content
        Case #RNet_Mail_Attribute_XSpamCheckerVersion: \Infos_x_spam_checker_version = Content
        Case #RNet_Mail_Attribute_XSpamLevel         : \Infos_x_spam_level = Content
        Case #RNet_Mail_Attribute_XSpamStatus        : \Infos_x_spam_status = Content
        Case #RNet_Mail_Attribute_To                 : \Infos_to = Content
        Case #RNet_Mail_Attribute_ReplyTo            : \Infos_reply_to = Content
        Case #RNet_Mail_Attribute_XAuthSmtpUser      : \Infos_x_auth_smtp_user = Content
        Case #RNet_Mail_Attribute_XAbuseContact      : \Infos_x_abuse_contact = Content
        Case #RNet_Mail_Attribute_MimeVersion        : \Infos_mime_version = Content
        Case #RNet_Mail_Attribute_ContentType        : \Infos_content_type = Content
        Case #RNet_Mail_Attribute_MessageId          : \Infos_message_id = Content
        Case #RNet_Mail_Attribute_DomainkeySignature : \Infos_domainkey_signature = Content
        Case #RNet_Mail_Attribute_Organization       : \Infos_organization = Content
        Case #RNet_Mail_Attribute_XPriority          : \Infos_x_priority = Content
        Case #RNet_Mail_Attribute_UserAgent          : \Infos_user_agent = Content
        Case #RNet_Mail_Attribute_ThreadTopic        : \Infos_thread_topic = Content
        Case #RNet_Mail_Attribute_ThreadIndex        : \Infos_thread_index = Content
        Case #RNet_Mail_Attribute_XEmvCampagneid     : \Infos_x_emv_campagneid = Content
        Case #RNet_Mail_Attribute_XEmvMemberid       : \Infos_x_emv_memberid = Content
        Default : ProcedureReturn #False                         
      EndSelect
    EndWith
    ProcedureReturn #True
  EndProcedure
  Procedure.l RNet_Mail_ResetAttribute(*Mail.S_RNet_Mail)
    With *Mail
      \Infos_return_path = ""
      \Infos_delivered_to = ""
      \Infos_received = ""
      \Infos_x_sender = ""
      \Infos_x_mailer = ""
      \Infos_x_user = ""
      \Infos_x_script = ""
      \Infos_date = ""
      \Infos_from = ""
      \Infos_bcc = ""
      \Infos_subject = ""
      \Infos_x_proxad_sc = ""
      \Infos_x_spam_checker_version = ""
      \Infos_x_spam_level = ""
      \Infos_x_spam_status = ""
      \Infos_to = ""
      \Infos_reply_to = ""
      \Infos_x_auth_smtp_user = ""
      \Infos_x_abuse_contact = ""
      \Infos_mime_version = ""
      \Infos_content_type = ""
      \Infos_message_id = ""
      \Infos_domainkey_signature = ""
      \Infos_organization = ""
      \Infos_x_priority = ""
      \Infos_user_agent = ""
      \Infos_thread_topic = ""
      \Infos_thread_index = ""
      \Infos_x_emv_campagneid = ""
      \Infos_x_emv_memberid = ""
    EndWith
  EndProcedure
  
; IDE Options = PureBasic 4.20 (Windows - x86)
; CursorPosition = 237
; FirstLine = 35
; Folding = AAAAAAAAAK+-