import 'package:flutter/material.dart';

/// Game Model
/// 
/// Architectural Decision:
/// - Abstract game representation
/// - Extensible for future games
/// - Contains metadata for UI display
class GameInfo {
  final String id;
  final String name;
  final String description;
  final IconData icon;
  final String route;

  const GameInfo({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.route,
  });
}

/// Game Registry
/// 
/// Architectural Decision:
/// - Centralized game registration
/// - Easy to add new games without modifying core logic
/// - Provides discoverable game list
/// - Type-safe game access
class GameRegistry {
  static const GameInfo nmodm = GameInfo(
    id: 'nmodm',
    name: 'NMODM',
    description: 'Two-player number racing game. Be the first to reach the target!',
    icon: Icons.numbers,
    route: '/nmodm',
  );

  // Add more games here in the future:
  // static const GameInfo ticTacToe = GameInfo(...);
  // static const GameInfo chess = GameInfo(...);

  /// Get all available games
  static List<GameInfo> getAllGames() {
    return [
      nmodm,
      // Add more games here
    ];
  }

  /// Get game by ID
  static GameInfo? getGameById(String id) {
    try {
      return getAllGames().firstWhere((game) => game.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Get default game (first in list)
  static GameInfo getDefaultGame() {
    final games = getAllGames();
    return games.isNotEmpty ? games.first : nmodm;
  }
}