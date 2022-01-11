// Обработка точек с запятой для цикла for,
// без учета комментариев и мультистрок.

void findJavaDartErrors(String text) {
  List<String> lines = text.split("\n");
  List<int> errorLines = [];

  for (int i = 0; i < lines.length; i++) {
    // ignore comments
    if (lines[i].trim().startsWith("//")) {
      continue;
    }
    if (lines[i].startsWith(RegExp("\\s*/\\*"))) {
      while ((!lines[i].contains(RegExp("\\*/\\s*"))) && (i < lines.length)) {
        i++;
      }
    }

    // errors with identifier and missing semicolon
    if (lines[i].contains(RegExp("[^<>!=]=[^<>!=]")) &&
        !lines[i].contains(";")) {
      String command = lines[i];
      while (!lines[i].trim().endsWith(";")) {
        i++;
        command += lines[i];
      }
      if (command.contains(RegExp("=\\s*;"))){
        errorLines.add(i);
      }

    } else if (lines[i].contains(RegExp("=\\s*;"))) {
      errorLines.add(i);
    }
    // errors with for in one line
    if (lines[i].contains(RegExp("for\\s*\\(")) &&
        !lines[i].contains(RegExp("for.*\\(.*;.*;.*\\)"))) {
      errorLines.add(i);
    }
  }

  print("$errorLines - java/dart");
}

bool isLineHasKeyword(String line) {
  List<String> keywords = ["for", "if", "while"];
  for (String keyword in keywords) {
    if (line.contains(keyword)) {
      return true;
    }
  }
  return false;
}
