import 'dart:async';
import 'dart:convert';
import 'dart:io' show Platform;
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mrzflutterplugin/mrzflutterplugin.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _result = 'No result yet';
  String fullImage;

  @override
  void initState() {
    super.initState();

    if (Platform.isAndroid) {
      Mrzflutterplugin.registerWithLicenceKey(
          "android_licence_key");
    } else if (Platform.isIOS) {
      Mrzflutterplugin.registerWithLicenceKey(iOS_licence_key);
    }
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> startScanning() async {
    String scannerResult;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      Mrzflutterplugin.setIDActive(true);
      Mrzflutterplugin.setPassportActive(true);
      Mrzflutterplugin.setVisaActive(true);

      String jsonResultString = await Mrzflutterplugin.startScanner;

      Map<String, dynamic> jsonResult = jsonDecode(jsonResultString);
        fullImage = jsonResult['full_image'];

      scannerResult = jsonResult['document_number'] +
          ' ' +
          jsonResult['given_names_readable'] +
          ' ' +
          jsonResult['surname'];
    } on PlatformException catch (ex) {
      String message = ex.message;
      scannerResult = 'Scanning failed: $message';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _result = scannerResult;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: new Center(
          child: new Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              if (fullImage != null) Image.memory(base64Decode(fullImage)),
              new FlatButton(
                child: Text("Start Scanner"),
                onPressed: startScanning,
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text('Result: $_result'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
