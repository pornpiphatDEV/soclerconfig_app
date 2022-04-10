let log_db = require("../config/logdbconfig").log_db;

module.exports.logdb = () => {
    log_db.query('select * from userlog_table', (err,result) => {
        try {
            console.log(result);
        } catch (err) {
            console.log(err);
        }
    });
}


module.exports.loguserdb = (username, event, ipaddress, status_success) => {
    console.log('login user');

    let sql = `insert into userlog_table(username, event, ipaddress, status_success) VALUES ('${username}','${event}','${ipaddress}','${status_success}');`
    
    console.log(sql);
    log_db.query(sql,(err,result) => {
        try {
            console.log(result);
        } catch (err) {
            console.log(err);
        }
    });
}