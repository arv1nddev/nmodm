import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/routing/app_router.dart';
import 'core/di/injection_container.dart';

/// Entry point of the application.
/// 
/// Architecture Decision:
/// - Uses Riverpod for state management due to:
///   1. Compile-time safety
///   2. Better testability than Provider
///   3. No BuildContext dependency
///   4. Excellent dev tools support
/// 
/// - ProviderScope wraps the entire app to enable Riverpod functionality
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize dependency injection container
  await setupDependencies();
  
  runApp(
    const ProviderScope(
      child: GameApp(),
    ),
  );
}

class GameApp extends ConsumerWidget {
  const GameApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    
    return MaterialApp.router(
      title: 'NMODM Game',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        cardTheme: CardThemeData(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      routerConfig: router,
    );
  }
}