import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:menifi/pages/ComicScreens/ComicDetailScreen.dart';

class ComicSearchScreen extends StatefulWidget {
  const ComicSearchScreen({super.key, this.comicName});
  final comicName;
  @override
  State<ComicSearchScreen> createState() => ComicSearchScreenState();
}

class ComicSearchScreenState extends State<ComicSearchScreen> {
  List data = [];
  bool isLoading = true;
  bool showIntroText = true;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GlobalKey<ScaffoldState> _ScaffoldKey = GlobalKey<ScaffoldState>();
  TextEditingController search_controller = TextEditingController();

  Future getComic(String comicName) async {
    setState(() {
      showIntroText = false;
    });
    http.Response response = await http.get(Uri.parse(
        'https://comics-api-wine.vercel.app/api/search?name=$comicName'));

    if (!mounted) return;
    setState(() {
      data = json.decode(response.body);
      isLoading = false;
    });
  }

  @override
  void initState() {
    if (widget.comicName != null) {
      search_controller.text = widget.comicName;
      getComic(widget.comicName);
    } else {
      setState(() {
        isLoading = false;
      });
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
          'Comic Search',
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
                      data = [];
                      isLoading = true;
                    });
                    getComic(animename);
                  },
                  controller: search_controller,
                  cursorColor: const Color.fromARGB(255, 190, 185, 185),
                  readOnly: false,
                  textAlignVertical: TextAlignVertical.center,
                  style: const TextStyle(fontFamily: 'Gilroy-Medium'),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: "Search For Comic",
                    suffixIcon: IconButton(
                      onPressed: () {
                        setState(() {
                          search_controller.clear();
                          data = [];
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
                          "What are you waiting for?",
                          style: TextStyle(
                              fontFamily: 'Gilroy-Bold',
                              fontSize: 35,
                              color: Color.fromARGB(255, 209, 208, 208)),
                          textAlign: TextAlign.center,
                        ),
                        Container(
                          margin: const EdgeInsets.only(top: 10),
                          child: const Text(
                            "Search for your favorite comic titles using our search bar.",
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
                        : data.isNotEmpty
                            ? ListView.builder(
                                physics: const BouncingScrollPhysics(),
                                padding: const EdgeInsets.only(
                                    left: 20, right: 20, top: 20),
                                shrinkWrap: true,
                                itemCount: data.length,
                                itemBuilder: (context, index) =>
                                    GestureDetector(
                                      onTap: () {
                                        if (data[index]['id'] != null) {
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      ComicDetailScreen(
                                                        comicId: data[index]
                                                            ['id'],
                                                        comicName: data[index]
                                                            ['title'],
                                                      )));
                                        }
                                      },
                                      child: Container(
                                          decoration: const BoxDecoration(
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(10)),
                                              color: Color.fromARGB(
                                                  255, 43, 42, 42)),
                                          margin:
                                              const EdgeInsets.only(top: 30),
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 10, horizontal: 10),
                                          child: Text(
                                            "${data[index]['title']}",
                                            maxLines: 3,
                                            overflow: TextOverflow.ellipsis,
                                            textAlign: TextAlign.center,
                                            style: const TextStyle(
                                                fontFamily: 'Gilroy-Medium',
                                                fontSize: 15),
                                          )),
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
                                      "Try Searching the comic with different name",
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
