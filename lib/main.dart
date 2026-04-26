import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/storage_service.dart';
import 'services/app_provider.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final storageService = StorageService();
  final appProvider = AppProvider(storageService);
  await appProvider.init();

  runApp(MyApp(appProvider: appProvider));
}

class MyApp extends StatelessWidget {
  final AppProvider appProvider;

  const MyApp({super.key, required this.appProvider});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: appProvider,
      child: MaterialApp(
        title: '麻雀点数記録',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
          useMaterial3: true,
        ),
        home: const HomeScreen(),
      ),
    );
  }
}
