import 'dart:convert';

import 'themes.dart';
import 'autoRefactorService.dart';
import 'package:flutter/material.dart';
import 'code_text_field.dart';
import 'package:highlight/languages/all.dart';
import 'blocksSettings.dart' as blocksSettings;

class CustomCodeBox extends StatefulWidget {
  final String language;
  final String theme;

  const CustomCodeBox({Key? key, required this.language, required this.theme})
      : super(key: key);

  @override
  _CustomCodeBoxState createState() => _CustomCodeBoxState();
}

class _CustomCodeBoxState extends State<CustomCodeBox> {
  String? language;
  String? theme;
  bool? reset;

  @override
  void initState() {
    super.initState();
    language = widget.language;
    theme = widget.theme;
    reset = false;
  }

  List<String?> languageList = <String>[
    "java",
    "go",
    "python",
    "scala",
    "dart"
  ];

  List<String?> themeList  = <String>[
    "monokai-sublime",
    "a11y-dark",
    "an-old-hope",
    "vs2015",
    "vs",
    "atom-one-dark"
  ];

  Widget buildDropdown(Iterable<String?> choices, String value, IconData icon,
      Function(String?) onChanged) {
    return DropdownButton<String>(
      value: value,
      items: choices.map((String? value) {
        return DropdownMenuItem<String>(
          value: value,
          child: value == null
              ? const Divider()
              : Text(value, style: const TextStyle(color: Colors.white)),
        );
      }).toList(),
      icon: Icon(icon, color: Colors.white),
      onChanged: onChanged,
      dropdownColor: Colors.black87,
    );
  }

  @override
  Widget build(BuildContext context) {
    final codeDropdown =
        buildDropdown(languageList, language!, Icons.code, (val) {
      if (val == null) return;
      setState(() => language = val);
    });
    final themeDropdown =
        buildDropdown(themeList, theme!, Icons.color_lens, (val) {
      if (val == null) return;
      setState(() => theme = val);
    });
    final resetButton = TextButton.icon(
      icon: const Icon(Icons.delete, color: Colors.white), 
      label: const Text('Reset', style: TextStyle(color: Colors.white)),
      onPressed: () {
        setState(() {
          reset = (!reset!);
        });
      }, 
    );

    final buttons = Container (
      height: MediaQuery.of(context).size.height/13,
      color: Colors.deepPurple[900],
      child: Row(
        children: [
        SizedBox(width: 25.0),
        Text('Code editor', style: TextStyle(fontSize: 28, color: Colors.white),),
        SizedBox(width: 510.0),
        codeDropdown,
        SizedBox(width: 12.0),
        themeDropdown,
        SizedBox(width: 12.0),
        resetButton
        ]
      )
    );
    final codeField = InnerField(
      key: ValueKey("$language - $theme - $reset"),
      language: language!,
      theme: theme!,
    );
    return Column(children: [
      buttons,
      codeField,
    ]);
  }
}

class InnerField extends StatefulWidget {
  final String language;
  final String theme;

  const InnerField({Key? key, required this.language, required this.theme})
      : super(key: key);

  @override
  _InnerFieldState createState() => _InnerFieldState();
}

class _InnerFieldState extends State<InnerField> {
  List<CodeController?> _codeControllers = [];
  List<int> sumStrBeforeBlock = [];

  _changeNumber(){
    setState(() { 
      for (int i = 1; i <  _codeControllers.length; i++) {
        int sumTextStrPrevBlock =  _codeControllers[i - 1]!.text.split('\n').length;
        sumStrBeforeBlock[i] = sumStrBeforeBlock[i-1] + sumTextStrPrevBlock;
        _codeControllers[i]!.stringsNumber = sumStrBeforeBlock[i];
        
      }
    });
  }

  @override
  void initState() {
    super.initState();
    sumStrBeforeBlock.add(0);
    Map<String, dynamic> blocks = jsonDecode(blocksSettings.settings);
    List<dynamic> blockList = blocks['blocks'];
    for (int i = 0; i < blockList.length; i++) {
      _codeControllers.add( CodeController(
        text: blockList[i]['text'],
        language: allLanguages[widget.language],
        theme: THEMES[widget.theme],
        stringsNumber: sumStrBeforeBlock[i],
        enabled: blockList[i]['enabled']!.toLowerCase() == 'true'
      ));
      sumStrBeforeBlock.add(sumStrBeforeBlock[i] +  blockList[i]['text']!.split('\n').length as int);
      _codeControllers[i]!.addListener(_changeNumber);
    }
  }

  @override
  void dispose() {
    for (int i = 0; i <  _codeControllers.length; i++) {
      _codeControllers[i]?.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    Widget blockOfCode(int index){
      return Container(
        key: ValueKey("${sumStrBeforeBlock[index]}"),
        child: CodeField(
          controller: _codeControllers[index]!,
          textStyle: const TextStyle(fontFamily: 'SourceCode'),
        )
      );
    }

    return Container(
      color: _codeControllers[0]!.theme!['root']!.backgroundColor,
      height: MediaQuery.of(context).size.height / 13 * 12,
      child: Stack(
        children: [
          ListView.builder(
            itemCount: _codeControllers.length,
            itemBuilder: (BuildContext context, int index){
              return blockOfCode(index);
            }
          ),
          Align(
            alignment: Alignment.topRight,
            child: FloatingActionButton(
              child: const Icon(Icons.format_align_left_outlined),
              backgroundColor: Colors.purple[700],
              onPressed: (){
                setState(() {
                  for (int i = 0; i <  _codeControllers.length; i++) {
                    if (_codeControllers[i]!.enabled) {
                      _codeControllers[i]!.text = autoRefactor( _codeControllers[i]!.text, widget.language);
                    }
                  }
                });
              }
            )
          )
        ]
      )
    );
  }
}