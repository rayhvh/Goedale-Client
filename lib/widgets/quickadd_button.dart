import 'package:flutter/material.dart';

Widget quickaddButton(num amount, num price) {
  if (amount < 10 && amount > 0) {
    return Column(
      children: <Widget>[
        Text('Nog maar ' + amount.toString() + " over!" ),
        Text('€ ' + price.toString() ),
      ],
    );
  } else {
    return Column(
      children: <Widget>[
        Text("€ " + price.toString()),
      ],
    );
  }
}