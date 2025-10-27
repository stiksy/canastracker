import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../models/player.dart';
import '../models/team.dart';
import '../providers/game_provider.dart';
import 'game_screen.dart';

class NewGameScreen extends StatefulWidget {
  const NewGameScreen({super.key});

  @override
  State<NewGameScreen> createState() => _NewGameScreenState();
}

class _NewGameScreenState extends State<NewGameScreen> {
  final _uuid = const Uuid();
  final List<_TeamSetup> _teams = [];
  int _numberOfDecks = 2;

  @override
  void initState() {
    super.initState();
    // Start with 2 empty teams
    _teams.add(_TeamSetup(id: _uuid.v4(), name: 'Equipe 1'));
    _teams.add(_TeamSetup(id: _uuid.v4(), name: 'Equipe 2'));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nova Partida'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                // Deck count selector
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Quantidade de baralhos',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.remove_circle_outline),
                              onPressed: _numberOfDecks > 1
                                  ? () => setState(() => _numberOfDecks--)
                                  : null,
                            ),
                            SizedBox(
                              width: 40,
                              child: Text(
                                _numberOfDecks.toString(),
                                style: Theme.of(context).textTheme.titleLarge,
                                textAlign: TextAlign.center,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.add_circle_outline),
                              onPressed: _numberOfDecks < 4
                                  ? () => setState(() => _numberOfDecks++)
                                  : null,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Teams
                ...List.generate(_teams.length, (index) {
                  return _TeamCard(
                    teamSetup: _teams[index],
                    onNameChanged: (name) {
                      setState(() {
                        _teams[index].name = name;
                      });
                    },
                    onPlayersChanged: (players) {
                      setState(() {
                        _teams[index].players = players;
                      });
                    },
                    onRemove: _teams.length > 2
                        ? () {
                            setState(() {
                              _teams.removeAt(index);
                            });
                          }
                        : null,
                  );
                }),

                const SizedBox(height: 8),

                // Add team button
                if (_teams.length < 4)
                  OutlinedButton.icon(
                    onPressed: () {
                      setState(() {
                        _teams.add(_TeamSetup(
                          id: _uuid.v4(),
                          name: 'Equipe ${_teams.length + 1}',
                        ));
                      });
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('Adicionar Equipe'),
                  ),
              ],
            ),
          ),

          // Start game button
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _canStartGame() ? _startGame : null,
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('Iniciar Partida'),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.all(16),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  bool _canStartGame() {
    if (_teams.length < 2) return false;

    for (final team in _teams) {
      if (team.players.isEmpty) return false;
      if (team.name.trim().isEmpty) return false;
    }

    return true;
  }

  Future<void> _startGame() async {
    final teams = _teams.map((teamSetup) {
      return Team(
        id: teamSetup.id,
        name: teamSetup.name,
        players: teamSetup.players,
      );
    }).toList();

    final gameProvider = context.read<GameProvider>();
    await gameProvider.startNewGame(teams, numberOfDecks: _numberOfDecks);

    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const GameScreen(),
        ),
      );
    }
  }
}

class _TeamSetup {
  String id;
  String name;
  List<Player> players;

  _TeamSetup({
    required this.id,
    required this.name,
    List<Player>? players,
  }) : players = players ?? [];
}

class _TeamCard extends StatefulWidget {
  final _TeamSetup teamSetup;
  final ValueChanged<String> onNameChanged;
  final ValueChanged<List<Player>> onPlayersChanged;
  final VoidCallback? onRemove;

  const _TeamCard({
    required this.teamSetup,
    required this.onNameChanged,
    required this.onPlayersChanged,
    this.onRemove,
  });

  @override
  State<_TeamCard> createState() => _TeamCardState();
}

class _TeamCardState extends State<_TeamCard> {
  late TextEditingController _nameController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.teamSetup.name);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Nome da Equipe',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: widget.onNameChanged,
                  ),
                ),
                if (widget.onRemove != null) ...[
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: widget.onRemove,
                  ),
                ],
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Jogadores',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            if (widget.teamSetup.players.isEmpty)
              Text(
                'Nenhum jogador adicionado',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontStyle: FontStyle.italic,
                    ),
              )
            else
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: widget.teamSetup.players.map((player) {
                  return Chip(
                    label: Text(player.name),
                    onDeleted: () {
                      final updatedPlayers = List<Player>.from(widget.teamSetup.players)
                        ..remove(player);
                      widget.onPlayersChanged(updatedPlayers);
                    },
                  );
                }).toList(),
              ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: () => _showPlayerSelection(context),
              icon: const Icon(Icons.person_add),
              label: const Text('Adicionar Jogador'),
            ),
          ],
        ),
      ),
    );
  }

  void _showPlayerSelection(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => _PlayerSelectionDialog(
        alreadySelectedPlayers: widget.teamSetup.players,
        onPlayersSelected: (players) {
          final updatedPlayers = List<Player>.from(widget.teamSetup.players)..addAll(players);
          widget.onPlayersChanged(updatedPlayers);
        },
      ),
    );
  }
}

class _PlayerSelectionDialog extends StatefulWidget {
  final List<Player> alreadySelectedPlayers;
  final ValueChanged<List<Player>> onPlayersSelected;

  const _PlayerSelectionDialog({
    required this.alreadySelectedPlayers,
    required this.onPlayersSelected,
  });

  @override
  State<_PlayerSelectionDialog> createState() => _PlayerSelectionDialogState();
}

class _PlayerSelectionDialogState extends State<_PlayerSelectionDialog> {
  final Set<Player> _selectedPlayers = {};

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Selecionar Jogadores'),
      content: SizedBox(
        width: double.maxFinite,
        child: Consumer<GameProvider>(
          builder: (context, gameProvider, child) {
            final availablePlayers = gameProvider.availablePlayers
                .where((p) => !widget.alreadySelectedPlayers.contains(p))
                .toList();

            if (availablePlayers.isEmpty) {
              return const Center(
                child: Text('Nenhum jogador disponível. Crie jogadores primeiro.'),
              );
            }

            return ListView.builder(
              shrinkWrap: true,
              itemCount: availablePlayers.length,
              itemBuilder: (context, index) {
                final player = availablePlayers[index];
                final isSelected = _selectedPlayers.contains(player);

                return CheckboxListTile(
                  title: Text(player.name),
                  subtitle: Text('Partidas: ${player.gamesPlayed}'),
                  value: isSelected,
                  onChanged: (selected) {
                    setState(() {
                      if (selected == true) {
                        _selectedPlayers.add(player);
                      } else {
                        _selectedPlayers.remove(player);
                      }
                    });
                  },
                );
              },
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: _selectedPlayers.isEmpty
              ? null
              : () {
                  widget.onPlayersSelected(_selectedPlayers.toList());
                  Navigator.pop(context);
                },
          child: const Text('Confirmar'),
        ),
      ],
    );
  }
}
