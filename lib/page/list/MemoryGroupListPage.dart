import 'dart:math';

import 'package:dotted_border/dotted_border.dart';
import 'package:tools/tools.dart';
import 'package:drift_main/drift/DriftDb.dart';
import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../../single_dialog/showCreateMemoryGroupDialog.dart';
import '../gizmo/MemoryGroupGizmoPage.dart';
import 'MemoryGroupListPageAbController.dart';

class MemoryGroupListPage extends StatelessWidget {
  const MemoryGroupListPage({super.key, required this.user});

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
            },
          );
        },
      ),
      floatingActionButton: CustomRoundCornerButton(
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
        return c.singleMemoryGroupsAb(abw).isEmpty
            ? const SliverToBoxAdapter(child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [Text("还没有创建记忆任务~")]))
            : SliverList(
                delegate: SliverChildBuilderDelegate(
                  (ctx, index) {
                    return _memoryGroupGizmoWidget(index);
                  },
                  childCount: c.singleMemoryGroupsAb(abw).length,
                ),
              );
      },
    );
  }

  /// 总共xxx个，总已完成xxx个，总待复习xxx个，总待新学xxx个
  /// 总约定期限xxx，剩余期限xxx，在学时长xxx
  /// 本周期共xxx个，已完成xxx个，待复习xxx个，待新学xxx个
  /// 本周期约定期限xxx，剩余期限xxx，在学时长xxx
  Widget _memoryGroupGizmoWidget(int index) {
    return AbBuilder<MemoryGroupListPageAbController>(
      tag: Aber.single,
      builder: (c, abw) {
        final singleMgAb = c.singleMemoryGroupsAb(abw)[index];

        return Hero(
          tag: singleMgAb.hashCode,
          child: GestureDetector(
            child: Card(
              child: Padding(
                padding: EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            singleMgAb(abw).memoryGroup.title,
                            style: Theme.of(c.context).textTheme.titleMedium,
                          ),
                        ),
                        Icon(Icons.chevron_right, color: Colors.grey, size: 18),
                      ],
                    ),
                    Divider(color: Colors.grey.withOpacity(0.2)),
                    SizedBox(height: 10),
                    Row(
                      children: [
                        DottedBorder(
                          borderType: BorderType.RRect,
                          radius: Radius.circular(5),
                          color: Colors.grey,
                          padding: EdgeInsets.all(5),
                          child: Column(
                            children: [
                              Text("本"),
                              Text("周"),
                              Text("期"),
                              Transform.rotate(
                                angle: pi / 2,
                                child: Icon(Icons.arrow_right, color: Colors.black, size: 14),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: EdgeInsets.fromLTRB(10, 2, 10, 2),
                                    decoration: BoxDecoration(color: Colors.orangeAccent.withOpacity(0.3), borderRadius: BorderRadius.circular(50)),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text("待新学", style: TextStyle(color: Colors.deepOrange)),
                                        Text("  ●  ", style: TextStyle(fontSize: 8, color: Colors.deepOrange)),
                                        Text("${singleMgAb(abw).currentSmallCycleInfo?.getNotLearnNewAndReviewCount?.newCount}", style: TextStyle(color: Colors.deepOrange)),
                                      ],
                                    ),
                                  ),
                                  SizedBox(width: 10),
                                  Container(
                                    padding: EdgeInsets.fromLTRB(10, 2, 10, 2),
                                    decoration: BoxDecoration(color: Colors.amberAccent.withOpacity(0.3), borderRadius: BorderRadius.circular(50)),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text("待复习", style: TextStyle(color: Colors.orange)),
                                        Text("  ●  ", style: TextStyle(fontSize: 8, color: Colors.orange)),
                                        Text("${singleMgAb(abw).currentSmallCycleInfo?.getNotLearnNewAndReviewCount?.reviewCount}", style: TextStyle(color: Colors.orange)),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 20),
                              _proportion(index),
                              SizedBox(height: 10),
                              Row(
                                // crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Expanded(
                                    child: RichText(
                                      text: TextSpan(
                                        style: TextStyle(color: Colors.grey, fontSize: 12),
                                        text: "剩余期限 ",
                                        children: [
                                          TextSpan(
                                            style: TextStyle(color: Colors.black),
                                            text: "xxx",
                                          ),
                                          TextSpan(
                                            style: TextStyle(color: Colors.grey),
                                            text: "    在学时长 ",
                                            children: [
                                              TextSpan(
                                                style: TextStyle(color: Colors.grey),
                                                text: "xxx",
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  AbwBuilder(
                                    builder: (abw) {
                                      return StatusButton(
                                        listPageC: c,
                                        editPageC: null,
                                        singleMemoryGroupAb: singleMgAb,
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
            onTap: () {
              Navigator.push(
                c.context,
                MaterialPageRoute(
                  builder: (_) => MemoryGroupGizmoPage(
                    memoryGroupGizmo: singleMgAb().memoryGroup,
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

  Widget _proportion(int index) {
    return AbBuilder<MemoryGroupListPageAbController>(
      tag: Aber.single,
      builder: (c, abw) {
        final currentSmallCycleInfo = c.singleMemoryGroupsAb(abw)[index]().currentSmallCycleInfo;
        return Row(
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(50),
                child: Container(
                  decoration: BoxDecoration(color: Colors.grey.withOpacity(0.3)),
                  height: 8,
                  child: Row(
                    children: [
                      Flexible(
                        flex: currentSmallCycleInfo?.learnedNewAndReviewCount.newCount ?? 0,
                        child: Container(
                          decoration: BoxDecoration(color: Colors.green),
                        ),
                      ),
                      Flexible(
                        flex: currentSmallCycleInfo?.getNotLearnNewAndReviewCount?.newCount ?? 0,
                        child: Container(
                          decoration: BoxDecoration(color: Colors.orange),
                        ),
                      ),
                      Flexible(
                        flex: currentSmallCycleInfo?.getNotLearnNewAndReviewCount?.reviewCount ?? 0,
                        child: Container(
                          decoration: BoxDecoration(color: Colors.amberAccent),
                        ),
                      ),
                      Flexible(
                        flex: (currentSmallCycleInfo?.shouldNewAndReviewCount?.getNewAndReviewCount ?? 0) -
                            (currentSmallCycleInfo?.learnedNewAndReviewCount.getNewAndReviewCount ?? 0),
                        child: Container(
                            // decoration: BoxDecoration(color: Colors.g.withOpacity(0.3), borderRadius: BorderRadius.circular(50)),
                            ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // Text(" ${}/${currentSmallCycleInfo(abw).cycleFragmentCount}", style: TextStyle(color: Colors.grey, fontSize: 12)),
            SizedBox(width: 10),
          ],
        );
      },
    );
  }
}
