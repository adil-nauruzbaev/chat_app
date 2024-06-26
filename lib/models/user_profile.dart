class UserProfile {
  String? uid;
  String? name;
  String? picURL;

  UserProfile({
    required this.uid,
    required this.name,
    required this.picURL,
  });

  UserProfile.fromJson(Map<String, dynamic> json) {
    uid = json['uid'];
    name = json['name'];
    picURL = json['picURL'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = name;
    data['picURL'] = picURL;
    data['uid'] = uid;
    return data;
  }
}
