
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:goedale_client/widgets/starrating_widget.dart';
import 'package:goedale_client/functions/utils.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:goedale_client/pages/beerdetail_page.dart';
import 'package:goedale_client/scoped_model/beer_table.dart';
import 'package:scoped_model/scoped_model.dart';

class CartListView extends StatefulWidget {
  final List<DocumentSnapshot> cartItems;

  CartListView({this.cartItems});

  @override
  _CartListViewState createState() => _CartListViewState();
}

class _CartListViewState extends State<CartListView> {

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        itemCount: widget.cartItems.length,
        itemBuilder: (BuildContext context, int index) {
          return StreamBuilder(
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
                                backgroundImage: CachedNetworkImageProvider(
                                  snapshot.data['label']['iconUrl'],
                                ),
                              ),
                              title: Text(snapshot.data['name'],
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(snapshot.data['brewery']),
                                  Text(snapshot.data['abv'].toString() + "%"),
                                  Text(snapshot.data['style']),
                                  StarRating(
                                    rating: toRound(snapshot.data['rating']),
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
                                ScopedModelDescendant<BeerTable>(
                                  builder: (context,child,beerTableModel){
                                    return StreamBuilder(
                                      stream: Firestore.instance
                                          .collection('bokaalTables').document(beerTableModel.tableNumber).collection("cart").document(snapshot.data.data['id'])
                                          .snapshots(), // change to dynamic db?
                                      builder: (BuildContext context,
                                          AsyncSnapshot<DocumentSnapshot> snapshotCart) {
                                        if (!snapshotCart.hasData) {
                                          return CircularProgressIndicator();
                                        }
                                        else{
                                          if (snapshotCart.data.data['qty'] == 0){
                                            Firestore.instance.runTransaction(
                                                    (Transaction transaction) async { // improve using batch,
                                                  DocumentReference reference =
                                                  Firestore.instance.collection("bokaalTables").document(beerTableModel.tableNumber).collection("cart").document(snapshot.data.data['id']);
                                                  await reference.delete();
                                                });
                                            return Container();
                                          }
                                          else{
                                            return Column(
                                              children: <Widget>[
                                                Text("Aantal (" + snapshot.data.data['amount'].toString() + " beschikbaar)"),
                                                Row(
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  children: <Widget>[
                                                    Padding(
                                                      padding: const EdgeInsets.all(8.0),
                                                      child: RaisedButton(
                                                          color: Colors.white,
                                                          onPressed: () {
                                                            Firestore.instance.runTransaction(
                                                                    (Transaction transaction) async { // improve using batch,
                                                                  DocumentReference reference =
                                                                  Firestore.instance.collection("bokaalTables").document(beerTableModel.tableNumber).collection("cart").document(snapshot.data.data['id']);
                                                                  await reference.updateData({
                                                                    "qty": snapshotCart.data.data['qty'] - 1,
                                                                  }, );
                                                                }
                                                            );
                                                            Firestore.instance.runTransaction(
                                                                    (Transaction transaction) async {
                                                                  DocumentReference reference =
                                                                  Firestore.instance.collection("bokaalStock").document(snapshot.data.data['id']);
                                                                  await reference.updateData({
                                                                    "amount": snapshot.data.data['amount'] + 1,
                                                                  });
                                                                }
                                                            );
                                                          },
                                                          child:  Icon(Icons.remove, color: Colors.black,)),
                                                    ),
                                                    Text(snapshotCart.data.data['qty'].toString(), style: Theme.of(context).textTheme.title),
                                                    Padding(
                                                      padding: const EdgeInsets.all(8.0),
                                                      child: RaisedButton(
                                                          color: Colors.white,
                                                          onPressed: (snapshot.data.data['amount'] == 0) ? null :() {
                                                            Firestore.instance.runTransaction(
                                                                    (Transaction transaction) async { // improve using batch,
                                                                  DocumentReference reference =
                                                                  Firestore.instance.collection("bokaalTables").document(beerTableModel.tableNumber).collection("cart").document(snapshot.data.data['id']);
                                                                  await reference.updateData({
                                                                    "qty": snapshotCart.data.data['qty'] + 1,
                                                                  }, );
                                                                }
                                                            );
                                                            Firestore.instance.runTransaction(
                                                                    (Transaction transaction) async {
                                                                  DocumentReference reference =
                                                                  Firestore.instance.collection("bokaalStock").document(snapshot.data.data['id']);
                                                                  await reference.updateData({
                                                                    "amount": snapshot.data.data['amount'] - 1,
                                                                  });
                                                                }
                                                            );

                                                          },
                                                          child: const Icon(Icons.add, color: Colors.black,)),
                                                    ),
                                                  ],
                                                ),
                                                Text("x €" + snapshot.data.data['price'].toString() +" = €" + (snapshot.data.data['price'] * snapshotCart.data.data['qty']).toString())
                                              ],
                                            );
                                          }
                                        }
                                      },
                                    );
                                  },
                                 
                                ), //todo exporting this to a separate file or improve
                                /*Text(snapshot.data['amount'].toString() +
                                    " over in voorraad"),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    IconButton(
                                      icon: Icon(Icons.remove),
                                      iconSize: 20,
                                      color: Colors.white,
                                      onPressed: () {},
                                    ),
                                    Text(widget.cartItems[index]
                                            .data['qty']
                                            .toString() +
                                        " in winkelmandje"),
                                    IconButton(
                                      icon: Icon(Icons.add),
                                      iconSize: 20,
                                      onPressed: () {},
                                    ),
                                  ],
                                ),*/
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
        });
  }
}
