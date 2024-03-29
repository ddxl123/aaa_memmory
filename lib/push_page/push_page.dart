import 'package:drift_main/drift/DriftDb.dart';
import 'package:flutter/material.dart';
import 'package:tools/tools.dart';

import '../home/personal_home_page/PersonalHomePage.dart';
import '../page/edit/FragmentGizmoEditPage/FragmentGizmoEditPage.dart';
import '../page/edit/FragmentGizmoEditPage/FragmentTemplate/base/FragmentTemplate.dart';
import '../page/edit/FragmentGroupGizmoEditPage.dart';
import '../page/edit/MemoryAlgorithmGizmoEditPage/MemoryAlgorithmGizmoEditPage.dart';
import '../page/edit/ShorthandGizmoEditPage.dart';
import '../page/fragment_group_view/FragmentGroupListView.dart';
import '../page/fragment_group_view/FragmentGroupSelectView.dart';
import '../page/login_register/LoginPage.dart';
import '../page/other/FollowListPage.dart';
import '../page/other/TemplateChoicePage.dart';
import '../page/stage/InAppStage.dart';
import '../page/stage/fragment_template_pages/MultiFragmentTemplatePage.dart';
import '../page/stage/fragment_template_pages/SingleFragmentTemplatePage.dart';

Future<void> pushToMemoryAlgorithmGizmoEditPage({
  required BuildContext context,
  required Ab<MemoryAlgorithm> cloneMemoryAlgorithmAb,
}) async {
  await Navigator.push(
    context,
    MaterialPageRoute(
      builder: (ctx) => MemoryAlgorithmGizmoEditPage(
        cloneMemoryAlgorithmAb: cloneMemoryAlgorithmAb,
      ),
    ),
  );
}

/// 返回选择的模板类型。
///
/// 返回 null 表示取消选择。
Future<FragmentTemplate?> pushToTemplateChoice({required BuildContext context}) async {
  return await Navigator.push<FragmentTemplate>(
    context,
    MaterialPageRoute(builder: (ctx) => const TemplateChoice()),
  );
}

Future<void> pushToFragmentEditView({
  required BuildContext context,
  required Fragment? initFragmentAb,
  required FragmentTemplate initFragmentTemplate,
  required List<Fragment> initSomeBefore,
  required List<Fragment> initSomeAfter,
  required (FragmentGroup?, RFragment2FragmentGroup?)? enterDynamicFragmentGroups,
  required Ab<bool> isEditableAb,
  required bool isTailNew,
}) async {
  await Navigator.push(
    context,
    MaterialPageRoute(
      builder: (ctx) => FragmentGizmoEditPage(
        initSomeBefore: initSomeBefore,
        initSomeAfter: initSomeAfter,
        initFragment: initFragmentAb,
        enterDynamicFragmentGroups: enterDynamicFragmentGroups,
        isEditableAb: isEditableAb,
        isTailNew: isTailNew,
        initFragmentTemplate: initFragmentTemplate,
      ),
    ),
  );
}

Future<void> pushToLoginPage({required BuildContext context}) async {
  await Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => const LoginPage(),
    ),
  );
}

Future<void> pushToShorthandGizmoEditPage({
  required BuildContext context,
  required Shorthand? initShorthand,
}) async {
  await Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => ShorthandGizmoEditPage(initShorthand: initShorthand),
    ),
  );
}

Future<void> pushToInAppStage({
  required BuildContext context,
  required int memoryGroupId,
}) async {
  await Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => InAppStage(memoryGroupId: memoryGroupId),
    ),
  );
}

Future<void> pushToSingleFragmentTemplateView({
  required BuildContext context,
  required FragmentTemplate fragmentTemplate,
}) async {
  await Navigator.push(
    context,
    MaterialPageRoute(
      builder: (ctx) => SingleFragmentTemplatePage(fragmentTemplate: fragmentTemplate),
    ),
  );
}

Future<void> pushToMultiFragmentTemplateView({
  required BuildContext context,
  required List<Fragment> allFragments,
  required Fragment fragment,
}) async {
  await Navigator.push(
    context,
    MaterialPageRoute(
      builder: (ctx) => MultiFragmentTemplatePage(
        allFragments: allFragments,
        fragment: fragment,
      ),
    ),
  );
}

Future<void> pushToFragmentGroupListView({
  required BuildContext context,
  required int enterUserId,
  required int? enterFragmentGroupId,
}) async {
  await Navigator.push(
    context,
    MaterialPageRoute(
      builder: (ctx) => FragmentGroupListView(
        enterFragmentGroupId: enterFragmentGroupId,
        enterUserId: enterUserId,
      ),
    ),
  );
}

Future<void> pushToFragmentGroupGizmoEditPage({
  required BuildContext context,
  required Ab<FragmentGroup?> fragmentGroupAb,
}) async {
  await Navigator.push(
    context,
    MaterialPageRoute(
      builder: (ctx) => FragmentGroupGizmoEditPage(currentDynamicFragmentGroupAb: fragmentGroupAb),
    ),
  );
}

Future<void> pushToPersonalHomePage({
  required BuildContext context,
  required int userId,
}) async {
  await Navigator.push(
    context,
    MaterialPageRoute(
      builder: (ctx) => PersonalHomePage(userId: userId),
    ),
  );
}

/// 整个()返回 null，则为取消选择
///
/// 第一个为 null，则为选择了 root
///
/// 返回的是 dynamicFragmentGroup
Future<void> pushToFragmentGroupSelectView({
  required BuildContext context,
  required SelectResult selectResult,
}) async {
  await Navigator.push<(FragmentGroup?, void)>(
    context,
    MaterialPageRoute(builder: (ctx) => FragmentGroupSelectView(selectResult: selectResult)),
  );
}

Future<void> pushToFollowListPage({
  required BuildContext context,
  required int userId,
  required bool followOrBeFollowed,
}) async {
  await Navigator.push(
    context,
    MaterialPageRoute(
      builder: (ctx) => FollowListPage(userId: userId, followOrBeFollowed: followOrBeFollowed),
    ),
  );
}
