let mysql = require("mysql");

 const db = mysql.createConnection({
    user: "root",
    host: "localhost",
    password: "1234567890",
    database: "solar_lightDB5",
  });


  exports.db = db;

  