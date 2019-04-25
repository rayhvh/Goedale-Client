import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:goedale_client/main.dart';
import 'package:goedale_client/functions/globals.dart';
import 'package:goedale_client/widgets/cart_listview.dart';

class CartPage extends StatefulWidget {


  @override
  _CartPage createState() => _CartPage();
}

class _CartPage extends State<CartPage>{
  num tableIdentifyNumber = tableNumber;
  @override
  Widget build(BuildContext context){
    return Container( child: StreamBuilder(
    stream: Firestore.instance
        .collection('bokaalTables').document('6').collection('cart') // fix dynamic number..
        .snapshots(),
    builder: (BuildContext context,
    AsyncSnapshot<QuerySnapshot> snapshot) {
    if (!snapshot.hasData) return CircularProgressIndicator();
    print(tableIdentifyNumber);
    return CartListView(
    cartItems: snapshot.data.documents);
    },
    ),
    );
  }
}
