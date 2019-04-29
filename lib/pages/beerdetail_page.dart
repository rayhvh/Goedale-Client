import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:goedale_client/widgets/firestore_beerdetail_widget.dart';

class BeerDetailPage extends StatefulWidget {
//  final Beer beer;
//  BeerDetailPage(this.beer);
final String beerId;
BeerDetailPage(this.beerId);
  @override
  _BeerDetailPageState createState() => _BeerDetailPageState(beerId);
}

class _BeerDetailPageState extends State<BeerDetailPage> {
//  final Beer beer;
//  _BeerDetailPageState(this.beer);
final String beerId;
_BeerDetailPageState(this.beerId);

  @override
  Widget build(BuildContext context){
    return Container(
      child:  Container(
        child: StreamBuilder(
          stream: Firestore.instance
              .collection('bokaalStock').document(beerId)
              .snapshots(), // change to dynamic db?
          builder: (BuildContext context,
              AsyncSnapshot<DocumentSnapshot> snapshot) {
            if (!snapshot.hasData) return CircularProgressIndicator();

            return FirestoreBeerdetail(
                beerdocument: snapshot.data );
          },
        ),
      ),);
  }
}
