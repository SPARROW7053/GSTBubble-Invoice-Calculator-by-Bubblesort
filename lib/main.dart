import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'core/theme/app_theme.dart';
import 'core/providers/gst_calculator_provider.dart';
import 'core/providers/invoice_provider.dart';
import 'core/providers/business_provider.dart';
import 'core/providers/theme_provider.dart';
import 'core/services/database_service.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive
  await Hive.initFlutter();
  
  // Initialize database service
  final dbService = DatabaseService();
  await dbService.initialize();

  // Set preferred orientations (skip on web)
  if (!kIsWeb) {
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => GstCalculatorProvider()),
        ChangeNotifierProvider(create: (_) => InvoiceProvider(dbService)),
        ChangeNotifierProvider(create: (_) => BusinessProvider(dbService)),
      ],
      child: const GstInvoiceProApp(),
    ),
  );
}

class GstInvoiceProApp extends StatelessWidget {
  const GstInvoiceProApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          title: 'GSTBubble — Invoice & Calculator by Bubblesort',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeProvider.themeMode,
          home: const HomeScreen(),
        );
      },
    );
  }
}
