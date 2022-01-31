/* Search for syntax errors for java and dart : indentation errors.
 Including comments, strings. */

Map<int, String> findGolangErrors(String text) {
  List<String> lines = text.split("\n");
  Map<int, String> errors = {};
  int indentLevel = 0;

  for (int i = 0; i < lines.length; i++) {
    String currentLine = lines[i];

    if (currentLine.trim().isEmpty ||
        currentLine.startsWith(RegExp("\\s*//"))) {
      continue;
    }

    if (currentLine.startsWith(RegExp("\\s*/\\*"))) {
      while ((!currentLine.contains(RegExp("\\*/\\s*"))) &&
          (i < lines.length - 1)) {
        i++;
        currentLine = lines[i];
      }
    } else if (currentLine.startsWith(RegExp(".*`"))) {
      do {
        i++;
        currentLine = lines[i];
      } while ((!currentLine.contains(RegExp("`"))) && (i < lines.length - 1));
    }

    if (currentLine.trim().endsWith("}") ||
        currentLine.contains(RegExp("}\\s*//"))) {
      indentLevel--;
    }

    for (int countOfSpace = 0;
        countOfSpace < currentLine.length;
        countOfSpace++) {
      if (currentLine[countOfSpace] != " ") {
        if (countOfSpace / 4 != indentLevel) {
          errors.addAll({(i + 1): "error in indents"});
        }
        break;
      }
    }

    if (currentLine.trim().endsWith("{") ||
        currentLine.contains(RegExp("{\\s*//"))) {
      indentLevel++;
    }
  }
  return errors;
}