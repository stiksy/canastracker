import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/round.dart';
import '../providers/game_provider.dart';
import '../services/scoring_service.dart';

class RoundEntryScreen extends StatefulWidget {
  const RoundEntryScreen({super.key});

  @override
  State<RoundEntryScreen> createState() => _RoundEntryScreenState();
}

class _RoundEntryScreenState extends State<RoundEntryScreen> {
  final Map<String, _TeamRoundData> _teamData = {};
  bool _isSubmitting = false;
  String? _teamThatWentOut;

  @override
  void initState() {
    super.initState();
    final gameProvider = context.read<GameProvider>();
    final game = gameProvider.currentGame;

    if (game != null) {
      for (final team in game.teams) {
        _teamData[team.id] = _TeamRoundData();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<GameProvider>(
      builder: (context, gameProvider, child) {
        final game = gameProvider.currentGame;

        if (game == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Adicionar Rodada')),
            body: const Center(child: Text('Nenhuma partida iniciada')),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: Text('Rodada ${game.rounds.length + 1}'),
          ),
          body: ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              // Which team went out selector
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Qual time bateu?',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 8),
                      ...game.teams.map((team) {
                        return RadioListTile<String?>(
                          title: Text(team.name),
                          value: team.id,
                          groupValue: _teamThatWentOut,
                          onChanged: (value) {
                            setState(() {
                              _teamThatWentOut = value;
                            });
                          },
                          contentPadding: EdgeInsets.zero,
                        );
                      }),
                      RadioListTile<String?>(
                        title: const Text('Nenhum time bateu'),
                        value: null,
                        groupValue: _teamThatWentOut,
                        onChanged: (value) {
                          setState(() {
                            _teamThatWentOut = null;
                          });
                        },
                        contentPadding: EdgeInsets.zero,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              ...game.teams.map((team) {
                final data = _teamData[team.id]!;
                final currentScore = gameProvider.getCurrentScores()[team.id] ?? 0;
                final minimumMeld = gameProvider.getMinimumMeldForTeam(team.id);

                // Calculate total red and black 3s across all teams
                int totalRedThrees = 0;
                int totalBlackThrees = 0;
                for (final teamData in _teamData.values) {
                  totalRedThrees += teamData.redThrees;
                  totalBlackThrees += teamData.blackThrees;
                }

                final maxThreesPerColor = game.numberOfDecks * 4;

                return _TeamScoreCard(
                  teamId: team.id,
                  teamName: team.name,
                  playersNames: team.playersNames,
                  currentScore: currentScore,
                  minimumMeld: minimumMeld,
                  data: data,
                  teamThatWentOut: _teamThatWentOut,
                  totalRedThrees: totalRedThrees,
                  totalBlackThrees: totalBlackThrees,
                  maxThreesPerColor: maxThreesPerColor,
                  onDataChanged: () => setState(() {}),
                );
              }),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: _isSubmitting ? null : _submitRound,
                icon: _isSubmitting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.check),
                label: Text(_isSubmitting ? 'Salvando...' : 'Salvar Rodada'),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _submitRound() async {
    setState(() => _isSubmitting = true);

    try {
      final gameProvider = context.read<GameProvider>();
      final teamScores = <String, RoundScore>{};

      for (final entry in _teamData.entries) {
        final data = entry.value;
        final roundScore = RoundScore(
          teamId: entry.key,
          cleanCanastas: data.cleanCanastas,
          dirtyCanastas: data.dirtyCanastas,
          redThrees: data.redThrees,
          blackThrees: data.blackThrees,
          meldPoints: data.meldPoints,
          cardsInHand: data.cardsInHand,
          wentOut: _teamThatWentOut == entry.key,
          totalScore: 0, // Will be calculated by the provider
        );

        teamScores[entry.key] = roundScore;
      }

      await gameProvider.addRound(teamScores);

      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao salvar rodada: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }
}

class _TeamRoundData {
  int cleanCanastas = 0;
  int dirtyCanastas = 0;
  int redThrees = 0;
  int blackThrees = 0;
  int meldPoints = 0;
  int cardsInHand = 0;
}

class _TeamScoreCard extends StatelessWidget {
  final String teamId;
  final String teamName;
  final String playersNames;
  final int currentScore;
  final int minimumMeld;
  final _TeamRoundData data;
  final String? teamThatWentOut;
  final int totalRedThrees;
  final int totalBlackThrees;
  final int maxThreesPerColor;
  final VoidCallback onDataChanged;

  const _TeamScoreCard({
    required this.teamId,
    required this.teamName,
    required this.playersNames,
    required this.currentScore,
    required this.minimumMeld,
    required this.data,
    required this.teamThatWentOut,
    required this.totalRedThrees,
    required this.totalBlackThrees,
    required this.maxThreesPerColor,
    required this.onDataChanged,
  });

  @override
  Widget build(BuildContext context) {
    final wentOut = teamThatWentOut == teamId;

    final roundScore = RoundScore(
      teamId: '',
      cleanCanastas: data.cleanCanastas,
      dirtyCanastas: data.dirtyCanastas,
      redThrees: data.redThrees,
      blackThrees: data.blackThrees,
      meldPoints: data.meldPoints,
      cardsInHand: data.cardsInHand,
      wentOut: wentOut,
      totalScore: 0,
    );

    final calculatedScore = ScoringService.calculateRoundScore(roundScore);
    final breakdown = ScoringService.getScoreBreakdown(roundScore);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Team header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      teamName,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    Text(
                      playersNames,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Atual',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    Text(
                      NumberFormat('#,###').format(currentScore),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Abertura mínima: $minimumMeld pontos',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontStyle: FontStyle.italic,
                  ),
            ),
            const Divider(height: 24),

            // Canastas
            Text(
              'Canastras',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            _CounterRow(
              label: 'Limpa',
              value: data.cleanCanastas,
              onChanged: (val) {
                data.cleanCanastas = val;
                onDataChanged();
              },
            ),
            _CounterRow(
              label: 'Suja',
              value: data.dirtyCanastas,
              onChanged: (val) {
                data.dirtyCanastas = val;
                onDataChanged();
              },
            ),

            const Divider(height: 24),

            // Other scoring
            Text(
              'Outras Pontuações',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            _CounterRow(
              label: '3 Vermelhos',
              value: data.redThrees,
              onChanged: (val) {
                data.redThrees = val;
                onDataChanged();
              },
              max: 4,
              canIncrement: totalRedThrees < maxThreesPerColor,
            ),
            _CounterRow(
              label: '3 Pretos',
              value: data.blackThrees,
              onChanged: (val) {
                data.blackThrees = val;
                onDataChanged();
              },
              max: 4,
              canIncrement: totalBlackThrees < maxThreesPerColor,
            ),
            _NumberInputRow(
              label: 'Pontos de Cartas',
              value: data.meldPoints,
              onChanged: (val) {
                data.meldPoints = val;
                onDataChanged();
              },
            ),
            _NumberInputRow(
              label: 'Cartas na Mão',
              value: data.cardsInHand,
              onChanged: (val) {
                data.cardsInHand = val;
                onDataChanged();
              },
            ),

            const Divider(height: 24),

            // Score breakdown
            Text(
              'Detalhamento',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            if (breakdown.isEmpty)
              Text(
                'Nenhuma pontuação inserida',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontStyle: FontStyle.italic,
                    ),
              )
            else
              ...breakdown.entries.map((entry) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(entry.key),
                      Text(
                        NumberFormat('+#,###;-#,###').format(entry.value),
                        style: TextStyle(
                          color: entry.value >= 0 ? Colors.green : Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                );
              }),

            const Divider(height: 16),

            // Total
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total da Rodada',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                Text(
                  NumberFormat('+#,###;-#,###').format(calculatedScore),
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: calculatedScore >= 0 ? Colors.green : Colors.red,
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

class _CounterRow extends StatelessWidget {
  final String label;
  final int value;
  final ValueChanged<int> onChanged;
  final int max;
  final bool canIncrement;

  const _CounterRow({
    required this.label,
    required this.value,
    required this.onChanged,
    this.max = 10,
    this.canIncrement = true,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.remove_circle_outline),
                onPressed: value > 0 ? () => onChanged(value - 1) : null,
              ),
              SizedBox(
                width: 40,
                child: Text(
                  value.toString(),
                  style: Theme.of(context).textTheme.titleMedium,
                  textAlign: TextAlign.center,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.add_circle_outline),
                onPressed: (value < max && canIncrement) ? () => onChanged(value + 1) : null,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _NumberInputRow extends StatelessWidget {
  final String label;
  final int value;
  final ValueChanged<int> onChanged;

  const _NumberInputRow({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          SizedBox(
            width: 120,
            child: TextField(
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              textAlign: TextAlign.end,
              decoration: const InputDecoration(
                isDense: true,
                contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                border: OutlineInputBorder(),
              ),
              controller: TextEditingController(text: value.toString())
                ..selection = TextSelection.collapsed(offset: value.toString().length),
              onChanged: (text) {
                final newValue = int.tryParse(text) ?? 0;
                onChanged(newValue);
              },
            ),
          ),
        ],
      ),
    );
  }
}
