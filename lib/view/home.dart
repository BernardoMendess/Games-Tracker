import 'package:flutter/material.dart';
import 'package:login_app/controller/genre_controller.dart';
import 'package:login_app/controller/login_controller.dart';
import 'package:login_app/controller/game_controller.dart';
import 'package:login_app/model/game.dart';
import 'package:login_app/model/genre.dart';
import 'package:login_app/view/login.dart';
import 'package:login_app/view/recent_reviews.dart';
import 'package:login_app/view/game_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Home extends StatefulWidget {
  final String username;

  const Home({Key? key, required this.username}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List<Game> gameList = [];
  List<Genre> genreList = [];
  TextEditingController gameController = TextEditingController();
  TextEditingController releaseDateController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  TextEditingController startDateController = TextEditingController();
  TextEditingController endDateController = TextEditingController();
  var _db = GameController();
  var _lc = LoginController();
  var _gc = GenreController();

  String? selectedGenre;
  double? selectedReviewRating;

  @override
  void initState() {
    super.initState();
    loadGames();
    getGenres();
  }

  void _insertGame() async {
    String gameStr = gameController.text;
    String dataStr = releaseDateController.text;
    String descriptionStr = descriptionController.text;
    int? userId = await _lc.getUserIdByUsername(widget.username);

    Game game = Game(userId, gameStr, dataStr, descriptionStr);
    int result = await _db.insertGame(game);
    loadGames();
  }

  void updateGame(Game game) async {
    int result = await _db.updateGame(game);
    loadGames();
  }

  void deleteGame(int id) async {
    int result = await _db.deleteGame(id);
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

  loadGames() async {
    List<Game> games;
    int? userId = await _lc.getUserIdByUsername(widget.username);
    games = userId != null ? await _db.getGamesByUserId(userId) : await _db.getLastestGames();

    setState(() {
      gameList = games;
    });
  }

  void getGenres() async {
    List<Genre> genres = await _gc.getGenres();

    setState(() {
      genreList = genres;
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
              builder: (context) => GameScreen(userId: gameList[index].userId!, gameId: gameList[index].id!),
            ),
          ).then((value) {
            loadGames();
          });
        },
      ),
    );
  }

  Widget buildGamesList() {
    return ListView.builder(
      itemCount: gameList.length,
      itemBuilder: (context, index) => gameItemBuild(context, index),
    );
  }

  void getFilteredGames() async {
    List<Game> filteredGames = [];

    if (selectedGenre != null) {
      int genreId = int.parse(selectedGenre!);
      filteredGames = await _db.searchGamesByGenre(genreId);
    } else if (selectedReviewRating != null) {
      double minRating = selectedReviewRating!;
      double maxRating = selectedReviewRating! + 0.99;
      filteredGames = await _db.searchGamesByReviewRating(minRating, maxRating);
    } else {
      String startDateStr = startDateController.text;
      String endDateStr = endDateController.text;

      if (startDateStr.isNotEmpty && endDateStr.isNotEmpty) {
        DateTime startDate = DateTime.parse(startDateStr);
        DateTime endDate = DateTime.parse(endDateStr);

        filteredGames = await _db.searchGamesByReleaseDate(startDate.toString(), endDate.toString());
      }
    }

    setState(() {
      gameList = filteredGames;
    });
  }

  void selectGenre(String genreId) {
    setState(() {
      selectedGenre = genreId;
    });
  }

  void selectReviewRating(double rating) {
    setState(() {
      selectedReviewRating = rating;
    });
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
              backgroundColor: Color.fromARGB(255, 230, 137, 137),
              onPressed: () {
                gameController.clear();
                releaseDateController.clear();
                descriptionController.clear();

                showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: Text("Adicionar Game"),
                      content: SingleChildScrollView(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            TextField(
                              keyboardType: TextInputType.text,
                              decoration: InputDecoration(labelText: "Digite o nome do jogo"),
                              controller: gameController,
                            ),
                            TextField(
                              keyboardType: TextInputType.datetime,
                              decoration: InputDecoration(labelText: "Data de Lançamento"),
                              controller: releaseDateController,
                            ),
                            TextField(
                              keyboardType: TextInputType.multiline,
                              decoration: InputDecoration(labelText: "Descrição"),
                              controller: descriptionController,
                            ),
                          ],
                        ),
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
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text('Data de Lançamento'),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              TextField(
                                keyboardType: TextInputType.datetime,
                                decoration: InputDecoration(labelText: "Data de Início (YYYY-MM-DD)"),
                                controller: startDateController,
                              ),
                              TextField(
                                keyboardType: TextInputType.datetime,
                                decoration: InputDecoration(labelText: "Data de Fim (YYYY-MM-DD)"),
                                controller: endDateController,
                              ),
                            ],
                          ),
                          actions: [
                            TextButton(
                              child: Text("Cancelar"),
                              onPressed: () {
                                Navigator.pop(context);
                              },
                            ),
                            TextButton(
                              child: Text("Buscar"),
                              onPressed: () {
                                getFilteredGames();
                                Navigator.pop(context);
                              },
                            ),
                          ],
                        );
                      },
                    );
                  },
                  child: Text('Buscar por Data de Lançamento'),
                ),
                ElevatedButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text('Selecione um Gênero'),
                          content: DropdownButton<String>(
                            value: selectedGenre,
                            onChanged: (String? newValue) {
                              selectGenre(newValue!);
                              Navigator.of(context).pop();
                            },
                            items: genreList.map<DropdownMenuItem<String>>((Genre genre) {
                              return DropdownMenuItem<String>(
                                value: genre.id.toString(),
                                child: Text(genre.name!),
                              );
                            }).toList(),
                          ),
                        );
                      },
                    );
                  },
                  child: Text('Gênero'),
                ),
                ElevatedButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text('Selecione um Intervalo de Nota da Review'),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ...[1.0, 2.0, 3.0, 4.0, 5.0].map((rating) {
                                return RadioListTile<double>(
                                  title: Text('$rating - ${(rating + 0.99).toStringAsFixed(2)}'),
                                  value: rating,
                                  groupValue: selectedReviewRating,
                                  onChanged: (double? newValue) {
                                    if (newValue != null) {
                                      selectReviewRating(newValue);
                                    }
                                    Navigator.of(context).pop();
                                  },
                                );
                              }).toList(),
                            ],
                          ),
                        );
                      },
                    );
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
}
