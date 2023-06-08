create or replace procedure blob_issue.upload_test (
  in_filename                     in  varchar2,
  in_mimetype                     in  varchar2  := null,
  in_data                         in  blob,
  in_orderid                      in  number    := null,
  in_shipid                       in  number    := null,
  in_nameid                       in  varchar2,
  in_session_id                   in  varchar2  := null,
  out_status                      out varchar2,
  out_message                     out varchar2,
  out_file_id                     out varchar2
) as

  l_req                          qmsg_attachment;
  l_res                          qmsg_attachment;
  l_enqueue_message_properties   dbms_aq.message_properties_t;
  l_dequeue_message_properties   dbms_aq.message_properties_t;
  l_enqueue_options              dbms_aq.enqueue_options_t;
  l_dequeue_options              dbms_aq.dequeue_options_t;
  l_msgid                        raw(16);
  l_session_id                   varchar2(128) := nvl(in_session_id, sys_context('USERENV', 'SESSIONID'));

begin
  -- send message to queue
  l_req := qmsg_attachment(
    status     => null,
    message    => null,
    file_id    => null,
    created    => null,
    filename   => in_filename,
    filesize   => dbms_lob.getlength(in_data),
    mimetype   => in_mimetype,
    data       => in_data,
    orderid    => in_orderid,
    shipid     => in_shipid,
    lastuser   => null,
    lastupdate => null,
    nameid     => in_nameid,
    session_id => l_session_id
  );

  l_enqueue_message_properties.priority := 1;
  l_enqueue_message_properties.correlation := 'UPLOAD';
  l_enqueue_message_properties.expiration := 120;

  dbms_aq.enqueue(
    queue_name         => 'blob_issue.attachment',
    message_properties => l_enqueue_message_properties,
    enqueue_options    => l_enqueue_options,
    payload            => l_req,
    msgid              => l_msgid
  );

  commit;

exception
  when others then
    out_status  := 'ERROR';

    if sqlcode = -25228 then
      out_message := 'Timeout occured when attempting to upload attachment data';
    else
      out_message := sqlerrm;
    end if;

end upload_test;
/
