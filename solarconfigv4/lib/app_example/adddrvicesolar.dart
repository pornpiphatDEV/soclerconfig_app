import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:get_storage/get_storage.dart';
// import 'package:solarconfigv4/app_example/custom_dropdown.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

class adddrvicesolar extends StatefulWidget {
  @override
  _adddrvicesolarState createState() => _adddrvicesolarState();
}

class _adddrvicesolarState extends State<adddrvicesolar>
    with SingleTickerProviderStateMixin {
  String _selected;
  List country_data4 = List();
  String countryid4;

  String _latitude = "";
  String _longitude = "";

  int cou = 0;
  String token;
  final datacount = GetStorage();

  TextEditingController My_controller1 = new TextEditingController();
  TextEditingController My_controller2 = new TextEditingController();


  bool isDisabled = false;
  void _getCurrentLocation() async {
    final position = await Geolocator()
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    print(position);

    setState(() {
      // _latitude = "${position.latitude}, ${position.longitude}";
      _latitude = "${position.latitude}";
      _longitude = "${position.longitude}";
    });
  }

  void _gettoken() async {
    int id = datacount.read('Project_table_idtable1');
    // print('**************************************');
    // print(id);
    // print('**************************************');

    String url = "http://192.168.30.40:5000/gettoken/$id";
    var response = await http
        .get(Uri.encodeFull(url), headers: {"Accept": "application/json"});

    token = response.body;

    final Token = jsonDecode(token);

    // print("*************************************");
    // print(token);
    // print("*************************************");
    // print(user['id']);

    // String Tokenid = Token['id'];
    // String Tokenname = Token['token_name'];

    print("*************************************");
    print(Token['id']);
    print(Token['token_name']);
    print("*************************************");
  }

  // Initializing the Bluetooth connection state to be unknown
  BluetoothState _bluetoothState = BluetoothState.UNKNOWN;
  // Initializing a global key, as it would help us in showing a SnackBar later
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  // Get the instance of the Bluetooth
  FlutterBluetoothSerial _bluetooth = FlutterBluetoothSerial.instance;
  // Track the Bluetooth connection with the remote device
  BluetoothConnection connection;

  int _deviceState;

  bool isDisconnecting = false;

  Map<String, Color> colors = {
    'onBorderColor': Colors.green,
    'offBorderColor': Colors.red,
    'neutralBorderColor': Colors.transparent,
    'onTextColor': Colors.green[700],
    'offTextColor': Colors.red[700],
    'neutralTextColor': Colors.blue,
  };
  // Method to disconnect bluetooth
  void _disconnect() async {
    setState(() {
      _isButtonUnavailable = true;
      _deviceState = 0;
    });

    await connection.close();
    show('Device disconnected');
    if (!connection.isConnected) {
      setState(() {
        _connected = false;
        _isButtonUnavailable = false;
      });
    }
  }

  Future show(
    String message, {
    Duration duration: const Duration(seconds: 3),
  }) async {
    await new Future.delayed(new Duration(milliseconds: 100));
    _scaffoldKey.currentState.showSnackBar(
      new SnackBar(
        content: new Text(
          message,
        ),
        duration: duration,
      ),
    );
  }

  // To track whether the device is still connected to Bluetooth
  bool get isConnected => connection != null && connection.isConnected;

  // Define some variables, which will be required later
  List<BluetoothDevice> _devicesList = [];
  BluetoothDevice _device;
  bool _connected = false;
  bool _isButtonUnavailable = false;

  Future<String> Productdeviccol() async {
    var res = await http.get(
        Uri.encodeFull("http://192.168.30.40:5000/Productdeviccol"),
        headers: {
          "Accept": "application/json"
        }); //if you have any auth key place here...properly..
    var resBody = json.decode(res.body);
    setState(() {
      // country_data = resBody;
      country_data4 = resBody;
    });
    return "Sucess";
  }

  Future<void> enableBluetooth() async {
    // Retrieving the current Bluetooth state
    _bluetoothState = await FlutterBluetoothSerial.instance.state;

    // If the bluetooth is off, then turn it on first
    // and then retrieve the devices that are paired.
    if (_bluetoothState == BluetoothState.STATE_OFF) {
      await FlutterBluetoothSerial.instance.requestEnable();
      await getPairedDevices();
      return true;
    } else {
      await getPairedDevices();
    }
    return false;
  }

  // For retrieving and storing the paired devices
  // in a list.
  Future<void> getPairedDevices() async {
    List<BluetoothDevice> devices = [];

    // To get the list of paired devices
    try {
      devices = await _bluetooth.getBondedDevices();
    } on PlatformException {
      print("Error");
    }

    // It is an error to call [setState] unless [mounted] is true.
    if (!mounted) {
      return;
    }

    // Store the [devices] list in the [_devicesList] for accessing
    // the list outside this class
    setState(() {
      _devicesList = devices;
    });
  }

  @override
  void initState() {
    super.initState();
    this._getCurrentLocation();
    this.Productdeviccol();
    this._gettoken();

    // Get current state
    FlutterBluetoothSerial.instance.state.then((state) {
      setState(() {
        _bluetoothState = state;
      });
    });

    _deviceState = 0; // neutral

    // If the bluetooth of the device is not enabled,
    // then request permission to turn on bluetooth
    // as the app starts up
    enableBluetooth();

    // Listen for further state changes
    FlutterBluetoothSerial.instance
        .onStateChanged()
        .listen((BluetoothState state) {
      setState(() {
        _bluetoothState = state;
        if (_bluetoothState == BluetoothState.STATE_OFF) {
          _isButtonUnavailable = true;
        }
        getPairedDevices();
      });
    });
  }

  // Create the List of devices to be shown in Dropdown Menu
  List<DropdownMenuItem<BluetoothDevice>> _getDeviceItems() {
    List<DropdownMenuItem<BluetoothDevice>> items = [];
    if (_devicesList.isEmpty) {
      items.add(DropdownMenuItem(
        child: Text('NONE'),
      ));
    } else {
      _devicesList.forEach((device) {
        items.add(DropdownMenuItem(
          child: Text(device.name),
          value: device,
        ));
      });
    }
    return items;
  }

  @override
  void dispose() {
    // Avoid memory leak and disconnect
    if (isConnected) {
      isDisconnecting = true;
      connection.dispose();
      connection = null;
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text("Add DeviceProjact"),
          centerTitle: true,
          backgroundColor: Colors.green,
          actions: <Widget>[
            FlatButton.icon(
              icon: Icon(
                Icons.refresh,
                color: Colors.white,
              ),
              label: Text(
                "Refresh",
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              splashColor: Colors.deepPurple,
              onPressed: () async {
                // So, that when new devices are paired
                // while the app is running, user can refresh
                // the paired devices list.
                await getPairedDevices().then((_) {
                  show('Device list refreshed');
                });
              },
            ),
          ]),
      body: SingleChildScrollView(
        child: Container(
            padding: EdgeInsets.all(15.0),
            child: Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Expanded(
                        child: Text(
                          'Enable Bluetooth',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      Switch(
                        value: _bluetoothState.isEnabled,
                        onChanged: (bool value) {
                          future() async {
                            if (value) {
                              await FlutterBluetoothSerial.instance
                                  .requestEnable();
                            } else {
                              await FlutterBluetoothSerial.instance
                                  .requestDisable();
                            }

                            await getPairedDevices();
                            _isButtonUnavailable = false;

                            if (_connected) {
                              _disconnect();
                            }
                          }

                          future().then((_) {
                            setState(() {});
                          });
                        },
                      )
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text(
                        'Device:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      DropdownButton(
                        items: _getDeviceItems(),
                        onChanged: (value) => setState(() => _device = value),
                        value: _devicesList.isNotEmpty ? _device : null,
                        // onTap: () => {print(_devicesList)},
                      ),
                      RaisedButton(
                        onPressed: _isButtonUnavailable
                            ? null
                            : _connected
                                ? _disconnect
                                : _connect,
                        child: Text(_connected ? 'Disconnect' : 'Connect'),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                      controller: My_controller1..text = _latitude,
                      decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: "Latitude ")),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                      controller: My_controller2..text = _longitude,
                      decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: "Longitude ")),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: DecoratedBox(
                      decoration: BoxDecoration(
                          border: new Border.all(color: Colors.green),
                          borderRadius: BorderRadius.circular(5.0)),
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(10, 5, 0, 0),
                        child: Stack(
                          children: <Widget>[
                            Center(
                              child: Text(
                                "solar",
                                style: TextStyle(
                                  fontSize: 13.0,
                                ),
                              ),
                            ),
                            DropdownButtonHideUnderline(
                              child: DropdownButton(
                                items: country_data4.map((item) {
                                  return new DropdownMenuItem(
                                      child: new Text(
                                        item['Productdeviccol_name'],
                                        style: TextStyle(
                                          fontSize: 13.0,
                                        ),
                                      ),
                                      value: item['idtable1'].toString());
                                }).toList(),
                                onChanged: (String newVal) {
                                  setState(() {
                                    countryid4 = newVal;
                                    print(countryid4.toString());
                                  });
                                },
                                value: countryid4,
                              ),
                            )
                          ],
                        ),
                      )),
                ),
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Container(
                      height: 50,
                      padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                      child: RaisedButton(
                          textColor: Colors.white,
                          color: Colors.green,
                          child: Text('Screen'),
                          onPressed:
                              _connected ? _sendOnMessageToBluetooth : null)),
                ),
               RaisedButton(
                          disabledColor: Colors.black,
                          onPressed: isDisabled
                              ? null
                              : () {
                                  print("Clicked");
                                },
                          child: Text("Click Me"),
                        ),
              ],
            )),
      ),
    );
  }

  // Method to connect to bluetooth
  void _connect() async {
    setState(() {
      _isButtonUnavailable = true;
    });
    if (_device == null) {
      show('No device selected');
    } else {
      if (!isConnected) {
        await BluetoothConnection.toAddress(_device.address)
            .then((_connection) {
          print('Connected to the device');
          connection = _connection;
          setState(() {
            _connected = true;
          });

          connection.input.listen(null).onDone(() {
            if (isDisconnecting) {
              print('Disconnecting locally!');
            } else {
              print('Disconnected remotely!');
            }
            if (this.mounted) {
              setState(() {});
            }
          });
        }).catchError((error) {
          print('Cannot connect, exception occurred');
          print(error);
        });
        show('Device connected');

        setState(() => _isButtonUnavailable = false);
      }
    }
  }

  void _sendOnMessageToBluetooth() async {
    // connection.output.add(utf8.encode("L1/$token" + "\r\n"));
    // await connection.output.allSent;
    // show('Device Turned On');

    // print(_device.name);
    print('---------------------------------------------------------');
    print(_device.name);
    print(My_controller1.text);
    print(My_controller2.text);
    print(countryid4);

    final Token = jsonDecode(token);
    print(Token['id']);
    print(Token['token_name']);

    print('---------------------------------------------------------');
    var username = datacount.read('username');

    final datadevice = {
      "username":username,
      "device": _device.name,
      "latitude": My_controller1.text,
      "longitude": My_controller2.text,
      "tokenid": Token['id'].toString(),
      "Productdevic": countryid4
    };

    var url = 'http://192.168.30.40:5000/createddevice';
    var response = await http.post(url, body: datadevice);
    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');

    if (response.statusCode != 200) {
      show("post error ");
    } else {
      connection.output
          .add(utf8.encode("L1/${Token['token_name'].toString()}" + "\r\n"));

      Navigator.pop(context);
      // await connection.output.allSent;
      // show('Device Turned id');
    }
  }
}
