class Data {
  final String title;
  final List<dynamic> res;
  
  const Data({
    required this.title,
    required this.res,
  });

  factory Data.fromJson(Map<String, dynamic> json) {
    return Data(
      title: json['feed']['title'],
      res: json['feed']['results'],
    );
  }
}
