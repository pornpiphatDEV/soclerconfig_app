import "package:flutter/material.dart";
import 'app_example/Login_Screen.dart';
import 'app_example/userScreen.dart';
import 'package:http/http.dart' as http;

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        theme: ThemeData(primarySwatch: Colors.green), home: LoginPage());
  }
}
