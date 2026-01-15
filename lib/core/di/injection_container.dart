import 'package:shared_preferences/shared_preferences.dart';
import '../data/local/local_storage_service.dart';

/// Dependency Injection Container
/// 
/// Architectural Decision:
/// - Uses static getters for singleton access
/// - Initialized at app startup
/// - Provides centralized access to core services
/// - Allows easy mocking for testing
late final LocalStorageService localStorageService;

Future<void> setupDependencies() async {
  // Initialize SharedPreferences
  final prefs = await SharedPreferences.getInstance();
  
  // Initialize LocalStorageService
  localStorageService = LocalStorageService(prefs);
}