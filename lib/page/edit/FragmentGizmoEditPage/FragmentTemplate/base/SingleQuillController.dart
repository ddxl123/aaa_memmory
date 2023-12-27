import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill/quill_delta.dart';

/// 封装好的控制器。
class SingleQuillController {
  final quillController = QuillController.basic();
  final scrollController = ScrollController();
  final focusNode = FocusNode();

  void dispose() {
    focusNode.dispose();
    quillController.dispose();
    scrollController.dispose();
  }

  String _getContentJsonString() => jsonEncode(quillController.document.toDelta().toJson());

  String? getContentJsonStringOrNull() => isContentEmpty() ? null : _getContentJsonString();

  String transferToTitle() => quillController.document.toDelta().first.value.toString().trim().split("\n").first;

  bool isContentEmpty() => jsonEncode(quillController.document.toDelta().toJson()) == jsonEncode(Document().toDelta().toJson());

  bool equalFromJsonString({required String? jsonString}) => getContentJsonStringOrNull() == jsonString;

  /// 存储的 [quillController] 内容本身就是以 [String] 类型存储的，因此输入的 [jsonString] 是 [String] 类型，并且会用 [jsonDecode] 进行转换。
  void resetContent(String? jsonString) {
    quillController.clear();
    quillController.document = jsonString == null ? Document() : Document.fromJson(jsonDecode(jsonString));
  }
}
