import 'package:tools/tools.dart';
import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../../push_page/push_page.dart';
import '../../single_dialog/showCreateMemoryAlgorithmDialog.dart';
import 'MemoryAlgorithmListPageAbController.dart';

class MemoryAlgorithmListPage extends StatelessWidget {
  const MemoryAlgorithmListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AbBuilder<MemoryAlgorithmListPageAbController>(
      putController: MemoryAlgorithmListPageAbController(),
      tag: Aber.single,
      builder: (c, abw) {
        return Scaffold(
          body: _body(),
          floatingActionButton: CustomRoundCornerButton(
            text: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.science_sharp),
                SizedBox(width: 10),
                Text("新增算法"),
              ],
            ),
            onPressed: () {
              showCreateMemoryAlgorithmDialog();
            },
          ),
        );
      },
    );
  }

  Widget _body() {
    return AbBuilder<MemoryAlgorithmListPageAbController>(
      tag: Aber.single,
      builder: (c, abw) {
        return Padding(
          padding: const EdgeInsets.all(10),
          child: SmartRefresher(
            controller: c.refreshController,
            physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
            child: CustomScrollView(
              slivers: [
                _memoryModel(),
              ],
            ),
            onRefresh: () async {
              await c.refreshPage();
              c.refreshController.refreshCompleted();
            },
          ),
        );
      },
    );
  }

  Widget _memoryModel() {
    return AbBuilder<MemoryAlgorithmListPageAbController>(
      tag: Aber.single,
      builder: (c, abw) {
        return c.memoryAlgorithmsAb(abw).isEmpty
            ? SliverToBoxAdapter(child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [Text("还没有记忆算法~")]))
            : SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    return Row(
                      children: [
                        Expanded(
                          child: TextButton(
                            child: Text(c.memoryAlgorithmsAb()[index].title.toString()),
                            onPressed: () {
                              pushToMemoryAlgorithmGizmoEditPage(context: context, memoryAlgorithm: c.memoryAlgorithmsAb()[index]);
                            },
                          ),
                        ),
                      ],
                    );
                  },
                  childCount: c.memoryAlgorithmsAb(abw).length,
                ),
              );
      },
    );
  }
}
