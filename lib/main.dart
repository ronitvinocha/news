import 'package:flutter/material.dart';
import 'package:news/hompage.dart';


void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
          pageTransitionsTheme: PageTransitionsTheme(builders: {
            TargetPlatform.android: CupertinoPageTransitionsBuilder(),
            TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          }),
          primarySwatch: Colors.blue,
          primaryColor: Color(0xFFC5192D),
          bottomSheetTheme: BottomSheetThemeData(
              backgroundColor: Colors.black.withOpacity(0)),
          visualDensity: VisualDensity.adaptivePlatformDensity,
          fontFamily: 'Manrope',
          backgroundColor: Colors.white,
          hintColor: Color.fromRGBO(228, 228, 228, 0.6),
          dividerColor: Color.fromRGBO(255, 255, 255, 1),
          disabledColor: Color.fromRGBO(235, 235, 228, 1),
          textSelectionTheme: TextSelectionThemeData(
            selectionHandleColor: Colors.transparent,
          ),
          textTheme: TextTheme(
            headline1: TextStyle(
                fontSize: 25.0,
                fontWeight: FontWeight.w800,
                fontStyle: FontStyle.normal,
                color: Colors.white),
            headline2: TextStyle(
                fontSize: 22.0,
                fontWeight: FontWeight.w700,
                fontStyle: FontStyle.normal,
                color: Colors.white),
            bodyText1: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontStyle: FontStyle.normal,
                fontWeight: FontWeight.w500),
            bodyText2: TextStyle(
                color: Color(0xFF484848),
                fontSize: 12,
                fontStyle: FontStyle.normal,
                fontWeight: FontWeight.w400),
          )),
      home: HomePage(),
    );
  }
}
