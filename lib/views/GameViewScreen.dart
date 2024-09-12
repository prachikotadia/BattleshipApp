// ignore_for_file: library_private_types_in_public_api, file_names, avoid_print, prefer_interpolation_to_compose_strings

import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:battleships/views/login_screen.dart';
import 'package:battleships/views/main_app_screen.dart';
import 'package:battleships/utils/utilities.dart';

class GameViewScreen extends StatefulWidget {
  final int gameId;

  const GameViewScreen({Key? key, required this.gameId}) : super(key: key);

  @override
  _GameViewScreenState createState() => _GameViewScreenState();
}

class _GameViewScreenState extends State<GameViewScreen> {
  Map<String, dynamic> gameState = {};
  String selectedShot = '';
  late NetworkUtil networkUtil;

  @override
  void initState() {
    super.initState();
    networkUtil = NetworkUtil(onUnauthorized: _handleUnauthorized);
    fetchGameState();
  }

  void _handleUnauthorized() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => LoginScreen()),
        (Route<dynamic> route) => false,
      );
    });
  }

  void fetchGameState() async {
    try {
      final response = await networkUtil.getGame(widget.gameId);
      if (response.statusCode == 200) {
        setState(() {
          gameState = json.decode(response.body);
        });
      } else {
        print("Error fetching game state: ${response.statusCode}");
      }
    } catch (e) {
      print("Exception fetching game state: $e");
    }
  }

  void playShot() async {
    if (selectedShot.isEmpty || !isUserTurn()) {
      showSnackBar('Invalid shot or not your turn');
      return;
    }

    var body = json.encode({"shot": selectedShot});
    var response = await networkUtil.put('games/${widget.gameId}', body);

    if (response.statusCode == 200) {
      var responseBody = json.decode(response.body);
      String message = responseBody['message'];
      bool sunkShip = responseBody['sunk_ship'];
      bool won = responseBody['won'];

      if (sunkShip) {
        message = 'Hit and sunk ship! ' + message;
      } else {
        message = 'Shot missed. ' + message;
      }

      showSnackBar(message);

      fetchGameState();
      if (won) {
        checkWinCondition(responseBody);
      }
      setState(() {
        selectedShot = '';
      });
    } else {
      showSnackBar('Error playing shot: ${response.statusCode}');
    }
  }

  bool isUserTurn() {
    return gameState['turn'] == gameState['position'];
  }

  void checkWinCondition(dynamic response) {
    if (response['won']) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Game Over'),
          content: const Text('Congratulations! You won the game!'),
          actions: <Widget>[
            TextButton(
                child: const Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                        builder: (context) => MainAppScreen(username: '')),
                  );
                }),
          ],
        ),
      );
    }
  }

  void showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Widget buildLegend() {
    return Container(
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Legend',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildLegendItem(Icons.directions_boat, 'Ship', Colors.blue),
              _buildLegendItem(Icons.bubble_chart, 'Wreck', Colors.red),
              _buildLegendItem(Icons.error_outline, 'Missed Shot', Colors.grey),
              _buildLegendItem(
                  Icons.local_fire_department, 'Sunk Ship', Colors.green),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(IconData icon, String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 24, color: color),
        const SizedBox(width: 5),
        Text(label),
      ],
    );
  }

  Widget buildGameBoard() {
    int gridSize = 5;
    List<String> gridCoordinates = List.generate(
        gridSize * gridSize,
        (index) =>
            String.fromCharCode(65 + index ~/ gridSize) +
            (index % gridSize + 1).toString());

    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: gridSize,
      ),
      itemCount: gridSize * gridSize,
      itemBuilder: (context, index) {
        String position = gridCoordinates[index];
        List<Widget> iconChildren = [];

        if (gameState['ships'].contains(position)) {
          iconChildren.add(const Icon(Icons.directions_boat,
              size: 24, color: Colors.blue)); 
        }
        if (gameState['wrecks'].contains(position)) {
          iconChildren.add(const Icon(Icons.bubble_chart,
              size: 24, color: Colors.red)); 
        }
        if (gameState['shots'].contains(position)) {
          iconChildren.add(const Icon(Icons.error_outline,
              size: 24, color: Colors.grey)); 
        }
        if (gameState['sunk'].contains(position)) {
          iconChildren.add(const Icon(Icons.local_fire_department,
              size: 24, color: Colors.green)); 
        }

        return InkWell(
          onTap: () {
            if (isUserTurn() &&
                !gameState['shots'].contains(position) &&
                !gameState['sunk'].contains(position)) {
              setState(() {
                selectedShot = position;
              });
            }
          },
          child: Container(
            decoration: BoxDecoration(
              color: selectedShot == position
                  ? const Color.fromARGB(255, 234, 115, 106)
                  : null,
              border: Border.all(color: Colors.black),
            ),
            child: FittedBox(
              fit: BoxFit.contain,
              child: Wrap(
                direction:
                    iconChildren.length > 1 ? Axis.vertical : Axis.horizontal,
                children: iconChildren,
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Game ${widget.gameId}'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: fetchGameState,
          ),
        ],
      ),
      body: gameState.isNotEmpty
          ? Column(
              children: [
                Expanded(
                  child: buildGameBoard(),
                ),
                buildLegend(),
              ],
            )
          : const CircularProgressIndicator(),
      floatingActionButton: isUserTurn()
          ? FloatingActionButton(
              onPressed: playShot,
              child: const Icon(Icons.send),
            )
          : null,
    );
  }
}
