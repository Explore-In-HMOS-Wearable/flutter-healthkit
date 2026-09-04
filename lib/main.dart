import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_healthkit/core/navigation/navigation.dart';
import 'package:flutter_healthkit/core/theme.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final appRouter = AppRouter();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load();
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'HEALTHKIT',
      theme: AppTheme.light,
      routerConfig: appRouter.config(),
    );
  }
}
