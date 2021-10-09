import 'dart:convert';

class Source {
  String id;
  String name;

  Source({this.id, this.name});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
    };
  }

  factory Source.fromMap(Map<String, dynamic> map) {
    return Source(
      id: map['id'],
      name: map['name'],
    );
  }

  String toJson() => json.encode(toMap());

  factory Source.fromJson(String source) => Source.fromMap(json.decode(source));

  @override
  String toString() => 'Source(id: $id, name: $name)';
}
