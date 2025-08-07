import 'package:flutter/material.dart';
import 'dart:async';
import 'login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _offsetAnimation;
  bool _showSplash = true;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );
    _offsetAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0, -1.2),
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    Timer(const Duration(milliseconds: 900), () {
      _controller.forward();
      Future.delayed(const Duration(milliseconds: 700), () {
        setState(() {
          _showSplash = false;
        });
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Login screen behind
          LoginScreen(),
          // Splash screen on top with animation
          if (_showSplash)
            SlideTransition(
              position: _offsetAnimation,
              child: Container(
                color: Colors.white,
                child: Center(
                  child: Image.asset(
                    'assets/Logo.png',
                    height: 160,
                    width: 160,
                    fit: BoxFit.contain,
                  ),
                  // To use the network image instead, uncomment below:
                  // Image.network(
                  //   'https://i.postimg.cc/KvpdmxD1/Logo.png',
                  //   height: 160,
                  //   width: 160,
                  //   fit: BoxFit.contain,
                  // ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
