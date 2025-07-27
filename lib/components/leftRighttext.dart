import 'package:flutter/material.dart';

class LeftRightText extends StatelessWidget {
  final String leftText;
  final String rightText;

  LeftRightText({
    required this.leftText,
    required this.rightText,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: Colors.black,
                width: 1.0,
              ),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                leftText,
                style: TextStyle(
                  color: Colors.redAccent,
                  fontSize: 15,
                ),
              ),
              Expanded(
                child: Container(
                  alignment: Alignment.centerRight,
                  child: Text(
                    rightText,
                    style: TextStyle(
                      color: Colors.black,
                    ),
                    textAlign: TextAlign.right,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 32),
      ],
    );
  }
}
