import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:code_text_field/code_editor.dart';
import 'package:code_text_field/constants/constants.dart';

Future<String> loadBlockSettings() async{
  return await rootBundle.loadString('assets/settings/blockSettings.json');
}

Future<String> loadRefactorSettings() async{
  return await rootBundle.loadString('assets/settings/autoRefactoringSettings.json');
}

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
    java,
    go,
    python,
    scala,
    dart
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
      icon: Icon(Icons.delete, color: Colors.white), 
      label: Text('Reset', style: TextStyle(color: Colors.white)),
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
        Spacer(flex: 2),
        Text('Code editor', style: TextStyle(fontSize: 28, color: Colors.white)),
        Spacer(flex: 35),
        codeDropdown,
        Spacer(),
        themeDropdown,
        Spacer(),
        resetButton
        ]
      )
    );

    Widget codeField(String blocks, String refactorSettings) => CodeEditor(
      key: ValueKey("$language - $theme - $reset"),
      language: language!,
      theme: theme!,
      blocks: blocks,
      refactorSettings: refactorSettings,
      autoRefactoringButton: true,
    );

    return FutureBuilder<List<String>>(
      future: Future.wait([loadBlockSettings(), loadRefactorSettings()]),
      builder: (context, AsyncSnapshot<List<String>> async) {
        if (async.connectionState == ConnectionState.done) {
          if (async.hasError) {
            return Center(
              child: Text("ERROR"),
            );
          } 
          else if (async.hasData) {
            String blocks = async.data![0];
            String refactorSettings = async.data![1];
            return Column(
              children: [
                buttons,
                codeField(blocks, refactorSettings),
              ]
            );
          }
        }
        return Center(
          child: CircularProgressIndicator(),
        );
      }
    );
  }
}
