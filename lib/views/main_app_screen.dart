// ignore_for_file: library_private_types_in_public_api, avoid_print, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'ShipPlacementScreen.dart';
import 'package:battleships/views/GameViewScreen.dart';
import 'package:battleships/views/completed_games_screen.dart';
import 'package:battleships/views/login_screen.dart';
import 'package:battleships/utils/utilities.dart';
import 'dart:convert';

class MainAppScreen extends StatefulWidget {
  final String username;

  const MainAppScreen({Key? key, required this.username}) : super(key: key);

  @override
  _MainAppScreenState createState() => _MainAppScreenState();
}

class _MainAppScreenState extends State<MainAppScreen> {
  late List<dynamic> games = [];
  late NetworkUtil networkUtil;

  @override
  void initState() {
    super.initState();
    networkUtil = NetworkUtil(onUnauthorized: _handleUnauthorized);
    _fetchGames();
  }

  void _handleUnauthorized() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _navigateToLogin();
    });
  }

  void _navigateToLogin() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => LoginScreen()),
      (Route<dynamic> route) => false,
    );
  }

  void _fetchGames() async {
    try {
      final response = await networkUtil.getGames();
      if (response.statusCode == 200) {
        _updateGamesList(response.body);
      } else {
        _handleFetchGamesError();
      }
    } catch (e) {
      _handleFetchGamesException(e);
    }
  }

  void _updateGamesList(String responseBody) {
    setState(() {
      games = json
          .decode(responseBody)['games']
          .where((game) => game['status'] == 3 || game['status'] == 0)
          .toList();
    });
  }

  void _handleFetchGamesError() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text("Failed to fetch games. Please try again."),
        action: SnackBarAction(
          label: 'Retry',
          onPressed: _fetchGames, 
        ),
      ),
    );
  }


  void _handleFetchGamesException(e) {
    print("Exception while fetching games: $e");
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text("An error occurred. Please try again."),
        action: SnackBarAction(
          label: 'Retry',
          onPressed: _fetchGames, 
        ),
      ),
    );
  }


  void _showAIDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) => _buildAIDialog(context),
    );
  }

  AlertDialog _buildAIDialog(BuildContext context) {
    return AlertDialog(
      title: const Text("Choose AI Type"),
      content: _buildAIOptionsList(),
    );
  }

  Column _buildAIOptionsList() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        _buildAIOptionTile(context, "Random"),
        _buildAIOptionTile(context, "Perfect"),
        _buildAIOptionTile(context, "OneShip"),
      ],
    );
  }

  ListTile _buildAIOptionTile(BuildContext context, String aiType) {
    return ListTile(
      title: Text(aiType),
      onTap: () => _onAITypeSelected(context, aiType),
    );
  }

  void _onAITypeSelected(BuildContext context, String aiType) {
    Navigator.of(context).pop();
    _navigateToShipPlacement(aiType);
  }

  void _navigateToShipPlacement(String aiType) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ShipPlacementScreen(
          aiType: aiType,
          onGameStarted: _fetchGames,
          isHumanGame: false,
        ),
      ),
    );
  }

  void _deleteGame(int gameId) async {
    try {
      final response = await networkUtil.deleteGame(gameId);
      if (response.statusCode == 200) {
        _showDeletionSuccessSnackBar(context, response.body);
        _fetchGames();
      } else {
        _showErrorSnackBar(context, 'Error: Could not delete the game');
      }
    } catch (e) {
      _showExceptionSnackBar(context, e);
    }
  }

  void _showDeletionSuccessSnackBar(BuildContext context, String responseBody) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(json.decode(responseBody)['message'])),
    );
  }

  void _showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _showExceptionSnackBar(BuildContext context, dynamic exception) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Exception: $exception')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Battleships'),
        actions: [IconButton(icon: const Icon(Icons.refresh), onPressed: _fetchGames)],
      ),
      drawer: _buildDrawer(),
      body: _buildGameList(),
    );
  }

  Drawer _buildDrawer() {
  return Drawer(
    child: ListView(
      children: [
        _buildUserAccountHeader(), // Ensure this method uses vibrant colors and maybe even a custom background image or pattern
        _buildDrawerOption(
          icon: Icons.person_outline,
          title: 'New game (Human)',
          onTap: () => _navigateToShipPlacementForHuman(),
          color: Colors.deepPurple, // A unique color for this option
          iconColor: Colors.white,
        ),
        _buildDrawerOption(
          icon: Icons.computer,
          title: 'New game (AI)',
          onTap: _showAIDialog,
          color: Colors.blueAccent, // A unique color for this option
          iconColor: Colors.yellowAccent,
        ),
        _buildDrawerOption(
          icon: Icons.history,
          title: 'Show completed games',
          onTap: _navigateToCompletedGames,
          color: Colors.green, // A unique color for this option
          iconColor: Colors.black,
        ),
        _buildDrawerOption(
          icon: Icons.exit_to_app,
          title: 'Log out',
          onTap: _logout,
          color: Colors.redAccent, // A unique color for this option
          iconColor: Colors.white,
        ),
      ],
    ),
  );
}

  Widget _buildDrawerOption({required IconData icon, required String title, required VoidCallback onTap, Color color = Colors.blue, Color iconColor = Colors.white}) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        gradient: LinearGradient(
          colors: [color.withOpacity(0.7), color], // Gradient effect
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: ListTile(
        leading: Icon(icon, color: iconColor),
        title: Text(title, style: TextStyle(color: iconColor)),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        onTap: onTap,
      ),
    );
  }


  UserAccountsDrawerHeader _buildUserAccountHeader() {
    return UserAccountsDrawerHeader(
      accountName: Text(widget.username),
      accountEmail: const Text(''),
      currentAccountPicture: CircleAvatar(
        backgroundColor: Colors.white,
        child: Text(
          widget.username.isNotEmpty ? widget.username[0].toUpperCase() : "?",
          style: const TextStyle(fontSize: 40.0),
        ),
      ),
    );
  }

  

  void _navigateToShipPlacementForHuman() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ShipPlacementScreen(
          onGameStarted: _fetchGames,
          isHumanGame: true,
        ),
      ),
    );
  }

  void _navigateToCompletedGames() {
    Navigator.of(context).push(MaterialPageRoute(builder: (context) => const CompletedGamesScreen()));
  }

  Future<void> _logout() async {
    await StorageUtil.deleteToken();
    await StorageUtil.deleteUsername();
    _navigateToLogin();
  }

  ListView _buildGameList() {
    return ListView.builder(
      itemCount: games.length,
      itemBuilder: (context, index) => _buildGameTile(context, games[index]),
    );
  }

  ListTile _buildGameTile(BuildContext context, dynamic game) {
    return ListTile(
      title: Text('#${game['id']} ${game['player1']} vs ${game['player2']}'),
      subtitle: Text(_determineGameStatus(game)),
      trailing: IconButton(
        icon: const Icon(Icons.delete),
        onPressed: () => _deleteGame(game['id']),
      ),
      onTap: () => _navigateToGameViewScreen(game['id']),
    );
  }

  String _determineGameStatus(dynamic game) {
    if (game['status'] == 3) {
      return (game['turn'] == game['position']) ? "Your Turn" : "Opponent's Turn";
    } else if (game['status'] == 1 || game['status'] == 2) {
      return 'Completed';
    }
    return 'Matchmaking';
  }

  void _navigateToGameViewScreen(int gameId) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => GameViewScreen(gameId: gameId),
      ),
    );
  }
}
