import 'package:flutter/material.dart';

import 'code_text_field.dart';
import 'constants/themes.dart';
import '/languages/all.dart';
import 'src/code_modifier.dart';

class CodeEditor extends StatefulWidget {
  final String language;
  final String theme;
  final Map<String, TextStyle>? patternMap;
  final Map<String, TextStyle>? stringMap;
  final EditorParams params;
  final List<CodeModifier> modifiers;
  final bool webSpaceFix;
  final void Function(String)? onChange;
  
  final int? minLines;
  final int? maxLines;
  final bool wrap;
  final LineNumberStyle lineNumberStyle;
  final Color? cursorColor;
  final TextStyle? textStyle;
  final TextSpan Function(int, TextStyle?)? lineNumberBuilder;
  final void Function(String)? onChanged;
  final Color? background;
  final EdgeInsets padding;
  final Decoration? decoration;
  final TextSelectionThemeData? textSelectionTheme;
  final FocusNode? focusNode;

  const CodeEditor({
    Key? key, 
    required this.language, 
    required this.theme,
    this.patternMap,
    this.stringMap,
    this.params = const EditorParams(),
    this.modifiers = const <CodeModifier>[
      const IntendModifier(),
      const CloseBlockModifier(),
      const TabModifier(),
    ],
    this.webSpaceFix = true,
    this.onChange,

    this.minLines,
    this.maxLines,
    this.wrap = false,
    this.background,
    this.decoration,
    this.textStyle,
    this.padding = const EdgeInsets.symmetric(),
    this.lineNumberStyle = const LineNumberStyle(),
    this.cursorColor,
    this.textSelectionTheme,
    this.lineNumberBuilder,
    this.focusNode,
    this.onChanged,
  })
    : super(key: key);

  @override
  CodeEditorState createState() => CodeEditorState();
}

class CodeEditorState extends State<CodeEditor> {
  CodeController? codeController;

  @override
  void initState() {
    super.initState();
    codeController = CodeController(
      language: allLanguages[widget.language],
      theme: THEMES[widget.theme],
      patternMap: widget.patternMap,
      stringMap: widget.stringMap,
      params: widget.params,
      modifiers: widget.modifiers,
      webSpaceFix: widget.webSpaceFix,
      onChange: widget.onChange,
    );
  }

  @override
  void dispose() {
    codeController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Color? backgroundColor = widget.decoration == null ? (widget.background ?? 
                                      codeController?.theme?['root']?.backgroundColor ?? Colors.grey.shade900) : null;

    return 
        Container(
          color: backgroundColor,
          padding: EdgeInsets.symmetric(vertical: 15),
          child: ListView(
            children: [ CodeField(
              controller: codeController!,
              background: backgroundColor,
            )
            ]
          )
        );
  }
}