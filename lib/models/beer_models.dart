import 'package:meta/meta.dart';

class Beer {
  final String id;
  final String name;
  final String description;
  final String tasteDescription;
  final BeerLabel label;
  final double abv;
  final BeerStyle style;
  final double rating;
  final String brewery;
  final List<BeerPhoto> beerPhotos;

  Beer({
    @required this.id,
    @required this.name,
    this.description,
    this.tasteDescription,
    this.label,
    this.abv,
    this.style,
    this.rating,
    this.brewery,
    this.beerPhotos,
  });



  factory Beer.fromJson(Map<String, dynamic> json){

    List<dynamic> mapList = json["response"]["beer"]["media"]["items"];
    var photoList = mapList.map((beerPhotoJson) => BeerPhoto.fromJson(beerPhotoJson)).toList();

    return Beer(
      id: json['response']['beer']['bid'].toString(),
      name: json['response']['beer']['beer_name'],
      description: json['response']['beer']['beer_description'],
      label: BeerLabel(
          largeUrl: json['response']['beer']['beer_label_hd']
      ) ,
      abv: double.parse(json['response']['beer']['beer_abv'].toString()),
      style: BeerStyle(id: json['response']['beer']['beer_id'], name: json['response']['beer']['beer_style']),
      rating: json['response']['beer']['rating_score'],
      beerPhotos: photoList,
      brewery: json['response']['beer']['brewery']['brewery_name'],
    );
  }

}

class BeerPhoto{
  final String photo_md;
  BeerPhoto({this.photo_md});
  factory BeerPhoto.fromJson(Map<String, dynamic> json){
    return BeerPhoto(
        photo_md: json['photo']['photo_img_md']
    );
  }
}

class BeerStyle {
  final String id;
  final String name;

  BeerStyle({
    @required this.id,
    @required this.name,
  });


}

class BeerLabel {
  final String iconUrl;
  final String mediumUrl;
  final String largeUrl;

  BeerLabel({
    this.iconUrl,
    this.mediumUrl,
    this.largeUrl,
  });
}