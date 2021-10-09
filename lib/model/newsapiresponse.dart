import 'dart:convert';

import 'package:news/model/article.dart';

class NewsApiRepsonse {
  String status;
  List<Articles> articles;

  NewsApiRepsonse({this.status, this.articles});

  Map<String, dynamic> toMap() {
    return {
      'status': status,
      'articles': articles?.map((x) => x.toMap())?.toList(),
    };
  }

  factory NewsApiRepsonse.fromMap(Map<String, dynamic> map) {
    return NewsApiRepsonse(
      status: map['status'],
      articles:
          List<Articles>.from(map['articles']?.map((x) => Articles.fromMap(x))),
    );
  }

  String toJson() => json.encode(toMap());

  factory NewsApiRepsonse.fromJson(String source) =>
      NewsApiRepsonse.fromMap(json.decode(source));

  @override
  String toString() => 'NewsApiRepsonse(status: $status, articles: $articles)';
}
