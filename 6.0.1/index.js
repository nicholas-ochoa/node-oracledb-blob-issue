const OracleDB = require("oracledb");

async function main() {
  console.log('testing with node-oracledb 6.0.1');
  console.log('--------------------------------');

  OracleDB.initOracleClient();

  OracleDB.outFormat = OracleDB.OUT_FORMAT_OBJECT;
  OracleDB.fetchAsString = [OracleDB.CLOB];
  OracleDB.fetchAsBuffer = [OracleDB.BLOB];

  OracleDB.extendedMetaData = true;

  const connectString = process.env.CONNECT_STRING ?? 'localhost:1521/test';

  const pool = await OracleDB.createPool({
    user: "blob_issue",
    password: "blob_issue",
    connectString,
  });

  const conn = await OracleDB.getConnection();

  const queue = await conn.getQueue("ATTACHMENT", {
    payloadType: "QMSG_ATTACHMENT",
  });

  queue.deqOptions.correlation = "UPLOAD";
  queue.deqOptions.navigation = OracleDB.AQ_DEQ_NAV_FIRST_MSG;
  queue.deqOptions.mode = OracleDB.AQ_DEQ_MODE_REMOVE;
  queue.deqOptions.wait = OracleDB.AQ_DEQ_WAIT_FOREVER;

  console.log('waiting for a message...');

  const message = await queue.deqOne();
  const payload = message.payload;

  let data = null;

  try {
    data = await payload.DATA.getData();
  } catch (err) {
    console.error("ERROR: Could not retrieve upload payload data", {
      name: err.name,
      message: err.message,
      cause: err.cause,
      stack: err.stack,
    });
  }

  if (data) {
    console.log('SUCCESS', {
      filename: payload.FILENAME,
      filesize: payload.FILESIZE,
      mimetype: payload.MIMETYPE,
      data,
      orderid: payload.ORDERID,
      shipid: payload.SHIPID,
      nameid: payload.NAMEID,
      session_id: payload.SESSION_ID,
    });
  }

  await conn.commit();

  await conn.close();
  await pool.close();

  console.log('--------------------------------');
  console.log('completed');
}

main();
