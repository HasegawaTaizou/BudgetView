import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'screen_wrapper_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => ScreenWrapperScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;

    double positionFromTop = screenHeight * 0.3;

    return Scaffold(
      body: Align(
        alignment: Alignment.topCenter,
        child: Padding(
          padding: EdgeInsets.only(top: positionFromTop),
          child: SvgPicture.asset('assets/images/budget-view-logo.svg'),
        ),
      ),
    );
  }
}
