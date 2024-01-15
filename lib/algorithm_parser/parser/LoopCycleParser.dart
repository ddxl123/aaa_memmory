class LoopCycleParser {
  LoopCycleParser._();

  static List<int> toList({required String text}) {
    return text.split(" ").where((element) => element.trim() != "").map((e) => int.parse(e)).toList();
  }

  /// 返回 false 表示文本格式不正确。
  ///
  /// 返回 null，表示 [text] 为 null。
  static bool? verifyLoopCycle(String? text) {
    if (text == null) {
      return null;
    }
    final list = text.split(" ")..removeWhere((element) => element.trim().isEmpty);
    if (list.isEmpty) {
      return null;
    }
    for (var value in list) {
      final result = double.tryParse(value);
      if (result == null) {
        return false;
      }
    }
    return true;
  }
}
