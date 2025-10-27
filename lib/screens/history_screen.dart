import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/history_provider.dart';
import '../providers/game_provider.dart';
import '../models/game.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  bool _showCompleted = true;
  bool _showInProgress = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HistoryProvider>().loadGames();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Histórico'),
        actions: [
          PopupMenuButton(
            itemBuilder: (context) => [
              CheckedPopupMenuItem(
                checked: _showCompleted,
                value: 'completed',
                child: const Text('Completas'),
              ),
              CheckedPopupMenuItem(
                checked: _showInProgress,
                value: 'in_progress',
                child: const Text('Em Andamento'),
              ),
            ],
            onSelected: (value) {
              setState(() {
                if (value == 'completed') {
                  _showCompleted = !_showCompleted;
                } else {
                  _showInProgress = !_showInProgress;
                }
              });
            },
          ),
        ],
      ),
      body: Consumer<HistoryProvider>(
        builder: (context, historyProvider, child) {
          if (historyProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final games = historyProvider.games.where((game) {
            if (game.status == GameStatus.completed && !_showCompleted) {
              return false;
            }
            if (game.status == GameStatus.inProgress && !_showInProgress) {
              return false;
            }
            return true;
          }).toList();

          if (games.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.history,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Nenhuma partida',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.grey,
                        ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: games.length,
            itemBuilder: (context, index) {
              final game = games[index];
              return _GameCard(
                game: game,
                onDelete: () async {
                  await historyProvider.deleteGame(game.id);
                  // Also clear the current game in GameProvider if it matches
                  context.read<GameProvider>().clearGameIfMatches(game.id);
                },
              );
            },
          );
        },
      ),
    );
  }
}

class _GameCard extends StatelessWidget {
  final Game game;
  final VoidCallback onDelete;

  const _GameCard({
    required this.game,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final scores = game.getCurrentScores();
    final winner = game.getWinner();
    final isCompleted = game.status == GameStatus.completed;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _showGameDetails(context),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    isCompleted ? Icons.check_circle : Icons.timer,
                    color: isCompleted ? Colors.green : Colors.orange,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    DateFormat('yMd').format(game.startTime),
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.delete_outline),
                    onPressed: () => _confirmDelete(context),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (isCompleted && winner != null) ...[
                Row(
                  children: [
                    const Icon(Icons.emoji_events, color: Colors.amber, size: 20),
                    const SizedBox(width: 4),
                    Text(
                      'Vencedor: ${winner.name}',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
              ],
              const Divider(height: 16),
              ...game.teams.map((team) {
                final score = scores[team.id] ?? 0;
                final isWinningTeam = winner?.id == team.id;
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              team.name,
                              style: TextStyle(
                                fontWeight:
                                    isWinningTeam ? FontWeight.bold : FontWeight.normal,
                              ),
                            ),
                            Text(
                              team.playersNames,
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                      Text(
                        NumberFormat('#,###').format(score),
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: isWinningTeam ? Colors.amber : null,
                            ),
                      ),
                    ],
                  ),
                );
              }),
              const SizedBox(height: 8),
              Text(
                '${game.rounds.length} rodadas jogadas',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontStyle: FontStyle.italic,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showGameDetails(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) {
          return _GameDetailsSheet(
            game: game,
            scrollController: scrollController,
          );
        },
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir Partida'),
        content: const Text('Você tem certeza de que deseja excluir esta partida?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              onDelete();
            },
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
  }
}

class _GameDetailsSheet extends StatelessWidget {
  final Game game;
  final ScrollController scrollController;

  const _GameDetailsSheet({
    required this.game,
    required this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    final scores = game.getCurrentScores();

    return Container(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Detalhes da Partida',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),
          _DetailRow('Início', DateFormat('yMd').format(game.startTime)),
          if (game.endTime != null)
            _DetailRow('Fim', DateFormat('yMd').format(game.endTime!)),
          _DetailRow('Meta', NumberFormat('#,###').format(game.targetScore)),
          _DetailRow('Rodadas', game.rounds.length.toString()),
          const Divider(height: 32),
          Text(
            'Placar final',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          ...game.teams.map((team) {
            final score = scores[team.id] ?? 0;
            return Card(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            team.name,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            team.playersNames,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                    Text(
                      NumberFormat('#,###').format(score),
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                ),
              ),
            );
          }),
          const SizedBox(height: 16),
          Expanded(
            child: ListView(
              controller: scrollController,
              children: [
                Text(
                  'Rodada a Rodada',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                ...game.rounds.map((round) {
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Rodada ${round.roundNumber}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          ...game.teams.map((team) {
                            final roundScore = round.teamScores[team.id];
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 2.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(team.name),
                                  Text(
                                    NumberFormat('+#,###;-#,###')
                                        .format(roundScore?.totalScore ?? 0),
                                    style: TextStyle(
                                      color: (roundScore?.totalScore ?? 0) >= 0
                                          ? Colors.green
                                          : Colors.red,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '$label:',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Text(value),
        ],
      ),
    );
  }
}
