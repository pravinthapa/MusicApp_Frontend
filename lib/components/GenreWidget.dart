import 'package:finalmicrophone/components/songCard.dart';
import 'package:finalmicrophone/components/songClassforGenres.dart';
import 'package:flutter/material.dart';

class GenreWidget extends StatefulWidget {
  final List<dynamic> songsList;
  final String textTitle;

  const GenreWidget({Key? key, required this.songsList, required this.textTitle}) : super(key: key);

  @override
  _GenreWidgetState createState() => _GenreWidgetState();
}

class _GenreWidgetState extends State<GenreWidget> {


  @override
  Widget build(BuildContext context) {
    if (widget.songsList.isEmpty) {
      return Container();
    }

    return Column(
      children: [
        Container(
          alignment: Alignment.center,
          padding: EdgeInsets.symmetric(vertical: 16.0),
          child: Text(
            widget.textTitle,
            style: TextStyle(
              fontSize: 20.0,
              fontWeight: FontWeight.bold,
              color: Colors.black,
              decoration: TextDecoration.underline,
            ),
          ),
        ),

        SizedBox(
          width: MediaQuery.of(context).size.width,
          height: 300.0,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: widget.songsList.length,
            itemBuilder: (BuildContext context, int index) {
              Song song = widget.songsList[index];
              return SongCard(
                imageUrl: song.imageUrl,
                name: song.name,
                artistName: song.artistName,
              );
            },
          ),
        ),
      ],
    );

  }
}