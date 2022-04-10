let express = require("express");
let mysql = require("mysql");
let db = require("../config/config").db;

module.exports.avgvolt_solar = async () => {
  db.query(
    "SELECT round(avg(volt_solar) ,3) Avg_volt_solar   FROM dbr_solar",
    (error, result) => {
      if (error) {
        console.log(error);
      } else {
        // console.log(result[0].Avg_volt_solar);
        let avg_volt_solar = result[0].Avg_volt_solar;
        console.log(avg_volt_solar);
        db.query(
          "insert into volt_solarDB(volt_solar) values(?)",
          [avg_volt_solar],

          (err, result) => {
            if (err) {
              console.log(err);
            } else {
              // res.send("Values inserted");
              console.log("start  avg_volt_solar ");
            }
          }
        );
      }
    }
  );
};

module.exports.volt_battery = async () => {
    db.query(
    "SELECT round(avg(volt_battery) ,3) Avg_battery   FROM dbr_solar ;",
    (error, result) => {
      if (error) {
        console.log(error);
      } else {
        // console.log(result[0].Avg_volt_solar);
        let volt_battery = result[0].Avg_battery;
        console.log(volt_battery);

        db.query(
          "insert into volt_battery(volt_battery) values(?)",
          [
            volt_battery
           
          ],

          (err, result) => {
            if (err) {
              console.log(err);
            } else {
              // res.send("Values inserted");
              console.log('start  avg_volt_battery ');
            }
          }
        );
      }
    }
  );
};


module.exports.volt_led = async () => {
    db.query(
        "SELECT round(avg(volt_led) ,3) Avg_led   FROM dbr_solar ;",
        (error, result) => {
          if (error) {
            console.log(error);
          } else {
            // console.log(result[0].Avg_volt_solar);
            let volt_led = result[0].Avg_led;
            console.log(volt_led);
    
            db.query(
              "insert into volt_led(volt_led) values(?)",
              [
                volt_led
               
              ],
    
              (err, result) => {
                if (err) {
                  console.log(err);
                } else {
                  // res.send("Values inserted");
                  console.log('start  avg_volt_led ');
                }
              }
            );
          }
        }
      );
}