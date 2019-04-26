import 'package:shared_preferences/shared_preferences.dart';

setTableNumber(int number) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  int tableNumber = (prefs.getInt('tableNumber') ?? 0);
  print('number $tableNumber  was the table number.');
  await prefs.setInt('tableNumber', number);
  print(prefs.getInt('tableNumber').toString() + " is the new table number");
}

getTableNumber() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getInt('tableNumber');
}

