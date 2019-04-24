// This example shows a [Scaffold] with an [AppBar], a [BottomAppBar] and a
// [FloatingActionButton]. The [body] is a [Text] placed in a [Center] in order
// to center the text within the [Scaffold] and the [FloatingActionButton] is
// centered and docked within the [BottomAppBar] using
// [FloatingActionButtonLocation.centerDocked]. The [FloatingActionButton] is
// connected to a callback that increments a counter.
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'pages/stock_page.dart';
import 'pages/cart_page.dart';
import 'pages/history_page.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Code Sample for material.Scaffold',
      theme: ThemeData.dark(),
      home: HomeWidget(),
    );
  }
}

class HomeWidget extends StatefulWidget {
  HomeWidget({Key key}) : super(key: key);

  @override
  _HomeWidgetState createState() => _HomeWidgetState();
}

PageController pageController;

class _HomeWidgetState extends State<HomeWidget> {
  int _page = 0;
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Goedale'),
        ),
        body: PageView(
          children: <Widget>[
            Container(
              child: StockPage(),
            ),
            Container(
              child: CartPage(),
            ),
            Container(
              child: HistoryPage(),
            ),
          ],
          controller: pageController,
          onPageChanged: onPageChanged,
        ),
        bottomNavigationBar: CupertinoTabBar(

          items: <BottomNavigationBarItem>[
            BottomNavigationBarItem(
                icon: Icon(
              Icons.home,
              color: (_page == 0) ? Colors.white : Colors.grey,
            )),
            BottomNavigationBarItem(
                icon: Icon(
              Icons.shopping_cart,
              color: (_page == 1) ? Colors.white : Colors.grey,
            )),
            BottomNavigationBarItem(
                icon: Icon(
              Icons.history,
              color: (_page == 2) ? Colors.white : Colors.grey,
            )),
          ],
          onTap: navigationTapped,
          currentIndex: _page,
        ));
  }

  void navigationTapped(int page) {
    //Animating Page
    pageController.animateToPage(page, duration: Duration(milliseconds: 250), curve: Curves.easeInOutQuart);
  }

  void onPageChanged(int page) {
    print(pageController.page);
    setState(() {
      this._page = page;
    });
  }
  @override
  void initState() {
    super.initState();
    pageController = new PageController();
  }

  @override
  void dispose() {
    super.dispose();
    pageController.dispose();
  }
}
