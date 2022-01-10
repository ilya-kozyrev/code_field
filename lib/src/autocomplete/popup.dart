import 'dart:math';

import 'package:code_text_field/src/autocomplete/popup_controller.dart';
import 'package:flutter/material.dart';

class Popup extends StatefulWidget {
  final double row;
  final double column;
  final double editingWindowWidth;
  PopupController controller;

  Popup({
    Key? key,
    required this.row,
    required this.column,
    required this.controller,
    required this.editingWindowWidth,
  }) : super(key: key);

  @override
  _PopupState createState() => _PopupState();
}

class _PopupState extends State<Popup> {
  late double width;
  late double height;

  @override
  void initState() {
    this.width = 150;
    this.height = 100;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: min(widget.column, widget.editingWindowWidth - width),
        top: widget.row + 30,
      ),
      child: Container(
        child: ListView.builder(
            itemCount: widget.controller.suggestions.length,
            itemBuilder: (context, index) {
              return Text(widget.controller.suggestions[index]);
            }),
        width: width,
        height: height,
      ),
    );
  }
}
