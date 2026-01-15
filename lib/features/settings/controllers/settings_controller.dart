import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/di/injection_container.dart';

/// Settings State
/// 
/// Architectural Decision:
/// - Immutable state class
/// - Simple data holder
class SettingsState {
  final bool skipGameSelection;
  final String? defaultGameId;

  const SettingsState({
    required this.skipGameSelection,
    this.defaultGameId,
  });

  SettingsState copyWith({
    bool? skipGameSelection,
    String? defaultGameId,
  }) {
    return SettingsState(
      skipGameSelection: skipGameSelection ?? this.skipGameSelection,
      defaultGameId: defaultGameId ?? this.defaultGameId,
    );
  }
}

/// Settings Controller
/// 
/// Responsibilities:
/// - Manage settings state
/// - Persist settings to local storage
/// - Provide state to UI
/// 
/// Architectural Decision:
/// - Uses StateNotifier for simple state management
/// - Direct access to storage service
/// - Synchronous state updates with async persistence
class SettingsController extends StateNotifier<SettingsState> {
  SettingsController() : super(_loadInitialState());

  static SettingsState _loadInitialState() {
    return SettingsState(
      skipGameSelection: localStorageService.getSkipGameSelection(),
      defaultGameId: localStorageService.getDefaultGame(),
    );
  }

  void setSkipGameSelection(bool value) {
    state = state.copyWith(skipGameSelection: value);
    localStorageService.setSkipGameSelection(value);
  }

  void setDefaultGame(String gameId) {
    state = state.copyWith(defaultGameId: gameId);
    localStorageService.setDefaultGame(gameId);
  }

  void refresh() {
    state = _loadInitialState();
  }
}

/// Settings Controller Provider
final settingsControllerProvider =
    StateNotifierProvider<SettingsController, SettingsState>((ref) {
  return SettingsController();
});