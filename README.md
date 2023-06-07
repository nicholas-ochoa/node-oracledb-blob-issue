Overview
---
This repo contains two test scripts that reproduce an issue I started experiencing with the node-oracledb driver beginning with version `6.0.0`. When attempting to retrieve data from a `BLOB` on a queue message payload, an exception is encountered in the node-oracledb code that prevents the data from loading. This example shows how the same code worked previously on `5.5.0`.

Tested using Node.js 18.16.0 on Windows 11 against an Oracle 19c database.


Setup
---
To set up the environment, run the following scripts in the `db` folder (in order):

1. `create-schema.sql` (run this as `sysdba` to create the `blob_issue` schema used for this test)
2. `create-objects.sql` - Creates the supporting objects/types/queues
3. `create-proc.sql` - Create the `upload_test` procedure used to send messages to the queue.

Next, run `npm install` in the `5.5.0` directory, and then again in the `6.0.1` directory.


Testing
---
From the root directory of the repo run: `CONNECT_STRING="customer_db/test" node ./5.5.0/index.js` to start the queue listener test using `v5.5.0` of the node-oracledb driver. Replace `customer_db/test` with a valid connection string for your database.

After the listener is running, from SQL developer or SQL Plus you will then need to run the `db/send_msg.sql` script to send a test message to the queue.

You should get output similar to this:

```bash
nicholas on work-desktop in /c/git/blob-issue
$ CONNECT_STRING="customer_db/test" node ./5.5.0/index.js
testing with node-oracledb 5.5.0
--------------------------------
waiting for a message...
SUCCESS {
  filename: 'test-file.png',
  filesize: 101,
  mimetype: 'image/png',
  data: <Buffer 89 50 4e 47 0d 0a 1a 0a 00 00 00 0d 49 48 44 52 00 00 00 20 00 00 00 20 08 06 00 00 00 73 7a 7a f4 00 00 00 2c 49 44 41 54 78 da ed ce 31 01 00 00 0c ... 51 more bytes>,
  orderid: null,
  shipid: null,
  nameid: 'TESTUSER',
  session_id: '1809306'
}
--------------------------------
completed
```

Repeat with the `v6.0.1` test `CONNECT_STRING="customer_db/test" node ./6.0.1/index.js`:

```bash
nicholas on work-desktop in /c/git/blob-issue
$ CONNECT_STRING="customer_db/test" node ./6.0.1/index.js
testing with node-oracledb 6.0.1
--------------------------------
waiting for a message...
ERROR: Could not retrieve upload payload data {
  name: 'TypeError',
  message: "Cannot read properties of undefined (reading '_parentObj')",
  cause: undefined,
  stack: "TypeError: Cannot read properties of undefined (reading '_parentObj')\n" +
    '    at LobImpl._getConnImpl (C:\\git\\blob-issue\\6.0.1\\node_modules\\oracledb\\lib\\impl\\lob.js:43:29)\n' +
    '    at Lob.<anonymous> (C:\\git\\blob-issue\\6.0.1\\node_modules\\oracledb\\lib\\util.js:154:29)\n' +
    '    at Lob.<anonymous> (C:\\git\\blob-issue\\6.0.1\\node_modules\\oracledb\\lib\\util.js:176:25)\n' +
    '    at Lob.wrapper (C:\\git\\blob-issue\\6.0.1\\node_modules\\oracledb\\lib\\util.js:123:19)\n' +
    '    at main (C:\\git\\blob-issue\\6.0.1\\index.js:42:31)'
}
--------------------------------
completed
```


Notes:
---
The `BLOB` payload in the `send_msg.sql` script is just a 32x32 pixel PNG file.
