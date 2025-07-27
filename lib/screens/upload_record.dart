import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:finalmicrophone/screens/songsPage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:simple_ripple_animation/simple_ripple_animation.dart';
import 'package:provider/provider.dart';
import '../components/customBorder.dart';
import '../components/loadingState.dart';
import '../components/resusableGesture.dart';
import '../provider/play_audio_provider.dart';
import '../provider/record_audio_provider.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class UploadAndRecord extends StatefulWidget {
  const UploadAndRecord({Key? key}) : super(key: key);

  @override
  State<UploadAndRecord> createState() => _UploadAndRecordState();
}

class _UploadAndRecordState extends State<UploadAndRecord> {
  final String uid = FirebaseAuth.instance.currentUser!.uid!;

  Future<void>? _callUserFuture;
  String? screenName = '';

  // final user = FirebaseAuth.instance.currentUser!;
  @override
  void initState() {
    _callUserFuture = callUser();

    super.initState();
  }

  //can't fetch logged in user after opening app after closing if non -google user is signed in.
  //aru ta kaam chalirekei cha.

  callUser() async {
    if (FirebaseAuth.instance.currentUser!.displayName != null) {
      setState(() {
        screenName =
            FirebaseAuth.instance.currentUser!.displayName!.split(" ")[0];
      });
    } else {
      late DocumentSnapshot doc;
      final docRef = FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid!);
      doc = await docRef.get();
      final data = doc.data() as Map<String, dynamic>;
      setState(() {
        screenName = data['first name'];
      });
    }
  }

  Future<void> addSongToHistory(String songName, bool isFavorite,
      List<dynamic> artists, String ImageUrl) async {
    final historyRef = FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('history');

    final querySnapshot =
        await historyRef.where('songName', isEqualTo: songName).limit(1).get();

    if (querySnapshot.docs.isNotEmpty) {
      final doc = querySnapshot.docs.first;
      await doc.reference.update({'isFavorite': isFavorite});
    } else {
      await historyRef.add({
        'songName': songName,
        'isFavorite': isFavorite,
        'createdAt': FieldValue.serverTimestamp(),
        'artists': artists,
        'ImageUrl': ImageUrl
      });
    }
  }

  Future<void> addSong(String name, String url, String imageUrl,
      String album_name, List genres, List artists) async {
    final songsRef = FirebaseFirestore.instance.collection('songs');

    // check if song already exists
    final querySnapshot =
        await songsRef.where('name', isEqualTo: name).limit(1).get();

    if (querySnapshot.docs.isNotEmpty) {
      print('this song is already available');
    } else {
      await songsRef.add({
        'name': name,
        'url': url,
        'imageUrl': imageUrl,
        'album_name': album_name,
        'genres': genres,
        'artists': artists
      });
    }

    // song does not exist, add to collection
  }

  @override
  Widget build(BuildContext context) {
    clearData() {
      Provider.of<RecordAudioProvider>(context, listen: false).clearOldData();
    }

    bool isReceived = Provider.of<RecordAudioProvider>(context).received;
    bool connectionFail =
        Provider.of<RecordAudioProvider>(context).connectionfail;

    final _recordProvider = Provider.of<RecordAudioProvider>(context);

    final _playProvider = Provider.of<PlayAudioProvider>(context);
    bool isRecordingInProgress = _recordProvider.recordedFilePath.isNotEmpty &&
        !isReceived &&
        !connectionFail;
    bool isUploadingInProgress =
        _recordProvider.uploadStatus && !isReceived && !connectionFail;
    bool resultAfterRecording = _recordProvider.recordedFilePath.isNotEmpty &&
        !_playProvider.isSongPlaying &&
        _recordProvider.received;
    bool resultAfterUploading = _recordProvider.uploadStatus &&
        !_playProvider.isSongPlaying &&
        _recordProvider.received;
    bool uploadAudioCase = !_recordProvider.uploadStatus &&
        !_recordProvider.recordedFilePath.isNotEmpty &&
        !_recordProvider.isRecording &&
        !connectionFail;
    bool recordAudioCase = !_recordProvider.uploadStatus &&
        !_recordProvider.recordedFilePath.isNotEmpty &&
        !connectionFail;
    String imageUrlBG =
        'https://images.unsplash.com/photo-1550895030-823330fc2551?ixlib=rb-4.0.3&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=387&q=80';

    return FutureBuilder<void>(
      future: _callUserFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else {
          return Scaffold(
            appBar: AppBar(
              centerTitle: true,
              title: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Welcome ${screenName}!',
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ),
            backgroundColor: Colors.white,
            body: Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                decoration: BoxDecoration(
                    image: DecorationImage(
                        fit: BoxFit.cover,
                        image: AssetImage('assets/images/background.jpg'))),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (isRecordingInProgress) LoadingState(onTap: clearData),
                      if (!isRecordingInProgress) Text(''),
                      if (isUploadingInProgress) LoadingState(onTap: clearData),
                      if (!isUploadingInProgress) Text(''),
                      Visibility(
                        visible: uploadAudioCase,
                        child: Padding(
                          padding: const EdgeInsets.all(18.0),
                          child: UnicornOutlineButton(
                            strokeWidth: 2,
                            radius: 24,
                            gradient: LinearGradient(
                                colors: [Colors.black, Colors.redAccent]),
                            onPressed: () => {},
                            child: Container(
                              padding: EdgeInsets.symmetric(vertical: 15),
                              child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      'Switch IP',
                                      style: TextStyle(
                                        fontSize: 30,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: 'Roboto',
                                        color: Colors.black,
                                      ),
                                    ),
                                    SizedBox(height: 20),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        GestureDetector(
                                          onTap: () =>
                                              _recordProvider.riyanshwifi(),
                                          child: Text(
                                            'Riyansh Wifi',
                                            style: TextStyle(
                                              fontSize: 20,
                                              fontFamily: 'Roboto',
                                              color: Colors.black,
                                            ),
                                          ),
                                        ),
                                        SizedBox(width: 20),
                                        Icon(Icons.check,
                                            color: _recordProvider.ipLocation ==
                                                    IPLocation.riyanshWifi
                                                ? Colors.purple
                                                : Colors.white),
                                      ],
                                    ),
                                    SizedBox(height: 20),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        GestureDetector(
                                          onTap: () =>
                                              _recordProvider.NDMwifi(),
                                          child: Text(
                                            'NDM Wifi',
                                            style: TextStyle(
                                              fontSize: 20,
                                              fontFamily: 'Roboto',
                                              color: Colors.black,
                                            ),
                                          ),
                                        ),
                                        SizedBox(width: 20),
                                        Icon(Icons.check,
                                            color: _recordProvider.ipLocation ==
                                                    IPLocation.NDMwifi
                                                ? Colors.purple
                                                : Colors.white),
                                      ],
                                    ),
                                    SizedBox(height: 20),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        GestureDetector(
                                          onTap: () =>
                                              _recordProvider.mobilehotspot(),
                                          child: Text(
                                            'Mobile Hotspot',
                                            style: TextStyle(
                                              fontSize: 20,
                                              fontFamily: 'Roboto',
                                              color: Colors.black,
                                            ),
                                          ),
                                        ),
                                        SizedBox(width: 20),
                                        Icon(Icons.check,
                                            color: _recordProvider.ipLocation ==
                                                    IPLocation.mobileHotspot
                                                ? Colors.purple
                                                : Colors.white),
                                      ],
                                    ),
                                  ]),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(
                        height: 30,
                      ),
                      if (uploadAudioCase) _recordHeading('Upload Audio'),
                      const SizedBox(
                        height: 40,
                      ),
                      if (uploadAudioCase) _uploadSection(),
                      const SizedBox(
                        height: 60,
                      ),
                      if (recordAudioCase) _recordHeading('Record Audio'),
                      const SizedBox(
                        height: 40,
                      ),
                      if (recordAudioCase) _recordingSection(),
                      if (connectionFail) afterConnectionFail(),
                      afterReceived(),
                      const SizedBox(height: 40),

                      if (resultAfterRecording) ResultColumn(),
                      if (resultAfterUploading) ResultColumn(),
                      const SizedBox(
                        height: 40,
                      ),

