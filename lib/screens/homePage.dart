import 'package:finalmicrophone/screens/favourites.dart';
import 'package:finalmicrophone/screens/history.dart';
import 'package:finalmicrophone/screens/switchIP.dart';
import 'package:finalmicrophone/screens/upload_record.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:provider/provider.dart';

import '../provider/record_audio_provider.dart';
import 'experiment.dart';

class RecordAndPlayScreen extends StatefulWidget {
  const RecordAndPlayScreen({Key? key}) : super(key: key);

  @override
  State<RecordAndPlayScreen> createState() => _RecordAndPlayScreenState();
}

class _RecordAndPlayScreenState extends State<RecordAndPlayScreen> {
  int _selectedIndex = 0;
  static List<Widget> _widgetOptions = <Widget>[
    UploadAndRecord(),
    HistoryList(),
    FavoritesPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        bottomNavigationBar: Container(
          color: Colors.black,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
            child: GNav(
              // tab button shadow

              gap: 8,
              // the tab button gap between icon and text
              backgroundColor: Colors.black,
              color: Colors.white,
              activeColor: Colors.white,
              tabBackgroundColor: Colors.grey.shade800,

              duration: Duration(milliseconds: 300),
              //
              padding: EdgeInsets.all(15),
              tabs: [
                GButton(
                  icon: Icons.home,
                  text: 'Home',
                ),
                GButton(
                  icon: Icons.history,
                  text: 'History',
                ),
                GButton(
                  icon: Icons.favorite,
                  text: 'Favorites',
                ),
                GButton(
                  icon: Icons.logout,
                  text: 'Logout',
                )
              ],
              selectedIndex: _selectedIndex,
              onTabChange: (index) {
                if (index == 3) {
                  signUserOut();
                } else {
                  setState(() {
                    _selectedIndex = index;
                  });
                }
              },
            ),
          ),
        ),
        body: _widgetOptions.elementAt(_selectedIndex));
  }

  signUserOut() {
    Provider.of<RecordAudioProvider>(context, listen: false).clearOldData();
    FirebaseAuth.instance.signOut();
  }
}
