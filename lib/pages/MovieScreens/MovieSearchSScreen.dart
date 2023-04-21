import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:menifi/components/CustomDrawer/CustomDrawer.dart';
import 'package:menifi/components/Homescreen/PopularMoviesSlider.dart';
import 'package:menifi/components/Movies/UpComingMoviesSlider.dart';
import 'package:menifi/pages/MovieScreens/MovieDetailScreen.dart';
import 'package:shimmer/shimmer.dart';

import '../../components/constants.dart';
import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;

class MovieSearchScreen extends StatefulWidget {
  const MovieSearchScreen({super.key, this.movieName});
  final movieName;
  @override
  State<MovieSearchScreen> createState() => _MovieSearchScreenState();
}

class _MovieSearchScreenState extends State<MovieSearchScreen> {
  FirebaseAuth _auth = FirebaseAuth.instance;
  final GlobalKey<ScaffoldState> _ScaffoldKey = new GlobalKey<ScaffoldState>();
  TextEditingController search_controller = new TextEditingController();

  // Movie search page we are using the menifi api for getting the movies related
  // name of the movie that was passed on the screen from previous screen;
  late Map data;
  List SearchResult = [];
  bool isLoading = true;
  bool showIntroText = true;
  Future getSearchedMovie(String movieName) async {
    setState(() {
      showIntroText = false;
    });
    http.Response response = await http.get(
        Uri.parse('https://menifi-api.vercel.app/api/search/${movieName}'));

    setState(() {
      SearchResult = json.decode(response.body);
      SearchResult = SearchResult.where((element) =>
          element['type'] == 'movie' &&
          element['href'].toString().contains('/movie/')).toList();
      isLoading = false;
    });
    // print(SearchResult);
  }

  @override
  void initState() {
    if (widget.movieName != null) {
      search_controller.text = widget.movieName;
      getSearchedMovie(widget.movieName);
    }
    super.initState();
  }

