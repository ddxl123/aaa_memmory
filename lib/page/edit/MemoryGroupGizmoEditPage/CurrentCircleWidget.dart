import 'package:aaa_memory/tool/other.dart';
import 'package:drift_main/share_common/share_enum.dart';
import 'package:flutter/material.dart';
import 'package:tools/tools.dart';

import '../../../single_dialog/showSelectMemoryAlgorithmInMemoryGroupDialog.dart';
import 'MemoryGroupGizmoEditPageAbController.dart';

class CurrentCircleWidget extends StatelessWidget {
  const CurrentCircleWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return AbBuilder<MemoryGroupGizmoEditPageAbController>(
      builder: (c, abw) {
        return Padding(
          padding: EdgeInsets.all(5),
          child: Column(
            children: [
              _titleWidget(),
              SizedBox(height: 10),
              Divider(color: Colors.black12, height: 30),
              Column(
                children: [
                  Row(
                    children: [
                      SizedBox(width: 10),
                      Text("记忆算法", style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                  SizedBox(height: 10),
                  _memoryAlgorithmWidget(),
                  SizedBox(height: 10),
                  _memoryLoopCycleWidget(),
                  SizedBox(height: 10),
                  _newCountWidget(),
                  SizedBox(height: 10),
                  _reviewCountWidget(),
                ],
              ),
              Divider(color: Colors.black12, height: 30),
              Column(
                children: [
                  Row(
                    children: [
                      SizedBox(width: 10),
                      Text("碎片展示顺序", style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                  SizedBox(height: 10),
                  _newReviewDisplayOrder(),
                  _newDisplayOrder(),
                  _reviewDisplayOrder(),
                ],
              ),
              floatingRoundCornerButtonPlaceholderBox(60),
            ],
          ),
        );
      },
    );
  }

  Widget _titleWidget() {
    return AbBuilder<MemoryGroupGizmoEditPageAbController>(
      builder: (c, abw) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 10),
          child: Row(
            children: [
              const Text('名称：'),
              Expanded(
                child: TextField(
                  controller: c.titleTextEditingController,
                  style: const TextStyle(fontSize: 14),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: '请输入...',
                    hintStyle: TextStyle(fontSize: 14),
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                  scrollPadding: EdgeInsets.zero,
                  onChanged: (v) {
                    c.cloneSingleMemoryGroup.refreshInevitable((obj) => obj..memoryGroup.title = v);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _memoryAlgorithmWidget() {
    return AbBuilder<MemoryGroupGizmoEditPageAbController>(
      builder: (c, abw) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 10),
          child: Row(
            children: [
              const Text('使用算法：'),
              TextButton(
                style: ButtonStyle(visualDensity: kMinVisualDensity),
                child: Text(c.cloneSingleMemoryGroup(abw).currentSmallCycleInfo?.getMemoryAlgorithm?.title ?? '点击选择'),
                onPressed: () async {
                  await showSelectMemoryAlgorithmInMemoryGroupDialog(mgAndOtherAb: c.cloneSingleMemoryGroup);
                  await c.cloneSingleMemoryGroup().currentSmallCycleInfo?.read();
                  abw.refresh();
                  c.cloneSingleMemoryGroup.refreshForce();
                },
              ),
              // TODO:
              // Text("模拟(验证算法的正确性)"),
            ],
          ),
        );
      },
    );
  }

  Widget _memoryLoopCycleWidget() {
    return AbBuilder<MemoryGroupGizmoEditPageAbController>(
      builder: (c, abw) {
        final lc = c.cloneSingleMemoryGroup(abw).currentSmallCycleInfo?.loopCycle;
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 10),
          child: Row(
            children: [
              const Text('循环周期：'),
              Expanded(
                child: Text(lc?.toText() ?? "未设置", style: TextStyle(color: Colors.grey)),
              ),
              SizedBox(width: 10),
              CustomTooltip(
                texts: [
                  CustomTooltipText(text: "1. 跟随算法中的循环周期设置"),
                  if (lc == null) CustomTooltipText(text: "2. [未设置]"),
                  if (lc != null)
                    // TODO：查询描述
                    CustomTooltipText(
                        text: "2. 以接下来最近的 [${lc.startSmallCycle.getHmText}] 为起始时间点，"
                            "分别以 ${lc.toTextWithoutStart()} 小时为累加周期。"),
                ],
              ),
              // TODO:
              // Text("模拟(验证算法的正确性)"),
            ],
          ),
        );
      },
    );
  }

  Widget _newCountWidget() {
    return AbBuilder<MemoryGroupGizmoEditPageAbController>(
      builder: (c, abw) {
        final csi = c.cloneSingleMemoryGroup(abw).currentSmallCycleInfo!;
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 10),
          child: Row(
            children: [
              const Text('新碎片数量：'),
              Expanded(
                child: Text(
                  "${csi.learnedThirdNewAndReviewCount?.newCount ?? "-"}/${csi.shouldNewAndReviewCount?.newCount ?? "-"}",
                ),
              ),
              SizedBox(width: 10),
            ],
          ),
        );
      },
    );
  }

  Widget _reviewCountWidget() {
    return AbBuilder<MemoryGroupGizmoEditPageAbController>(
      builder: (c, abw) {
        final csi = c.cloneSingleMemoryGroup(abw).currentSmallCycleInfo!;
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 10),
          child: Row(
            children: [
              const Text('复习碎片数量：'),
              Expanded(
                child: Text(
                  "${csi.learnedThirdNewAndReviewCount?.reviewCount ?? "-"}/${csi.shouldNewAndReviewCount?.reviewCount ?? "-"}"
                  "  (+${csi.learnedThirdNewAndReviewCount?.newReviewCount ?? "-"})",
                ),
              ),
              SizedBox(width: 10),
            ],
          ),
        );
      },
    );
  }

  Widget _newReviewDisplayOrder() {
    return AbBuilder<MemoryGroupGizmoEditPageAbController>(
      builder: (c, abw) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
          child: Row(
            children: [
              const Text('新 | 复习碎片：'),
              Spacer(),
              CustomDropdownBodyButton<NewReviewDisplayOrder>(
                initValue: c.cloneSingleMemoryGroup(abw).memoryGroup.new_review_display_order,
                items: [
                  CustomItem(value: NewReviewDisplayOrder.mix, text: '混合'),
                  CustomItem(value: NewReviewDisplayOrder.new_review, text: '优先新碎片'),
                  CustomItem(value: NewReviewDisplayOrder.review_new, text: '优先复习碎片'),
                ],
                onChanged: (v) {
                  c.cloneSingleMemoryGroup.refreshInevitable((obj) => obj..memoryGroup.new_review_display_order = v!);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _newDisplayOrder() {
    return AbBuilder<MemoryGroupGizmoEditPageAbController>(
      builder: (c, abw) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
          child: Row(
            children: [
              const Text('新碎片：'),
              Spacer(),
              CustomDropdownBodyButton<NewDisplayOrder>(
                initValue: c.cloneSingleMemoryGroup(abw).memoryGroup.new_display_order,
                items: [
                  CustomItem(value: NewDisplayOrder.random, text: '随机'),
                  CustomItem(value: NewDisplayOrder.title_a_2_z, text: '标题首字母A~Z顺序'),
                  CustomItem(value: NewDisplayOrder.create_early_2_late, text: '创建时间'),
                ],
                onChanged: (v) {
                  c.cloneSingleMemoryGroup.refreshInevitable((obj) => obj..memoryGroup.new_display_order = v!);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _reviewDisplayOrder() {
    return AbBuilder<MemoryGroupGizmoEditPageAbController>(
      builder: (c, abw) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
          child: Row(
            children: [
              const Text('复习碎片：'),
              Spacer(),
              CustomDropdownBodyButton<ReviewDisplayOrder>(
                initValue: c.cloneSingleMemoryGroup(abw).memoryGroup.review_display_order,
                items: [
                  CustomItem(value: ReviewDisplayOrder.expire_first, text: '过期优先'),
                  CustomItem(value: ReviewDisplayOrder.no_expire_first, text: '未过期优先'),
                  CustomItem(value: ReviewDisplayOrder.ignore_expire, text: '忽略过期'),
                ],
                onChanged: (v) {
                  c.cloneSingleMemoryGroup.refreshInevitable((obj) => obj..memoryGroup.review_display_order = v!);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

// class ReviewIntervalWidget extends StatefulWidget {
//   const ReviewIntervalWidget({super.key});
//
//   @override
//   State<ReviewIntervalWidget> createState() => _ReviewIntervalWidgetState();
// }
//
// class _ReviewIntervalWidgetState extends State<ReviewIntervalWidget> {
//   final MemoryGroupGizmoEditPageAbController c = Aber.find<MemoryGroupGizmoEditPageAbController>();
//
//   DateTime reviewInterval = DateTime.now();
//
//   int reviewIntervalCount = 0;
//
//   @override
//   void initState() {
//     super.initState();
//     queryCountForReviewInterval();
//   }
//
//   Future<void> queryCountForReviewInterval() async {
//     final mgAndOther = c.cloneSingleMemoryGroup();
//     if (mgAndOther.memoryGroup.study_status == StudyStatus.not_startup) {
//       return;
//     }
//     final diff = reviewInterval.difference(mgAndOther.memoryGroup.start_time!);
//     final count = driftDb.fragmentMemoryInfos.id.count();
//     final sel = driftDb.selectOnly(driftDb.fragmentMemoryInfos);
//     sel.where(
//       driftDb.fragmentMemoryInfos.memory_group_id.equals(mgAndOther.memoryGroup.id) &
//           driftDb.fragmentMemoryInfos.study_status.equalsValue(FragmentMemoryInfoStudyStatus.review) &
//           driftDb.fragmentMemoryInfos.next_plan_show_time.jsonExtract(r"$[#-1]").dartCast<int>().isSmallerOrEqualValue(diff.inSeconds),
//     );
//     sel.addColumns([count]);
//     final result = await sel.get();
//     reviewIntervalCount = result.first.read(count)!;
//     setState(() {});
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return AbBuilder<MemoryGroupGizmoEditPageAbController>(
//       builder: (c, abw) {
//         return Padding(
//           padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 10),
//           child: Row(
//             children: [
//               Expanded(
//                 child: RichText(
//                   text: TextSpan(
//                     text: "复习接下来 ",
//                     children: [
//                       TextSpan(
//                         text: time2TextTime(
//                           longSeconds: c.cloneSingleMemoryGroup(abw).memoryGroup.review_interval.difference(DateTime.now()).inSeconds,
//                           canNegative: true,
//                         ),
//                         style: TextStyle(decoration: TextDecoration.underline),
//                         recognizer: TapGestureRecognizer()
//                           ..onTap = () {
//                             DatePicker.showDateTimePicker(
//                               c.context,
//                               locale: LocaleType.zh,
//                               minTime: DateTime.now(),
//                               currentTime: c.cloneSingleMemoryGroup(abw).memoryGroup.review_interval,
//                               onChanged: (v) {
//                                 c.cloneSingleMemoryGroup.refreshInevitable((obj) => obj..memoryGroup.review_interval = v);
//                                 queryCountForReviewInterval();
//                               },
//                             );
//                           },
//                       ),
//                       TextSpan(
//                         text: " 前需要复习的 ",
//                       ),
//                       TextSpan(
//                         text: "${c.cloneSingleMemoryGroup().reviewIntervalCount}",
//                       ),
//                       TextSpan(text: " 个碎片")
//                     ],
//                     style: TextStyle(color: Colors.black),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }
// }
