import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const MyApp());
}

class SnakeGameState extends ChangeNotifier {
  List<int> snake = [65, 66, 67, 68, 69];
  final List<String> direction = ["left", "down", "up", "right"];
  int food = 520;
  List<int> bonusFood = [];
  String currentDirection = "right";
  bool isMoving = false;
  int columnsNumber = 30;
  int rowsNumber = 35;
  Timer? gameTimer;
  Timer? bonusFoodTimer;

  int score = 0;

  void changeDirection(String direction) {
    currentDirection = direction;
    if (!isMoving) {
      isMoving = true;
      startGame();
    }
  }

  void startGame({waitingTime = 400}) {
    var initialLength = snake.length;
    gameTimer = Timer.periodic(Duration(milliseconds: waitingTime), (timer) {
      if (isMoving) {
        moveSnake();
      }

      if (snake.length == initialLength + 2 && waitingTime != 90) {
        waitingTime -= 25;
        gameTimer?.cancel();
        startGame(waitingTime: waitingTime);
      }
    });
  }

  void endGame() {
    gameTimer?.cancel();
    bonusFoodTimer?.cancel();
    snake = [65, 66, 67, 68, 69];
    generateFood();
    currentDirection = "right";
    isMoving = false;
    score = 0;
    notifyListeners();
  }

  void moveSnake() {
    int head = snake.last;
    int newHead;

    if (willCrossBorders()) {
      endGame();
      return;
    }

    switch (currentDirection) {
      case "up":
        newHead = head - columnsNumber;
        break;
      case "down":
        newHead = head + columnsNumber;
        break;
      case "left":
        newHead = head - 1;
        break;
      case "right":
        newHead = head + 1;
        break;

      default:
        newHead = head + 1;
    }

    if (newHead == food) {
      snake.add(newHead);
      generateFood();
      score++;
    } else if (bonusFood.contains(newHead)) {
      bonusFood.clear();
      bonusFoodTimer?.cancel();
      snake.add(newHead);
      generateFood();
      score += 5;
    } else if (snake.contains(newHead)) {
      endGame();
    } else {
      snake.add(newHead);
      snake.removeAt(0);
    }

    notifyListeners();
  }

  bool willCrossBorders() {
    int head = snake.last;

    // Check if the head is outside the grid boundaries
    return (currentDirection == "right" &&
            head % columnsNumber == columnsNumber - 1) ||
        (currentDirection == "up" && head ~/ columnsNumber == 0) ||
        (currentDirection == "down" &&
            head ~/ columnsNumber == rowsNumber - 1) ||
        (currentDirection == "left" && head % columnsNumber == 0);
  }

  void generateFood() {
    final random = Random();
    int newFood;

    do {
      newFood = random.nextInt(rowsNumber * columnsNumber);
    } while (snake.contains(newFood));

    food = newFood;
    bool youAreLucky =
        random.nextInt(5) == 2 && bonusFood.isEmpty && isMoving ? true : false;

    if (youAreLucky) {
      generateBonusFood();
    }
  }

  void generateBonusFood() {
    final random = Random();
    int newBonusFood;
    int secondsCount = 0;

    do {
      newBonusFood = random.nextInt(rowsNumber * columnsNumber);
    } while (snake.contains(newBonusFood) && food != newBonusFood);

    bonusFood.add(newBonusFood);
    bonusFoodTimer = Timer.periodic(Duration(milliseconds: 1000), (timer) {
      if (secondsCount < 10) {
        secondsCount++;
      } else {
        bonusFood.clear();
        bonusFoodTimer?.cancel();
      }
    });
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (BuildContext context) => SnakeGameState(),
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          scaffoldBackgroundColor: Colors.black,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.black),
          useMaterial3: true,
        ),
        home: Scaffold(
          body: Column(
            children: [
              const SizedBox(
                width: double.infinity,
                height: 1,
              ),
              const Score(),
              LayoutBuilder(
                  builder: (BuildContext context, BoxConstraints constraints) {
                return SizedBox(
                  height: 550,
                  width:
                      constraints.maxWidth < 350 ? constraints.maxWidth : 350,
                  child: const SnakeGrid(),
                );
              }),
              const Controllers(),
            ],
          ),
        ),
      ),
    );
  }
}

