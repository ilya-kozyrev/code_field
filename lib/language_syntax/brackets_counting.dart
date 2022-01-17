const brackets = {'(': ')', '{': '}', '[': ']'};

Map<int, String> countingBrackets(String text) {
  int lineNumber = 1;
  String stackBrackets = "";
  Map<int, String> errors = {};

  for (int i = 0; i < text.length; i++) {
    if (text[i] == "\n") {
      lineNumber++;
    }

    if ((text[i] == "(") | (text[i] == "[") | (text[i] == "{")) {
      stackBrackets = stackBrackets + text[i];
    }

    if ((text[i] == ")") | (text[i] == "]") | (text[i] == "}")) {
      if (stackBrackets == "") {
        errors.addAll({lineNumber: "Unexpected symbol"});
      } else if (text[i] != brackets[stackBrackets[stackBrackets.length - 1]]) {
        errors.addAll({
          lineNumber:
              "Expected to find '${brackets[stackBrackets[stackBrackets.length - 1]]}', but founded ${text[i]}"
        });
      } else {
        stackBrackets = stackBrackets.substring(0, stackBrackets.length - 1);
      }
    }
  }
  return errors;
}
