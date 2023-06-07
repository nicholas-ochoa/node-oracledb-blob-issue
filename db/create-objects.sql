--
-- create type
--

create or replace type blob_issue.qmsg_attachment as object (
  status              varchar2(128),
  message             varchar2(4000),
  file_id             varchar2(26),
  created             date,
  filename            varchar2(1024),
  filesize            number,
  mimetype            varchar2(512),
  data                blob,
  orderid             number,
  shipid              number,
  lastuser            varchar2(32),
  lastupdate          date,
  nameid              varchar2(32),
  session_id          varchar2(64)
);
/

begin
  --
  -- create queue table
  --

  dbms_aqadm.create_queue_table(
    queue_table         => 'BLOB_ISSUE.QT_RP_ATTACHMENT',
    sort_list           => 'PRIORITY,ENQ_TIME',
    queue_payload_type  => 'BLOB_ISSUE.QMSG_ATTACHMENT'
  );

  --
  -- create queue
  --

  dbms_aqadm.create_queue(
    queue_table     => 'BLOB_ISSUE.QT_RP_ATTACHMENT',
    queue_name      => 'BLOB_ISSUE.ATTACHMENT'
  );

  --
  -- enable queue
  --

  dbms_aqadm.start_queue(queue_name => 'BLOB_ISSUE.ATTACHMENT');
end;
/

show errors;

exit;
