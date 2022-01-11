// Обработка отступов с учетом комментариев и мультистрок.
void findPythonErrorTabs(String text) {
  List<String> lines = text.split("\n");
  List<int> errorLines = [];
  bool isPreviousLineContainsColon = false;
  int previousCountOfSpace = 0;

  for (int i = 0; i < lines.length; i++) {
    int lineLength = lines[i].length;
    int countOfSpace = 0;

    if (lines[i].trim().isEmpty || lines[i].startsWith(RegExp("\\s*#"))) {
      continue;
    }

    if (lines[i].startsWith(RegExp(".*'''"))) {
      do {
        i++;
      } while ((!lines[i].contains(RegExp("'''"))) && (i < lines.length));
    } else if (lines[i].startsWith(RegExp(".*\"\"\""))) {
      do {
        i++;
      } while ((!lines[i].contains(RegExp("\"\"\""))) && (i < lines.length));
    }

    while (lines[i][countOfSpace] == " " && (countOfSpace < lineLength)) {
      countOfSpace++;
    }

    if (isPreviousLineContainsColon == true &&
        previousCountOfSpace == countOfSpace) {
      errorLines.addAll([i, i + 1]);
    }

    previousCountOfSpace = countOfSpace;

    if ((lineLength > 2) && (lines[i][lineLength - 1] == ":")) {
      isPreviousLineContainsColon = true;
    } else {
      isPreviousLineContainsColon = false;
    }
  }

  print("$errorLines - python");
}
