/* Search for syntax errors for java and dart : indentation errors.
 Including comments, strings. */

Map<int, String> findGolangErrors(String text) {
  List<String> lines = text.split("\n");
  Map<int, String> errors = {};
  int indentLevelBrace = 0;
  int indentLevelBracket = 0;

  for (int i = 0; i < lines.length; i++) {
    if (lines[i].trim().isEmpty || lines[i].startsWith(RegExp("\\s*//"))) {
      continue;
    }

    if (lines[i].startsWith(RegExp("\\s*/\\*"))) {
      while ((!lines[i].contains(RegExp("\\*/\\s*"))) && (i < lines.length - 1)) {
        i++;
      }
    } else if (lines[i].startsWith(RegExp(".*`"))) {
      do {
        i++;
      } while ((!lines[i].contains(RegExp("`"))) && (i < lines.length - 1));
    }

    if ((lines[i].trim().endsWith("}") || lines[i].contains(RegExp("}\\s*//"))) &&
        (indentLevelBrace != 0)) {
      indentLevelBrace--;
    } else if ((lines[i].trim().endsWith(")") || lines[i].contains(RegExp("\\)\\s*//"))) &&
        (indentLevelBracket != 0)) {
      indentLevelBracket--;
    }

    for (int countOfSpace = 0; countOfSpace < lines[i].length; countOfSpace++) {
      if (lines[i][countOfSpace] != " ") {
        if (countOfSpace / 4 != indentLevelBrace + indentLevelBracket) {
          errors.addAll({(i + 1): "error in indents"});
        }
        break;
      }
    }

    if (lines[i].trim().endsWith("{") || lines[i].contains(RegExp("{\\s*//"))) {
      indentLevelBrace++;
    } else if (lines[i].trim().endsWith("(") || lines[i].contains(RegExp("\\(\\s*//"))) {
      indentLevelBracket++;
    }
  }
  return errors;
}
