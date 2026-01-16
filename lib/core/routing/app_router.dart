import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/splash/presentation/splash_screen.dart';
import '../../features/game_selection/presentation/game_selection_screen.dart';
import '../../features/settings/presentation/settings_screen.dart';
import '../../features/nmodm/presentation/nmodm_mode_selection_screen.dart';
import '../../features/nmodm/presentation/nmodm_game_screen.dart';
import '../../features/nmodm/domain/models/nmodm_config.dart';

/// Routing Configuration
/// 
/// Architectural Decision:
/// - Uses go_router for declarative routing
/// - Type-safe route definitions
/// - Centralized route management
/// - Supports deep linking (future enhancement)
final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/splash',
    routes: [
      GoRoute(
        path: '/splash',
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/game-selection',
        name: 'game-selection',
        builder: (context, state) => const GameSelectionScreen(),
      ),
      GoRoute(
        path: '/settings',
        name: 'settings',
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: '/nmodm',
        name: 'nmodm',
        builder: (context, state) => const NmodmModeSelectionScreen(),
      ),
      GoRoute(
        path: '/nmodm/game',
        name: 'nmodm-game',
        builder: (context, state) {
          final config = state.extra as NmodmConfig;
          return NmodmGameScreen(config: config);
        },
      ),
    ],
  );
});

/// Route Names (for type-safe navigation)
class AppRoutes {
  static const splash = '/splash';
  static const gameSelection = '/game-selection';
  static const settings = '/settings';
  static const nmodm = '/nmodm';
  static const nmodmGame = '/nmodm/game';
}