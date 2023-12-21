import 'package:drift_main/drift/DriftDb.dart';
import 'package:drift_main/httper/httper.dart';
import 'package:drift_main/share_common/share_enum.dart';
import 'package:flutter/cupertino.dart';
import 'package:tools/tools.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../../push_page/push_page.dart';
import '../edit/MemoryGroupGizmoEditPage/MemoryGroupGizmoEditPage.dart';
import '../edit/edit_page_type.dart';

enum FragmentAndMemoryInfoStatus {
  /// 只在加载中
  otherLoading,

  /// 加载失败
  otherLoadFail,

  /// 本地和云端数量都为 0
  zero,

  /// 本地和云端数量都不为 0，且数量相同
  allDownloaded,

  /// 本地数量为 0，云端数量不为 0
  neverDownloaded,

  /// 本地和云端数量都不为 0，但数量不一致
  /// 1. 已下载过，但是云端存在一些未下载的，需要下载云端未下载的
  /// 2. 需要删除本地多余的，只删除记忆信息，不删除碎片，因为其他记忆组内可能使用了。
  differentDownload,
}

class MemoryGroupAndOther {
  MemoryGroupAndOther({required this.memoryGroup});

  /// 注意是查询云端并覆盖本地后的
  final MemoryGroup memoryGroup;

  FragmentAndMemoryInfoStatus fragmentAndMemoryInfoStatus = FragmentAndMemoryInfoStatus.otherLoading;

  /// 当前记忆组碎片总数量
  ///
  /// 注意，先是本地查询后的数量，后进行数量同步后，才是云端同步后的数量。
  int fragmentCount = 0;

  /// 当前记忆组剩余未学习的数量，注意是查询云端并覆盖本地后的
  ///
  /// 注意，先是本地查询后的数量，后进行数量同步后，才是云端同步后的数量。
  int remainNeverFragmentsCount = 0;

  /// 当前记忆组的记忆算法，注意是查询云端并覆盖本地后的
  ///
  /// 如果记忆模型是被删除掉而未查询到，则直接赋值为 null
  MemoryModel? memoryModel;
}

class MemoryGroupListPageAbController extends AbController {
  MemoryGroupListPageAbController({required this.user});

  final User user;
  final RefreshController refreshController = RefreshController(initialRefresh: true);

  final memoryGroupAndOthersAb = <MemoryGroupAndOther>[].ab;

  /// TODO: 加载成功与失败的提示
  Future<void> refreshPage() async {
    await driftDb.cloudOverwriteLocalDAO.queryCloudAllMemoryGroupOverwriteLocal(
      userId: user.id,
      onSuccess: (List<MemoryGroup> memoryGroups) async {
        memoryGroupAndOthersAb.refreshInevitable(
          (obj) => obj
            ..clear()
            ..addAll(
              memoryGroups.map((e) => MemoryGroupAndOther(memoryGroup: e)..fragmentAndMemoryInfoStatus = FragmentAndMemoryInfoStatus.otherLoading),
            ),
        );
      },
      onError: (int? code, HttperException httperException, StackTrace st) async {
        logger.outErrorHttp(code: code, showMessage: httperException.showMessage, debugMessage: httperException.debugMessage, st: st);
      },
    );

    // 无需 await
    _forOthers();
  }

  Future<void> _forOthers() async {
    await driftDb.cloudOverwriteLocalDAO.queryCloudAllMemoryModelOverwriteLocal(
      userId: user.id,
      onSuccess: (List<MemoryModel> memoryModels) async {
        for (var element in memoryGroupAndOthersAb()) {
          // 如果记忆模型是被删除掉，则直接赋值为 null
          element.memoryModel = memoryModels.where((mm) => element.memoryGroup.memory_model_id == mm.id).firstOrNull;
          // 无需 await
          _forTotalCount(memoryGroupAndOther: element);
          _forRemainNeverStudyCount(memoryGroupAndOther: element);
        }
        memoryGroupAndOthersAb.refreshForce();
      },
      onError: (int? code, HttperException httperException, StackTrace st) async {
        logger.outErrorHttp(code: code, showMessage: httperException.showMessage, debugMessage: httperException.debugMessage, st: st);
      },
    );
  }

  /// TODO：当本地总数量与云端总数量相同时，但是存在修改时，该怎么办？
  Future<void> _forTotalCount({required MemoryGroupAndOther memoryGroupAndOther}) async {
    // 查询本地总数量
    final localTotalCount = await driftDb.generalQueryDAO.queryFragmentInMemoryGroupCount(memoryGroupId: memoryGroupAndOther.memoryGroup.id);
    memoryGroupAndOther.fragmentCount = localTotalCount;
    memoryGroupAndOthersAb.refreshForce();

    // 查询云端总数量
    final result = await request(
      path: HttpPath.GET__LOGIN_REQUIRED_MEMORY_GROUP_HANDLE_FRAGMENTS_COUNT_QUERY,
      dtoData: MemoryGroupFragmentsCountQueryDto(
        memory_group_id: memoryGroupAndOther.memoryGroup.id,
        dto_padding_1: null,
      ),
      parseResponseVoData: MemoryGroupFragmentsCountQueryVo.fromJson,
    );
    await result.handleCode(
      code160201: (String showMessage, vo) async {
        // 数量相关
        if (localTotalCount == 0 && vo.count == 0) {
          memoryGroupAndOther.fragmentAndMemoryInfoStatus = FragmentAndMemoryInfoStatus.zero;
          memoryGroupAndOthersAb.refreshForce();
          return;
        }
        if (localTotalCount == 0 && vo.count > 0) {
          memoryGroupAndOther.fragmentAndMemoryInfoStatus = FragmentAndMemoryInfoStatus.neverDownloaded;
          memoryGroupAndOthersAb.refreshForce();
          return;
        }
        if (localTotalCount != vo.count) {
          memoryGroupAndOther.fragmentAndMemoryInfoStatus = FragmentAndMemoryInfoStatus.differentDownload;
          memoryGroupAndOthersAb.refreshForce();
          return;
        }
      },
      otherException: (a, b, c) async {
        logger.outErrorHttp(code: a, showMessage: b.showMessage, debugMessage: b.debugMessage, st: c);
      },
    );
  }

  Future<void> _forRemainNeverStudyCount({required MemoryGroupAndOther memoryGroupAndOther}) async {
    final count = await driftDb.generalQueryDAO.queryManyFragmentByStudyStatusCount(
      memoryGroupId: memoryGroupAndOther.memoryGroup.id,
      studyStatus: StudyStatus.never,
    );
    memoryGroupAndOther.remainNeverFragmentsCount = count;
    memoryGroupAndOthersAb.refreshForce();
  }

  Future<void> onStatusTap(MemoryGroup memoryGroupGizmo) async {
    await showCustomDialog(
      builder: (ctx) {
        return MemoryGroupGizmoEditPage(
          editPageType: MemoryGroupGizmoEditPageType.modify,
          memoryGroupId: memoryGroupGizmo.id,
        );
      },
    );
    // await pushToMemoryGroupGizmoEditPageOfModify(context: context, memoryGroupId: memoryGroupGizmo.id);
    await refreshPage();
  }
}
