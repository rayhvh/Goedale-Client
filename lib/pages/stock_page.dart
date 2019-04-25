import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:goedale_client/widgets/firestore_stock_listview.dart';
import 'package:goedale_client/main.dart';


class StockPage extends StatefulWidget {
  @override
  _StockPage createState() => _StockPage();
}

class _StockPage extends State<StockPage>{

  @override
  Widget build(BuildContext context){
    return Container(
    child:  Container(
      child: StreamBuilder(
        stream: Firestore.instance
            .collection('bokaalStock')
            .snapshots(), // change to dynamic db?
        builder: (BuildContext context,
            AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) return CircularProgressIndicator();
          return FirestoreStockListview(
              beersInStock: snapshot.data.documents);
        },
      ),
    ),);
  }
}
