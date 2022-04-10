import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:solarconfigv4/app_example/listProjact.dart';
import 'package:get_storage/get_storage.dart';

class userScrren extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new _State();
}

class _State extends State<userScrren> {
  TextEditingController nameController = TextEditingController();
  // TextEditingController passwordController = TextEditingController();
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
                    height: 50,
                    padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                    child: RaisedButton(
                      textColor: Colors.white,
                      color: Colors.green,
                      child: Text('Screen'),
                      onPressed: () async {
                        Screenusers();
                        // datacount.write("username", username);
                        // datacount.write("password", password);
                      },
                    )),
              ],
            )));
  }

  // void alertDialog(String s) {}
  Future<void> Screenusers() async {
    print(nameController.text);

    var url = 'http://192.168.30.40:5000/getprojact';
    var response =
        await http.post(url, body: {"username": nameController.text});

    // print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');

    String data = nameController.text;

    if (response.statusCode == 200) {
      if (response.body == "ok") {
        datacount.write("username", data);
        Navigator.push(context, MaterialPageRoute(builder: (context) {
          return listProject();
        }));
      } else {
        // print("No user information found.");
        _showMyDialog();
      }
    } else {
      print("no response error");
    }
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
                Text('Please check username.'),
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
