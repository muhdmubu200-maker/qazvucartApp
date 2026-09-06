import 'package:flutter/material.dart';

class AppConfig {
    const AppConfig._();
    
    static const String appName = 'QazvuCart';
    
    static const String productionUrl = "https://qazvucart.onrender.com";
    
    static const String allowedHost = "qazvucart.onrender.com";
    
    static const Duration connectionTimeout = Duration(seconds: 50);
    
    static const Duration splashDuration = Duration(milliseconds: 900);
    
    static const Color primaryColor = Color(0xFFFFD21F);
    
    static const Color backgroundColor = Color(0xFFF7F7F7);
    
    static const Color darkColor = Color(0xFF111111);
}