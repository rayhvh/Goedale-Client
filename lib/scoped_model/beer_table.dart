import 'package:scoped_model/scoped_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BeerTable extends Model {
  String _tableNumber = '0';
  String get tableNumber => _tableNumber;

  void changeTableNumber(String tableNumber) {
    print(this._tableNumber + " was het oude nummer");
    this._tableNumber = tableNumber;
    saveTableNumber(tableNumber);
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

}
