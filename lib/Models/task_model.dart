class TaskModel {
  String? TaskId;
  String? title;
  String? description;
  String? date;
  bool? status;
  String? parentId;

  TaskModel(
      {this.TaskId,
      this.title,
      this.description,
      this.date,
      this.status,
      this.parentId});

  TaskModel.fromJosn(Map<String, dynamic>? json,this.TaskId) {
    TaskId = TaskId;
    title = json?["title"];
    description = json?["description"];
    date = json?["date"];
    status = json?["status"];
    parentId = json?["parentId"];
  }
  Map<String, dynamic> toMap() {
    return {
      "title": title,
      "description": description,
      "date": date,
      "status": status,
      "parentId": parentId
    };
  }
}
