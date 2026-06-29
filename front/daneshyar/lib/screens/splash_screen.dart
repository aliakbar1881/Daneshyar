import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
// import 'dart:ui' as ui;

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    // انیمیشن مقیاس لوگو
    _scaleController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 800),
    );
    _scaleAnimation = CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    );
    _scaleController.forward();

    // انیمیشن محو شدن کل صفحه
    _fadeController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1200),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeIn),
    );
    _fadeController.forward();

    // رفتن به صفحه اصلی بعد از 2.5 ثانیه با انیمیشن
    Future.delayed(Duration(seconds: 2, milliseconds: 500), () {
      if (mounted) {
        context.go('/home');
      }
    });
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF0F2027),
              Color(0xFF203A43),
              Color(0xFF2C5364),
            ],
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // لوگو با انیمیشن مقیاس
                  ScaleTransition(
                    scale: _scaleAnimation,
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [
                            Colors.cyan.shade300,
                            Colors.blue.shade500,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.blue.withOpacity(0.5),
                            blurRadius: 30,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.auto_awesome,
                        size: 70,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  SizedBox(height: 40),
                  // عنوان با فونت زیبا و سایه
                  ShaderMask(
                    shaderCallback: (bounds) => LinearGradient(
                      colors: [Colors.cyan.shade200, Colors.white],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ).createShader(bounds),
                    child: Text(
                      'دانش‌یار هوشمند',
                      style: TextStyle(
                        fontSize: 34,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.2,
                        fontFamily: 'Vazir',
                        height: 1.3,
                        shadows: [
                          Shadow(
                            blurRadius: 10,
                            color: Colors.black26,
                            offset: Offset(2, 2),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 12),
                  // زیرنویس
                  Text(
                    'همراه هوشمند پژوهش‌های بین‌رشته‌ای',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white70,
                      fontFamily: 'Vazir',
                      letterSpacing: 0.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 60),
                  // اسپینر با رنگ متفاوت
                  SpinKitFadingCircle(
                    color: Colors.cyan.shade200,
                    size: 40,
                  ),
                  SizedBox(height: 20),
                  Text(
                    'بارگذاری سیستم هوشمند...',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.white54,
                      fontFamily: 'Vazir',
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}