// _resetButton(),
// _loadingPage(),
                    ],
                  ),
                )),
          );
        }
      },
    );
  }

  afterConnectionFail() {
    final _recordProvider = Provider.of<RecordAudioProvider>(context);

    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Could not send request',
            style: TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.bold,
              color: Colors.red,
            ),
          ),
          const SizedBox(height: 80),
          CustomButton(
            text: 'Go back',
            onTap: () {
              Provider.of<RecordAudioProvider>(context, listen: false)
                  .clearOldData();
            },
          ),
        ],
      ),
    );
  }

  afterReceived() {
    final _recordProvider = Provider.of<RecordAudioProvider>(context);

    return InkWell(
      onTap: () {
        print(_recordProvider.song);
        addSongToHistory(
            _recordProvider.song['name'],
            false,
            _recordProvider.song['artists'],
            _recordProvider.song['image_url'].toString());
        print('reached here>');
        addSong(
            _recordProvider.song['name'],
            _recordProvider.song['url'],
            _recordProvider.song['image_url'],
            _recordProvider.song['album_name'],
            _recordProvider.song['genres'],
            _recordProvider.song['artists']);
        Navigator.of(context).pushNamed('/songPage');
      },
      child: _recordProvider.received
          ? Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: Colors.blue,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  "See Result!",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
            )
          : Container(),
    );
  }

  _uploadSection() {
    final _recordProviderWithoutListener =
        Provider.of<RecordAudioProvider>(context, listen: false);
    return InkWell(
      onTap: () async => await _recordProviderWithoutListener.uploadAudio(),
      child: _commonIconSection(Icons.upload, Colors.brown),
    );
  }

  _recordHeading(String messageTime) {
    return Center(
      child: Text(
        messageTime,
        style: TextStyle(
            fontSize: 25, fontWeight: FontWeight.w700, color: Colors.black),
      ),
    );
  }

  ResultColumn() {
    final _recordProvider = Provider.of<RecordAudioProvider>(context);

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _resetButton(),
        const SizedBox(
          height: 40,
        ),
        Text(
            'Response Time: ${_recordProvider.responseTime.inSeconds.toString()} seconds'),
      ],
    );
  }

  _recordingSection() {
    final _recordProvider = Provider.of<RecordAudioProvider>(context);
    final _recordProviderWithoutListener =
        Provider.of<RecordAudioProvider>(context, listen: false);
    if (_recordProvider.isRecording) {
      return InkWell(
        onTap: () async => await _recordProviderWithoutListener.stopRecording(),
        child: RippleAnimation(
          repeat: true,
          minRadius: 40,
          ripplesCount: 6,
          color: Colors.tealAccent,
          child: Container(
              width: 70,
              height: 70,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.lightGreen,
                borderRadius: BorderRadius.circular(108),
              ),
              child: const Icon(
                Icons.keyboard_voice_rounded,
                color: Colors.white,
                size: 30,
              )),
        ),
      );
    }
    return InkWell(
      onTap: () async => await _recordProviderWithoutListener.recordVoice(),
      child: _commonIconSection(Icons.keyboard_voice_sharp, Colors.green),
    );
  }

  _commonIconSection(IconData iconData, Color color) {
    return Container(
      width: 70,
      height: 70,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(100),
      ),
      child: Icon(iconData, color: Colors.white, size: 30),
    );
  }

  _resetButton() {
    final _recordProvider =
        Provider.of<RecordAudioProvider>(context, listen: false);

    return InkWell(
      onTap: () => _recordProvider.clearOldData(),
      child: Center(
        child: Container(
          width: 80,
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.redAccent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Text(
            'Reset',
            style: TextStyle(fontSize: 18, color: Colors.white),
          ),
        ),
      ),
    );
  }
}
