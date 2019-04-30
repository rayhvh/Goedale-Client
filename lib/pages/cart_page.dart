import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:goedale_client/widgets/cart_listview.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:goedale_client/scoped_model/global_model.dart';

class CartPage extends StatefulWidget {
  @override
  _CartPage createState() => _CartPage();
}

class _CartPage extends State<CartPage>{

  @override
  void initState(){
    super.initState();
  }

  @override
  Widget build(BuildContext context){
    return Container( child: ScopedModelDescendant<GlobalModel>(
      builder: (context,child,globalModel){
        return StreamBuilder(
          stream: Firestore.instance
              .collection('bokaalTables').document(globalModel.tableNumber).collection('cart')
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
