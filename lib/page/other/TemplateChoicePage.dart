import 'package:aaa_memory/page/edit/FragmentGizmoEditPage/FragmentTemplate/base/FragmentTemplate.dart';
import 'package:aaa_memory/page/edit/FragmentGizmoEditPage/FragmentTemplate/template/blank/BlankFragmentTemplate.dart';
import 'package:aaa_memory/page/edit/FragmentGizmoEditPage/FragmentTemplate/template/true_false/TFFragmentTemplate.dart';
import 'package:flutter/material.dart';

import '../edit/FragmentGizmoEditPage/FragmentTemplate/template/choice/ChoiceFragmentTemplate.dart';
import '../edit/FragmentGizmoEditPage/FragmentTemplate/template/question_answer/QAFragmentTemplate.dart';
import '../edit/FragmentGizmoEditPage/FragmentTemplate/template/single/SimpleFragmentTemplate.dart';

class SingleTemplateChoicePage extends StatelessWidget {
  const SingleTemplateChoicePage({
    super.key,
    required this.title,
    required this.explain,
    required this.onTap,
  });

  final String title;
  final String explain;
  final void Function() onTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Card(
            elevation: 2,
            margin: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
            child: GestureDetector(
              onTap: onTap,
              child: Padding(
                padding: EdgeInsets.all(15),
                child: Column(
                  children: [
                    Text(title, style: Theme.of(context).textTheme.titleMedium),
                    SizedBox(height: 5),
                    Text(explain, style: TextStyle(color: Colors.grey)),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class TemplateChoice extends StatelessWidget {
  const TemplateChoice({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.chevron_left, size: 30),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text("请选择一种模板"),
        actions: [TextButton(onPressed: () {}, child: const Text("求助制作"))],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            SingleTemplateChoicePage(
              title: "AI 解析",
              explain: "输入任意文本，给予提示词，AI 自动解析并生成碎片",
              onTap: () {
                Navigator.pop(context, SimpleFragmentTemplate(performType: PerformType.edit));
              },
            ),
            SingleTemplateChoicePage(
              title: "单面碎片",
              explain: "只有一面",
              onTap: () {
                Navigator.pop(context, SimpleFragmentTemplate(performType: PerformType.edit));
              },
            ),
            SingleTemplateChoicePage(
              title: "问答题",
              explain: "有问有答",
              onTap: () {
                Navigator.pop(context, QAFragmentTemplate(performType: PerformType.edit));
              },
            ),
            SingleTemplateChoicePage(
              title: "选择题",
              explain: "单选或多选",
              onTap: () {
                Navigator.pop(context, ChoiceFragmentTemplate(performType: PerformType.edit));
              },
            ),
            SingleTemplateChoicePage(
              title: "判断题",
              explain: "只有对与错",
              onTap: () {
                Navigator.pop(context, TFFragmentTemplate(performType: PerformType.edit));
              },
            ),
            SingleTemplateChoicePage(
              title: "填空题",
              explain: "将挖空部分隐藏",
              onTap: () {
                Navigator.pop(context, BlankFragmentTemplate(performType: PerformType.edit));
              },
            ),
          ],
        ),
      ),
    );
  }
}
