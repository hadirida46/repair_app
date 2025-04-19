import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'sign_in.dart';

class SplashScreen extends StatefulWidget {
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    Future.delayed(Duration(seconds: 4), () {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          transitionDuration: Duration(milliseconds: 700),
          pageBuilder: (_, __, ___) => SignIn(),
          transitionsBuilder: (_, animation, __, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        ),
      );
    });
  }

  final Color primaryOrange = Color(0xFFFF6F00);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.indigo[900],
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Circular logo with Lottie and fallback
            Container(
              width: 130,
              height: 130,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.black, width: 3),
              ),
              child: ClipOval(
                child: Lottie.asset(
                  'assets/Logo.json',
                  fit: BoxFit.cover,
                  frameBuilder: (context, child, composition) {
                    // If Lottie hasn't loaded yet, show the fallback image
                    if (composition == null) {
                      return Image.asset('assets/Logo.png', fit: BoxFit.cover);
                    }
                    return child;
                  },
                ),
              ),
            ),
            SizedBox(height: 30),

            // Big creative quote
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30.0),
              child: Text(
                "Home or office,\n we've got your back",
                style: TextStyle(
                  fontFamily: 'Lobster',
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: primaryOrange,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
