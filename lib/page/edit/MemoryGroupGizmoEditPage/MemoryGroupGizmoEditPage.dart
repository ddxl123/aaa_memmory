import 'package:tools/tools.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../list/MemoryGroupListPage/MemoryGroupListPageAbController.dart';
import '../../list/MemoryGroupListPage/SingleMemoryGroup.dart';
import '../../list/MemoryGroupListPage/StatusButton.dart';
import '../edit_page_type.dart';
import 'CurrentCircleWidget.dart';
import 'MemoryGroupGizmoEditPageAbController.dart';

class MemoryGroupGizmoEditPage extends StatelessWidget {
  const MemoryGroupGizmoEditPage({
    super.key,
    required this.editPageType,
    required this.cloneSingleMemoryGroupAb,
    required this.listPageC,
  });

  final MemoryGroupListPageAbController listPageC;
  final Ab<SingleMemoryGroup> cloneSingleMemoryGroupAb;
  final MemoryGroupGizmoEditPageType editPageType;

  @override
  Widget build(BuildContext context) {
    return AbBuilder<MemoryGroupGizmoEditPageAbController>(
      putController: MemoryGroupGizmoEditPageAbController(cloneSingleMemoryGroup: cloneSingleMemoryGroupAb, listPageC: listPageC),
      builder: (putController, putAbw) {
        return DialogWidget(
          fullPadding: EdgeInsets.fromLTRB(10, 0, 10, 0),
          topKeepWidget: Row(
            children: [
              _appBarLeadingWidget(),
              Text("本周期（小周期）", style: Theme.of(context).textTheme.titleMedium),
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
              child: StatusButton(
                listPageC: listPageC,
                editPageC: putController,
                singleMemoryGroupAb: cloneSingleMemoryGroupAb,
              ),
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

  Widget _appBarTitleWidget() {
    return AbBuilder<MemoryGroupGizmoEditPageAbController>(
      builder: (c, abw) {
        return Text(c.cloneSingleMemoryGroup(abw).memoryGroup.title);
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
