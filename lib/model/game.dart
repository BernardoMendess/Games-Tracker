class Game {
  int? id;
  int? userId;
  String? name;
  String? releaseDate;
  String? description;

  Game(this.userId, this.name, this.releaseDate, this.description);
  
  Game.withId(this.id, this.userId, this.name, this.releaseDate, this.description);

  Game.fromMap(Map<String, dynamic> map) {
    this.id = map["id"];
    this.userId = map["user_id"];
    this.name = map["name"];
    this.releaseDate = map["release_date"];
    this.description = map["description"];
  }

  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = {
      "user_id": this.userId,
      "name": this.name,
      "release_date": this.releaseDate,
      "description": this.description
    };

    if (this.id != null) {
      map["id"] = this.id;
    }

    return map;
  }
}
