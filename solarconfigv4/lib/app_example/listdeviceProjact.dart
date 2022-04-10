import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:get_storage/get_storage.dart';
import 'package:solarconfigv4/app_example/adddrvicesolar.dart';

class listdevic extends StatefulWidget {
  @override
  _listdevicState createState() => _listdevicState();
}

class _listdevicState extends State<listdevic>
    with SingleTickerProviderStateMixin {
  AnimationController _controller;
  final datacount = GetStorage();
  List data;

  Future<String> getData() async {
    // print(datacount);
    String urlred = datacount.read('Projactname');
    // print(urlred);
    String url = "http://192.168.30.40:5000/getdevice/$urlred";
    var response = await http
        .get(Uri.encodeFull(url), headers: {"Accept": "application/json"});

    this.setState(() {
      data = jsonDecode(response.body);
    });

    return "Success!";
  }

  @override
  void initState() {
    this.getData();
    super.initState();
    _controller = AnimationController(vsync: this);
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
          title: new Text("listdevic"), backgroundColor: Colors.green),
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
                  title: new Text(data[index]["devicname"]),
                  // subtitle: Text(data[index]["place"]),
                  leading: Icon(Icons.handyman_outlined),
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
          // print(datacount.read('Projactname'));
          Navigator.push(context, MaterialPageRoute(builder: (context) {
            return adddrvicesolar();
          }));
        },
      ),
    );
  }
}
