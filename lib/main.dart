import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/database_service.dart';
import 'screens/dashboard_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final dbService = DatabaseService();
  await dbService.init();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: dbService),
      ],
      child: const HomeFixApp(),
    ),
  );
}

class HomeFixApp extends StatelessWidget {
  const HomeFixApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HomeFix',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
        ),
      ),
      home: const DashboardScreen(),
    );
  }
}
