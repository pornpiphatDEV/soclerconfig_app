let mysql = require("mysql");

 const log_db = mysql.createConnection({
    user: "root",
    host: "localhost",
    password: "1234567890",
    database: "logsystem_solarlightDB",
  });


  exports.log_db = log_db;
