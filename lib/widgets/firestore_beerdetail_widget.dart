import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:goedale_client/models/beer_models.dart';
import 'package:goedale_client/functions/utils.dart';
import 'package:goedale_client/widgets/starrating_widget.dart';

class FirestoreBeerdetail extends StatelessWidget {
  final DocumentSnapshot beerdocument;

  FirestoreBeerdetail({this.beerdocument});

  @override
  Widget build(BuildContext context) {
    print(beerdocument.data); // map this data to a model or not..
    TextEditingController amountController = new TextEditingController();
    if (beerdocument.data == null) {
      Navigator.pop(context);
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(beerdocument.data['name']),
      ),
      body: Row(
        children: <Widget>[
          Expanded(
            child: Column(
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          children: <Widget>[
                            CachedNetworkImage(
                              imageUrl: beerdocument.data["label"]["largeUrl"],
                              height: 200,
                            ),
                            Text(beerdocument.data['name'],
                                style: Theme.of(context).textTheme.title),
                            Text(beerdocument.data['brewery']),
                            Text(beerdocument.data['style']),
                            Text(beerdocument.data['abv'].toString() + "%"),
                            StarRating(rating: beerdocument.data['rating'],
                            color: Colors.white,
                            borderColor: Colors.white,),
                            Text(beerdocument.data['rating'].toString()),
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      child: Column(
                        children: <Widget>[
                          StreamBuilder(
                            stream: Firestore.instance
                                .collection('bokaalTables').document('6').collection("cart").document(beerdocument.data['id'])
                                .snapshots(), // change to dynamic db?
                            builder: (BuildContext context,
                                AsyncSnapshot<DocumentSnapshot> snapshot) {

                              if (!snapshot.hasData) {
                                return CircularProgressIndicator();
                              }
                              else{

                                if(snapshot.data.data == null){
                                  print("nog geen data in cart");
                                  return Column(
                                    children: <Widget>[
                                      Text("€" + beerdocument.data['price'].toString(), style: Theme.of(context).textTheme.title),
                                      Text("Nog " + beerdocument.data['amount'].toString() + " in voorraad", style: Theme.of(context).textTheme.title),
                                      RaisedButton(
                                          onPressed: () {
                                            Firestore.instance.runTransaction(
                                                    (Transaction transaction) async { // improve using batch,
                                                  DocumentReference reference =
                                                  Firestore.instance.collection("bokaalTables").document('6').collection("cart").document(beerdocument.data['id']);
                                                  //fix 6 to dynamic number.

                                                  await reference.setData({
                                                    "beerId": beerdocument.data['id'],
                                                    "qty": 1,
                                                  }, merge: true);
                                                }
                                            );
                                            Firestore.instance.runTransaction(
                                                    (Transaction transaction) async {
                                                  DocumentReference reference =
                                                  Firestore.instance.collection("bokaalStock").document(beerdocument.data['id']);
                                                  await reference.updateData({
                                                    "amount": beerdocument.data['amount'] - 1,
                                                  });
                                                }
                                            );

                                          },
                                          child: const Text('+')),
                                      Text("0 in winkelwagen", style: Theme.of(context).textTheme.title)
                                    ],
                                  );

                                }
                                else  if (snapshot.data.data['qty'] == 0){
                                  Firestore.instance.runTransaction(
                                          (Transaction transaction) async { // improve using batch,
                                        DocumentReference reference =
                                        Firestore.instance.collection("bokaalTables").document('6').collection("cart").document(beerdocument.data['id']);
                                        //fix 6 to dynamic number
                                        await reference.delete();
                                      });
                                  return Container();
                                }
                                else{
                                  return Column(
                                    children: <Widget>[
                                      Text("€" + beerdocument.data['price'].toString(), style: Theme.of(context).textTheme.title),
                                      Text("Nog " + beerdocument.data['amount'].toString() + " in voorraad", style: Theme.of(context).textTheme.title),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: <Widget>[
                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: RaisedButton(
                                                onPressed: (beerdocument.data['amount'] == 0) ? null :() {
                                                  Firestore.instance.runTransaction(
                                                          (Transaction transaction) async { // improve using batch,
                                                        DocumentReference reference =
                                                        Firestore.instance.collection("bokaalTables").document('6').collection("cart").document(beerdocument.data['id']);
                                                        //fix 6 to dynamic number
                                                        await reference.updateData({
                                                          "qty": snapshot.data.data['qty'] + 1,
                                                        }, );
                                                      }
                                                  );
                                                  Firestore.instance.runTransaction(
                                                          (Transaction transaction) async {
                                                        DocumentReference reference =
                                                        Firestore.instance.collection("bokaalStock").document(beerdocument.data['id']);
                                                        await reference.updateData({
                                                          "amount": beerdocument.data['amount'] - 1,
                                                        });
                                                      }
                                                  );

                                                },
                                                child: const Text('+')),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: RaisedButton(
                                                onPressed: () {
                                                  Firestore.instance.runTransaction(
                                                          (Transaction transaction) async { // improve using batch,
                                                        DocumentReference reference =
                                                        Firestore.instance.collection("bokaalTables").document('6').collection("cart").document(beerdocument.data['id']);
                                                        //fix 6 to dynamic number
                                                        await reference.updateData({
                                                          "qty": snapshot.data.data['qty'] - 1,
                                                        }, );
                                                      }
                                                  );
                                                  Firestore.instance.runTransaction(
                                                          (Transaction transaction) async {
                                                        DocumentReference reference =
                                                        Firestore.instance.collection("bokaalStock").document(beerdocument.data['id']);
                                                        await reference.updateData({
                                                          "amount": beerdocument.data['amount'] + 1,
                                                        });
                                                      }
                                                  );
                                                },
                                                child: const Text('-')),
                                          ),
                                        ],
                                      ),
                                      Text(snapshot.data.data['qty'].toString() + " in winkelwagen", style: Theme.of(context).textTheme.title)
                                    ],
                                  );
                                }

                              }

                            },
                          ),

                        ],
                      ),
                    )
                  ],
                ),
                Expanded(
                  child: Column(
                    children: <Widget>[
                      Text("Beschrijving",
                          style: Theme.of(context).textTheme.title),
                      Text(beerdocument.data['desc']),
                      Text("Smaak omschrijving",
                          style: Theme.of(context).textTheme.title),
                      Text(beerdocument.data['tasteDesc']),
                      Text("Foto's", style: Theme.of(context).textTheme.title),
                      StreamBuilder(
                        stream: Firestore.instance
                            .collection('bokaalStock')
                            .document(beerdocument.data['id'])
                            .collection('beerPhotos')
                            .snapshots(), // change to dynamic db?
                        builder: (BuildContext context,
                            AsyncSnapshot<QuerySnapshot> snapshot) {
                          if (!snapshot.hasData)
                            return CircularProgressIndicator();

                          return Container(
                            height: 200,
                            child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                 itemCount: snapshot.data.documents.length,
                                itemBuilder: (BuildContext context, int index) {
                                  return Padding(
                                    padding: const EdgeInsets.all(8.0),
                                  child: CachedNetworkImage( imageUrl:snapshot.data.documents[index].data['photo_md'] , placeholder: (context, url) => new CircularProgressIndicator(),
                                    errorWidget: (context, url, error) => new Icon(Icons.error),)
//                                    Image.network(
//                                      snapshot.data.documents[index].data['photo_md'],
//                                      height: 200,
//                                    ),
                                  );
                                }),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
