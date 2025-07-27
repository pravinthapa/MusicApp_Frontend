import 'dart:async';
import 'package:flutter/material.dart';
import 'package:finalmicrophone/components/resusableGesture.dart';

class LoadingState extends StatefulWidget {
  final Function()? onTap;

  LoadingState({required this.onTap});

  @override
  _LoadingState createState() => _LoadingState();
}

class _LoadingState extends State<LoadingState> {
  String statusText = "System is searching for the song";
  Timer? timer;
  int seconds = 0;

  @override
  void initState() {
    super.initState();
    startTimer();
  }

  void startTimer() {
    timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        seconds++;
        if (seconds >= 15 ) {
          statusText = "Almost there" + "." * (seconds % 3 + 1);
        } else if (seconds > 30) {
          statusText = "Taking more than usual" + "." * (seconds % 3 + 1);
          timer.cancel();
        } else {
          statusText = "System is searching for the song" + "." * (seconds % 3 + 1);
        }
      });
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SizedBox(
            height: 30,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Container(),
                ),
                CustomButton(text: 'Cancel and Go back', onTap: widget.onTap),
              ],
            ),
          ),
          SizedBox(
            height: 200,
          ),
          Center(child: CircularProgressIndicator()),
          SizedBox(
            height: 30,
          ),
          Text(
            statusText,
            style: TextStyle(fontSize: 18),
          ),
        ],
      ),
    );
  }
}
