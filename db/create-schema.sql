whenever sqlerror continue
whenever oserror continue

set verify off;

alter profile default limit
  failed_login_attempts unlimited
  password_life_time unlimited;

create user blob_issue
  identified by blob_issue
  default tablespace users
  temporary tablespace temp
  profile default
  account unlock;

alter user blob_issue default role all;
alter user blob_issue quota unlimited on users;

grant
  connect,
  resource,
  select_catalog_role,
  aq_administrator_role
to blob_issue;

grant
  create type,
  create view,
  create table,
  select any table,
  drop public synonym,
  create public synonym,
  execute any procedure,
  create sequence,
  create database link,
  create any directory,
  drop any directory,
  debug connect session,
  debug any procedure,
  create any job,
  manage scheduler,
  create trigger,
  create procedure
to blob_issue;

grant execute on sys.aq$_agent to blob_issue with grant option;
grant execute on sys.aq$_dequeue_history to blob_issue with grant option;
grant execute on sys.aq$_dequeue_history_t to blob_issue with grant option;
grant execute on sys.aq$_history to blob_issue with grant option;
grant execute on sys.aq$_notify_msg to blob_issue with grant option;
grant execute on sys.aq$_recipients to blob_issue with grant option;
grant execute on sys.aq$_subscribers to blob_issue with grant option;

grant execute on sys.dbms_aq to blob_issue;

exit;
