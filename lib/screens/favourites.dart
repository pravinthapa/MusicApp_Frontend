import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:finalmicrophone/screens/songsPage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../provider/record_audio_provider.dart';

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({Key? key}) : super(key: key);

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  void _openResultsPage(BuildContext context, String songName) async {
    final recordProvider =
        Provider.of<RecordAudioProvider>(context, listen: false);
    await recordProvider.loadCachedSong(songName);
    if (recordProvider.song != null &&
        recordProvider.song['name'] == songName) {
      print('WEnt from here,  loadedcache.');
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SongPage(
            name: recordProvider.song['name'].toString(),
            url: recordProvider.song['url'].toString(),
            image_url: recordProvider.song['image_url'].toString(),
            album_name: recordProvider.song['album_name'].toString(),
            artists: recordProvider.song['artists'],
            genres: recordProvider.song['genres'],
          ),
        ),
      );
    } else {
      var requiredSong = await FirebaseFirestore.instance
          .collection('songs')
          .where('name', isEqualTo: songName)
          .limit(1)
          .get();
      var songData = requiredSong.docs.first;
      print('WEnt from here,  fetched the song again.');

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SongPage(
            name: songData['name'].toString(),
            url: songData['url'].toString(),
            image_url: songData['imageUrl'].toString(),
            album_name: songData['album_name'].toString(),
            artists: songData['artists'],
            genres: songData['genres'],
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final String uid = FirebaseAuth.instance.currentUser!.uid!;
    String imageUrlBG =
        'https://images.unsplash.com/photo-1550895030-823330fc2551?ixlib=rb-4.0.3&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=387&q=80';
    return Scaffold(
        body: Stack(
      children: [
        Image.asset(
          'assets/images/background.jpg',
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
        ),
        Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('users')
                    .doc(uid)
                    .collection('favorites')
                    .orderBy('createdAt', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Center(
                      child: CircularProgressIndicator(
                        strokeWidth: 1.0,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                      ),
                    );
                  }

                  final docs = snapshot.data!.docs;

                  if (docs.isEmpty) {
                    return Center(
                      child: Text(
                        'No favorites yet.',
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 30,
                        ),
                      ),
                    );
                  }

                  return ListView.builder(
                    itemCount: docs.length,
                    itemBuilder: (context, index) {
                      final doc = docs[index];
                      final songName = doc['songName'];
                      final isFavorite = doc['isFavorite'];
                      final songArtist = doc['artists'];
                      final songImageUrl = doc['ImageUrl'];
                      final createdAt = doc['createdAt'];

                      return Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        padding: EdgeInsets.all(10),
                        margin: EdgeInsets.symmetric(vertical: 4.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Display the date above the container

                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Display the song image on the left of the tile
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8.0),
                                  child: Image.network(
                                    songImageUrl,
                                    fit: BoxFit.cover,
                                    height: MediaQuery.of(context).size.height *
                                        0.2,
                                    width:
                                        MediaQuery.of(context).size.width * 0.3,
                                  ),
                                ),
                                SizedBox(width: 10),
                                Expanded(
                                  child: ListTile(
                                    onTap: () async {
                                      _openResultsPage(context, songName);
                                    },
                                    selectedTileColor: Colors.cyanAccent[100],
                                    title: Text(
                                      songName,
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                      ),
                                    ),
                                    subtitle: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        SizedBox(height: 4),
                                        Text(
                                          songArtist,
                                          style: TextStyle(
                                            color: Colors.grey,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                    ),
                                    trailing: Wrap(
                                      spacing: -10,
                                      children: [
                                        Theme(
                                          data: Theme.of(context).copyWith(
                                            cardColor: Colors.green
                                                .shade300, // Set the background color of the popup menu
                                          ),
                                          child: PopupMenuButton<String>(
                                            icon: Icon(Icons.more_vert),
                                            onSelected: (String choice) {
                                              if (choice == 'delete') {
                                                doc.reference.delete();
                                              }
                                            },
                                            itemBuilder:
                                                (BuildContext context) {
                                              return ['delete']
                                                  .map((String choice) {
                                                return PopupMenuItem<String>(
                                                  value: choice,
                                                  child: Text(
                                                    choice,
                                                    style: TextStyle(
                                                      color: Colors.black,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 18,
                                                    ),
                                                  ),
                                                );
                                              }).toList();
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              )),
            ],
          ),
        ),
      ],
    ));
  }
}
