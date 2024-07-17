import 'package:flutter/material.dart';
import 'package:login_app/controller/game_controller.dart';
import 'package:login_app/model/game.dart';
import 'package:login_app/view/game_screen.dart';

class ListGames extends StatefulWidget {
  final int? userId;
  const ListGames({required this.userId, Key? key}) : super(key: key);

  @override
  _ListGamesState createState() => _ListGamesState();
}

class _ListGamesState extends State<ListGames> {
  List<Game> gameList = [];
  var _db = GameController();

  @override
  void initState() {
    super.initState();
    loadGames();
  }

  loadGames() async {
    List<Game> games;
    games = await _db.getGamesNotUser(widget.userId!);

    setState(() {
      gameList = games;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Jogos',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Color.fromARGB(255, 99, 179, 99),
      ),
      body: gameList.isEmpty
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: gameList.length,
              itemBuilder: (context, index) {
                return Container(
                  margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    border: Border(bottom: BorderSide(color: Colors.grey)),
                  ),
                  child: ListTile(
                    title: Text(gameList[index].name!),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => GameScreen(userId: widget.userId, gameId: gameList[index].id!),
                        ),
                      ).then((value) {
                        loadGames();
                      });
                    },
                  ),
                );
              },
            ),
    );
  }
}
