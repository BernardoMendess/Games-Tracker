import 'package:flutter/material.dart';
import 'package:login_app/controller/login_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:login_app/controller/game_controller.dart';
import 'package:login_app/model/game.dart';
import 'package:login_app/view/login.dart';
import 'package:login_app/view/gameDetails.dart';
import 'package:login_app/view/reviewRecents.dart';

class Home extends StatefulWidget {
  final String username;

  const Home({Key? key, required this.username}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List<Game> gameList = [];
  TextEditingController gameController = TextEditingController();
  var _db = GameController();
  var _lc = LoginController();

  String? selectedGenre;
  double? selectedReviewRating;

  @override
  void initState() {
    super.initState();
    loadGames();
  }

  Future<void> loadGames() async {
    List<Game> games;
    int? userId = await _lc.getUserIdByUsername(widget.username);

    if (userId != null) {
      games = await _db.getGamesByUserId(userId);
    } else {
      games = await _db.getLastestGames();
    }

    setState(() {
      gameList = games;
    });
  }

  Widget gameItemBuild(BuildContext context, int index) {
    TextEditingController gameController = TextEditingController();

    return Dismissible(
      key: Key(gameList[index].id.toString()),
      direction: DismissDirection.horizontal,
      onDismissed: (DismissDirection direction) {
        if (direction == DismissDirection.startToEnd) {
          gameController.text = gameList[index].name ?? '';

          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text("Editar Jogo"),
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
                    child: Text("Atualizar"),
                    onPressed: () async {
                      gameList[index].name = gameController.text;
                      updateGame(gameList[index]);
                      Navigator.pop(context);
                    },
                  ),
                ],
              );
            },
          );
        } else if (direction == DismissDirection.endToStart) {
          Game removedGame = gameList[index];
          gameList.removeAt(index);
          deleteGame(removedGame.id!);

          final snackBar = SnackBar(
            content: Text("Jogo excluído!"),
            duration: Duration(seconds: 5),
            action: SnackBarAction(
              label: "Desfazer",
              onPressed: () {
                setState(() {
                  gameList.insert(index, removedGame);
                });
              },
            ),
          );

          ScaffoldMessenger.of(context).showSnackBar(snackBar);
        }
      },
      background: Container(
        color: Colors.green,
        padding: EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Icon(Icons.edit, color: Colors.white,),
          ],
        ),
      ),
      secondaryBackground: Container(
        color: Colors.red,
        padding: EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Icon(Icons.delete, color: Colors.white,),
          ],
        ),
      ),
      child: ListTile(
        title: Text(gameList[index].name ?? ''),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => GameDetails(game: gameList[index]),
            ),
          ).then((value) {
            loadGames();
          });
        },
      ),
    );
  }

  void _insertGame() async {
    String gameStr = gameController.text;
    int? userId = await _lc.getUserIdByUsername(widget.username);

    Game game = Game(userId, gameStr, "2023-01-01", "Descrição do jogo");
    int result = await _db.insertGame(game);
    print("Inserted: $result");

    loadGames();
  }

  void updateGame(Game game) async {
    int result = await _db.updateGame(game);

    print("Updated: $result");
    loadGames();
  }

  void deleteGame(int id) async {
    int result = await _db.deleteGame(id);
    print("Deleted: $id");
    loadGames();
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

  Widget buildGamesList() {
    return ListView.builder(
      itemCount: gameList.length,
      itemBuilder: (context, index) => gameItemBuild(context, index),
    );
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
      floatingActionButton: widget.username.isNotEmpty
          ? FloatingActionButton(
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
                        decoration:
                            InputDecoration(labelText: "Digite o nome do jogo"),
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
            )
          : null,
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
                    // Filtrar por data de lançamento
                  },
                  child: Text('Data de Lançamento'),
                ),
                ElevatedButton(
                  onPressed: () {
                    // Filtrar por gênero
                  },
                  child: Text('Gênero'),
                ),
                ElevatedButton(
                  onPressed: () {
                    // Filtrar por nota da review
                  },
                  child: Text('Nota da Review'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => RecentReviews()),
                    );
                  },
                  child: Text('Reviews Recentes'),
                ),
              ],
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                getFilteredGames();
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

  void getFilteredGames() {
    // Adicione aqui a lógica de filtro
  }
}
