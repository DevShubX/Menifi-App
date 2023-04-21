import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:image_picker/image_picker.dart';
import 'package:menifi/components/CustomDrawer/CustomDrawer.dart';
import 'package:menifi/components/Manga/FullScreenImage.dart';

import '../../components/Firebase/FirebaseMethods.dart';
import '../../components/constants.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GlobalKey<ScaffoldState> _ScaffoldKey = GlobalKey<ScaffoldState>();
  final DatabaseReference _database = FirebaseDatabase.instance.ref();
  FirebaseStorage _storage = FirebaseStorage.instance;

  @override
  void initState() {
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
      key: _ScaffoldKey,
      extendBodyBehindAppBar: true,
      extendBody: true,
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'Account',
          style: TextStyle(fontFamily: 'Gilroy-Bold', fontSize: 22),
        ),
        elevation: 0,
        backgroundColor: appbar_color,
        leadingWidth: 40,
        leading: Container(
          margin: const EdgeInsets.only(left: 5),
          child: GestureDetector(
            onTap: () {
              _ScaffoldKey.currentState!.openDrawer();
            },
            child: Image.asset(
              "assets/images/M-Logo.png",
              width: 10,
              height: 10,
            ),
          ),
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
      drawer: CustomDrawer(),
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
                image: DecorationImage(
                    image: AssetImage('assets/images/gradient-bg-5.jpg'),
                    fit: BoxFit.cover)),
          ),
          SingleChildScrollView(
            child: Column(
              children: [
                Container(
                    margin: const EdgeInsets.only(top: 70),
                    alignment: Alignment.center,
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => ProfileImageCustomize(
                                    imageUrl:
                                        "${_auth.currentUser!.photoURL}")));
                      },
                      child: CircleAvatar(
                          radius: 50,
                          foregroundImage: NetworkImage(
                            "${_auth.currentUser!.photoURL}",
                          )),
                    )),
                Container(
                  width: MediaQuery.of(context).size.width,
                  margin:
                      const EdgeInsets.symmetric(vertical: 40, horizontal: 40),
                  padding:
                      const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                  decoration: BoxDecoration(
                      color: const Color.fromARGB(176, 41, 41, 41),
                      borderRadius: BorderRadius.circular(15)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Name",
                        style: TextStyle(
                            fontFamily: 'Gilroy-Bold',
                            color: Colors.grey,
                            fontSize: 18),
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      Text(
                        "${_auth.currentUser!.displayName}",
                        style: const TextStyle(
                            fontFamily: 'Gilroy-Medium', fontSize: 18),
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      const Text(
                        "Email",
                        style: TextStyle(
                            fontFamily: 'Gilroy-Bold',
                            color: Colors.grey,
                            fontSize: 18),
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      Text(
                        "${_auth.currentUser!.email}",
                        style: const TextStyle(
                            fontSize: 18, fontFamily: 'Gilroy-Medium'),
                      ),
                    ],
                  ),
                ),
                StreamBuilder(
                    stream: _database
                        .child(
                            'users/${_auth.currentUser!.uid}/recentlyWatched/recently_watched_arr')
                        .get()
                        .asStream(),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        List rcn =
                            (snapshot.data!.value ?? []) as List<dynamic>;
                        rcn = rcn.reversed.toList();
                        int tvshows = 0;
                        int anime = 0;
                        int movies = 0;
                        rcn.forEach(
                          (element) {
                            if (element['type'] == "ANIME") {
                              anime++;
                            } else if (element['movieId']
                                .toString()
                                .contains('movie')) {
                              movies++;
                            } else if (element['movieId']
                                .toString()
                                .contains('tv')) {
                              tvshows++;
                            }
                          },
                        );
                        return Column(
                          children: [
                            Container(
                              width: MediaQuery.of(context).size.width,
                              margin: const EdgeInsets.only(
                                  left: 40, right: 40, bottom: 40),
                              padding: const EdgeInsets.symmetric(
                                  vertical: 20, horizontal: 20),
                              decoration: BoxDecoration(
                                  color: const Color.fromARGB(176, 41, 41, 41),
                                  borderRadius: BorderRadius.circular(15)),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    "Stats",
                                    style: TextStyle(
                                        fontFamily: 'Gilroy-Bold',
                                        color: Colors.grey,
                                        fontSize: 19),
                                  ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Image.asset(
                                        'assets/images/movie-icon.png',
                                        width: 20,
                                      ),
                                      const SizedBox(
                                        width: 5,
                                      ),
                                      Text(
                                        "Movies Watched: $movies",
                                        style: const TextStyle(
                                            fontFamily: 'Gilroy-Medium',
                                            color: Color.fromARGB(
                                                255, 235, 235, 235),
                                            fontSize: 15),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Image.asset(
                                        'assets/images/tvshows-icon.png',
                                        width: 20,
                                      ),
                                      const SizedBox(
                                        width: 5,
                                      ),
                                      Text(
                                        "TV Shows Watched: $tvshows",
                                        style: const TextStyle(
                                            fontFamily: 'Gilroy-Medium',
                                            color: Color.fromARGB(
                                                255, 235, 235, 235),
                                            fontSize: 15),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Image.asset(
                                        'assets/images/anime-icon.png',
                                        width: 20,
                                      ),
                                      const SizedBox(
                                        width: 5,
                                      ),
                                      Text(
                                        "Anime Watched: $anime",
                                        style: const TextStyle(
                                            fontSize: 15,
                                            color: Color.fromARGB(
                                                255, 235, 235, 235),
                                            fontFamily: 'Gilroy-Medium'),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            Container(
                                margin: const EdgeInsets.only(bottom: 20),
                                child: const Text(
                                  "Watch History",
                                  style: TextStyle(
                                      fontFamily: 'Gilroy-Bold', fontSize: 22),
                                )),
                            rcn.isNotEmpty
                                ? Container(
                                    margin: const EdgeInsets.symmetric(
                                        horizontal: 10),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10),
                                    decoration: BoxDecoration(
                                        color: const Color.fromARGB(
                                            176, 41, 41, 41),
                                        borderRadius:
                                            BorderRadius.circular(10)),
                                    child: GridView.builder(
                                        shrinkWrap: true,
                                        physics:
                                            const NeverScrollableScrollPhysics(),
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 20),
                                        gridDelegate:
                                            const SliverGridDelegateWithFixedCrossAxisCount(
                                                crossAxisCount: 3,
                                                mainAxisExtent: 180,
                                                mainAxisSpacing: 20,
                                                crossAxisSpacing: 10),
                                        itemCount: rcn.length,
                                        itemBuilder:
                                            (BuildContext context, index) {
                                          return Column(
                                            children: [
                                              ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                                child: Image.network(
                                                    "${rcn[index]['filmPoster'] ?? rcn[index]['anilistPoster']['large']}",
                                                    width: 120,
                                                    height: 180,
                                                    errorBuilder: (context,
                                                        error, stackTrace) {
                                                      return Image.network(
                                                          width: 120,
                                                          height: 180,
                                                          fit: BoxFit.cover,
                                                          'https://www.redhouseoriginals.com/wp-content/uploads/dark-placeholder.png');
                                                    },
                                                    fit: BoxFit.cover,
                                                    loadingBuilder: (context,
                                                        child,
                                                        loadingProgress) {
                                                      if (loadingProgress ==
                                                          null) {
                                                        return child;
                                                      } else {
                                                        return Container(
                                                          width: 135,
                                                          height: 195,
                                                          color: const Color
                                                                  .fromARGB(
                                                              85, 0, 0, 0),
                                                          child: const Center(
                                                            child:
                                                                CircularProgressIndicator
                                                                    .adaptive(),
                                                          ),
                                                        );
                                                      }
                                                    }),
                                              ),
                                            ],
                                          );
                                        }))
                                : Container(
                                    height: 200,
                                    margin: const EdgeInsets.symmetric(
                                        horizontal: 10),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10),
                                    decoration: BoxDecoration(
                                        color: const Color.fromARGB(
                                            176, 41, 41, 41),
                                        borderRadius:
                                            BorderRadius.circular(10)),
                                    child: const Center(
                                      child: Text(
                                        "You Have Not Watched \nAnything Yet.",
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            fontFamily: 'Gilroy-Bold',
                                            color: Color.fromARGB(
                                                255, 212, 212, 212),
                                            fontSize: 19),
                                      ),
                                    ),
                                  ),
                            const SizedBox(
                              height: 20,
                            )
                          ],
                        );
                      } else {
                        return const Center(
                          child: CircularProgressIndicator.adaptive(),
                        );
                      }
                    }),
              ],
            ),
          ),
        ],
      ),
    ));
  }
}

class ProfileImageCustomize extends StatelessWidget {
  ProfileImageCustomize({super.key, this.imageUrl});

  final imageUrl;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  saveImage(String url) async {
    await GallerySaver.saveImage(url, toDcim: true)
        .then((value) => popupToast("Image Saved To Gallery"));
  }

  Future updateProfileImage() async {
    final image = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (image == null) return;
    final imageTemp = File(image.path);
    popupToast("Updating Profile Pic");
    Reference storageref = _storage.ref();
    Reference ref = storageref.child(_auth.currentUser!.uid);
    UploadTask uploadTask = ref.putFile(imageTemp);
    String downloadUrl =
        await uploadTask.then((snapshot) => snapshot.ref.getDownloadURL());
    if (_auth.currentUser != null) {
      await _auth.currentUser!.updatePhotoURL(downloadUrl);
      popupToast('Profile Pic Updated');
    }
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
          ),
          IconButton(
              onPressed: () {
                updateProfileImage();
              },
              icon: const Icon(Icons.edit))
        ],
      ),
      body: Center(child: Image.network(imageUrl)),
    ));
  }
}
