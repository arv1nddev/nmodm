import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/di/injection_container.dart';
import '../../../core/domain/game_registry.dart';
import '../controllers/settings_controller.dart';

/// Settings Screen
/// 
/// Responsibilities:
/// - Display and modify app settings
/// - Persist settings changes
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(settingsControllerProvider);
    final controller = ref.read(settingsControllerProvider.notifier);
    final games = GameRegistry.getAllGames();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Game Launch Settings',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 16),
                  SwitchListTile(
                    title: const Text('Always open default game on launch'),
                    subtitle: const Text(
                      'Skip game selection screen when app starts',
                    ),
                    value: state.skipGameSelection,
                    onChanged: (value) {
                      controller.setSkipGameSelection(value);
                    },
                  ),
                  const Divider(),
                  ListTile(
                    title: const Text('Default Game'),
                    subtitle: Text(
                      state.defaultGameId != null
                          ? GameRegistry.getGameById(state.defaultGameId!)
                                  ?.name ??
                              'Unknown'
                          : 'None selected',
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () async {
                      final selected = await showDialog<String>(
                        context: context,
                        builder: (context) => _GameSelectionDialog(
                          games: games,
                          currentGameId: state.defaultGameId,
                        ),
                      );
                      if (selected != null) {
                        controller.setDefaultGame(selected);
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'About',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 16),
                  const ListTile(
                    leading: Icon(Icons.info_outline),
                    title: Text('Version'),
                    subtitle: Text('1.0.0'),
                  ),
                  const ListTile(
                    leading: Icon(Icons.code),
                    title: Text('Architecture'),
                    subtitle: Text('Clean Architecture with Riverpod'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GameSelectionDialog extends StatelessWidget {
  final List<GameInfo> games;
  final String? currentGameId;

  const _GameSelectionDialog({
    required this.games,
    required this.currentGameId,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Select Default Game'),
      content: SizedBox(
        width: double.maxFinite,
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: games.length,
          itemBuilder: (context, index) {
            final game = games[index];
            final isSelected = game.id == currentGameId;
            
            return ListTile(
              leading: Icon(game.icon),
              title: Text(game.name),
              trailing: isSelected
                  ? Icon(
                      Icons.check_circle,
                      color: Theme.of(context).colorScheme.primary,
                    )
                  : null,
              onTap: () => Navigator.of(context).pop(game.id),
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
      ],
    );
  }
}