class SnakeGrid extends StatefulWidget {
  final int rowsNumber;
  final int columnsNumber;
  const SnakeGrid({super.key, this.rowsNumber = 35, this.columnsNumber = 30});

  @override
  State<SnakeGrid> createState() => _SnakeGridState();
}

class _SnakeGridState extends State<SnakeGrid> {
  List<int> snake = [65, 66, 67, 68, 69];
  List<int> bonusFood = [];
  final List<String> direction = ["left", "down", "up", "right"];
  int food = 5;
  String currentDirection = "right";
  bool isMoving = false;

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<SnakeGameState>();

    isMoving = appState.isMoving;
    currentDirection = appState.currentDirection;
    snake = appState.snake;
    bonusFood = appState.bonusFood;
    food = appState.food;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 10),
      child: GridView.builder(
          itemCount: widget.rowsNumber * widget.columnsNumber,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 30),
          itemBuilder: (context, index) {
            if (index == food) {
              return Padding(
                padding: const EdgeInsets.all(0.5),
                child: Container(
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(3)),
                    color: Colors.red,
                  ),
                ),
              );
            } else if (snake.contains(index)) {
              return Padding(
                padding: const EdgeInsets.all(0.5),
                child: Container(
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(3)),
                    color: Color.fromARGB(255, 0, 255, 0),
                  ),
                ),
              );
            } else if (bonusFood.contains(index)) {
              return Padding(
                padding: const EdgeInsets.all(0.5),
                child: Container(
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(3)),
                    color: Color.fromARGB(200, 255, 165, 0),
                  ),
                ),
              );
            } else {
              return Padding(
                padding: const EdgeInsets.all(0.5),
                child: Container(
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(3)),
                    color: Color.fromARGB(200, 120, 120, 120),
                  ),
                ),
              );
            }
          }),
    );
  }
}

class Controllers extends StatelessWidget {
  const Controllers({super.key});

  @override
  Widget build(BuildContext context) {
    return const Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        ControllerLeft(),
        SizedBox(
          width: 15,
        ),
        ControllerDown(),
        SizedBox(
          width: 15,
        ),
        ControllerUp(),
        SizedBox(
          width: 15,
        ),
        ControllerRight(),
      ],
    );
  }
}

class ControllerUp extends StatelessWidget {
  const ControllerUp({super.key});

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<SnakeGameState>();
    return GestureDetector(
      onTap: () => appState.changeDirection('up'),
      child: Container(
        width: 50,
        height: 50,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Color.fromARGB(255, 120, 120, 120),
        ),
        child: const Icon(
          Icons.keyboard_arrow_up,
        ),
      ),
    );
  }
}

class ControllerRight extends StatelessWidget {
  const ControllerRight({super.key});

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<SnakeGameState>();
    return GestureDetector(
      onTap: () => appState.changeDirection("right"),
      child: Container(
        width: 50,
        height: 50,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Color.fromARGB(255, 120, 120, 120),
        ),
        child: const Icon(
          Icons.keyboard_arrow_right,
        ),
      ),
    );
  }
}

class ControllerDown extends StatelessWidget {
  const ControllerDown({super.key});

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<SnakeGameState>();
    return GestureDetector(
      onTap: () => appState.changeDirection("down"),
      child: Container(
        width: 50,
        height: 50,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Color.fromARGB(255, 120, 120, 120),
        ),
        child: const Icon(
          Icons.keyboard_arrow_down,
        ),
      ),
    );
  }
}

class ControllerLeft extends StatelessWidget {
  const ControllerLeft({super.key});

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<SnakeGameState>();
    return GestureDetector(
      onTap: () => appState.changeDirection("left"),
      child: Container(
        width: 50,
        height: 50,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Color.fromARGB(255, 120, 120, 120),
        ),
        child: const Icon(
          Icons.keyboard_arrow_left,
        ),
      ),
    );
  }
}

class Score extends StatelessWidget {
  const Score({super.key});

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<SnakeGameState>();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
      child: Text(
        "Score: ${appState.score}",
        style:
            TextStyle(fontSize: 24, color: Color.fromARGB(255, 120, 120, 120)),
      ),
    );
  }
}
