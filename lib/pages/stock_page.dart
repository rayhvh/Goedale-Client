import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:goedale_client/widgets/firestore_stock_listview.dart';
import 'package:goedale_client/main.dart';


class StockPage extends StatefulWidget {
  @override
  _StockPage createState() => _StockPage();
}

class _StockPage extends State<StockPage>{

  List _orderOptions = ['Naam A-Z', 'Naam Z-A', 'Voorraad', 'Rating', 'Prijs oplopend', "Prijs aflopend" , 'Alc % oplopend','Alc % aflopend', 'Brouwer', 'Style' ];
  List<DropdownMenuItem<String>> _dropDownMenuItems;
  String selectedOption;

  String orderBy = "name";
  bool descending = false;

  @override
  void initState() {
    _dropDownMenuItems = getDropDownMenuItems();
    selectedOption = _dropDownMenuItems[0].value;
    super.initState();
  }

  List<DropdownMenuItem<String>> getDropDownMenuItems() {
    List<DropdownMenuItem<String>> items =  List();
    for (String option in _orderOptions) {
      items.add( DropdownMenuItem(
          value: option,
          child:  Text(option)
      ));
    }
    return items;
  }

  updateSortByMethod (){
    
    switch (selectedOption) {
      case "Naam A-Z": {
        this.setState(() {
          orderBy = 'name';
          descending = false;
        });
      }
      break;
      case "Naam Z-A": {
        this.setState(() {
          orderBy = 'name';
          descending = true;
        });
      }
      break;
      case "Voorraad": {
        this.setState(() {
          orderBy = 'amount';
          descending = false;
        });
      }
      break;
      case "Rating": {
        this.setState(() {
          orderBy = 'rating';
          descending = true;
        });
      }
      break;
      case "Prijs oplopend": {
        this.setState(() {
          orderBy = 'price';
          descending = false;
        });
      }
      break;
      case "Prijs aflopend": {
        this.setState(() {
          orderBy = 'price';
          descending = true;
        });
      }
      break;
      case "Alc % oplopend": {
        this.setState(() {
          orderBy = 'abv';
          descending = false;
        });
      }
      break;
      case "Alc % aflopend": {
        this.setState(() {
          orderBy = 'abv';
          descending = true;
        });
      }
      break;
      case "Brouwer": {
        this.setState(() {
          orderBy = 'brewery';
          descending = false;
        });
      }
      break;
      case "Style": {
        this.setState(() {
          orderBy = 'style';
          descending = false;
        });
      }
      break;
      default: {
        this.setState(() {
          orderBy = 'name';
          descending = false;
        });
      }
      break;
    }
  }

  @override
  Widget build(BuildContext context){
    return Container(
    child:  Stack(
      children: <Widget>[

        Container(
          child: StreamBuilder(
            stream: Firestore.instance
                .collection('bokaalStock').orderBy(orderBy, descending:descending )
                .snapshots(), // change to dynamic db?
            builder: (BuildContext context,
                AsyncSnapshot<QuerySnapshot> snapshot) {
              if (!snapshot.hasData) return CircularProgressIndicator();
              return FirestoreStockListview(
                  beersInStock: snapshot.data.documents);
            },
          ),
        ),
        Align(
          alignment: Alignment.topRight,
          child: DropdownButton(
            value: selectedOption,
            items: _dropDownMenuItems,
            onChanged: (String newValue){
              this.setState(() {
                selectedOption = newValue;
              });
              updateSortByMethod();
            },
          ),
        ),
      ],
    ),);
  }
}
