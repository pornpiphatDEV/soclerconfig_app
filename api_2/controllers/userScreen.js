let express = require("express");
let mysql = require("mysql");
let db = require("../config/config").db;
let decode = require("../lib/DecodeSolar");

module.exports.get_usersScreen = async (req, res) => {
  let username = req.body.username;
  console.log(username);
  db.query(
    "select  idtable1 ,username, Projact_name,place,dateTime_created  from users inner join Project_table Project_table on users.users_id = Project_table.user_users_id where username = ?;",
    [username],
    (error, result) => {
      if (error) {
        console.log(error);
        res.send(error);
      } else {
        if(result.length > 0 ){
            res.send('ok');
        }
        else{
            res.send(undefined);
        }
        
      }
    }
  );
};
