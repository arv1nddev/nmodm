import 'nmodm_config.dart';

/// Player enum
enum Player { one, two }

/// Game status
enum GameStatus { playing, won }

/// NMODM Game State
/// 
/// Architectural Decision:
/// - Immutable state object
/// - Contains all information needed to represent game at any point
/// - Can be serialized for persistence
/// - Supports undo/redo (future enhancement)
class NmodmState {
  final NmodmConfig config;
  final int currentPosition;
  final Player currentPlayer;
  final GameStatus status;
  final Player? winner;
  final List<int> moveHistory;

  const NmodmState({
    required this.config,
    required this.currentPosition,
    required this.currentPlayer,
    required this.status,
    this.winner,
    required this.moveHistory,
  });

  /// Initial state factory
  factory NmodmState.initial(NmodmConfig config) {
    return NmodmState(
      config: config,
      currentPosition: config.k,
      currentPlayer: Player.one,
      status: GameStatus.playing,
      winner: null,
      moveHistory: [],
    );
  }

  /// Create state from JSON
  factory NmodmState.fromJson(Map<String, dynamic> json) {
    return NmodmState(
      config: NmodmConfig.fromJson(json['config'] as Map<String, dynamic>),
      currentPosition: json['currentPosition'] as int,
      currentPlayer: Player.values[json['currentPlayer'] as int],
      status: GameStatus.values[json['status'] as int],
      winner: json['winner'] != null
          ? Player.values[json['winner'] as int]
          : null,
      moveHistory: (json['moveHistory'] as List<dynamic>)
          .map((e) => e as int)
          .toList(),
    );
  }

  /// Convert state to JSON
  Map<String, dynamic> toJson() {
    return {
      'config': config.toJson(),
      'currentPosition': currentPosition,
      'currentPlayer': currentPlayer.index,
      'status': status.index,
      'winner': winner?.index,
      'moveHistory': moveHistory,
    };
  }

  /// Get valid moves from current position
  List<int> getValidMoves() {
    if (status != GameStatus.playing) return [];

    final validMoves = <int>[];
    for (int i = 1; i < config.m; i++) {
      final nextPosition = currentPosition + i;
      if (nextPosition <= config.t) {
        validMoves.add(nextPosition);
      }
    }
    return validMoves;
  }

  /// Check if a move is valid
  bool isValidMove(int targetPosition) {
    return getValidMoves().contains(targetPosition);
  }

  /// Apply a move and return new state
  NmodmState applyMove(int targetPosition) {
    if (!isValidMove(targetPosition)) {
      throw ArgumentError('Invalid move: $targetPosition');
    }

    final newMoveHistory = [...moveHistory, targetPosition];
    final reachedTarget = targetPosition == config.t;

    return NmodmState(
      config: config,
      currentPosition: targetPosition,
      currentPlayer: reachedTarget
          ? currentPlayer
          : (currentPlayer == Player.one ? Player.two : Player.one),
      status: reachedTarget ? GameStatus.won : GameStatus.playing,
      winner: reachedTarget ? currentPlayer : null,
      moveHistory: newMoveHistory,
    );
  }

  /// Copy with method for state updates
  NmodmState copyWith({
    NmodmConfig? config,
    int? currentPosition,
    Player? currentPlayer,
    GameStatus? status,
    Player? winner,
    List<int>? moveHistory,
  }) {
    return NmodmState(
      config: config ?? this.config,
      currentPosition: currentPosition ?? this.currentPosition,
      currentPlayer: currentPlayer ?? this.currentPlayer,
      status: status ?? this.status,
      winner: winner ?? this.winner,
      moveHistory: moveHistory ?? this.moveHistory,
    );
  }

  @override
  String toString() {
    return 'NmodmState(pos: $currentPosition, player: $currentPlayer, status: $status)';
  }
}

/// Extension for Player enum
extension PlayerExtension on Player {
  String get displayName => this == Player.one ? 'Player 1' : 'Player 2';
  
  int get number => this == Player.one ? 1 : 2;
}