import 'dart:async';

import 'package:flutter/material.dart';
import 'package:u_driver/Home.dart';

import '../Registration/Log_In.dart';
import '../global.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {


  startTimer() {
    Timer(const Duration(seconds: 3), () async {
      if (await fAuth.currentUser != null) {
        currentFirebaseUser = fAuth.currentUser;
        Navigator.push(
            context, MaterialPageRoute(builder: (_) => const Home(),),);
      } else {
        Navigator.push(
            context, MaterialPageRoute(builder: (_) => const LogIn(),),);
      }
    });
  }

  @override
  void initState() {
    super.initState();

    startTimer();
  }



  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      body: Container(
        height: double.infinity,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.grey,
        ),
        child: Center(
          child: Container(
            child: Image.asset("images/udriver.png"),
          ),
        ),
      ),
    );
  }
}
