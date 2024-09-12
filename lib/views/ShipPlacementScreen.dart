// ignore_for_file: use_build_context_synchronously, file_names, library_private_types_in_public_api, sized_box_for_whitespace

import 'package:battleships/utils/utilities.dart';
import 'package:battleships/views/login_screen.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: ShipPlacementScreen(),
    );
  }
}

class ShipPlacementScreen extends StatefulWidget {
  final String? aiType;
  final Function? onGameStarted;
  final bool? isHumanGame;

  const ShipPlacementScreen({
    Key? key,
    this.aiType,
    this.onGameStarted,
    this.isHumanGame,
  }) : super(key: key);

  @override
  _ShipPlacementScreenState createState() => _ShipPlacementScreenState();
}

class _ShipPlacementScreenState extends State<ShipPlacementScreen> {
  Set<String> shipPositions = {};
  late NetworkUtil networkUtil;

  @override
  void initState() {
    super.initState();
      networkUtil = NetworkUtil(onUnauthorized: _handleUnauthorized);
  }

  void _handleUnauthorized() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => LoginScreen()),
        (Route<dynamic> route) => false,
      );
    });
  }

  void handleTap(String position) {
    setState(() {
      if (shipPositions.contains(position)) {
        shipPositions.remove(position);
      } else if (shipPositions.length < 5) {
        shipPositions.add(position);
      }
    });
  }

  void startGame() async {
    if (shipPositions.length != 5) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select exactly 5 ships.')),
      );
      return;
    }

    Map<String, dynamic> body = {
      "ships": shipPositions.toList(),
    };

  

    var response = await networkUtil.post('games', body);
    if (response.statusCode == 200) {
      widget.onGameStarted!();
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    const double labelColumnWidth = 32.0; // Width for the labels column
    const double paddingAroundGrid = 4.0; // Padding around the grid

    final screenSize = MediaQuery.of(context).size;
    final gridWidth =
        screenSize.width - labelColumnWidth - (2 * paddingAroundGrid);
    // Calculate the size of each grid cell
    final cellSize = gridWidth / 5;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Place Your Ships'),
      ),
      body: Column(
        children: [
          // Numeric column headers (1, 2, 3, 4, 5)
          Padding(
            padding:
                const EdgeInsets.only(left: labelColumnWidth + paddingAroundGrid),
            child: Row(
              children: List.generate(
                  5,
                  (index) => Expanded(
                        child: Center(
                          child: Text(
                            '${index + 1}',
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 18),
                          ),
                        ),
                      )),
            ),
          ),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Row labels (A, B, C, D, E)
                Column(
                  children: List.generate(
                      5,
                      (index) => Center(
                        child: Container(
                          height:cellSize,
                          width:24,
                              child: Center(
                                child: Text(
                                  String.fromCharCode(65 + index),
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold, fontSize: 18),
                                ),
                              ),
                            ),
                      )),
                ),
                Expanded(
                  child: GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 5,
                      childAspectRatio: 1,
                      mainAxisSpacing: paddingAroundGrid,
                      crossAxisSpacing: paddingAroundGrid,
                    ),
                    itemCount: 25,
                    itemBuilder: (context, index) {
                      final position = String.fromCharCode(65 + index ~/ 5) +
                          (index % 5 + 1).toString();
                      final isPositionSelected =
                          shipPositions.contains(position);
                      return InkWell(
                        onTap: () => handleTap(position),
                        child: Container(
                          width: cellSize,
                          height: cellSize,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.black),
                            color:
                                isPositionSelected ? Colors.blue : Colors.white,
                          ),
                          child: Center(
                            child: isPositionSelected
                                ? Icon(Icons.directions_boat,
                                    size: cellSize * 0.8)
                                : Container(),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: startGame,
        child: const Icon(Icons.check),
      ),
    );
  }
}

