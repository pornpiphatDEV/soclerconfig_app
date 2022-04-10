import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:solarconfigv4/app_example/listProjact.dart';

class addprojact_Screen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return FormScreenState();
  }
}

class FormScreenState extends State<addprojact_Screen> {
  String _projactname;
  String _companyproject;
  String _plact;
  String _latitudelocation;
  String _longitudelocation;

  // String _url;

  final datacount = GetStorage();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  Widget _buildprojact() {
    return TextFormField(
      decoration: InputDecoration(labelText: 'Porjactname'),
      // maxLength: 10,
      validator: (String value) {
        if (value.isEmpty) {
          return 'Projactname is Required';
        }

        return null;
      },
      onSaved: (String value) {
        _projactname = value;
      },
    );
  }

  Widget _buildcompanyproject() {
    return TextFormField(
      decoration: InputDecoration(labelText: 'Companyproject'),
      // maxLength: 10,
      validator: (String value) {
        if (value.isEmpty) {
          return 'Companyprojec is Required';
        }

        return null;
      },
      onSaved: (String value) {
        _companyproject = value;
      },
    );
  }

  Widget _buildplacr() {
    return TextFormField(
      decoration: InputDecoration(labelText: 'Place'),
      // maxLength: 10,
      validator: (String value) {
        if (value.isEmpty) {
          return 'Placr is Required';
        }

        return null;
      },
      onSaved: (String value) {
        _plact = value;
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Create Projact")),
      body: SingleChildScrollView(
        child: Container(
          margin: EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Image.asset('assets/images/logo.png'),
                _buildprojact(),
                _buildcompanyproject(),
                _buildplacr(),
                SizedBox(height: 10),
                RaisedButton(
                  child: Text(
                    'Submit',
                    style: TextStyle(color: Colors.blue, fontSize: 16),
                  ),
                  onPressed: () async {
                    setState(() async {
                      if (!_formKey.currentState.validate()) {
                        return;
                      }

                      _formKey.currentState.save();

                      var userid = datacount.read('users_id');
                      var username = datacount.read('username');

                          // datacount.write("username", data);

                      print(_projactname);
                      print(_companyproject);
                      print(_plact);
                      print(userid.toString());
                      print(username);

                      //Send to API

                      var addprojact = {
                        '_username':username.toString(),
                        '_projactname': _projactname,
                        '_companyproject': _companyproject,
                        '_plact': _plact,
                        '_userid': userid.toString()
                      };

                      var url = 'http://192.168.30.40:5000/addprojact';
                      var response = await http.post(url, body: addprojact);

      
                      print(response.body);

                      Navigator.pop(_formKey.currentState.context, true);

   
                    });
                  },
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
