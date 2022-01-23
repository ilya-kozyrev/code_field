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
        if (errors.containsKey(lineNumber)) {
          errors[lineNumber] = errors[lineNumber]! + "\n" + "Unexpected symbol";
        } else {
          errors.addAll({lineNumber: "Unexpected symbol"});
        }
      } else if (text[i] != brackets[stackBrackets[stackBrackets.length - 1]]) {
        if (errors.containsKey(lineNumber)) {
          errors[lineNumber] = errors[lineNumber]! +
              "\n" +
              "Expected to find '${brackets[stackBrackets[stackBrackets.length - 1]]}', but founded ${text[i]}";
        } else {
          errors.addAll({
            lineNumber:
                "Expected to find '${brackets[stackBrackets[stackBrackets.length - 1]]}', but founded ${text[i]}"
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
    }
    else {
      errors.addAll({lineNumber : "Missing bracket"});
    }
  }

  return errors;
}
