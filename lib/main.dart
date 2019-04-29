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
import 'package:scoped_model/scoped_model.dart';
import 'package:goedale_client/scoped_model/beer_table.dart';

import 'package:goedale_client/pages/stock_page.dart';
import 'package:goedale_client/pages/cart_page.dart';
import 'package:goedale_client/pages/history_page.dart';
import 'package:goedale_client/pages/admin_page.dart';

import 'package:goedale_client/functions/globals.dart'; //weg?



void main() => runApp(MyApp(BeerTable()));



class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  final BeerTable beerTable;
  const MyApp(this.beerTable);

  @override
  Widget build(BuildContext context) {
    return ScopedModel<BeerTable>(
      model: beerTable,
      child: MaterialApp(
        title: 'Goedale',
        theme: ThemeData.dark(),
        home: HomeWidget(),
      ),
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
  @override
  void initState() {
    super.initState();
    pageController = new PageController();
    //updateTableNumber();
    tableNumber = ScopedModel.of<BeerTable>(context).tableNumber;
      setAppBarTitle();
  }
//  Future updateTableNumber() async {
//    getTableNumber().then((result) {
//      setState(() {
//        tableNumber = result.toString();
//      });
//    });
//  }

  setAppBarTitle() {
    tableNumber = ScopedModel.of<BeerTable>(context).tableNumber;
    if (_page == 0) {
      appBarTitleText = Text("Aanbod - Goedale - Tafel: " + tableNumber);
    } else if (_page == 1) {
      appBarTitleText = Text("Winkelwagen - Goedale - Tafel: " + tableNumber);
    } else if (_page == 2) {
      appBarTitleText = Text("Bestellingen - Goedale - Tafel: " + tableNumber);
    }
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
                    icon:  Stack(
                      children: <Widget>[
                        Icon(Icons.shopping_cart, color: (_page == 1) ? Colors.white : Colors.grey),
                        Positioned(
                          right: 0,
                          child:  Container(
                            padding: EdgeInsets.all(1),
                            decoration:  BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            constraints: BoxConstraints(
                              minWidth: 12,
                              minHeight: 12,
                            ),
                            child:  Text(
                              '5',//todo somehow manage state better to get cart items here.
                              style:  TextStyle(
                                color: Colors.white,
                                fontSize: 8,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        )
                      ],
                    ),),
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
      setAppBarTitle();
    });
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
              keyboardType: TextInputType.number,
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
                    _textFieldController.text = "";
                    Navigator.of(context).pop();
                    openAdminAndWait(context)
                 //   _getAdminSettings(); //remove?
                  } else{
                    print("wrong pw");
                  }
                },
              )
            ],
          );
        });
  }
openAdminAndWait(BuildContext context) async {
  final result = await Navigator.push(context, MaterialPageRoute(builder: (context) => AdminPage()));
// todo fix this wait, this wait just updates the title after the context has closed. because we can't somehow change it otherwise
  setAppBarTitle();
}

}

