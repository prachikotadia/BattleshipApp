// ignore_for_file: empty_catches, library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:battleships/utils/utilities.dart';
import 'dart:convert';

class CompletedGamesScreen extends StatefulWidget {
  const CompletedGamesScreen({super.key});

  @override
  _CompletedGamesScreenState createState() => _CompletedGamesScreenState();
}

class _CompletedGamesScreenState extends State<CompletedGamesScreen> {
  List<dynamic> completedGames = []; 

  @override
  void initState() {
    super.initState();
    _fetchAndProcessCompletedGames();
  }

  void _fetchAndProcessCompletedGames() async {
    try {
      final response = await NetworkUtil().getGames();
      if (response.statusCode == 200) {
        _processGameData(response.body);
      } 
    } catch (e) {
    }
  }

  /// Decodes and filters the game data, setting state with the filtered list.
  void _processGameData(String responseBody) {
    final decodedGames = json.decode(responseBody)['games'];
    final filteredGames = decodedGames.where((game) => game['status'] == 1 || game['status'] == 2).toList();

    setState(() {
      completedGames = filteredGames;
    });
  }

  /// Builds a visually distinctive ListTile based on the game's outcome.
  Widget _buildGameTile(Map<String, dynamic> game) {
    final bool isWon = game['status'] == 1;
    return ListTile(
      title: Text(
        'Game ID: ${game['id']}',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: isWon ? Colors.green : const Color.fromARGB(255, 62, 62, 31), 
        ),
      ),
      subtitle: Text(
        'Status: ${isWon ? "Won" : "Lost"}',
        style: TextStyle(
          fontStyle: FontStyle.italic,
          color: isWon ? Colors.green.shade700 : const Color.fromARGB(255, 113, 82, 31),
        ),
      ),
      trailing: Icon(
        isWon ? Icons.check_circle_outline : Icons.highlight_off,
        color: isWon ? Colors.green : const Color.fromARGB(255, 211, 118, 118),
      ),
      tileColor: isWon ? Colors.green.shade50 : const Color.fromARGB(255, 247, 201, 169),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(color: isWon ? Colors.green.shade300 : const Color.fromARGB(255, 230, 133, 101)),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Completed Games'),
        backgroundColor: Colors.blueGrey,
      ),
      body: completedGames.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: completedGames.length,
              itemBuilder: (context, index) {
                final game = completedGames[index];
                return _buildGameTile(game);
              },
            ),
    );
  }
}
