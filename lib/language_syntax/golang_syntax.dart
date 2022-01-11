// Обработка правильности отступов, точек с запятой для цикла for
// с учетом комментариев, с учетом строк.
void findGolangErrors(String text) {
  List<String> lines = text.split("\n");
  List<int> errorLines = [];
  int indentLevel = 0;

  for (int i = 0; i < lines.length; i++) {
    String currentLine = lines[i];

    if (currentLine.trim().isEmpty ||
        currentLine.startsWith(RegExp("\\s*//"))) {
      continue;
    }

    if (currentLine.startsWith(RegExp("\\s*/\\*"))) {
      while (
          (!currentLine.contains(RegExp("\\*/\\s*"))) && (i < lines.length)) {
        i++;
        currentLine = lines[i];
      }
    } else if (currentLine.startsWith(RegExp(".*`"))) {
      do {
        i++;
        currentLine = lines[i];
      } while ((!currentLine.contains(RegExp("`"))) && (i < lines.length));
    }

    if (currentLine.trim().endsWith("}")) {
      indentLevel--;
    }

    for (int countOfSpace = 0;
        countOfSpace < currentLine.length;
        countOfSpace++) {
      if (currentLine[countOfSpace] != " ") {
        if (countOfSpace / 4 != indentLevel) {
          errorLines.add(i);
        }
        break;
      }
    }

    if (currentLine.trim().endsWith("{")) {
      indentLevel++;
    }

    if (currentLine.startsWith(RegExp("\\s*for")) &&
        !currentLine.contains(RegExp("for.*[;].*[;].*")) &&
        currentLine.contains(";") &&
        !currentLine.contains(RegExp("\".*for.*[;].*[;].*\"")) &&
        !currentLine.contains(RegExp("'.*for.*[;].*[;].*'"))) {
      errorLines.add(i);
    }
  }
  print("$errorLines - golang");
}
