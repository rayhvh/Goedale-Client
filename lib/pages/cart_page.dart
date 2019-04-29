import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:goedale_client/main.dart';
import 'package:goedale_client/functions/globals.dart';
import 'package:goedale_client/widgets/cart_listview.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:goedale_client/scoped_model/beer_table.dart';

class CartPage extends StatefulWidget {
  @override
  _CartPage createState() => _CartPage();
}

class _CartPage extends State<CartPage>{

  //String queryNumber; //todo add listener for this. needs update after change.
  @override
  void initState(){
    super.initState();
//    getTableNumber().then((result){
//      setState(() {
//        queryNumber = result.toString();
//      });
//    });
  }

  @override
  Widget build(BuildContext context){
    return Container( child: ScopedModelDescendant<BeerTable>(
      builder: (context,child,beerTableModel){
        return StreamBuilder(
          stream: Firestore.instance
              .collection('bokaalTables').document(beerTableModel.tableNumber).collection('cart')
              .snapshots(),
          builder: (BuildContext context,
              AsyncSnapshot<QuerySnapshot> snapshot) {
            if (!snapshot.hasData) return CircularProgressIndicator();
            return CartListView(
                cartItems: snapshot.data.documents);
          },
        );

      },
    ),
    );
  }
}
