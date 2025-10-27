import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import '../providers/history_provider.dart';
import 'new_game_screen.dart';
import 'game_screen.dart';
import 'history_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Canastracker'),
        centerTitle: true,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Logo/Header section
              Card(
                color: Theme.of(context).colorScheme.primaryContainer,
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    children: [
                      Icon(
                        Icons.style,
                        size: 64,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Canastra',
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Acompanhe suas partidas',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context).colorScheme.onPrimaryContainer,
                            ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Check if there's a game in progress
              Consumer<GameProvider>(
                builder: (context, gameProvider, child) {
                  if (gameProvider.currentGame != null &&
                      gameProvider.currentGame!.status.toString() == 'GameStatus.inProgress') {
                    return Card(
                      color: Theme.of(context).colorScheme.secondaryContainer,
                      child: ListTile(
                        leading: const Icon(Icons.timer),
                        title: const Text('Partida em Andamento'),
                        subtitle: Text(
                          'Iniciado há ${_formatDateTime(gameProvider.currentGame!.startTime)}',
                        ),
                        trailing: const Icon(Icons.arrow_forward_ios),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const GameScreen(),
                            ),
                          );
                        },
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),

              const SizedBox(height: 16),

              // Main menu buttons
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _MenuButton(
                      icon: Icons.add_circle,
                      label: 'Nova Partida',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const NewGameScreen(),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    _MenuButton(
                      icon: Icons.history,
                      label: 'Histórico',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const HistoryScreen(),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    _MenuButton(
                      icon: Icons.people,
                      label: 'Gerenciar Jogadores',
                      onTap: () {
                        _showManagePlayersDialog(context);
                      },
                    ),
                  ],
                ),
              ),

              // Stats summary
              Consumer<HistoryProvider>(
                builder: (context, historyProvider, child) {
                  final totalGames = historyProvider.completedGames.length;
                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _StatItem(
                            label: 'Partida',
                            value: totalGames.toString(),
                          ),
                          _StatItem(
                            label: 'Em Andamento',
                            value: historyProvider.inProgressGames.length.toString(),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m atrás';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h atrás';
    } else {
      return '${difference.inDays}d atrás';
    }
  }

  void _showManagePlayersDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const _ManagePlayersDialog(),
    );
  }
}

class _MenuButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _MenuButton({
    required this.icon,
    required this.label,
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
              Icon(icon, size: 32),
              const SizedBox(width: 16),
              Text(
                label,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const Spacer(),
              const Icon(Icons.arrow_forward_ios),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;

  const _StatItem({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}

class _ManagePlayersDialog extends StatefulWidget {
  const _ManagePlayersDialog();

  @override
  State<_ManagePlayersDialog> createState() => _ManagePlayersDialogState();
}

class _ManagePlayersDialogState extends State<_ManagePlayersDialog> {
  final _nameController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Gerenciar Jogadores'),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Nome do Jogador',
                border: OutlineInputBorder(),
              ),
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: () async {
                if (_nameController.text.isNotEmpty) {
                  await context.read<GameProvider>().createPlayer(_nameController.text);
                  _nameController.clear();
                }
              },
              icon: const Icon(Icons.add),
              label: const Text('Adicionar Jogador'),
            ),
            const SizedBox(height: 16),
            const Divider(),
            Expanded(
              child: Consumer<GameProvider>(
                builder: (context, gameProvider, child) {
                  return ListView.builder(
                    shrinkWrap: true,
                    itemCount: gameProvider.availablePlayers.length,
                    itemBuilder: (context, index) {
                      final player = gameProvider.availablePlayers[index];
                      return ListTile(
                        title: Text(player.name),
                        subtitle: Text('Partidas: ${player.gamesPlayed} | Vitórias: ${player.gamesWon}'),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () async {
                            await gameProvider.deletePlayer(player.id);
                          },
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Fechar'),
        ),
      ],
    );
  }
}
