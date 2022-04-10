let express = require("express");
let mysql = require("mysql");
let db = require("../config/config").db;





module.exports.Productdeviccol = async (req, res) => {
  db.query("select idtable1 , Productdeviccol_name from Productdevic;", (error, result) => {
    if (error) {
      console.log(error);
    } else {
      res.send(result);
      // console.log(result);
    }
  });
}



module.exports.ProductBrand_lde = async (req, res) => {
  db.query("select * from ProductBrand_lde", (error, result) => {
    if (error) {
      console.log(error);
    } else {
      res.send(result);
      // console.log(result);
    }
  });
};

module.exports.ProductBrand_Battery = async (req, res) => {
  db.query("select * from ProductBrand_Battery", (error, result) => {
    if (error) {
      console.log(error);
    } else {
      res.send(result);
      // console.log(result);
    }
  });
};

module.exports.ProductBrand_solar = async (req, res) => {
  db.query("select * from ProductBrand_solar", (error, result) => {
    if (error) {
      console.log(error);
    } else {
      res.send(result);
      // console.log(result);
    }
  });
};
