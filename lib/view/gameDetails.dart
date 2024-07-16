import 'package:flutter/material.dart';
import 'package:login_app/model/game.dart';

class GameDetails extends StatelessWidget {
  final Game game;

  const GameDetails({Key? key, required this.game}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(game.name!),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Detalhes do jogo aqui'),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Adicionar Review
              },
              child: Text('Adicionar Review'),
            ),
          ],
        ),
      ),
    );
  }
}
