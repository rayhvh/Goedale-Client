import 'package:flutter/material.dart';
import 'package:goedale_client/functions/globals.dart';
import 'package:goedale_client/main.dart';

class AdminPage extends StatefulWidget {
  @override
  _AdminPageState createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  String tableNumber = "";
  Future getTable() async {
    getTableNumber().then((result) {
      setState(() {
        tableNumber = result.toString();
        _numberTextField.text = result.toString();
      });
    });
  }

  @override
  void initState() {
    super.initState();
    getTable();
  }

  TextEditingController _numberTextField = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Container(
        child: Row(
          children: <Widget>[
            Text("Tafel nummer: "),
            Expanded(
              child: TextFormField(
                controller: _numberTextField,
                decoration: InputDecoration(hintText: "Nummer van de tafel"),
                keyboardType: TextInputType.number,
              ),
            ),
            RaisedButton(
              child: Icon(Icons.check),
              onPressed: (){
                setTableNumber(int.parse(_numberTextField.text));
                Navigator.of(context).pop(_numberTextField.text); //TODO fix returning data better. reload data in home without having to first return something..
              },
            ),

          ],
        ),
      ),
    );
  }
}
