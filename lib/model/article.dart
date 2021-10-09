import 'dart:convert';

import 'package:news/model/souce.dart';

class Articles {
  Source source;
  String author;
  String title;
  String description;
  String url;
  String urlToImage;
  String publishedAt;
  String content;
  bool isSaved;

  Articles(
      {this.source,
      this.author,
      this.title,
      this.description,
      this.url,
      this.urlToImage,
      this.publishedAt,
      this.content,
      this.isSaved});

  Map<String, dynamic> toMap() {
    return {
      'source': source.toMap(),
      'author': author,
      'title': title,
      'description': description,
      'url': url,
      'urlToImage': urlToImage,
      'publishedAt': publishedAt,
      'content': content,
      'isSaved': isSaved,
    };
  }

  factory Articles.fromMap(Map<String, dynamic> map) {
    return Articles(
        source: Source.fromMap(map['source']),
        author: map['author'],
        title: map['title'],
        description: map['description'],
        url: map['url'],
        urlToImage: map['urlToImage'],
        publishedAt: map['publishedAt'],
        content: map['content'],
        isSaved: map['isSaved'] == null ? false : map["isSaved"]);
  }

  String toJson() => json.encode(toMap());

  factory Articles.fromJson(String source) =>
      Articles.fromMap(json.decode(source));

  @override
  String toString() {
    return 'Articles(source: $source, author: $author, title: $title, description: $description, url: $url, urlToImage: $urlToImage, publishedAt: $publishedAt,  isSaved: $isSaved)';
  }
}
