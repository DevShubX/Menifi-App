import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:menifi/components/Skeletons/ImagesSliderSkeleton.dart';
import 'package:menifi/pages/ComicScreens/ComicScreen.dart';
import 'package:menifi/pages/ComicScreens/ComicSearchScreen.dart';

class PopularComicSlider extends StatefulWidget {
  const PopularComicSlider({super.key});

  @override
  State<PopularComicSlider> createState() => _PopularComicSliderState();
}

class _PopularComicSliderState extends State<PopularComicSlider> {
  late Map data;
  List PopularComics = [];
  bool isLoading = true;
  int dataLenght = 10;
  Future getPopularComic() async {
    http.Response response = await http
        .get(Uri.parse('https://comics-api-wine.vercel.app/api/volumes/'));
    setState(() {
      PopularComics = json.decode(response.body);
      isLoading = false;
    });
  }

  @override
  void initState() {
    getPopularComic();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          /// Text Portion Container
          Container(
            margin: EdgeInsets.only(top: 30, left: 15, right: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Popular Volumes",
                  style: TextStyle(fontFamily: 'Gilroy-Bold', fontSize: 19),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const ComicScreen()));
                  },
                  child: const Text(
                    "See All",
                    style: TextStyle(
                        fontFamily: 'Gilroy-Medium',
                        color: Color.fromARGB(255, 255, 17, 0),
                        fontSize: 15),
                  ),
                )
              ],
            ),
          ),
          //// Photos Slider Container with each image of 120x185
          isLoading
              ? const ImagesSliderSkeleton()
              : Container(
                  height: 185,
                  margin: const EdgeInsets.only(top: 15, left: 5),
                  child: ListView.builder(
                      shrinkWrap: true,
                      scrollDirection: Axis.horizontal,
                      itemCount: PopularComics.isNotEmpty ? dataLenght : 0,
                      itemBuilder: (BuildContext context, index) {
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => ComicSearchScreen(
                                        comicName: PopularComics[index]
                                            ['title'])));
                          },
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 10),
                            width: 120,
                            height: 185,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(5),
                              child: Image.network(
                                fit: BoxFit.cover,
                                '${PopularComics[index]['imgUrl']}',
                                height: 185,
                                width: 120,
                                errorBuilder: (context, error, stackTrace) {
                                  return Image.network(
                                      width: 120,
                                      height: 185,
                                      fit: BoxFit.cover,
                                      'https://www.redhouseoriginals.com/wp-content/uploads/dark-placeholder.png');
                                },
                                loadingBuilder:
                                    (context, child, loadingProgress) {
                                  if (loadingProgress == null) {
                                    return child;
                                  } else {
                                    return Container(
                                      color: const Color.fromARGB(85, 0, 0, 0),
                                      child: const Center(
                                        child: CircularProgressIndicator
                                            .adaptive(),
                                      ),
                                    );
                                  }
                                },
                              ),
                            ),
                          ),
                        );
                      }),
                )
        ],
      ),
    );
  }
}
