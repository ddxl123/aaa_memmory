import 'package:aaa_memory/page/edit/FragmentGizmoEditPage/FragmentTemplate/base/SingleQuillController.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:tools/tools.dart';

class SingleQuillEditor1Page extends StatefulWidget {
  const SingleQuillEditor1Page({
    super.key,
    this.singleQuillController,
    required this.isEditable,
    this.appBarCallback,
    required this.initJsonString,
    required this.backListener,
  });

  final SingleQuillController? singleQuillController;
  final bool isEditable;
  final String? initJsonString;
  final PreferredSizeWidget Function(SingleQuillEditor1PageState state)? appBarCallback;
  final Future<bool> Function(SingleQuillEditor1PageState state, bool hasRoute) backListener;

  @override
  State<SingleQuillEditor1Page> createState() => SingleQuillEditor1PageState();
}

class SingleQuillEditor1PageState extends State<SingleQuillEditor1Page> with AbBackListener {
  late final SingleQuillController singleQuillController;

  @override
  void initState() {
    super.initState();
    attachBack(context: context);
    singleQuillController = widget.singleQuillController ?? SingleQuillController();
    singleQuillController.resetContent(widget.initJsonString);
  }

  @override
  void dispose() {
    super.dispose();
    detachBack();
  }

  @override
  Future<bool> backListener(bool hasRoute) async => await widget.backListener(this, hasRoute);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: widget.appBarCallback?.call(this),
      body: Padding(
        padding: EdgeInsets.all(10),
        child: QuillEditor(
          scrollController: singleQuillController.scrollController,
          focusNode: singleQuillController.focusNode,
          configurations: QuillEditorConfigurations(
            placeholder: "请输入...",
            customStyles: DefaultStyles(
              placeHolder: DefaultTextBlockStyle(
                const TextStyle(color: Colors.grey),
                const VerticalSpacing(0, 0),
                const VerticalSpacing(0, 0),
                const BoxDecoration(),
              ),
            ),
            controller: singleQuillController.quillController,
            readOnly: !widget.isEditable,
            showCursor: widget.isEditable,
            autoFocus: false,
            expands: false,
            padding: const EdgeInsets.all(0),
            scrollable: true,
          ),
        ),
      ),
      bottomSheet: QuillToolbar.simple(
        configurations: QuillSimpleToolbarConfigurations(
          controller: singleQuillController.quillController,
          multiRowsDisplay: false,
        ),
      ),
    );
  }
}
