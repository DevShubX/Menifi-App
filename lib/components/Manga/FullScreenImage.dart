import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:menifi/components/Firebase/FirebaseMethods.dart';

class FullScreenImage extends StatelessWidget {
  const FullScreenImage({super.key, this.imageUrl});
  final imageUrl;

  saveImage(String url) async {
    await GallerySaver.saveImage(url, toDcim: true)
        .then((value) => popupToast("Image Saved To Gallery"));
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      backgroundColor: const Color.fromARGB(255, 0, 0, 0),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color.fromARGB(255, 0, 0, 0),
        actions: [
          IconButton(
              onPressed: () {
                saveImage(imageUrl);
              },
              icon: const Icon(Icons.download)),
          const SizedBox(
            width: 10,
          )
        ],
      ),
      body: Center(child: Image.network(imageUrl)),
    ));
  }
}
