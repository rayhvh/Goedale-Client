import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:goedale_client/widgets/starrating_widget.dart';
import 'package:goedale_client/functions/utils.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:goedale_client/pages/beerdetail_page.dart';
import 'package:goedale_client/scoped_model/global_model.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:goedale_client/pages/payment_page.dart';
import 'dart:async';

class CartListView extends StatefulWidget {
  final List<DocumentSnapshot> cartItems;

  CartListView({this.cartItems});

  @override
  _CartListViewState createState() => _CartListViewState();
}

class _CartListViewState extends State<CartListView> {


  @override
  initState() {
    super.initState();
//    getTableNumber().then((tableNumberResult){
//      updatePrices(tableNumberResult);
//    });
    ScopedModel.of<GlobalModel>(context).updatePrices();
    print('initstat');
  }



  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<GlobalModel>(
      builder: (context,child,globalModel){
        return Column(
          children: <Widget>[
            Expanded(
              child: ListView.builder(
                  itemCount: widget.cartItems.length,
                  itemBuilder: (BuildContext context, int index) {
                    return StreamBuilder( //todo Stream builder for each cart item, vs entire stock + listview builder with check on matching ID from cart items.
                        stream: Firestore.instance
                            .collection('bokaalStock')
                            .document(widget.cartItems[index].data['beerId'])
                            .snapshots(), // change to dynamic db?
                        builder: (BuildContext context,
                            AsyncSnapshot<DocumentSnapshot> snapshot) {

                          if (!snapshot.hasData) return CircularProgressIndicator();
                          return ListTile(
                            title: Column(
                              children: <Widget>[
                                Row(
                                  children: <Widget>[
                                    Expanded(
                                      child: ListTile(
                                        isThreeLine: true,
                                        leading: CircleAvatar(
                                          backgroundImage:
                                          CachedNetworkImageProvider(
                                            snapshot.data['label']['iconUrl'],
                                          ),
                                        ),
                                        title: Text(snapshot.data['name'],
                                            style: TextStyle(fontWeight: FontWeight.bold)),
                                        subtitle: Column(
                                          crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                          children: <Widget>[
                                            Text(snapshot.data['brewery']),
                                            Text(snapshot.data['abv'].toString() +
                                                "%"),
                                            Text(snapshot.data['style']),
                                            StarRating(
                                              rating:
                                              toRound(snapshot.data['rating']),
                                              color: Colors.white,
                                              borderColor: Colors.white,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Column(
                                        children: <Widget>[],
                                      ),
                                    ),
                                    Expanded(
                                      child: Column(
                                        children: <Widget>[
                                          StreamBuilder(
                                            stream: Firestore.instance
                                                .collection('bokaalTables')
                                                .document(
                                                globalModel.tableNumber)
                                                .collection("cart")
                                                .document(
                                                snapshot.data.data['id'])
                                                .snapshots(), // change to dynamic db?
                                            builder: (BuildContext context,
                                                AsyncSnapshot<DocumentSnapshot>
                                                snapshotCart) {
                                              if (!snapshotCart.hasData) {
                                                return CircularProgressIndicator();
                                              } else {
                                                if (snapshotCart
                                                    .data.data['qty'] ==
                                                    0) {
                                                  Firestore.instance
                                                      .runTransaction((Transaction
                                                  transaction) async {
                                                    // improve using batch,
                                                    DocumentReference
                                                    reference = Firestore
                                                        .instance
                                                        .collection(
                                                        "bokaalTables")
                                                        .document(
                                                        globalModel.tableNumber)
                                                        .collection("cart")
                                                        .document(snapshot
                                                        .data.data['id']);
                                                    await reference.delete();
                                                  });
                                                  return Container();
                                                } else {
                                                  return Column(
                                                    children: <Widget>[
                                                      Text("Aantal (" +
                                                          snapshot.data
                                                              .data['amount']
                                                              .toString() +
                                                          " beschikbaar)"),
                                                      Row(
                                                        mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                        children: <Widget>[
                                                          Padding(
                                                            padding:
                                                            const EdgeInsets
                                                                .all(8.0),
                                                            child: RaisedButton(
                                                                color: Colors
                                                                    .white,
                                                                onPressed: () {
                                                                  Firestore.instance.runTransaction((Transaction transaction) async {
                                                                    DocumentReference reference = Firestore.instance.collection("bokaalTables")
                                                                        .document(globalModel.tableNumber).collection("cart")
                                                                            .document(snapshot.data.data['id']);
                                                                        await reference.updateData(
                                                                          {
                                                                            "qty": snapshotCart.data.data['qty'] - 1,
                                                                          },).then((_){
                                                                          Firestore.instance.runTransaction((Transaction transaction) async {
                                                                                DocumentReference reference = Firestore.instance.collection("bokaalStock")
                                                                                    .document(snapshot.data.data['id']);
                                                                                await reference.updateData(
                                                                                    {
                                                                                  "amount": snapshot.data.data['amount'] + 1,
                                                                                }).then((_){

                                                                                  globalModel.updatePrices();
                                                                                  globalModel.updateCartItemAmount();
                                                                                });
                                                                              });
                                                                        });
                                                                      });


                                                                },
                                                                child: Icon(
                                                                  Icons.remove,
                                                                  color: Colors
                                                                      .black,
                                                                )),
                                                          ),
                                                          Text(
                                                              snapshotCart.data
                                                                  .data['qty'].toString(), style: Theme.of(context).textTheme.title),
                                                          Padding(
                                                            padding:
                                                            const EdgeInsets
                                                                .all(8.0),
                                                            child: RaisedButton(
                                                                color: Colors
                                                                    .white,
                                                                onPressed:
                                                                (snapshot.data.data['amount'] == 0) ? null : () {
                                                                  Firestore.instance.runTransaction((Transaction
                                                                  transaction) async {
                                                                    // improve using batch,
                                                                    DocumentReference reference = Firestore.instance.collection("bokaalTables").document(globalModel.tableNumber).collection("cart").document(snapshot.data.data['id']);
                                                                    await reference.updateData(
                                                                      {
                                                                        "qty": snapshotCart.data.data['qty'] + 1,
                                                                      },
                                                                    ).then((_) {
                                                                      Firestore.instance.runTransaction((Transaction
                                                                      transaction) async {
                                                                        DocumentReference reference = Firestore.instance.collection("bokaalStock").document(snapshot.data.data['id']);
                                                                        await reference.updateData({
                                                                          "amount": snapshot.data.data['amount'] - 1,
                                                                        }).then((_) {
                                                                          //updatePrices(globalModel.tableNumber);
                                                                          globalModel.updatePrices();
                                                                          globalModel.updateCartItemAmount();
                                                                        });
                                                                      });
                                                                    });
                                                                  });
                                                                  },
                                                                child:
                                                                const Icon(
                                                                  Icons.add,
                                                                  color: Colors
                                                                      .black,
                                                                )),
                                                          ),
                                                        ],
                                                      ),
                                                      Text("x €" +
                                                          snapshot.data
                                                              .data['price']
                                                              .toString() +
                                                          " = €" +
                                                          (snapshot.data.data[
                                                          'price'] *
                                                              snapshotCart
                                                                  .data
                                                                  .data[
                                                              'qty'])
                                                              .toString())
                                                    ],
                                                  );
                                                }
                                              }
                                            },
                                          )//todo exporting this to a separate file or improve

                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                Divider(
                                  height: 15.0,
                                  color: Colors.white,
                                ),
                              ],
                            ),
                            onTap: () {
                              Navigator.push(
                                  context,
                                  new MaterialPageRoute(
                                      builder: (context) => BeerDetailPage(
                                          widget.cartItems[index].data['beerId'])));
                            },
                          );
                        });
                  }),
            ),
            Container(
             // color: Colors.white,
        decoration: new BoxDecoration(
        gradient: new LinearGradient(
        colors: [
        Colors.grey,
       Colors.white,
        ],
        begin: const FractionalOffset(0.0, 0.0),
        end: const FractionalOffset(1.0, 0.0),
        stops: [0.0, 1.0],
        tileMode: TileMode.clamp)),
                constraints: BoxConstraints.expand(
                  height: 60
                ),
                child:
                 Row(
                   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                   children: <Widget>[
                     Text("Te betalen bedrag: €" + globalModel.totalAmount.toString(), style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold)),
                   RaisedButton(
                     color: Colors.black,
                       onPressed: () async {
                         await globalModel.moveCartToOrder().then((_) async{
                          await Navigator.push(context, MaterialPageRoute(builder: (context) => PaymentPage())).then((_){
                          //  print('after pay exec.');
                          //  Future.delayed(Duration(seconds: 1), () => globalModel.updatePrices());
                            //globalModel.updatePrices();
                           // globalModel.updateCartItemAmount();
                          });
                         });
                       },
                       child:Text("Naar betalen"))
                   ],
                 )),
          ],
        );
      },

    );
  }
}




//
//  getTableNumber() async{
//     return await ScopedModel.of<GlobalModel>(context).loadTableNumber();
//  }
//
//  Future<List<DocumentSnapshot>> getBeersId(String tableNumberResult) async{
//    var data = await Firestore.instance.collection('bokaalTables').document(tableNumberResult).collection('cart').getDocuments();
//    var beerId = data.documents;
//    return beerId;
//  }
//
//  Future updatePrices(String tableNumberResult) async{
//    num tempTotal =0;
//    getBeersId(tableNumberResult).then((data) async {
//      for (int i=0; i < data.length; i++ ){
//       var beer = await Firestore.instance.collection('bokaalStock').document(data[i]['beerId']).get();
//      // print(data[i]['qty'].toString() + " getPrices, qty");
//       tempTotal += beer.data['price'] * data[i]['qty'];
//       setState(() {
//       });
//      // print(tempTotal.toString() + " total vannuit getPrices ");
//      }
//    }).then((_) {
//      setState(() {
//        totalPrice = tempTotal;
//        print(totalPrice);
//      });
//    });
//  }