import 'models/nmodm_config.dart';
import 'models/nmodm_state.dart';

/// NMODM Game Engine
/// 
/// Architectural Decision:
/// - Pure business logic, no UI dependencies
/// - Stateless - all operations return new state
/// - Fully deterministic and testable
/// - Validates all moves
/// 
/// Responsibilities:
/// - Game rule enforcement
/// - Move validation
/// - State transitions
/// - Win condition checking
class NmodmGameEngine {
  /// Create initial game state
  static NmodmState createGame(NmodmConfig config) {
    if (!config.isValid()) {
      throw ArgumentError('Invalid configuration: ${config.getValidationError()}');
    }
    return NmodmState.initial(config);
  }

  /// Execute a move
  /// 
  /// Returns new state if move is valid, throws ArgumentError otherwise
  static NmodmState makeMove(NmodmState currentState, int targetPosition) {
    // Validate game is still in progress
    if (currentState.status != GameStatus.playing) {
      throw ArgumentError('Game is already finished');
    }

    // Validate move is within allowed range
    final minMove = currentState.currentPosition + 1;
    final maxMove = currentState.currentPosition + currentState.config.m - 1;

    if (targetPosition < minMove || targetPosition > maxMove) {
      throw ArgumentError(
        'Invalid move. Must be between $minMove and $maxMove',
      );
    }

    // Validate move doesn't exceed target
    if (targetPosition > currentState.config.t) {
      throw ArgumentError(
        'Invalid move. Cannot exceed target ${currentState.config.t}',
      );
    }

    // Apply the move
    return currentState.applyMove(targetPosition);
  }

  /// Get all valid moves for current state
  static List<int> getValidMoves(NmodmState state) {
    return state.getValidMoves();
  }

  /// Check if game is finished
  static bool isGameFinished(NmodmState state) {
    return state.status == GameStatus.won;
  }

  /// Get winner if game is finished
  static Player? getWinner(NmodmState state) {
    return state.winner;
  }

  /// Reset game with same configuration
  static NmodmState resetGame(NmodmState state) {
    return NmodmState.initial(state.config);
  }

  /// Create game from saved state
  static NmodmState restoreGame(Map<String, dynamic> savedState) {
    try {
      return NmodmState.fromJson(savedState);
    } catch (e) {
      throw ArgumentError('Invalid saved state format');
    }
  }

  /// Calculate if current player can win in one move
  static bool canWinInOneMove(NmodmState state) {
    if (state.status != GameStatus.playing) return false;
    
    final validMoves = getValidMoves(state);
    return validMoves.contains(state.config.t);
  }

  /// Get optimal move (for AI - future enhancement)
  /// Returns null if no winning strategy is known
  static int? getOptimalMove(NmodmState state) {
    // This is a placeholder for AI logic
    // Can implement winning strategy calculation here
    // For now, returns null (no AI)
    return null;
  }
}