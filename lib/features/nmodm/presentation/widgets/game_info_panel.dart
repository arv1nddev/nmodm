import 'package:flutter/material.dart';
import '../../domain/models/nmodm_state.dart';

/// Game Info Panel Widget
/// 
/// Displays:
/// - Current player
/// - Game configuration
/// - Current position
/// - Valid move range
class GameInfoPanel extends StatelessWidget {
  final NmodmState gameState;
  final bool isAnimating;

  const GameInfoPanel({
    super.key,
    required this.gameState,
    required this.isAnimating,
  });

  @override
  Widget build(BuildContext context) {
    final validMoves = gameState.getValidMoves();
    final minMove = validMoves.isNotEmpty ? validMoves.first : null;
    final maxMove = validMoves.isNotEmpty ? validMoves.last : null;

    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Current Player Indicator
          if (gameState.status == GameStatus.playing)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: _getPlayerColor(
                      context,
                      gameState.currentPlayer,
                    ).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: _getPlayerColor(
                        context,
                        gameState.currentPlayer,
                      ),
                      width: 2,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.person,
                        color: _getPlayerColor(
                          context,
                          gameState.currentPlayer,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${gameState.currentPlayer.displayName}\'s Turn',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: _getPlayerColor(
                                context,
                                gameState.currentPlayer,
                              ),
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          
          const SizedBox(height: 16),
          
          // Game Stats
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _StatCard(
                label: 'Current',
                value: '${gameState.currentPosition}',
                icon: Icons.my_location,
              ),
              _StatCard(
                label: 'Target',
                value: '${gameState.config.t}',
                icon: Icons.flag,
              ),
              if (minMove != null && maxMove != null)
                _StatCard(
                  label: 'Valid Range',
                  value: '$minMove-$maxMove',
                  icon: Icons.swap_horiz,
                ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getPlayerColor(BuildContext context, Player player) {
    return player == Player.one
        ? Colors.blue
        : Colors.red;
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(
          icon,
          size: 20,
          color: Theme.of(context).colorScheme.primary,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
      ],
    );
  }
}