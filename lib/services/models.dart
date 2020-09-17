class Option {
  String value;
  String detail;
  bool complete;

  Option({this.complete, this.value, this.detail});
  Option.fromMap(Map data) {
    value = data['value'];
    detail = data['detail'] ?? '';
    complete = data['complete'];
  }
}

class Question {
  String text;
  List<Option> options;
  Question({this.options, this.text});

  Question.fromMap(Map data) {
    text = data['text'] ?? '';
    options =
        (data['options'] as List ?? []).map((v) => Option.fromMap(v)).toList();
  }
}

///// Database Collections

class Questions {
  String id;
  String title;
  String description;
  String video;
  String topic;
  List<Question> questions;

  Questions(
      {this.title,
      this.questions,
      this.video,
      this.description,
      this.id,
      this.topic});

  factory Questions.fromMap(Map data) {
    return Questions(
        id: data['id'] ?? '',
        title: data['title'] ?? '',
        topic: data['topic'] ?? '',
        description: data['description'] ?? '',
        video: data['video'] ?? '',
        questions: (data['questions'] as List ?? [])
            .map((v) => Question.fromMap(v))
            .toList());
  }
}

class Asset {
  final String id;
  final String title;
  final String description;
  final String img;
  final List<Questions> questions;

  Asset({this.id, this.title, this.description, this.img, this.questions});

  factory Asset.fromMap(Map data) {
    return Asset(
      id: data['id'] ?? '',
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      img: data['img'] ?? 'default.png',
      questions: (data['questions'] as List ?? [])
          .map((v) => Questions.fromMap(v))
          .toList(), //data['questions'],
    );
  }
}

class Reminders {
  String uid;
  int total;
  dynamic assets;

  Reminders({this.uid, this.assets, this.total});

  factory Reminders.fromMap(Map data) {
    return Reminders(
      uid: data['uid'],
      total: data['total'] ?? 0,
      assets: data['assets'] ?? {},
    );
  }
}
