import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:menifi/pages/TVShowScreens/TVShowsSearchScreen.dart';
import '../../components/constants.dart';

class PopularTvShowsScreen extends StatefulWidget {
  const PopularTvShowsScreen({super.key});

  @override
  State<PopularTvShowsScreen> createState() => _PopularTvShowsScreenState();
}

class _PopularTvShowsScreenState extends State<PopularTvShowsScreen> {
  final ScrollController controller = ScrollController();
  int pageNumber = 1;
  List? PopularTv = [];
  late Map data;
  bool isLoading = true;

  Future getTVShows() async {
    http.Response response = await http.get(Uri.parse(
        'https://api.themoviedb.org/3/tv/popular?api_key=$key&language=en-US&page=$pageNumber'));

    data = json.decode(response.body);

    setState(() {
      pageNumber++;
      PopularTv!.addAll(data['results']);
      isLoading = false;
    });
  }

  @override
  void initState() {
    getTVShows();
    super.initState();

    controller.addListener(() async {
      if (controller.position.maxScrollExtent == controller.offset) {
        getTVShows();
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
          "Popular TV Shows",
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
              itemCount: PopularTv!.length + 1,
              itemBuilder: (context, index) {
                if (index < PopularTv!.length) {
                  final item = PopularTv![index];
                  final date = (item['first_air_date'] != "" &&
                          item['first_air_date'] != null)
                      ? DateFormat.yMMMd()
                          .format(DateTime.parse(item['first_air_date']))
                          .toString()
                      : "NA";
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => TVShowsSearchScreen(
                                    tvShowName:
                                        item['name'] ?? item['original_name'],
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
                                      'https://www.slntechnologies.com/wp-content/uploads/2017/08/ef3-placeholder-image.jpg');
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
                                    '${item['name'] ?? item['original_name']}',
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
