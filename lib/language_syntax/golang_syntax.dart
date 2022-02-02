/* Search for syntax errors for java and dart : indentation errors.
 Including comments, strings. */

Map<int, String> findGolangErrors(String text) {
  List<String> lines = text.split("\n");
  Map<int, String> errors = {};

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
  }
  return errors;
}
