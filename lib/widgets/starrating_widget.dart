import 'package:flutter/material.dart';



class StarRating extends StatelessWidget {
  final int starCount;
  final double rating;
  final Color color;
  final Color borderColor;
  final double size;
  final bool allowHalfRating;

  StarRating(
      {this.starCount = 5,
        this.rating = 0.0,
        this.color,
        this.borderColor,
        this.size,
        this.allowHalfRating = true}) {
    assert(this.rating != null);
  }

  Widget buildStar(BuildContext context, int index) {
    Icon icon;
    if (index >= rating) {
      icon = new Icon(
        Icons.star_border,
        color: borderColor ?? Theme.of(context).primaryColor,
        size: size ?? 25.0,
      );
    } else if (index > rating - (allowHalfRating ? 0.51 : 1.0) &&
        index < rating) {
      icon = new Icon(
        Icons.star_half,
        color: color ?? Theme.of(context).primaryColor,
        size: size ?? 25.0,
      );
    } else {
      icon = new Icon(
        Icons.star,
        color: color ?? Theme.of(context).primaryColor,
        size: size ?? 25.0,
      );
    }

    return icon;
  }

  @override
  Widget build(BuildContext context) {
    return new Material(
      color: Colors.transparent,
      child: new Wrap(
          alignment: WrapAlignment.start,
          children: new List.generate(
              starCount, (index) => buildStar(context, index))),
    );
  }
}
