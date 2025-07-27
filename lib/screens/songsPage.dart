import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../components/GenreWidget.dart';
import '../components/leftRighttext.dart';
import '../components/neubox.dart';
import '../components/songClassforGenres.dart';

class SongPage extends StatefulWidget {
  final List<dynamic> genres;
  final String album_name;
  final String name;
  final String url;
  final List<dynamic> artists;

  final String image_url;

  const SongPage({
    Key? key,
    required this.genres,
    required this.album_name,
    required this.name,
    required this.url,
    required this.image_url,
    required this.artists,
  }) : super(key: key);

  @override
  State<SongPage> createState() => _SongPageState();
}

class _SongPageState extends State<SongPage> {
  late YoutubePlayerController _ycontroller;
  final String uid = FirebaseAuth.instance.currentUser!.uid!;
  bool isLoading = true;
  bool isLoadingArtistSong = true;
  late List<dynamic> genreSongs = [];
  late List<dynamic> artistSongs = [];
  Future<List<dynamic>> _getCachedList(String key) async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString(key);
    if (json != null) {
      return jsonDecode(json);
    }
    return [];
  }

  Future<void> _cacheList(String key, List<dynamic> list) async {
    final prefs = await SharedPreferences.getInstance();
    final json = jsonEncode(list);
    prefs.setString(key, json);
    print('Cache stored for key: $key, value: $json');
  }

  Future<void> _fetchSongs(
      List<dynamic> givenList, String collectionName, bool loadingState) async {
    setState(() {
      loadingState = true;
    });
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection(collectionName)
          .where('name', isEqualTo: givenList[0])
          .limit(1)
          .get();

      final docSnapshot = querySnapshot.docs.first;
      final songs = docSnapshot.data()['songs'];
      List<Map<String, dynamic>> songsList = []; // changed type of list to Map

      for (var songName in songs) {
        //so just, make sure all songs from songsOfGenres is imported in the database, and it will show.
        var requiredSong = await FirebaseFirestore.instance
            .collection('songs')
            .where('name', isEqualTo: songName)
            .limit(1)
            .get();
        var songData;
        if (requiredSong.docs.isNotEmpty) {
          songData = requiredSong.docs.first.data();
        }
        if (songData != null) {
          var song = Song.fromJson(songData);
          songsList.add(song.toMap()); // add song as map to list
        }
      }
      //adds the list in the cacheliSt, withkey is either genre name or artist name and the value is list.
      print('before caching list.');
      await _cacheList(givenList[0], songsList);
      print('this should have cached the list.');
      setState(() {
        if (collectionName == 'RecommendGenres') {
          genreSongs = songsList
              .map((map) => Song.fromMap(map))
              .toList(); // convert list of maps to list of Song objects
          isLoading = false;
        } else {
          artistSongs = songsList
              .map((map) => Song.fromMap(map))
              .toList(); // convert list of maps to list of Song objects
          isLoadingArtistSong = false;
        }
        loadingState = false;
      });
    } catch (error) {
      setState(() {
        if (collectionName == 'RecommendGenres') {
          isLoading = false;
        } else {
          isLoadingArtistSong = false;
        }
      });
      print('Error fetching songs: $error');
    }
  }

  @override
  void initState() {
    super.initState();

    _getCachedList(widget.genres[0]).then((cachedList) {
      if (cachedList.isNotEmpty) {
        setState(() {
          genreSongs =
              cachedList.map((songMap) => Song.fromMap(songMap)).toList();
          isLoading = false;
        });
      } else {
        _fetchSongs(widget.genres, 'RecommendGenres', isLoading);
      }
    });
    _getCachedList(widget.artists[0]).then((cachedList) {
      if (cachedList.isNotEmpty) {
        setState(() {
          artistSongs =
              cachedList.map((songMap) => Song.fromMap(songMap)).toList();
          isLoadingArtistSong = false;
        });
      } else {
        _fetchSongs(widget.artists, 'artists', isLoadingArtistSong);
      }
    });

    // _fetchSongs(widget.genres, 'RecommendGenres', isLoading);
    // _fetchSongs(widget.artists, 'artists', isLoadingArtistSong);
    final videoId = YoutubePlayer.convertUrlToId(widget.url);
    _ycontroller = YoutubePlayerController(
      initialVideoId: videoId!,
      flags: YoutubePlayerFlags(
        autoPlay: false,
        mute: false,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25.0),
            child: Column(
              children: [
                const SizedBox(height: 10),

                // back button and menu button
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(
                      height: 60,
                      width: 60,
                      child: NeuBox(child: BackButton()),
                    ),
                    Text('Y  O U R  S O N G !'),
                    SizedBox(
                      height: 60,
                      width: 60,
                      child: NeuBox(child: Icon(Icons.menu)),
                    ),
                  ],
                ),

                const SizedBox(height: 30),

                // cover art, artist name, song name
                NeuBox(
                  child: Column(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: CachedNetworkImage(
                          height: 280,
                          fit: BoxFit.fill,
                          progressIndicatorBuilder: (context, url, progress) =>
                              Center(
                            child: CircularProgressIndicator(
                              value: progress.progress,
                            ),
                          ),
                          imageUrl: widget.image_url,
                        ),
                      ),
                      const SizedBox(height: 30),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.name,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              widget.artists.join(', '),
                              style: TextStyle(
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                const Icon(
                                  Icons.favorite,
                                  color: Colors.red,
                                  size: 32,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 70),
                isLoadingArtistSong
                    ? Center(child: CircularProgressIndicator())
                    : GenreWidget(
                        songsList: artistSongs, textTitle: 'Top Songs'),

                SizedBox(height: 70),
                NeuBox(
                  child: Column(
                    children: [
                      Center(
                        child: Text(
                          'Youtube Player',
                          style: TextStyle(
                            // fontFamily: 'MycustomFont',
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
                      YoutubePlayer(
                          controller: _ycontroller,
                          showVideoProgressIndicator: true,
                          progressIndicatorColor: Colors.amber,
                          bottomActions: [
                            CurrentPosition(),
                            ProgressBar(
                              isExpanded: true,
                              colors: const ProgressBarColors(
                                playedColor: Colors.amber,
                                handleColor: Colors.amberAccent,
                              ),
                            ),
                            const PlaybackSpeedButton(),
                            FullScreenButton(),
                          ]),
                      SizedBox(height: 20),
                    ],
                  ),
                ),

                SizedBox(height: 70),

                isLoading
                    ? Center(child: CircularProgressIndicator())
                    : GenreWidget(
                        songsList: genreSongs, textTitle: 'You may also like'),
                SizedBox(height: 100),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Track Information',
                      style: TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                      textAlign: TextAlign.left,
                    ),
                  ),
                ),
                LeftRightText(
                  leftText: 'Track',
                  rightText: widget.name,
                ),
                LeftRightText(
                  leftText: 'Album',
                  rightText: widget.album_name,
                ),

                LeftRightText(
                  leftText: 'Artists',
                  rightText: widget.artists.join(', '),
                ),
                LeftRightText(
                  leftText: 'Genres',
                  rightText: widget.genres.join(', '),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
