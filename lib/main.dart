import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_ecommerce/routing/app_router.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await dotenv.load(fileName: ".env");
    print(".env file loaded successfully.");
  } catch (e) {
    print("Error loading .env file: $e");
  }

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goRouter = ref.watch(goRouterProvider);

    return MaterialApp.router(
      title: 'Flutter E-commerce',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        colorScheme:
            ColorScheme.fromSwatch(primarySwatch: Colors.blue).copyWith(
          secondary: Colors.blue,
        ),
        useMaterial3: true,
      ),
      routerConfig: goRouter,
      debugShowCheckedModeBanner: false,
    );
  }
}
