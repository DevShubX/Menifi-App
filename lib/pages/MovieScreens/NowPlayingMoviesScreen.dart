import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:flutter/widgets.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:menifi/pages/MovieScreens/MovieSearchSScreen.dart';

import '../../components/constants.dart';

class NowPlayingMoviesScreen extends StatefulWidget {
  const NowPlayingMoviesScreen({super.key});

  @override
  State<NowPlayingMoviesScreen> createState() => _NowPlayingMoviesScreenState();
}

class _NowPlayingMoviesScreenState extends State<NowPlayingMoviesScreen> {
  final ScrollController controller = ScrollController();
  int pageNumber = 1;
  late Map data;
  List? NowPlayingMovies = [];
  bool isLoading = true;

  Future getMovies() async {
    http.Response response = await http.get(Uri.parse(
        'https://api.themoviedb.org/3/movie/now_playing?api_key=$key&language=en-US&page=$pageNumber'));

    data = json.decode(response.body);

    setState(() {
      pageNumber++;
      NowPlayingMovies!.addAll(data['results']);
      isLoading = false;
    });
  }

  @override
  void initState() {
    getMovies();
    super.initState();

    controller.addListener(() async {
      if (controller.position.maxScrollExtent == controller.offset) {
        getMovies();
      }
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      extendBody: true,
      extendBodyBehindAppBar: false,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Color.fromARGB(223, 20, 1, 44),
        title: const Text(
          "Now Playing Movies",
          style: TextStyle(fontFamily: 'Gilroy-Bold', fontSize: 22),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          Container(
              decoration: const BoxDecoration(
            color: Color.fromARGB(223, 20, 1, 44),
          )),
          ListView.builder(
              padding: EdgeInsets.only(top: 20, left: 20, right: 20),
              controller: controller,
              itemCount: NowPlayingMovies!.length + 1,
              itemBuilder: (context, index) {
                if (index < NowPlayingMovies!.length) {
                  final item = NowPlayingMovies![index];
                  final date = item['release_date'] != null
                      ? DateFormat.yMMMd()
                          .format(DateTime.parse(item['release_date']))
                          .toString()
                      : "NA";
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => MovieSearchScreen(
                                    movieName:
                                        item['title'] ?? item['original_title'],
                                  )));
                    },
                    child: Container(
                      height: 165,
                      margin: EdgeInsets.only(bottom: 20),
                      child: Row(
                        children: [
                          Container(
                            width: 110,
                            height: 165,
                            margin: EdgeInsets.only(right: 20),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: Color.fromARGB(52, 0, 0, 0),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Color.fromARGB(94, 0, 0, 0),
                                    spreadRadius: 5,
                                    blurRadius: 5,
                                    offset: Offset(
                                        0, 3), // changes position of shadow
                                  ),
                                ]),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.network(
                                "https://image.tmdb.org/t/p/w185/${item['poster_path']}",
                                width: 110,
                                height: 165,
                                errorBuilder: (context, error, stackTrace) {
                                  return Image.network(
                                      width: 110,
                                      height: 165,
                                      fit: BoxFit.cover,
                                      'https://www.redhouseoriginals.com/wp-content/uploads/dark-placeholder.png');
                                },
                                loadingBuilder:
                                    (context, child, loadingProgress) {
                                  if (loadingProgress == null) {
                                    return child;
                                  } else {
                                    return const Center(
                                      child:
                                          CircularProgressIndicator.adaptive(),
                                    );
                                  }
                                },
                              ),
                            ),
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  flex: 0,
                                  child: Text(
                                    '${item['title'] ?? item['original_title']}',
                                    maxLines: 3,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                        fontFamily: 'Gilroy-Bold',
                                        fontSize: 17),
                                  ),
                                ),
                                const SizedBox(
                                  height: 15,
                                ),
                                Text(
                                  "${date}",
                                  style: const TextStyle(
                                      fontFamily: 'Gilroy-Medium',
                                      color: Colors.grey),
                                ),
                                const SizedBox(
                                  height: 15,
                                ),
                                Text(
                                  '${item['original_language'] ?? ""}'
                                      .toUpperCase(),
                                  style: const TextStyle(
                                      fontFamily: 'Gilroy-Medium',
                                      color: Colors.grey),
                                ),
                                const SizedBox(
                                  height: 15,
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 2, horizontal: 5),
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(5),
                                      color: Color.fromARGB(255, 255, 17, 0)),
                                  child: Text(
                                    " ${double.parse(item['vote_average'].toStringAsFixed(1))}",
                                    style: const TextStyle(
                                        fontFamily: 'Gilroy-Bold',
                                        fontSize: 11,
                                        color: Colors.white),
                                  ),
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                } else {
                  return const Center(
                    child: CircularProgressIndicator.adaptive(),
                  );
                }
              })
        ],
      ),
    ));
  }
}
