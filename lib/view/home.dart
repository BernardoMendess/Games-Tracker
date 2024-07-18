import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:login_app/controller/genre_controller.dart';
import 'package:login_app/controller/login_controller.dart';
import 'package:login_app/controller/game_controller.dart';
import 'package:login_app/controller/review_controller.dart';
import 'package:login_app/model/game.dart';
import 'package:login_app/model/genre.dart';
import 'package:login_app/view/edit_game_screen.dart';
import 'package:login_app/view/list_games.dart';
import 'package:login_app/model/review.dart';
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
  int? userId;
  var _db = GameController();
  var _lc = LoginController();
  var _gc = GenreController();
  var _rv = ReviewController();

  String? selectedGenre;
  double? selectedReviewRating;

  @override
  void initState() {
    super.initState();
    loadGames();
    getGenres();
  }

  void _insertGame(int genreId) async {
    String gameStr = gameController.text;
    String dataStr = releaseDateController.text;
    String descriptionStr = descriptionController.text;
    userId = await _lc.getUserIdByUsername(widget.username);

    Game game = Game(userId, gameStr, dataStr, descriptionStr);
    int result = await _db.insertGame(game, genreId);
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
    userId = await _lc.getUserIdByUsername(widget.username);
    games = userId != null
        ? await _db.getGamesByUserId(userId!)
        : await _db.getLastestGames();

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

  Future<String> calcRating(int id) async {
  List<Review> reviews = await _rv.getReviewsByGameId(id);
  double sum = 0;
  for (Review r in reviews) {
    sum += r.score!;
  }
  double average = sum / reviews.length;
  return average.toStringAsFixed(1);
}


  DateTime? selectedDate;
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
        releaseDateController.text = DateFormat('dd/MM/yyyy').format(selectedDate!);
      });
    }
  }
  
  Widget gameItemBuild(BuildContext context, int index) {
    return Dismissible(
      key: Key(gameList[index].id.toString()),
      direction: DismissDirection.endToStart,
      onDismissed: (DismissDirection direction) {
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
      },
      background: Container(
        color: Colors.red,
        padding: EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Icon(
              Icons.delete,
              color: Colors.white,
            ),
          ],
        ),
      ),
      child: Column(
        children: [
          ListTile(
            title: Text(gameList[index].name ?? ''),
            subtitle: FutureBuilder<String>(
              future: calcRating(gameList[index].id!),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Text("Calculando...");
                } else if (snapshot.hasError) {
                  return Text("Erro: ${snapshot.error}");
                } else {
                  return Text("Rating: ${snapshot.data}");
                }
              },
            ),
            trailing: widget.username.isNotEmpty
                ? IconButton(
                    icon: Icon(Icons.edit),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EditGameScreen(game: gameList[index]),
                        ),
                      ).then((updatedGame) {
                        if (updatedGame != null) {
                          setState(() {
                            gameList[index] = updatedGame;
                          });
                        }
                      });
                    },
                  )
                : null,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => GameScreen(userId: userId, gameId: gameList[index].id!),
                ),
              ).then((value) {
                loadGames();
              });
            },
          ),
          Divider(),
        ],
      )
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
      double maxRating = selectedReviewRating! + 0.9;
      filteredGames = await _db.getGamesByRating(minRating, maxRating);
    } else {
      String startDateStr = startDateController.text;
      String endDateStr = endDateController.text;

      if (startDateStr.isNotEmpty && endDateStr.isNotEmpty) {
        DateTime startDate = DateTime.parse(startDateStr);
        DateTime endDate = DateTime.parse(endDateStr);

        filteredGames = await _db.searchGamesByReleaseDate(
            startDate.toString(), endDate.toString());
      }
    }

    setState(() {
      gameList = filteredGames;
    });
  }

  void getGames() async {
    List<Game> games = [];

    games = await _db.getGamesByUserId((await _lc.getUserIdByUsername(widget.username))!);

    setState(() {
      gameList = games;
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

  void clearFilters() {
    setState(() {
      selectedGenre = null;
      selectedReviewRating = null;
      startDateController.clear();
      endDateController.clear();
      loadGames(); 
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Games Tracker",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Color.fromARGB(255, 99, 179, 99),
        actions: [
          if (widget.username.isNotEmpty)
            IconButton(
              icon: Icon(
                Icons.logout,
                color: Colors.white,
              ),
              onPressed: () {
                _logout();
              },
            ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: widget.username.isNotEmpty
          ? FloatingActionButton(
              child: Icon(Icons.add, color: Colors.white,),
              backgroundColor: Color.fromARGB(255, 182, 235, 175),
              onPressed: () {
                gameController.clear();
                releaseDateController.clear();
                descriptionController.clear();
                selectedGenre = null;

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
                              decoration: InputDecoration(
                                  labelText: "Digite o nome do jogo"),
                              controller: gameController,
                            ),
                            GestureDetector(
                              onTap: () => _selectDate(context),
                              child: AbsorbPointer(
                                child: TextFormField(
                                  keyboardType: TextInputType.datetime,
                                  decoration: InputDecoration(
                                    labelText: "Data de Lançamento",
                                    border: OutlineInputBorder(),
                                    contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                                  ),
                                  controller: releaseDateController,
                                ),
                              ),
                            ),
                            TextField(
                              keyboardType: TextInputType.multiline,
                              decoration:
                                  InputDecoration(labelText: "Descrição"),
                              controller: descriptionController,
                            ),
                            DropdownButtonFormField<String>(
                              decoration: InputDecoration(
                                  labelText: "Selecione um gênero"),
                              value: selectedGenre,
                              items: genreList.map((Genre genre) {
                                return DropdownMenuItem<String>(
                                  value: genre.id.toString(),
                                  child: Text(genre.name!),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  selectedGenre = value;
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                      actions: [
                        TextButton(
                          child: Text(
                            "Cancelar",
                            style: TextStyle(
                              color: Color.fromARGB(255, 99, 179, 99),
                            ),
                          ),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                        ),
                        TextButton(
                          child: Text(
                            "Salvar",
                            style: TextStyle(
                              color: Color.fromARGB(255, 99, 179, 99),
                            ),
                          ),
                          onPressed: () {
                            int genreId = int.parse(selectedGenre!);
                            _insertGame(genreId);
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
        padding: EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(height: 10),
            Text(
              'Filtros',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20),
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
                                keyboardType: TextInputType.name,
                                decoration: InputDecoration(
                                    labelText: "Data de Início (YYYY-MM-DD)"),
                                controller: startDateController,
                              ),
                              TextField(
                                keyboardType: TextInputType.name,
                                decoration: InputDecoration(
                                    labelText: "Data de Fim (YYYY-MM-DD)"),
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
                  child: Text('Data de Lançamento',
                      style:
                          TextStyle(color: Color.fromARGB(255, 99, 179, 99))),
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
                            items: genreList
                                .map<DropdownMenuItem<String>>((Genre genre) {
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
                  child: Text('Gênero',
                      style:
                          TextStyle(color: Color.fromARGB(255, 99, 179, 99))),
                ),
                ElevatedButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title:
                              Text('Selecione um Intervalo de Nota da Review'),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ...[0.1, 1.1, 2.1, 3.1, 4.1, 5.1, 6.1, 7.1, 8.1, 9.1].map((rating) {
                                return RadioListTile<double>(
                                  title: Text(
                                      '$rating - ${(rating + 0.9).toStringAsFixed(1)}'),
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
                  child: Text('Nota da Review',
                      style:
                          TextStyle(color: Color.fromARGB(255, 99, 179, 99))),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    getFilteredGames();
                  },
                  child: Text('Buscar Jogos',
                      style: TextStyle(color: Color.fromARGB(255, 99, 179, 99))),
                ),
                ElevatedButton(
                  onPressed: () {
                    clearFilters();
                  },
                  child: Text('Limpar Filtros',
                      style: TextStyle(color: Color.fromARGB(255, 99, 179, 99))),
                ),
                SizedBox(height: 20),
              ],
            ),
            Text(
              'Explorar',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => RecentReviews()),
                      );
                    },
                    child: Text('Reviews Recentes',
                      style: TextStyle(color: Color.fromARGB(255, 99, 179, 99)),
                    ),
                  ),
                  SizedBox(width: 10),
                  if (widget.username.isNotEmpty)
                    ElevatedButton(
                      onPressed: () async {
                        int? userId = await _lc.getUserIdByUsername(widget.username);
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => ListGames(userId: userId!,)),
                        );
                      },
                      child: Text('Jogos de outros usuários',
                        style: TextStyle(color: Color.fromARGB(255, 99, 179, 99)),
                      ),
                    ),
                ],
              ),
            ),
            SizedBox(height: 35),
            Text(
              'Listagem de Jogos',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
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