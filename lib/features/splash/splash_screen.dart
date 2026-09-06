import 'dart:async';
import 'package:flutter/material.dart';
import '../../config/app_config.dart';
import '../webview/webview_screen.dart';

class SplashScreen extends StatefulWidget{
  const SplashScreen({super.key});
  
  @override
  State<SplashScreen> createState() => _SplashScreenState() ;
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;
  late final Animation<double> _fadeAnimation;
    
  @override
  void initState() {
    super.initState();
    
    _controller = AnimationController(
      vsync: this, // Fixed typo here
      duration: const Duration(milliseconds: 700),
    );
    
    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
    );
    
    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    );
    
    _controller.forward();
    
    Timer(
      AppConfig.splashDuration,
      _openApp,
    );
  }
  
    void _openApp() {
    if(!mounted) return;
    
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_,__,___) => const WebViewScreen(),
        transitionDuration: const Duration(milliseconds: 350),
        transitionsBuilder: (_, animation, __, child) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
      ),
    );
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
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: ScaleTransition( // Nested as a child, not a separate parameter
            scale: _scaleAnimation,
            child: Image.asset(
              'assets/images/splash_screen.png',
              width: 150,
              height: 150,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return const SizedBox(
                  width: 150,
                  height: 150,
                  child: Icon(
                    Icons.shopping_bag_rounded,
                    size: 80,
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
