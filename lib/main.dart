import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:splashscreen/splashscreen.dart';
import 'package:system/map/bloc/bloc.dart';

import 'map/maps.dart';

void main() {
  runApp(new MaterialApp(
    debugShowCheckedModeBanner: false,
    home: new MyApp(),
  ));
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => new _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return new SplashScreen(
      seconds: 10,
      navigateAfterSeconds: new homepage(),
      image: new Image.asset(
        'assets/image/logo.jpg',
      ),
      backgroundColor: Colors.white,
      photoSize: 100.0,
      loaderColor: Colors.red,
    );
  }
}

class homepage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'google maps',
      /// Application goes to maps.dart
      home: BlocProvider(
        create: (BuildContext context) => MapsBloc(),
        child: Maps(),
      ),
    );
  }
}
