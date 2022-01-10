class PopupController {
  late List<String> suggestions;
  late int selectedItem;
  bool isPopupShown = false;
  late double height;
  late double width;

  void show(List<String> suggestions) {
    this.suggestions = suggestions;
    isPopupShown = true;
  }

  void hide() {
    isPopupShown = false;
  }
}
