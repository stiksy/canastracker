import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/game_provider.dart';
import '../models/game.dart';
import 'round_entry_screen.dart';

class GameScreen extends StatelessWidget {
  const GameScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<GameProvider>(
      builder: (context, gameProvider, child) {
        final game = gameProvider.currentGame;

        if (game == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Game')),
            body: const Center(child: Text('No active game')),
          );
        }

        final scores = gameProvider.getCurrentScores();
        final isCompleted = game.status == GameStatus.completed;

        return Scaffold(
          appBar: AppBar(
            title: Text(isCompleted ? 'Jogo Concluído' : 'Jogo em Andamento'),
            actions: [
              if (!isCompleted)
                IconButton(
                  icon: const Icon(Icons.info_outline),
                  onPressed: () => _showGameInfo(context, game),
                ),
            ],
          ),
          body: Column(
            children: [
              // Current scores
              Card(
                margin: const EdgeInsets.all(16),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Current Scores',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          Text(
                            'Target: ${NumberFormat('#,###').format(game.targetScore)}',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                      const Divider(),
                      ...game.teams.map((team) {
                        final score = scores[team.id] ?? 0;
                        final isWinner = isCompleted && game.winnerId == team.id;
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Row(
                            children: [
                              if (isWinner)
                                const Icon(Icons.emoji_events, color: Colors.amber),
                              if (isWinner) const SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      team.name,
                                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                            fontWeight: isWinner ? FontWeight.bold : null,
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
                                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: isWinner
                                          ? Colors.amber
                                          : Theme.of(context).colorScheme.primary,
                                    ),
                              ),
                            ],
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ),

              // Rounds header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Rodadas (${game.rounds.length})',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    if (!isCompleted)
                      TextButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const RoundEntryScreen(),
                            ),
                          );
                        },
                        icon: const Icon(Icons.add),
                        label: const Text('Adicionar'),
                      ),
                  ],
                ),
              ),

              // Rounds list
              Expanded(
                child: game.rounds.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.style_outlined,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Nenhuma rodada ainda',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: Colors.grey,
                                  ),
                            ),
                            const SizedBox(height: 8),
                            if (!isCompleted)
                              ElevatedButton.icon(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const RoundEntryScreen(),
                                    ),
                                  );
                                },
                                icon: const Icon(Icons.add),
                                label: const Text('Adicionar Primeira Rodada'),
                              ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: game.rounds.length,
                        itemBuilder: (context, index) {
                          final round = game.rounds[index];
                          return _RoundCard(
                            round: round,
                            teams: game.teams,
                          );
                        },
                      ),
              ),
            ],
          ),
          floatingActionButton: !isCompleted
              ? FloatingActionButton.extended(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const RoundEntryScreen(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Nova Rodada'),
                )
              : null,
        );
      },
    );
  }

  void _showGameInfo(BuildContext context, Game game) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Informações do Jogo'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _InfoRow('Iniciado', DateFormat('dd/MM/yyyy HH:mm').format(game.startTime)),
            _InfoRow('Pontuação Meta', NumberFormat('#,###').format(game.targetScore)),
            _InfoRow('Rodadas Jogadas', game.rounds.length.toString()),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fechar'),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow(this.label, this.value);

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

class _RoundCard extends StatelessWidget {
  final round;
  final teams;

  const _RoundCard({
    required this.round,
    required this.teams,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        title: Text('Round ${round.roundNumber}'),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: teams.map<Widget>((team) {
                final teamScore = round.teamScores[team.id];
                if (teamScore == null) {
                  return ListTile(
                    title: Text(team.name),
                    trailing: const Text('Sem pontuação'),
                  );
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ListTile(
                      title: Text(
                        team.name,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      trailing: Text(
                        NumberFormat('+#,###;-#,###').format(teamScore.totalScore),
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: teamScore.totalScore >= 0
                                  ? Colors.green
                                  : Colors.red,
                            ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (teamScore.cleanCanastas > 0)
                            _ScoreDetail('Canastras Limpas', teamScore.cleanCanastas),
                          if (teamScore.dirtyCanastas > 0)
                            _ScoreDetail('Canastras Sujas', teamScore.dirtyCanastas),
                          if (teamScore.redThrees > 0)
                            _ScoreDetail('3 Vermelhos', teamScore.redThrees),
                          if (teamScore.meldPoints > 0)
                            _ScoreDetail('Pontos de Jogo', teamScore.meldPoints),
                          if (teamScore.cardsInHand > 0)
                            _ScoreDetail('Cartas na Mão', -teamScore.cardsInHand),
                          if (teamScore.wentOut)
                            const _ScoreDetail('Bateu', 100),
                        ],
                      ),
                    ),
                    const Divider(),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _ScoreDetail extends StatelessWidget {
  final String label;
  final int value;

  const _ScoreDetail(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          Text(
            value >= 0 ? '+$value' : value.toString(),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: value >= 0 ? Colors.green : Colors.red,
                ),
          ),
        ],
      ),
    );
  }
}
