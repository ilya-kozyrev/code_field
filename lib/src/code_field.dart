import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:linked_scroll_controller/linked_scroll_controller.dart';
import './code_controller.dart';

class LineNumberController extends TextEditingController {
  final TextSpan Function(int, TextStyle?)? lineNumberBuilder;

  LineNumberController(this.lineNumberBuilder);

  @override
  TextSpan buildTextSpan(
      {required BuildContext context, TextStyle? style, bool? withComposing}) {
    final children = <TextSpan>[];
    final list = text.split("\n");
    for (int k = 0; k < list.length; k++) {
      final el = list[k];
      final number = int.parse(el);
      var textSpan = TextSpan(text: el, style: style);
      if (lineNumberBuilder != null)
        textSpan = lineNumberBuilder!(number, style);
      children.add(textSpan);
      if (k < list.length - 1) children.add(TextSpan(text: "\n"));
    }
    return TextSpan(children: children, style: style);
  }
}

class LineNumberStyle {
  /// Width of the line number column
  final double width;

  /// Alignment of the numbers in the column
  final TextAlign textAlign;

  /// Style of the numbers
  final TextStyle? textStyle;

  /// Background of the line number column
  final Color? background;

  /// Central horizontal margin between the numbers and the code
  final double margin;

  const LineNumberStyle({
    this.width = 14.0,
    this.textAlign = TextAlign.left,
    this.margin = 10.0,
    this.textStyle,
    this.background,
  });
}

class CodeField extends StatefulWidget {
  /// {@macro flutter.widgets.textField.minLines}
  final int? minLines;

  /// {@macro flutter.widgets.textField.maxLInes}
  final int? maxLines;

  /// Whether overflowing lines should wrap around or make the field scrollable horizontally
  final bool wrap;

  /// A CodeController instance to apply language highlight, themeing and modifiers
  final CodeController controller;

  /// A LineNumberStyle instance to tweak the line number column styling
  final LineNumberStyle lineNumberStyle;

  /// {@macro flutter.widgets.textField.cursorColor}
  final Color? cursorColor;

  /// {@macro flutter.widgets.textField.textStyle}
  final TextStyle? textStyle;

  /// A way to replace specific line numbers by a custom TextSpan
  final TextSpan Function(int, TextStyle?)? lineNumberBuilder;

  /// {@macro flutter.widgets.editableText.onChanged}
  final void Function(String)? onChanged;

  final Color? background;
  final EdgeInsets padding;
  final TextSelectionThemeData? textSelectionTheme;
  final FocusNode? focusNode;

  const CodeField({
    Key? key,
    required this.controller,
    this.minLines,
    this.maxLines,
    required this.wrap,
    this.background,
    this.textStyle,
    required this.padding,
    required this.lineNumberStyle,
    this.cursorColor,
    this.textSelectionTheme,
    this.lineNumberBuilder,
    this.focusNode,
    this.onChanged,
  }) : super(key: key);

  @override
  CodeFieldState createState() => CodeFieldState();
}

class CodeFieldState extends State<CodeField> {
// Add a controller
  LinkedScrollControllerGroup? _controllers;
  ScrollController? _numberScroll;
  ScrollController? _codeScroll;
  LineNumberController? _numberController;
  //
  StreamSubscription<bool>? _keyboardVisibilitySubscription;
  FocusNode? _focusNode;
  String? lines;
  String longestLine = "";

  @override
  void initState() {
    super.initState();
    _controllers = LinkedScrollControllerGroup();
    _numberScroll = _controllers?.addAndGet();
    _codeScroll = _controllers?.addAndGet();
    _numberController = LineNumberController(widget.lineNumberBuilder);
    widget.controller.addListener(_onTextChanged);
    _focusNode = widget.focusNode ?? FocusNode();
    _focusNode!.attach(context, onKey: _onKey);

    _onTextChanged();
  }

