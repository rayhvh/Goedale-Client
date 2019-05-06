import 'package:flutter/material.dart';
import 'package:goedale_client/scoped_model/global_model.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:qr_flutter/qr_flutter.dart';

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

       return StreamBuilder(
          stream: Firestore.instance.collection('bokaalTables').document(globalModel.tableNumber).collection('orders').document(globalModel.currentOrderId).snapshots(),
          builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
          if (!snapshot.hasData)return CircularProgressIndicator();
            if(snapshot.data.data['isPaid'] == true){


              return Scaffold(
                appBar: AppBar(
                  title: Text('Betaald'),
                  automaticallyImplyLeading: false,
                ),
                body: Container(
                  child: Center(
                    child: Column(
                      children: <Widget>[
                        Text('Yes! betaald!'),
                        SizedBox(
                          width: 125,
                          child: RaisedButton(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Text('Doorgaan!'),
                                Icon(Icons.navigate_next),
                              ],
                            ),
                            onPressed: () async {
                              await globalModel.orderGotPaid().then((_){
                                Navigator.pop(context);
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }
            else {

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
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                                "Scan de QR code met je telefoon of ga naar:",
                                style: Theme.of(context).textTheme.title),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text("https://raymond.notive.app/pay/" + globalModel.currentOrderId +"/"+ globalModel.tableNumber,
                                style: TextStyle(fontSize: 25.0, color: Colors.red, decoration: TextDecoration.underline, fontWeight: FontWeight.bold)
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                                "om je bestelling te betalen",
                                style: Theme.of(context).textTheme.title),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Container(
                              color: Colors.white,
                              child: QrImage(
                                  data: "https://raymond.notive.app/pay/" + globalModel.currentOrderId +"/"+ globalModel.tableNumber,
                                  size: 500
                              ),
                            ),
                          ),
                        /*  Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text("Bestelling: " + globalModel.currentOrderId,style: Theme.of(context).textTheme.title),
                          ),*/
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text("Te betalen bedrag: €" + globalModel.totalAmount.toString(),style: Theme.of(context).textTheme.title),
                          ),

                          SizedBox(
                            height: 5,
                            width: 5,
                            child: RaisedButton(
                              color: Colors.grey[850],
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[

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
            }
          }

        );
      },
    );
  }
}
