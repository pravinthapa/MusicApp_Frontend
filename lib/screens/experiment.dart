import 'package:finalmicrophone/components/loadingState.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../provider/record_audio_provider.dart';

class Experiment extends StatelessWidget {


  @override
  Widget build(BuildContext context) {
  return Column(
  children: [
        LoadingState(onTap:  (){  Provider.of<RecordAudioProvider>(context, listen: false)
        .clearOldData();}),
  ],
);
  }
}