  KeyEventResult _onKey(FocusNode node, RawKeyEvent event) {
    return widget.controller.onKey(event);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTextChanged);
    _numberScroll?.dispose();
    _codeScroll?.dispose();
    _numberController?.dispose();
    _keyboardVisibilitySubscription?.cancel();
    super.dispose();
  }

  void rebuild() {
    setState(() {});
  }

  void _onTextChanged() {
    // Rebuild line number
    final str = widget.controller.text.split("\n");
    final buf = <String>[];
    for (var k = 0; k < str.length; k++) {
      buf.add((k + 1 + widget.controller.stringsNumber).toString());
    }
    _numberController?.text = buf.join("\n");
    // Find longest line
    longestLine = "";
    widget.controller.text.split("\n").forEach((line) {
      if (line.length > longestLine.length) longestLine = line;
    });
    setState(() {});
  }

  // Wrap the codeField in a horizontal scrollView
  Widget _wrapInScrollView(Widget codeField) {
    final leftPad = widget.lineNumberStyle.margin / 4;
    final intrinsic = IntrinsicWidth(
      child: codeField
    );

    return SingleChildScrollView(
      padding: EdgeInsets.only(
        left: leftPad,
        right: widget.padding.right,
      ),
      scrollDirection: Axis.horizontal,
      child: intrinsic,
    );
  }

  @override
  Widget build(BuildContext context) {
    // Default color scheme
    const ROOT_KEY = 'root';
    final defaultText = Colors.grey.shade200;
    final theme = widget.controller.theme;
    
    TextStyle textStyle = widget.textStyle ?? TextStyle();
    final textColor = textStyle.color ?? theme?[ROOT_KEY]?.color ?? defaultText;
    textStyle = textStyle.copyWith(
      color: widget.controller.enabled ? textColor : textColor.withOpacity(0.4),
      fontSize: textStyle.fontSize ?? 16.0,
    );
    TextStyle numberTextStyle = widget.lineNumberStyle.textStyle ?? TextStyle();
    final numberColor =
        (theme?[ROOT_KEY]?.color ?? defaultText).withOpacity(0.7);
    // Copy important attributes
    numberTextStyle = numberTextStyle.copyWith(
      color: numberTextStyle.color ?? numberColor,
      fontSize: textStyle.fontSize,
      fontFamily: textStyle.fontFamily,
    );
    final cursorColor =
        widget.cursorColor ?? theme?[ROOT_KEY]?.color ?? defaultText;

    final lineNumberCol = TextField(
      scrollPadding: widget.padding,
      style: numberTextStyle,
      controller: _numberController,
      enabled: false,
      minLines: widget.minLines,
      maxLines: widget.maxLines,
      scrollController: _numberScroll,
      decoration: InputDecoration(
        isDense: true,  
        disabledBorder: InputBorder.none,
        contentPadding: EdgeInsets.symmetric(vertical: 4),
      ),
      textAlign: widget.lineNumberStyle.textAlign,
    );

    final numberCol = Container(
      width: (((_numberController?.text ?? '\n').split('\n')).last.toString().length + 1) * widget.lineNumberStyle.width,
      padding: EdgeInsets.only(
        left: widget.padding.left,
        right: widget.lineNumberStyle.margin / 2,
      ),
      color: widget.lineNumberStyle.background,
      child: lineNumberCol,
    );

    final codeField = TextField(
      focusNode: _focusNode,
      scrollPadding: widget.padding,
      style: textStyle,
      controller: widget.controller,
      minLines: widget.minLines,
      maxLines: widget.maxLines,
      scrollController: _codeScroll,
      decoration: InputDecoration(
        isDense: true,  
        enabledBorder: InputBorder.none,
        disabledBorder: InputBorder.none,
        border: InputBorder.none,
        focusedBorder: InputBorder.none,
        contentPadding: EdgeInsets.symmetric(vertical: 4),
      ),
      cursorColor: cursorColor,
      autocorrect: false,
      enableSuggestions: false,
      enabled: widget.controller.enabled,
      onChanged: widget.onChanged,
    );

    final codeCol = Theme(
      data: Theme.of(context).copyWith(
        textSelectionTheme: widget.textSelectionTheme,
      ),
      child: widget.wrap ? codeField : _wrapInScrollView(codeField)
    );

    return Container(
      padding: EdgeInsets.fromLTRB(10, 0, 0, 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          numberCol,
          Expanded(child: codeCol),
        ],
      ),
    );
  }
}
