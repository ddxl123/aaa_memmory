import 'package:tools/tools.dart';
import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../../push_page/push_page.dart';
import '../../single_dialog/showCreateMemoryModelDialog.dart';
import 'MemoryModeListPageAbController.dart';

class MemoryModeListPage extends StatelessWidget {
  const MemoryModeListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AbBuilder<MemoryModeListPageAbController>(
      putController: MemoryModeListPageAbController(),
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
              showCreateMemoryModelDialog();
            },
          ),
        );
      },
    );
  }

  Widget _body() {
    return AbBuilder<MemoryModeListPageAbController>(
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
    return AbBuilder<MemoryModeListPageAbController>(
      tag: Aber.single,
      builder: (c, abw) {
        return c.memoryModelsAb(abw).isEmpty
            ? SliverToBoxAdapter(child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [Text("还没有记忆算法~")]))
            : SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    return Row(
                      children: [
                        Expanded(
                          child: TextButton(
                            child: Text(c.memoryModelsAb()[index].title.toString()),
                            onPressed: () {
                              pushToMemoryModelGizmoEditPage(context: context, memoryModel: c.memoryModelsAb()[index]);
                            },
                          ),
                        ),
                      ],
                    );
                  },
                  childCount: c.memoryModelsAb(abw).length,
                ),
              );
      },
    );
  }
}
