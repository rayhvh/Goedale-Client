import 'package:scoped_model/scoped_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';

class GlobalModel extends Model {
  String _tableNumber = '0';
  num _totalAmount = 0;
  num _cartItemAmount = 0;
  String _currentOrderId = '';

  String get tableNumber => _tableNumber;
  num get totalAmount => _totalAmount;
  num get cartItemAmount => _cartItemAmount;
  String get currentOrderId => _currentOrderId;

  void changeTableNumber(String tableNumber) {
    print(this._tableNumber + " was het oude nummer");
    this._tableNumber = tableNumber;
    createIdTableFireStore();
    saveTableNumber(tableNumber);
    updatePrices();
    updateCartItemAmount();
    print(this._tableNumber + " is het nieuwe nummer");
    notifyListeners();
  }

  createIdTableFireStore() async {
    await Firestore.instance
        .collection('bokaalTables')
        .document(this._tableNumber)
        .setData({
      'id': this._tableNumber,
    });
  }

  saveTableNumber(String number) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (number == "") {
      await prefs.setString('tableNumber', "0");
    } else {
      await prefs.setString('tableNumber', number);
    }
  }

  loadTableNumber() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String loadedNumber = prefs.getString('tableNumber');
    if (loadedNumber == null) {
      this._tableNumber = '0';
    } else {
      this._tableNumber = '0';
      this._tableNumber = loadedNumber;
    }
    notifyListeners();
    return loadedNumber;
  }

  updateCartItemAmount() async {
    var list = await Firestore.instance
        .collection('bokaalTables')
        .document(this._tableNumber)
        .collection('cart')
        .getDocuments();
    if (list.documents.length > 0) {
      this._cartItemAmount = list.documents.length;
    } else {
      this._cartItemAmount = 0;
    }
    print(_cartItemAmount);
    notifyListeners();
  }

  moveCartToOrder() async {
    var list = await Firestore.instance
        .collection('bokaalTables')
        .document(this._tableNumber)
        .collection('cart')
        .getDocuments();
    var stats = await Firestore.instance
        .collection('bokaalSettings')
        .document('Stats').get();
    var date = new DateTime.now().millisecondsSinceEpoch;
    var newDoc = await Firestore.instance
        .collection('bokaalTables')
        .document(this._tableNumber)
        .collection('orders')
        .add({
      "orderNr" : stats.data['totalOrders'] + 1,
      "isPaid": false,
      "madeAt": date,
      "totalAmount": this._totalAmount, // no reason re-calculate. staying var.
    });
    await Firestore.instance.collection('bokaalSettings').document('Stats').updateData({
      'totalOrders' : stats.data['totalOrders'] + 1
    });
    for (int i = 0; i < list.documents.length; i++) {
      Firestore.instance.runTransaction((Transaction transaction) async {
        DocumentReference reference = Firestore.instance
            .collection("bokaalTables")
            .document(this._tableNumber)
            .collection("orders")
            .document(newDoc.documentID)
            .collection('items')
            .document(list.documents[i]['beerId']);
        await reference.setData(
          {
            "beerId": list.documents[i]['beerId'],
            "qty": list.documents[i]['qty'],
          },

        );
      });
    }
    _currentOrderId = newDoc.documentID;
    notifyListeners();
  }

  orderGotPaid() async {
    await Firestore.instance
        .collection('bokaalTables')
        .document(this._tableNumber)
        .collection('cart')
        .getDocuments()
        .then((snapshot) {
      for (DocumentSnapshot cartItem in snapshot.documents) {
        cartItem.reference.delete();
      }
      this._currentOrderId = '';
      print('en nu notify');
    }).then((_) {
      Future.delayed(Duration(milliseconds: 750), () => updatePrices())
          .then((_) {
        updateCartItemAmount(); //todo fix the ugliesst ever dirty code.. somehow the notify in updatepr/cart crashes the app, firebase async error?
      });
    });
  }

  orderGotCancelled() async {
    await Firestore.instance
        .collection('bokaalTables')
        .document(this._tableNumber)
        .collection('orders')
        .document(this._currentOrderId)
        .delete()
        .then((_) {
      this._currentOrderId = "";
    });
  }

  Future<List<DocumentSnapshot>> getBeersId(String tableNumberResult) async {
    var data = await Firestore.instance
        .collection('bokaalTables')
        .document(tableNumberResult)
        .collection('cart')
        .getDocuments();
    var beerId = data.documents;
    return beerId;
  }

  Future updatePrices() async {
    num tempTotal = 0;
    getBeersId(this._tableNumber).then((data) async {
      for (int i = 0; i < data.length; i++) {
        var beer = await Firestore.instance
            .collection('bokaalStock')
            .document(data[i]['beerId'])
            .get();
        tempTotal += beer.data['price'] * data[i]['qty'];
      }
    }).then((_) {
      this._totalAmount = tempTotal;
      notifyListeners();
      // print(this._totalAmount.toString() + " is de total amount in cart");
    });
  }
}
