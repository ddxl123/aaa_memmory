import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';

import '../../tools.dart';

/// 请结合 [showCustomDialog] 使用。
///
/// 带有一个 [TextField] 的对话框。
class TextField1DialogWidget extends StatefulWidget {
  const TextField1DialogWidget({
    super.key,
    this.title,
    this.text,
    required this.cancelText,
    required this.okText,
    this.mainVerticalColumns,
    this.onOk,
    this.onCancel,
    this.dialogSize,
    this.textEditingController,
    this.inputDecoration = const InputDecoration(),
    this.inputFormatters,
    this.keyboardType,
    this.autoFocus = false,
    this.topRightAction,
    this.okTextStyle,
    this.isRemoveOkTextStyle = false,
    this.isHideTextField = false,
  });

  final String? title;
  final String? text;
  final String cancelText;
  final String okText;
  final List<Widget>? mainVerticalColumns;
  final InputDecoration inputDecoration;
  final TextEditingController? textEditingController;
  final FutureOr<void> Function(TextEditingController tec)? onOk;
  final FutureOr<void> Function()? onCancel;
  final DialogSize? dialogSize;
  final List<TextInputFormatter>? inputFormatters;
  final TextInputType? keyboardType;
  final bool autoFocus;
  final Widget? topRightAction;
  final TextStyle? okTextStyle;
  final bool isRemoveOkTextStyle;
  final bool isHideTextField;

  @override
  State<TextField1DialogWidget> createState() => _TextField1DialogWidgetState();
}

class _TextField1DialogWidgetState extends State<TextField1DialogWidget> {
  late final TextEditingController textEditingController;

  @override
  void initState() {
    textEditingController = widget.textEditingController ?? TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    textEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DialogWidget(
      title: widget.title,
      dialogSize: widget.dialogSize,
      topRightAction: widget.topRightAction,
      mainVerticalWidgets: [
        ...[
          widget.text == null ? Container() : const SizedBox(height: 10),
          widget.text == null
              ? Container()
              : Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [Expanded(child: Text(widget.text!))],
                ),
        ],
        ...widget.mainVerticalColumns ?? [],
        widget.isHideTextField
            ? Container()
            : Row(
                children: [
                  Expanded(
                    child: TextField(
                      maxLines: 10,
                      minLines: 1,
                      controller: textEditingController,
                      focusNode: widget.autoFocus ? (FocusNode()..requestFocus()) : FocusNode(),
                      decoration: widget.inputDecoration,
                      inputFormatters: widget.inputFormatters,
                      keyboardType: widget.keyboardType,
                    ),
                  ),
                ],
              ),
      ],
      bottomHorizontalButtonWidgets: [
        const SizedBox(width: 50),
        TextButton(
          child: Text(widget.cancelText),
          onPressed: () async {
            if (widget.onCancel == null) {
              SmartDialog.dismiss(status: SmartStatus.dialog);
            } else {
              await widget.onCancel?.call();
            }
          },
        ),
        const SizedBox(width: 10),
        TextButton(
          child: Text(
            widget.okText,
            style: widget.isRemoveOkTextStyle ? null : (widget.okTextStyle ?? const TextStyle(color: Colors.red)),
          ),
          onPressed: () async {
            // TODO: 输入空字符后点击确定，会抛出异常。
            await widget.onOk?.call(textEditingController);
          },
        ),
      ],
    );
  }
}
