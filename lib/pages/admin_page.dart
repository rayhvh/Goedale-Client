import 'package:flutter/material.dart';
import 'package:goedale_client/scoped_model/global_model.dart';
import 'package:scoped_model/scoped_model.dart';

class AdminPage extends StatefulWidget {
  @override
  _AdminPageState createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  @override
  void initState() {
    super.initState();
   // getTable();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(),
      body: Container(
        child: ScopedModelDescendant<GlobalModel>(
          builder: (context,child,beerTableModel){
            TextEditingController _numberTextField = TextEditingController(text: beerTableModel.tableNumber);
            return Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(30,8,30,0),
                child: Row(
                  children: <Widget>[

                    Expanded(
                      child: TextFormField(
                        controller: _numberTextField,
                        decoration: InputDecoration(hintText: "Het nummer van de tafel van deze tablet.", labelText: "Tafel nummer", icon:Icon(Icons.info_outline)),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    RaisedButton(
                      child: Icon(Icons.check),
                      onPressed: (){
                        beerTableModel.changeTableNumber(_numberTextField.text);
                        final snackBar = SnackBar(content: Text("Tafel nummer bijgewerkt naar " + _numberTextField.text),backgroundColor: Colors.red,);
                        _scaffoldKey.currentState.showSnackBar(snackBar);
                      },
                    ),

                  ],
                ),
              ),
            );
          },
        )
      ),
    );
  }
}
