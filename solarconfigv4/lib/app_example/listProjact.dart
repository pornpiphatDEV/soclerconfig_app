import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:get_storage/get_storage.dart';
import 'package:solarconfigv4/app_example/listdeviceProjact.dart';
import 'package:solarconfigv4/app_example/addprojact.dart';

class listProject extends StatefulWidget {
  @override
  listProjectState createState() => new listProjectState();
  // _myHomePageState createState() => new _myHomePageState();
}

class listProjectState extends State<listProject> {
  List data;

  final datacount = GetStorage();

  Future<String> getData() async {
    // print(datacount);
    String urlred = datacount.read('username');
    // print(urlred);
    String url = "http://192.168.30.40:5000/getprojactuser/$urlred";
    var response = await http
        .get(Uri.encodeFull(url), headers: {"Accept": "application/json"});

    this.setState(() {
      data = jsonDecode(response.body);
    });

    return "Success!";
  }

  // Future getData() async {
  //   String urlred = datacount.read('username');
  //   var url = 'http://192.168.100.8:5000/getprojactuser/$urlred';
  //   var response = await http.get(url);
  //   print(json.decode(response.body));
  //   return json.decode(response.body);
  // }

  @override
  void initState() {
    this.getData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
          title: new Text("listProject"), backgroundColor: Colors.green),
      body: RefreshIndicator(
        onRefresh: getData,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: SizedBox(
            child: ListView.builder(
              itemCount: data == null ? 0 : data.length,
              itemBuilder: (BuildContext context, int index) {
                return new Card(
                    child: ListTile(
                  title: new Text(data[index]["Projact_name"]),
                  subtitle: Text(data[index]["place"]),
                  leading: Icon(Icons.engineering_sharp),
                  trailing: GestureDetector(
                    child: Icon(
                      Icons.delete,
                      color: Colors.red,
                    ),
                    onTap: () {
                      print(data[index]["idtable1"]);
                      showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              title: Text("Warning"),
                              content: Text(
                                  "You want to delete a project named ${data[index]["Projact_name"]} ?"),
                              actions: <Widget>[
                                FlatButton(
                                  child: Text("Yes"),
                                  onPressed: () async {
                                    int id = data[index]["idtable1"];
                                    var url =
                                        'http://192.168.100.8:5000/deleteprojact';
                                    var response = http
                                        .post(url, body: {'id': id.toString()});
                                    setState() {
                                      // listProject();
                                      getData();
                                    }

                                    Navigator.pop(context);
                                    print("ok deleteProjact");
                                  },
                                ),
                                FlatButton(
                                  child: Text("No"),
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                )
                              ],
                            );
                          });
                    },
                  ),
                  onTap: () {
                    // print(index);
                    print(data[index]["Projact_name"]);
                    datacount.write("Projactname", data[index]["Projact_name"]);

                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) {
                      datacount.write(
                          "Project_table_idtable1", data[index]["idtable1"]);
                      print(data[index]["idtable1"]);
                      return listdevic();
                    }));
                  },
                ));
              },
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Add', // used by assistive technologies
        child: Icon(Icons.add),
        onPressed: () {
          // print(datacount.read('users_id'));
          Navigator.push(context, MaterialPageRoute(builder: (context) {
            return addprojact_Screen();
          }));
        },
      ),
    );
  }

  Future<void> _showMyDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('AlertDialog Title'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('This is a demo alert dialog.'),
                Text('Would you like to approve of this message?'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Yes'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('NO'),
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
