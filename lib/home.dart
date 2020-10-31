import 'dart:io';

import 'package:countdown_flutter/countdown_flutter.dart';
import 'package:death_counter/choose-card.dart';
import 'package:death_counter/text.dart';
import 'package:death_counter/toast.dart';
import 'package:firebase_admob/firebase_admob.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'main.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> with WidgetsBindingObserver {
  Future<bool> _onWillPop() {
    return showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Are you sure?'),
            content: Text('Do you want to exit an App'),
            actions: <Widget>[
              FlatButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text('No'),
              ),
              FlatButton(
                onPressed: () => exit(0),
                /*Navigator.of(context).pop(true)*/
                child: Text('Yes'),
              ),
            ],
          ),
        ) ??
        false;
  }

  BannerAd myBanner = BannerAd(
    adUnitId: 'ca-app-pub-2118340185089535/4235062555',
    size: AdSize.smartBanner,
    targetingInfo: MobileAdTargetingInfo(
      keywords: <String>[],
      testDevices: <String>[], // Android emulators are considered test devices
    ),
    listener: (MobileAdEvent event) {
      print("BannerAd event is $event");
    },
  );

  int days;

  @override
  void initState() {
    // TODO: implement initState
    WidgetsBinding.instance.addObserver(this);
    firstTime();
    super.initState();
    print('Started');
    FirebaseAdMob.instance
        .initialize(appId: "ca-app-pub-87954875124685");

    myBanner
      ..load()
      ..show();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
    print('disposed');
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    print('state = $state');
    if (state == AppLifecycleState.detached) {
      print('existing');
      ToastBar(text: "Exsiting", color: Colors.red).show();
    }
  }

  SharedPreferences x;
  firstTime() async {
    x = await SharedPreferences.getInstance();

    if (x.getBool('isSeen') == null) {
      await x.setBool('isSeen', true);
      await x.setInt('days', 1545177600);
    }

    setState(() {
      days = x.getInt('days');
      x.setInt('new', days);
    });

    print(days);
  }

  @override
  Widget build(BuildContext context) {
    print("dates is $days");
    var _countDown = days != null
        ? Countdown(
            duration: Duration(seconds: x.getInt('days')),
            builder: (BuildContext ctx, Duration remaining) {
              x.setInt('days', remaining.inSeconds);

              return Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Expanded(
                        flex: 4,
                        child: Image(
                          image: AssetImage("images/home.png"),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Padding(
                          padding: const EdgeInsets.only(right: 5),
                          child: RaisedButton(
                            onPressed: () async {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => ChooseCard(
                                          remaining: remaining.inSeconds,
                                        )),
                              );
                            },
                            color: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(40),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: <Widget>[
                                Container(
                                  height: 20,
                                  width: 20,
                                  child: Image.asset(
                                    'images/logo for the app.png',
                                  ),
                                ),
                                Text(
                                  "Play",
                                  style: TextStyle(fontWeight: FontWeight.w100),
                                ),
                              ],
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 10),
                    child: CountDownText(
                      time: (remaining.inDays ~/ 365).toString(),
                      color: Colors.red,
                      suffix: 'YRS',
                    ),
                  ),
                  CountDownText(
                    time: ((remaining.inDays % 365)).toString(),
                    suffix: "DAY",
                    color: Colors.red,
                  ),
                  CountDownText(
                    time: (remaining.inHours % 24).toString(),
                    suffix: "HRS",
                    color: Colors.white,
                  ),
                  CountDownText(
                    time: (remaining.inMinutes % 60).toString(),
                    suffix: "MIN",
                    color: Colors.white,
                  ),
                  CountDownText(
                    time: (remaining.inSeconds % 60).toString(),
                    suffix: "SEC",
                    color: Colors.white,
                  ),
                  RaisedButton(
                    color: Colors.black,
                    child: Text(
                      'Refresh',
                      style: TextStyle(
                          fontWeight: FontWeight.normal, color: Colors.amber),
                    ),
                    onPressed: () {
                      int newdays = x.getInt('new');
                      x.setInt('days', newdays);
                      RestartWidget.restartApp(context);
                    },
                  )
                ],
              );
            })
        : Center(
            child: CircularProgressIndicator(
              backgroundColor: Colors.black,
            ),
          );

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          elevation: 0,
          centerTitle: true,
          backgroundColor: Colors.black,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Container(
                height: 45,
                width: 45,
                child: Image(
                  image: AssetImage('images/logo for the app.png'),
                ),
              ),
              SizedBox(
                width: 10,
              ),
              Text("Counting the part eyes"),
            ],
          ),
        ),
        body: SingleChildScrollView(child: _countDown),
      ),
    );
  }
}
