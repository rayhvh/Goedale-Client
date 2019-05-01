import 'package:scoped_model/scoped_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class GlobalModel extends Model {

  String _tableNumber = '0';
  num _totalAmount = 0;
  num _cartItemAmount =0;
  String _currentOrderId = '';

  String get tableNumber => _tableNumber;
  num get totalAmount => _totalAmount;
  num get cartItemAmount => _cartItemAmount;
  String get currentOrderId => _currentOrderId;


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


  updateCartItemAmount() async{
    var list =await Firestore.instance.collection('bokaalTables').document(this._tableNumber).collection('cart').getDocuments();
    this._cartItemAmount = list.documents.length;
    print(_cartItemAmount);
    notifyListeners();
}


  moveCartToOrder() async{
    var list =await Firestore.instance.collection('bokaalTables').document(this._tableNumber).collection('cart').getDocuments();
    var date = new DateTime.now();
    var newDoc = await  Firestore.instance.collection('bokaalTables').document(this._tableNumber).collection('orders').add({
      "isPaid": false,
      "madeAt": date,
      "totalAmount": this._totalAmount, // no reason re-calculate. staying var.
    });
    for (int i=0; i< list.documents.length; i++) {
      Firestore.instance.runTransaction(
              (Transaction transaction) async {
            DocumentReference reference =
            Firestore.instance.collection("bokaalTables").document(this._tableNumber).collection("orders").document(newDoc.documentID).collection('items').document(list.documents[i]['beerId']);
            await reference.setData({
              "beerId": list.documents[i]['beerId'],
              "qty": list.documents[i]['qty'],
            },);});
    }
    _currentOrderId = newDoc.documentID;
    notifyListeners();
    //todo delete items from cart after moving, add later because testing.

  }

  orderGotPaid() async{
    await Firestore.instance.collection('bokaalTables').document(this._tableNumber).collection('cart').getDocuments().then((snapshot){
      for (DocumentSnapshot cartItem in snapshot.documents){
        cartItem.reference.delete();
      }
      this._currentOrderId ='';
      notifyListeners();
    });
  }

  orderGotCancelled() async{
   await Firestore.instance.collection('bokaalTables').document(this._tableNumber).collection('orders').document(this._currentOrderId).delete().then((_){
     this._currentOrderId = "";
   });
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
        tempTotal += beer.data['price'] * data[i]['qty'];
      }
    }).then((_) {
      this._totalAmount = tempTotal;
      notifyListeners();
     // print(this._totalAmount.toString() + " is de total amount in cart");
    });
  }


}
