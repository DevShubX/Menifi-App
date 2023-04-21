import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:menifi/components/Firebase/FirebaseMethods.dart';
import 'package:menifi/pages/TVShowScreens/TVShowDetailsScreen.dart';
import 'package:shimmer/shimmer.dart';

class TVShowsSearchScreen extends StatefulWidget {
  const TVShowsSearchScreen({super.key, this.tvShowName});
  final tvShowName;
  @override
  State<TVShowsSearchScreen> createState() => _TVShowsSearchScreenState();
}

class _TVShowsSearchScreenState extends State<TVShowsSearchScreen> {
  FirebaseAuth _auth = FirebaseAuth.instance;
  final GlobalKey<ScaffoldState> _ScaffoldKey = new GlobalKey<ScaffoldState>();
  TextEditingController search_controller = new TextEditingController();

  late Map data;
  List searchResult = [];
  bool isLoading = true;
  bool showIntroText = true;

  Future getSearchedTvShow(String tvShowName) async {
    setState(() {
      showIntroText = false;
    });
    http.Response response = await http.get(
        Uri.parse('https://menifi-api.vercel.app/api/search/${tvShowName}'));

    setState(() {
      searchResult = json.decode(response.body);
      searchResult = searchResult
          .where((element) =>
              element['type'] == 'tv' &&
              element['href'].toString().contains('/tv/'))
          .toList();
      isLoading = false;
    });
    // print(SearchResult);
  }

  @override
  void initState() {
    if (widget.tvShowName != null) {
      search_controller.text = widget.tvShowName;
      getSearchedTvShow(widget.tvShowName);
    }
    super.initState();
  }

  @override
  void dispose() {
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
          "TV Show Search",
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
              return Future.delayed(const Duration(seconds: 2), () {
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
                          searchResult = [];
                          isLoading = true;
                        });
                        getSearchedTvShow(movieName);
                      },
                      controller: search_controller,
                      cursorColor: const Color.fromARGB(255, 190, 185, 185),
                      readOnly: false,
                      textAlignVertical: TextAlignVertical.center,
                      style: const TextStyle(fontFamily: 'Gilroy-Medium'),
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: "Search TV Show",
                        suffixIcon: IconButton(
                          onPressed: () {
                            setState(() {
                              search_controller.clear();
                              searchResult = [];
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
                                "Looking for something specific? Use the search bar to find any TV show.",
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
                            : searchResult.isNotEmpty
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
                                    itemCount: searchResult.length,
                                    itemBuilder:
                                        (context, index) =>
                                            searchResult[index]['href']
                                                    .toString()
                                                    .isNotEmpty
                                                ? GestureDetector(
                                                    onTap: () {
                                                      if (searchResult[index]
                                                              ['href'] !=
                                                          null) {
                                                        String newtvshowid =
                                                            "${searchResult[index]['href']}"
                                                                .replaceAll(
                                                                    "/tv/", "");
                                                        Navigator.push(
                                                            context,
                                                            MaterialPageRoute(
                                                                builder: (BuildContext context) => TVShowDetailsScreen(
                                                                    tvshowImage:
                                                                        searchResult[index]
                                                                            [
                                                                            'imgUrl'],
                                                                    tvshowName:
                                                                        searchResult[index]
                                                                            [
                                                                            'title'],
                                                                    tvshowId:
                                                                        newtvshowid)));
                                                      } else {
                                                        popupToast('Not Found');
                                                      }
                                                    },
                                                    child: Container(
                                                      decoration: const BoxDecoration(
                                                          color: Color.fromARGB(
                                                              185, 39, 39, 39),
                                                          borderRadius:
                                                              BorderRadius.only(
                                                                  bottomLeft: Radius
                                                                      .circular(
                                                                          5),
                                                                  bottomRight: Radius
                                                                      .circular(
                                                                          5))),
                                                      child: Column(
                                                        children: [
                                                          ClipRRect(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        5),
                                                            child:
                                                                Image.network(
                                                              "${searchResult[index]['imgUrl']}",
                                                              fit: BoxFit.cover,
                                                              width: 160,
                                                              height: 235,
                                                              errorBuilder:
                                                                  (context,
                                                                      error,
                                                                      stackTrace) {
                                                                return Image.network(
                                                                    width: 160,
                                                                    height: 235,
                                                                    fit: BoxFit
                                                                        .cover,
                                                                    'https://www.redhouseoriginals.com/wp-content/uploads/dark-placeholder.png');
                                                              },
                                                              loadingBuilder:
                                                                  (context,
                                                                      child,
                                                                      loadingProgress) {
                                                                if (loadingProgress ==
                                                                    null)
                                                                  return child;
                                                                else {
                                                                  return Container(
                                                                    width: 160,
                                                                    height: 235,
                                                                    child: Shimmer.fromColors(
                                                                        period: const Duration(milliseconds: 1000),
                                                                        baseColor: const Color.fromARGB(85, 0, 0, 0),
                                                                        highlightColor: const Color.fromARGB(255, 124, 122, 122),
                                                                        child: Container(
                                                                          width:
                                                                              120,
                                                                          decoration:
                                                                              BoxDecoration(
                                                                            borderRadius:
                                                                                BorderRadius.circular(5),
                                                                            color:
                                                                                Colors.grey.shade300,
                                                                          ),
                                                                        )),
                                                                  );
                                                                }
                                                              },
                                                            ),
                                                          ),
                                                          Container(
                                                              margin: EdgeInsets
                                                                  .only(
                                                                      top: 10),
                                                              child: Text(
                                                                "${searchResult[index]['title']}",
                                                                maxLines: 2,
                                                                overflow:
                                                                    TextOverflow
                                                                        .ellipsis,
                                                                textAlign:
                                                                    TextAlign
                                                                        .center,
                                                                style: const TextStyle(
                                                                    fontFamily:
                                                                        'Gilroy-Medium',
                                                                    fontSize:
                                                                        15),
                                                              ))
                                                        ],
                                                      ),
                                                    ),
                                                  )
                                                : Container())
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
    ));
  }
}
