import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../domain/models/nmodm_config.dart';
import '../domain/models/nmodm_state.dart';
import '../controllers/nmodm_game_controller.dart';
import 'widgets/number_line.dart';
import 'widgets/game_info_panel.dart';

/// NMODM Game Screen
/// 
/// Responsibilities:
/// - Display game board (number line)
/// - Show current player and game status
/// - Handle user interactions
/// - Display win/lose state
class NmodmGameScreen extends ConsumerStatefulWidget {
  final NmodmConfig config;

  const NmodmGameScreen({
    super.key,
    required this.config,
  });

  @override
  ConsumerState<NmodmGameScreen> createState() => _NmodmGameScreenState();
}

class _NmodmGameScreenState extends ConsumerState<NmodmGameScreen> {
  bool _isAnimating = false;

  @override
  Widget build(BuildContext context) {
    final gameState = ref.watch(
      nmodmGameControllerLoadOrCreateProvider(widget.config),
    );
    final controller = ref.read(
      nmodmGameControllerLoadOrCreateProvider(widget.config).notifier,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('NMODM Game'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _showResetDialog(context, controller),
            tooltip: 'Reset Game',
          ),
        ],
      ),
      body: Column(
        children: [
          // Game Info Panel
          GameInfoPanel(
            gameState: gameState,
            isAnimating: _isAnimating,
          ),
          
          const Divider(height: 1),
          
          // Number Line (scrollable game board)
          Expanded(
            child: NumberLine(
              gameState: gameState,
              onSquareTap: (position) => _handleSquareTap(
                context,
                controller,
                gameState,
                position,
              ),
              isAnimating: _isAnimating,
            ),
          ),
          
          // Bottom Action Bar
          if (gameState.status == GameStatus.won)
            _WinnerBanner(
              winner: gameState.winner!,
              onPlayAgain: () => controller.resetGame(),
              onExit: () => context.pop(),
            ),
        ],
      ),
    );
  }

  void _handleSquareTap(
    BuildContext context,
    NmodmGameController controller,
    NmodmState gameState,
    int position,
  ) {
    // Ignore taps during animation or if game is over
    if (_isAnimating || gameState.status != GameStatus.playing) {
      return;
    }

    // Check if move is valid
    if (!gameState.isValidMove(position)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Invalid move!'),
          duration: Duration(seconds: 1),
        ),
      );
      return;
    }

    // Start animation
    setState(() => _isAnimating = true);

    // Make the move
    try {
      controller.makeMove(position);
      
      // End animation after delay
      Future.delayed(const Duration(milliseconds: 600), () {
        if (mounted) {
          setState(() => _isAnimating = false);
          
          // Check for win
          final newState = ref.read(
            nmodmGameControllerLoadOrCreateProvider(widget.config),
          );
          if (newState.status == GameStatus.won) {
            _showWinDialog(context, newState.winner!);
          }
        }
      });
    } catch (e) {
      setState(() => _isAnimating = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  void _showWinDialog(BuildContext context, Player winner) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              Icons.emoji_events,
              color: Colors.amber,
              size: 32,
            ),
            const SizedBox(width: 12),
            const Text('Victory!'),
          ],
        ),
        content: Text(
          '${winner.displayName} wins!',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.pop();
            },
            child: const Text('Exit'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(context).pop();
              ref.read(
                nmodmGameControllerLoadOrCreateProvider(widget.config).notifier,
              ).resetGame();
            },
            child: const Text('Play Again'),
          ),
        ],
      ),
    );
  }

  void _showResetDialog(BuildContext context, NmodmGameController controller) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Game'),
        content: const Text('Are you sure you want to restart the game?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              controller.resetGame();
              Navigator.of(context).pop();
            },
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }
}

class _WinnerBanner extends StatelessWidget {
  final Player winner;
  final VoidCallback onPlayAgain;
  final VoidCallback onExit;

  const _WinnerBanner({
    required this.winner,
    required this.onPlayAgain,
    required this.onExit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.emoji_events,
                  color: Colors.amber,
                  size: 28,
                ),
                const SizedBox(width: 12),
                Text(
                  '${winner.displayName} Wins!',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: onExit,
                    child: const Text('Exit'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: onPlayAgain,
                    child: const Text('Play Again'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}