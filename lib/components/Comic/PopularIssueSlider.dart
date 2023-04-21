import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:http/http.dart' as http;
import 'package:menifi/pages/ComicScreens/ComicSearchScreen.dart';
import 'dart:convert';
import 'dart:async';

import '../Skeletons/ImagesSliderSkeleton.dart';

class PopularIssueSlider extends StatefulWidget {
  const PopularIssueSlider({super.key});

  @override
  State<PopularIssueSlider> createState() => _PopularIssueSliderState();
}

class _PopularIssueSliderState extends State<PopularIssueSlider> {
  List data = [];
  bool isLoading = true;

  Future getComic() async {
    http.Response response = await http
        .get(Uri.parse('https://comics-api-wine.vercel.app/api/issues/'));

    setState(() {
      data = json.decode(response.body);
      isLoading = false;
    });
  }

  @override
  void initState() {
    getComic();
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
            margin: const EdgeInsets.only(top: 30, left: 15, right: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text(
                  "Popular Issues",
                  style: TextStyle(fontFamily: 'Gilroy-Bold', fontSize: 19),
                ),
                // GestureDetector(
                //   onTap: () {},
                //   child: const Text(
                //     "See All",
                //     style: TextStyle(
                //         fontFamily: 'Gilroy-Medium',
                //         color: Color.fromARGB(255, 255, 17, 0),
                //         fontSize: 15),
                //   ),
                // )
              ],
            ),
          ),
          //// Photos Slider Container with each image of 120x185
          isLoading
              ? const ImagesSliderSkeleton()
              : Container(
                  height: 230,
                  margin: const EdgeInsets.only(top: 15, left: 5),
                  child: ListView.builder(
                      shrinkWrap: true,
                      scrollDirection: Axis.horizontal,
                      itemCount: data.length,
                      itemBuilder: (BuildContext context, index) {
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => ComicSearchScreen(
                                          comicName: data[index]['title'],
                                        )));
                          },
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 10),
                            width: 120,
                            height: 230,
                            child: Column(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(5),
                                  child: Image.network(
                                    fit: BoxFit.cover,
                                    '${data[index]['imgUrl']}',
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
                                          width: 120,
                                          height: 185,
                                          color:
                                              const Color.fromARGB(85, 0, 0, 0),
                                          child: const Center(
                                            child: CircularProgressIndicator
                                                .adaptive(),
                                          ),
                                        );
                                      }
                                    },
                                  ),
                                ),
                                Container(
                                  margin: const EdgeInsets.only(top: 10),
                                  child: Text(
                                    "${data[index]['title'] ?? "NA"}",
                                    maxLines: 2,
                                    textAlign: TextAlign.center,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                        fontFamily: 'Gilroy-Medium'),
                                  ),
                                )
                              ],
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
