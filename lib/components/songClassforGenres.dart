class Song {
  final String imageUrl;
  final String name;
  final String artistName;

  Song({required this.imageUrl, required this.name, required this.artistName});

  factory Song.fromJson(Map<String, dynamic> json) {
    return Song(
      imageUrl: json['imageUrl'],
      name: json['name'],
      artistName: json['artists'].join(', '),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'imageUrl': imageUrl,
      'name': name,
      'artistName': artistName,
    };
  }

  factory Song.fromMap(Map<String, dynamic> map) {
    return Song(
      imageUrl: map['imageUrl'],
      name: map['name'],
      artistName: map['artistName'],
    );
  }
}
