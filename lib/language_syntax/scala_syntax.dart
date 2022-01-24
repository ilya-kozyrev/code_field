Map<int, String> findScalaErrors(String text) {
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
        lines[i] = lines[i];
      }
    }

    if (lines[i].contains(RegExp(":\\s*="))) {
      errors.addAll({(i + 1): "Missing type"});
    }

    if (lines[i].contains(RegExp("\\s*def\\s*"))) {
      while (!lines[i].contains(RegExp("[^<>!=]*=[^<>!=]*"))) {
        i++;
      }
      if (!lines[i].contains(RegExp("\\(.*\\):"))) {
        errors.addAll({(i + 1): "Missing ':' in def statement"});
      }
    }

    if (lines[i].trim().endsWith("}")) {
      indentLevelBrace--;
    }

    for (int countOfSpace = 0; countOfSpace < lines[i].length; countOfSpace++) {
      if (lines[i][countOfSpace] != " ") {
        if (countOfSpace / 2 != (indentLevelBrace + indentLevelBracket)) {
          print("$countOfSpace $indentLevelBrace $indentLevelBracket");
          errors.addAll({(i + 1): "error in indents"});
        }
        break;
      }
    }

    if (lines[i].trim().endsWith(")") &&
        !lines[i].contains(RegExp("\\(.*\\)"))) {
      indentLevelBracket--;
    }

    if (lines[i].trim().endsWith("{")) {
      indentLevelBrace++;
    } else if (lines[i].trim().endsWith("(")) {
      indentLevelBracket++;
    }
  }

  return errors;
}
