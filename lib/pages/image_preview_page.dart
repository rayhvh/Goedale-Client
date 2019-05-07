import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ImagePreviewPage extends StatefulWidget {
  final String imageUrl;
  ImagePreviewPage(this.imageUrl);
  @override
  _ImagePreviewPageState createState() => _ImagePreviewPageState(imageUrl);
}

class _ImagePreviewPageState extends State<ImagePreviewPage> {
final String imageUrl;
_ImagePreviewPageState(this.imageUrl);

  @override
  void initState() {
    super.initState();
    // getTable();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Container(child: Align(
          alignment: Alignment.topCenter,
          child: CachedNetworkImage(imageUrl: imageUrl,)))
    );
  }
}
