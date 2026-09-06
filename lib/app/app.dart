import 'package:flutter/material.dart';

import '../config/app_config.dart';
import '../features/splash/splash_screen.dart';

class QazvuCart extends StatelessWidget {
  const QazvuCart({super.key});

  @override
  Widget build(BuildContext context) {

    return MaterialApp(
      debugShowCheckedModeBanner: false,

      title: AppConfig.appName,

      theme: ThemeData(
        useMaterial3: true,

        scaffoldBackgroundColor:
            Colors.white,

        colorScheme:
            ColorScheme.fromSeed(
          seedColor:
              AppConfig.primaryColor,

          brightness:
              Brightness.light,
        ),

        splashFactory:
            NoSplash.splashFactory,

        highlightColor:
            Colors.transparent,
      ),

      home:
          const SplashScreen(),
    );
  }
}