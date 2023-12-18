import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:tools/tools.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../edit_page_type.dart';
import 'CurrentCircleWidget.dart';
import 'MemoryGroupGizmoEditPageAbController.dart';

class MemoryGroupGizmoEditPage extends StatelessWidget {
  const MemoryGroupGizmoEditPage({super.key, required this.editPageType, required this.memoryGroupId});

  final int memoryGroupId;
  final MemoryGroupGizmoEditPageType editPageType;

  @override
  Widget build(BuildContext context) {
    return AbBuilder<MemoryGroupGizmoEditPageAbController>(
      putController: MemoryGroupGizmoEditPageAbController(memoryGroupId: memoryGroupId),
      builder: (putController, putAbw) {
        return DialogWidget(
          fullPadding: EdgeInsets.zero,
          topKeepWidget: Row(
            children: [
              _appBarLeadingWidget(),
              const Spacer(),
              _appBarRightButtonWidget(),
            ],
          ),
          mainVerticalWidgets: const [
            CurrentCircleWidget(),
          ],
          bottomHorizontalButtonWidgets: [],
          stackChildren: [
            Positioned(
              bottom: 10,
              child: _floatingActionButton(),
            ),
          ],
        );
        // return Scaffold(
        //   body: const CurrentCircleWidget(),
        //   floatingActionButton: _floatingActionButton(),
        //   floatingActionButtonLocation: FloatingRoundCornerButtonLocation(context: context, offset: const Offset(0, -30)),
        // );
      },
    );
  }

  Widget _floatingActionButton() {
    return AbBuilder<MemoryGroupGizmoEditPageAbController>(
      builder: (c, abw) {
        if (c.fragmentAndMemoryInfoStatus(abw) == FragmentAndMemoryInfoStatus.zero) {
          return FloatingRoundCornerButton(
            color: Colors.amberAccent,
            text: const Text('未添加碎片', style: TextStyle(color: Colors.grey)),
            onPressed: () {
              SmartDialog.showToast("请先添加想要记忆的碎片！");
            },
          );
        }
        if (c.fragmentAndMemoryInfoStatus(abw) == FragmentAndMemoryInfoStatus.neverDownloaded) {
          return FloatingRoundCornerButton(
            color: Colors.grey,
            text: const Text('未下载碎片', style: TextStyle(color: Colors.white)),
            onPressed: () async {
              await showCustomDialog(
                builder: (ctx) => OkAndCancelDialogWidget(
                  text: "是否下载碎片？",
                  okText: "下载",
                  cancelText: "等会下",
                  onOk: () async {
                    await c.allDownloadFragmentAndMemoryInfos(memoryGroupId: memoryGroupId);
                  },
                ),
              );
            },
          );
        }
        if (c.fragmentAndMemoryInfoStatus(abw) == FragmentAndMemoryInfoStatus.differentDownload) {
          return FloatingRoundCornerButton(
            color: Colors.grey,
            text: const Text('碎片数量不同步', style: TextStyle(color: Colors.white)),
            onPressed: () async {
              await showCustomDialog(
                builder: (ctx) => OkAndCancelDialogWidget(
                  text: "碎片数量不同步，是否进行数量同步？",
                  okText: "同步",
                  cancelText: "直接开始",
                  onOk: () async {
                    await c.differentFragmentAndMemoryInfos();
                  },
                  onCancel: () async {
                    await c.clickStart();
                  },
                ),
              );
            },
          );
        }
        return FloatingRoundCornerButton(
          color: Colors.amberAccent,
          text: Text(c.memoryGroupAb(abw).start_time == null ? '开始' : "继续", style: TextStyle(color: Colors.white)),
          onPressed: () async {
            await c.clickStart();
          },
        );
      },
    );
  }

  Widget _appBarTitleWidget() {
    return AbBuilder<MemoryGroupGizmoEditPageAbController>(
      builder: (c, abw) {
        return Text(c.memoryGroupAb(abw).title);
      },
    );
  }

  /// 叉号
  Widget _appBarLeadingWidget() {
    return AbBuilder<MemoryGroupGizmoEditPageAbController>(
      builder: (c, abw) {
        return IconButton(
          icon: const Icon(FontAwesomeIcons.xmark, color: Colors.red),
          onPressed: () {
            c.abBack();
          },
        );
      },
    );
  }

  /// 对号
  Widget _appBarRightButtonWidget() {
    return AbBuilder<MemoryGroupGizmoEditPageAbController>(
      builder: (c, abw) {
        return Row(
          children: [
            TextButton(
              child: const Text('仅保存'),
              onPressed: () async {
                final isSavedSuccess = await c.onlySave();
                if (isSavedSuccess) {
                  c.abBack();
                }
              },
            ),
          ],
        );
      },
    );
  }
}
