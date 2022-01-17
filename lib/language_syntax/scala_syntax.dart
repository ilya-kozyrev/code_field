void findScalaErrors(String text) {
  List<String> lines = text.split("\n");
  List<int> errorLines = [];
  int indentLevel = 0;

  for (int i = 0; i < lines.length; i++) {

    if (lines[i].trim().isEmpty ||
        lines[i].startsWith(RegExp("\\s*//"))) {
      continue;
    }
    if (lines[i].startsWith(RegExp("\\s*/\\*"))) {
      while (
      (!lines[i].contains(RegExp("\\*/\\s*"))) && (i < lines.length)) {
        i++;
        lines[i] = lines[i];
      }
    }
    
    if (lines[i].contains(RegExp(":\\s*="))) {
      errorLines.add(i);
    }

    if (lines[i].contains(RegExp("\\s*def\\s*"))) {
      while (!lines[i].contains(RegExp("[^<>!=]=[^<>!=]"))) {
        i++;
      }
      if (!lines[i].contains(RegExp("\\(.*\\):"))) {
        errorLines.add(i);
      }
    }

    if (lines[i].trim().endsWith("}")) {
      indentLevel--;
    }

    for (int countOfSpace = 0; countOfSpace < lines[i].length; countOfSpace++) {
      if (lines[i][countOfSpace] != " ") {
        if (countOfSpace / 2 != indentLevel) {
          errorLines.add(i);
        }
        break;
      }
    }

    if (lines[i].trim().endsWith("{")) {
      indentLevel++;
    }
  }

  print("$errorLines - scala");
}
