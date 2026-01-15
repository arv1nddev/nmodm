import 'package:flutter/material.dart';
import '../../domain/models/nmodm_state.dart';

/// Number Line Widget
/// 
/// Responsibilities:
/// - Display horizontal scrollable number line
/// - Show all numbers from start to target
/// - Highlight valid/invalid squares
/// - Display pawn at current position
/// - Handle tap interactions
class NumberLine extends StatefulWidget {
  final NmodmState gameState;
  final Function(int) onSquareTap;
  final bool isAnimating;

  const NumberLine({
    super.key,
    required this.gameState,
    required this.onSquareTap,
    required this.isAnimating,
  });

  @override
  State<NumberLine> createState() => _NumberLineState();
}

class _NumberLineState extends State<NumberLine> {
  final ScrollController _scrollController = ScrollController();
  static const double _squareSize = 70.0;
  static const double _squareSpacing = 8.0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToCurrentPosition(animated: false);
    });
  }

  @override
  void didUpdateWidget(NumberLine oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.gameState.currentPosition != widget.gameState.currentPosition) {
      _scrollToCurrentPosition(animated: true);
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToCurrentPosition({required bool animated}) {
    if (!_scrollController.hasClients) return;

    final position = widget.gameState.currentPosition;
    final targetOffset = (position - widget.gameState.config.k) * 
        (_squareSize + _squareSpacing) - 
        (MediaQuery.of(context).size.width / 2) + 
        (_squareSize / 2);

    if (animated) {
      _scrollController.animateTo(
        targetOffset.clamp(
          0.0,
          _scrollController.position.maxScrollExtent,
        ),
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    } else {
      _scrollController.jumpTo(
        targetOffset.clamp(
          0.0,
          _scrollController.position.maxScrollExtent,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final validMoves = widget.gameState.getValidMoves();
    final numbers = List.generate(
      widget.gameState.config.t - widget.gameState.config.k + 1,
      (index) => widget.gameState.config.k + index,
    );

    return Container(
      color: Theme.of(context).colorScheme.surfaceContainerLowest,
      child: SingleChildScrollView(
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(
          horizontal: MediaQuery.of(context).size.width / 2 - _squareSize / 2,
          vertical: 32,
        ),
        child: Row(
          children: numbers.map((number) {
            final isCurrentPosition = number == widget.gameState.currentPosition;
            final isTarget = number == widget.gameState.config.t;
            final isValidMove = validMoves.contains(number);
            final isEnabled = isValidMove && 
                widget.gameState.status == GameStatus.playing &&
                !widget.isAnimating;

            return Padding(
              padding: EdgeInsets.only(
                right: number == numbers.last ? 0 : _squareSpacing,
              ),
              child: _NumberSquare(
                number: number,
                isCurrentPosition: isCurrentPosition,
                isTarget: isTarget,
                isValidMove: isValidMove,
                isEnabled: isEnabled,
                onTap: () => widget.onSquareTap(number),
                currentPlayer: widget.gameState.currentPlayer,
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

class _NumberSquare extends StatelessWidget {
  final int number;
  final bool isCurrentPosition;
  final bool isTarget;
  final bool isValidMove;
  final bool isEnabled;
  final VoidCallback onTap;
  final Player currentPlayer;

  const _NumberSquare({
    required this.number,
    required this.isCurrentPosition,
    required this.isTarget,
    required this.isValidMove,
    required this.isEnabled,
    required this.onTap,
    required this.currentPlayer,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isEnabled ? onTap : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 70,
        height: 70,
        decoration: BoxDecoration(
          color: _getBackgroundColor(context),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _getBorderColor(context),
            width: isCurrentPosition ? 3 : 2,
          ),
          boxShadow: [
            if (isValidMove && isEnabled)
              BoxShadow(
                color: _getPlayerColor(context).withOpacity(0.3),
                blurRadius: 8,
                spreadRadius: 1,
              ),
          ],
        ),
        child: Stack(
          children: [
            // Number
            Center(
              child: Text(
                '$number',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: isCurrentPosition || isTarget
                          ? FontWeight.bold
                          : FontWeight.w600,
                      color: _getTextColor(context),
                    ),
              ),
            ),
            
            // Target Flag Icon
            if (isTarget)
              Positioned(
                top: 4,
                right: 4,
                child: Icon(
                  Icons.flag,
                  size: 16,
                  color: Colors.amber,
                ),
              ),
            
            // Pawn at current position
            if (isCurrentPosition)
              Positioned(
                bottom: 4,
                left: 0,
                right: 0,
                child: Center(
                  child: Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: _getPlayerColor(context),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white,
                        width: 2,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        '${currentPlayer.number}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Color _getBackgroundColor(BuildContext context) {
    if (isTarget) {
      return Colors.amber.withOpacity(0.2);
    }
    if (isCurrentPosition) {
      return _getPlayerColor(context).withOpacity(0.1);
    }
    if (isValidMove && isEnabled) {
      return _getPlayerColor(context).withOpacity(0.05);
    }
    return Theme.of(context).colorScheme.surfaceContainerHighest;
  }

  Color _getBorderColor(BuildContext context) {
    if (isTarget) {
      return Colors.amber;
    }
    if (isCurrentPosition) {
      return _getPlayerColor(context);
    }
    if (isValidMove && isEnabled) {
      return _getPlayerColor(context).withOpacity(0.5);
    }
    return Theme.of(context).colorScheme.outline.withOpacity(0.3);
  }

  Color _getTextColor(BuildContext context) {
    if (isCurrentPosition || (isValidMove && isEnabled)) {
      return Theme.of(context).colorScheme.onSurface;
    }
    return Theme.of(context).colorScheme.onSurfaceVariant;
  }

  Color _getPlayerColor(BuildContext context) {
    return currentPlayer == Player.one ? Colors.blue : Colors.red;
  }
}