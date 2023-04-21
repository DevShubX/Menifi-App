import 'package:better_player/better_player.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'dart:async';
import 'dart:convert';

import 'package:url_launcher/url_launcher.dart';

class MovieVidePlayer extends StatefulWidget {
  const MovieVidePlayer(
      {super.key, this.sources, this.subtitles, this.downloadLink});
  final List? sources;
  final subtitles;
  final downloadLink;
  @override
  State<MovieVidePlayer> createState() => _MovieVidePlayerState();
}

class _MovieVidePlayerState extends State<MovieVidePlayer> {
  late BetterPlayerController btcontroller;

  List<BetterPlayerSubtitlesSource>? betterPlayerSubtitles = [];

  Future convertSubtitle() async {
    /// Convert subtitles object from api to betterplayersubtitle objects\
    if (widget.subtitles.length > 0) {
      for (var element in widget.subtitles) {
        betterPlayerSubtitles?.add(BetterPlayerSubtitlesSource(
          type: BetterPlayerSubtitlesSourceType.network,
          name: '${element['lang']}',
          urls: ['${element['url']}'],
        ));
      }
    }
  }

  Map<String, String> src = {};
  void convertSources() {
    for (var ele in widget.sources!) {
      src['${ele['quality']}'] = "${ele['url']}";
    }
  }

  @override
  void initState() {
    super.initState();
    convertSubtitle();
    convertSources();
    btcontroller = BetterPlayerController(const BetterPlayerConfiguration(
        autoPlay: false,
        looping: false,
        allowedScreenSleep: false,
        autoDetectFullscreenAspectRatio: true,
        autoDetectFullscreenDeviceOrientation: true,
        autoDispose: true,
        fullScreenByDefault: true,
        fit: BoxFit.contain,
        controlsConfiguration: BetterPlayerControlsConfiguration(
            controlBarColor: Color.fromARGB(30, 0, 0, 0),
            playIcon: Icons.play_circle_fill_outlined,
            pauseIcon: Icons.pause_circle,
            progressBarPlayedColor: Colors.red)));

    _initPlayer();
  }

  void _initPlayer() async {
    await btcontroller
        .setupDataSource(
          BetterPlayerDataSource(
            BetterPlayerDataSourceType.network,
            widget.sources![0]['url'],
            videoFormat: BetterPlayerVideoFormat.hls,
            subtitles: betterPlayerSubtitles,
            resolutions: src,
          ),
        )
        .then((value) => setState(() {}));
  }

  @override
  void dispose() {
    btcontroller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Color.fromARGB(255, 0, 0, 0),
        actions: [
          IconButton(
              onPressed: () {
                launchUrl(Uri.parse("${widget.downloadLink}"),
                    mode: LaunchMode.externalApplication);
              },
              icon: const Icon(
                Icons.download,
                color: Colors.red,
              )),
          const SizedBox(
            width: 5,
          ),
        ],
      ),
      backgroundColor: Colors.black,
      body: SafeArea(
        child: BetterPlayer(
          controller: btcontroller,
        ),
      ),
    );
  }
}
