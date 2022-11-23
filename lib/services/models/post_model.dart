class PostModel {
  String name;
  String uid;
  String image;
  num count;
  bool isEnabled;

  PostModel(
      {required this.name,
      required this.image,
      required this.count,
      required this.uid,
      required this.isEnabled});

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = name;
    data['image'] = image;
    data['uid'] = uid;
    data['count'] = count;
    data['isEnabled'] = isEnabled;
    return data;
  }

  factory PostModel.fromJson(dynamic json) {
    return PostModel(
      name: json['name'] as String,
      image: json['image'] as String,
      uid: json['uid'] == null ? '' : json['uid'] as String,
      count: json['count'] as num,
      isEnabled: json['isEnabled'] == null ? false : json['isEnabled'] as bool,
    );
  }
}
