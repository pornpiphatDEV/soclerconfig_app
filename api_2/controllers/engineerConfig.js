
let express = require("express");
let mysql = require("mysql"); 
let db = require('../config/config').db;
let decode = require('../lib/DecodeSolar')




module.exports.get_users = async (req,res) => {
    db.query("select user_id , username from users" ,(error, result) =>{
        if(error){
            console.log(error);
        } else {
            res.send(result);
            console.log(result);
        }
    });
}


module.exports.redtoken_user = async (req,res) => {
    let username = req.params.username;
    console.log(username);
    // let sqlquery = "select username , token_name , latitude,longitude,Installation_status,online from  users inner join token_table on user_id = token_table.users_user_idwhere username = ?";
    
    let sqlquery = "select user_id , username from users";
 
    
    db.query(sqlquery,(error, result) =>{
        if(error){
            console.log(error);
            res.send(error);
        } else {
            // var strParseWriteReq = JSON.stringify(req.params)
            res.send(result);
            console.log(result);
        }
    });
}



