class Repo {
  int? id;
  String? fullname;
  String? private;
  String? avataUrl;
  String? type;
  String? description;
  String? login;

  Repo({
    this.id,
    this.fullname,
    this.private,
    this.avataUrl,
    this.type,
    this.description,
    this.login,
  });

  static Repo fromJson(json) {
    return Repo(
      id: json["id"],
      fullname: json['fullname'],
      private: json['private'],
      avataUrl: json['avataUrl'],
      type: json['type'],
      description: json['description'],
      login: json['login'],
    );
  }
}
