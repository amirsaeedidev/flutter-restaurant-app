import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_colors.dart';
import 'main_wrapper.dart';
import 'shared/providers/navigation_provider.dart';

void main() {
  runApp(
    // راه‌اندازی MultiProvider برای مدیریت تمام وضعیت‌های برنامه
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => NavigationProvider()),
        // پروایدرهای سبد خرید و ... بعداً اینجا اضافه میشن
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Restaurant App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.light,
        primaryColor: AppColors.primary,
        scaffoldBackgroundColor: AppColors.lightBackground,
        colorScheme: ColorScheme.light(
          primary: AppColors.primary,
          secondary: AppColors.secondary,
          surface: AppColors.lightSurface,
        ),
        cardColor: AppColors.lightSurface,
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: AppColors.lightText),
          bodyMedium: TextStyle(color: AppColors.lightTextSecondary),
        ),
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: AppColors.primary,
        scaffoldBackgroundColor: AppColors.darkBackground,
        colorScheme: ColorScheme.dark(
          primary: AppColors.primary,
          secondary: AppColors.secondary,
          surface: AppColors.darkSurface,
        ),
        cardColor: AppColors.darkSurface,
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: AppColors.darkText),
          bodyMedium: TextStyle(color: AppColors.darkTextSecondary),
        ),
      ),
      themeMode: ThemeMode.system,
      home: const MainWrapper(),
    );
  }
}
