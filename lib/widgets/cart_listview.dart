import 'package:goedale_client/main.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:goedale_client/widgets/starrating_widget.dart';
import 'package:goedale_client/functions/utils.dart';
import 'package:cached_network_image/cached_network_image.dart';

class CartListView extends StatelessWidget {
  final List<DocumentSnapshot> cartItems;

  CartListView({this.cartItems});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        itemCount: cartItems.length,
        itemBuilder: (BuildContext context, int index) {
         return StreamBuilder(
              stream: Firestore.instance
                  .collection('bokaalStock')
                  .document(cartItems[index].data['beerId'])
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
                                  Text(snapshot.data['abv'].toString() +
                                      "%"),
                                  Text(snapshot.data['style']),
                                  //   Text( _listing.beer.rating.toString()),
                                ],
                              ),
                            ),
                          ),
                          Expanded(
                            child: Column(
                              children: <Widget>[
                                StarRating(
                                  rating:
                                      toRound(snapshot.data['rating']),
                                  color: Colors.white,
                                  borderColor: Colors.white,
                                ),
                                Text(
                                    snapshot.data['rating'].toString()),
                              ],
                            ),
                          ),
                          Expanded(child: Column(
                            children: <Widget>[
                              Text(cartItems[index].data['qty'].toString() + " in winkelmandje"),
                              Text(snapshot.data['amount'].toString() + " over in voorraad"),
                            ],
                          ),),

                        ],
                      ),
                      Divider(
                        height: 15.0,
                        color: Colors.white,
                      ),
                    ],
                  ),
                  onTap: () {
                    // Navigator.push(context, new MaterialPageRoute(builder: (context) => BeerDetailPage(_listing.beer)));
                  },
                );
              });
        });
  }
}
