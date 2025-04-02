import 'package:flutter/material.dart';

class Box extends StatefulWidget {
  const Box({super.key});

  @override
  State<StatefulWidget> createState() {
    return BoxState();
  }

}

class BoxState extends State {
  bool isOk = false;

  @override
  void initState() {

    isOk = true;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [Text(isOk ? "Ok" : "Non ok"), 
    ElevatedButton(onPressed: () {
      setState(() {
        isOk = !isOk;
      });
    }, child: Text("Cambia stato"))]);
  }
  
}