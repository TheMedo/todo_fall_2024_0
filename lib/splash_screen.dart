import 'package:flutter/material.dart';
import 'package:todo_fall_2024_0/screen/home/home_screen.dart'; // Import the HomeScreen

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Simulate a delay before navigating to the home screen
    Future.delayed(Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomeScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          Colors.blue, // Choose your splash screen background color
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Display the splash image
            Image.asset(
              'assets/productive_penguin.png', // Path to the image in the assets folder
              width: 200, // Adjust the width and height as needed
              height: 200,
              fit: BoxFit
                  .cover, // Adjust how the image fits within the container
            ),
            SizedBox(height: 20),
            Text(
              'ToDo App',
              style: TextStyle(fontSize: 24, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
