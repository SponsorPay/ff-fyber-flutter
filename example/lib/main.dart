import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fyber_4_flutter/fyber_4_flutter.dart';

void main() => runApp(new MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => new _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _platformVersion = 'Unknown';

  @override
  initState() {
    super.initState();
    initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  initPlatformState() async {
    String platformVersion;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      platformVersion = await Fyber4Flutter.platformVersion;
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _platformVersion = platformVersion;
    });
  }

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      theme: ThemeData(
        primaryColor: const Color.fromARGB(255, 0, 208, 134),
      ),
      home: new Scaffold(
        appBar: new AppBar(
          title: new Row(
            children: <Widget>[
              new Text('Fyber SDK 4'),
              new Padding(
                padding: const EdgeInsets.only(left: 4.0),
                child: new FlutterLogo(
                  colors: Colors.purple,
                ),
              ),
            ],
          ),
        ),
        body: new FlutterSdkTestPage(),
      ),
    );
  }
}

class FlutterSdkTestPage extends StatefulWidget {
  @override
  _FlutterSdkTestPageState createState() => _FlutterSdkTestPageState();
}

final FormFieldValidator<String> _nonNullValidator = (String value) =>
    (value != null && value.length > 0) ? "" : "Field is empty";

class _FlutterSdkTestPageState extends State<FlutterSdkTestPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return new SingleChildScrollView(
      child: new Padding(
        padding: const EdgeInsets.all(8.0),
        child: new Column(
          children: <Widget>[
            new Form(
              key: _formKey,
              child: Column(
                children: <Widget>[
                  new TextFormField(
                    initialValue: "26357",
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: "App ID"),
                    validator: _nonNullValidator,
                  ),
                  new TextFormField(
                    initialValue: "token",
                    keyboardType: TextInputType.number,
                    decoration:
                        const InputDecoration(labelText: "Security token"),
                    validator: _nonNullValidator,
                  ),
                  new TextFormField(
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: "User"),
                  ),
                  new Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: new RaisedButton(
                      onPressed: _onStartSDK,
                      child: new Text("Start SDK"),
                    ),
                  ),
                ],
              ),
            ),
            new FyberSdkStartedIndicator(),
            new FyberAdsControlPanel(),
          ],
        ),
      ),
    );
  }

  void _onStartSDK() {
    if (_formKey.currentState.validate()) {
      // TODO start SDK
    }
  }
}

class FyberSdkStartedIndicator extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // TODO check for SDK to become started
    return Container();
  }
}

class FyberAdsControlPanel extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: <Widget>[
        new RaisedButton(
          onPressed: _showRV,
          child: new Text("Rewarded"),
        ),
        new RaisedButton(
          onPressed: _showOW,
          child: new Text("Offerwall"),
        ),
        new RaisedButton(
          onPressed: _showInt,
          child: new Text("Interstitial"),
        ),
      ],
    );
  }

  void _showRV() {}

  void _showOW() {}

  void _showInt() {}
}
