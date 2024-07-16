import 'package:flutter/material.dart';
import 'package:login_app/controller/game_controller.dart';
import 'package:login_app/model/game.dart';

class GameScreen extends StatelessWidget {
  final int gameId;

  const GameScreen({required this.gameId, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Detalhes do Jogo'),
      ),
      body: FutureBuilder<Game>(
        future: GameController().getGameById(gameId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Erro ao carregar os dados.'));
          } else if (!snapshot.hasData) {
            return Center(child: Text('Nenhum jogo encontrado.'));
          }

          final game = snapshot.data!;

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Nome do Jogo: ${game.name}',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text('Descrição: ${game.description}'),
                SizedBox(height: 8),
                Text('Data de Lançamento: ${game.releaseDate}'),
              ],
            ),
          );
        },
      ),
    );
  }
}
