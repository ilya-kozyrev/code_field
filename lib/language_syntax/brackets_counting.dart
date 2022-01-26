const brackets = {'(': ')', '{': '}', '[': ']'};

Map<int, String> countingBrackets(String text) {
  int lineNumber = 1;
  String stackBrackets = "";
  Map<int, String> errors = {};
  bool isCharInString = false;
  bool isShieldingInString = false;
  String openQuote = "";

  for (int i = 0; i < text.length; i++) {
    String char = text[i];

    if (char == "\n") {
      lineNumber++;
      continue;
    } else if ((char == "'") | (char == "\"")) {
      if (openQuote == "") {
        openQuote = char;
      } else if ((openQuote == char) &&
          isCharInString &&
          ((i - 2) >= 0) &&
          ((text[i - 1] != "\\") || (text[i-2] == "\\"))) {
        openQuote = "";
      } else {
        continue;
      }
      if (((i + 2) < text.length) &&
          (text[i] == text[i + 1]) &&
          (text[i + 1] == text[i + 2])) {
        i = i + 2;
      }
      if (isCharInString) {
        isCharInString = false;
      } else {
        isCharInString = true;
      }
    } else if ((char == "\$") &&
        ((i + 1) < text.length) &&
        (text[i + 1] == "{") &&
        isCharInString) {
      isShieldingInString = true;
      isCharInString = false;
      i++;
    } else if (isShieldingInString && (char == "}")) {
      isShieldingInString = false;
      isCharInString = true;
    } else if (isCharInString) {
      continue;
    } else if ((char == "(") | (char == "[") | (char == "{")) {
      stackBrackets = stackBrackets + char;
    } else if ((char == ")") | (char == "]") | (char == "}")) {
      if (stackBrackets == "") {
        if (errors.containsKey(lineNumber)) {
          errors[lineNumber] = errors[lineNumber]! + "\n" + "Unexpected symbol";
        } else {
          errors.addAll({lineNumber: "Unexpected symbol"});
        }
      } else if (char != brackets[stackBrackets[stackBrackets.length - 1]]) {
        if (errors.containsKey(lineNumber)) {
          errors[lineNumber] = errors[lineNumber]! +
              "\n" +
              "Expected to find '${brackets[stackBrackets[stackBrackets.length - 1]]}', but founded $char";
        } else {
          errors.addAll({
            lineNumber:
                "Expected to find '${brackets[stackBrackets[stackBrackets.length - 1]]}', but founded $char"
          });
        }
      } else {
        stackBrackets = stackBrackets.substring(0, stackBrackets.length - 1);
      }
    }
  }

  if (stackBrackets.isNotEmpty) {
    if (errors.containsKey(lineNumber)) {
      errors[lineNumber] = errors[lineNumber]! + "\n" + "Missing bracket";
    } else {
      errors.addAll({lineNumber: "Missing bracket"});
    }
  }

  return errors;
}
