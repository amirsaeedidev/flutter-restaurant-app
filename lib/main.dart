import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_colors.dart';
import 'core/theme/theme_provider.dart';
import 'features/auth/providers/auth_provider.dart';
import 'features/cart_and_checkout/providers/cart_provider.dart';
import 'features/discount/providers/discount_provider.dart';
import 'features/loyalty/providers/loyalty_provider.dart';
import 'features/orders/providers/orders_provider.dart';
import 'features/profile/providers/profile_provider.dart';
import 'features/auth/screens/onboarding.dart';
import 'shared/providers/navigation_provider.dart';
import 'features/address/providers/address_provider.dart';
import 'core/services/supabase_service.dart'; // ← اضافه شد
import 'package:flutter_dotenv/flutter_dotenv.dart'; // برای dotenv.load لازم است
import 'features/home/providers/home_provider.dart';
//import 'core/debug/supabase_debug_screen.dart';
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');
  await SupabaseService.initialize(); // ← راه‌اندازی Supabase
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => DiscountProvider()),
        ChangeNotifierProvider(create: (_) => HomeProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => NavigationProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => OrdersProvider()),
        ChangeNotifierProvider(create: (_) => LoyaltyProvider()),
        ChangeNotifierProvider(create: (_) => ProfileProvider()),
        ChangeNotifierProvider(create: (_) => DiscountProvider()),
        ChangeNotifierProvider(create: (_) => AddressProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeMode = context.watch<ThemeProvider>().themeMode;

    return MaterialApp(
      title: 'رستوران آزمایشی',
      debugShowCheckedModeBanner: false,
      themeMode: themeMode,
      theme: ThemeData(
        fontFamily: 'Lalezar',
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
        fontFamily: 'Lalezar',
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
      home: OnboardingScreen(),
    );
  }
}