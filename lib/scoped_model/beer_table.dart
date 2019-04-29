import 'package:scoped_model/scoped_model.dart';

class BeerTable extends Model {
  String _tableNumber = '0';
  String get tableNumber => _tableNumber;

  void changeTableNumber(String tableNumber) {
    print(this._tableNumber + " was het oude nummer");
    this._tableNumber = tableNumber;
    print(this._tableNumber + " is het nieuwe nummer");
    notifyListeners();
  }
}
