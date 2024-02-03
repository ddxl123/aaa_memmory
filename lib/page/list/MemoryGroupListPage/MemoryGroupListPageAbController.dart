import 'package:drift_main/drift/DriftDb.dart';
import 'package:drift_main/httper/httper.dart';
import 'package:tools/tools.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../../edit/MemoryGroupGizmoEditPage/MemoryGroupGizmoEditPage.dart';
import '../../edit/edit_page_type.dart';
import 'SingleMemoryGroup.dart';
import 'StatusButton.dart';

class MemoryGroupListPageAbController extends AbController {
  MemoryGroupListPageAbController({required this.user});

  final User user;
  final RefreshController refreshController = RefreshController(initialRefresh: true);

  final singleMemoryGroupsAb = <Ab<SingleMemoryGroup>>[].ab;

  Future<void> refreshPage() async {
    await driftDb.cloudOverwriteLocalDAO.queryCloudAllMemoryGroupOverwriteLocal(
      userId: user.id,
      onSuccess: (List<MemoryGroup> memoryGroups) async {
        singleMemoryGroupsAb.refreshInevitable(
          (obj) => obj
            ..clearBroken(this)
            ..addAll(
              memoryGroups.map((e) => (SingleMemoryGroup(memoryGroup: e)..downloadStatus = DownloadStatus.other_loading).ab),
            ),
        );
        refreshController.refreshCompleted();
      },
      onError: (int? code, HttperException httperException, StackTrace st) async {
        logger.outErrorHttp(code: code, showMessage: httperException.showMessage, debugMessage: httperException.debugMessage, st: st);
        refreshController.refreshFailed();
      },
    );
    // 无需 await
    _forOthers();
  }

  Future<void> _forOthers() async {
    bool isSuccess = false;
    final newMemoryAlgorithms = <MemoryAlgorithm>[];
    await driftDb.cloudOverwriteLocalDAO.queryCloudAllMemoryAlgorithmOverwriteLocal(
      userId: user.id,
      onSuccess: (List<MemoryAlgorithm> memoryAlgorithms) async {
        newMemoryAlgorithms.addAll(memoryAlgorithms);
        isSuccess = true;
      },
      onError: (int? code, HttperException httperException, StackTrace st) async {
        logger.outErrorHttp(code: code, showMessage: httperException.showMessage, debugMessage: httperException.debugMessage, st: st);
      },
    );

    if (isSuccess) {
      for (var element in singleMemoryGroupsAb()) {
        // 如果记忆模型是被删除掉，则直接赋值为 null
        element().currentSmallCycleInfo?.setMemoryAlgorithm = newMemoryAlgorithms.where((mm) => element().memoryGroup.memory_algorithm_id == mm.id).firstOrNull;
        element.refreshForce();

        await element().queryAllSmallCycleInfos();
        element.refreshForce();

        // 无需 await
        _forOtherSingle(mgAndOtherAb: element);
      }
      singleMemoryGroupsAb.refreshForce();
    }
  }

  Future<void> _forOtherSingle({required Ab<SingleMemoryGroup> mgAndOtherAb}) async {
    await mgAndOtherAb().queryLocalTotalCount();
    singleMemoryGroupsAb.refreshForce();
    await mgAndOtherAb().queryCloudTotalCount();
    singleMemoryGroupsAb.refreshForce();
  }

  Future<void> onStatusTap(Ab<SingleMemoryGroup> cloneSingleMemoryGroupAb) async {
    await showCustomDialog(
      builder: (ctx) {
        return MemoryGroupGizmoEditPage(
          editPageType: MemoryGroupGizmoEditPageType.modify,
          cloneSingleMemoryGroupAb: cloneSingleMemoryGroupAb,
          listPageC: this,
        );
      },
    );
    // await pushToMemoryGroupGizmoEditPageOfModify(context: context, memoryGroupId: memoryGroupGizmo.id);
    await refreshPage();
  }
}
