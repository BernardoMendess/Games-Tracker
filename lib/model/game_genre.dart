class GameGenre {
  int? gameId;
  int? genreId;

  GameGenre(this.gameId, this.genreId);

  GameGenre.fromMap(Map map) {
    this.gameId = map["game_id"];
    this.genreId = map["genre_id"];
  }

  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = {
      "game_id": this.gameId,
      "genre_id": this.genreId 
    };

    return map;
  }
}
