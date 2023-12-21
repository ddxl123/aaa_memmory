import 'package:tools/tools.dart';
import 'package:drift_main/drift/DriftDb.dart';
import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../../single_dialog/showCreateMemoryGroupDialog.dart';
import '../gizmo/MemoryGroupGizmoPage.dart';
import 'MemoryGroupListPageAbController.dart';

class MemoryGroupListPage extends StatelessWidget {
  const MemoryGroupListPage({Key? key, required this.user}) : super(key: key);
  final User user;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AbBuilder<MemoryGroupListPageAbController>(
        putController: MemoryGroupListPageAbController(user: user),
        tag: Aber.single,
        builder: (c, putAbw) {
          return SmartRefresher(
            controller: c.refreshController,
            physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(child: SizedBox(height: 30)),
                _memoryGroupGizmoList(c.context),
                SliverToBoxAdapter(child: SizedBox(height: 80)),
              ],
            ),
            onRefresh: () async {
              await Future.delayed(const Duration(milliseconds: 200));
              await c.refreshPage();
              c.refreshController.refreshCompleted();
            },
          );
        },
      ),
      floatingActionButton: FloatingRoundCornerButton(
        text: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.science_sharp),
            SizedBox(width: 10),
            Text("新增记忆组"),
          ],
        ),
        onPressed: () {
          showCreateMemoryGroupDialog();
        },
      ),
    );
  }

  Widget _memoryGroupGizmoList(BuildContext context) {
    return AbBuilder<MemoryGroupListPageAbController>(
      tag: Aber.single,
      builder: (c, abw) {
        return c.memoryGroupAndOthersAb(abw).isEmpty
            ? const SliverToBoxAdapter(child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [Text("还没有创建记忆任务~")]))
            : SliverList(
                delegate: SliverChildBuilderDelegate(
                  (ctx, index) {
                    return _memoryGroupGizmoWidget(index);
                  },
                  childCount: c.memoryGroupAndOthersAb(abw).length,
                ),
              );
      },
    );
  }

  Color _statusButtonBackgroundColorFilter(MemoryGroup memoryGroup) {
    if (memoryGroup.start_time == null) {
      return Colors.amberAccent;
    } else if (memoryGroup.start_time == DateTime.fromMicrosecondsSinceEpoch(0)) {
      return Colors.grey;
    } else {
      return Colors.greenAccent;
    }
  }

  String _statusButtonTextFilter(MemoryGroup memoryGroup) {
    if (memoryGroup.start_time == null) {
      return '未执行';
    } else if (memoryGroup.start_time == DateTime.fromMicrosecondsSinceEpoch(0)) {
      return '已完成';
    } else {
      return '继续';
    }
  }

  Widget _memoryGroupGizmoWidget(int index) {
    return AbBuilder<MemoryGroupListPageAbController>(
      tag: Aber.single,
      builder: (c, abw) {
        final mgAndOther = c.memoryGroupAndOthersAb(abw)[index];
        return Hero(
          tag: mgAndOther.hashCode,
          child: GestureDetector(
            child: Card(
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          mgAndOther.memoryGroup.title,
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                      AbwBuilder(
                        builder: (abw) {
                          return OutlinedButton(
                            style: ButtonStyle(
                              side: MaterialStateProperty.all(const BorderSide(color: Colors.blue, width: 1)),
                              backgroundColor: MaterialStateProperty.all(_statusButtonBackgroundColorFilter(mgAndOther.memoryGroup)),
                            ),
                            child: () {
                              return Text(_statusButtonTextFilter(mgAndOther.memoryGroup));
                            }(),
                            onPressed: () {
                              c.onStatusTap(mgAndOther.memoryGroup);
                            },
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
            onTap: () {
              Navigator.push(
                c.context,
                MaterialPageRoute(
                  builder: (_) => MemoryGroupGizmoPage(
                    memoryGroupGizmo: mgAndOther.memoryGroup,
                    innerMemoryGroupGizmoWidget: _memoryGroupGizmoWidget(index),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
