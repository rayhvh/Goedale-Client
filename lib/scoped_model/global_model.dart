import 'package:scoped_model/scoped_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class GlobalModel extends Model {

  String _tableNumber = '0';
  num _totalAmount = 0;
  String get tableNumber => _tableNumber;
  num get totalAmount => _totalAmount;

  void changeTableNumber(String tableNumber) {
    print(this._tableNumber + " was het oude nummer");
    this._tableNumber = tableNumber;
    saveTableNumber(tableNumber);
    updatePrices();
    print(this._tableNumber + " is het nieuwe nummer");
    notifyListeners();
  }
  
  saveTableNumber(String number) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if(number == "")
      {await prefs.setString('tableNumber', "0");}
    else
      {await prefs.setString('tableNumber', number);}
  }

  loadTableNumber() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String loadedNumber = prefs.getString('tableNumber');
    this._tableNumber = loadedNumber;
    notifyListeners();
    return loadedNumber;
  }


  Future<List<DocumentSnapshot>> getBeersId(String tableNumberResult) async{
    var data = await Firestore.instance.collection('bokaalTables').document(tableNumberResult).collection('cart').getDocuments();
    var beerId = data.documents;
    return beerId;
  }

  Future updatePrices() async{
    num tempTotal =0;
    getBeersId(this._tableNumber).then((data) async {
      for (int i=0; i < data.length; i++ ){
        var beer = await Firestore.instance.collection('bokaalStock').document(data[i]['beerId']).get();
        // print(data[i]['qty'].toString() + " getPrices, qty");
        tempTotal += beer.data['price'] * data[i]['qty'];
      }
    }).then((_) {
      this._totalAmount = tempTotal;
      notifyListeners();
      print(this._totalAmount.toString() + " is de total amount in cart");
    });
  }


}
