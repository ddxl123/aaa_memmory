import 'package:aaa_memory/page/edit/FragmentGizmoEditPage/FragmentTemplate/template/blank/BlankFragmentTemplate.dart';
import 'package:aaa_memory/page/edit/FragmentGizmoEditPage/FragmentTemplate/template/blank/BlankFragmentTemplateInAppStageWidget.dart';
import 'package:aaa_memory/page/edit/FragmentGizmoEditPage/FragmentTemplate/template/true_false/TFFragmentTemplate.dart';
import 'package:aaa_memory/page/edit/FragmentGizmoEditPage/FragmentTemplate/template/true_false/TFFragmentTemplateInAppStageWidget.dart';
import 'package:tools/tools.dart';
import 'package:flutter/material.dart';

import '../edit/FragmentGizmoEditPage/FragmentTemplate/base/FragmentTemplate.dart';
import '../edit/FragmentGizmoEditPage/FragmentTemplate/template/choice/ChoiceFragmentTemplate.dart';
import '../edit/FragmentGizmoEditPage/FragmentTemplate/template/choice/ChoiceFragmentTemplateInAppStageWidget.dart';
import '../edit/FragmentGizmoEditPage/FragmentTemplate/template/question_answer/QAFragmentTemplate.dart';
import '../edit/FragmentGizmoEditPage/FragmentTemplate/template/question_answer/QAFragmentTemplateInAppStageWidget.dart';
import '../edit/FragmentGizmoEditPage/FragmentTemplate/template/single/SimpleFragmentTemplate.dart';
import '../edit/FragmentGizmoEditPage/FragmentTemplate/template/single/SimpleFragmentTemplateInAppStageWidget.dart';
import 'InAppStageAbController.dart';

class InAppStage extends StatefulWidget {
  const InAppStage({Key? key, required this.memoryGroupId}) : super(key: key);

  final int memoryGroupId;

  @override
  State<InAppStage> createState() => _InAppStageState();
}

// Dart
class _InAppStageState extends State<InAppStage> {
  late final InAppStageAbController inAppStageAbController;

  @override
  void initState() {
    super.initState();
    inAppStageAbController = InAppStageAbController(memoryGroupId: widget.memoryGroupId);
  }

  @override
  Widget build(BuildContext context) {
    return AbBuilder<InAppStageAbController>(
      putController: inAppStageAbController,
      builder: (c, abw) {
        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            actions: [_moreButtonWidget()],
          ),
          body: _body(),
          bottomNavigationBar: _bottomWidget(),
        );
      },
    );
  }

  Widget _moreButtonWidget() {
    return AbBuilder<InAppStageAbController>(
      builder: (c, abw) {
        return CustomDropdownBodyButton(
          initValue: 0,
          primaryButton: const Icon(Icons.more_horiz),
          items: [
            CustomItem(value: 0, text: c.isButtonDataShowValueAb(abw) ? '按钮显示时间' : '按钮显示算法数值'),
          ],
          onChanged: (v) {
            c.isButtonDataShowValueAb.refreshEasy((oldValue) => !oldValue);
          },
        );
      },
    );
  }

  Widget _bottomWidget() {
    return AbBuilder<InAppStageAbController>(
      builder: (c, abw) {
        if (c.currentPerformerAb(abw) == null) {
          return TextButton(
            child: const Text("确认"),
            onPressed: () {
              Navigator.pop(context);
            },
          );
        }
        if (!c.currentPerformerAb(abw)!.inAppStageAbController.isShowBottomButtonAb(abw)) {
          return const SizedBox();
        }
        if (c.currentButtonDatasAb(abw).isEmpty) {
          return const Row(children: [Expanded(child: Text('获取按钮数据分配为空！'))]);
        }
        return Row(
          children: c.currentButtonDatasAb().map(
            (e) {
              final parseTime = e.parseTimeToFixView(c.memoryGroup.start_time!);
              if (parseTime == null) {
                return const SizedBox(height: 0);
              }
              return Expanded(
                child: AbwBuilder(
                  builder: (abw) {
                    return TextButton(
                      child: Text(c.isButtonDataShowValueAb(abw) ? e.value.toString() : parseTime),
                      onPressed: () async {
                        // TODO:
                        await c.finishAndNext(clickValue: e.value, contentValue: []);
                      },
                    );
                  },
                ),
              );
            },
          ).toList(),
        );
      },
    );
  }

  Widget _body() {
    return AbBuilder<InAppStageAbController>(
      builder: (c, abw) {
        return c.currentPerformerAb(abw) == null
            ? const Center(
                child: Text('任务已全部完成！'),
              )
            : FragmentTemplate.templateSwitch(
                c.currentPerformerAb(abw)!.fragmentTemplate.fragmentTemplateType,
                questionAnswer: () {
                  return QAFragmentTemplateInAppStageWidget(
                    qaFragmentTemplate: c.currentPerformerAb(abw)!.fragmentTemplate as QAFragmentTemplate,
                  );
                },
                choice: () {
                  return ChoiceFragmentTemplateInAppStageWidget(
                    choiceFragmentTemplate: c.currentPerformerAb(abw)!.fragmentTemplate as ChoiceFragmentTemplate,
                  );
                },
                simple: () {
                  return SimpleFragmentTemplateInAppStageWidget(
                    simpleFragmentTemplate: c.currentPerformerAb(abw)!.fragmentTemplate as SimpleFragmentTemplate,
                  );
                },
                trueFalse: () {
                  return TFFragmentTemplateInAppStageWidget(
                    tfFragmentTemplate: c.currentPerformerAb(abw)!.fragmentTemplate as TFFragmentTemplate,
                  );
                },
                blank: () {
                  return BlankFragmentTemplateInAppStageWidget(
                    blankFragmentTemplate: c.currentPerformerAb(abw)!.fragmentTemplate as BlankFragmentTemplate,
                  );
                },
              );
      },
    );
  }
}
