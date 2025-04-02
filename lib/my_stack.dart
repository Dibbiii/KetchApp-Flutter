import 'package:flutter/material.dart';

class MyStack extends StatelessWidget {
  const MyStack({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.amber,
      height: 300,
      child: Stack(
        children: [
          Center(child: Icon(Icons.access_alarm)),
          Positioned(
            left: 5,
            right: 5,
            top: 15,
            child: Icon(Icons.account_balance),
          ),
          Align(
            alignment: Alignment.bottomRight,
            child: Container(width: 100, height: 100, color: Colors.red),
          ),
          Align(alignment: Alignment.bottomRight, child: Icon(Icons.kayaking)),
        ],
      ),
    );
  }
}
