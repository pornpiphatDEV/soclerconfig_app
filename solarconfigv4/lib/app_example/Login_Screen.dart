import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
// import 'package:solarconfigv4/app_example/Singnin_Screen.dart';
// import 'package:solarconfigv4/app_example/NavigationDrawerDemo .dart';

import 'package:solarconfigv4/app_example/listProjact.dart';
import 'package:get_storage/get_storage.dart';

class LoginPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new _State();
}

class _State extends State<LoginPage> {
  TextEditingController nameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  final datacount = GetStorage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        // appBar: AppBar(
        //   title: Text('Login Screen App'),
        // ),

        body: Padding(
            padding: EdgeInsets.all(10),
            child: ListView(
              children: <Widget>[
                Image.asset('assets/images/logo.png'),
                Container(
                  padding: EdgeInsets.all(10),
                  child: TextField(
                    controller: nameController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'User Name',
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.fromLTRB(10, 10, 10, 0),
                  child: TextField(
                    obscureText: true,
                    controller: passwordController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Password',
                    ),
                  ),
                ),
                FlatButton(
                  onPressed: () {
                    //forgot password screen
                  },
                  textColor: Colors.blue,
                  child: Text('Forgot Password'),
                ),
                Container(
                    height: 50,
                    padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                    child: RaisedButton(
                      textColor: Colors.white,
                      color: Colors.green,
                      child: Text('Login'),
                      onPressed: () async {
                        var username = (nameController.text);
                        var password = (passwordController.text);

                        print(username);
                        print(password);

                        var url = 'http://192.168.30.40:5000/login';
                        var response = await http.post(url,
                            body: {'username': username, 'password': password});
                        print('Response status: ${response.statusCode}');
                        print('Response body: ${response.body}');

                        // print(await http.read('http://192.168.2.56:3000/'));

                        print(response.body);

                        String status = response.body;
                        int status_length = status.length;
                        String data = nameController.text;
                        // var res = jsonDecode(response.body);
                        // print(res[0]["users_id"]);
                        // print(status_length);
                        if (status_length > 0) {
                          var res = jsonDecode(status);
                          print(res[0]["users_id"]);
                          datacount.write("users_id", res[0]["users_id"]);
                          datacount.write("username", data);
                          Navigator.pushReplacement(context,
                              MaterialPageRoute(builder: (context) {
                            return listProject();
                          }));

                          // print("ok Users ");
                        } else {
                          _showMyDialog();
                        }

                        // datacount.write("username", username);
                        // datacount.write("password", password);
                      },
                    )),
              ],
            )));
  }

  Future<void> _showMyDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('No uses'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('There is no username in the system.'),
                // Text('Would you like to approve of this message?'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Approve'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
