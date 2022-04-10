let express = require("express");
let cors = require("cors");
let app = express();
let bodyParser = require("body-parser");
let decode = require("./lib/DecodeSolar");

let mysql = require("mysql");
let db = require("./config/config").db;

let userController = require("./controllers/userController");
let engineerconfig = require("./controllers/engineerConfig");
let userScreen = require("./controllers/userScreen");

let drvicesolar = require("./controllers/modulelistdrvicesolar");
let avgquery = require("./controllers/averagequery");

app.use(cors());
app.use(express.json());
let propsData = process.env.PORT || 5000;

app.use(bodyParser.json());
app.use(bodyParser.urlencoded({ extended: true }));

app.get("/", (req, res) => {
  res.send("Sora api by ENCLL");
});

// user
app.post("/sigin", userController.sigin);
app.get("/getdata", userController.getsolar);
app.post("/insert", userController.insert);
app.get("/getuser ", userController.getuser);
app.post("/login", userController.userlogin);

// engineerconfig
app.get("/getuser", engineerconfig.get_users);
app.get("/redtokenuser/:username", engineerconfig.redtoken_user);

app.post("/testapi", (req, res) => {
  // const obj = JSON.parse(decode.hex_to_ascii(req.body.token));
  // console.log(obj);
  console.log(req.body);
  // console.log('hello');
  res.send("Post Data  ");
});

app.get("/testget", (req, res) => {
  db.query("select * from users", (error, result) => {
    if (error) {
      console.log(error);
      // res.send(error);
    } else {
      res.send(result);
    }
  });
});

app.post("/getprojact", userScreen.get_usersScreen);
app.post("/addprojact", userController.addprojact);
app.post("/deleteprojact", userController.deleteprojact);

app.get("/ProductBrandlde", drvicesolar.ProductBrand_lde);
app.get("/ProductBrandsolar", drvicesolar.ProductBrand_solar);
app.get("/ProductBrandBattery", drvicesolar.ProductBrand_Battery);
app.get("/Productdeviccol", drvicesolar.Productdeviccol);
app.get("/gettoken/:id", (req, res) => {
  let idtoken = req.params.id;
  db.query(
    "select token_id ,token_name from token_table where Project_table_idtable1 = ?;",
    [idtoken],
    (error, result) => {
      if (error) {
        console.log(error);
      } else {
        // res.send(result);
        result.forEach((val) => {
          // res.send(val.token_name);
          res.send({ id: val.token_id, token_name: val.token_name });
        });
      }
    }
  );
});

app.post("/createddevice", userController.createddevice);

app.get("/getprojactuser/:username", (req, res) => {
  let username = req.params.username;
  console.log(username);
  db.query(
    "select  idtable1 ,username, Projact_name,place,dateTime_created  from users inner join Project_table Project_table on users.users_id = Project_table.user_users_id where username = ?;",
    [username],
    (error, result) => {
      if (error) {
        console.log(error);
      } else {
        res.send(result);
      }
    }
  );
});


app.get("/getdevice/:projactname" , (req,res) => {
  let projactname =req.params.projactname;
  console.log(projactname);
  db.query(
    "select  devic_infoDB.devic_info_id, Project_table.Projact_name , devic_infoDB.devicname from  devic_infoDB inner join token_table on devic_infoDB.token_table_token_id = token_table.token_id inner join Project_table on Project_table.idtable1 = token_table.token_id where Projact_name = ?;",
    [projactname],
    (error, result) => {
      if (error) {
        console.log(error);
      } else {
        res.send(result);
      }
    });
});

// ฟั่งชั่น เพิ่มข้อมูลทุกๆ ช่วงโมง  (อย่าลบไปนะ)
// setInterval(avgquery.avgvolt_solar, 1000);
// setInterval(avgquery.volt_battery, 1000);
// setInterval(avgquery.volt_led,1000);

app.listen(propsData, () => {
  console.log("Start server api port 5000");
});
