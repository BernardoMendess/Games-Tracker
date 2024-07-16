
class Review {
  int? id;
  int? userId;
  int? gameId;
  double? score;
  String? date;
  String? description;

  Review(this.userId, this.gameId, this.score, this.date, this.description);

  Review.fromMap(Map map) {
    this.id = map["id"];
    this.userId = map["user_id"];
    this.gameId = map["game_id"];
    this.score = map["score"];
    this.date = map["date"];
    this.description = map["description"];
  }

  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = {
      "user_id": this.userId,
      "game_id": this.gameId,
      "score": this.score,
      "date": this.date,
      "description": this.description
    };

    if (this.id != null) {
      map["id"] = this.id;
    }

    return map;
  }
}
