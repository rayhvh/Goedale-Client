import 'beer_models.dart';
import 'package:meta/meta.dart';
class BeerListing {
  final Beer beer;
  final num price;
  final num stockAmount;
  BeerListing(
      {@required this.beer, @required this.price, @required this.stockAmount});
}
