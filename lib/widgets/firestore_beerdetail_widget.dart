import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:goedale_client/pages/image_preview_page.dart';

import 'package:goedale_client/widgets/starrating_widget.dart';

import 'package:scoped_model/scoped_model.dart';
import 'package:goedale_client/scoped_model/global_model.dart';
import 'package:qr_flutter/qr_flutter.dart';

class FirestoreBeerdetail extends StatefulWidget {
  final DocumentSnapshot beerdocument;

  FirestoreBeerdetail({this.beerdocument});

  @override
  _FirestoreBeerdetailState createState() => _FirestoreBeerdetailState();
}

class _FirestoreBeerdetailState extends State<FirestoreBeerdetail> {
//  String tableNumber;
//  @override
//  void initState(){
//    super.initState();
//    getTableNumber().then((result){
//      setState(() {
//        tableNumber = result.toString();
//      });
//    });
//  }


  @override
  Widget build(BuildContext context) {
    print(widget.beerdocument.data); // map this data to a model or not..
   // TextEditingController amountController = new TextEditingController();
    if (widget.beerdocument.data == null) {
      Navigator.pop(context);
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.beerdocument.data['name']),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(0,5,0,0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Container(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: <Widget>[
                          CachedNetworkImage(
                            imageUrl: widget.beerdocument.data["label"]["largeUrl"],
                            height: 200,
                          ),
                          Text(widget.beerdocument.data['name'],
                              style: Theme.of(context).textTheme.title),
                          Text(widget.beerdocument.data['brewery']),
                          Text(widget.beerdocument.data['style']),
                          Text(widget.beerdocument.data['abv'].toString() + "%"),
                          StarRating(rating: widget.beerdocument.data['rating'],
                          color: Colors.white,
                          borderColor: Colors.white,),
                          Text(widget.beerdocument.data['rating'].toString()),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    child: Column(
                      children: <Widget>[
                        ScopedModelDescendant<GlobalModel>(
                          builder: (context, child, globalModel){
                            return StreamBuilder(
                              stream: Firestore.instance
                                  .collection('bokaalTables').document(globalModel.tableNumber).collection("cart").document(widget.beerdocument.data['id'])
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
                                        Text("€" + widget.beerdocument.data['price'].toString(), style: Theme.of(context).textTheme.title),
                                        Text("Nog " + widget.beerdocument.data['amount'].toString() + " in voorraad", style: Theme.of(context).textTheme.title),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: <Widget>[
                                            Padding(
                                              padding: const EdgeInsets.all(8.0),
                                              child: RaisedButton(
                                                color: Colors.white,
                                                child: Icon(Icons.remove, color:Colors.black,),
                                                onPressed: null,
                                              ),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.all(8.0),
                                              child: RaisedButton(
                                                  color: Colors.white,
                                                  onPressed: () {
                                                    Firestore.instance.runTransaction(
                                                            (Transaction transaction) async { // improve using batch,
                                                          DocumentReference reference =
                                                          Firestore.instance.collection("bokaalTables").document(globalModel.tableNumber).collection("cart").document(widget.beerdocument.data['id']);
                                                          await reference.setData({
                                                            "beerId": widget.beerdocument.data['id'],
                                                            "qty": 1,
                                                          }, merge: true).then((_) {
                                                            Firestore.instance.runTransaction(
                                                                    (Transaction transaction) async {
                                                                  DocumentReference reference =
                                                                  Firestore.instance.collection("bokaalStock").document(widget.beerdocument.data['id']);
                                                                  await reference.updateData({
                                                                    "amount": widget.beerdocument.data['amount'] - 1,
                                                                  }).then((_) {
                                                                    globalModel.updateCartItemAmount();
                                                                  });
                                                                }
                                                            );
                                                          });
                                                        }
                                                    );

                                                  },
                                                  child: const  Icon(Icons.add, color: Colors.black,)),
                                            ),
                                          ],
                                        ),
                                        Text("0 in winkelwagen", style: Theme.of(context).textTheme.title)
                                      ],
                                    );
                                  }
                                  else  if (snapshot.data.data['qty'] == 0){
                                    Firestore.instance.runTransaction(
                                            (Transaction transaction) async { // improve using batch,
                                          DocumentReference reference =
                                          Firestore.instance.collection("bokaalTables").document(globalModel.tableNumber).collection("cart").document(widget.beerdocument.data['id']);
                                          await reference.delete().then((_){
                                            globalModel.updateCartItemAmount();
                                          });
                                        });
                                    return Container();
                                  }
                                  else{
                                    return Column(
                                      children: <Widget>[
                                        Text("€" + widget.beerdocument.data['price'].toString(), style: Theme.of(context).textTheme.title),
                                        Text("Nog " + widget.beerdocument.data['amount'].toString() + " in voorraad", style: Theme.of(context).textTheme.title),
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
                                                          Firestore.instance.collection("bokaalTables").document(globalModel.tableNumber).collection("cart").document(widget.beerdocument.data['id']);
                                                          await reference.updateData({
                                                            "qty": snapshot.data.data['qty'] - 1,
                                                          }, ).then((_) {
                                                            Firestore.instance.runTransaction(
                                                                    (Transaction transaction) async {
                                                                  DocumentReference reference =
                                                                  Firestore.instance.collection("bokaalStock").document(widget.beerdocument.data['id']);
                                                                  await reference.updateData({
                                                                    "amount": widget.beerdocument.data['amount'] + 1,
                                                                  }).then((_) {
                                                                    globalModel.updateCartItemAmount();
                                                                  });
                                                                }
                                                            );
                                                          });
                                                        }
                                                    );

                                                  },
                                                  child:  Icon(Icons.remove, color: Colors.black,)),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.all(8.0),
                                              child: RaisedButton(
                                                  color: Colors.white,
                                                  onPressed: (widget.beerdocument.data['amount'] == 0) ? null :() {
                                                    Firestore.instance.runTransaction(
                                                            (Transaction transaction) async { // improve using batch,
                                                          DocumentReference reference =
                                                          Firestore.instance.collection("bokaalTables").document(globalModel.tableNumber).collection("cart").document(widget.beerdocument.data['id']);
                                                          await reference.updateData({
                                                            "qty": snapshot.data.data['qty'] + 1,
                                                          }, ).then((_) {
                                                            Firestore.instance.runTransaction(
                                                                    (Transaction transaction) async {
                                                                  DocumentReference reference =
                                                                  Firestore.instance.collection("bokaalStock").document(widget.beerdocument.data['id']);
                                                                  await reference.updateData({
                                                                    "amount": widget.beerdocument.data['amount'] - 1,
                                                                  }).then((_) {
                                                                    globalModel.updateCartItemAmount();
                                                                  });
                                                                }
                                                            );
                                                          });
                                                        }
                                                    );


                                                  },
                                                  child: const Icon(Icons.add, color: Colors.black,)),
                                            ),
                                          ],
                                        ),
                                        Text(snapshot.data.data['qty'].toString() + " in winkelwagen", style: Theme.of(context).textTheme.title)
                                      ],
                                    );
                                  }
                                }
                              },
                            );
                          },

                        ), //
                      ],
                    ),
                  )
                ],
              ),
            ),
            Container(
              child: Column(
                children: <Widget>[
                  Text("Beschrijving",
                      style: Theme.of(context).textTheme.title),
                  Text(widget.beerdocument.data['desc']),
                  Divider(height: 10,),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      Column(
                        children: <Widget>[
                          Text("Smaak omschrijving",
                              style: Theme.of(context).textTheme.title),
                          Text(widget.beerdocument.data['tasteDesc']),
                        ],
                      ),
                      Column(
                        children: <Widget>[
                          Text("Untappd page",
                              style: Theme.of(context).textTheme.title),
                          Container(
                            color: Colors.white,
                            child: QrImage(
                                data: "https://untappd.com/qr/beer/" +widget.beerdocument.data['id'],
                                size: 200
                            ),
                          ),
                        ],
                      ),

                    ],
                  ),
                  Divider(height: 10,),
                  Text("Foto's", style: Theme.of(context).textTheme.title),
                  StreamBuilder(
                    stream: Firestore.instance
                        .collection('bokaalStock')
                        .document(widget.beerdocument.data['id'])
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
                              child: GestureDetector(
                                onTap: (){
                                  Navigator.push(context, MaterialPageRoute(builder: (context) => ImagePreviewPage(snapshot.data.documents[index].data['photo_og'])));
                                },
                                child: CachedNetworkImage( imageUrl:snapshot.data.documents[index].data['photo_md'] , placeholder: (context, url) => new CircularProgressIndicator(),
                                  errorWidget: (context, url, error) => new Icon(Icons.error),),
                              )
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
      ),
    );
  }
}
