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

  final List<NmodmState> _past = [];
  final List<NmodmState> _future = [];

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

      _past.add(state);   // save snapshot
      _future.clear();    // invalidate redo history

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
    _past.clear();
    _future.clear();

    state = NmodmGameEngine.resetGame(state);
    _saveGameState();
  }

  /// Start new game with different config
  void startNewGame(NmodmConfig config) {
    _past.clear();
    _future.clear();

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

  //undo game state
  void undo() {
    if (!canUndo) return;

    _future.add(state);
    state = _past.removeLast();

    _saveGameState();
  }

  //redo game state
  void redo() {
    if (!canRedo) return;

    _past.add(state);
    state = _future.removeLast();

    _saveGameState();
  }


  /// Get valid moves for current position
  List<int> getValidMoves() {
    return NmodmGameEngine.getValidMoves(state);
  }

  /// Check if player can win in one move
  bool canWinInOneMove() {
    return NmodmGameEngine.canWinInOneMove(state);
  }

  // bool canUndo(){
  //   return _past.isNotEmpty;
  // }

  // bool canRedo(){
  //   return _future.isNotEmpty;
  // }

  bool get canUndo => _past.isNotEmpty;
  bool get canRedo => _future.isNotEmpty;


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