import 'package:flutter/material.dart';
import 'package:login_app/controller/game_controller.dart';
import 'package:login_app/controller/genre_controller.dart';
import 'package:login_app/model/game.dart';
import 'package:intl/intl.dart';
import 'package:login_app/model/game_genre.dart';
import 'package:login_app/model/genre.dart';

class EditGameScreen extends StatefulWidget {
  final Game game;

  const EditGameScreen({required this.game, Key? key}) : super(key: key);

  @override
  _EditGameScreenState createState() => _EditGameScreenState();
}

class _EditGameScreenState extends State<EditGameScreen> {
  List<Game> gameList = [];
  List<Genre> genreList = [];
  TextEditingController gameController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  TextEditingController releaseDateController = TextEditingController();
  String? selectedGenre;
  var _db = GameController();
  var _gc = GenreController();
  DateTime? selectedDate;

  @override
  void initState() {
    super.initState();
    gameController.text = widget.game.name ?? '';
    descriptionController.text = widget.game.description ?? '';
    if (widget.game.releaseDate != null) {
      selectedDate = DateFormat('yyyy-MM-dd').parse(widget.game.releaseDate!);
      releaseDateController.text = DateFormat('dd/MM/yyyy').format(selectedDate!);
    }
    getGenres();
  }

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

  void getGenres() async {
    List<Genre> genres = await _gc.getGenres();

    setState(() {
      genreList = genres;
    });
  }

  Future<GameGenre?> getGameGenre(int gameId) async {
    return await _db.getGameGenreById(gameId);
  }

  Future<void> updateGame(int genreId) async {
    Game game = Game.withId(
      widget.game.id,
      widget.game.userId,
      gameController.text,
      selectedDate != null ? DateFormat('yyyy-MM-dd').format(selectedDate!) : null,
      descriptionController.text,
    );

    int result = await _db.updateGame(game, genreId);

    if (result > 0) {
      loadGames();
      Navigator.pop(context, game);
    }
  }

  void loadGames() async {
    List<Game> game = await _db.getGames();

    setState(() {
      gameList = game;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Editar Jogo',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Color.fromARGB(255, 99, 179, 99),
      ),
      body: FutureBuilder<GameGenre?>(
        future: getGameGenre(widget.game.id!),
        builder: (context, genreSnapshot) {
          if (genreSnapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (genreSnapshot.hasError) {
            return Center(child: Text('Erro ao carregar gênero do jogo'));
          } else if (!genreSnapshot.hasData) {
            return Center(child: Text('Gênero do jogo não encontrado'));
          }

          final gameGenre = genreSnapshot.data;

          if (gameGenre != null && selectedGenre == null) {
            selectedGenre = gameGenre.genreId.toString();
          }

          return SingleChildScrollView(
            padding: EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  keyboardType: TextInputType.text,
                  decoration: InputDecoration(
                    labelText: "Digite o nome do jogo",
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                  ),
                  controller: gameController,
                ),
                SizedBox(height: 20),
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    labelText: "Selecione um gênero",
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                  ),
                  value: selectedGenre,
                  items: genreList.map((Genre genre) {
                    return DropdownMenuItem<String>(
                      value: genre.id.toString(),
                      child: Text(genre.name!),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedGenre = value!;
                    });
                  },
                ),
                SizedBox(height: 20),
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
                SizedBox(height: 20),
                TextFormField(
                  keyboardType: TextInputType.multiline,
                  maxLines: null,
                  decoration: InputDecoration(
                    labelText: "Descrição",
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                  ),
                  controller: descriptionController,
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text(
                        'Cancelar',
                        style: TextStyle(color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Color.fromARGB(255, 99, 179, 99)),
                    ),
                    SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: () async {
                        if (selectedGenre != null) {
                          int genreId = int.parse(selectedGenre!);
                          await updateGame(genreId);
                        }
                      },
                      child: Text(
                        'Salvar',
                        style: TextStyle(color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Color.fromARGB(255, 99, 179, 99)),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
