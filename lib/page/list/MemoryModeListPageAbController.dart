import 'package:drift_main/drift/DriftDb.dart';
import 'package:drift_main/httper/httper.dart';
import 'package:tools/tools.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../../global/GlobalAbController.dart';

class MemoryModeListPageAbController extends AbController {
  final RefreshController refreshController = RefreshController(initialRefresh: true);

  final memoryModelsAb = <MemoryModel>[].ab;

  @override
  void onDispose() {
    refreshController.dispose();
    super.onDispose();
  }

  Future<void> refreshPage() async {
    await driftDb.cloudOverwriteLocalDAO.queryCloudAllMemoryModelOverwriteLocal(
      userId: Aber.find<GlobalAbController>().loggedInUser()!.id,
      onSuccess: (mms) async {
        memoryModelsAb.refreshInevitable((obj) => obj
          ..clear()
          ..addAll(mms));
      },
      onError: (int? code, HttperException httperException, StackTrace st) async {
        logger.outErrorHttp(code: code, showMessage: httperException.showMessage, debugMessage: httperException.debugMessage, st: st);
      },
    );
  }
}
