void outer() {
  final x = helper(3);
  int helper(int a) {
    return a * 2;
  }
}
