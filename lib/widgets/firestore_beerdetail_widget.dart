import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:goedale_client/models/beer_models.dart';

class FirestoreBeerdetail extends StatelessWidget {
  final DocumentSnapshot beerdocument;

  FirestoreBeerdetail({this.beerdocument});
  
  @override
  Widget build(BuildContext context) {
    print(beerdocument.data); // map this data to a model or not..
    if(beerdocument.data == null){
      Navigator.pop(context);
    }
    return  Scaffold(
      appBar: AppBar(
        title: Text("biernaam"),
      ),
      body: Center(
        child: Text(beerdocument.data.toString()),
      ),


    );
  }
}