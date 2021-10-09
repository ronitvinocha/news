import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:news/database.dart';
import 'package:news/model/article.dart';
import 'package:news/model/genericshimmer.dart';
import 'package:news/model/newsapiresponse.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:sembast/sembast.dart';
import 'package:collection/collection.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class HomePage extends StatefulWidget {
  HomePage({Key key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  final isNewToOld = ValueNotifier<bool>(true);
  var store = StoreRef.main();
  List<Articles> articleList;
  List<Articles> offlineArticleList = [];
  var _scrollController = ScrollController();
  RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  @override
  void initState() {
    super.initState();
    fetchArticles();
    isNewToOld.addListener(() {
      _scrollController.animateTo(0,
          duration: Duration(milliseconds: 300),
          curve: Curves.fastLinearToSlowEaseIn);
    });
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      systemNavigationBarColor: Colors.black,
    ));
  }

  fetchArticles() async {
    try {
      var response = await http.get(Uri.parse(
          'https://candidate-test-data-moengage.s3.amazonaws.com/Android/news-api-feed/staticResponse.json'));
      var db = await NewsDatabase.createorGetDatabase();
      var offlineList = await store.record('articleList').get(db) as List;
      if (offlineList != null) {
        setState(() {
          offlineArticleList =
              offlineList.map((x) => Articles.fromMap(x))?.toList();
        });
        print(offlineArticleList);
        var tempList =
            List.of(NewsApiRepsonse.fromJson(response.body).articles);
        for (Articles article in offlineArticleList) {
          var temparticle = tempList.firstWhereOrNull(((element) =>
              (element.title == article.title &&
                  element.author == article.author)));
          tempList[tempList.indexOf(temparticle)] = article;
        }
        setState(() {
          articleList = List.of(tempList);
        });
      } else {
        setState(() {
          articleList =
              List.of(NewsApiRepsonse.fromJson(response.body).articles);
        });
      }
      _refreshController.refreshCompleted();
    } catch (e) {
      var db = await NewsDatabase.createorGetDatabase();
      var offlineList = await store.record('articleList').get(db) as List;
      if (offlineList != null) {
        setState(() {
          offlineArticleList =
              offlineList.map((x) => Articles.fromMap(x))?.toList();
        });
        print(offlineArticleList);
        setState(() {
          articleList = List.of(offlineArticleList);
        });
      }
      _refreshController.refreshCompleted();
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Color.fromRGBO(70, 70, 70, 1),
        appBar: AppBar(
            centerTitle: true,
            elevation: 0,
            backgroundColor: Colors.black,
            title: Text(
              "Headlines",
              style: Theme.of(context).textTheme.headline1,
            ),
            actions: [
              ValueListenableBuilder(
                  valueListenable: isNewToOld,
                  builder: (ctx, value, _) {
                    return IconButton(
                        iconSize: 30,
                        icon: Icon(value
                            ? Icons.arrow_drop_down
                            : Icons.arrow_drop_up),
                        color: Colors.white,
                        onPressed: () {
                          {
                            toggleTiming();
                          }
                        });
                  })
            ]),
        body: articleList == null
            ? ListView.builder(itemBuilder: (ctx, index) {
                return Container(
                    margin: EdgeInsets.only(top: 20, left: 16, right: 16),
                    child: GenericShimmer(
                      height: 200,
                      radius: 4,
                    ));
              })
            : SmartRefresher(
                controller: _refreshController,
                onRefresh: _onRefresh,
                enablePullDown: true,
                header: CustomHeader(
                  refreshStyle: RefreshStyle.Behind,
                  height: 70,
                  builder: (ctx, status) {
                    return Container(
                      height: 70,
                      alignment: Alignment.topCenter,
                      child: SpinKitFadingCircle(
                        color: Colors.white,
                        duration: Duration(milliseconds: 700),
                        size: 30.0,
                      ),
                    );
                  },
                ),
                child: ListView.builder(
                  controller: _scrollController,
                  itemBuilder: (ctx, index) {
                    return articleWidget(articleList[index]);
                  },
                  itemCount: articleList.length,
                ),
              ),
      ),
    );
  }

  _onRefresh() {
    fetchArticles();
  }

  toggleTiming() {
    isNewToOld.value = !isNewToOld.value;
    setState(() {
      articleList = List.of(articleList.reversed.toList());
    });
  }

  saveArticle(Articles article) async {
    var newarticle = article;
    newarticle.isSaved = !newarticle.isSaved;
    setState(() {
      articleList[articleList.indexOf(article)] = newarticle;
    });
    var db = await NewsDatabase.createorGetDatabase();
    if (newarticle.isSaved) {
      print(newarticle);
      offlineArticleList.add(newarticle);
      await store
          .record('articleList')
          .put(db, offlineArticleList.map((e) => e.toMap()).toList());
    } else {
      offlineArticleList.remove(newarticle);
      await store
          .record('articleList')
          .put(db, offlineArticleList.map((e) => e.toMap()).toList());
    }
  }

  Widget articleWidget(Articles article) {
    var date = DateTime.parse(article.publishedAt);
    var oustputformat = DateFormat("EEE, MMM dd");
    var timeformat = DateFormat("hh:mm a");
    return InkWell(
        onTap: () {
          _launchURL(article.url);
        },
        child: Container(
          margin: EdgeInsets.only(top: 20, left: 16, right: 16),
          width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(8)),
          child: Stack(
            children: [
              ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: ShaderMask(
                    shaderCallback: (bounds) {
                      return LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [Colors.white, Colors.black])
                          .createShader(bounds);
                    },
                    child: Container(
                      height: 200,
                      width: MediaQuery.of(context).size.width,
                      child: CachedNetworkImage(
                        imageUrl: article.urlToImage,
                        fit: BoxFit.fill,
                        placeholder: (context, url) => Container(
                          color: Colors.grey,
                          child: SpinKitSquareCircle(
                            color: Colors.white,
                            size: 30.0,
                          ),
                        ),
                        errorWidget: (context, url, error) => Container(
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  )),
              Positioned(
                  child: TextButton(
                      onPressed: () {
                        saveArticle(article);
                      },
                      style: ButtonStyle(
                          padding: MaterialStateProperty.all(EdgeInsets.zero)),
                      child: Container(
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: Colors.black.withOpacity(0.6),
                        ),
                        child: !article.isSaved
                            ? Text(
                                "Save to offline",
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyText2
                                    .merge(TextStyle(
                                        fontSize: 14, color: Colors.white)),
                              )
                            : Row(
                                children: [
                                  Text("Saved",
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyText2
                                          .merge(TextStyle(
                                              fontSize: 14,
                                              color: Colors.white))),
                                  Container(
                                    width: 5,
                                  ),
                                  Icon(
                                    Icons.check,
                                    color: Colors.white,
                                  )
                                ],
                              ),
                      )),
                  right: 4,
                  top: 4),
              Positioned(
                  bottom: 10,
                  left: 10,
                  right: 10,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        article.title,
                        style: Theme.of(context)
                            .textTheme
                            .bodyText1
                            .merge(TextStyle(fontSize: 14)),
                      ),
                      Container(
                        height: 10,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            oustputformat.format(date),
                            style: Theme.of(context).textTheme.bodyText2.merge(
                                TextStyle(fontSize: 12, color: Colors.white60)),
                          ),
                          Text(
                            timeformat.format(date),
                            style: Theme.of(context).textTheme.bodyText2.merge(
                                TextStyle(fontSize: 12, color: Colors.white60)),
                          )
                        ],
                      )
                    ],
                  ))
            ],
          ),
        ));
  }

  void _launchURL(_url) async => await canLaunch(_url)
      ? await launch(_url)
      : () {
          final snackBar = SnackBar(
              backgroundColor: Colors.red.shade400,
              duration: Duration(seconds: 2),
              content: Text(
                'Can not launch url',
                style: Theme.of(context)
                    .textTheme
                    .headline2
                    .merge(TextStyle(color: Colors.white, fontSize: 14)),
              ));
          ScaffoldMessenger.of(context).showSnackBar(snackBar);
        };
}
