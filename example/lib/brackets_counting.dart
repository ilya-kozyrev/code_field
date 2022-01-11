const brackets = {'(': ')', '{': '}', '[': ']'};

void errorLine() {
  print('error');
}

void countingBrackets(String text) {
  String stackBrackets = "";

  for (int i = 0; i < text.length; i++) {
    if ((text[i] == "(") | (text[i] == "[") | (text[i] == "{")) {
      stackBrackets = stackBrackets + text[i];
    }

    if ((text[i] == ")") | (text[i] == "]") | (text[i] == "}")) {
      if (stackBrackets == "") {
        errorLine();
      } else if (text[i] != brackets[stackBrackets[stackBrackets.length - 1]]) {
        errorLine();
      } else {
        stackBrackets = stackBrackets.substring(0, stackBrackets.length - 1);
      }
    }
  }
}
