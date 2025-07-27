import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../provider/record_audio_provider.dart';

class HistoryList extends StatefulWidget {
  const HistoryList({Key? key}) : super(key: key);

  @override
  _HistoryListState createState() => _HistoryListState();
}

class _HistoryListState extends State<HistoryList> {
  @override
  Widget build(BuildContext context) {
    Future<void> printCachedValues() async {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys();
      print('Cached values:');
      for (var key in keys) {
        final value = prefs.get(key);
        if (value is String) {
          print('$key: $value');
        } else {
          final list = value as List<dynamic>;
          print('$key: $list');
        }
      }
    }

    printCachedValues();

    Future<void> addSongToFavorites(String songName, bool isFavorite,
        String artists, String ImageUrl) async {
      final String uid = FirebaseAuth.instance.currentUser!.uid!;
      final favoritesRef = FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('favorites');

      final querySnapshot = await favoritesRef
          .where('songName', isEqualTo: songName)
          .limit(1)
          .get();

      if (isFavorite) {
        if (querySnapshot.docs.isNotEmpty) {
          final doc = querySnapshot.docs.first;
          await doc.reference.update({'isFavorite': true});
        } else {
          await favoritesRef.add({
            'songName': songName,
            'isFavorite': true,
            'createdAt': FieldValue.serverTimestamp(),
            'artists': artists,
            'ImageUrl': ImageUrl
          });
        }
      } else {
        if (querySnapshot.docs.isNotEmpty) {
          final doc = querySnapshot.docs.first;
          await doc.reference.delete();
        }
      }
    }

    print(Provider.of<RecordAudioProvider>(context).song['genres'].runtimeType);

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
                      .collection('history')
                      .orderBy('createdAt', descending: true)
                      .snapshots(),
                  builder: (BuildContext context,
                      AsyncSnapshot<QuerySnapshot> snapshot) {
                    if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    }
                    if (!snapshot.hasData) {
                      return Center(
                        child: CircularProgressIndicator(
                          strokeWidth: 1.0,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.blue),
                        ),
                      );
                    }

                    final docs = snapshot.data!.docs;

                    if (docs.isEmpty) {
                      return Center(
                        child: Text(
                          'No History yet.',
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 30,
                          ),
                        ),
                      );
                    }
                    return ListView.builder(
                      itemCount: snapshot.data!.docs.length,
                      itemBuilder: (BuildContext context, int index) {
                        final doc = snapshot.data!.docs[index];
                        final songName = doc['songName'];
                        final isFavorite = doc['isFavorite'];
                        final songArtist = doc['artists'][0];
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
                              Padding(
                                padding: const EdgeInsets.only(bottom: 8.0),
                                child: Text(
                                  DateFormat('EEEE, MMM d')
                                      .format(createdAt.toDate()),
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Display the song image on the left of the tile
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8.0),
                                    child: Image.network(
                                      songImageUrl,
                                      fit: BoxFit.cover,
                                      height:
                                          MediaQuery.of(context).size.height *
                                              0.2,
                                      width: MediaQuery.of(context).size.width *
                                          0.3,
                                    ),
                                  ),
                                  SizedBox(width: 10),
                                  Expanded(
                                    child: ListTile(
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
                                          IconButton(
                                            icon: Icon(
                                              isFavorite
                                                  ? Icons.favorite
                                                  : Icons.favorite_border,
                                              color: isFavorite
                                                  ? Colors.red
                                                  : Colors.grey,
                                            ),
                                            onPressed: () {
                                              doc.reference.update(
                                                  {'isFavorite': !isFavorite});
                                              addSongToFavorites(
                                                  songName,
                                                  !isFavorite,
                                                  songArtist,
                                                  songImageUrl);
                                            },
                                          ),
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
                ),
              ),
            ],
          ),
        ),
      ],
    ));
  }
}
