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
import 'package:goedale_client/functions/globals.dart';
import 'package:goedale_client/pages/admin_page.dart';

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
  var appBarTitleText = new Text("Goedale");
  int _page = 0;
  String tableNumber;

  Future updateTableNumber() async {
    getTableNumber().then((result) {
      setState(() {
        tableNumber = result.toString();
      });
    });
  }

  setAppBarTitle() {
    if (_page == 0) {
      appBarTitleText = Text("Aanbod - Goedale - Tafel: " + tableNumber);
    } else if (_page == 1) {
      appBarTitleText = Text("Winkelwagen - Goedale - Tafel: " + tableNumber);
    } else if (_page == 2) {
      appBarTitleText = Text("Bestellingen - Goedale - Tafel: " + tableNumber);
    }
  }

  @override
  void initState() {
    super.initState();
    pageController = new PageController();
    updateTableNumber();
    //  setTableNumber(6); // make menu for this.
//    getTableNumber().then((result){
//      setState(() {
//        tableNumber = result.toString();
//      });
//    });
  }

  Widget build(BuildContext context) {
    return Scaffold(
        drawer: Drawer(
          child: ListView(
            // Important: Remove any padding from the ListView.
            padding: EdgeInsets.zero,
            children: <Widget>[
              DrawerHeader(
                child: Text('Goedale - Bokaal'),
                decoration: BoxDecoration(
                  color: Colors.red,
                ),
              ),
              ListTile(
                title: Text('Beheer'),
                onTap: () {
                  _displayDialog(context);
                },
              ),
              ListTile(
                title: Text('Instellingen'),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        ),
        appBar: AppBar(
            title:
                appBarTitleText //Text((_page == 0) ?  "Aanbod" : "Winkelwagen" + ' - Goedale - Tafel: ' + tableNumber),
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
        bottomNavigationBar: SizedBox(
          height: 70,
          child: CupertinoTabBar(
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
          ),
        ));
  }

  void navigationTapped(int page) {
    //Animating Page
    pageController.jumpToPage(page);
    //pageController.animateToPage(page, duration: Duration(milliseconds: 250), curve: Curves.easeInOutQuart);
  }

  void onPageChanged(int page) {

    setState(() {
      this._page = page;
    });
    setAppBarTitle();
  }

  @override
  void dispose() {
    super.dispose();
    pageController.dispose();
  }

  TextEditingController _textFieldController = TextEditingController();
  _displayDialog(BuildContext context) async {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Voer pincode in'),
            content: TextField(
              controller: _textFieldController,
              decoration: InputDecoration(hintText: "Pincode"),
              obscureText: true,
            ),
            actions: <Widget>[
              FlatButton(
                child: new Text('Annuleren'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              FlatButton(
                child: Text("Ok"),
                onPressed: () {
                  if (_textFieldController.text == "1234") {
                    Navigator.of(context).pop();
                    Navigator.push(
                        context,
                        new MaterialPageRoute(
                            builder: (context) => AdminPage()));
                  } else{
                    print("wrong pw");
                  }
                },
              )
            ],
          );
        });
  }
}
