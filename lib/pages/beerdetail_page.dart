import 'package:flutter/material.dart';
import 'package:goedale_client/models/beer_models.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:goedale_client/widgets/firestore_beerdetail_widget.dart';

class BeerDetailPage extends StatefulWidget {
  final Beer beer;
  BeerDetailPage(this.beer);

  @override
  _BeerDetailPageState createState() => _BeerDetailPageState(beer);
}

class _BeerDetailPageState extends State<BeerDetailPage> {
  final Beer beer;
  _BeerDetailPageState(this.beer);

  @override
  void initState() {
    super.initState();

  }

  @override
  Widget build(BuildContext context){
    return Container(
      child:  Container(
        child: StreamBuilder(
          stream: Firestore.instance
              .collection('bokaalStock').document(beer.id)
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
