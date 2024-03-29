import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:tools/src/dialog/DialogWidget.dart';
import 'package:tools/src/dialog/OkAndCancelDialogWidget.dart';
import 'package:tools/src/dialog/TextField1DialogWidget.dart';

/// [builder] 请使用：
///  - [DialogWidget]
///  - [OkAndCancelDialogWidget]
///  - [TextField1DialogWidget]
///  ...
Future<void> showCustomDialog({
  Widget Function(BuildContext context)? builder,
  Widget Function(BuildContext context, void Function(void Function()))? stfBuilder,
  bool clickMaskDismiss = true,
  bool backDismiss = true,
}) async {
  return await SmartDialog.show(
    clickMaskDismiss: clickMaskDismiss,
    backDismiss: backDismiss,
    useSystem: true,
    maskColor: Colors.black.withOpacity(0.2),
    builder: (_) => stfBuilder == null ? builder!(_) : StatefulBuilder(builder: (ctx, r) => stfBuilder.call(ctx, r)),
  );
}
