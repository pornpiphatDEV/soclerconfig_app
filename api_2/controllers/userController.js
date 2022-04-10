let express = require("express");
let mysql = require("mysql");
let db = require("../config/config").db;
let decode = require("../lib/DecodeSolar");

let jwt = require("jsonwebtoken");
let passport = require("passport");
let LogModel = require('../model/logmodel');

module.exports.insert = (req, res) => {
  const obj = JSON.parse(decode.hex_to_ascii(req.body.api_token));
  console.log(obj);

  Voltsolar = obj.Voltsolar;
  Voltbattery = obj.Voltbattery;
  VoltLED = obj.VoltLED;
  temperature = obj.temperature;
  humidity = obj.humidity;
  temperatureCPU = obj.temperatureCPU;
  light = obj.light;

  db.query(
    "insert into dbr_solar(volt_solar,volt_battery,volt_led ,temperature,humidity,temperatureCPU,light) values(?,?,?,?,?,?,?)",
    [
      Voltsolar,
      Voltbattery,
      VoltLED,
      temperature,
      humidity,
      temperatureCPU,
      light,
    ],

    (err, result) => {
      if (err) {
        console.log(err);
      } else {
        res.send("Values inserted");
      }
    }
  );
};

module.exports.sigin = async (req, res) => {
  let username = req.body.username;
  let password = req.body.password;
  let email = req.body.email;
  let mobile_phone = req.body.mobile_phone;

  console.log(req.body);

  db.query(
    "insert into users(username,password,email,mobile_phone) values (?,?,?,?);",
    [username, password, email, mobile_phone],

    (err, result) => {
      if (err) {
        console.log(err);
      } else {
        res.send("Values inserted");
      }
    }
  );
};

module.exports.userlogin = async (req, res) => {
  let username = req.body.username;
  let password = jwt.sign(req.body.password, "your_jwt_secret");
  let ip = req.headers['x-forwarded-for'] || req.connection.remoteAddress;
  console.log(username);
  console.log(password);

  if (username && password) {
    let query = "select * from users where username = ? and password= ?";
    db.query(query, [username, password], (error, result) => {
      if (error) {
        console.log(error);
      } else {
        if (result.length > 0) {
          // console.log(result);
          LogModel.loguserdb(username, 'login mobileapp', ip, 1);
          res.send(result);
        } else {
          LogModel.loguserdb(username, 'login mobileapp', ip, 0);
          res.send(undefined);
        }
      }
    });
  }
};

module.exports.addprojact = async (req, res) => {
 
  console.log(req.body);
  let _projactname = req.body._projactname;
  let _companyproject = req.body._companyproject;
  let _plact = req.body._plact;
  let _userid = req.body._userid;
  let _username = req.body._username;
  const token = jwt.sign(_projactname, "your_jwt_secret");
  let date_ob = new Date();
  let ip = req.headers['x-forwarded-for'] || req.connection.remoteAddress;

  console.log(ip);

  // LogModel.loguserdb(username,'login mobileapp',ip,1);
  // // let query = "INSERT INTO Project_table (Projact_name`, `companyproject`, `place`, `latitudelocation`, `longitudelocation`, `user_users_id`) VALUES (?, ?, ?, ?, ?, ?);"
  db.query(
    "INSERT INTO Project_table (`Projact_name`, `companyproject`, `place`, `user_users_id`) VALUES (?, ?, ?, ?);",
    [_projactname, _companyproject, _plact, _userid],
    (error, result) => {
      if (error) {
        LogModel.loguserdb(_username,'addprojact',ip,0);
        console.log(error);
      } else {
        LogModel.loguserdb(_username,'addprojact',ip,1);
        console.log("Values inserted Projact");
        db.query(
          "SELECT idtable1 FROM Project_table where user_users_id = ? and idtable1 = (select max(idtable1) from Project_table where user_users_id = ?);",
          [_userid, _userid],
          (error, result) => {
            if (error) {
              console.log(error);
            } else {
              console.log(result[0].idtable1);
              db.query(
                "INSERT INTO token_table(token_name, Project_table_idtable1) VALUES (? , ?);",
                [token, result[0].idtable1],
                (error, result) => {
                  if (error) {
                    LogModel.loguserdb(_username,'generatetoken',ip,0);
                    console.log(error);
                    res.send(error)
                  } else {
                    LogModel.loguserdb(_username, 'generatetoken', ip, 1);
                    console.log(result);
                    res.send("ok INSERT and create token");

                  }
                }
              );
            }
          }
        );
      }
    }
  );
};

module.exports.getsolar = async (req, res) => {
  db.query("select * from dbr_solar", (error, result) => {
    if (error) {
      console.log(error);
    } else {
      res.send(result);
      // console.log(result);
    }
  });
};

module.exports.getuser = async (req, res) => {
  db.query("select * from users", (error, result) => {
    if (error) {
      console.log(error);
      // res.send(error);
    } else {
      res.send(result);
    }
  });
};

module.exports.deleteprojact = async (req, res) => {
  let id = req.body.id;
  console.log(id);
  db.query(
    "DELETE FROM token_table WHERE Project_table_idtable1= ? ;",
    [id],
    (error, result) => {
      if (error) {
        console.log(error);
      } else {
        // res.send("delete token ");
        db.query(
          "DELETE FROM Project_table WHERE idtable1= ? ;",
          [id],
          (error, result) => {
            if (error) {
              console.log(error);
            } else {
              res.send("ok DELETE projact");
            }
          }
        );
      }
    }
  );
};

module.exports.createddevice = async (req, res) => {
  console.log(req.body);
  let username = req.body.username;
  let device = req.body.device;
  let latitude = req.body.latitude;
  let longitude = req.body.longitude;
  let tokenid = req.body.tokenid;
  let Productdevic = req.body.Productdevic;
  let ip = req.headers['x-forwarded-for'] || req.connection.remoteAddress;
  db.query(
    "INSERT INTO devic_infoDB (latitude, longitude, devicname, token_table_token_id, Productdevic_idtable1) VALUES (?,?,?,?,?) ",
    [latitude, longitude, device, tokenid, Productdevic],
    (error, result) => {
      if (error) {
        LogModel.loguserdb(username, 'createddevice', ip, 0);
        console.log(error);
      } else {
        LogModel.loguserdb(username, 'createddevice', ip, 1);
        res.send('ok');
      }
    }
  );
};