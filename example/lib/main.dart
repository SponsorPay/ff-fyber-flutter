import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fyber_4_flutter/fyber_4_flutter.dart';

void main() => runApp(new MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => new _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color.fromARGB(255, 0, 208, 134),
      ),
      home: new Scaffold(
        appBar: new AppBar(
          title: new Row(
            children: <Widget>[
              new Text('Fyber SDK for'),
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
    (value == null || value.length == 0) ? "Field is empty" : null;

class _FlutterSdkTestPageState extends State<FlutterSdkTestPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final GlobalKey<FormFieldState<String>> _appId = GlobalKey();
  final GlobalKey<FormFieldState<String>> _user = GlobalKey();
  final GlobalKey<FormFieldState<String>> _securityToken = GlobalKey();

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
                    key: _appId,
                    initialValue: "26357",
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: "App ID"),
                    validator: _nonNullValidator,
                  ),
                  new TextFormField(
                    key: _securityToken,
                    initialValue: "token",
                    keyboardType: TextInputType.text,
                    decoration:
                        const InputDecoration(labelText: "Security token"),
                    validator: _nonNullValidator,
                  ),
                  new TextFormField(
                    key: _user,
                    keyboardType: TextInputType.text,
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

  void _onStartSDK() async {
    if (_formKey.currentState.validate()) {
      final started = await Fyber4Flutter.startFyber(
        appId: _appId.currentState.value,
        securityToken: _securityToken.currentState.value,
        user: _user.currentState.value,
        enableLogging: true,
      );
      print(
          "Fyber SDK ${started ? "started... yay!" : "not running... nooo!"}");
    }
  }
}

class FyberSdkStartedIndicator extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: FutureBuilder<bool>(
        future: Fyber4Flutter.sdkReady,
        initialData: false,
        builder: (context, snapshot) {
          if (snapshot.data) {
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text("Sdk seems ready"),
            );
          } else {
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: <Widget>[
                  Text("SDK is not ready yet"),
                  CircularProgressIndicator()
                ],
              ),
            );
          }
        },
      ),
    );
  }
}

class FyberAdsControlPanel extends StatefulWidget {
  @override
  FyberAdsControlPanelState createState() {
    return new FyberAdsControlPanelState();
  }
}

class FyberAdsControlPanelState extends State<FyberAdsControlPanel> {
  List<String> shownAds = [];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            RaisedButton(
              onPressed: _showRV,
              child: Text("Rewarded"),
            ),
            RaisedButton(
              onPressed: _showOW,
              child: Text("Offerwall"),
            ),
            RaisedButton(
              onPressed: _showInt,
              child: Text("Interstitial"),
            ),
          ],
        ),
        EngagementEventLogger(),
      ]..addAll(
          shownAds.reversed.map((text) => ListTile(
                title: Text(text),
              )),
        ),
    );
  }

  void _showRV() async {
    final result =
        await Fyber4Flutter.showRewardedVideo(notifyOnCompletion: false);
    setState(() {
      shownAds.add("Rewarded Video request result: $result");
    });
  }

  void _showOW() async {
    final result = await Fyber4Flutter.showOfferwall(closeOnRedirect: true);
    setState(() {
      shownAds.add("Offerwall request result: $result");
    });
  }

  void _showInt() async {
    final result = await Fyber4Flutter.showInterstitial();
    setState(() {
      shownAds.add("Interstitial request result: $result");
    });
  }
}

class EngagementEventLogger extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<EngagementEvent>(
      initialData: null,
      stream: Fyber4Flutter.engagementResults,
      builder: (context, snapshot) {
        if (snapshot.data != null) {
          return new SizedBox(
            height: 48.0,
            child: new Center(
                child: new Text("Last engagement: ${snapshot.data}")),
          );
        } else {
          return new SizedBox(
            height: 48.0,
          );
        }
      },
    );
  }
}