  @override
  void dispose() {
    search_controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        extendBodyBehindAppBar: true,
        key: _ScaffoldKey,
        extendBody: true,
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          centerTitle: true,
          elevation: 0,
          backgroundColor: Colors.transparent,
          title: const Text(
            "Movie Search",
            style: TextStyle(fontFamily: 'Gilroy-Bold', fontSize: 20),
          ),
          actions: [
            Container(
              margin: const EdgeInsets.only(right: 5),
              child: CircleAvatar(
                backgroundImage: NetworkImage(
                  '${_auth.currentUser?.photoURL}',
                ),
                radius: 20,
              ),
            )
          ],
        ),
        body: Stack(
          children: [
            Container(
              decoration: const BoxDecoration(
                  image: DecorationImage(
                      image: AssetImage('assets/images/gradient-bg-7.png'),
                      fit: BoxFit.cover)),
            ),
            RefreshIndicator(
              onRefresh: () {
                return Future.delayed(Duration(seconds: 2), () {
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (BuildContext context) => super.widget));
                });
              },
              child: Column(
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 70, left: 10, right: 10),
                    padding: const EdgeInsets.only(top: 2, bottom: 2),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade800),
                      borderRadius: BorderRadius.circular(15),
                      color: const Color.fromARGB(255, 27, 27, 27),
                    ),
                    child: TextFormField(
                        onFieldSubmitted: (movieName) {
                          setState(() {
                            SearchResult = [];
                            isLoading = true;
                          });
                          getSearchedMovie(movieName);
                        },
                        controller: search_controller,
                        cursorColor: const Color.fromARGB(255, 190, 185, 185),
                        readOnly: false,
                        textAlignVertical: TextAlignVertical.center,
                        style: const TextStyle(fontFamily: 'Gilroy-Medium'),
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: "Search Movie",
                          suffixIcon: IconButton(
                            onPressed: () {
                              setState(() {
                                search_controller.clear();
                                SearchResult = [];
                                isLoading = true;
                                showIntroText = true;
                              });
                            },
                            icon: Icon(Icons.clear),
                            color: search_controller.text.isEmpty
                                ? Colors.transparent
                                : Colors.red,
                          ),
                          prefixIcon: Image.asset(
                            'assets/images/search-icon-32.png',
                            width: 32,
                            height: 32,
                          ),
                        )),
                  ),
                  showIntroText
                      ? Container(
                          margin: EdgeInsets.only(top: 60),
                          width: MediaQuery.of(context).size.width * 0.7,
                          child: Column(
                            children: [
                              const Text(
                                "What are you \nlooking for?",
                                style: TextStyle(
                                    fontFamily: 'Gilroy-Bold',
                                    fontSize: 35,
                                    color: Color.fromARGB(255, 209, 208, 208)),
                                textAlign: TextAlign.center,
                              ),
                              Container(
                                margin: EdgeInsets.only(top: 10),
                                child: const Text(
                                  "Discover new movies and explore our collection and find your next favourite.",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontFamily: 'Gilroy-Medium',
                                      color: Colors.grey,
                                      fontSize: 15),
                                ),
                              ),
                            ],
                          ),
                        )
                      : Expanded(
                          child: isLoading
                              ? const Center(
                                  child: CircularProgressIndicator.adaptive(),
                                )
                              : SearchResult.isNotEmpty
                                  ? GridView.builder(
                                      padding: const EdgeInsets.only(
                                          left: 20, right: 20, top: 20),
                                      gridDelegate:
                                          const SliverGridDelegateWithFixedCrossAxisCount(
                                              mainAxisSpacing: 20,
                                              crossAxisSpacing: 20,
                                              mainAxisExtent: 300,
                                              crossAxisCount: 2),
                                      shrinkWrap: true,
                                      itemCount: SearchResult.length,
                                      itemBuilder: (context, index) =>
                                          GestureDetector(
                                            onTap: () {
                                              String newmovieId =
                                                  "${SearchResult[index]['href']}"
                                                      .replaceAll(
                                                          "/movie/", "");
                                              Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (BuildContext
                                                              context) =>
                                                          MovieDetailScreen(
                                                              movieName:
                                                                  "${SearchResult[index]['title']}",
                                                              imageUrl:
                                                                  SearchResult[
                                                                          index]
                                                                      [
                                                                      'imgUrl'],
                                                              movieId:
                                                                  newmovieId)));
                                            },
                                            child: Container(
                                              decoration: const BoxDecoration(
                                                  color: Color.fromARGB(
                                                      185, 39, 39, 39),
                                                  borderRadius:
                                                      BorderRadius.only(
                                                          bottomLeft:
                                                              Radius.circular(
                                                                  5),
                                                          bottomRight:
                                                              Radius.circular(
                                                                  5))),
                                              child: Column(
                                                children: [
                                                  ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            5),
                                                    child: Image.network(
                                                      "${SearchResult[index]['imgUrl']}",
                                                      fit: BoxFit.cover,
                                                      width: 160,
                                                      height: 235,
                                                      errorBuilder: (context,
                                                          error, stackTrace) {
                                                        return Image.network(
                                                            width: 160,
                                                            height: 235,
                                                            fit: BoxFit.cover,
                                                            'https://www.redhouseoriginals.com/wp-content/uploads/dark-placeholder.png');
                                                      },
                                                      loadingBuilder: (context,
                                                          child,
                                                          loadingProgress) {
                                                        if (loadingProgress ==
                                                            null)
                                                          return child;
                                                        else {
                                                          return Container(
                                                            width: 160,
                                                            height: 235,
                                                            child: Shimmer
                                                                .fromColors(
                                                                    period: const Duration(
                                                                        milliseconds:
                                                                            1000),
                                                                    baseColor:
                                                                        const Color.fromARGB(
                                                                            85,
                                                                            0,
                                                                            0,
                                                                            0),
                                                                    highlightColor:
                                                                        const Color.fromARGB(
                                                                            255,
                                                                            124,
                                                                            122,
                                                                            122),
                                                                    child:
                                                                        Container(
                                                                      width:
                                                                          120,
                                                                      decoration:
                                                                          BoxDecoration(
                                                                        borderRadius:
                                                                            BorderRadius.circular(5),
                                                                        color: Colors
                                                                            .grey
                                                                            .shade300,
                                                                      ),
                                                                    )),
                                                          );
                                                        }
                                                      },
                                                    ),
                                                  ),
                                                  Container(
                                                      margin: EdgeInsets.only(
                                                          top: 10),
                                                      child: Text(
                                                        "${SearchResult[index]['title']}",
                                                        maxLines: 2,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        textAlign:
                                                            TextAlign.center,
                                                        style: const TextStyle(
                                                            fontFamily:
                                                                'Gilroy-Medium',
                                                            fontSize: 15),
                                                      ))
                                                ],
                                              ),
                                            ),
                                          ))
                                  : const Center(
                                      child: Text(
                                        "No Results",
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            fontFamily: 'Gilroy-Bold',
                                            fontSize: 25),
                                      ),
                                    ),
                        ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

List<String> RecommendationsText = [
  "Search for your favorite movies and TV shows - type in a title to find what you're looking for.",
  "Looking for something specific? Use the search bar to find any movie or TV show.",
  "Find your next binge-watch - search for movies and TV shows to add to your watchlist.",
  "Discover new titles - search for movies and TV shows by genre or actor.",
  "Quickly find what you're looking for - use our search bar to locate any movie or TV show.",
  "Search our extensive collection - find any movie or TV show with just a few keystrokes.",
  "Search for movies and TV shows across multiple streaming services - find where to watch your favorite titles.",
  "Get recommendations based on your search - discover related titles you might enjoy.",
  "Find movies and TV shows from around the world - search for titles from different countries and languages.",
  "Looking for something specific? Search for any movie or TV show and start watching now.",
  "Discover new movies and explore our collection and find your next favourite",
];
