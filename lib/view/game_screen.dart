import 'package:flutter/material.dart';
import 'package:login_app/controller/game_controller.dart';
import 'package:login_app/controller/review_controller.dart';
import 'package:login_app/model/game.dart';
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
  var _db = GameController();
  var _rc = ReviewController();

  @override
  void initState() {
    super.initState();
  }

  void _insertReview() async {
    String reviewStr = reviewController.text;

    if (widget.userId != null) {
      Review review = Review(widget.userId, widget.gameId, 5, "", reviewStr);
      int result = await _rc.insertReview(review);
      loadReviews();
    }
  }

  void loadReviews() async {
    List<Review> reviews = await _rc.getReviews();

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
          content: TextField(
            keyboardType: TextInputType.multiline,
            maxLines: null,
            controller: reviewController,
            decoration: InputDecoration(
              hintText: 'Escreva sua review aqui...',
            ),
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
