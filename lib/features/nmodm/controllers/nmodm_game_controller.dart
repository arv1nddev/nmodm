import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/di/injection_container.dart';
import '../domain/models/nmodm_config.dart';
import '../domain/models/nmodm_state.dart';
import '../domain/nmodm_game_engine.dart';

/// NMODM Game Controller
/// 
/// Responsibilities:
/// - Manage game state
/// - Handle user moves
/// - Persist game state
/// - Coordinate between UI and game engine
/// 
/// Architectural Decision:
/// - Uses StateNotifier for reactive state management
/// - All game logic delegated to engine (separation of concerns)
/// - Auto-saves game state after each move
class NmodmGameController extends StateNotifier<NmodmState> {
  static const String _gameId = 'nmodm';

  NmodmGameController(NmodmConfig config)
      : super(NmodmGameEngine.createGame(config));

  /// Load saved game or create new one
  factory NmodmGameController.loadOrCreate(NmodmConfig config) {
    final savedState = localStorageService.getGameState(_gameId);
    
    if (savedState != null) {
      try {
        final restoredState = NmodmGameEngine.restoreGame(savedState);
        // Only restore if configuration matches
        if (restoredState.config == config) {
          return NmodmGameController._(restoredState);
        }
      } catch (e) {
        // If restoration fails, create new game
      }
    }
    
    return NmodmGameController(config);
  }

  NmodmGameController._(NmodmState initialState) : super(initialState);

  /// Make a move
  void makeMove(int targetPosition) {
    try {
      final newState = NmodmGameEngine.makeMove(state, targetPosition);
      state = newState;
      _saveGameState();
    } catch (e) {
      // Invalid move - state remains unchanged
      // UI should prevent invalid moves, but this is a safety net
      rethrow;
    }
  }

  /// Reset game
  void resetGame() {
    state = NmodmGameEngine.resetGame(state);
    _saveGameState();
  }

  /// Start new game with different config
  void startNewGame(NmodmConfig config) {
    state = NmodmGameEngine.createGame(config);
    _saveGameState();
  }

  /// Clear saved game state
  void clearSavedState() {
    localStorageService.clearGameState(_gameId);
  }

  /// Save current game state
  void _saveGameState() {
    localStorageService.saveGameState(_gameId, state.toJson());
  }

  /// Get valid moves for current position
  List<int> getValidMoves() {
    return NmodmGameEngine.getValidMoves(state);
  }

  /// Check if player can win in one move
  bool canWinInOneMove() {
    return NmodmGameEngine.canWinInOneMove(state);
  }
}

/// Provider family for creating game controllers with different configs
final nmodmGameControllerProvider = StateNotifierProvider.family<
    NmodmGameController, NmodmState, NmodmConfig>(
  (ref, config) => NmodmGameController(config),
);

/// Provider for loading or creating game with saved state
final nmodmGameControllerLoadOrCreateProvider = StateNotifierProvider.family<
    NmodmGameController, NmodmState, NmodmConfig>(
  (ref, config) => NmodmGameController.loadOrCreate(config),
);