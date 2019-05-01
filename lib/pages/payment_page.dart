import 'package:flutter/material.dart';
import 'package:goedale_client/scoped_model/global_model.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PaymentPage extends StatefulWidget {
  @override
  _PaymentPageState createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  @override
  void initState() {
    super.initState();
    // getTable();
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<GlobalModel>(
      builder: (context, child, globalModel) {
        return Scaffold(
          appBar: AppBar(
              title: Text("Goedale betalen"),
              automaticallyImplyLeading: false,
              actions: <Widget>[
                // action button
                IconButton(
                  icon: Icon(Icons.close),
                  onPressed: () async {
                    await globalModel.orderGotCancelled().then((_){
                      Navigator.pop(context);
                    });
                  },
                ),
              ]),
          body: Container(
              child: Center(
            child: Column(
              children: <Widget>[
                Text("Bestelling: " + globalModel.currentOrderId),
                Text("Bedrag: " + globalModel.totalAmount.toString()),
                SizedBox(
                  width: 125,
                  child: RaisedButton(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text('Betaald '),
                        Icon(Icons.check),
                      ],
                    ),
                    onPressed: () async {
                      await Firestore.instance
                          .collection('bokaalTables')
                          .document(globalModel.tableNumber)
                          .collection('orders')
                          .document(globalModel.currentOrderId)
                          .updateData({"isPaid": true});
                    },
                  ),
                ),
              ],
            ),
          )),
        );
      },
    );
  }
}
