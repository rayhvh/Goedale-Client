import 'package:goedale_client/main.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:goedale_client/models/beer_models.dart';
import 'package:goedale_client/models/beerlisting_model.dart';
import 'package:goedale_client/widgets/starrating_widget.dart';
import 'package:goedale_client/widgets/quickadd_button.dart';
import 'package:goedale_client/functions/utils.dart';
import 'package:goedale_client/pages/beerdetail_page.dart';

class FirestoreStockListview extends StatelessWidget {
  final List<DocumentSnapshot> documents;

  FirestoreStockListview({this.documents});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: documents.length,
      itemBuilder: (BuildContext context, int index) {
        var _listing = BeerListing(
          beer: Beer(
            id: documents[index].data['id'].toString(),
            name: documents[index].data['name'].toString(),
            brewery: documents[index].data['brewery'].toString(),
            label: BeerLabel(
                iconUrl: documents[index].data['label']['iconUrl'].toString()),
            style: BeerStyle(
                id: null, name: documents[index].data['style'].toString()),
            abv: documents[index].data['abv'],
            rating: documents[index].data['rating'],
          ),
          price: documents[index].data['price'],
          stockAmount: documents[index].data['amount'],
        );

        if (_listing.stockAmount == 0) {
        //  return Text('uitverkocht');
          return Container();
        } else {
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
                                NetworkImage(_listing.beer.label.iconUrl,),
                          ),
                          title: Text(_listing.beer.name,
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(_listing.beer.brewery),
                              Text(_listing.beer.abv.toString() + "%"),
                              Text(_listing.beer.style.name),
                              //   Text( _listing.beer.rating.toString()),
                            ],
                          ),
                          ),
                    ),
                    Expanded(
                      child: Column(
                        children: <Widget>[
                          StarRating(
                            rating: toRound(_listing.beer.rating),
                            color: Colors.white,
                            borderColor: Colors.white,
                          ),
                          Text(_listing.beer.rating.toString()),
                        ],
                      ),
                    ),
                    Expanded(
                        child: quickaddButton(
                            _listing.stockAmount, _listing.price))
                  ],
                ),
                Divider(
                  height: 15.0,
                  color: Colors.white,
                ),
              ],
            ),
            onTap:() {
              Navigator.push(context, new MaterialPageRoute(builder: (context) => BeerDetailPage(_listing.beer)));
            },
          );
        }
      },
    );
  }
}
