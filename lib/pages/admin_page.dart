import 'package:flutter/material.dart';
import 'package:goedale_client/scoped_model/global_model.dart';
import 'package:scoped_model/scoped_model.dart';

class AdminPage extends StatefulWidget {
  @override
  _AdminPageState createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {

  @override
  void initState() {
    super.initState();
   // getTable();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Container(
        child: ScopedModelDescendant<GlobalModel>(
          builder: (context,child,beerTableModel){
            TextEditingController _numberTextField = TextEditingController(text: beerTableModel.tableNumber);
            return Row(
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
                    beerTableModel.changeTableNumber(_numberTextField.text);
                  },
                ),

              ],
            );
          },
        )
      ),
    );
  }
}
