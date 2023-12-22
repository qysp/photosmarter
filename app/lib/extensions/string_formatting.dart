extension Formatting on String {
  String capitalize() {
    return replaceFirst(this[0], this[0].toUpperCase());
  }
}
