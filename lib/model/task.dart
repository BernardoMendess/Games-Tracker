class Task {
  int? id;
  String? title;
  int? done;

  Task(this.title, this.done);

  Task.fromMap(Map map) {
    this.id = map["id"];
    this.title = map["title"];
    this.done = map["done"];
  }

  Map<String, dynamic> toMap(){
    Map<String, dynamic> map = {
      "title": this.title,
      "done": this.done
    };
    
    if (this.id != null) {
      map["id"] = this.id;
    }
    
    return map; 
  }
}