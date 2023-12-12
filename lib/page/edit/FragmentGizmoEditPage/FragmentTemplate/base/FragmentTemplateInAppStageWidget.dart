import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';

import 'FragmentTemplate.dart';

/// 记忆展示状态下的基本 Widget。
class FragmentTemplateInAppStageWidget extends StatefulWidget {
  const FragmentTemplateInAppStageWidget({
    super.key,
    required this.fragmentTemplate,
    required this.onTap,
    required this.columnChildren,
    this.moreChildren,
    this.bottomSheet,
  });

  final FragmentTemplate fragmentTemplate;

  final FutureOr<void> Function() onTap;

  final List<Widget> columnChildren;

  final List<SpeedDialChild>? moreChildren;

  final Widget? bottomSheet;

  @override
  State<FragmentTemplateInAppStageWidget> createState() => _FragmentTemplateInAppStageWidgetState();
}

class _FragmentTemplateInAppStageWidgetState extends State<FragmentTemplateInAppStageWidget> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onTap: widget.onTap,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(15),
                physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                child: Column(
                  children: [
                    ...widget.columnChildren,
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: widget.moreChildren == null
          ? null
          : SpeedDial(
              icon: Icons.more_horiz,
              activeIcon: Icons.close_outlined,
              overlayOpacity: 0.2,
              overlayColor: Colors.black,
              children: widget.moreChildren!,
            ),
    );
  }
}
