set serveroutput on
declare
  l_filename         varchar2(1024)  := 'test-file.png';
  l_filesize         number          := 187647;
  l_mimetype         varchar2(512)   := 'image/png';
  l_data             blob;
  l_orderid          number          := null;
  l_shipid           number          := null;
  l_nameid           varchar2(32)    := 'TESTUSER';
  l_session_id       varchar2(64)    := sys_context('USERENV','SESSIONID');

  l_out_status       varchar2(128);
  l_out_message      varchar2(128);
  l_out_id           number;
  l_out_file_id      varchar2(128);

begin
  dbms_output.put_line('------------------------------------------------------------------------');

  -- 32x32px PNG
  l_data := to_blob('89504E470D0A1A0A0000000D4948445200000020000000200806000000737A7AF40000002C4944415478DAEDCE310100000C02A0D93FB48BE1030948AFBDA1080808080808080808080808080808AC030F5B955FC1717E21B90000000049454E44AE426082');

  dbms_output.put_line(chr(9) || 'filename:   ' || nvl(l_filename, '-'));
  dbms_output.put_line(chr(9) || 'mimetype:   ' || nvl(l_mimetype, '-'));
  dbms_output.put_line(chr(9) || 'orderid:    ' || nvl(l_orderid, 0));
  dbms_output.put_line(chr(9) || 'shipid:     ' || nvl(l_shipid, 0));
  dbms_output.put_line(chr(9) || 'nameid:     ' || nvl(l_nameid, '-'));
  dbms_output.put_line(chr(9) || 'session_id: ' || nvl(l_session_id, '-') || chr(10) || chr(10));

  upload_test(
    in_filename   => l_filename,
    in_mimetype   => l_mimetype,
    in_data       => l_data,
    in_orderid    => l_orderid,
    in_shipid     => l_shipid,
    in_nameid     => l_nameid,
    in_session_id => l_session_id,
    out_status    => l_out_status,
    out_message   => l_out_message,
    out_file_id   => l_out_file_id
  );

  dbms_output.put_line(chr(9) || 'status:  ' || nvl(l_out_status, '-'));
  dbms_output.put_line(chr(9) || 'message: ' || nvl(l_out_message, '-'));
  dbms_output.put_line(chr(9) || 'file_id: ' || l_out_file_id || chr(10) || chr(10));

  dbms_output.put_line('------------------------------------------------------------------------');
end;
/
