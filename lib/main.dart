import 'package:finalmicrophone/screens/songsPage.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'components/auth_page.dart';
import 'provider/record_audio_provider.dart';
import 'provider/play_audio_provider.dart';
import 'screens/homePage.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const EntryRoot());
}

class EntryRoot extends StatelessWidget {
  const EntryRoot({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => RecordAudioProvider(context)),
        ChangeNotifierProvider(create: (_) => PlayAudioProvider()),
      ],
      child: MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Record And Play',
          initialRoute: '/',
          routes: {
            '/recordScreen': (context) => RecordAndPlayScreen(),
            '/songPage': (context) => SongPage(
                  artists:
                      Provider.of<RecordAudioProvider>(context).song['artists'],
                  genres:
                      Provider.of<RecordAudioProvider>(context).song['genres'],
                  album_name: Provider.of<RecordAudioProvider>(context)
                      .song['album_name'],
                  name: Provider.of<RecordAudioProvider>(context).song['name'],
                  url: Provider.of<RecordAudioProvider>(context).song['url'],
                  image_url: Provider.of<RecordAudioProvider>(context)
                      .song['image_url'],
                ),
          },
          home: AuthPage()),
    );
  }
}
