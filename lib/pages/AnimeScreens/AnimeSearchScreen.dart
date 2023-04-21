import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:menifi/pages/AnimeScreens/AnimeDetailsScreen.dart';
import 'package:shimmer/shimmer.dart';

import '../../components/Firebase/FirebaseMethods.dart';

class AnimeSearchScreen extends StatefulWidget {
  const AnimeSearchScreen({super.key, this.animeName});
  final animeName;
  @override
  State<AnimeSearchScreen> createState() => _AnimeSearchScreenState();
}

class _AnimeSearchScreenState extends State<AnimeSearchScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GlobalKey<ScaffoldState> _ScaffoldKey = GlobalKey<ScaffoldState>();
  TextEditingController search_controller = TextEditingController();

  late Map data;
  List? Anime = [];
  bool isLoading = true;
  bool showIntroText = true;

  Future getAnime(String animename) async {
    setState(() {
      showIntroText = false;
    });

    http.Response response = await http.get(Uri.parse(
        'https://redux-api-wine.vercel.app/api/search?name=$animename'));

    if (!mounted) return;
    setState(() {
      Anime = json.decode(response.body);
      isLoading = false;
    });
  }

  @override
  void initState() {
    if (widget.animeName != null) {
      search_controller.text = widget.animeName;
      getAnime(widget.animeName);
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
      backgroundColor: const Color.fromARGB(255, 21, 0, 43),
      extendBody: true,
      extendBodyBehindAppBar: true,
      key: _ScaffoldKey,
      appBar: AppBar(
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: const Text(
          'Anime Search',
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
      body: RefreshIndicator(
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
                color: const Color.fromARGB(179, 27, 27, 27),
              ),
              child: TextFormField(
                  onFieldSubmitted: (animename) {
                    setState(() {
                      Anime = [];
                      isLoading = true;
                    });
                    getAnime(animename);
                  },
                  controller: search_controller,
                  cursorColor: const Color.fromARGB(255, 190, 185, 185),
                  readOnly: false,
                  textAlignVertical: TextAlignVertical.center,
                  style: const TextStyle(fontFamily: 'Gilroy-Medium'),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: "Search For Anime",
                    suffixIcon: IconButton(
                      onPressed: () {
                        setState(() {
                          search_controller.clear();
                          Anime = [];
                          isLoading = true;
                          showIntroText = true;
                        });
                      },
                      icon: const Icon(Icons.clear),
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
                    margin: const EdgeInsets.only(top: 60),
                    width: MediaQuery.of(context).size.width * 0.7,
                    child: Column(
                      children: [
                        const Text(
                          "Looking for a specific anime?",
                          style: TextStyle(
                              fontFamily: 'Gilroy-Bold',
                              fontSize: 35,
                              color: Color.fromARGB(255, 209, 208, 208)),
                          textAlign: TextAlign.center,
                        ),
                        Container(
                          margin: const EdgeInsets.only(top: 10),
                          child: const Text(
                            "Search for your favorite anime titles using our search bar.",
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
                        : Anime!.isNotEmpty
                            ? GridView.builder(
                                physics: const BouncingScrollPhysics(),
                                padding: const EdgeInsets.only(
                                    left: 20, right: 20, top: 20),
                                gridDelegate:
                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                        mainAxisSpacing: 20,
                                        crossAxisSpacing: 20,
                                        mainAxisExtent: 340,
                                        crossAxisCount: 2),
                                shrinkWrap: true,
                                itemCount: Anime!.length,
                                itemBuilder: (context, index) =>
                                    GestureDetector(
                                      onTap: () {
                                        if (Anime![index]['link'] != null) {
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      AnimeDetailsScreen(
                                                        animeLink: Anime![index]
                                                            ['link'],
                                                        animeImageUrl:
                                                            Anime![index]
                                                                ['image'],
                                                        animeName: Anime![index]
                                                            ['title'],
                                                      )));
                                        }
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.only(top: 5),
                                        decoration: const BoxDecoration(
                                            color:
                                                Color.fromARGB(185, 39, 39, 39),
                                            borderRadius: BorderRadius.only(
                                                bottomLeft: Radius.circular(5),
                                                bottomRight:
                                                    Radius.circular(5))),
                                        child: Column(
                                          children: [
                                            ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(5),
                                              child: Image.network(
                                                "${Anime![index]['image']}",
                                                fit: BoxFit.cover,
                                                width: 160,
                                                height: 235,
                                                errorBuilder: (context, error,
                                                    stackTrace) {
                                                  return Image.network(
                                                      width: 160,
                                                      height: 235,
                                                      fit: BoxFit.cover,
                                                      'https://www.redhouseoriginals.com/wp-content/uploads/dark-placeholder.png');
                                                },
                                                loadingBuilder: (context, child,
                                                    loadingProgress) {
                                                  if (loadingProgress == null)
                                                    return child;
                                                  else {
                                                    return SizedBox(
                                                      width: 160,
                                                      height: 235,
                                                      child: Shimmer.fromColors(
                                                          period:
                                                              const Duration(
                                                                  milliseconds:
                                                                      1000),
                                                          baseColor: const Color
                                                                  .fromARGB(
                                                              85, 0, 0, 0),
                                                          highlightColor:
                                                              const Color
                                                                      .fromARGB(
                                                                  255,
                                                                  124,
                                                                  122,
                                                                  122),
                                                          child: Container(
                                                            width: 120,
                                                            decoration:
                                                                BoxDecoration(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          5),
                                                              color: Colors.grey
                                                                  .shade300,
                                                            ),
                                                          )),
                                                    );
                                                  }
                                                },
                                              ),
                                            ),
                                            Container(
                                                margin: const EdgeInsets.only(
                                                    top: 10),
                                                child: Text(
                                                  "${Anime![index]['title']}",
                                                  maxLines: 3,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  textAlign: TextAlign.center,
                                                  style: const TextStyle(
                                                      fontFamily:
                                                          'Gilroy-Medium',
                                                      fontSize: 15),
                                                )),
                                            Container(
                                              margin: const EdgeInsets.only(
                                                  top: 10),
                                              child: Text(
                                                "Released: "
                                                "${Anime![index]['releasedDate'].toString().replaceAll("Released:", "")}",
                                                style: const TextStyle(
                                                    fontFamily: 'Gilroy-Medium',
                                                    fontSize: 14,
                                                    color: Color.fromARGB(
                                                        255, 182, 182, 182)),
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                    ))
                            : Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: const [
                                    Text(
                                      "No Results",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          fontFamily: 'Gilroy-Bold',
                                          fontSize: 25),
                                    ),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    Text(
                                      "Try Searching the anime with different name",
                                      style: TextStyle(
                                          fontFamily: 'Gilroy-Medium'),
                                    ),
                                  ],
                                ),
                              ),
                  ),
          ],
        ),
      ),
    ));
  }
}
