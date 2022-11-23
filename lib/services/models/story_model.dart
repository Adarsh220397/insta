class StoryModel {
  String name;

  String image;
  num count;
  bool isEnabled;
  StoryModel(
      {required this.name,
      required this.image,
      required this.count,
      required this.isEnabled});

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = name;
    data['image'] = image;

    data['count'] = count;
    data['isEnabled'] = isEnabled;
    return data;
  }

  factory StoryModel.fromJson(dynamic json) {
    return StoryModel(
      name: json['name'] as String,
      image: json['image'] as String,
      count: json['count'] as num,
      isEnabled: json['isEnabled'] == null ? false : json['isEnabled'] as bool,
    );
  }
}
