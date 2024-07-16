import 'package:flutter/material.dart';
import 'package:login_app/controller/game_controller.dart';
import 'package:login_app/model/game.dart';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:login_app/view/login.dart';

class Home extends StatefulWidget {
  final String username;

  const Home({Key? key, required this.username}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List<Game> gameList = [];
  TextEditingController gameController = TextEditingController();
  TextEditingController gameController2 = TextEditingController();
  var _db = GameController();

  @override
  void initState() {
    super.initState();
    getGames();
  }

  Widget buildGamesList() {
    if (widget.username.isNotEmpty) {
      return ListView.builder(
        itemCount: gameList.length,
        itemBuilder: gameItemBuild,
      );
    } else {
      return Container(
        alignment: Alignment.center,
        child: Text('Lista dos últimos jogos com nota aqui'),
      );
    }
  }

  Widget gameItemBuild(BuildContext context, int index) {
    return Dismissible(
      key: Key(DateTime.now().microsecondsSinceEpoch.toString()),
      direction: DismissDirection.horizontal,
      onDismissed: (direction) {
        var lastRemovedGame;

        if (direction == DismissDirection.startToEnd) {
          // Atualizar Jogo
          gameController2.text = gameList[index].name!;

          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: Text("Atualizar Game"),
                content: TextField(
                  keyboardType: TextInputType.text,
                  decoration: InputDecoration(labelText: "Digite o nome"),
                  controller: gameController2,
                ),
                actions: [
                  TextButton(
                    child: Text("Cancelar"),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                  TextButton(
                    child: Text("Atualizar"),
                    onPressed: () {
                      Game game = gameList[index];
                      String gameStr = gameController2.text;
                      game.name = gameStr;
                      updateGame(game);

                      Navigator.pop(context);
                    },
                  ),
                ],
              );
            },
          );
        } else if (direction == DismissDirection.endToStart) {
          // Excluindo o Jogo
          lastRemovedGame = gameList[index];
          gameList.removeAt(index);
          bool isExecuted = false;

          final snackBar = SnackBar(
            content: Text("Jogo excluído!"),
            duration: Duration(seconds: 5),
            action: SnackBarAction(
              label: "Desfazer",
              onPressed: () {
                isExecuted = true;
                setState(() {
                  gameList.insert(index, lastRemovedGame);
                });
              },
            ),
          );

          ScaffoldMessenger.of(context).showSnackBar(snackBar);

          Timer(Duration(seconds: 5), () {
            if (!isExecuted) deleteGame(lastRemovedGame.id!);
          });
        }
      },
      background: Container(
        color: Colors.green,
        padding: EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Icon(Icons.edit, color: Colors.white),
          ],
        ),
      ),
      secondaryBackground: Container(
        color: Colors.red,
        padding: EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Icon(Icons.delete, color: Colors.white),
          ],
        ),
      ),
      child: ListTile(
        title: Text(gameList[index].name!),
        onTap: () {
          // Detalhes do jogo
        },
      ),
    );
  }

  void _insertGame() async {
    String gameStr = gameController.text;

    Game game = Game(1, gameStr, "2023-01-01", "Descrição do jogo");
    int result = await _db.insertGame(game);
    print("Inserted: $result");

    getGames();
  }

  void getGames() async {
    List games = await _db.getGames();
    print("games: ${games.toString()}");

    gameList.clear();
    for (var gameMap in games) {
      Game game = Game.fromMap(gameMap);
      gameList.add(game);
    }

    setState(() {});
  }

  void updateGame(Game game) async {
    int result = await _db.updateGame(game);

    print("Updated: $result");
    getGames();
  }

  void deleteGame(int id) async {
    int result = await _db.deleteGame(id);
    print("Deleted: $id");
    getGames();
  }

  void _logout() async {
    bool confirmLogout = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirmação'),
        content: Text('Tem certeza que deseja sair?'),
        actions: <Widget>[
          TextButton(
            child: Text('Cancelar'),
            onPressed: () {
              Navigator.of(context).pop(false);
            },
          ),
          TextButton(
            child: Text('Sair'),
            onPressed: () {
              Navigator.of(context).pop(true);
            },
          ),
        ],
      ),
    );

    if (confirmLogout) {
      SharedPreferences preferences = await SharedPreferences.getInstance();
      preferences.clear();

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => Login()),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Games Tracker"),
        backgroundColor: const Color.fromARGB(255, 214, 82, 82),
        actions: [
          if (widget.username.isNotEmpty)
            IconButton(
              icon: Icon(Icons.logout),
              onPressed: () { _logout(); },
            ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: widget.username.isNotEmpty ? FloatingActionButton(
        child: Icon(Icons.add),
        backgroundColor: Colors.black,
        onPressed: () {
          gameController.clear();

          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: Text("Adicionar Game"),
                content: TextField(
                  keyboardType: TextInputType.text,
                  decoration: InputDecoration(labelText: "Digite o nome do jogo"),
                  controller: gameController,
                ),
                actions: [
                  TextButton(
                    child: Text("Cancelar"),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                  TextButton(
                    child: Text("Salvar"),
                    onPressed: () {
                      _insertGame();
                      Navigator.pop(context);
                    },
                  ),
                ],
              );
            },
          );
        },
      ) : null,
      body: Container(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                  },
                  child: Text('Data de Lançamento'),
                ),
                ElevatedButton(
                  onPressed: () {
                  },
                  child: Text('Gênero'),
                ),
                ElevatedButton(
                  onPressed: () {
                  },
                  child: Text('Nota da Review'),
                ),
              ],
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
              },
              child: Text('Buscar Jogos'),
            ),
            SizedBox(height: 20),
            Expanded(
              child: buildGamesList(),
            ),
          ],
        ),
      ),
    );
  }
}
