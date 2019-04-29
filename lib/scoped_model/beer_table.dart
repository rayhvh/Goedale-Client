import 'package:scoped_model/scoped_model.dart';

class BeerTable extends Model {
  String _tableNumber = '0';
  String get tableNumber => _tableNumber;

  void changeTableNumber(String tableNumber) {
    this._tableNumber = tableNumber;
    notifyListeners();
  }
}
