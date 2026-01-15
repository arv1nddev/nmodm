import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/domain/game_registry.dart';

/// Game Selection Screen
/// 
/// Responsibilities:
/// - Display available games
/// - Navigate to selected game
/// - Access to settings
class GameSelectionScreen extends ConsumerWidget {
  const GameSelectionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final games = GameRegistry.getAllGames();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Select a Game'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: games.isEmpty
              ? Center(
                  child: Text(
                    'No games available',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                )
              : GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 0.85,
                  ),
                  itemCount: games.length,
                  itemBuilder: (context, index) {
                    final game = games[index];
                    return _GameCard(game: game);
                  },
                ),
        ),
      ),
    );
  }
}

class _GameCard extends StatelessWidget {
  final GameInfo game;

  const _GameCard({required this.game});

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => context.push(game.route),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                game.icon,
                size: 64,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 16),
              Text(
                game.name,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Expanded(
                child: Text(
                  game.description,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                  textAlign: TextAlign.center,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}