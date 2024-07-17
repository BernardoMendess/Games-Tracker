import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:login_app/controller/game_controller.dart';
import 'package:login_app/controller/genre_controller.dart';
import 'package:login_app/controller/review_controller.dart';
import 'package:login_app/model/game.dart';
import 'package:login_app/model/game_genre.dart';
import 'package:login_app/model/genre.dart';
import 'package:login_app/model/review.dart';

class GameScreen extends StatefulWidget {
  final int gameId;
  final int? userId;

  const GameScreen({required this.gameId, this.userId, Key? key}) : super(key: key);

  @override
  _GameScreenState createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  List<Review> reviewList = [];
  TextEditingController reviewController = TextEditingController();
  TextEditingController ratingController = TextEditingController();
  var _db = GameController();
  var _gr = GenreController();
  var _rc = ReviewController();

  @override
  void initState() {
    super.initState();
    loadReviews();
  }

  void _insertReview() async {
    String reviewStr = reviewController.text;
    double rating = double.parse(ratingController.text);

    if (widget.userId != null) {
      Review review = Review(widget.userId!, widget.gameId, rating, DateTime.now().toString(), reviewStr);
      int result = await _rc.insertReview(review);
      if (result != 0) {
        reviewController.clear();
        ratingController.clear();
        loadReviews();
      }
    }
  }

  void loadReviews() async {
    List<Review> reviews = await _rc.getReviewsByGameId(widget.gameId);

    setState(() {
      reviewList = reviews;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Detalhes do Jogo'),
        backgroundColor: const Color.fromARGB(255, 214, 82, 82),
      ),
      body: FutureBuilder<Game?>(
        future: _db.getGameById(widget.gameId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Erro ao carregar os dados.'));
          } else if (!snapshot.hasData || snapshot.data == null) {
            return Center(child: Text('Nenhum jogo encontrado.'));
          }

          final game = snapshot.requireData!;

          return FutureBuilder<GameGenre>(
            future: _db.getGameGenreById(game.id!),
            builder: (context, genreSnapshot) {
              if (genreSnapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              } else if (genreSnapshot.hasError) {
                return Center(child: Text('Erro ao carregar gênero do jogo'));
              } else if (!genreSnapshot.hasData) {
                return Center(child: Text('Gênero do jogo não encontrado'));
              }

              final gameGender = genreSnapshot.requireData;

              return FutureBuilder<Genre>(
                future: _gr.getGenreById(gameGender.genreId!),
                builder: (context, genreDetailSnapshot) {
                  if (genreDetailSnapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (genreDetailSnapshot.hasError) {
                    return Center(child: Text('Erro ao carregar detalhes do gênero'));
                  } else if (!genreDetailSnapshot.hasData) {
                    return Center(child: Text('Gênero não encontrado'));
                  }

                  final genre = genreDetailSnapshot.requireData;

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
                        Text('Gênero: ${genre.name}'),
                        SizedBox(height: 8),
                        Text('Data de Lançamento: ${game.releaseDate}'),
                        SizedBox(height: 8),
                        Text('Descrição: ${game.description}'),
                        SizedBox(height: 16),
                        Text(
                          'Reviews:',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 8),
                        Expanded(
                          child: ListView.builder(
                            itemCount: reviewList.length,
                            itemBuilder: (context, index) {
                              final review = reviewList[index];
                              return ListTile(
                                title: Text('Nota: ${review.score}'),
                                subtitle: Text(review.description!),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          );
        },
      ),
      floatingActionButton: widget.userId != null ? FloatingActionButton.extended(
        onPressed: () {
          _addReviewDialog();
        },
        label: Text('Review'),
        icon: Icon(Icons.rate_review),
        backgroundColor: Color.fromARGB(255, 230, 137, 137),
      ) : null,
    );
  }

  void _addReviewDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Adicionar Review'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: ratingController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: 'Nota (0-10)',
                ),
              ),
              TextField(
                keyboardType: TextInputType.multiline,
                maxLines: null,
                controller: reviewController,
                decoration: InputDecoration(
                  hintText: 'Escreva sua review aqui...',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              child: Text('Cancelar'),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            TextButton(
              child: Text('Salvar'),
              onPressed: () {
                _insertReview();
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }
}
