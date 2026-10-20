import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'pages/splash_page.dart';
import 'providers/clubwear_provider.dart';
import 'widgets/common_widgets.dart';

void main() {
  runApp(const ClubwearApp());
}

class ClubwearApp extends StatelessWidget {
  const ClubwearApp({super.key});

  @override
  Widget build(BuildContext context) {
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        brightness: Brightness.light,
      ).copyWith(
        primary: AppColors.primary,
        onPrimary: Colors.white,
        secondary: AppColors.gold,
        surface: Colors.white,
        onSurface: AppColors.primary,
      ),
    );

    return ChangeNotifierProvider(
      create: (_) => ClubwearProvider(),
      child: MaterialApp(
        title: 'Clubwear',
        debugShowCheckedModeBanner: false,
        theme: base.copyWith(
          scaffoldBackgroundColor: AppColors.background,
          iconTheme: const IconThemeData(color: AppColors.primary),
          textTheme: base.textTheme.apply(
            bodyColor: AppColors.primary,
            displayColor: AppColors.primary,
          ),
          appBarTheme: const AppBarTheme(
            backgroundColor: AppColors.background,
            surfaceTintColor: Colors.transparent,
            foregroundColor: AppColors.primary,
            elevation: 0,
          ),
          snackBarTheme: SnackBarThemeData(
            behavior: SnackBarBehavior.floating,
            backgroundColor: AppColors.primary,
            actionTextColor: AppColors.gold,
            contentTextStyle:
            const TextStyle(color: Colors.white, fontSize: 13),
            shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
          dialogTheme: DialogThemeData(
            backgroundColor: Colors.white,
            shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          ),
        ),
        home: const SplashPage(),
      ),
    );
  }
}