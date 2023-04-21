import 'package:better_player/better_player.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class AnimeVideoPlayer extends StatefulWidget {
  const AnimeVideoPlayer({
    super.key,
    this.sources,
  });
  final List? sources;
  @override
  State<AnimeVideoPlayer> createState() => _AnimeVideoPlayerState();
}

class _AnimeVideoPlayerState extends State<AnimeVideoPlayer> {
  late BetterPlayerController btcontroller;
  Map<String, String> src = {};
  void convertSources() {
    for (var ele in widget.sources!.reversed.toList()) {
      if (ele['quality'] != 'default') {
        src['${ele['quality']}'] = "${ele['url']}";
      }
    }
  }

  @override
  void initState() {
    super.initState();
    convertSources();
    btcontroller = BetterPlayerController(const BetterPlayerConfiguration(
        fit: BoxFit.contain,
        autoPlay: false,
        looping: false,
        allowedScreenSleep: false,
        autoDetectFullscreenAspectRatio: true,
        autoDetectFullscreenDeviceOrientation: true,
        autoDispose: true,
        fullScreenByDefault: false, // Need to change later
        controlsConfiguration: BetterPlayerControlsConfiguration(
            controlBarColor: Color.fromARGB(30, 0, 0, 0),
            playIcon: Icons.play_circle_fill_outlined,
            pauseIcon: Icons.pause_circle,
            progressBarPlayedColor: Colors.red)));

    _initPlayer();
  }

  void _initPlayer() async {
    var reverse = widget.sources!.reversed.toList();
    reverse =
        reverse.where((element) => element['quality'] != 'default').toList();
    await btcontroller
        .setupDataSource(
          BetterPlayerDataSource(
            BetterPlayerDataSourceType.network,
            reverse[0]['url'],
            videoFormat: BetterPlayerVideoFormat.hls,
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
    return SafeArea(
      child: Scaffold(
          appBar: AppBar(
            elevation: 0,
            backgroundColor: Colors.transparent,
          ),
          backgroundColor: const Color.fromARGB(255, 0, 0, 0),
          body: BetterPlayer(
            controller: btcontroller,
          )),
    );
  }
}
