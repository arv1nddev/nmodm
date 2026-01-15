import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/di/injection_container.dart';
import '../domain/models/nmodm_config.dart';

/// NMODM Mode Selection Screen
/// 
/// Responsibilities:
/// - Allow user to select game mode
/// - Configure custom game parameters
/// - Navigate to game screen
class NmodmModeSelectionScreen extends ConsumerWidget {
  const NmodmModeSelectionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('NMODM'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Select Game Mode',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Expanded(
                child: ListView(
                  children: [
                    _ModeCard(
                      title: 'Standard Mode',
                      description: 'Start at 0, reach 100, add 1-9',
                      icon: Icons.trending_up,
                      onTap: () {
                        final config = NmodmConfig.standard();
                        context.push('/nmodm/game', extra: config);
                      },
                    ),
                    const SizedBox(height: 16),
                    _ModeCard(
                      title: 'Previous Game',
                      description: 'Continue from last saved position',
                      icon: Icons.history,
                      onTap: () {
                        final savedState =
                            localStorageService.getGameState('nmodm');
                        if (savedState != null) {
                          try {
                            final config = NmodmConfig.fromJson(
                              savedState['config'] as Map<String, dynamic>,
                            );
                            context.push('/nmodm/game', extra: config);
                          } catch (e) {
                            _showErrorSnackBar(
                              context,
                              'Could not load saved game',
                            );
                          }
                        } else {
                          _showErrorSnackBar(
                            context,
                            'No saved game found',
                          );
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    _ModeCard(
                      title: 'Custom Mode',
                      description: 'Set your own starting point, target, and range',
                      icon: Icons.tune,
                      onTap: () {
                        _showCustomModeDialog(context);
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _showCustomModeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const _CustomModeDialog(),
    );
  }
}

class _ModeCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final VoidCallback onTap;

  const _ModeCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  size: 32,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurfaceVariant,
                          ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 20,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CustomModeDialog extends StatefulWidget {
  const _CustomModeDialog();

  @override
  State<_CustomModeDialog> createState() => _CustomModeDialogState();
}

class _CustomModeDialogState extends State<_CustomModeDialog> {
  final _formKey = GlobalKey<FormState>();
  final _kController = TextEditingController(text: '0');
  final _mController = TextEditingController(text: '10');
  final _tController = TextEditingController(text: '100');

  @override
  void dispose() {
    _kController.dispose();
    _mController.dispose();
    _tController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Custom Game Configuration'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _kController,
                decoration: const InputDecoration(
                  labelText: 'Starting Number (k)',
                  helperText: 'Initial position',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a starting number';
                  }
                  final k = int.tryParse(value);
                  if (k == null || k < 0) {
                    return 'Must be a non-negative number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _mController,
                decoration: const InputDecoration(
                  labelText: 'Range Limit (m)',
                  helperText: 'Can add 1 to m-1',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a range limit';
                  }
                  final m = int.tryParse(value);
                  if (m == null || m <= 1) {
                    return 'Must be greater than 1';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _tController,
                decoration: const InputDecoration(
                  labelText: 'Target Number (t)',
                  helperText: 'Number to reach',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a target number';
                  }
                  final t = int.tryParse(value);
                  final k = int.tryParse(_kController.text) ?? 0;
                  if (t == null || t <= k) {
                    return 'Must be greater than starting number';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              final config = NmodmConfig(
                k: int.parse(_kController.text),
                m: int.parse(_mController.text),
                t: int.parse(_tController.text),
              );
              
              Navigator.of(context).pop();
              context.push('/nmodm/game', extra: config);
            }
          },
          child: const Text('Start Game'),
        ),
      ],
    );
  }
}