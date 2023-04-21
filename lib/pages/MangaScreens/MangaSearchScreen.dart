import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:menifi/pages/MangaScreens/MangaDetailsScreen.dart';
import 'package:shimmer/shimmer.dart';
import 'package:intl/intl.dart';

class MangaSearchScreen extends StatefulWidget {
  const MangaSearchScreen({super.key, this.mangaName});
  final mangaName;
  @override
  State<MangaSearchScreen> createState() => _MangaSearchScreenState();
}

class _MangaSearchScreenState extends State<MangaSearchScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GlobalKey<ScaffoldState> _ScaffoldKey = GlobalKey<ScaffoldState>();
  TextEditingController search_controller = TextEditingController();

  late Map data;
  List? Manga = [];
  bool isLoading = true;
  bool showIntroText = true;

  Future getMangas(String manganame) async {
    setState(() {
      showIntroText = false;
    });

    http.Response response = await http.get(Uri.parse(
        'https://redux-api-wine.vercel.app/api/manga/comick/search?name=$manganame'));

    if (!mounted) return;
    setState(() {
      Manga = json.decode(response.body)['compResults'];
      isLoading = false;
    });
  }

  @override
  void initState() {
    if (widget.mangaName != null) {
      search_controller.text = widget.mangaName;
      getMangas(widget.mangaName);
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
          'Manga Search',
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
                  onFieldSubmitted: (manganame) {
                    setState(() {
                      Manga = [];
                      isLoading = true;
                    });
                    getMangas(manganame);
                  },
                  controller: search_controller,
                  cursorColor: const Color.fromARGB(255, 190, 185, 185),
                  readOnly: false,
                  textAlignVertical: TextAlignVertical.center,
                  style: const TextStyle(fontFamily: 'Gilroy-Medium'),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: "Search For Manga",
                    suffixIcon: IconButton(
                      onPressed: () {
                        setState(() {
                          search_controller.clear();
                          Manga = [];
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
                          "Looking for something good?",
                          style: TextStyle(
                              fontFamily: 'Gilroy-Bold',
                              fontSize: 35,
                              color: Color.fromARGB(255, 209, 208, 208)),
                          textAlign: TextAlign.center,
                        ),
                        Container(
                          margin: const EdgeInsets.only(top: 10),
                          child: const Text(
                            "Find your next manga adventure! Search our vast library of manga titles, including popular series and hidden gems.",
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
                        : Manga!.isNotEmpty
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
                                itemCount: Manga!.length,
                                itemBuilder: (context, index) {
                                  final date = DateFormat.yMMMd().format(
                                      DateTime.parse(
                                          Manga![index]['created_at']));
                                  return GestureDetector(
                                    onTap: () {
                                      if (Manga![index]['hid'] != null) {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    MangaDetailsScreen(
                                                      mangaId: Manga![index]
                                                          ['hid'],
                                                      mangaImgUrl: Manga![index]
                                                          ['image'],
                                                      mangaName: Manga![index]
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
                                              bottomRight: Radius.circular(5))),
                                      child: Column(
                                        children: [
                                          Stack(
                                            children: [
                                              ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(5),
                                                child: Image.network(
                                                  "${Manga![index]['image']}",
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
                                                  loadingBuilder: (context,
                                                      child, loadingProgress) {
                                                    if (loadingProgress == null)
                                                      return child;
                                                    else {
                                                      return SizedBox(
                                                        width: 160,
                                                        height: 235,
                                                        child:
                                                            Shimmer.fromColors(
                                                                period: const Duration(
                                                                    milliseconds:
                                                                        1000),
                                                                baseColor:
                                                                    const Color
                                                                            .fromARGB(
                                                                        85,
                                                                        0,
                                                                        0,
                                                                        0),
                                                                highlightColor:
                                                                    const Color
                                                                            .fromARGB(
                                                                        255,
                                                                        124,
                                                                        122,
                                                                        122),
                                                                child:
                                                                    Container(
                                                                  width: 120,
                                                                  decoration:
                                                                      BoxDecoration(
                                                                    borderRadius:
                                                                        BorderRadius
                                                                            .circular(5),
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
                                              Positioned(
                                                  top: 10,
                                                  left: 10,
                                                  child: Container(
                                                    padding: const EdgeInsets
                                                            .symmetric(
                                                        vertical: 2,
                                                        horizontal: 5),
                                                    decoration: BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(5),
                                                        color: const Color
                                                                .fromARGB(
                                                            255, 255, 17, 0)),
                                                    child: Text(
                                                      "${Manga![index]['rating'] ?? "NA"}",
                                                      style: const TextStyle(
                                                          fontFamily:
                                                              'Gilroy-Bold',
                                                          fontSize: 12,
                                                          color: Colors.white),
                                                    ),
                                                  )),
                                            ],
                                          ),
                                          Container(
                                              margin: const EdgeInsets.only(
                                                  top: 10),
                                              child: Text(
                                                "${Manga![index]['title']}",
                                                maxLines: 3,
                                                overflow: TextOverflow.ellipsis,
                                                textAlign: TextAlign.center,
                                                style: const TextStyle(
                                                    fontFamily: 'Gilroy-Medium',
                                                    fontSize: 15),
                                              )),
                                          Container(
                                            margin:
                                                const EdgeInsets.only(top: 10),
                                            child: Text(
                                              "Released: "
                                              "${date}",
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
                                  );
                                })
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
                                      "Try Searching the manga with different name",
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
