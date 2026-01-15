import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

/// Local Storage Service
/// 
/// Architectural Decision:
/// - Abstracts SharedPreferences to allow easy replacement
/// - Provides type-safe methods for common operations
/// - Uses JSON for complex objects
/// - Centralized storage keys to prevent typos
class LocalStorageService {
  final SharedPreferences _prefs;

  LocalStorageService(this._prefs);

  // Storage Keys
  static const String _keySkipGameSelection = 'skip_game_selection';
  static const String _keyDefaultGame = 'default_game';
  static const String _keyLastGameState = 'last_game_state_';

  // Settings Methods
  Future<bool> setSkipGameSelection(bool value) async {
    return await _prefs.setBool(_keySkipGameSelection, value);
  }

  bool getSkipGameSelection() {
    return _prefs.getBool(_keySkipGameSelection) ?? false;
  }

  Future<bool> setDefaultGame(String gameId) async {
    return await _prefs.setString(_keyDefaultGame, gameId);
  }

  String? getDefaultGame() {
    return _prefs.getString(_keyDefaultGame);
  }

  // Game State Methods
  Future<bool> saveGameState(String gameId, Map<String, dynamic> state) async {
    final key = '$_keyLastGameState$gameId';
    final jsonString = jsonEncode(state);
    return await _prefs.setString(key, jsonString);
  }

  Map<String, dynamic>? getGameState(String gameId) {
    final key = '$_keyLastGameState$gameId';
    final jsonString = _prefs.getString(key);
    if (jsonString == null) return null;
    
    try {
      return jsonDecode(jsonString) as Map<String, dynamic>;
    } catch (e) {
      return null;
    }
  }

  Future<bool> clearGameState(String gameId) async {
    final key = '$_keyLastGameState$gameId';
    return await _prefs.remove(key);
  }

  // Generic Methods
  Future<bool> setString(String key, String value) async {
    return await _prefs.setString(key, value);
  }

  String? getString(String key) {
    return _prefs.getString(key);
  }

  Future<bool> setInt(String key, int value) async {
    return await _prefs.setInt(key, value);
  }

  int? getInt(String key) {
    return _prefs.getInt(key);
  }

  Future<bool> setBool(String key, bool value) async {
    return await _prefs.setBool(key, value);
  }

  bool? getBool(String key) {
    return _prefs.getBool(key);
  }

  Future<bool> remove(String key) async {
    return await _prefs.remove(key);
  }

  Future<bool> clear() async {
    return await _prefs.clear();
  }
}